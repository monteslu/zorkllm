#!/usr/bin/env node
// Hand-rolled loader for czil.wasm - no emscripten runtime, no WASI
// dependency. The module's whole ABI is one host import (read_file) plus
// stdio writes; everything else is exported functions and shared memory.
//
// Usage: node czil-compile.mjs game.zil -o game.z3 [-r n] [-s serial] [-I dir]
import { readFileSync, writeFileSync, statSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const argv = process.argv.slice(2);
let root = null, out = null, serial = '', release = 1, zversion = 0;
const includes = [];
for (let i = 0; i < argv.length; i++) {
  if (argv[i] === '-o') out = argv[++i];
  else if (argv[i] === '-r') release = parseInt(argv[++i], 10) || 1;
  else if (argv[i] === '-s') serial = argv[++i];
  else if (argv[i] === '-I') includes.push(argv[++i]);
  else if (argv[i] === '-v') zversion = parseInt(argv[++i], 10) || 0;
  else root = argv[i];
}
if (!root || !out) {
  console.error('usage: czil-compile.mjs game.zil -o game.z3 [-r release] [-s serial] [-I dir]');
  process.exit(2);
}

const wasmPath = join(dirname(fileURLToPath(import.meta.url)), 'czil.wasm');
let memory;
const text = new TextDecoder();
const str = (ptr, len) => text.decode(new Uint8Array(memory.buffer, ptr, len));

const { instance } = await WebAssembly.instantiate(readFileSync(wasmPath), {
  host: {
    read_file(pathPtr, pathLen, destPtr, destCap) {
      const path = str(pathPtr, pathLen);
      try {
        if (destCap === 0) return statSync(path).size;
        const data = readFileSync(path);
        const n = Math.min(data.length, destCap);
        new Uint8Array(memory.buffer, destPtr, n).set(data.subarray(0, n));
        return n;
      } catch {
        return -1;
      }
    },
  },
  env: { emscripten_notify_memory_growth: () => {} },
  wasi_snapshot_preview1: {
    fd_write(fd, iovsPtr, iovsLen, nwrittenPtr) {
      const view = new DataView(memory.buffer);
      let written = 0;
      for (let i = 0; i < iovsLen; i++) {
        const ptr = view.getUint32(iovsPtr + i * 8, true);
        const len = view.getUint32(iovsPtr + i * 8 + 4, true);
        (fd === 2 ? process.stderr : process.stdout).write(str(ptr, len));
        written += len;
      }
      view.setUint32(nwrittenPtr, written, true);
      return 0;
    },
    fd_read: () => 0,
    fd_close: () => 0,
    fd_seek: () => 0,
    environ_sizes_get(countPtr, sizePtr) {
      const view = new DataView(memory.buffer);
      view.setUint32(countPtr, 0, true);
      view.setUint32(sizePtr, 0, true);
      return 0;
    },
    environ_get: () => 0,
  },
});
memory = instance.exports.memory;
instance.exports._initialize();

const stage = (s) => {
  const bytes = new TextEncoder().encode(s + '\0');
  const ptr = instance.exports.malloc(bytes.length);
  new Uint8Array(memory.buffer, ptr, bytes.length).set(bytes);
  return ptr;
};

const rc = instance.exports.czil_compile(stage(root), release, stage(serial), stage(includes.join(':')), zversion);
if (rc !== 0) {
  const errPtr = instance.exports.czil_error();
  const errBytes = new Uint8Array(memory.buffer, errPtr, 1024);
  console.error('compile failed:', str(errPtr, errBytes.indexOf(0)));
  process.exit(1);
}
const len = instance.exports.czil_output_len();
writeFileSync(out, new Uint8Array(memory.buffer, instance.exports.czil_output(), len));
console.log(`${out}: ${len} bytes`);
