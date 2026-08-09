#!/usr/bin/env node
/**
 * zorkllm - play Zork I/II/III through any LLM.
 *
 *   zorkllm zork1                                # Anthropic (ANTHROPIC_API_KEY) or local ollama
 *   zorkllm zork2 --api-url http://localhost:11434/v1 --model qwen2.5:7b-instruct
 *   zorkllm zork3 --provider anthropic --model claude-opus-5
 *   zorkllm path/to/game.z3 --api-url https://openrouter.ai/api/v1 --api-key ... --model ...
 *
 * In-game:  plain English is translated by the LLM; lines starting with ">"
 * go straight to the parser; /save /restore /quit /help are handled locally.
 */
import { createInterface } from 'node:readline';
import { fileURLToPath } from 'node:url';
import { dirname, join, resolve } from 'node:path';
import { existsSync } from 'node:fs';
import { loadGame } from './zmachine.js';
import { ZorkAgent } from './agent.js';
import { resolveConfig, createClient } from './providers.js';

const GAMES_DIR = join(dirname(fileURLToPath(import.meta.url)), '..', 'games');
const BUILTIN = { zork1: 'Zork I', zork2: 'Zork II', zork3: 'Zork III' };

const dim = (s) => `\x1b[2m${s}\x1b[0m`;
const cyan = (s) => `\x1b[36m${s}\x1b[0m`;
const green = (s) => `\x1b[32m${s}\x1b[0m`;

function parseArgs(argv) {
  const flags = {};
  const positional = [];
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--provider') flags.provider = argv[++i];
    else if (a === '--model') flags.model = argv[++i];
    else if (a === '--api-url') flags.apiUrl = argv[++i];
    else if (a === '--api-key') flags.apiKey = argv[++i];
    else if (a === '--history') flags.historyTurns = Number(argv[++i]);
    else if (a === '--no-vocab') flags.includeVocab = false;
    else if (a === '--no-guide') flags.guide = false;
    else if (a === '--think') flags.think = true;
    else if (a === '--help' || a === '-h') flags.help = true;
    else positional.push(a);
  }
  return { flags, positional };
}

function usage() {
  console.log(`Usage: zorkllm [zork1|zork2|zork3|path.z3] [options]

Options:
  --provider  anthropic | openai        (openai = any OpenAI-compatible server)
  --model     model name (default: auto-detect the server's loaded model;
              anthropic default claude-opus-5)
  --api-url   base URL for openai-compatible servers (default http://localhost:11434/v1)
  --api-key   API key (or ANTHROPIC_API_KEY / OPENAI_API_KEY env)
  --history N how many recent exchanges the LLM sees (default 20; use 6-8 for 4k-context models)
  --no-vocab  omit the game dictionary from the prompt (saves ~1k tokens)
  --no-guide  pure translator: no post-turn guidance, one LLM call per turn
              (recommended for small models, ~4B and under)
  --think     leave the model's reasoning/thinking on (default: off for speed)

Environment: ZORKLLM_PROVIDER, ZORKLLM_MODEL, ZORKLLM_API_URL, ZORKLLM_API_KEY

In game:
  plain English        the LLM translates it into parser commands
  > command            bypass the LLM, talk to the parser directly
  /save [file]         save game    /restore [file]   restore game
  /quit                exit         /help             this text`);
}

