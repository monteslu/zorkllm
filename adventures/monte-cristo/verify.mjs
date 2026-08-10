#!/usr/bin/env node
// Acceptance test for THE COUNT OF MONTE CRISTO.
//
//   node verify.mjs                 # walkthrough must reach 400 and win
//   node verify.mjs --write         # (re)freeze expected-transcript.txt
//
// Feeds walkthrough.txt to cristo.z8 through zorkllm's Z-machine, captures
// the transcript, and fails unless the victory text appears and SCORE
// reports 400 of 400. v8 story files do not populate the v3 status-line
// globals, so session.status is null and every assertion is made against
// the game's own printed output. When a frozen transcript exists the run
// is also diffed against it line for line.
import { readFile, writeFile } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

// Fixed RNG: the critical path is deterministic by design, but the engine
// still rolls dice for idle flavor, and a frozen transcript has to match.
let seed = 0x2dba7 >>> 0;
Math.random = () => {
  seed = (seed + 0x6d2b79f5) >>> 0;
  let t = seed;
  t = Math.imul(t ^ (t >>> 15), t | 1);
  t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
};

const here = dirname(fileURLToPath(import.meta.url));
const STORY = join(here, 'cristo.z8');
const SCRIPT = join(here, 'walkthrough.txt');
const FROZEN = join(here, 'expected-transcript.txt');
const write = process.argv.includes('--write');

const { loadGame } = await import(join(here, '..', '..', 'src', 'zmachine.js'));

if (!existsSync(STORY)) {
  console.error(`missing ${STORY} - build it first:
  node ../../czil/dist/czil-compile.mjs cristo.zil \\
    -I ../../zil/zork1 -I ../../zil/engine-v8 -o cristo.z8`);
  process.exit(2);
}

const commands = (await readFile(SCRIPT, 'utf8'))
  .split('\n')
  .map((l) => l.trim())
  .filter((l) => l && !l.startsWith('#'));

const session = await loadGame(STORY);
const lines = [];
const guard = setTimeout(() => {
  console.error('[TIMEOUT: the game never came back to a prompt]');
  process.exit(3);
}, 60000);

lines.push(await session.start());
for (const cmd of commands) {
  if (session.ended) break;
  lines.push(`> ${cmd}`);
  lines.push(await session.send(cmd));
}
clearTimeout(guard);

const transcript = lines.join('\n').replace(/[ \t]+$/gm, '') + '\n';

if (write) {
  await writeFile(FROZEN, transcript);
  console.log(`froze ${FROZEN} (${transcript.split('\n').length} lines)`);
  process.exit(0);
}

const failures = [];

// 1. The victory text. "Wait and hope" is the novel's last word and the
//    game's; if it is not printed the run did not finish the story.
if (!/Wait, and hope\./.test(transcript)) {
  failures.push('victory text missing: no "Wait, and hope."');
}
if (!/\*\*\*\*  You have won  \*\*\*\*/.test(transcript)) {
  failures.push('win banner missing');
}
if (/\*\*\*\*  You have died  \*\*\*\*/.test(transcript)) {
  failures.push('the walkthrough died somewhere');
}

// 2. The score, from the game's own SCORE output. status is null on v8.
const score = transcript.match(/Your score is (\d+) of a possible (\d+)/);
if (!score) {
  failures.push('no SCORE line in the transcript');
} else {
  if (score[1] !== '400') failures.push(`score is ${score[1]}, expected 400`);
  if (score[2] !== '400') failures.push(`maximum is ${score[2]}, expected 400`);
}
if (!/Your rank: Wait and Hope\./.test(transcript)) {
  failures.push('final rank is not "Wait and Hope"');
}

// 3. Parser failures anywhere on the critical path mean the walkthrough
//    has drifted from the game even if the score still lands.
const parserNoise = [
  /You can't see any /,
  /I don't know the word/,
  /You used the word .* in a way that I don't understand/,
  /There seems to be a noun missing/,
  /Which .* do you mean/,
  /That sentence isn't one I recognize/,
];
for (const [i, line] of transcript.split('\n').entries()) {
  for (const re of parserNoise) {
    if (re.test(line)) failures.push(`parser failure at line ${i + 1}: ${line}`);
  }
}

