/**
 * Headless driver around the `zmachine` interpreter: feed a command string in,
 * get the game's text back. The Z-machine is the authority on all game state.
 */
import { readFile, writeFile, mkdir } from 'node:fs/promises';
import { dirname } from 'node:path';
import { ZMachine } from '../vendor/zmachine.mjs';
import { extractVocabulary, dictWordLength, extractVerbs, extractNouns } from './vocab.js';

const PROMPT_TRIM = /\n?>\s*$/;

export class GameSession {
  /** @type {string[]} words from the story file's dictionary */
  vocabulary = [];
  /** @type {{location: string, score: number, turns: number}|null} */
  status = null;

  /** Object number of the player ("cretin"), located lazily on v4+. */
  #playerObj = undefined;
  /** @type {string[]} unique room names in the order first visited (authoritative, from the engine) */
  visitedRooms = [];
  /** True once the game has quit */
  ended = false;
  /** File path used by the next in-game SAVE/RESTORE opcode */
  saveFile = 'zorkllm.sav';

  #buffer = '';
  /** v4+ games draw a status bar in window 1; only window 0 is game prose. */
  #currentWindow = 0;
  /** @type {((r: {text: string, terminator: number}) => void)|null} */
  #pendingRead = null;
  /** @type {((output: string) => void)|null} */
  #waiter = null;

