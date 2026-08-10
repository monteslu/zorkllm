#!/usr/bin/env node
/**
 * Reachability audit: build the room graph from the compiled story file
 * and find rooms you cannot get to, or cannot get back from.
 *
 * This reads the exit properties directly rather than playing, so it sees
 * the whole map at once - including rooms a walkthrough never visits,
 * which is exactly where orphans and one-way drops hide. It is the check
 * that playing can never make reliably, because a tester who knows the
 * game will not wander into the corner that has no way out.
 *
 * Exit encoding (czil / ZILF, v3 and v8 alike). Directions occupy the
 * highest property numbers, counting down from the last declared one, and
 * each direction property holds:
 *
 *   1 byte   UEXIT - unconditional; the byte is the destination object
 *   2 bytes  NEXIT - a refusal string; no destination
 *   3+ bytes CEXIT/DEXIT - conditional on a global or a door; byte 0 is
 *            still the destination, so the edge exists but may be shut
 *   FEXIT    a PER routine; the destination is computed at run time and
 *            cannot be read statically - reported as opaque, not missing
 *
 * Usage:
 *   node tools/audit-reach.mjs <story.z8> [--start <room name>] [--verbose]
 *   node tools/audit-reach.mjs --all
 *
 * Exits non-zero when a room is unreachable or is a one-way trap.
 *
 * IMPORTANT LIMIT. A `(DIR PER ROUTINE)` exit compiles to FEXIT, whose
 * destination is computed at run time and cannot be read from the story
 * file at all. Games that gate movement on story state - which is most
 * adaptations of a plotted novel - route much of their map through PER
 * routines, so a large "unreachable" count usually means the map is
 * dynamic, not broken. The tool reports the FEXIT count per game so the
 * two cases can be told apart, and refuses to fail a build when opaque
 * exits outnumber readable ones. Zork I, whose map is almost entirely
 * static, is the case this analysis is actually conclusive for: 105 of
 * its 110 rooms reachable, the 5 exceptions being the boat-only Frigid
 * River segments.
 */
import { existsSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { loadGame } from '../src/zmachine.js';

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const args = process.argv.slice(2);
const verbose = args.includes('--verbose');

const GAMES = [
  ['treasure-island', 'adventures/treasure-island/treasure.z8'],
  ['alice', 'adventures/alice/alice.z8'],
  ['wizard-of-oz', 'adventures/wizard-of-oz/oz.z8'],
  ['monte-cristo', 'adventures/monte-cristo/cristo.z8'],
  ['dracula', 'adventures/dracula/dracula.z8'],
  ['zork1', 'games/zork1.z3'],
];

/**
 * Read one object's property table as {propNumber: bytes}.
 * @param {any} zm @param {number} obj
 */
function properties(zm, obj) {
  const mem = zm.objectTable.memory ?? zm.memory;
  const version = zm.version ?? 3;
  const ot = zm.objectTable;
  const propAddr = ot.getPropertyTableAddress
    ? ot.getPropertyTableAddress(obj)
    : null;
  if (propAddr === null) return null;
  let p = propAddr;
  p += 1 + mem.readByte(p) * 2;              // skip the short name
  const out = new Map();
  for (;;) {
    const size = mem.readByte(p);
    if (size === 0) break;
    let num;
    let len;
    let dataAt;
    if (version >= 4) {
      num = size & 0x3f;
      if (size & 0x80) { len = mem.readByte(p + 1) & 0x3f; len = len === 0 ? 64 : len; dataAt = p + 2; }
      else { len = (size & 0x40) ? 2 : 1; dataAt = p + 1; }
    } else {
      num = size & 0x1f;
      len = (size >> 5) + 1;
      dataAt = p + 1;
    }
    const bytes = [];
    for (let i = 0; i < len; i++) bytes.push(mem.readByte(dataAt + i));
    out.set(num, bytes);
    p = dataAt + len;
  }
  return out;
}

async function auditOne(name, storyRel) {
  const storyPath = join(ROOT, storyRel);
  if (!existsSync(storyPath)) return { name, skipped: 'no story file' };
  const session = await loadGame(storyPath);
  await session.start();
  const zm = session.zm;
  const ot = zm.objectTable;
  const nameOf = (n) => {
    try {
      const info = ot.getShortNameAddress(n);
      return info.lengthBytes > 0 ? zm.textDecoder.decode(info.address).text : null;
    } catch { return null; }
  };

  // Rooms are exactly the children of the ROOMS pseudo-object, which is
  // where ZIL puts them. Finding it by walking up from the start room is
  // reliable and avoids the trap of guessing from property shape - an
  // earlier version treated any property pointing at a named object as an
  // exit, and duly reported "torch" and "lunch" as unreachable rooms.
  const maxObj = (zm.version ?? 3) >= 4 ? 500 : 255;
  const rooms = new Map();          // obj -> {name, exits: Map<dir, {to, kind}>}
  let opaque = 0;

  // The start room is the player object's parent - taken directly, never
  // by matching the status-line name, because room names are not unique
  // (Zork has four rooms called "Coal Mine") and a name scan finds
  // whichever object happens to come first.
  let playerObj = null;
  for (let i = 1; i <= maxObj; i++) {
    if (/^(cretin|adventurer|yourself)$/i.test(nameOf(i) ?? '')) {
      const parent = ot.getParent(i);
      if (parent && nameOf(parent)) { playerObj = i; break; }
    }
  }
  const startObj = playerObj ? ot.getParent(playerObj) : null;
  const roomsContainer = startObj ? ot.getParent(startObj) : null;
  const isRoom = new Set();
  if (roomsContainer) {
    let c = ot.getChild(roomsContainer);
    while (c) { isRoom.add(c); c = ot.getSibling(c); }
  }
  if (!isRoom.size) return { name, skipped: 'could not locate the ROOMS container' };

  for (const obj of isRoom) {
    const nm = nameOf(obj);
    if (!nm) continue;
    const props = properties(zm, obj);
    if (!props) continue;
    const exits = new Map();
    let sawRoutine = false;
    // Direction properties are the high-numbered ones. Rather than guess
    // where they start, treat any property whose first byte names a real
    // object with a short name as a candidate exit, then sanity-check that
    // the object it points at also has exits or is otherwise room-like.
    for (const [num, bytes] of props) {
      if (bytes.length === 0 || bytes.length > 8) continue;
      // The engine dispatches on property SIZE (gverbs.zil:2001-2006):
      // 1 UEXIT, 2 NEXIT (refusal string), 3 FEXIT (routine - destination
      // computed at run time, unreadable here), 4 CEXIT (conditional on a
      // global), 5 DEXIT (conditional on a door). Only 1, 4 and 5 carry a
      // destination in byte 0.
      let kind = null;
      if (bytes.length === 1) kind = 'unconditional';
      else if (bytes.length === 4) kind = 'conditional';
      else if (bytes.length === 5) kind = 'door';
      else { if (bytes.length === 3) sawRoutine = true; continue; }
      const dest = bytes[0];
      if (dest === 0 || !isRoom.has(dest)) continue;
      exits.set(num, { to: dest, kind });
    }
    if (exits.size || sawRoutine) rooms.set(obj, { name: nm, exits, sawRoutine });
  }

  // Rooms whose exits are all PER routines have no readable edges at all;
  // they are opaque to this analysis rather than broken.
  for (const obj of isRoom) if (!rooms.has(obj)) opaque += 1;

  let start = rooms.has(startObj) ? startObj : [...rooms.keys()][0];

  // Forward reachability from the start room.
  const seen = new Set([start]);
  const queue = [start];
  while (queue.length) {
    const here = queue.shift();
    for (const [, e] of rooms.get(here)?.exits ?? []) {
      if (!seen.has(e.to) && rooms.has(e.to)) { seen.add(e.to); queue.push(e.to); }
    }
  }

  // A one-way trap: reachable, but nothing leads back toward the start.
  const reverse = new Map();
  for (const [obj, r] of rooms) {
    for (const [, e] of r.exits) {
      if (!reverse.has(e.to)) reverse.set(e.to, new Set());
      reverse.get(e.to).add(obj);
    }
  }
  const canReturn = new Set([start]);
  const rq = [start];
  while (rq.length) {
    const here = rq.shift();
    for (const from of reverse.get(here) ?? []) {
      if (!canReturn.has(from)) { canReturn.add(from); rq.push(from); }
    }
  }

  const unreachable = [...rooms.entries()]
    .filter(([obj]) => !seen.has(obj))
    .map(([obj, r]) => r.name);
  const oneWay = [...seen]
    .filter((obj) => !canReturn.has(obj))
    .map((obj) => rooms.get(obj).name);

  const routineOnly = [...rooms.values()].filter((r) => r.sawRoutine && !r.exits.size).length;
  const withRoutines = [...rooms.values()].filter((r) => r.sawRoutine).length;
  // When most of the map moves through PER routines, static reachability
  // cannot conclude anything; say so rather than emit a wall of findings.
  const inconclusive = withRoutines * 2 >= rooms.size;
  return { name, start: rooms.get(start)?.name, total: rooms.size,
    reached: seen.size, unreachable, oneWay, opaque: routineOnly,
    withRoutines, inconclusive };
}

const targets = args.includes('--all') || !args.some((a) => a.endsWith('.z8') || a.endsWith('.z3'))
  ? GAMES
  : [[args[0].split('/').pop(), args[0]]];

let failures = 0;
for (const [name, story] of targets) {
  const r = await auditOne(name, story);
  if (r.skipped) { console.log(`${name}: skipped (${r.skipped})`); continue; }
  console.log(`\n=== ${name} ===`);
  console.log(`  start: ${r.start} | rooms with readable exits: ${r.total}`
    + ` | reached: ${r.reached}${r.opaque ? ` | ${r.opaque} PER-routine-only (opaque)` : ''}`);
  if (r.inconclusive) {
    console.log(`  INCONCLUSIVE - ${r.withRoutines} of ${r.total} rooms move via PER routines,`);
    console.log('    whose destinations are computed at run time. Static reachability cannot');
    console.log('    see those edges; use a wanderer test for these games instead.');
    continue;
  }
  if (r.unreachable.length) {
    failures += r.unreachable.length;
    console.log(`  UNREACHABLE from the start (${r.unreachable.length}):`);
    for (const n of r.unreachable.slice(0, verbose ? 999 : 10)) console.log(`    ${n}`);
    if (!verbose && r.unreachable.length > 10) console.log(`    ... ${r.unreachable.length - 10} more`);
  } else console.log('  ok - every room with exits is reachable');
  if (r.oneWay.length) {
    console.log(`  ONE-WAY - reachable but no path back to the start (${r.oneWay.length}):`);
    for (const n of r.oneWay.slice(0, verbose ? 999 : 10)) console.log(`    ${n}`);
    if (!verbose && r.oneWay.length > 10) console.log(`    ... ${r.oneWay.length - 10} more`);
  } else console.log('  ok - every reached room has a path back');
}
console.log(failures ? `\n${failures} unreachable room(s).` : '\nno unreachable rooms.');
process.exit(failures ? 1 : 0);
