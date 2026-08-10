# Making new adventures

This repo contains the complete toolchain for building and playing new
text adventures on the original Zork engine:

```
your .zil source  ->  czil compiler  ->  game.z3 bytecode  ->  played by:
(rooms, objects,      (C, or the wasm     (Z-machine           - zorkllm + any LLM
 actions)              build in Node)      story file)          - any Z-machine app
```

Nothing at play time reads ZIL. The `.zil` files are source code; czil
compiles them once into a `.z3` story file; the JavaScript Z-machine in
`vendor/` executes that bytecode. The LLM layer sits on top and never
touches any of it.

`examples/tinyquest/` is a complete worked example: three rooms, a hidden
key, a locked container, a scored win condition. It compiles against the
Zork I engine files and its walkthrough replays byte-for-byte in CI. When
in doubt, copy it and diff against it.

This document covers the mechanics: ZIL, the engine files, the compiler.
If you are adapting an existing story (a public-domain novel) rather than
inventing one, read [ADAPTING.md](ADAPTING.md) first - it covers the
study-then-design process that has to happen before any of this, and the
`adventures/` directory holds worked examples of its output.

## Build and run

```sh
# native compiler (needs a C compiler once)
cd czil && make czil-compile && cd ..
czil/czil-compile examples/tinyquest/tinyquest.zil -I zil/zork1 -o tinyquest.z3

# or pure Node - no C toolchain needed (czil compiled to WebAssembly)
node czil/dist/czil-compile.mjs examples/tinyquest/tinyquest.zil -I zil/zork1 -o tinyquest.z3

# play it through an LLM
node src/cli.js tinyquest.z3

# or replay a scripted walkthrough (no LLM, deterministic - use this for tests)
node czil/tests/play.mjs tinyquest.z3 examples/tinyquest/walkthrough.txt
```

Both compilers produce byte-identical output. A full Zork-sized game
compiles in well under a second.

**Abbreviation compression is on by default** (the standard Z-machine
text compression; shrinks a Zork-sized game about 11% with zero behavior
change). `--no-abbrevs` skips the selection pass for the fastest
edit-test loop.

**v8 is the default target for new games.** A v3 story file tops out at
128KB, 32 flags, 31 properties, and 6-character dictionary words; the
engine already uses most of the flags. A version 8 story file gets more
of everything (512KB, 48 flags, 63 properties, 9-character dictionary
words), and czil compiles v8 whenever a source doesn't declare
otherwise (declare `<VERSION ZIP>` if you specifically want v3 - the
Zork sources do, which is how the trilogy still builds byte-faithful to
the shipped binaries):

```sh
node czil/dist/czil-compile.mjs game.zil -I zil/zork1 -I zil/engine-v8 -o game.z8
```

Two things make a v8 build work: add `-I zil/engine-v8` (a small
overlay that adapts the engine's parser internals to the v8 dictionary
format - the zork1 files themselves are never modified), and one line in
your main file after the GVERBS insert so the overlay loads only for
non-v3 builds:

```zil
<VERSION? (ZIP) (T <INSERT-FILE "V8PATCH" T>)>
```

Tiny Quest carries that line already, and the test suite proves its v8
build plays the identical transcript to its v3 build (it declares
`<VERSION ZIP>` and gets rebuilt as v8 with `-v 8`; a new game can
simply declare nothing and default to v8, or pin `<VERSION 8>`). One
difference: v5+ interpreters do not draw the v3 status line, so v8
games have no status bar (the zorkllm CLI prompt does not show one for
v8 games).

## The shape of a game

A game is one main file plus (at least) a dungeon file and an actions
file. The engine - parser, verbs, clock, main loop - is reused from
`zil/zork1` via `-I`; you never copy or edit those files.

### The main file (`tinyquest.zil`)

