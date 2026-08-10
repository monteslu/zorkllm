"DVERBS - new syntax, game-required verb routines, and shared helpers
for DRACULA: The Un-Dead."

"------------------------------------------------------------------
New syntax. The engine's gsyntax covers about a hundred verbs; these
are the forms the design needs that it lacks."

<SYNTAX SHOW OBJECT (HELD CARRIED HAVE) TO OBJECT (FIND ACTORBIT)
	(ON-GROUND IN-ROOM) = V-SHOW>
<SYNONYM SHOW DISPLAY PRESENT>

<SYNTAX WATCH OBJECT = V-WATCH>
<SYNONYM WATCH OBSERVE GUARD>

;"ASK someone ABOUT something. The engine has TELL X ABOUT Y (V-TELL)
but no ASK form at all; ASK routes to the same action so every NPC
routine can answer either phrasing with one <VERB? TELL> test."
<SYNTAX ASK OBJECT (FIND ACTORBIT) (ON-GROUND IN-ROOM) ABOUT OBJECT
	= V-TELL>
<SYNTAX ASK OBJECT (FIND ACTORBIT) (ON-GROUND IN-ROOM) FOR OBJECT
	= V-ASK-FOR>
<SYNTAX ASK OBJECT (FIND ACTORBIT) (ON-GROUND IN-ROOM) = V-TELL>

<SYNTAX CATCH OBJECT = V-CATCH>
<SYNONYM CATCH TRAP>

<SYNTAX SIT = V-SIT-DOWN>
<SYNTAX SIT ON OBJECT = V-SIT-ON>

;"The engine has WEAR but no un-wear: REMOVE/DOFF fall through to
V-TAKE, whose 'already wearing it' check fires before the object's own
action ever runs, so the boots could never come off. A distinct verb
gives BOOTS-FCN (and the crucifix) a hook of their own."
;"gsyntax's only THROW-with-indirect forms demand an ACTORBIT target
(THROW X AT/WITH someone), so THROW LETTER THROUGH BARS could never
reach the window's action. THROUGH is already a synonym of WITH, so a
plain non-ACTORBIT form is what the design's phrasings need."
<SYNTAX THROW OBJECT (HELD CARRIED HAVE) WITH OBJECT = V-THROW-AT>
<SYNTAX THROW OBJECT (HELD CARRIED HAVE) AT OBJECT = V-THROW-AT>
<SYNTAX THROW OBJECT (HELD CARRIED HAVE) OUT OBJECT = V-THROW-AT>

;"X is the near-universal IF abbreviation for EXAMINE and the engine
does not define it. A wandering player types it constantly."
<SYNONYM EXAMINE X>

<SYNTAX REMOVE OBJECT (HELD CARRIED) = V-DOFF>
<SYNTAX TAKE OFF OBJECT (HELD CARRIED) = V-DOFF>
<SYNONYM REMOVE DOFF>

<SYNTAX WRITE OBJECT = V-WRITE>
<SYNONYM WRITE COMPOSE>

<SYNTAX DRAW OBJECT = V-DRAWRING>

<SYNTAX SEAL OBJECT = V-SEAL>

<SYNTAX STOP OBJECT = V-STOPOBJ>
<SYNONYM STOP HALT INTERCEPT>

<SYNTAX BLOW OBJECT (HELD CARRIED HAVE) = V-BLOWOBJ>

<SYNTAX HANG OBJECT (HELD CARRIED HAVE) ON OBJECT = V-HANG>
<SYNTAX HANG OBJECT (HELD CARRIED HAVE) AROUND OBJECT = V-HANG>
<SYNONYM HANG DRAPE>

<SYNTAX RUB OBJECT (HELD CARRIED HAVE) ON OBJECT = V-RUB-ON>

<SYNTAX SLEEP = V-SLEEP>
<SYNONYM SLEEP NAP DOZE REST>

<SYNTAX HELP = V-HELP>

