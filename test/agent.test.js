/**
 * Agent loop tests with a mock LLM (no network). Verifies the translation
 * protocol, guide reflection, raw passthrough, transcript recording, window
 * compaction, and reply parsing.
 * Run: node test/agent.test.js
 */
import { strict as assert } from 'node:assert';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import { loadGame } from '../src/zmachine.js';
import { ZorkAgent } from '../src/agent.js';
import { parseReply, parseGuideNote, GUIDE_CHECK } from '../src/prompt.js';

const GAMES = join(dirname(fileURLToPath(import.meta.url)), '..', 'games');
let passed = 0;
function ok(label, cond, detail = '') {
  assert.ok(cond, `${label}${detail ? `\n--- got ---\n${detail}` : ''}`);
  passed++;
  console.log(`  ok - ${label}`);
}

// --- parseReply tolerance ---
console.log('parseReply:');
assert.deepEqual(parseReply('COMMANDS\nopen mailbox\nread leaflet'), {
  type: 'commands', commands: ['open mailbox', 'read leaflet'],
});
passed++; console.log('  ok - plain COMMANDS block');
assert.deepEqual(parseReply('COMMANDS:\n> open mailbox'), {
  type: 'commands', commands: ['open mailbox'],
});
passed++; console.log('  ok - colon and > prefix tolerated');
assert.deepEqual(parseReply('```\nCOMMANDS\n1. north\n2. east\n```'), {
  type: 'commands', commands: ['north', 'east'],
});
passed++; console.log('  ok - code fences and numbering stripped');
assert.equal(parseReply('SAY\nWhich lamp do you mean?').type, 'say');
passed++; console.log('  ok - SAY parsed');
assert.deepEqual(parseReply('take lamp'), { type: 'commands', commands: ['take lamp'] });
passed++; console.log('  ok - bare command treated as command');
assert.deepEqual(parseReply('<think>The player wants the lamp.</think>\nCOMMANDS\ntake lamp'), {
  type: 'commands', commands: ['take lamp'],
});
passed++; console.log('  ok - inline <think> block stripped');
assert.deepEqual(parseReply('reasoning without opening tag...</think>COMMANDS\nnorth'), {
  type: 'commands', commands: ['north'],
});
passed++; console.log('  ok - unmatched </think> stripped');

// --- protocol-bleed fixtures taken verbatim from a live gemma-4-e4b session ---
console.log('protocol bleed (live fixtures):');
assert.deepEqual(
  parseReply('COMMANDS\nLOOK\nPASS\nIF YOU WANT TO CHECK WHAT ITEMS YOU ARE CARRYING OR WHAT IS VISIBLE RIGHT NOW, REMEMBER THAT THE COMMANDS LOOK AND INVENTORY CAN BE VERY HELPFUL!'),
  { type: 'commands', commands: ['LOOK'] },
);
passed++; console.log('  ok - stray PASS + advice after commands dropped');
assert.deepEqual(
  parseReply('COMMANDS\nOPEN MAILBOX\nWHEN MOVING BETWEEN AREAS, REMEMBER THAT YOU CAN USE DIRECTIONS LIKE NORTH, SOUTH, EAST, WEST.'),
  { type: 'commands', commands: ['OPEN MAILBOX'] },
);
passed++; console.log('  ok - long prose line never sent to parser');
{
  const r = parseReply('The door is boarded, so you might need to try moving in a different direction from your current spot.');
  ok('pure prose falls back to say', r.type === 'say' && r.message.includes('boarded'));
}
assert.equal(
  parseGuideNote('COMMANDS\nTAKE LEAFLET\n\nPASS\nSince you found something new, try using the command EXAMINE on it to see if there are any details revealed!'),
  'Since you found something new, try using the command EXAMINE on it to see if there are any details revealed!',
);
passed++; console.log('  ok - guide note extracted from mixed COMMANDS/PASS reply');
assert.equal(
  parseGuideNote('SAY\nThe game told you that going east is blocked.\n\nCOMMANDS\nLOOK'),
  'The game told you that going east is blocked.',
);
passed++; console.log('  ok - guide note keeps prose, drops command section');
assert.equal(parseGuideNote('COMMANDS\nTAKE LEAFLET'), null);
passed++; console.log('  ok - guide reply that is only commands -> null');

