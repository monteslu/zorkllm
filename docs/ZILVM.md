# Scoping: a ZIL interpreter

A plan for running ZIL source directly instead of compiling it to a
Z-machine story file. Written to be picked up cold.

## Why

The Z-machine solved two 1980 problems. One was technical - a TRS-80 had
16KB and Infocom shipped to a dozen incompatible machines, so games had to
be small and portable. The other was commercial: bytecode meant customers
could not read the source, extract the puzzles, or republish the games.

Neither applies here. The trilogy is MIT-licensed, the adaptations in
`adventures/` are ours from public-domain novels, and the whole point is
that people can read the source and write their own. Compiling to hide
something we are publishing is pure cost, and the compression is
unnecessary on hardware that carries a multi-gigabyte model.

What compilation costs us, concretely, is **metadata**. The compiler
assigns `NORTH` a property number by declaration order and discards the
name. The engine does not care - `V-WALK` looks up property N - but every
tool that reads the story file from outside has to reverse-engineer the
mapping. Over one session that cost:

- Four attempts at reading exits, three of which were wrong in ways that
  looked right, one of which told a player "the way out is north" while
  standing on a ship's deck whose only exit was down.
- A reachability checker that misdecoded FEXIT properties and reported
  "torch" and "lunch" as unreachable rooms.
- An audit that could not distinguish an `M-LOOK` override from the LDESC
  it replaced, because routine names are addresses.

Every one of those is a question the source answers in a single line.

The second reason is the LLM layer. The app holds the world; the model is
briefed per question. Briefing is cheap and accurate when the app can
query real structure, and expensive and lossy when it must infer structure
from prose. A source-based runtime makes "what is in this room", "which
ways lead out", "what does this verb do here" into lookups.

The third is Android. A C interpreter compiles to a `.so` over JNI, or to
WASM. Shipping a JavaScript runtime beside a 3GB on-device model is a cost
worth avoiding.

## What exists already

**czil** (`czil/`, 6,346 lines of C11) is a ZIL compiler whose first three
stages are exactly the front end an interpreter needs:

| Stage | File | Lines | Reusable? |
| --- | --- | --- | --- |
| Reader | `src/reader.c` | 484 | **Yes** - parses the whole trilogy today |
| Values | `src/value.c` | 247 | **Yes** |
| Evaluator | `src/eval.c` | 1,313 | **Yes** - MDL evaluation, macros, `%<COND>` |
| Z-model | `src/zmodel.c` | 818 | Partly - object/property model, minus packing |
| Codegen | `src/zcode.c` | 2,685 | **No** - this is what an interpreter replaces |
| Text | `src/ztext.c` | 236 | No - z-char packing is a compilation artifact |
| Abbrevs | `src/zabbrev.c` | 201 | No - compression only |

So roughly 2,000 lines are directly reusable, another 800 partly, and
about 3,100 are replaced by an execution engine. The reader and evaluator
are proven against three complete games, which is the part that would
otherwise be riskiest.

**The oracle** is the existing Z-machine (`vendor/zmachine.mjs`), which
plays the shipped 1980s binaries correctly. Any divergence is the new
interpreter's fault by definition - no judgement calls.

**Seeded RNG parity** already landed. `loadGame(path, {random})` injects an
RNG into the VM, so two implementations calling one function produce
identical `RANDOM`-driven behaviour. Proven on a Zork thief fight: same
seed byte-identical, different seed divergent, no injection genuinely
live. This means the thief, combat and idle barks are *inside* the
comparable surface rather than excluded from it.

## What must actually run

The runtime does not just execute game files. The parser, verb library and
clock are themselves ZIL:

| File | Lines | What it is |
| --- | --- | --- |
| `gverbs.zil` | 2,216 | Every default verb |
| `gparser.zil` | 1,407 | Tokenizer, syntax matching, scope, disambiguation |
| `gsyntax.zil` | 561 | Syntax declarations |
| `gmain.zil` | 313 | Main loop, `PERFORM` dispatch |
| `gglobals.zil` | 308 | Pseudo-objects, globals |
| `gmacros.zil` | 154 | Compile-time macros |
| `gclock.zil` | 60 | Demons and interrupts |
| **engine total** | **5,019** | must execute correctly |

Plus a game: Zork I is 6,837 lines; the adaptations run 4,518 (Treasure
Island) to 7,231 (Dracula).

The hard parts, in rough order:

1. **MDL evaluation semantics** - `%<COND>` compile-time branches,
   `<VERSION?>`, macros expanding into declarations. czil's evaluator
   already does this; the risk is that it does it *for compilation*, and
   an interpreter may need laziness the compiler resolved eagerly.
