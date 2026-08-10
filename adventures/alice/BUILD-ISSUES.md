# BUILD-ISSUES: engine constraints found building WONDERLAND

Defects and hard constraints in the shared Zork engine (`zil/zork1`) and the
czil compiler, found while building `adventures/alice`. Nothing in the shared
tree was patched; every item below is worked around inside the game's own
files. Recorded here because the same traps will hit any other adaptation on
this engine.

Engine files referenced are read-only for game authors: `zil/zork1/gverbs.zil`,
`gparser.zil`, `gsyntax.zil`, `gglobals.zil`.

---

## 1. `V-TAKE` never calls `SCORE-OBJ`, so `(VALUE n)` is dead

**Symptom.** An object with `(VALUE 2)` is picked up with `TAKE JAR`. The score
stays at 0. No error, no warning.

**Root cause.** `gverbs.zil` defines `SCORE-OBJ` (line ~1867), which reads
`P?VALUE`, adds it, and zeroes the property so it only scores once. But the
plain take path — `V-TAKE` → `ITAKE` → `MOVE` — never calls it. The only
callers are the container path in `V-PUT` (line ~1113), a `FILCH` spell branch,
and `GOTO`'s room-value logic. In Zork I the treasures score on being *put in
the trophy case*, not on being taken, so nothing in the stock game exercised
a take-scores-points path.

**Fix.** Do not rely on `(VALUE n)`. Award explicitly in the object's own
`ACTION` routine, guarded by a one-shot global:

```
<ROUTINE MARMALADE-JAR-FCN ()
	 <COND (<AND <VERB? TAKE> <NOT <IN? ,MARMALADE-JAR ,WINNER>>>
		<MOVE ,MARMALADE-JAR ,WINNER>
		<COND (<NOT ,F-JAR>
		       <SETG F-JAR T>
		       <SCORE-UPD 2>)>
		<TELL "You take the jar as it drifts past..." CR>
		<RTRUE>)>>
```

Note the routine must do the `MOVE` itself and `<RTRUE>`, because returning
false would let the default take run and print a second "Taken."

**Detection.** Any `(VALUE n)` in your dungeon file that you have not paired
with an explicit `SCORE-UPD` is dead weight. Grep for it.

---

## 2. `ITAKE-CHECK` bypasses object `ACTION` routines

**Symptom, mild.** `EAT KEY` prints `(Taken)` before your bespoke refusal.

**Symptom, severe.** A size gate, ownership check, or any other guard written
as `<COND (<AND <VERB? TAKE> ...> <TELL "you can't"> <RTRUE>)>` is silently
defeated when the object is used as an indirect object. In WONDERLAND this
let `UNLOCK DOOR WITH KEY` pick up a key the player was far too small to lift,
which defeated the whole Act 1 puzzle and let the player finish the game 100
moves early.

**Root cause.** `gparser.zil` `ITAKE-CHECK` (line ~1248) implements the
implicit take for syntax slots flagged `STAKE`/`SHAVE`. It calls
`<ITAKE <>>` **directly** — not `<PERFORM ,V?TAKE ...>` — so the object's
`ACTION` routine is never consulted. `ITAKE` checks only `TAKEBIT`, container
openness, and weight.

**Fix.** Never put a take-guard only on the object. Guard at the point of use
as well — in the verb that consumes it, or in the room's `M-BEG`:

```
<ROUTINE LITTLE-DOOR-FCN ()
	 <COND (<VERB? UNLOCK>
		<COND (<AND <SMALL?> <EQUAL? ,PRSI ,GOLDEN-KEY>>
		       ;"the parser may have force-taken it; put it back"
		       <COND (<IN? ,GOLDEN-KEY ,WINNER>
			      <MOVE ,GOLDEN-KEY ,GLASS-TABLE>)>
		       <TELL "The key is nearly as long as you are..." CR>)
		      ...
```

The defensive `MOVE` back is the important part: assume the parser already
took it.