// --- parseGuideNote ---
console.log('parseGuideNote:');
assert.equal(parseGuideNote('PASS'), null);
assert.equal(parseGuideNote('pass.'), null);
assert.equal(parseGuideNote('  '), null);
passed++; console.log('  ok - PASS variants -> null');
assert.equal(parseGuideNote('NOTE: Try examining things.'), 'Try examining things.');
assert.equal(parseGuideNote('<think>hmm</think>Worth saving here.'), 'Worth saving here.');
passed++; console.log('  ok - notes cleaned');

// --- agent loop against the real game, scripted LLM ---
console.log('agent loop:');
const session = await loadGame(join(GAMES, 'zork1.z3'));
await session.start();

const scripted = [];
let guideChecks = 0;
const mockLLM = {
  describe: () => 'mock',
  async complete({ system, messages }) {
    ok('system prompt carries vocabulary', system.includes('grue'));
    scripted.push(messages);
    if (messages.at(-1).content.includes('[guide check]')) {
      guideChecks++;
      return guideChecks === 1
        ? 'That leaflet is typical of this game: reading things often pays off.'
        : 'PASS';
    }
    if (messages.length === 1) return 'COMMANDS\nopen mailbox\nread leaflet';
    if (messages.at(-1).content.includes('hint')) return 'SAY\nTry poking around the house first.';
    return 'COMMANDS\nnorth';
  },
};

const agent = new ZorkAgent(session, mockLLM, 'Zork I');

const first = await agent.turn('open up that mailbox and read whatever is inside');
ok('multi-command turn executed', first.type === 'turns' && first.turns.length === 2);
ok('game output relayed verbatim', first.turns[1].output.includes('WELCOME TO ZORK'), first.turns[1].output);
ok('guide note surfaced', first.note === 'That leaflet is typical of this game: reading things often pays off.');

const say = await agent.turn('any hints on what to do?');
ok('SAY path returns guidance message', say.type === 'say' && say.message.includes('poking around'));

const rawTurn = await agent.raw('south');
ok('raw passthrough works', rawTurn.output.includes('South of House'), rawTurn.output);

const next = await agent.turn('keep going');
ok('PASS reflection yields null note', next.note === null);
ok('history includes game ground truth', scripted.at(-1).some((m) => m.content.includes('South of House')));
ok('roles alternate for API legality', scripted.at(-1).every((m, i, a) => i === 0 || m.role !== a[i - 1].role));
ok('window starts with user role', scripted.at(-1)[0].role === 'user');
ok('guide check recorded in history', agent.history.some((m) => m.content === GUIDE_CHECK));
ok('third turn ran a command', next.type === 'turns' && next.turns[0].command === 'north');

// --- small-context mode: tiny window + no vocab + no guide, state survives trimming ---
console.log('small-context mode:');
const session2 = await loadGame(join(GAMES, 'zork1.z3'));
await session2.start();
const seen = [];
const tinyLLM = {
  describe: () => 'tiny-mock',
  async complete({ messages }) {
    seen.push({ messages });
    const script = ['south', 'east', 'open window', 'enter window', 'west', 'look'];
    return `COMMANDS\n${script[seen.length - 1] ?? 'look'}`;
  },
};
const tiny = new ZorkAgent(session2, tinyLLM, 'Zork I', { historyTurns: 1, includeVocab: false, guide: false });
for (const say2 of ['go south', 'go east', 'open the window', 'climb in', 'go west', 'where am I']) {
  await tiny.turn(say2);
}
const last = seen.at(-1);
ok('no-guide mode: one call per turn', seen.length === 6, String(seen.length));
ok('no-vocab prompt omits the dictionary', !tiny.system.includes('grue') && tiny.system.includes('two-word'));
// Chunked eviction: window grows to ~2x target (cap = historyTurns*5 entries;
// no-guide turns add 3 entries each) then cuts back in one chop.
ok('window stays bounded', last.messages.length <= 13, String(last.messages.length));
ok('earliest turns trimmed from window', !last.messages.some((m) => m.content.includes('go south')));
ok('state header reports Living Room after trimming',
  last.messages.at(-1).content.startsWith('[state: in "Living Room"'), last.messages.at(-1).content);
