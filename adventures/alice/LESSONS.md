# LESSONS: building a novel adaptation on the Zork engine

Written for whoever builds the next book on this engine. You have a design
document; you do not have the two days of debugging that turned WONDERLAND's
design into a working 100-point game. This is that.

Companion document: `BUILD-ISSUES.md` in this directory lists the ten engine
defects and constraints with copy-pasteable fixes. **Read that first** — it
will save you more time than anything here. This file is about method: what to
build in what order, which idioms held up, and which of my ideas were wrong.

Final shape of this game, for calibration: 26 rooms, 121 objects, 20 new verbs,
~3,700 lines of ZIL across four files, 114 KB compiled as v8, 135-command
walkthrough scoring 100/100 deterministically.

---

## 1. The single most valuable habit

**Compile and play after every increment, and read the transcript.** Not "run
the tests" — actually read what the game printed. Nearly every bug in this
build was invisible from the source and obvious in the transcript:

- `TAKE JAR` printing "You can't see any jar here!" (the fall advanced too
  fast, so the scoring window never opened)
- `UNLOCK DOOR WITH KEY` printing "(Taken)" at ten inches tall (the parser
  force-took a key the puzzle depended on being unreachable — this defeated
  the entire first act and would have shipped)
- `EXAMINE MOUSE` failing in a room whose description lists a Mouse (a
  part-of-speech collision, item 4 in BUILD-ISSUES)

None of those produce a compiler warning. All three were one line of transcript
away from being caught immediately, and one of them I *did* let sit for a while
because I was building outward instead of playing.

The harness is `node czil/tests/play.mjs game.z8 script.txt`. Keep a few short
scripts around — a boot script, one per act — and run them constantly.

---

## 2. Order of work that went smoothly (and where I got it wrong)

What worked:

1. **Skeleton compiles and boots** before any content.
2. **Core mechanic first, tested in isolation.** For this book that was the
   size system; for another it might be time-of-day, or inventory-as-memory.
   Build it, then write a script that exercises every gate at every state.
3. **Act 1 fully playable** — including scoring — before writing Act 2.
4. Acts 2 and 3 outward from there.
5. Walkthrough → freeze transcript → verifier.

Where I got it wrong: I wrote all of Acts 2 and 3 (about 2,700 lines) between
compiles, having only ever played through the pool of tears. They compiled
clean, which felt like progress and was not: the first real playthrough hit
eleven distinct failures, several of them structural (the `IN` direction
collision broke four rooms at once). Had I played each act as I wrote it, I
would have found the `IN` bug after the first room that used it instead of
after the fourth.

**Rule: never write a second scene on an untested mechanic.** Compiling is not
testing. A clean compile of 2,700 lines of ZIL means almost nothing.

Rough effort split, honestly measured: 30% writing prose and puzzle logic, 45%
debugging parser and engine behaviour, 15% walkthrough iteration, 10%
documentation. Budget for debugging to be the largest slice; it will be.

---

## 3. ZIL idioms that worked

### A single global for the core mechanic, with one routine owning all its consequences

The size system is one global and one transition routine. Every consequence of
a size change lives in `CHANGE-SIZE` — nothing else in the game writes
`ALICE-SIZE` except the three scripted set-pieces that deliberately bypass the
transition rules.

```
<GLOBAL ALICE-SIZE 2>          ;"1 = SMALL, 2 = NORMAL, 3 = LARGE"

<ROUTINE SMALL? () <==? ,ALICE-SIZE 1>>
<ROUTINE NORMAL? () <==? ,ALICE-SIZE 2>>
<ROUTINE LARGE? () <==? ,ALICE-SIZE 3>>

<ROUTINE CHANGE-SIZE (NEW "OPTIONAL" (VIOLENT <>) "AUX" OLD)
	 <SET OLD ,ALICE-SIZE>
	 <SETG ALICE-SIZE .NEW>
	 ;"shrinking drops what you cannot hold"
	 <COND (<AND <L? .NEW .OLD> <IN? ,GOLDEN-KEY ,WINNER>> ...)>
	 ;"only VIOLENT changes slam doors -- this is the whole puzzle"
	 <COND (<AND .VIOLENT <FSET? ,LITTLE-DOOR ,OPENBIT>> ...)>
	 ;"and the scripted consequence of arriving small in a flooded room"
	 <COND (<AND <==? .NEW 1> ,POOL-EXISTS> <POOL-SLIP>)>
	 T>
```

