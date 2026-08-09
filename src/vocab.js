/**
 * Extract the parser dictionary straight out of a Z-machine v3 story file.
 * The game's real vocabulary (684 words for Zork I) goes into the LLM's
 * system prompt so it translates into words the parser actually knows.
 */

const A0 = 'abcdefghijklmnopqrstuvwxyz';
const A1 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
const A2 = ' \n0123456789.,!?_#\'"/\\-:()'; // index 0 unused (escape), v3 alphabet table

/**
 * Decode the text of one dictionary entry: 4 bytes (6 z-chars) in v1-3,
 * 6 bytes (9 z-chars) in v4+.
 * @param {Buffer} buf @param {number} off @param {number} textWords
 * @returns {string}
 */
function decodeEntryText(buf, off, textWords) {
  const zchars = [];
  for (let i = 0; i < textWords; i++) {
    const w = buf.readUInt16BE(off + i * 2);
    zchars.push((w >> 10) & 0x1f, (w >> 5) & 0x1f, w & 0x1f);
  }
  let out = '';
  let alphabet = 0;
  for (let i = 0; i < zchars.length; i++) {
    const z = zchars[i];
    if (z === 0) out += ' ';
    else if (z >= 1 && z <= 3) i += 1; // abbreviation ref: skip operand (not expected in dict words)
    else if (z === 4) alphabet = 1;
    else if (z === 5) alphabet = 2;
    else {
      if (alphabet === 2 && z === 6) {
        // 10-bit ZSCII escape: consumes the next two z-chars
        const code = ((zchars[i + 1] ?? 0) << 5) | (zchars[i + 2] ?? 0);
        i += 2;
        out += String.fromCharCode(code);
      } else {
        const table = alphabet === 0 ? A0 : alphabet === 1 ? A1 : A2;
        out += table[z - 6] ?? '';
      }
      alphabet = 0;
    }
  }
  return out.trim();
}

/**
 * @param {Buffer} story  raw story file contents (any z-machine version)
 * @returns {string[]} dictionary words (truncated by the format itself:
 *   6 chars in v1-3, 9 chars in v4+)
 */
export function extractVocabulary(story) {
  const version = story.readUInt8(0);
  const textWords = version <= 3 ? 2 : 3;
  const dictAddr = story.readUInt16BE(0x08);
  let p = dictAddr;
  const numSeps = story.readUInt8(p);
  p += 1 + numSeps;
  const entryLen = story.readUInt8(p);
  p += 1;
  const count = story.readUInt16BE(p);
  p += 2;
  const words = [];
  for (let i = 0; i < count; i++) {
    const word = decodeEntryText(story, p + i * entryLen, textWords);
    if (word) words.push(word);
  }
  return words;
}

/** Word length the parser truncates to: 6 chars in v1-3, 9 in v4+. */
export function dictWordLength(story) {
  return story.readUInt8(0) <= 3 ? 6 : 9;
}
