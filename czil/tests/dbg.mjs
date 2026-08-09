// Debug: raw io adapter with output cap to see what a hang is printing.
import { readFile } from 'node:fs/promises';
const { ZMachine } = await import(new URL('../../vendor/zmachine.mjs', import.meta.url));

const story = await readFile(process.argv[2]);
const commands = process.argv.slice(3);
let printed = 0;
let queue = [...commands];
const io = {
  initialize() {},
  print(t) {
    printed += t.length;
    if (printed < 4000) process.stdout.write(t);
    else if (printed - t.length < 4000) process.stdout.write('\n[...OUTPUT CAP HIT...]\n');
    if (printed > 200000) { console.log('\n[RUNAWAY OUTPUT, aborting]'); process.exit(4); }
  },
  printLine(t) { io.print(t + '\n'); },
  newLine() { io.print('\n'); },
  readLine() {
    const cmd = queue.shift();
    if (cmd === undefined) { console.log('\n[out of script]'); process.exit(0); }
    io.print(`\n> ${cmd}\n`);
    return Promise.resolve({ text: cmd, terminator: 13 });
  },
  readChar() { return Promise.resolve(13); },
  quit() { console.log('[quit]'); process.exit(0); },
  restart() {},
  showStatusLine() {}, setWindow() {}, splitWindow() {}, eraseWindow() {},
  setTextStyle() {}, setBufferMode() {}, getBufferMode: () => true,
  setCursor() {}, eraseLine() {}, verify: () => true,
  save() { return Promise.resolve(false); }, restore() { return Promise.resolve(null); },
};
setTimeout(() => { console.log('\n[10s TIMEOUT - hang without output]'); process.exit(3); }, 10000);
const zm = ZMachine.load(story, io);
await zm.run();
