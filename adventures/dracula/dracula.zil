"DRACULA: The Un-Dead - main file.
A text adventure adaptation of Bram Stoker's novel, built on the
MIT-licensed Zork engine files (see zil/zork1). Compile with:
  node czil/dist/czil-compile.mjs adventures/dracula/dracula.zil
    -I zil/zork1 -I zil/engine-v8 -o adventures/dracula/dracula.z8"

<VERSION 8>

<SETG ZORK-NUMBER 0> ;"no trilogy-specific engine branches"

<SET REDEFINE T>

<OR <GASSIGNED? ZILCH>
    <SETG WBREAKS <STRING !\" !,WBREAKS>>>

<PRINC "Dracula: The Un-Dead
">

<FREQUENT-WORDS?>

<INSERT-FILE "GMACROS" T>
<INSERT-FILE "GSYNTAX" T>
;"GGLOBALS comes BEFORE the game's own dungeon file so the parser's
special objects (IT, NOT-HERE-OBJECT, INTNUM...) get low object numbers,
below the direction property range PERFORM compares them against."
<INSERT-FILE "GGLOBALS" T>
<INSERT-FILE "DWORLD" T>

<PROPDEF SIZE 5>
<PROPDEF CAPACITY 0>
<PROPDEF VALUE 0>
<PROPDEF TVALUE 0>

<INSERT-FILE "GCLOCK" T>
<INSERT-FILE "GMAIN" T>
<INSERT-FILE "GPARSER" T>
<INSERT-FILE "GVERBS" T>
;"v5/v8 overlay for the format-dependent parser internals."
<VERSION? (ZIP) (T <INSERT-FILE "V8PATCH" T>)>
<INSERT-FILE "DVERBS" T>
<INSERT-FILE "DACT1" T>
<INSERT-FILE "DACT2" T>
<INSERT-FILE "DACT3" T>
