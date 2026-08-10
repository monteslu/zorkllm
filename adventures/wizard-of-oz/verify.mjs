#!/usr/bin/env node
// THE SILVER SHOES - acceptance test.
//
// Compiles nothing: it loads the built oz.z8, replays walkthrough.txt,
// and fails unless the Kansas homecoming plays and the final score is 250.
// If expected-transcript.txt exists, the transcript is diffed against it.
//
//   node adventures/wizard-of-oz/verify.mjs            # check
//   node adventures/wizard-of-oz/verify.mjs --freeze   # (re)write the transcript
//
// v8 story files do not populate the v3 status globals, so session.status
// is null: the score is asserted on the text of the SCORE line instead.

import { readFile, writeFile } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const here = dirname(fileURLToPath(import.meta.url));
const repo = join(here, '..', '..');

// Deterministic RNG: the game keeps RANDOM off the critical path, but the
// banter tables roll, and a frozen transcript needs the same rolls twice.
let seed = 0x2dba7 >>> 0;
Math.random = () => {
  seed = (seed + 0x6d2b79f5) >>> 0;
  let t = seed;
  t = Math.imul(t ^ (t >>> 15), t | 1);
  t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
};

const { loadGame } = await import(join(repo, 'src', 'zmachine.js'));

const freeze = process.argv.includes('--freeze');
const story = join(here, 'oz.z8');
const scriptFile = join(here, 'walkthrough.txt');
const frozen = join(here, 'expected-transcript.txt');

if (!existsSync(story)) {
  console.error(`FAIL: ${story} not built. Compile it first:
  node czil/dist/czil-compile.mjs adventures/wizard-of-oz/oz.zil \\
    -I zil/zork1 -I zil/engine-v8 -o adventures/wizard-of-oz/oz.z8`);
  process.exit(1);
}

const commands = (await readFile(scriptFile, 'utf8'))
  .split('\n')
  .map((l) => l.trim())
  .filter((l) => l && !l.startsWith('#'));

const session = await loadGame(story);
const timeout = setTimeout(() => {
  console.error('FAIL: timed out waiting for an input prompt');
  process.exit(3);
}, 60000);

const lines = [];
lines.push(await session.start());
let used = 0;
for (const cmd of commands) {
  if (session.ended) break;
  lines.push(`> ${cmd}`);
  lines.push(await session.send(cmd));
  used++;
}
// One last SCORE for the assertion, if the game is still accepting input.
if (!session.ended) {
  lines.push('> score');
  lines.push(await session.send('score'));
}
clearTimeout(timeout);

const transcript = lines.join('\n').replace(/[ \t]+$/gm, '') + '\n';
const problems = [];

if (used !== commands.length) {
  problems.push(
    `walkthrough stopped early: ${used} of ${commands.length} commands ran ` +
      `(the game ended at "${commands[used] ?? '?'}")`
  );
}

// 1. The homecoming actually played.
for (const needle of [
  "I'm so glad to be at home again!",
  '*** You have won ***',
]) {
  if (!transcript.includes(needle)) problems.push(`missing from transcript: ${needle}`);
}

// 2. The final score is 250 of 250. v8 has no status line; read the text.
const scores = [...transcript.matchAll(/Your score is (-?\d+) of a possible (\d+)/g)];
if (scores.length === 0) {
  problems.push('no SCORE output found in the transcript');
} else {
  const [, got, max] = scores[scores.length - 1];
  if (Number(max) !== 250) problems.push(`SCORE-MAX is ${max}, expected 250`);
  if (Number(got) !== 250) problems.push(`final score is ${got}, expected 250`);
}

// 3. FILM TRAP: 1900 book only. None of this may ever appear.
const filmisms = [
  /\bruby slipper/i,
  /\bbroomstick\b/i,
  /\bcrystal ball\b/i,
  /\bthere's no place like home\b/i,
  /\bwicked witch of the west is dead\b/i,
  /\bflying monkeys\b/i, // the book's are Winged Monkeys
  /\bglinda[^.\n]{0,40}\bnorth\b/i, // Glinda is the South in the book
];
for (const re of filmisms) {
  if (re.test(transcript)) problems.push(`film-only material in transcript: ${re}`);
}