<SYNTAX PIN OBJECT = V-PIN>
<SYNTAX PIN OBJECT TO OBJECT = V-PIN>

<SYNTAX LOOK OUT OBJECT = V-LOOK-OUT>

<SYNTAX CLIMB OUT OBJECT = V-THROUGH>
<SYNTAX CLIMB DOWN = V-KLIMB-DOWN>
<SYNTAX CLIMB UP = V-KLIMB-UP>

<SYNTAX KILL OBJECT (FIND ACTORBIT) (ON-GROUND IN-ROOM) = V-SIMPLE-KILL>
<SYNTAX ATTACK OBJECT (FIND ACTORBIT) (ON-GROUND IN-ROOM) = V-SIMPLE-KILL>

<SYNTAX STAKE OBJECT = V-STAKEV>

<SYNONYM OPEN PRY>

"------------------------------------------------------------------
Default handlers for the new verbs. Nearly every real use is
intercepted by an object or room action; these are the polite floors."

<ROUTINE V-SHOW ()
	 <COND (<FSET? ,PRSI ,ACTORBIT>
		<TELL "You hold up " D ,PRSO ", to no visible effect." CR>)
	       (T
		<TELL "It has no eyes to see." CR>)>>

<ROUTINE V-WATCH ()
	 <TELL "You watch for a while. Nothing changes but the light." CR>>

<ROUTINE V-ASK-FOR ()
	 <TELL "You are given nothing but a look." CR>>

<ROUTINE V-CATCH ()
	 <TELL "Your hands close on nothing but air and dignity." CR>>

<ROUTINE V-SIT-DOWN ()
	 <TELL "You sit down for a moment. It does not help, but it is not
nothing." CR>>

<ROUTINE V-SIT-ON ()
	 <TELL "There is no sitting on that." CR>>

;"Objects intercept this; the floor just drops the thing."
<ROUTINE V-THROW-AT ()
	 <TELL "It bounces off, and lies where it falls." CR>
	 <MOVE ,PRSO ,HERE>>

<ROUTINE V-DOFF ()
	 <COND (<NOT <FSET? ,PRSO ,WEARBIT>>
		<TELL "You are not wearing that." CR>)
	       (T
		<TELL "You take off the " D ,PRSO "." CR>)>>

<ROUTINE V-WRITE ()
	 <TELL "There is nothing here worth setting down." CR>>

<ROUTINE V-DRAWRING ()
	 <TELL "You trace it in the air, to no purpose." CR>>

<ROUTINE V-SEAL ()
	 <TELL "There is no unhallowed thing here that wants sealing." CR>>

<ROUTINE V-STOPOBJ ()
	 <TELL "It is not moving." CR>>

<ROUTINE V-BLOWOBJ ()
	 <TELL "You blow on it. Nothing answers." CR>>

<ROUTINE V-HANG ()
	 <PERFORM ,V?PUT-ON ,PRSO ,PRSI>>

<ROUTINE V-RUB-ON ()
	 <TELL "You rub " D ,PRSO " on " D ,PRSI ", to no clear purpose." CR>>

;"SLEEP is a phase-advance in every act, but only where sleeping is
safe; elsewhere it warns once and refuses. Per-act clocks own the
actual advance (DO-SLEEP is defined in DACT1)."
<ROUTINE V-SLEEP ()
	 <DO-SLEEP>>

<ROUTINE V-HELP ()
	 <TELL
"Move with compass directions, and IN, OUT, UP, DOWN. Useful commands:
LOOK, EXAMINE things, READ papers, TAKE and DROP, OPEN and CLOSE, ASK
someone ABOUT something, SHOW a thing TO someone, GIVE, WAIT, SLEEP,
and SCORE. Study everything; this house rewards attention. When the
game warns you plainly, believe it." CR>>

<ROUTINE V-PIN ()
	 <TELL "There is nothing here to pin, or to pin it to." CR>>

