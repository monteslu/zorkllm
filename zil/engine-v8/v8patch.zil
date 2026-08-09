"V8PATCH - overlay redefinitions that adapt the v3 Zork engine files to
v5/v8 story-file formats. Inserted by a game's main file after GVERBS
when compiling with -v 8 (czil applies the LAST definition of any
constant or routine, so nothing in zil/zork1 is modified).

Two format differences from v3:
 - dictionary entries carry 6 text bytes (9 z-chars), so the
   part-of-speech byte moves from offset 4 to 6 and values to 7/8;
 - adjectives have no per-word number; the word pointer itself is the
   identity, and object ADJECTIVE properties hold dictionary words."

<CONSTANT P-PSOFF 6> ;"v8: part of speech byte after 6 text bytes"
<CONSTANT P-P1OFF 7> ;"v8: first value byte"

<ROUTINE WT? (PTR BIT "OPTIONAL" (B1 5) "AUX" (OFFS ,P-P1OFF) TYP)
	<COND (<BTST <SET TYP <GETB .PTR ,P-PSOFF>> .BIT>
	       <COND (<G? .B1 4> <RTRUE>)
		     (<EQUAL? .B1 ,P1?ADJECTIVE>
		      ;"v8 adjectives have no number: the word IS the value"
		      .PTR)
		     (T
		      <SET TYP <BAND .TYP ,P-P1BITS>>
		      <COND (<NOT <EQUAL? .TYP .B1>> <SET OFFS <+ .OFFS 1>>)>
		      <GETB .PTR .OFFS>)>)>>

<ROUTINE THIS-IT? (OBJ TBL "AUX" SYNS)
 <COND (<FSET? .OBJ ,INVISIBLE> <RFALSE>)
       (<AND ,P-NAM
	     <NOT <ZMEMQ ,P-NAM
			 <SET SYNS <GETPT .OBJ ,P?SYNONYM>>
			 <- </ <PTSIZE .SYNS> 2> 1>>>>
	<RFALSE>)
       (<AND ,P-ADJ
	     <OR <NOT <SET SYNS <GETPT .OBJ ,P?ADJECTIVE>>>
		 ;"v8: adjective properties are dictionary words"
		 <NOT <ZMEMQ ,P-ADJ .SYNS <- </ <PTSIZE .SYNS> 2> 1>>>>>
	<RFALSE>)
       (<AND <NOT <ZERO? ,P-GWIMBIT>> <NOT <FSET? .OBJ ,P-GWIMBIT>>>
	<RFALSE>)>
 <RTRUE>>