The `VIOLENT` flag is the design's central rule ("bottle magic slams doors,
mushroom magic is gradual") expressed as one optional argument. Every caller
either passes it or does not, and the rule is enforced in exactly one place.
When I later needed to prove the game had no unwinnable states, that proof was
a two-line read of this routine plus one playthrough.

**Transferable:** find your book's one state variable, give it predicates, and
make one routine own every side effect. Resist scattering `<SETG>` calls.

### Size-variant room descriptions in the room ACTION at `M-LOOK`

`LDESC` holds nothing; the routine prints the right variant and returns true:

```
<ROUTINE HALL-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK> <HALL-LOOK> <RTRUE>)
	       ...

<ROUTINE HALL-LOOK ()
	 <COND (<SMALL?> <TELL "The hall is a cathedral now...">)
	       (<NORMAL?> <TELL "You are in a long, low hall...">)
	       (T <TELL "You fill a startling amount of this hall...">)>
	 ;"then append conditional sentences for state: curtain, key, pool"
	 <COND (<NOT ,CURTAIN-MOVED> <TELL " Along one wall hangs a low curtain.">)>
	 <CRLF>>
```

Composing the description from a base variant plus conditional sentences kept
the hall correct across roughly a dozen state combinations without a
combinatorial explosion of text.

### `M-BEG` for interception, `M-END` for heartbeat

This division held everywhere:

- **`M-BEG`** — intercept a command *before* the parser's pre-actions can
  reject it. This is the escape hatch for every engine constraint in
  BUILD-ISSUES: bare-word `SAY`, `FILL` on scenery, `IN` as a direction.
  Return `<RTRUE>` to consume the turn.
- **`M-END`** — advance scripted sequences and ambient events, one beat per
  turn. Return `<RFALSE>` so the turn completes normally.

Reading the quoted-say buffer at `M-BEG` is the one genuinely obscure trick,
and it is worth knowing because it is the only way to accept a bare word:

```
<COND (<AND <VERB? SAY> <NOT ,PRSO> ,P-CONT
	    <EQUAL? <GET ,P-LEXV ,P-CONT> ,W?NONSENSE ,W?STUFF>>
       <SETG P-CONT <>>
       <SETG QUOTE-FLAG <>>
       <SAY-NONSENSE>
       <RTRUE>)>
```

Clearing `P-CONT` and `QUOTE-FLAG` is mandatory; skip it and the parser tries
to keep reading the rest of the line as a new command.

### Scripted sequences as one counter advanced from `M-END`

The Rabbit's-house siege and the twelve-beat trial are each a single integer
plus a dispatch routine. Tagged player actions jump the counter; `WAIT`
advances it; nothing can stall it forever.

```
<ROUTINE TRIAL-BEAT ()
	 <COND (<==? ,TRIAL-PHASE 1> <SETG TRIAL-PHASE 2> <TELL "...">)
	       (<==? ,TRIAL-PHASE 2> <SETG TRIAL-PHASE 3> <TELL "...">)
	       ;"beats that wait for the player use a nudge counter"
	       (<==? ,TRIAL-PHASE 5>
		<SETG TRIAL-NUDGE <+ ,TRIAL-NUDGE 1>>
		<COND (<G? ,TRIAL-NUDGE 2> <DO-NOTHING-WHATEVER>)
		      (T <TELL "the King repeats the question...">)>)>
	 <RFALSE>>
```

The nudge counter is what makes a set piece feel alive rather than stuck: the
scene re-prompts twice in the player's own voice, then resolves itself. Every
interactive beat in the trial does this, so a player who types nothing but
`WAIT` still sees the whole trial and reaches the ending (minus the points for
the beats they did not take). That property is worth designing for
deliberately.

