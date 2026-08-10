# Build issues: engine and compiler constraints, and how the design was adapted

Everything here is a constraint of the shared toolchain (`zil/zork1`,
`zil/engine-v8`, `czil`) that this game had to work around from inside
`adventures/monte-cristo/`. Nothing outside this directory was modified.
Where a constraint forced a change to DESIGN.md's spec, the adaptation is
stated.

---

## 1. A v8 dictionary word cannot be both a noun and an adjective

**The big one.** In a v8 story file, `WT?` in `zil/engine-v8/v8patch.zil`
reads a word's value from a byte whose offset depends on which parts of
speech the word carries. For a word that is only a noun, the object value
sits at offset 7. For a word that is *both* an adjective and a noun,
czil packs the entry so that `<WT? word ,PS?OBJECT ,P1?OBJECT>` reads
offset 8 and gets zero, i.e. false. The parser therefore refuses the word
as a noun and answers "You can't see any X here!" even when exactly one
matching object is in scope and `EXAMINE <adj> X` works fine.

Dumped from the built story file, the difference is visible directly:

```
block   ps=0xc0  v1=1  v2=217     <- noun only: works
stone   ps=0xa2  v1=1  v2=0       <- adjective + noun: unusable as a noun
```

**Symptom:** a noun that is declared on an object and present in the
dictionary is never found. `EXAMINE STONE` fails; `EXAMINE LOOSE STONE`
succeeds.

**Fix:** never let one word appear in both a `SYNONYM` and an `ADJECTIVE`
anywhere in the game *including the engine's own files*. Audited with:

```sh
{ grep -ohE "\(SYNONYM [A-Z0-9 -]+\)" zil/zork1/gglobals.zil *.zil \
    | sed 's/(SYNONYM //; s/)//' | tr ' ' '\n' | sed 's/^/N /'
  grep -ohE "\(ADJECTIVE [A-Z0-9 -]+\)" zil/zork1/gglobals.zil *.zil \
    | sed 's/(ADJECTIVE //; s/)//' | tr ' ' '\n' | sed 's/^/A /'
} | awk 'NF==2' | sort -u \
  | awk '{s[$2]=s[$2] $1} END {for (w in s) if (s[w]~/A/ && s[w]~/N/) print w}'
```

That found sixteen collisions in this game: COIN, CORNER, CREDIT, OAK,
OLIVE, POWDER, ROPE, SAILOR, SAILORS, SEA, SIGNAL, SPADA, STONE, WATER,
WEDDING, WEDGE. All were fixed by renaming the adjective.

**One is unfixable from here:** `STONE` is an `ADJECTIVE` on the engine's
`STAIRS` object in `zil/zork1/gglobals.zil`, which is off limits. So
`STONE` can never work as a noun in any game built on these files.

> **Design adaptation.** DESIGN.md §9 step 38 is `PRY STONE WITH HANDLE`.
> The walkthrough says **`PRY BLOCK WITH HANDLE`**, and the hewn stone
> carries `BLOCK` as its first synonym and `HEWN`/`DRESSED` as adjectives.
> The failure text for the shard now says "the hewn block" so the word
> the player needs is the word the game prints.

Note this also silently affects the design's 6-character truncation audit
(§11): v8 keeps nine characters, so the truncation collisions the design
worried about are gone, and this entirely different collision class
replaces them.

## 2. IN and OUT are unusable as directions in v8

Same root cause. `IN` and `OUT` are declared in `<DIRECTIONS>` *and* are
prepositions (`<SYNONYM IN INSIDE INTO>` in gsyntax), so their direction
values cannot be read back and `(IN PER STREET-IN)` exits are dead:

```
in   ps=0x18  v1=251  v2=53   <- direction + preposition
land ps=0x13  v1=51   v2=0    <- direction only: works
```

**Fix:** two new direction words that are nothing else, declared in this
game's `<DIRECTIONS>` and given as an alias on every IN/OUT exit:

```zil
<DIRECTIONS NORTH EAST WEST SOUTH NE NW SE SW UP DOWN IN OUT LAND
	    ENTRANCE EXIT>
<SYNONYM ENTRANCE INWARD>
<SYNONYM EXIT OUTWARD>
```

