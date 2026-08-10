"DACT1 - Act I: Castle Dracula. The day/night clock, the Count's
circuit, the brides, the supper, the mirror, the letters, the vault,
and the escape down the wall."

"---- Act I state ----"

<GLOBAL DAY 0>          ;"0 = arrival night; 1-4 the four days"
<GLOBAL NIGHT T>
<GLOBAL PHASE-TICKS 0>
<GLOBAL ARRIVAL-STATE 0>
<GLOBAL SUPPER-ASKS 0>
<GLOBAL DOOR-TRIED <>>
<GLOBAL SHAVE-READY <>>
<GLOBAL SHAVE-DONE <>>
<GLOBAL CHOKE <>>
<GLOBAL STUCK-COUNT 0>
<GLOBAL STUCK-OPEN <>>
<GLOBAL LIZARD-SEEN <>>
<GLOBAL LETTER-WRITTEN <>>
<GLOBAL LETTER-SENT <>>
<GLOBAL GOLD-TAKEN <>>
<GLOBAL DRACULA-ROOM-SEEN <>>
<GLOBAL BOX-OPENED <>>
<GLOBAL COUNT-STRUCK <>>
<GLOBAL BRIDES-TURNS 0>
<GLOBAL BRIDES-RESCUED <>>
<GLOBAL BRIDES-WARDED <>>
<GLOBAL WING-SAFE <>>
<GLOBAL WOLF-DOOR-STATE 0>
<GLOBAL ESCAPE-OPEN <>>
<GLOBAL DESCENT 0>
<GLOBAL LEDGE-POS 0>
<GLOBAL LEDGE-FROM <>>
<GLOBAL ATTACK-WARNED <>>
<GLOBAL DUSK-WARNED <>>
<GLOBAL SLEEP-WARNED <>>
<GLOBAL STAIR-WARNED <>>
<GLOBAL CRUCIFIX-WARNED <>>
<GLOBAL DRACULA-LOC <>>
<GLOBAL DRACULA-STEP 0>
<GLOBAL CRUCIFIX-WORN <>>
<GLOBAL BOOTS-WORN <>>

"---- The castle clock ----"

<ROUTINE LAMP-HELD? ()
	 <OR <HELD? ,HAND-LAMP> <HELD? ,ELECTRIC-LAMP>>>

<ROUTINE I-CASTLE ("AUX" (SAID <>))
	 <COND (<NOT <EQUAL? ,ACT 1>> <RFALSE>)>
	 <SETG PHASE-TICKS <+ ,PHASE-TICKS 1>>
	 <COND (,NIGHT
		<COND (<AND <G? ,DAY 0> <NOT <EQUAL? ,DAY 0>>>
		       <SET SAID <DRACULA-CIRCUIT>>)>
		<COND (<G? ,PHASE-TICKS 34>
		       <ACT1-DAWN>
		       <SET SAID T>)>)
	       (T
		<COND (<AND <EQUAL? ,DAY 4> <EQUAL? ,PHASE-TICKS 20>>
		       <TELL
"The sun is dropping toward the western peaks." CR>
		       <SET SAID T>)
		      (<AND <EQUAL? ,DAY 4> <EQUAL? ,PHASE-TICKS 28>>
		       <TELL
"The light is failing on the snow of the far ranges. Now, or never." CR>
		       <SET SAID T>)
		      (<G? ,PHASE-TICKS 34>
		       <ACT1-DUSK>
		       <SET SAID T>)>)>
	 .SAID>

<ROUTINE ACT1-DUSK ()
	 <SETG NIGHT T>
	 <SETG PHASE-TICKS 0>
	 <SETG WING-SAFE <>>
	 <TELL CR
