#!/usr/bin/env node
/**
 * Differential harness: drive two engines over identical command
 * sequences and report the FIRST place they disagree.
 *
 * This exists before the interpreter does, on purpose. Standing it up
 * against the Z-machine alone means it trivially passes against itself -
 * which proves the harness before it has anything to catch. A differ that
 * has never reported a difference is a guess, so `--selftest` also runs a
 * deliberately corrupted comparison that MUST fail.
 *
 * A percentage match is useless. The only useful output names the command
 * that diverged and shows both texts, so the report is a bug you can act
 * on rather than a score.
 *
 * Backends are pluggable: each is an async factory returning
 * `{ start(), send(command), ended }`. The reference backend is the
 * Z-machine playing a compiled story file; the interpreter will register
 * as a second backend reading the same game's ZIL source.
 *
 * Usage:
 *   node zilvm/differ.mjs --game <name> [--script <file>] [--seed N]
 *   node zilvm/differ.mjs --selftest
 */
import { readFile } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');

/**
 * The seeded RNG both engines share. Injecting one function is what makes
 * RANDOM-driven behaviour - the thief, combat, idle barks - comparable
 * rather than something to exclude from the comparison.
 * @param {number} seed
 */
export function makeRng(seed) {
  let s = seed >>> 0;
  return (range) => {
    s = (Math.imul(s, 1103515245) + 12345) >>> 0;
    return (s % range) + 1;
  };
}

/** Games with both a compiled story file and ZIL source in this repo. */
export const GAMES = {
  zork1: { story: 'games/zork1.z3', source: 'zil/zork1', main: 'zork1.zil' },
  'treasure-island': {
    story: 'adventures/treasure-island/treasure.z8',
    source: 'adventures/treasure-island', main: 'treasure.zil',
    script: 'adventures/treasure-island/walkthrough.txt',
  },
  alice: {
    story: 'adventures/alice/alice.z8',
    source: 'adventures/alice', main: 'alice.zil',
    script: 'adventures/alice/walkthrough.txt',
  },
  'wizard-of-oz': {
    story: 'adventures/wizard-of-oz/oz.z8',
    source: 'adventures/wizard-of-oz', main: 'oz.zil',
    script: 'adventures/wizard-of-oz/walkthrough.txt',
  },
  'monte-cristo': {
    story: 'adventures/monte-cristo/cristo.z8',
    source: 'adventures/monte-cristo', main: 'cristo.zil',
    script: 'adventures/monte-cristo/walkthrough.txt',
  },
  dracula: {
    story: 'adventures/dracula/dracula.z8',
    source: 'adventures/dracula', main: 'dracula.zil',
    script: 'adventures/dracula/walkthrough.txt',
  },
};

/**
 * Reference backend: the Z-machine playing the compiled story file. This
 * is the oracle - it plays the shipped 1980s binaries correctly, so any
 * divergence belongs to the other side by definition.
 * @param {string} storyPath @param {(range: number) => number} random
 */
export async function zmachineBackend(storyPath, random) {
  const { loadGame } = await import(join(ROOT, 'src', 'zmachine.js'));
  const session = await loadGame(storyPath, { random });
  return {
    name: 'zmachine',
    start: () => session.start(),
    send: (command) => session.send(command),
    get ended() { return session.ended; },
  };
}

/**
 * A backend that corrupts another one after N turns. Used only by
 * --selftest, to prove the differ can actually fail.
 */
function corruptedBackend(inner, afterTurn) {
  let turn = 0;
  return {
    name: `${inner.name}+corrupted`,
    start: () => inner.start(),
    async send(command) {
      turn += 1;
      const out = await inner.send(command);
      return turn === afterTurn ? out.replace(/[aeiou]/g, 'x') : out;
    },
    get ended() { return inner.ended; },
  };
}

/**
 * Run both backends over the commands, stopping at the first difference.
 * @returns {Promise<{ok: boolean, turns: number, command?: string, a?: string, b?: string, at?: number}>}
 */
export async function diff(backendA, backendB, commands) {
  const openA = (await backendA.start()) ?? '';
  const openB = (await backendB.start()) ?? '';
  if (openA !== openB) {
    return { ok: false, turns: 0, command: '(opening text)', a: openA, b: openB, at: firstDiff(openA, openB) };
  }
  let turns = 0;
  for (const command of commands) {
    if (backendA.ended || backendB.ended) break;
    turns += 1;
    const a = (await backendA.send(command)) ?? '';
    const b = (await backendB.send(command)) ?? '';
    if (a !== b) return { ok: false, turns, command, a, b, at: firstDiff(a, b) };
  }
  return { ok: true, turns };
}

