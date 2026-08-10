/**
 * The agent loop: player free text -> LLM translation -> parser commands ->
 * game output. Game text is always relayed verbatim; the LLM never writes
 * game prose. Everything here is provider-agnostic.
 */
import { buildSystemPrompt, parseReply, GUIDE_CHECK, GUIDE_CONTINUE, parseGuideNote } from './prompt.js';

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

/** Verbs that open a movement sentence ("go north on the path"). */
const MOVEMENT_LEADS = new Set([
  'go', 'walk', 'head', 'move', 'run', 'travel', 'proceed', 'continue',
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

// Engine responses that leave a newcomer staring at a dead end: questions
// the parser asks back, blocked movement, and the stock refusals from the
// ZIL and Inform standard libraries. These are library strings shared
// across each family's games, never title-specific text. Matching one
// upgrades the post-turn reflection to the continuation prompt (and
// enables it at all on bypassed turns); over-matching only costs a guide
// call that may PASS, so the list leans inclusive.
const CONFUSING_RESPONSE = new RegExp([
  // questions asked back / missing information
  'You must specify', 'Which .* do you mean', 'What do you want',
  'Please give a direction', 'You must tell me how',
  // blocked movement
  "can't go that way", 'There is a wall', "I can't see how",
  // stock refusals
  "You can't do that", "can't see any", "You don't have",
  'has no effect', "doesn't seem to work", 'futile',
  "isn't notably helpful", 'A valiant attempt', "can't be opened",
  'Nothing happens', "You can't be serious",
].join('|'), 'i');

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
    /** The game's own word classifications (dictionary part-of-speech bytes). */
    /** @type {Set<string>[]} normalized word sets of recent guide notes */
    this.recentNotes = [];
    this.verbSet = new Set(session.verbs ?? []);
    this.nounSet = new Set(session.nouns ?? []);
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
      return { type: 'turns', turns: [{ command, output }], note: await this.#reflectIfConfusing(output) };
    }
    // Movement sentences carrying exactly one direction ("go north on the
    // path", "head up those stairs") mean that direction; sentences with
    // several directions are plans and go to the LLM.
    if (MOVEMENT_LEADS.has(tokens[0])) {
      const dirs = tokens.filter((t) => DIRECTION_WORDS.has(t));
      if (dirs.length === 1 && this.#inDictionary(dirs[0])) {
        const { command, output } = await this.raw(dirs[0]);
        return { type: 'turns', turns: [{ command, output }], note: await this.#reflectIfConfusing(output) };
      }
    }
    const gameAskedQuestion = /affirmative\)?:?\s*$|\?\s*$/i.test(this.lastGameOutput || '');
    if (!word.includes(' ')) {
      if ((META_WORDS.has(word) && this.#inDictionary(word))
        || (YESNO_WORDS.has(word) && gameAskedQuestion)) {
        const { command, output } = await this.raw(word);
        return { type: 'turns', turns: [{ command, output }], note: await this.#reflectIfConfusing(output) };
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
        return { type: 'turns', turns: [{ command, output }], note: await this.#reflectIfConfusing(output) };
      }
    }
    // Input that already IS parser-speak skips translation: the game's
    // own dictionary must know every word, classify the first as a verb,
    // and classify one as a noun. The noun requirement keeps chat that
    // happens to start with a verb ("wait what") away from the engine.
    // The engine still does ALL parsing - this only routes.
    const preparsed = this.#asParserCommand(tokens);
    let reply;
    if (preparsed) {
      this.history.push({ role: 'user', content: playerText });
      reply = `COMMANDS\n${preparsed}`;
      this.history.push({ role: 'assistant', content: reply });
    } else {
    this.history.push({ role: 'user', content: playerText });
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
    }
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
      // A question deserves an answer, not a restatement. Weak models
      // reply to "what should I do?" with "You are on the Marseilles
      // Quay." - true, already on screen, and useless to the player who
      // asked precisely because they are stuck. One corrective retry that
      // names the concrete options costs a turn nothing: no game move has
      // happened.
      if (this.#echoesGame(decision.message) || this.#isVacantAnswer(playerText, decision.message)) {
        const retried = await this.#retrySay(playerText);
        if (retried) return { type: 'say', message: retried };
      }
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
    const note = retryNote ?? (turns.length
      ? await this.#reflect(this.#isConfusing(turns.at(-1).output) ? GUIDE_CONTINUE : GUIDE_CHECK)
      : null);
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
    // A rejected command that leads with a direction or movement verb and
    // contains exactly one direction ("NORTH ON PATH", "GO NORTH QUICKLY")
    // corrects deterministically to that direction - no model needed.
    {
      const ct = command.toLowerCase().split(/\s+/);
      if (ct.length > 1 && (DIRECTION_WORDS.has(ct[0]) || MOVEMENT_LEADS.has(ct[0]))) {
        const dirs = ct.filter((t) => DIRECTION_WORDS.has(t));
        if (dirs.length === 1 && this.#inDictionary(dirs[0])) {
          return { type: 'command', command: dirs[0].toUpperCase() };
        }
      }
    }
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

  /**
   * If the input is already a valid-looking parser command, return the
   * cleaned text to send; otherwise null. Purely a router: membership and
   * part-of-speech come from the story file's own dictionary, and the
   * engine performs all actual parsing. Misfires are cheap - rejections
   * cost no game move and flow into the normal retry ladder.
   * @param {string[]} tokens lowercased words of the player's input
   * @returns {string|null}
   */
  #asParserCommand(tokens) {
    if (tokens.length < 2 || tokens.length > 5) return null;
    if (!this.verbSet.size || !this.nounSet.size) return null;
    const clean = tokens.map((t) => t.replace(/[^a-z0-9-]/g, '')).filter(Boolean);
    if (clean.length < 2 || clean.length !== tokens.length) return null;
    const cut = (t) => t.slice(0, this.dictWordLength);
    if (!this.verbSet.has(cut(clean[0]))) return null;
    if (!clean.every((t) => this.vocabSet.has(cut(t)))) return null;
    if (!clean.some((t) => this.nounSet.has(cut(t)))) return null;
    return clean.join(' ');
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
   * asking whether a newcomer needs anything pointed out. Real notes stay
   * in history so the guide remembers what it already taught; PASS
   * exchanges are removed, because a window full of [guide check] -> PASS
   * pairs teaches the model to imitate its own silence - after a few, it
   * answers PASS to everything (observed live: same model, same stuck
   * player, coached with a clean window and went mute with a PASS-filled
   * one). Guidance is best-effort - never fails the turn.
   * @returns {Promise<string|null>}
   */
  async #reflect(message = GUIDE_CHECK) {
    if (!this.guide || this.session.ended) return null;
    this.history.push({ role: 'user', content: message });
    try {
      const reply = await this.llm.complete({ system: this.system, messages: this.#window() });
      let note = parseGuideNote(reply);
      // Models echo their own recent notes almost verbatim ("the path runs
      // east and north" seventeen turns straight, live). A repeat teaches
      // nothing, so it is treated exactly like PASS - suppressed and
      // removed from history, where it would only breed more repeats.
      // A note that restates the engine's own text is worse than silence:
      // the player reads the same sentence twice and learns nothing. The
      // guide's whole value is saying what the game did NOT. Weak models
      // parrot constantly - observed live, a note reading "The door east
      // opens on the quay." directly beneath that exact line.
      if (note && this.#echoesGame(note)) note = null;
      if (note && this.#isRepeatNote(note)) note = null;
      if (note) {
        this.history.push({ role: 'assistant', content: reply });
        this.recentNotes.push(this.#normalizeNote(note));
        if (this.recentNotes.length > 5) this.recentNotes.shift();
      } else {
        this.history.pop();
      }
      return note;
    } catch {
      this.history.pop();
      return null;
    }
  }

  /**
   * A question answered with nothing. Distinct from an echo: "You are on
   * the quay. What do you wish to do now?" overlaps the room text by only
   * 20%, so an echo check passes it, yet it tells a stuck player nothing.
   * The test is whether the reply names anything the player could act on -
   * an object in scope, something carried, or a direction. If it names
   * none of those, it is padding.
   * @param {string} question @param {string} answer
   */
  #isVacantAnswer(question, answer) {
    if (!/^(what|where|how|which|who|why)\b|\?\s*$|stuck|help|next|should i|do now/i.test(question)) {
      return false;   // only judge replies to a request for direction
    }
    const scope = this.session.scope?.() ?? { carrying: [], present: [] };
    const ways = this.session.exits?.() ?? [];
    // Object names contain filler ("purse of your pay"); matching on
    // those makes "What is your next move?" look like it names a thing.
    const FILLER = new Set(['your', 'yours', 'their', 'this', 'that', 'with', 'from',
      'some', 'here', 'there', 'thing', 'things', 'pair', 'piece', 'little', 'small', 'great']);
    const nouns = [...scope.present, ...scope.carrying]
      .flatMap((n) => n.toLowerCase().split(/\s+/))
      .filter((w) => w.length > 3 && !FILLER.has(w));
    const lower = answer.toLowerCase();
    const namesThing = nouns.some((n) => lower.includes(n));
    const namesWay = ways.some((d) => new RegExp(`\\b${d}\\b`).test(lower));
    return !namesThing && !namesWay;
  }

  /**
   * The guide answered a question by restating the room. Ask again, with
   * the mechanical scope the engine is certain of, and require concrete
   * nouns rather than a location.
   * @param {string} question
   * @returns {Promise<string|null>}
   */
  async #retrySay(question) {
    const scope = this.session.scope?.() ?? { carrying: [], present: [] };
    // NOTE: session.exits() is not trustworthy yet - the direction/property
    // mapping cannot be read reliably from a story file, and a wrong answer
    // is worse than none ("the way out is north" on a deck whose only exit
    // was down). Left out of the hint until it is exact.
    const facts = [
      scope.present.length ? `Here: ${scope.present.join(', ')}.` : '',
      scope.carrying.length ? `Carrying: ${scope.carrying.join(', ')}.` : 'Carrying nothing.',
    ].filter(Boolean).join(' ');
    this.history.push({
      role: 'user',
      content: `[retry] Your answer only repeated where the player is standing, which they can `
        + `already see. They asked: "${question}". ${facts} Answer with something they could DO `
        + `next - name a thing to examine, a person to talk to, or a direction to try. One or two `
        + `sentences, in your own voice, no command words.`,
    });
    try {
      const reply = await this.llm.complete({ system: this.system, messages: this.#window() });
      this.history.push({ role: 'assistant', content: reply });
      const decision = parseReply(reply);
      const message = decision.type === 'say' ? decision.message : null;
      return message && !this.#echoesGame(message) ? message : null;
    } catch {
      this.history.pop();
      return null;
    }
  }

  /**
   * Does this note just say back what the game printed? Compares against
   * the engine text the player is looking at right now, sentence by
   * sentence, so a note that copies one line out of a long room
   * description is caught as surely as a whole-output echo.
   * @param {string} note
   */
  #echoesGame(note) {
    const output = this.lastGameOutput || '';
    if (!output) return false;
    const words = this.#normalizeNote(note);
    if (!words.size) return true;
    const sentences = output.split(/(?<=[.!?])\s+|\n+/).filter(Boolean);
    for (const sentence of [output, ...sentences]) {
      const prev = this.#normalizeNote(sentence);
      if (!prev.size) continue;
      const shared = [...words].filter((w) => prev.has(w)).length;
      // Half the note's content words already on screen means a
      // paraphrase, which teaches as little as a verbatim copy: "The door
      // east opens on the quay" answered by "The door leads east onto the
      // quay" scores 0.67 and is pure noise. Weak models paraphrase far
      // more often than they copy, so a strict threshold catches almost
      // nothing - measured on a live session, 0.8 let three of four
      // echoes through.
      if (shared / words.size >= 0.5) return true;
    }
    return false;
  }

  /** Word-set overlap against the last few notes given. */
  #isRepeatNote(note) {
    const words = this.#normalizeNote(note);
    return this.recentNotes.some((prev) => {
      const shared = [...words].filter((w) => prev.has(w)).length;
      return shared / Math.max(words.size, prev.size) >= 0.75;
    });
  }

  /** @param {string} note @returns {Set<string>} */
  #normalizeNote(note) {
    return new Set(note.toLowerCase().replace(/[^a-z0-9\s]/g, '').split(/\s+/).filter(Boolean));
  }

  /**
   * Bypassed turns skip the guide to stay instant - unless the engine's
   * response is the kind that leaves a newcomer stuck (a rejection, a
   * dead end, a question). Then one reflection call buys a plain-words
   * explanation, which is exactly when guidance earns its latency.
   * @param {string} output
   * @returns {Promise<string|null>}
   */
  async #reflectIfConfusing(output) {
    if (!this.guide || !output || !this.#isConfusing(output)) return null;
    return this.#reflect(GUIDE_CONTINUE);
  }

  /** Is this the kind of engine response that leaves a newcomer stuck? */
  #isConfusing(output) {
    return PARSER_REJECT.test(output) || CONFUSING_RESPONSE.test(output);
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
    // v4+ games keep no status globals, so score/turns are null there; print
    // only what the engine actually knows rather than the word "null".
    const tally = s.score === null || s.turns === null
      ? '' : `, score ${s.score}, ${s.turns} moves`;
    // Mechanical scope: what the engine knows is carried and present. A
    // weak model with these facts stops inventing objects ("there is no
    // lamp here" for a lamp in hand), and the specifics give a stuck
    // player something real to act on without revealing any puzzle - the
    // engine would have listed all of it for a LOOK or INVENTORY anyway.
    const scope = this.session.scope?.() ?? { carrying: [], present: [] };
    const carrying = scope.carrying.length
      ? ` Carrying: ${scope.carrying.join(', ')}.` : ' Carrying nothing.';
    const present = scope.present.length
      ? ` Here: ${scope.present.join(', ')}.` : '';

    return `[state: in "${s.location}"${tally}.${carrying}${present}${rooms}]`;
  }

  /** History entries before this index are evicted from the LLM window. */
  #anchor = 0;

  /**
   * Read-only diagnostic: where the context window starts, how much history
   * exists, and the current estimated request size. Used to measure eviction
   * pressure - a session that evicts every other turn cannot hold a puzzle in
   * mind, which is invisible from the transcript alone.
   */
  anchorProbe() {
    return {
      anchor: this.#anchor,
      history: this.history.length,
      tokens: this.#estimateTokens(this.#buildWindow()),
    };
  }

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
