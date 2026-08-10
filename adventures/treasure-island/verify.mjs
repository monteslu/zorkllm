#!/usr/bin/env node
// Acceptance test for TREASURE ISLAND.
//
//   node verify.mjs            # both paths, diffed against the frozen transcripts
//   node verify.mjs --bless    # re-freeze the transcripts from the current build
//
// Each run loads treasure.z8, feeds a walkthrough line by line, and checks
// three things: the victory banner appears, the final SCORE line reports the
// score the design promises, and the transcript matches the frozen copy
// byte for byte. Exits nonzero on any failure.
//
// v8 story files do not populate the v3 status globals, so session.status is
// null - every assertion here reads the text of the SCORE command instead.

import { readFile, writeFile } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const here = dirname(fileURLToPath(import.meta.url));
const repo = join(here, '..', '..');
const GAME = join(here, 'treasure.z8');

// Deterministic RNG: the engine's PICK-ONE and combat tables must roll the
// same way on every run or the frozen transcript is worthless.
let seed = 0x2dba7 >>> 0;
Math.random = () => {
  seed = (seed + 0x6d2b79f5) >>> 0;
  let t = seed;
  t = Math.imul(t ^ (t >>> 15), t | 1);
  t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
};

const { loadGame } = await import(join(repo, 'src', 'zmachine.js'));

const RUNS = [
  {
    name: 'full',
    script: join(here, 'walkthrough.txt'),
    frozen: join(here, 'expected-transcript.txt'),
    score: 350,
    rank: "Gentleman o' Fortune",
  },
  {
    name: 'minimal',
    script: join(here, 'walkthrough-minimal.txt'),
    frozen: join(here, 'expected-transcript-minimal.txt'),
    score: 325,
    rank: "Cap'n",
  },
  // The wanderer tests. A walkthrough is written by whoever built the game
  // and only proves it is completable by someone who already knows the
  // answer. These two prove a LOST player survives Act I - the act with the
  // countdown - and reaches the squire's hall on the strength of the game's
  // own escalating hints. They are not expected to win, or to score well;
  // they are expected not to die.
  {
    name: 'wanderer',
    script: join(here, 'walkthrough-wanderer.txt'),
    survives: "Squire's Hall",
  },
  {
    name: 'wanderer-llm',
    script: join(here, 'walkthrough-wanderer-llm.txt'),
    survives: "Squire's Hall",
  },
];

const bless = process.argv.includes('--bless');
let failures = 0;

function fail(run, msg) {
  console.error(`FAIL [${run.name}] ${msg}`);
  failures++;
}

async function play(run) {
  const commands = (await readFile(run.script, 'utf8'))
    .split('\n')
    .map((l) => l.trim())
    .filter((l) => l && !l.startsWith('#'));

  const session = await loadGame(GAME);
  const out = [];
  out.push(await session.start());
  for (const cmd of commands) {
    if (session.ended) break;
    out.push(`> ${cmd}`);
    out.push(await session.send(cmd));
  }
  return { transcript: out.join('\n').replace(/[ \t]+$/gm, '') + '\n', commands };
}

for (const run of RUNS) {
  if (!existsSync(run.script)) {
    fail(run, `missing walkthrough ${run.script}`);
    continue;
  }
  const { transcript, commands } = await play(run);

  // --- wanderer runs: survival, not victory ---
  if (run.survives) {
    if (transcript.includes('****  You have died  ****')) {
      fail(run, 'a lost player died in Act I - the countdown is too tight '
        + 'or the hints do not land in time');
    }
    if (transcript.includes('****  Your adventure is over  ****')) {
      fail(run, 'a lost player lost the packet to the raid');
    }
    if (!transcript.includes(run.survives)) {
      fail(run, `never reached ${run.survives}`);
    }
    // A wanderer must NOT accidentally win: if they do, this file has
    // stopped being a test of the game's forgiveness and become a second
    // walkthrough.
    if (transcript.includes('****  You have won  ****')) {
      fail(run, 'the wanderer won the game - it is no longer a wanderer test');
    }
    if (!failures) {
      const rejects = (transcript.match(
        /I don't know the word|There was no verb|not clear what you're referring/g,
      ) ?? []).length;
      console.log(
        `ok [${run.name}] ${commands.length} inputs (${rejects} unparsed), `
        + `survived Act I to ${run.survives}`,
      );
    }
    continue;
  }

  // 1. the game was actually won
  if (!transcript.includes('****  You have won  ****')) {
    fail(run, 'victory banner never appeared');
  }

  // 2. the score the design promises, read off the SCORE text (v8 has no
  //    status line, so this is the only trustworthy source)
  const scores = [...transcript.matchAll(
    /Your score is (\d+) of a possible (\d+)/g,
  )];
  if (scores.length === 0) {
    fail(run, 'no SCORE output found in the transcript');
  } else {
    const [, got, max] = scores[scores.length - 1];
    if (Number(max) !== 350) fail(run, `SCORE-MAX is ${max}, expected 350`);
    if (Number(got) !== run.score) {
      fail(run, `final score ${got}, expected ${run.score}`);
    }
  }

  // 3. the rank ladder still lines up with the score
  if (!transcript.includes(`That rates you: ${run.rank}.`)) {
    fail(run, `rank "${run.rank}" not reported`);
  }

  // 4. nothing on the winning path stranded the player: no parser failure
  //    should appear on a path that is supposed to work start to finish
  const stumbles = [
    "You can't see any",
    "You can't go that way",
    'There was no verb',
    "I don't know the word",
    "It's not clear what you're referring to",
    "You don't have that",
    'What a loony',
    'You must supply a verb',
  ].filter((s) => transcript.includes(s));
  if (stumbles.length) {
    fail(run, `walkthrough hits parser refusals: ${stumbles.join(' | ')}`);
  }

  // 5. frozen transcript diff
  if (bless) {
    await writeFile(run.frozen, transcript);
    console.log(`blessed [${run.name}] ${run.frozen} (${commands.length} commands)`);
    continue;
  }
  if (!existsSync(run.frozen)) {
    fail(run, `no frozen transcript at ${run.frozen} - run with --bless`);
  } else {
    const want = await readFile(run.frozen, 'utf8');
    if (want !== transcript) {
      const a = want.split('\n');
      const b = transcript.split('\n');
      let i = 0;
      while (i < a.length && i < b.length && a[i] === b[i]) i++;
      fail(run, `transcript diverges from the frozen copy at line ${i + 1}`);
      console.error(`  frozen:  ${JSON.stringify(a[i] ?? '<eof>')}`);
      console.error(`  current: ${JSON.stringify(b[i] ?? '<eof>')}`);
    }
  }

  if (!failures) {
    console.log(
      `ok [${run.name}] ${commands.length} commands, ${run.score}/350, ${run.rank}`,
    );
  }
}

if (failures) {
  console.error(`\n${failures} failure(s).`);
  process.exit(1);
}
console.log('\nTreasure Island: all checks passed.');