```zil
<VERSION ZIP>                      ;"v3 story file"
<SETG ZORK-NUMBER 0>               ;"see below"
<SET REDEFINE T>
<OR <GASSIGNED? ZILCH>
    <SETG WBREAKS <STRING !\" !,WBREAKS>>>
<FREQUENT-WORDS?>

<INSERT-FILE "GMACROS" T>
<INSERT-FILE "GSYNTAX" T>
<INSERT-FILE "GGLOBALS" T>         ;"BEFORE your dungeon file - see below"
<INSERT-FILE "TDUNGEON" T>         ;"your world"

<PROPDEF SIZE 5>
<PROPDEF CAPACITY 0>
<PROPDEF VALUE 0>
<PROPDEF TVALUE 0>

<INSERT-FILE "GCLOCK" T>
<INSERT-FILE "GMAIN" T>
<INSERT-FILE "GPARSER" T>
<INSERT-FILE "GVERBS" T>
<INSERT-FILE "TACTIONS" T>         ;"your action routines"
```

Two lines differ from Zork's own main file, both deliberately:

- **`<SETG ZORK-NUMBER 0>`** - the engine files are threaded with
  `%<COND (<==? ,ZORK-NUMBER 1> ...zork1 code...) (T ...generic code...)>`
  compile-time switches. Using a number that matches none of them selects
  the generic fallbacks everywhere and keeps Zork's content-specific code
  (thief, boat, sand room) out of your build.
- **GGLOBALS is inserted before your dungeon file** (Zork does the
  reverse). Object numbers are assigned in definition order, and the
  engine's `PERFORM` compares the pseudo-object `IT` against `PRSO` - but
  for movement, `PRSO` holds a direction *property number* (19-31). If
  `IT` lands on an object number in that range, every walk in that
  direction breaks. GGLOBALS defines 18 objects; putting them first pins
  the parser's special objects safely below 19 no matter how small your
  game is.

### The dungeon file (`tdungeon.zil`)

Declare directions first - the engine expects the game to do it:

```zil
<DIRECTIONS NORTH EAST WEST SOUTH NE NW SE SW UP DOWN IN OUT LAND>
```

Rooms and objects:

```zil
<ROOM GARDEN
      (IN ROOMS)
      (DESC "Overgrown Garden")               ;"the status-line name"
      (LDESC "You are standing in ...")       ;"printed on entry/LOOK"
      (NORTH TO SHED-INTERIOR IF SHED-DOOR IS OPEN ELSE
"The shed door is closed.")
      (ACTION GARDEN-FCN)                     ;"optional room routine"
      (FLAGS RLANDBIT ONBIT SACREDBIT)>       ;"ONBIT = lit"

<OBJECT BRASS-KEY
	(IN GARDEN)
	(SYNONYM KEY)                          ;"nouns the parser accepts"
	(ADJECTIVE BRASS SMALL)
	(DESC "small brass key")               ;"how the game names it"
	(FLAGS TAKEBIT INVISIBLE)              ;"INVISIBLE until revealed"
	(SIZE 2)>
```

Exit forms (all five compile and play):

| Form | Meaning |
|---|---|
| `(EAST TO KITCHEN)` | unconditional |
| `(WEST "The door is boarded.")` | never passable, prints message |
| `(DOWN PER TRAP-EXIT-FCN)` | routine returns the destination room or false |
| `(NORTH TO SHED IF SHED-DOOR IS OPEN ELSE "It's closed.")` | door-gated |
| `(UP TO ATTIC IF LADDER-FLAG ELSE "No way up.")` | global-flag-gated |

Common flags: `TAKEBIT` (can be picked up), `CONTBIT` (container),
`OPENBIT` (open), `LOCKEDBIT`, `DOORBIT`, `SURFACEBIT` (things sit on
it), `NDESCBIT` (not listed in room descriptions), `INVISIBLE`,
`ONBIT` (gives light on rooms), `RLANDBIT` (dry land - rooms want it),
`TRYTAKEBIT`, `VEHBIT`, `READBIT`, `WEARBIT`, `FOODBIT`, `DRINKBIT`.
v3 allows 32 flags total, and the engine uses most of them - a small
game has about a dozen free.

Give treasures `(VALUE n)` for points on first pickup and `(TVALUE n)`
for points when placed in the trophy location, or just SETG SCORE
yourself in an action routine (Tiny Quest does the latter).

### The actions file (`tactions.zil`)

Action routines receive control before the engine's default verbs, so a
returned true (`RTRUE`) means "handled" and false falls through:

```zil
<ROUTINE TOOLBOX-FCN ()
	 <COND (<AND <VERB? OPEN> <FSET? ,TOOLBOX ,LOCKEDBIT>>
		<TELL "The toolbox is locked." CR>
		<RTRUE>)
	       (<AND <VERB? UNLOCK> <EQUAL? ,PRSI ,BRASS-KEY>>
		<FCLEAR ,TOOLBOX ,LOCKEDBIT>
		<TELL "The key turns, and the lock springs open." CR>
		<RTRUE>)>>
```

The vocabulary you live in: `,PRSA` (the action), `,PRSO` (direct
object), `,PRSI` (indirect object), `<VERB? TAKE DROP>` (is the action
one of these), `,HERE` (current room), `,WINNER` (the player),
`<FSET obj flag> <FCLEAR ...> <FSET? ...>`, `<MOVE obj dest>`,
`<TELL "text " D ,OBJ " more" CR>` (D prints an object's DESC),
`<GETP obj ,P?PROP>`, room routines get an argument: `,M-LOOK` when the
room is being described, `,M-ENTER` on entry.

Every game must also supply a few things the engine expects from the
content side (copy them from Tiny Quest):

- `<ROUTINE GO () ...>` - entry point: set `HERE`, `LIT`, `WINNER`,
  print your banner, `<V-LOOK>`, `<MAIN-LOOP>`.
- `V-SCORE` and `V-DIAGNOSE` (wired in the engine's syntax table),
  `JIGS-UP` (death handler), `FIND-WEAPON` (return false if no combat),
  `<GLOBAL SCORE-MAX n>`.
- Stub objects a few generic engine verbs reference: `WATER`,
  `GLOBAL-WATER`, `WALL`, the unreachable `ON-LAKE`/`IN-LAKE` rooms, and
  a `FLAG-CARRIER` holding `NONLANDBIT`. All are in `tdungeon.zil` under
  clearly marked comments.

### New verbs

```zil
<SYNTAX POLISH OBJECT = V-POLISH>
<ROUTINE V-POLISH ()
	 <TELL "You buff " D ,PRSO " to a fine shine." CR>>
```

Prepositions and two-object forms follow the same shape as the engine's
own: `<SYNTAX PUT OBJECT IN OBJECT = V-PUT>`. Verbs already in
`zil/zork1/gsyntax.zil` (about 100 of them) work out of the box.

## The edit-compile-test loop

1. Write a `walkthrough.txt` of raw parser commands that beats the game.
2. `node czil/dist/czil-compile.mjs game.zil -I zil/zork1 -o game.z3`
3. `node czil/tests/play.mjs game.z3 walkthrough.txt` - read the whole
   transcript, every turn. The engine's errors are your test failures.
4. Freeze the good transcript and diff against it on every change
   (`tests/run.sh` does exactly this for Tiny Quest).
5. Only then play it through the LLM: `node src/cli.js game.z3`. The
   agent layer adapts automatically - it reads the dictionary and status
   line out of your story file.

Compile errors are precise and listed here from experience:

| Error | Meaning |
|---|---|
| `SYNONYM: base word X is not in the vocabulary` | you forgot `<DIRECTIONS ...>` or reference a word no object/verb defines |
| `SYNTAX X: action routine V-X is not defined` | engine syntax needs a routine your actions file must provide |
| `unknown global X` / `cannot resolve atom X` | referenced object/routine/global that is never defined - stub it or define it |
| `unknown form head X` | calling a routine that does not exist |
| `v3 allows 32 flags` | too many FLAGS names; reuse or trim |
| `property X on Y is N bytes` | v3 properties max 8 bytes: at most 4 SYNONYM words per object |
| `exit to unknown room X` | typo in a TO clause |

## Rules that keep games working

- Never edit files in `zil/` - they are the engine and the originals.
- Room DESCs are the status line: keep them short, title-case.
- Text in strings: `|` is a newline; runs of source whitespace collapse.
- The parser only sees the first 6 letters of a word: `TRAPDOOR` and
  `TRAPDOORS` are the same word; pick synonyms that stay distinct.
- Every object the player can refer to needs SYNONYM (and ADJECTIVE when
  two objects share a noun).
- Test with the scripted player first, the LLM second: the LLM masks
  parser problems by rephrasing, which hides your bugs.
