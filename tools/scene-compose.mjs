#!/usr/bin/env node
/**
 * Compose a scene description from a manifest, mechanically.
 *
 * This tool does no inference. It concatenates clauses, each tagged with
 * where it came from, and REFUSES to run if a clause that a human or a
 * model is supposed to supply is missing. It will never invent a style,
 * a mood, a light, or a time of day to fill a gap.
 *
 * Provenance is the point. A composed description mixes text extracted
 * from the game with text somebody wrote, and once concatenated the two
 * are indistinguishable - which is how an authored "bright clear
 * daylight" ends up looking like a fact about a room whose description
 * never mentions the sky. Every clause here is emitted with its source,
 * so a reviewer can tell them apart.
 *
 *   extracted  - printed by the game engine; ground truth
 *   authored   - written by a person in the style file
 *   model      - produced by tools/scene-clean.mjs, guard-checked
 *
 * Usage:
 *   node tools/scene-compose.mjs <manifest.json> --style <style.json>
 *        [--room <substring>] [--format text|json] [--allow-missing]
 *
 * Required in the style file (the tool errors listing what is absent):
 *   style     - medium and treatment, applied to every scene
 *   negative  - standing exclusions
 *   acts[].mood with acts[].source - the mood arc and the passage it
 *               derives from. A mood with no source is a preference and
 *               must be labelled `"source": "preference"` deliberately.
 */
import { readFileSync } from 'node:fs';

const args = process.argv.slice(2);
const flag = (n, d = null) => { const i = args.indexOf(n); return i >= 0 ? args[i + 1] : d; };
const has = (n) => args.includes(n);

const manifestPath = args.find((a) => !a.startsWith('-') && a.endsWith('.json'));
const stylePath = flag('--style');
const only = flag('--room');
const format = flag('--format', 'text');
const allowMissing = has('--allow-missing');

if (!manifestPath || !stylePath) {
  console.error('usage: scene-compose.mjs <manifest.json> --style <style.json> [--room X] [--format text|json]');
  process.exit(2);
}

const manifest = JSON.parse(readFileSync(manifestPath, 'utf8'));
const style = JSON.parse(readFileSync(stylePath, 'utf8'));

/** Everything the style file must supply before anything can be composed. */
const problems = [];
if (!style.style) problems.push('style.style is required (medium and treatment; nothing is assumed)');
if (!Array.isArray(style.negative) || !style.negative.length) {
  problems.push('style.negative is required (standing exclusions)');
}
for (const act of style.acts ?? []) {
  if (!act.mood) problems.push(`act "${act.name}": mood is required`);
  if (!act.source) {
    problems.push(`act "${act.name}": source is required - quote the passage the mood derives from, `
      + 'or set it to "preference" to record that it is taste, not text');
  }
}
if (!style.acts?.length) {
  problems.push('style.acts is required - a single unvarying mood flattens a story that changes');
}

if (problems.length && !allowMissing) {
  console.error('cannot compose - the style file is incomplete:\n');
  for (const p of problems) console.error('  - ' + p);
  console.error('\nNothing here is guessed by design. Supply the missing clauses, or pass');
  console.error('--allow-missing to compose without them (the clause is omitted, not invented).');
  process.exit(1);
}

const rows = [];
for (const room of manifest.rooms) {
  if (only && !room.room.toLowerCase().includes(only.toLowerCase())) continue;

  const clauses = [];
  if (room.dark) {
    clauses.push({ source: 'extracted', text: room.scenery, note: 'room is unlit; no scene is derivable' });
  } else if (room.sceneryClean) {
    clauses.push({ source: 'model', text: room.sceneryClean, note: 'scene-clean.mjs, subtractive, guard-checked' });
    if (room.introduced?.length) {
      clauses.push({ source: 'warning', text: `cleanup introduced words absent from source: ${room.introduced.join(', ')}` });
    }
  } else {
    clauses.push({ source: 'extracted', text: room.scenery, note: 'engine LOOK output, uncleaned' });
  }

  // Derived exclusions: things the manifest already knows do not belong in
  // a standing depiction of this room. These are computed, not authored -
  // an occupant is a creature or object the engine listed separately from
  // the room's own description, which is precisely the definition of "not
  // part of the place".
  if (!room.dark && room.occupants?.length) {
    const subjects = room.occupants
      .map((line) => line.replace(/\s+is here\b.*$/i, '').replace(/^(a|an|the)\s+/i, '').trim())
      .filter((t) => t && t.split(/\s+/).length <= 4);
    if (subjects.length) {
      clauses.push({
        source: 'derived',
        text: `do not depict: ${subjects.join(', ')}`,
        note: 'manifest occupants - seen here but not part of the room',
      });
    }
  }

  const act = (style.acts ?? []).find((a) => a.name === room.act);
  if (style.style) clauses.push({ source: 'authored', text: style.style, note: 'style file' });
  if (act?.mood) {
    clauses.push({ source: 'authored', text: act.mood, note: `act "${act.name}" - ${act.source}` });
  } else if (room.act) {
    clauses.push({ source: 'missing', text: `no mood defined for act "${room.act}"` });
  }

  rows.push({ id: room.id, room: room.room, act: room.act, dark: !!room.dark, clauses,
    negative: style.negative ?? [] });
}

if (format === 'json') {
  console.log(JSON.stringify({ story: manifest.story, scenes: rows }, null, 2));
} else {
  for (const r of rows) {
    console.log('='.repeat(74));
    console.log(`ROOM ${r.id}: ${r.room}${r.act ? `   [act: ${r.act}]` : ''}${r.dark ? '   [DARK]' : ''}`);
    console.log('='.repeat(74));
    for (const c of r.clauses) {
      console.log(`  (${c.source})${c.note ? ` ${c.note}` : ''}`);
      console.log(`    ${c.text.replace(/\n/g, '\n    ')}`);
    }
    const usable = r.clauses.filter((c) => ['extracted', 'model', 'authored'].includes(c.source));
    const derived = r.clauses.filter((c) => c.source === 'derived').map((c) => c.text);
    console.log('\n  PROMPT:');
    console.log('    ' + usable.map((c) => c.text.replace(/\s*\.\s*$/, '')).join('. ') + '.');
    console.log('\n  NEGATIVE: ' + [...r.negative, ...derived].join('; '));
    console.log();
  }
}
