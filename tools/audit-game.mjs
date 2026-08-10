#!/usr/bin/env node
/**
 * Static audit of a compiled game: the checks a walkthrough cannot make.
 *
 * A walkthrough is written by whoever built the game, so it encodes the
 * author's own mental model and can only prove the game is completable by
 * someone who already knows the answer. Every game in `adventures/` passed
 * its walkthrough while still stranding a player who did not guess the
 * intended move. These checks do not know the intended path, which is
 * exactly why they find what the walkthrough misses.
 *
 * Checks, all derived from the game's own text - no play, no judgement:
 *
 *   dead-end     A room whose description never names a way out. The
 *                player's correct instinct when stuck is LOOK; if LOOK
 *                does not mention an exit, LOOK cannot help them.
 *   unspeakable  A place the game DIRECTS the player to, in a word the
 *                parser does not know. An NPC who says "come to the
 *                counting-house" when COUNTING is not a dictionary word
 *                is instructing the player in words it refuses to hear.
 *
 * Related failure this cannot see, worth checking by hand: a room whose
 * M-LOOK handler prints a richer state-aware description often drops the
 * exit sentence its LDESC had. The LDESC still looks correct in source,
 * the room still works, and the walkthrough still passes - but the text a
 * player actually reads names no way out. Five of six real defects in one
 * game were this. When an M-LOOK override replaces an LDESC, diff the two
 * for direction words. (Every game in adventures/ uses the pattern:
 * Treasure Island 5 handlers, Alice 9, Monte Cristo 9, Oz 13, Dracula 27.)
 *
 * Known limits, so nobody mistakes a clean run for a correct game:
 *
 * - The dead-end check reads only the room's own description. A game may
 *   legitimately announce exits elsewhere (an NPC, a scripted beat), so
 *   findings are candidates for a human to judge, not proven bugs.
 * - "Directs the player" is matched by phrasing. An instruction worded
 *   some other way is missed, and the check only sees text the
 *   walkthrough happened to print.
 * - Neither check proves a game is winnable. That needs a wanderer test:
 *   junk input that must still reach the next act (see
 *   adventures/wizard-of-oz/walkthrough-wanderer-llm.txt).
 *
 * Usage:
 *   node tools/audit-game.mjs <story.z8> [walkthrough.txt] [--verbose]
 *   node tools/audit-game.mjs --all
 *
 * Exits non-zero if any check fails, so it can gate a build.
 */
