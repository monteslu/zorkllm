"CACTIONS - The Count of Monte Cristo: engine hooks, globals, new verbs,
and the action routines for Acts I, II and III."

"=== Engine-required content-side routines ==="

<GLOBAL SCORE-MAX 400>

<ROUTINE V-SCORE ("OPTIONAL" (ASK? T))
	 <TELL "Your score is " N ,SCORE>
	 <TELL " of a possible " N ,SCORE-MAX ", in " N ,MOVES>
	 <COND (<1? ,MOVES> <TELL " turn.">)
	       (T <TELL " turns.">)>
	 <CRLF>
	 <TELL "Your rank: " <RANK-NAME> "." CR>
	 ,SCORE>

<ROUTINE RANK-NAME ()
	 <COND (<G? ,SCORE 399> "Wait and Hope")
	       (<G? ,SCORE 349> "The Count of Monte Cristo")
	       (<G? ,SCORE 299> "The Avenger")
	       (<G? ,SCORE 249> "Master of Monte Cristo")
	       (<G? ,SCORE 199> "Sinbad the Sailor")
	       (<G? ,SCORE 149> "The Man Who Escaped the Chateau d'If")
	       (<G? ,SCORE 99> "Pupil of the Abbe Faria")
	       (<G? ,SCORE 49> "Prisoner Number 34")
	       (<G? ,SCORE 24> "First Mate of the Pharaon")
	       (T "Ship's Boy")>>

<ROUTINE V-DIAGNOSE ()
	 <COND (<EQUAL? ,ACT 2>
		<TELL "You are thin, and filthy, and alive." CR>)
	       (T <TELL "You are in perfect health." CR>)>>

;"Death. Callers that need more than one paragraph TELL it themselves
and pass the empty string, because a v3-shaped call takes three
arguments and a Dumas obituary does not fit in one."
<ROUTINE JIGS-UP (DESC "OPTIONAL" (PLAYER? <>))
	 <COND (<NOT <EQUAL? .DESC "">> <TELL .DESC CR>)>
	 <CRLF>
	 <TELL "    ****  You have died  ****" CR CR>
	 <V-SCORE>
	 <QUIT>>

<ROUTINE FIND-WEAPON (WHO) <RFALSE>>

"=== Game globals ==="

<GLOBAL ACT 1>
<GLOBAL PHASE 0>		;"Act II phase machine"
<GLOBAL IDENTITY 0>		;"0 Edmond 1 Busoni 2 Wilmore 3 the Count 4 sailor"
<GLOBAL SCENE-LOCK <>>		;"suspends the jailer demon during scripted scenes"

"Act I flags"
<GLOBAL SAILS-FURLED <>>
<GLOBAL DOCKED <>>
<GLOBAL CAPTAINCY <>>
<GLOBAL FATHER-PAID <>>
<GLOBAL KISSED <>>
<GLOBAL FEAST-CALLED <>>
<GLOBAL FEAST-TURNS 0>
<GLOBAL MORREL-TALKED <>>
<GLOBAL VILL-TURNS 0>
<GLOBAL LETTER-GIVEN <>>

"Act II flags"
<GLOBAL HEARD-SOUND <>>
<GLOBAL KNOCKED <>>
<GLOBAL SOUND-BACK <>>
<GLOBAL JUG-BROKEN <>>
<GLOBAL BED-MOVED <>>
<GLOBAL WALL-DUG <>>
<GLOBAL PLATE-SET <>>
<GLOBAL PAN-LEFT <>>
<GLOBAL HANDLE-OUT <>>
<GLOBAL STONE-PRIED <>>
<GLOBAL DIG-COUNT 0>
<GLOBAL BEAM-HIT <>>
<GLOBAL CATECHISM <>>
<GLOBAL TUNNEL-OPEN <>>
<GLOBAL ENEMY-COUNT 0>
<GLOBAL SAID-DANG <>>
<GLOBAL SAID-FERN <>>
<GLOBAL SAID-VILL <>>
<GLOBAL KNOWS-ENEMIES <>>
<GLOBAL LESSONS 0>
<GLOBAL FIT-ACTIVE <>>
<GLOBAL FIT-TURNS 0>
<GLOBAL FARIA-SAVED <>>
<GLOBAL FARIA-STATE 0>		;"0 unmet 1 voice 2 companion 3 paralyzed 4 dead"
<GLOBAL SPADA-TOLD <>>
<GLOBAL PARCH-READ <>>
<GLOBAL PARCH-WHOLE <>>
<GLOBAL FARIA-DEAD <>>
<GLOBAL SACK-OPEN <>>
<GLOBAL BODY-PLACED <>>
<GLOBAL BODY-COVERED <>>
<GLOBAL CARRYING-BODY <>>
<GLOBAL IN-SACK <>>
<GLOBAL SACK-SEWN <>>
<GLOBAL SWAP-TURNS 0>
<GLOBAL SWAP-IDLE 0>
<GLOBAL HAVE-KNIFE-IN-SACK <>>
<GLOBAL BREATH 0>
<GLOBAL SACK-CUT <>>
<GLOBAL CORD-CUT <>>
<GLOBAL SWIM-COUNT 0>
<GLOBAL WRONG-SWIM 0>
<GLOBAL STORM-DONE <>>
<GLOBAL JAILER-TICK 0>
<GLOBAL CACHE-OPEN <>>

"Act III flags"
<GLOBAL ROCKS-COUNTED <>>
<GLOBAL WEDGE-DUG <>>
<GLOBAL POWDER-SET <>>
<GLOBAL BOULDER-GONE <>>
<GLOBAL GROTTO-OPEN <>>
<GLOBAL HOLLOW-FOUND <>>
<GLOBAL COFFER-FOUND <>>
<GLOBAL COFFER-OPEN <>>
<GLOBAL RICH <>>
<GLOBAL SUPPLIES-LEFT <>>
<GLOBAL CONFIRMED-GUILT <>>
<GLOBAL CAD-TALKED <>>
<GLOBAL PURSE-OUT <>>
<GLOBAL DIAMOND-GIVEN <>>
<GLOBAL MORREL-TOLD <>>
<GLOBAL DEBT-PAID <>>

"Act IV flags"
<GLOBAL CREDIT-OPEN <>>
<GLOBAL OPERATOR-PAID <>>
<GLOBAL TELEGRAPH-DONE <>>
<GLOBAL JANINA-ASKED <>>
<GLOBAL JANINA-DOCS <>>
<GLOBAL PRESS-RUN <>>
<GLOBAL MORCERF-DONE <>>
<GLOBAL SALON-SCENE <>>
<GLOBAL JACKET-REVEAL <>>
<GLOBAL BERTUCCIO-TOLD <>>
<GLOBAL AUTEUIL-BOX <>>
<GLOBAL DINNER-HELD <>>
<GLOBAL VILLEFORT-SHAKEN <>>
<GLOBAL NOIRTIER-TOLD <>>
<GLOBAL VALENTINE-SAVED <>>
<GLOBAL ASSIZES-DONE <>>
<GLOBAL WRATH-CHECKED <>>
<GLOBAL BURGLARY-SET <>>
<GLOBAL CAD-VISIT <>>
<GLOBAL CADEROUSSE-LETTER <>>
<GLOBAL CAD-DEAD <>>
<GLOBAL CAPERS-STARTED 0>
<GLOBAL VILL-EXPIRE 0>

