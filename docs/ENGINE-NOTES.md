# Engine notes: traps, idioms, and process

Hard-won findings from building five full-length adaptations on the Zork I
engine (see `adventures/`). Everything here was hit by a real build and
verified; where several games hit the same thing independently, it is
marked **[confirmed by N games]** — those are the ones that will cost you
a day if you meet them cold.

Per-game detail lives in each `adventures/<game>/LESSONS.md` and
`BUILD-ISSUES.md`. This file is the distilled, cross-cutting version.

## Do these before writing any game logic

1. **Use `(LOC ROOMS)`, never `(IN ROOMS)`, on every room.**
   [confirmed by 3 games] `IN` is a registered direction, so `(IN ROOMS)`
   compiles as the property `IN = ROOMS` and silently destroys that room's
   `IN` exit — walking in answers "You can't go there without a vehicle."
   Tiny Quest has the same duplicate but is masked, because both of its
   entries happen to decode as plausible one-byte exits. One game lost 90
   minutes to this; the symptom points at vehicles and flags, never at
   property emission.

2. **Run a noun/adjective collision audit.** [confirmed by 3 games] A word
   declared as both `SYNONYM` (noun) and `ADJECTIVE` becomes unusable as a
   noun: the parser tests the adjective bit first (`gparser.zil:548`) and
   never reaches the noun branch. The symptom is maddening — an object
   plainly in the room that the parser insists isn't there, while
   `EXAMINE <adjective> <noun>` works. This is 1980 Infocom parser
   behaviour, not a compiler bug, so it cannot be fixed, only avoided.
   Sweep `zil/zork1/gglobals.zil` too: it permanently claims `STONE`,
   `SAILOR`, `WATER`, `SAND`, `HANDS` and others. One game had 16
   collisions, another 13. The audit script is in
   `adventures/monte-cristo/LESSONS.md` §1.2.

3. **Grep the engine for `<CONSTANT` and `<GLOBAL` before naming objects.**
   Parser constants share a namespace with your objects. An object named
   `STAKE` shadowed `<CONSTANT STAKE 8>` and corrupted the parser's HAVE
   check — with the symptom appearing on a *completely unrelated* object
   ("You don't have that!" for something plainly in inventory). Biggest
   single time sink in that build.

4. **Run a 9-char dictionary-collision check.** Two synonyms agreeing in
   their first nine z-chars fail the build with `SYNONYM word missing from
   vocab`, naming no word, no file, no line. (`BUCCANEER` vs
   `BUCCANEERS`.) Note `-` and digits cost two z-chars each.

5. **Neutralise `FUMBLE-PROB`.** It puts `RANDOM` on your critical path
   above 7 carried items, breaking transcript determinism, behind a
   message that reads like an intentional inventory limit. Put
   `<SETG FUMBLE-NUMBER 100>` and `<SETG FUMBLE-PROB 0>` in `GO`.

6. **Never bake an article into `DESC`.** The engine supplies its own, so
   `(DESC "the Scarecrow")` yields "You can't talk to the the Scarecrow!"
   The sharper half of this: engine strings hardcode the article too —
   `V-TELL` prints `"The " D ,PRSO " pauses for a moment..."`, so a proper
   name gives "The Toto pauses for a moment." That article lives inside
   the engine and cannot be edited, only intercepted. The rule is
   therefore two-part: **common noun** ("wooden bucket") → leave it
   article-free and let the engine article it; **proper name** ("Toto")
   → also give the object a `<TALKING?>` clause in its ACTION routine so
   the generic message never fires. Sweep every `ACTORBIT` object whose
   DESC starts with a capital for a missing TELL clause.

## Scoring

- **`(VALUE n)` awards nothing.** [confirmed by 4 games] Stock `V-TAKE`
  never calls `SCORE-OBJ`, and the other call site is compiled out under
  `ZORK-NUMBER 0`. Every point must be awarded explicitly in your own
  routines, with a one-shot flag per award.
- **Never award points inside a TAKE branch.** [confirmed by 2 games] The
  parser's implicit take (`ITAKE-CHECK` → `ITAKE` directly) bypasses object
  ACTION routines, so `READ SPOT` can take the object, skip your handler,
  and lose the award *permanently* — a later `TAKE SPOT` answers "You
  already have that!" Sweep possession from a clock demon instead. The
  symptom is a final score quietly low by a few points with no visible
  cause.
- The same bypass defeats puzzle gates: `UNLOCK DOOR WITH KEY` grabbed a
  key one game's central trap depended on being unreachable, which would
  have shipped a game finishable 100 moves early. **Guard at the point of
  use, not on the object.**

## Parser and verbs

- **`<VERB? X>` names an ACTION, not a verb word.** [confirmed by 2 games]
  `KILL`→`ATTACK`, `PULL`→`MOVE`, `JUMP`→`LEAP`, `HIDE`→`PUT`. Generate the
  mapping from `gsyntax.zil`; guessing wastes a compile at best and
  silently never fires at worst.