---

## 3. `IN` as a movement direction collides with `(IN ROOMS)`

**Symptom.** `IN` at a room with `(IN PER SOME-ROUTINE)` prints
"You can't go there without a vehicle." The `PER` routine never runs.

**Root cause.** `<DIRECTIONS ... IN OUT LAND>` makes `IN` a direction
property. But every room also declares its parent as `(IN ROOMS)`. Both are
the property named `IN`; the first one wins, so the movement exit is silently
replaced by a pointer to the `ROOMS` object, which has no `RLANDBIT`, so
`GOTO` rejects it with the vehicle message.

`OUT` has no such problem — nothing declares `(OUT ...)` as a parent — so
`OUT PER` exits work normally. tinyquest never used an `IN` exit, so this was
not covered by the example.

**Fix.** Delete the `(IN PER ...)` exit and intercept the walk at the room's
`M-BEG`:

```
<ROUTINE RABBIT-LAWN-FCN (RARG)
	 <COND (<AND <EQUAL? .RARG ,M-BEG>
		     <VERB? WALK>
		     <EQUAL? ,PRSO ,P?IN>>
		<COND (<RABBIT-HOUSE-IN> <GOTO ,RABBIT-ROOM>)>
		<RTRUE>)
	       ...
```

`ENTER` (bare) routes to `V-ENTER` → `DO-WALK ,P?IN`, so it lands in the same
handler and both verbs work.

---

## 4. A word used as both SYNONYM and ADJECTIVE stops resolving as a noun

**Symptom.** `EXAMINE MOUSE` → "You can't see any mouse here!" while the room
description plainly lists a Mouse, and the object is definitely in the room.
Baffling, because the object, the room, and the flags are all correct.

**Root cause.** `MOUSE` was a `(SYNONYM MOUSE)` on the Mouse and also an
`(ADJECTIVE ... MOUSE)` on the mouse-hole. The dictionary entry then carries
both part-of-speech bits (observed flag byte `10100010` versus a clean noun's
`10000000`), and the parser prefers the adjective reading, then fails to find
a noun to attach it to.

**Fix.** Keep every vocabulary word in exactly one part of speech. Audit with:

```python
import re
s = open('adungeon.zil').read()
syn = set(); adj = set()
for m in re.finditer(r'\(SYNONYM ([^)]*)\)', s): syn.update(m.group(1).split())
for m in re.finditer(r'\(ADJECTIVE ([^)]*)\)', s): adj.update(m.group(1).split())
print(sorted(syn & adj))     # must be empty
```

WONDERLAND had 13 collisions (`CAT`, `RABBIT`, `PEBBLE`, `GLASS`, `MARMALADE`,
`GARDEN`, `JURY`, `FROG`, `DAISY`, `COMFIT`, `PAPER`, `SWEET`, `MOUSE`). Run
this check before debugging any "can't see any X" that makes no sense.

---

## 5. `<VERB? X>` only accepts *action* names, not surface verbs

**Symptom.** Compile error: `unknown global V?PULL`.

**Root cause.** The compiler emits one `V?name` constant per distinct action
routine (`zcode.c` `action_name_for`), derived from the `= V-SOMETHING` on the
syntax line. `PULL` exists as a verb but maps to `= V-MOVE`, so the constant is
`V?MOVE`; `V?PULL` never exists. Same for `CURSE` (→ `V?CURSES`) and `HIT`
(a `SYNONYM` of `ATTACK`, → `V?ATTACK`).

**Fix.** Check the right-hand side of the syntax line in `gsyntax.zil`, not the
word you type as a player. Audit with:

```bash
grep -ohE '<VERB\? [^>]+>' *.zil | sed 's/<VERB? //;s/>//' | tr ' ' '\n' \
  | grep -E '^[A-Z]' | sort -u > /tmp/used.txt
grep -oE '= V-[A-Z-]+' ../../zil/zork1/gsyntax.zil | sed 's/= V-//' | sort -u > /tmp/valid.txt
comm -23 /tmp/used.txt /tmp/valid.txt      # must be empty
```