"Act V flags"
<GLOBAL DANGLARS-ASKED <>>
<GLOBAL PARDONED <>>
<GLOBAL MANUSCRIPT-TAKEN <>>

"=== New syntax ==="

<SYNTAX STUDY = V-STUDY>
<SYNTAX STUDY WITH OBJECT (FIND ACTORBIT) (IN-ROOM) = V-STUDY>
<SYNTAX STUDY OBJECT = V-STUDY>
<SYNONYM STUDY LEARN>

<SYNTAX SEW OBJECT = V-SEW>
<SYNTAX SEW OBJECT WITH OBJECT (HELD CARRIED) = V-SEW>
<SYNONYM SEW STITCH>

<SYNTAX PRY OBJECT WITH OBJECT (HELD CARRIED) = V-PRY>
<SYNTAX PRY OBJECT = V-PRY>
<SYNONYM PRY LEVER>

<SYNTAX FORGIVE OBJECT = V-FORGIVE>
<SYNONYM FORGIVE PARDON SPARE>

<SYNTAX FURL OBJECT = V-FURL>
<SYNONYM FURL STRIKE>

<SYNTAX PAY OBJECT = V-PAY>
<SYNTAX PAY = V-PAY>

<SYNTAX HOST OBJECT = V-HOST>
<SYNTAX HOST = V-HOST>

<SYNTAX SEND OBJECT = V-SET>
<SYNTAX SEND = V-SET>
<SYNONYM SEND TRANSMIT DISPATCH>

<SYNTAX DRAG OBJECT = V-DRAG>
<SYNTAX DRAG OBJECT TO OBJECT = V-DRAG>
<SYNONYM DRAG HAUL>

<SYNTAX COVER OBJECT = V-COVER>

<SYNTAX REVEAL = V-REVEAL>
<SYNTAX REVEAL OBJECT = V-REVEAL>
<SYNONYM REVEAL UNMASK>

;"SWIM stays a bare verb. GPARSER only lets a direction word through
when the sentence's verb is WALK itself (ACT?WALK is compared by value,
so a late SYNONYM does not retarget it), which means SWIM WEST cannot
parse. In the open sea the plain compass words do the swimming and the
room says so; SWIM alone re-reads the heading out loud."
<SYNTAX SWIM = V-SWIMDIR>

;"ENTER OBJECT is V-THROUGH, which head-butts anything that is not a
door or a vehicle. The sack, the tunnel and the overhang all want to be
climbed into, so give ENTER a game-side form that reaches their
actions first."
<SYNTAX ENTER OBJECT (ON-GROUND IN-ROOM HELD CARRIED) = V-GETIN>
<SYNTAX GETIN OBJECT (ON-GROUND IN-ROOM HELD CARRIED) = V-GETIN>

<SYNTAX LIFT OBJECT = V-LIFT>
<SYNTAX LIFT OBJECT WITH OBJECT (HELD CARRIED) = V-LIFT>

<SYNTAX HAIL OBJECT = V-WAVEAT>
<SYNTAX HAIL = V-WAVEAT>

<SYNTAX SHOW OBJECT (HELD CARRIED HAVE)
	TO OBJECT (FIND ACTORBIT) (ON-GROUND IN-ROOM) = V-SHOW>
<SYNTAX SHOW OBJECT (FIND ACTORBIT) (ON-GROUND IN-ROOM)
	OBJECT (HELD CARRIED HAVE) = V-SHOW-REV>
<SYNONYM SHOW PRESENT>

;"v3 truncated NORTHWEST to NORTHW and SOUTHEAST to SOUTHE, so the
engine's compass synonyms are the short forms. A v8 dictionary keeps
nine characters, which makes the spelled-out words genuinely different
words; players type them, so declare them."
<SYNONYM SE SOUTHEAST>
<SYNONYM SW SOUTHWEST>
<SYNONYM NE NORTHEAST>
<SYNONYM NW NORTHWEST>

;"Words a player reaches for when they want off a ship. DISEMBARK is
already a verb in gsyntax but only with an object; these give the bare
forms somewhere to land."
<SYNONYM LEAVE DEBARK DISEMBARK ASHORE>

<SYNTAX KNOCK OBJECT = V-KNOCK>

<SYNTAX DIG OBJECT (ON-GROUND IN-ROOM) = V-DIG>

;"DROP is widened to reach scenery: DROP ANCHOR must find the ship's
anchor, which the player never holds. Object actions run before V-DROP,
and IDROP still refuses anything genuinely uncarried."
<SYNTAX DROP OBJECT (HELD CARRIED ON-GROUND IN-ROOM MANY)
	= V-DROP PRE-DROP>

;"CUT WITH in the stock engine demands a WEAPONBIT tool and only ever
slices BURNBIT things; the sack, the cord and the olive bough are all
handled in their own actions, so widen the tool scope to TOOLBIT."
<SYNTAX CUT OBJECT (ON-GROUND IN-ROOM HELD CARRIED)
	WITH OBJECT (FIND TOOLBIT) (CARRIED HELD) = V-CUT>
<SYNTAX CUT OBJECT (ON-GROUND IN-ROOM HELD CARRIED) = V-CUT>

;"BREAK in the stock engine insists on a WITH clause. Breaking the water
jug on the floor is the whole of puzzle II-2's first move, and it wants
no tool at all."
<SYNTAX DESTROY OBJECT (ON-GROUND IN-ROOM HELD CARRIED) = V-MUNG>

;"BURN also insists on a FLAMEBIT source. On Monte Cristo the flint is
in the powder horn's cap and the game says so, so the bare form lights."
<SYNTAX BURN OBJECT (ON-GROUND IN-ROOM HELD CARRIED) = V-BURN>

;"ATTACK/HIT wants a WEAPONBIT and refuses to swing at scenery. The
grotto wall is exactly a thing to be hit with a pickaxe."
<SYNTAX ATTACK OBJECT (ON-GROUND IN-ROOM)
	WITH OBJECT (FIND TOOLBIT) (HELD CARRIED) = V-ATTACK>

;"BY as a preposition, for PUT PLATE BY DOOR. AT and NEAR read the same
way and route to the same handler."
<SYNTAX PUT OBJECT (HELD CARRIED ON-GROUND IN-ROOM)
	BY OBJECT = V-PUT-BY>
<SYNTAX PUT OBJECT (HELD CARRIED ON-GROUND IN-ROOM)
	AT OBJECT = V-PUT-BY>
<SYNONYM BY NEAR BESIDE AGAINST>

"=== New verb routines ==="

<ROUTINE V-STUDY ()
	 <COND (<AND <EQUAL? ,ACT 2>
		     <EQUAL? ,FARIA-STATE 2 3>
		     <IN? ,FARIA ,HERE>>
		<FARIA-LESSON>)
	       (T
		<TELL
"There is nothing here worth a scholar's hour, and no one to teach it."
CR>)>
	 <RTRUE>>

<ROUTINE V-SEW ()
	 <COND (<NOT <EQUAL? ,PRSO ,SACK>>
		<TELL "You have no thread to spare on that." CR>)
	       (T <SEW-THE-SACK>)>
	 <RTRUE>>

<ROUTINE V-PRY ()
	 <COND (,PRSO <PERFORM ,V?MOVE ,PRSO ,PRSI> <RTRUE>)
	       (T <TELL "Pry what?" CR> <RTRUE>)>>

<ROUTINE V-FORGIVE ()
	 <COND (<AND <EQUAL? ,PRSO ,DANGLARS5> <IN? ,DANGLARS5 ,HERE>>
		<PARDON-DANGLARS>)
	       (T
		<TELL "Forgiveness is a coin you spend once. Not here." CR>)>
	 <RTRUE>>

