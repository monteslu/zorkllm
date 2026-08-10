#!/bin/sh
# Build the game and run every script.
#
#   verify.mjs      the winning walkthrough (400/400, frozen transcript)
#                   AND the wanderer (junk input must still reach Marseilles)
#   tests/*.txt     branch tests, checked by eye for their themed text
#   audit-game.mjs  static checks: rooms that name no exit, and places the
#                   game directs the player to in words the parser rejects
#
# Expected findings, all judged and deliberate:
#   audit-game   Villefort's Study and the Island of Tiboulen genuinely
#                have no exits; both are scripted scenes that end
#                themselves and both say so in their own text.
#   audit-mlook  CELL27 suppresses its LDESC only while the player is
#                sewn inside the burial sack.
#
# verify.mjs additionally asserts, with controls proved by reintroducing
# each bug: the wanderer reaches Marseilles, hand-rolled takes are
# visible in INVENTORY, and exactly one disguise is worn at a time.
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

# CELL27 is the one expected finding: its M-LOOK suppresses the LDESC only
# while the player is sewn inside the burial sack, which correctly names
# no exit.
echo "== M-LOOK audit (1 known-good finding expected)"
(cd $ROOT && node tools/audit-mlook.mjs monte-cristo) || true
