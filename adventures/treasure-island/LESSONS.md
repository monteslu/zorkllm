# Lessons from building TREASURE ISLAND on the Zork I engine

Written for the next person adapting a different novel with czil + `zil/zork1`.
You have a design doc; this is the knowledge that is not in it.

Companion file: `BUILD-ISSUES.md` (toolchain defects and the workarounds this
game shipped). This file is the transferable part: idioms, dead ends, and
process.

Scale for calibration: 30 rooms, ~130 objects, ~3,100 lines of actions ZIL,
92KB v8 story file, 119-command winning walkthrough.

---

## 1. Engine gotchas, with fixes

### 1.1 `<VERB? X>` names an ACTION, not a verb word

The single most common compile error you will hit. `<VERB? KILL>` fails with
`unknown global V?KILL` because `V?` resolves against **routines named
`V-something`**, and `KILL` maps to `V-ATTACK`.

```
KILL   -> ATTACK      PULL   -> MOVE       JUMP    -> LEAP
DESTROY-> MUNG        ASK    -> TELL       LIGHT   -> LAMP-ON / BURN
HIDE   -> PUT (!)     THROW  -> THROW, OVERBOARD, PUT-ON, THROW-OFF
LOOK   -> LOOK, EXAMINE, LOOK-INSIDE, LOOK-UNDER, LOOK-ON, FIND, READ
CLIMB  -> CLIMB-UP, CLIMB-DOWN, CLIMB-ON, CLIMB-FOO, BOARD, THROUGH
```

Generate the map instead of guessing — this took two minutes and saved an hour:

```python
import re; s=open('zil/zork1/gsyntax.zil').read(); m={}
for x in re.finditer(r'<SYNTAX\s+([A-Z0-9-]+)\b[^=]*=\s*(V-[A-Z0-9-]+)', s):
    m.setdefault(x.group(1),set()).add(x.group(2))
for x in re.finditer(r'<SYNONYM\s+([^>]*)>', s):
    w=x.group(1).split()
    for k in w[1:]:
        if w[0] in m: m.setdefault(k,set()).update(m[w[0]])
```

Because one verb word maps to several actions, cover them all:
`<VERB? CLIMB-UP CLIMB-FOO CLIMB-ON>` — not `<VERB? CLIMB>`.

### 1.2 Implicit takes bypass object ACTION routines — score on possession

**Confirmed in this build, and it was a live bug in my own game.**
`ITAKE-CHECK` (gparser.zil:1272) performs the implicit take by calling
`<ITAKE <>>` directly, so `PERFORM` never runs and the object's ACTION never
sees a TAKE. Any syntax with `STAKE`/`SHAVE` in its bits triggers this — `READ`
is one of them.

Symptom in my game: `READ SPOT` printed `(Taken)`, took the black spot, and
skipped the `+5` in its TAKE branch. Worse, it was **unrecoverable** — a later
`TAKE SPOT` answers "You already have that!" and the award can never fire.
Score 345/350, cause invisible.

Do not award points in a TAKE branch. Sweep for possession on the clock:

```zil
<ROUTINE I-CARRIED ()
	<COND (<AND <NOT ,S-SPOT> <IN? ,BLACK-SPOT ,WINNER>>
	       <SETG S-SPOT T> <AWARD 5>)>
	<COND (<AND <NOT ,S-PACKET> <IN? ,PACKET ,WINNER>>
	       <SETG S-PACKET T> <AWARD 15>)>
	<RFALSE>>
```

This catches explicit and implicit takes alike, and the once-flag makes it
idempotent if you also keep the TAKE branch for its flavour text. **Write the
control test**: `read <thing>` then `score`, before you trust any pickup award.

The same bypass defeats gates. If your puzzle is "you must not pick this up
until X", `TRYTAKEBIT` + an ACTION check is not airtight — a verb with `STAKE`
will lift it out from under you.

### 1.3 `VALUE` properties are dead unless you call `SCORE-OBJ` yourself

`V-TAKE` is four lines and calls `ITAKE` then prints "Taken." It never touches
`SCORE-OBJ`. The only callers of `SCORE-OBJ` in the engine are `V-PUT` (the
trophy-case idiom), room scoring in `GOTO`, and a Zork II spell. So
`(VALUE 10)` on an object is silently inert in a game without a trophy case.
Award explicitly — `AUTHORING.md` mentions this, but it reads like a choice
rather than a requirement. It is a requirement.