<ROUTINE V-FURL ()
	 <COND (<EQUAL? ,PRSO ,SAILS> <FURL-THE-SAILS>)
	       (T <TELL "That does not furl." CR>)>
	 <RTRUE>>

<ROUTINE V-PAY ()
	 <COND (<EQUAL? ,HERE ,OFFICE> <PAY-THE-DEBT>)
	       (T <TELL "There is no debt of yours to settle here." CR>)>
	 <RTRUE>>

<ROUTINE V-HOST ()
	 <COND (<EQUAL? ,HERE ,AUTSALON> <HOLD-THE-DINNER>)
	       (T <TELL "This is no house of yours to entertain in." CR>)>
	 <RTRUE>>

<ROUTINE V-SET ()
	 <COND (<EQUAL? ,HERE ,TELETOWER> <WORK-THE-SIGNAL>)
	       (T <TELL "Nothing here answers to setting." CR>)>
	 <RTRUE>>

<ROUTINE V-DRAG ()
	 <COND (<EQUAL? ,PRSO ,BODY> <PERFORM ,V?TAKE ,BODY> <RTRUE>)
	       (T <PERFORM ,V?TAKE ,PRSO> <RTRUE>)>>

<ROUTINE V-COVER ()
	 <COND (<AND <EQUAL? ,PRSO ,BODY> <IN? ,BODY ,PRISON-BED>>
		<COVER-THE-BODY>)
	       (<EQUAL? ,PRSO ,BODY>
		<TELL "Not while he lies on bare stone. He goes in the bed."
CR>)
	       (T <TELL "There is no covering that." CR>)>
	 <RTRUE>>

<ROUTINE V-REVEAL ()
	 <COND (<EQUAL? ,IDENTITY 1> <DOFF-THE-WIG> <RTRUE>)
	       (T <THE-COUNT-UNMASKS>)>
	 <RTRUE>>

<ROUTINE V-GETIN ()
	 <COND (<FSET? ,PRSO ,DOORBIT> <PERFORM ,V?THROUGH ,PRSO> <RTRUE>)
	       (T
		<TELL "You cannot get inside the " D ,PRSO "." CR>
		<RTRUE>)>>

