# LESSONS — building a novel adaptation on the zorkllm / Zork I engine

Written after building **DRACULA: The Un-Dead** (43 rooms, ~150 objects,
22 puzzles, three acts, several interacting timers) for the next person
adapting a *different* book on this toolchain. Companion file:
`BUILD-ISSUES.md`, which is the catalogue of engine defects with fixes.
This file is about how to *work*.

The one-line summary: **the engine is fine and the prose is easy; almost
all of the cost is in the parser and in timers.** Budget accordingly.

---

## 1. Engine gotchas, with the fix

`BUILD-ISSUES.md` has the full list with root causes traced into the C
and ZIL sources. The ones most likely to bite *any* game, in the order
they will bite you:

### 1.1 Use `(LOC ROOMS)`, never `(IN ROOMS)`

If any room has an `IN` exit, `(IN ROOMS)` compiles as the *property*
`IN = ROOMS` and silently destroys that exit. `LOC` takes the same parent
branch with no direction collision. Do this from the first room you
write; retrofitting means touching every room.

```zil
<ROOM ENTRANCE-HALL
      (LOC ROOMS)
      (IN PER HALL-IN)
      ...>
```

### 1.2 Object VALUE properties are dead; award points by hand

`SCORE-OBJ` is called from `V-PUT`/`V-PUT-ON` and from a
`ZORK-NUMBER 1 or 2` conditional, but **`V-TAKE` never calls it** and we
compile with `SETG ZORK-NUMBER 0`, so the `%<COND …>` branch at
gverbs ~1961 is compiled out entirely. Any `(VALUE 10)` you put on an
object is inert. Award explicitly:

```zil
<ROUTINE AWARD (N)
	 <SETG BASE-SCORE <+ ,BASE-SCORE .N>>
	 <SETG SCORE ,BASE-SCORE>>
```

…and call `<AWARD 5>` inside the routine that represents the
accomplishment, guarded by a one-shot global so it cannot be farmed:

```zil
<COND (<NOT ,ATLAS-READ> <SETG ATLAS-READ T> <AWARD 2>)>
```

Corollary: keep a running tally of every `<AWARD n>` in your sources and
compare it to `SCORE-MAX`. Ours drifted badly (see §4).

### 1.3 `ITAKE-CHECK` bypasses object ACTION routines

`ITAKE-CHECK` (gparser ~1248) calls `ITAKE` directly for syntax lines
carrying the `SHAVE` or `STAKE` bits, so an implicit take happens without
the object's ACTION ever running. If your design has "you must not be
able to pick this up until X", a gate written only in the object's ACTION
can be walked straight through by `PUT THING IN BOX`. Gate with
`TRYTAKEBIT` + a `PRE-` routine, or check the condition again at the
point of use rather than at the point of taking.

### 1.4 Reserved atom names will corrupt the parser at *runtime*

`gparser.zil` defines `<CONSTANT STAKE 8>` and `<CONSTANT SHAVE 2>` (plus
`SH SC SIR SOG SMANY`) as syntax bit masks. We named an object `STAKE`.
It compiled cleanly and then, at runtime, `DROP LETTER` and
`THROW LETTER AT BARS` answered `"You don't have that!"` while
`READ LETTER` worked fine — because `<BTST .IBITS ,STAKE>` was testing an
object number instead of the mask.

This cost more debugging time than anything else in the build, because
the symptom appears on an *unrelated* object. **Before naming objects,
grep the engine for `<CONSTANT` and `<GLOBAL` and avoid every name.** Any
"held object mysteriously not held" bug should send you straight here.

### 1.5 `<VERB? X>` needs `V-X` to exist — test the ACTION, not the word