/** Index of the first differing character, for a precise report. */
function firstDiff(a, b) {
  const n = Math.min(a.length, b.length);
  for (let i = 0; i < n; i++) if (a[i] !== b[i]) return i;
  return n;
}

/** Print a divergence as something actionable. */
function report(result, label) {
  if (result.ok) {
    console.log(`ok  ${label}: ${result.turns} commands identical`);
    return true;
  }
  console.log(`DIFF ${label}: diverged at command ${result.turns} (${JSON.stringify(result.command)})`);
  const context = 60;
  const from = Math.max(0, result.at - context);
  console.log(`  byte ${result.at}`);
  console.log(`  A: ...${JSON.stringify(result.a.slice(from, result.at + context))}`);
  console.log(`  B: ...${JSON.stringify(result.b.slice(from, result.at + context))}`);
  return false;
}

async function loadScript(path) {
  if (!path || !existsSync(path)) return null;
  return (await readFile(path, 'utf8'))
    .split('\n')
    .map((l) => l.replace(/;.*$/, '').trim())
    .filter((l) => l && !l.startsWith('#'));
}

/** Default probe when a game has no walkthrough: reflexive verbs only. */
const BASIC = ['look', 'inventory', 'north', 'south', 'east', 'west', 'up', 'down',
  'wait', 'examine me', 'score', 'look', 'diagnose'];

const args = process.argv.slice(2);
const flag = (n, d = null) => { const i = args.indexOf(n); return i >= 0 ? args[i + 1] : d; };

if (args.includes('--selftest')) {
  // The control that must fail. A harness that has only ever passed is
  // not evidence of anything.
  const game = GAMES.zork1;
  const seed = 0x2dba7;
  const commands = BASIC;
  let failures = 0;

  const a1 = await zmachineBackend(join(ROOT, game.story), makeRng(seed));
  const b1 = await zmachineBackend(join(ROOT, game.story), makeRng(seed));
  if (!report(await diff(a1, b1, commands), 'zmachine vs itself')) failures += 1;

  const a2 = await zmachineBackend(join(ROOT, game.story), makeRng(seed));
  const b2 = corruptedBackend(await zmachineBackend(join(ROOT, game.story), makeRng(seed)), 3);
  const corrupted = await diff(a2, b2, commands);
  if (corrupted.ok) {
    console.log('SELFTEST FAILED: the differ did not notice a corrupted backend');
    failures += 1;
  } else {
    console.log(`ok  corrupted backend detected at command ${corrupted.turns}`);
  }

  const a3 = await zmachineBackend(join(ROOT, game.story), makeRng(1));
  const b3 = await zmachineBackend(join(ROOT, game.story), makeRng(2));
  const seeds = await diff(a3, b3, ['n', 'n', 'e', 'open window', 'enter window', 'w',
    'take sword', 'move rug', 'open trap door', 'take lamp', 'turn on lamp', 'down', 'n',
    'kill thief with sword', 'kill thief with sword']);
  if (seeds.ok) {
    console.log('note: differing seeds produced identical play (no RANDOM on this path)');
  } else {
    console.log(`ok  differing seeds diverge at command ${seeds.turns} (RNG is live)`);
  }

  console.log(failures ? `\n${failures} selftest failure(s).` : '\nselftest passed.');
  process.exit(failures ? 1 : 0);
}

const name = flag('--game', 'zork1');
const game = GAMES[name];
if (!game) {
  console.error(`unknown game ${name}; known: ${Object.keys(GAMES).join(', ')}`);
  process.exit(2);
}
const seed = Number(flag('--seed', '186279')) >>> 0;
const commands = (await loadScript(flag('--script', game.script && join(ROOT, game.script))))
  ?? BASIC;

// Until the interpreter exists, both backends are the Z-machine: the
// harness proves itself and the game's determinism under a fixed seed.
const a = await zmachineBackend(join(ROOT, game.story), makeRng(seed));
const b = await zmachineBackend(join(ROOT, game.story), makeRng(seed));
const ok = report(await diff(a, b, commands), `${name} (${commands.length} commands)`);
process.exit(ok ? 0 : 1);
