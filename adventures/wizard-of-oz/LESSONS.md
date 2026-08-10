# LESSONS — building THE SILVER SHOES on the zorkllm/Zork-I engine

Written for whoever builds the *next* book on this engine. You have a
DESIGN.md; you do not have the half-day of parser archaeology that made
mine compile. This is that half-day.

`BUILD-ISSUES.md` in this directory is the companion document: it lists
engine defects and constraints with symptom/cause/fix. This file is the
positive knowledge — what to do, what worked, what to skip.

The headline: **the companion system (§2) is the reusable part.** If your
book has a sidekick, a party, a talking animal, a servant, a ghost that
follows you around — §2 is a working implementation you can lift.

---

## 0. Read this first: the shape of the work

Rough effort split on this game (44 rooms, 117 objects, ~3,400 lines of
ZIL, ~187-command walkthrough):

| Phase | Share | Notes |
|---|---|---|
| Getting the skeleton to *compile* | 15% | almost entirely vocabulary and scope problems, not logic |
| Companion system + verifying actor routing | 20% | the interesting engineering |
| Puzzle/scene logic across four acts | 35% | mostly mechanical once the patterns are set |
| Making the walkthrough actually pass | 25% | **budget for this**; see §5 |
| Docs, endings, chaos-testing, freeze | 5% | |

The single biggest surprise: **more time went into "the parser cannot see
that noun" than into any puzzle.** Scope is the tax on this engine. §1.3
is the checklist that would have saved most of it.

---

## 1. Getting off the ground

### 1.1 Audit your vocabulary before you write a line of prose

Two words in the whole game colliding at 9 characters cost a compile
cycle with an error message that names neither. Run this first, and again
whenever you add objects:

```python
#!/usr/bin/env python3
import re, collections, glob, sys
words = set()
files = glob.glob('zil/zork1/g*.zil') + sys.argv[1:]   # + your files
for f in files:
    s = open(f).read()
    for m in re.finditer(r'\((SYNONYM|ADJECTIVE)\s+([^)]*)\)', s):
        words.update(m.group(2).split())
    for m in re.finditer(r'<(SYNONYM|BUZZ)\s+([^>]*)>', s):
        words.update(m.group(2).split())
    for m in re.finditer(r'<SYNTAX\s+([A-Z0-9$#\\-]+)', s):
        words.add(m.group(1).lstrip('\\'))
    for m in re.finditer(r'<DIRECTIONS\s+([^>]*)>', s):
        words.update(m.group(1).split())
g = collections.defaultdict(list)
for w in words:
    if re.match(r'^[A-Z0-9$#-]+$', w):
        g[w[:9]].append(w)          # 6 for v3
for k, v in sorted(g.items()):
    if len(v) > 1:
        print(k, sorted(v))
```

v8 gives you 9 characters, which is generous — SCARECROW fits whole, and
none of Baum's vocabulary needed abbreviating. On v3 (6 chars) this
script is not optional.

Two rules that fall out of it:

- **Never make one word both a verb and a noun/adjective.** The dictionary
  merges the parts of speech, the parser can't disambiguate positionally,
  and you get `You used the word "oil" in a way that I don't understand.`
  Pick a lane. (BUILD-ISSUES §2.)
- **Watch the engine's own vocabulary**, not just yours. `ADVENTURE`
  collided with `ADVENTURER`, which is the *player object*.

### 1.2 Build a bracket checker before you build the game

The compiler reports an unterminated form as an empty error message
attributed to the `<INSERT-FILE>` that contained it. This finds it in a
second:

```python
#!/usr/bin/env python3
import sys
for path in sys.argv[1:]:
    s = open(path).read()
    d = 0; instr = False; i = 0; line = 1; stack = []
    while i < len(s):
        c = s[i]
        if c == '\n': line += 1
        if instr:
            if c == '\\': i += 2; continue
            if c == '"': instr = False
        else:
            if c == '"': instr = True
            elif c == '<': d += 1; stack.append(line)
            elif c == '>':
                d -= 1
                if stack: stack.pop()
                if d < 0: print(f'{path}: extra > at line {line}'); d = 0
    if stack: print(f'{path}: unclosed forms opened at lines {stack}')
    if instr: print(f'{path}: unterminated string')
```

The killer case is a multi-paragraph `<TELL "..." CR CR "..." CR>` where
you lose the final `>`. You will write dozens of those.

### 1.3 The scope checklist (this is the big one)

**Every noun the player may type must be reachable from `,HERE` at the
moment they type it.** The engine gives you exactly four ways:

| Where the object lives | In scope when |
|---|---|
| `(IN <room>)` | player is in that room |
| `(IN <container>)` with CONTBIT+OPENBIT | player can reach the container |
| `(IN LOCAL-GLOBALS)` + room's `(GLOBAL ...)` | player is in a listed room |
| `(IN GLOBAL-OBJECTS)` | always |

Anything with no `(IN ...)` at all is **nowhere** and can never be named,
even after you `<MOVE>` something else. This bites in a specific,
predictable way: *objects that come into existence mid-game*. The raft you
build, the ladder you build, the straw you pull out of the Scarecrow, the
water you throw, the cap you find, the spectacles you wear. The player
must be able to type the noun *before* the thing exists, because typing
the noun is how it comes to exist.