**One warning:** be generous with these acceptance windows. My cat-verdict beat
originally accepted the answer only at exactly `CROQ-STAGE 3`; the walkthrough
delivered it at stage 2 and silently lost 3 points. Accept a *range* of states
wherever the player might reasonably act early:

```
<COND (<AND <EQUAL? ,HERE ,CROQUET-GROUND>
	    <G? ,CROQ-STAGE 0> <L? ,CROQ-STAGE 4>>
       <CAT-VERDICT T>)
```

### Gated exits as `PER` routines that return a room or print a reason

```
<ROUTINE BRAMBLE-TUNNEL-EXIT ()
	 <COND (<NOT <SMALL?>>
		<TELL "The tunnel under the brambles would suit a rabbit, or
a very small girl; you are at present neither." CR>
		<RFALSE>)
	       (<NOT ,PUPPY-BUSY>
		<TELL "Between you and the tunnel stands the puppy..." CR>
		<RFALSE>)
	       (T <RETURN ,MUSHROOM-CLEARING>)>>
```

Return the room to travel, `<RFALSE>` after printing to refuse. Each refusal
gives a *reason*, which is both the tone rule and the hint system. Caveat: the
`IN` direction is unusable this way (BUILD-ISSUES item 3).

### One-shot scoring flags

`SCORE-UPD` adds points but has no memory. Every award needs a guard:

```
<COND (<NOT ,F-PUPPY> <SETG F-PUPPY T> <SCORE-UPD 3>)>
```

Then verify total-points-defined equals `SCORE-MAX`:

```bash
grep -oE "SCORE-UPD [0-9]+" *.zil | awk -F'SCORE-UPD ' '{s+=$2} END {print s}'
```

Mine read 107 against a max of 100 — that discrepancy correctly flagged an
unguarded award and two awards reachable by two different routes.

---

## 4. Things I tried that did NOT work

**`(VALUE n)` for scoring.** Looks like the intended mechanism, is completely
inert on a plain `TAKE`. Four objects silently scored nothing. See
BUILD-ISSUES item 1.

**Guarding a puzzle item only in its own `ACTION` routine.** The parser's
implicit take bypasses `ACTION` entirely, so `UNLOCK DOOR WITH KEY` picked up a
key that `TAKE KEY` correctly refused. Guard at the point of use.

**`TOUCHBIT` / flag-twiddling to suppress the "Sitting on the glass table is:"
listing.** No flag combination on a `SURFACEBIT` container suppresses
`FIRSTER`'s automatic listing. The actual fix is structural: do not make the
table a container. Put the key in the room and mention it in the room
description. I did not get to this one — it is the last cosmetic blemish in the
game.

**Assuming `<VERB? X>` accepts the word players type.** It accepts *action*
names. `PULL`, `HIT`, and `CURSE` are all surface words that map to differently
named actions. See BUILD-ISSUES item 5.

**Assuming a clean compile meant the world was wired up.** 2,700 lines
compiled clean and had eleven distinct runtime failures, including four rooms
made unreachable by a single property-name collision.

**Trusting the design's move-by-move walkthrough verbatim.** Four commands in
DESIGN.md's 134-move sequence are not expressible in this parser. That is not
the designer's fault — those constraints are only discoverable by building —
but do expect to rewrite some of it, and *document each divergence in the
walkthrough file itself* so the next reader knows it was deliberate.

**Deferring the walkthrough to the end.** Because the walkthrough is the only
thing that exercises the whole game, and because acts interact (the procession
timer collides with the painting puzzle; the trial's growth collides with the
jury-box beat), late integration concentrated all the timing bugs into one
painful session. Write the walkthrough incrementally, act by act.

---

## 5. Design-to-implementation friction

Feedback for whoever writes the next DESIGN.md, and for `docs/ADAPTING.md`.

**What the design got exactly right, and should be repeated:**

- **Every puzzle stated with its exact solution.** Never once did I have to
  guess what a puzzle wanted.
- **A points table summing to the maximum.** This is a checklist and a test
  oracle. I verified all 37 awards individually against it.
- **Drafted intro/outro prose.** The set pieces were transcription, not
  composition, and they are the best text in the game.