2. **The property/exit model without packing** - keep names, drop the
   number assignment. This is where the metadata win is realised.
3. **`PERFORM` dispatch order** - actor, room `M-BEG`, preaction, PRSI,
   PRSO, default. Documented in `docs/ENGINE-NOTES.md`; getting it wrong
   produces subtly wrong games rather than crashes.
4. **The clock** - `QUEUE`/`ENABLE`/`INT`, and the fact that it advances
   only on a successful parse (see ENGINE-NOTES; this shapes every timer).
5. **Save/restore** - state must round-trip, or play diverges after a
   reload rather than immediately.

## Build order

**The differ comes first, before any interpreter exists.** A harness that
drives two backends over identical command sequences and compares byte for
byte, reporting the first differing byte with the sequence that produced
it. A percentage match is useless; "after these 43 commands we print
'Taken.' and the oracle prints '(Taken)'" is a bug report.

Stand it up against the Z-machine *alone* first, so it trivially passes
against itself. That proves the harness before it has anything to catch -
the same "run a control that must fail" discipline that caught three
tooling bugs in one session.

Then:

1. **Reader + evaluator over all games.** Reuse czil stages 1-3; assert
   every `.zil` in `zil/` and `adventures/` parses and evaluates.
2. **Object model with names retained.** Rooms, objects, properties,
   directions. Expose it as a queryable API from day one - that API is the
   product, not a side effect.
3. **Execution: expressions, routines, control flow.** No parser yet.
   Test by calling routines directly and comparing return values.
4. **The main loop and `PERFORM`.** Now `LOOK` works. First real differ
   run: boot every game and compare the opening text.
5. **Verbs and the parser.** The long middle. Differ coverage grows
   command by command.
6. **Clock, demons, save/restore.** Timers are where subtle divergence
   lives.

Throughout, the new engine lives behind a flag (`--engine=zil`) beside the
default. It can be wrong, incomplete or crashing for months without
touching a player's game, because nothing calls it unless asked.

## Done is mechanical

Three corpora, all already in the repo:

- **Trilogy walkthroughs** (`czil/tests/walkthrough-*.txt`) - Zork I, II,
  III replaying against the shipped binaries.
- **Five frozen transcripts** (`adventures/*/expected-transcript.txt`) -
  119 to 218 commands each, plus the wanderer variants.
- **Seeded random play** - with the injected RNG, thousands of generated
  sequences are reproducible and comparable. Prefer exhaustive
  state-space walking (every verb against every in-scope object from every
  reachable room) over uniform random input, which mostly bounces off the
  parser and proves little.

The interpreter is finished when `--engine=zil` reproduces the default
engine byte-for-byte across all three. Only then does the default change.

## Open questions

- **How much homebrew ZIL exists?** The bet is that the ZILF revival, the
  IF Archive and the 2019 Infocom source leak mean a real corpus of
  playable source, not just six games we wrote. Worth checking before
  committing: it changes this from "run our own games" to "run an
  ecosystem". Also check dialect - modern ZILF ZIL and 1979 MDL are not
  the same language in practice, and czil already knows which it handles.
- **Does the trilogy still need the Z-machine?** If a game exists only as
  a story file, the Z-machine stays for it. Keeping both engines is
  cheap - they only need to produce text and accept commands.
- **How lazy must evaluation be?** czil's evaluator resolves things at
  compile time that an interpreter may need to defer. This is the biggest
  technical unknown and the first thing to probe.

## Design principles carried forward

These came out of building five games and playing them with local models;
they are what the interpreter should serve.

- **The app is the source of truth.** It holds the whole world in RAM,
  permanently and authoritatively. The model is briefed per question and
  is never asked to remember - anything it needs, the app can tell it
  again. A wrong model answer is recoverable because nothing it says
  becomes true unless the engine agrees.
- **Context is a working set, not a manifest.** Load the minimum, at the
  point of use. Measured: a point-of-use verb list works where the same
  list 3.5k tokens earlier in the system prompt is ignored. Mechanical
  facts that replace inference (room contents, inventory) earn their
  tokens; a full dictionary sent every turn probably does not.
- **The more formulaic, the less the model must do.** Every fact the app
  states is one the model cannot get wrong. A 2B model reached Oz for the
  first time the day the room-contents header landed - not a better model,
  a smaller job.
- **Game text is authored, always.** The model translates and guides; it
  never writes prose the player reads as the game's voice. This is why
  `--no-guide` is a coherent mode rather than a degraded one.