The pattern that solves all of them:

```zil
;"Declare it as a local-global, list it in the rooms that mention it,
 and let its ACTION routine handle 'not yet' in fiction."
<OBJECT LADDER
	(IN LOCAL-GLOBALS)
	(SYNONYM LADDER)
	(ADJECTIVE WOODEN)
	(DESC "wooden ladder")
	(FLAGS NDESCBIT CLIMBBIT)
	(ACTION LADDER-FCN)>

<ROOM CHINA-WALL ... (GLOBAL LADDER WALL) ...>

<ROUTINE LADDER-FCN ()
	 <COND (<VERB? CLIMB-UP CLIMB-FOO BOARD> <CWALL-CLIMB>)
	       (<VERB? BUILD MAKE> <DO-BUILD>)
	       (<VERB? EXAMINE>
		<COND (,LADDER-BUILT <TELL "A tall wooden ladder..." CR>)
		      (T <TELL "There is no ladder. There is a wall, and
somebody with an axe and no need of sleep." CR>)>
		<RTRUE>)>>
```

`NDESCBIT` keeps it out of room listings, and its existence is a global
(`LADDER-BUILT`), not its location. Ten objects in this game work this
way: RAFT, LADDER, HIS-STRAW, WATER, WOOD-W, OZ-WIZARD, SCREEN, BALLOON,
CROWD, KITTEN.

**A second scope trap:** a container without `CONTBIT`+`OPENBIT` hides its
contents completely. The green spectacles started `(IN GREEN-BOX)` and
`WEAR SPECTACLES` said "You can't see any spectacles here!" in the very
room where the Guardian is offering them. Moved them to the room; the box
is scenery.

### 1.4 Do not trust the engine's syntax lines for anything load-bearing

The stock forms carry search bits that will defeat you. `THROW OBJECT
(HELD CARRIED HAVE) AT OBJECT` refused *THROW WATER AT WITCH* — the
climax of the entire game — with "You don't have the well water", before
any of my code ran. Declare your own with permissive bits:

```zil
<SYNTAX THROW OBJECT (ON-GROUND IN-ROOM HELD CARRIED)
	AT OBJECT (ON-GROUND IN-ROOM) = V-SPLASH>
<SYNTAX POUR OBJECT (ON-GROUND IN-ROOM HELD CARRIED)
	ON OBJECT (ON-GROUND IN-ROOM) = V-SPLASH>
<SYNTAX SPLASH OBJECT (ON-GROUND IN-ROOM HELD CARRIED) = V-SPLASH>
<SYNONYM SPLASH DOUSE DRENCH SOAK>
<SYNTAX EMPTY OBJECT (ON-GROUND IN-ROOM HELD CARRIED)
	ON OBJECT (ON-GROUND IN-ROOM) = V-SPLASH>
```

Then one routine accepts every combination (water or bucket as PRSO, witch
as PRSO or PRSI, held or not). All five phrasings are tested. **For your
game's one irreplaceable command, write the syntax yourself and test at
least four phrasings.** This is also the same class of bug as the
implicit-take issue the coordinator flagged: the engine's `(TAKE)` search
bit calls `ITAKE` directly from the parser (gparser.zil:1270), which never
runs your object's ACTION routine, so any gate you put there is bypassed.

### 1.5 `V?` names come from the *routine*, not the verb

`<VERB? KILL>` does not compile: KILL is a `<SYNONYM KILL MURDER SLAY>` of
ATTACK, and the action constant is derived from the `= V-ATTACK` clause.
The valid `V?` set is exactly `{X : "= V-X" appears in some SYNTAX}`.
Mapping that caught me out:

| you'll write | actually | | you'll write | actually |
|---|---|---|---|---|
| `KILL` | `ATTACK` | | `POUR` | `POUR-ON` (or `DROP`) |
| `ASK` | `TELL` | | `PULL` | `MOVE` |
| `JUMP` | `LEAP` | | `CLEAN` | `BRUSH` |
| `CLIMB` | `CLIMB-FOO`/`-UP`/`-ON` | | `PET`,`TOUCH` | `RUB` |
| `LUBRICATE` | `OIL` (if you named it so) | | `REMOVE` | `TAKE` |

One-liner to check all of yours:

```bash
python3 -c "
import re,glob
acts={m.group(1) for f in ['zil/zork1/gsyntax.zil','yoursyntax.zil']
      for m in re.finditer(r'=\s*V-([A-Z0-9-]+)', open(f).read())}
used={w for f in glob.glob('your*.zil')
      for m in re.finditer(r'<VERB\?\s+([^>]*)>', open(f).read())
      for w in m.group(1).split()}
print('BAD:', sorted(used-acts))"
```

### 1.6 The v8 boilerplate that works