- **An explicit rule for the core mechanic** ("bottle slams doors, mushroom
  does not"). Stated as a rule rather than as a list of cases, it translated
  into one boolean argument and stayed consistent everywhere.
- **A stated no-unwinnable-states property.** This is testable, and I tested
  it. Ask for such properties explicitly.

**Where it was underspecified:**

- **Timing of scripted events is never stated in turns.** "The procession
  arrives on your first NORMAL-size presence" collided with a three-command
  painting puzzle, costing 3 points. Designs should say "N turns after X, but
  never before the player has had a chance to do Y," or better, name the
  events that must be allowed to complete first.
- **Acceptance windows for scene answers are unstated.** When can the player
  say the magic thing — only at the exact beat, or any time during the scene?
  Say "any time between X and Y". Assume early answers.
- **Parser phrasing is assumed to be free.** `SAY I AM NOT A MILE HIGH`,
  `PUT BILL IN BOX`, `GIVE TREACLE TO HATTER` all read naturally and none
  parse. Designs should give each key beat a *one-noun* fallback phrasing.
- **Container contents are treated as reachable objects.** "Fill the jar with
  treacle, then give the treacle to the Hatter" — the second half cannot work.
  Either the container is the object, or say so.
- **Inventory volume is never considered.** The design hands the player ~15
  objects. The engine fumbles above 7 and refuses above ~20 by weight, both
  with misleading messages.

**One structural suggestion.** The design's walkthrough was written before the
game existed, so it doubles as a specification and as a test. Those are
different jobs. Keep the design's move list as *intent*, and treat the shipped
`walkthrough.txt` as the authority, with divergences documented inline. That is
what I did here.

---

## 6. Testing that earned its keep

**The frozen-transcript verifier** (`verify.mjs`) does five things, and all
five have caught something:

1. every command consumed (catches early game-over)
2. victory text present (catches wrong ending)
3. `SCORE` output shows the max — **assert on text**, because v8 story files
   do not populate the v3 status globals and `session.status` is `null`
4. **no parser-failure strings anywhere in the transcript** — this is the
   highest-value assertion in the whole file. "You can't see any X", "You can't
   go that way", "don't have that", "too many things". A walkthrough can reach
   100 points while quietly failing commands, and this catches it. Mine did
   exactly that at 97 points with four silent failures.
5. byte-for-byte diff against the frozen transcript

**Run the walkthrough three times and compare.** Catches nondeterminism from
`RANDOM`. The engine's `FUMBLE-PROB` put a dice roll on my critical path
(BUILD-ISSUES item 6); three identical runs is how you prove it is gone.

**Test the no-unwinnable claim by deliberately playing badly.** I skipped the
entire Rabbit's-house sequence — no pebble-cakes, no spare — and confirmed the
mushroom path still reaches the garden and scores the +6. This found a real
asymmetry: from LARGE, one nibble reaches NORMAL, not SMALL, so the rescue
needs two. Worth knowing; not worth "fixing".

**Sample the absurdist responses.** A quick script of `PRAY`, `SING`, `JUMP`,
`CURTSEY`, `COUNT DOORS`, `EAT KEY`, `KNOCK ON HOLE` found three places where
Zork's voice leaked through ("You have lost your mind", "Why knock on a
rabbit-hole?"). In a game whose selling point is that it has an answer for
everything, these are real defects. Grep your transcripts for stock Zork
strings.

---

## 7. The five things I would tell another builder today

1. **Read `BUILD-ISSUES.md` before writing a line.** Items 1, 2, and 4 will
   each cost you an hour of confusion and are each a one-line fix if you know.
2. **Run the noun/adjective collision audit early** (item 4). It is ten lines
   of Python and it explains the single most baffling class of bug on this
   engine — an object that visibly exists and cannot be referred to.
3. **Never write a second scene on an untested mechanic.** A clean compile
   proves nothing about whether the world is reachable.
4. **Put the "no parser failures" assertion in your verifier on day one.**
   Scoring 100 does not mean the walkthrough is clean.
5. **Kill every source of randomness on the critical path immediately** —
   `FUMBLE-PROB` is the non-obvious one, and it is in the engine, not your
   game.
