/**
 * The agent loop: player free text -> LLM translation -> parser commands ->
 * game output. Game text is always relayed verbatim; the LLM never writes
 * game prose. Everything here is provider-agnostic.
 */
import { buildSystemPrompt, parseReply, GUIDE_CHECK, parseGuideNote } from './prompt.js';

/**
 * Single words that ARE parser commands already - translating them through an
 * LLM adds latency and failure modes (models lecture about QUIT instead of
 * sending it). These bypass the LLM entirely; the game handles them itself,
 * including its own confirmation prompts.
 */
const META_WORDS = new Set([
  'quit', 'q', 'save', 'restore', 'restart', 'score', 'version', 'diagnose',
  'verbose', 'brief', 'superbrief', 'look', 'l', 'inventory', 'i', 'wait', 'z',
  'again', 'g', 'north', 'south', 'east', 'west', 'ne', 'nw', 'se', 'sw',
  'northeast', 'northwest', 'southeast', 'southwest', 'up', 'u', 'down', 'd',
  'in', 'out',
  // Zork's own dictionary maps these to V-CURSES ("Such language in a
  // high-class establishment like this!") - the 1980 sass is the authentic
  // response to swearing, so don't let the LLM intercept and moralize.
  'shit', 'fuck', 'damn', 'curse',
  // Magic words and easter-egg verbs the world has opinions about.
  'xyzzy', 'plugh', 'zork', 'frobozz', 'hello', 'pray', 'echo',
]);

/** Famous full phrases that must reach the parser verbatim, not the guide. */
const FAMOUS_PHRASES = new Map([
  ['hello sailor', 'hello sailor'],
  ['hello, sailor', 'hello sailor'],
  ['odysseus', 'odysseus'],
  ['ulysses', 'ulysses'],
]);

/** Direction words that can lead a short exclamation ("west young man!!"). */
const DIRECTION_WORDS = new Set([
  'north', 'south', 'east', 'west', 'northeast', 'northwest', 'southeast',
  'southwest', 'up', 'down',
]);

/**
 * Yes/no answers pass straight through - but only when the game itself just
 * asked a question (e.g. QUIT's "Do you wish to leave the game? (Y is
 * affirmative)"). Otherwise "no" might be answering the guide, not the game.
 */
const YESNO_WORDS = new Set(['y', 'yes', 'n', 'no']);

/**
 * Parser rejection messages. Infocom-engine games (the ZIL trilogy parser:
 * UNKNOWN-WORD, CANT-USE, SYNTAX-CHECK) and Inform-compiled games phrase
 * these differently; both families are covered. A rejected command consumed
 * NO game move - parsers only tick the clock on successful parses - so
 * retrying a corrected command is free and safe. Questions ("What do you
 * want to burn it with?") deliberately don't match: those await the player.
 */
const PARSER_REJECT = new RegExp([
  // Infocom / ZIL trilogy parser
  "I don't know the word",
  'You used the word "',
  "That sentence isn't one I recognize",
  'There was no verb in that sentence',
  'too many nouns in that sentence',
  // Inform-compiled games (most post-Infocom .z5/.z8)
  "That's not a verb I recogni[sz]e",
  "You can't see any such thing",
  "I didn't understand that sentence",
  'not something you need to refer to',
  'Verb error',
].join('|'), 'i');
// Games with fully custom messages simply skip the retry optimization -
// rejection detection is an enhancement, never a correctness requirement.

/** Recognized profanity; the first four are in Zork's own dictionary. */
const SWEAR_WORDS = new Set([
  'shit', 'fuck', 'damn', 'curse', 'bitch', 'ass', 'asshole', 'crap', 'hell',
  'fucking', 'fuckin', 'dammit', 'damnit', 'goddamn', 'goddammit', 'bastard', 'wtf',
]);

/**
 * A message that is mostly swearing goes straight to the parser as a curse -
 * Zork answers profanity itself ("Such language in a high-class establishment
 * like this!") and that 1980 sass beats anything a model would say.
 * @param {string} text
 * @returns {string|null} the command to send, or null if not a tirade
 */
function detectTirade(text) {
  const tokens = text.toLowerCase().replace(/[^a-z\s]/g, '').split(/\s+/).filter(Boolean);
  if (!tokens.length) return null;
  const swears = tokens.filter((t) => SWEAR_WORDS.has(t));
  // Two-thirds threshold: "read that shit motherfucker" is half profanity but
  // carries a real request - that belongs with the LLM, not the curse handler.
  if (swears.length < tokens.length * (2 / 3)) return null;
  return swears.find((t) => ['shit', 'fuck', 'damn', 'curse'].includes(t)) || 'damn';
}