```zil
<VERSION 8>
<SETG ZORK-NUMBER 0>
<SET REDEFINE T>
<OR <GASSIGNED? ZILCH> <SETG WBREAKS <STRING !\" !,WBREAKS>>>
<FREQUENT-WORDS?>

<INSERT-FILE "GMACROS" T>
<INSERT-FILE "GSYNTAX" T>
<INSERT-FILE "OZSYNTAX" T>     ;"your new verbs, BEFORE GGLOBALS"
<INSERT-FILE "GGLOBALS" T>     ;"BEFORE your dungeon — see AUTHORING.md"
<INSERT-FILE "OZDUNGEON" T>

<PROPDEF SIZE 5> <PROPDEF CAPACITY 0> <PROPDEF VALUE 0> <PROPDEF TVALUE 0>

<INSERT-FILE "GCLOCK" T>
<INSERT-FILE "GMAIN" T>
<INSERT-FILE "GPARSER" T>
<INSERT-FILE "GVERBS" T>
<VERSION? (ZIP) (T <INSERT-FILE "V8PATCH" T>)>
<INSERT-FILE "OZACTIONS" T>    ;"split your actions freely; order is free"
<INSERT-FILE "OZWEST" T>
<INSERT-FILE "OZSOUTH" T>
```

Three action files (one per act-cluster) worked well: each stayed under
~1,100 lines, and the split matched the order I built in. The compiler
does not care.

Also required from the content side, all trivially copyable from
tinyquest: `GO`, `V-SCORE`, `V-DIAGNOSE`, `JIGS-UP`, `FIND-WEAPON`
(return false if there is no combat), `<GLOBAL SCORE-MAX n>`, and the stub
objects `WATER` / `GLOBAL-WATER` / `WALL` / `FLAG-CARRIER` and rooms
`ON-LAKE` / `IN-LAKE`. **`WATER` is worth reusing meaningfully** rather
than stubbing — here it is the murder weapon.

---

## 2. THE COMPANION SYSTEM

Three recruitable followers (Scarecrow, Tin Woodman, Cowardly Lion) plus a
non-recruitable constant one (Toto). They follow you, they solve
obstacles, they solve them *for* you if you dawdle, and they talk to each
other while you walk. This all works and it is the best part of the game.

### 2.1 State in globals, not object flags

One small integer per companion, and every question you ask about them is
a comparison against it:

```zil
<GLOBAL SCARE-STATE 0>  ;"0 on pole, 1 in party, 2 marooned, 3 unstuffed"
<GLOBAL WOOD-STATE 0>   ;"0 rusted, 1 in party, 2 battered, 3 mended"
<GLOBAL LION-STATE 0>   ;"0 wild, 1 in party, 2 asleep, 3 caged, 4 crowned"
```

Object flags are a scarce, shared resource (v3 gives 32 total and the
engine spends most of them; v8 gives 48 and you still should not). Globals
are free, readable, and let a companion be *in the world but not in the
party* — which is exactly what "marooned on a pole in the river",
"battered on a rocky plain", and "caged in the courtyard" need.

The presence predicates every gate calls:

```zil
<ROUTINE HAS-WOOD? ()
	 <AND <OR <==? ,WOOD-STATE 1> <==? ,WOOD-STATE 3>>
	      <IN? ,WOODMAN ,HERE>>>
```

Note it tests *both* the state and the location. The state alone is not
enough (scripted scenes move companions elsewhere for a turn); the
location alone is not enough (a marooned Scarecrow is in a room the player
can stand in).

### 2.2 Actor-addressed commands: the dual-path rule

**This works on this engine.** `WOODMAN, CHOP TREE` routes correctly, and
so does `LION, ROAR`, `SCARECROW, SCATTER STRAW`, `QUEEN, SAVE LION`. All
eight companion-gated obstacles in this game are verified solvable both
ways. Here is exactly how, because the mechanism is not obvious and it
has one sharp edge.

**The engine's path.** `ACTOR, COMMAND` parses as the verb TELL with
`PRSO` = the actor, and the remainder of the input held in `,P-CONT`.
`V-TELL` (gverbs.zil:1389) sees `ACTORBIT` on PRSO, sees `,P-CONT` is set,
and does:

```zil
<SETG WINNER ,PRSO>
<SETG HERE <LOC ,WINNER>>
```

The main loop then re-parses the continuation with `WINNER` = the
companion. `PERFORM` (gmain.zil:211) dispatches **`<GETP ,WINNER
,P?ACTION>` first**, before the room, before preactions, before the
object. So the companion's own ACTION routine gets first refusal on every
addressed command. That is the whole mechanism, and it is clean.

**Your companion ACTION routine therefore has two halves:**

```zil
<ROUTINE WOODMAN-FCN ()
	 <COND (<==? ,WINNER ,WOODMAN>
		;"--- HALF 1: he is being given an order ---"
		<COND (<==? ,WOOD-STATE 0>
		       <TELL "The Tin Woodman groans through his rusted
jaws." CR>
		       <RTRUE>)
		      (<VERB? CHOP>  <DO-CHOP>)          ;"same routine"
		      (<VERB? BUILD MAKE> <DO-BUILD>)    ;"the plain verb"
		      (<VERB? ATTACK STOP RESCUE> <DO-FIGHT ,PRSO>)
		      (<VERB? SCATTER COVER> <DO-STRAW>)
		      (<VERB? HELLO>
		       <TELL "\"Hello!\" says the Tin Woodman, delighted to
be addressed." CR>
		       <RTRUE>)
		      (T
		       ;"in-voice refusal for anything unknown — never a
			parser error"
		       <TELL "\"I would gladly,\" says the Tin Woodman,
\"but I do not see how. Tell me a thing to chop and I am your man.\"" CR>
		       <RTRUE>)>)
	       ;"--- HALF 2: he is the object of the player's command ---"
	       (<AND <VERB? EXAMINE> <IN? ,WOODMAN ,HERE>> ...)
	       (<AND <VERB? OIL> <IN? ,WOODMAN ,HERE>> <DO-OIL>)
	       (<AND <TALKING?> <IN? ,WOODMAN ,HERE>> ...idle line...)>>
```

