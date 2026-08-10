# BUILD-ISSUES — THE SILVER SHOES

Engine/compiler constraints hit while building, the workaround used, and
any design adaptation that followed. Nothing outside
`adventures/wizard-of-oz/` was modified.

---

## 1. Dictionary dedup silently drops a spelling (czil, v8)

**Symptom:** `compile failed: SYNONYM word missing from vocab`, with no
indication which word.

**Root cause:** `emit_dictionary()` in `czil/src/zcode.c` sorts words by
their *encoded* text and drops duplicate encodings, merging their parts of
speech into the survivor. Lookup afterward (`find_word`) matches on raw
text, so the dropped spelling can no longer be resolved. In v8 the
dictionary key is 9 characters, so any two vocabulary words sharing their
first 9 letters collide.

**Collisions found here:** `ADVENTURE` (my JOURNEY-W synonym) vs the
engine's own `ADVENTURER`; `BUTTERCUP` vs `BUTTERCUPS`.

**Fix:** audit every vocabulary word — object SYNONYM/ADJECTIVE, verb
SYNTAX heads, SYNONYM verb aliases, BUZZ words, DIRECTIONS — across *both*
your files and `zil/zork1/g*.zil`, and truncate-to-9 for uniqueness. A
script that does it is in LESSONS.md §1.1. Renamed to `TRIP` and `DAISY`.

**Not a defect worth patching**, but the error message could name the word.

---

## 2. A word cannot be both a verb and a noun/adjective

**Symptom:** `OIL WOODMAN` → *You used the word "oil" in a way that I
don't understand.* (`CANT-USE`, gparser.zil:676.)

**Root cause:** `OIL` was an ADJECTIVE on OIL-CAN *and* a verb (engine
`<SYNONYM LUBRICATE OIL GREASE>`). The parts of speech merge in the
dictionary entry, but the parser's positional matching then can't decide,
and `CANT-USE` fires.

**Fix:** pick one. `OIL` is now verb-only (`<SYNTAX OIL OBJECT ... =
V-OIL>` in ozsyntax.zil); the can is `OILCAN`/`CAN`, adjectives
`BATTERED`/`TIN`/`JEWELED`. Same class of problem is why the design's own
note about `SILVER` (adjective on the shoes only, never a noun) matters.

---

## 3. Compiler reports parse errors without a location

**Symptom:** `compile failed: oz.zil: eval error:` (empty message) `in:
<INSERT-FILE "OZSOUTH" T>`.

**Root cause:** an unterminated `<TELL ...` form — a missing `>` at the
end of a multi-string TELL. The reader consumes to EOF and reports the
INSERT-FILE frame, not the offending line.

**Fix:** a 15-line angle-bracket-depth checker that skips string literals
and escapes, run per file before compiling; it prints the line of every
unclosed form. Script in LESSONS.md §1.2. This paid for itself the first
time and I would build it before writing any ZIL next time.

---

## 4. `<FSET obj ,WORNBIT>` — WORNBIT does not exist

**Symptom:** `SILVER-SHOES-FCN: unknown global WORNBIT`.

**Root cause:** this engine has no worn flag. `WEARBIT` means *wearable*;
"currently worn" is expressed as *carried and WEARBIT*, and `V-INVENTORY`
prints "(being worn)" on that basis alone.

**Fix:** deleted every `<FSET ... ,WORNBIT>`; wear state lives in my own
globals (`SHOES-WORN`, `SPECS-ON`). Fine, and arguably better, because
the shoes/spectacles/cap all have wear semantics the engine's model
doesn't capture (locked on, un-removable).

---

## 5. `V-TAKE` never calls `SCORE-OBJ`: object VALUE is dead

**Confirmed here.** `SCORE-OBJ` exists (gverbs.zil:1867) and does the
right thing, but nothing in the shipped verb set calls it. `(VALUE n)` on
an object awards nothing.

**Fix:** all 30 scoring events are explicit `<SCORE-IT n>` calls guarded
by a per-deed `SC-*` global, so each fires once and only once:

```zil
<ROUTINE SCORE-IT (N) <SETG SCORE <+ ,SCORE .N>> <RTRUE>>
<COND (<NOT ,SC-MELT> <SETG SC-MELT T> <SCORE-IT 26>)>
```

`PROPDEF VALUE 0` / `TVALUE 0` are still declared (the engine's globals
reference the property numbers) but no object carries a nonzero value.

---

## 6. Implicit take bypasses object ACTION routines