`V?FOO` is minted from the action name on the right of a SYNTAX line, not
the dictionary word on the left. `<SYNTAX KILL … = V-SIMPLE-KILL>` gives
you `V?SIMPLE-KILL` and no `V?KILL`. The compiler catches this
(`unknown global V?KILL`), but only once everything else compiles, so
you get them in a slow trickle. Useful mappings:
`WAKE`→`ALARM`, `TURN ON`→`LAMP-ON`, `PUT X IN Y`/`APPLY`→`PUT`,
`TALK TO`/`TELL ABOUT`→`TELL`, `PICK LOCK`→`PICK`.

### 1.6 An adjective on object A blocks that word as a noun on object B

`GOLD` as an ADJECTIVE on the dining-room plate made `TAKE GOLD` fail in
the room that actually contained the gold heap. Same for `LOG`. **Every
word that is a noun somewhere must not be an adjective anywhere else.**

### 1.7 PRE- routines run before object ACTIONs and can veto them

`PRE-MUNG` rejects any indirect object without `WEAPONBIT`, so
`BREAK DOOR WITH HAMMER` was refused before `GREAT-DOOR-FCN` ran. An
object action cannot rescue a command a PRE- routine has already
rejected; fix the flags instead.

### 1.8 Dictionary dedup can fail the build with no word named

`compile failed: SYNONYM word missing from vocab` means two words are
byte-identical after truncation to the dict length (9 in v8) and the
survivor is not findable under the dropped spelling. Find them first:

```python
# collisions.py — group every vocab word by its first 9 chars
import re, glob, collections
words = collections.defaultdict(set)
for f in glob.glob('*.zil') + glob.glob('../../zil/zork1/*.zil'):
    t = open(f).read()
    for m in re.finditer(r'\((?:SYNONYM|ADJECTIVE)\s+([^)]*)\)', t):
        for w in m.group(1).split():
            if re.fullmatch(r'[A-Z][A-Z0-9?#\'-]*', w):
                words[w[:9]].add(w)
    for m in re.finditer(r'<(?:SYNTAX|SYNONYM|BUZZ)\s+([^=>]*)', t):
        for w in m.group(1).split():
            if re.fullmatch(r'[A-Z][A-Z0-9?#\'-]*', w) and w != 'OBJECT':
                words[w[:9]].add(w)
for k, v in sorted(words.items()):
    if len(v) > 1:
        print(k, '<-', sorted(v))
```

Ours: `TOMBSTONE` / `TOMBSTONES`. **v8's 9-character dictionary makes
most of a design's v3 collision worries evaporate** — the design doc's
whole 6-character audit section was moot — but the long-word case is new
and worse, because it fails the build instead of merging quietly.

---

## 2. ZIL idioms that worked

### 2.1 Multi-stage schedule-driven timers (the big one)

This game's soul is timers: Lucy's winnable four-night decline,
Dracula's nightly circuit, the sunset on the Borgo road. The structure
that worked, and that I would use again unchanged:

**One permanent daemon per act, queued once in `GO`, each returning
immediately unless its own act is running.**

```zil
<ROUTINE GO ()
	 ...
	 <QUEUE I-CASTLE -1>      ;"TICK -1 = permanent daemon"
	 <QUEUE I-PURFLEET -1>
	 <MAIN-LOOP>>

<ROUTINE I-PURFLEET ()
	 <COND (<NOT <EQUAL? ,ACT 3>> <RFALSE>)>
	 <SETG TICKS2 <+ ,TICKS2 1>>
	 <COND (<G? ,TICKS2 40>                  ;"soft cap: nudge a
	                                          stalled player along"
		<COND (,NIGHT2 <P2-DAWN>) (T <P2-DUSK>)>
		<RTRUE>)>
	 <RFALSE>>
```

**The phase transition owns the stage check, not the turn counter.** All
of Lucy's logic lives in one routine called from `P2-DUSK`, which reads
the player's preparations as *state set during the day*:

```zil
<ROUTINE DEFENCES-OK? ()
	 <AND ,WINDOW-SHUT ,WREATH-ON <G? <DEFENCE-COUNT> 1>>>

<ROUTINE LUCY-NIGHT ()
	 <COND (<AND <NOT ,WOLF-NIGHT-DONE> <OR <G? ,DAY2 3> ,WATCHING>>
		<SETG WOLF-NIGHT-DONE T>
		<LUCY-NIGHT-WOLF>
		<RTRUE>)>
	 <COND (<DEFENCES-OK?> <safe-night text>)
	       (T <LUCY-DECLINE 1>)>>

<ROUTINE LUCY-DECLINE (N)
	 <SETG LUCY-STAGE <+ ,LUCY-STAGE .N>>
	 <COND (<G? ,LUCY-STAGE 2> <LUCY-DIES>)>>
```

Four rules that made this work:

1. **State in globals, never in object flags.** `WINDOW-SHUT`,
   `GARLIC-SASH`, `WREATH-ON`, `LUCY-STAGE`. Trivially inspectable,
   trivially testable, no flag budget.
2. **Never key a beat to an exact turn or date.** My first version fired
   the wolf night on "day 4" exactly. Adding three flavour commands to
   the walkthrough moved the day count and silently skipped the game's
   climax — twice. Key beats to *player readiness* (`OR <G? ,DAY2 3>
   ,WATCHING`) with a one-shot done-flag. This is the single most
   valuable thing in this document.
3. **A scene printed during a turn needs a turn of grace before it can
   close.** The wolf appears at dusk, which is itself inside a turn; the
   `M-END` that closes the scene runs on that same turn, so the player
   never got to answer. Fix: a `WOLF-WAITED` flag that eats one M-END.
4. **No RANDOM anywhere near the critical path.** Everything above is a
   deterministic function of player state, so the walkthrough replays
   byte-for-byte and `verify.mjs` can diff a frozen transcript.

Also useful: make a verb that *means* "spend the night" actually spend
it, rather than costing one turn:

```zil
<ROUTINE KEEP-WATCH ()
	 <SETG WATCHING T>
	 <TELL "You draw the chair to the bedside..." CR>
	 <COND (,NIGHT2 <P2-DAWN>)>
	 <COND (<NOT ,LUCY-RESOLVED> <P2-DUSK>)>
	 <RTRUE>>
```

### 2.2 Act-gating one adventurer (no character switching)

The design's call — a single `ADVENTURER` as `WINNER` for the whole game,
with acts as scripted scene changes — was completely right. Never reseat
`WINNER`. The whole mechanism is three routines:

```zil
<GLOBAL ACT 1>

<OBJECT BANK (DESC "bank") (FLAGS INVISIBLE NDESCBIT)>

<ROUTINE BANK-ALL ("AUX" X N)     ;"empty the old life's pockets"
	 <SET X <FIRST? ,WINNER>>
	 <REPEAT ()
		 <COND (<NOT .X> <RETURN>)>
		 <SET N <NEXT? .X>>
		 <MOVE .X ,BANK>
		 <SET X .N>>>

<ROUTINE ACT1-FINISH ()
	 <AWARD 15>
	 <TELL <closing narration> CR CR
"-- From the journal of Mina Murray, Whitby, August. --" CR CR>
	 <SETG ACT 2>
	 <BANK-ALL>
	 <MOVE ,LUCY ,CRESCENT-BEDROOM>
	 <SETG HERE ,CRESCENT-BEDROOM>
	 <MOVE ,WINNER ,HERE>
	 <SETG LIT T>
	 <V-FIRST-LOOK>>
```

`BANK` is an invisible nowhere-object; moving things there is the
cheapest possible "off stage". Reused constantly — dead NPCs, spent
items, scenery that only exists in one act.

**Rooms revisited in a later act** keep the same ROOM object and branch
their description on `ACT` in an `M-LOOK` handler, with contents swapped
by the transition routine:

```zil
<ROUTINE RUINED-CHAPEL-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<COND (<EQUAL? ,ACT 4> <TELL <winter version> CR>)
		      (T <TELL <Act I version> CR>)>
		<RTRUE>)
	       (T <ACT1-COMMON .RARG>)>>
```

Castle Courtyard / Ruined Chapel / Vault serve both Act I and Act III
this way at no cost.

**Shared per-act room behaviour** goes in one `ACTn-COMMON` routine that
every room in the act delegates to, with `ACTn-PLAIN-FCN` as the ACTION
for rooms that need nothing else. That is where act-wide handling of
`WAIT`, `SLEEP`, and `PRAY` lives — write it once.

⚠ **Rooms with their own `M-ENTER`/`M-LOOK` branches never reach
`ACTn-COMMON`.** I kept a party of NPCs beside the player by re-seating
them from the room action and it worked in about half the rooms. The fix
is to do per-turn housekeeping from the **daemon**, which always runs:

```zil
<ROUTINE PARTY-FOLLOW ()
	 <COND (,PARTY-ON
		<MOVE ,VAN-HELSING ,HERE>
		<MOVE ,GODALMING ,HERE>
		<MOVE ,MORRIS ,HERE>
		<FSET ,VAN-HELSING ,NDESCBIT>   ;"narrate in prose, don't
		<FSET ,GODALMING ,NDESCBIT>      let the lister read a
		<FSET ,MORRIS ,NDESCBIT>>>       phone book")>
```

### 2.3 The journal-header convention

Costs nothing and does a great deal. Acts, deaths, and time-skips are all
one-line headers in the same format:

```
-- From the diary of Dr. John Seward, kept in phonograph. Purfleet,
   September. --
```

Death overrides `JIGS-UP` so it reads as the record breaking off:

```zil
<ROUTINE JIGS-UP (DESC "OPTIONAL" (PLAYER? <>))
	 <TELL .DESC CR CR>
	 <TELL
"The journal ends here. (Type RESTORE to take up an earlier page, or
RESTART to begin the record anew.)" CR CR>
	 <V-SCORE>
	 <FINISH>>
```

Two dividends beyond tone: the headers give a TTS listener chapter
boundaries, and they are perfect assertion targets — `verify.mjs` checks
all six appear *in order*, which catches any act-transition regression
in one line of test code.

### 2.4 An NPC topic routine beats a property table

`ASK X ABOUT Y` dispatch as a flat `COND` over `PRSI` is readable,
diffable, and needs no new properties:

```zil
<ROUTINE VH-TOPICS ()
	 <COND (<EQUAL? ,PRSI ,GARLIC ,WREATH> <TELL "\"The garlic. Rub him
on the sash, so...\"" CR>)
	       (<EQUAL? ,PRSI ,LUCY> ...)
	       (T <TELL "\"Ah, you ask me that. I do not know all...\"" CR>)>>
```

The `T` branch is important: an in-character deflection for unknown
topics makes the NPC feel bounded rather than broken.

---

## 3. Things that did NOT work

### 3.1 New syntax: what the parser accepted and what fought back

This is the most transferable section. Verdicts from actual spikes:

**Accepted cleanly, no trouble at all:**

| Form | Notes |
|---|---|
| `SHOW X TO Y` with `(FIND ACTORBIT)` | worked first try |
| `ASK X ABOUT Y` → `= V-TELL` | **route it to the engine's existing `V-TELL`.** Then one `<VERB? TELL>` test handles ASK, TELL ABOUT, and TALK TO together |
| `WATCH X`, `WRITE X`, `DRAW X`, `SEAL X`, `STOP X`, `CATCH X`, `PIN X`, `PIN X TO Y` | all fine; simple one/two-object forms are never a problem |
| `RUB X ON Y` | fine as a *new* form; the stock one is `RUB X WITH Y` |
| `HANG X ON/AROUND Y` | fine; delegate to `<PERFORM ,V?PUT-ON …>` |
| `LOOK OUT WINDOW` | **fine** — the design flagged this as risky and it was not. `<SYNTAX LOOK OUT OBJECT = V-LOOK-OUT>` |
| `CLIMB OUT WINDOW` | fine, as `= V-THROUGH` |
| `CLIMB DOWN` / `CLIMB UP` bare | fine, dispatch with `<DO-WALK ,P?DOWN>` |

