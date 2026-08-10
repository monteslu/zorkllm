#!/bin/sh
# Build the game and run every script: the winning walkthrough (which must
# score 400 and match the frozen transcript) plus the branch tests, which
# are checked by eye for their themed text but at least must not crash.
set -e
cd "$(dirname "$0")/.." || exit 1
ROOT=../..

echo "== compile"
node $ROOT/czil/dist/czil-compile.mjs cristo.zil \
  -I $ROOT/zil/zork1 -I $ROOT/zil/engine-v8 -o cristo.z8

echo "== verify (walkthrough, 400/400, frozen transcript)"
node verify.mjs

node verify.mjs >/dev/null && echo "   wanderer: ok"

for t in tests/*.txt; do
  echo "== $t"
  node $ROOT/czil/tests/play.mjs cristo.z8 "$t" | tail -4
done