import { readFileSync, existsSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { loadGame } from '../src/zmachine.js';

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const args = process.argv.slice(2);
const verbose = args.includes('--verbose');

const GAMES = [
  ['treasure-island', 'adventures/treasure-island/treasure.z8', 'adventures/treasure-island/walkthrough.txt'],
  ['alice', 'adventures/alice/alice.z8', 'adventures/alice/walkthrough.txt'],
  ['wizard-of-oz', 'adventures/wizard-of-oz/oz.z8', 'adventures/wizard-of-oz/walkthrough.txt'],
  ['monte-cristo', 'adventures/monte-cristo/cristo.z8', 'adventures/monte-cristo/walkthrough.txt'],
  ['dracula', 'adventures/dracula/dracula.z8', 'adventures/dracula/walkthrough.txt'],
];

/**
 * A room names a way out only if it says which WAY. Mentioning a place
 * ("all Marseilles has turned out on the quay") is scenery; a player
 * cannot act on it. This must be a direction word or a phrase that
 * pairs a feature with one - "the road runs west", "stairs lead down".
 * Naming the noun alone is exactly the Deck of the Pharaon bug: the quay
 * is mentioned, but nothing says the quay is WEST.
 */
const COMPASS = String.raw`(?:north|south|east|west|northeast|northwest|southeast|southwest|up|down|inward|outward|above|below)`;
const EXIT_WORDS = new RegExp([
  String.raw`\b(?:to the |lies? |lie |leads? |runs? |goes? |continues? |opens? |back |head |climb |descend )` + COMPASS + String.raw`\b`,
  String.raw`\b` + COMPASS + String.raw`(?:ward|wards)?\b[^.]{0,40}\b(?:lies?|leads?|runs?|is|are|stands?|opens?)\b`,
  String.raw`\b(?:exits?|way out|stairs?|staircase|ladder|doorway|gate|passage|corridor|tunnel)\b[^.]{0,30}\b` + COMPASS + String.raw`\b`,
].join('|'), 'i');

/** Function words that are never worth checking against the dictionary. */
const STOP = new Set(`a an the and or but of in on at to from with without into over under above below
beside beyond across along around through between among near by for is are was were be been being it
its this that these those there here where when while as if then than so very much many more most some
any all each every no not only just still yet own same such too can will would could should may might
must shall you your yours he she they them his her their we us our i me my mine what which who whom
whose how why do does did done have has had having says said say tell tells told come comes came go
goes going went get gets got take takes took see sees saw look looks looked make makes made know knows
knew think thinks thought like likes liked want wants wanted give gives gave find finds found put puts
now then once again always never sometimes perhaps maybe well right left first last next new old good
bad great little long short high low far away back down up out off over about after before during
since until upon against toward towards within between behind beneath beyond`.split(/\s+/));

/**
 * Only the nouns that constitute an instruction. A game may print any
 * word it likes as scenery - "thundering", "seventeen-something", the
 * author's name - and the parser is under no obligation to know them.
 * The bug is narrower and much more specific: text that DIRECTS the
 * player somewhere, in a word the parser will then reject. So look only
 * at phrases of the form "go/come/return to the X", "make for the X",
 * and the like, and check X.
 *
 * Being narrow is the point. The first version of this check reported
 * 141 findings for one game, which is the same as reporting none.
 */
const DIRECTIVE = /\b(?:go|come|return|head|make|set out|proceed|report|bring (?:it|them|her|him))\s+(?:back\s+)?(?:to|for|toward|towards|into|down to|up to|over to)\s+(?:the\s+|a\s+|an\s+|your\s+|his\s+|her\s+|my\s+)?([A-Za-z][A-Za-z-]{3,})/gi;

function candidateNouns(text) {
  const out = new Set();
  for (const match of text.matchAll(DIRECTIVE)) {
    const word = match[1].replace(/^-+|-+$/g, '').toLowerCase();
    if (word.length >= 4 && !STOP.has(word)) out.add(word);
  }
  return out;
}

async function auditOne(name, storyRel, walkRel) {
  const storyPath = join(ROOT, storyRel);
  if (!existsSync(storyPath)) return { name, skipped: 'no story file' };
  const session = await loadGame(storyPath);
  const vocab = new Set(session.vocabulary);
  const cut = (w) => w.slice(0, session.dictWordLength);
  const known = (w) => vocab.has(cut(w)) || vocab.has(cut(w.replace(/-/g, '')))
    || w.split('-').every((part) => part.length < 4 || vocab.has(cut(part)));

  const opening = await session.start();
  /** @type {Map<string,{text:string, said:string[]}>} */
  const seen = new Map();
  const note = (text) => {
    const room = session.status?.location;
    if (!room) return;
    // Register every room the player stands in, even when this turn
    // printed no description (a brief-mode revisit, or an action taken on
    // arrival). Recording only rooms that print their name undercounts
    // badly - Monte Cristo showed 18 of the 40 rooms it actually visits.
    if (!seen.has(room)) seen.set(room, { text: '', said: [] });
    const lines = text.split('\n').map((l) => l.trim());
    const entry = seen.get(room) ?? { text: '', said: [] };
    // Find the room name anywhere in the output, not only on line 0. An
    // intro paragraph before the first room name would otherwise push the
    // real opening description into `said`, and a later brief-mode
    // revisit gets graded instead - which reported Treasure Island's
    // Benbow Parlour as exitless when its full text names three exits.
    // First full description wins; later ones carry event text.
    const idx = lines.indexOf(room);
    if (idx >= 0) {
      if (!entry.text) entry.text = lines.slice(idx + 1).join(' ');
    } else if (text.trim()) entry.said.push(text.trim());
    seen.set(room, entry);
  };
  note(opening);

  const walkPath = walkRel && join(ROOT, walkRel);
  if (walkPath && existsSync(walkPath)) {
    const commands = readFileSync(walkPath, 'utf8').split('\n')
      .map((l) => l.replace(/;.*$/, '').trim()).filter((l) => l && !l.startsWith('#'));
    for (const command of commands) {
      if (session.ended) break;
      note(await session.send(command));
    }
  }

  const deadEnds = [];
  const unspeakable = new Map();
  for (const [room, entry] of seen) {
    if (entry.text && !EXIT_WORDS.test(entry.text) && !/pitch black|dark/i.test(entry.text)) {
      deadEnds.push({ room, text: entry.text.slice(0, 90) });
    }
    for (const line of [entry.text, ...entry.said]) {
      for (const noun of candidateNouns(line)) {
        if (!known(noun)) {
          const hits = unspeakable.get(noun) ?? new Set();
          hits.add(room);
          unspeakable.set(noun, hits);
        }
      }
    }
  }
  return { name, rooms: seen.size, deadEnds, unspeakable };
}

const targets = args.includes('--all') || !args.some((a) => a.endsWith('.z8') || a.endsWith('.z3'))
  ? GAMES
  : [[args[0].split('/').pop(), args[0], args[1]]];

let failures = 0;
for (const [name, story, walk] of targets) {
  const r = await auditOne(name, story, walk);
  if (r.skipped) { console.log(`${name}: skipped (${r.skipped})`); continue; }
  const bad = r.deadEnds.length + r.unspeakable.size;
  failures += bad;
  console.log(`\n=== ${name} (${r.rooms} rooms visited) ===`);

  if (r.deadEnds.length) {
    console.log(`  DEAD END - room text names no way out (${r.deadEnds.length}):`);
    for (const d of r.deadEnds) console.log(`    ${d.room}\n      "${d.text}..."`);
  } else console.log('  ok - every room names a way out');

  if (r.unspeakable.size) {
    // Most-cited first: a word the game repeats is one it expects the
    // player to use, so it matters more than a one-off.
    const ranked = [...r.unspeakable.entries()].sort((a, b) => b[1].size - a[1].size);
    const list = ranked.slice(0, verbose ? 999 : 12);
    console.log(`  UNSPEAKABLE - printed but not in the parser's dictionary (${r.unspeakable.size}):`);
    for (const [word, rooms] of list) {
      console.log(`    "${word}" - said in ${[...rooms].slice(0, 2).join(', ')}`);
    }
    if (!verbose && r.unspeakable.size > 12) console.log(`    ... ${r.unspeakable.size - 12} more (--verbose)`);
  } else console.log('  ok - every printed noun is speakable');
}

console.log(failures ? `\n${failures} finding(s).` : '\nclean.');
process.exit(failures ? 1 : 0);
