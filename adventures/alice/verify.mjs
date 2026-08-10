#!/usr/bin/env node
// WONDERLAND acceptance test.
//
//   node adventures/alice/verify.mjs            # run + diff the transcript
//   node adventures/alice/verify.mjs --freeze   # re-record expected-transcript.txt
//
// Exits nonzero unless the walkthrough reaches the riverbank waking and
// SCORE reports 100 of 100. v8 story files do not populate the v3 status
// globals, so session.status is null and every assertion is made against
// the transcript text itself.

import { readFile, writeFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const here = dirname(fileURLToPath(import.meta.url));
const root = join(here, '..', '..');

// Deterministic RNG, matching czil/tests/play.mjs, so a game that does roll
// RANDOM off the critical path still produces a byte-identical transcript.
let seed = 0x2dba7 >>> 0;
Math.random = () => {
  seed = (seed + 0x6d2b79f5) >>> 0;
  let t = seed;
  t = Math.imul(t ^ (t >>> 15), t | 1);
  t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
};

const { loadGame } = await import(join(root, 'src', 'zmachine.js'));

const STORY = join(here, 'alice.z8');
const WALK = join(here, 'walkthrough.txt');
const EXPECTED = join(here, 'expected-transcript.txt');
const freeze = process.argv.includes('--freeze');

const commands = (await readFile(WALK, 'utf8'))
  .split('\n')
  .map((l) => l.trim())
  .filter((l) => l && !l.startsWith('#'));

const session = await loadGame(STORY);
const out = [];
const timeout = setTimeout(() => {
  console.error('FAIL: game never reached an input prompt (30s timeout)');
  process.exit(3);
}, 30000);

out.push(await session.start());
let executed = 0;
for (const cmd of commands) {
  if (session.ended) break;
  out.push(`> ${cmd}`);
  out.push(await session.send(cmd));
  executed++;
}
clearTimeout(timeout);

const transcript = out.join('\n');

if (freeze) {
  await writeFile(EXPECTED, transcript + '\n');
  console.log(`froze expected-transcript.txt (${executed} commands)`);
  process.exit(0);
}

const failures = [];

// 1. Every command must have been consumed.
if (executed !== commands.length) {
  failures.push(
    `only ${executed} of ${commands.length} commands ran (game ended early)`,
  );
}

// 2. The victory text: waking on the riverbank.
const victoryMarkers = [
  'only dead leaves',
  'Wake up, Alice dear',
  'such a curious dream',
  'a white rabbit had hurried by',
];
for (const m of victoryMarkers) {
  if (!transcript.includes(m)) failures.push(`victory text missing: ${m}`);
}

// 3. The score, asserted on SCORE output text (session.status is null on v8).
if (!/Your score is 100 of 100/.test(transcript)) {
  const seen = transcript.match(/Your score is (\d+) of (?:a possible )?100/g);
  failures.push(
    `final score is not 100/100 (saw: ${seen ? seen.join(', ') : 'no score line'})`,
  );
}
if (!transcript.includes('Quite Mad, Thank You')) {
  failures.push('final rank is not "Quite Mad, Thank You"');
}

// 4. No parser failures anywhere on the critical path.
const parserErrors = [
  "can't see any",
  "can't go that way",
  "can't go there without a vehicle",
  "You can't talk to",
  "don't have that",
  "in a way that I don't understand",
  'too many things',
  'There is nothing to fill it with',
  'You must tell me how to do that',
];
for (const e of parserErrors) {
  if (transcript.includes(e)) {
    const line = transcript.split('\n').find((l) => l.includes(e));
    failures.push(`parser failure on critical path: "${line.trim()}"`);
  }
}

// 5. Byte-for-byte diff against the frozen transcript.
let expected = null;
try {
  expected = await readFile(EXPECTED, 'utf8');
} catch {
  failures.push('expected-transcript.txt missing (run with --freeze)');
}
if (expected !== null) {
  const a = transcript.trimEnd().split('\n');
  const b = expected.trimEnd().split('\n');
  if (a.length !== b.length) {
    failures.push(`transcript length changed: ${a.length} lines vs ${b.length}`);
  }
  for (let i = 0; i < Math.min(a.length, b.length); i++) {
    if (a[i] !== b[i]) {
      failures.push(
        `transcript diverges at line ${i + 1}\n  expected: ${b[i]}\n  actual:   ${a[i]}`,
      );
      break;
    }
  }
}

if (failures.length) {
  console.error('FAIL');
  for (const f of failures) console.error('  - ' + f);
  process.exit(1);
}

console.log(`PASS: ${executed} commands, 100/100, Quite Mad, Thank You.`);
process.exit(0);
