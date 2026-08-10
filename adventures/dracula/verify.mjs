#!/usr/bin/env node
// Replay walkthrough.txt against dracula.z8 and check the ending.
//
// v8 story files do not populate the v3 status-line globals, so
// session.status is always null here: the score is asserted from the
// text of the SCORE command instead, which is the authoritative
// in-game report either way.
//
// Usage:
//   node verify.mjs              check against the frozen transcript
//   node verify.mjs --freeze     rewrite expected-transcript.txt
import { loadGame } from '../../src/zmachine.js';
import { readFileSync, writeFileSync, existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const HERE = dirname(fileURLToPath(import.meta.url));
const STORY = join(HERE, 'dracula.z8');
const WALK = join(HERE, 'walkthrough.txt');
const EXPECTED = join(HERE, 'expected-transcript.txt');
const FREEZE = process.argv.includes('--freeze');

const EXPECT_SCORE = 204;
const EXPECT_MAX = 210;

function commands(path) {
  return readFileSync(path, 'utf8')
    .split('\n')
    .map((l) => (l.trim().startsWith('#') ? '' : l.trim()))
    .filter(Boolean);
}

const fail = [];
function check(ok, msg) {
  if (!ok) fail.push(msg);
}

const session = await loadGame(STORY);
let out = await session.start();
const parts = [out];
for (const c of commands(WALK)) {
  if (session.ended) break;
  parts.push(`\n> ${c}\n`);
  parts.push(await session.send(c));
}
// The victory text ends with FINISH, which leaves the interpreter at the
// RESTART/RESTORE/QUIT prompt; SCORE is already printed by the outro.
const transcript = parts.join('');

if (FREEZE) {
  writeFileSync(EXPECTED, transcript);
  console.log(`froze ${EXPECTED} (${transcript.length} bytes)`);
  process.exit(0);
}

// --- content assertions (independent of the frozen transcript) ---
check(/\*\*\* You have won \*\*\*/.test(transcript), 'victory banner missing');
check(
  /the whole body crumbles into dust/.test(transcript),
  'the sunset kill did not fire',
);

const scores = [...transcript.matchAll(/Your score is (\d+) \(total of (\d+) points\)/g)];
check(scores.length > 0, 'no SCORE report in transcript');
if (scores.length) {
  const [, got, max] = scores[scores.length - 1];
  check(
    Number(got) === EXPECT_SCORE,
    `final score ${got}, expected ${EXPECT_SCORE}`,
  );
  check(Number(max) === EXPECT_MAX, `SCORE-MAX ${max}, expected ${EXPECT_MAX}`);
}

// every act header must have been narrated, in order
const headers = [
  'From the journal of Jonathan Harker',
  'From the journal of Mina Murray, Whitby, August',
  'From the diary of Dr. John Seward',
  'From the journal of Mina Harker, aboard the Orient Express',
  'From the memorandum of Abraham Van Helsing',
  'From the journal of Jonathan Harker, the sixth of November',
];
let cursor = 0;
for (const h of headers) {
  const at = transcript.indexOf(h, cursor);
  check(at >= 0, `journal header missing or out of order: "${h}"`);
  if (at >= 0) cursor = at;
}

// key puzzle beats
for (const [beat, re] of [
  ['mirror scene', /there is no one in it/],
  ['brides warded', /thrust a torch at three moths/],
  ['shovel blow', /gashing the forehead deep above the brows/],
  ['wall escape', /grass, and steep meadow/],
  ['Demeter log', /I am captain, and it is my duty to stay by my ship/],
  ['churchyard rescue', /two little red points on her throat/],
  ['Lucy saved', /The first gain is ours/],
  ['Renfield tier 1', /The blood is the life/],
  ['Carfax sanctified', /Twenty-nine boxes/],
  ['rats routed', /the terriers, professional, joyous/],
  ['Bloxam', /Nine big 'uns to a 'ouse off Piccadilly/],
  ['locksmith ruse', /as such things are rightly done/],
  ['Mina attacked', /Unclean! Unclean!/],
  ['river deduction', /as close to Dracula's castle as can be got by water/],
  ['holy circle', /I cannot,/],
  ['sisters staked', /crumbled into their native dust/],
  ['castle sealed', /never more can the Count enter there/],
]) {
  check(re.test(transcript), `beat missing: ${beat}`);
}

// parser health: no unresolved nouns or verbs anywhere in a clean run
for (const bad of [
  /You can't see any /,
  /That sentence isn't one I recognize/,
  /I don't know the word/,
  /You don't have that!/,
]) {
  const m = transcript.match(bad);
  check(!m, `parser failure in walkthrough: ${JSON.stringify(m && m[0])}`);
}

// --- frozen transcript diff ---
if (existsSync(EXPECTED)) {
  const want = readFileSync(EXPECTED, 'utf8');
  if (want !== transcript) {
    const w = want.split('\n');
    const g = transcript.split('\n');
    let i = 0;
    while (i < w.length && i < g.length && w[i] === g[i]) i++;
    fail.push(
      `transcript differs from expected-transcript.txt at line ${i + 1}\n` +
        `  expected: ${JSON.stringify(w[i] ?? '<eof>')}\n` +
        `  actual:   ${JSON.stringify(g[i] ?? '<eof>')}`,
    );
  }
} else {
  console.warn('note: no expected-transcript.txt; run with --freeze');
}

if (fail.length) {
  console.error('FAIL');
  for (const f of fail) console.error('  - ' + f);
  process.exit(1);
}
console.log(
  `PASS  score ${EXPECT_SCORE}/${EXPECT_MAX}, ` +
    `${commands(WALK).length} commands, ${transcript.length} bytes`,
);