// 4. Nothing crashed into a parser wall on the critical path.
for (const re of [/\[TIMEOUT/, /internal error/i, /Fatal/]) {
  if (re.test(transcript)) problems.push(`engine trouble in transcript: ${re}`);
}

if (freeze) {
  if (problems.length) {
    console.error('refusing to freeze a failing transcript:');
    for (const p of problems) console.error(`  - ${p}`);
    process.exit(1);
  }
  await writeFile(frozen, transcript);
  console.log(`froze ${frozen} (${transcript.split('\n').length} lines, ${used} commands)`);
  process.exit(0);
}

if (existsSync(frozen)) {
  const want = await readFile(frozen, 'utf8');
  if (want !== transcript) {
    const a = want.split('\n');
    const b = transcript.split('\n');
    const n = Math.max(a.length, b.length);
    let shown = 0;
    console.error('FAIL: transcript differs from expected-transcript.txt');
    for (let i = 0; i < n && shown < 12; i++) {
      if (a[i] !== b[i]) {
        console.error(`  line ${i + 1}:`);
        console.error(`    - ${a[i] ?? '(eof)'}`);
        console.error(`    + ${b[i] ?? '(eof)'}`);
        shown++;
      }
    }
    problems.push('transcript diff (see above)');
  }
}

// ---------------------------------------------------------------------
// The wanderer: a player who never guesses the intended opening must
// still reach Oz. Regression guard for the stranded-in-Kansas bug.
// ---------------------------------------------------------------------
const wanderFile = join(here, 'walkthrough-wanderer.txt');
let wanderTurns = 0;
if (existsSync(wanderFile)) {
  seed = 0x2dba7 >>> 0; // reset the RNG so this run is deterministic too
  const wcmds = (await readFile(wanderFile, 'utf8'))
    .split('\n')
    .map((l) => l.trim())
    .filter((l) => l && !l.startsWith('#'));

  const w = await loadGame(story);
  const wt = setTimeout(() => {
    console.error('FAIL: wanderer timed out waiting for an input prompt');
    process.exit(3);
  }, 60000);

  const wlines = [await w.start()];
  let reachedAt = -1;
  for (const cmd of wcmds) {
    if (w.ended) break;
    wlines.push(`> ${cmd}`);
    wlines.push(await w.send(cmd));
    wanderTurns++;
    if (reachedAt < 0 && /Munchkin Clearing/.test(wlines[wlines.length - 1])) {
      reachedAt = wanderTurns;
    }
  }
  if (!w.ended) {
    wlines.push(await w.send('score'));
  }
  clearTimeout(wt);
  const wtext = wlines.join('\n');

  if (reachedAt < 0) {
    problems.push(
      'WANDERER STRANDED: a player who never types the intended opening ' +
        `never reached Munchkin Clearing in ${wanderTurns} commands. ` +
        'The prologue must advance on its own.'
    );
  }
  // The wanderer must not be handed the scored deed for free.
  const wscore = [...wtext.matchAll(/Your score is (-?\d+) of a possible/g)];
  if (wscore.length) {
    const got = Number(wscore[wscore.length - 1][1]);
    if (got !== 0) {
      problems.push(
        `wanderer scored ${got}; the auto-advancing prologue must award ` +
          'nothing (closing the trap door yourself is what earns the 5).'
      );
    }
  }
  if (/You have died|\*\*\*\s*You have/.test(wtext)) {
    problems.push('wanderer reached an ending; the prologue must not kill or win');
  }
  // A player doing it properly must see no nudges: the storm-escalation
  // lines must be absent from the scored walkthrough above.
  for (const nudge of [
    'the wind gives a long low wail',
    'Toto scratches at the door',
    'Your eyes keep closing by themselves',
  ]) {
    if (transcript.includes(nudge)) {
      problems.push(`nudge leaked into the scored path: "${nudge}"`);
    }
  }
}

if (problems.length) {
  console.error('FAIL:');
  for (const p of problems) console.error(`  - ${p}`);
  process.exit(1);
}

console.log(
  `PASS: THE SILVER SHOES, ${used} commands, 250/250, home to Kansas.` +
    (wanderTurns ? ` Wanderer reaches Oz in ${wanderTurns} commands, scoring 0.` : '')
);
process.exit(0);