<ROUTINE V-SWIMDIR ()
	 <COND (<EQUAL? ,HERE ,OPENSEA>
		<TELL
"You are swimming, and have been for an hour. One steady spark low in
the south: the light of Planier. Leave it on your left hand and
Tiboulen lies west." CR>)
	       (T
		<TELL "There is nothing here deep enough to drown in." CR>)>
	 <RTRUE>>

<ROUTINE V-LIFT ()
	 <PERFORM ,V?MOVE ,PRSO ,PRSI>
	 <RTRUE>>

;"PREACTIONS are indexed by action, not by syntax line, so the stock
PRE-MUNG fires ahead of every BREAK regardless of which BREAK syntax
matched and kills the bare-handed forms before the object ever sees
them. Redefined to stand aside and let objects answer for themselves."
;"REMOVE is a TAKE synonym here, so REMOVE WIG is a take of a thing you
already hold, and the stock PRE-TAKE answers 'You are already wearing
it' before the wig's own action can turn it into the game's second
great reveal. Let costume pieces through; everything else keeps the
stock behavior."
<ROUTINE PRE-TAKE ()
	 <COND (<AND <IN? ,PRSO ,WINNER>
		     <EQUAL? ,PRSO ,WIG ,CASSOCK ,SAILOR-JACKET>>
		<RFALSE>)
	       (<IN? ,PRSO ,WINNER>
		<COND (<FSET? ,PRSO ,WEARBIT>
		       <TELL "You are already wearing it." CR>)
		      (T <TELL "You already have that!" CR>)>
		<RTRUE>)
	       (<AND <FSET? <LOC ,PRSO> ,CONTBIT>
		     <NOT <FSET? <LOC ,PRSO> ,OPENBIT>>>
		<TELL
"You can't reach something that's inside a closed container." CR>
		<RTRUE>)
	       (,PRSI
		<COND (<EQUAL? ,PRSI ,GROUND>
		       <SETG PRSI <>>
		       <RFALSE>)
		      (<NOT <EQUAL? ,PRSI <LOC ,PRSO>>>
		       <TELL "The " D ,PRSO " isn't in the " D ,PRSI "." CR>
		       <RTRUE>)
		      (T
		       <SETG PRSI <>>
		       <RFALSE>)>)
	       (<EQUAL? ,PRSO <LOC ,WINNER>>
		<TELL "You're inside of it!" CR>
		<RTRUE>)
	       (T <RFALSE>)>>

;"Same story as PRE-MUNG: the stock PRE-BURN rejects every BURN with no
FLAMEBIT source before the object can answer. The slow-match is lit
with the flint in the powder horn's cap, and that is the game's
business, not the parser's."
<ROUTINE PRE-BURN ()
	 <COND (<AND ,PRSI <NOT <FLAMING? ,PRSI>>>
		<TELL "With a " D ,PRSI "??!?" CR>
		<RTRUE>)
	       (T <RFALSE>)>>

<ROUTINE PRE-MUNG ()
	 <COND (<AND ,PRSI <NOT <FSET? ,PRSI ,WEAPONBIT>>
		     <NOT <FSET? ,PRSI ,TOOLBIT>>>
		<TELL "Trying to destroy the " D ,PRSO " with a " D ,PRSI
" is futile." CR>
		<RTRUE>)
	       (T <RFALSE>)>>

;"Conversation topics live in GLOBAL-OBJECTS so ASK X ABOUT Y always
resolves. That also puts them in reach of EXAMINE and every other verb,
where the stock answers are nonsense; they are ideas, and the only verb
an idea answers to is being asked about."
<ROUTINE TOPIC-FCN ()
	 <COND (<AND <VERB? TELL> ,PRSO <FSET? ,PRSO ,ACTORBIT>> <RFALSE>)
	       (<VERB? EXAMINE READ SEARCH LOOK-INSIDE>
		<TELL "You think about " D ,PRSO " for a moment. There is
nobody here to say it to." CR>
		<RTRUE>)
	       (<VERB? TELL>
		<TELL "There is nobody here to tell." CR>
		<RTRUE>)
	       (<VERB? TAKE MOVE DROP PUT GIVE SHOW ATTACK MUNG KISS>
		<TELL "That is a subject, not a thing." CR>
		<RTRUE>)
	       (T <RFALSE>)>>

"=== GO TO <place> ===

The engine's V-WALK-TO answers 'You should supply a direction!', which
is useless to a player who has just been told to come to the
counting-house. These route a named destination: walk there when it is
one move away, name the direction when it is further, and say something
in-world when it is not reachable from here at all. GO TO, WALK TO,
ENTER and the bare noun all arrive here."

<GLOBAL PLACE-HERE-CACHE 1>

<ROUTINE PLACE-FCN ()
	 <COND (<VERB? WALK-TO GETIN THROUGH BOARD CLIMB-FOO WALK>
		<GO-TO-PLACE ,PRSO>
		<RTRUE>)
	       (<VERB? EXAMINE FIND>
		<GO-TO-PLACE ,PRSO T>
		<RTRUE>)
	       ;"LEAVE SHIP parses as DROP SHIP, and a player who types it
		on a deck means the opposite of dropping: they want off."
	       (<VERB? DROP>
		<COND (<EQUAL? .PLACE-HERE-CACHE 0> <NULL-F>)>
		<LEAVE-PLACE ,PRSO>
		<RTRUE>)
	       (<VERB? TAKE MOVE PUT GIVE ATTACK MUNG>
		<TELL "That is a place, not a thing you can handle." CR>
		<RTRUE>)
	       (T <RFALSE>)>>

;"LEAVE <the place you are standing in>: take the way out. Naming
 somewhere else is just an awkward way of saying GO THERE."
<ROUTINE LEAVE-PLACE (PLACE)
	 <COND (<NOT <EQUAL? .PLACE <PLACE-HERE>>>
		<GO-TO-PLACE .PLACE>
		<RTRUE>)
	       (<EQUAL? ,HERE ,DECK>
		<TELL "You make for the side." CR>
		<DO-WALK ,P?WEST>)
	       (<EQUAL? ,HERE ,CABIN> <DO-WALK ,P?UP>)
	       (T <DO-WALK ,P?EXIT>)>
	 <RTRUE>>

;"Walk the player toward .PLACE. LOOK? true means only describe the way,
never move (that is EXAMINE QUAY, which should not teleport anyone).
A destination more than one room off gets the first leg and says so,
rather than pretending it is next door."
<ROUTINE GO-TO-PLACE (PLACE "OPTIONAL" (LOOK? <>) "AUX" DIR)
	 <COND (<EQUAL? .PLACE <PLACE-HERE>>
		<TELL "You are there." CR>
		<RTRUE>)>
	 <SET DIR <PLACE-DIR .PLACE>>
	 <COND (<NOT .DIR>
		<TELL "You cannot get to the " D .PLACE " from here." CR>
		<RTRUE>)
	       (<AND <NOT <PLACE-ADJACENT? .PLACE>> <NOT .LOOK?>>
		<TELL "The " D .PLACE " is not next door, but the way to it
starts off in this direction." CR>
		<GO-ONE-LEG .DIR>
		<RTRUE>)
	       (<EQUAL? .DIR 1>
		<TELL "The " D .PLACE " ">
		<PLACE-VERB .PLACE>
		<TELL " north of here." CR>
		<COND (<NOT .LOOK?> <DO-WALK ,P?NORTH>)>)
	       (<EQUAL? .DIR 2>
		<TELL "The " D .PLACE " ">
		<PLACE-VERB .PLACE>
		<TELL " south of here." CR>
		<COND (<NOT .LOOK?> <DO-WALK ,P?SOUTH>)>)
	       (<EQUAL? .DIR 3>
		<TELL "The " D .PLACE " ">
		<PLACE-VERB .PLACE>
		<TELL " east of here." CR>
		<COND (<NOT .LOOK?> <DO-WALK ,P?EAST>)>)
	       (<EQUAL? .DIR 4>
		<TELL "The " D .PLACE " ">
		<PLACE-VERB .PLACE>
		<TELL " west of here." CR>
		<COND (<NOT .LOOK?> <DO-WALK ,P?WEST>)>)
	       (<EQUAL? .DIR 5>
		<TELL "The " D .PLACE " is below you." CR>
		<COND (<NOT .LOOK?> <DO-WALK ,P?DOWN>)>)
	       (<EQUAL? .DIR 6>
		<TELL "The " D .PLACE " is above you." CR>
		<COND (<NOT .LOOK?> <DO-WALK ,P?UP>)>)
	       (<EQUAL? .DIR 7>
		<TELL "You go in." CR>
		<COND (<NOT .LOOK?> <DO-WALK ,P?ENTRANCE>)>)
	       (<EQUAL? .DIR 8>
		<TELL "You go out." CR>
		<COND (<NOT .LOOK?> <DO-WALK ,P?EXIT>)>)
	       (<EQUAL? .DIR 9>
		<TELL "The " D .PLACE " lies northwest of here." CR>
		<COND (<NOT .LOOK?> <DO-WALK ,P?NW>)>)
	       (<EQUAL? .DIR 10>
		<TELL "The " D .PLACE " lies southeast of here." CR>
		<COND (<NOT .LOOK?> <DO-WALK ,P?SE>)>)
	       (<EQUAL? .DIR 11>
		<TELL "The " D .PLACE " lies southwest of here." CR>
		<COND (<NOT .LOOK?> <DO-WALK ,P?SW>)>)
	       (<EQUAL? .DIR 12>
		<TELL "The " D .PLACE " lies northeast of here." CR>
		<COND (<NOT .LOOK?> <DO-WALK ,P?NE>)>)>
	 <RTRUE>>

;"The Allees de Meilhan is a plural; everything else is singular."
<ROUTINE PLACE-VERB (PLACE)
	 <COND (<EQUAL? .PLACE ,P-MEILHAN> <TELL "lie">)
	       (T <TELL "lies">)>>

;"True when .PLACE really is one move away, so the direction line can be
 stated as fact. Everything else gets routed a leg at a time."
<ROUTINE PLACE-ADJACENT? (PLACE)
	 <COND (<EQUAL? ,HERE ,DECK>
		<EQUAL? .PLACE ,P-QUAY ,P-CABIN ,P-TOWN ,SHIP-T>)
	       (<EQUAL? ,HERE ,QUAY>
		<EQUAL? .PLACE ,P-OFFICE ,P-MEILHAN ,P-CATALANS ,P-RESERVE>)
	       (<EQUAL? ,HERE ,CABIN> <EQUAL? .PLACE ,P-DECK ,SHIP-T>)
	       (<EQUAL? ,HERE ,OFFICE ,MEILHAN ,CATALANS ,RESERVE>
		<EQUAL? .PLACE ,P-QUAY ,P-TOWN>)
	       (<EQUAL? ,HERE ,STREET>
		<EQUAL? .PLACE ,P-SALON ,P-BANK ,P-PRESS ,P-PEERS ,P-ASSIZES
			,P-TELEGRAPH ,P-VHALL ,P-AUTEUIL>)
	       (T <RTRUE>)>>

;"Take one step in the given direction code."
<ROUTINE GO-ONE-LEG (DIR)
	 <COND (<EQUAL? .DIR 1> <DO-WALK ,P?NORTH>)
	       (<EQUAL? .DIR 2> <DO-WALK ,P?SOUTH>)
	       (<EQUAL? .DIR 3> <DO-WALK ,P?EAST>)
	       (<EQUAL? .DIR 4> <DO-WALK ,P?WEST>)
	       (<EQUAL? .DIR 5> <DO-WALK ,P?DOWN>)
	       (<EQUAL? .DIR 6> <DO-WALK ,P?UP>)
	       (<EQUAL? .DIR 7> <DO-WALK ,P?ENTRANCE>)
	       (<EQUAL? .DIR 8> <DO-WALK ,P?EXIT>)
	       (<EQUAL? .DIR 9> <DO-WALK ,P?NW>)
	       (<EQUAL? .DIR 10> <DO-WALK ,P?SE>)
	       (<EQUAL? .DIR 11> <DO-WALK ,P?SW>)
	       (<EQUAL? .DIR 12> <DO-WALK ,P?NE>)>>

;"Which place object stands for the room the player is in."
<ROUTINE PLACE-HERE ()
	 <COND (<EQUAL? ,HERE ,DECK> ,P-DECK)
	       (<EQUAL? ,HERE ,CABIN> ,P-CABIN)
	       (<EQUAL? ,HERE ,QUAY> ,P-QUAY)
	       (<EQUAL? ,HERE ,OFFICE> ,P-OFFICE)
	       (<EQUAL? ,HERE ,MEILHAN> ,P-MEILHAN)
	       (<EQUAL? ,HERE ,CATALANS> ,P-CATALANS)
	       (<EQUAL? ,HERE ,RESERVE> ,P-RESERVE)
	       (<EQUAL? ,HERE ,INN> ,P-INN)
	       (<EQUAL? ,HERE ,CELL34> ,P-CELL34)
	       (<EQUAL? ,HERE ,CELL27> ,P-CELL27)
	       (<EQUAL? ,HERE ,GROTTO1 ,GROTTO2> ,P-GROTTO)
	       (<EQUAL? ,HERE ,SALON> ,P-SALON)
	       (<EQUAL? ,HERE ,CSTUDY> ,P-STUDY)
	       (<EQUAL? ,HERE ,BANKHALL ,BANKOFF> ,P-BANK)
	       (<EQUAL? ,HERE ,PRESS> ,P-PRESS)
	       (<EQUAL? ,HERE ,PEERS> ,P-PEERS)
	       (<EQUAL? ,HERE ,ASSIZES> ,P-ASSIZES)
	       (<EQUAL? ,HERE ,TELEGARDEN ,TELETOWER> ,P-TELEGRAPH)
	       (<EQUAL? ,HERE ,AUTSALON> ,P-AUTEUIL)
	       (<EQUAL? ,HERE ,AUTGARDEN> ,P-GARDEN)
	       (<EQUAL? ,HERE ,VHALL ,NOIRTIER-ROOM ,VALROOM> ,P-VHALL)
	       (T <>)>>

;"Direction code from HERE to .PLACE, or false if there is no one-move
 answer. 1 N 2 S 3 E 4 W 5 D 6 U 7 in 8 out 9 NW 10 SE 11 SW 12 NE."
<ROUTINE PLACE-DIR (PLACE)
	 <COND (<EQUAL? ,HERE ,DECK>
		<COND (<EQUAL? .PLACE ,P-QUAY ,P-TOWN> 4)
		      (<EQUAL? .PLACE ,P-CABIN> 5)
		      (<EQUAL? .PLACE ,P-OFFICE ,P-MEILHAN ,P-CATALANS
			       ,P-RESERVE>
		       4)
		      (T <>)>)
	       (<EQUAL? ,HERE ,CABIN>
		<COND (<EQUAL? .PLACE ,P-DECK ,P-QUAY ,P-TOWN> 6) (T <>)>)
	       (<EQUAL? ,HERE ,QUAY>
		<COND (<EQUAL? .PLACE ,P-OFFICE> 4)
		      (<EQUAL? .PLACE ,P-MEILHAN> 1)
		      (<EQUAL? .PLACE ,P-CATALANS> 2)
		      (<EQUAL? .PLACE ,P-RESERVE> 3)
		      (<EQUAL? .PLACE ,P-DECK ,P-CABIN> 7)
		      (T <>)>)
	       (<EQUAL? ,HERE ,OFFICE>
		<COND (<AND <EQUAL? .PLACE ,P-MEILHAN> <EQUAL? ,ACT 3>> 1)
		      (<EQUAL? .PLACE ,P-QUAY ,P-TOWN ,P-DECK ,P-MEILHAN
			       ,P-CATALANS ,P-RESERVE>
		       3)
		      (T <>)>)
	       (<EQUAL? ,HERE ,MEILHAN>
		<COND (<AND <EQUAL? .PLACE ,P-OFFICE> <EQUAL? ,ACT 3>> 2)
		      (<EQUAL? .PLACE ,P-QUAY ,P-TOWN ,P-DECK ,P-OFFICE
			       ,P-CATALANS ,P-RESERVE>
		       2)
		      (T <>)>)
	       (<EQUAL? ,HERE ,CATALANS>
		<COND (<EQUAL? .PLACE ,P-QUAY ,P-TOWN ,P-DECK ,P-OFFICE
			       ,P-MEILHAN ,P-RESERVE>
		       1)
		      (T <>)>)
	       (<EQUAL? ,HERE ,RESERVE>
		<COND (<EQUAL? .PLACE ,P-QUAY ,P-TOWN ,P-DECK ,P-OFFICE
			       ,P-MEILHAN ,P-CATALANS>
		       4)
		      (T <>)>)
	       (<EQUAL? ,HERE ,CELL34>
		<COND (<EQUAL? .PLACE ,P-CELL27> 4) (T <>)>)
	       (<EQUAL? ,HERE ,TUNNEL>
		<COND (<EQUAL? .PLACE ,P-CELL27> 4)
		      (<EQUAL? .PLACE ,P-CELL34> 3)
		      (T <>)>)
	       (<EQUAL? ,HERE ,CELL27>
		<COND (<EQUAL? .PLACE ,P-CELL34> 3) (T <>)>)
	       (<EQUAL? ,HERE ,BEAUCAIRE-ROAD>
		<COND (<EQUAL? .PLACE ,P-INN> 7)
		      (<EQUAL? .PLACE ,P-TOWN ,P-QUAY ,P-OFFICE> 2)
		      (T <>)>)
	       (<EQUAL? ,HERE ,INN>
		<COND (<EQUAL? .PLACE ,P-TOWN ,P-QUAY ,P-OFFICE> 8) (T <>)>)
	       (<EQUAL? ,HERE ,CLEARING>
		<COND (<AND <EQUAL? .PLACE ,P-GROTTO> ,GROTTO-OPEN> 5)
		      (T <>)>)
	       (<EQUAL? ,HERE ,GROTTO1>
		<COND (<EQUAL? .PLACE ,P-ISLAND> 6) (T <>)>)
	       (<EQUAL? ,HERE ,SALON>
		<COND (<EQUAL? .PLACE ,P-STUDY> 3)
		      (<EQUAL? .PLACE ,P-TOWN> 2)
		      (T <>)>)
	       (<EQUAL? ,HERE ,CSTUDY>
		<COND (<EQUAL? .PLACE ,P-SALON ,P-TOWN> 4) (T <>)>)
	       (<EQUAL? ,HERE ,STREET>
		<COND (<EQUAL? .PLACE ,P-SALON ,P-STUDY> 1)
		      (<EQUAL? .PLACE ,P-BANK> 4)
		      (<EQUAL? .PLACE ,P-PRESS> 3)
		      (<EQUAL? .PLACE ,P-PEERS> 10)
		      (<EQUAL? .PLACE ,P-ASSIZES> 2)
		      (<EQUAL? .PLACE ,P-TELEGRAPH> 9)
		      (<EQUAL? .PLACE ,P-VHALL> 11)
		      (<EQUAL? .PLACE ,P-AUTEUIL ,P-GARDEN> 7)
		      (T <>)>)
	       (<EQUAL? ,HERE ,BANKHALL>
		<COND (<EQUAL? .PLACE ,P-TOWN> 3) (T <>)>)
	       (<EQUAL? ,HERE ,BANKOFF>
		<COND (<EQUAL? .PLACE ,P-BANK ,P-TOWN> 3) (T <>)>)
	       (<EQUAL? ,HERE ,PRESS ,PEERS ,ASSIZES>
		<COND (<EQUAL? .PLACE ,P-TOWN ,P-SALON> <STREET-WAY>)
		      (T <>)>)
	       (<EQUAL? ,HERE ,TELEGARDEN>
		<COND (<EQUAL? .PLACE ,P-TELEGRAPH> 6)
		      (<EQUAL? .PLACE ,P-TOWN ,P-SALON> 10)
		      (T <>)>)
	       (<EQUAL? ,HERE ,TELETOWER>
		<COND (<EQUAL? .PLACE ,P-TOWN ,P-SALON> 5) (T <>)>)
	       (<EQUAL? ,HERE ,AUTSALON>
		<COND (<EQUAL? .PLACE ,P-GARDEN> 3)
		      (<EQUAL? .PLACE ,P-TOWN ,P-SALON> 8)
		      (T <>)>)
	       (<EQUAL? ,HERE ,AUTGARDEN>
		<COND (<EQUAL? .PLACE ,P-AUTEUIL> 4) (T <>)>)
	       (<EQUAL? ,HERE ,VHALL>
		<COND (<EQUAL? .PLACE ,P-TOWN ,P-SALON> 12) (T <>)>)
	       (<EQUAL? ,HERE ,NOIRTIER-ROOM>
		<COND (<EQUAL? .PLACE ,P-VHALL ,P-TOWN> 2) (T <>)>)
	       (<EQUAL? ,HERE ,VALROOM>
		<COND (<EQUAL? .PLACE ,P-VHALL ,P-TOWN> 4) (T <>)>)
	       (T <>)>>

;"From the three Paris rooms that hang off the street, the way back is
 the reverse of the way in; they differ, so name each."
<ROUTINE STREET-WAY ()
	 <COND (<EQUAL? ,HERE ,PRESS> 4)
	       (<EQUAL? ,HERE ,PEERS> 9)
	       (<EQUAL? ,HERE ,ASSIZES> 1)
	       (T <>)>>

;"GO TO <place>. The stock routine only ever says 'You should supply a
 direction!'; a player who has been told to come to the counting-house
 has supplied one, in the only terms the game gave them."
<ROUTINE V-WALK-TO ()
	 <COND (<AND ,PRSO <EQUAL? <GETP ,PRSO ,P?ACTION> ,PLACE-FCN>>
		<GO-TO-PLACE ,PRSO>
		<RTRUE>)
	       (<AND ,PRSO <OR <IN? ,PRSO ,HERE>
			       <GLOBAL-IN? ,PRSO ,HERE>>>
		<TELL "It's here!" CR>
		<RTRUE>)
	       (T
		<TELL
"You should supply a direction. North, south, east, west, up or down."
CR>
		<RTRUE>)>>

;"SHIP is both a place you can leave and a thing Morrel grieves over in
 1829. On the Pharaon it behaves as a place; anywhere else it is the
 conversation topic it has always been."
<ROUTINE SHIP-FCN ()
	 <COND (<EQUAL? ,HERE ,DECK ,CABIN ,QUAY>
		<COND (<VERB? DROP>
		       <LEAVE-PLACE ,P-DECK>
		       <RTRUE>)
		      (<VERB? WALK-TO GETIN THROUGH BOARD WALK>
		       <GO-TO-PLACE ,P-DECK>
		       <RTRUE>)
		      (<VERB? EXAMINE>
		       <TELL
"The Pharaon, three-masted, in mourning trim, and yours to bring to her
rest." CR>
		       <RTRUE>)>
		<RFALSE>)
	       (T <TOPIC-FCN>)>>

<ROUTINE V-PUT-BY ()
	 <COND (<AND <EQUAL? ,PRSO ,PLATE> <EQUAL? ,PRSI ,CELL-DOOR>>
		<PERFORM ,V?DROP ,PLATE>
		<RTRUE>)
	       (T
		<TELL "You put the " D ,PRSO " down beside the " D ,PRSI
". Nothing comes of it." CR>
		<RTRUE>)>>

<ROUTINE V-SHOW ()
	 <TELL "\"Very interesting,\" says " D ,PRSI ", who is not
interested." CR>
	 <RTRUE>>

<ROUTINE V-SHOW-REV ()
	 <PERFORM ,V?SHOW ,PRSI ,PRSO>
	 <RTRUE>>

<ROUTINE V-WAVEAT ()
	 <COND (<AND <EQUAL? ,HERE ,TIBOULEN> ,STORM-DONE>
		<HAIL-THE-TARTAN>)
	       (T <TELL "You wave. Nothing in the world waves back." CR>)>
	 <RTRUE>>

"=== Small helpers ==="

<ROUTINE ADD-SCORE (N)
	 <SETG BASE-SCORE <+ ,BASE-SCORE .N>>
	 <SETG SCORE <+ ,SCORE .N>>
	 T>


"=== ACT I - MARSEILLES ==="

<ROUTINE DECK-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-END>
		<COND (<AND <NOT ,MORREL-TALKED> <IN? ,MORREL ,DECK>>
		       <RFALSE>)>
		<RFALSE>)
	       (T <RFALSE>)>>

