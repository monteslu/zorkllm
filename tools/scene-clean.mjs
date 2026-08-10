#!/usr/bin/env node
/**
 * Reduce a room's description to what is visible in it.
 *
 * Room prose is written for a player who needs to navigate, so it carries
 * things a depiction cannot use: exits ("the road runs on to the west"),
 * sounds ("and groaning"), and second-person action ("Munchkins bow to
 * you"). A regex handles the clean cases and mangles the rest, because
 * the useless clause is often welded to a useful one inside a single
 * sentence.
 *
 * So this pass is a model, held to one rule: it may only DELETE and
 * REPHRASE. Every content noun in the output must already appear in the
 * input. That is checked mechanically afterwards, and any new noun is
 * reported rather than trusted - a cleanup step that can add things is
 * the exact failure the scene manifest exists to prevent.
 *
 * Usage:
 *   node tools/scene-clean.mjs <manifest.json> [--room <substring>] [-o out.json]
 *
 * Env: same provider config as the game client (ZORKLLM_API_URL / _MODEL /
 * _API_KEY, or OPENAI_API_KEY).
 */
import { readFileSync, writeFileSync } from 'node:fs';
import { resolveConfig, createClient } from '../src/providers.js';

const args = process.argv.slice(2);
const flag = (n) => { const i = args.indexOf(n); return i >= 0 ? args[i + 1] : null; };
const manifestPath = args.find((a) => !a.startsWith('-') && a.endsWith('.json'));
const only = flag('--room');
const outPath = flag('-o');

if (!manifestPath) {
  console.error('usage: scene-clean.mjs <manifest.json> [--room <substring>] [-o out.json]');
  process.exit(2);
}

const INSTRUCTION = `You prepare room descriptions from a text adventure for an illustrator.

Rewrite the description to contain ONLY what is physically visible in the room.

Remove:
- directions and exits ("the road runs on to the west", "back to the north")
- sounds, smells, and other non-visual detail ("and groaning")
- second person and the player ("bow to you", "you crouch")
- anything about what the player can or should do

Keep every visible thing, and its stated colour, condition and arrangement.

HARD RULE: introduce nothing. Every object, material, colour and creature in
your output must appear in the input. Do not add sky, weather, light, time of
day, or scenery of any kind. If the input does not mention it, it does not
exist. Prefer deleting words to inventing them.

Reply with the rewritten description only - one or two plain sentences, no
preamble, no quotes.`;

/** Content words that matter for the "introduced nothing" check. */
const STOP = new Set(`a an the and or but of in on at to from with without into over under
above below beside beyond across along around through between among near by for is are was
were be been being it its it's this that these those there here where when while as if then
than so very much many more most some any all each every no not only just still yet own same
such own up down out off again once about against during before after above below both few
other own too can will would could should may might must shall`.split(/\s+/));

const nouns = (text) => new Set(
  text.toLowerCase().replace(/[^a-z\s-]/g, ' ').split(/\s+/)
    .filter((w) => w.length > 3 && !STOP.has(w))
    .map((w) => w.replace(/(ing|ed|s)$/, '')),
);

const manifest = JSON.parse(readFileSync(manifestPath, 'utf8'));
const config = resolveConfig({ apiKey: process.env.OPENAI_API_KEY });
const llm = await createClient(config);
console.error(`cleaning with ${llm.describe()}`);

let flagged = 0;
for (const room of manifest.rooms) {
  if (only && !room.room.toLowerCase().includes(only.toLowerCase())) continue;
  if (!room.scenery || room.dark) continue;
  const reply = await llm.complete({
    system: INSTRUCTION,
    messages: [{ role: 'user', content: room.scenery }],
  });
  const cleaned = reply.trim().replace(/^["']|["']$/g, '');
  // The guard: anything in the output that was not in the input.
  const before = nouns(room.scenery);
  const added = [...nouns(cleaned)].filter((w) => !before.has(w));
  room.sceneryClean = cleaned;
  if (added.length) {
    room.introduced = added;
    flagged += 1;
  }
  console.error(`- ${room.room}${added.length ? `  INTRODUCED: ${added.join(', ')}` : ''}`);
}

const json = JSON.stringify(manifest, null, 2);
if (outPath) writeFileSync(outPath, json); else console.log(json);
console.error(flagged
  ? `\n${flagged} room(s) introduced words not in the source - review before use.`
  : '\nno room introduced anything new.');
