#!/bin/bash
# czil stage-2 acceptance: the reader must parse the entire MIT-licensed
# Zork trilogy source, match structural counts, round-trip expressions,
# and reject garbage (controls that must fail).
set -u
cd "$(dirname "$0")/.."
PASS=0; FAIL=0
ok()   { PASS=$((PASS+1)); echo "  ok - $1"; }
bad()  { FAIL=$((FAIL+1)); echo "  FAIL - $1"; }

check() { # label, expr, expected-output
  local got
  got=$(./czil-read -e "$2" 2>&1)
  [ "$got" = "$3" ] && ok "$1" || bad "$1 (got: $got)"
}

echo "trilogy parse:"
for dir in ../zil/zork1 ../zil/zork2 ../zil/zork3; do
  if ./czil-read "$dir"/*.zil > /dev/null 2>&1; then
    ok "all files in $dir parse"
  else
    bad "$dir has parse failures:"; ./czil-read "$dir"/*.zil | grep FAIL
  fi
done

echo "structural cross-check (top-level OBJECT/ROOM forms vs grep):"
for f in ../zil/zork1/1dungeon.zil ../zil/zork1/gglobals.zil; do
  want=$(grep -cE '^<(OBJECT|ROOM)[[:space:]]' "$f")
  got=$(./czil-read -d "$f" 2>/dev/null | grep -cE '^<(OBJECT|ROOM)[[:space:]]')
  [ "$want" = "$got" ] && ok "$f: $got OBJECT/ROOM forms" || bad "$f: want $want got $got"
done

echo "expression semantics:"
check "decimal fix"        "42"            "42"
check "negative fix"       "-7"            "-7"
check "octal *3777*"       "*3777*"        "2047"
check "binary #2"          "#2 1010"       "10"
check "hex #16"            "#16 FF"        "255"
check "lval sugar"         ".X"            ".X"
check "gval sugar"         ",WBREAKS"      ",WBREAKS"
check "quote sugar"        "'FOO"          "'FOO"
check "gval segment"       "!,W"           "!,W"
check "form segment"       '!<STR !\" X>' '!<STR !\" X>'
check "empty form (FALSE)" "<>"            "<>"
check "adecl"              "X:FIX"         "X:FIX"
check "chtype deferred"    "#DECL ((A) B)" "#DECL ((A) B)"
check "readeval deferred"  "%<COND (T 1)>" "%<COND (T 1)>"
check "escaped atom"       'FCD\#3'        "FCD#3"
check "bang dropped in atom" "A!B"         "AB"
check "oblist suffix kept" "FOO!-INITIAL"  "FOO!-INITIAL"
check "string escapes"     '"a\"b"'        '"a\"b"'
check "comment skipped"    ';"note" 5'     "5"
check "commented form skipped" ";<FOO BAR> 9" "9"
check "line comment"       ";;junk
7" "7"

echo "controls (must fail):"
for bad_input in "<FOO" "(A B" '"unterminated' "<A ]>" "!!X"; do
  if ./czil-read -e "$bad_input" >/dev/null 2>&1; then
    bad "accepted garbage: $bad_input"
  else
    ok "rejects: $bad_input"
  fi
done

echo "evaluator (converted zilf interpreter tests + czil additions):"
if out=$(./czil-eval -t tests/eval.t 2>&1); then
  ok "eval.t: ${out##*$'\n'}"
else
  bad "eval.t failures:"; echo "$out"
fi

# Note: each game has 63 textual %<COND occurrences but 62 swept nodes;
# the 63rd (gmain.zil ~line 185) is inside a ;-commented-out form the
# reader drops. It is a pure GASSIGNED? check, no side effects lost.
echo "trilogy READEVAL sweep (every %<...> macro in all three games must evaluate):"
for n in 1 2 3; do
  if out=$(./czil-eval --sweep -z $n ../zil/zork$n/*.zil 2>&1); then
    ok "zork$n: $out"
  else
    bad "zork$n sweep failed:"; echo "$out"
  fi
done

echo "sweep controls (must fail):"
if echo '%<NOSUCHSUBR 1>' > /tmp/czil-sweep-control.zil && \
   ./czil-eval --sweep /tmp/czil-sweep-control.zil >/dev/null 2>&1; then
  bad "sweep accepted an unevaluable READEVAL"
else
  ok "sweep rejects unevaluable READEVAL"
fi
rm -f /tmp/czil-sweep-control.zil

echo "stage 4: Z-model vs the shipped MIT-licensed story files:"
Z3DIR=../games
SCRATCH=$(mktemp -d)
trap 'rm -rf "$SCRATCH"' EXIT
for n in 1 2 3; do
  root=../zil/zork$n/zork$n.zil
  z3=$Z3DIR/zork$n.z3
  if ! ./czil-build --stats "$root" > "$SCRATCH/stats$n.txt" 2>&1; then
    bad "zork$n model build failed:"; cat "$SCRATCH/stats$n.txt"
    continue
  fi
  ok "zork$n model builds ($(grep '^objects' "$SCRATCH/stats$n.txt"))"

  want=$(./z3dict "$z3" counts)
  got=$(./czil-build --objects "$root" | wc -l)
  [ "$want" = "$got" ] && ok "zork$n object count matches shipped z3 ($got)" \
                       || bad "zork$n object count: shipped $want, czil $got"

  ./z3dict "$z3" objects | LC_ALL=C sort > "$SCRATCH/descs-real.txt"
  ./czil-build --descs "$root" | LC_ALL=C sort > "$SCRATCH/descs-czil.txt"
  if LC_ALL=C comm -3 "$SCRATCH/descs-real.txt" "$SCRATCH/descs-czil.txt" | grep -q .; then
    bad "zork$n object short names differ from shipped z3:"
    LC_ALL=C comm -3 "$SCRATCH/descs-real.txt" "$SCRATCH/descs-czil.txt" | head -10
  else
    ok "zork$n object short names match shipped z3 exactly"
  fi

  ./z3dict "$z3" | LC_ALL=C sort -u > "$SCRATCH/dict-real.txt"
  ./czil-build --vocab "$root" | LC_ALL=C sort -u > "$SCRATCH/dict-czil.txt"
  LC_ALL=C comm -3 "$SCRATCH/dict-real.txt" "$SCRATCH/dict-czil.txt" > "$SCRATCH/dict-diff.txt"
  if [ $n = 3 ]; then
    # Expected single delta: ZILF (and czil) put every <DIRECTIONS> word in
    # the vocabulary; the original ZILCH only emitted directions that some
    # room exit used. zork3 declares LAND but never uses it.
    if [ "$(cat "$SCRATCH/dict-diff.txt")" = "$(printf '\tland')" ]; then
      ok "zork3 dictionary matches shipped z3 (+ 'land' from DIRECTIONS, documented ZILF delta)"
    else
      bad "zork3 dictionary diff is not the expected single 'land' entry:"
      head -10 "$SCRATCH/dict-diff.txt"
    fi
  else
    if grep -q . "$SCRATCH/dict-diff.txt"; then
      bad "zork$n dictionary differs from shipped z3:"; head -10 "$SCRATCH/dict-diff.txt"
    else
      ok "zork$n dictionary matches shipped z3 exactly ($(wc -l < "$SCRATCH/dict-real.txt") words)"
    fi
  fi
done

echo "stage 4 controls (must fail):"
# differ self-test: zork1's vocabulary vs the WRONG oracle must not match
./z3dict "$Z3DIR/zork2.z3" | LC_ALL=C sort -u > "$SCRATCH/dict-wrong.txt"
./czil-build --vocab ../zil/zork1/zork1.zil | LC_ALL=C sort -u > "$SCRATCH/dict-z1.txt"
if LC_ALL=C comm -3 "$SCRATCH/dict-wrong.txt" "$SCRATCH/dict-z1.txt" | grep -q .; then
  ok "differ control: zork1 vocab vs zork2 dictionary does differ"
else
  bad "differ control FAILED: zork1 vocab matched the zork2 dictionary"
fi
printf '<SYNTAX BROKEN OBJECT V-MISSING-EQUALS>' > "$SCRATCH/broken.zil"
if ./czil-build --stats "$SCRATCH/broken.zil" >/dev/null 2>&1; then
  bad "model build accepted a SYNTAX with no '='"
else
  ok "model build rejects a SYNTAX with no '='"
fi
printf '<ROUTINE NO-BODY (X)>' > "$SCRATCH/broken2.zil"
if ./czil-build --stats "$SCRATCH/broken2.zil" >/dev/null 2>&1; then
  bad "model build accepted a bodyless ROUTINE"
else
  ok "model build rejects a bodyless ROUTINE"
fi

echo "stage 5: compile to .z3 and diff transcripts against the shipped games:"
# release/serial per shipped banner so the version line matches too
declare -A REL=( [1]="119 880429" [2]="63 860811" [3]="25 860811" )
for n in 1 2 3; do
  set -- ${REL[$n]}
  if ! ./czil-compile ../zil/zork$n/zork$n.zil -o "$SCRATCH/z$n.z3" -r "$1" -s "$2" > "$SCRATCH/cc$n.log" 2>&1; then
    bad "zork$n compile failed:"; cat "$SCRATCH/cc$n.log"
    continue
  fi
  ok "zork$n compiles ($(grep -oE '[0-9]+ bytes' "$SCRATCH/cc$n.log"))"

  wt=tests/walkthrough-generic.txt
  [ $n = 1 ] && wt=tests/walkthrough-zork1.txt
  if ! timeout 120 node tests/play.mjs "$SCRATCH/z$n.z3" "$wt" > "$SCRATCH/wt$n-czil.txt" 2>&1; then
    bad "zork$n czil walkthrough did not finish"; tail -3 "$SCRATCH/wt$n-czil.txt"
    continue
  fi
  if ! timeout 120 node tests/play.mjs "$Z3DIR/zork$n.z3" "$wt" > "$SCRATCH/wt$n-real.txt" 2>&1; then
    bad "zork$n shipped walkthrough did not finish"
    continue
  fi
  if diff -q "$SCRATCH/wt$n-real.txt" "$SCRATCH/wt$n-czil.txt" > /dev/null; then
    ok "zork$n transcript identical to shipped ($(grep -c '^> ' "$SCRATCH/wt$n-czil.txt") commands)"
  else
    bad "zork$n transcript differs from shipped:"
    diff "$SCRATCH/wt$n-real.txt" "$SCRATCH/wt$n-czil.txt" | head -10
  fi
done

echo "stage 5 controls (must fail):"
# corrupt the first executed instruction: the differ must notice
cp "$SCRATCH/z1.z3" "$SCRATCH/z1-corrupt.z3"
startpc=$(od -An -tu1 -j6 -N2 "$SCRATCH/z1-corrupt.z3" | awk '{print $1*256+$2}')
printf '\xBA' | dd of="$SCRATCH/z1-corrupt.z3" bs=1 seek=$startpc conv=notrunc 2>/dev/null
timeout 30 node tests/play.mjs "$SCRATCH/z1-corrupt.z3" tests/walkthrough-zork1.txt > "$SCRATCH/wt1-corrupt.txt" 2>&1
if diff -q "$SCRATCH/wt1-real.txt" "$SCRATCH/wt1-corrupt.txt" > /dev/null 2>&1; then
  bad "transcript differ did not notice a corrupted story file"
else
  ok "transcript differ notices a corrupted story file"
fi


echo "example game (the authoring-guide walkthrough must replay exactly):"
if ./czil-compile ../examples/tinyquest/tinyquest.zil -I ../zil/zork1 -o "$SCRATCH/tinyquest.z3" > /dev/null 2>&1; then
  ok "tinyquest compiles against the engine files"
  timeout 60 node tests/play.mjs "$SCRATCH/tinyquest.z3" ../examples/tinyquest/walkthrough.txt > "$SCRATCH/tq.txt" 2>&1
  if diff -q ../examples/tinyquest/expected-transcript.txt "$SCRATCH/tq.txt" > /dev/null; then
    ok "tinyquest walkthrough transcript matches (10/10 points)"
  else
    bad "tinyquest transcript changed:"; diff ../examples/tinyquest/expected-transcript.txt "$SCRATCH/tq.txt" | head -8
  fi
else
  bad "tinyquest failed to compile"
fi


echo "v8 backend (same game, 4x address space, transcript-identical):"
if ./czil-compile ../examples/tinyquest/tinyquest.zil -I ../zil/zork1 -I ../zil/engine-v8 \
     -o "$SCRATCH/tinyquest8.z8" -v 8 > /dev/null 2>&1; then
  ok "tinyquest compiles as v8"
  timeout 60 node tests/play.mjs "$SCRATCH/tinyquest8.z8" ../examples/tinyquest/walkthrough.txt > "$SCRATCH/tq8.txt" 2>&1
  grep -v '^\[status' ../examples/tinyquest/expected-transcript.txt > "$SCRATCH/tq3-clean.txt"
  grep -v '^\[status' "$SCRATCH/tq8.txt" > "$SCRATCH/tq8-clean.txt"
  if diff -q "$SCRATCH/tq3-clean.txt" "$SCRATCH/tq8-clean.txt" > /dev/null; then
    ok "v8 gameplay transcript identical to v3 (status lines aside)"
  else
    bad "v8 transcript differs from v3:"; diff "$SCRATCH/tq3-clean.txt" "$SCRATCH/tq8-clean.txt" | head -8
  fi
else
  bad "tinyquest v8 compile failed"
fi

echo
echo "czil tests: $PASS passed, $FAIL failed"
[ $FAIL -eq 0 ]