> **Design adaptation.** The walkthrough uses `ENTRANCE` and `EXIT` where
> the design says `IN` and `OUT` (the Auteuil coach, the Pont du Gard
> inn). `IN`/`OUT` remain declared so nothing regresses in a v3 build and
> so the LLM layer still has something to aim at.

## 3. SWIM cannot take a direction

`GPARSER` only accepts a bare direction word when the sentence's verb is
`WALK`, compared by action value (`ACT?WALK`). A late `<SYNONYM WALK
SWIM>` does not retarget the existing `SWIM` verb, so `SWIM WEST` always
fails with "You used the word west in a way that I don't understand."

> **Design adaptation.** DESIGN.md §9 steps 78-80 are `SWIM WEST` ×3. The
> walkthrough uses bare `WEST` ×3; the open-sea room narrates the swimming
> ("You strike out west with the mistral behind you"), and bare `SWIM`
> re-reads Faria's heading aloud as a hint.

## 4. Preactions run per action, not per syntax line

`PERFORM` looks up `<GET ,PREACTIONS .A>` by action number, so adding a
new `<SYNTAX ...>` line for an existing action does **not** escape that
action's stock preaction. Four stock preactions had to be redefined in
`cactions.zil` (czil takes the last definition, so `zil/zork1` is
untouched):

| Preaction | What it broke | Why it had to go |
|---|---|---|
| `PRE-MUNG` | `BREAK JUG` | refuses every BREAK with no `WITH` clause before the object sees it; breaking the water jug bare-handed is puzzle II-2's first move |
| `PRE-BURN` | `BURN FUSE` | refuses every BURN with no FLAMEBIT source; the flint is in the powder horn's cap and the game says so |
| `PRE-TAKE` | `REMOVE WIG` | REMOVE is a TAKE synonym, so removing a worn thing answers "You are already wearing it" before the wig's own action can run the game's second great reveal |
| `PRE-DROP` | n/a | left alone; the DROP *syntax* was widened instead (below) |

## 5. Object-scope flags on syntax lines

- `DROP OBJECT (HELD MANY HAVE)` cannot reach scenery, so `DROP ANCHOR`
  failed. Widening to `(HELD CARRIED ON-GROUND IN-ROOM MANY)` works, but
  **`HAVE` must be dropped**: `TAKE-CHECK` in gparser prints "You don't
  have the anchor" for any non-held object on a syntax carrying `SHAVE`.
- `CUT OBJECT WITH OBJECT (FIND WEAPONBIT)` only ever slices `BURNBIT`
  things. Widened to `(FIND TOOLBIT)` with the objects handling the rest.
- `ATTACK` refuses to swing at anything without `ACTORBIT`. A game-side
  `ATTACK OBJECT WITH OBJECT (FIND TOOLBIT)` lets `HIT WALL WITH PICKAXE`
  reach the grotto wall.
- `DIG` has no bare `DIG OBJECT` form; added one.
- `ENTER OBJECT` is `V-THROUGH`, which head-butts anything that is not a
  door or a vehicle ("You hit your head against the burial sack"). A new
  `V-GETIN` action lets `ENTER SACK` / `ENTER OVERHANG` reach the object.

## 6. `BY` is not a preposition