;"Refusing to let the player off the ship is the game's first gate, and
 for one real player it was also its last: the old text said only that
 she was not at her rest, which names no action. Every refusal now says
 which job is left, in the words the game will accept for it."
<ROUTINE DECK-ASHORE ()
	 <COND (,DOCKED ,QUAY)
	       (<NOT ,SAILS-FURLED>
		<TELL
"She is still under way, and a captain does not step ashore off a
moving ship. Furl the sails first, and then let the anchor go." CR>
		<RFALSE>)
	       (T
		<TELL
"The canvas is in, but she is still drifting on the tide. Drop the
anchor, and then the quay is yours." CR>
		<RFALSE>)>>

<ROUTINE FURL-THE-SAILS ()
	 <COND (,SAILS-FURLED
		<TELL "The canvas is already snug on the yards." CR>)
	       (T
		<SETG SAILS-FURLED T>
		<TELL
"\"Furl the topsails!\" The canvas comes in along the yards like a bird
folding. Danglars watches from the mast and says nothing, which is his
way of saying a great deal." CR>)>>

<ROUTINE SAILS-FCN ()
	 <COND (<VERB? FURL LOWER TAKE MOVE CLOSE>
		<FURL-THE-SAILS>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<COND (,SAILS-FURLED
		       <TELL "Furled and snug, the way Leclere taught you." CR>)
		      (T <TELL "Topsails still drawing. She wants furling." CR>)>
		<RTRUE>)>>

<ROUTINE ANCHOR-FCN ()
	 <COND (<VERB? DROP LOWER MOVE TAKE>
		<COND (<NOT ,SAILS-FURLED>
		       <TELL
"Anchor under sail? You would drag her half across the roads. Furl
first." CR>)
		      (,DOCKED
		       <TELL "She rides at her anchor already." CR>)
		      (T
		       <SETG DOCKED T>
		       <ADD-SCORE 5>
		       <TELL
"The anchor goes down in a roar of chain and the Pharaon comes to rest
in the roads of Marseilles. Morrel's skiff is already alongside." CR CR
"\"Come aboard, M. Morrel! She is home.\"" CR>
		       <MOVE ,MORREL ,DECK>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL "Ready at the cathead, waiting on your word." CR>
		<RTRUE>)>>

<ROUTINE CREW-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"Good men, and every one of them watching to see whether the boy at the
helm is a captain." CR>
		<RTRUE>)
	       (<VERB? TELL>
		<TELL "\"Aye, captain,\" says the mate, and grins at the word."
CR>
		<RTRUE>)>>

<ROUTINE CHEST-FCN ()
	 <COND (<VERB? OPEN>
		<COND (<FSET? ,SEA-CHEST ,OPENBIT>
		       <TELL "It stands open." CR>)
		      (T
		       <FSET ,SEA-CHEST ,OPENBIT>
		       <TELL
"You lift the lid. Leclere's sword and his cross of honor lie inside,
wrapped for a widow in Marseilles who does not yet know she is one." CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL "A captain's chest, packed by other hands than his." CR>
		<RTRUE>)>>

<ROUTINE MORREL-FCN ()
	 <COND (<AND <VERB? TELL> <NOT ,PRSI>>
		<COND (<EQUAL? ,ACT 3> <MORREL3-TALK>)
		      (<EQUAL? ,HERE ,OFFICE>
		       <COND (,CAPTAINCY
			      <TELL
"\"Go to your father, Edmond, and then to your Catalan. The ship keeps.\""
CR>)
			     (T
			      <SETG CAPTAINCY T>
			      <ADD-SCORE 10>
			      <TELL
"\"You brought her home through the gales and you touched at Elba on a
dying man's word. Both are what I want in a captain.\" He puts out his
hand. \"At twenty, captain of the Pharaon!\"" CR CR
"Somewhere behind the ledgers, a pen stops scratching." CR>)>)
		      (T
		       <TELL
"\"A sad voyage, Edmond, and a well-sailed one. Come to the
counting-house when she is squared away.\"" CR>)>
		<RTRUE>)
	       (<AND <VERB? TELL> ,PRSI>
		<COND (<EQUAL? ,ACT 3> <MORREL3-TOPIC>)
		      (T
		       <TELL
"\"Later, my boy. Ships first, and then the world.\"" CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<COND (<EQUAL? ,ACT 3>
		       <TELL
"He has aged twenty years in fourteen. An honest man watching his own
name come due." CR>)
		      (T
		       <TELL
"A shipowner of Marseilles, and the only rich man you have ever known
who looks a sailor in the eye." CR>)>
		<RTRUE>)>>

<ROUTINE DANGLARS-FCN ()
	 <COND (<VERB? TELL>
		<TELL
"\"Captain Dantes,\" says Danglars, tasting the words like a bad
oyster. \"Or nearly. Not yet. Very nearly.\"" CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"The supercargo: a man who counts everything and is owed, in his own
reckoning, rather more." CR>
		<RTRUE>)>>

<ROUTINE ELBA-LETTER-FCN ()
	 <COND (<VERB? READ EXAMINE>
		<TELL
"A sealed packet, and one line on the outside in a dying man's hand: to
Monsieur Noirtier, Rue Coq-Heron, Paris." CR>
		<RTRUE>)
	       (<VERB? DROP PUT GIVE>
		<COND (<AND <VERB? GIVE> <EQUAL? ,PRSI ,VILLEFORT>>
		       <RFALSE>)
		      (T
		       <TELL "It is a dying man's trust. You keep it." CR>
		       <RTRUE>)>)>>

<ROUTINE OFFICE-FCN (RARG)
	 <COND (<AND <EQUAL? .RARG ,M-ENTER> <EQUAL? ,ACT 1>>
		<MOVE ,MORREL ,OFFICE>
		<RFALSE>)
	       (<AND <EQUAL? .RARG ,M-LOOK> <EQUAL? ,ACT 3>>
		<TELL
"The counting-house of Morrel and Son, 1829: one clerk, one empty
cash-box, and a wall of portraits of ships that are all at the bottom
of the sea. Cocles keeps the ledgers as though the numbers might yet
repent. The quay lies east, and the stairs to the old room in the
Allees de Meilhan go up and north." CR>
		<RTRUE>)
	       (T <RFALSE>)>>

<ROUTINE OFFICE-EAST ()
	 <COND (<EQUAL? ,ACT 3> ,QUAY)
	       (T ,QUAY)>>

<ROUTINE OFFICE-NORTH ()
	 <COND (<EQUAL? ,ACT 3> ,MEILHAN)
	       (T
		<TELL "The counting-house opens east, onto the quay." CR>
		<RFALSE>)>>

<ROUTINE MEILHAN-FCN (RARG)
	 <COND (<AND <EQUAL? .RARG ,M-ENTER> <EQUAL? ,ACT 1>>
		<MOVE ,CADEROUSSE ,MEILHAN>
		<RFALSE>)
	       (<AND <EQUAL? .RARG ,M-LOOK> <EQUAL? ,ACT 3>>
		<TELL
"The room in the Allees de Meilhan, let to strangers these many years:
a bed not his, a window box gone to sticks, and the same bare mantel
over the same cold grate. The stairs lead back down and south. Some
rooms outlive everyone in them." CR>
		<RTRUE>)
	       (T <RFALSE>)>>

<ROUTINE MEILHAN-SOUTH ()
	 <COND (<EQUAL? ,ACT 3> ,OFFICE)
	       (T ,QUAY)>>

<ROUTINE FATHER-FCN ()
	 <COND (<AND <VERB? GIVE> <EQUAL? ,PRSO ,COIN-PURSE>>
		<COND (,FATHER-PAID
		       <TELL "He has taken all he will take from you today." CR>)
		      (T
		       <SETG FATHER-PAID T>
		       <ADD-SCORE 10>
		       <REMOVE ,COIN-PURSE>
		       <TELL
"\"Keep it, Edmond, I want for nothing.\" You put it in his hands and
close his fingers over it, and he stops arguing, which tells you what
the cupboard has been telling you." CR CR
"In the doorway, Caderousse watches the silver go by with the eyes of a
man doing arithmetic." CR>)>
		<RTRUE>)
	       (<VERB? TELL>
		<TELL
"\"Captain at twenty, and married within the week. I have lived long
enough.\"" CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"Thin, proud, and delighted. He has been eating less than he says." CR>
		<RTRUE>)
	       (<VERB? KISS>
		<TELL "He holds you the way old men hold what they know they
must give back." CR>
		<RTRUE>)>>

<ROUTINE MANTEL-FCN ()
	 <COND (<AND <VERB? PUT PUT-ON> <EQUAL? ,PRSO ,RED-PURSE>
		     <EQUAL? ,ACT 3>>
		<PURSE-ON-MANTEL>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<COND (<EQUAL? ,ACT 1>
		       <TELL
"A bare shelf, a crucifix, and a faded red silk purse: M. Morrel's
charity, kept where a proud man can see it and not spend it." CR>)
		      (T
		       <TELL
"The same mantelpiece. Fourteen years of other people's dust, and the
mark where a red purse used to lie." CR>)>
		<RTRUE>)>>

<ROUTINE CADEROUSSE-FCN ()
	 <COND (<EQUAL? ,ACT 3> <CADEROUSSE3>)
	       (<VERB? TELL>
		<TELL
"\"Well, well. Captain, is it, and married too? Some men are born under
a lucky star.\" He laughs, and the laugh runs out before the sentence
does." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"Your father's neighbor, a tailor by trade and a thirst by vocation." CR>
		<RTRUE>)>>

<ROUTINE MERCEDES-FCN ()
	 <COND (<VERB? KISS>
		<COND (,KISSED
		       <TELL "She laughs. \"Save some for the arbor.\"" CR>)
		      (T
		       <SETG KISSED T>
		       <ADD-SCORE 5>
		       <TELL
"She comes off the doorstep into your arms and all Marseilles may look
if it likes. \"You are late, Edmond, and you are alive. I forgive the
first.\"" CR CR
"In the shadow of the wall, Fernand turns his face away." CR>)>
		<RTRUE>)
	       (<AND <VERB? TELL> <EQUAL? ,PRSI ,FEAST-TOPIC>>
		<COND (,FEAST-CALLED
		       <TELL "\"At La Reserve. I know. I have known since
you rounded the point.\"" CR>)
		      (T
		       <SETG FEAST-CALLED T>
		       <TELL
"\"Today, then. At La Reserve, under the arbor.\" She sends a boy
running with the word, and the boy runs as though good news might spoil."
CR>)>
		<RTRUE>)
	       (<AND <VERB? TELL> <EQUAL? ,PRSI ,FERNAND>>
		<TELL
"\"My cousin scowls because the sea gave me you. He will get over it,
or he will not.\"" CR>
		<RTRUE>)
	       (<VERB? TELL>
		<TELL
"\"Tell me anything. I have been listening for your voice for three
months.\"" CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"Black hair, black eyes, and the walk of a queen in a fishing village."
CR>
		<RTRUE>)>>

<ROUTINE FERNAND-FCN ()
	 <COND (<VERB? TELL>
		<TELL
"\"Marry her, then,\" says Fernand, to the wall. \"Sailors drown.\"" CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A Catalan fisherman with a soldier's shoulders and a boy's grievance."
CR>
		<RTRUE>)>>

<ROUTINE FEAST-TOPIC-FCN () <RFALSE>>

<ROUTINE FEAST-TABLE-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"Arles sausages, boiled crawfish, and the wine of La Malgue. Everything
you love is at this table, and so is everything that hates you." CR>
		<RTRUE>)>>

<ROUTINE RESERVE-WEST ()
	 <COND (,FEAST-CALLED
		<TELL "Leave your own betrothal feast? Mercedes has your arm."
CR>
		<RFALSE>)
	       (T ,QUAY)>>

<ROUTINE RESERVE-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-ENTER>
		<COND (<AND ,FEAST-CALLED <EQUAL? ,FEAST-TURNS 0>>
		       <SETG FEAST-TURNS 1>
		       <MOVE ,MERCEDES ,RESERVE>
		       <MOVE ,FERNAND ,RESERVE>
		       <MOVE ,DANGLARS ,RESERVE>
		       <MOVE ,CADEROUSSE ,RESERVE>
		       <MOVE ,FATHER ,RESERVE>
		       <MOVE ,MORREL ,RESERVE>)>
		<RFALSE>)
	       (<EQUAL? .RARG ,M-END>
		<COND (<G? ,FEAST-TURNS 0> <FEAST-TICK>)>
		<RFALSE>)
	       (T <RFALSE>)>>

<ROUTINE FEAST-TICK ()
	 <SETG FEAST-TURNS <+ ,FEAST-TURNS 1>>
	 <COND (<EQUAL? ,FEAST-TURNS 2>
		<TELL
"Morrel is on his feet with a glass. \"To the Pharaon, and to her
captain!\" The table roars." CR>
		<RTRUE>)
	       (<EQUAL? ,FEAST-TURNS 3>
		<TELL
"Your father is crying and pretending it is the wine. Mercedes's hand
is on your sleeve and has not moved in an hour." CR>
		<RTRUE>)
	       (<EQUAL? ,FEAST-TURNS 4>
		<TELL
"Fernand has gone white and left his plate. Danglars leans to
Caderousse and says something behind his hand." CR>
		<RTRUE>)
	       (<EQUAL? ,FEAST-TURNS 5>
		<TELL
"Someone is knocking at the door of the arbor, and the knock is not a
guest's." CR>
		<RTRUE>)
	       (<G? ,FEAST-TURNS 5>
		<THE-ARREST>
		<RTRUE>)>>

<ROUTINE THE-ARREST ()
	 <SETG FEAST-TURNS 0>
	 <TELL
"Four soldiers and a corporal, and a commissary of police with his hat
in his hand." CR CR
"\"Edmond Dantes, I arrest you in the name of the law!\" Mercedes does
not scream. She looks at you as though memorizing you, which is the
worst thing she could do." CR CR
"They take you by the harbor road to the Palais de Justice, and a young
magistrate rises from his own betrothal dinner to hear the case."
CR CR>
	 <GOTO ,VSTUDY>
	 <RTRUE>>

<ROUTINE VSTUDY-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-END>
		<SETG VILL-TURNS <+ ,VILL-TURNS 1>>
		<COND (<AND <NOT ,LETTER-GIVEN> <G? ,VILL-TURNS 3>>
		       <TELL
"\"The letter, Dantes. Do not make me send men to your father's room
for it.\" He holds out his hand, and you put the packet into it." CR CR>
		       <VILLEFORT-BURNS>)>
		<RFALSE>)
	       (T <RFALSE>)>>

<ROUTINE VILLEFORT-FCN ()
	 <COND (<AND <VERB? GIVE SHOW> <EQUAL? ,PRSO ,ELBA-LETTER>>
		<VILLEFORT-BURNS>
		<RTRUE>)
	       (<VERB? TELL>
		<COND (,LETTER-GIVEN
		       <TELL "\"Say nothing more. Nothing is the only safe
thing you own.\"" CR>)
		      (T
		       <TELL
"\"You are accused of being a Bonapartist agent. Your accuser is
anonymous; his handwriting is disguised; his information is exact.\" He
studies you. \"You touched at Elba. You carry a letter. Give it to me.\""
CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"Twenty-seven years old and already marble. He is reading you and
something else at the same time." CR>
		<RTRUE>)>>

<ROUTINE VILLEFORT-BURNS ()
	 <COND (,LETTER-GIVEN <RFALSE>)>
	 <SETG LETTER-GIVEN T>
	 <REMOVE ,ELBA-LETTER>
	 <ADD-SCORE 5>
	 <TELL
"He breaks the seal, and reads the address, and the marble cracks all
at once. Noirtier. Rue Coq-Heron. His own father's name, on a letter
from the Emperor's island." CR CR
"He turns and puts it into the grate and holds it down with the poker
until there is nothing. \"You see, I destroy it? Now: you never carried
a letter. Deny it boldly, and you are saved.\"" CR CR>
	 <TELL
"He calls the gendarmes himself. There is a boat that night, and a
black rock standing out of a black sea." CR CR
"\"The Chateau d'If?\" you cry. The gendarme smiles and does not
answer." CR CR>
	 <ENTER-ACT-TWO>
	 <RTRUE>>

"=== ACT TRANSITIONS ==="

;"Retire everyone whose scene is over. The proper names live on the
global topic objects; leaving a used-up NPC lying in a room it will
never be entered again only creates ASK ABOUT ambiguity."
<ROUTINE RETIRE-CAST ()
	 <REMOVE ,MORREL>
	 <REMOVE ,DANGLARS>
	 <REMOVE ,MERCEDES>
	 <REMOVE ,FERNAND>
	 <REMOVE ,CADEROUSSE>
	 <REMOVE ,FATHER>
	 <REMOVE ,CREW>
	 <REMOVE ,VILLEFORT>
	 <REMOVE ,COCLES>
	 <RTRUE>>

<ROUTINE ENTER-ACT-TWO ()
	 <SETG ACT 2>
	 <SETG PHASE 1>
	 <TELL
"    ***  ACT TWO: THE CHATEAU D'IF, 1815  ***" CR CR>
	 <RETIRE-CAST>
	 <GOTO ,CELL34>
	 <ENABLE <QUEUE I-JAILER 12>>
	 <RTRUE>>