export class ZorkAgent {
  /**
   * @param {import('./zmachine.js').GameSession} session
   * @param {{complete: (req: {system: string, messages: Array<{role: string, content: string}>}) => Promise<string>}} llm
   * @param {string} gameName
   * @param {{historyTurns?: number, includeVocab?: boolean}} [opts]
   *   historyTurns: target exchanges kept in the LLM window (default 20; the
   *   window ranges between N and 2N before chunked eviction - see #window).
   *   Try 6-8 for 4k-context local models. includeVocab: false drops the
   *   dictionary from the system prompt, saving ~1k tokens. guide: false
   *   disables the post-turn reflection pass (purist mode, one call per turn).
   */
  constructor(session, llm, gameName, opts = {}) {
    this.session = session;
    this.llm = llm;
    /** Dictionary lookup for validating commands (entries pre-truncated by the z-machine format: 6 chars in v3, 9 in v4+). */
    this.vocabSet = new Set(session.vocabulary);
    this.dictWordLength = session.dictWordLength ?? 6;
    this.historyTurns = opts.historyTurns ?? 20;
    this.guide = opts.guide !== false;
    /** Hard cap on estimated request tokens (server's loaded context minus generation+safety margin). */
    this.tokenBudget = opts.tokenBudget ?? null;
    this.system = buildSystemPrompt(gameName, opts.includeVocab === false ? [] : session.vocabulary);
    /** @type {Array<{role: 'user'|'assistant', content: string}>} */
    this.history = [];
  }

  /**
   * Run one raw parser command, bypassing the LLM (player typed `> cmd`).
   * Recorded in history so the LLM stays aware of the transcript.
   * @param {string} command
   * @returns {Promise<{command: string, output: string}>}
   */
  async raw(command) {
    const output = await this.session.send(command);
    this.history.push(
      { role: 'user', content: `(typed a raw command) >${command}` },
      { role: 'assistant', content: `COMMANDS\n${command}` },
    );
    this.#recordGameOutput(command, output);
    return { command, output };
  }