---

## 6. `FUMBLE-NUMBER` puts RANDOM on the critical path

**Symptom.** `TAKE BRUSH` intermittently fails with "You're holding too many
things already!" — and a walkthrough that passed yesterday fails today.

**Root cause.** `gverbs.zil` line ~1942: if the player carries more than
`FUMBLE-NUMBER` (7) items, every `TAKE` rolls `<PROB <* .CNT ,FUMBLE-PROB>>`.
It is a probabilistic drop, not a hard capacity limit, and the message does not
say so. Any game whose walkthrough accumulates more than 7 objects will fail
nondeterministically.

**Fix.** Disable it in `GO` (these are plain globals, writable from your file):

```
<SETG FUMBLE-NUMBER 100>
<SETG FUMBLE-PROB 0>
```

Raise `LOAD-MAX` / `LOAD-ALLOWED` from 100 at the same time if your game hands
out many objects; with the default `<PROPDEF SIZE 5>` the real weight ceiling
is only 20 objects.

---

## 7. `PRE-FILL` and `PRE-PUT` demand a held object

**Symptom.** `FILL JAR WITH TREACLE` → "That's easy for you to say since you
don't even have the treacle." `PUT BILL IN BOX` → "You don't have the Bill the
Lizard."

**Root cause.** `PRE-FILL` rewrites `FILL x WITH y` into `PUT y IN x` unless
`y` is `WATER`/`GLOBAL-WATER`. `PRE-PUT` delegates to `PRE-GIVE`, which
requires the direct object be in the player's hands. Scenery you intend to
scoop (treacle on a wall) or an NPC you intend to pick up (a lizard on the
floor) can never satisfy that.

**Fix.** Intercept at the room's `M-BEG`, which runs before the pre-action:

```
<ROUTINE TREACLE-WELL-FCN (RARG)
	 <COND (<AND <EQUAL? .RARG ,M-BEG> <VERB? FILL PUT>>
		<FILL-THE-JAR>
		<RTRUE>)
	       ...
```

For the lizard, a bespoke verb (`<SYNTAX RIGHT OBJECT = V-RIGHT>`) sidesteps
the pre-action chain entirely and reads better than `PUT`.

---

## 8. Contents of a held container are not reachable by name

**Symptom.** The player holds a jar containing treacle. `GIVE TREACLE TO
HATTER` → "You don't have that!"

**Root cause.** `PRE-GIVE`'s held-check tests the object itself, not its
transitive container.

**Fix.** Accept the container as a synonym for its contents in the receiving
NPC's action routine, and say so in the walkthrough:

```
<COND (<AND <VERB? GIVE SHOW PUT>
	    <EQUAL? ,PRSO ,MARMALADE-JAR ,TREACLE-GOO>>
       <FIX-THE-WATCH>
       <RTRUE>)
```

---

## 9. `SAY <sentence>` is not a supported syntax, and "I" is not a word

**Symptom.** `SAY I AM NOT A MILE HIGH` → `You used the word "i" in a way that
I don't understand.`

**Root cause.** The engine has `SAY OBJECT` (a single noun) and quoted-say
handling at `M-BEG` via `P-LEXV`. There is no multi-word say. The pronoun `I`
is not in the dictionary at all.

**Fix.** Give each spoken beat a one-word global object (`W-NONSENSE`,
`W-ALICE`, `W-MILE`, `W-NOTHING`) and dispatch in a `V-SAY-WORD` routine, plus
a bare-word `M-BEG` intercept reading `<GET ,P-LEXV ,P-CONT>` for players who
type the word alone. Document the accepted phrasing in the walkthrough; an LLM
front-end can map natural phrasings onto it, but the raw parser cannot.

---

## 10. Room `M-END` writes are not visible to exits until the next turn