**Confirmed here** (gparser.zil:1270-1275): when a syntax carries the
`TAKE` search bit and the object is not held, the parser calls `<ITAKE <>>`
directly. `ITAKE` moves the object; the object's ACTION routine never
runs, so a gate implemented in that routine is silently defeated.

**How it bit this game:** the syntax `THROW OBJECT (HELD CARRIED HAVE) AT
OBJECT` refused *THROW WATER AT WITCH* with "You don't have the well
water" — the crown puzzle of the game lost to a parser technicality,
before any of my code ran.

**Fix:** do not rely on the engine's forms for anything load-bearing.
Declared my own syntaxes with permissive search bits and my own action:

```zil
<SYNTAX THROW OBJECT (ON-GROUND IN-ROOM HELD CARRIED)
	AT OBJECT (ON-GROUND IN-ROOM) = V-SPLASH>
```

Five phrasings now melt her (THROW/POUR/SPLASH/EMPTY, water or bucket,
held or not), all verified.

---

## 7. `<ENABLE <QUEUE rtn -1>>` runs forever

**Symptom:** the river-drift scene replayed its final paragraph on every
subsequent turn, in every room, permanently.

**Root cause:** `-1` means "every turn until disabled". `CLOCKER` never
removes it. There is a `DISABLE` macro (gmacros.zil:143) and an `INT`
routine to get the handle, but nothing hints that you need them.

**Fix:** every terminating `-1` demon ends with
`<DISABLE <INT I-WHATEVER>>` as its first act in the terminal branch.
Eight demons in this game; six needed it (I-DRIFT, I-KALIDAH, I-POPPY,
I-WC2, I-WAVE, I-DITHER, I-LOST). The party demon `I-OZ` runs forever by
design.

---

## 8. `QUEUE rtn N` is unreliable for "fire on arrival at room X"

**Symptom:** the beetle scene (P6) never fired. Queued for 2 ticks at the
moment of the Lion's recruitment, it was supposed to land as the party
walked west; it did not, reproducibly.

**Root cause:** not fully diagnosed. The tick countdown interacts with
which region of `C-TABLE` the interrupt lands in (`C-DEMONS` vs `C-INTS`,
gclock.zil:44) and with `P-WON`. Rather than fight it, I moved the trigger.

**Fix (and the general rule):** for anything that must happen *at a
place*, use the room's `M-ENTER`, not a queued tick:

```zil
<ROUTINE GORGE-FCN (RARG)
	 <COND (<AND <==? .RARG ,M-ENTER> <==? ,BEETLE-STATE 0>
		     <==? ,WOOD-STATE 1> <==? ,LION-STATE 1>>
		<MOVE ,WOODMAN ,HERE>   ;"see below"
		<I-BEETLE>
		<RFALSE>)
```

Deterministic, and it reads better in the source too. Queues are for
*"in N turns wherever you are"* (drowsiness, dithering hints), which is
what they are good at.

---

## 9. Room `M-ENTER` runs before the follow demon moves companions

**Symptom:** the beetle scene tested `<HAS-WOOD?>` (which requires
`<IN? ,WOODMAN ,HERE>`) at `M-ENTER` and always failed.

**Root cause:** ordering. `GOTO` fires the room's `M-ENTER` immediately on
arrival; the per-turn clock (which is where a follower demon moves the
party) runs afterward. At `M-ENTER` the companions are still in the room
you just left.

**Fix:** an `M-ENTER` scene that needs a companion present must place him
itself: `<MOVE ,WOODMAN ,HERE>` before testing, or test the state global
(`<==? ,WOOD-STATE 1>`) rather than the location. This game does both.

---

## 10. Objects that appear mid-game need a home before they exist

**Symptom:** `BUILD RAFT`, `CLIMB LADDER`, `SCATTER STRAW`, `THROW WATER`,
`WEAR SPECTACLES` all failed with "You can't see any X here!" — the verb
could never be typed because the noun was not in scope until after the
thing existed, which required the verb.

**Root cause:** objects with no `(IN ...)` are nowhere and unreferenceable.

**Fix:** put them `(IN LOCAL-GLOBALS)` and list them in the `(GLOBAL ...)`
property of the rooms where the player may name them. They are then in
scope permanently, and their ACTION routine handles the
"doesn't-exist-yet" case in fiction:

```zil
<OBJECT RAFT (IN LOCAL-GLOBALS) (SYNONYM RAFT LOGS) ...>
<ROOM RIVERBANK ... (GLOBAL RIVER-LG TREES-LG YELLOW-ROAD-LG RAFT) ...>

<ROUTINE RAFT-FCN ()
	 <COND (<NOT ,RAFT-BUILT>
		<COND (<VERB? BUILD CHOP MAKE> <DO-BUILD>)
		      (T <TELL "There is no raft yet, only good straight
trees and somebody with an axe." CR> <RTRUE>)>)
	       ...>>
```

A related trap: an object inside a container with no `CONTBIT`/`OPENBIT`
is also out of scope. The spectacles started `(IN GREEN-BOX)` and could
not be worn; moved to `(IN GATE-ROOM)` with the box as pure scenery.

---

## 11. `PRE-BOARD` blocks VEHBIT objects that aren't real vehicles

**Symptom:** `BOARD RAFT` → *"The log raft must be on the ground to be
boarded."* / *"You have a theory on how to board a log raft, perhaps?"*

**Root cause:** `PRE-BOARD` runs before the object's ACTION and enforces
the engine's vehicle model (the object must be in the room, the player
must not already be in a vehicle, etc.). A LOCAL-GLOBALS raft is never "on
the ground".

**Fix:** dropped `VEHBIT` from the raft and the balloon; both are scene
machines, not vehicles. Boarding is a global flag (`ON-RAFT`) and the
scripted drift moves the player between rooms directly. Same for the
balloon, which the player never actually rides.

**Design adaptation (noted):** DESIGN.md §4 marks the raft `VEHBIT`. It
does not need to be one; nothing in the river sequence uses vehicle
semantics.

---

## 12. `V-TELL` runs the actor's ACTION routine twice-over

**Symptom:** `WOODMAN, CHOP TREES` printed the Woodman's idle
conversation line *and then* chopped.

**Root cause:** `V-TELL` (gverbs.zil:1389) is reached with `PRSA = TELL`
and `PRSO = <the actor>` for the addressing half of the command. Because
PERFORM dispatches `<GETP ,WINNER ,P?ACTION>` first, and WINNER is still
the *player* on that pass, the actor's routine runs as PRSO's action with
`VERB? TELL` — matching any "talk to me" clause you wrote. Only *after*
V-TELL sets `WINNER` does the parser re-parse the continuation.

**Fix:** guard every companion conversation clause on `,P-CONT` (which is
non-false exactly when there is a continuation to re-parse):

```zil
<ROUTINE TALKING? () <AND <VERB? TELL HELLO> <NOT ,P-CONT>>>
...
(<AND <TALKING?> <IN? ,WOODMAN ,HERE>> ...the idle line...)
```

This is the single most important thing to know about actor-addressed
commands on this engine. Full write-up in LESSONS.md §2.2.

---

## 13. `NOT-HERE-OBJECT` short-circuits before your WINNER action

Not a problem I had to work around in the end, but worth recording:
`PERFORM` (gmain.zil:205) tests
`<EQUAL? ,NOT-HERE-OBJECT ,PRSO ,PRSI>` and calls `NOT-HERE-OBJECT-F`
*before* dispatching to the WINNER's action routine. So if an addressed
command names something out of scope, you cannot intercept it — the actor
says "I don't see any X here!" and that is that. The remedy is to make
sure the noun *is* in scope (issue 10), not to try to catch it.

---

## 14. Design/table arithmetic

`DESIGN.md` §7 sets `SCORE-MAX 250` but its own deed table sums to **269**.
Reconciled by trimming four awards, keeping every deed and every rank
boundary intact:

| Deed | Design | Shipped |
|---|---|---|
| Kalidah bridge (clean) | 15 | 10 |
| The screen & the humbug | 15 | 10 |
| Golden Cap found & charm read | 10 | 5 |
| The Witch melted | 30 | 26 |

Total: exactly 250, achieved by `walkthrough.txt` and asserted by
`verify.mjs`.

---

## 15. Other small design adaptations

- **`SAY <free text>` in the Wizard's interrogation.** DESIGN.md §9 steps
  50-52 use sentences (`SAY FROM THE WITCH OF THE EAST`). The parser
  cannot take arbitrary text after SAY. The scene now accepts *anything*
  conversational — `ANSWER`, `SAY <any known noun>`, `TELL OZ ...`,
  `HELLO` — and supplies Dorothy's honest reply itself, which is closer to
  the design's intent ("any honest-sounding answers advance") and much
  kinder to an LLM player. The walkthrough uses bare `ANSWER`.
