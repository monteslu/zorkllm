# BUILD-ISSUES — DRACULA: The Un-Dead

Engine and compiler defects/constraints hit while building this game, and
the workaround used. Nothing outside `adventures/dracula/` was modified;
every fix here lives in the game's own files.

---

## 1. `(IN ROOMS)` silently destroys a room's `IN` direction exit

**Severity: high.** This broke every `IN` exit in the game at once.

**Symptom.** `IN` and `ENTER` in a room that declares `(IN PER FOO)` or
`(IN TO SOMEROOM)` answer `"You can't go there without a vehicle."` The
exit routine is never called.

**Root cause.** `czil/src/zcode.c` around line 1062 treats a one-atom
`(IN X)` clause as the object's *parent* only when
`find_propnum(IN) < 0`. But `<DIRECTIONS ... IN OUT LAND>` registers `IN`
as a property, so `find_propnum(IN) >= 0` and the clause is compiled as
the property `IN = ROOMS` instead. The room then has an `IN` property
pointing at the ROOMS container, the real `IN` exit clause is clobbered,
and `DO-WALK ,P?IN` walks into garbage.

**Fix.** Use `LOC` instead of `IN` for the parent clause on every room:

```zil
<ROOM CASTLE-LEDGE
      (LOC ROOMS)              ;"NOT (IN ROOMS) -- see BUILD-ISSUES 1"
      (IN PER LEDGE-IN)
      ...>
```

`LOC` takes the same parent branch in the compiler and has no direction
of the same name, so both work. Reordering the clauses does **not** help.

**Recommendation for future games:** use `(LOC ROOMS)` on every room
unconditionally, even if the game has no `IN` exits yet, because adding
one later fails silently and confusingly.

---

## 2. Dictionary dedup makes a truncated-away word permanently unfindable

**Symptom.** `compile failed: SYNONYM word missing from vocab`, with no
indication of which word.

**Root cause.** `emit_dictionary` (zcode.c ~650) drops words whose
encodings are byte-identical after truncation to the dictionary word
length (9 chars in v8), merging their parts of speech into the survivor.
The comment in the source says dropped spellings "still need lookup by
text" but the implementation just trims `nwords`, so `find_word()`, which
matches on raw `text`, fails for the dropped spelling and the whole build
dies with the message above.

**Our collision:** `TOMBSTONE` (on `SUICIDE-SEAT`) and `TOMBSTONES` (on
`TOMBSTONES`) both truncate to `TOMBSTONE`.

**Fix.** Rename one of them (`HEADSTONE`). To find collisions ahead of
time, group every SYNONYM/ADJECTIVE/SYNTAX word by its first 9
characters and report any group with more than one distinct spelling —
see LESSONS.md for the script.

---

## 3. Parser bit constants are in the same namespace as game objects

**Severity: high**, and the failure is at *runtime*, not compile time.

**Symptom.** `DROP LETTER`, `THROW LETTER AT BARS`, and
`GIVE LETTER TO SZGANY` all answered `"You don't have that!"` even though
`I` listed the letter in inventory and `READ LETTER` worked. Only the
syntax lines carrying the `HAVE` bit failed.

**Root cause.** `gparser.zil` defines `<CONSTANT STAKE 8>` and
`<CONSTANT SHAVE 2>` as *syntax bit masks*. This game has an object named
`STAKE` (the wooden stake). The object definition shadowed the constant,
so `<BTST .IBITS ,STAKE>` in the parser's HAVE check tested against an
object number instead of the bit mask 8 and took the wrong branch.

**Fix.** Renamed the object `WOOD-STAKE`, keeping `(SYNONYM STAKE)` so the
player still types `STAKE`. The dictionary word is unaffected; only the
ZIL atom changed.

**Reserved atoms to avoid for objects/globals** (from gparser.zil ~1032):
`SH SC SIR SOG STAKE SMANY SHAVE`. Also avoid `P-*`, `C-*`, `V?*`,
`M-*`, and anything named after an engine routine.

---

## 4. `<VERB? X>` compiles only if a `V-X` action exists

**Symptom.** `unknown global V?KILL`, `V?APPLY`, `V?PUT-IN`.

**Root cause.** `VERB?` expands to a comparison against the constant
`V?X`, which is created from the *action name* on the right of a SYNTAX
line, not from the dictionary word on the left. `<SYNTAX KILL ... =
V-SIMPLE-KILL>` creates `V?SIMPLE-KILL`, never `V?KILL`. Likewise `APPLY`
and `THROW ... IN` both route to `V-PUT`, so only `V?PUT` exists.

**Fix.** Always test the *action*: `<VERB? SIMPLE-KILL>`, `<VERB? PUT>`.
Mapping for forms this game needed:

| Player types | Action to test |
|---|---|
| `KILL X`, `ATTACK X` | `SIMPLE-KILL` (ours) or `ATTACK` |
| `PUT X IN Y`, `APPLY X TO Y`, `THROW X IN Y` | `PUT` |
| `PUT X ON Y`, `THROW X ON Y` | `PUT-ON` |
| `WAKE X` | `ALARM` |
| `TURN ON X` | `LAMP-ON` |
| `PICK LOCK`, `PICK X WITH Y` | `PICK` |
| `TALK TO X`, `TELL X ABOUT Y` | `TELL` |

---

## 5. `PRE-MUNG` requires WEAPONBIT before the object action runs

**Symptom.** `BREAK DOOR WITH HAMMER` →
`"Trying to destroy the great door with a heavy hammer is futile."` even
though `GREAT-DOOR-FCN` handles `MUNG`.

**Root cause.** `PRE-MUNG` runs before the object's ACTION and rejects any
indirect object lacking `WEAPONBIT`. The hammer had `TOOLBIT` only.

**Fix.** Added `WEAPONBIT` to the hammer. (Generally: PRE-routines are
gatekeepers that run *before* object actions, so an object action can
never rescue a command a PRE-routine rejects.)

---

## 6. No un-wear verb; `V-TAKE`'s "already wearing it" pre-empts objects

**Symptom.** `REMOVE BOOTS` → `"You are already wearing it."` The boots
could never come off, making the wall-climb puzzle unsolvable.

**Root cause.** gsyntax has `WEAR` but no `REMOVE`/`DOFF`. `REMOVE` falls
through to `V-TAKE`, whose worn-object check (gverbs ~1356) fires before
`BOOTS-FCN` is consulted.

**Fix.** Added our own verb in `dverbs.zil`:

```zil
<SYNTAX REMOVE OBJECT (HELD CARRIED) = V-DOFF>
<SYNTAX TAKE OFF OBJECT (HELD CARRIED) = V-DOFF>
<SYNONYM REMOVE DOFF>
```

and tested `<VERB? TAKE DOFF DROP>` in the boots' and crucifix's actions.

---

## 7. `THROW X AT/WITH Y` demands an ACTORBIT indirect object

**Symptom.** `THROW LETTER THROUGH BARS` never reached the window's
action. (`THROUGH` is a stock synonym of `WITH`.)

**Root cause.** Both of gsyntax's THROW-with-indirect forms carry
`(FIND ACTORBIT)` on the indirect object, so scenery can never be the
target.

**Fix.** Added non-ACTORBIT forms routing to our own `V-THROW-AT`.

---

## 8. An adjective on object A blocks the same word as a noun on object B

**Symptom.** `TAKE GOLD` in Dracula's Room → `"You can't see any gold
here!"`, though `GOLD` is a SYNONYM of the heap there. Same for
`READ LOG` at the pier.

**Root cause.** `GOLD` was an ADJECTIVE on `GOLD-SERVICE` (in another
room) and `LOG` an ADJECTIVE on `DINING-FIRE`. The parser resolves the
adjective sense first and then fails to find a matching noun in scope.

**Fix.** Renamed the adjectives (`GOLDEN BEATEN`, `MIGHTY ROARING`). Keep
any word that is a *noun* on one object out of every other object's
ADJECTIVE list.

---

## 9. `session.status` is null for v8

Not a defect, but it shapes testing: v8 story files do not populate the
v3 status-line globals, so `GameSession.status` is always `null`.
`verify.mjs` therefore asserts on the text emitted by the `SCORE`
command, which is the authoritative in-game report regardless of version.

---

## Design adaptations forced by the above

- **SCORE-MAX lowered from 250 to 210.** The design's table sums to 250
  only by counting mutually exclusive branch awards (saving Lucy *and*
  staking her) in the same total. 210 is the honest per-branch ceiling;
  the rank thresholds were rescaled to match. Full-score on the
  save-Lucy path is 204 (the remaining 6 are staking-branch-only finds).
- **`THROW SHORTHAND LETTER THROUGH BARS`** — bare `LETTER` still loses a
  parser disambiguation we did not fully root-cause after fixing the
  `STAKE` constant collision; the adjective form works and the
  walkthrough uses it. `GIVE LETTER TO SZGANY` is the documented
  alternative and has the same handler.
- **The wolf night is no longer keyed to an exact date.** As designed
  ("night 4") the game's climax depended on the player having typed
  exactly the right number of WAITs. It now fires on day four *or* on
  any night the player chooses to keep vigil, whichever comes first.
- **The attack on Mina fires directly after the Carfax raid** rather than
  "the following dawn". A player who went straight from Carfax to the box
  trail never saw an intervening dawn and skipped the act's turning
  point entirely.
- **`OPEN TOMB DOOR`** (two-noun phrase) is not parsed; `OPEN DOOR` is.
