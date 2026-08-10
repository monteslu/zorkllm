"TIACTIONS - action routines, timers, scenes and scoring for
TREASURE ISLAND: A Tale of the Sea-Cook."

<GLOBAL SCORE-MAX 350>

;"=== Story state ==============================================="

;"ACT: 1 Benbow, 2 Bristol/ship, 3 island"
<GLOBAL ACT 1>
;"Act III phase: 0 ashore, 1 stockade, 2 escapade, 3 sea, 4 captive, 5 hunt, 6 cave"
<GLOBAL PHASE 0>

<GLOBAL BENBOW-CLOCK 0>
<GLOBAL RAID-STEP 0>
<GLOBAL RAID-PEEKS 0>
<GLOBAL BARREL-STEP 0>
<GLOBAL BARREL-WARNED <>>
<GLOBAL BARREL-FRESH <>>
<GLOBAL SIEGE-STEP 0>
<GLOBAL BOARDER-HITS 0>
<GLOBAL BOARDER-IDLE 0>
<GLOBAL EBB-STEP 0>
<GLOBAL HAWSER-CUTS 0>
<GLOBAL HAWSER-INSIST 0>
<GLOBAL SLACK-CLOCK 0>
<GLOBAL DRIFT-STEP 0>
<GLOBAL CORD-SEEN <>>
<GLOBAL BOARD-CHANCES 0>
<GLOBAL SAIL-STEP 0>
<GLOBAL DUEL-STEP 0>
<GLOBAL CLIMB-GRACE 0>
<GLOBAL CAPTIVE-STEP 0>
<GLOBAL HUNT-STEP 0>
<GLOBAL ROPE-FIGHTS 0>
<GLOBAL CAVE-STEP 0>
<GLOBAL DIG-COUNT 0>
<GLOBAL MARSH-HEARD <>>
<GLOBAL BEN-MET <>>
<GLOBAL BEN-FRIEND <>>
<GLOBAL CHEESED <>>
<GLOBAL WARNED <>>
<GLOBAL PRIMED <>>
<GLOBAL SILVER-FOUND <>>
<GLOBAL MAP-READ <>>
<GLOBAL NOTE-GIVEN <>>
<GLOBAL SEA-PHASE <>>
<GLOBAL BEACHED <>>
<GLOBAL NIGHTFALL <>>
<GLOBAL CANNON-CLOCK 0>
<GLOBAL PARROT-TICK 0>
<GLOBAL SPOT-NAG 0>

;"once-flags for scoring"
<GLOBAL S-SPOT <>> <GLOBAL S-KEY <>> <GLOBAL S-CHEST <>> <GLOBAL S-PACKET <>>
<GLOBAL S-RAID <>> <GLOBAL S-GIVE <>> <GLOBAL S-MAP <>> <GLOBAL S-NOTE <>>
<GLOBAL S-BARREL <>> <GLOBAL S-COUNCIL <>> <GLOBAL S-WAR <>> <GLOBAL S-ASHORE <>>
<GLOBAL S-BEN <>> <GLOBAL S-CHEESE <>> <GLOBAL S-LOGHOUSE <>> <GLOBAL S-SIEGE <>>
<GLOBAL S-CORACLE <>> <GLOBAL S-LAUNCH <>> <GLOBAL S-HAWSER <>> <GLOBAL S-BOARD <>>
<GLOBAL S-ROGER <>> <GLOBAL S-BEACH <>> <GLOBAL S-HANDS <>> <GLOBAL S-INGOT <>>
<GLOBAL S-SPOT2 <>> <GLOBAL S-AMBUSH <>> <GLOBAL S-CAVE <>> <GLOBAL S-SAIL <>>

<ROUTINE AWARD (N)
	<SETG BASE-SCORE <+ ,BASE-SCORE .N>>
	<SETG SCORE ,BASE-SCORE>
	<RTRUE>>

;"=== Scoring / status verbs ===================================="

<ROUTINE RANK-NAME ()
	<COND (<G? ,SCORE 349> <TELL "Gentleman o' Fortune">)
	      (<G? ,SCORE 324> <TELL "Cap'n">)
	      (<G? ,SCORE 269> <TELL "Sea-Cook">)
	      (<G? ,SCORE 219> <TELL "Quartermaster">)
	      (<G? ,SCORE 169> <TELL "Coxswain">)
	      (<G? ,SCORE 119> <TELL "Able Seaman">)
	      (<G? ,SCORE 74> <TELL "Ship's Boy">)
	      (<G? ,SCORE 34> <TELL "Cabin Boy">)
	      (T <TELL "Swab">)>>

<ROUTINE V-SCORE ("OPTIONAL" (ASK? T))
	<TELL "Your score is " N ,SCORE " of a possible " N ,SCORE-MAX
", in " N ,MOVES>
	<COND (<1? ,MOVES> <TELL " move.">) (T <TELL " moves.">)>
	<CRLF>
	<TELL "That rates you: "> <RANK-NAME> <TELL "." CR>
	,SCORE>

