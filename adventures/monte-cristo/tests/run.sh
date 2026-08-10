#!/bin/sh
# Build the game and run every script.
#
#   verify.mjs      the winning walkthrough (400/400, frozen transcript)
#                   AND the wanderer (junk input must still reach Marseilles)
#   tests/*.txt     branch tests, checked by eye for their themed text
#   audit-game.mjs  static checks: rooms that name no exit, and places the
#                   game directs the player to in words the parser rejects
#
# The audit reports two known-good findings: Villefort's Study and the
# Island of Tiboulen genuinely have no exits. Both are scripted scenes
# that end themselves, and both now say so in their own text.
set -e
cd "$(dirname "$0")/.." || exit 1
ROOT=../..

echo "== compile"
node $ROOT/czil/dist/czil-compile.mjs cristo.zil \
  -I $ROOT/zil/zork1 -I $ROOT/zil/engine-v8 -o cristo.z8

echo "== verify (walkthrough + wanderer)"
node verify.mjs

for t in tests/*.txt; do
  echo "== $t"
  node $ROOT/czil/tests/play.mjs cristo.z8 "$t" | tail -4
done

echo "== static audit (2 known-good findings expected)"
(cd $ROOT && node tools/audit-game.mjs \
  adventures/monte-cristo/cristo.z8 \
  adventures/monte-cristo/walkthrough.txt) || true