### 1.4 `READ` on a `READBIT` object with no `TEXT` prints garbage

```zil
<ROUTINE V-READ ()
	 <COND (<NOT <FSET? ,PRSO ,READBIT>> <TELL "How does one read...">)
	       (T <TELL <GETP ,PRSO ,P?TEXT> CR>)>>
```

No guard. A missing `TEXT` property yields 0, which is interpreted as a string
address, and the interpreter prints whatever is at the bottom of the story
file — pages of dictionary spew. It looks like an interpreter crash; it is a
missing property. **Handle `READ` in every readable object's own ACTION** (you
want bespoke text there anyway) or give it a `TEXT` property.

### 1.5 The engine's global objects shadow yours

`gglobals.zil` puts a pile of objects in `GLOBAL-OBJECTS`, which is in scope
everywhere and wins ties. The two that bit me:

- **`HANDS`** is the player's hands. My antagonist was Israel Hands;
  `SHOOT HANDS` resolved to the body part and fell through to a generic
  refusal, silently, at the game's climax. Fix: make the distinctive word the
  first synonym (`ISRAEL`), and defensively short-circuit in the verb —
  at the cross-trees, `SHOOT` means one thing regardless of what parsed.
- **`GROUND`** owns the nouns `GROUND SAND DIRT FLOOR` and answers `DIG` with
  "The ground is too hard for digging here." Since `PERFORM` runs the PRSO's
  ACTION before the default verb, your room never gets a look in.

Before naming anything, grep: `grep -n "SYNONYM" zil/zork1/gglobals.zil`.

### 1.6 `PERFORM` order decides who can intercept what

Memorise this; nearly every "why doesn't my handler run" traces to it:

```
1. WINNER's ACTION            <- the actor routine; runs FIRST, sees everything
2. room ACTION with M-BEG     <- per-room interception, before preactions
3. the syntax PREACTION       <- e.g. PRE-BOARD; can refuse before you see it
4. PRSI's ACTION
5. PRSO's container CONTFCN
6. PRSO's ACTION
7. the default verb routine
```

Two consequences worth internalising:

- A **preaction can refuse before your object ever runs** (`PRE-BOARD` rejects
  anything without `VEHBIT`). Intercept at `M-BEG` in the room, or at the actor.
- The **actor routine is the universal backstop.** I used it for three things
  the room level could not reach: the `DIG` steal from `GROUND`, the barrel
  lock-in (the player is inside a vehicle, so the room is not `<LOC ,WINNER>`),
  and the movement rails during the treasure hunt.

Wire it in `GO`, since `ADVENTURER` ships with `(ACTION 0)`:

```zil
<PUTP ,ADVENTURER ,P?ACTION ,ADVENTURER-FCN>
```

### 1.7 `WAIT` is three clock ticks

`V-WAIT` calls `<CLOCKER>` three times, then sets `CLOCK-WAIT` to suppress the
main loop's tick. If you drive a scripted scene from a clock interrupt, one
typed `WAIT` eats three story beats and your carefully paced set piece
stutters past. See §2.1 for what to do instead.

### 1.8 `YES`/`NO` are buzzwords

`<BUZZ A AN THE IS AND OF THEN ALL ONE BUT EXCEPT . , " YES NO Y HERE>`. A
yes/no question cannot be answered with "yes". Design the choice as two real
verbs (I used `STAY` versus `FOLLOW DOCTOR`).

### 1.9 `X` is not `EXAMINE`

The engine predates the convention. Players type it constantly. One line:
`<SYNONYM EXAMINE X>`.

### 1.10 `ASK actor ABOUT topic` needs the topic to be a real object

`<SYNTAX TELL OBJECT (FIND ACTORBIT) (IN-ROOM) ABOUT OBJECT = V-TELL>` — the
topic is a parsed object, so `ASK BEN ABOUT TREASURE` dies with "You can't see
any treasure here!" unless a treasure object is in scope. Give yourself one
catch-all global holding the nouns players actually type; the actors ignore the
topic and answer in character:

```zil
<OBJECT TOPICS
	(IN GLOBAL-OBJECTS)
	(SYNONYM FLINT MUTINY ISLAND TREASURE HIMSELF ME EVERYTHING PLAN)
	(DESC "that subject") (FLAGS NDESCBIT) (ACTION TOPICS-FCN)>
```

### 1.11 Two compiler traps

