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
    if (this.version !== 3) return; // status globals 16/17/18 are a v3 convention
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
