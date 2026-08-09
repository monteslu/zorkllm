// czil stage-5 harness: run a story file through zorkllm's Z-machine,
// feeding it a command script, printing the transcript to stdout.
// Usage: node tests/play.mjs game.z3 script.txt
import { readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

// Deterministic RNG so two story files given the same commands make the
// same RANDOM rolls: the whole point of the transcript differ.
let seed = 0x2dba7 >>> 0;
Math.random = () => {
  seed = (seed + 0x6d2b79f5) >>> 0;
  let t = seed;
  t = Math.imul(t ^ (t >>> 15), t | 1);
  t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
};

const here = dirname(fileURLToPath(import.meta.url));
const { loadGame } = await import(join(here, '..', '..', 'src', 'zmachine.js'));

const [game, scriptFile] = process.argv.slice(2);
if (!game || !scriptFile) {
  console.error('usage: node tests/play.mjs game.z3 script.txt');
  process.exit(2);
}

const commands = (await readFile(scriptFile, 'utf8'))
  .split('\n')
  .map((l) => l.trim())
  .filter((l) => l && !l.startsWith('#'));

const session = await loadGame(game);
const timeout = setTimeout(() => {
  console.error('[TIMEOUT: game did not reach an input prompt]');
  process.exit(3);
}, 30000);

const opening = await session.start();
console.log(opening);
for (const cmd of commands) {
  if (session.ended) break;
  console.log(`> ${cmd}`);
  const out = await session.send(cmd);
  console.log(out);
  const st = session.status;
  if (st) console.log(`[status: ${st.location} | score ${st.score} | moves ${st.turns}]`);
}
clearTimeout(timeout);
process.exit(0);
