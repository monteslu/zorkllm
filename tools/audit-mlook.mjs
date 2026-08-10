#!/usr/bin/env node
/**
 * Find M-LOOK handlers that drop the exit sentence their LDESC had.
 *
 * A room may print a richer, state-aware description from an M-LOOK
 * handler instead of its static LDESC. When that prose is rewritten, the
 * sentence naming the exits is easy to lose: the LDESC still looks
 * correct in source, the room still works, the walkthrough still passes,
 * and the text a player actually reads names no way out. Five of six
 * real defects found in one game were exactly this.
 *
 * The check is a source diff, not a play test, because the failure is in
 * text a walkthrough may never trigger - an M-LOOK branch only fires in
 * a particular act or state. So: for every room whose ACTION routine has
 * an M-LOOK branch, compare the direction words in its LDESC against the
 * direction words in the strings that branch can print.
 *
 * Reports a room when its LDESC names a direction and a SUPPRESSING
 * M-LOOK branch does not. Still a candidate, not a proven bug: a handler
 * may suppress deliberately because the player genuinely cannot see -
 * Monte Cristo's Cell 27 prints "nothing but coarse canvas an inch from
 * your eyes" while the player is sewn inside a burial sack, which is the
 * correct description of that state and names no exit for good reason.
 * Check each finding by playing LOOK in the state that triggers it.
 *
 * Usage:
 *   node tools/audit-mlook.mjs [--all] [<adventure dir> ...]
 */
import { readFileSync, readdirSync, existsSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const args = process.argv.slice(2);
const GAMES = ['treasure-island', 'alice', 'wizard-of-oz', 'monte-cristo', 'dracula'];

const DIRECTION = /\b(north|south|east|west|northeast|northwest|southeast|southwest|up|down|upward|downward|inward|outward|above|below|back)\b/i;

/** Every .zil file in an adventure directory, concatenated with origins. */
function sources(dir) {
  const files = readdirSync(dir).filter((f) => f.endsWith('.zil'));
  return files.map((f) => ({ file: f, text: readFileSync(join(dir, f), 'utf8') }));
}

/** Extract `<ROOM NAME ... >` blocks with their LDESC and ACTION. */
function rooms(text) {
  const out = [];
  const re = /<ROOM\s+([A-Z0-9?-]+)([\s\S]*?)\n(?=<|$)/g;
  for (const m of text.matchAll(re)) {
    const body = m[2];
    const ldesc = body.match(/\(LDESC\s*\n?\s*"([\s\S]*?)"\s*\)/);
    const action = body.match(/\(ACTION\s+([A-Z0-9?-]+)\)/);
    out.push({ name: m[1], ldesc: ldesc ? ldesc[1] : null, action: action ? action[1] : null });
  }
  return out;
}

/** The body of a named routine, to the next top-level form. */
function routineBody(text, name) {
  const re = new RegExp(`<ROUTINE\\s+${name.replace(/[?-]/g, '\\$&')}\\b[\\s\\S]*?\\n(?=<ROUTINE|<OBJECT|<ROOM|$)`, 'g');
  const m = re.exec(text);
  return m ? m[0] : null;
}

/**
 * Strings printed inside an M-LOOK branch, and whether that branch
 * SUPPRESSES the LDESC.
 *
 * This distinction is the whole check. A handler that ends `<RTRUE>`
 * tells the engine the room has been described and the LDESC never
 * prints - so if its text names no exit, the player sees none. A handler
 * that falls through (`<RFALSE>`, or no return) merely prepends detail
 * and the LDESC still follows, exits intact. Ignoring the return value
 * reports every prepending handler as a defect: eight such false
 * positives in one game, all of which name directions correctly in play.
 */
function mlookStrings(body) {
  const at = body.search(/M-LOOK/);
  if (at < 0) return null;
  const tail = body.slice(at);
  const end = tail.search(/M-(BEG|END|ENTER|FLASH|OBJDESC)/);
  const scope = end > 0 ? tail.slice(0, end) : tail;
  const strings = [...scope.matchAll(/"([^"]{4,})"/g)].map((m) => m[1]);
  // Suppressing means an RTRUE reached before the clause ends. RFALSE
  // first means it falls through to the LDESC.
  const rtrue = scope.search(/<RTRUE>/);
  const rfalse = scope.search(/<RFALSE>/);
  const suppresses = rtrue >= 0 && (rfalse < 0 || rtrue < rfalse);
  return { strings, suppresses };
}

const targets = args.filter((a) => !a.startsWith('--'));
const list = targets.length ? targets : GAMES;

let findings = 0;
for (const game of list) {
  const dir = join(ROOT, 'adventures', game);
  if (!existsSync(dir)) { console.log(`${game}: skipped (no directory)`); continue; }
  const src = sources(dir);
  const all = src.map((s) => s.text).join('\n');
  const roomList = src.flatMap((s) => rooms(s.text));
  const hits = [];
  let checked = 0;

  for (const room of roomList) {
    if (!room.action || !room.ldesc) continue;
    const body = routineBody(all, room.action);
    if (!body) continue;
    const printed = mlookStrings(body);
    if (!printed || !printed.strings.length) continue;
    checked += 1;
    // Only a suppressing handler can hide the LDESC's exits.
    if (!printed.suppresses) continue;
    const ldescHasDir = DIRECTION.test(room.ldesc);
    const mlookHasDir = printed.strings.some((p) => DIRECTION.test(p));
    if (ldescHasDir && !mlookHasDir) {
      hits.push({ room: room.name, action: room.action,
        ldesc: room.ldesc.replace(/\s+/g, ' ').slice(0, 70),
        mlook: printed.strings[0].replace(/\s+/g, ' ').slice(0, 70) });
    }
  }

  console.log(`\n=== ${game} (${checked} rooms with an M-LOOK override) ===`);
  if (!hits.length) { console.log('  ok - every M-LOOK override still names a direction'); continue; }
  findings += hits.length;
  for (const h of hits) {
    console.log(`  ${h.room} (${h.action})`);
    console.log(`    LDESC names a way out: "...${h.ldesc}..."`);
    console.log(`    M-LOOK prints instead: "${h.mlook}..."`);
  }
}

console.log(findings
  ? `\n${findings} M-LOOK override(s) may have dropped an exit sentence - check each by playing LOOK in that state.`
  : '\nno M-LOOK override dropped a direction.');
process.exit(findings ? 1 : 0);
