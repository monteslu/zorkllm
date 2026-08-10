"THE COUNT OF MONTE CRISTO - main file.
An interactive tragedy of patience, built on the MIT-licensed Zork
engine files (see zil/zork1). Compile (v8):
  node czil/dist/czil-compile.mjs adventures/monte-cristo/cristo.zil
    -I zil/zork1 -I zil/engine-v8 -o adventures/monte-cristo/cristo.z8"

<VERSION 8>

<SETG ZORK-NUMBER 0> ;"no trilogy-specific engine branches"

<SET REDEFINE T>

<OR <GASSIGNED? ZILCH>
    <SETG WBREAKS <STRING !\" !,WBREAKS>>>

<PRINC "The Count of Monte Cristo: an interactive tragedy of patience
">

<FREQUENT-WORDS?>

<INSERT-FILE "GMACROS" T>
<INSERT-FILE "GSYNTAX" T>
;"GGLOBALS comes BEFORE the game's own dungeon files so the parser's
special objects (IT, NOT-HERE-OBJECT, INTNUM...) get low object
numbers, below the direction property range that PERFORM compares
against for movement."
<INSERT-FILE "GGLOBALS" T>
<INSERT-FILE "CDUNGEON" T>
<INSERT-FILE "CPARIS" T>

<PROPDEF SIZE 5>
<PROPDEF CAPACITY 0>
<PROPDEF VALUE 0>
<PROPDEF TVALUE 0>
<PROPDEF TEXT 0>

<INSERT-FILE "GCLOCK" T>
<INSERT-FILE "GMAIN" T>
<INSERT-FILE "GPARSER" T>
<INSERT-FILE "GVERBS" T>
;"v8 overlay: adapts the parser internals to the 9-character v8
dictionary. Loads only for non-v3 builds."
<VERSION? (ZIP) (T <INSERT-FILE "V8PATCH" T>)>
<INSERT-FILE "CACTIONS" T>
<INSERT-FILE "CACTION2" T>
