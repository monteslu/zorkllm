"WONDERLAND - an interactive nonsense, after Lewis Carroll.
Built on the MIT-licensed Zork engine files (zil/zork1). Compile with:
  node czil/dist/czil-compile.mjs adventures/alice/alice.zil
       -I zil/zork1 -I zil/engine-v8 -o adventures/alice/alice.z8"

<VERSION 8>

<SETG ZORK-NUMBER 0> ;"no trilogy-specific engine branches"

<SET REDEFINE T>

<OR <GASSIGNED? ZILCH>
    <SETG WBREAKS <STRING !\" !,WBREAKS>>>

<PRINC "WONDERLAND: an interactive nonsense
">

<FREQUENT-WORDS?>

<INSERT-FILE "GMACROS" T>
<INSERT-FILE "GSYNTAX" T>

";Filler words an LLM front end emits constantly. BUZZ makes the parser
 ignore them rather than reject the whole command: 'grab THAT jar',
 'go to THE door', 'i WANT to go north'. Roughly two thirds of natural
 language fails to parse (see walkthrough-wanderer-llm.txt); every word
 absorbed here is a turn the player gets back."

<BUZZ THAT THIS THESE THOSE MY YOUR SOME PLEASE JUST NOW OVER THERE
      REALLY VERY QUITE RATHER ABOUT AROUND AT WELL OK OKAY LETS LET
      I I'LL ILL IM I'M WANT TRY GUESS THINK MAYBE PERHAPS
      WOW WHOA HEY UM UH SO ANYWAY AGAIN>

"--- New verbs for Wonderland (spiked and proven before use) ---"

<SYNTAX CRY = V-CRY>
<SYNONYM CRY WEEP SOB>

<SYNTAX SING = V-SING>
<SYNTAX SING OBJECT = V-SING>

<SYNTAX DANCE = V-DANCE>

<SYNTAX RECITE = V-RECITE>
<SYNTAX RECITE OBJECT = V-RECITE>
<SYNONYM RECITE REPEAT>

<SYNTAX PAINT OBJECT = V-PAINT>
<SYNTAX PAINT OBJECT WITH OBJECT = V-PAINT>

<SYNTAX CURTSEY = V-CURTSEY>
<SYNTAX CURTSEY TO OBJECT = V-CURTSEY>
<SYNONYM CURTSEY CURTSY BOW>

<SYNTAX STROKE OBJECT = V-STROKE>

<SYNTAX WHISTLE = V-WHISTLE>

<SYNTAX RACE = V-RACE>

<SYNTAX SHOW OBJECT TO OBJECT = V-SHOW>

<SYNTAX REACH = V-REACH>
<SYNTAX REACH OUT OBJECT = V-REACH>
<SYNTAX REACH OBJECT = V-REACH>

<SYNTAX FAN OBJECT = V-FAN>

<SYNTAX RIGHT OBJECT = V-RIGHT>

<SYNTAX REFUSE = V-REFUSE>
<SYNONYM REFUSE PROTEST>

<SYNTAX THREATEN = V-THREATEN>
<SYNTAX THREATEN OBJECT = V-THREATEN>

<SYNTAX NONSENSE = V-NONSENSE>

<SYNTAX YES = V-YES>
<SYNTAX NO = V-NO>

<SYNTAX STUFF = V-NONSENSE>

"--- Additional syntax lines for engine verbs ---"

<SYNTAX ATTACK OBJECT (FIND ACTORBIT) (ON-GROUND IN-ROOM) = V-ATTACK>
<SYNTAX THROW OBJECT (HELD CARRIED HAVE) = V-THROW>
<SYNTAX SAY OBJECT = V-SAY-WORD>
<SYNTAX CLIMB = V-SIT>
<SYNTAX KICK = V-KICK-BARE>
<SYNTAX LISTEN = V-LISTEN-BARE>
<SYNONYM EAT NIBBLE>

;"GGLOBALS comes BEFORE the game's own dungeon file (the reverse of the
Zork ordering) so the parser's special objects (IT, NOT-HERE-OBJECT,
INTNUM...) get low object numbers. See AUTHORING.md."
<INSERT-FILE "GGLOBALS" T>
<INSERT-FILE "ADUNGEON" T>

<PROPDEF SIZE 5>
<PROPDEF CAPACITY 0>
<PROPDEF VALUE 0>
<PROPDEF TVALUE 0>

<INSERT-FILE "GCLOCK" T>
<INSERT-FILE "GMAIN" T>
<INSERT-FILE "GPARSER" T>
<INSERT-FILE "GVERBS" T>
<VERSION? (ZIP) (T <INSERT-FILE "V8PATCH" T>)>
<INSERT-FILE "AACTIONS" T>
<INSERT-FILE "AACTION2" T>
<INSERT-FILE "AACTION3" T>
