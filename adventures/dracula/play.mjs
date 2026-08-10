// Scratch driver: feed commands from argv/stdin file and print the transcript.
import { loadGame } from '../../src/zmachine.js';
import { readFileSync } from 'node:fs';

const [, , storyArg, cmdFile] = process.argv;
const story = storyArg || new URL('dracula.z8', import.meta.url).pathname;
const session = await loadGame(story);
let out = await session.start();
process.stdout.write(out);
const cmds = readFileSync(cmdFile, 'utf8')
  .split('\n')
  .map((l) => l.replace(/#.*$/, '').trim())
  .filter(Boolean);
for (const c of cmds) {
  if (session.ended) break;
  process.stdout.write(`\n> ${c}\n`);
  process.stdout.write(await session.send(c));
}