<ROUTINE V-LOOK-OUT ()
	 <TELL "You see nothing remarkable that way." CR>>

<ROUTINE V-KLIMB-DOWN ()
	 <DO-WALK ,P?DOWN>>

<ROUTINE V-KLIMB-UP ()
	 <DO-WALK ,P?UP>>

<ROUTINE V-SIMPLE-KILL ()
	 <COND (<FSET? ,PRSO ,ACTORBIT>
		<TELL "Bare hands are a poor argument here." CR>)
	       (T
		<TELL "Violence will not mend that." CR>)>>

<ROUTINE V-STAKEV ()
	 <TELL "That is not a thing to be staked." CR>>

"------------------------------------------------------------------
Engine-required verbs and hooks."

<GLOBAL SCORE-MAX 210>

<ROUTINE V-SCORE ("OPTIONAL" (ASK? T))
	 <TELL "Your score is " N ,SCORE>
	 <TELL " (total of " N ,SCORE-MAX " points), in " N ,MOVES>
	 <COND (<1? ,MOVES> <TELL " move.">)
	       (T <TELL " moves.">)>
	 <CRLF>
	 <TELL "That earns you the rank of ">
	 <COND (<L? ,SCORE 20> <TELL "Solicitor's Clerk">)
	       (<L? ,SCORE 50> <TELL "Journal-Keeper">)
	       (<L? ,SCORE 85> <TELL "Believer in Things You Cannot">)
	       (<L? ,SCORE 125> <TELL "Pupil of Van Helsing">)
	       (<L? ,SCORE 165> <TELL "Sterilizer of Earth">)
	       (<L? ,SCORE 200> <TELL "Philosopher and Metaphysician">)
	       (T <TELL "King Laugh">)>
	 <TELL "." CR>
	 ,SCORE>

<ROUTINE V-DIAGNOSE ()
	 <COND (<EQUAL? ,ACT 1>
		<TELL
"Your heart runs quick and light, as it has since you first saw this
castle. You are unhurt. So far the harm done here is all to your
certainty about the world." CR>)
	       (<EQUAL? ,ACT 2>
		<TELL
"You are well, only wind-blown. It is Lucy who wants watching." CR>)
	       (<EQUAL? ,ACT 3>
		<TELL
"You are tired in the way of doctors: too much watching, too little
sleep, and a mind that will not stop diagnosing." CR>)
	       (T
		<TELL
"You are worn to bone and purpose. It is enough. It will have to be."
CR>)>>

<ROUTINE JIGS-UP (DESC "OPTIONAL" (PLAYER? <>))
	 <TELL .DESC CR CR>
	 <TELL
"The journal ends here. (Type RESTORE to take up an earlier page, or
RESTART to begin the record anew.)" CR CR>
	 <V-SCORE>
	 <FINISH>>

<ROUTINE FIND-WEAPON (WHO)
	 <RFALSE>>

"------------------------------------------------------------------
Shared helpers."

<GLOBAL ACT 1>

<ROUTINE AWARD (N)
	 <SETG BASE-SCORE <+ ,BASE-SCORE .N>>
	 <SETG SCORE ,BASE-SCORE>>

<OBJECT BANK
	(DESC "bank")
	(FLAGS INVISIBLE NDESCBIT)>

<ROUTINE BANK-ALL ("AUX" X N)
	 <SET X <FIRST? ,WINNER>>
	 <REPEAT ()
		 <COND (<NOT .X> <RETURN>)>
		 <SET N <NEXT? .X>>
		 <MOVE .X ,BANK>
		 <SET X .N>>>

<ROUTINE SWITCH-ACT (NEW-HERE "AUX" V)
	 <BANK-ALL>
	 <SETG HERE .NEW-HERE>
	 <MOVE ,WINNER ,HERE>
	 <SETG LIT <LIT? ,HERE>>
	 <V-LOOK>>
