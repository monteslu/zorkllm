"THE SILVER SHOES - main file.
An interactive wonder tale from The Wonderful Wizard of Oz (Baum, 1900),
built on the MIT-licensed Zork engine files (see zil/zork1). Compile:
  node czil/dist/czil-compile.mjs adventures/wizard-of-oz/oz.zil \
    -I zil/zork1 -I zil/engine-v8 -o adventures/wizard-of-oz/oz.z8"

<VERSION 8>

<SETG ZORK-NUMBER 0> ;"no trilogy-specific engine branches"

<SET REDEFINE T>

<OR <GASSIGNED? ZILCH>
    <SETG WBREAKS <STRING !\" !,WBREAKS>>>

<PRINC "The Silver Shoes: an interactive wonder tale
">

<FREQUENT-WORDS?>

<INSERT-FILE "GMACROS" T>
<INSERT-FILE "GSYNTAX" T>
<INSERT-FILE "OZSYNTAX" T>
;"GGLOBALS before the game's dungeon file so the parser's special
objects get low object numbers (see AUTHORING.md)."
<INSERT-FILE "GGLOBALS" T>
<INSERT-FILE "OZDUNGEON" T>

<PROPDEF SIZE 5>
<PROPDEF CAPACITY 0>
<PROPDEF VALUE 0>
<PROPDEF TVALUE 0>

<INSERT-FILE "GCLOCK" T>
<INSERT-FILE "GMAIN" T>
<INSERT-FILE "GPARSER" T>
<INSERT-FILE "GVERBS" T>
<VERSION? (ZIP) (T <INSERT-FILE "V8PATCH" T>)>
<INSERT-FILE "OZACTIONS" T>
<INSERT-FILE "OZWEST" T>
<INSERT-FILE "OZSOUTH" T>