async function main() {
  const { flags, positional } = parseArgs(process.argv.slice(2));
  if (flags.help) return usage();

  const pick = positional[0] || 'zork1';
  const gameName = BUILTIN[pick] || pick;
  const storyPath = BUILTIN[pick] ? join(GAMES_DIR, `${pick}.z3`) : resolve(pick);
  if (!existsSync(storyPath)) {
    console.error(`No such game: ${storyPath}`);
    process.exit(1);
  }

  const config = resolveConfig(flags);
  const llm = await createClient(config);
  const session = await loadGame(storyPath);
  session.saveFile = `${pick.replace(/[^a-z0-9]/gi, '_')}.sav`;
  // Size everything to the context the server actually has loaded (often far
  // below the model's maximum - LM Studio loads 131k models at 8k by default).
  const ctx = llm.contextLength;
  const auto = {};
  if (ctx) {
    if (flags.includeVocab === undefined && ctx <= 4500) auto.includeVocab = false;
    if (flags.historyTurns === undefined) {
      const systemTokens = (flags.includeVocab ?? auto.includeVocab) === false ? 900 : 1900;
      const budget = ctx - 800 - systemTokens; // generation + safety margin
      auto.historyTurns = Math.max(3, Math.min(20, Math.floor(budget / 500)));
    }
    auto.tokenBudget = ctx - 800;
  }
  const agent = new ZorkAgent(session, llm, gameName, {
    historyTurns: flags.historyTurns ?? auto.historyTurns,
    includeVocab: flags.includeVocab ?? auto.includeVocab,
    guide: flags.guide,
    tokenBudget: auto.tokenBudget,
  });

  console.log(dim(`zorkllm | ${gameName} | LLM: ${llm.describe()} | ${session.vocabulary.length} dictionary words`));
  if (ctx) {
    console.log(dim(`context: ${ctx} tokens (server-reported) | history window: ${agent.historyTurns} exchanges${agent.system.includes('VOCABULARY (') ? '' : ' | vocab omitted to fit'}`));
  }
  console.log(cyan(`Just say what you want to do - "look around", "grab the sword", "what should I try?" -
no special wording needed, and you can ask questions any time. The game's own
replies are shown exactly as written in 1980.`));
  console.log(dim(`">" prefix sends a raw parser command, /help for more.\n`));

  const opening = await session.start();
  console.log(opening + '\n');

  const rl = createInterface({ input: process.stdin, output: process.stdout });
  const ask = () => new Promise((res) => rl.question(statusPrompt(session), res));

  for (;;) {
    const line = (await ask()).trim();
    if (!line) continue;

    if (line.startsWith('/')) {
      const [cmd, ...rest] = line.slice(1).split(/\s+/);
      if (cmd === 'quit' || cmd === 'exit') break;
      if (cmd === 'help') { usage(); continue; }
      if (cmd === 'save' || cmd === 'restore') {
        if (rest[0]) session.saveFile = rest[0];
        const { output } = await agent.raw(cmd.toUpperCase());
        console.log('\n' + output + '\n');
        continue;
      }
      console.log(dim(`unknown /${cmd} - try /help`));
      continue;
    }

    try {
      if (line.startsWith('>')) {
        const { command, output } = await agent.raw(line.slice(1).trim());
        printTurn(command, output);
      } else {
        const stop = spinner();
        let result;
        try {
          result = await agent.turn(line);
        } finally {
          stop();
        }
        if (result.type === 'say') {
          console.log('\n' + cyan(result.message) + '\n');
        } else {
          for (const t of result.turns) printTurn(t.command, t.output);
          if (result.note) console.log(cyan(result.note) + '\n');
        }
      }
    } catch (err) {
      console.error(dim(`\n[llm error] ${err.message}\n`));
    }

    if (session.ended) break;
  }

  rl.close();
  console.log(dim('\n(zorkllm session ended)'));
  process.exit(0);
}

/**
 * Animated "Thinking..." line while the LLM works, so slow local models
 * don't look stuck. Returns a stop function that clears the line. No-op
 * when stdout isn't a terminal (piped/scripted runs stay clean).
 */
function spinner() {
  if (!process.stdout.isTTY) return () => {};
  const frames = ['   ', '.  ', '.. ', '...'];
  let i = 0;
  const started = Date.now();
  const tick = () => {
    const secs = Math.floor((Date.now() - started) / 1000);
    const timer = secs >= 3 ? ` ${secs}s` : '';
    process.stdout.write(`\r\x1b[2mThinking${frames[i++ % frames.length]}${timer}\x1b[0m `);
  };
  tick();
  const id = setInterval(tick, 350);
  return () => {
    clearInterval(id);
    process.stdout.write('\r\x1b[2K');
  };
}

function printTurn(command, output) {
  console.log('\n' + green(`> ${command.toUpperCase()}`));
  if (output) console.log(output);
  console.log();
}

function statusPrompt(session) {
  const s = session.status;
  return s ? dim(`[${s.location.trim()} | ${s.score}pts | ${s.turns} moves] `) + '» ' : '» ';
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
