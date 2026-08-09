# zorkllm architecture

This document is the working map of the codebase: what each piece does, the
invariants that must not be broken, and where to make common changes. It is
written so that someone (or some agent) who has never seen the code can make a
correct change on the first try.

## The one-sentence design

The Z-machine is the game; the LLM is only a translator and narrator-guide;
every fact the player sees comes from the engine, and anything the model
cannot be trusted to do reliably is done deterministically instead.

## What actually runs the game

Nothing executes ZIL at play time. The chain is:

1. `zil/zork{1,2,3}/*.zil` - ZIL **source code** (like `.c` files),
   the MIT-licensed originals.
2. `czil/` - a **compiler** (C11, and a bare-wasm build for Node) that
   turns ZIL source into a `.z3` file. Used at build time only.
3. `games/*.z3` - **bytecode** for the Z-machine, a 1979 virtual
   machine. The bundled files are the actual shipped Infocom binaries;
   czil's test gate is that its rebuilt ones play identically.
4. `vendor/zmachine.mjs` - a Z-machine **interpreter in JavaScript**
   (a CPU emulator for that bytecode, running in Node). This is what
   "runs the game", exactly as the original Apple II interpreter did.
5. `src/` - the LLM agent, which only types parser commands into the
   running interpreter and reads its text back.

So: JavaScript runs the game; C (or its wasm build) compiles the game;
the LLM plays the game.

## Layers

```
player text
   |
   v
src/cli.js         terminal UI: readline loop, spinner, /commands, "> raw" escape
   |
   v
src/agent.js       ZorkAgent: deterministic bypasses -> LLM translation ->
   |               command execution -> parser-reject retry -> guide reflection
   |----> src/prompt.js     system prompt text + reply parsing (the protocol)
   |----> src/providers.js  one client for OpenAI-compatible servers, one for Anthropic
   v
src/zmachine.js    GameSession: headless driver over the interpreter
   |
   v
vendor/zmachine.mjs  the npm `zmachine` interpreter (MIT), bundled to one file
   |
   v
games/*.z3         the real 1980s story files (MIT-licensed by Microsoft)
```

`src/vocab.js` sits beside this stack: it reads the story file's own parser
dictionary at load time and feeds it to both the system prompt and the
agent's dictionary gate.

## Invariants (do not break these)

1. **The engine is the only truth.** Game text is always shown unmodified.
   The model must never describe the world from memory: the system prompt
   bans invented atmosphere in SAY messages, and "what do we see" style
   questions are translated to LOOK rather than answered from the transcript.
   If you add a feature that paraphrases or summarizes game output, you have
   broken the core promise.

2. **The player never needs parser words.** Nothing user-facing may say "try
   typing LOOK" or claim a word is unknown. Loose speech ("gander", "what's
   in my pockets") must translate. Guidance teaches possibilities in plain
   English, not command vocabulary.

3. **Nothing is Zork-specific.** Every deterministic shortcut is gated on the
   loaded game's own dictionary (`#inDictionary`). A game without a CURSE
   verb routes swearing to the LLM instead. Any v1-v8 story file must keep
   working: `node src/cli.js path/to/game.z5`.

4. **Game state never lives in the LLM.** Score, room, moves, inventory, and
   timers live in the Z-machine. The context window can be evicted at any
   time without corrupting anything, because the `[state: ...]` header is
   re-read from the engine on every request and never stored in history.

5. **One model per session.** No multi-model architectures; the design target
   is a single small local model (4B class) doing everything well.

6. **Small models are the floor.** The protocol is plain text (COMMANDS/SAY),
   not tool calling, because ~4B models cannot do tool calls reliably. Any
   protocol change must stay parseable by a sloppy 4B model, and
   `parseReply` must stay tolerant of the mess they produce (fences, stray
   headers, prose mixed into command lists).

## A turn, end to end (`ZorkAgent.turn`, src/agent.js)