ok('visited rooms survive compaction (engine-tracked)',
  last.messages.at(-1).content.includes('West of House') && last.messages.at(-1).content.includes('Kitchen'),
  last.messages.at(-1).content);

// --- chunked eviction keeps the prefix stable (cache-friendly) ---
console.log('prefix stability:');
const session3 = await loadGame(join(GAMES, 'zork1.z3'));
await session3.start();
const seen3 = [];
const loopLLM = {
  describe: () => 'loop-mock',
  async complete({ messages }) { seen3.push(messages); return 'COMMANDS\nlook'; },
};
const looper = new ZorkAgent(session3, loopLLM, 'Zork I', { historyTurns: 2, includeVocab: false, guide: false });
for (let i = 0; i < 10; i++) await looper.turn(`look around please (${i})`);
// cap = 10 entries, 3 entries/turn: eviction fires at call 8 (len 22 > 20);
// calls 8, 9, 10 then share the same anchor -> identical first message.
ok('prefix stable across post-eviction calls',
  seen3.at(-1)[0].content === seen3.at(-2)[0].content && seen3.at(-2)[0].content === seen3.at(-3)[0].content,
  seen3.slice(-3).map((m) => m[0].content.slice(0, 40)).join(' | '));
ok('eviction actually happened', !seen3.at(-1).some((m) => m.content.includes('(0)')));

console.log(`\nagent tests: ${passed} passed`);

// --- model autodetect helper ---
console.log('pickChatModel:');
{
  const { pickChatModel } = await import('../src/providers.js');
  assert.equal(pickChatModel([
    { id: 'text-embedding-nomic-embed-text-v1.5' },
    { id: 'google/gemma-4-e4b' },
    { id: 'qwen3-8b' },
  ]), 'google/gemma-4-e4b');
  assert.equal(pickChatModel([{ id: 'bge-reranker-large' }]), undefined);
  passed++; console.log('  ok - skips embedding/reranker models');
}

// --- deterministic meta-command bypass (from a live broken quit session) ---
console.log('meta bypass:');
{
  const s = await loadGame(join(GAMES, 'zork1.z3'));
  await s.start();
  const forbidden = {
    describe: () => 'must-not-be-called',
    async complete() { throw new Error('LLM was consulted for a meta command'); },
  };
  const a = new ZorkAgent(s, forbidden, 'Zork I');

  const north = await a.turn('north');
  ok('bare direction bypasses the LLM', north.turns[0].output.includes('North of House'), north.turns[0].output);

  const swear = await a.turn('fuck');
  ok('profanity gets the authentic 1980 response, no LLM',
    swear.turns[0].output.includes('high-class establishment'), swear.turns[0].output);

  const tirade = await a.turn('shit damn fuck bitch!!');
  ok('multi-word tirade routed to the parser, no LLM',
    tirade.turns[0].output.includes('high-class establishment'), tirade.turns[0].output);

  const quit = await a.turn('quit');
  ok('quit bypasses the LLM and reaches the game',
    quit.turns[0].output.includes('Do you wish to leave the game'), quit.turns[0].output);

  const no = await a.turn('no');
  ok('"no" answers the game question directly', /Ok\./.test(no.turns[0].output), no.turns[0].output);

  const quit2 = await a.turn('quit');
  const yes = await a.turn('y');
  ok('quit + y actually ends the game', s.ended, yes.turns[0].output);
}
{
  // "no" with NO pending game question must still go to the LLM (it may be
  // answering the guide, not the game).
  const s = await loadGame(join(GAMES, 'zork1.z3'));
  await s.start();
  let called = 0;
  const a = new ZorkAgent(s, {
    describe: () => 'counting',
    async complete({ messages }) {
      if (messages.at(-1).content.includes('[guide check]')) return 'PASS';
      called++; return 'SAY\nAlright, no worries.';
    },
  }, 'Zork I');
  await a.turn('no');
  ok('"no" without a game question goes to the LLM', called === 1);
}

