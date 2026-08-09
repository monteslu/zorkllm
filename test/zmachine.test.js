/**
 * Interpreter smoke tests against the real Zork I/II/III story files.
 * Run: node test/zmachine.test.js
 */
import { strict as assert } from 'node:assert';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import { unlink } from 'node:fs/promises';
import { loadGame } from '../src/zmachine.js';

const GAMES = join(dirname(fileURLToPath(import.meta.url)), '..', 'games');
let passed = 0;
function ok(label, cond, detail = '') {
  assert.ok(cond, `${label}${detail ? `\n--- got ---\n${detail}` : ''}`);
  passed++;
  console.log(`  ok - ${label}`);
}

// --- Zork I: boot, walkthrough opening, vocabulary, save/restore ---
{
  console.log('zork1:');
  const session = await loadGame(join(GAMES, 'zork1.z3'));

  ok('vocabulary extracted (~684 words)', session.vocabulary.length > 600 && session.vocabulary.length < 800);
  ok('vocabulary has "grue"', session.vocabulary.includes('grue'));
  ok('vocabulary has "lamp"', session.vocabulary.includes('lamp'));

  const opening = await session.start();
  ok('opening mentions West of House', opening.includes('West of House'), opening);
  ok('opening mentions the mailbox', opening.includes('mailbox'), opening);

  const open = await session.send('open mailbox');
  ok('mailbox contains leaflet', open.includes('leaflet'), open);

  const read = await session.send('read leaflet');
  ok('leaflet says WELCOME TO ZORK', read.includes('WELCOME TO ZORK'), read);

  // Control that must fail: gibberish must be rejected by the parser.
  const junk = await session.send('frobnicate the bazfoo');
  ok('control: parser rejects unknown word', /don't know the word/i.test(junk), junk);

  const south = await session.send('south');
  ok('south goes to South of House', south.includes('South of House'), south);

  // 4 commands sent but the gibberish control doesn't parse, so only 3 count -
  // matching the ZIL CLOCKER, which increments MOVES only on successful parses.
  ok('status line tracks moves', session.status && session.status.turns === 3
    && session.status.location === 'South of House', JSON.stringify(session.status));

  // Save, move, restore, verify position rolled back.
  session.saveFile = join(dirname(fileURLToPath(import.meta.url)), 'tmp-test.sav');
  const saved = await session.send('save');
  ok('save reports Ok', /ok/i.test(saved), saved);
  await session.send('east');
  const restored = await session.send('restore');
  ok('restore reports Ok', /ok/i.test(restored), restored);
  const look = await session.send('look');
  ok('restore rolled back to South of House', look.includes('South of House'), look);
  await unlink(session.saveFile).catch(() => {});
}

// --- Zork II / III: boot only ---
for (const [file, marker] of [
  ['zork2.z3', 'Inside the Barrow'],
  ['zork3.z3', 'Ending'],
]) {
  console.log(`${file}:`);
  const session = await loadGame(join(GAMES, file));
  const opening = await session.start();
  ok(`${file} boots with text`, opening.length > 100, opening.slice(0, 200));
  ok(`${file} vocabulary extracted`, session.vocabulary.length > 400);
  const out = await session.send('look');
  ok(`${file} responds to LOOK`, out.length > 20, out);
}

console.log(`\nzmachine tests: ${passed} passed`);