**The sharp edge — and it *will* bite you.** On the addressing pass
(`WOODMAN, CHOP TREE`, before WINNER switches), `PRSA` is `TELL` and
`PRSO` is the Woodman — so the companion's routine runs as *PRSO's
action* and matches any `<VERB? TELL>` clause you wrote for conversation.
Result: the Woodman delivers his idle line *and then* chops, every single
time. The fix is one predicate:

```zil
;"True for a real TELL/ASK X ABOUT..., false for the addressing half of
 an actor command: ,P-CONT is non-false exactly when there is a
 continuation waiting to be re-parsed."
<ROUTINE TALKING? () <AND <VERB? TELL HELLO> <NOT ,P-CONT>>>
```

Use `<TALKING?>` instead of `<VERB? TELL>` in every conversation clause on
every actor. That one line is the difference between the feature working
and looking broken.

**The dual-path rule itself** is enforced by discipline, not by the
engine: *every order dispatches to the exact routine the plain verb uses.*
There is one `DO-CHOP`, and three callers reach it — `V-CHOP` (plain
`CHOP TREE`), `WOODMAN-FCN` (addressed), and the room's exit routine
(walking WEST into the brambles). The routine itself figures out what the
player must have meant from `,HERE`:

```zil
<ROUTINE DO-CHOP ()
	 <COND (<AND <==? ,HERE ,BRAMBLE-ROAD> <NOT ,BRAMBLE-OPEN>>
		<COND (<HAS-WOOD?> <CHOP-BRAMBLES>) (T <NO-AXE>)>)
	       (<==? ,HERE ,SECOND-GORGE> <SGORGE-CHOP>)
	       (<AND <==? ,HERE ,TALL-TREE> <NOT ,SCARE-FIXED>> ...)
	       (<AND <==? ,HERE ,FIGHTING-TREES> <NOT ,TREES-CHOPPED>> ...)
	       (<AND <==? ,HERE ,RIVERBANK> <NOT ,RAFT-BUILT>> <DO-BUILD>)
	       (<AND <==? ,HERE ,CHINA-WALL> <NOT ,LADDER-BUILT>> <DO-BUILD>)
	       (<HAS-WOOD?>
		<TELL "\"There is nothing here that wants chopping,\" says
the Tin Woodman, a little sadly." CR>
		<RTRUE>)
	       (T <NO-AXE>)>>
```

This "one verb routine, dispatch on room" shape is worth adopting
wholesale. It makes the plain verb the *primary* interface (which is what
LLM players and casual players type), keeps the addressed form a pure
alias, and gives you one place to put the failure text.

**The one thing you cannot do:** intercept an addressed command whose noun
is out of scope. `PERFORM` tests `NOT-HERE-OBJECT` *before* dispatching to
WINNER (gmain.zil:205), so `WOODMAN, CHOP TREE` in a room with no tree
prints "The Tin Woodman seems confused. 'I don't see any tree here!'" and
your routine never runs. That message is charming enough that I left it,
but it means §1.3 (scope) is a prerequisite for §2.2 (routing), not an
independent concern.

### 2.3 One demon for follow + banter

A single `C-INT`, enabled in `GO`, runs forever:

```zil
<ROUTINE GO ()
	<SETG HERE ,FARMHOUSE>
	<SETG LIT T>
	<SETG WINNER ,ADVENTURER>
	<SETG PLAYER ,WINNER>
	<SETG VERBOSE T>
	<MOVE ,WINNER ,HERE>
	<INTRO-TEXT>
	<V-LOOK>
	<ENABLE <QUEUE I-OZ -1>>      ;"-1 = every turn, forever"
	<MAIN-LOOP>
	<AGAIN>>

<ROUTINE I-OZ ("AUX" N)
	 ;"1. FOLLOW: silently. Arrival is never narrated; they simply
	    are with you. A companion whose state is not 1 stays where
	    the story put him."
	 <COND (<AND <==? ,SCARE-STATE 1> <NOT <IN? ,SCARECROW ,HERE>>>
		<MOVE ,SCARECROW ,HERE>)>
	 <COND (<AND <OR <==? ,WOOD-STATE 1> <==? ,WOOD-STATE 3>>
		     <NOT <IN? ,WOODMAN ,HERE>>>
		<MOVE ,WOODMAN ,HERE>)>
	 <COND (<AND <OR <==? ,LION-STATE 1> <==? ,LION-STATE 4>>
		     <NOT <IN? ,LION ,HERE>>>
		<MOVE ,LION ,HERE>)>
	 <COND (<AND <G? ,STORM-PHASE 1> <NOT ,TOTO-FELL>
		     <NOT <IN? ,TOTO ,HERE>> <NOT ,TOTO-GONE>>
		<MOVE ,TOTO ,HERE>)>
	 ;"2. A temporary bark override (the reunion song), which expires."
	 <COND (<G? ,SONG-TURNS 0>
		<SETG SONG-TURNS <- ,SONG-TURNS 1>>
		<COND (<AND <NOT ,SCENE-FLAG> <HAS-SCARE?>>
		       <TELL <PICK-ONE ,BARK-SONG> CR>
		       <RTRUE>)>)>
	 ;"3. Scenes suppress banter entirely."
	 <COND (,SCENE-FLAG <RFALSE>)>
	 ;"4. Idle banter, gated on party size and probability."
	 <SET N <PARTY-SIZE>>
	 <COND (<AND <G? .N 1> <PROB 16>>
		<TELL <PICK-ONE <COND (,GIFTS-GIVEN ,BARK-GIFT)
				      (<==? ,SCARE-STATE 2> ,BARK-GRIEF)
				      (,LION-HURT ,BARK-LIMP)
				      (T ,BARK-ROAD)>> CR>
		<RTRUE>)
	       (<AND <IN? ,TOTO ,HERE> <PROB 12>>
		<TELL <PICK-ONE ,BARK-TOTO> CR>
		<RTRUE>)>
	 <RFALSE>>
```