`PUT PLATE BY DOOR` (DESIGN.md §9 step 35) gets "I don't know the word
by". Added `<SYNONYM BY NEAR BESIDE AGAINST>` and a `PUT OBJECT BY
OBJECT = V-PUT-BY` syntax.

## 7. v3-shaped calls take at most three arguments

`<JIGS-UP "para one" CR CR "para two">` fails to compile with
`v3 calls take at most 3 arguments`. Every multi-paragraph death here
`TELL`s its own obituary and calls `<JIGS-UP "">`; the local `JIGS-UP`
suppresses the empty string.

## 8. `VERB?` names actions, not verbs

`<VERB? PULL>` fails with `unknown global V?PULL` because PULL's action
is `V-MOVE`. The valid names are the action-routine suffixes, not the
words in `<SYNTAX>`. Hit on PULL (→MOVE), POUR (→DROP / POUR-ON), KILL
(→ATTACK), CLIMB-IN (→BOARD), REPLY (→ANSWER).

Also: `SET` is already a `TURN` synonym and `LIFT` a `RAISE` synonym, so
DESIGN.md §11's proposed `SET SIGNAL` verb would shadow `TURN`. The
telegraph verb is `SEND` (with `TRANSMIT`/`DISPATCH`); `TURN LEVERS` and
`PULL LEVERS` also work through the object's action.

## 9. There is no worn state, and no DISROBE

`V-WEAR` is `<PERFORM ,V?TAKE ,PRSO>` and nothing more; `WEARBIT` only
changes the message. The whole disguise system is therefore a game-side
`IDENTITY` global set by the costume objects' own `WEAR` handlers, with
`REMOVE` arriving as a `TAKE` of a held thing (see §4, `PRE-TAKE`).

## 10. Room descriptions are suppressed on revisit

`DESCRIBE-ROOM` only calls `M-LOOK` when the room is untouched or VERBOSE
is on, so the 1829 versions of the Marseilles rooms and the Act V versions
of the cells never printed. Fixed by `<FCLEAR ,ROOM ,TOUCHBIT>` at each
act transition for the rooms whose description has changed.

## 11. Inventory limit

`LOAD-ALLOWED` cut the player off in Act IV ("You're holding too many
things already!") because the Chateau d'If props were still being carried
nine years later. The act-four transition now removes the prison relics
explicitly. Worth doing for narrative reasons anyway.

---

## Design adaptations, collected

Everything the finished game does differently from DESIGN.md:

1. **`PRY BLOCK WITH HANDLE`**, not `PRY STONE` (§1 above).
2. **`WEST` ×3 in the open sea**, not `SWIM WEST` (§3).
3. **`ENTRANCE` / `EXIT`** for the coach and the inn door, not `IN`/`OUT` (§2).
4. **`SEND SIGNAL`**, not `SET SIGNAL` (§8). `TURN LEVERS` also works.
5. **`HIT WALL WITH PICKAXE`** for the grotto (design already used this);
   **`DIG ANGLE WITH PICKAXE`** rather than `DIG CORNER`, because CORNER
   was one of the sixteen adjective/noun collisions.
6. **`CUT TREE`** rather than `CUT BRANCH` — you cut the tree to get the
   branch, which reads better and avoids referring to an object that does
   not exist yet.
7. **The jailer's discovery death is not reachable after Faria arrives.**
   The design has absence from cell 34 be fatal once the tunnel exists.
   In play that made the whole cell-27 half of Act II a coin-flip, since
   Faria's cell is where the education, the phial and the parchment all
   happen. Implemented instead as: fatal before Faria (the player has no
   craft), a near-miss with the straw dummy afterwards (his first
   practical lesson), and the ten-o'clock clock in `SWAP-TICK` carrying
   the real danger of the sack-swap act. Both deaths are reachable and
   tested (`tests/death-jailer.txt` covers the clock).
8. **The Caderousse deathbed is not room-gated.** The design stages it in
   the salon; the burglary happens in the study, so the dying man is
   carried in wherever the player is and `REMOVE WIG` fires the reveal
   there. Same scene, one less way to lose it.
9. **The Morcerf salon confrontation moves the player.** After the vote,
   the game walks you home and stages Morcerf in the salon, because the
   design left the player standing in the Peers gallery with no way to
   reach the scene. `WEAR JACKET` then works from the salon *or* the study.
10. **Topic pseudo-objects live in `GLOBAL-OBJECTS`, not `LOCAL-GLOBALS`.**
    See LESSONS.md; the design's per-room `GLOBAL` lists do not scale past
    one act, and person-topics collide with the person objects unless the
    retired cast is removed from play at each act boundary.
11. **`ASK CADEROUSSE ABOUT DIAMOND` before giving it** is a hint, not a
    gate. The gate is `CONFIRMED-GUILT`, per the design's flag list.