"The sun drops behind the western peaks. Night, and the castle wakes." CR>
	 <COND (<EQUAL? ,DAY 4>
		<FINAL-NIGHTFALL>)
	       (T
		<SETG DRACULA-LOC ,LIBRARY>
		<SETG DRACULA-STEP 0>
		<DRACULA-APPEARS ,LIBRARY>
		<COND (<BELOW-STAIRS?>
		       <TELL CR
"You are below stairs, in his part of the dark, and the dark has just
become his. From up the stone screw of the stair comes a sound like a
man remembering how to breathe." CR>
		       <JIGS-UP
"It is behind you on the stair, and it is not hurrying, because it does
not need to.">)>)>>

<ROUTINE BELOW-STAIRS? ()
	 <EQUAL? ,HERE ,CIRCULAR-STAIR ,DARK-PASSAGE ,RUINED-CHAPEL ,VAULT>>

<ROUTINE FINAL-NIGHTFALL ()
	 <COND (<AND <EQUAL? ,HERE ,CASTLE-LEDGE> <G? ,DESCENT 0>>
		<TELL
"Above you, in the castle, a silvery laughter begins, room by room, as
if the house itself were being searched. Keep climbing." CR>)
	       (<EQUAL? ,HERE ,CASTLE-LEDGE>
		<TELL
"Above you, in the castle, a silvery laughter begins, room by room. The
wall is all the world now. Climb." CR>)
	       (T
		<TELL
"The light goes out of the sky like a snuffed lamp. Somewhere below, a
door you never found opens without a sound, and a silvery, musical
laughter comes up the winding stair -- such a laugh as never came
through human lips. 'Your time is not yet come,' he told them once. It
has come now." CR>
		<JIGS-UP
"They are patient, and the castle is theirs, and every door you reach
is locked but the last one, which opens on three smiling faces.">)>>

<ROUTINE ACT1-DAWN ()
	 <SETG NIGHT <>>
	 <SETG DAY <+ ,DAY 1>>
	 <SETG PHASE-TICKS 0>
	 <SETG SLEEP-WARNED <>>
	 <SETG STAIR-WARNED <>>
	 <DRACULA-RETIRES>
	 <COND (<IN? ,BRIDES ,LADIES-WING> <MOVE ,BRIDES ,BANK>)>
	 <TELL CR
"A cock crows, thin and far. Morning. You are safe -- as safe as this
place allows." CR>
	 <COND (<EQUAL? ,DAY 2>
		<SETG SHAVE-READY T>
		<TELL CR
"There is hot water steaming at your door, and no one in the corridor
who could have carried it. You could do with a shave." CR>)
	       (<EQUAL? ,DAY 3>
		<MOVE ,SZGANY ,COURTYARD>
		<TELL CR
"From below comes the ring of hammers and the chatter of strange
voices. Gypsies -- Szgany -- have camped in the courtyard, working at
great square boxes. Where there are hands, letters may travel." CR>)
	       (<EQUAL? ,DAY 4>
		<MOVE ,SZGANY ,BANK>
		<SETG ESCAPE-OPEN T>
		<TELL CR
"Heavy wheels grind in the courtyard, and cracking whips, and the
chorus of the Szgany dies away down the rocky road. The great door is
shut, and the chains rattle; there is a grinding of the key in the
lock. You are alone in the castle with those awful women. The wall,
then. Today, in the light, or never." CR>)>>

<ROUTINE DRACULA-APPEARS (RM)
	 <MOVE ,DRACULA .RM>
	 <FCLEAR ,DRACULA ,NDESCBIT>
	 <PUTP ,DRACULA ,P?LDESC
"The Count is here, courteous as winter.">
	 <COND (<EQUAL? .RM ,HERE>
		<TELL CR
"The door opens without a sound. \"You are wakeful, my friend. The
nights here are long.\" The Count regards you with something that is
nearly warmth." CR>)>>

<ROUTINE DRACULA-RETIRES ()
	 <SETG DRACULA-LOC <>>
	 <FSET ,DRACULA ,NDESCBIT>
	 <COND (<G? ,DAY 1>
		<MOVE ,DRACULA ,GREAT-BOX>)
	       (T <MOVE ,DRACULA ,BANK>)>>

<GLOBAL CIRCUIT-TICKS 0>

<ROUTINE DRACULA-CIRCUIT ("AUX" NXT (SAID <>))
	 <COND (<NOT ,DRACULA-LOC> <RFALSE>)>
	 <SETG CIRCUIT-TICKS <+ ,CIRCUIT-TICKS 1>>
	 <COND (<L? ,CIRCUIT-TICKS 3> <RFALSE>)>
	 <SETG CIRCUIT-TICKS 0>
	 <SETG DRACULA-STEP <+ ,DRACULA-STEP 1>>
	 <COND (<G? ,DRACULA-STEP 3> <SETG DRACULA-STEP 0>)>
	 <SET NXT <COND (<EQUAL? ,DRACULA-STEP 0> ,LIBRARY)
			(<EQUAL? ,DRACULA-STEP 1> ,DINING-ROOM)
			(<EQUAL? ,DRACULA-STEP 2> ,ENTRANCE-HALL)
			(T ,COURTYARD)>>
	 <COND (<EQUAL? ,DRACULA-LOC ,HERE>
		<TELL CR
"The Count inclines his head. \"Sleep well.\" The dark of the doorway
takes him without a fold of his cloak catching the light." CR>
		<SET SAID T>)>
	 <SETG DRACULA-LOC .NXT>
	 <MOVE ,DRACULA .NXT>
	 <COND (<EQUAL? .NXT ,HERE>
		<TELL CR
"A step in the passage, unhurried. He has all the nights there are.
The door opens without a sound, and the Count is with you." CR>
		<SET SAID T>)>
	 .SAID>

"---- SLEEP: the phase advance, dispatched by act ----"

<ROUTINE DO-SLEEP ()
	 <COND (<EQUAL? ,ACT 1> <SLEEP-ACT1>)
	       (<EQUAL? ,ACT 2> <WHITBY-ADVANCE>)
	       (<EQUAL? ,ACT 3> <PURFLEET-WAIT>)
	       (<EQUAL? ,ACT 4>
		<COND (<EQUAL? ,HERE ,VARNA-HOTEL> <VARNA-ADVANCE>)
		      (<EQUAL? ,HERE ,CAMP> <CAMP-ADVANCE>)
		      (T
		       <TELL
"There is no sleeping here, and no time for it." CR>)>)
	       (T
		<TELL
"Sleep? With the sun going down that road? No." CR>)>>

<ROUTINE SLEEP-ACT1 ()
	 <COND (<EQUAL? ,HERE ,BEDROOM>
		<COND (,NIGHT
		       <TELL
"You bolt the door that has no bolt, and lie down in your clothes with
the beads in your fist, and sleep as the hunted sleep." CR>
		       <ACT1-DAWN>)
		      (T
		       <TELL
"You sleep the afternoon away in the one safe room, and wake with the
light going red on the wall." CR>
		       <ACT1-DUSK>)>)
	       (,NIGHT
		<COND (<NOT ,SLEEP-WARNED>
		       <SETG SLEEP-WARNED T>
		       <TELL
"Sleep tugs at you. Not here. His own words: haste to your own chamber;
there are bad dreams for those who sleep unwisely." CR>)
		      (T
		       <JIGS-UP
"You sleep where you sit, and wake to a silvery laughter and three
faces very close, and the sweet honey breath, and the two sharp teeth
that do not pause this time.">)>)
	       (T
		<TELL
"Not here, and not in daylight, with so little of it left to spend."
CR>)>>

"---- Shared Act I room handling ----"

<ROUTINE ACT1-COMMON (RARG)
	 <COND (<NOT <EQUAL? ,ACT 1>> <RFALSE>)>
	 <COND (<EQUAL? .RARG ,M-BEG>
		<COND (,CHOKE
		       <COND (<AND <VERB? WALK> <EQUAL? ,PRSO ,P?NORTH>>
			      <SETG CHOKE <>>
			      <SETG SHAVE-DONE T>
			      <TELL
"You tear free and through the door. Behind you, unhurried, a voice:
\"Another time, then. We have many nights before us.\" You do not stop
until the dining-room fire is between you and everything." CR>
			      <MOVE ,WINNER ,DINING-ROOM>
			      <SETG HERE ,DINING-ROOM>
			      <V-FIRST-LOOK>
			      <RTRUE>)
			     (<VERB? LOOK EXAMINE SCORE> <RFALSE>)
			     (T
			      <JIGS-UP
"The hand at your throat is cold as river stone and strong as a
closing door. The last thing you see is that the room behind him,
in the little glass on the floor, is empty.">
			      <RTRUE>)>)
		      (<AND <VERB? WAIT> <NOT ,NIGHT> <G? ,DAY 0>>
		       <COND (<AND <EQUAL? ,DAY 4> <NOT ,DUSK-WARNED>>
			      <SETG DUSK-WARNED T>
			      <TELL
"You have no hours to spare. Already the sun is dropping toward the
western peaks, and when it goes behind them, the castle is theirs." CR>
			      <RTRUE>)
			     (T
			      <TELL
"You let the hours slide over you like grey water: the light crossing
the floor, the wolves tuning below, the castle listening." CR>
			      <ACT1-DUSK>
			      <RTRUE>)>)
		      (<AND <VERB? PRAY>
			    <EQUAL? ,HERE ,RUINED-CHAPEL ,VAULT>>
		       <TELL
"You say what you remember of the office for the dead, in a chapel
built for it and long unused to it. The words fall into the turned
earth and lie there like seed in salt. But you feel better for them." CR>
		       <RTRUE>)>)>
	 <RFALSE>>

<ROUTINE ACT1-PLAIN-FCN (RARG)
	 <ACT1-COMMON .RARG>>

<ROUTINE ACT1-STAIR-FCN (RARG)
	 <ACT1-COMMON .RARG>>

"---- Courtyard, great door, entrance hall ----"

<ROUTINE COURTYARD-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<COND (<EQUAL? ,ACT 4>
		       <TELL
"The courtyard of Castle Dracula, in snow and hard daylight. You know
this place from a dead man's journal you have read until you dream it.
The great doors of the keep stand north." CR>
		       <RTRUE>)
		      (T
		       <TELL
"A vast courtyard of black stone under broken battlements. Dark
archways yawn on every side, all barred beyond. The great nail-studded
door of the keep stands north">
		       <COND (<IN? ,SZGANY ,COURTYARD>
			      <TELL
", and the Szgany are camped about their boxes, singing at their work">)>
		       <TELL "." CR>
		       <RTRUE>)>)
	       (T <ACT1-COMMON .RARG>)>>

<ROUTINE COURTYARD-NORTH ()
	 <COND (<EQUAL? ,ACT 4>
		<COND (,DOORS-BROKEN <RETURN ,RUINED-CHAPEL>)
		      (T
		       <TELL
"The great doors hang shut. Break them from their hinges first, lest
some ill-intent or ill-chance should close them behind you." CR>
		       <RFALSE>)>)
	       (<FSET? ,GREAT-DOOR ,OPENBIT>
		<RETURN ,ENTRANCE-HALL>)
	       (T
		<TELL "The great door is shut fast." CR>
		<RFALSE>)>>

<ROUTINE GREAT-DOOR-FCN ()
	 ;"Act III (ACT 4) re-uses this door as Van Helsing's hammer work."
	 <COND (<EQUAL? ,ACT 4>
		<COND (<VERB? MUNG ATTACK SIMPLE-KILL OPEN PUSH MOVE>
		       <BREAK-THE-DOORS>
		       <RTRUE>)
		      (<VERB? EXAMINE>
		       <COND (,DOORS-BROKEN
			      <TELL
"The great doors lie flat in the snow where you threw them, and the
doorway stands open to the sky and shall not shut again." CR>)
			     (T
			      <TELL
"The great doors of the keep, shut and rust-hinged, with a winter's
snow banked against them. They would close behind a man very
conveniently." CR>)>
		       <RTRUE>)>
		<RFALSE>)>
	 <COND (<NOT <EQUAL? ,ACT 1>> <RFALSE>)>
	 <COND (<VERB? KNOCK>
		<COND (<AND <EQUAL? ,DAY 0> <NOT <FSET? ,GREAT-DOOR ,OPENBIT>>
			    <EQUAL? ,HERE ,COURTYARD>>
		       <ARRIVAL-DOOR-OPENS>
		       <RTRUE>)
		      (T
		       <TELL
"You knock. The sound goes away into the stone and does not come back."
CR>
		       <RTRUE>)>)
	       (<VERB? OPEN>
		<COND (<FSET? ,GREAT-DOOR ,OPENBIT>
		       <TELL "It stands open." CR>)
		      (<AND ,NIGHT <G? ,DAY 2>
			    <EQUAL? ,HERE ,ENTRANCE-HALL>
			    <EQUAL? ,WOLF-DOOR-STATE 0>>
		       <WOLF-DOOR-SCENE>)
		      (<EQUAL? ,DAY 0>
		       <TELL "It does not move." CR>)
		      (<NOT ,DOOR-TRIED>
		       <SETG DOOR-TRIED T>
		       <TELL
"The bolts draw back, one by one, and the chains come free in your
hands -- and the door is locked, and the key is gone. The castle is a
veritable prison, and you are the prisoner in it." CR>)
		      (T
		       <TELL
"Bolts and chains yield as before, and the lock holds as before. The
key is wherever HE is." CR>)>
		<RTRUE>)
	       (<VERB? CLOSE>
		<TELL "Whatever keeps this door needs no help from you." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"Old oak, studded with great iron nails, set in a doorway of massive
stone. The bolts and chains are on this country's side; the lock
answers to one key only, and you have never seen it." CR>
		<RTRUE>)>>

<ROUTINE ARRIVAL-DOOR-OPENS ()
	 <SETG ARRIVAL-STATE 2>
	 <FSET ,GREAT-DOOR ,OPENBIT>
	 <TELL
"From within comes a sound of heavy steps and the rattle of long-unused
chains. The great door swings back, and in the doorway stands a tall
old man, clean-shaven but for a long white moustache, clad in black
from head to foot, holding an antique silver lamp." CR CR
"\"Welcome to my house! Enter freely and of your own will!\" He does
not step out to meet you. \"Come freely. Go safely; and leave something
of the happiness you bring!\"" CR>>

<ROUTINE ENTRANCE-HALL-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-ENTER>
		<COND (<AND <EQUAL? ,ACT 1> <EQUAL? ,ARRIVAL-STATE 2>>
		       <SETG ARRIVAL-STATE 3>
		       <FCLEAR ,GREAT-DOOR ,OPENBIT>
		       <MOVE ,DRACULA ,DINING-ROOM>
		       <TELL CR
"The moment you cross the threshold his grip closes on your bag -- cold
fingers, strong past all argument. \"You are my guest, and it is late;
my people are not available.\" Behind you the great door closes with a
clang, and the chains go home. He precedes you up the winding stair
with the lamp, and the smell of supper follows from somewhere above." CR>
		       <RTRUE>)>)
	       (T <ACT1-COMMON .RARG>)>>

<ROUTINE HALL-SOUTH ()
	 <COND (<EQUAL? ,WOLF-DOOR-STATE 1>
		<SETG WOLF-DOOR-STATE 2>
		<TELL
"The wolves surge at the gap, red-tongued, joyous. One step more and
they will have you. The Count watches you with polite, infinite
attention. Behind you the hall stands open -- north, and live." CR>
		<RFALSE>)
	       (<EQUAL? ,WOLF-DOOR-STATE 2>
		<JIGS-UP
"You take the step. The Count does not move at all. The wolves take
you on the threshold, and the last human thing you hear is the door
closing, softly, on the warm and lighted hall -- given to the wolves,
and at your own instigation.">
		<RTRUE>)
	       (<FSET? ,GREAT-DOOR ,OPENBIT>
		<RETURN ,COURTYARD>)
	       (T
		<TELL
"The great door is locked, and the key is wherever HE is." CR>
		<RFALSE>)>>

<ROUTINE WOLF-DOOR-SCENE ()
	 <SETG WOLF-DOOR-STATE 1>
	 <TELL
"The Count is on the stair, holding the lamp. \"You wish to leave? So
soon? Then come.\" He draws the bolts himself; the great door swings
slowly back. Outside, the courtyard is a carpet of moving grey backs
and green eyes: the wolves, waiting like a congregation. \"You are
free to go, my friend. The night is fine.\"" CR>>

"---- Doors of the upper floors ----"

<ROUTINE LOCKED-DOORS-FCN ()
	 <COND (<VERB? OPEN PUSH MOVE UNLOCK KNOCK>
		<TELL
"Locked, every one, and bolted, and the bolts rusted home. Doors,
doors everywhere, and all of them of one mind about you." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"Stout old doors, locked and bolted. Nothing lives behind most of
them but furniture under sheets. Most of them." CR>
		<RTRUE>)>>

<ROUTINE UPPER-PASSAGE-FCN (RARG)
	 <ACT1-COMMON .RARG>>

<ROUTINE STUCK-DOOR-FCN ()
	 <COND (,STUCK-OPEN
		<COND (<VERB? PUSH MOVE OPEN CLOSE>
		       <TELL
"It stands open now, at the one angle the sunken floor allows." CR>
		       <RTRUE>)
		      (<VERB? EXAMINE>
		       <TELL
"Forced back on its shrieking hinges, and proud of you, in its way." CR>
		       <RTRUE>)>
		<RFALSE>)>
	 <COND (<VERB? EXAMINE>
		<TELL
"The heavy door is not locked -- fallen. Its hinges have sunk, and it
rests upon the floor. Weight, not keys, is the argument here." CR>
		<RTRUE>)
	       (<AND <VERB? TURN> <EQUAL? ,PRSI ,SHOVEL>>
		<STUCK-DOOR-OPENS
"You work the shovel blade under the sagging edge and heave. With a
shriek of hinges the heavy door grinds back.">
		<RTRUE>)
	       (<VERB? PUSH MOVE OPEN>
		<SETG STUCK-COUNT <+ ,STUCK-COUNT 1>>
		<COND (<EQUAL? ,STUCK-COUNT 1>
		       <TELL
"It gives an inch, gritting on stone. Your shoulder aches." CR>)
		      (<EQUAL? ,STUCK-COUNT 2>
		       <TELL
"Another inch, dearly bought. It wants more than an arm. A lever might
spare your shoulder -- or your whole frame might do it." CR>)
		      (T
		       <STUCK-DOOR-OPENS
"You set your whole frame to it. With a shriek of hinges the heavy
door grinds back.">)>
		<RTRUE>)>>

<ROUTINE STUCK-DOOR-OPENS (STR)
	 <COND (<NOT ,STUCK-OPEN>
		<SETG STUCK-OPEN T>
		<FSET ,STUCK-DOOR ,OPENBIT>
		<AWARD 3>
		<TELL .STR CR>)>>

<ROUTINE STUCK-EAST ()
	 <COND (,STUCK-OPEN <RETURN ,LADIES-WING>)
	       (T
		<TELL
"The heavy door is jammed; its hinges have sunk, and it rests upon the
floor." CR>
		<RFALSE>)>>

<ROUTINE STUCK-WEST ()
	 <COND (,STUCK-OPEN <RETURN ,UPPER-PASSAGE>)
	       (T
		<TELL "The heavy door is jammed shut." CR>
		<RFALSE>)>>

"---- Dining room, supper, library ----"

<ROUTINE DINING-ROOM-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-ENTER>
		<COND (<AND <EQUAL? ,ACT 1> <EQUAL? ,ARRIVAL-STATE 3>>
		       <SETG ARRIVAL-STATE 4>
		       <MOVE ,DRACULA ,DINING-ROOM>
		       <FCLEAR ,DRACULA ,NDESCBIT>
		       <PUTP ,DRACULA ,P?LDESC
"The Count stands by the hearth, and the firelight declines to find
his shadow.">
		       <TELL CR
"Supper is laid for one: roast chicken, cheese, a salad, old Tokay.
\"I pray you, be seated and sup how you please. You will, I trust,
excuse me that I do not join you; but I have dined already.\" He
stands by the great hearth as you eat, and the talk is easy, and his
teeth, when he smiles, lie a little over the red lips. Ask him what
you will; he seems in the mood for questions." CR>
		       <RTRUE>)>)
	       (T <ACT1-COMMON .RARG>)>>

<ROUTINE GOLD-SERVICE-FCN ()
	 <COND (<VERB? TAKE>
		<TELL
"You are a solicitor, not a house-breaker -- and some part of you
suspects the plate is counted by something that never sleeps." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"Plate and cups of beaten gold, older than any hallmark you know. No
silver anywhere in the service. No mirror in the room. You begin to
keep a small ledger of what is missing in this house." CR>
		<RTRUE>)>>

<ROUTINE LIBRARY-FCN (RARG)
	 <ACT1-COMMON .RARG>>

<GLOBAL ATLAS-READ <>>

<ROUTINE ATLAS-FCN ()
	 <COND (<VERB? READ EXAMINE>
		<TELL
"The great atlas falls open of itself at the map of England, as a book
will when one page is much consulted. Three places are ringed in old
ink: Whitby, on the eastern sea; Exeter, in the west; and Purfleet,
on the Thames east of London -- where, your papers say, the Count has
bought his house." CR>
		<COND (<NOT ,ATLAS-READ>
		       <SETG ATLAS-READ T>
		       <AWARD 2>)>
		<RTRUE>)>>

"---- Bedroom: bed, mirror, letters, boots, crucifix ----"

<ROUTINE BEDROOM-FCN (RARG)
	 <ACT1-COMMON .RARG>>

<ROUTINE BEDROOM-BED-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"A great curtained bed, older than the Armada and softer than it has
any right to be. Above it hangs the little crucifix's shadow-mark on
the stone, where such a thing has hung for centuries." CR>
		<RTRUE>)
	       (<VERB? THROUGH CLIMB-ON BOARD>
		<PERFORM ,V?SLEEP>
		<RTRUE>)>>

<ROUTINE BEDROOM-WINDOW-FCN ()
	 <COND (<VERB? LOOK-OUT LOOK-INSIDE>
		<COND (<IN? ,SZGANY ,COURTYARD>
		       <TELL
"Through the bars: the courtyard, and the Szgany at their fires among
ranked wooden boxes. One of them looks up at your window and grins,
and says something that makes the others laugh." CR>)
		      (T
		       <TELL
"Through the bars: the empty courtyard, black stone and moonshadow or
sun by turns, and the barred archways beyond." CR>)>
		<RTRUE>)
	       (<VERB? OPEN>
		<TELL "It opens a hand's-breadth, on bars and a fall." CR>
		<RTRUE>)
	       (<AND <VERB? THROW THROW-AT> <EQUAL? ,PRSO ,LETTER>>
		<COND (<IN? ,SZGANY ,COURTYARD>
		       <LETTER-THROWN>)
		      (T
		       <TELL
"There is no one below to take it, and paper thrown to the wind is
only confession." CR>)>
		<RTRUE>)
	       (<VERB? THROUGH>
		<TELL "The bars have opinions about that." CR>
		<RTRUE>)>>

<ROUTINE LETTER-THROWN ()
	 <SETG LETTER-SENT T>
	 <MOVE ,LETTER ,BANK>
	 <AWARD 5>
	 <TELL
"You wrap the shorthand letter about a coin from your purse and drop
it through the bars. Below, a brown hand fields it neatly; a hat is
swept off in a bow of great mockery and some little truth. It is done.
Whatever else happens in this castle, a page of it is over the wall."
CR>>

<ROUTINE LETTER-PAPER-FCN ()
	 <COND (<VERB? WRITE>
		<COND (,LETTER-WRITTEN
		       <TELL "The letters are written." CR>)
		      (T
		       <SETG LETTER-WRITTEN T>
		       <MOVE ,LETTER ,WINNER>
		       <MOVE ,LETTER-PAPER ,BANK>
		       <TELL
"He has had you write three letters, post-dated -- the twelfth of June,
the nineteenth, the twenty-ninth -- saying that you have left the
castle and are well. You know now the span of your life, and you write
a fourth letter he has not asked for: in shorthand, to Mina, the truth
of this place. If it reaches the coast of Yorkshire before you do, at
least the truth will not die in here with you." CR>)>
		<RTRUE>)
	       (<VERB? READ EXAMINE>
		<TELL
"Good letter paper and a pen. What is wanted is a messenger, and the
castle does not keep one -- though gypsies camp sometimes in the
courtyard, and everything in this country can be bought." CR>
		<RTRUE>)>>

<ROUTINE LETTER-FCN ()
	 <COND (<VERB? READ EXAMINE>
		<TELL
"Shorthand, close and quick: everything -- the locked doors, the
absent mirrors, the thing that crawled down the wall in the moonlight,
face down, cloak spread like wings. And at the end: whatever comes, I
loved you." CR>
		<RTRUE>)>>

<ROUTINE SHAVING-GLASS-FCN ()
	 <COND (<VERB? EXAMINE RUB LOOK-INSIDE>
		<COND (<AND <EQUAL? ,ACT 1> ,SHAVE-READY <NOT ,SHAVE-DONE>
			    <EQUAL? ,HERE ,BEDROOM>>
		       <SHAVING-SCENE>
		       <RTRUE>)
		      (T
		       <TELL
"Your little shaving glass from Exeter. It shows you your own face,
which is doing its best." CR>
		       <RTRUE>)>)>>

<ROUTINE SHAVING-SCENE ()
	 <SETG SHAVE-DONE T>
	 <TELL
"You prop the glass on the sill and lather, and have made the first
stroke when a hand falls on your shoulder and the Count's voice says
\"Good-morning.\" You start -- the razor nicks your chin -- and the
start is this: in the glass you can see the whole room behind you, and
there is no one in it." CR CR>
	 <COND (,CRUCIFIX-WORN
		<SETG SHAVE-DONE T>
		<MOVE ,SHAVING-GLASS ,BANK>
		<MOVE ,SHARD ,BEDROOM>
		<FSET ,SHARD ,NDESCBIT>
		<AWARD 5>
		<TELL
"The blood runs down your chin, and his eyes blaze, and his hand darts
for your throat -- and touches the beads of the crucifix, and stops as
if it had touched a stove. The change is instant, and courtly. \"Take
care how you cut yourself. It is more dangerous than you think in this
country.\" He plucks up the glass. \"And this is the wretched thing
that has done the mischief. It is a foul bauble of man's vanity. Away
with it!\" -- and flings it through the bars, where it rings to pieces
on the stones far below. A long silvered sliver lies on the sill. When
you look up from it, you are alone." CR>)
	       (T
		<SETG CHOKE T>
		<TELL
"The blood runs down your chin, and his eyes blaze, and his hand is at
your bare throat -- nothing between his skin and yours -- and it is
not stopping. The door is at your back, north. There will not be a
second chance to use it." CR>)>>

<ROUTINE SHARD-FCN ()
	 <COND (<AND <VERB? TAKE> <NOT ,SHARD-KEPT>>
		<SETG SHARD-KEPT T>
		<AWARD 2>
		<MOVE ,SHARD ,WINNER>
		<TELL
"You pick the sliver off the sill and wrap it in a handkerchief. It is
honest, and small, and it shows what is there. You may want a thing
that does that." CR>
		<RTRUE>)
	       (<VERB? EXAMINE LOOK-INSIDE>
		<TELL
"A finger-long sliver of the shaving glass. Small enough to hide, and
honest as ever: it shows what is there, and refuses what is not." CR>
		<RTRUE>)>>

<ROUTINE HAND-LAMP-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"A plain hand lamp, well trimmed. It has never wanted for oil; you
have stopped asking who fills it." CR>
		<RTRUE>)
	       (<VERB? LAMP-OFF>
		<TELL
"In this castle? You will keep every light you have." CR>
		<RTRUE>)>>

<ROUTINE WARDROBE-FCN ()
	 <COND (<VERB? EXAMINE OPEN LOOK-INSIDE SEARCH>
		<COND (<G? ,DAY 2>
		       <TELL
"Your travelling suit is gone, and your hat, and your papers of
identity. Somewhere in the night a tall figure wears an Englishman's
clothes on an Englishman's errands, and what it does in them will be
laid at your name." CR>)
		      (T
		       <TELL
"Your good travelling suit, brushed and hung -- by whom, you have
stopped asking." CR>)>
		<RTRUE>)>>

<ROUTINE BOOTS-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"Stout Exeter boots, honest on a pavement, useless on a wall." CR>
		<RTRUE>)
	       (<AND <VERB? TAKE DOFF DROP> ,BOOTS-WORN>
		<SETG BOOTS-WORN <>>
		<TELL
"You pull off your boots and knot the laces through your belt. The
stone is cold through your stockings, and closer, somehow. Fingers
and toes, like the lizard went." CR>
		<RTRUE>)
	       (<AND <VERB? WEAR> <NOT ,BOOTS-WORN>>
		<SETG BOOTS-WORN T>
		<TELL "You pull your boots back on." CR>
		<RTRUE>)
	       (<AND <VERB? DROP> ,BOOTS-WORN>
		<SETG BOOTS-WORN <>>
		<RFALSE>)>>

<ROUTINE CRUCIFIX-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"The innkeeper's wife's rosary, the crucifix worn smooth by her
thumbs. For your mother's sake, she said. You were taught to think
such objects idolatrous. You are being retaught." CR>
		<RTRUE>)
	       (<AND <VERB? TAKE DOFF DROP> ,CRUCIFIX-WORN>
		<COND (<NOT ,CRUCIFIX-WARNED>
		       <SETG CRUCIFIX-WARNED T>
		       <TELL
"Something in you clings to it. Are you sure? The old woman's eyes
said: for your mother's sake." CR>
		       <RTRUE>)
		      (T
		       <SETG CRUCIFIX-WORN <>>
		       <TELL
"You lift the beads over your head. Your neck feels bare as a
stubble-field." CR>
		       <COND (<VERB? DROP> <RFALSE>)>
		       <RTRUE>)>)
	       (<AND <VERB? WEAR> <NOT ,CRUCIFIX-WORN>>
		<SETG CRUCIFIX-WORN T>
		<SETG CRUCIFIX-WARNED <>>
		<TELL
"You hang the beads about your neck again, and something in the room
relaxes -- possibly you." CR>
		<RTRUE>)>>

"---- Landing, ledge, wall ----"

<ROUTINE SOUTH-LANDING-FCN (RARG)
	 <ACT1-COMMON .RARG>>

<ROUTINE LANDING-WINDOW-FCN ()
	 <COND (<VERB? LOOK-OUT>
		<COND (<AND ,NIGHT <NOT ,LIZARD-SEEN>>
		       <SETG LIZARD-SEEN T>
		       <TELL
"Moonlight, and the wall dropping sheer away -- and out of the Count's
window below, a head emerges, and then a whole man, and he crawls DOWN
the castle wall, face down, cloak spread about him like great wings,
fingers and toes gripping the bare stone. You watch until the dark
takes him. Where his body has gone, why may not another body go? Mem.:
the mortar is washed clean between the stones -- handholds every yard."
CR>)
		      (,NIGHT
		       <TELL
"Moonlit air, a thousand feet of it, over a sea of black treetops. The
wall below is all silver edges: stone, and the clean-washed joints
between the stones." CR>)
		      (T
		       <TELL
"Sky, and below the sill the wall drops a thousand feet, sheer as a
cut, to green treetops small as moss. South, very far, the land folds
away toward the world you came from." CR>)>
		<RTRUE>)
	       (<VERB? OPEN>
		<TELL "The casement swings wide on the gulf of air." CR>
		<RTRUE>)
	       (<VERB? THROUGH>
		<CLIMB-TO-LEDGE ,SOUTH-LANDING>
		<RTRUE>)>>

<ROUTINE LANDING-OUT ()
	 <CLIMB-TO-LEDGE-RM ,SOUTH-LANDING>>

<ROUTINE WING-OUT ()
	 <CLIMB-TO-LEDGE-RM ,LADIES-WING>>

<ROUTINE CLIMB-TO-LEDGE-RM (FROM)
	 <COND (,BOOTS-WORN
		<TELL
"Your boot-soles skid on the first stone. You scramble back over the
sill, heart hammering. Fingers and toes, like the lizard went -- bare
ones." CR>
		<RFALSE>)
	       (T
		<SETG LEDGE-FROM .FROM>
		<SETG LEDGE-POS 0>
		<RETURN ,CASTLE-LEDGE>)>>

<ROUTINE CLIMB-TO-LEDGE (FROM "AUX" RM)
	 <SET RM <CLIMB-TO-LEDGE-RM .FROM>>
	 <COND (.RM <GOTO .RM>)>>

<ROUTINE WING-WINDOW-FCN ()
	 <COND (<VERB? LOOK-OUT>
		<TELL
"Moonlight or day, the view is one long fall: the wall, the gulf, the
treetops. To the north along the ledge, another window: his." CR>
		<RTRUE>)
	       (<VERB? THROUGH>
		<CLIMB-TO-LEDGE ,LADIES-WING>
		<RTRUE>)>>

<ROUTINE CASTLE-LEDGE-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<COND (<G? ,DESCENT 0>
		       <TELL
"You are on the face of the wall itself, a thousand feet of air
plucking at your coat. Fingers and toes, and the clean mortar joints.
Down is the only direction left in the world." CR>)
		      (<EQUAL? ,LEDGE-POS 1>
		       <TELL
"A hand's-breadth of crumbling stone under the Count's own window,
which stands unlatched. The wind pulls at your coat like a living
thing. Do not look down." CR>)
		      (T
		       <TELL
"You stand on a hand's-breadth of crumbling stone above a gulf of
moonlit air; the window at your back, the wall going north along the
face. The wind pulls at your coat like a living thing. Do not look
down." CR>)>
		<RTRUE>)
	       (<EQUAL? .RARG ,M-BEG>
		<COND (<AND <G? ,DESCENT 0> <L? ,DESCENT 3>>
		       <COND (<OR <AND <VERB? WALK> <EQUAL? ,PRSO ,P?DOWN>>
				  <VERB? KLIMB-DOWN CLIMB-DOWN>>
			      <RFALSE>)
			     (<VERB? LOOK EXAMINE SCORE WAIT>
			      <TELL
"Nowhere to wait, nothing to see but stone an inch from your nose.
Breathe once. Keep climbing." CR>
			      <RTRUE>)
			     (T
			      <TELL
"The wall does not care what you meant to do instead. Fingers and
toes. Keep climbing." CR>
			      <RTRUE>)>)
		      (<AND <VERB? LEAP> <NOT ,ESCAPE-OPEN>>
		       <LEDGE-GUARD>
		       <RTRUE>)>)>
	 <RFALSE>>

<ROUTINE LEDGE-GUARD ()
	 <TELL
"A thousand feet of moonlight below. At its foot a man may sleep -- as
a man. Not yet. Not while Mina waits." CR>>

<ROUTINE LEDGE-NORTH ()
	 <COND (<EQUAL? ,LEDGE-POS 1>
		<TELL "The ledge crumbles to nothing further north." CR>
		<RFALSE>)
	       (T
		<SETG LEDGE-POS 1>
		<TELL
"Sixty heartbeats of sideways prayer, and you are under the window the
crawling thing came out of. It is unlatched." CR>
		<RFALSE>)>>

<ROUTINE LEDGE-SOUTH ()
	 <COND (<EQUAL? ,LEDGE-POS 0>
		<TELL "The ledge gives out to the south." CR>
		<RFALSE>)
	       (T
		<SETG LEDGE-POS 0>
		<TELL
"You edge back south along the wall to the window you first came out
of." CR>
		<RFALSE>)>>

<ROUTINE LEDGE-IN ()
	 <COND (<G? ,DESCENT 0>
		<TELL "There is no window here. There is only wall." CR>
		<RFALSE>)
	       (<EQUAL? ,LEDGE-POS 1>
		<RETURN ,DRACULA-ROOM>)
	       (T
		<RETURN ,LEDGE-FROM>)>>

<ROUTINE LEDGE-DOWN ()
	 <COND (<NOT ,ESCAPE-OPEN>
		<LEDGE-GUARD>
		<RFALSE>)
	       (<EQUAL? ,DESCENT 0>
		<SETG DESCENT 1>
		<TELL
"You lower yourself over the lip, and the world becomes very simple:
fingers, toes, and the clean-washed joints of the stone. God does not
make walls this old without handholds. Keep climbing." CR>
		<RFALSE>)
	       (<EQUAL? ,DESCENT 1>
		<SETG DESCENT 2>
		<TELL
"Halfway. Once a stone goes out under your foot and falls a long time
before it makes any sound at all. You press your face to the wall
until the castle stops swaying, and go on. Keep climbing." CR>
		<RFALSE>)
	       (T
		<ACT1-FINISH>
		<RFALSE>)>>

<ROUTINE DRACULA-ROOM-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-ENTER>
		<COND (<NOT ,DRACULA-ROOM-SEEN>
		       <SETG DRACULA-ROOM-SEEN T>
		       <AWARD 5>
		       <TELL CR
"You came in by his window, as he goes out by it. Whatever this room
was, it is now only where a thing keeps its gold and its door to the
earth below." CR>)>
		<COND (,NIGHT
		       <TELL CR
"It is night, and this is his hour and his room. Below, on the stair,
the dark is listening. Leave." CR>)>
		<RFALSE>)
	       (T <ACT1-COMMON .RARG>)>>

<ROUTINE DRACULA-ROOM-OUT ()
	 <SETG LEDGE-POS 1>
	 <RETURN ,CASTLE-LEDGE>>

<ROUTINE DRACULA-ROOM-DOWN ()
	 <COND (<FSET? ,CORNER-DOOR ,OPENBIT>
		<RETURN ,CIRCULAR-STAIR>)
	       (T
		<TELL "The corner door is shut." CR>
		<RFALSE>)>>

<ROUTINE GOLD-FCN ()
	 <COND (<VERB? TAKE>
		<COND (,GOLD-TAKEN
		       <TELL "Your pockets hold coin enough." CR>)
		      (T
		       <SETG GOLD-TAKEN T>
		       <AWARD 5>
		       <MOVE ,GOLD ,WINNER>
		       <FCLEAR ,GOLD ,TRYTAKEBIT>
		       <FSET ,GOLD ,TAKEBIT>
		       <TELL
"You fill your pockets with coins three centuries cold. If you live,
you will need them." CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE COUNT>
		<TELL
"Roman gold and Turkish, British guineas, ducats -- a mound of it,
dulled with grave-dust, and none of it newer than three hundred
years. Money enough to buy half of London. It has been used to buy
exactly that." CR>
		<RTRUE>)>>

<ROUTINE CORNER-DOOR-FCN ()
	 <COND (<VERB? OPEN>
		<COND (<FSET? ,CORNER-DOOR ,OPENBIT>
		       <TELL "It stands open on the descending stair." CR>)
		      (T
		       <FSET ,CORNER-DOOR ,OPENBIT>
		       <TELL
"The heavy door swings inward on a stone stair screwing down into the
dark, and the smell comes up to meet you: old earth, newly turned." CR>)>
		<RTRUE>)
	       (<VERB? CLOSE>
		<FCLEAR ,CORNER-DOOR ,OPENBIT>
		<TELL "Closed, for what comfort that is." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"Heavy, old, and unlocked: the one unlocked door in the castle, which
tells you everything about what lives below." CR>
		<RTRUE>)>>

<ROUTINE DRACULA-WINDOW-FCN ()
	 <COND (<VERB? LOOK-OUT>
		<TELL
"The ledge, the gulf, the world. His own private door to the night."
CR>
		<RTRUE>)
	       (<VERB? THROUGH>
		<SETG LEDGE-POS 1>
		<GOTO ,CASTLE-LEDGE>
		<RTRUE>)>>

"---- Below stairs ----"

<ROUTINE CIRCULAR-STAIR-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-ENTER>
		<COND (<AND ,NIGHT <EQUAL? ,ACT 1>>
		       <SETG STAIR-WARNED T>
		       <TELL CR
"It is night. From below, up the stone screw of the stair, comes a
sound like a man remembering how to breathe. Every law this castle has
taught you says: not below, not now, not you." CR>)>
		<RFALSE>)
	       (T <ACT1-COMMON .RARG>)>>

<ROUTINE CSTAIR-DOWN ()
	 <COND (<AND ,NIGHT <EQUAL? ,ACT 1>>
		<JIGS-UP
"You go down into the breathing dark. At the third turning of the
stair it stops breathing, because it no longer needs to pretend, and
its hands are exactly as strong as you always feared.">
		<RFALSE>)
	       (<NOT <LAMP-HELD?>>
		<TELL
"Black as the pit below, and that odour rising. You will not go a step
into it without a light." CR>
		<RFALSE>)
	       (T <RETURN ,DARK-PASSAGE>)>>

<ROUTINE RUINED-CHAPEL-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<COND (<EQUAL? ,ACT 4>
		       <TELL
"The broken roof lets in the winter sky. The boxes are gone to
England; the digging is old and frozen. Steps descend to the vault,
where the tombs are." CR>)
		      (T
		       <TELL
"The roof is broken and the light looks in on ground dug over and
over. Great wooden boxes stand ranked like coffins waiting for a
congregation -- you count fifty. Steps descend into the vaults; the
dark passage runs north." CR>)>
		<RTRUE>)
	       (T <ACT1-COMMON .RARG>)>>

<ROUTINE CHAPEL-NORTH ()
	 <COND (<EQUAL? ,ACT 4>
		<TELL
"That way is caved and frozen. Only the vault below still opens." CR>
		<RFALSE>)
	       (T <RETURN ,DARK-PASSAGE>)>>

<ROUTINE CHAPEL-DOWN ()
	 <COND (<EQUAL? ,ACT 4> <RETURN ,VAULT>)
	       (<NOT <LAMP-HELD?>>
		<TELL
"The steps go down into blind dark. Not without a light." CR>
		<RFALSE>)
	       (T <RETURN ,VAULT>)>>

<ROUTINE CHAPEL-OUT ()
	 <COND (<EQUAL? ,ACT 4>
		<COND (,CASTLE-SEALED
		       <GO-TO-ROAD>
		       <RFALSE>)
		      (T <RETURN ,COURTYARD>)>)
	       (T
		<TELL
"From the chapel the only ways are the dark passage north and the
vault below." CR>
		<RFALSE>)>>

<ROUTINE EARTH-G-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"The ground has been dug over, and lately. The earth is fresh. Nothing
grows in it. Something sleeps on it." CR>
		<RTRUE>)
	       (<VERB? SMELL>
		<TELL
"Old earth, newly turned: the smell you will now know in the dark for
the rest of your life." CR>
		<RTRUE>)
	       (<VERB? DIG>
		<TELL
"The Szgany have done all the digging this ground will ever need." CR>
		<RTRUE>)>>

<ROUTINE CASTLE-BOXES-FCN ()
	 <COND (<VERB? EXAMINE COUNT>
		<TELL
"Great square boxes of new wood, rope-handled, half of them filled
already with the fresh-dug earth. You count fifty. Bills of lading in
your own office named fifty boxes, for Whitby, by sea. You did the
conveyancing yourself." CR>
		<RTRUE>)
	       (<VERB? OPEN LOOK-INSIDE SEARCH>
		<TELL
"Earth, in this one, and this, and this: common earth, patted level as
a garden bed. Only in the vault below is there a box anyone troubled
to make holes in." CR>
		<RTRUE>)>>

<ROUTINE CHAPEL-DOOR-FCN ()
	 <COND (<AND <EQUAL? ,ACT 4> <VERB? SEAL>>
		<SEAL-THE-CASTLE>
		<RTRUE>)
	       (<AND <EQUAL? ,ACT 4> <VERB? PUT>
		     <EQUAL? ,PRSO ,WAFER>>
		<SEAL-THE-CASTLE>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<COND (<EQUAL? ,ACT 4>
		       <TELL
"The old chapel doorway, and every crack and jamb of it waiting for
what you carry in the envelope." CR>)
		      (T
		       <TELL
"A low doorway to the vault stair, worn by centuries of processions
that all went one way." CR>)>
		<RTRUE>)>>

<ROUTINE VAULT-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<COND (<EQUAL? ,ACT 4>
		       <TELL
"The old vault, swept by winter draughts. Three tombs stand here that
were never here before -- new-old, unmarked, waiting -- and beyond
them one great tomb more lordly than all the rest. On it is one word:
Dracula." CR>)
		      (,BOX-OPENED
		       <TELL
"Fragments of ancient coffins and piles of dust. In the third recess
the great box rests on new earth, its pierced lid thrown back, and
what is in it does not sleep. It waits with its eyes open." CR>)
		      (T
		       <TELL
"Fragments of ancient coffins and piles of dust. In the third recess a
single great box rests on new-dug earth, its lid leaning against the
wall, and the lid is pierced with holes." CR>)>
		<RTRUE>)
	       (T <ACT1-COMMON .RARG>)>>

<ROUTINE VAULT-UP ()
	 <RETURN ,RUINED-CHAPEL>>

<ROUTINE GREAT-BOX-FCN ()
	 <COND (<EQUAL? ,HERE ,FROZEN-ROAD> <RETURN <ROAD-BOX-FCN>>)>
	 <COND (<VERB? OPEN LOOK-INSIDE SEARCH>
		<COND (,BOX-OPENED
		       <TELL
"The lid is back, and he is as he was: gorged, new-fleshed, smiling at
nothing. The gash your shovel left weeps slowly above his brows." CR>
		       <COND (<NOT ,COUNT-STRUCK> <TELL
"There is no gash yet, of course. There is only the smile." CR>)>)
		      (T
		       <SETG BOX-OPENED T>
		       <MOVE ,DRACULA ,VAULT>
		       <FCLEAR ,DRACULA ,NDESCBIT>
		       <PUTP ,DRACULA ,P?LDESC
"In the great box, on the new earth, the Count lies filled and sleek.">
		       <AWARD 5>
		       <TELL
"You lift the lid aside. On a bed of new-dug earth lies the Count --
but younger, the white hair iron-grey, the cheeks fuller, the lips
redder, with fresh blood dried at their corners and trickled down the
chin. He is gorged, like a filthy leech, exhausted with his repletion.
The eyes are open, stony, dead-alive, and there is no breath, and no
pulse, and no doubt at all left in you about anything." CR>)>
		<RTRUE>)
	       (<VERB? CLOSE>
		<TELL
"You tip the pierced lid back over him. Your hands want washing.
Your memory wants it more." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A great box of new deal, holes pierced through the lid, resting on
fresh earth in the third recess." CR>
		<RTRUE>)>>

"Act III uses these; defined here because the vault owns them."

<GLOBAL DOORS-BROKEN <>>
<GLOBAL CASTLE-SEALED <>>
<GLOBAL TOMB-WAFERED <>>
<GLOBAL SISTERS-DEAD <>>
<GLOBAL FASCINATION 0>

<ROUTINE GREAT-TOMB-FCN ()
	 <COND (<AND <VERB? PUT> <EQUAL? ,PRSO ,WAFER>>
		<COND (,TOMB-WAFERED
		       <TELL "It is done, and done forever." CR>)
		      (T
		       <SETG TOMB-WAFERED T>
		       <AWARD 5>
		       <TELL
"You lay a portion of the Wafer on the black earth within the great
tomb, and so banish him from it, Un-Dead, for ever. Whatever races the
sunset toward this place is racing toward a locked door." CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE READ>
		<TELL
"One great tomb, more lordly than all the rest; huge it is, and nobly
proportioned. On it is but one word: Dracula." CR>
		<RTRUE>)
	       (<VERB? OPEN LOOK-INSIDE SEARCH>
		<TELL
"Black earth, pressed smooth by centuries of one sleeper. Empty now --
and it must be made empty for ever." CR>
		<RTRUE>)>>

<ROUTINE SISTER-TOMBS-FCN ()
	 <COND (<VERB? EXAMINE LOOK-INSIDE OPEN SEARCH>
		<COND (,SISTERS-DEAD
		       <TELL
"Three tombs, and in them three handfuls of native dust, at rest at
last. In the moment before the crumbling, each face wore a look of
gladness." CR>)
		      (T
		       <TELL
"Three tombs, and in them, radiant in the winter light, the three
sisters -- the fair one and the two dark -- so full of life and
voluptuous beauty that the stake drags at your hand. They are not
sleeping. They are waiting for dark." CR>)>
		<RTRUE>)
	       (<VERB? STAKEV SIMPLE-KILL ATTACK STAB>
		<WOOD-STAKE-THE-SISTERS>
		<RTRUE>)>>

"---- The Count himself ----"

<ROUTINE DRACULA-FCN ()
	 <COND (<AND <EQUAL? ,HERE ,FROZEN-ROAD>> <RETURN <ROAD-DRACULA-FCN>>)>
	 <COND (<AND <EQUAL? ,ACT 3>> <RETURN <PICC-DRACULA-FCN>>)>
	 <COND (<IN? ,DRACULA ,VAULT>
		<COND (<VERB? EXAMINE>
		       <TELL
"Gorged and new-made: the moustache iron-grey now, the mouth redder,
the whole man swollen with other lives">
		       <COND (,COUNT-STRUCK
			      <TELL
". Above the brows, your gash weeps slowly, and will scar">)>
		       <TELL ". The dead eyes are open, and there is hate
in them, and triumph, and no man at home to argue with." CR>
		       <RTRUE>)
		      (<VERB? SEARCH RUB TAKE>
		       <TELL
"You go through the clothes with your skin crawling: no key, nothing.
Then the dead eyes move -- or the light does -- and your nerve breaks
like a dropped plate. You are up the steps and in the chapel before
you know your legs have moved." CR>
		       <MOVE ,WINNER ,RUINED-CHAPEL>
		       <SETG HERE ,RUINED-CHAPEL>
		       <RTRUE>)
		      (<VERB? ATTACK SIMPLE-KILL STAB MUNG>
		       <COND (,COUNT-STRUCK
			      <TELL
"You cannot make your hand go down again. The gash weeps above the
stony eyes, and the eyes hold you, and your arm is water." CR>
			      <RTRUE>)
			     (<AND ,PRSI <NOT <EQUAL? ,PRSI ,SHOVEL>>>
			      <TELL
"Nothing you hold will bite on that but the shovel's edge." CR>
			      <RTRUE>)
			     (<NOT <HELD? ,SHOVEL>>
			      <TELL
"Bare hands, on that? Your body simply declines. There is a shovel
somewhere in this castle, and your body would hear arguments about
the shovel." CR>
			      <RTRUE>)
			     (T
			      <SETG COUNT-STRUCK T>
			      <AWARD 5>
			      <TELL
"You swing the shovel with everything your arm has ever owned -- and
the head turns on the pillow of earth, and the eyes fall full upon
you, dead and blazing at once, and the shovel turns in your hand and
glances from the face, gashing the forehead deep above the brows. The
lid falls half across the box with the wind of your swing. Your hand
will not lift the shovel again, and you know it, and so does he." CR>
			      <RTRUE>)>)
		      (<VERB? TELL>
		       <TELL
"By day there is no one in there to talk to. That is the whole
horror of it, and the whole mercy." CR>
		       <RTRUE>)>
		<RFALSE>)>
	 <COND (<VERB? TELL>
		<DRACULA-TOPICS>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A tall old man, clean-shaven but for a long white moustache, clad in
black from head to foot without one speck of colour. His face is
strong -- aquiline, high-bridged, the forehead lofty -- and the lips
lie red under the moustache, and the nails are cut to points, and
when he passes the lamp he throws no shadow at all." CR>
		<RTRUE>)
	       (<VERB? ATTACK SIMPLE-KILL STAB MUNG>
		<COND (,ATTACK-WARNED
		       <JIGS-UP
"His hand takes your wrist, and this time he does not smile. What
happens after is quick, and the castle has seen it many times, and
the wolves below sing for their supper.">
		       <RTRUE>)
		      (T
		       <SETG ATTACK-WARNED T>
		       <TELL
"His hand closes on your wrist like a steel vice, and he smiles.
\"Not yet, my friend. I have use for you.\" He releases you with
terrible gentleness. Next time he will not." CR>
		       <RTRUE>)>)
	       (<VERB? SHOW>
		<COND (<EQUAL? ,PRSO ,CRUCIFIX>
		       <TELL
"His eyes drop to the beads, and his face goes smooth as a closed
book. \"We are in Transylvania, and Transylvania is not England. Our
ways are not your ways, and there shall be to you many strange
things.\" He looks at everything in the room but your throat." CR>)
		      (T
		       <TELL
"He examines it with the courtesy of a man being shown a parish
newsletter." CR>)>
		<RTRUE>)
	       (<VERB? GIVE>
		<TELL
"\"Keep it, my friend. What is yours will come to me in time.\" The
smile is warm. The sentence is not." CR>
		<RTRUE>)
	       (<VERB? HELLO KISS>
		<TELL
"He inclines his head with old-world grace. \"I am Dracula; and I bid
you welcome.\"" CR>
		<RTRUE>)
	       (<VERB? LISTEN>
		<TELL
"His voice is deep, and the consonants come from somewhere with more
mountains than England has. You have stopped hearing the accent and
begun hearing the centuries." CR>
		<RTRUE>)>>

<ROUTINE DRACULA-TOPICS ()
	 <COND (<EQUAL? ,PRSI ,CASTLE-G>
		<SUPPER-COUNT>
		<TELL
"\"I am glad you found your way in here, for I am sure there is much
that will interest you. You may go anywhere you wish in the castle,
except where the doors are locked, where of course you will not wish
to go.\" The firelight stands very still." CR>)
	       (<EQUAL? ,PRSI ,GT-ENGLAND>
		<SUPPER-COUNT>
		<TELL
"\"I long to go through the crowded streets of your mighty London, to
be in the midst of the whirl and rush of humanity, to share its life,
its change, its death. Here I am noble; I am boyar; the common people
know me, and I am master. In your London, a stranger is nobody. Men
know him not -- and to know not is to care not for.\" He smiles at
the fire. \"I have been so long master that I would be master still.\"" CR>)
	       (<EQUAL? ,PRSI ,WOLVES-G>
		<SUPPER-COUNT>
		<TELL
"Far below, the wolves begin, valley answering valley. He goes to the
window as to music. \"Listen to them -- the children of the night.
What music they make!\" Something in your face amuses him. \"Ah, sir,
you dwellers in the city cannot enter into the feelings of the
hunter.\"" CR>)
	       (<EQUAL? ,PRSI ,GT-HISTORY>
		<TELL
"\"We Szekelys have a right to be proud, for in our veins flows the
blood of many brave races who fought as the lion fights, for
lordship.\" For an hour he is voivode and chronicle at once, and the
fire dies, and he does not notice, because the wars are all still
happening somewhere behind his eyes." CR>)
	       (<EQUAL? ,PRSI ,DRACULA>
		<TELL
"\"I love the shade and the shadow, and would be alone with my
thoughts when I may.\" It is the truest thing he has said all night,
and the saddest, and you write it down later with a shaking hand." CR>)
	       (<EQUAL? ,PRSI ,LETTER ,LETTER-PAPER>
		<TELL
"\"Write, my friend, by all means. Write that you are well, and that
you stay perhaps a month more.\" The perhaps sits on the table between
you like a knife." CR>)
	       (<EQUAL? ,PRSI ,SHAVING-GLASS ,SHARD>
		<TELL
"\"A foul bauble of man's vanity,\" he says, and the subject is
closed like a tomb door." CR>)
	       (<EQUAL? ,PRSI ,BRIDES>
		<TELL
"His face shutters. \"There are bad dreams for those who sleep
unwisely. Keep to your own rooms after dark, my friend, and your
dreams will keep to theirs.\"" CR>)
	       (T
		<TELL
"He turns the question as a man turns a card he does not mean to
play." CR>)>>

<ROUTINE SUPPER-COUNT ()
	 <COND (<AND <EQUAL? ,DAY 0> <L? ,SUPPER-ASKS 3>>
		<SETG SUPPER-ASKS <+ ,SUPPER-ASKS 1>>
		<COND (<EQUAL? ,SUPPER-ASKS 3>
		       <QUEUE-SUPPER-END>)>)>>

<ROUTINE QUEUE-SUPPER-END ()
	 <TELL CR
"Somewhere below, thin and far, a cock crows. The Count is on his feet
in one motion. \"Why, there is the morning again! How remiss I am to
let you stay up so long.\" At the door he turns, and bows. \"Sleep
well, my friend. Your chamber is south, through the little octagonal
room. I am away from home to-day until the evening.\"" CR>
	 <SETG DRACULA-LOC <>>
	 <FSET ,DRACULA ,NDESCBIT>
	 <MOVE ,DRACULA ,BANK>>

"---- The brides and the Ladies' Wing ----"

<ROUTINE LADIES-WING-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-ENTER>
		<COND (<AND <EQUAL? ,ACT 1> ,NIGHT <NOT ,WING-SAFE>>
		       <MOVE ,BRIDES ,LADIES-WING>
		       <SETG BRIDES-TURNS 1>
		       <TELL CR
"The moonlight through the diamond panes is full of dust, and the dust
is wrong: it thickens, gathers, takes shape. Three young women stand
in the moonbeam where no women were -- two dark, with high aquiline
noses like the Count's, and one fair, fair as fair can be. They look
at you and laugh together, a silvery, musical laugh, like water-glasses
played by a cunning hand. \"He is young and strong,\" one whispers.
\"There are kisses for us all.\"" CR>)>
		<RFALSE>)
	       (<EQUAL? .RARG ,M-END>
		<COND (<AND <IN? ,BRIDES ,LADIES-WING>
			    <EQUAL? ,HERE ,LADIES-WING>>
		       <BRIDES-ADVANCE>)>
		<RFALSE>)
	       (T <ACT1-COMMON .RARG>)>>

<ROUTINE BRIDES-ADVANCE ()
	 <SETG BRIDES-TURNS <+ ,BRIDES-TURNS 1>>
	 <COND (<EQUAL? ,BRIDES-TURNS 2>
		<TELL CR
"The fair one comes on, bending, until you can hear the churning of
her tongue behind the teeth, and her breath is honey-sweet, with a
bitter under it, the bitter smell of blood. Your eyelids weigh a
hundred years each. Some part of you says: door, west, now. It says
it very quietly." CR>)
	       (<EQUAL? ,BRIDES-TURNS 3>
		<TELL CR
"Her lips are at your throat -- two sharp teeth, just touching, just
pausing, and you wait with beating heart in an agony of anticipation
that is half longing --" CR CR>
		<COND (<NOT ,BRIDES-RESCUED>
		       <SETG BRIDES-RESCUED T>
		       <MOVE ,BRIDES ,BANK>
		       <TELL
"-- and the room fills with fury like weather. The Count is there, and
his hand closes on the fair one's neck and hurls her back across the
chamber. \"How dare you touch him, any of you? This man belongs to
me!\" The women laugh their terrible laugh -- \"You yourself never
loved; you never love!\" -- and the storm of the whole night goes out
like a lamp." CR CR>
		       <ACT1-DAWN>
		       <TELL CR
"You wake in your own bed, in daylight, with your collar loosened and
your boots set neatly by the door. If it was a dream, someone
carried you here through it." CR>
		       <MOVE ,WINNER ,BEDROOM>
		       <SETG HERE ,BEDROOM>)
		      (T
		       <JIGS-UP
"'Your time is not yet come,' he told them once, and took you from
under their teeth. He is not here to-night. The kiss is long, and at
the far end of it you are colder than the moonlight, and the journal
in your coat will be read by no one, ever.">)>)>>

<ROUTINE BRIDES-FCN ()
	 <COND (<AND <EQUAL? ,ACT 4> <EQUAL? ,HERE ,VAULT>>
		<RETURN <SISTER-TOMBS-FCN>>)>
	 <COND (<VERB? EXAMINE>
		<TELL
"Two dark, one fair, all three luminous as things lit from inside, and
all three wrong: no dust moves when their skirts move, and their
shadows have not followed them into the room." CR>
		<RTRUE>)
	       (<VERB? SHOW>
		<COND (<EQUAL? ,PRSO ,CRUCIFIX>
		       <MOVE ,BRIDES ,BANK>
		       <SETG WING-SAFE T>
		       <COND (<NOT ,BRIDES-WARDED>
			      <SETG BRIDES-WARDED T>
			      <AWARD 5>)>
		       <TELL
"You hold up the old woman's beads, and it is as if you had thrust a
torch at three moths. They recoil hissing, beauty curdling into
something older, and pour backward into the moonbeam, and the dust is
only dust, sifting down through empty light. The room stands silent.
The silence is on your side, for once." CR>
		       <RTRUE>)>)
	       (<VERB? TELL HELLO>
		<TELL
"Their answer is the laugh, silvery and musical and no more human
than bells are. Talk is not what they are here for." CR>
		<RTRUE>)
	       (<VERB? ATTACK SIMPLE-KILL KISS>
		<TELL
"Your body will not close with them. Every animal ancestor you have
is pulling the other way on the rein." CR>
		<RTRUE>)>>

"---- Szgany, wolves, misc ----"

<ROUTINE SZGANY-FCN ()
	 <COND (<EQUAL? ,HERE ,FROZEN-ROAD> <RETURN <ROAD-SZGANY-FCN>>)>
	 <COND (<VERB? EXAMINE>
		<TELL
"Szgany -- gypsies of the mountains, fearless and without religion,
who answer to no law but the great boyar in the castle. They work,
and sing, and do not once look up at the barred windows." CR>
		<RTRUE>)
	       (<VERB? TELL HELLO YELL>
		<TELL
"They point at you, and talk among themselves, and laugh. Whatever
you are to them, it is not a person whose letters get delivered
honestly." CR>
		<RTRUE>)
	       (<AND <VERB? GIVE> <EQUAL? ,PRSO ,LETTER>>
		<LETTER-THROWN>
		<RTRUE>)>>

<ROUTINE WOLVES-G-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"You cannot see them. You will always be able to hear them." CR>
		<RTRUE>)
	       (<VERB? LISTEN>
		<TELL
"Valley answers valley, below in the dark: the children of the night,
about their music." CR>
		<RTRUE>)>>

<ROUTINE WOLF-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"A great, gaunt grey head, red-eyed, filling the broken pane: a wolf
the size of the whole night." CR>
		<RTRUE>)
	       (<VERB? SHOW>
		<COND (<AND <EQUAL? ,PRSO ,CRUCIFIX> <WOLF-BEAT-ACTIVE?>>
		       <WOLF-REPELLED-NOW>
		       <RTRUE>)>)
	       (<AND <VERB? THROW THROW-AT> <EQUAL? ,PRSO ,GARLIC ,WREATH>
		     <WOLF-BEAT-ACTIVE?>>
		<WOLF-REPELLED-NOW>
		<RTRUE>)
	       (<VERB? ATTACK SIMPLE-KILL>
		<TELL
"It is a head in a window, and behind it a body the size of the
shrubbery. What is wanted here is not courage but the right
argument." CR>
		<RTRUE>)>>

<ROUTINE SUN-G-FCN ()
	 <COND (<VERB? EXAMINE>
		<COND (<EQUAL? ,HERE ,FROZEN-ROAD>
		       <ROAD-SUN-REPORT>
		       <RTRUE>)
		      (,NIGHT
		       <TELL "The sun is elsewhere, doing somebody else
some good." CR>
		       <RTRUE>)
		      (T
		       <TELL
"The one ally in this whole country that needs no persuading. It is
also, always, going." CR>
		       <RTRUE>)>)>>

<ROUTINE WALL-FCN ()
	 <COND (<VERB? EXAMINE>
		<COND (<EQUAL? ,HERE ,CASTLE-LEDGE ,SOUTH-LANDING>
		       <TELL
"Old stone, great blocks of it, and the mortar washed clean from
between them by five hundred winters: handholds every yard, for
whatever dares use them." CR>
		       <RTRUE>)
		      (T
		       <TELL "Honest stone, keeping its own counsel." CR>
		       <RTRUE>)>)
	       (<VERB? CLIMB-UP CLIMB-DOWN CLIMB-FOO>
		<COND (<EQUAL? ,HERE ,CASTLE-LEDGE>
		       <DO-WALK ,P?DOWN>
		       <RTRUE>)>)>>

"---- Act I ends ----"

<ROUTINE ACT1-FINISH ()
	 <SETG DESCENT 3>
	 <AWARD 15>
	 <TELL
"Stone by stone, joint by joint, and then softness under your feet:
grass, and steep meadow, and the trees taking you in like a church.
You look up once. The castle stands black and jagged against the sky,
and no face shows at any window, and you turn your back on it and
run, fall, run, downhill, west, alive." CR CR
"Here the shorthand journal of Jonathan Harker breaks off. Weeks
later a sick man will wake in a hospital at Buda-Pesth, and a letter
will go to England." CR CR
"-- From the journal of Mina Murray, Whitby, August. --" CR CR>
	 <SETG ACT 2>
	 <BANK-ALL>
	 <MOVE ,LUCY ,CRESCENT-BEDROOM>
	 <SETG HERE ,CRESCENT-BEDROOM>
	 <MOVE ,WINNER ,HERE>
	 <SETG LIT T>
	 <V-FIRST-LOOK>>