// 4. Frozen-transcript diff, once one exists.
if (existsSync(FROZEN)) {
  const expected = await readFile(FROZEN, 'utf8');
  if (expected !== transcript) {
    const a = expected.split('\n');
    const b = transcript.split('\n');
    const n = Math.max(a.length, b.length);
    for (let i = 0; i < n; i++) {
      if (a[i] !== b[i]) {
        failures.push(
          `transcript diverges at line ${i + 1}\n  expected: ${JSON.stringify(a[i])}\n  actual:   ${JSON.stringify(b[i])}`,
        );
        break;
      }
    }
    if (a.length !== b.length) {
      failures.push(`transcript length ${b.length}, expected ${a.length}`);
    }
  }
} else {
  console.log(`note: no ${FROZEN} yet - run with --write to freeze it`);
}

// ---------------------------------------------------------------------
// 5. The wanderer test.
//
// The walkthrough above is written by whoever built the game, so passing
// it only proves the game is completable by someone who already knows
// the answer. This game scored 400/400 while a real player was stranded
// on the Pharaon at turn three, having typed eight reasonable things and
// found no way off the deck.
//
// walkthrough-wanderer.txt contains none of the intended solution. It
// opens with that player's session verbatim and continues with junk,
// scenery and unparseable input. It must still reach Marseilles - not
// because the script knows the trick, but because the room now says
// which way the quay is and every refusal names the job that is left.
// ---------------------------------------------------------------------
const WANDER = join(here, 'walkthrough-wanderer.txt');
let wanderNote = '';

if (existsSync(WANDER)) {
  seed = 0x2dba7 >>> 0; // reset the RNG: each run must be deterministic
  const wcmds = (await readFile(WANDER, 'utf8'))
    .split('\n')
    .map((l) => l.trim())
    .filter((l) => l && !l.startsWith('#'));

  const w = await loadGame(STORY);
  const wguard = setTimeout(() => {
    console.error('[TIMEOUT: wanderer never came back to a prompt]');
    process.exit(3);
  }, 60000);

  const wlines = [await w.start()];
  let ashoreAt = -1;
  let turns = 0;
  for (const cmd of wcmds) {
    if (w.ended) break;
    wlines.push(`> ${cmd}`);
    wlines.push(await w.send(cmd));
    turns++;
    if (ashoreAt < 0 && /Marseilles Quay/.test(wlines[wlines.length - 1])) {
      ashoreAt = turns;
    }
  }
  if (!w.ended) wlines.push(await w.send('score'));
  clearTimeout(wguard);
  const wtext = wlines.join('\n');

  const rejected = (wtext.match(
    /I don't know the word|There was no verb|isn't one I recognize|not clear what you|used the word/g,
  ) || []).length;

  if (ashoreAt < 0) {
    failures.push(
      `WANDERER STRANDED: never reached Marseilles Quay in ${turns} inputs ` +
        `(${rejected} rejected by the parser). A player who does not guess ` +
        'FURL SAILS must still get off the ship.',
    );
  } else if (turns - ashoreAt < 3) {
    // Passing on the last input is a coincidence, not a test.
    failures.push(
      `wanderer reached Marseilles at input ${ashoreAt} of ${turns} — ` +
        'fewer than 3 inputs of headroom. Lengthen the test.',
    );
  }

  // The wanderer never furls anything on purpose, so it must not have
  // been handed the docking point. If it has, the script has drifted
  // into being a second walkthrough and stops testing what it is for.
  const wscore = wtext.match(/Your score is (\d+) of/);
  if (wscore && Number(wscore[1]) > 15) {
    failures.push(
      `wanderer scored ${wscore[1]}; it is meant to blunder, not to play. ` +
        'Check the script has not acquired the intended solution.',
    );
  }
  if (/\*\*\*\*  You have died  \*\*\*\*/.test(wtext)) {
    failures.push('wanderer died; Act I is supposed to be deathless');
  }

  // Being told to go somewhere the parser cannot hear is the second half
  // of the original bug, and it is worth asserting directly.
  if (/Come to the counting-house/.test(wtext)
      && /go to counting house[\s\S]{0,80}(isn't one I recognize|don't know the word)/i.test(wtext)) {
    failures.push(
      'Morrel directs the player to the counting-house in words the ' +
        'parser rejects — the original unspeakable-destination bug.',
    );
  }

  wanderNote = `, wanderer ashore at input ${ashoreAt}/${turns} (${rejected} rejected)`;
}

if (failures.length) {
  console.error('FAIL');
  for (const f of failures) console.error(`  - ${f}`);
  process.exit(1);
}

console.log(
  `PASS  400/400 in ${commands.length} commands, victory text intact${wanderNote}`,
);