**Fought back:**

| Form | What happened | What to do |
|---|---|---|
| bare `IN` / `ENTER` as a direction | dead in every room | `(LOC ROOMS)` — see §1.1 |
| `REMOVE X` / `TAKE OFF X` | no such verb; falls to `V-TAKE`, which refuses worn items before the object action runs | define your own `V-DOFF` |
| `THROW X THROUGH/AT Y` where Y is scenery | stock forms require `(FIND ACTORBIT)` on Y | add a non-ACTORBIT form |
| `BLOW X` | only `BLOW OUT/UP/IN` exist | new `<SYNTAX BLOW OBJECT … = V-BLOWOBJ>`; test `<VERB? BLOWOBJ>` |
| `OPEN TOMB DOOR` (two nouns) | `"That sentence isn't one I recognize."` | one noun plus adjectives only; make the adjective distinctive |
| `ASK MAIDS FOR SUGAR` where SUGAR is out of scope | whole command rejected before the NPC's action runs | have the NPC answer a bare `TALK TO`; never require an out-of-scope PRSI |
| `GIVE X TO NPC` handled in X's action | **PRSI's action runs before PRSO's**, so the NPC (or `V-GIVE`'s "refuses it politely") wins | put the handler on the **NPC** |

### 3.2 Dead ends in approach, not just syntax

- **Reordering `(IN ROOMS)` after the `(IN PER …)` clause** to make the
  direction win: no effect. The compiler decides by name, not order.