- **`PERFORM` order**: actor → room `M-BEG` → preaction → PRSI → PRSO →
  default. Two consequences: PRSI's action runs *before* PRSO's (so
  `GIVE STAKE TO ARTHUR` belongs on Arthur), and the actor routine is the
  universal backstop for anything a room cannot reach.
- **Preactions are per-action, not per-syntax-line.** Adding your own
  `<SYNTAX ...>` does not escape the stock preaction that vetoes it; you
  must redefine the `PRE-` routine.
- **Syntax forms that fight back**: `REMOVE X`, `BLOW X`,
  `THROW X AT <scenery>`, and most two-noun phrases. Forms that work
  fine despite looking risky: `LOOK OUT WINDOW`, `CLIMB OUT`,
  `ASK X ABOUT Y` (route it to the engine's `V-TELL` so one
  `<VERB? TELL>` handles ASK/TELL/TALK together).
- **`READ` on a `READBIT` object with no `TEXT` property prints garbage** —
  `V-READ` treats the missing property as a string address and walks off
  into the story file.
- **Scope is the tax on this engine.** Anything the player may name must be
  in scope. Objects that appear mid-game (a raft you build, water you
  throw) need `(IN LOCAL-GLOBALS)` and a listing in the room's
  `(GLOBAL ...)` *before they exist*. One builder spent a third of its
  debugging on "you can't see any X here."
- **Conversation topics** belong in `GLOBAL-OBJECTS`, not `LOCAL-GLOBALS`,
  and need a `RETIRE-CAST` routine at each act boundary.

## Actors and companions

- **Actor-addressed commands (`WOODMAN, CHOP TREE`) work**, with one gotcha
  that looks exactly like the feature is broken: `V-TELL` runs the actor's
  ACTION routine once with `VERB? TELL` *before* switching `WINNER`, so a
  conversation clause fires on the addressing pass and the companion
  delivers an idle line and then obeys. Guard it:

  ```zil
  <ROUTINE TALKING? () <AND <VERB? TELL HELLO> <NOT ,P-CONT>>>
  ```

- **Room `M-ENTER` fires before the follow demon moves your party**, so an
  entry scene that tests a companion's presence always fails. Place the
  companion yourself, or test a state global.

## Timers, demons, and scripted scenes

- **Drive scripted scenes from the room's `M-END`**, which fires exactly
  once per parsed turn. Do not drive them from the clock: `WAIT` is three
  ticks and will eat your beats. Exception: if the player is inside a
  vehicle, `M-END` goes to the vehicle, so those scenes need the clock plus
  a first-turn guard.
- **`<ENABLE <QUEUE rtn -1>>` runs forever** until `<DISABLE <INT rtn>>`. A
  scene that re-plays its closing paragraph in every room forever is this
  bug; six of one game's eight demons needed the fix.
- **Never key a timed beat to an exact turn or date.** Adding three flavour
  commands to a walkthrough silently skipped one game's climax, twice. Key
  beats to player readiness plus a one-shot done-flag.
- **Do per-turn housekeeping in the demon, not in room actions** — rooms
  with their own `M-ENTER`/`M-LOOK` branches never reach a shared
  per-act routine.
- Use `M-ENTER` for place-based triggers and `QUEUE` only for "in N turns,
  wherever you are." Mixing them up loses scenes.

## Playing through an LLM front end

These games are usually played with a model translating natural language
into parser commands, which changes two engine-level assumptions:

- **The clock only ticks on a successful parse**, and natural-language play
  produces far fewer successful parses than typed play. Measured over 50
  chatty inputs: a third never became a command at all (answered
  conversationally instead), and many of the rest were rejected — about
  **one clock tick per three player inputs**. Every timed beat, nudge, and
  daemon threshold must be tuned against a real LLM transcript, not against
  a hand-typed walkthrough, or it fires three times later than intended.
