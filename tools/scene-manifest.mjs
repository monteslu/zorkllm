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
const flag = (name) => {
  const i = args.indexOf(name);
  return i >= 0 ? args[i + 1] : null;
};
const outPath = flag('-o');
const stylePath = flag('--style');
const consumed = new Set();
for (const f of ['-o', '--style']) {
  const i = args.indexOf(f);
  if (i >= 0) { consumed.add(i); consumed.add(i + 1); }
}
const positional = args.filter((_, i) => !consumed.has(i));
const [storyPath, walkPath] = positional;

if (!storyPath) {
  console.error('usage: scene-manifest.mjs <story file> [walkthrough.txt] [-o out.json] [--style style.json]');
  process.exit(2);
}

/**
 * Optional per-game presentation config. Accuracy comes from the engine;
 * consistency has to be authored. A style file supplies the look that
 * every scene in this game shares, and the mood arc across the story:
 *
 *   {
 *     "style": "<one clause describing the medium and treatment>",
 *     "negative": ["no text", "no figures", ...],
 *     "acts": [
 *       {"name": "Kansas",  "untilTurn": 6,  "mood": "gray, flat, drained of colour"},
 *       {"name": "Munchkin","untilTurn": 40, "mood": "saturated, storybook, bright"}
 *     ]
 *   }
 *
 * Acts are matched by the turn a room was first seen, because visit order
 * is the one act signal a story file actually carries. Hand-editing a
 * room's act afterwards is expected and fine.
 */
const styleConfig = stylePath ? JSON.parse(readFileSync(stylePath, 'utf8')) : null;

/** @param {number} firstSeen */
function actFor(firstSeen) {
  if (!styleConfig?.acts?.length) return null;
  for (const act of styleConfig.acts) {
    if (firstSeen <= (act.untilTurn ?? Infinity)) return act;
  }
  return styleConfig.acts[styleConfig.acts.length - 1];
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
  const entry = rooms.get(room) ?? { room, firstSeen: turn, scenery: null, variants: [], occupants: [] };
  // Split the permanent room from whatever happens to be standing in it.
  // The first paragraph is the room's own description - the part that is
  // true whenever the player is here. Later paragraphs are contents and
  // wandering NPCs ("Toto is here, being a dog about it"), which change
  // constantly and would otherwise produce a near-duplicate variant on
  // every visit. A scene description wants the former; the latter is a
  // separate, optional layer.
  // The room's own LDESC is printed as one block, before any contents or
  // NPC lines. Everything after the first blank line - and every line
  // after a sentence about a person, animal or item - is transient: a
  // wandering companion, an idle bark ("Toto chases a butterfly and
  // loses"), a dropped object. Only the first block describes the place.
  const paragraphs = body.split(/\n\s*\n/).map((p) => p.trim()).filter(Boolean);
  const first = paragraphs[0] ?? body;
  const firstLines = first.split('\n');
  // Within the opening block, stop at the first line that announces
  // something present rather than describing the room itself.
  const PRESENCE = /^(there is|there are|on the |sitting|lying|.* is here\b|.* are here\b)/i;
  const sceneryLines = [];
  const spilled = [];
  for (const line of firstLines) {
    if (sceneryLines.length && PRESENCE.test(line.trim())) spilled.push(line.trim());
    else if (spilled.length) spilled.push(line.trim());
    else sceneryLines.push(line);
  }
  const scenery = sceneryLines.join('\n').trim() || first;
  const extras = [...spilled, ...paragraphs.slice(1)];
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
  /** Shared by every scene in this game; the thing that makes a set a set. */
  style: styleConfig?.style ?? null,
  negative: styleConfig?.negative ?? null,
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
    /** Turn this room was first entered; the basis for the act guess. */
    firstSeen: entry.firstSeen,
    /** Where this room falls in the story's mood arc. */
    act: actFor(entry.firstSeen)?.name ?? null,
    mood: actFor(entry.firstSeen)?.mood ?? null,
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