  /**
   * @param {Buffer} story raw story file bytes
   */
  constructor(story) {
    this.version = story.readUInt8(0);
    this.vocabulary = extractVocabulary(story);
    this.dictWordLength = dictWordLength(story);
    this.verbs = extractVerbs(story);
    this.nouns = extractNouns(story);
    const session = this;
    /** @type {import('zmachine').IOAdapter} */
    const io = {
      initialize() {},
      print(text) { if (session.#currentWindow === 0) session.#buffer += text; },
      printLine(text) { if (session.#currentWindow === 0) session.#buffer += text + '\n'; },
      newLine() { if (session.#currentWindow === 0) session.#buffer += '\n'; },
      readLine() {
        session.#updateStatus();
        return new Promise((resolve) => {
          session.#pendingRead = resolve;
          session.#flush();
        });
      },
      readChar() { return Promise.resolve(13); },
      quit() {
        session.ended = true;
        session.#flush();
      },
      restart() {},
      showStatusLine(location, score, turns) {
        session.status = { location, score, turns };
      },
      setWindow(w) { session.#currentWindow = w; }, splitWindow() {}, eraseWindow() {},
      setTextStyle() {}, setBufferMode() {}, getBufferMode: () => true,
      setCursor() {}, eraseLine() {},
      verify: () => true,
      async save(data) {
        try {
          await mkdir(dirname(session.saveFile), { recursive: true }).catch(() => {});
          await writeFile(session.saveFile, data);
          return true;
        } catch {
          return false;
        }
      },
      async restore() {
        try {
          return await readFile(session.saveFile);
        } catch {
          return null;
        }
      },
    };
    this.zm = ZMachine.load(story, io);
  }

  /**
   * V3 interpreters refresh the status line before each input read; this
   * library only handles the explicit show_status opcode, so read the
   * standard v3 globals (16=location obj, 17=score, 18=moves) ourselves.
   */
  #updateStatus() {
    if (this.version !== 3) { this.#updateStatusV4(); return; }
    try {
      const locationObj = this.zm.variables.load(16);
      let location = '';
      if (locationObj !== 0) {
        const nameInfo = this.zm.objectTable.getShortNameAddress(locationObj);
        if (nameInfo.lengthBytes > 0) location = this.zm.textDecoder.decode(nameInfo.address).text;
      }
      this.status = {
        location,
        score: this.zm.variables.load(17),
        turns: this.zm.variables.load(18),
      };
      if (location && !this.visitedRooms.includes(location)) this.visitedRooms.push(location);
    } catch {
      // status is cosmetic; never let it break a turn
    }
  }

  /**
   * v4+ story files do not maintain the v3 status globals (16/17/18), so the
   * room name has to come from the object tree: the player object's parent IS
   * the current room. The player object is located once by short name - the
   * ZIL engine calls it "cretin" - and cached. Score and turns stay null
   * rather than guessed, since v4+ games are free to keep them anywhere.
   * Without this, `visitedRooms` is empty for every v8 game and the LLM loses
   * its spatial anchor (observed live: a 50-turn session with no room history
   * at all).
   */
  #updateStatusV4() {
    try {
      const ot = this.zm.objectTable;
      if (this.#playerObj === undefined) {
        this.#playerObj = null;
        for (let i = 1; i <= 500; i++) {
          const info = ot.getShortNameAddress(i);
          if (info.lengthBytes > 0
            && /^(cretin|adventurer|yourself)$/i.test(this.zm.textDecoder.decode(info.address).text)) {
            // Engines also define pseudo-objects the parser uses for "me"/"you"
            // that live outside the room tree; the real player object is the
            // one whose parent is a named room.
            const par = ot.getParent(i);
            if (par && ot.getShortNameAddress(par).lengthBytes > 0) {
              this.#playerObj = i;
              break;
            }
          }
        }
      }
      if (!this.#playerObj) return;
      const room = ot.getParent(this.#playerObj);
      if (!room) return;
      const nameInfo = ot.getShortNameAddress(room);
      if (nameInfo.lengthBytes <= 0) return;
      const location = this.zm.textDecoder.decode(nameInfo.address).text;
      if (!location) return;
      this.status = { location, score: null, turns: null };
      if (!this.visitedRooms.includes(location)) this.visitedRooms.push(location);
    } catch {
      // spatial tracking is an enhancement; never let it break a turn
    }
  }

  /**
   * Objects the player is carrying and objects present in the room, read
   * from the object tree. These are facts the engine is certain of, and a
   * weak model that has them stops inventing them - the failure mode of a
   * small model is fabrication, not silence, so crowding the context with
   * true specifics is worth more than any instruction not to guess.
   *
   * Deliberately shallow: direct children only, no container contents, so
   * a closed sack does not leak what is inside it. Objects the engine
   * hides (INVISIBLE, e.g. Zork's trap door under the rug) never appear in
   * the tree walk as visible siblings anyway - they are listed, so callers
   * must not treat this as "what the player can see". It is scope, not
   * sight; use it for grounding, never to reveal.
   * @returns {{carrying: string[], present: string[]}}
   */
  scope() {
    const empty = { carrying: [], present: [] };
    try {
      const ot = this.zm.objectTable;
      const player = this.#findPlayer(ot);
      if (!player) return empty;
      const room = ot.getParent(player);
      if (!room) return empty;
      const name = (n) => {
        const info = ot.getShortNameAddress(n);
        return info.lengthBytes > 0 ? this.zm.textDecoder.decode(info.address).text : null;
      };
      const children = (parent, skip) => {
        const out = [];
        let c = ot.getChild(parent);
        while (c) {
          const n = name(c);
          if (n && c !== skip) out.push(n);
          c = ot.getSibling(c);
        }
        return out;
      };
      return { carrying: children(player), present: children(room, player) };
    } catch {
      return empty;
    }
  }

  /**
   * Directions that lead somewhere from the current room, read from the
   * room's exit properties. Read-only: probing by walking would mutate
   * the game, and a hint must never cost a move.
   *
   * Direction properties occupy the highest property numbers, and the
   * engine dispatches on property SIZE (gverbs.zil): 1 UEXIT, 2 NEXIT
   * (a refusal string, no destination), 3 FEXIT (a routine - destination
   * computed at run time, invisible here), 4 CEXIT, 5 DEXIT. Only sizes
   * 1, 4 and 5 name a room, and even those may be shut, so this answers
   * "which ways are worth trying", not "which ways are open".
   * @returns {string[]}
   */
  exits() {
    try {
      const ot = this.zm.objectTable;
      const player = this.#findPlayer(ot);
      const room = player && ot.getParent(player);
      if (!room) return [];
      const mem = ot.memory ?? this.zm.memory;
      let p = ot.getPropertyTableAddress(room);
      p += 1 + mem.readByte(p) * 2;
      const found = [];
      for (;;) {
        const size = mem.readByte(p);
        if (size === 0) break;
        let num; let len; let at;
        if (this.version >= 4) {
          num = size & 0x3f;
          if (size & 0x80) { len = (mem.readByte(p + 1) & 0x3f) || 64; at = p + 2; }
          else { len = (size & 0x40) ? 2 : 1; at = p + 1; }
        } else {
          num = size & 0x1f; len = (size >> 5) + 1; at = p + 1;
        }
        if (len === 1 || len === 4 || len === 5) found.push(num);
        p = at + len;
      }
      // Property numbers descend from the last declared direction, and the
      // engine's own order is N S E W NE NW SE SW U D IN OUT.
      const order = ['north', 'south', 'east', 'west', 'northeast', 'northwest',
        'southeast', 'southwest', 'up', 'down', 'in', 'out'];
      const high = Math.max(...found, 0);
      if (!high) return [];
      return found.sort((a, b) => b - a)
        .map((n) => order[high - n])
        .filter(Boolean);
    } catch {
      return [];
    }
  }

  /** @param {any} ot */
  #findPlayer(ot) {
    if (this.#playerObj !== undefined && this.#playerObj !== null) return this.#playerObj;
    for (let i = 1; i <= 500; i++) {
      const info = ot.getShortNameAddress(i);
      if (info.lengthBytes > 0
        && /^(cretin|adventurer|yourself)$/i.test(this.zm.textDecoder.decode(info.address).text)) {
        const parent = ot.getParent(i);
        if (parent && ot.getShortNameAddress(parent).lengthBytes > 0) {
          this.#playerObj = i;
          return i;
        }
      }
    }
    return null;
  }

  /** Hand accumulated output to whoever is waiting for this turn to finish. */
  #flush() {
    if (!this.#waiter) return;
    const out = this.#buffer.replace(PROMPT_TRIM, '');
    this.#buffer = '';
    const resolve = this.#waiter;
    this.#waiter = null;
    resolve(out.trim());
  }

  /**
   * Boot the machine and return the opening text (banner + first room).
   * @returns {Promise<string>}
   */
  start() {
    const opening = new Promise((resolve) => { this.#waiter = resolve; });
    this.runPromise = this.zm.run().then(
      () => { this.ended = true; this.#flush(); },
      (err) => { this.ended = true; this.#buffer += `\n[interpreter error: ${err.message}]`; this.#flush(); },
    );
    return opening;
  }

  /**
   * Send one parser command; resolves with everything the game printed in
   * response (one full game turn, up to the next input prompt).
   * @param {string} command
   * @returns {Promise<string>}
   */
  send(command) {
    if (this.ended) return Promise.resolve('[the game has ended]');
    if (!this.#pendingRead) return Promise.reject(new Error('game is not waiting for input'));
    const done = new Promise((resolve) => { this.#waiter = resolve; });
    const resolve = this.#pendingRead;
    this.#pendingRead = null;
    resolve({ text: command, terminator: 13 });
    return done;
  }
}

/**
 * @param {string} storyPath
 * @returns {Promise<GameSession>}
 */
export async function loadGame(storyPath) {
  const story = await readFile(storyPath);
  return new GameSession(story);
}
