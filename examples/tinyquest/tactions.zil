"TACTIONS - action routines for Tiny Quest."

<GLOBAL GEAR-PLACED <>>

<ROUTINE GARDEN-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK> <RFALSE>)>>

<ROUTINE FLOWERPOT-FCN ()
	 <COND (<AND <VERB? MOVE TAKE RAISE>
		     <FSET? ,BRASS-KEY ,INVISIBLE>>
		<FCLEAR ,BRASS-KEY ,INVISIBLE>
		<TELL
"Lifting the flowerpot reveals a small brass key that was hidden
beneath it!" CR>
		<COND (<VERB? TAKE> <RFALSE>)>
		<RTRUE>)>>

<ROUTINE SHED-DOOR-FCN ()
	 <COND (<VERB? OPEN>
		<COND (<FSET? ,SHED-DOOR ,OPENBIT>
		       <TELL "It's already open." CR>)
		      (T
		       <FSET ,SHED-DOOR ,OPENBIT>
		       <TELL
"The door opens with a groan of neglected hinges." CR>)>
		<RTRUE>)
	       (<VERB? CLOSE>
		<FCLEAR ,SHED-DOOR ,OPENBIT>
		<TELL "Closed." CR>
		<RTRUE>)>>

<ROUTINE TOOLBOX-FCN ()
	 <COND (<AND <VERB? OPEN> <FSET? ,TOOLBOX ,LOCKEDBIT>>
		<TELL "The toolbox is locked." CR>
		<RTRUE>)
	       (<AND <VERB? UNLOCK> <EQUAL? ,PRSI ,BRASS-KEY>>
		<FCLEAR ,TOOLBOX ,LOCKEDBIT>
		<TELL "The key turns, and the lock springs open." CR>
		<RTRUE>)>>

<ROUTINE SOCKET-FCN ()
	 <COND (<AND <VERB? PUT>
		     <EQUAL? ,PRSO ,BRASS-GEAR>
		     <EQUAL? ,PRSI ,MACHINE-SOCKET>
		     <NOT ,GEAR-PLACED>>
		<MOVE ,BRASS-GEAR ,MACHINE-SOCKET>
		<SETG GEAR-PLACED T>
		<SETG BASE-SCORE <+ ,BASE-SCORE 10>>
		<SETG SCORE ,BASE-SCORE>
		<TELL
"The gear slides home. Deep inside the machine something catches,
turns, and the whole cellar fills with a warm ticking - the heartbeat
of a clock that has waited years to run again. Well done!" CR>
		<RTRUE>)>>

"Engine-required verbs that normally live in the game's actions file."

<ROUTINE V-SCORE ("OPTIONAL" (ASK? T))
	 <TELL "Your score is " N ,SCORE>
	 <TELL " (total of " N ,SCORE-MAX " points), in " N ,MOVES>
	 <COND (<1? ,MOVES> <TELL " move.">)
	       (T <TELL " moves.">)>
	 <CRLF>
	 ,SCORE>

<ROUTINE V-DIAGNOSE ()
	 <TELL "You are in perfect health." CR>>

<ROUTINE JIGS-UP (DESC "OPTIONAL" (PLAYER? <>))
	 <TELL .DESC CR CR>
	 <TELL "    ****  You have died  ****" CR CR>
	 <V-SCORE>
	 <QUIT>>

"Combat-system hooks the engine verbs call; Tiny Quest has no combat."

<ROUTINE FIND-WEAPON (WHO)
	 <RFALSE>>

<GLOBAL SCORE-MAX 10>