  /**
   * Handle one player utterance.
   * @param {string} playerText
   * @returns {Promise<{type: 'say', message: string} | {type: 'turns', turns: Array<{command: string, output: string}>, note: string|null}>}
   */
  async turn(playerText) {
    // Every deterministic bypass below is gated on the loaded game's OWN
    // dictionary (#inDictionary), so nothing here assumes Zork specifically -
    // a game without a CURSE verb or a SAILOR easter egg simply routes those
    // inputs to the LLM instead.
    const tirade = detectTirade(playerText);
    if (tirade && this.#inDictionary(tirade)) {
      const { command, output } = await this.raw(tirade);
      return { type: 'turns', turns: [{ command, output }], note: null };
    }
    const word = playerText.trim().toLowerCase().replace(/[.!?]+$/, '');
    if (FAMOUS_PHRASES.has(word) && this.#inDictionary(FAMOUS_PHRASES.get(word))) {
      const { command, output } = await this.raw(FAMOUS_PHRASES.get(word));
      return { type: 'turns', turns: [{ command, output }], note: null };
    }
    // Short exclamations led by a direction ("west young man!!", "north now")
    // are just directions with attitude.
    const tokens = word.split(/\s+/);
    if (tokens.length >= 2 && tokens.length <= 3 && DIRECTION_WORDS.has(tokens[0])
      && this.#inDictionary(tokens[0])) {
      const { command, output } = await this.raw(tokens[0]);
      return { type: 'turns', turns: [{ command, output }], note: null };
    }
    const gameAskedQuestion = /affirmative\)?:?\s*$|\?\s*$/i.test(this.lastGameOutput || '');
    if (!word.includes(' ')) {
      if ((META_WORDS.has(word) && this.#inDictionary(word))
        || (YESNO_WORDS.has(word) && gameAskedQuestion)) {
        const { command, output } = await this.raw(word);
        return { type: 'turns', turns: [{ command, output }], note: null };
      }
    }
    // The parser is mid-question ("What do you want to break the window
    // with?") and the player gave a short answer ("the sword", "my
    // hands"): hand it straight to the parser, which resolves such
    // answers natively. Leading possessives the 1980 dictionary lacks
    // ("my") are dropped; beyond that every word must be dictionary-known
    // or the LLM translates as usual. A wrong guess costs nothing -
    // rejections consume no game move and fall into the retry.
    if (gameAskedQuestion && tokens.length <= 3) {
      const answer = tokens.filter((t, i) => !(i === 0 && ['my', 'their', 'this', 'that'].includes(t))).join(' ');
      if (answer && this.#inDictionary(answer)) {
        const { command, output } = await this.raw(answer);
        return { type: 'turns', turns: [{ command, output }], note: null };
      }
    }
    this.history.push({ role: 'user', content: playerText });
    let reply;
    try {
      reply = await this.llm.complete({ system: this.system, messages: this.#window() });
    } catch (err) {
      // Last-resort recovery for servers whose context we couldn't detect:
      // shrink the window to the bare minimum and retry once.
      if (/context/i.test(err.message) && this.history.length - this.#anchor > 8) {
        this.#anchor = this.history.length - 8;
        try {
          reply = await this.llm.complete({ system: this.system, messages: this.#window() });
        } catch (err2) {
          this.history.pop();
          throw err2;
        }
      } else {
        this.history.pop();
        throw err;
      }
    }
    this.history.push({ role: 'assistant', content: reply });
    let decision = parseReply(reply);
    if (decision.type === 'empty') {
      // Empty or header-only reply (bare PASS, lone COMMANDS). Nudge once
      // with an explicit reminder of the two reply shapes.
      this.history.push({
        role: 'user',
        content: '[Your reply was empty. Answer the player now: either COMMANDS followed by parser commands, or SAY followed by one or two sentences spoken to the player.]',
      });
      const retry = await this.llm.complete({ system: this.system, messages: this.#window() });
      this.history.push({ role: 'assistant', content: retry });
      decision = parseReply(retry);
      if (decision.type === 'empty') {
        return {
          type: 'say',
          message: 'I didn\'t quite catch that - tell me something specific to do ("climb the tree", "go north") or ask me a question.',
        };
      }
    }
    if (decision.type === 'say') {
      return { type: 'say', message: decision.message };
    }
    const turns = [];
    let retries = 0;
    let retryNote = null;
    for (const command of decision.commands) {
      if (this.session.ended) break;
      const output = await this.session.send(command);
      turns.push({ command, output });
      this.#recordGameOutput(command, output);
      if (PARSER_REJECT.test(output) && retries < 2) {
        retries++;
        const fixed = await this.#retryCommand(command, output);
        if (fixed?.type === 'command' && !this.session.ended) {
          const retryOutput = await this.session.send(fixed.command);
          turns.push({ command: fixed.command, output: retryOutput });
          this.#recordGameOutput(fixed.command, retryOutput);
        } else if (fixed?.type === 'say') {
          // No dictionary way to express it - the explanation IS the payoff
          // for this turn ("there's no singing in my vocabulary...").
          retryNote = fixed.message;
        }
      }
    }
    const note = retryNote ?? (turns.length ? await this.#reflect() : null);
    return { type: 'turns', turns, note };
  }

  /**
   * A command bounced off the parser (which costs no game move), so ask the
   * LLM for one corrected command restricted to dictionary words - or, if the
   * action simply doesn't exist in this game, an in-voice explanation.
   * @param {string} command @param {string} output
   * @returns {Promise<{type: 'command', command: string} | {type: 'say', message: string} | null>}
   */
  async #retryCommand(command, output) {
    // Point-of-use verb list: small models ignore the vocabulary in the
    // distant system prompt but follow one embedded in the correction ask.
    // Ordering matters to them too: the list goes first and the ask goes
    // LAST, or the model takes whatever escape hatch it read most recently.
    const verbs = this.session.verbs?.length
      ? `My parser's complete verb list: ${this.session.verbs.join(' ')}.\n`
      : '';
    this.history.push({
      role: 'user',
      content: `[retry] The command "${command}" bounced off my 1980 parser: "${output.split('\n')[0]}" No game time passed.\n${verbs}The player's intent almost always maps to one of those verbs ("crash" -> BREAK, "fire" -> BURN, "grab" -> TAKE). Reply COMMANDS with ONE corrected command using the closest verb from the list. Only if you are certain no listed verb fits, reply SAY with one short sentence in your own voice saying this world has no way to do that.`,
    });
    try {
      const reply = await this.llm.complete({ system: this.system, messages: this.#window() });
      this.history.push({ role: 'assistant', content: reply });
      const decision = parseReply(reply);
      if (decision.type === 'empty') return null;   // nothing useful came back
      if (decision.type === 'say') {
        return { type: 'say', message: decision.message };
      }
      const fixed = decision.commands[0];
      if (!fixed || fixed.toLowerCase() === command.toLowerCase() || !this.#inDictionary(fixed)) {
        // The whole point of a correction is dictionary compliance; a retry
        // that still contains unknown words would just bounce again. Give the
        // player an honest in-voice answer instead of a second rejection.
        return {
          type: 'say',
          message: "I don't have words for that - my 1980 vocabulary never learned it, so it's probably not how this world works.",
        };
      }
      return { type: 'command', command: fixed };
    } catch {
      this.history.pop();
      return null;
    }
  }

  /** Would the parser recognize every word of this command? */
  #inDictionary(command) {
    return command
      .toLowerCase()
      .replace(/[^a-z0-9\s-]/g, '')
      .split(/\s+/)
      .filter(Boolean)
      .every((w) => /^\d+$/.test(w) || this.vocabSet.has(w.slice(0, this.dictWordLength)));
  }

  /**
   * Post-turn guide reflection: one extra call on the same (cached) prefix
   * asking whether a newcomer needs anything pointed out. Recorded in history
   * either way so the window stays append-only and the guide remembers what
   * it already taught. Guidance is best-effort - never fails the turn.
   * @returns {Promise<string|null>}
   */
  async #reflect() {
    if (!this.guide || this.session.ended) return null;
    this.history.push({ role: 'user', content: GUIDE_CHECK });
    try {
      const reply = await this.llm.complete({ system: this.system, messages: this.#window() });
      this.history.push({ role: 'assistant', content: reply });
      return parseGuideNote(reply);
    } catch {
      this.history.pop();
      return null;
    }
  }

  /** Record the game's response as ground truth in the transcript. */
  #recordGameOutput(command, output) {
    this.lastGameOutput = output;
    this.history.push({ role: 'user', content: `[game responded to "${command}"]\n${output}` });
  }

  /**
   * Authoritative one-line game state, read from the engine, prepended to the
   * latest message at request time (never stored in history, so it can't go
   * stale). This is what keeps a small-context model oriented after old turns
   * fall out of the window: even if it has forgotten everything, the current
   * room, score, move count, and the visited-room list survive compaction for
   * free because they come from the Z-machine, not from the transcript.
   */
  #stateHeader() {
    const s = this.session.status;
    if (!s) return '';
    const visited = this.session.visitedRooms;
    const rooms = visited.length > 1 ? ` Rooms visited: ${visited.join(', ')}.` : '';
    return `[state: in "${s.location}", score ${s.score}, ${s.turns} moves.${rooms}]`;
  }

  /** History entries before this index are evicted from the LLM window. */
  #anchor = 0;

  /**
   * Recent history window, merged so roles alternate legally.
   *
   * Eviction is chunked, not sliding: the window grows to ~2x the target,
   * then cuts back to the target in one chop. A sliding window would shift
   * the prefix every turn, which busts prefix-matched caches (llama.cpp /
   * Ollama KV cache, Anthropic prompt caching) and forces a full re-prefill
   * per turn; with chunked eviction the prefix is byte-stable between
   * evictions, so each turn only appends.
   */
  #window() {
    const cap = this.historyTurns * 5; // ~5 history entries per game exchange (incl. guide check)
    if (this.history.length - this.#anchor > cap * 2) {
      this.#anchor = this.history.length - cap;
    }
    let merged = this.#buildWindow();
    // Hard budget enforcement: turn-count heuristics can't know how chatty a
    // session was, so if the server told us its loaded context size, evict
    // further (in chunks, preserving the prefix between calls) until we fit.
    while (
      this.tokenBudget && this.#estimateTokens(merged) > this.tokenBudget
      && this.history.length - this.#anchor > 8
    ) {
      this.#anchor += 4;
      merged = this.#buildWindow();
    }
    return merged;
  }

  /** Merge history from the anchor so roles alternate legally; inject state header. */
  #buildWindow() {
    const recent = this.history.slice(this.#anchor);
    /** @type {Array<{role: 'user'|'assistant', content: string}>} */
    const merged = [];
    for (const msg of recent) {
      const last = merged[merged.length - 1];
      if (last && last.role === msg.role) last.content += '\n\n' + msg.content;
      else merged.push({ ...msg });
    }
    if (merged[0]?.role === 'assistant') merged.shift();
    const header = this.#stateHeader();
    const last = merged[merged.length - 1];
    if (header && last?.role === 'user') last.content = `${header}\n${last.content}`;
    return merged;
  }

  /** Rough request size in tokens (chars/4 plus per-message overhead). */
  #estimateTokens(messages) {
    const chars = this.system.length + messages.reduce((n, m) => n + m.content.length, 0);
    return Math.ceil(chars / 4) + messages.length * 8 + 64;
  }
}
