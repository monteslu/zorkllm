#!/usr/bin/env node
/**
 * Build a scene manifest for a story file: one entry per reachable room,
 * carrying the room's identity and the exact prose a player sees on
 * arrival.
 *
 * The manifest is the authoritative description of what a room contains.
 * It is derived by walking the game with a walkthrough and capturing the
 * engine's own room text, never by reading the object tree directly -
 * that distinction is the whole point. The object tree lists everything
 * physically in a room including things flagged INVISIBLE (Zork's trap
 * door sits in the Living Room from turn one, hidden under the rug) and
 * things flagged NDESCBIT (present, but folded into the room prose rather
 * than listed). A description built from the tree therefore describes a
 * room the player cannot see yet, and spoils it. The engine's LOOK output
 * already applies both flags, so it is ground truth.
 *
 * Usage:
 *   node tools/scene-manifest.mjs <story.z3|.z8> [walkthrough.txt] [-o out.json]
 *
 * With a walkthrough, every room that playthrough reaches is captured, in
 * visit order. Without one, only the starting room is captured.
 *
 * Rooms whose state changes visibly (a rug moved aside, a door opened)
 * appear more than once: each distinct description of the same room is
 * recorded as a variant, so a later stage can pair "before" and "after".
 */
import { readFileSync, writeFileSync } from 'node:fs';
import { loadGame } from '../src/zmachine.js';

const args = process.argv.slice(2);
const outIdx = args.indexOf('-o');
const outPath = outIdx >= 0 ? args[outIdx + 1] : null;
const positional = args.filter((a, i) => a !== '-o' && i !== outIdx + 1);
const [storyPath, walkPath] = positional;

if (!storyPath) {
  console.error('usage: scene-manifest.mjs <story file> [walkthrough.txt] [-o out.json]');
  process.exit(2);
}

/** Strip the room name header and any trailing prompt noise. */
function bodyOf(text, roomName) {
  const lines = text.split('\n').map((l) => l.trimEnd());
  const start = lines[0]?.trim() === roomName ? 1 : 0;
  return lines.slice(start).join('\n').trim();
}

/** A room is dark when the engine says so; art for these is not derivable. */
const DARK = /pitch black|it is dark|grue/i;

const session = await loadGame(storyPath);
const opening = await session.start();

/** @type {Map<string, {room: string, variants: Array<{turn: number, text: string, dark: boolean}>}>} */
const rooms = new Map();
let turn = 0;

function record(text) {
  const room = session.status?.location;
  if (!room) return;
  // Only text that actually re-describes the room counts. An action's
  // response ("Taken.", "Time passes...") is about the verb, not the
  // place, and would otherwise be captured as if it were scenery.
  const lines = text.split('\n').map((l) => l.trim());
  if (lines[0] !== room) return;
  const body = bodyOf(text, room);
  if (!body) return;
  const entry = rooms.get(room) ?? { room, scenery: null, variants: [], occupants: [] };
  // Split the permanent room from whatever happens to be standing in it.
  // The first paragraph is the room's own description - the part that is
  // true whenever the player is here. Later paragraphs are contents and
  // wandering NPCs ("Toto is here, being a dog about it"), which change
  // constantly and would otherwise produce a near-duplicate variant on
  // every visit. A scene description wants the former; the latter is a
  // separate, optional layer.
  const paragraphs = body.split(/\n\s*\n/).map((p) => p.trim()).filter(Boolean);
  const scenery = paragraphs[0] ?? body;
  const extras = paragraphs.slice(1);
  entry.scenery ??= scenery;
  if (scenery !== entry.scenery && !entry.variants.some((v) => v.text === scenery)) {
    // A genuinely different description of the same place: a state change
    // worth its own image (rug moved aside, trap door revealed).
    entry.variants.push({ turn, text: scenery, dark: DARK.test(scenery) });
  }
  for (const line of extras) {
    if (!entry.occupants.includes(line)) entry.occupants.push(line);
  }
  rooms.set(room, entry);
}

record(opening);

if (walkPath) {
  const commands = readFileSync(walkPath, 'utf8')
    .split('\n')
    .map((l) => l.replace(/;.*$/, '').trim())
    .filter((l) => l && !l.startsWith('#'));
  for (const command of commands) {
    if (session.ended) break;
    turn += 1;
    const output = await session.send(command);
    record(output);
    // A LOOK after movement catches rooms whose arrival text is terse.
    if (/^(n|s|e|w|ne|nw|se|sw|u|d|north|south|east|west|up|down|in|out|enter|exit)$/i.test(command)) {
      record(await session.send('look'));
    }
  }
}

const manifest = {
  story: storyPath.split('/').pop(),
  version: session.version,
  rooms: [...rooms.values()].map((entry, index) => ({
    id: index + 1,
    room: entry.room,
    /** The room as it always is: the scene to depict. */
    scenery: entry.scenery,
    dark: DARK.test(entry.scenery ?? ''),
    /** Alternate states of the same room (revealed passages, opened doors). */
    variants: entry.variants,
    /** Things seen standing here at some point - people, animals, items. */
    occupants: entry.occupants,
  })),
};

const json = JSON.stringify(manifest, null, 2);
if (outPath) {
  writeFileSync(outPath, json);
  const variants = manifest.rooms.reduce((n, r) => n + r.variants.length, 0);
  const dark = manifest.rooms.filter((r) => r.dark).length;
  console.log(`${manifest.rooms.length} rooms (${dark} dark), ${variants} alternate states -> ${outPath}`);
} else {
  console.log(json);
}
