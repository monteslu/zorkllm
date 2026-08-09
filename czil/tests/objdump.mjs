import { readFile } from 'node:fs/promises';
const m = await readFile(process.argv[2]);
const rw = (a) => (m[a] << 8) | m[a + 1];
const objtab = rw(0x0a);
const count = Number(process.argv[4] ?? 250);
const A2 = "\x00\n0123456789.,!?_#'\"/\\-:()";
function decodeStr(addr) {
  let out = '', shift = 0, zcs = [];
  for (;;) { const w = rw(addr); addr += 2; zcs.push((w>>10)&31,(w>>5)&31,w&31); if (w & 0x8000) break; }
  for (let i = 0; i < zcs.length; i++) {
    const z = zcs[i];
    if (z === 0) { out += ' '; shift = 0; }
    else if (z <= 3) { i++; shift = 0; }
    else if (z === 4) shift = 1;
    else if (z === 5) shift = 2;
    else if (shift === 2 && z === 6) { out += String.fromCharCode((zcs[i+1]<<5)|zcs[i+2]); i += 2; shift = 0; }
    else { out += shift === 0 ? String.fromCharCode(97+z-6) : shift === 1 ? String.fromCharCode(65+z-6) : A2[z-6]; shift = 0; }
  }
  return out;
}
for (let i = 0; i < count; i++) {
  const e = objtab + 62 + i * 9;
  const props = rw(e + 7);
  const tl = m[props];
  const name = tl ? decodeStr(props + 1) : '';
  if (name !== process.argv[3]) continue;
  console.log(`object ${i+1}: "${name}" parent=${m[e+4]} sibling=${m[e+5]} child=${m[e+6]}`);
  let p = props + 1 + tl * 2;
  while (m[p]) {
    const size = (m[p] >> 5) + 1, num = m[p] & 31;
    console.log(`  prop ${num} len ${size}: ${[...m.slice(p+1, p+1+size)].map(x=>x.toString(16).padStart(2,'0')).join(' ')}`);
    p += 1 + size;
  }
}