Points worth stealing:

- **Follow is silent.** Never print "The Scarecrow follows you." Printing
  it three times a move is unbearable; printing nothing reads as a party
  travelling together, which is what you want.
- **`SCENE-FLAG` is one global that mutes all banter.** Set it at the top
  of every scripted sequence, clear it at the end. Without it the Lion
  makes a joke in the middle of the Witch melting.
- **`PROB 16` / `PROB 12`** are about right for barks: frequent enough to
  feel alive, rare enough not to intrude. Higher and the transcript
  becomes noise.
- **Bark tables swap by state, not by act number.** `BARK-GIFT` (after the
  Wizard's gifts), `BARK-GRIEF` (while the Scarecrow is marooned),
  `BARK-LIMP` (after a botched Kalidah window), `BARK-SONG` (a
  6-turn override after the stork rescue). Selecting on state means the
  banter reacts to *this* player's history, which is most of the effect
  for none of the work.

Bark tables are just `LTABLE`s of strings; `<PICK-ONE tbl>` handles the
shuffle:

```zil
<GLOBAL BARK-ROAD
	<LTABLE 0
"\"What makes you a coward?\" asks the Scarecrow. \"It's a mystery,\"
says the Lion. \"I suppose I was born that way.\""
"The Woodman steps carefully over an ant, and looks proud of it."
...>>
```

**Write them as two-voice exchanges**, not one-liners at the player. Eight
lines per table is plenty; the design called for ~8 and that was right.

### 2.4 The grace-period auto-solve

The design's rule was "companions never let you lose a scene battle; the
fun is calling the play yourself." Mechanically:

```zil
<ROUTINE I-WAVE ()
	 <COND (,CAPTURED <RFALSE>)>
	 <SETG WAVE-TURNS <+ ,WAVE-TURNS 1>>
	 <COND (<L? ,WAVE-TURNS 3>
		<COND (<==? ,WAVE-TURNS 2> <WAVE-HINT>)>   ;"nudge on turn 2"
		<RFALSE>)
	       (T
		;"turn 3: the right companion acts on his own."
		<TELL CR "Nobody waits to be asked." CR>
		<COND (<==? ,WAVE 1> <WAVE1-WIN>)
		      (<==? ,WAVE 2> <DO-SCARE-CROWS>)
		      (<==? ,WAVE 3> <DO-STRAW>)
		      (T <WAVE4-WIN>)>
		<RTRUE>)>>
```

Three properties make this feel generous rather than patronising:

1. **The auto-solve calls the same routine the player would have.** Not a
   special "you failed" path — literally `WAVE1-WIN`. The scene plays out
   identically.
2. **Turn 2 is an in-character hint that names the answer**: *"This is my
   fight," says the Tin Woodman, and sharpens his axe on the sole of his
   tin foot, and waits to be told.* The player who reads it wins on turn
   3 themselves.
3. **The points are the same either way** here. Where you *do* want to
   reward player agency, dock the auto-solve — the mouse-debt scene
   (P13) awards fewer points when the Woodman acts unprompted, which is
   the right calibration for an optional deed.

The same three-beat shape (beat 1 stage the problem, beat 2 name the
solution in a character's voice, beat 3 solve it) is used for the Lion
ambush, the beetle, the wildcat, and the poppy field. It is the single
most reusable scene structure in the game.

### 2.5 Anti-dead-end rails, diegetically

The Golden Cap grants exactly three commands and two of them are
required. A player can waste one (the book does). The rail:

```zil
<ROUTINE CAP-BLOCKED? ()
	 <COND (<OR <==? ,HERE ,LOST-FIELDS> <==? ,HERE ,HAMMER-HILL>>
		<RFALSE>)                            ;"required uses: allow"
	       (<AND <==? ,CAP-USES 1> <NOT ,HH-DONE> <HAS-SCARE?>>
		<COND (,CAP-INSIST <SETG CAP-INSIST <>> <RFALSE>)
		      (T
		       <SETG CAP-INSIST T>
		       <TELL "\"Wait!\" cries the Scarecrow, and puts a
stuffed hand over your mouth before the last word. \"If the Monkeys could
have carried you to Kansas, Oz would not have needed a balloon. Save our
last command. I have a feeling about that hill in the south.\"" CR CR
"(Say it again if you insist.)" CR>
		       <RTRUE>)>)
	       (T <RFALSE>)>>
```

The pattern generalises: **a companion who visibly has good judgement is
the most graceful place to put an unwinnable-state guard.** It is not a
parser refusal, it costs the player nothing, it can be overridden, and it
characterises the Scarecrow (who spends the whole book insisting he has no
brains) at the exact moment he demonstrates otherwise. Verified: three
uses, the Kansas refusal spends one, the rail fires with one left, a
fourth attempt gets "the Cap's three commands are spent, and it is only a
hat now", and the game stays winnable throughout.

---

## 3. Other ZIL patterns that earned their keep

### 3.1 Scripted sequences: `PER` exits that move the player themselves

For a multi-room scripted transition (the river drift, the monkey capture,
the Cap flights, the china-wall descent), don't try to express it as
exits. Have the routine relocate the player and re-describe:

```zil
<ROUTINE CAP-USE-CITY ()
	 <SPEND-CAP>
	 <COND (<NOT ,SC-CAP1> <SETG SC-CAP1 T> <SCORE-IT 5>)>
	 <SETG ACT 4>
	 <TELL "...two screens of Gayelette-and-Quelala lore..." CR>
	 <MOVE ,WINNER ,CITY-GATE>
	 <SETG HERE ,CITY-GATE>
	 <SETG SPECS-ON <>>          ;"they were unlocked when you left"
	 <V-LOOK>
	 <RTRUE>>
```

`<MOVE ,WINNER ...>` + `<SETG HERE ...>` + `<V-LOOK>` is the idiom.
Always set both; setting only `HERE` leaves the player object behind and
scope breaks in confusing ways two turns later.

### 3.2 Catch-all responses during scripted turns

A scripted sequence that ignores input feels broken. Every auto-advancing
room has an `M-BEG` catch-all:

```zil
<ROUTINE MIDRIVER-FCN (RARG)
	 <COND (<==? .RARG ,M-BEG>
		<COND (<VERB? WALK>
		       <TELL "There is nowhere to walk. The river has the
raft." CR>
		       <RTRUE>)
		      (<VERB? SWIM>
		       <TELL "\"Stay on the raft,\" says the Lion, who is
about to do the swimming for everybody." CR>
		       <RTRUE>)>)>>
```

`M-BEG` runs before preactions and object actions, so it is the right
hook for "during this scene, X means Y". It is also how the kitchen
intercepts `THROW WATER` regardless of what the parser decided PRSO was.

### 3.3 Trigger on `M-ENTER`, not on a queued tick, for place-based events

See BUILD-ISSUES §8-9. Queues are for *"in N turns, wherever you are"*
(drowsiness escalation, the Witch's taunting hints). Room `M-ENTER` is for
*"when you get there"*. Mixing them up cost me the beetle scene twice.

And remember `M-ENTER` fires **before** the follow demon moves the party,
so an entry scene needing a companion must place him: `<MOVE ,WOODMAN
,HERE>` then test.

### 3.4 Soft timers that cannot be failed

The poppy field escalates over five turns and then *succeeds at putting
you to sleep* — which is the story, not a failure:

```zil
<ROUTINE I-POPPY ()
	 <COND (<OR ,POPPY-DONE <NOT <EQUAL? ,HERE ,POPPY-FIELD>>> <RFALSE>)>
	 <SETG POPPY-COUNT <+ ,POPPY-COUNT 1>>
	 <COND (<==? ,POPPY-COUNT 2> <TELL CR "You yawn, hugely..." CR>)
	       (<==? ,POPPY-COUNT 3> <TELL CR "Toto lies down..." CR>)
	       (<==? ,POPPY-COUNT 4> <TELL CR "\"Run!\" says the
Scarecrow to the Lion..." CR>)
	       (T <POPPY-COLLAPSE>)>       ;"carried out by your friends"
	 <RTRUE>>
```

The player feels danger for four turns and is never punished. Exactly one
death exists in the whole game (jumping into the gorge) and it is guarded
by two escalating warnings, the first of which is a companion physically
catching your sleeve. **In an adaptation of a children's book this is the
right dial setting**, and it costs nothing: a forgiving game is easier to
test because the walkthrough cannot be derailed by a misstep.

### 3.5 Explicit scoring with once-only guards

Since `VALUE` is dead (BUILD-ISSUES §5):

```zil
<GLOBAL SC-MELT <>>
<ROUTINE SCORE-IT (N) <SETG SCORE <+ ,SCORE .N>> <RTRUE>>
...
<COND (<NOT ,SC-MELT> <SETG SC-MELT T> <SCORE-IT 26>)>
```

30 `SC-*` globals, one per deed. Tedious, completely reliable, and it lets
one deed be reachable by several routes (the mouse debt scores the same
whether the player calls it or the Woodman acts alone) without
double-awarding. Sum them in a script and check against `SCORE-MAX`
*before* you tune the walkthrough — mine was 19 over, and finding out at
the end meant re-running everything.

### 3.6 Ranks in `V-SCORE`

Cheap and disproportionately satisfying:

```zil
<TELL "." CR "This gives you the rank of ">
<COND (<G? ,SCORE 249> <TELL "Honorary Sorceress">)
      (<G? ,SCORE 219> <TELL "Wearer of the Golden Cap">)
      ... >
<COND (,CHURCH-BROKE
       <TELL "(Includes: china church, one (1), minus one point.)" CR>)>
```

The single negative point, itemised in the score report, got the biggest
laugh of anything in the game per byte spent.

---

## 4. Things I tried that did NOT work

**`VEHBIT` for the raft and the balloon.** `PRE-BOARD` runs before your
object's ACTION and enforces the engine's vehicle model, so `BOARD RAFT`
answers *"The log raft must be on the ground to be boarded."* — for an
object you deliberately made a local-global. Both are scene machines, not
vehicles. Dropped VEHBIT; boarding is a flag. **Do not reach for VEHBIT
unless the player genuinely drives the thing around a map.**

**`<SYNTAX TAKE ME TO OBJECT = ...>`** for the finale's *TAKE ME HOME TO
AUNT EM*. Compile error: `misplaced preposition TO` — `ME` is a pseudo
object, not a preposition, and the syntax grammar can't express it.
Landed on bare `HOME`/`KANSAS` as magic-word verbs (the `PLUGH`
precedent) plus `SAY KANSAS`, with the book's line printed as Dorothy's
speech. **Free-text commands are not expressible; accept a keyword and
render the sentence yourself.**

**`SAY <arbitrary sentence>`** for the Wizard's three questions, as the
design specified. The parser dies on the second word. Replaced with a
scene that advances on *any* conversational input and supplies Dorothy's
honest answers itself. **This turned out better than the design** — the
player types `ANSWER` (or anything) and gets Baum's dialogue, instead of
guessing at a phrasing.

**Putting takeable objects inside a plain container.** Spectacles in the
Guardian's green box: invisible to the parser (no CONTBIT/OPENBIT). Every
"the NPC offers you X from a Y" beat should put X in the room and make Y
scenery.

**A wholesale sed of plain verbs → addressed verbs in the walkthrough**,
as a dual-path test. Useless: substituting `chop tree` → `woodman, chop
tree` globally hits rooms with no tree, the run derails at the first
mismatch, and every subsequent "failure" is noise. **Test the dual path
one gate at a time**, each from a fresh prefix of the known-good
walkthrough. Script for that in §5.

**Trusting `PROB` to be reproducible across builds.** It is, given the
seeded RNG in the harness — but banter fires on turn parity, so inserting
a single `wait` in the walkthrough shifts every subsequent bark and the
frozen transcript diff explodes. Freeze *after* the walkthrough is final.

---

## 5. Process: what to do in what order

**The order that worked:**

1. Vocabulary audit + bracket checker (§1.1, §1.2) — before writing prose.
2. Skeleton compiles and boots: rooms, objects, `GO`, stubs, empty action
   routines. Get "it compiles and I can walk around" first.
3. **Companion system next**, as the brief instructed, and that was
   right — it is the substrate every later puzzle sits on, and the
   `TALKING?`/`P-CONT` discovery would have poisoned thirty routines if
   found late.
4. One act at a time: write the act, extend the walkthrough, run it, fix,
   repeat. Never more than ~300 lines between compiles.
5. Score reconciliation. **Do this at act 2, not at the end.**
6. Alternate endings, cap economy, chaos input.
7. Freeze the transcript; write `verify.mjs`; write the docs.

**How to test efficiently.** The whole loop is:

```bash
node czil/dist/czil-compile.mjs oz.zil -I zil/zork1 -I zil/engine-v8 -o oz.z8 \
  && node czil/tests/play.mjs oz.z8 walkthrough.txt 2>&1 | sed -n '400,500p'
```

Under two seconds. Read the transcript window around wherever you just
worked. `play.mjs` seeds `Math.random`, so runs are reproducible.

For testing one branch without replaying an hour of game, slice the
walkthrough:

```python
w = open('walkthrough.txt').read().split('\n')
i = w.index('throw water at witch')          # the gate under test
for n, phrasing in enumerate(['pour water on witch', 'splash witch',
                              'throw bucket at witch', 'empty bucket on witch']):
    open(f'/tmp/w{n}.txt', 'w').write('\n'.join(w[:i] + [phrasing, 'score']) + '\n')
```

That is how all five bucket phrasings, all eight companion gates, the
three-use Cap economy, the balloon fake-out, and the stay-in-Oz ending
were each verified — a known-good prefix plus the two or three commands
under test. **Build this slicer on day one.**

**Chaos-testing** (`xyzzy`, `dance`, `eat toto`, `kill dorothy`, `pray`,
`take all`, verbs at the wrong time) found four real rough edges in one
pass and took ten minutes. Worth doing once per act.

**What I would do differently:**

- Write the scope audit (§1.3) as a *pre-flight checklist for every new
  object* rather than discovering each miss at runtime. Roughly a third of
  my debugging turns were "you can't see any X here".
- Reconcile the score table against `SCORE-MAX` before writing any
  scoring code.
- Not write the walkthrough as a single monolith up front. Grow it act by
  act; its ordering is coupled to scene timing (how many turns a demon
  takes) and every timing change reshuffles it.

---

## 6. Design-to-implementation friction

Where DESIGN.md was underspecified, wrong, or optimistic. Useful for
`docs/ADAPTING.md`.

**The score table did not sum to SCORE-MAX.** 269 vs a declared 250. This
is a mechanical check a design template should force: *put the total row
in the table.*

**Commands the parser cannot accept were specified as solutions.** `SAY
FROM THE WITCH OF THE EAST`, `TAKE ME HOME TO AUNT EM`, `ASK QUEEN TO SAVE
LION`, `TELL WINKIES TO CARRY WOODMAN`. The design's own §11 warns about
6-character dictionary limits but not about *sentence structure*. A
design should specify solutions as **verb + one or two nouns**, and put
the flavourful sentence in the response text where it belongs. Suggested
rule for ADAPTING.md: *every puzzle's solution must be expressible as
`VERB [NOUN [PREP NOUN]]`; if you cannot write it that way, the puzzle is
not yet designed.*

**Scene timing was specified in turns without accounting for movement
turns.** "The wildcat scene begins after 2 turns" — 2 turns after what, and
does the turn the player spends walking in count? Every one of these
needed empirical tuning against the walkthrough. A design that says
"fires on entry" or "fires N turns after entry, counting the entry turn"
is unambiguous; "after 2 turns" is not.

**Object placement for not-yet-existing things was unspecified**, which is
the single biggest source of implementation work (§1.3). A design listing
"LADDER — built at CHINA-WALL" should also say the noun must be
addressable before it exists.

**What the design got exactly right**, and I would keep: the per-puzzle
"exact solution / failure text / hint ladder" format (§4) is superb — it
is directly transcribable into a `COND`; the capability index (Scarecrow
plans, Woodman chops, Lion leaps) made every gate's failure text write
itself; the drafted intro/outro text meant the highest-stakes prose in the
game was already done and consistent; and the explicit fair-death policy
(§6) removed a whole category of decisions.

---

## 7. The FILM TRAP in practice

The 1900 book is public domain; the 1939 film is not. `STUDY.md` §8's
checklist was **binding, and it held up completely** — but only because
it was concrete. Abstract instructions ("use the book") would not have
worked; a list of specific forbidden items did.

What the discipline actually cost: nothing, because it was decided before
writing. What it protected: the silver (not ruby) shoes, which are the
title and the final puzzle; the Witch's umbrella (not broom) and single
telescope eye; the absence of any incantation at the finale (the book's
command is plain speech, *"Take me home to Aunt Em!"*); Glinda of the
South, not the North; Winged (not flying) Monkeys; and the fact that
Dorothy melts the Witch **in anger, on purpose, over a stolen shoe** —
which is a better scene than the film's accident and is the emotional
peak of the game.

Two habits worth copying:

1. **Automate the check.** `verify.mjs` greps the produced transcript for
   film-only phrases and fails the build:

```js
const filmisms = [
  /\bruby slipper/i, /\bbroomstick\b/i, /\bcrystal ball\b/i,
  /\bthere's no place like home\b/i, /\bflying monkeys\b/i,
  /\bglinda[^.\n]{0,40}\bnorth\b/i,
];
for (const re of filmisms)
  if (re.test(transcript)) problems.push(`film-only material: ${re}`);
```

   Grep the *sources* too, once, before shipping. My only hit was
   `RUBY-THRONE` — which is Baum ("a throne of rubies") and correct.

2. **Quote the book verbatim where it is best.** *"Look out, here I go!"*,
   *"Exactly so! I am a humbug."*, *"That isn't the way we Lions do these
   things."*, *"There has never been a Winged Monkey in Kansas yet."*
   Verbatim public-domain text is both the safest content and the best
   writing in the game. Keep `book.txt` open and lift the good lines.

Future adaptations of any public-domain novel with a famous adaptation
(Dracula, Alice, Treasure Island, Monte Cristo all qualify) should write
their own §8 list *before* the design, not after.

---

## 8. Quick reference — the ten things I wish I had known

1. Scope is the tax. Anything nameable needs `(IN ...)`; things that
   appear mid-game go in `LOCAL-GLOBALS` and get listed in the room's
   `(GLOBAL ...)`. §1.3
2. `V?FOO` comes from the routine name in `= V-FOO`, not from the verb
   word. `V?KILL` does not exist. §1.5
3. A word can be a verb *or* a noun, never both. §1.2 / BUILD-ISSUES §2
4. `WORNBIT` does not exist; worn = carried + `WEARBIT`.
5. `VALUE` is dead — `V-TAKE` never calls `SCORE-OBJ`. Score explicitly.
6. `<ENABLE <QUEUE rtn -1>>` runs forever until you `<DISABLE <INT rtn>>`.
7. Room `M-ENTER` fires before the follow demon moves your party.
8. Actor-addressed commands work; guard conversation clauses with
   `<NOT ,P-CONT>` or every order prints an idle line first. §2.2
9. Write your own SYNTAX with permissive search bits for any command the
   game cannot afford to lose. §1.4
10. Freeze the transcript last; a single inserted `wait` reshuffles every
    probabilistic bark after it.
