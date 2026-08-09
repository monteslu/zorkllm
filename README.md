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
  words; hints escalate only as the player asks. `--no-guide` for purist mode.
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

See [AUTHORING.md](AUTHORING.md) for the full guide to writing games,
and `czil/README.md` for the compiler itself (its test gate: the trilogy
compiled from this repo's sources plays transcript-identical to the
shipped 1980s binaries).

## How it works

For the full internals — turn lifecycle, the COMMANDS/SAY protocol, context
strategy, invariants, and where to make changes — see
[ARCHITECTURE.md](ARCHITECTURE.md).

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