1. **Deterministic bypasses**, in order, each gated on the game dictionary:
   - Swearing tirade (2 of first 3 words profane) -> sent raw to the parser;
     Zork's own V-CURSES easter egg is the authentic response.
   - Famous phrases (`xyzzy`, `hello sailor`, ...) -> raw.
   - Direction-led exclamations of 2-3 words ("west young man!!") -> the
     direction, raw.
   - Single meta words (`quit`, `save`, `look`, `inventory`, directions...)
     -> raw. `y`/`yes`/`n`/`no` -> raw only when the last game output ended
     in a question, otherwise they go to the LLM (they may be answering the
     guide, not the game).
   Bypasses cost 0 LLM calls and 0 seconds; they exist because live testing
   showed models lecture, hallucinate success, or mis-coach on exactly these
   inputs. One exception to "0 calls": when a bypassed turn produces a
   confusing engine response (a parser rejection, blocked movement, a
   disambiguation question, or a stock ZIL/Inform refusal like "You can't
   do that" - see CONFUSING_RESPONSE in src/agent.js), the guide
   reflection still runs so the player gets a note instead of only the
   engine's terse error. Because that error was just printed, the
   reflection uses a continuation variant of the guide-check prompt: the
   note must pick up where the engine's message left off in the same
   voice, adding only what it failed to say, never restating it. The same
   variant is chosen on normal turns whose final response matches.
   Successful bypassed turns stay zero-cost.
2. **Pre-parse router** (`#asParserCommand`). Input that already IS
   parser-speak skips translation: the game's own dictionary must know
   every word, classify the first as a verb, and classify at least one
   as a noun (all read from the story file's part-of-speech bytes - the
   engine still does ALL parsing; this only routes). The noun
   requirement keeps chat that happens to start with a verb ("wait
   what") away from the engine, where it would execute WAIT and burn
   game moves. Misrouted commands bounce for free and fall into the
   normal retry ladder.
3. **Translation call.** The window (see below) is sent with the system
   prompt; the reply is parsed by `parseReply` into `commands`, `say`, or
   `empty`.
   - `empty` (blank reply, bare `PASS`, lone header): one corrective retry
     with an explicit reminder of the two reply shapes, then a friendly
     "tell me something specific" fallback. Never surface internal jargon.
   - `say`: shown to the player as the guide's voice; no game turn happens.
4. **Execution.** Each command is sent to the engine; every game response is
   pushed into history as `[game responded to "CMD"]\n<output>` - ground
   truth the model sees next turn, which is how pronouns and disambiguation
   questions resolve.
5. **Parser-reject retry** (`#retryCommand`). Rejections cost no game move
   (the ZIL clock only ticks on successful parses), so one corrective LLM
   call is free. The correction is validated with `#inDictionary` before
   sending; a still-invalid correction is never sent (it would just bounce
   again) - the player gets an honest in-voice note instead. The retry's SAY
   explanation, if any, surfaces as the turn note.
6. **Guide reflection** (`#reflect`). One extra call on the same cached
   prefix asking for `PASS` or a short newcomer note (`GUIDE_CHECK` in
   prompt.js). Notes teach mechanics and point at just-revealed
   possibilities; they never volunteer puzzle solutions. `--no-guide`
   disables this.

## Context strategy (`#window`, `#buildWindow`, `#stateHeader`)

- **Chunked eviction, not sliding.** The window grows to ~2x the target then
  cuts back in one chop (`#anchor` jump). A sliding window would change the
  prompt prefix every turn and defeat prefix caches (llama.cpp/Ollama KV
  cache, Anthropic prompt caching); chunked eviction keeps the prefix
  byte-stable between evictions. First turn after an eviction re-prefills;
  every other turn hits cache.
- **Hard token budget.** At startup the client asks the server what context
  is actually loaded (LM Studio `/api/v0/models` reports
  `loaded_context_length`, often 8k for a 131k model; Ollama reports the
  running model's context). The CLI sizes history/vocab to it and sets
  `tokenBudget`; `#window` estimates each request (chars/4 heuristic) and
  evicts in chunks until it fits. A context-exceeded error from an unknown
  server shrinks to 8 entries and retries once.
- **State header.** `#stateHeader` reads room/score/moves/visited-rooms from
  the engine and prepends it to the latest user message at request time. It
  is injected, never stored, so it cannot go stale or be evicted.
- **Roles must alternate.** `#buildWindow` merges consecutive same-role
  entries and drops a leading assistant message; Anthropic rejects windows
  that do not alternate.

## The protocol (src/prompt.js)

The model replies in one of two shapes, chosen per turn:

```
COMMANDS          SAY
NORTH             Which lamp do you mean, the brass one or the broken one?
OPEN MAILBOX
```

`parseReply` is deliberately forgiving: code fences stripped, `<think>`
blocks stripped (including an unmatched closing tag), `COMMANDS:` and `> `
prefixes tolerated, numbered lists accepted, lines over 6 words or ending in
sentence punctuation treated as prose rather than commands, a stray header
mid-reply ends command parsing, and a trailing dangling ALL-CAPS command
after sentence punctuation is stripped from spoken text ("... try something
else! QUIT"). Every one of these rules exists because a live small-model
session produced that exact malformation; the fixtures in
`test/agent.test.js` are verbatim from those sessions.

`buildSystemPrompt` carries the voice rules (the guide IS the game, first
person, never "the game told you"), the prime directive (player never needs
parser words), the zero-world-description rule for SAY, and the game's own
vocabulary list (`--no-vocab` omits it to save ~950 tokens).

## Providers (src/providers.js)

- `resolveConfig` picks a provider from flags/env: explicit flags win, then
  `ANTHROPIC_API_KEY`, then `OPENAI_API_KEY`/`OPENAI_BASE_URL`, then Ollama
  on localhost.
- `detectServer` finds the loaded model and real context size: LM Studio
  `/api/v0/models` (state=loaded) -> Ollama `/api/ps` then `/api/tags` ->
  generic `/v1/models` (first non-embedding id).
- **Thinking models:** every request sends `reasoning_effort: "none"`
  (translation is a reflex task; reasoning was measured at ~9x latency for
  no accuracy gain). A 4xx response retries once without the field and stops
  sending it. `--think` opts back in. `<think>` output is stripped anyway.
- `max_tokens: 512` caps runaway generation - unbounded completions, not
  long prompts, were the real cause of "context size exceeded" crashes.
- `ZORKLLM_DEBUG=/path/file.jsonl` appends every raw exchange (prompt tail,
  raw content, reasoning text, finish reason, usage). This is the first tool
  to reach for on any "the model did something weird" report.

## The engine driver (src/zmachine.js)

`GameSession` wraps the interpreter with a promise-inverted `readLine`: the
game runs until it asks for input, everything printed lands in a buffer, and
`send(command)` resolves with that turn's text. Details that matter:

- Only window 0 output is captured (v4+ games draw status bars in window 1;
  letting that through corrupts transcripts).
- v3 status (room/score/moves) is read from globals 16/17/18 at each input
  prompt because the library only handles the explicit status opcode. The
  visited-rooms list is derived from this - mechanical, never summarized.
- Save/restore use the session's `saveFile`; `/save name` from the CLI sets
  it.

## Vocabulary (src/vocab.js)

`extractVocabulary` walks the story file's dictionary directly: v1-v3 use
4-byte text entries (6 z-chars), v4+ use 6-byte (9 z-chars).
`dictWordLength` matters everywhere words are compared: the parser only sees
the first 6 (or 9) letters, so `#inDictionary` truncates before checking
("trapdoor" matches the entry "trapdo").

## Testing philosophy

`npm test` runs two suites, no network:

- `test/zmachine.test.js`: the interpreter against the real story files -
  walkthrough with exact score assertions, save/restore round trip, and a
  control that must fail.
- `test/agent.test.js`: `parseReply`/`parseGuideNote` fixtures (most taken
  verbatim from live broken sessions - when a live session breaks, its
  transcript becomes a fixture), and the agent loop against scripted mock
  LLMs (bypass routing, retry ladders, empty-reply handling, quit flow).

The rule: every live failure becomes a test before or with its fix.

## Where to make common changes

- New deterministic shortcut: the constant sets at the top of `src/agent.js`
  (`META_WORDS`, `FAMOUS_PHRASES`, ...) - always gate on `#inDictionary`.
- Prompt/voice change: `src/prompt.js` `buildSystemPrompt`. Watch total size
  (~2k tokens); it is the fixed cost every request pays.
- New provider: `src/providers.js` - prefer teaching `detectServer` about it
  over adding a third client; almost everything is OpenAI-compatible.
- New reply malformation from some model: add the raw reply as a fixture in
  `test/agent.test.js`, then extend `parseReply`.
- Different game: nothing to change - `node src/cli.js path/to/game.z5`.
  If its parser rejection messages are unrecognized, extend `PARSER_REJECT`
  in `src/agent.js` (unknown messages only cost the free-retry optimization;
  nothing breaks).

## Known limits

- The guide does not diagnose false premises (a player insisting on an
  object that is elsewhere gets the engine's honest "You can't see any X
  here!" every time, but no "are you thinking of a different room?").
- Token estimation is chars/4, not a real tokenizer - the budget keeps a
  safety margin for that reason.
- `EXPAND`-style multi-step planning is deliberately absent: one player
  message becomes at most a handful of commands, and the game's own output
  steers the next step.
