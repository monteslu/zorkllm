# Build issues and design adaptations

Everything here was worked around inside this directory. No file in
`czil/`, `zil/`, `src/`, `test/`, `examples/` or `docs/` was modified.

## Toolchain issues found

### 1. A room's `IN` exit is unreachable (czil)

`<ROOM X (IN ROOMS) ... (IN TO Y)>` compiles the parenthood clause and the
exit clause to the **same property number**, emitting property 53 twice in
the object's property table. The Z-machine's `GETPT` returns the first
match, so `V-WALK` reads the `(IN ROOMS)` artifact instead of the exit and
answers *"You can't go there without a vehicle."* A `PER` routine form
(`(IN PER FCN)`) does not help - the duplicate is still emitted first, and
reordering the clauses in the source does not change the emission order.

Tiny Quest has the same duplicate property but is not visibly broken by it:
both of its entries happen to be one-byte UEXITs, so the wrong one still
decodes as a plausible room number.

**Adaptation.** `IN` was removed from `<DIRECTIONS>` entirely and made a
verb instead:

```zil
<SYNTAX IN = V-ENTER>
<SYNTAX INSIDE = V-ENTER>
```

`V-ENTER` is overridden in `tiactions.zil` and dispatches on `HERE` for the
five rooms that need an inward move (the inn from the road, the log-house
over the paling, the galley or cabin from the deck, Ben Gunn's cave, the
goatskin tent). Everywhere else it falls through to `DO-WALK ,P?OUT`.
Player-visible behaviour is identical; `OUT` was left in `<DIRECTIONS>`
because no room needs both an `(OUT TO ...)` exit and the artifact.

### 2. Dictionary dedup drops a word the object table still references

`emit_dictionary` merges words whose 9-z-char encodings match and trims
`nwords`, but object `SYNONYM`/`ADJECTIVE` emission then looks the dropped
spelling up **by text** and fails the whole compile with the unlocated
error `SYNONYM word missing from vocab` - no file, line, or word named.

Here it was `BUCCANEER` (on the boarding pirate) versus `BUCCANEERS` (on the
buccaneers collective): identical for nine z-chars.

**Adaptation.** The collective dropped `BUCCANEERS` and took `CREW`. Worth
knowing for anyone who hits the same message: the culprit is a pair of
synonyms that agree in their first nine z-chars, and `-` and digits cost two
z-chars each.

## Engine behaviours that shaped the implementation

These are not bugs - they are how the Zork I engine works - but each one
changed a design decision.

- **`READ` on a `READBIT` object with no `TEXT` property prints garbage.**
  `V-READ` does `<TELL <GETP ,PRSO ,P?TEXT> CR>` with no guard, so a missing
  property is interpreted as a string address and the interpreter walks off
  into the middle of the story file. Every readable object here handles
  `READ` in its own action routine.

- **`<VERB? X>` names an action, not a verb word.** `<VERB? KILL>` does not
  compile (`unknown global V?KILL`) because `KILL` maps to `V-ATTACK`. The
  same trap applies to `PULL` (`V-MOVE`), `JUMP` (`V-LEAP`), `DESTROY`
  (`V-MUNG`), `ASK` (`V-TELL`) and `LOOK UNDER` (`V-LOOK-UNDER`, reached from
  the verb word `LOOK`).

- **The engine's global objects shadow game objects.** `HANDS` in
  `gglobals.zil` is the player's hands and is in `GLOBAL-OBJECTS`, so it wins
  over Israel Hands; `ISRAEL` is now his first synonym, and `V-SHOOT`
  redirects at the cross-trees regardless of what the parser resolved.
  `GROUND` owns the noun `SAND` and answers `DIG` with *"The ground is too
  hard for digging here"* before any room action can - `DIG` is therefore
  intercepted in the actor routine (`ADVENTURER-FCN`), which `PERFORM` runs
  first.

- **`BOARD` is `(FIND VEHBIT)`-scoped.** The Hispaniola is scenery, not a
  vehicle, so `BOARD SHIP` could not find it; boarding is handled at `M-BEG`
  in the quay, anchorage, and inlet room routines, which run before the
  syntax preaction. Redefining the syntax does not work: czil merges the
  duplicate entry and keeps the original's `PRE-BOARD`.

- **`WAIT` is three clock ticks, not one.** Scripted scenes are therefore
  driven from each room's `M-END` (exactly one call per parsed turn) rather
  than from a clock interrupt, so one typed command is always one story beat.
  The apple barrel is the exception: the player is inside a vehicle there, so
  `<LOC ,WINNER>` is the barrel and the room's `M-END` never fires - that one
  scene runs off the `I-SCENES` clock demon with a first-turn guard.

- **`YES`/`NO` are buzzwords**, so the parole choice cannot be answered with
  `YES`. The design already offered `STAY` (reusing `V-STAY`, which is a
  harmless stub in the generic engine) and `FOLLOW DOCTOR`; both work, and
  `WAIT` holds the prompt open indefinitely.

- **`X` is not an abbreviation for `EXAMINE`** in this engine. Added as
  `<SYNONYM EXAMINE X>` since players type it constantly.

## Design adaptations

- **`SNEAK` shipped as designed** (§11 left the phrasing open). It is a
  bare verb, scoped to the wrecked cabin during the wine errand; the room
  description names the sparred gallery, and `ENTER GALLERY` reaches it too.
- **The raid under the bridge resolves in two waits, not three.** The
  design's beats 2 and 4 were merged so the packet-found / packet-missing
  branch lands in the same paragraph as the ransacking. Pacing only.
- **`ASK <actor> ABOUT <topic>`** needs the topic to be a real object in
  scope, so a `TOPICS` catch-all global carries the nouns players actually
  type (FLINT, MUTINY, ISLAND, TREASURE, PLAN...). The actors ignore the
  topic and answer in character, which is what §5 asked for.
- **The seaman's oddments in the sea-chest are `GEAR`**, not `ODDMENTS` -
  Billy's pocket oddments already own that noun and are in the player's
  inventory by then. `MOVE GEAR` and `SEARCH CHEST` both peel the layer.
- **Combat is deterministic.** Per §11 note 5 the boarding pirate takes
  exactly two hits and never rolls, so the transcript is byte-stable. He
  kills only after three consecutive turns of not fighting, as designed.

## Known rough edges

- `DIG` with no object asks *"What do you want to dig in?"*; `DIG SAND` or
  `DIG SAND WITH SPADE` is the phrasing the game expects and the room text
  points at the sand.
- The parrot's ambience rotates on a fixed 4-turn cycle rather than the
  design's 1-in-4 random, to keep the frozen transcript stable.
- `LAND` is a declared direction and works from the beached deck, but only
  reads naturally there; elsewhere it gives the engine's default refusal.
