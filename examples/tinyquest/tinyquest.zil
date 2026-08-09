"TINYQUEST main file - a three-room example adventure built on the
MIT-licensed Zork engine files (see zil/zork1). Compile with:
  czil-compile tinyquest.zil -I ../../zil/zork1 -o tinyquest.z3"

<VERSION ZIP>

<SETG ZORK-NUMBER 0> ;"no trilogy-specific engine branches"

<SET REDEFINE T>

<OR <GASSIGNED? ZILCH>
    <SETG WBREAKS <STRING !\" !,WBREAKS>>>

<PRINC "Tiny Quest: an example adventure
">

<FREQUENT-WORDS?>

<INSERT-FILE "GMACROS" T>
<INSERT-FILE "GSYNTAX" T>
;"GGLOBALS comes BEFORE the game's own dungeon file (the reverse of the
Zork ordering) so the parser's special objects (IT, NOT-HERE-OBJECT,
INTNUM...) get low object numbers. PERFORM compares IT against PRSO,
and for WALK PRSO is a direction PROPERTY number (19-31) - an object
numbered in that range breaks movement. Keeping the engine's handful of
objects below 19 makes any size of game safe."
<INSERT-FILE "GGLOBALS" T>
<INSERT-FILE "TDUNGEON" T>

<PROPDEF SIZE 5>
<PROPDEF CAPACITY 0>
<PROPDEF VALUE 0>
<PROPDEF TVALUE 0>

<INSERT-FILE "GCLOCK" T>
<INSERT-FILE "GMAIN" T>
<INSERT-FILE "GPARSER" T>
<INSERT-FILE "GVERBS" T>
<INSERT-FILE "TACTIONS" T>