- **`(IN TO room)` exits are broken** when the room also has `(IN ROOMS)` —
  duplicate property, wrong one wins. Full analysis in `BUILD-ISSUES.md`. If
  your map needs inward movement, plan on `IN` being a verb from the start.
- **`SYNONYM word missing from vocab`** names no file, line, or word. It means
  two vocabulary words agree in their first **nine z-chars** (v8) and the
  dictionary dedup dropped one that the object table still references by text.
  Mine was `BUCCANEER`/`BUCCANEERS`. `-` and digits cost two z-chars each.
  Script the collision check across your files plus `zil/zork1/g*.zil`.

---

## 2. ZIL idioms that worked

### 2.1 Scripted multi-turn scenes: drive them from `M-END`

The single most useful pattern in the game — every set piece uses it. `M-END`
fires **exactly once per successfully parsed turn** (gmain.zil:154),
independent of which verb was typed. One command, one beat, always.

```zil
<ROUTINE LOG-HOUSE-FCN (RARG)
	<COND (<EQUAL? .RARG ,M-ENTER>
	       <COND (<AND <EQUAL? ,PHASE 0> <NOT ,S-LOGHOUSE>>
		      <SETG SIEGE-STEP 1> <GARRISON-ARRIVAL> <RTRUE>)>
	       <RFALSE>)
	      (<EQUAL? .RARG ,M-END>
	       <COND (<G? ,SIEGE-STEP 0> <SIEGE-BEAT> <RTRUE>)>
	       <RFALSE>)>
	<RFALSE>>

<ROUTINE SIEGE-BEAT ()
	<SETG SIEGE-STEP <+ ,SIEGE-STEP 1>>
	<COND (<EQUAL? ,SIEGE-STEP 2> <TELL "...the embassy..." CR> <RTRUE>)
	      (<EQUAL? ,SIEGE-STEP 3> <TELL "...the lull..." CR> <RTRUE>)
	      (<EQUAL? ,SIEGE-STEP 4> <MOVE ,BOARDER ,LOG-HOUSE> ...)>
	<RFALSE>>
```

A counter global plus a `COND` ladder handled scenes of 3 to 9 beats without
strain. Interactive beats are just a step number the ladder refuses to advance
past — see §2.4.

**Watch the entry turn.** If the scene starts at `M-ENTER`, the same turn's
`M-END` fires immediately and eats beat 2. Either print beat 1 in the
`M-ENTER` branch (what I did) or carry a one-shot `FRESH` flag.

### 2.2 Scenes where the player is inside a vehicle need the clock

`M-END` is dispatched to `<LOC ,WINNER>`. Inside the apple barrel that is the
barrel, not the deck, so the room's routine goes silent for the whole set
piece. That scene runs off a clock demon with a first-turn guard:

```zil
<ROUTINE I-SCENES ()
	<COND (<AND <G? ,BARREL-STEP 0> <L? ,BARREL-STEP 90>>
	       <COND (,BARREL-FRESH <SETG BARREL-FRESH <>> <RFALSE>)>
	       <BARREL-BEAT> <RTRUE>)>
	<RFALSE>>
```

Because of §1.7 this means one `WAIT` = three beats there — acceptable for a
scene the player is meant to sit through, but check it in play.

### 2.3 Daemons: one `-1` queue, enabled in `GO`

```zil
<ROUTINE INIT-SCENES ()
	<ENABLE <QUEUE I-BENBOW  -1>>   ;"act-I countdown"
	<ENABLE <QUEUE I-SCENES  -1>>   ;"vehicle-bound scene driver"
	<ENABLE <QUEUE I-PARROT  -1>>   ;"ambience"
	<ENABLE <QUEUE I-CARRIED -1>>   ;"possession scoring, see 1.2"
	<RTRUE>>
```

`-1` is "every turn forever"; the routine decides whether it is relevant.
Have each demon bail immediately on the wrong act (`<COND (<NOT <EQUAL? ,ACT
1>> <RFALSE>)>`) or you will get an Act I death timer firing in Act III. That
exact bug cost me a debugging cycle: the Benbow clock killed the player in the
squire's hall because the act global had not advanced.

### 2.4 Interactive beats: hold the counter, answer in a verb

For a scene that must pause for a real decision (the parole), make the step a
stable state the beat routine refuses to advance:

```zil
<ROUTINE CAPTIVE-BEAT ()
	<COND (<EQUAL? ,CAPTIVE-STEP 7> <RFALSE>)>   ;"hold for the answer"
	<SETG CAPTIVE-STEP <+ ,CAPTIVE-STEP 1>>
	...>
```

Then `V-STAY` keeps the parole and the escape verbs break it. `WAIT` holds the
prompt open indefinitely, which is the forgiving behaviour you want.

### 2.5 NPC state machines: one object, one global, `COND` on state

Silver is one object with five states in a global (`PHASE`), not five objects.
Every actor routine has the same shape — verb first, state second:

```zil
<ROUTINE SILVER-FCN ()
	<COND (<AND <VERB? GIVE> <EQUAL? ,PRSO ,SQUIRE-NOTE> <NOT ,NOTE-GIVEN>>
	       ...the Black Dog scene... <RTRUE>)
	      (<VERB? EXAMINE>
	       <COND (<G? ,PHASE 3> <TELL "...holding the end of your rope..." CR>)
		     (T <TELL "...the most frightening thing you have ever been
fond of." CR>)>
	       <RTRUE>)
	      (<VERB? ATTACK SHOOT> <TELL "He is twice your size..." CR> <RTRUE>)
	      (<VERB? TELL HELLO> ...state-dependent brush-off... <RTRUE>)>>
```

Always give actors an `ATTACK` and a `TELL`/`HELLO` branch. Those are the two
things players try on every NPC, and the engine's defaults ("Insults of this
nature won't help you") break the fiction instantly.

Move actors with the scene: `<MOVE ,SILVER ,SKELETON>` at each hunt beat. A
tiny helper for a travelling party pays for itself:

```zil
<ROUTINE MOVE-PARTY (RM)
	<MOVE ,DOCTOR .RM> <MOVE ,GRAY .RM> <MOVE ,BEN-GUNN .RM>
	<MOVE ,SILVER .RM> <RTRUE>>
```

### 2.6 Phase-switched rooms: branch `M-LOOK`, do not duplicate the room

Three rooms serve two acts (the deck, galley and cabin, before and after the
mutiny). One room object, no `LDESC` property, and a branch on `M-LOOK`:

```zil
<ROUTINE GALLEY-FCN (RARG)
	<COND (<EQUAL? .RARG ,M-LOOK>
	       <COND (,SEA-PHASE <TELL "...ransacked, the cage empty..." CR>)
		     (T <TELL "...clean as a new pin..." CR>)>
	       <RTRUE>)>
	<RFALSE>>
```

Confirmed stable across the frozen transcript. Cheaper than swapped rooms and
it keeps exits, globals and object contents in one place.

### 2.7 State-gated exits: `PER` routines beat `IF`-clauses

A `PER` routine returns a room (go there), or prints and returns false:

```zil
<ROUTINE HILLFOOT-UP-FCN ()
	<COND (<EQUAL? ,PHASE 6> ,BEN-CAVE)
	      (T <TELL "The cliff wants a guide who knows it." CR> <RFALSE>)>>
```

More flexible than `(UP TO X IF FLAG ELSE "...")` because the refusal text can
vary with state, and one routine can serve several phases. Used for every
one-way act gate.

### 2.8 Deterministic combat

The design asked for a byte-stable transcript, so the boarder is a counter, not
a dice roll — and it reads no worse:

```zil
<COND (<AND <VERB? ATTACK CUT> <OR <EQUAL? ,PRSI ,CUTLASS> ...>>
       <SETG BOARDER-IDLE 0>
       <SETG BOARDER-HITS <+ ,BOARDER-HITS 1>>
       <COND (<EQUAL? ,BOARDER-HITS 1> <TELL "...he comes on again." CR>)
	     (T <SIEGE-VICTORY>)>)>
```

Danger comes from an idle counter (three turns of not fighting kills you), not
from randomness. `FIND-WEAPON` must still return a real weapon or the engine's
combat verbs misbehave:

```zil
<ROUTINE FIND-WEAPON (WHO)
	<COND (<AND <EQUAL? .WHO ,WINNER> <IN? ,CUTLASS ,WINNER>> ,CUTLASS)
	      (<AND <EQUAL? .WHO ,WINNER> <IN? ,GULLY ,WINNER>> ,GULLY)
	      (T <RFALSE>)>>
```

### 2.9 Layered container reveals

The sea-chest peels in three layers using `INVISIBLE` and falling through on
`TAKE` so the engine still prints "Taken.":