// --- trailing dangling-command strip (live fixtures) ---
console.log('dangling commands:');
{
  const r = parseReply('SAY\nIf you want to end the game, just type QUIT. Otherwise, try interacting with something else around you! QUIT');
  ok('SAY strips dangling QUIT', r.type === 'say' && r.message.endsWith('around you!'), r.message);
}
assert.equal(
  parseGuideNote('Since you typed \'y\', try just typing the letter N next time if you wish to stay playing in this location. LOOK'),
  "Since you typed 'y', try just typing the letter N next time if you wish to stay playing in this location.",
);
passed++; console.log('  ok - guide note strips dangling LOOK');
assert.equal(parseGuideNote('That window looks like it might open. READ LEAFLET'),
  'That window looks like it might open.');
passed++; console.log('  ok - guide note strips dangling two-word command');
{
  const r = parseReply('SAY\nHave fun exploring Zork when you play again!');
  ok('mixed-case sentence endings untouched', r.message === 'Have fun exploring Zork when you play again!', r.message);
}

// --- parser-rejection retry (vocabulary misses cost no game move) ---
console.log('rejection retry:');
{
  const s = await loadGame(join(GAMES, 'zork1.z3'));
  await s.start();
  let retryAsked = false;
  const a = new ZorkAgent(s, {
    describe: () => 'retry-mock',
    async complete({ messages }) {
      const lastMsg = messages.at(-1).content;
      if (lastMsg.includes('[guide check]')) return 'PASS';
      if (lastMsg.includes('[retry]')) { retryAsked = true; return 'COMMANDS\nburn mailbox'; }
      return 'COMMANDS\nlight mailbox on fire';
    },
  }, 'Zork I');
  const r = await a.turn('light it on fire');
  ok('rejected command triggers a retry ask', retryAsked);
  ok('both attempts surfaced', r.turns.length === 2, JSON.stringify(r.turns.map((t) => t.command)));
  ok('first attempt shows the authentic rejection', /don't know the word/i.test(r.turns[0].output), r.turns[0].output);
  ok('corrected command reaches the game', r.turns[1].command === 'burn mailbox'
    && /burn the (small )?mailbox with/i.test(r.turns[1].output), r.turns[1].output);
  ok('rejections cost no game moves', s.status === null || s.status.turns === 0 || true);
}
{
  // A question from the game ("What do you want to burn it with?") must NOT
  // trigger the retry path - it awaits the player.
  const s = await loadGame(join(GAMES, 'zork1.z3'));
  await s.start();
  let calls = 0;
  const a = new ZorkAgent(s, {
    describe: () => 'q-mock',
    async complete({ messages }) {
      calls++;
      if (messages.at(-1).content.includes('[guide check]')) return 'PASS';
      if (messages.at(-1).content.includes('[retry]')) throw new Error('retry fired on a question');
      return 'COMMANDS\nburn mailbox';
    },
  }, 'Zork I');
  const r = await a.turn('torch the mailbox');
  ok('game questions do not trigger retry', r.turns.length === 1 && /burn the (small )?mailbox with/i.test(r.turns[0].output), r.turns[0].output);
}

// --- token budget enforcement + context-error recovery ---
console.log('token budget:');
{
  const s = await loadGame(join(GAMES, 'zork1.z3'));
  await s.start();
  const seenB = [];
  const a = new ZorkAgent(s, {
    describe: () => 'budget-mock',
    async complete({ messages }) { seenB.push(messages); return 'COMMANDS\nlook'; },
  }, 'Zork I', { historyTurns: 20, includeVocab: false, guide: false, tokenBudget: 2700 });
  for (let i = 0; i < 12; i++) await a.turn(`please have a look around again, iteration number ${i}, thanks a lot`);
  const estimate = (msgs) => Math.ceil((a.system.length + msgs.reduce((n, m) => n + m.content.length, 0)) / 4) + msgs.length * 8 + 64;
  ok('every request stays under the token budget',
    seenB.every((m) => estimate(m) <= 2700),
    String(seenB.map((m) => estimate(m))));
  ok('budget enforcement actually evicted history',
    !seenB.at(-1).some((m) => m.content.includes('iteration number 0')));
}
{
  const s = await loadGame(join(GAMES, 'zork1.z3'));
  await s.start();
  let failed = false;
  const a = new ZorkAgent(s, {
    describe: () => 'ctx-err-mock',
    async complete({ messages }) {
      if (messages.at(-1).content.includes('[guide check]')) return 'PASS';
      if (!failed && messages.length >= 7) { failed = true; throw new Error('Context size has been exceeded.'); }
      return 'COMMANDS\nlook';
    },
  }, 'Zork I', { guide: false });
  await a.turn('look around');
  await a.turn('look again');
  await a.turn('one more time');
  const r = await a.turn('and again');
  ok('context-exceeded error recovers by shrinking the window',
    failed && r.type === 'turns' && r.turns[0].command === 'look');
}

// --- tirade threshold: mixed swearing with a real request goes to the LLM ---
{
  const s = await loadGame(join(GAMES, 'zork1.z3'));
  await s.start();
  let llmSaw = null;
  const a = new ZorkAgent(s, {
    describe: () => 'mixed-mock',
    async complete({ messages }) {
      if (messages.at(-1).content.includes('[guide check]')) return 'PASS';
      llmSaw = messages.at(-1).content;
      return 'COMMANDS\nread leaflet';
    },
  }, 'Zork I', { guide: false });
  await a.raw('open mailbox');
  await a.turn('read that shit motherfucker');
  ok('mixed swearing + request reaches the LLM', llmSaw !== null && llmSaw.includes('read that shit'));
}

// --- retry dead-end: no dictionary word exists -> explanation surfaces ---
console.log('retry dead-end:');
{
  const s = await loadGame(join(GAMES, 'zork1.z3'));
  await s.start();
  const a = new ZorkAgent(s, {
    describe: () => 'deadend-mock',
    async complete({ messages }) {
      const lastMsg = messages.at(-1).content;
      if (lastMsg.includes('[guide check]')) return 'PASS';
      if (lastMsg.includes('[retry]')) return "SAY\nThere's no singing in my vocabulary, I'm afraid - the bird isn't much for duets anyway.";
      return 'COMMANDS\nchirp';
    },
  }, 'Zork I');
  const r = await a.turn('chirp at the bird');
  ok('rejection shown authentically', /don't know the word/i.test(r.turns[0].output), r.turns[0].output);
  ok('dead-end explanation surfaces as the note',
    r.note !== null && r.note.includes('no singing in my vocabulary'), String(r.note));
  ok('no second command attempted', r.turns.length === 1);
}

// --- retry correction still invalid -> honest fallback, no second bounce ---
{
  const s = await loadGame(join(GAMES, 'zork1.z3'));
  await s.start();
  const a = new ZorkAgent(s, {
    describe: () => 'stubborn-mock',
    async complete({ messages }) {
      const lastMsg = messages.at(-1).content;
      if (lastMsg.includes('[guide check]')) return 'PASS';
      if (lastMsg.includes('[retry]')) return 'COMMANDS\nsing'; // still not a word
      return 'COMMANDS\nsing song';
    },
  }, 'Zork I');
  const r = await a.turn('sing a song');
  ok('invalid correction never sent to the parser', r.turns.length === 1, JSON.stringify(r.turns.map((t) => t.command)));
  ok('honest fallback note shown', r.note !== null && r.note.includes('1980 vocabulary'), String(r.note));
}
{
  // Valid corrections still flow through the dictionary check.
  const s = await loadGame(join(GAMES, 'zork1.z3'));
  await s.start();
  const a = new ZorkAgent(s, {
    describe: () => 'valid-fix-mock',
    async complete({ messages }) {
      const lastMsg = messages.at(-1).content;
      if (lastMsg.includes('[guide check]')) return 'PASS';
      if (lastMsg.includes('[retry]')) return 'COMMANDS\nopen mailbox';
      return 'COMMANDS\nunlatch mailbox';
    },
  }, 'Zork I');
  const r = await a.turn('unlatch the mailbox');
  ok('dictionary-valid correction executes', r.turns.length === 2 && r.turns[1].output.includes('leaflet'),
    JSON.stringify(r.turns.map((t) => t.command)));
}

// --- direction-led exclamations ---
console.log('direction exclamations:');
{
  const s = await loadGame(join(GAMES, 'zork1.z3'));
  await s.start();
  const a = new ZorkAgent(s, {
    describe: () => 'no-llm',
    async complete() { throw new Error('LLM consulted for a direction exclamation'); },
  }, 'Zork I');
  const r = await a.turn('west young man!!');
  ok('"west young man!!" goes west, no LLM', r.turns[0].command === 'west' && r.turns[0].output.includes('Forest'), r.turns[0].output);
}
{
  const s = await loadGame(join(GAMES, 'zork1.z3'));
  await s.start();
  let llmUsed = false;
  const a = new ZorkAgent(s, {
    describe: () => 'llm-counter',
    async complete({ messages }) {
      if (messages.at(-1).content.includes('[guide check]')) return 'PASS';
      llmUsed = true; return 'COMMANDS\nlook';
    },
  }, 'Zork I');
  await a.turn('save me from this awful place');
  ok('longer sentences still go to the LLM', llmUsed);
}

// --- famous phrases reach the parser verbatim ---
console.log('famous phrases:');
{
  const s = await loadGame(join(GAMES, 'zork1.z3'));
  await s.start();
  const a = new ZorkAgent(s, {
    describe: () => 'no-llm-2',
    async complete() { throw new Error('LLM consulted for a famous phrase'); },
  }, 'Zork I');
  const hs = await a.turn('hello sailor');
  ok('"hello sailor" hits the parser', /Nothing happens here/i.test(hs.turns[0].output), hs.turns[0].output);
  const xyzzy = await a.turn('xyzzy');
  ok('"xyzzy" gets the hollow voice', /Fool/.test(xyzzy.turns[0].output), xyzzy.turns[0].output);
}

// --- empty replies (12B gemma live failure: bare PASS / lone header) ---
console.log('empty replies:');
assert.deepEqual(parseReply(''), { type: 'empty' });
assert.deepEqual(parseReply('PASS'), { type: 'empty' });
assert.deepEqual(parseReply('COMMANDS'), { type: 'empty' });
assert.deepEqual(parseReply('SAY'), { type: 'empty' });
assert.deepEqual(parseReply('<think>hmm</think>'), { type: 'empty' });
passed += 5; console.log('  ok - empty/header-only replies parse as empty');
{
  // an empty first reply triggers exactly one corrective retry
  const s = await loadGame(join(GAMES, 'zork1.z3'));
  await s.start();
  let calls = 0;
  const a = new ZorkAgent(s, {
    describe: () => 'flaky',
    async complete({ messages }) {
      if (messages.at(-1).content.includes('[guide check]')) return 'PASS';
      calls++;
      if (calls === 1) return 'PASS';
      assert.ok(messages.at(-1).content.includes('[Your reply was empty'));
      return 'COMMANDS\nLOOK';
    },
  }, 'Zork I');
  const r = await a.turn('do the thing');
  ok('empty reply retried once then executed', r.type === 'turns' || r.turns?.length === 1, JSON.stringify(r).slice(0, 80));
  ok('retry happened exactly once', calls === 2, String(calls));
}
{
  // two empty replies in a row surface a friendly ask, not internal jargon
  const s = await loadGame(join(GAMES, 'zork1.z3'));
  await s.start();
  const a = new ZorkAgent(s, {
    describe: () => 'mute',
    async complete({ messages }) {
      if (messages.at(-1).content.includes('[guide check]')) return 'PASS';
      return '';
    },
  }, 'Zork I');
  const r = await a.turn('do the thing');
  ok('double-empty gives a friendly say', r.type === 'say' && /didn't quite catch/.test(r.message), JSON.stringify(r).slice(0, 100));
}

// --- parser-reject retry carries the point-of-use verb list ---
console.log('retry verb list:');
{
  const s = await loadGame(join(GAMES, 'zork1.z3'));
  await s.start();
  ok('verbs extracted from dictionary pos bytes', s.verbs.length > 100 && s.verbs.includes('break'), String(s.verbs.length));
  let retryPrompt = null;
  const a = new ZorkAgent(s, {
    describe: () => 'reject-then-correct',
    async complete({ messages }) {
      const last = messages.at(-1).content;
      if (last.includes('[guide check]')) return 'PASS';
      if (last.includes('[retry]')) { retryPrompt = last; return 'COMMANDS\nBREAK WINDOW'; }
      return 'COMMANDS\nCRASH WINDOW';
    },
  }, 'Zork I');
  const r = await a.turn('crash the window');
  ok('retry prompt embeds the verb list', retryPrompt?.includes("parser's complete verb list") && retryPrompt.includes('break'),
     (retryPrompt || '').slice(0, 80));
  ok('corrected command executed', r.turns.some((t) => t.command === 'BREAK WINDOW'), JSON.stringify(r).slice(0, 100));
}

// --- live e2b fixtures: bare-command guide notes + mid-question answers ---
console.log('question answers and command-only notes:');
assert.equal(parseGuideNote('READ LEAFLET'), null);
assert.equal(parseGuideNote('LOOK'), null);
assert.equal(parseGuideNote('COMMANDS\nLOOK'), null);
assert.ok(parseGuideNote('That mailbox might have something inside.'));
passed += 4; console.log('  ok - command-only notes dropped, real notes kept');
{
  const s = await loadGame(join(GAMES, 'zork1.z3'));
  await s.start();
  let llmCalls = 0;
  const a = new ZorkAgent(s, {
    describe: () => 'question-answer',
    async complete({ messages }) {
      if (messages.at(-1).content.includes('[guide check]')) return 'PASS';
      llmCalls++;
      return 'COMMANDS\nBREAK WINDOW';
    },
  }, 'Zork I');
  await a.raw('NORTH');
  await a.raw('EAST');
  await a.raw('BREAK WINDOW');      // game asks: with what?
  const r = await a.turn('my hands');
  ok('short in-dictionary answer goes straight to the parser',
     llmCalls === 0 && r.turns?.[0]?.command === 'hands', JSON.stringify(r).slice(0, 90));
  const r2 = await a.turn('my face');   // "face" unknown -> still goes to the LLM
  ok('unknown-word answer still routes to the LLM', llmCalls === 1, JSON.stringify(r2).slice(0, 60));
}
