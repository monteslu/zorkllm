# zorkllm

Play **Zork I, II, and III** through any LLM. The model is only a translator:
you type natural language, it emits classic parser commands, and the original
Z-machine game engine stays authoritative for every rule, room, and grue.

The three games were [MIT-licensed by Microsoft in November 2025](https://opensource.microsoft.com/blog/2025/11/20/preserving-code-that-shaped-generations-zork-i-ii-and-iii-go-open-source/)
and their story files are bundled in `games/` (see `games/LICENSE`).

## Quick start

```sh
npm install

# Local model via Ollama / LM Studio / llama.cpp (any OpenAI-compatible server).
# No --model needed: it auto-detects the server's loaded model.
node src/cli.js zork1 --api-url http://localhost:1234/v1

# Anthropic (uses ANTHROPIC_API_KEY)
node src/cli.js zork1 --provider anthropic --model claude-opus-5

# Any hosted OpenAI-compatible API
node src/cli.js zork2 --api-url https://openrouter.ai/api/v1 --api-key sk-... --model some/model
```

With no flags it prefers `ANTHROPIC_API_KEY`, then `OPENAI_API_KEY`/`OPENAI_BASE_URL`,
then falls back to Ollama on `localhost:11434`.

## Playing

```
[West of House | 0pts | 0 moves] » grab whatever's in the mailbox and read it

> OPEN MAILBOX
Opening the small mailbox reveals a leaflet.

> TAKE LEAFLET
Taken.

> READ LEAFLET
"WELCOME TO ZORK! ..."
```

- Plain English is translated by the LLM — sloppy, vague, or chatty phrasing is
  fine; nobody has to talk like a 1980 parser. Multiple actions become multiple
  game turns.
- **Guide mode** (default): after each turn the model may add a short note for
  newcomers — explaining cryptic parser responses, pointing at possibilities
  the game just revealed, teaching basics like EXAMINE/INVENTORY/light/saving.
  It teaches the *medium* freely but won't volunteer puzzle solutions or magic
  words; hints escalate only as the player asks.
- **`--no-guide` — recommended below roughly 4B.** Note quality tracks model
  quality, and a small model's confident-but-wrong hint costs a stuck player
  more than no hint at all (measured: a 2B model denying that the Emerald
  City exists, in a game about reaching it). Without the guide the LLM is
  purely a translator: your phrasing in, parser commands out, everything
  printed back is the game engine's own text. It is also cheaper — 48 LLM
  calls versus 66 over an identical 50-turn session — and no slower.
  The failure modes are asymmetric, which is why the split is worth making:
  a bad translation costs one free parser rejection and gets retried, while
  a bad guide note is asserted to a player with no way to check it.
- `> command` bypasses the LLM and talks to the 1980 parser directly.
- `/save [file]`, `/restore [file]`, `/quit`, `/help`.
- Game text is always shown unmodified.
- **Thinking models**: the agent requests reasoning off per-call
  (`reasoning_effort: "none"`, auto-retried without it on servers that reject
  the field) — measured 300 → 16 completion tokens per turn on gemma-4-e4b in
  LM Studio, no server configuration needed. `--think` leaves reasoning on.
  Inline `<think>` blocks are stripped defensively either way.

## Make your own adventures

The repo is the whole toolchain, not just the player. `zil/` holds the
MIT-licensed source code of all three Zork games; `czil/` is a C port of
the ZILF compiler (also compiled to bare WebAssembly, so plain Node can
build games with no C toolchain); `examples/tinyquest/` is a small
complete game built on the Zork engine files.

```sh
node czil/dist/czil-compile.mjs examples/tinyquest/tinyquest.zil -I zil/zork1 -o tinyquest.z3
node src/cli.js tinyquest.z3
```

See [AUTHORING.md](docs/AUTHORING.md) for the full guide to writing games,
[ADAPTING.md](docs/ADAPTING.md) for how to turn a public-domain novel into a
buildable game design (the process behind `adventures/`, written for
LLM agents as much as people), [ENGINE-NOTES.md](docs/ENGINE-NOTES.md) for engine traps and idioms learned
building them, [ZILVM.md](docs/ZILVM.md) for the plan to run ZIL source
directly instead of compiling it, [SCENES.md](docs/SCENES.md) for extracting structured scene
descriptions from a story file, and `czil/README.md` for the compiler
itself (its test gate: the trilogy compiled from this repo's sources
plays transcript-identical to the shipped 1980s binaries).

Games are verified in three layers - a walkthrough (proves completable),
static audits in `tools/` (prove coherent), and a wanderer test of pure
junk input (proves a lost player is never stranded). See
[ENGINE-NOTES.md](docs/ENGINE-NOTES.md) for why the first alone is not
enough.

`adventures/` holds full adaptations in progress - five classic novels
(Treasure Island, Dracula, The Count of Monte Cristo, Alice in
Wonderland, The Wonderful Wizard of Oz), each with deep study notes and
a complete room-by-room, puzzle-by-puzzle design.

## How it works

For the full internals — turn lifecycle, the COMMANDS/SAY protocol, context
strategy, invariants, and where to make changes — see
[ARCHITECTURE.md](docs/ARCHITECTURE.md).

- `vendor/zmachine.mjs` — the [`zmachine`](https://www.npmjs.com/package/zmachine)
  interpreter (MIT), bundled to a single file. Runs the real `.z3` story files;
  handles save/restore (Quetzal format).
- `src/zmachine.js` — headless driver: send a command string, get the game's
  text for that turn.
- `src/vocab.js` — extracts the game's real parser dictionary (684 words for
  Zork I) straight from the story file; it goes into the system prompt so the
  model translates into words the parser actually knows.
- `src/prompt.js` — the translation contract. Plain-text `COMMANDS` / `SAY`
  protocol (no tool calling), so small local models work.
- `src/providers.js` — two clients cover everything: OpenAI-compatible chat
  completions (fetch) and Anthropic (official SDK).
- `src/agent.js` — the loop; game output is fed back into the transcript as
  ground truth so pronouns and disambiguation questions resolve.

Nothing is Zork-specific: any v1–v8 Z-machine story file works —
`node src/cli.js path/to/game.z5`. The vocabulary, word-truncation length,
status line, and every deterministic shortcut (curse words, magic phrases,
meta verbs) adapt to the loaded game's own dictionary; games lacking a word
simply route that input through the LLM instead. Verified against Inform-
compiled v5 games as well as the Infocom trilogy.

## Two floors: 16k context, 4B model

Independent requirements that fail in different ways.

**Context: 16k floor, 32k comfortable.** This is arithmetic, not
capability. The system prompt runs ~3.5k tokens (the game's dictionary
dominates) and a literary adaptation prints roughly 3x Zork's room text, so
at 8k the window evicts every second turn and the model cannot hold a
puzzle in mind. Measured over an identical 50-turn session: 22 evictions at
8k, zero at 16k, with no latency cost (0.55s vs 0.57s per turn) — it buys
memory, not compute, and most local runtimes default to 8k regardless of
what the model supports, so it is usually one slider away.

A *complete* playthrough of the five `adventures/` games accumulates
17k-25k tokens along the walkthrough path alone (Dracula is the largest at
~25k; Monte Cristo the cheapest at ~17k despite being the longest game —
per-turn prose style matters more than game size). A real player wanders,
so budget 2-3x that: **16k is the floor, 24k finishes a walkthrough
uncompacted, 32k absorbs a genuine exploratory playthrough.** Past that
you are paying memory to retain transcript the Z-machine already tracks
authoritatively, and chunked eviction keeps the prompt prefix byte-stable
anyway.

**Capability: ~4B is the floor for guide mode only.** Translation works
fine below it; advice does not, and more context does not fix it, because
context was never the constraint. A 2B model at 16k with room to spare
still denied that the Emerald City exists. Run smaller models with
`--no-guide`: same speed, fewer calls, and nothing printed but the game's
own text.

The classic Infocom games are lighter than the `adventures/` adaptations
and remain comfortable at 8k.

## Small context windows

Game state never lives in the LLM — score, inventory, room contents, and timers
are all inside the Z-machine, so trimming the model's context can never corrupt
a game. Three knobs keep small local models (4k–8k context) comfortable:

- `--history N` — target number of recent exchanges the model sees (default
  20; 6–8 is plenty for a 4k context). Eviction is **chunked, not sliding**:
  the window grows to ~2×N then cuts back to N in one chop, so the prompt
  prefix stays byte-stable between evictions — which is what lets prefix-
  matched caches (llama.cpp/Ollama KV cache, Anthropic prompt caching) keep
  working instead of re-prefilling the whole context every turn.
- `--no-vocab` — omits the game dictionary from the system prompt
  (~1765 tokens with the full Zork I dictionary, ~810 without).
- **Authoritative state header** — every request prepends a line read directly
  from the engine, so even a model that has forgotten everything stays oriented:

  ```
  [state: in "Living Room", score 45, 19 moves. Rooms visited: West of House,
   South of House, Behind House, Kitchen, Living Room, Cellar, ...]
  ```

  The visited-rooms list is tracked by the driver from the engine's own status
  globals — mechanical compaction of spatial history, no summarization calls,
  and it can't hallucinate.

All of this is **sized automatically**: at startup the client asks the server
how much context is actually loaded (LM Studio reports `loaded_context_length`
— often 8k even for 131k models; Ollama reports the running model's context)
and fits the history window, vocabulary, and a hard token budget to it. Every
request is estimated against that budget and history is evicted in chunks
until it fits, so a long session can never outgrow the server. A
context-exceeded error from an unknown server recovers by shrinking the window
and retrying once. `--history` / `--no-vocab` still override the automatics.

One more resilience layer: when the 1980 parser rejects a command ("I don't
know the word X"), that rejection costs no game move — the ZIL clock only
ticks on successful parses — so the agent asks the model once for a corrected
command restricted to dictionary words and runs that. Vocabulary misses heal
themselves mid-turn.

## Troubleshooting

- While the model is working the CLI shows an animated `Thinking...` line
  (with a seconds counter once it gets slow) — big local models can take
  10-30s a turn; the 4B-class models are genuinely the sweet spot here.
- If a model ever behaves strangely, set `ZORKLLM_DEBUG=/tmp/zorkllm.jsonl`
  and replay the moment: every raw LLM exchange (prompt tail, raw reply,
  reasoning text, finish reason, token usage) is appended as one JSON line.
- An empty or protocol-less model reply is retried once with a corrective
  nudge before the CLI falls back to asking you to rephrase.

## Tests

```sh
npm test
```

Runs the interpreter against the real story files (walkthrough assertions,
save/restore round-trip, a control that must fail) and the agent loop against
a scripted mock LLM — no network needed.