```zil
<ROUTINE CLOTHES-FCN ()
	<COND (<AND <VERB? TAKE MOVE> <FSET? ,CHEST-ODDMENTS ,INVISIBLE>>
	       <FCLEAR ,CHEST-ODDMENTS ,INVISIBLE>
	       <TELL "You lift the clothes clear. Below them..." CR>
	       <COND (<VERB? TAKE> <RFALSE>)>   ;"let V-TAKE finish the job"
	       <RTRUE>)>>
```

That `<COND (<VERB? TAKE> <RFALSE>)>` line is the trick worth stealing:
handle the side effect, then hand the verb back to the engine.

### 2.10 Two endings that are not death

`JIGS-UP` is for death. For a lost-but-alive ending and for victory, write
siblings that reuse `FINISH` (which offers RESTART/RESTORE/QUIT):

```zil
<ROUTINE GAME-OVER (DESC)
	<TELL .DESC CR CR> <TELL "    ****  Your adventure is over  ****" CR CR>
	<FINISH>>
```

The raid that finds the packet you failed to steal ends the game in the
squire's disappointment rather than killing you, which is a much better beat
than a death message.

---

## 3. Things that did NOT work

- **`(IN TO room)` exits.** Cost the most time of anything in the build:
  roughly ninety minutes, because the symptom ("You can't go there without a
  vehicle") points at vehicles and flags, not at property emission. I checked
  `RLANDBIT`, wrote an object-table dumper, and compared against Tiny Quest
  before finding the duplicate property. **If a walk fails inexplicably, dump
  the room's property table before theorising.** A 40-line script over the
  story file is faster than any amount of reading.

- **Re-declaring a syntax to drop its preaction.** `<SYNTAX BOARD OBJECT
  (ON-GROUND IN-ROOM) = V-BOARD>` does not remove `PRE-BOARD`; czil merges the
  duplicate and keeps the original preaction. Intercept at `M-BEG` instead.

- **Reordering object clauses to fix the property collision.** `(IN TO Y)`
  before `(IN ROOMS)` emits in the same order regardless. Source order does
  not control property emission order.

- **Trusting `PER` to sidestep the collision.** `(IN PER FCN)` produces the
  same duplicate property; the routine is simply never reached.

- **Awarding points in a TAKE branch** (§1.2). Looked correct, passed the
  walkthrough, and was silently unreachable by the natural phrasing.

- **Deriving the minimal-path walkthrough from the full one with a script.**
  I tried three times with pattern-matching edits and produced three different
  broken routes, because dropping the optional detour also drops the movement
  commands that get you home. The map is a graph; text edits do not respect it.
  Write the second walkthrough by hand, or generate it and then actually read
  the transcript's room names.

- **`SHOOT HANDS` as the climax command.** Correct English, correct design,
  wrong parse (§1.5). Test your set-piece commands with the *exact* wording
  your walkthrough uses, not a paraphrase.

---

## 4. Design-to-implementation friction

`DESIGN.md` was unusually complete — 1,350 lines with per-puzzle solutions, a
113-command walkthrough, and a build-notes section that anticipated the version
target and most dictionary collisions. Nearly all of it survived contact. What
follows is the delta, offered as guidance for writing the next design.

**What made this design implementable, and should be copied:**

- **A command-level walkthrough in the design.** It is the acceptance test, the
  spec for scene lengths, and the thing that catches "this puzzle has no verb"
  before you write code. Worth more than any prose section.
- **A scoring table with a running total.** I checked the score after every act
  and caught drift instantly. Numbers that add to a stated maximum are a
  self-checking spec.
- **Per-puzzle failure text.** Given, so I never had to invent under pressure,
  and the game's voice stayed consistent through 3,000 lines.
- **An explicit determinism requirement.** "No RANDOM between the player and
  victory" made the combat design decision for me and made CI possible.

**Where it was underspecified, and what I would ask for next time:**

- **Scene beat counts versus player commands.** The design said "five turns of
  overheard mutiny" without saying whether a beat advances on any command or
  only on `WAIT`. That is the central mechanic of a scripted scene and it needs
  stating: *"one parsed command advances one beat, any verb."*
- **Which beats are interactive.** The council, the parole and the ambush all
  read as prose paragraphs, but one of them (the parole) must stop and wait for
  a decision. Designs should mark interactive beats explicitly.
- **Verb phrasing per puzzle, not per verb list.** §11 listed the new verbs but
  the walkthrough used `SHOOT HANDS`, `PULL CORD`, `MOVE GEAR`, `GO ASHORE` —
  each of which needed parser work that the verb list did not predict. A design
  that gives the exact command string per puzzle step surfaces this at design
  time.
- **Object-name collisions with the *engine*, not just within the game.** §11's
  collision watch-list was excellent, but scoped to the game's own vocabulary.
  It missed `HANDS` and `SAND`, both owned by `gglobals.zil`. Next design pass
  should grep the engine globals.

**Where it was wrong once built:**

- **The three-turn raid.** Written as six beats, it played as dead air; I merged
  two and it improved. Scene lengths on paper run long. Expect to cut ~20%.
- **"Enter the barrel, five WAITs."** With `WAIT` costing three ticks, this only
  works because the scene is clock-driven. Had it been `M-END`-driven the design
  would have been right; the interaction between the two was not foreseeable
  from the design.
- **The status-line note (§10.8).** Correctly flagged v8 as having no status
  line, but the consequence for testing — `session.status` is `null`, so CI must
  assert on `SCORE` text — surfaced only in the harness. Worth a line in
  `ADAPTING.md`.

---

## 5. Process notes

**The order that worked**, and I would repeat exactly:

1. **Read the engine before writing content.** `gsyntax.zil`, then `gverbs.zil`
   for the verbs you plan to use, then `gmain.zil` for `PERFORM` and the main
   loop. An hour here saves several later; almost every gotcha in §1 is visible
   in the source if you look before you write.
2. **Stub-compile the whole world first.** I generated one no-op routine per
   `(ACTION ...)` reference (122 of them) with a shell loop and compiled. That
   proved the 31KB dungeon file was structurally sound and gave me a working
   binary to spike against before any logic existed. Strongly recommended.
3. **Syntax spike before content** (this was in my brief and it earned its
   keep). Five new verbs, one throwaway routine each printing `[SPIKE: ok]`,
   compiled and played. Found in ten minutes: all five parse, and — the useful
   surprise — `READ` printing garbage, which would have been baffling to
   diagnose later inside a real scene.
4. **Act by act, compile and play after every increment.** Never more than
   ~300 lines between runs. Every act had 2-4 bugs; finding them against 300
   new lines is trivial and against 3,000 would not be.
5. **Grow the walkthrough as you go.** It doubled as the regression test from
   Act I onward. By the endgame it was running the full 119 commands on every
   compile, so a fix that broke Act II announced itself immediately.
6. **Deaths and flavour after the happy path**, then freeze the transcript.

**Testing efficiently.** Scripted play (`czil/tests/play.mjs`) is the whole
loop; the compile-and-play cycle is about two seconds. Two techniques paid off
beyond the walkthrough:

- **Derive death tests from the winning walkthrough programmatically** — take
  the prefix up to a command and append the wrong move. Eight death tests in
  one short script, all reproducible:

  ```python
  i = base.index('climb mast')
  open('d6.txt','w').write('\n'.join(base[:i] + ['wait','wait','wait']))
  ```

- **Run a control that must fail.** The `read spot` / `score` control in §1.2 is
  the reason that bug is fixed rather than shipped. If a mechanic is supposed to
  award points, prove it does *not* award them when you break it.

Three of eight designed deaths did not fire on first test (the hawser counter
reset, the parole needed an actor in scope, the raid peek counter reset). All
three would have shipped broken without explicit tests — **the walkthrough
passing tells you nothing about your failure states.**

**Where the effort went**, roughly: 15% reading the engine and spiking, 45%
writing actions ZIL, 30% debugging (of which the `IN`-exit hunt alone was a
third), 10% test harness and docs. The debugging fraction would have been much
worse without the incremental compile-and-play discipline.

**What I would do differently.** Dump the object/property table early — I wrote
that 40-line script only when desperate, and it immediately answered a question
I had been guessing at for an hour. Keep it in the directory from day one:

```js
// property table for object N, v4+ layout (6 flag bytes, 63 prop defaults)
const objtab = g16(0x0a) + 63*2, OBJSZ = 14;
let pa = g16(objtab + N*OBJSZ + 12); pa += 1 + m[pa]*2;
while (m[pa]) { /* walk sizes, print prop numbers */ }
```

Also: write the minimal/alternate walkthrough by hand from the start rather
than deriving it, and add the possession-sweep scoring demon (§1.2) before
writing a single award.
