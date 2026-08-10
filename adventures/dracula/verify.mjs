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
const WANDERER = process.argv.includes('--wanderer');

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

// --- wanderer mode -------------------------------------------------
// The walkthrough proves the game is completable by someone who already
// knows the answer; it cannot prove anything about a player who does
// not. This mode replays junk and half-English and asserts the three
// properties a lost player actually depends on:
//
//   1. no room they reach leaves them silently stuck (LOOK always names
//      a way out, or explicitly says why there is none),
//   2. junk never crashes the parser or corrupts act state,
//   3. if the way out has closed, the game SAYS so rather than going
//      quiet -- Harker's escape is a real puzzle and a wanderer may well
//      fail it, but failing is only fair if the game admits it.
//
// Note on pacing: the Z-machine clock advances only on a SUCCESSFUL
// parse (CLOCKER runs from MAIN-LOOP under `,P-WON`), so a rejected
// command ticks nothing and neither M-BEG nor M-END fires. A wandering
// player therefore experiences every timed beat at a fraction of the
// clean transcript's rate. Act I is driven by SLEEP rather than a turn
// counter, which is what makes it safe.
if (WANDERER) {
  const WALK_W = join(HERE, 'walkthrough-wanderer.txt');
  const s = await loadGame(STORY);
  const chunks = [await s.start()];
  for (const c of commands(WALK_W)) {
    if (s.ended) break;
    chunks.push(`\n> ${c}\n`);
    chunks.push(await s.send(c));
  }
  const tw = chunks.join('');

  check(!s.ended, 'wanderer died or the game ended during the junk run');

  // Every room the wanderer entered must name a way out on sight. A room
  // header is a line that is exactly a known room name; the text under it
  // must contain a direction.
  const DIRECTION =
    /\b(north|south|east|west|up|down|in|out|inward|outward|northwest|northeast|southwest|southeast)\b/i;
  const NO_EXIT_BY_DESIGN = [
    // Rooms that deliberately state there is nowhere to go. That is an
    // answer, not a silence, so it satisfies the property.
    /nowhere to go/i,
    /only news to wait for/i,
  ];
  const blocks = tw.split(/\n(?=[A-Z])/);
  for (const b of blocks) {
    const lines = b.split('\n');
    const head = lines[0]?.trim();
    // A room header is short, has no sentence punctuation, and is not a
    // list header like "You are carrying:".
    if (!head || head.length > 40) continue;
    if (!/^[A-Z][^.!?:]*$/.test(head)) continue;
    if (/^(You|The travelling|There|On |A |An )/.test(head)) continue;
    const body = lines.slice(1).join(' ');
    if (!body.trim()) continue;
    if (DIRECTION.test(body) || DIRECTION.test(head)) continue;
    if (NO_EXIT_BY_DESIGN.some((r) => r.test(body))) continue;
    if (/pitch black|too dark/i.test(body)) continue;
    // Only complain about text that actually looks like a room
    // description rather than a scene beat.
    if (body.length > 60 && !/"/.test(body)) {
      check(false, `wanderer: room "${head}" names no way out: ${body.slice(0, 70)}`);
    }
  }

  // Junk must never produce an interpreter-level failure.
  for (const bad of [/\[Fatal/i, /internal error/i, /\bundefined\b/]) {
    check(!bad.test(tw), `wanderer: interpreter failure ${bad}`);
  }

  // The guard against the early escape must EXPLAIN itself, not just
  // refuse. This is the specific thing that strands a wandering player.
  if (/Not while Mina waits/.test(tw)) {
    check(
      /Szgany are still in the courtyard|by daylight|courtyard empty/.test(tw),
      'wanderer: the ledge refused the climb without saying what to wait for',
    );
  }

  if (fail.length) {
    console.error('FAIL (wanderer)');
    for (const f of fail) console.error('  - ' + f);
    process.exit(1);
  }
  console.log(`PASS (wanderer)  ${commands(WALK_W).length} junk commands, survived, no silent dead ends`);
  process.exit(0);
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