- **`TAKE ME HOME` at the finale.** No parseable form; ME is a pseudo
  object and there is no preposition. The finale accepts `SAY KANSAS`,
  `KANSAS`, `HOME`, and `SAY HOME`, and *prints* the book line ("Take me
  home to Aunt Em!") as Dorothy's speech. Walkthrough uses `SAY KANSAS`.
- **`CLEAN POTS`** — CLEAN is an engine synonym of BRUSH and collides
  positionally; `SCRUB POTS`, `SWEEP`, `MOP` all work. Walkthrough uses
  `SCRUB POTS`.
- **The Guardian's green box** is scenery; the spectacles sit in the room
  (issue 10).
- **Toto's inventory line.** Carrying Toto renders as "A Toto" in
  `V-INVENTORY` (the engine has no article model). Toto is therefore
  returned to the room by the follow demon each turn unless a scene holds
  him, which also matches the fiction better.

---

## 16. The clock only advances on a successful parse

**Not a defect — a constraint with real design consequences.** `CLOCKER`
runs from `MAIN-LOOP` only after `PARSER` returns a win. Input the
dictionary rejects (`x bed`, `sing`, a misspelling) prints its error and
costs the player *no game time*: no demon fires, no timer advances,
`MOVES` does not increment.

**Measured here:** 15 consecutive unparsed commands produced **one** storm
beat.

**Why it matters:** an LLM-driven player generates a lot of unparsed
input, so any timer tuned against "turns the player types" runs several
times slower than intended in practice. This is the mechanism behind the
stranded-prologue bug (§17) — the storm counters were not actually wrong,
they were being starved.

**Fix:** tune every timer against a real junk transcript, not against a
clean walkthrough. `walkthrough-wanderer.txt` exists partly to keep this
honest.

---

## 17. Scripted openings strand non-ideal players

**Symptom:** 50 turns of chaotic natural-language input through the LLM
layer — three runs, two models, three context sizes — never reached Oz.
The player sat in the Kansas farmhouse examining furniture.

**Root cause:** every link of the prologue chain was reachable only by the
player typing the intended command. `START-CYCLONE` only from
`DO-GRAB-TOTO`/`CELLAR-EXIT`; `LAND-HOUSE` only from `V-SLEEP`; and (found
only after fixing those two) leaving the landed house only from `OUT`.

**Fix:** the prologue now advances on its own clock, driven from the
permanent `I-OZ` demon and gated on `STORM-PHASE`, with escalating
in-voice nudges before each automatic step. The scored deed is unchanged —
closing the trap door yourself is still the only way to earn its 5 points,
and a player doing it properly sees no nudges at all. Full pattern in
LESSONS.md §3.7.

**Regression guard:** `walkthrough-wanderer.txt` (no useful command in it)
plus assertions in `verify.mjs` that it reaches Munchkin Clearing, scores
**0**, does not die, and that no nudge string leaks into the scored
transcript. Proven to fail by reverting the fix before restoring it.

---

## 18. Self-requeueing QUEUE works; a guard clause above it does not

**Reported symptom:** `<ENABLE <QUEUE I-FLIGHT n>>` called from inside
`I-FLIGHT` appeared not to re-fire.

**Actual cause:** the mechanism is fine. `CLOCKER` decrements the slot's
tick to 0 and *then* calls the routine, so the routine's `PUT` of a fresh
tick survives the sweep. Verified with a purpose-built four-beat probe
game: all four beats fired.

What swallows later beats is a once-only guard sitting **above** the beat
logic in the same `COND`:

```zil
(,FLIGHT-BEAT <RFALSE>)   ;"after beat 1 this always wins; everything
                            below it is unreachable"
```

Reproduced in the probe — same routine, one guard added, **1 beat instead
of 4.**

**Fix / preference:** when a queued beat "doesn't fire", check `COND`
ordering before suspecting the clock. Prefer one monotonic counter
compared with `==?`/`G?` over boolean guards; a counter cannot develop an
unreachable branch. The rewritten prologue uses no guard flags at all.

---

## 19. Trap door state contradicted its own room description

**Symptom:** the farmhouse description says the trap door stands "open in
the middle of the floor", but `CLOSE TRAP DOOR` answered "It is already
closed."

**Root cause:** the object was declared `(FLAGS NDESCBIT DOORBIT)` with no
`OPENBIT`, while the prose (and the story — Aunt Em threw it open and went
down the ladder) says otherwise.

**Fix:** added `OPENBIT` to the declaration. Also made the cyclone
re-opening it explicit ("The trap door bangs open again under the pull of
the wind") instead of silently `FSET`-ing it, so a player who shuts it
pre-emptively is told what happened rather than finding it mysteriously
open two turns later.