- **Hanging act-critical scenes on a dawn/dusk boundary** ("the night
  after the raid"): a player who goes straight from the raid to the next
  errand never crosses one, and skips the scene. Fire consequential
  scenes **directly from the action that causes them**.
- **Bisecting a compile failure by stubbing whole files**: misleading
  here, because the error I was chasing (`SYNONYM word missing`) was a
  *pre-existing latent* collision in the world file that only surfaced
  once other errors ahead of it were cleared. When an error changes as
  you stub things out, suspect ordering, not causation.
- **Trusting the design's walkthrough as literal commands**: it was
  written before the map existed and had the wrong directions in a dozen
  places (`UP` then `WEST` where the map needs `UP`, `UP`, `WEST`). It is
  a *spec of intent*, not a script. Expect to rebuild it against the
  real map.

---

## 4. Design-to-implementation friction

`DESIGN.md` was genuinely excellent — 1,585 lines, every puzzle with its
exact solution and failure text, drafted intro/outro prose, a TTS style
guide. Most of the build was transcription, which is the right outcome.
Where it cost time:

- **The score table did not sum to its own maximum.** SCORE-MAX 250 was
  reachable only by counting mutually exclusive branch awards (saving
  Lucy *and* laying her to rest) in one total. Real per-branch ceiling
  is 210. **A design should state the maximum for each branch
  separately**, or state that the total is aspirational. This wasn't
  noticed until the walkthrough finished at "200/250" and looked like a
  bug.
- **Timers specified as dates, not as conditions.** "Night 3: the mother
  threat. Night 4: the wolf." Implemented literally, the game's climax
  depended on the player's exact WAIT count. Designs should express
  timed beats as *preconditions plus ordering* ("the wolf night is the
  last night, and comes once the player commits to a vigil"), which is
  both what the author means and what is implementable.
- **The dictionary-collision audit (§11.2) was for v3** and mostly moot
  at v8's 9 characters — but it did not flag the two collisions that
  actually mattered (`TOMBSTONE`/`TOMBSTONES`, at 9 chars) or the
  reserved-atom hazard, which is not a dictionary issue at all.
- **Underspecified: where the player's kit comes from.** The design says
  Van Helsing issues crucifixes "before the Carfax raid", but the wolf
  night — which needs a crucifix — happens *before* that. Designs should
  list, per scene, the objects the player must be holding, and the build
  should assert it. I lost a cycle to "show crucifix to wolf → You don't
  have that!".
- **Underspecified: container state.** The shaving glass and letter paper
  are "in the travelling bag", but nobody said whether the bag is open.
  It was closed, so `EXAMINE GLASS` failed and the mirror scene was
  unreachable. Worth a blanket rule: **starting containers are open
  unless the design says otherwise.**
- Two things the design flagged as risky that were not: v8 flag pressure
  (never came close) and the `LOOK OUT WINDOW` / `CLIMB OUT` two-word
  forms (both trivial). Its "confirm early with a spike" advice was right
  even so — the spike cost ten minutes and bought certainty.

---

## 5. Process notes

**Order that worked, and would repeat:**

1. Get the *existing* skeleton compiling again before writing a line.
   (Ours did not — it had a latent world-file error.)
2. Inventory what's missing mechanically before writing prose:
   `grep -oh '[A-Z0-9?-]*-FCN' dworld.zil | sort -u` against the routines
   that exist. That diff is your true work list; mine was 77 routines.
3. Write a whole act, compile, then **play it**. Not more than one act
   between plays.
4. Build the walkthrough *incrementally alongside the act*, not at the
   end. Every command in it is a test.
5. Freeze the transcript only once the run is green, then diff forever.

**Testing efficiently.** A ~20-line driver that pipes a command file into
`loadGame` and prints the transcript is worth writing in the first ten
minutes (`play.mjs` here). Then the loop is one command, and you grep the
output rather than reading it:

```bash
node play.mjs dracula.z8 walkthrough.txt > /tmp/wt.txt 2>&1
grep -n "can't\|Huh\|don't have\|aren't here" /tmp/wt.txt | head
```

**Make `verify.mjs` assert content, not just the score.** Ours checks the
victory banner, the exact score, all six journal headers *in order*,
seventeen named puzzle beats by regex, and — most valuable of all — that
no parser-failure string appears anywhere in a clean run:

```js
for (const bad of [/You can't see any /, /I don't know the word/,
                   /That sentence isn't one I recognize/, /You don't have that!/]) {
  check(!bad.test(transcript), `parser failure: ${transcript.match(bad)?.[0]}`);
}
```

That last check caught three real bugs the score assertion missed
entirely, because a walkthrough can reach a winning score while several
of its commands are silently failing.

**Test the branches you are not shipping.** The Lucy-lost path, each
designed death, and the sunset failure were all exercised with separate
short command files built by truncating the main walkthrough at a known
point and appending divergent commands:

```python
t = open('walkthrough.txt').read()
open('/tmp/d5.txt','w').write(t[:t.index('draw circle')] + 'draw circle\nwait\nwait\nexit circle\n')
```

Three of those runs found bugs that the happy path never touched (the
Bloofer Lady never appearing, Godalming refusing the stake, the circle
having no way out).

**Where effort actually went**, roughly:

| | |
|---|---|
| Writing act logic and prose | ~35% |
| Fighting the parser / verb plumbing | ~30% |
| Timer sequencing and re-sequencing | ~20% |
| Walkthrough + verify + branch testing | ~15% |

The 30% on the parser is the number to plan around. Prose is fast; the
gap between "the design says the player types X" and "the parser accepts
X and routes it to my routine" is where a novel adaptation actually
lives. **Spike every non-stock verb form on day one**, before any content
depends on it.

**What I would do differently:** run the dictionary-collision script and
a reserved-atom grep *before* naming a single object, and write the
`AWARD` tally check into `verify.mjs` from the start so the score budget
can never drift out of agreement with `SCORE-MAX`.