- **v4+ games have no status line**, so `session.status` carries a room
  name (read from the player object's parent in the object tree) but null
  score and turns. Test harnesses must assert on the SCORE command's text.

## Testing

**The walkthrough proves a game is completable. It cannot prove a game is
survivable.** A walkthrough is written by whoever built the game, so it
encodes their mental model and only demonstrates that someone who already
knows the answer can win. Every game in `adventures/` passed its
walkthrough while still stranding a real player. Testing needs three
layers, and only the first is common practice.

### 1. The walkthrough (proves completable)

- **Assert "no parser-failure strings anywhere in the transcript" in the
  very first version of your verifier.** [confirmed by 3 games] One game
  scored 97/100 while four commands silently failed; another found three
  bugs this way that its score assertion missed.
- **The walkthrough passing tells you nothing about failure states.**
  Three of one game's eight designed deaths were broken on first test.
  Derive death tests from the winning path programmatically: take the
  prefix up to a command, append the wrong move.
- Rebuild from source and `cmp` against the shipped story file. Every game
  here reproduces byte-identically, which is what makes a frozen
  transcript trustworthy.

### 2. Static audits (prove coherent)

`tools/audit-game.mjs` reads the game's own text and flags rooms whose
description names no way out, and places an NPC directs the player toward
in words the parser does not know. `tools/audit-mlook.mjs` catches a
narrower defect described below. Neither plays the game, so neither can be
fooled by a tester who knows the route.

The failure they were built for: an NPC said "come to the counting-house"
while COUNTING was not a dictionary word, in a room whose description
named no exit. The player typed eight sensible commands and quit.

**A finding is a question, not a defect.** On these five games most
findings are deliberate - scripted scenes, rooms you cannot leave yet,
impasses whose refusal text names the answer. Ask "can a lost player
learn a way out of here?" and accept "yes, the refusal tells them" as a
pass.

### 3. Wanderer tests (prove survivable)

A walkthrough of nothing but junk and unparseable input, asserting the
player still reaches the next act. This is the layer that catches
stranding, and it found bugs in every game that added one.

The recipe, distilled from the builder who developed it:

- **Build it from a real failing transcript.** Junk invented at your desk
  is too parseable - one builder's first wanderer passed while the game
  was still broken.
- **Assert four things**: reaches the location, scores *zero* (a wanderer
  that knows answers stops testing anything), does not die, and clears
  with at least five inputs of headroom. Passing by one input is a
  coincidence.
- **Assert the negative too** - that no nudge string appears in the
  *scored* transcript. That caught two leaks the moment timers were
  compressed.
- **Prove the test can fail**, then restore. An assertion that has never
  failed is a guess.
- **Add an unparseable-input variant.** Natural-language play yields
  roughly one parsed command per three player inputs, so a typed-junk
  wanderer never exercises the starved clock. One builder's LLM variant
  caught a bug its typed sibling structurally could not.
- **Read its transcript end to end.** It is the only time you see the game
  as a lost player does.

### What a walkthrough never types

The most transferable framing anyone produced this round: **list the verbs
a player types reflexively - LOOK, INVENTORY, EXAMINE, X, the compass -
and ask what your walkthrough does with each. Anything on that list it
never types is untested surface.** Real bugs found exactly there:

- `X` was not a synonym for `EXAMINE`. Every modern IF player types it;
  the walkthrough never did, because its author knew to type EXAMINE.
- Four scored objects were absent from `INVENTORY`, because a custom
  `<MOVE obj ,WINNER>` skips the housekeeping that clears `NDESCBIT`. The
  walkthrough never typed INVENTORY after taking anything.
- A room's `M-LOOK` override dropped the exit sentence its LDESC had. The
  LDESC still looks right in source and the room still works; only the
  text a player reads is wrong. Five of one game's six real defects were
  this. Note the distinction: a handler ending `<RTRUE>` *suppresses* the
  LDESC, so its text is all the player sees; one ending `<RFALSE>` merely
  prepends and the exits still print. Only the suppressing kind can hide a
  way out.

### Debugging the tests themselves

- **Dump, don't theorise.** When a walk or a word misbehaves, dump the
  room's property table or the word's dictionary entry. A 40-line script
  over the story file beats any amount of reading.
- **Test your matcher against real input before trusting its output.** The
  exit auditor here was "fixed" three times on guesses - line-0 matching,
  longest-text, truncation - before anyone checked whether its regex
  matched the sentences these games actually write. It did not: "The hall
  is north." failed to parse, producing 16 false positives across two
  games. A builder hit the same trap independently and wrote it up as *the
  dictionary dump confirmed a hypothesis I had already formed rather than
  testing it*.
- **A clean compile means almost nothing.** One builder wrote 2,700 lines
  between playtests: they compiled clean and had eleven runtime failures,
  four rooms made unreachable by a single property collision.

## Process that worked

The order every successful build converged on:

1. Read `gsyntax.zil`, then `gverbs.zil` for your verbs, then `gmain.zil`
   for `PERFORM` and the main loop. An hour here saves several later —
   almost every trap above is visible in the source if you look first.
2. Write the audit scripts (§"Do these before...") — they are ~15 lines
   each and the compiler's errors for these classes are near-useless.
3. **Stub-compile the whole world**: generate one no-op routine per
   `(ACTION ...)` reference with a shell loop and compile. This proves the
   world file is structurally sound and gives you a binary to spike
   against before any logic exists.
4. **Syntax spike**: one throwaway routine per new verb printing
   `[SPIKE: ok]`. Ten minutes, and it surfaces the weird ones early.
5. Act by act, compile and **play** after every increment, never more than
   ~300 lines between runs.
6. Grow the walkthrough as you go, so it doubles as the regression test
   from Act I onward.
7. Deaths and flavour after the happy path, then freeze the transcript.

Rough calibration from the five: a finished game runs 6,000-7,200 lines of
ZIL, 90-130 KB compiled, 30-45 rooms, 100-150 objects, 190-340 action
routines, and a 120-220 command walkthrough.