**Symptom (not a bug — a trap).** `RABBIT-SEEN` is set in `RIVERBANK-FCN` at
`M-END`. A player who types `NORTH` on turn 1 is refused, because the flag is
set *after* that turn's movement is resolved.

**Guidance.** This is correct engine behaviour and should not be "fixed", but
it does mean any state your room sets at `M-END` is one turn behind. Either
have the walkthrough absorb the turn (a leading `WAIT`) or set the flag at
`M-ENTER` instead. Make sure the refusal text nudges rather than confuses;
ours is "There is nothing worth getting up for. Yet."

---

## 11. A custom take must clear `NDESCBIT` itself

**Symptom.** An object is taken, prints your message, scores its points — and
does not appear in `INVENTORY`. The player is holding something the game will
not admit they have.

**Root cause.** The engine's take path (`ITAKE`) does housekeeping beyond the
`MOVE`: it clears `NDESCBIT` and sets `TOUCHBIT`. A handler that does its own
`<MOVE obj ,WINNER>` — which you must do whenever you want custom text or
scoring (item 1) — skips all of it. Scenery-style objects declared with
`NDESCBIT` so they do not clutter a room description stay invisible forever.

**Fix.**

```
<MOVE ,THING ,WINNER>
<FCLEAR ,THING ,NDESCBIT>
<FSET ,THING ,TOUCHBIT>
```

**Detection.** Cross-reference every `<MOVE x ,WINNER>` in your action
routines against objects declared with `NDESCBIT`:

```bash
grep -n "MOVE ,[A-Z-]* ,WINNER>" *.zil          # custom takes
grep -B8 "NDESCBIT" adungeon.zil | grep OBJECT  # invisible objects
```

Four objects in WONDERLAND had this and none was caught by a 100/100
walkthrough, because the walkthrough never typed `INVENTORY` after taking
them. Put `INVENTORY` in your wanderer test.

---

## 12. Filler words: `BUZZ` is the cheapest forgiveness you can buy

**Symptom.** `grab that jar` → `I don't know the word "that".` The command was
perfectly clear; one function word killed it.

**Why it matters more than it looks.** The Z-machine clock advances only on a
successful parse (`CLOCKER` runs from `MAIN-LOOP` under `,P-WON`), so a
rejected parse ticks nothing — no `M-BEG`, no `M-END`, no timer. Natural
language fails to parse roughly two thirds of the time, so every timed beat
runs at about a third of the rate your transcript suggests, and any window
that can close while the player types the wrong word eventually will.

**Fix.** `BUZZ` makes the parser ignore a word rather than reject the command:

```
<BUZZ THAT THIS THESE THOSE MY YOUR SOME PLEASE JUST NOW OVER THERE
      REALLY VERY QUITE RATHER ABOUT AROUND AT WELL OK OKAY LETS LET
      I I'LL ILL IM I'M WANT TRY GUESS THINK MAYBE PERHAPS
      WOW WHOA HEY UM UH SO ANYWAY AGAIN>
```

One declaration cut WONDERLAND's LLM-wanderer rejection rate from 37 to 28 of
49 inputs. Check the engine's existing `<BUZZ>` list in `gsyntax.zil` first so
you do not redeclare (`A AN THE IS AND OF THEN ALL ONE BUT EXCEPT` are taken).

---

## Compiler notes (czil)

- Object `ACTION` properties are resolved at compile time: referencing a
  routine that does not exist yet fails with `non-constant value for property
  ACTION on FOO`. Stub every action routine before first compile.
- The v8 dictionary resolves 9 characters, so the 6-character collisions the
  design worried about (`GARDENER`/`GARDEN`) are not an issue. Part-of-speech
  collisions (item 4) are, and they are not length-related.
- Final size: 114 KB for 26 rooms, 121 objects, ~3,700 lines of ZIL, all ten
  poems, and both endings. The v3 128 KB ceiling would have been tight; v8 has
  ample room.
