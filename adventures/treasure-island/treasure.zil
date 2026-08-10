"TREASURE ISLAND: A Tale of the Sea-Cook - main file.
Freely adapted from Robert Louis Stevenson for the zorkllm toolchain.
Compile (v8, from the repo root):
  node czil/dist/czil-compile.mjs adventures/treasure-island/treasure.zil \
    -I zil/zork1 -I zil/engine-v8 -o adventures/treasure-island/treasure.z8"

<VERSION 8>

<SETG ZORK-NUMBER 0> ;"no trilogy-specific engine branches"

<SET REDEFINE T>

<OR <GASSIGNED? ZILCH>
    <SETG WBREAKS <STRING !\" !,WBREAKS>>>

<PRINC "Treasure Island: A Tale of the Sea-Cook
">

<FREQUENT-WORDS?>

<INSERT-FILE "GMACROS" T>
<INSERT-FILE "GSYNTAX" T>
;"GGLOBALS comes BEFORE the game's own dungeon file so the parser's
special objects (IT, NOT-HERE-OBJECT, INTNUM...) get low object numbers
that can never collide with direction property numbers."
<INSERT-FILE "GGLOBALS" T>
<INSERT-FILE "TIDUNGEON" T>

<PROPDEF SIZE 5>
<PROPDEF CAPACITY 0>
<PROPDEF VALUE 0>
<PROPDEF TVALUE 0>

<INSERT-FILE "GCLOCK" T>
<INSERT-FILE "GMAIN" T>
<INSERT-FILE "GPARSER" T>
<INSERT-FILE "GVERBS" T>
;"v8 overlay: adapts the parser internals to the 9-char dictionary."
<VERSION? (ZIP) (T <INSERT-FILE "V8PATCH" T>)>
<INSERT-FILE "TIACTIONS" T>