<ROUTINE V-DIAGNOSE ()
	<COND (,S-HANDS
	       <TELL
"You have a shoulder that will always know when weather is coming, and
a story nobody at home will believe." CR>)
	      (T <TELL "You are whole, which at your age is the usual state of
affairs, and at this rate will not last." CR>)>>

<ROUTINE JIGS-UP (DESC "OPTIONAL" (PLAYER? <>))
	<TELL .DESC CR CR>
	<TELL
"Your adventures end here - as Blind Pew's did, as Israel Hands' did, as
seventeen men of the Hispaniola's did. The sea keeps no favourites." CR CR>
	<TELL "    ****  You have died  ****" CR CR>
	<FINISH>>

;"Not-a-death ending (raid takes the packet)."
<ROUTINE GAME-OVER (DESC)
	<TELL .DESC CR CR>
	<TELL "    ****  Your adventure is over  ****" CR CR>
	<FINISH>>

<ROUTINE WINNER-END (DESC)
	<TELL .DESC CR CR>
	<TELL "    ****  You have won  ****" CR CR>
	<FINISH>>

<ROUTINE FIND-WEAPON (WHO)
	<COND (<AND <EQUAL? .WHO ,WINNER> <IN? ,CUTLASS ,WINNER>> ,CUTLASS)
	      (<AND <EQUAL? .WHO ,WINNER> <IN? ,GULLY ,WINNER>> ,GULLY)
	      (T <RFALSE>)>>

;"=== New syntax ================================================"

<SYNTAX SHOOT OBJECT = V-SHOOT>
<SYNTAX SHOOT OBJECT WITH OBJECT = V-SHOOT>
<SYNONYM SHOOT FIRE>

<SYNTAX PRIME OBJECT = V-PRIME>
<SYNTAX PRIME = V-PRIME>
<SYNONYM PRIME RELOAD>

<SYNTAX HIDE = V-HIDE>
<SYNTAX HIDE UNDER OBJECT = V-HIDE>

<SYNTAX SAIL = V-SAIL>
<SYNTAX SAIL OBJECT = V-SAIL>

<SYNTAX SNEAK = V-SNEAK>

;"IN had to leave <DIRECTIONS> (see BUILD-ISSUES.md); make it a verb."
<SYNONYM EXAMINE X>       ;"the modern IF habit; the engine predates it"

<SYNTAX IN = V-ENTER>
<SYNTAX INSIDE = V-ENTER>

;"The engine's BOARD wants a VEHBIT object in scope. The Hispaniola is
 scenery, not a vehicle, so widen the syntax and let SHIP-FCN decide."
<SYNTAX BOARD OBJECT (ON-GROUND IN-ROOM) = V-BOARD>

;"=== Timers ===================================================="

;"T1 - the Benbow clock."
<ROUTINE I-BENBOW ()
	<COND (<NOT <EQUAL? ,ACT 1>> <RFALSE>)>
	<SETG BENBOW-CLOCK <+ ,BENBOW-CLOCK 1>>
	<COND (<EQUAL? ,HERE ,UNDER-BRIDGE> <RFALSE>)>
	<COND (<EQUAL? ,BENBOW-CLOCK 8>
	       <TELL
"Far off on the frozen road: tap - tap - tap. It stops. It starts
again." CR>
	       <RTRUE>)
	      (<EQUAL? ,BENBOW-CLOCK 14>
	       <TELL
"The tapping again, nearer, and this time a low whistle answers it from
the hill. Whatever Flint's crew wants, it is in that chest upstairs -
and you have minutes, not hours." CR>
	       <RTRUE>)
	      (<EQUAL? ,BENBOW-CLOCK 19>
	       <TELL
"Feet on the road - many feet, running. Get out, get east, get under
something." CR>
	       <RTRUE>)
	      (<G? ,BENBOW-CLOCK 21>
	       <JIGS-UP
"They come through the door of your father's inn like weather. The blind
man's stick finds you before his crew does, and his hand is on your arm
like a vise, and he is not gentle, and he is not slow. Them that die
tonight, a wise man will say of another occasion, will be the lucky
ones - and he will not be thinking of you.">
	       <RTRUE>)>
	<RFALSE>>

;"T5 - the island cannon, two turns after Ben Gunn."
<ROUTINE I-CANNON ()
	<TELL
"The whole island wakes and bellows to a cannon, and the echoes come
back off the Spy-glass one after another. They have begun to fight." CR>
	<RTRUE>>

;"The parrot's ambience: deterministic rotation, no RANDOM."
<ROUTINE PARROT-NEAR? ()
	<OR <IN? ,PARROT ,HERE>
	    <AND <IN? ,SILVER ,HERE> <G? ,PHASE 3>>>>

<ROUTINE I-PARROT ()
	<COND (<NOT <PARROT-NEAR?>> <RFALSE>)>
	<SETG PARROT-TICK <+ ,PARROT-TICK 1>>
	<COND (<EQUAL? ,PARROT-TICK 4>
	       <SETG PARROT-TICK 0>
	       <TELL "\"Pieces of eight! Pieces of eight!\" screams the
parrot, and goes on screaming until Silver quiets her." CR>
	       <RTRUE>)
	      (<EQUAL? ,PARROT-TICK 2>
	       <TELL "The parrot says something that would curl a chaplain's
wig." CR>
	       <RTRUE>)>
	<RFALSE>>

;"=== ACT I: the Admiral Benbow ================================="

<ROUTINE PARLOUR-FCN (RARG)
	<COND (<EQUAL? .RARG ,M-END>
	       <COND (<AND <NOT ,S-PACKET>
			   <L? ,BENBOW-CLOCK 8>
			   <EQUAL? <SETG SPOT-NAG <+ ,SPOT-NAG 1>> 4>>
		      <TELL "The clock ticks. Ten o'clock, the spot said." CR>
		      <RTRUE>)>
	       <RFALSE>)>
	<RFALSE>>

<ROUTINE BILLY-BODY-FCN ()
	<COND (<VERB? SEARCH LOOK-INSIDE EXAMINE LOOK LOOK-UNDER>
	       <COND (<FSET? ,GULLY ,INVISIBLE>
		      <FCLEAR ,GULLY ,INVISIBLE>
		      <FCLEAR ,POCKET-COMPASS ,INVISIBLE>
		      <FCLEAR ,ODDMENTS ,INVISIBLE>
		      <FCLEAR ,TARRY-STRING ,INVISIBLE>
		      <TELL
"You go through the captain's pockets the way he taught you to gut a
fish: quickly, and without discussion. A gully knife with a crooked
handle, a pocket compass, and a pitiful drift of odds and ends -
tobacco, a thimble, needles and thread." CR CR>
		      <TELL
"And round his neck, under the shirt, a bit of tarry string with
something heavy on the end of it." CR>
		      <RTRUE>)
		     (T
		      <TELL
"Nothing else on him but tattoo-work and old weather. The tarry string
is still round his neck." CR>
		      <RTRUE>)>)
	      (<VERB? TAKE MOVE>
	       <TELL
"He was a big man in life and he is a bigger one now. Leave him for the
doctor." CR>
	       <RTRUE>)
	      (<VERB? ATTACK>
	       <TELL "Apoplexy got there before you did." CR>
	       <RTRUE>)>>

<ROUTINE BLACK-SPOT-FCN ()
	<COND (<VERB? READ READ-PAGE EXAMINE>
	       <TELL
"A little round of paper, blackened on the one side. On the other, in a
good clear hand: \"You have till ten tonight.\"" CR>
	       <RTRUE>)
	      (<AND <VERB? TAKE> <NOT ,S-SPOT>>
	       <SETG S-SPOT T>
	       <AWARD 5>
	       <RFALSE>)>>

<ROUTINE GULLY-FCN ()
	<COND (<VERB? EXAMINE>
	       <TELL
"The captain's clasp-knife, crooked in the handle and honest in the
blade. A boy going where you are going wants a knife." CR>
	       <RTRUE>)>>

<ROUTINE COMPASS-FCN ()
	<COND (<VERB? EXAMINE READ READ-PAGE>
	       <COND (<EQUAL? ,HERE ,SKELETON>
		      <TELL
"You lay the compass along the bones. The line runs east-southeast and
by east: Skeleton Island astern, and the tall trees ahead." CR>)
		     (T
		      <TELL
"A pocket compass, brass and scratched. The needle swings, settles, and
tells you north, which is more than anyone else has done tonight." CR>)>
	       <RTRUE>)>>

<ROUTINE ODDMENTS-FCN ()
	<COND (<VERB? EXAMINE>
	       <TELL
"Pigtail tobacco, a thimble, needles and thread. The whole estate of a
man who frightened a whole coast." CR>
	       <RTRUE>)>>

<ROUTINE STRING-FCN ()
	<COND (<AND <VERB? CUT> <EQUAL? ,PRSI ,GULLY>>
	       <FCLEAR ,BRASS-KEY ,INVISIBLE>
	       <MOVE ,BRASS-KEY ,WINNER>
	       <MOVE ,GULLY ,WINNER>
	       <FSET ,TARRY-STRING ,INVISIBLE>
	       <COND (<NOT ,S-KEY> <SETG S-KEY T> <AWARD 10>)>
	       <TELL
"The string is tarred and tough, but the gully is the captain's own and
knows its work. The key drops into your hand." CR CR>
	       <TELL
"You pocket the captain's gully too. A boy going where you are going
wants a knife." CR>
	       <RTRUE>)
	      (<VERB? CUT>
	       <TELL "Not with that. Tarred string wants a real edge." CR>
	       <RTRUE>)
	      (<VERB? TAKE MOVE OPEN>
	       <TELL
"The string is tarred and tough. Fingers won't do it - you want the
captain's own knife." CR>
	       <RTRUE>)
	      (<VERB? EXAMINE>
	       <TELL
"A bit of tarry string round the dead man's neck, with something heavy
under the shirt." CR>
	       <RTRUE>)>>

<ROUTINE KEY-FCN ()
	<COND (<VERB? EXAMINE>
	       <TELL "A little brass key on a stub of tarry string." CR>
	       <RTRUE>)>>

<ROUTINE CHAIR-FCN ()
	<COND (<VERB? EXAMINE>
	       <TELL
"The chair he went over in. It has been kicked halfway to the hearth." CR>
	       <RTRUE>)>>

<ROUTINE EMBERS-FCN ()
	<COND (<VERB? EXAMINE LOOK LOOK-INSIDE LOOK-UNDER>
	       <TELL
"The fire is nearly out, and there is nobody left in the house whose job
it is to build it up." CR>
	       <RTRUE>)>>

<ROUTINE CANDLE-FCN ()
	<COND (<VERB? EXAMINE>
	       <TELL "A tallow candle, burning steady. The moon is doing the
real work tonight." CR>
	       <RTRUE>)>>

<ROUTINE RUM-FCN ()
	<COND (<VERB? DRINK DRINK-FROM EAT>
	       <TELL
"\"The name of rum for you is death,\" said the doctor - and you are
fourteen." CR>
	       <RTRUE>)
	      (<VERB? EXAMINE>
	       <TELL "The rum that killed the captain, waiting patiently for
its next appointment." CR>
	       <RTRUE>)>>

<ROUTINE TILL-FCN ()
	<COND (<VERB? OPEN SEARCH LOOK-INSIDE EXAMINE TAKE>
	       <TELL
"Your mother's till, and every farthing in it honestly owed. The
neighbours swear it will be robbed by morning; you decline to start
them off." CR>
	       <RTRUE>)>>

<ROUTINE CHEST-FCN ()
	<COND (<AND <VERB? UNLOCK> <EQUAL? ,PRSI ,BRASS-KEY>>
	       <COND (<NOT <FSET? ,SEA-CHEST ,LOCKEDBIT>>
		      <TELL "It is unlocked already." CR> <RTRUE>)>
	       <FCLEAR ,SEA-CHEST ,LOCKEDBIT>
	       <TELL
"The lock is stiff, but the key turns and the lid throws back." CR>
	       <RTRUE>)
	      (<AND <VERB? OPEN> <FSET? ,SEA-CHEST ,LOCKEDBIT>>
	       <TELL "Locked, and the captain kept the key on him." CR>
	       <RTRUE>)
	      (<AND <VERB? OPEN> <NOT <FSET? ,SEA-CHEST ,OPENBIT>>>
	       <FSET ,SEA-CHEST ,OPENBIT>
	       <COND (<NOT ,S-CHEST> <SETG S-CHEST T> <AWARD 5>)>
	       <TELL
"Up goes the lid on a smell of tar and tobacco, and there on top, folded
and brushed, a very good suit of clothes that has never been worn." CR>
	       <RTRUE>)
	      (<AND <VERB? SEARCH LOOK-INSIDE LOOK LOOK-UNDER>
		    <FSET? ,SEA-CHEST ,OPENBIT>
		    <NOT <FSET? ,CHEST-ODDMENTS ,INVISIBLE>>
		    <FSET? ,BOAT-CLOAK ,INVISIBLE>>
	       <FCLEAR ,BOAT-CLOAK ,INVISIBLE>
	       <TELL
"Under the seaman's gear lies an old boat-cloak, whitened with sea
salt." CR>
	       <RTRUE>)>>

<ROUTINE CLOTHES-FCN ()
	<COND (<AND <VERB? TAKE MOVE>
		    <FSET? ,CHEST-ODDMENTS ,INVISIBLE>>
	       <FCLEAR ,CHEST-ODDMENTS ,INVISIBLE>
	       <TELL
"You lift the clothes clear. Below them the chest is a jumble: a
quadrant, a tin canikin, sticks of tobacco, a Spanish watch, two braces
of handsome pistols, and a handful of West Indian shells." CR>
	       <COND (<VERB? TAKE> <RFALSE>)>
	       <RTRUE>)>>

<ROUTINE CHEST-ODDMENTS-FCN ()
	<COND (<AND <VERB? TAKE MOVE>
		    <FSET? ,BOAT-CLOAK ,INVISIBLE>>
	       <FCLEAR ,BOAT-CLOAK ,INVISIBLE>
	       <TELL
"You shift the whole rattling lot to one side. Under it lies an old
boat-cloak, whitened with sea salt." CR>
	       <COND (<VERB? TAKE> <RFALSE>)>
	       <RTRUE>)
	      (<VERB? EXAMINE>
	       <TELL
"A quadrant, a canikin, sticks of tobacco, a Spanish watch, pistols, and
shells from the Indies. Curiosities, and no help tonight." CR>
	       <RTRUE>)>>

<ROUTINE CLOAK-FCN ()
	<COND (<AND <VERB? TAKE MOVE RAISE>
		    <FSET? ,PACKET ,INVISIBLE>>
	       <FCLEAR ,PACKET ,INVISIBLE>
	       <FCLEAR ,COIN-BAG ,INVISIBLE>
	       <TELL
"You turn back the cloak, and there, the last things in the chest: a
bundle sewn up in oilcloth, and a canvas bag that gives out, at a touch,
the jingle of gold." CR>
	       <COND (<VERB? TAKE> <RFALSE>)>
	       <RTRUE>)>>

<ROUTINE PACKET-FCN ()
	<COND (<AND <VERB? TAKE> <NOT ,S-PACKET>>
	       <SETG S-PACKET T>
	       <AWARD 15>
	       <MOVE ,PACKET ,WINNER>
	       <TELL
"You have it: Flint's fist, sewn up in oilcloth, and heavier in the hand
than paper has any right to be. Now go." CR>
	       <RTRUE>)
	      (<VERB? OPEN CUT>
	       <TELL
"The stitches are a sailor's and the oilcloth is a sailor's, and you
have neither the time nor the right. The doctor can open it." CR>
	       <RTRUE>)
	      (<VERB? EXAMINE READ READ-PAGE>
	       <TELL "A flat bundle sewn up in oilcloth. Sealed with a
thimble, of all things." CR>
	       <RTRUE>)>>

<ROUTINE COIN-BAG-FCN ()
	<COND (<VERB? TAKE>
	       <MOVE ,COIN-BAG ,WINNER>
	       <TELL
"Your mother would count out her due and not a farthing over. You have
no time to be as honest as your mother." CR>
	       <RTRUE>)
	      (<VERB? EXAMINE OPEN COUNT>
	       <TELL
"Gold, in more currencies than you can name, and none of it yours." CR>
	       <RTRUE>)>>

<ROUTINE BED-FCN ()
	<COND (<VERB? EXAMINE SEARCH LOOK-INSIDE>
	       <TELL
"The captain's bed, never once made in all the months he lay in it." CR>
	       <RTRUE>)>>

<ROUTINE WINDOW-FCN ()
	<COND (<VERB? EXAMINE LOOK LOOK-INSIDE LOOK-UNDER OPEN>
	       <TELL
"Moonlight on the frozen road, all the way down to the cove. Nothing
moves on it yet. Yet." CR>
	       <RTRUE>)>>

<ROUTINE COVE-ROAD-FCN (RARG)
	<COND (<EQUAL? .RARG ,M-ENTER>
	       <COND (<AND ,S-PACKET <G? ,BENBOW-CLOCK 3>>
		      <TELL
"The cold takes your breath. Somewhere east, down toward the bridge, the
dell stream is running under a stone arch - which is the only roof in
this parish that Pew's crew will not think to look under." CR>
		      <RTRUE>)>)>
	<RFALSE>>

<ROUTINE SIGNBOARD-FCN ()
	<COND (<VERB? EXAMINE READ READ-PAGE>
	       <TELL
"The Admiral Benbow, and a notch out of the bottom board where a
cutlass came down the day Black Dog ran. Your father never had it
mended." CR>
	       <RTRUE>)>>

<ROUTINE BRIDGE-FCN (RARG)
	<COND (<EQUAL? .RARG ,M-ENTER>
	       <TELL
"Behind you, down the road, the tapping has stopped - which is worse
than the tapping." CR>
	       <RTRUE>)>
	<RFALSE>>

<ROUTINE V-HIDE ()
	<COND (<EQUAL? ,HERE ,BRIDGE>
	       <DO-WALK ,P?DOWN>
	       <RTRUE>)
	      (<EQUAL? ,HERE ,UNDER-BRIDGE>
	       <TELL "You are as hidden as the parish affords." CR>
	       <RTRUE>)
	      (<EQUAL? ,HERE ,DECK>
	       <COND (<AND <EQUAL? ,ACT 2> <IN? ,APPLE-BARREL ,DECK>>
		      <PERFORM ,V?BOARD ,APPLE-BARREL>
		      <RTRUE>)>
	       <TELL "There is no hiding on a deck." CR>
	       <RTRUE>)
	      (T
	       <TELL
"You look for somewhere to hide, which is a fine instinct and no use at
all just here." CR>
	       <RTRUE>)>>

;"T2 - the raid, heard from under the arch."
<ROUTINE UNDER-BRIDGE-FCN (RARG)
	<COND (<EQUAL? .RARG ,M-ENTER>
	       <SETG RAID-STEP 1>
	       <TELL
"Tap. Tap. Tap - and then a voice out of the dark, thin and cruel:
\"Down with the door!\" The door of your father's inn goes down in four
blows." CR>
	       <RTRUE>)
	      (<EQUAL? .RARG ,M-END>
	       <COND (<G? ,RAID-STEP 0> <RAID-BEAT> <RTRUE>)>
	       <RFALSE>)
	      (<EQUAL? .RARG ,M-BEG>
	       <COND (<AND <VERB? WALK CLIMB-UP LEAP> <G? ,RAID-STEP 0>>
		      <SETG RAID-PEEKS <+ ,RAID-PEEKS 1>>
		      <COND (<G? ,RAID-PEEKS 1>
			     <JIGS-UP
"You put your head up a second time, and this time the lantern is ready
for you. \"Here's one!\" - and a hand like a boat-hook has your collar,
and the blind man's stick comes down out of the dark with a very good
idea of where your head is.">
			     <RTRUE>)>
		      <TELL
"You put your head up; a lantern swings your way. Down, fool, down." CR>
		      <RTRUE>)>
	       <RFALSE>)>
	<RFALSE>>

<ROUTINE RAID-BEAT ()
	<SETG RAID-STEP <+ ,RAID-STEP 1>>
	<COND (<EQUAL? ,RAID-STEP 2>
	       <TELL
"Boots on the stairs, and the whole house being turned over above your
head. Then a shout: \"Bill's dead!\" - and the blind man screaming at
them to go up and scatter and find it, find it, find it." CR CR>
	       <COND (<OR <IN? ,PACKET ,WINNER> ,S-PACKET>
		      <TELL
"\"The chest's turned out and there's nought in it!\" - \"It's these
people of the inn - it's that boy!\" Glass goes. Your mother's chairs
go." CR>)
		     (T
		      <TELL
"And then the cry from the captain's window, the one you will hear in
your sleep: \"It's here! Flint's fist, by thunder!\"" CR>)>
	       <RTRUE>)
	      (<EQUAL? ,RAID-STEP 3>
	       <TELL
"A whistle on the hill, twice - and the whole pack breaks and runs for
Kitt's Hole, and the blind man is left in the road hammering at nothing
with his stick and cursing them for a set of rats. Then: horses. Four of
them, at a gallop, out of the moon. A pistol shot. And Pew, blind and
turned around and running the wrong way, goes under the hoofs of the
first horse with a scream that ends the night." CR>
	       <RTRUE>)
	      (<G? ,RAID-STEP 3>
	       <COND (<NOT <OR <IN? ,PACKET ,WINNER> ,S-PACKET>>
		      <GAME-OVER
"From under the arch you heard it all: the door going down, boots on
your mother's stairs, and the cry from the captain's window. They were
gone before the riders came, out through Kitt's Hole on the ebb, and the
map with them. Doctor Livesey says, gently, that no boy could have done
more. The squire says nothing at all, which is worse. Somewhere past the
horizon a crew of merry gentlemen is beating up for a certain island -
and the age of your adventures is over at fourteen, in a wrecked inn,
with the kettle on.">
		      <RTRUE>)>
	       <COND (<NOT ,S-RAID> <SETG S-RAID T> <AWARD 10>)>
	       <TELL
"Supervisor Dance finds you in the stream with your knees blue and
Flint's fist inside your shirt. \"Boy,\" says he, \"you'll ride behind
me,\" and you do, all the way to Doctor Livesey's, and from there to the
squire's, and the night turns into the best supper of your life." CR CR>
	       <SETG RAID-STEP 0>
	       <SETG ACT 2>
	       <GOTO ,HALL>
	       <RTRUE>)>
	<RFALSE>>

;"--- the squire's hall ---"

<ROUTINE HALL-FCN (RARG)
	<COND (<EQUAL? .RARG ,M-END>
	       <COND (<AND ,MAP-READ <EQUAL? ,HERE ,HALL>>
		      <TELL CR
"The squire is as good as his word and twice as loud about it. Within
three weeks there is a letter from Bristol, and a coach, and a morning
when the sea smells close enough to touch." CR CR>
		      <MOVE ,SQUIRE-NOTE ,WINNER>
		      <MOVE ,TREASURE-MAP ,WINNER>
		      <GOTO ,QUAY>
		      <RTRUE>)>
	       <RFALSE>)>
	<RFALSE>>

<ROUTINE DOCTOR-FCN ()
	<COND (<AND <VERB? GIVE> <EQUAL? ,PRSO ,PACKET> <NOT ,S-GIVE>>
	       <SETG S-GIVE T>
	       <AWARD 10>
	       <MOVE ,PACKET ,DOCTOR>
	       <FCLEAR ,ACCOUNT-BOOK ,INVISIBLE>
	       <MOVE ,TREASURE-MAP ,HALL>
	       <TELL
"The doctor snips the stitches with a pocket scissors and out come two
things: a book, and a sealed paper. The book is accounts - crosses and
sums and a place-name now and then, \"Offe Caraccas\", and at the foot
of it, in the same big hand, \"Bones, his pile.\" Twenty years of
somebody else's blood, totted up neat." CR CR>
	       <TELL
"Then the seal, and the squire on his feet before it is fairly open: the
map of an island, nine miles long and five across, shaped like a fat
dragon standing up, with soundings and hills and three crosses of red
ink - and by the last, in a small neat hand: \"Bulk of treasure here.\"
\"Livesey,\" cries the squire, \"I fit out a ship in Bristol dock, and
you shall be ship's doctor, and Hawkins here shall come as cabin-boy!\"
The doctor folds the chart and hands it, of all people, to you. \"Keep
it close, Jim. A landlord's boy is the last pocket they'll pick.\"" CR>
	       <RTRUE>)
	      (<VERB? EXAMINE>
	       <TELL
"Doctor Livesey: neat as new paint, powdered, black-eyed, and the only
man in the parish that Billy Bones was ever afraid of." CR>
	       <RTRUE>)
	      (<VERB? TELL>
	       <TELL
"\"All in good time, Jim,\" says the doctor. \"I'll stake my wig on
it.\"" CR>
	       <RTRUE>)
	      (<VERB? ATTACK>
	       <TELL "He would take it as a symptom." CR>
	       <RTRUE>)>>

<ROUTINE SQUIRE-FCN ()
	<COND (<VERB? EXAMINE>
	       <TELL
"Squire Trelawney: six feet of enthusiasm in a travelling coat, with a
face roughened and reddened by long journeys and a habit of saying
everything twice, loudly." CR>
	       <RTRUE>)
	      (<VERB? GIVE>
	       <TELL "\"Give it to Livesey, boy, he's the careful one.\"" CR>
	       <RTRUE>)
	      (<VERB? TELL>
	       <TELL
"\"Silence, sir!\" cries the squire, at nobody. \"We shall have the
finest schooner in England and the finest crew - I'll say no more than
that!\" He then says a great deal more than that." CR>
	       <RTRUE>)>>

<ROUTINE PIE-FCN ()
	<COND (<VERB? EAT TAKE>
	       <TELL
"You make a supper the like of which you never had at the Benbow. You
were, as the squire observes, hungry as a hawk." CR>
	       <RTRUE>)>>

<ROUTINE ACCOUNT-BOOK-FCN ()
	<COND (<VERB? READ READ-PAGE EXAMINE>
	       <TELL
"Crosses and sums, twenty years of them, and a place-name now and then:
\"Offe Caraccas\". At the foot: \"Bones, his pile.\"" CR>
	       <RTRUE>)>>

<ROUTINE MAP-FCN ()
	<COND (<VERB? READ READ-PAGE EXAMINE>
	       <TELL
"The island, nine miles by five, shaped like a fat dragon standing up,
with soundings, hills, and the names of the anchorages. Three crosses of
red ink, and by the last: \"Bulk of treasure here.\"" CR CR>
	       <TELL
"On the back, in the same small neat hand: \"Tall tree, Spy-glass
shoulder, bearing a point to the N. of N.N.E. Skeleton Island E.S.E. and
by E. Ten feet.\" Then, squeezed in below, as if it hardly mattered:
\"Bar silver is in the north cache; you can find it by the trend of the
east hummock, ten fathoms south of the black crag with the face on
it.\"" CR>
	       <COND (<NOT ,S-MAP> <SETG S-MAP T> <SETG MAP-READ T> <AWARD 5>)>
	       <COND (<EQUAL? ,HERE ,SPYGLASS-SHOULDER>
		      <TELL CR "You are standing on the Spy-glass shoulder the
note names." CR>)
		     (<EQUAL? ,HERE ,BLACK-CRAG>
		      <TELL CR "The crag with the face on it is over your
head, and the east hummock trends away exactly as promised." CR>)
		     (<EQUAL? ,HERE ,SKELETON>
		      <TELL CR "Skeleton Island lies astern of the bones, on
the line the note gives." CR>)>
	       <RTRUE>)>>

;"=== ACT II: Bristol and the Hispaniola ========================"

<ROUTINE QUAY-FCN (RARG)
	<COND (<EQUAL? .RARG ,M-BEG>
	       <COND (<AND <VERB? BOARD ENTER THROUGH CLIMB-UP CLIMB-FOO>
			   <EQUAL? ,PRSO ,SHIP>>
		      <COND (,NOTE-GIVEN <BOARD-HISPANIOLA>)
			    (T
			     <TELL
"\"The squire's note first, lad - the sign of the Spy-glass, up the
street.\"" CR>)>
		      <RTRUE>)>
	       <RFALSE>)
	      (<EQUAL? .RARG ,M-ENTER>
	       <TELL
"Bristol. You have never seen so much water put to work at once." CR>
	       <RFALSE>)>
	<RFALSE>>

<ROUTINE QUAY-EAST-FCN ()
	<COND (,NOTE-GIVEN <BOARD-HISPANIOLA> <RFALSE>)
	      (T
	       <TELL
"\"The squire's note first, lad - the sign of the Spy-glass, up the
street.\"" CR>
	       <RFALSE>)>>

<ROUTINE BOARD-HISPANIOLA ()
	<TELL
"The boat puts you under the Hispaniola's side and you go up her ladder
like a monkey with an errand." CR CR>
	<TELL
"The voyage is three weeks of blue water and hard work and small
kindnesses. The squire is loud, the doctor is dry, and Captain Smollett
is right about everything and popular with nobody. Mr. Arrow, the mate,
turns out to be drunk on liquor nobody can find, and one black night
between two watches he simply is not there any more, and nobody is very
surprised. Silver keeps the galley like a chapel and you like the sound
of his voice better than you mean to." CR CR>
	<TELL
"Now it is the last evening before landfall, the wind has dropped, the
watch is forward looking for the island, and you have a fancy for an
apple." CR CR>
	<GOTO ,DECK>
	<RTRUE>>

<ROUTINE TAVERN-FCN (RARG)
	<COND (<EQUAL? .RARG ,M-ENTER>
	       <COND (<NOT ,NOTE-GIVEN>
		      <TELL
"A big man gets up from a table by the far wall as you come in - very
tall, very strong, with a face as big as a ham, and one leg cut off close
by the hip. He crosses the floor on a crutch, hopping like a bird, and
he is smiling at you before he knows who you are." CR>
		      <RTRUE>)>)>
	<RFALSE>>

<ROUTINE SILVER-FCN ()
	<COND (<AND <VERB? GIVE> <EQUAL? ,PRSO ,SQUIRE-NOTE> <NOT ,NOTE-GIVEN>>
	       <SETG NOTE-GIVEN T>
	       <COND (<NOT ,S-NOTE> <SETG S-NOTE T> <AWARD 10>)>
	       <MOVE ,SQUIRE-NOTE ,SILVER>
	       <REMOVE ,BLACK-DOG>
	       <TELL
"He breaks the seal and gives a great start. \"Oh!\" says he. \"I see.
You're our new cabin-boy. Pleased I am to see you\" - and then his eye
goes past you to the door, where a man at the far table has got up all
at once and gone out of it like a rat down a drain." CR CR>
	       <TELL
"\"Oh, stop him! Who was it? Harry! Run and catch him!\" Silver thumps
the floor with his crutch. \"Who did you say he was? Black Dog? Ah, and
in my house! Morgan, you was a-talkin' with him - what was you talkin'
of?\" \"We was a-talkin' of keel-hauling,\" says Morgan, and Silver
laughs till the glasses ring. \"Keel-hauling, was you! Well, you'll be
keel-hauled for it yourself one of these days.\" Then, to you, gravely:
\"You and me should get on well, Hawkins, for I'll take my davy I should
be rated ship's boy. But come now - the squire must hear of this from
me, and I'll walk down with you.\"" CR>
	       <RTRUE>)
	      (<AND <VERB? GIVE> <EQUAL? ,PRSO ,TREASURE-MAP>>
	       <TELL
"You very nearly do. That is the whole trouble with Long John: you very
nearly do, every time." CR>
	       <RTRUE>)
	      (<VERB? EXAMINE>
	       <COND (<G? ,PHASE 3>
		      <TELL
"Long John, with two guns slung about him and the parrot on his
shoulder, holding the end of your rope. From time to time he turns his
eyes on you with a deadly look - and you read him like print." CR>)
		     (T
		      <TELL
"Tall as a ham and strong as a mast, with his left leg cut off close by
the hip and a crutch under his shoulder that he handles like a bird
handles a wing. His face is intelligent and smiling, and he is the most
frightening thing you have ever been fond of." CR>)>
	       <RTRUE>)
	      (<VERB? ATTACK SHOOT>
	       <TELL
"He is twice your size, half your legs, and ten times your wickedness.
He looks almost hurt at the thought." CR>
	       <RTRUE>)
	      (<VERB? TELL HELLO>
	       <COND (<G? ,PHASE 3>
		      <TELL
"\"Dooty is dooty, Jim,\" says Silver, and does not look at you." CR>)
		     (T
		      <TELL
"\"Now that's what I call a boy with a head on him,\" says Silver, who
has said the same thing to every man in this room." CR>)>
	       <RTRUE>)>>

<ROUTINE BLACK-DOG-FCN ()
	<COND (<VERB? EXAMINE>
	       <TELL
"A tallowy creature wanting two fingers, sitting where he can watch the
door. He is watching the door." CR>
	       <RTRUE>)
	      (<VERB? ATTACK TELL HELLO>
	       <TELL "He looks through you and out the other side." CR>
	       <RTRUE>)>>

<ROUTINE CUSTOMERS-FCN ()
	<COND (<VERB? EXAMINE LISTEN>
	       <TELL
"Loud, kind, weathered men, all talking at once about wind and wages.
Not one of them looks like a murderer, which proves nothing." CR>
	       <RTRUE>)>>

<ROUTINE NOTE-FCN ()
	<COND (<VERB? READ READ-PAGE OPEN EXAMINE>
	       <TELL
"Sealed with the squire's arms. Some things a cabin-boy does not do." CR>
	       <RTRUE>)>>

;"--- the ship ---"

<ROUTINE DECK-FCN (RARG)
	<COND (<EQUAL? .RARG ,M-LOOK>
	       <COND (,SEA-PHASE
		      <TELL
"The deck of the Hispaniola with nobody on it. No soul at the helm, a
broken bottle rolling in the scuppers with the swell, and the black flag
at the peak. Two watchmen lie aft, one on his face, one on his back with
his teeth showing.">
		      <COND (,BEACHED
			     <TELL " She lies canted over on the sand of the
inlet, and the shore is a wade away.">)>
		      <CRLF>)
		     (T
		      <TELL
"The deck of the Hispaniola, two hundred tons, the sweetest schooner a
boy ever stood on. Forward, the fore companion drops to the galley; aft,
the companion goes down to the cabin. Amidships stands Long Tom, the
brass nine, and beside it the apple barrel, broached for any hand with a
fancy." CR>)>
	       <RTRUE>)
	      (<EQUAL? .RARG ,M-END>
	       <COND (<G? ,SAIL-STEP 0> <SAIL-BEAT> <RTRUE>)
		     (<G? ,DUEL-STEP 0> <DUEL-BEAT> <RTRUE>)>
	       <RFALSE>)>
	<RFALSE>>

<ROUTINE DECK-DOWN-FCN ()
	<COND (,SEA-PHASE ,CABIN)
	      (T ,GALLEY)>>

<ROUTINE DECK-UP-FCN ()
	<COND (<G? ,DUEL-STEP 0> ,CROSS-TREES)
	      (,SEA-PHASE ,CROSS-TREES)
	      (T
	       <TELL "You have work enough on deck." CR>
	       <RFALSE>)>>

<ROUTINE DECK-LAND-FCN ()
	<COND (<AND ,BEACHED <EQUAL? ,DUEL-STEP 0>>
	       <TELL
"You lower yourself over the canted side and wade ashore in water to
your waist, with the sun going down red behind the trees." CR CR>
	       <SETG PHASE 3>
	       ,NORTH-INLET)
	      (,BEACHED
	       <TELL "Not while Israel Hands has an opinion about it." CR>
	       <RFALSE>)
	      (T
	       <TELL "There is a quarter-mile of water between you and any
land at all." CR>
	       <RFALSE>)>>

<ROUTINE BARREL-FCN (RARG)
	<COND (<EQUAL? .RARG ,M-ENTER>
	       <COND (<AND <EQUAL? ,ACT 2> <EQUAL? ,BARREL-STEP 0>>
		      <SETG BARREL-STEP 1>
		      <SETG BARREL-FRESH T>
		      <COND (<NOT ,S-BARREL> <SETG S-BARREL T> <AWARD 5>)>
		      <TELL
"In you get bodily. Scarce an apple left; you sit in the dark on the
staves with the ship rocking you half to sleep - until a heavy man sits
down with a clash against the barrel, and the staves knock against your
ear, and you understand, all at once and completely, that you must not
move." CR>
		      <RTRUE>)>
	       <RFALSE>)
	      (<VERB? EXAMINE>
	       <TELL
"A big barrel with the head out, three-quarters empty and smelling of
sweet rot. A boy would go in it easily." CR>
	       <RTRUE>)>>

<ROUTINE APPLE-FCN ()
	<COND (<VERB? EAT>
	       <TELL
"Sweet and withered. It may be the last quiet bite of your life." CR>
	       <REMOVE ,APPLE>
	       <RTRUE>)
	      (<VERB? TAKE>
	       <RFALSE>)>>

<ROUTINE LONG-TOM-FCN ()
	<COND (<VERB? EXAMINE>
	       <TELL
"A long brass nine, kept bright by men who hope never to use it." CR>
	       <RTRUE>)
	      (<VERB? SHOOT LAMP-ON>
	       <TELL
"You are fourteen and this is nine feet of naval artillery. Even your
optimism has limits." CR>
	       <RTRUE>)>>

<ROUTINE MAST-FCN ()
	<COND (<AND <VERB? CLIMB-UP CLIMB-FOO CLIMB-ON CLIMB-DOWN> <G? ,DUEL-STEP 0>>
	       <GOTO ,CROSS-TREES>
	       <RTRUE>)
	      (<VERB? EXAMINE>
	       <TELL "The mizzen, with the shrouds coming down to the rail
like a ladder made for exactly this." CR>
	       <RTRUE>)>>

<ROUTINE TILLER-FCN ()
	<COND (<VERB? EXAMINE TAKE MOVE TURN>
	       <COND (,SEA-PHASE
		      <TELL
"You put a hand on the tiller and the whole schooner answers, which is a
sensation no boy should be allowed." CR>)
		     (T <TELL "Israel Hands' own tiller. Best left alone."
CR>)>
	       <RTRUE>)>>

<ROUTINE BREAKER-FCN ()
	<COND (<VERB? DRINK DRINK-FROM>
	       <TELL "You drink your fill of stale sweet water." CR>
	       <RTRUE>)>>

<ROUTINE AFT-COMPANION-FCN ()
	<COND (<VERB? ENTER THROUGH BOARD CLIMB-DOWN>
	       <GOTO ,CABIN>
	       <RTRUE>)
	      (<VERB? EXAMINE>
	       <TELL "The companion aft, dropping to the stern cabin." CR>
	       <RTRUE>)>>

<ROUTINE FORE-HATCH-FCN ()
	<COND (<VERB? ENTER THROUGH BOARD CLIMB-DOWN>
	       <COND (,SEA-PHASE <GOTO ,DECK>) (T <GOTO ,GALLEY>)>
	       <RTRUE>)
	      (<VERB? EXAMINE>
	       <TELL "The fore companion, dropping to the galley." CR>
	       <RTRUE>)>>

<ROUTINE GIG-BOAT-FCN ()
	<COND (<VERB? BOARD ENTER THROUGH CLIMB-UP CLIMB-FOO CLIMB-ON CLIMB-DOWN>
	       <RFALSE>)>>

<ROUTINE GALLEY-FCN (RARG)
	<COND (<EQUAL? .RARG ,M-LOOK>
	       <COND (,SEA-PHASE
		      <TELL
"The galley, ransacked: dishes down, lockers staved, and the cage in the
corner standing open and empty. Silver has taken her ashore." CR>)
		     (T
		      <TELL
"Silver's galley, clean as a new pin, dishes burnished and hanging, and
Cap'n Flint the parrot in her cage in the corner, sidling and swearing.
It smells of bacon and better days." CR>)>
	       <RTRUE>)>
	<RFALSE>>

<ROUTINE PARROT-FCN ()
	<COND (<VERB? TAKE>
	       <TELL
"She has sailed with England the pirate and watched the fishing-up of
the plate ships. She is not going in a boy's pocket." CR>
	       <RTRUE>)
	      (<VERB? GIVE>
	       <TELL "She takes it, considers it, and bites you." CR>
	       <RTRUE>)
	      (<VERB? KISS>
	       <TELL
"She has the vocabulary of two hundred wicked years and she uses all of
it." CR>
	       <RTRUE>)
	      (<VERB? EXAMINE LISTEN>
	       <TELL
"Green as a leaf, two hundred years old if she is a day, and by all
accounts entirely without remorse. \"Pieces of eight!\" she remarks.
\"Pieces of eight!\"" CR>
	       <RTRUE>)
	      (<VERB? ATTACK>
	       <TELL "You would lose." CR>
	       <RTRUE>)>>

<ROUTINE CAGE-FCN ()
	<COND (<VERB? EXAMINE OPEN>
	       <TELL
"A brass cage that has crossed more oceans than most admirals." CR>
	       <RTRUE>)>>

<ROUTINE CHEESE-FCN ()
	<COND (<VERB? EAT>
	       <TELL
"You could. Somewhere on this island there is a man who would weep." CR>
	       <RTRUE>)
	      (<VERB? EXAMINE>
	       <TELL "A wedge of Parmesan cheese out of Silver's own stores.
It travels well." CR>
	       <RTRUE>)>>

<ROUTINE GALLEY-STUFF-FCN ()
	<COND (<VERB? EXAMINE>
	       <TELL
"Burnished dishes hanging in rows. Whatever else the sea-cook is, he is
a very good cook." CR>
	       <RTRUE>)>>

<ROUTINE CABIN-FCN (RARG)
	<COND (<EQUAL? .RARG ,M-LOOK>
	       <COND (,SEA-PHASE
		      <TELL
"The stern cabin, wrecked: every lockfast place broken open in the hunt
for the chart, the floor thick with marsh mud, dozens of empty bottles
clinking in the corners, and the lamp still burning umber over the
table.">
		      <COND (<AND <G? ,SAIL-STEP 2> <L? ,SAIL-STEP 5>>
			     <TELL " The sparred gallery runs forward under the
deck, and the fore companion is open at the end of it.">)>
		      <CRLF>)
		     (T
		      <TELL
"The stern cabin, snug as a strong-box: chart table, lockers, and the
stern window open on the wake." CR>)>
	       <RTRUE>)
	      (<EQUAL? .RARG ,M-ENTER>
	       <COND (<AND <EQUAL? ,ACT 2> <EQUAL? ,BARREL-STEP 99>>
		      <COUNCIL-OF-WAR>
		      <RTRUE>)>
	       <RFALSE>)
	      (<EQUAL? .RARG ,M-BEG>
	       <COND (<AND <EQUAL? ,BARREL-STEP 100>
			   <VERB? WALK BOARD ENTER THROUGH DISEMBARK EXIT>>
		      <GO-ASHORE>
		      <RTRUE>)>
	       <RFALSE>)
	      (<EQUAL? .RARG ,M-END>
	       <COND (<G? ,SAIL-STEP 0> <SAIL-BEAT> <RTRUE>)>
	       <RFALSE>)>
	<RFALSE>>

<ROUTINE GO-ASHORE ()
	<SETG BARREL-STEP 0>
	<SETG ACT 3>
	<REMOVE ,SQUIRE-NOTE>
	<TELL
"You go down into the gig with the rest of them, and Silver's hand is on
your shoulder the whole way in, friendly as a father's." CR CR>
	<GOTO ,LANDING-BEACH>
	<RTRUE>>

<ROUTINE CHART-TABLE-FCN ()
	<COND (<VERB? EXAMINE SEARCH LOOK-INSIDE LOOK LOOK-UNDER>
	       <TELL
"The captain's charts, weighted with a lump of coral. None of them is
the one that matters." CR>
	       <RTRUE>)>>

<ROUTINE RAISINS-FCN ()
	<COND (<VERB? EAT>
	       <TELL "Sticky, and very welcome." CR>
	       <RTRUE>)>>

<ROUTINE MEDICAL-BOOK-FCN ()
	<COND (<VERB? READ READ-PAGE EXAMINE>
	       <TELL
"Half the leaves torn out for pipelights, which tells you everything
about the new owners." CR>
	       <RTRUE>)>>

<ROUTINE BOTTLES-FCN ()
	<COND (<VERB? EXAMINE COUNT>
	       <TELL
"Dozens of them, clinking together in the corners with the roll of the
ship. Nobody aboard has been sober since you left." CR>
	       <RTRUE>)>>

<ROUTINE BRANDY-FCN ()
	<COND (<VERB? DRINK DRINK-FROM>
	       <TELL "You are fourteen, and the doctor was very clear." CR>
	       <RTRUE>)>>

<ROUTINE WINE-FCN ()
	<COND (<VERB? DRINK DRINK-FROM>
	       <TELL "Not yours, and not today." CR>
	       <RTRUE>)>>

<ROUTINE BISCUIT-FCN ()
	<COND (<VERB? EAT>
	       <TELL "Hard as a plank and better than nothing." CR>
	       <RTRUE>)>>

<ROUTINE GALLERY-FCN ()
	<COND (<VERB? ENTER THROUGH WALK EXAMINE>
	       <V-SNEAK>
	       <RTRUE>)>>

;"--- the apple barrel scene ---"

<ROUTINE BARREL-BEAT ()
	<SETG BARREL-STEP <+ ,BARREL-STEP 1>>
	<COND (<EQUAL? ,BARREL-STEP 2>
	       <TELL
"Silver's voice, close enough to touch through the staves, and warm as a
hearth: \"Flint was cap'n; I was quartermaster, along of my timber leg.
Now, here's what I say to you, Dick: you're smart as paint, I seen that
when I set my eyes on you, and I'll talk to you like a man.\"" CR>
	       <RTRUE>)
	      (<EQUAL? ,BARREL-STEP 3>
	       <TELL
"\"Here it is about gentlemen of fortune. They lives rough, and they
risk swinging, but they eat and drink like fighting-cocks. Now, the most
goes for rum and a good fling, and to sea again in their shirts. But
that's not my course. I lays it by, a bit here and a bit there, and none
suspecting. I'm fifty, mark you; once back from this cruise I set up
gentleman in earnest.\"" CR>
	       <RTRUE>)
	      (<EQUAL? ,BARREL-STEP 4>
	       <TELL
"Israel Hands, sour and impatient: \"I didn't want no more o' the
gentlemen. Look here - how long are we a-going to stand off and on like
a blessed bumboat? I've had a'most enough o' Cap'n Smollett; I want to
go into that cabin, I do. I want their pickles and wines and that.\"
\"Israel,\" says Silver, \"your head ain't much account, but you're able
to hear, I reckon. You'll berth forward, and you'll live hard, and
you'll speak soft, till I give the word.\"" CR>
	       <RTRUE>)
	      (<EQUAL? ,BARREL-STEP 5>
	       <TELL
"\"When? I'll tell you when. The last moment I can manage - and that's
when. Cap'n Smollett sails the ship for us; the squire and doctor has a
map, and I don't know where it is, do I? No more do you. So let them
find the stuff and help us get it aboard, and then we'll see. If I was
sure of you all, I'd have Smollett navigate us half-way back again
before I struck.\" \"And what do we do with 'em?\" asks Dick. \"Dead men
don't bite,\" says Silver cheerfully. \"I claim Trelawney. I'll wring
his calf's head off his body with these hands.\"" CR>
	       <RTRUE>)
	      (<EQUAL? ,BARREL-STEP 6>
	       <TELL
"\"Dick,\" says Silver, \"jump up, like a sweet lad, and get me an
apple, to wet my pipe like.\" Your heart stops entirely. But Hands says
he'd sooner have rum, and Silver sends Dick for the key to the spirit
locker instead, and while their backs are turned a voice comes down out
of the dark forward, clear as a bell:" CR CR>
	       <TELL "\"Land ho!\"" CR CR>
	       <TELL
"The whole ship breaks into a rush of feet, and you are alone with a
barrel and the worst news in England." CR>
	       <SETG BARREL-STEP 98>
	       <RTRUE>)>
	<RFALSE>>

<ROUTINE COUNCIL-OF-WAR ()
	<SETG BARREL-STEP 100>
	<COND (<NOT ,S-WAR> <SETG S-WAR T> <AWARD 10>)>
	<TELL
"You get the three of them alone in the cabin and tell it all, and
nobody interrupts once. When you have done, Captain Smollett looks at
the doctor and the doctor looks at the squire. \"Trelawney,\" says
Smollett, \"that crew of yours - well, sir. Twenty-six hands aboard, and
seven of them are ours: you, me, the doctor, Hunter, Joyce, Redruth, and
Gray, if Gray's a man. Nineteen against seven, and we must strike no
blow before they do.\" The doctor puts his hand on your shoulder.
\"Jim here can help us more than anyone. The men are not shy with him,
and Jim notices things.\"" CR CR>
	<TELL
"Morning, then: the anchor down in Captain Kidd's Anchorage, the island
grey with unpleasant-looking woods, and the boats going ashore full of
men who are no longer pretending very hard. Silver invites you along, in
his kindest voice. You go, because you are exactly the sort of boy who
goes." CR>
	<RTRUE>>

;"=== ACT III: the island ======================================="

<ROUTINE BEACH-FCN (RARG)
	<COND (<EQUAL? .RARG ,M-ENTER>
	       <COND (<NOT ,S-ASHORE>
		      <SETG S-ASHORE T>
		      <SETG ACT 3>
		      <AWARD 5>
		      <TELL
"You are over the gunwale and into the sand before the boat has properly
touched, and away into the trees with Silver bawling your name behind
you in a voice you have never heard him use." CR>
		      <RTRUE>)>)>
	<RFALSE>>

<ROUTINE GIGS-FCN ()
	<COND (<VERB? EXAMINE>
	       <TELL "Two ship's boats hauled up on the grey sand, each with a
man's coat left in the sternsheets." CR>
	       <RTRUE>)
	      (<VERB? BOARD ENTER THROUGH>
	       <TELL "Nowhere to row to that is better than here." CR>
	       <RTRUE>)>>

<ROUTINE MARSH-FCN (RARG)
	<COND (<EQUAL? .RARG ,M-ENTER>
	       <COND (<NOT ,MARSH-HEARD>
		      <SETG MARSH-HEARD T>
		      <TELL
"Out of the fen, a room away and hidden by the reeds, comes a cry of
anger - then a scuffle - then a long-drawn scream that stops in the
middle of itself. Every marsh bird in the anchorage goes up at once, and
the whole fen rings, and then the silence comes back and lies down flat." CR CR>
		      <TELL
"Tom had a name and a dooty; Silver had a crutch and a knife. You did
not see it, and you will hear it the rest of your life." CR>
		      <RTRUE>)>)>
	<RFALSE>>

<ROUTINE SNAKE-FCN ()
	<COND (<VERB? TAKE EXAMINE>
	       <TELL
"A rattlesnake, coiled in a hollow with its head up and its tail going
like a famous rattle. You have never heard the sound before and you know
it perfectly." CR>
	       <RTRUE>)
	      (<VERB? ATTACK SHOOT>
	       <TELL
"You make a lunge; the snake makes a decision. It goes into the
bulrushes and takes its opinion of you with it." CR>
	       <RTRUE>)>>

<ROUTINE OPEN-WOODS-FCN (RARG)
	<RFALSE>>

<ROUTINE HILL-FOOT-FCN (RARG)
	<COND (<EQUAL? .RARG ,M-ENTER>
	       <COND (<NOT ,BEN-MET>
		      <SETG BEN-MET T>
		      <MOVE ,BEN-GUNN ,HILL-FOOT>
		      <COND (<NOT ,S-BEN> <SETG S-BEN T> <AWARD 10>)>
		      <SETG CANNON-CLOCK 3>
		      <TELL
"A gravel spout rattles down off the shoulder above you, and something
that is not a goat goes flitting between two pine trunks, quick and
dark and bent double. Then it comes out into the open and drops on its
knees in the sand with its hands held out." CR CR>
		      <TELL
"\"Ben Gunn,\" says the creature. \"I'm poor Ben Gunn, I am, and I
haven't spoke with a Christian these three years.\" He is white for want
of sun, and clothed in goat-skins and ship's canvas stitched with brass
buttons and bits of stick. \"Marooned,\" he says. \"Three years, and
lived on goats and berries and oysters. But mate - I'm rich. Rich!\" He
looks quickly over both shoulders. \"You ain't a one-legged man, are
you? Not you. And you'd tell me true if Flint's own ship was out there
in the anchorage?\" He listens to the answer with his mouth open, and
then, in a whisper, as if it were the great business of the day:
\"You mightn't happen to have a piece of cheese about you, now?
Toasted, mostly. I dream of it.\"" CR>
		      <RTRUE>)>)
	      (<EQUAL? .RARG ,M-END>
	       <COND (<AND <G? ,CANNON-CLOCK 0> <L? ,PHASE 2>>
		      <SETG CANNON-CLOCK <- ,CANNON-CLOCK 1>>
		      <COND (<EQUAL? ,CANNON-CLOCK 0> <I-CANNON> <RTRUE>)>)>
	       <RFALSE>)>
	<RFALSE>>

<ROUTINE HILLFOOT-UP-FCN ()
	<COND (<EQUAL? ,PHASE 6> ,BEN-CAVE)
	      (T
	       <TELL
"The cliff wants a guide who knows it, and the only man who knows it is
not offering yet." CR>
	       <RFALSE>)>>

<ROUTINE BEN-GUNN-FCN ()
	<COND (<AND <VERB? GIVE> <EQUAL? ,PRSO ,CHEESE> <NOT ,CHEESED>>
	       <SETG CHEESED T>
	       <SETG BEN-FRIEND T>
	       <MOVE ,CHEESE ,BEN-GUNN>
	       <COND (<NOT ,S-CHEESE> <SETG S-CHEESE T> <AWARD 10>)>
	       <TELL
"He takes it in both hands the way another man would take a child, and
capers on the sand, and pays you in coin better than gold." CR CR>
	       <TELL
"\"Now you listen, mate. Under the white rock, south down the spit,
that's where Ben Gunn's boat lies - made with my two hands, mate, and
Ben Gunn keeps her under a tent of goat-skins. And a word in your ear:
him that digs under the tall pine will dig up pig-nuts. Ben Gunn has
reasons of his own.\" He winks at you with his whole face. \"I've a
precious sight more confidence in a gen'leman born than in them
gen'lemen of fortune, having been one myself.\"" CR>
	       <RTRUE>)
	      (<VERB? EXAMINE>
	       <TELL
"Ben Gunn: goat-skins, brass buttons, and three years of talking to
himself, all showing at once in his face." CR>
	       <RTRUE>)
	      (<VERB? GIVE>
	       <TELL "\"That ain't cheese,\" says Ben, with feeling." CR>
	       <RTRUE>)
	      (<VERB? TELL HELLO>
	       <COND (,CHEESED
		      <TELL
"\"White rock, south down the spit - my boat. Tall pine - pig-nuts. And
if it comes to Silver, mate, you tell him Ben Gunn's a man as had
reasons.\"" CR>)
		     (T
		      <TELL
"\"Cheese,\" says Ben Gunn, going straight past your question. \"Toasted,
mostly.\"" CR>)>
	       <RTRUE>)
	      (<VERB? ATTACK>
	       <TELL "He has been alone three years. Have some decency." CR>
	       <RTRUE>)>>

<ROUTINE CEMETERY-FCN ()
	<COND (<VERB? EXAMINE>
	       <TELL
"Mounds of stones laid out in rows, every one of them tended. Somebody
up here has had a great deal of time and only goats for company." CR>
	       <RTRUE>)>>

<ROUTINE SHORE-WOODS-FCN (RARG)
	<RFALSE>>

<ROUTINE CLEARING-FCN (RARG)
	<COND (<EQUAL? .RARG ,M-BEG>
	       <COND (<AND <VERB? WALK> <EQUAL? ,SIEGE-STEP 1>>
		      <TELL
"Musket fire in the woods - over the fence now or die on it." CR>
		      <RTRUE>)>)>
	<RFALSE>>

<ROUTINE PALING-FCN ()
	<COND (<VERB? CLIMB-UP CLIMB-FOO CLIMB-ON CLIMB-DOWN ENTER THROUGH>
	       <COND (<EQUAL? ,HERE ,STOCKADE-CLEARING> <DO-WALK ,P?IN>)
		     (T <DO-WALK ,P?OUT>)>
	       <RTRUE>)
	      (<VERB? EXAMINE>
	       <TELL
"Six feet of pine trunks set on end, too close to squeeze and too high
to be comfortable about. There is no gate: they meant it that way." CR>
	       <RTRUE>)>>

<ROUTINE JACK-FCN ()
	<COND (<VERB? EXAMINE>
	       <TELL
"The Union Jack, snapping over the log-house. Captain Smollett would
sooner be shot at than take it down, and has arranged to be both." CR>
	       <RTRUE>)
	      (<VERB? LOWER TAKE>
	       <TELL "Not that flag. Never that flag." CR>
	       <RTRUE>)>>

;"--- the log-house and the siege ---"

<ROUTINE LOG-HOUSE-FCN (RARG)
	<COND (<EQUAL? .RARG ,M-LOOK>
	       <COND (<G? ,PHASE 3>
		      <TELL
"The log-house with the wrong men in it: six buccaneers sprawled and
snoring, a fire built up higher than the garrison ever wasted wood on,
and Long John Silver sitting against the wall with the parrot on his
shoulder." CR>)
		     (T
		      <TELL
"The log-house: unsquared pine, sand underfoot and in your teeth,
loopholes on every side, and a clear spring rising in a sunken ship's
kettle by the porch. It smells of woodsmoke and crowded men." CR>)>
	       <RTRUE>)
	      (<EQUAL? .RARG ,M-ENTER>
	       <COND (<AND <EQUAL? ,PHASE 0> <NOT ,S-LOGHOUSE>>
		      <SETG S-LOGHOUSE T>
		      <SETG PHASE 1>
		      <SETG SIEGE-STEP 1>
		      <AWARD 10>
		      <GARRISON-ARRIVAL>
		      <RTRUE>)
		     (<AND <EQUAL? ,PHASE 3> <EQUAL? ,CAPTIVE-STEP 0>>
		      <SETG PHASE 4>
		      <SETG CAPTIVE-STEP 1>
		      <CAPTURE-SCENE>
		      <RTRUE>)>
	       <RFALSE>)
	      (<EQUAL? .RARG ,M-END>
	       <COND (<G? ,SIEGE-STEP 0> <SIEGE-BEAT> <RTRUE>)
		     (<G? ,CAPTIVE-STEP 0> <CAPTIVE-BEAT> <RTRUE>)>
	       <RFALSE>)>
	<RFALSE>>

<ROUTINE GARRISON-ARRIVAL ()
	<MOVE ,DOCTOR ,LOG-HOUSE>
	<MOVE ,SQUIRE ,LOG-HOUSE>
	<TELL
"You go over the paling and are hauled down the other side by the collar
by a delighted Squire Trelawney. The garrison's story comes out in six
lines: the jolly-boat run ashore under fire, the stores mostly lost, poor
Redruth shot through and lying now under the Union Jack, and the
doctor - who has been asking questions about a marooned man on this
island in a tone you recognise." CR CR>
	<TELL
"Night comes down cold. Morning comes up hot. And at nine o'clock, out
of the fog at the edge of the woods, a white flag on a stick, and a
voice you have missed more than you will admit: \"Flag o' truce! Silver
to come up and make terms!\"" CR>
	<RTRUE>>

<ROUTINE SIEGE-BEAT ()
	<SETG SIEGE-STEP <+ ,SIEGE-STEP 1>>
	<COND (<EQUAL? ,SIEGE-STEP 2>
	       <MOVE ,SILVER ,STOCKADE-CLEARING>
	       <TELL
"Silver comes up the slope on his crutch in the sand, cheerful as a
Sunday. \"Here's the p'ints. You give us the chart, and we'll give you
your choice: come aboard with us when the treasure's shipped, or stop
here with food and drink and the first ship we sight sent in for you.\"
Captain Smollett does not get up. \"Is that all? Then hear me. You can't
find the treasure. You can't sail the ship - there's not a man among you
fit to. You can't fight us. And now you'll get up out of that sand and
go, or the next time I see you I'll put a bullet in your back.\"" CR CR>
	       <TELL
"Silver's face is a study. \"Them that die'll be the lucky ones,\" says
he, and hauls himself up, and goes." CR>
	       <RTRUE>)
	      (<EQUAL? ,SIEGE-STEP 3>
	       <TELL
"An hour of nothing at all, which is worse than shooting. Then Gray, at
his loophole, in a voice of purest politeness: \"If you please, sir - if
I see anyone, am I to fire?\" \"I told you so!\" cries the captain." CR>
	       <RTRUE>)
	      (<EQUAL? ,SIEGE-STEP 4>
	       <MOVE ,BOARDER ,LOG-HOUSE>
	       <REMOVE ,SILVER>
	       <TELL
"A volley out of the woods, and the balls come through the loopholes and
sing round the room. Then the yell, and the rush - seven of them over
the north fence at once, and their leader is not shot and does not stop,
and comes bodily in through the porch with a cutlass up." CR CR>
	       <TELL
"\"Out, lads, out, and fight 'em in the open!\" roars Smollett.
\"Cutlasses!\" There is a pile of them by the door." CR>
	       <RTRUE>)
	      (<G? ,SIEGE-STEP 4>
	       <COND (<NOT <IN? ,BOARDER ,LOG-HOUSE>> <RFALSE>)>
	       <COND (<G? ,BOARDER-IDLE 2>
		      <JIGS-UP
"You stand there with your hands empty and your mouth open while a man
who has killed for a living decides what to do about you. It does not
take him long. Captain Smollett, who warned you he would have no
favourites on his ship, is heard to say something short and sad about
boys.">
		      <RTRUE>)>
	       <TELL
"The boarder comes at you again, cutlass swinging, and the whole house is
smoke and shouting." CR>
	       <RTRUE>)>
	<RFALSE>>

<ROUTINE BOARDER-FCN ()
	<COND (<AND <VERB? ATTACK CUT>
		    <OR <EQUAL? ,PRSI ,CUTLASS> <EQUAL? ,PRSI ,GULLY>
			<EQUAL? ,PRSI ,DIRK>>>
	       <SETG BOARDER-IDLE 0>
	       <SETG BOARDER-HITS <+ ,BOARDER-HITS 1>>
	       <COND (<EQUAL? ,BOARDER-HITS 1>
		      <TELL
"You get the point up and he runs onto it, more from haste than from
your skill. He roars, and falls back against the doorpost with his hand
to his ribs, and comes on again." CR>
		      <RTRUE>)
		     (T
		      <SETG SIEGE-STEP 0>
		      <REMOVE ,BOARDER>
		      <COND (<NOT ,S-SIEGE> <SETG S-SIEGE T> <AWARD 15>)>
		      <SIEGE-VICTORY>
		      <RTRUE>)>)
	      (<VERB? ATTACK>
	       <TELL
"With your bare hands? There is a pile of cutlasses by the door and the
captain has just shouted about them." CR>
	       <RTRUE>)
	      (<VERB? EXAMINE>
	       <TELL
"A big man in a red night-cap with a cutlass and no plans past the next
minute." CR>
	       <RTRUE>)>>

<ROUTINE SIEGE-VICTORY ()
	<SETG PHASE 2>
	<TELL
"He goes down across the doorway and does not get up, and all at once
the thing is over: the boarders break and run for the fence and the
woods take them. Five of them are down and only four of us are standing,
and the captain has a ball through the shoulder and is swearing about
paperwork." CR CR>
	<TELL
"Afterwards, in the hot afternoon, the doctor takes his hat and his
pistols and walks out into the trees without saying where. \"If I am
right,\" you tell Gray, \"he is going to see Ben Gunn.\" The rest of the
garrison sleeps in the heat, and nobody at all is watching the gate." CR>
	<RTRUE>>

<ROUTINE SMOLLETT-FCN ()
	<COND (<VERB? EXAMINE>
	       <TELL
"Captain Smollett: a sharp-looking man, cross with everything aboard,
and right about all of it." CR>
	       <RTRUE>)
	      (<VERB? TELL HELLO>
	       <TELL
"\"I don't like this cruise; I don't like the men; and I don't like my
officer. That's short and sweet.\"" CR>
	       <RTRUE>)>>

<ROUTINE GRAY-FCN ()
	<COND (<VERB? EXAMINE>
	       <TELL
"Abraham Gray, who came over the side to the captain's whistle with a
knife-cut down the face, and has said about nine words since." CR>
	       <RTRUE>)
	      (<VERB? TELL HELLO>
	       <TELL "\"Aye, sir,\" says Gray, and goes on loading." CR>
	       <RTRUE>)>>

<ROUTINE MUSKET-RACK-FCN ()
	<COND (<VERB? TAKE>
	       <TELL
"A musket is a two-man job in a crowd like this. Take a cutlass." CR>
	       <RTRUE>)
	      (<VERB? EXAMINE>
	       <TELL "Muskets in a rack, and powder in a keg beside them." CR>
	       <RTRUE>)>>

<ROUTINE CUTLASS-FCN ()
	<COND (<VERB? TAKE>
	       <SETG BOARDER-IDLE 0>
	       <RFALSE>)
	      (<VERB? EXAMINE>
	       <TELL "A plain navy cutlass, heavier than it looks and shorter
than you would like." CR>
	       <RTRUE>)>>

<ROUTINE BISCUIT-BAGS-FCN ()
	<COND (<VERB? EXAMINE TAKE SEARCH LOOK-INSIDE>
	       <TELL
"Bread-bags, mostly empty. The stores went down with the jolly-boat." CR>
	       <RTRUE>)>>

<ROUTINE KETTLE-FCN ()
	<COND (<VERB? EXAMINE DRINK DRINK-FROM>
	       <TELL
"A ship's iron kettle sunk in the sand with a spring rising into it,
clear and cold. It is the reason the stockade is here at all." CR>
	       <RTRUE>)>>

<ROUTINE LOOPHOLES-FCN ()
	<COND (<VERB? EXAMINE LOOK LOOK-INSIDE LOOK-UNDER ENTER THROUGH>
	       <TELL
"Through the loophole: stumps, sand, and the woods standing very still
in the heat." CR>
	       <RTRUE>)>>

<ROUTINE LOGHOUSE-OUT-FCN ()
	<COND (<EQUAL? ,SIEGE-STEP 0>
	       <COND (<EQUAL? ,PHASE 2>
		      <ESCAPADE>
		      ,STOCKADE-CLEARING)
		     (<G? ,PHASE 3>
		      <TELL
"Six buccaneers and a sea-cook are between you and the door, and one of
them is awake." CR>
		      <RFALSE>)
		     (T ,STOCKADE-CLEARING)>)
	      (T
	       <TELL
"Not now. There is a man in the doorway with a cutlass." CR>
	       <RFALSE>)>>

<ROUTINE ESCAPADE ()
	<SETG PHASE 2>
	<MOVE ,PISTOLS ,WINNER>
	<MOVE ,POWDER-HORN ,WINNER>
	<MOVE ,SHIP-BISCUIT ,WINNER>
	<TELL
"Nobody is watching. You fill your pockets with biscuit, take a brace of
pistols with powder-horn and ball, and are over the fence before your
conscience can vote. This is your second folly, and it will save every
life you love - but you do not know that yet." CR CR>
	<RTRUE>>

;"--- the white rock and the coracle ---"

<ROUTINE SPIT-FCN (RARG)
	<COND (<EQUAL? .RARG ,M-BEG>
	       <COND (<AND <VERB? LAUNCH BOARD ENTER THROUGH> <EQUAL? ,PRSO ,CORACLE>>
		      <LAUNCH-CORACLE>
		      <RTRUE>)
		     (<AND <VERB? PUT> <EQUAL? ,PRSO ,CORACLE>
			   <EQUAL? ,PRSI ,SEA>>
		      <LAUNCH-CORACLE>
		      <RTRUE>)>)>
	<RFALSE>>

<ROUTINE LAUNCH-CORACLE ()
	<COND (<NOT <IN? ,CORACLE ,WINNER>>
	       <TELL "You have no boat." CR>
	       <RTRUE>)
	      (<NOT ,NIGHTFALL>
	       <TELL
"In broad day, with the anchorage full of men who would love to see it?
Wait for dark." CR>
	       <RTRUE>)>
	<COND (<NOT ,S-LAUNCH> <SETG S-LAUNCH T> <AWARD 5>)>
	<REMOVE ,CORACLE>
	<SETG EBB-STEP 1>
	<TELL
"You slide her down the sand and get in, and she takes you at once - a
lop-sided, dancing little thing that goes any way but the one you
paddle, and rides the ebb like a cork with an opinion." CR CR>
	<GOTO ,ANCHORAGE>
	<RTRUE>>

<ROUTINE WHITE-ROCK-FCN (RARG)
	<RFALSE>>

<ROUTINE ROCK-FCN ()
	<COND (<VERB? EXAMINE>
	       <TELL
"A rock taller than a man and white as a bone, which is how a marooned
man makes a landmark he can find in the dark." CR>
	       <RTRUE>)>>

<ROUTINE TENT-FCN ()
	<COND (<VERB? OPEN RAISE MOVE LOOK LOOK-INSIDE LOOK-UNDER SEARCH>
	       <COND (<FSET? ,TENT ,OPENBIT>
		      <TELL "Already open, and already empty of surprises." CR>
		      <RTRUE>)>
	       <FSET ,TENT ,OPENBIT>
	       <TELL
"You lift the goat-skins. Under them, upside down on the turf, lies a
boat - if you are feeling generous. It is a coracle: a lop-sided frame
of tough wood with goat-skin stretched over it, hairy side in, and about
big enough for one boy and his poor judgement. Beside it is an old
spade, worn bright at the edge." CR>
	       <RTRUE>)
	      (<VERB? EXAMINE>
	       <TELL
"A little tent of goat-skins, pegged down in the hollow, exactly like
what the gipsies carry about in England." CR>
	       <RTRUE>)>>

<ROUTINE CORACLE-FCN ()
	<COND (<AND <VERB? TAKE> <NOT ,S-CORACLE>>
	       <SETG S-CORACLE T>
	       <AWARD 15>
	       <MOVE ,CORACLE ,WINNER>
	       <SETG NIGHTFALL T>
	       <TELL
"You get her up on your head, which is how they are carried and also why
Ben Gunn walks the way he does." CR CR>
	       <TELL
"By the time you are out of the hollow the sun is down behind the
Spy-glass, the fog is coming in off the sea in cold handfuls, and away
across the anchorage the pirates' camp fire has been lit. Two lights on
the black water: the fire ashore, and the cabin window of the
Hispaniola." CR>
	       <RTRUE>)
	      (<VERB? LAUNCH BOARD ENTER THROUGH>
	       <LAUNCH-CORACLE>
	       <RTRUE>)
	      (<VERB? EXAMINE>
	       <TELL
"A goat-skin coracle, lop-sided, light as a feather, and about as
seaworthy as an opinion." CR>
	       <RTRUE>)>>

<ROUTINE SPADE-FCN ()
	<COND (<VERB? EXAMINE>
	       <TELL
"Ben Gunn's spade, worn bright at the edge by three years of digging up
things that were not treasure - and once, of digging up something that
was." CR>
	       <RTRUE>)>>

;"--- the anchorage, the hawser, the drift ---"

<ROUTINE ANCHORAGE-FCN (RARG)
	<COND (<EQUAL? .RARG ,M-LOOK>
	       <COND (<G? ,DRIFT-STEP 2>
		      <TELL
"Off the west coast of the island in a grey dawn, with the surf on
Haulbowline Head going up in smoke and the sea lions barking. You are
wet through, stiff, and very much awake." CR>)
		     (<G? ,DRIFT-STEP 0>
		      <TELL
"Black water and black fog, and the ebb carrying you out with the
schooner's trailing cord in your fist." CR>)
		     (T
		      <TELL
"Black water, black fog, and two lights: the glow of the pirates' camp
fire ashore, and a blur at the stern window of the Hispaniola. The ebb
carries you down on her; the coracle turns any way but the one you
paddle. Her hawser rises dead ahead, taut as a bowstring." CR>)>
	       <RTRUE>)
	      (<EQUAL? .RARG ,M-BEG>
	       <COND (<AND <VERB? BOARD ENTER THROUGH CLIMB-UP CLIMB-FOO
				 CLIMB-ON LEAP TAKE>
			   <G? ,BOARD-CHANCES 0>>
		      <BOARD-THE-SHIP>
		      <RTRUE>)>
	       <RFALSE>)
	      (<EQUAL? .RARG ,M-END>
	       <EBB-BEAT>
	       <RTRUE>)>
	<RFALSE>>

<ROUTINE EBB-BEAT ()
	<COND (<G? ,DRIFT-STEP 0> <DRIFT-BEAT> <RTRUE>)>
	<SETG SLACK-CLOCK <+ ,SLACK-CLOCK 1>>
	<COND (<EQUAL? ,SLACK-CLOCK 3>
	       <TELL
"A puff of wind comes down off the trees; the schooner swings her head
and the hawser dips slack in your hand." CR>
	       <RTRUE>)
	      (<G? ,SLACK-CLOCK 4>
	       <SETG SLACK-CLOCK 0>
	       <TELL
"The wind dies, the schooner takes up her weight again, and the hawser
comes taut as a fiddle-string." CR>
	       <RTRUE>)>
	<RFALSE>>

<ROUTINE SLACK? ()
	<EQUAL? ,SLACK-CLOCK 3 4>>

<ROUTINE HAWSER-FCN ()
	<COND (<AND <VERB? CUT ATTACK MUNG>
		    <OR <EQUAL? ,PRSI ,GULLY> <EQUAL? ,PRSI ,CUTLASS>
			<EQUAL? ,PRSI ,DIRK>>>
	       <COND (<SLACK?>
		      <SETG HAWSER-CUTS <+ ,HAWSER-CUTS 1>>
		      <SETG SLACK-CLOCK 0>
		      <COND (<EQUAL? ,HAWSER-CUTS 1>
			     <TELL
"With the strain off her you cut strand after strand, and the hawser
gives, and gives, and stops - she rides by two." CR>
			     <RTRUE>)
			    (T
			     <COND (<NOT ,S-HAWSER>
				    <SETG S-HAWSER T> <AWARD 15>)>
			     <SETG DRIFT-STEP 1>
			     <FCLEAR ,CORD ,INVISIBLE>
			     <FSET ,HAWSER ,INVISIBLE>
			     <TELL
"The last two strands part with a noise like a shot in your hands, and
the Hispaniola is loose. She turns very slowly, all at once enormous,
and starts down the anchorage with the ebb - and you with her, a
trailing cord of the hawser still in your fist." CR>
			     <RTRUE>)>)
		     (T
		      <SETG HAWSER-INSIST <+ ,HAWSER-INSIST 1>>
		      ;"the count never resets: a boy who keeps sawing at a
		       taut hawser gets what the book promises" 
		      <COND (<EQUAL? ,HAWSER-INSIST 1>
			     <TELL
"Taut as a bowstring. A taut hawser suddenly cut is a thing as dangerous
as a kicking horse. Your nerve - for once - does you a service. Wait for
the wind." CR>
			     <RTRUE>)
			    (<EQUAL? ,HAWSER-INSIST 2>
			     <TELL
"It is still taut, and it will still take your head off, and the wind
will still come. Wait for it." CR>
			     <RTRUE>)
			    (T
			     <JIGS-UP
"A taut hawser, suddenly cut, is a thing as dangerous as a kicking horse.
You were told. The end of it comes round out of the dark with the whole
weight of a schooner behind it, and the coracle goes over, and the black
water of Captain Kidd's Anchorage closes over a boy who would not
wait.">
			     <RTRUE>)>)>)
	      (<VERB? CUT ATTACK>
	       <TELL "Not with that. You want an edge." CR>
	       <RTRUE>)
	      (<VERB? MOVE TAKE EXAMINE>
	       <TELL
"Her hawser, thick as your arm and thrumming with the pull of the tide." CR>
	       <RTRUE>)>>

<ROUTINE CORD-FCN ()
	<COND (<AND <VERB? MOVE TAKE EXAMINE CLIMB-UP CLIMB-FOO CLIMB-ON CLIMB-DOWN>
		    <NOT ,CORD-SEEN> <G? ,DRIFT-STEP 0>>
	       <SETG CORD-SEEN T>
	       <TELL
"You haul yourself up the cord until your head comes level with the
cabin window - and there, an arm's length off, in the lamplight, are
Israel Hands and the man in the red cap, locked together in a deadly
wrestle, each with a hand at the other's throat." CR CR>
	       <TELL
"You drop back into the coracle with your heart going, and the current
takes you, and the two lights swing away astern." CR>
	       <RTRUE>)
	      (<VERB? MOVE TAKE EXAMINE>
	       <TELL "A yard of cut hawser, trailing in the black water." CR>
	       <RTRUE>)>>

<ROUTINE DRIFT-BEAT ()
	<SETG DRIFT-STEP <+ ,DRIFT-STEP 1>>
	<COND (<EQUAL? ,DRIFT-STEP 4>
	       <TELL
"The current turns south and then west, and the island goes past you
sideways in the dark, and there is nothing to be done about any of it.
You lie down in the bottom of the coracle among the wet and let her
ride." CR>
	       <RTRUE>)
	      (<EQUAL? ,DRIFT-STEP 5>
	       <TELL
"You must have slept, so you must have lain there hours, dreaming of the
Admiral Benbow. When you sit up the world has been swapped: grey dawn,
the whole west coast of the island going by, and the surf breaking on
Haulbowline Head with a noise like a mill. Sea lions bark on the rocks
and take no interest in you at all." CR>
	       <RTRUE>)
	      (<EQUAL? ,DRIFT-STEP 6>
	       <SETG BOARD-CHANCES 1>
	       <TELL
"And then, out of the north, under her mainsail and her two jibs, with
nobody at the helm and nobody on deck, the Hispaniola comes down on
you - yawing, gathering, filling the sky. Her bowsprit is over your
head. Now or never." CR>
	       <RTRUE>)
	      (<EQUAL? ,DRIFT-STEP 7>
	       <SETG BOARD-CHANCES 2>
	       <TELL
"She sheers off and comes back, slower. One more chance, on the next
swell -" CR>
	       <RTRUE>)
	      (<G? ,DRIFT-STEP 7>
	       <JIGS-UP
"The swell lifts, the bowsprit passes over you like a church door
closing, and the moment - the one moment - is gone. The current has the
coracle now, and the current wants the open sea. You bail with your
sea-cap and steer with a prayer; the island shrinks to a smudge, to a
thought, to nothing. Gulls ask after you. Nobody else does. Somewhere
behind you, on a beach you will never see, a man with one leg is
explaining to the last honest men in the world that the boy was lost,
poor lad - brave, but never what you'd call smart as paint. The worst of
drowning at sea, you find, is the time it gives you to review your
decisions.">
	       <RTRUE>)>
	<RFALSE>>

<ROUTINE BOARD-THE-SHIP ()
	<COND (<NOT <G? ,BOARD-CHANCES 0>>
	       <TELL "She is nowhere near you." CR>
	       <RTRUE>)>
	<COND (<NOT ,S-BOARD> <SETG S-BOARD T> <AWARD 10>)>
	<SETG DRIFT-STEP 0>
	<SETG BOARD-CHANCES 0>
	<SETG SEA-PHASE T>
	<SETG PHASE 3>
	<REMOVE ,CORACLE>
	<MOVE ,ISRAEL-HANDS ,DECK>
	<MOVE ,OBRIEN ,DECK>
	<MOVE ,JOLLY-ROGER ,DECK>
	<MOVE ,BRANDY ,CABIN>
	<MOVE ,WINE ,CABIN>
	<MOVE ,MEDICAL-BOOK ,CABIN>
	<MOVE ,EMPTY-BOTTLES ,CABIN>
	<REMOVE ,APPLE-BARREL>
	<REMOVE ,PARROT>
	<REMOVE ,PARROT-CAGE>
	<REMOVE ,RAISINS>
	<TELL
"You jump, and get both hands on the bowsprit shrouds, and hang there
with the water tearing under you - and then, as the schooner rolls, you
are up and over and rolling on her deck. Behind you a dull blow tells
you the Hispaniola has charged down and struck the coracle, and that
there is no retreat left anywhere in the world." CR CR>
	<GOTO ,DECK>
	<RTRUE>>

<ROUTINE SHIP-FCN ()
	<COND (<AND <VERB? BOARD CLIMB-UP CLIMB-FOO CLIMB-ON CLIMB-DOWN LEAP ENTER THROUGH>
		    <EQUAL? ,HERE ,ANCHORAGE>>
	       <BOARD-THE-SHIP>
	       <RTRUE>)
	      (<AND <VERB? BOARD CLIMB-UP CLIMB-FOO CLIMB-ON CLIMB-DOWN ENTER THROUGH>
		    <EQUAL? ,HERE ,NORTH-INLET>>
	       <COND (<G? ,PHASE 5>
		      <TELL "Everything you own is ashore now." CR>
		      <RTRUE>)>
	       <GOTO ,DECK>
	       <RTRUE>)
	      (<AND <VERB? BOARD ENTER THROUGH CLIMB-UP CLIMB-FOO CLIMB-ON CLIMB-DOWN>
		    <EQUAL? ,HERE ,QUAY>>
	       <COND (,NOTE-GIVEN <BOARD-HISPANIOLA> <RTRUE>)
		     (T
		      <TELL
"\"The squire's note first, lad - the sign of the Spy-glass, up the
street.\"" CR>
		      <RTRUE>)>)
	      (<VERB? EXAMINE>
	       <TELL
"Two hundred tons of schooner, and the sweetest thing a boy ever stood
on, whoever happens to be aboard her at the time." CR>
	       <RTRUE>)>>

<ROUTINE SEA-FCN ()
	<COND (<VERB? SWIM>
	       <TELL
"You have seen what the surf does to boats. It is not waiting to do
better by boys." CR>
	       <RTRUE>)
	      (<VERB? TELL ANSWER REPLY>
	       <TELL
"You address the ocean. The ocean, an older and larger body than
yourself, declines to answer." CR>
	       <RTRUE>)
	      (<VERB? EXAMINE>
	       <TELL
"The sea, going about its business, which has never once included you." CR>
	       <RTRUE>)>>

<ROUTINE SHORE-FCN ()
	<COND (<VERB? EXAMINE>
	       <TELL "Trees to the water's edge, and not a friendly one among
them." CR>
	       <RTRUE>)>>

<ROUTINE SPYGLASS-HILL-FCN ()
	<COND (<VERB? EXAMINE>
	       <TELL
"The Spy-glass, the tallest of the three hills, sheer at the top and
trembling in the haze. Everything on this island is measured from it." CR>
	       <RTRUE>)
	      (<VERB? CLIMB-UP CLIMB-FOO CLIMB-ON CLIMB-DOWN>
	       <TELL
"The Spy-glass goes up sheer as a pedestal. Goats manage it. You are not
a goat." CR>
	       <RTRUE>)>>

;"--- Captain Hawkins: the flag, Hands, the sailing ---"

<ROUTINE ROGER-FCN ()
	<COND (<VERB? LOWER TAKE MUNG ATTACK CUT>
	       <COND (,S-ROGER
		      <TELL "It is already at the bottom of the bay." CR>
		      <RTRUE>)>
	       <SETG S-ROGER T>
	       <AWARD 10>
	       <REMOVE ,JOLLY-ROGER>
	       <TELL
"Down comes the cursed black flag, and overboard with it. God save the
King, and there's an end to Captain Silver!" CR>
	       <RTRUE>)
	      (<VERB? EXAMINE>
	       <TELL
"The Jolly Roger at the peak of the mainmast, black and complacent." CR>
	       <RTRUE>)>>

<ROUTINE OBRIEN-FCN ()
	<COND (<VERB? EXAMINE SEARCH LOOK-INSIDE>
	       <TELL
"O'Brien, the man in the red cap, lying on his back with his teeth
showing and his arms out like a crucified sailor. Whatever he and Hands
settled between them, he lost." CR>
	       <RTRUE>)
	      (<VERB? THROW OVERBOARD MOVE TAKE>
	       <REMOVE ,OBRIEN>
	       <TELL
"You get him up by the waist like a sack of bran and heave, and his red
cap comes off and stays floating, and when the water settles you can see
him lying on the clean bright sand in the shadow of the ship, with the
fish steering over him." CR>
	       <RTRUE>)>>

<ROUTINE HANDS-FCN ()
	<COND (<AND <VERB? GIVE> <EQUAL? ,PRSO ,BRANDY> <EQUAL? ,SAIL-STEP 0>>
	       <MOVE ,BRANDY ,ISRAEL-HANDS>
	       <SETG SAIL-STEP 1>
	       <TELL
"He takes the bottle in both hands, knocks the neck off against the
bulwark, and drinks like a man who has been waiting all day for exactly
this. Then he wipes his mouth and looks at you with a new expression
altogether." CR CR>
	       <TELL
"\"By thunder, but I wanted some o' that! Now, look here. You gives me
food and drink and a old scarf to tie my wound up, and I'll tell you how
to sail her - and that's about square all round, I take it. North Inlet,
says you? Why, I haven't no ch'ice, not I! I'd help you sail her up to
Execution Dock, by thunder, so I would.\" And so, with a boy at the
tiller and a wounded murderer conning her, the Hispaniola comes round on
the wind and stands north." CR>
	       <RTRUE>)
	      (<AND <VERB? GIVE> <EQUAL? ,PRSO ,WINE> <G? ,SAIL-STEP 2>>
	       <MOVE ,WINE ,ISRAEL-HANDS>
	       <SETG SAIL-STEP 5>
	       <TELL
"\"Here's luck!\" says Hands, and knocks the neck off this one too, like
a man who has done it often. He is in high good humour, and asks you
twice whether you have ever been to sea before, and both times forgets
the answer." CR>
	       <RTRUE>)
	      (<AND <VERB? GIVE> <EQUAL? ,PRSO ,BRANDY>>
	       <TELL "\"I've had my drink,\" says Hands. \"Mind your
steering.\"" CR>
	       <RTRUE>)
	      (<VERB? EXAMINE>
	       <COND (<G? ,DUEL-STEP 0>
		      <TELL
"Israel Hands with a dirk in his hand and a wounded leg under him,
coming on with the slow patience of a man who has all afternoon." CR>)
		     (,S-HANDS
		      <TELL
"Down under the clean bright water, on the sand in the shadow of the
ship, with the fish steering over him." CR>)
		     (T
		      <TELL
"Israel Hands, propped against the bulwarks with his chin on his chest,
white as a tallow candle and bleeding through his breeches, and every
so often he groans. He watches you the whole time." CR>)>
	       <RTRUE>)
	      (<AND <VERB? SHOOT ATTACK> <G? ,DUEL-STEP 0>>
	       <COND (<NOT <EQUAL? ,HERE ,CROSS-TREES>>
		      <TELL
"He is between you and everything, and he has the longer arm. The
shrouds, Jim, the shrouds!" CR>
		      <RTRUE>)>
	       <SHOOT-HANDS>
	       <RTRUE>)
	      (<VERB? ATTACK>
	       <TELL
"He is wounded, not harmless, and he is watching your hands." CR>
	       <RTRUE>)
	      (<VERB? TELL HELLO>
	       <COND (<EQUAL? ,SAIL-STEP 0>
		      <TELL "\"Brandy,\" says Hands. It is the whole of his
conversation." CR>)
		     (T
		      <TELL
"\"Starboard a little - so - steady,\" says Hands, and grins at nothing
at all." CR>)>
	       <RTRUE>)>>

<ROUTINE SAIL-BEAT ()
	<COND (<EQUAL? ,SAIL-STEP 1>
	       <SETG SAIL-STEP 2>
	       <TELL
"The land goes by fast on both sides. Hands cons her from the deck with
his eyes half shut, and you learn more about steering in an hour than in
three weeks of being shouted at." CR>
	       <RTRUE>)
	      (<EQUAL? ,SAIL-STEP 2>
	       <SETG SAIL-STEP 3>
	       <TELL
"Then Hands hesitates, artful as a cat. \"Jim,\" says he, \"I reckon
you might go below and get me a - well, a bottle of wine, Jim. This here
brandy's too strong for my head. Wine, and a corkscrew, and take your
time about it.\"" CR>
	       <RTRUE>)
	      (<EQUAL? ,SAIL-STEP 3>
	       <SETG SAIL-STEP 4>
	       <RFALSE>)
	      (<EQUAL? ,SAIL-STEP 4>
	       <RFALSE>)
	      (<EQUAL? ,SAIL-STEP 5>
	       <SETG SAIL-STEP 6>
	       <TELL
"\"Cut me a piece o' that scarf,\" says Hands, and drinks, and cons her
in past the point. \"Starboard a little - so - steady - now, my hearty,
luff!\"" CR>
	       <RTRUE>)
	      (<EQUAL? ,SAIL-STEP 6>
	       <SETG SAIL-STEP 0>
	       <SETG BEACHED T>
	       <COND (<NOT ,S-BEACH> <SETG S-BEACH T> <AWARD 10>)>
	       <START-DUEL>
	       <RTRUE>)>
	<RFALSE>>

<ROUTINE V-SNEAK ()
	<COND (<AND <EQUAL? ,HERE ,CABIN> <G? ,SAIL-STEP 2> <L? ,SAIL-STEP 5>>
	       <SETG WARNED T>
	       <TELL
"You go forward along the sparred gallery on your hands and knees,
without a sound, and put one eye round the corner of the fore
companion." CR CR>
	       <TELL
"Israel Hands is on his hands and knees on the deck, moving quicker than
a man with that leg has any business moving. He hauls a long knife -
a dirk, blood-stained to the handle - out of a coil of rope, looks at
it, tries the point on his palm, hides it in the breast of his jacket,
and trundles back to his old place against the bulwarks with a groan.
So that is settled, then. You go back the way you came, and your hands
are shaking, and you are grinning like a fool." CR>
	       <RTRUE>)
	      (<EQUAL? ,HERE ,CABIN>
	       <TELL
"There is nothing forward worth crawling for just now." CR>
	       <RTRUE>)
	      (T
	       <TELL
"You go quietly for a few steps, feel foolish, and stop." CR>
	       <RTRUE>)>>

<ROUTINE START-DUEL ()
	<SETG DUEL-STEP 1>
	<SETG CLIMB-GRACE <COND (,WARNED 2) (T 1)>>
	<GOTO ,DECK>
	<TELL
"She takes the sand with a shock that puts the whole deck on its side.
The masts swing over; the sea comes in through the scuppers; you and
Hands and dead O'Brien all go rolling into the lee scuppers together in
a heap." CR CR>
	<TELL
"And when you get your head up, there is Hands, already half-way toward
you, with the dirk in his hand." CR>
	<RTRUE>>

<ROUTINE DUEL-BEAT ()
	<COND (<NOT <EQUAL? ,HERE ,DECK>> <RFALSE>)>
	<SETG CLIMB-GRACE <- ,CLIMB-GRACE 1>>
	<COND (<L? ,CLIMB-GRACE 0>
	       <JIGS-UP
"He gets a hand in your shirt, and you learn what a coxswain's arm is
worth. \"Him as strikes first is my fancy,\" said Israel Hands once, of
another matter. \"His views, amen, so be it.\" The dirk goes in under
your ribs on the canted deck of a ship you had just captured, which
strikes you, in the last half-second available for such thoughts, as an
extremely unfair way to end an excellent day.">
	       <RTRUE>)
	      (T
	       <TELL
"He is between you and the bow, and coming on. The shrouds, Jim, the
shrouds!" CR>
	       <RTRUE>)>>

<ROUTINE XTREES-FCN (RARG)
	<COND (<EQUAL? .RARG ,M-ENTER>
	       <COND (<EQUAL? ,DUEL-STEP 1>
		      <SETG DUEL-STEP 2>
		      <TELL
"You go up the mizzen shrouds with your hands and feet doing the
thinking, and the dirk strikes the mast not half a foot below you as you
go." CR CR>
		      <TELL
"Safe for a moment, you remember your pistols - and snap one at him:
click. The priming is soaked through with sea-water. Powder and ball you
have; a dry recharge is the work of a moment, if he gives you a moment." CR>
		      <RTRUE>)>)
	      (<EQUAL? .RARG ,M-END>
	       <COND (<G? ,DUEL-STEP 1> <XTREES-BEAT> <RTRUE>)>
	       <RFALSE>)>
	<RFALSE>>

<ROUTINE XTREES-DOWN-FCN ()
	<COND (<AND <G? ,DUEL-STEP 1> <L? ,DUEL-STEP 9>>
	       <TELL
"With Israel Hands in the shrouds below you? Certainly not." CR>
	       <RFALSE>)
	      (T ,DECK)>>

<ROUTINE XTREES-BEAT ()
	<SETG DUEL-STEP <+ ,DUEL-STEP 1>>
	<COND (<EQUAL? ,DUEL-STEP 3>
	       <TELL
"Below you Hands takes the dirk in his teeth, gets his wounded leg into
the shrouds, and begins - slowly, with groans - to climb." CR>
	       <RTRUE>)
	      (<EQUAL? ,DUEL-STEP 4>
	       <COND (<NOT ,PRIMED>
		      <JIGS-UP
"He comes over the cross-trees with the dirk in his teeth and both hands
free, and your pistols are two lumps of wet iron. \"Him as strikes first
is my fancy,\" said Israel Hands. \"His views, amen, so be it.\" He is
as good as his word, and he is quicker about it than you would have
thought a wounded man could be.">
		      <RTRUE>)>
	       <TELL
"He stops a third of the way up, with his head level with your feet, and
takes the dirk out of his mouth." CR CR>
	       <TELL
"\"One more step, Mr. Hands,\" said I, \"and I'll blow your brains out!
Dead men don't bite, you know.\" He stopped instantly. \"Jim,\" says he,
\"I reckon I'll have to strike, which comes hard, you see, for a master
mariner to a ship's younker like you, Jim.\" And while you are drinking
in his words and smiling away, as conceited as a cock upon a wall, his
right hand goes back over his shoulder." CR>
	       <RTRUE>)
	      (<EQUAL? ,DUEL-STEP 5>
	       <TELL
"Something sings like an arrow. There is a blow, and a sharp pang, and
you are pinned by the shoulder to the mast. Both pistols are in your
hands, and both of them are dry, and Israel Hands is climbing again." CR>
	       <RTRUE>)
	      (<G? ,DUEL-STEP 5>
	       <COND (<L? ,DUEL-STEP 8> <RFALSE>)>
	       <JIGS-UP
"You had a loaded pistol in each hand and a man in a knife-fight coming
up the shrouds at you, and you spent the difference on thinking about
it.">
	       <RTRUE>)>
	<RFALSE>>

<ROUTINE V-PRIME ()
	<COND (<AND <EQUAL? ,HERE ,CROSS-TREES> <G? ,DUEL-STEP 1>>
	       <COND (,PRIMED
		      <TELL "Both are dry and both are loaded. Use them." CR>
		      <RTRUE>)>
	       <SETG PRIMED T>
	       <TELL
"You draw the useless charges and reprime, one pistol and then the
other, with the powder-horn between your knees and a murderer on the
ladder." CR>
	       <RTRUE>)
	      (<OR <IN? ,PISTOLS ,WINNER> <IN? ,SILVER-PISTOL ,WINNER>>
	       <SETG PRIMED T>
	       <TELL "You check the priming. Dry, and ready." CR>
	       <RTRUE>)
	      (T
	       <TELL "You have nothing about you that wants priming." CR>
	       <RTRUE>)>>

<ROUTINE PISTOLS-FCN ()
	<COND (<VERB? PRIME LAMP-ON>
	       <V-PRIME>
	       <RTRUE>)
	      (<AND <VERB? SHOOT> <G? ,DUEL-STEP 1>
		    <EQUAL? ,HERE ,CROSS-TREES>>
	       <SHOOT-HANDS>
	       <RTRUE>)
	      (<VERB? EXAMINE>
	       <TELL
"A brace of ship's pistols out of the log-house rack, and a horn of dry
powder - dry, at least, when you started." CR>
	       <RTRUE>)>>

<ROUTINE POWDER-FCN ()
	<COND (<VERB? EXAMINE>
	       <TELL "A cow's horn of black powder, stoppered tight." CR>
	       <RTRUE>)>>

<ROUTINE SHOOT-HANDS ()
	<COND (<L? ,DUEL-STEP 4>
	       <TELL
"Not yet. He has not come near enough, and you would waste both barrels
on the rigging." CR>
	       <RTRUE>)
	      (<NOT ,PRIMED>
	       <TELL
"Click. Click. The priming is soaked with sea-water, and Israel Hands
laughs at you from the shrouds." CR>
	       <RTRUE>)>
	<SETG DUEL-STEP 0>
	<SETG CLIMB-GRACE 99>
	<COND (<NOT ,S-HANDS> <SETG S-HANDS T> <AWARD 25>)>
	<REMOVE ,ISRAEL-HANDS>
	<MOVE ,DIRK ,CROSS-TREES>
	<TELL
"Both my pistols went off, and both of them escaped out of my hands. He
gave a sort of gulp, loosed his hold upon the shrouds, and plunged head
first into the water." CR CR>
	<TELL
"He rose once to the surface in a lather of foam and blood, and then
sank again for good. Being both shot and drowned, he was food for fish
in the very place where he had designed your slaughter." CR CR>
	<TELL
"The dirk holds you to the mast by a pinch of skin. You tear it loose
with a shudder, and it is nothing worse than a torn shoulder and a
lesson." CR>
	<FCLEAR ,DIRK ,NDESCBIT>
	<RTRUE>>

<ROUTINE V-SHOOT ()
	<COND (<AND <G? ,DUEL-STEP 3> <EQUAL? ,HERE ,CROSS-TREES>>
	       <SHOOT-HANDS>
	       <RTRUE>)>
	<COND (<EQUAL? ,PRSO ,ISRAEL-HANDS>
	       <COND (<G? ,DUEL-STEP 1> <SHOOT-HANDS>)
		     (T <TELL "There is no call for that yet." CR>)>
	       <RTRUE>)
	      (<AND <G? ,DUEL-STEP 1> <EQUAL? ,HERE ,CROSS-TREES>
		    <EQUAL? ,PRSO ,PISTOLS>>
	       <SHOOT-HANDS>
	       <RTRUE>)
	      (<AND <EQUAL? ,PHASE 5> <EQUAL? ,PRSO ,PIRATES>>
	       <TELL
"One boy, one pistol, five pirates, and a rope round your waist. Wait
for the doctor." CR>
	       <RTRUE>)
	      (<OR <IN? ,PISTOLS ,WINNER> <IN? ,SILVER-PISTOL ,WINNER>>
	       <TELL
"You have powder and ball enough, and no earthly reason to spend either
on that." CR>
	       <RTRUE>)
	      (T
	       <TELL "You have nothing to shoot with." CR>
	       <RTRUE>)>>

<ROUTINE DIRK-FCN ()
	<COND (<VERB? TAKE>
	       <MOVE ,DIRK ,WINNER>
	       <TELL
"You work Israel's dirk out of the mast. You will not sleep better for
owning it." CR>
	       <RTRUE>)
	      (<VERB? EXAMINE>
	       <TELL "A long knife, blood-stained to the handle, and the
handle is worn smooth." CR>
	       <RTRUE>)>>

<ROUTINE INLET-FCN (RARG)
	<COND (<EQUAL? .RARG ,M-BEG>
	       <COND (<AND <VERB? BOARD ENTER THROUGH CLIMB-UP CLIMB-FOO>
			   <EQUAL? ,PRSO ,SHIP>>
		      <COND (<G? ,PHASE 4>
			     <TELL "Everything you own is ashore now." CR>)
			    (T <GOTO ,DECK>)>
		      <RTRUE>)>
	       <RFALSE>)>
	<RFALSE>>

<ROUTINE WRECK-FCN ()
	<COND (<VERB? EXAMINE>
	       <TELL
"A three-masted wreck so long aground that shore bushes have taken root
on her deck and are flowering there, and great tangles of seaweed hang
from her rail and drip." CR>
	       <RTRUE>)
	      (<VERB? SEARCH LOOK-INSIDE LOOK LOOK-UNDER BOARD CLIMB-UP CLIMB-FOO CLIMB-ON CLIMB-DOWN>
	       <TELL
"Nothing but seaweed, flowers, and forty years of other people's bad
luck." CR>
	       <RTRUE>)>>

;"--- the plateau, the crag, the bar silver ---"

<ROUTINE SLOPE-FCN (RARG) <RFALSE>>
<ROUTINE SHOULDER-FCN (RARG) <RFALSE>>

<ROUTINE SKELETON-ROOM-FCN (RARG) <RFALSE>>

<ROUTINE SKELETON-FCN ()
	<COND (<VERB? EXAMINE>
	       <TELL
"It points. The feet are one way and the hands, raised over the head
like a diver's, are the other, and the whole long line of it is dead
straight. Sight along the bones and you are looking east-southeast and
by east - the line for Skeleton Island astern of you, and for the tall
trees ahead." CR>
	       <RTRUE>)
	      (<VERB? SEARCH LOOK-INSIDE TAKE MOVE>
	       <TELL
"Not a copper doit nor a baccy box. Somebody has been here before the
birds." CR>
	       <RTRUE>)>>

<ROUTINE CRAG-FCN (RARG)
	<COND (<AND <EQUAL? .RARG ,M-BEG> <VERB? DIG>> <V-DIG> <RTRUE>)>
	<RFALSE>>

<ROUTINE CRAG-FACE-FCN ()
	<COND (<VERB? EXAMINE>
	       <TELL
"Weather has beaten a face into the black rock: brows, a broken nose,
and a mouth full of shadow, all of it watching the sea. Below it a long
hummock of sand trends away east." CR>
	       <RTRUE>)>>

<ROUTINE INGOT-FCN ()
	<COND (<VERB? TAKE>
	       <TELL
"A boy cannot carry a fortune and his life both. You have marked the
spot, which is worth more." CR>
	       <RTRUE>)
	      (<VERB? EXAMINE COUNT>
	       <TELL
"Silver in bars, laid close as books on a shelf, under two feet of sand
and three stones you set there yourself." CR>
	       <RTRUE>)>>

<ROUTINE V-DIG ()
	<COND (<NOT <IN? ,SPADE ,WINNER>>
	       <TELL
"You dig like a terrier. Sand runs back into sand. Whatever is under
here wants iron." CR>
	       <RTRUE>)
	      (<EQUAL? ,HERE ,BLACK-CRAG>
	       <COND (,S-INGOT
		      <TELL
"You have had it up once. Leave it for the squire's men and the last
morning." CR>
		      <RTRUE>)>
	       <SETG DIG-COUNT <+ ,DIG-COUNT 1>>
	       <COND (<EQUAL? ,DIG-COUNT 1>
		      <TELL
"Ten fathoms south of the crag with the face on it, on the trend of the
east hummock, you put the spade in. Two feet down it rings on something
that is not stone." CR>
		      <RTRUE>)
		     (T
		      <SETG S-INGOT T>
		      <SETG SILVER-FOUND T>
		      <FCLEAR ,INGOT ,INVISIBLE>
		      <AWARD 15>
		      <TELL
"Silver in bars, laid close as books on a shelf: Flint's north cache,
that no cross on any chart ever marked, and that nineteen murderers
have walked over twice a day for a week." CR CR>
		      <TELL
"A boy cannot carry a fortune and his life both. You heap the sand back,
set three stones on top of it, and carry the knowing instead." CR>
		      <RTRUE>)>)
	      (<EQUAL? ,HERE ,TALL-PINE>
	       <COND (<FSET? ,GUINEA ,INVISIBLE>
		      <FCLEAR ,GUINEA ,INVISIBLE>
		      <TELL
"You turn over the floor of the old pit and the spade throws up one
coin: a two-guinea piece, and nothing else in nine feet of hole." CR>
		      <RTRUE>)>
	       <TELL
"You dig in the pit that seventeen men died for. It is still empty, and
you are still not the first." CR>
	       <RTRUE>)
	      (T
	       <TELL
"You dig. The island fails to object. Ten feet, the map said - and not
here." CR>
	       <RTRUE>)>>

<ROUTINE PINE-FCN (RARG)
	<COND (<AND <EQUAL? .RARG ,M-BEG> <VERB? DIG>> <V-DIG> <RTRUE>)>
	<RFALSE>>

<ROUTINE EXCAVATION-FCN ()
	<COND (<VERB? SEARCH LOOK-INSIDE LOOK LOOK-UNDER EXAMINE>
	       <COND (<AND <FSET? ,GUINEA ,INVISIBLE> <G? ,HUNT-STEP 0>>
		      <FCLEAR ,GUINEA ,INVISIBLE>
		      <TELL
"Grass has sprouted in the bottom of it. Down in the corner, Morgan
turns up a single coin with his hands - a two-guinea piece." CR>
		      <RTRUE>)>
	       <TELL
"A great pit with the sides fallen in and grass on the floor of it, and
a broken pick-shaft lying where somebody threw it in disgust." CR>
	       <RTRUE>)
	      (<VERB? ENTER THROUGH BOARD>
	       <TELL
"You climb down into the empty cache and stand in the hole where seven
hundred thousand pounds used to be. It is a strange feeling and not a
long one." CR>
	       <RTRUE>)>>

<ROUTINE PICK-FCN ()
	<COND (<VERB? EXAMINE TAKE>
	       <TELL
"A pick-shaft broken clean in two. Whoever emptied this hole worked
until things broke." CR>
	       <RTRUE>)>>

<ROUTINE BOARDS-FCN ()
	<COND (<VERB? READ READ-PAGE EXAMINE>
	       <TELL
"Packing boards, branded with a hot iron: WALRUS. Flint's ship." CR>
	       <RTRUE>)>>

<ROUTINE GUINEA-FCN ()
	<COND (<AND <VERB? TAKE> <G? ,HUNT-STEP 0>>
	       <TELL
"Morgan has it, and holds it up, and George Merry says the thing that
will get him killed inside the hour: \"Two guineas! That's your seven
hundred thousand pounds, is it? You're the man for bargains, ain't you?
You're him that never ruined nothing, you wooden-headed lubber!\"" CR>
	       <RTRUE>)
	      (<VERB? TAKE>
	       <MOVE ,GUINEA ,WINNER>
	       <TELL
"You pocket the two-guinea piece. \"That's your seven hundred thousand
pounds, is it?\" - somebody is going to say that, and mean it, and it
will cost him." CR>
	       <RTRUE>)
	      (<VERB? EXAMINE>
	       <TELL "One two-guinea piece, and the whole of Flint's estate
that anybody has actually held." CR>
	       <RTRUE>)>>

;"--- captivity, the black spot, the parole ---"

<ROUTINE CAPTURE-SCENE ()
	<MOVE ,SILVER ,LOG-HOUSE>
	<MOVE ,PIRATES ,LOG-HOUSE>
	<MOVE ,PARROT ,LOG-HOUSE>
	<REMOVE ,DOCTOR>
	<REMOVE ,SQUIRE>
	<TELL
"You feel your way in past the porch in the dark, pleased with yourself,
composing the first sentence of your report - and out of the black
overhead comes a shriek that stops your heart in your chest:" CR CR>
	<TELL
"\"Pieces of eight! Pieces of eight! Pieces of eight!\"" CR CR>
	<TELL
"A torch goes up. Six men are on their feet at once, and one voice cuts
across all of them, cheerful as a Sunday: \"Who goes? Well, well - Jim
Hawkins, shiver my timbers, dropped in, eh? Now that's friendly.\"" CR CR>
	<TELL
"They turn out your pockets before they let you sit down, and Silver
holds the chart up to the firelight for a long, long moment. \"So the
doctor's chart weren't the only one! Well, well. First and last, we've
split upon Jim Hawkins.\"" CR>
	<MOVE ,TREASURE-MAP ,SILVER>
	<RTRUE>>

<ROUTINE CAPTIVE-BEAT ()
	;"Step 7 is the parole prompt: hold there until the player answers."
	<COND (<EQUAL? ,CAPTIVE-STEP 7> <RFALSE>)>
	<SETG CAPTIVE-STEP <+ ,CAPTIVE-STEP 1>>
	<COND (<EQUAL? ,CAPTIVE-STEP 2>
	       <TELL
"You tell them the whole of it, because there is nothing left to keep:
the apple barrel, the schooner cut adrift and beached where they will
never find her, Israel Hands in the bay. \"Kill me, if you please, or
spare me. But one thing I'll say and no more: if you spare me, bygones
are bygones, and when you fellows are in court for piracy, I'll save you
all I can. So the laugh's on my side.\" Nobody moves. Silver's eye is
very bright. \"I'll bear it in mind,\" says he." CR>
	       <RTRUE>)
	      (<EQUAL? ,CAPTIVE-STEP 3>
	       <TELL
"George Merry gets up with four grievances and counts them on his
fingers: this cruise is a failure, the crew is dying, the cook has
bungled the terms, and the boy is a hostage nobody wants. The five of
them go out into the sand to hold council, and the fire crackles, and
Silver whistles a little through his teeth and does not look worried,
which frightens you more than the knives." CR>
	       <RTRUE>)
	      (<EQUAL? ,CAPTIVE-STEP 4>
	       <MOVE ,BIBLE-PAGE ,LOG-HOUSE>
	       <TELL
"They come back in and Merry hands Silver something small and black.
Silver turns it over. \"The black spot! I thought so. And where might
you have got the paper? Why - hillo! Look here, now, this ain't lucky.
You've gone and cut this out of a Bible. What fool's cut a Bible?\"
Dick, who has the fever coming on him, looks at the fire. Silver flicks
the paper over to you, cool as a card-player. \"There. Have a look at
what they think of me.\"" CR CR>
	       <TELL
"Then he plays the chart across the fire like an ace, and the whole
temper of the room turns over in a second: \"Barbecue forever! Silver
for cap'n!\"" CR>
	       <RTRUE>)
	      (<EQUAL? ,CAPTIVE-STEP 5>
	       <MOVE ,DOCTOR ,LOG-HOUSE>
	       <TELL
"You sleep, in the end, because a boy will. And in the grey of the
morning there is the doctor at the edge of the wood with his hat on the
back of his head, come to see his patients: lemon-peel eyes, and \"you
call it a prison, Silver; I call it a hospital.\" He physics the fevered
Dick, and looks the mutineers over one by one, and asks, quite calmly,
to speak with the boy." CR>
	       <RTRUE>)
	      (<EQUAL? ,CAPTIVE-STEP 6>
	       <TELL
"Silver walks you down to the fence himself. \"You'll give me your word
as you won't slip your cable, and I'll give you mine as I'll not leave
the pair of you.\" You give it. Then, over the paling, the doctor's
voice, low and hard and very fast:" CR CR>
	       <TELL
"\"Jim - whip over, and we'll run for it.\"" CR>
	       <SETG CAPTIVE-STEP 7>
	       <RTRUE>)>
	<RFALSE>>

<ROUTINE PAROLE-KEPT ()
	<SETG CAPTIVE-STEP 0>
	<SETG PHASE 5>
	<SETG HUNT-STEP 1>
	<COND (<NOT ,S-SPOT2> <SETG S-SPOT2 T> <AWARD 10>)>
	<TELL CR
"The doctor takes a long breath. \"Then take this: they'll find the
Hispaniola gone, and they'll have to make what they can of that. Keep
close to Silver when the pinch comes - and Jim: I'll not leave you.\"
Aloud, to the sea-cook, over his shoulder as he goes: \"Silver - look
out for squalls when you find it.\"" CR CR>
	<TELL
"Breakfast, then, and the hunt forms up: five buccaneers with picks and
crowbars, Silver with two guns slung about him and the parrot on his
shoulder, and a rope round your waist with the other end in his fist,
so that you go along after him like a dancing bear." CR>
	<RTRUE>>

<ROUTINE V-STAY ()
	<COND (<EQUAL? ,CAPTIVE-STEP 7>
	       <TELL
"\"Doctor,\" you say, \"I passed my word.\" And you can hear yourself say
it, and how young it sounds, and you say it anyway." CR>
	       <PAROLE-KEPT>
	       <RTRUE>)
	      (T
	       <TELL "You stay where you are. The world does not." CR>
	       <RTRUE>)>>

<ROUTINE BREAK-PAROLE ()
	<JIGS-UP
"You get one leg over the paling before the muskets speak, and the
doctor is shouting your name, and George Merry is a better shot than
anybody gave him credit for. You broke your word. It saved nobody.">
	<RTRUE>>

<ROUTINE PIRATES-FCN ()
	<COND (<VERB? EXAMINE>
	       <COND (<G? ,PHASE 4>
		      <TELL
"Five buccaneers with picks and crowbars, sweating and jumpy, and every
one of them doing arithmetic about shares." CR>)
		     (T
		      <TELL
"Six of them, in the log-house that was ours this morning, drinking our
brandy and eating our pork." CR>)>
	       <RTRUE>)
	      (<VERB? ATTACK SHOOT>
	       <COND (<EQUAL? ,PHASE 5>
		      <TELL
"There are five of them, you have one pistol, and Silver has the end of
your rope. Wait." CR>)
		     (T
		      <TELL
"You would not last the length of the room, and they would enjoy it." CR>)>
	       <RTRUE>)
	      (<VERB? TELL HELLO>
	       <TELL
"\"You keep quiet,\" says George Merry, who has not liked you since the
apple barrel and does not know why." CR>
	       <RTRUE>)>>

<ROUTINE BIBLE-PAGE-FCN ()
	<COND (<VERB? READ READ-PAGE EXAMINE>
	       <TELL
"A round of paper, blacked on one side with ash. On the other side, in a
shaky hand, one word: \"Depposed.\" And running across the back of it,
the print it was cut from: \"Without are dogs and murderers.\"" CR>
	       <RTRUE>)>>

;"--- the treasure hunt on a rope ---"

<ROUTINE HUNT-ROOM-CHECK ()
	<COND (<AND <EQUAL? ,PHASE 5> <VERB? WALK>>
	       <SETG ROPE-FIGHTS <+ ,ROPE-FIGHTS 1>>
	       <COND (<G? ,ROPE-FIGHTS 2>
		      <JIGS-UP
"You set your feet and haul back on the rope a third time. Silver brings
you in like a fish, hand over hand, without hurrying and without a word,
and the crew - who have been looking for a reason all morning - vote
with their knives.">
		      <RTRUE>)>
	       <TELL
"The rope is Silver's answer, and it is a good one." CR>
	       <RTRUE>)>
	<RFALSE>>

<ROUTINE HUNT-BEAT ()
	<SETG HUNT-STEP <+ ,HUNT-STEP 1>>
	<COND (<EQUAL? ,HUNT-STEP 2>
	       <MOVE ,SILVER ,PLATEAU-SLOPE>
	       <MOVE ,PIRATES ,PLATEAU-SLOPE>
	       <MOVE ,PARROT ,PLATEAU-SLOPE>
	       <GOTO ,PLATEAU-SLOPE>
	       <TELL
"The party fans out across the slope, shouting to each other through the
scrub. They dig at every hummock, and turn up nothing but pig-nuts and
the roots of things, and Silver takes his bearings off the Spy-glass and
says nothing at all." CR>
	       <RTRUE>)
	      (<EQUAL? ,HUNT-STEP 3>
	       <MOVE ,SILVER ,SKELETON>
	       <MOVE ,PIRATES ,SKELETON>
	       <MOVE ,PARROT ,SKELETON>
	       <GOTO ,SKELETON>
	       <TELL
"At the top of the plateau the man in front lets out a cry, and they all
run, and there it is under the big pine: a skeleton, stretched dead
straight, the feet one way and the hands over the head the other." CR CR>
	       <TELL
"\"He's been thinner in his day,\" says Morgan. \"This is good
sea-cloth,\" says Merry, going through the rags. Silver hops round it on
his crutch and gets down and sights along the bones with his compass.
\"East-southeast and by east. That's a p'inter, that is - Flint's
humour, if I know the man. Six of them he took ashore, and one of them
lies here as a compass needle.\" He straightens up and the sun is out
and nobody laughs. \"Great guns, messmates - but if Flint was living,
this would be a hot spot for you and me.\"" CR>
	       <RTRUE>)
	      (<EQUAL? ,HUNT-STEP 4>
	       <MOVE ,SILVER ,SPYGLASS-SHOULDER>
	       <MOVE ,PIRATES ,SPYGLASS-SHOULDER>
	       <MOVE ,PARROT ,SPYGLASS-SHOULDER>
	       <GOTO ,SPYGLASS-SHOULDER>
	       <TELL
"They halt on the shoulder to get their breath, and it is then, out of
the trees in front of them, thin and high and quavering, that a voice
begins to sing:" CR CR>
	       <TELL
"\"Fifteen men on the dead man's chest - Yo-ho-ho, and a bottle of
rum!\"" CR CR>
	       <TELL
"Nothing you will ever see again will be quite the colour those five men
go. Morgan grovels on the ground. \"It's Flint, by -\" and then the
voice breaks off in the middle of a note, as if a hand had been laid
across the singer's mouth." CR>
	       <RTRUE>)
	      (<EQUAL? ,HUNT-STEP 5>
	       <TELL
"Then the wail comes, from farther off, and there is not a man there who
does not know the words: \"Darby M'Graw! Darby M'Graw! Fetch aft the
rum, Darby!\" - Flint's last words on earth, said out loud on a hot
morning in front of five of the men who heard him say them." CR CR>
	       <TELL
"Silver's face is grey, but his jaw is set. \"There was an echo. And who
ever seen a sperrit with a shadow? Well then, what's he doing with an
echo to him? That ain't in natur', surely?\" Merry, slowly, working it
out: \"You're right - and it weren't Flint's voice. It was liker - by
the powers, it was liker Ben Gunn!\" \"Ben Gunn!\" roars Morgan, getting
up off his knees. \"Dead or alive, nobody minds Ben Gunn.\" And it is
extraordinary how the fear goes out of them, and how fast." CR>
	       <RTRUE>)
	      (<EQUAL? ,HUNT-STEP 6>
	       <MOVE ,SILVER ,TALL-PINE>
	       <MOVE ,PIRATES ,TALL-PINE>
	       <MOVE ,PARROT ,TALL-PINE>
	       <GOTO ,TALL-PINE>
	       <MOVE ,SILVER-PISTOL ,TALL-PINE>
	       <FCLEAR ,SILVER-PISTOL ,NDESCBIT>
	       <TELL
"The tall tree comes in sight and they break into a run, dragging you at
the rope's end, and then all five of them stop dead as if they had hit a
wall." CR CR>
	       <TELL
"There is a great pit in the ground under the pine. The sides have
fallen in and grass has sprouted in the bottom of it, and there is a
broken pick-shaft, and boards branded WALRUS. The cache had been found
and rifled; the seven hundred thousand pounds were gone." CR CR>
	       <TELL
"Silver's face goes hard as flint, and his hand comes back and finds
your shoulder, and his voice is a whisper you can hardly hear. \"Jim,\"
says he, \"take that, and stand by for trouble\" - and passes you a
double-barrelled pistol." CR>
	       <RTRUE>)
	      (<EQUAL? ,HUNT-STEP 7>
	       <RFALSE>)
	      (<EQUAL? ,HUNT-STEP 8>
	       <AMBUSH>
	       <RTRUE>)>
	<RFALSE>>

<ROUTINE SILVER-PISTOL-FCN ()
	<COND (<AND <VERB? TAKE> <EQUAL? ,HUNT-STEP 6>>
	       <MOVE ,SILVER-PISTOL ,WINNER>
	       <SETG HUNT-STEP 7>
	       <TELL
"You take it, and at the same moment you understand exactly where the
seven hundred thousand pounds went, and who dug it, and what a wedge of
cheese is worth. Silver has begun, very quietly, to move round the pit
so that the two of you are shoulder to shoulder." CR>
	       <RTRUE>)
	      (<VERB? EXAMINE>
	       <TELL
"A double-barrelled pistol, both barrels loaded, given to you by the
most dangerous man on the island for reasons of his own." CR>
	       <RTRUE>)>>

<ROUTINE AMBUSH ()
	<SETG HUNT-STEP 9>
	<COND (<NOT ,S-AMBUSH> <SETG S-AMBUSH T> <AWARD 15>)>
	<TELL
"Merry is down in the pit and up again with the fever on him. \"Two
guineas! Comrades, that's him, that's the man - him and that boy - I'll
have his heart out!\" and he raises his arm and his voice for the
charge." CR CR>
	<TELL
"Right in the middle of it, crack! crack! crack! - three musket-shots
out of the nutmeg thicket. Merry tumbles head first into the excavation;
the man with the bandage spins like a top and goes down full length;
and the other three turn and run for their lives. Silver's two barrels
go into Merry as he struggles up, and he tells him so, looking down:
\"George, I reckon I settled you.\"" CR CR>
	<TELL
"Out of the thicket come the doctor, Gray, and Ben Gunn, with the
gunsmoke still on them. Away over the scrub you can see the three
survivors still running, right for Mizzenmast Hill, and the doctor calls
Gray back off the chase. Silver takes off his hat. \"Doctor Livesey,\"
says he, \"you saved my life, and Jim's too. And you're Ben Gunn - well,
I never.\"" CR>
	<MOVE ,BEN-GUNN ,TALL-PINE>
	<MOVE ,DOCTOR ,TALL-PINE>
	<MOVE ,GRAY ,TALL-PINE>
	<REMOVE ,PIRATES>
	<SETG PHASE 6>
	<RTRUE>>

;"--- the cave and the sail home ---"

<ROUTINE V-FOLLOW ()
	<COND (<AND <EQUAL? ,PHASE 6> <EQUAL? ,CAVE-STEP 0>>
	       <COND (<EQUAL? ,HERE ,TALL-PINE>
		      <TELL
"\"This way, Jim,\" says the doctor, and the whole strange procession -
doctor, squire's man, marooned man, sea-cook and boy - goes down off the
plateau together, while Ben Gunn tells how he found the skeleton and
rifled the cache and carried seven hundred thousand pounds up to his
cave on his back, a little at a time, in two years of afternoons." CR CR>
		      <MOVE-PARTY ,SPYGLASS-SHOULDER>
		      <GOTO ,SPYGLASS-SHOULDER>
		      <RTRUE>)
		     (T
		      <FOLLOW-PARTY>
		      <RTRUE>)>)
	      (<AND <EQUAL? ,PHASE 6> <G? ,CAVE-STEP 0>>
	       <TELL "Everyone you would follow is right here." CR>
	       <RTRUE>)
	      (T
	       <TELL "There is nobody to follow." CR>
	       <RTRUE>)>>

<ROUTINE MOVE-PARTY (RM)
	<MOVE ,DOCTOR .RM> <MOVE ,GRAY .RM> <MOVE ,BEN-GUNN .RM>
	<MOVE ,SILVER .RM>
	<RTRUE>>

<ROUTINE FOLLOW-PARTY ()
	<COND (<EQUAL? ,HERE ,SPYGLASS-SHOULDER> <MOVE-PARTY ,SKELETON> <GOTO ,SKELETON>)
	      (<EQUAL? ,HERE ,SKELETON> <MOVE-PARTY ,PLATEAU-SLOPE>
	       <GOTO ,PLATEAU-SLOPE>)
	      (<EQUAL? ,HERE ,PLATEAU-SLOPE> <MOVE-PARTY ,OPEN-WOODS>
	       <GOTO ,OPEN-WOODS>)
	      (<EQUAL? ,HERE ,OPEN-WOODS> <MOVE-PARTY ,HILL-FOOT>
	       <GOTO ,HILL-FOOT>)
	      (<EQUAL? ,HERE ,HILL-FOOT>
	       <TELL "\"Up you go, Jim,\" says Ben Gunn. \"It's my cave, and
you're the first honest visitor it's had.\"" CR>)
	      (T <TELL "\"This way, Jim,\" says the doctor." CR>)>
	<RTRUE>>

<ROUTINE CAVE-FCN (RARG)
	<COND (<EQUAL? .RARG ,M-ENTER>
	       <COND (<NOT ,S-CAVE>
		      <SETG S-CAVE T>
		      <SETG CAVE-STEP 1>
		      <AWARD 40>
		      <MOVE ,SMOLLETT ,BEN-CAVE>
		      <MOVE ,SILVER ,BEN-CAVE>
		      <TELL
"And there it is: heaped coin and quadrilaterals built of bars of gold,
Flint's treasure, that seventeen men of the Hispaniola have died for
already and nobody knows how many hundreds before them." CR CR>
		      <TELL
"Captain Smollett is on a mattress by the fire with his shoulder
strapped up. \"John Silver,\" says he, \"you're a prodigious villain and
an imposter - a monstrous imposter, sir. I am told I am not to prosecute
you. Well then, I will not.\" And then, to you, without turning his
head: \"You're a good boy in your line, Jim, but I don't think you and
me'll go to sea again. You're too much of the born favourite for me.\"" CR>
		      <RTRUE>)>)
	      (<EQUAL? .RARG ,M-END>
	       <COND (<G? ,CAVE-STEP 0> <CAVE-BEAT> <RTRUE>)>
	       <RFALSE>)>
	<RFALSE>>

<ROUTINE CAVE-BEAT ()
	<SETG CAVE-STEP <+ ,CAVE-STEP 1>>
	<COND (<EQUAL? ,CAVE-STEP 2>
	       <TELL
"Supper, then: salt goat, and a bottle of old wine out of the
Hispaniola, and all of us together in the firelight, and Long John
sitting back in the shadow with a good appetite and a civil word for
everybody - the same bland, polite, obsequious seaman of the voyage
out." CR CR>
	       <TELL
"The days after are the hardest work of your life: bread-bag after
bread-bag of coin carried down the hill and rowed out to the schooner,
English and French and Spanish and Portuguese, doubloons and double
guineas and moidores and sequins, the pictures of all the kings of
Europe for the last hundred years, and the parrot on a spar overhead
counting it. \"Pieces of eight! Pieces of eight!\"" CR CR>
	       <TELL
"On the last morning the three survivors are left ashore with powder and
shot and stores and the doctor's good advice, and everything is aboard,
and the tide serves." CR>
	       <RTRUE>)>
	<RFALSE>>

<ROUTINE TREASURE-FCN ()
	<COND (<VERB? TAKE COUNT SEARCH LOOK-INSIDE>
	       <TELL
"You fill both fists and let it run - English and French and Spanish and
Portuguese, doubloons and double guineas and moidores and sequins,
pictures of all the kings of Europe for the last hundred years. Loading
it is tomorrow's work." CR>
	       <RTRUE>)
	      (<VERB? EXAMINE>
	       <TELL
"Coin in heaps and gold in bars stacked like brickwork, glowing back at
the fire. It is the ugliest beautiful thing you have ever seen." CR>
	       <RTRUE>)>>

<ROUTINE GOAT-MEAT-FCN ()
	<COND (<VERB? EAT TAKE>
	       <TELL "Salt goat. Ben Gunn has had worse and says so, twice." CR>
	       <RTRUE>)>>

<ROUTINE V-SAIL ()
	<COND (<AND <EQUAL? ,PHASE 6> <G? ,CAVE-STEP 1>>
	       <COND (<NOT ,S-SAIL> <SETG S-SAIL T> <AWARD 25>)>
	       <VICTORY>
	       <RTRUE>)
	      (<EQUAL? ,PHASE 6>
	       <TELL
"Not yet. There is a fortune on a hillside and it will not carry
itself." CR>
	       <RTRUE>)
	      (T
	       <TELL
"You look at the sea for a while and want very much to be somewhere
else on it. Not yet." CR>
	       <RTRUE>)>>

<ROUTINE VICTORY ()
	<TELL
"The Hispaniola stands out of North Inlet with the same colours flying
that the captain fought under at the stockade. On the spit, three
marooned men kneel in the sand with their arms out; the doctor hails
them the news of the stores you have left, and one of them, by way of
thanks, puts a musket-ball through the main-sail." CR CR>
	<COND (,SILVER-FOUND
	       <TELL
"In the hold, along with the gold, lie certain bars of silver from under
a black crag - fetched off on the last morning by the squire's men, to
the everlasting glory of the only soul aboard who ever read a map to the
bottom." CR CR>)>
	<TELL
"At the first port with lights and fruit-boats, Long John Silver goes
over the side in a shore boat, quietly, in the dark, with a sack of coin
worth three or four hundred guineas to help him on his further
wanderings. Ben Gunn confesses everything at dawn. You are all of you,
on the whole, pleased to be so cheaply quit of him." CR CR>
	<TELL
"Home, then: five men of all that sailed, and the gold notched into
every one of your natures. Smollett retires; Gray saves and rises; Ben
Gunn gets a thousand pounds and spends it in nineteen days. And you -
you have money enough, and no wish on earth to see that accursed island
again. Oxen and wain-ropes would not bring you back. Though on the worst
nights you still hear the surf booming on its coasts, and start upright
in bed with the sharp voice of Captain Flint ringing in your ears:
\"Pieces of eight! Pieces of eight!\"" CR CR>
	<WINNER-END "">
	<RTRUE>>

;"=== Easter eggs and global flavor =============================="

<ROUTINE V-PRAY ()
	<COND (<EQUAL? ,HERE ,HILL-FOOT>
	       <TELL
"It weren't quite a chapel, but it seemed more solemn like." CR>
	       <RTRUE>)
	      (T
	       <TELL
"You say the one your mother taught you. It does no harm, and there is
some evidence it does good." CR>
	       <RTRUE>)>>

<ROUTINE V-COUNT ()
	<COND (<EQUAL? ,PRSO ,TREASURE-HEAP>
	       <TELL
"Doubloons, double guineas, moidores and sequins - the pictures of all
the kings of Europe for the last hundred years, strange oriental pieces
with squiggles like bits of string, and round pieces and square pieces
and pieces bored through the middle. You give up at about the same
moment the parrot does." CR>
	       <RTRUE>)
	      (T
	       <TELL "You lose count almost at once." CR>
	       <RTRUE>)>>

<SYNTAX SING = V-SING>
<SYNONYM SING YOHO>

<ROUTINE V-SING ()
	<COND (<PARROT-NEAR?>
	       <TELL
"You give them a stave of Fifteen Men. The parrot joins in, word
perfect, and improves on the ending." CR>
	       <RTRUE>)
	      (T
	       <TELL
"\"Fifteen men on the dead man's chest - Yo-ho-ho, and a bottle of
rum!\" Somewhere, your mother's ears burn." CR>
	       <RTRUE>)>>

<ROUTINE V-ADVENT ()
	<TELL
"That is the other kind of magic, and a different ocean entirely." CR>
	<RTRUE>>

<ROUTINE V-ZORK ()
	<TELL "Wrong cellar." CR>
	<RTRUE>>

<ROUTINE V-SWIM ()
	<TELL
"You have seen what the surf does to boats. It is not waiting to do
better by boys." CR>
	<RTRUE>>

<ROUTINE V-LISTEN ()
	<COND (<AND <EQUAL? ,HERE ,DECK> <G? ,BARREL-STEP 0>
		    <L? ,BARREL-STEP 90>>
	       <RFALSE>)
	      (<EQUAL? ,HERE ,ANCHORAGE>
	       <TELL
"Across the water, two drunk men are quarrelling in the cabin of the
Hispaniola, and away on the shore the camp fire is singing the one about
the dead man's chest: \"But one man of her crew alive, what put to sea
with seventy-five.\"" CR>
	       <RTRUE>)
	      (T
	       <TELL "The surf, which is always there, and under it the whole
island being quiet at you." CR>
	       <RTRUE>)>>

;"=== The winner's action: scene rails =========================="

<ROUTINE ADVENTURER-FCN ()
	;"Barrel lock-in: the player is inside a vehicle, so the room's
	 M-END does not fire. Drive the scene from here instead."
	<COND (<AND <G? ,BARREL-STEP 0> <L? ,BARREL-STEP 90>>
	       <COND (<AND <VERB? EXIT DISEMBARK STAND WALK CLIMB-UP CLIMB-FOO CLIMB-ON CLIMB-DOWN YELL ATTACK LEAP>
			   <NOT <EQUAL? ,BARREL-STEP 98>>>
		      <COND (<NOT ,BARREL-WARNED>
			     <SETG BARREL-WARNED T>
			     <TELL
"Silver's shoulder is against the staves, close enough that you can feel
him breathe. Move now and you die with an apple in your hand." CR>
			     <RTRUE>)
			    (T
			     <JIGS-UP
"You stand up with an apple in your hand, and the whole deck of the
Hispaniola turns round and looks at you, and Long John Silver's face
does a thing you will not have to remember for very long. \"Well,
well,\" says he, quite kindly. \"Dick, my son, fetch a line.\"">
			     <RTRUE>)>)>
	       <RFALSE>)>
	<COND (<AND <EQUAL? ,CAPTIVE-STEP 7>
		    <VERB? FOLLOW WALK CLIMB-UP CLIMB-FOO CLIMB-ON CLIMB-DOWN ENTER THROUGH>>
	       <BREAK-PAROLE>
	       <RTRUE>)>
	<COND (<AND <EQUAL? ,PHASE 5> <VERB? WALK CLIMB-UP CLIMB-DOWN LEAP>>
	       <HUNT-ROOM-CHECK>
	       <RTRUE>)>
	;"The engine's GROUND global owns SAND and answers DIG before any
	 room can; take DIG at the actor level so the spade works."
	<COND (<VERB? DIG> <V-DIG> <RTRUE>)>
	<RFALSE>>

;"Per-turn scene driver for rooms whose action is busy, plus the
 barrel (the player is in a vehicle there, so the room M-END is not
 reached)."
<ROUTINE I-CARRIED ()
	;"ITAKE-CHECK performs implicit takes by calling ITAKE directly, so an
	 object ACTION never sees the TAKE and a TAKE-branch award is silently
	 lost (READ SPOT takes the spot and skips the points). Score on
	 possession instead - this catches explicit and implicit alike."
	<COND (<AND <NOT ,S-SPOT> <IN? ,BLACK-SPOT ,WINNER>>
	       <SETG S-SPOT T>
	       <AWARD 5>)>
	<COND (<AND <NOT ,S-PACKET> <IN? ,PACKET ,WINNER>>
	       <SETG S-PACKET T>
	       <AWARD 15>)>
	<COND (<AND <NOT ,S-CORACLE> <IN? ,CORACLE ,WINNER>>
	       <SETG S-CORACLE T>
	       <SETG NIGHTFALL T>
	       <AWARD 15>)>
	<RFALSE>>

<ROUTINE I-SCENES ()
	<COND (<AND <G? ,BARREL-STEP 0> <L? ,BARREL-STEP 90>>
	       <COND (,BARREL-FRESH <SETG BARREL-FRESH <>> <RFALSE>)>
	       <BARREL-BEAT>
	       <RTRUE>)
	      (<AND <EQUAL? ,BARREL-STEP 98> <NOT <IN? ,WINNER ,APPLE-BARREL>>>
	       <SETG BARREL-STEP 99>
	       <COND (<NOT ,S-COUNCIL> <SETG S-COUNCIL T> <AWARD 20>)>
	       <TELL
"You wait until the deck is full of feet and voices, and then you slip
over the edge of the barrel and drop down among them in the dark, and
nobody so much as looks at you. You know, now, what nineteen men intend
to do to the seven you love. Aft, then - the cabin - and quickly." CR>
	       <RTRUE>)
	      (<AND <EQUAL? ,PHASE 5> <G? ,HUNT-STEP 0>>
	       <HUNT-BEAT>
	       <RTRUE>)>
	<RFALSE>>

;"=== Startup wiring ============================================"

<ROUTINE INIT-SCENES ()
	<ENABLE <QUEUE I-BENBOW -1>>
	<ENABLE <QUEUE I-SCENES -1>>
	<ENABLE <QUEUE I-PARROT -1>>
	<ENABLE <QUEUE I-CARRIED -1>>
	<RTRUE>>

;"czil collapses a room's second IN clause into its (IN ROOMS) parent,
 so an (IN TO room) exit compiles to a walk into the ROOMS object and
 the engine answers 'you can't go there without a vehicle'. PER exits
 sidestep the clause entirely. See BUILD-ISSUES.md."

<ROUTINE V-ENTER ()
	<COND (,PRSO <RFALSE>)>
	<COND (<EQUAL? ,HERE ,COVE-ROAD> <GOTO ,PARLOUR> <RTRUE>)
	      (<EQUAL? ,HERE ,STOCKADE-CLEARING> <GOTO ,LOG-HOUSE> <RTRUE>)
	      (<EQUAL? ,HERE ,DECK>
	       <COND (,SEA-PHASE <GOTO ,CABIN>) (T <GOTO ,GALLEY>)>
	       <RTRUE>)
	      (<EQUAL? ,HERE ,HILL-FOOT>
	       <DO-WALK ,P?UP>
	       <RTRUE>)
	      (<EQUAL? ,HERE ,WHITE-ROCK>
	       <PERFORM ,V?OPEN ,TENT>
	       <RTRUE>)
	      (T <DO-WALK ,P?OUT>)>>

<ROUTINE TOPICS-FCN ()
	<COND (<VERB? EXAMINE>
	       <TELL
"You turn it over in your mind. It does not get any simpler." CR>
	       <RTRUE>)>>
