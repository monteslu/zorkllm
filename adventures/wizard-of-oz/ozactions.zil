"OZACTIONS - core machinery for THE SILVER SHOES.
Globals, the companion system, scoring, engine stubs, and Acts I-II."

"=== GLOBALS: narrative state lives here, not in object flags ==="

<GLOBAL SCORE-MAX 250>

<GLOBAL ACT 1>
<GLOBAL STORM-PHASE 0>      ;"0 kansas, 1 flying, 2 landed, 3 out of the house (prologue over)"
<GLOBAL TOTO-SAVED 0>       ;"bit 1 = grabbed, bit 2 = trapdoor closed"
<GLOBAL TOTO-FELL <>>
<GLOBAL TOTO-GONE <>>
<GLOBAL FEET-TURNS 0>
<GLOBAL WITCH-N-GONE <>>
<GLOBAL SHOES-WORN <>>
<GLOBAL SHOE-NAG 0>

<GLOBAL SCARE-STATE 0>      ;"0 on pole, 1 in party, 2 marooned, 3 unstuffed"
<GLOBAL WOOD-STATE 0>       ;"0 rusted, 1 in party, 2 battered, 3 mended"
<GLOBAL LION-STATE 0>       ;"0 wild, 1 in party, 2 asleep, 3 caged, 4 crowned"

<GLOBAL OILED-COUNT 0>
<GLOBAL BEETLE-STATE 0>     ;"0 not yet, 1 rusted, 2 fixed"
<GLOBAL LION-SCENE 0>
<GLOBAL SCENE-FLAG <>>      ;"suppress banter while a scene runs"

<GLOBAL BRAMBLE-OPEN <>>
<GLOBAL GORGE-CROSSED <>>
<GLOBAL BRIDGE-STATE 0>     ;"0 standing, 1 felled, 2 crossing, 3 cut"
<GLOBAL KALIDAH-TURNS 0>
<GLOBAL KALIDAH-CLEAN <>>
<GLOBAL LION-HURT <>>
<GLOBAL RAFT-BUILT <>>
<GLOBAL RIVER-DONE <>>
<GLOBAL DRIFT 0>
<GLOBAL STORK-DONE <>>
<GLOBAL SONG-TURNS 0>
<GLOBAL POPPY-COUNT 0>
<GLOBAL POPPY-DONE <>>
<GLOBAL WILDCAT-STATE 0>    ;"0 none, 1 running, 2 killed, 3 queen asks, 4 done"
<GLOBAL WC-TURNS 0>
<GLOBAL LION-HAULED <>>
<GLOBAL BELL-RUNG <>>
<GLOBAL SPECS-ON <>>
<GLOBAL SPECS-DONE <>>
<GLOBAL DAY 0>
<GLOBAL AUDIENCE 0>         ;"0..4 audiences held"
<GLOBAL SUMMONED <>>
<GLOBAL ANSWERS 0>
<GLOBAL AUDIENCES-SCORED <>>

<GLOBAL WAVE 0>             ;"1 wolves, 2 crows, 3 bees, 4 winkies"
<GLOBAL WAVE-TURNS 0>
<GLOBAL WAVES-WON 0>
<GLOBAL CAPTURED <>>
<GLOBAL CHORES 0>
<GLOBAL CDAY 1>
<GLOBAL FEEDINGS 0>
<GLOBAL FED-TONIGHT <>>
<GLOBAL WITCH-DEAD <>>
<GLOBAL THEFT-DONE <>>
<GLOBAL DITHER 0>
<GLOBAL SHOE-BACK <>>
<GLOBAL MESS-SWEPT <>>
<GLOBAL CAP-READ <>>
<GLOBAL CAP-USES 3>
<GLOBAL RITUAL 0>           ;"charm words said so far"
<GLOBAL MONKEYS-HERE <>>
<GLOBAL LION-FREED <>>
<GLOBAL WOOD-FIXED <>>
<GLOBAL SCARE-FIXED <>>
<GLOBAL LOST-TURNS 0>
<GLOBAL WHISTLE-BLOWN <>>

<GLOBAL REVEAL 0>           ;"0 none, 1 screen down, 2 confessed, 3 promised"
<GLOBAL PROPS-SEEN 0>
<GLOBAL GIFTS-GIVEN <>>
<GLOBAL BALLOON-DAY 0>
<GLOBAL BALLOON-GONE <>>
<GLOBAL TREES-CHOPPED <>>
<GLOBAL LADDER-BUILT <>>
<GLOBAL WALL-CLIMBED <>>
<GLOBAL CHINA-CLEAN T>
<GLOBAL LEG-BACK <>>
<GLOBAL PRINCESS-FREED <>>
<GLOBAL CHURCH-BROKE <>>
<GLOBAL SPIDER-DEAD <>>
<GLOBAL HH-TRIED <>>
<GLOBAL GLINDA-TOLD <>>
<GLOBAL CAP-GIVEN <>>
<GLOBAL FAREWELLS 0>
<GLOBAL HEELS-KNOCKED <>>
<GLOBAL STAY-OFFERED <>>
<GLOBAL WON <>>

"Score-once bookkeeping flags."
<GLOBAL SC-TOTO <>> <GLOBAL SC-SHOES <>> <GLOBAL SC-SCARE <>>
<GLOBAL SC-WOOD <>> <GLOBAL SC-BEETLE <>> <GLOBAL SC-LION <>>
<GLOBAL SC-GORGE <>> <GLOBAL SC-BRIDGE <>> <GLOBAL SC-RAFT <>>
<GLOBAL SC-STORK <>> <GLOBAL SC-MICE <>> <GLOBAL SC-HAUL <>>
<GLOBAL SC-SPECS <>> <GLOBAL SC-AUD <>> <GLOBAL SC-FEED <>>
<GLOBAL SC-MELT <>> <GLOBAL SC-SHOE2 <>> <GLOBAL SC-WFIX <>>
<GLOBAL SC-SFIX <>> <GLOBAL SC-CAP <>> <GLOBAL SC-CAP1 <>>
<GLOBAL SC-SCREEN <>> <GLOBAL SC-GIFTS <>> <GLOBAL SC-CAP3 <>>
<GLOBAL SC-CHINA <>> <GLOBAL SC-CROWN <>> <GLOBAL SC-GLINDA <>>
<GLOBAL SC-BYE <>> <GLOBAL SC-HOME <>>

<ROUTINE SCORE-IT (N)
	 <SETG SCORE <+ ,SCORE .N>>
	 <RTRUE>>

"=== Companion presence helpers ==="

"True when the player really said TELL/ASK X ABOUT..., false when this
is the addressing half of an actor command (\"WOODMAN, CHOP TREE\"): the
engine's V-TELL runs the actor's ACTION routine once with VERB? TELL
before it switches WINNER and re-parses the rest, so every companion
conversation clause must exclude that pass or it prints twice."
<ROUTINE TALKING? ()
	 <AND <VERB? TELL HELLO> <NOT ,P-CONT>>>

<ROUTINE HAS-SCARE? ()
	 <AND <==? ,SCARE-STATE 1> <IN? ,SCARECROW ,HERE>>>

<ROUTINE HAS-WOOD? ()
	 <AND <OR <==? ,WOOD-STATE 1> <==? ,WOOD-STATE 3>>
	      <IN? ,WOODMAN ,HERE>>>

<ROUTINE HAS-LION? ()
	 <AND <OR <==? ,LION-STATE 1> <==? ,LION-STATE 4>>
	      <IN? ,LION ,HERE>>>

<ROUTINE PARTY-SIZE ("AUX" (N 0))
	 <COND (<HAS-SCARE?> <SET N <+ .N 1>>)>
	 <COND (<HAS-WOOD?> <SET N <+ .N 1>>)>
	 <COND (<HAS-LION?> <SET N <+ .N 1>>)>
	 .N>

"=== The party demon: follow, then banter ==="

<GLOBAL BARK-ROAD
	<LTABLE 0
"\"What makes you a coward?\" asks the Scarecrow. \"It's a mystery,\" says
the Lion. \"I suppose I was born that way.\""
"The Woodman steps carefully over an ant, and looks proud of it."
"\"If your heads were stuffed with straw like mine,\" says the Scarecrow,
\"you would probably all live in beautiful places, and then Kansas would
have no people at all.\""
"\"Do you think Oz could give me a heart?\" asks the Woodman. \"As easily
as he could give me brains,\" says the Scarecrow, who has never met him."
"The Lion looks behind himself, casually, for the fourth time this
minute."
"\"I shall ask for courage,\" says the Lion. \"You could ask for a smaller
appetite,\" says the Scarecrow, and everyone considers this."
"Toto trots ahead, comes back, and reports nothing, at length."
"\"Brains are the only thing worth having,\" says the Scarecrow. \"I did
not say that,\" says the Woodman. \"No,\" says the Scarecrow, \"you would
not.\"">>

<GLOBAL BARK-GIFT
	<LTABLE 0
"\"With my brains,\" says the Scarecrow, \"I calculate we are going the
right way. Also that this is a road.\""
"The Woodman stops, puts a hand on his tin chest, and listens to it for a
while, entirely satisfied."
"\"I am afraid of nothing,\" announces the Lion. \"Nothing at all. Not
one thing. Shall I list them?\""
"\"Bran-new brains,\" the Scarecrow says, to nobody, happily."
"\"My heart aches a little,\" says the Woodman. \"That is how you know it
is a good one,\" says the Scarecrow.">>

<GLOBAL BARK-GRIEF
	<LTABLE 0
"\"He was the best of us,\" begins the Woodman, and then stops, because
crying rusts his jaws."
"The Lion looks out over the water and says nothing at all."
"You keep expecting a blue hat at the edge of your eye.">>

<GLOBAL BARK-SONG
	<LTABLE 0
"\"Tol-de-ri-de-oh!\" sings the Scarecrow, at every step."
"\"Tol-de-ri-de-oh!\" The Lion has begun to hum along, badly.">>

<GLOBAL BARK-LIMP
	<LTABLE 0
"The Lion limps a little, and pretends he is only being careful."
"\"Does it hurt?\" asks the Woodman. \"Certainly not,\" says the Lion,
limping.">>

<GLOBAL BARK-TOTO
	<LTABLE 0
"Toto chases a butterfly and loses."
"Toto barks at nothing, twice, and looks pleased."
"Toto pushes his nose into your hand."
"Toto sits down suddenly and scratches his ear as though it were work.">>

<ROUTINE I-OZ ("AUX" N)
	 ;"The prologue drives itself from here, and returns early, so it
	  cannot perturb banter timing on the scored path: STORM-PHASE goes
	  to 3 the moment Dorothy is out of the house, and this whole
	  branch is dead for the rest of the game."
	 <COND (<AND <L? ,STORM-PHASE 3> <==? ,HERE ,FARMHOUSE>>
		<PROLOGUE-TICK>
		<RTRUE>)>
	 ;"Follow: move IN-PARTY companions to HERE, silently."
	 <COND (<AND <==? ,SCARE-STATE 1> <NOT <IN? ,SCARECROW ,HERE>>>
		<MOVE ,SCARECROW ,HERE>)>
	 <COND (<AND <OR <==? ,WOOD-STATE 1> <==? ,WOOD-STATE 3>>
		     <NOT <IN? ,WOODMAN ,HERE>>>
		<MOVE ,WOODMAN ,HERE>)>
	 <COND (<AND <OR <==? ,LION-STATE 1> <==? ,LION-STATE 4>>
		     <NOT <IN? ,LION ,HERE>>>
		<MOVE ,LION ,HERE>)>
	 <COND (<AND <G? ,STORM-PHASE 1>
		     <NOT ,TOTO-FELL>
		     <NOT <IN? ,TOTO ,HERE>>
		     <NOT ,TOTO-GONE>>
		<MOVE ,TOTO ,HERE>)>
	 ;"The Scarecrow's reunion song overrides for a few turns."
	 <COND (<G? ,SONG-TURNS 0>
		<SETG SONG-TURNS <- ,SONG-TURNS 1>>
		<COND (<AND <NOT ,SCENE-FLAG> <HAS-SCARE?>>
		       <TELL <PICK-ONE ,BARK-SONG> CR>
		       <RTRUE>)>)>
	 <COND (,SCENE-FLAG <RFALSE>)>
	 ;"Idle banter."
	 <SET N <PARTY-SIZE>>
	 <COND (<AND <G? .N 1> <PROB 16>>
		<TELL <PICK-ONE <COND (,GIFTS-GIVEN ,BARK-GIFT)
				      (<==? ,SCARE-STATE 2> ,BARK-GRIEF)
				      (,LION-HURT ,BARK-LIMP)
				      (T ,BARK-ROAD)>> CR>
		<RTRUE>)
	       (<AND <IN? ,TOTO ,HERE> <PROB 12>>
		<TELL <PICK-ONE ,BARK-TOTO> CR>
		<RTRUE>)>
	 <RFALSE>>

"=== Companion order dispatch =================================
Each companion's ACTION routine runs first in PERFORM when WINNER is that
companion (an addressed command: \"WOODMAN, CHOP TREE\"). Orders route to
exactly the routines the plain verbs use, so both phrasings always work
and the plain verb alone is always sufficient."

<ROUTINE WOODMAN-FCN ()
	 <COND (<==? ,WINNER ,WOODMAN>
		<COND (<==? ,WOOD-STATE 0>
		       <TELL "The Tin Woodman groans through his rusted jaws." CR>
		       <RTRUE>)
		      (<VERB? CHOP>  <DO-CHOP>)
		      (<VERB? BUILD MAKE> <DO-BUILD>)
		      (<VERB? ATTACK SLAP STOP RESCUE>
		       <DO-FIGHT ,PRSO>)
		      (<VERB? SCATTER COVER> <DO-STRAW>)
		      (<VERB? HELLO>
		       <TELL "\"Hello!\" says the Tin Woodman, delighted to be
addressed." CR>
		       <RTRUE>)
		      (<VERB? WAIT FOLLOW>
		       <TELL "\"I will follow you anywhere,\" says the Woodman,
\"and carefully, because of the beetles.\"" CR>
		       <RTRUE>)
		      (T
		       <TELL "\"I would gladly,\" says the Tin Woodman, \"but I
do not see how. Tell me a thing to chop and I am your man.\"" CR>
		       <RTRUE>)>)
	       (<AND <VERB? EXAMINE> <IN? ,WOODMAN ,HERE>>
		<COND (<==? ,WOOD-STATE 0>
		       <TELL "He is made entirely of tin, and rusted stiff: his
jaws will not open, and one arm is stopped in the air with an axe in it." CR>)
		      (<==? ,WOOD-STATE 2>
		       <TELL "He is so battered and dented he can neither move
nor groan. His axe lies beside him, the blade rusted, the handle broken." CR>)
		      (,GIFTS-GIVEN
		       <TELL "Bright tin, polished daily, with a small square
patch on the left of his chest where the silk heart went in." CR>)
		      (T
		       <TELL "A man made entirely of tin, jointed at the neck
and arms and legs, with an axe over his shoulder and no heart in him, he
says, at all." CR>)>
		<RTRUE>)
	       (<AND <VERB? OIL> <IN? ,WOODMAN ,HERE>> <DO-OIL>)
	       (<AND <VERB? KISS HUG> <IN? ,WOODMAN ,HERE>> <DO-FAREWELL ,WOODMAN>)
	       (<AND <VERB? TAKE> <IN? ,WOODMAN ,HERE>>
		<TELL "He weighs as much as a stove." CR>
		<RTRUE>)
	       (<AND <TALKING?> <IN? ,WOODMAN ,HERE>>
		<COND (<==? ,WOOD-STATE 0>
		       <TELL "He can only groan. Then, with an effort that
sounds expensive, one word: \"Oil... can...\"" CR>)
		      (T
		       <TELL "\"I do not mind the walking,\" says the Tin
Woodman. \"I mind the rain.\"" CR>)>
		<RTRUE>)>>

<ROUTINE SCARECROW-FCN ()
	 <COND (<==? ,WINNER ,SCARECROW>
		<COND (<VERB? SCARE LIE-DOWN> <DO-SCARE-CROWS>)
		      (<VERB? SCATTER COVER TAKE> <DO-STRAW>)
		      (<VERB? CHOP>
		       <TELL "\"I have no arms to speak of,\" says the
Scarecrow. \"Ask the one with the axe.\"" CR>
		       <RTRUE>)
		      (<VERB? HELLO>
		       <TELL "\"Good day,\" says the Scarecrow, and bows so far
he has to be straightened." CR>
		       <RTRUE>)
		      (T
		       <TELL "\"Let me think,\" says the Scarecrow, and thinks
so hard that pins show at the seams. \"No. But it was a good idea, which
proves I have no brains, because a man with brains would have had a
better one.\"" CR>
		       <RTRUE>)>)
	       (<AND <VERB? EXAMINE> <IN? ,SCARECROW ,HERE>>
		<COND (,GIFTS-GIVEN
		       <TELL "A suit of faded blue stuffed with straw, a
painted face, and a head that bulges a good deal at the top, with pins
and needles showing through." CR>)
		      (T
		       <TELL "A small man of straw in faded blue, with a
painted face and a pointed blue hat, and eyes that watch you with
enormous interest." CR>)>
		<RTRUE>)
	       (<AND <VERB? TAKE RAISE MOVE THROUGH> <==? ,SCARE-STATE 0>>
		<SCARE-RECRUIT>)
	       (<AND <VERB? KISS HUG> <IN? ,SCARECROW ,HERE>> <DO-FAREWELL ,SCARECROW>)
	       (<AND <TALKING?> <IN? ,SCARECROW ,HERE>>
		<TELL "\"I do not mind my legs and arms and body being
stuffed,\" says the Scarecrow, \"because I cannot get hurt. But I do not
want people to call me a fool.\"" CR>
		<RTRUE>)
	       (<AND <VERB? STUFF PUT> <IN? ,SCARECROW ,HERE>> <DO-STUFF>)>>

<ROUTINE LION-FCN ()
	 <COND (<==? ,WINNER ,LION>
		<COND (<VERB? ROAR YELL> <DO-ROAR>)
		      (<VERB? LEAP RIDE CLIMB-ON BOARD> <DO-LEAP>)
		      (<VERB? ATTACK> <DO-FIGHT ,PRSO>)
		      (<VERB? HELLO>
		       <TELL "\"Hello,\" says the Lion, in a very small voice
for so large an animal." CR>
		       <RTRUE>)
		      (T
		       <TELL "\"I would,\" says the Lion, \"but I don't see
how, and I'm frightened besides.\"" CR>
		       <RTRUE>)>)
	       (<AND <VERB? EXAMINE> <IN? ,LION ,HERE>>
		<COND (<==? ,LION-STATE 4>
		       <TELL "An enormous lion with a gold-and-green crown
slightly askew, trying very hard to look as though he has always had
one." CR>)
		      (<==? ,LION-STATE 2>
		       <TELL "He lies among the poppies, fast asleep, breathing
slow and deep, and much too heavy to carry." CR>)
		      (T
		       <TELL "A lion as big as a small horse, with a mane like
a haystack and the anxious eyes of somebody who expects to be asked
something difficult." CR>)>
		<RTRUE>)
	       (<AND <VERB? SLAP ATTACK> <IN? ,LION ,HERE>> <DO-SLAP>)
	       (<AND <VERB? RIDE CLIMB-ON BOARD LEAP> <IN? ,LION ,HERE>> <DO-LEAP>)
	       (<AND <VERB? KISS HUG> <IN? ,LION ,HERE>> <DO-FAREWELL ,LION>)
	       (<AND <VERB? GIVE> <IN? ,LION ,HERE>> <DO-FEED>)
	       (<AND <TALKING?> <IN? ,LION ,HERE>>
		<TELL "\"Everything is frightening,\" the Lion explains. \"But
I go on anyway, which people keep telling me is the same thing as being
brave. I don't see it.\"" CR>
		<RTRUE>)>>

<ROUTINE TOTO-FCN ()
	 <COND (<==? ,WINNER ,TOTO>
		<TELL "Toto only wags his tail; for, strange to say, he cannot
speak." CR>
		<RTRUE>)
	       ;"Bare TALK TO TOTO would otherwise reach the engine's
		hardcoded \"The \" D ,PRSO \" pauses for a moment...\", which
		reads \"The Toto\". Proper names must intercept it."
	       (<TALKING?>
		<TELL "Toto only wags his tail; for, strange to say, he cannot
speak." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL "A little black dog with long silky hair and small black
eyes that twinkle merrily on either side of his funny wee nose. He is
black as a boot button, and that is the sort of dog he is." CR>
		<RTRUE>)
	       (<VERB? RUB>
		<TELL "Toto leans his whole weight into your hand, which for
Toto is a considerable statement." CR>
		<RTRUE>)
	       (<VERB? KISS HUG>
		<TELL "You gather up the small warm dog. He licks your chin
once, briskly, as though signing a receipt." CR>
		<RTRUE>)
	       (<AND <VERB? GIVE> <EQUAL? ,PRSI ,TOTO>>
		<TELL "Toto takes it with enormous seriousness and eats it in
two bites." CR>
		<RTRUE>)
	       (<AND <VERB? TAKE> <==? ,STORM-PHASE 0> <NOT <IN? ,TOTO ,WINNER>>>
		<DO-GRAB-TOTO>)
	       (<AND <VERB? TAKE MOVE RAISE> ,TOTO-FELL>
		<DO-TOTO-RESCUE>)
	       (<VERB? TAKE>
		<COND (<IN? ,TOTO ,WINNER>
		       <TELL "You already have him, and he is squirming." CR>)
		      (T
		       <MOVE ,TOTO ,WINNER>
		       <TELL "You pick Toto up. He permits it." CR>)>
		<RTRUE>)
	       (<VERB? DROP>
		<MOVE ,TOTO ,HERE>
		<TELL "Toto lands neatly and shakes himself." CR>
		<RTRUE>)>>

"=== Shared solution routines (both phrasings land here) ==="

<ROUTINE DO-CHOP ()
	 <COND (<AND <==? ,HERE ,BRAMBLE-ROAD> <NOT ,BRAMBLE-OPEN>>
		<COND (<HAS-WOOD?> <CHOP-BRAMBLES>)
		      (T <NO-AXE>)>)
	       (<==? ,HERE ,SECOND-GORGE> <SGORGE-CHOP>)
	       (<AND <==? ,HERE ,TALL-TREE> <NOT ,SCARE-FIXED>>
		<COND (<AND <HAS-WOOD?> <==? ,WOOD-STATE 3>> <TALL-TREE-CHOP>)
		      (T
		       <TELL "The trunk is too smooth to climb, and the only
axe in this country is lying on a rocky plain, in no state to chop
anything." CR>
		       <RTRUE>)>)
	       (<AND <==? ,HERE ,FIGHTING-TREES> <NOT ,TREES-CHOPPED>>
		<COND (<HAS-WOOD?> <FTREES-CHOP>)
		      (T <NO-AXE>)>)
	       (<AND <==? ,HERE ,RIVERBANK> <NOT ,RAFT-BUILT>>
		<DO-BUILD>)
	       (<AND <==? ,HERE ,CHINA-WALL> <NOT ,LADDER-BUILT>>
		<DO-BUILD>)
	       (<HAS-WOOD?>
		<TELL "\"There is nothing here that wants chopping,\" says the
Tin Woodman, a little sadly." CR>
		<RTRUE>)
	       (T <NO-AXE>)>>

<ROUTINE NO-AXE ()
	 <TELL "If only you had an axe, and arms like tin barrels to swing
it." CR>
	 <RTRUE>>

<ROUTINE DO-BUILD ()
	 <COND (<AND <==? ,HERE ,RIVERBANK> <NOT ,RAFT-BUILT>>
		<COND (<HAS-WOOD?> <BUILD-RAFT>)
		      (T
		       <TELL "You could not cut and bind a raft with your
hands. Somebody with an axe could." CR>
		       <RTRUE>)>)
	       (<AND <==? ,HERE ,CHINA-WALL> <NOT ,LADDER-BUILT>>
		<COND (<HAS-WOOD?> <BUILD-LADDER>)
		      (T
		       <TELL "A ladder would want wood, and cutting, and
somebody tireless to do it." CR>
		       <RTRUE>)>)
	       (T
		<TELL "There is nothing here to build, and nothing here that
needs building." CR>
		<RTRUE>)>>

<ROUTINE DO-ROAR ()
	 <COND (<AND <==? ,WAVE 4> <==? ,HERE ,WEST-HILLS>> <WAVE4-WIN>)
	       (<AND <==? ,HERE ,THRONE-ROOM> <==? ,REVEAL 0> <G? ,AUDIENCE 3>>
		<SCREEN-FALLS T>)
	       (<HAS-LION?>
		<TELL "The Lion opens his mouth and roars, and the noise goes
away over the country and comes back smaller. Then he looks around to
see whether anyone minded." CR>
		<RTRUE>)
	       (T
		<TELL "You roar. It is a creditable roar, for your size, and
nothing whatever is frightened by it." CR>
		<RTRUE>)>>

<ROUTINE DO-LEAP ()
	 <COND (<AND <==? ,HERE ,GORGE-EDGE> <NOT ,GORGE-CROSSED>>
		<COND (<HAS-LION?>
		       <GORGE-CROSS>
		       <MOVE ,WINNER ,KALIDAH-WOOD>
		       <SETG HERE ,KALIDAH-WOOD>
		       <V-LOOK>
		       <RTRUE>)
		      (T
		       <TELL "The gorge is far too wide to jump and too steep
to climb." CR>
		       <RTRUE>)>)
	       (<AND <==? ,HERE ,CHINA-COUNTRY> ,WALL-CLIMBED>
		<COND (<HAS-LION?> <CHINA-EXIT>)
		      (T
		       <TELL "The far wall is lower, but still higher than
you." CR>
		       <RTRUE>)>)
	       (<HAS-LION?>
		<TELL "\"Where?\" says the Lion, looking around with real
alarm. There is nothing here worth leaping." CR>
		<RTRUE>)
	       (T
		<TELL "There is nothing here to leap." CR>
		<RTRUE>)>>

<ROUTINE DO-FIGHT (WHO)
	 <COND (<==? .WHO ,WILDCAT> <KILL-WILDCAT>)
	       (<==? .WHO ,WOLVES> <WAVE1-WIN>)
	       (<==? .WHO ,CROWS> <DO-SCARE-CROWS>)
	       (<==? .WHO ,BEES> <DO-STRAW>)
	       (<==? .WHO ,SPIDER> <KILL-SPIDER>)
	       (<==? .WHO ,WITCH-WEST>
		<TELL "She is twice your reach, and anyway you were raised
polite. The Witch laughs at you and does not even step back." CR>
		<RTRUE>)
	       (<==? .WHO ,LION> <DO-SLAP>)
	       (T <RFALSE>)>>

<ROUTINE DO-OIL ()
	 <COND (<AND <==? ,HERE ,SPRING-GLADE> <==? ,WOOD-STATE 0>>
		<OIL-WOODMAN>)
	       (<==? ,BEETLE-STATE 1> <OIL-JAWS>)
	       (<NOT <IN? ,OIL-CAN ,WINNER>>
		<TELL "You haven't anything to oil him with. There must be a
can about somewhere; he clearly kept himself tidy, before the rain." CR>
		<RTRUE>)
	       (T
		<TELL "You give the Tin Woodman a drop or two where he likes
it best, and he works the joint gratefully." CR>
		<RTRUE>)>>

<ROUTINE DO-SLAP ()
	 <COND (<AND <==? ,HERE ,DEEP-FOREST> <==? ,LION-STATE 0>>
		<LION-RECRUIT>)
	       (<HAS-LION?>
		<TELL "You would not, and he knows it, and the knowledge
plainly comforts him." CR>
		<RTRUE>)
	       (T
		<TELL "Violence is not the answer to this one." CR>
		<RTRUE>)>>

"=== Engine-required content stubs ==="

<ROUTINE V-SCORE ("OPTIONAL" (ASK? T))
	 <TELL "Your score is " N ,SCORE " of a possible 250, in " N ,MOVES
	       " move">
	 <COND (<NOT <==? ,MOVES 1>> <TELL "s">)>
	 <TELL "." CR "This gives you the rank of ">
	 <COND (<G? ,SCORE 249> <TELL "Honorary Sorceress">)
	       (<G? ,SCORE 219> <TELL "Wearer of the Golden Cap">)
	       (<G? ,SCORE 179> <TELL "Royal Guest of Oz">)
	       (<G? ,SCORE 139> <TELL "Slayer of Nothing, Melter of One">)
	       (<G? ,SCORE 89> <TELL "Companion of the Road">)
	       (<G? ,SCORE 39> <TELL "Friend of Scarecrows">)
	       (T <TELL "Munchkin Tourist">)>
	 <TELL "." CR>
	 <COND (,CHURCH-BROKE
		<TELL "(Includes: china church, one (1), minus one point.)" CR>)>
	 ,SCORE>

<ROUTINE V-DIAGNOSE ()
	 <TELL "You are a small, sensible person in good health, a long way
from home." CR>>

<ROUTINE JIGS-UP (DESC "OPTIONAL" (PLAYER? <>))
	 <TELL .DESC CR CR>
	 <TELL "    ****  You have died  ****" CR CR>
	 <TELL "Which is a shame, because everybody in this country was
trying so hard to keep you safe. Aunt Em would like a word." CR CR>
	 <V-SCORE>
	 <QUIT>>

<ROUTINE FIND-WEAPON (WHO)
	 <RFALSE>>

<ROUTINE WATER-FCN ()
	 <COND (<AND <VERB? THROW POUR-ON PUT> <IN? ,WITCH-WEST ,HERE>>
		<MELT-WITCH>)
	       (<VERB? TAKE>
		<COND (<IN? ,BUCKET ,HERE>
		       <TELL "Water is easier to carry in the bucket it is
already in." CR>)
		      (T <TELL "There is no water here to take." CR>)>
		<RTRUE>)
	       (<VERB? DRINK>
		<TELL "Cold and clean, and it tastes of iron and well-rope." CR>
		<RTRUE>)>>

<ROUTINE WALL-FCN ()
	 <COND (<AND <==? ,HERE ,CHINA-WALL> <VERB? CLIMB-FOO CLIMB-UP>>
		<CWALL-CLIMB>)
	       (<VERB? EXAMINE>
		<TELL "A wall. It does what walls do." CR>
		<RTRUE>)>>

"=== The intro ==="

<ROUTINE INTRO-TEXT ()
	 <TELL
"Dorothy lived in the middle of the great Kansas prairie, in a one-room
house with Uncle Henry, who never laughed, and Aunt Em, who never smiled,
and Toto, who was a small black dog and did enough of both for everybody.
When the sun and the wind had made everything else gray, the grass, the
house, even Aunt Em, Toto stayed black as a boot button, and that is the
sort of dog he was." CR CR>
	 <TELL
"Today nobody is laughing. The sky is grayer than usual, and from the
north comes a low wail of wind, and from the south a sharp whistling, and
Uncle Henry stands up very fast and says, \"There's a cyclone coming,
Em,\" and runs for the cows. Aunt Em throws open the trap door in the
floor and is gone down the ladder into the dark, calling one thing behind
her: \"Quick, Dorothy! Run for the cellar!\"" CR CR>
	 <TELL "But Toto has just gone under the bed." CR CR>
	 <TELL "THE SILVER SHOES" CR>
	 <TELL "An interactive wonder tale, from the book by L. Frank Baum." CR>
	 <TELL "(Type HELP at any time. Aunt Em would want you to.)" CR CR>>

"=== ACT I: the farmhouse ==="

<ROUTINE FARMHOUSE-FCN (RARG)
	 <COND (<==? .RARG ,M-LOOK>
		<COND (<==? ,STORM-PHASE 0>
		       <TELL
"One gray room holds the whole house: a rusty cookstove, a cupboard, a
table, and two beds, with a trap door to the cyclone cellar standing open
in the middle of the floor. Through the doorway the prairie runs flat and
gray to the edge of the sky, and the grass is bending all one way." CR>)
		      (<==? ,STORM-PHASE 1>
		       <TELL
"The little room tilts and steadies. Out the window there is nothing but
gray cloud going by, very fast, and no ground at all." CR>)
		      (T
		       <TELL
"The house has come to rest, tilted and whole. Through the doorway, in
place of the gray prairie, there is a green so bright it looks
unreasonable." CR>)>
		<RTRUE>)
	       (<==? .RARG ,M-BEG>
		<COND (<AND <==? ,STORM-PHASE 1> <VERB? WALK> ,TOTO-FELL>
		       <RFALSE>)>
		<RFALSE>)>>

<ROUTINE FARM-BED-FCN ()
	 <COND (<VERB? LOOK-UNDER EXAMINE SEARCH>
		<COND (<AND <L? ,STORM-PHASE 2> <IN? ,TOTO ,FARMHOUSE>>
		       <TELL "Toto is under the bed, pressed flat, with his
ears down and his eyes very round." CR>)
		      (T <TELL "A plain bed. Aunt Em made it this morning." CR>)>
		<RTRUE>)>>

<ROUTINE DO-GRAB-TOTO ()
	 <MOVE ,TOTO ,WINNER>
	 <SETG TOTO-SAVED <BOR ,TOTO-SAVED 1>>
	 <TELL
"You dive for the bed and get hold of Toto, and start for the trap door
with him kicking in your arms." CR>
	 <START-CYCLONE>
	 <RTRUE>>

<ROUTINE START-CYCLONE ()
	 <SETG STORM-PHASE 1>
	 <SETG SCENE-FLAG T>
	 <TELL CR
"Then the house shakes hard, twice, and there is a great shriek from the
wind, and the floor tips. The house whirls around two or three times and
rises slowly through the air, like a balloon." CR CR
"This is the strangest thing that has ever happened to you. You decide,
sensibly, to wait and see what happens next." CR>
	 <FSET ,TRAP-DOOR ,OPENBIT>
	 <SETG FLIGHT-TURNS 0>
	 <RTRUE>>

"=== The prologue clock ======================================
Baum's cyclone is not optional: Uncle Henry sees it coming, Aunt Em goes
down the ladder, and the house goes up with Dorothy still in it. So the
storm arrives on its own schedule whatever the player does, and
exhaustion eventually puts her on the bed, exactly as in the book
(\"she lay down upon her bed\").

The scored sequence is untouched and still the best one: GET TOTO starts
the cyclone early and scores nothing by itself; CLOSE TRAP DOOR on the
hanging-Toto beat is worth 5. A player who does both sees no nudges at
all, because every nudge below is gated on the player NOT having acted.

Driven from the permanent I-OZ demon rather than a self-requeueing
QUEUE. Both work (see LESSONS.md 3.7), but one counter with no guard
clause above it cannot develop an unreachable branch, which is the bug
class that stranded players here in the first place."

<GLOBAL KANSAS-TURNS 0>
<GLOBAL FLIGHT-TURNS 0>

<GLOBAL LANDED-TURNS 0>

<ROUTINE PROLOGUE-TICK ()
	 <COND (<==? ,STORM-PHASE 0> <KANSAS-TICK>)
	       (<==? ,STORM-PHASE 1> <FLIGHT-TICK>)
	       (T <LANDED-TICK>)>>

"After the landing, Toto is at the door barking to be let out and there
is a green country outside. A player who does not think of OUT gets
Toto's opinion, then Toto's decision."

<ROUTINE LANDED-TICK ()
	 <SETG LANDED-TURNS <+ ,LANDED-TURNS 1>>
	 <COND (<==? ,LANDED-TURNS 2>
		<TELL CR
"Toto scratches at the door and looks back at you over his shoulder." CR>
		<RTRUE>)
	       (<==? ,LANDED-TURNS 4>
		<TELL CR
"Through the doorway the light is a green you have no word for, and Toto
is barking at it steadily." CR>
		<RTRUE>)
	       (<G? ,LANDED-TURNS 5>
		<TELL CR
"Toto gets the door open with his nose and is gone into the green, and
of course you go after him." CR CR>
		<MOVE ,WINNER ,CLEARING>
		<SETG HERE ,CLEARING>
		<SETG STORM-PHASE 3>
		<V-LOOK>
		<RTRUE>)>
	 <RFALSE>>

<ROUTINE KANSAS-TICK ()
	 <SETG KANSAS-TURNS <+ ,KANSAS-TURNS 1>>
	 <COND (<==? ,KANSAS-TURNS 2>
		<TELL CR
"Away to the north the wind gives a long low wail, and the grass bends
flat in a wave that runs all the way to the edge of the sky." CR>
		<RTRUE>)
	       (<==? ,KANSAS-TURNS 3>
		<TELL CR
"\"Dorothy!\" comes Aunt Em's voice, small and far down under the floor.
\"Run for the cellar!\" Toto has not come out from under the bed." CR>
		<RTRUE>)
	       (<==? ,KANSAS-TURNS 4>
		<TELL CR
"The whistling from the south is very loud now, and the house shakes so
hard it is difficult to stand." CR>
		<RTRUE>)
	       (<G? ,KANSAS-TURNS 5>
		;"The storm does not wait to be invited."
		<COND (<IN? ,TOTO ,FARMHOUSE>
		       <TELL CR
"You make a grab for Toto and he bolts, and you go after him under the
bed, and that is where you both are when it happens." CR>
		       <MOVE ,TOTO ,WINNER>)>
		<START-CYCLONE>
		<RTRUE>)>
	 <RFALSE>>

<ROUTINE FLIGHT-TICK ()
	 <SETG FLIGHT-TURNS <+ ,FLIGHT-TURNS 1>>
	 ;"Beat 1: Toto goes through the open trap door. Only possible if
	  the player is holding him and has not shut it."
	 <COND (<AND <==? ,FLIGHT-TURNS 2>
		     <IN? ,TOTO ,WINNER>
		     <FSET? ,TRAP-DOOR ,OPENBIT>>
		<SETG TOTO-FELL T>
		<MOVE ,TOTO ,FARMHOUSE>
		<TELL CR
"Toto wriggles loose, runs the wrong way entirely, and drops straight
through the open trap door. Then, because the air pressure in a cyclone
is a strange thing, he does not fall: he hangs there in the hole with his
ears streaming, looking up at you, very surprised." CR>
		<RTRUE>)
	       (<AND <==? ,FLIGHT-TURNS 2> <IN? ,TOTO ,FARMHOUSE>>
		<TELL CR
"Toto creeps out from under the bed, thinks the whole business over, and
sits down beside you with his chin on your shoe." CR>
		<MOVE ,TOTO ,WINNER>
		<RTRUE>)>
	 ;"Toto hangs there until somebody gets him. After a few turns the
	  game does it for you: he is never lost, only unscored."
	 <COND (<AND ,TOTO-FELL <G? ,FLIGHT-TURNS 5>>
		<SETG TOTO-FELL <>>
		<MOVE ,TOTO ,WINNER>
		<TELL CR
"You cannot leave him hanging there. You crawl to the hole and get Toto
by the ear and haul him back in, and you both sit down hard on the
floor. Nothing about this seems to worry him." CR>
		<RTRUE>)>
	 ;"Nudges toward the trap door, then sleep, then sleep regardless."
	 <COND (<AND <==? ,FLIGHT-TURNS 4> <FSET? ,TRAP-DOOR ,OPENBIT>>
		<TELL CR
"The open trap door whistles horribly, and the wind comes up through it
cold enough to hurt." CR>
		<RTRUE>)
	       (<==? ,FLIGHT-TURNS 6>
		<TELL CR
"Hour after hour, and nothing to see but gray cloud. Toto is asleep. The
bed is right there, and you are more tired than you have ever been." CR>
		<RTRUE>)
	       (<==? ,FLIGHT-TURNS 8>
		<TELL CR
"Your eyes keep closing by themselves." CR>
		<RTRUE>)
	       (<G? ,FLIGHT-TURNS 9>
		;"Book-true: she lay down upon her bed and fell asleep."
		<LAND-HOUSE>
		<RTRUE>)>
	 <RFALSE>>

<ROUTINE DO-TOTO-RESCUE ()
	 <SETG TOTO-FELL <>>
	 <MOVE ,TOTO ,WINNER>
	 <SETG TOTO-SAVED <BOR ,TOTO-SAVED 2>>
	 <TELL
"You lie flat and reach down and get Toto by the ear, and haul him up out
of the hole and into your arms. He is delighted with himself." CR>
	 <RTRUE>>

<ROUTINE TRAP-DOOR-FCN ()
	 <COND (<VERB? CLOSE>
		<COND (<AND <==? ,STORM-PHASE 1> ,TOTO-FELL>
		       <TELL "Not with Toto hanging in it!" CR>)
		      (<FSET? ,TRAP-DOOR ,OPENBIT>
		       <FCLEAR ,TRAP-DOOR ,OPENBIT>
		       <COND (<AND <==? ,STORM-PHASE 1>
				   <NOT <BTST ,TOTO-SAVED 4>>>
			      <SETG TOTO-SAVED <BOR ,TOTO-SAVED 4>>
			      <COND (<NOT ,SC-TOTO>
				     <SETG SC-TOTO T>
				     <SCORE-IT 5>)>
			      <TELL "You get the trap door shut, and the awful
whistling under the floor stops. Toto approves of this and licks your
chin." CR>)
			     (T <TELL "The trap door thuds shut." CR>)>)
		      (T <TELL "It is already closed." CR>)>
		<RTRUE>)
	       (<VERB? OPEN>
		<FSET ,TRAP-DOOR ,OPENBIT>
		<TELL "You lift the ring and the trap door comes up. There is
nothing under it now but a hole and a great deal of wind." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL "A square trap door with an iron ring, standing "
		      <COND (<FSET? ,TRAP-DOOR ,OPENBIT> "open") (T "closed")>
		      "." CR>
		<RTRUE>)>>

<ROUTINE CELLAR-EXIT ()
	 <COND (<==? ,STORM-PHASE 0>
		<TELL "You reach for the ring just as the whole house shudders
and tips you off your feet." CR>
		<START-CYCLONE>
		<RFALSE>)
	       (<==? ,STORM-PHASE 1>
		<TELL "There is nothing below the trap door now except a great
deal of Kansas, going past." CR>
		<RFALSE>)
	       (T
		<TELL "The cellar is somewhere under a green lawn in another
country, and full of somebody else's problems." CR>
		<RFALSE>)>>

<ROUTINE FARMHOUSE-OUT ()
	 <COND (<==? ,STORM-PHASE 0>
		<TELL "The wind would take you off your feet before you got
ten steps." CR>
		<RFALSE>)
	       (<==? ,STORM-PHASE 1>
		<TELL "Out of a flying house? Certainly not." CR>
		<RFALSE>)
	       (T <SETG STORM-PHASE 3> ,CLEARING)>>

<ROUTINE V-SLEEP ()
	 <COND (<AND <==? ,HERE ,FARMHOUSE> <==? ,STORM-PHASE 1>>
		<LAND-HOUSE>)
	       (<==? ,HERE ,GREEN-CHAMBER> <PALACE-NIGHT>)
	       (<==? ,HERE ,GARRET> <CASTLE-NIGHT>)
	       (<==? ,HERE ,WOODMAN-COTTAGE>
		<TELL "You curl up on the bed of leaves and sleep till the sun
comes through the branches. The Woodman stood in the doorway all night
so as not to creak." CR>
		<RTRUE>)
	       (T
		<TELL "You are not sleepy yet, and there is no bed here that
would take the suggestion kindly." CR>
		<RTRUE>)>>

<ROUTINE LAND-HOUSE ()
	 <SETG STORM-PHASE 2>
	 <SETG SCENE-FLAG <>>
	 <MOVE ,TOTO ,FARMHOUSE>
	 <TELL
"Hours of it, and the howling, and the rocking, and at last you give up
being frightened and go to sleep on the bed with Toto in your arms." CR CR
"A shock wakes you: the house has come down with a thump, on ground, in
sunlight. Toto is at the door barking to be let out." CR>
	 <RTRUE>>

<ROUTINE KANSAS-CUPBOARD-FCN ()
	 <COND (<VERB? OPEN>
		<FSET ,KANSAS-CUPBOARD ,OPENBIT>
		<TELL "The cupboard holds a loaf of bread and not much else." CR>
		<RTRUE>)
	       (<VERB? EXAMINE SEARCH LOOK-INSIDE>
		<TELL "A plain cupboard with a loaf of bread in it." CR>
		<RTRUE>)>>

<ROUTINE BREAD-FCN ()
	 <COND (<VERB? EAT>
		<TELL "You eat some of the bread. It is Aunt Em's, and it
tastes like home, which is a complicated thing to eat." CR>
		<RTRUE>)>>

<ROUTINE BASKET-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "A little covered basket, the sort you carry a picnic in,
or a country's worth of trouble." CR>
		<RTRUE>)>>

<ROUTINE COOKSTOVE-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "Aunt Em's furniture: rusty, scrubbed, and gray. It has
never once been interesting until today." CR>
		<RTRUE>)>>

"=== The clearing: shoes, kiss, the Witch of the North ==="

<ROUTINE CLEARING-FCN (RARG)
	 <COND (<==? .RARG ,M-ENTER>
		<COND (<NOT ,WITCH-N-GONE>
		       <MOVE ,WITCH-NORTH ,CLEARING>
		       <MOVE ,MUNCHKINS ,CLEARING>
		       <MOVE ,DEAD-FEET ,CLEARING>
		       <SETG FEET-TURNS 1>
		       <TELL CR
"Three little men in blue and a little old woman in white are waiting for
you, and they bow very low. \"You are welcome, most noble Sorceress, to
the land of the Munchkins,\" says the old woman. \"You have killed the
Wicked Witch of the East, and set our people free.\"" CR CR
"She points. From under one corner of the house, two feet in silver shoes
are sticking out." CR>
		       <ENABLE <QUEUE I-FEET 2>>)>
		<RFALSE>)>>

<ROUTINE I-FEET ()
	 <SETG FEET-TURNS 2>
	 <REMOVE ,DEAD-FEET>
	 <MOVE ,SILVER-SHOES ,CLEARING>
	 <TELL CR
"\"She was so old,\" says the Witch of the North comfortably, \"that she
dried up quickly in the sun.\" And so she has: the feet are gone, and
where they were, on the grass, sit the silver shoes." CR>
	 <RTRUE>>

<ROUTINE DEAD-FEET-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "Two feet in silver shoes with pointed toes, sticking out
from under a corner of the house. Nobody seems upset about it." CR>
		<RTRUE>)
	       (<VERB? TAKE>
		<TELL "Give them a moment. They are drying up in the sun." CR>
		<RTRUE>)>>

<ROUTINE SILVER-SHOES-FCN ()
	 <COND (<AND <VERB? TAKE> <NOT <IN? ,SILVER-SHOES ,WINNER>>>
		<MOVE ,SILVER-SHOES ,WINNER>
		<TELL "You pick up the silver shoes. They are lighter than
they look, and the toes turn up." CR>
		<RTRUE>)
	       (<VERB? WEAR>
		<COND (,SHOES-WORN
		       <TELL "You are wearing them already." CR>)
		      (T
		       <COND (<NOT <IN? ,SILVER-SHOES ,WINNER>>
			      <MOVE ,SILVER-SHOES ,WINNER>)>
		       <SETG SHOES-WORN T>
		       <COND (<NOT ,SC-SHOES> <SETG SC-SHOES T> <SCORE-IT 5>)>
		       <TELL "You put your old worn-out shoes in the basket and
the silver ones on your feet. They fit exactly, as if they had been
waiting." CR>
		       <COND (<AND <==? ,HERE ,CLEARING> <NOT ,WITCH-N-GONE>>
			      <WITCH-N-BLESSING>)>)>
		<RTRUE>)
	       (<VERB? MUMBLE>
		<COND (,SHOES-WORN
		       <TELL "You have walked a long way in these and you are
not taking them off in a strange country." CR>)
		      (T <RFALSE>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL "Silver shoes with pointed toes. They shine as though
somebody polishes them at night, and they have never once pinched." CR>
		<RTRUE>)
	       (<AND <VERB? KNOCK-HEELS> ,SHOES-WORN> <DO-HEELS>)>>

<ROUTINE WITCH-N-BLESSING ()
	 <SETG WITCH-N-GONE T>
	 <SETG SCENE-FLAG <>>
	 <TELL CR
"The Witch of the North comes and kisses you gently on the forehead, and
where her lips touch there is a round shining mark. \"No one will dare
injure a person who has been kissed by the Witch of the North,\" she
says." CR CR
"\"The road to the City of Emeralds is paved with yellow brick,\" she
tells you, \"and you cannot miss it. When you get to Oz, do not be
afraid of him, but tell him your story and ask him to help you.\" Then
she turns about on her left heel three times and is gone, and the three
Munchkins bow to the ground and walk off among the trees." CR>
	 <REMOVE ,WITCH-NORTH>
	 <REMOVE ,MUNCHKINS>
	 <RTRUE>>

<ROUTINE WITCH-NORTH-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "A little old woman in a white gown, with a pointed hat
and small stars that tinkle on it. Her face is covered with wrinkles and
she walks rather stiffly, which she does not seem to mind." CR>
		<RTRUE>)
	       (<VERB? TELL HELLO>
		<TELL "\"The Wicked Witch of the East is dead,\" she says
patiently, \"and those are her silver shoes, and there is some charm
connected with them, though we never knew what. Take them, my dear; you
will want stout shoes.\"" CR>
		<RTRUE>)>>

<ROUTINE MUNCHKINS-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "Three little men, no taller than you, in round blue hats
with tinkling bells, blue clothes, and well-polished boots." CR>
		<RTRUE>)
	       (<VERB? TELL HELLO>
		<TELL "\"Most noble Sorceress,\" they say together, and bow, and
cannot be got to say anything else." CR>
		<RTRUE>)>>

<ROUTINE BROOK-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "A little brook rushing and sparkling along between green
banks, murmuring in a way that sounds very grateful to a girl who has
lived among the gray prairies." CR>
		<RTRUE>)
	       (<VERB? DRINK>
		<TELL "Cold and sweet and faintly of moss." CR>
		<RTRUE>)>>

<ROUTINE CLEARING-WEST ()
	 <COND (,SHOES-WORN ,YELLOW-ROAD)
	       (<AND <IN? ,SILVER-SHOES ,CLEARING> <L? ,SHOE-NAG 1>>
		<SETG SHOE-NAG 1>
		<TELL "Toto plants himself by the silver shoes and will not
budge." CR>
		<RFALSE>)
	       (<==? ,FEET-TURNS 1>
		<TELL "\"Wait a moment, my dear,\" says the Witch of the North.
\"There is something here for you.\"" CR>
		<RFALSE>)
	       (T
		<TELL "\"You will want stout shoes, my dear,\" the Witch of the
North calls after you. \"Those silver ones cannot wear out.\"" CR>
		,YELLOW-ROAD)>>

"=== Road and Boq ==="

<ROUTINE YELLOW-ROAD-FCN (RARG)
	 <COND (<==? .RARG ,M-ENTER>
		<COND (<AND <NOT ,WITCH-N-GONE> ,SHOES-WORN>)>
		<RFALSE>)>>

<ROUTINE ROAD-LG-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "Bricks of yellow, laid close and even. Wherever it goes,
it goes there on purpose." CR>
		<RTRUE>)
	       (<VERB? FOLLOW WALK-TO>
		<TELL "The road runs west. Walking is the way to follow it." CR>
		<RTRUE>)>>

<ROUTINE TREES-LG-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "Great trees, close together, with their branches meeting
overhead." CR>
		<RTRUE>)
	       (<VERB? CHOP> <DO-CHOP>)
	       (<VERB? CLIMB-FOO CLIMB-UP>
		<TELL "You are a sensible person and there is nothing up
there." CR>
		<RTRUE>)>>

<ROUTINE BOQ-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "A rich Munchkin in a blue coat, standing at his gate,
staring at your silver shoes with the frankest possible admiration." CR>
		<RTRUE>)
	       (<VERB? TELL HELLO>
		<TELL "\"You must be a great sorceress,\" says Boq, \"because
you wear silver shoes and have killed a witch, and there is white in your
frock, and only witches and sorceresses wear white.\" He points west.
\"It is a long journey to the City of Emeralds, and some of it is dark;
but Oz will help you, if anybody can.\"" CR>
		<RTRUE>)>>

"=== The Scarecrow ==="

<ROUTINE CORNFIELD-FCN (RARG)
	 <COND (<AND <==? .RARG ,M-ENTER> <==? ,SCARE-STATE 0>>
		<TELL CR
"In the middle of the field a scarecrow in a pointed blue hat hangs on a
pole, above the corn. And, unless the sun is playing tricks, it has just
winked at you." CR>
		<RFALSE>)>>

<ROUTINE SCARECROW-DESCFCN (ARG)
	 <COND (<==? .ARG ,M-OBJDESC>
		<COND (<==? ,SCARE-STATE 0>
		       <TELL "A scarecrow hangs on a pole above the corn, in
faded blue and a pointed hat." CR>)
		      (<==? ,SCARE-STATE 3>
		       <TELL "The Scarecrow's empty clothes lie here in a
bundle." CR>)
		      (T <TELL "The Scarecrow is here." CR>)>
		<RTRUE>)>>

<ROUTINE POLE-FCN ()
	 <COND (<AND <VERB? MOVE TAKE RAISE> <==? ,SCARE-STATE 0>>
		<SCARE-RECRUIT>)
	       (<VERB? EXAMINE>
		<TELL "A pole stuck up the back of a scarecrow's coat, which is
a poor way to spend a life." CR>
		<RTRUE>)>>

<ROUTINE CORN-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "Ripe corn, rustling, and not in the least frightened of
anybody." CR>
		<RTRUE>)
	       (<VERB? TAKE EAT>
		<TELL "It is somebody's crop, and you were raised better." CR>
		<RTRUE>)>>

<ROUTINE SCARE-RECRUIT ()
	 <SETG SCARE-STATE 1>
	 <MOVE ,SCARECROW ,HERE>
	 <COND (<NOT ,SC-SCARE> <SETG SC-SCARE T> <SCORE-IT 10>)>
	 <TELL
"You take hold of him under the arms and lift him off the pole; being
stuffed with straw, he is quite light. He shakes himself out, stretches,
and yawns." CR CR
"\"Thank you very much,\" says the Scarecrow. \"I feel like a new man. Who
are you, and where are you going?\" And when you tell him: \"Do you think
that if I go with you, Oz would give me some brains? You see, my head is
stuffed with straw, and that is why I am asking.\"" CR>
	 <RTRUE>>

"=== The Tin Woodman ==="

<ROUTINE COTTAGE-FCN (RARG)
	 <COND (<AND <==? .RARG ,M-ENTER> <==? ,WOOD-STATE 0>>
		<TELL CR
"From somewhere north among the trees comes a groan: long, hollow, and
extremely patient." CR>
		<RFALSE>)>>

<ROUTINE OIL-CAN-FCN ()
	 <COND (<VERB? EXAMINE>
		<COND (,LION-FREED
		       <TELL "A jeweled oil-can, gold and studded, a gift from
grateful tinsmiths. It works exactly as well as the old one." CR>)
		      (T
		       <TELL "A battered tin oil-can, half full, kept tidy by
somebody who used to worry about rain." CR>)>
		<RTRUE>)
	       (<VERB? OIL> <DO-OIL>)>>

<ROUTINE LEAF-BED-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "A bed of dried leaves in the corner, which nobody who
lives here has ever needed." CR>
		<RTRUE>)
	       (<VERB? SLEEP ENTER BOARD CLIMB-ON> <V-SLEEP>)>>

<ROUTINE GLADE-FCN (RARG)
	 <COND (<AND <==? .RARG ,M-LOOK> <==? ,WOOD-STATE 0>>
		<TELL "Beside a half-chopped tree stands a man made entirely of
tin, his axe lifted over his head, perfectly still. And groaning." CR>
		<RFALSE>)>>

<ROUTINE WOODMAN-DESCFCN (ARG)
	 <COND (<==? .ARG ,M-OBJDESC>
		<COND (<==? ,WOOD-STATE 0> <RTRUE>)
		      (<==? ,WOOD-STATE 2>
		       <TELL "The Tin Woodman lies here among the rocks,
battered out of all shape." CR>)
		      (T <TELL "The Tin Woodman is here." CR>)>
		<RTRUE>)>>

<ROUTINE SPRING-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "A little spring rising clear and cold out of the moss,
which is exactly the sort of thing that rusts a tin man." CR>
		<RTRUE>)
	       (<VERB? DRINK>
		<TELL "Cold enough to hurt your teeth, and very good." CR>
		<RTRUE>)>>

<ROUTINE HALF-TREE-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "A tree half chopped through, with the cut gone gray and
weathered. Whoever was working on it stopped a long time ago." CR>
		<RTRUE>)>>

<ROUTINE AXE-FCN ()
	 <COND (<VERB? TAKE>
		<TELL "It is the Woodman's, and in any case you could not lift
it in both hands." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<COND (,WOOD-FIXED
		       <TELL "A bright axe with a handle of solid gold, which
the Winkie goldsmiths insisted on." CR>)
		      (T
		       <TELL "A gleaming axe, kept sharp by somebody who takes
his work seriously." CR>)>
		<RTRUE>)>>

<ROUTINE OIL-WOODMAN ()
	 <COND (<NOT <IN? ,OIL-CAN ,WINNER>>
		<TELL "You haven't anything to oil him with. There must be a
can about somewhere; he clearly kept himself tidy, before the rain." CR>
		<RTRUE>)
	       (T
		<SETG WOOD-STATE 1>
		<MOVE ,WOODMAN ,HERE>
		<COND (<NOT ,SC-WOOD> <SETG SC-WOOD T> <SCORE-IT 10>)>
		<TELL
"You oil the jaws first, and the Scarecrow takes the tin head and works it
gently from side to side until it moves freely. \"That is a great
comfort,\" says the Tin Woodman. \"I have been holding that axe in the
air ever since I rusted, and I am glad to be able to put it down.\"" CR CR
"You oil the neck, and the arms, and the legs, and he bends and sighs at
every joint. Then he lowers the axe at last and leans it against the
tree. \"I might have stood there always if you had not come along,\" he
says. \"You have certainly saved my life. Do you think Oz could give me
a heart?\"" CR CR
"\"Keep the oil-can in your basket,\" he adds, \"in case I am caught in
the rain.\"" CR>
		<RTRUE>)>>

"=== Brambles ==="

<ROUTINE BRAMBLES-FCN ()
	 <COND (<VERB? CHOP CUT ATTACK> <DO-CHOP>)
	       (<VERB? EXAMINE>
		<TELL "Branches and whole trees woven together like a basket.
Not even Toto could squeeze through." CR>
		<RTRUE>)
	       (<VERB? MOVE PUSH TAKE>
		<TELL "They are woven like a basket, and rooted, and thorny." CR>
		<RTRUE>)>>

<ROUTINE CHOP-BRAMBLES ()
	 <SETG BRAMBLE-OPEN T>
	 <TELL
"\"This is my sort of trouble,\" says the Tin Woodman, and sets to work,
and chips fly like green snow. In a little while there is a clean gap in
the wall of branches, and the yellow bricks run on west." CR>
	 <RTRUE>>

<ROUTINE BRAMBLE-FCN (RARG)
	 <COND (<==? .RARG ,M-LOOK>
		<COND (,BRAMBLE-OPEN
		       <TELL "A clean gap has been cut through the branches to
the west." CR>)>
		<RFALSE>)>>

<ROUTINE BRAMBLE-WEST ()
	 <COND (,BRAMBLE-OPEN ,DEEP-FOREST)
	       (<HAS-WOOD?> <CHOP-BRAMBLES> ,DEEP-FOREST)
	       (T
		<TELL "The branches are woven like a basket. If only you had
an axe, and arms like tin barrels to swing it." CR>
		<RFALSE>)>>

"=== The Lion ==="

<ROUTINE DEEP-FOREST-FCN (RARG)
	 <COND (<AND <==? .RARG ,M-ENTER> <==? ,LION-STATE 0>>
		<SETG LION-SCENE 1>
		<SETG SCENE-FLAG T>
		<MOVE ,LION ,DEEP-FOREST>
		<ENABLE <QUEUE I-LION 2>>
		<TELL CR
"A terrible roar, and a great Lion bounds into the road. One blow of his
paw sends the Scarecrow spinning over and over to the edge of the road;
he strikes at the Tin Woodman and only dents his own claws on the tin;
and then he turns, with his mouth open, on Toto." CR>
		<RFALSE>)>>

<ROUTINE LION-DESCFCN (ARG)
	 <COND (<==? .ARG ,M-OBJDESC>
		<COND (<==? ,LION-STATE 0>
		       <TELL "A great Lion stands in the road, showing his
teeth." CR>)
		      (<==? ,LION-STATE 2>
		       <TELL "The Lion lies asleep in the flowers, a little way
back among the poppies." CR>)
		      (<==? ,LION-STATE 3>
		       <TELL "Behind the bars paces the Cowardly Lion, trying
to look dangerous and mostly looking hungry." CR>)
		      (T <TELL "The Cowardly Lion is here." CR>)>
		<RTRUE>)>>

<ROUTINE I-LION ()
	 <COND (<N==? ,LION-STATE 0> <RFALSE>)>
	 <SETG LION-SCENE <+ ,LION-SCENE 1>>
	 <COND (<==? ,LION-SCENE 2>
		<TELL CR
"Toto runs barking straight at the great beast. There is no time to
think." CR>
		<ENABLE <QUEUE I-LION 2>>
		<RTRUE>)
	       (T
		;"grace period: the game will not let Toto lose."
		<TELL CR
"Your hand moves before you decide anything: you rush forward and slap the
Lion on the nose as hard as you can." CR>
		<LION-RECRUIT>
		<RTRUE>)>>

<ROUTINE LION-RECRUIT ()
	 <SETG LION-STATE 1>
	 <SETG SCENE-FLAG <>>
	 <MOVE ,LION ,HERE>
	 <COND (<NOT ,SC-LION> <SETG SC-LION T> <SCORE-IT 10>)>
	 <TELL
"\"Don't you dare to bite Toto!\" you shout. \"You ought to be ashamed of
yourself, a big beast like you, biting a poor little dog!\"" CR CR
"\"I didn't bite him,\" says the Lion, rubbing his nose where you hit it.
\"I know it. You are nothing but a big coward.\" \"I know it,\" says the
Lion, hanging his head. \"I've always known it. But how can I help it?\"
He looks at the ground. \"If I go with you to Oz, do you suppose he could
give me courage?\"" CR>
	 <RTRUE>>

<ROUTINE DEEP-WEST ()
	 <COND (<==? ,LION-STATE 0>
		<TELL "The Lion pads after you, apologizing. \"Wait! I mostly
never bite anybody!\"" CR>
		<RFALSE>)
	       (T ,GORGE-EDGE)>>

"=== The beetle ==="

<ROUTINE I-BEETLE ()
	 <COND (<OR <N==? ,BEETLE-STATE 0> <NOT <HAS-WOOD?>>> <RFALSE>)>
	 <SETG BEETLE-STATE 1>
	 <MOVE ,BEETLE ,HERE>
	 <TELL CR
"The Tin Woodman stops short. He has stepped on a beetle crossing the
road, and killed the poor little thing. \"This will serve me a lesson,\"
he begins, \"to look where I st\"" CR CR
"And his jaws rust shut in the middle of the word, because he has been
crying, and his tears have run down his face and into the hinges. He
gestures at you, desperately, with both tin hands." CR>
	 <ENABLE <QUEUE I-BEETLE-HELP 4>>
	 <RTRUE>>

<ROUTINE I-BEETLE-HELP ()
	 <COND (<N==? ,BEETLE-STATE 1> <RFALSE>)>
	 <COND (<HAS-SCARE?>
		<TELL CR
"The Scarecrow takes the oil-can out of your basket without a word and
oils the Woodman's jaws himself. It takes him some minutes, being made of
straw." CR>
		<OIL-JAWS-TEXT>
		<SETG BEETLE-STATE 2>)
	       (T <ENABLE <QUEUE I-BEETLE-HELP 3>>)>
	 <RTRUE>>

<ROUTINE OIL-JAWS ()
	 <COND (<NOT <IN? ,OIL-CAN ,WINNER>>
		<TELL "The oil-can is not in your hands, and he is looking at
you with his whole face." CR>
		<RTRUE>)
	       (T
		<SETG BEETLE-STATE 2>
		<COND (<NOT ,SC-BEETLE> <SETG SC-BEETLE T> <SCORE-IT 5>)>
		<TELL "You oil the Woodman's jaws, working them gently until
they come free." CR>
		<OIL-JAWS-TEXT>
		<RTRUE>)>>

<ROUTINE OIL-JAWS-TEXT ()
	 <REMOVE ,BEETLE>
	 <TELL CR
"\"This will serve me a lesson,\" says the Woodman, finishing his sentence
at last, \"to look where I step. For if I should kill another bug or
beetle I should surely cry again, and crying rusts my jaws so that I
cannot speak.\"" CR CR
"After that he walks along with his eyes on the road, and steps over
everything, and is very happy." CR>
	 <RTRUE>>

<ROUTINE BEETLE-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "A small beetle, quite dead, and mourned more sincerely
than most kings." CR>
		<RTRUE>)>>

"=== The first gorge ==="

<ROUTINE GORGE-FCN (RARG)
	 <COND (<AND <==? .RARG ,M-ENTER> <==? ,BEETLE-STATE 0>
		     <==? ,WOOD-STATE 1> <==? ,LION-STATE 1>>
		<MOVE ,WOODMAN ,HERE>
		<I-BEETLE>
		<RFALSE>)
	       (<==? .RARG ,M-BEG>
		<COND (<AND <VERB? LEAP> <NOT ,GORGE-CROSSED>>
		       <GORGE-JUMP>)>)>>

<GLOBAL JUMP-WARNINGS 0>

<ROUTINE GORGE-JUMP ()
	 <SETG JUMP-WARNINGS <+ ,JUMP-WARNINGS 1>>
	 <COND (<==? ,JUMP-WARNINGS 1>
		<TELL "The Scarecrow catches your sleeve. \"I have no
brains,\" he says, \"and even I wouldn't.\"" CR>
		<RTRUE>)
	       (<==? ,JUMP-WARNINGS 2>
		<TELL "\"Please don't,\" says the Lion, who knows more about
falling than anybody here. \"Let me carry you. That is what I am for.\"" CR>
		<RTRUE>)
	       (T
		<JIGS-UP "You take a run at the gorge, and the far side comes
no nearer, and the gray rocks at the bottom come up very fast indeed.">
		<RTRUE>)>>

<ROUTINE GORGE-LG-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "A gorge broad and deep, with jagged rocks at the bottom
that look like gray teeth." CR>
		<RTRUE>)
	       (<VERB? LEAP CROSS> <GORGE-JUMP>)
	       (<VERB? CLIMB-FOO CLIMB-DOWN>
		<TELL "The sides go straight down, and they are crumbly." CR>
		<RTRUE>)>>

<ROUTINE GORGE-WEST ()
	 <COND (,GORGE-CROSSED ,KALIDAH-WOOD)
	       (<HAS-LION?> <GORGE-CROSS> ,KALIDAH-WOOD)
	       (T
		<TELL "The gorge is far too wide to jump and too steep to
climb." CR>
		<RFALSE>)>>

<ROUTINE GORGE-CROSS ()
	 <SETG GORGE-CROSSED T>
	 <COND (<NOT ,SC-GORGE> <SETG SC-GORGE T> <SCORE-IT 5>)>
	 <TELL
"\"I think I could jump over it,\" says the Lion, measuring the distance
with his eye. \"One at a time. Who's first?\"" CR CR
"The Scarecrow goes first, and calls back that it was nothing at all. Then
the Woodman, heavy as a stove, and the Lion's back legs shake when he
lands. Then you, with Toto in your arms and your eyes shut. \"Why don't
you run and jump?\" the Scarecrow asks him afterward. \"That isn't the
way we Lions do these things,\" says the Lion, panting, and lies down to
rest." CR>
	 <RTRUE>>

<ROUTINE DO-RIDE ()
	 <COND (<HAS-LION?> <DO-LEAP>)
	       (T
		<TELL "There is nothing here to ride." CR>
		<RTRUE>)>>

"=== Kalidah wood and the second gorge ==="

<ROUTINE KWOOD-FCN (RARG)
	 <COND (<==? .RARG ,M-ENTER>
		<TELL CR
"Something heavy moves in the dark, off among the trunks, keeping pace.
The Lion whispers one word: \"Kalidahs.\"" CR>
		<RFALSE>)>>

<ROUTINE KWOOD-EAST ()
	 <TELL "\"We came over that gorge to get here,\" says the Scarecrow,
\"and the road only goes one way, which is the way we are going.\"" CR>
	 <RFALSE>>

<ROUTINE KALIDAHS-FCN ()
	 <COND (<TALKING?>
		<TELL "They are not the conversational sort." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL "Monstrous beasts with bodies like bears and heads like
tigers, and claws so long and sharp they could tear a tin man in two." CR>
		<RTRUE>)
	       (<VERB? ATTACK CHOP>
		<TELL "\"Not those,\" says the Lion, all the fur standing up
along his back. \"Anything but those.\"" CR>
		<RTRUE>)>>

<ROUTINE SGORGE-FCN (RARG)
	 <COND (<==? .RARG ,M-LOOK>
		<COND (<==? ,BRIDGE-STATE 1>
		       <TELL "The great tree lies across the gulf now, a bridge
from edge to edge." CR>)
		      (<==? ,BRIDGE-STATE 3>
		       <TELL "The gulf is empty; the bridge is gone into it,
with two Kalidahs." CR>)>
		<RFALSE>)>>

<ROUTINE BRIDGE-TREE-FCN ()
	 <COND (<VERB? CHOP CUT> <SGORGE-CHOP>)
	       (<VERB? CROSS CLIMB-FOO CLIMB-UP THROUGH>
		<COND (<==? ,BRIDGE-STATE 1> <SGORGE-CROSS>)
		      (T
		       <TELL "It is standing straight up, and would want
felling first." CR>
		       <RTRUE>)>)
	       (<VERB? EXAMINE>
		<TELL "One great tree at the very edge, tall enough to reach
the other side, if only it were lying down." CR>
		<RTRUE>)>>

<ROUTINE SGORGE-CHOP ()
	 <COND (<NOT <HAS-WOOD?>> <NO-AXE>)
	       (<==? ,BRIDGE-STATE 0>
		<SETG BRIDGE-STATE 1>
		<TELL
"\"Then let us begin,\" says the Tin Woodman, and begins. The Lion puts
his front legs against the trunk and pushes with all his might, and the
great tree tips slowly and comes down with a crash, straight across the
gulf." CR>
		<RTRUE>)
	       (<==? ,BRIDGE-STATE 2>
		<SETG BRIDGE-STATE 3>
		<DISABLE <INT I-KALIDAH>>
		<SETG KALIDAH-CLEAN T>
		<SETG SCENE-FLAG <>>
		<REMOVE ,KALIDAHS>
		<COND (<NOT ,SC-BRIDGE> <SETG SC-BRIDGE T> <SCORE-IT 10>)>
		<TELL
"The Woodman swings, and swings again, and the end of the tree splinters
and drops. The bridge goes down into the gulf with a crash, and the two
Kalidahs go with it, and are dashed to pieces on the sharp rocks at the
bottom." CR CR
"\"Well,\" says the Lion, drawing a long breath, \"I see we are going to
live a little while longer, and I am glad of it, for it must be a very
uncomfortable thing not to be alive.\"" CR>
		<MOVE ,WINNER ,RIVERBANK>
		<SETG HERE ,RIVERBANK>
		<V-LOOK>
		<RTRUE>)
	       (<==? ,BRIDGE-STATE 1>
		<TELL "It is down already, and lying across the gulf." CR>
		<RTRUE>)
	       (T
		<TELL "The tree is gone into the gorge." CR>
		<RTRUE>)>>

<ROUTINE SGORGE-EAST ()
	 <TELL "There is nothing back there but a wood full of Kalidahs." CR>
	 <RFALSE>>

<ROUTINE SGORGE-WEST ()
	 <COND (<==? ,BRIDGE-STATE 1> <SGORGE-CROSS> <RFALSE>)
	       (<==? ,BRIDGE-STATE 2>
		<TELL "You are already out on the tree, with a Kalidah coming
after you." CR>
		<RFALSE>)
	       (<==? ,BRIDGE-STATE 3> ,RIVERBANK)
	       (T
		<TELL "This gulf is far too broad for any leap. There is a tree
at the edge that is tall enough to reach the other side, if only it were
lying down." CR>
		<RFALSE>)>>

<ROUTINE SGORGE-CROSS ()
	 <SETG BRIDGE-STATE 2>
	 <SETG SCENE-FLAG T>
	 <SETG KALIDAH-TURNS 0>
	 <MOVE ,KALIDAHS ,SECOND-GORGE>
	 <ENABLE <QUEUE I-KALIDAH -1>>
	 <TELL
"You start across the trunk. Halfway over, there is a snarl behind you:
two great beasts with bodies like bears and heads like tigers come out of
the wood and start onto the tree." CR CR
"The Lion turns and faces them and roars so terribly that the two
Kalidahs stop where they are, astonished. It will not hold them long." CR>
	 <RTRUE>>

<ROUTINE I-KALIDAH ()
	 <COND (<N==? ,BRIDGE-STATE 2> <RFALSE>)>
	 <SETG KALIDAH-TURNS <+ ,KALIDAH-TURNS 1>>
	 <COND (<==? ,KALIDAH-TURNS 2>
		<TELL CR
"\"Chop away our end of the tree!\" cries the Scarecrow. The Kalidahs
gather themselves." CR>
		<RTRUE>)
	       (<G? ,KALIDAH-TURNS 3>
		;"Missed window: sad, scary, survivable."
		<SETG BRIDGE-STATE 3>
		<DISABLE <INT I-KALIDAH>>
		<SETG LION-HURT T>
		<SETG SCENE-FLAG <>>
		<REMOVE ,KALIDAHS>
		<TELL CR
"The Kalidahs come on, and the Lion turns and holds the bridgehead
himself while the rest of you scramble across. There is a short, terrible
noise. Then the tree gives way under all that weight and goes into the
gulf, and the Kalidahs with it, and the Lion drags himself up the far
bank with three long cuts along his shoulder." CR CR
"\"It is nothing,\" he says, in a voice that is not quite right. \"It is
nothing at all.\"" CR>
		<MOVE ,WINNER ,RIVERBANK>
		<SETG HERE ,RIVERBANK>
		<V-LOOK>
		<RTRUE>)>
	 <RFALSE>>

"=== The river ==="

<ROUTINE RIVERBANK-FCN (RARG)
	 <COND (<==? .RARG ,M-LOOK>
		<COND (,RAFT-BUILT
		       <TELL "A log raft lies at the water's edge, ready." CR>)>
		<RFALSE>)>>

<ROUTINE RIVER-LG-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "A broad river sliding past, deep and swift and much
faster than it looks." CR>
		<RTRUE>)
	       (<VERB? SWIM CROSS>
		<COND (<==? ,HERE ,STORK-BEND>
		       <TELL "The current out there defeated even the Lion. But
something with wings might manage it." CR>)
		      (T
		       <TELL "The current would carry you away like a hat.
Something to float on would be better." CR>)>
		<RTRUE>)
	       (<VERB? DRINK>
		<TELL "You drink from your hands. It tastes of the whole
country upstream." CR>
		<RTRUE>)>>

<ROUTINE BUILD-RAFT ()
	 <SETG RAFT-BUILT T>
	 	 <TELL
"\"Then we must build a raft,\" says the Scarecrow, and the Tin Woodman
sets to work with his axe, cutting the straight young trees and trimming
them, and it takes him the rest of the day and most of the night. In the
morning the raft is finished and lying at the water's edge." CR>
	 <RTRUE>>

<GLOBAL ON-RAFT <>>

<ROUTINE RAFT-FCN ()
	 <COND (<NOT ,RAFT-BUILT>
		<COND (<VERB? BUILD CHOP MAKE> <DO-BUILD>)
		      (T
		       <TELL "There is no raft yet, only good straight trees
and somebody with an axe." CR>
		       <RTRUE>)>)
	       (<VERB? BOARD CLIMB-ON ENTER TAKE>
		<COND (,ON-RAFT <TELL "You are on it." CR>)
		      (T
		       <SETG ON-RAFT T>
		       <TELL "You get onto the raft. It rides low and steady,
and the Lion makes it ride lower." CR>)>
		<RTRUE>)
	       (<VERB? LAUNCH THROUGH CROSS>
		<COND (,ON-RAFT <RIVER-LAUNCH>)
		      (T
		       <SETG ON-RAFT T>
		       <TELL "You step aboard first." CR>
		       <RIVER-LAUNCH>)>)
	       (<VERB? EXAMINE>
		<TELL "A raft of straight logs bound together, the work of one
tireless night." CR>
		<RTRUE>)>>

<ROUTINE RIVER-WEST ()
	 <COND (<AND ,RAFT-BUILT ,ON-RAFT> <RIVER-LAUNCH> <RFALSE>)
	       (,RAFT-BUILT
		<TELL "The raft is right here and the river is deep. Get on
board first." CR>
		<RFALSE>)
	       (T
		<TELL "The river is deep and swift. You would need something to
float on, and there are good straight trees standing right here." CR>
		<RFALSE>)>>

<ROUTINE RIVER-LAUNCH ()
	 <SETG SCENE-FLAG T>
	 <SETG DRIFT 0>
	 <MOVE ,WINNER ,MIDRIVER>
	 <SETG HERE ,MIDRIVER>
	 <TELL
"The Woodman and the Scarecrow push off with long poles, and the raft goes
out into the stream." CR CR>
	 <V-LOOK>
	 <ENABLE <QUEUE I-DRIFT -1>>
	 <RTRUE>>

<ROUTINE MIDRIVER-FCN (RARG)
	 <COND (<==? .RARG ,M-BEG>
		<COND (<VERB? WALK>
		       <TELL "There is nowhere to walk. The river has the
raft." CR>
		       <RTRUE>)
		      (<VERB? SWIM>
		       <TELL "\"Stay on the raft,\" says the Lion, who is about
to do the swimming for everybody." CR>
		       <RTRUE>)>)>>

<ROUTINE I-DRIFT ()
	 <SETG DRIFT <+ ,DRIFT 1>>
	 <COND (<==? ,DRIFT 1>
		<TELL CR
"The water is deeper than the poles are long, and the current takes the
raft and swings it, and the road of yellow brick on the far bank begins to
slide away upstream." CR>
		<RTRUE>)
	       (<==? ,DRIFT 2>
		<SETG SCARE-STATE 2>
		<MOVE ,SCARECROW ,MIDRIVER>
		<TELL CR
"The Scarecrow pushes his pole hard into the mud to hold the raft, and it
sticks fast, and the raft goes on without him, and there he is, left
clinging to the pole in the middle of the river." CR CR
"\"Good-bye!\" he calls, politely, getting smaller." CR>
		<RTRUE>)
	       (T
		<DISABLE <INT I-DRIFT>>
		<TELL CR
"\"I will swim,\" says the Lion, and goes into the water, and tows the
raft after him by a rope in his teeth, hauling until his eyes are white
with effort. Then the bottom grates on gravel, and you are ashore." CR>
		<SETG RIVER-DONE T>
		<SETG SCENE-FLAG <>>
		<COND (<NOT ,SC-RAFT> <SETG SC-RAFT T> <SCORE-IT 5>)>
		<MOVE ,WINNER ,FAR-BANK>
		<SETG HERE ,FAR-BANK>
		<V-LOOK>
		<RTRUE>)>>

<ROUTINE FAR-BANK-FCN (RARG)
	 <COND (<AND <==? .RARG ,M-ENTER> <==? ,SCARE-STATE 2>>
		<TELL CR
"\"That was a bad thing for the Scarecrow,\" says the Tin Woodman, and his
jaw begins to tremble, and then he stops himself very carefully and does
not cry." CR>
		<RFALSE>)>>

"=== The Stork ==="

<ROUTINE STORK-BEND-FCN (RARG)
	 <COND (<==? .RARG ,M-LOOK>
		<COND (,STORK-DONE
		       <TELL "The stork has gone on about her business
upriver." CR>)>
		<RFALSE>)>>

<ROUTINE STORK-FCN ()
	 <COND (,STORK-DONE <RFALSE>)
	       (<VERB? EXAMINE>
		<TELL "A great white stork standing in the shallows on one leg,
resting, and looking at you sideways with a good deal of character." CR>
		<RTRUE>)
	       (<VERB? TELL HELLO RESCUE STOP ASK-FOR>
		<STORK-RESCUE>)
	       (<VERB? GIVE>
		<TELL "\"I am not hungry,\" says the stork, \"I am curious.\"" CR>
		<RTRUE>)>>

<ROUTINE STORK-RESCUE ()
	 <COND (<N==? ,SCARE-STATE 2>
		<TELL "\"Who are you?\" says the stork, and, being told, is
satisfied, and goes back to resting." CR>
		<RTRUE>)
	       (T
		<SETG STORK-DONE T>
		<SETG SCARE-STATE 1>
		<MOVE ,SCARECROW ,HERE>
		<SETG SONG-TURNS 6>
		<COND (<NOT ,SC-STORK> <SETG SC-STORK T> <SCORE-IT 5>)>
		<TELL
"\"Who is that out in the river?\" asks the stork. \"That is our friend
the Scarecrow. Isn't he heavy?\" \"He is stuffed with straw,\" you say,
\"so he weighs nothing at all.\"" CR CR
"\"Well,\" says the stork, \"I will try. If he is too heavy I shall drop
him.\" She flies out over the water, takes the Scarecrow by the arm, and
carries him back to the bank, and everybody hugs him at once, even the
Lion, who is careful about his claws." CR CR
"\"Tol-de-ri-de-oh!\" sings the Scarecrow, walking along. He cannot seem
to stop." CR>
		<REMOVE ,STORK>
		<RTRUE>)>>

"=== The poppies ==="

<ROUTINE POPPY-FCN (RARG)
	 <COND (<==? .RARG ,M-ENTER>
		<COND (<NOT ,POPPY-DONE>
		       <SETG POPPY-COUNT 1>
		       <ENABLE <QUEUE I-POPPY -1>>)>
		<RFALSE>)
	       (<==? .RARG ,M-BEG>
		<COND (<AND <VERB? SLEEP> <NOT ,POPPY-DONE>>
		       <TELL "You lie down in the flowers, which is exactly what
they want, and your friends haul you up again at once." CR>
		       <RTRUE>)>)>>

<ROUTINE POPPIES-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "Great scarlet poppies, so thick and so bright they dazzle
the eyes, and their scent is spicy and warm and completely convincing." CR>
		<RTRUE>)
	       (<VERB? SMELL>
		<TELL "You breathe in, deeply, which was a mistake. The whole
world goes soft at the edges." CR>
		<SETG POPPY-COUNT <+ ,POPPY-COUNT 1>>
		<RTRUE>)>>

<ROUTINE I-POPPY ()
	 <COND (<OR ,POPPY-DONE
		    <NOT <EQUAL? ,HERE ,POPPY-FIELD>>>
		<RFALSE>)>
	 <SETG POPPY-COUNT <+ ,POPPY-COUNT 1>>
	 <COND (<==? ,POPPY-COUNT 2>
		<TELL CR "You yawn, hugely, and are surprised at yourself." CR>)
	       (<==? ,POPPY-COUNT 3>
		<TELL CR
"Toto lies down in the flowers and does not get up. The Woodman picks him
up and carries him without a word. Your own eyes are very heavy." CR>)
	       (<==? ,POPPY-COUNT 4>
		<TELL CR
"\"Run!\" says the Scarecrow to the Lion. \"Run as fast as you can, and
get out of this deadly flower bed. We will carry the little girl, but if
you fall asleep you are too big to be carried.\" The Lion runs, and is
out of sight in a moment. The poppies are so soft." CR>)
	       (T <POPPY-COLLAPSE>)>
	 <RTRUE>>

<ROUTINE POPPY-COLLAPSE ()
	 <DISABLE <INT I-POPPY>>
	 <SETG POPPY-DONE T>
	 <SETG LION-STATE 2>
	 <MOVE ,LION ,POPPY-FIELD>
	 <MOVE ,TOTO ,GREEN-BANK>
	 <TELL CR
"Your eyes close, and you forget where you are and where you are going,
and you lie down among the poppies, fast asleep." CR CR
"The Scarecrow and the Tin Woodman, who are not made of flesh and cannot
be put to sleep by flowers, cross their hands and make a chair of them,
and carry you between them, over the poppies, mile after mile, until the
red field is behind you and there is sweet green grass underfoot." CR CR
"You wake on the grass with the wind on your face." CR CR>
	 <MOVE ,WINNER ,GREEN-BANK>
	 <SETG HERE ,GREEN-BANK>
	 <V-LOOK>
	 <SETG WC-TURNS 0>
	 <ENABLE <QUEUE I-WILDCAT 2>>
	 <RTRUE>>

<ROUTINE POPPY-NORTH ()
	 <COND (,POPPY-DONE ,GREEN-BANK)
	       (T
		;"Walking is progress; the timer decides the outcome."
		<TELL "You walk north through the flowers, which go on and on,
and the scent goes with you." CR>
		<RFALSE>)>>

"=== Green bank: the wildcat, the mice, the Lion hauled out ==="

<ROUTINE GREEN-BANK-FCN (RARG)
	 <COND (<==? .RARG ,M-ENTER>
		<COND (<==? ,WILDCAT-STATE 0>
		       <SETG WC-TURNS 0>
		       <ENABLE <QUEUE I-WILDCAT 2>>)>
		<RFALSE>)
	       (<==? .RARG ,M-LOOK>
		<COND (<AND <==? ,LION-STATE 2> <NOT ,LION-HAULED>>
		       <TELL "A little way back, the Lion lies in the flowers,
fast asleep and much too heavy to carry." CR>)>
		<RFALSE>)>>

<ROUTINE GREEN-BANK-WEST ()
	 <COND (<AND <==? ,LION-STATE 2> <NOT ,LION-HAULED>>
		<TELL "\"Do not go back in there,\" says the Scarecrow. \"You
are a great deal of upkeep, being made of flesh, and I say that with
affection.\"" CR>
		<RFALSE>)
	       (T
		<TELL "There is nothing back that way but poppies." CR>
		<RFALSE>)>>

<ROUTINE I-WILDCAT ()
	 <COND (<N==? ,WILDCAT-STATE 0> <RFALSE>)>
	 <SETG WILDCAT-STATE 1>
	 <SETG SCENE-FLAG T>
	 <MOVE ,WILDCAT ,GREEN-BANK>
	 <MOVE ,MOUSE-QUEEN ,GREEN-BANK>
	 <ENABLE <QUEUE I-WC2 -1>>
	 <TELL CR
"A great yellow Wildcat comes tearing across the grass with its ears laid
back and its mouth open, and running for its life just ahead of it is a
little gray field mouse." CR>
	 <RTRUE>>

<ROUTINE I-WC2 ()
	 <COND (<N==? ,WILDCAT-STATE 1> <RFALSE>)>
	 <SETG WC-TURNS <+ ,WC-TURNS 1>>
	 <COND (<G? ,WC-TURNS 2>
		<TELL CR
"The Tin Woodman does not wait to be asked. \"I have no heart, you know,\"
he says, lifting his axe, \"so I am careful to help all those who may need
a friend.\"" CR>
		<KILL-WILDCAT>
		<RTRUE>)>
	 <RFALSE>>

<ROUTINE KILL-WILDCAT ()
	 <COND (<N==? ,WILDCAT-STATE 1> <RFALSE>)>
	 <DISABLE <INT I-WC2>>
	 <SETG WILDCAT-STATE 3>
	 <REMOVE ,WILDCAT>
	 <TELL
"The Tin Woodman steps into the Wildcat's path and brings the axe down
once, and it is over, and he wipes the blade on the grass and looks
sorry." CR CR
"The little mouse stops running and sits up. \"Oh, thank you! Thank you
ever so much for saving my life!\" \"Don't speak of it, I beg of you,\"
says the Woodman. \"I have no heart, you know, so I am careful to help
all those who may need a friend, even if it happens to be only a
mouse.\"" CR CR
"\"Only a mouse!\" cries the little animal, indignantly. \"Why, I am a
Queen, the Queen of all the Field Mice!\" And the grass all around is
suddenly full of mice, hundreds of them, bowing." CR CR
"\"Is there anything we can do,\" asks the Queen, \"to repay you for
saving the life of your Queen?\"" CR>
	 <ENABLE <QUEUE I-QUEEN-HINT 3>>
	 <RTRUE>>

<ROUTINE I-QUEEN-HINT ()
	 <COND (<N==? ,WILDCAT-STATE 3> <RFALSE>)>
	 <COND (<HAS-SCARE?>
		<TELL CR
"\"I have an idea,\" says the Scarecrow, who is very pleased about it.
\"There are a great many of them. Ask them to save our Lion.\"" CR>)>
	 <RFALSE>>

<ROUTINE QUEEN-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "A small gray field mouse who holds herself like somebody
used to being listened to." CR>
		<RTRUE>)
	       (<AND <VERB? TELL RESCUE ASK-FOR HELLO SAVE COMMAND>
		     <==? ,WILDCAT-STATE 3>>
		<MICE-RESCUE>)
	       (<==? ,WINNER ,MOUSE-QUEEN> <MICE-RESCUE>)
	       (<VERB? TELL HELLO>
		<TELL "\"If ever you need us again,\" says the Queen, \"come
out into the field and blow the whistle, and we shall hear you.\"" CR>
		<RTRUE>)>>

<ROUTINE MICE-RESCUE ()
	 <SETG WILDCAT-STATE 4>
	 <SETG LION-HAULED T>
	 <SETG LION-STATE 1>
	 <SETG SCENE-FLAG <>>
	 <MOVE ,LION ,GREEN-BANK>
	 <MOVE ,MOUSE-WHISTLE ,WINNER>
	 <COND (<NOT ,SC-MICE> <SETG SC-MICE T> <SCORE-IT 10>)>
	 <COND (<NOT ,SC-HAUL> <SETG SC-HAUL T> <SCORE-IT 5>)>
	 <TELL
"\"Our friend the Lion is asleep in the poppy bed,\" you say, \"and he is
too heavy to carry.\" Toto makes a lunge at the nearest mouse and the Tin
Woodman picks him up and holds him, kindly and firmly, for the rest of
the afternoon." CR CR
"The Woodman builds a truck out of saplings, and the mice come in
thousands, each harnessed with a string, and they haul the sleeping Lion
out of the flowers and over the grass, and the truck is not even heavy
when so many are pulling. When he wakes he is very much surprised, and
very glad, and pretends he was only resting his eyes." CR CR
"\"Take this,\" says the Queen, and gives you a little whistle. \"If ever
you need us again, come out into the field and blow.\" And the mice are
gone into the grass like water into sand." CR>
	 <REMOVE ,MOUSE-QUEEN>
	 <RTRUE>>

<ROUTINE WILDCAT-FCN ()
	 <COND (<TALKING?>
		<TELL "It is going much too fast to be reasoned with." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL "A great yellow cat running full out, all teeth and
purpose." CR>
		<RTRUE>)
	       (<VERB? ATTACK STOP CHOP RESCUE SLAP> <KILL-WILDCAT>)>>

<ROUTINE WHISTLE-FCN ()
	 <COND (<VERB? BLOW-OBJ> <DO-BLOW-WHISTLE>)
	       (<VERB? EXAMINE>
		<TELL "A tiny whistle, mouse-sized, on a string around your
neck." CR>
		<RTRUE>)>>

<ROUTINE V-BLOW-OBJ ()
	 <COND (<EQUAL? ,PRSO ,MOUSE-WHISTLE> <DO-BLOW-WHISTLE>)
	       (T
		<TELL "You blow at it. Nothing happens, which is about right." CR>
		<RTRUE>)>>

<ROUTINE DO-BLOW-WHISTLE ()
	 <COND (<NOT <IN? ,MOUSE-WHISTLE ,WINNER>>
		<TELL "You do not have the whistle." CR>
		<RTRUE>)
	       (<==? ,HERE ,LOST-FIELDS> <LOST-WHISTLE>)
	       (T
		<TELL "You blow the little whistle. It makes almost no sound at
all, and no mouse comes; this is not a field where they live." CR>
		<RTRUE>)>>

"=== Green road and the gate ==="

<ROUTINE GREEN-ROAD-FCN (RARG)
	 <COND (<==? .RARG ,M-ENTER>
		<TELL CR
"A green-faced farmer straightens up from his fence to watch you go by.
\"Everything in the Emerald City is green,\" he calls, \"and Oz himself is
a Great Wizard, and can take on any form he wishes. But nobody has ever
seen him, and I have lived here all my life.\"" CR>
		<RFALSE>)>>

<ROUTINE FARMFOLK-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "A green farmer, a green wife, and two green children,
none of whom can stop looking at the Lion." CR>
		<RTRUE>)
	       (<VERB? TELL HELLO>
		<TELL "\"They say Oz is a terrible thing to look upon,\" the
farmer says cheerfully. \"But then, they say that about my mother-in-law,
and she is only forceful.\"" CR>
		<RTRUE>)>>

<ROUTINE CITY-GATE-FCN (RARG)
	 <COND (<==? .RARG ,M-LOOK>
		<COND (,BELL-RUNG
		       <TELL "The great gate stands open." CR>)>
		<RFALSE>)>>

<ROUTINE GATE-BUTTON-FCN ()
	 <COND (<VERB? PUSH RING RUB>
		<COND (,BELL-RUNG
		       <TELL "You ring again. The Guardian is already
expecting you." CR>)
		      (T
		       <SETG BELL-RUNG T>
		       <FSET ,EMERALD-GATE ,OPENBIT>
		       <TELL "You push the button, and a silvery tinkle sounds
somewhere inside. The great gate swings slowly open, and a little man
about your own size, clothed all in green with a green skin, is standing
in it." CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL "A button beside the gate, for a bell." CR>
		<RTRUE>)>>

<ROUTINE EMERALD-GATE-FCN ()
	 <COND (<VERB? OPEN KNOCK>
		<COND (,BELL-RUNG <TELL "It is open." CR>)
		      (T
		       <TELL "It does not budge. There is a button beside it,
for a bell." CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL "A great gate studded with emeralds that burn so
brightly in the sun they dazzle even painted eyes." CR>
		<RTRUE>)>>

<ROUTINE CITY-GATE-IN ()
	 <COND (,BELL-RUNG ,GATE-ROOM)
	       (T
		<TELL "The gate is shut. There is a button beside it, for a
bell." CR>
		<RFALSE>)>>

<ROUTINE CITY-GATE-WEST ()
	 <COND (<G? ,ACT 2> ,WEST-FIELDS)
	       (T ,GREEN-ROAD)>>

"=== Spectacles ==="

<ROUTINE GATE-ROOM-FCN (RARG)
	 <COND (<==? .RARG ,M-ENTER>
		<COND (<AND <NOT ,SPECS-DONE> <NOT ,SPECS-ON>>
		       <FCLEAR ,SPECTACLES ,INVISIBLE>
		       <TELL CR
"\"What do you wish in the Emerald City?\" asks the Guardian of the Gates.
Told, he considers a long time. \"Then I must take you to the Palace. But
first you must put on the spectacles.\" He opens the big green box; it is
full of spectacles of every size, and every one of them has green
glass." CR CR
"\"Everyone in the Emerald City must wear spectacles night and day,\" he
says. \"If you did not, the brightness and the glory of the Emerald City
would blind you. Even I sleep in mine.\"" CR>)
		      (<AND ,SPECS-ON <G? ,ACT 2> <NOT ,SPECS-DONE>>)>
		<RFALSE>)>>

<ROUTINE GUARDIAN-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "A little man about your own size, clothed all in green,
with a green skin, jingling a small key on a chain and looking pleased
with the arrangement." CR>
		<RTRUE>)
	       (<VERB? TELL HELLO>
		<COND (,SPECS-ON
		       <TELL "\"They are locked on,\" says the Guardian
comfortably, \"and I have the only key.\"" CR>)
		      (T
		       <TELL "\"Put on the spectacles,\" says the Guardian,
\"and I will take you to the Palace of Oz.\"" CR>)>
		<RTRUE>)>>

<ROUTINE GREEN-BOX-FCN ()
	 <COND (<VERB? OPEN EXAMINE SEARCH LOOK-INSIDE>
		<TELL "The box is full of spectacles of every size and shape,
and all of them have green glass in them." CR>
		<RTRUE>)>>

<ROUTINE SPECTACLES-FCN ()
	 <COND (<VERB? WEAR TAKE>
		<COND (,SPECS-ON
		       <TELL "You are wearing them." CR>)
		      (T
		       <SETG SPECS-ON T>
		       <MOVE ,SPECTACLES ,WINNER>
		       <COND (<NOT ,SC-SPECS> <SETG SC-SPECS T> <SCORE-IT 5>)>
		       <TELL "The Guardian finds a pair to fit you, and puts
them over your eyes, and locks them on behind your head with the little
key. Then a pair for the Scarecrow, and a pair for the Woodman, and a
very large pair for the Lion, and a very small pair for Toto, who is not
consulted." CR>)>
		<RTRUE>)
	       (<VERB? DROP>
		<COND (<AND ,SPECS-ON <N==? ,HERE ,GATE-ROOM>>
		       <TELL "They are locked on, and the Guardian of the Gates
has the only key. The Emerald City is very committed to being emerald." CR>)
		      (,SPECS-ON
		       <TELL "The Guardian will unlock them when you leave the
city, and not one moment before." CR>)
		      (T <RFALSE>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL "Through them, everything is green. Around the edges,
where the frames do not quite fit, you decide not to think about the
edges." CR>
		<RTRUE>)>>

<ROUTINE GATE-ROOM-IN ()
	 <COND (,SPECS-ON ,EMERALD-STREET)
	       (T
		<TELL "The Guardian bars the way, politely horrified. \"The
brightness and the glory would blind you! Even I sleep in mine.\"" CR>
		<RFALSE>)>>

<ROUTINE CITYFOLK-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "Green men, green women, green children, in green
clothes, buying green lemonade from a green stall with green pennies. Not
one of them looks surprised." CR>
		<RTRUE>)>>

<ROUTINE STREET-FCN (RARG)
	 <COND (<==? .RARG ,M-ENTER>
		<COND (<AND <==? ,ACT 2> <==? ,AUDIENCE 0>>
		       <TELL CR
"The Guardian leads you through the streets to a great building in the
exact middle of the city: the Palace of Oz." CR>)>
		<RFALSE>)>>

<ROUTINE STREET-EAST ()
	 <COND (<G? ,ACT 3> ,BALLOON-PLAZA)
	       (T
		<TELL "The great plaza east is roped off; something enormous is
being built in it, under green canvas." CR>
		<RFALSE>)>>

"=== The palace, audiences, the Wizard ==="

<ROUTINE PALACE-COURT-FCN (RARG)
	 <COND (<==? .RARG ,M-ENTER>
		<COND (<AND <==? ,AUDIENCE 0> <NOT ,SUMMONED> <==? ,DAY 0>>
		       <SETG DAY 1>
		       <TELL CR
"The soldier with the green whiskers takes your message in, and comes back
much impressed. \"Oz will grant you an audience,\" he says. \"But you
must each go in alone, and he will see one of you each day. So you will
have to stay in the Palace for several days. You shall have rooms.\"" CR CR
"The green girl shows you up to the sweetest little room in the world, and
tells you to sleep, and that Oz will send for you in the morning." CR>)>
		<RFALSE>)>>

<ROUTINE SOLDIER-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "A soldier in a green uniform with a long green beard,
which he is plainly very proud of and combs during quiet moments." CR>
		<RTRUE>)
	       (<VERB? TELL HELLO SEND-MSG THREATEN> <SOLDIER-TALK>)>>

<ROUTINE SOLDIER-TALK ()
	 <COND (<AND <G? ,AUDIENCE 3> <L? ,REVEAL 1> <G? ,DAY 5>>
		<SEND-THREAT>)
	       (<G? ,AUDIENCE 3>
		<TELL "\"Oz is thinking,\" says the soldier unhappily. \"He has
been thinking for days. You might send him a stronger sort of message.\"" CR>
		<RTRUE>)
	       (T
		<TELL "\"You must sleep,\" says the soldier, \"and Oz will send
for you when he is ready. He always is, eventually.\"" CR>
		<RTRUE>)>>

<ROUTINE GREEN-GIRL-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "A pretty green girl in a green silk gown, who has looked
after a great many nervous visitors and is not impressed by any of them." CR>
		<RTRUE>)
	       (<VERB? TELL HELLO SEND-MSG THREATEN> <SOLDIER-TALK>)>>

<ROUTINE GREEN-BED-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "Green silk sheets, a fountain spraying green perfume,
and a shelf of little green books full of queer green pictures." CR>
		<RTRUE>)
	       (<VERB? SLEEP ENTER BOARD CLIMB-ON> <V-SLEEP>)>>

<ROUTINE CHAMBER-FCN (RARG)
	 <COND (<==? .RARG ,M-LOOK>
		<COND (,SUMMONED
		       <TELL "Oz has sent for you. The throne room is below and
to the north." CR>)>
		<RFALSE>)>>

<ROUTINE PALACE-NIGHT ()
	 <COND (<AND <==? ,AUDIENCE 0> <NOT ,SUMMONED>>
		<SETG SUMMONED T>
		<SETG DAY 2>
		<TELL "You sleep in green silk, and in the morning the soldier
knocks. \"Oz will see you now,\" he says, and he is nervous about it." CR>
		<RTRUE>)
	       (<AND <G? ,AUDIENCE 0> <L? ,AUDIENCE 4>>
		<COMPANION-AUDIENCE>)
	       (<AND <G? ,AUDIENCE 3> <L? ,REVEAL 1>>
		<SETG DAY <+ ,DAY 1>>
		<COND (<G? ,DAY 6>
		       <TELL "Another day, and no word from Oz. The Scarecrow
is beginning to have an idea about it; you can tell, because the pins are
starting to stick out." CR>)
		      (T
		       <TELL "You sleep, and wake, and there is no word from
Oz." CR>)>
		<RTRUE>)
	       (<AND <==? ,REVEAL 3> <NOT ,GIFTS-GIVEN>>
		<SETG SUMMONED T>
		<TELL "You sleep badly and wake early. Today the little man
keeps his promise, and the soldier comes for all four of you." CR>
		<RTRUE>)
	       (<AND ,GIFTS-GIVEN <L? ,BALLOON-DAY 3>>
		<SETG BALLOON-DAY <+ ,BALLOON-DAY 1>>
		<TELL "Another day of sewing green silk and painting on glue.
The balloon in the plaza grows a little bigger and a great deal
greener." CR>
		<RTRUE>)
	       (T
		<TELL "You sleep well, and nothing changes in the night." CR>
		<RTRUE>)>>

<ROUTINE COURT-NORTH ()
	 <COND (<AND ,SUMMONED <L? ,AUDIENCE 1>> ,THRONE-ROOM)
	       (<G? ,REVEAL 0> ,THRONE-ROOM)
	       (<AND <G? ,AUDIENCE 3> ,SUMMONED> ,THRONE-ROOM)
	       (<G? ,AUDIENCE 3>
		<TELL "The soldier bars the door, apologetic. \"Not until Oz
sends for you.\"" CR>
		<RFALSE>)
	       (<G? ,AUDIENCE 0>
		<TELL "\"Today is not your day,\" says the soldier. \"Today is
somebody else's day. Sleep, and we shall see.\"" CR>
		<RFALSE>)
	       (T
		<TELL "The soldier bars the door. \"Nobody goes in to Oz
unsent for. Nobody at all. Not even me, and I work here.\"" CR>
		<RFALSE>)>>

"=== Audience 1: the Great Head ==="

<ROUTINE THRONE-FCN (RARG)
	 <COND (<==? .RARG ,M-ENTER>
		<COND (<AND <==? ,AUDIENCE 0> ,SUMMONED>
		       <SETG SCENE-FLAG T>
		       <SETG ANSWERS 0>
		       <TELL CR
"In the middle of the room, on the marble throne, there is an enormous
Head, without a body to support it or any arms or legs at all. There is
no hair upon this head, but it has eyes and a nose and a mouth, and is
much bigger than the head of the biggest giant." CR CR
"The eyes turn slowly and look at you, and the mouth moves. \"I am Oz, the
Great and Terrible. Who are you, and why do you seek me?\"" CR>)
		      (<AND <==? ,REVEAL 3> <NOT ,GIFTS-GIVEN> ,SUMMONED>
		       <THRONE-GIFTS>)
		      (<AND <G? ,AUDIENCE 3> <==? ,REVEAL 0>>
		       <SETG SCENE-FLAG T>
		       <TELL CR
"The room is empty. The throne stands bare under its blinding light, and
there is nobody in it, and nobody anywhere." CR CR
"Then a Voice comes, from everywhere at once, and from nowhere: \"I am
Oz, the Great and Terrible. Why do you seek me?\"" CR>)>
		<RFALSE>)
	       (<==? .RARG ,M-BEG>
		<COND (<AND <==? ,AUDIENCE 0> ,SUMMONED
			    <VERB? SAY-OBJ ANSWER REPLY TELL YELL MUMBLE HELLO KANSAS>>
		       <HEAD-ANSWER>)>)>>

<ROUTINE HEAD-ANSWER ()
	 <SETG ANSWERS <+ ,ANSWERS 1>>
	 <COND (<==? ,ANSWERS 1>
		<TELL "\"I am Dorothy, the Small and Meek,\" you say, because
it seems only fair. \"I have come to you for help.\"" CR CR
"The eyes roll from side to side, slowly, taking in the whole of you.
\"Where did you get the silver shoes?\"" CR>
		<RTRUE>)
	       (<==? ,ANSWERS 2>
		<TELL "\"I got them from the Wicked Witch of the East,\" you
say, \"when my house fell on her and killed her.\"" CR CR
"\"Where did you get the mark upon your forehead?\"" CR>
		<RTRUE>)
	       (T <HEAD-PRICE>)>>

<ROUTINE HEAD-PRICE ()
	 <SETG AUDIENCE 1>
	 <SETG SUMMONED <>>
	 <SETG SCENE-FLAG <>>
	 <TELL "\"That is where the Witch of the North kissed me,\" you say,
\"when she bade me good-bye and sent me to you.\"" CR CR
"The eyes look at you a long time. Then: \"What do you wish me to do?\"
And when you have asked to be sent back to Kansas, to Aunt Em and Uncle
Henry:" CR CR
"\"In this country everyone must pay for everything he gets. Kill the
Wicked Witch of the West, and I will send you back to Kansas. Not
before.\"" CR CR
"\"But I cannot!\" you say." CR CR
"\"That is my answer, and until the Wicked Witch dies you will not see
your uncle and aunt again. Now go, and do not ask me again until you have
earned your wish.\" The great Head says nothing more, whatever you say to
it, and at last you go out." CR>
	 <RTRUE>>

<ROUTINE OZ-FCN ()
	 <COND (<AND <G? ,AUDIENCE 0> <L? ,AUDIENCE 4>>
		<TELL "Oz is not seeing you today." CR>
		<RTRUE>)
	       (<AND <==? ,AUDIENCE 0> <VERB? EXAMINE>>
		<TELL "An enormous bald head with no body at all, resting on
the marble throne, with eyes that move." CR>
		<RTRUE>)
	       (<AND <==? ,AUDIENCE 0> <VERB? TELL ANSWER REPLY SAY-OBJ HELLO>>
		<HEAD-ANSWER>)
	       (<==? ,REVEAL 0>
		<COND (<VERB? EXAMINE>
		       <TELL "There is nobody to examine. The Voice comes from
everywhere." CR>
		       <RTRUE>)
		      (<VERB? TELL ANSWER HELLO SAY-OBJ>
		       <TELL "\"I have said what I will do,\" says the Voice,
from everywhere at once. \"I have said it and I will not say it
again.\"" CR>
		       <RTRUE>)>)
	       (<G? ,REVEAL 0> <HUMBUG-TALK>)>>

<ROUTINE COMPANION-AUDIENCE ()
	 <SETG AUDIENCE <+ ,AUDIENCE 1>>
	 <SETG DAY <+ ,DAY 1>>
	 <COND (<==? ,AUDIENCE 2>
		<TELL "In the morning the soldier fetches the Scarecrow, and
you wait, and at last he comes back looking thoughtful." CR CR
"\"Oz was a Lovely Lady this time,\" he says, \"in green silk gauze, with
wings, and jewels in her green hair. She said she would give me brains
when I had killed the Wicked Witch of the West.\" He considers. \"She
needs a heart as much as the Tin Woodman.\"" CR>
		<RTRUE>)
	       (<==? ,AUDIENCE 3>
		<TELL "The Woodman's day. He comes back at evening with a small
dent in his forehead where he bowed too hard." CR CR
"\"A most terrible Beast,\" he reports, \"with a head like a rhinoceros
and five eyes, and five long arms, and five legs, all covered with thick
wool. It also wants the Wicked Witch killed.\" He pauses. \"It was very
loud. I do not think it needed to be so loud.\"" CR>
		<RTRUE>)
	       (T
		<SETG AUDIENCE 4>
		<COND (<NOT ,SC-AUD> <SETG SC-AUD T> <SCORE-IT 10>)>
		<TELL "The Lion's day. He goes in with his tail dragging and
comes out at a trot." CR CR
"\"A Ball of Fire,\" he says, \"so fierce and glowing I could scarcely
look at it, and it told me to come back when the Witch was dead, and I
came back at once. I did not even ask it anything. I was going to. There
was no point.\"" CR CR
"Four of you, four shapes, one Wizard. The Scarecrow says nothing at all,
which is his way of thinking hard." CR CR>
		<PREP-DEPARTURE>
		<RTRUE>)>>

<ROUTINE PREP-DEPARTURE ()
	 <SETG ACT 3>
	 <TELL
"In the morning the green girl fills your basket, and the axe is sharpened
on the green grindstone, and the Scarecrow gets fresh straw and new paint
around the eyes, and Toto gets a small green bell for his collar. Nobody
says out loud where you are going." CR>
	 <RTRUE>>

<ROUTINE THRONE-OBJ-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "A great throne of marble, shaped like a chair and
sparkling with gems, under a light too bright to look at directly." CR>
		<RTRUE>)
	       (<VERB? LOOK-BEHIND SEARCH LOOK-UNDER>
		<COND (<AND <G? ,AUDIENCE 3> <==? ,REVEAL 0>>
		       <SCREEN-FALLS <>>)
		      (T
		       <TELL "Nothing behind the throne but very green wall." CR>
		       <RTRUE>)>)>>

<ROUTINE THRONE-EAST ()
	 <COND (<G? ,REVEAL 1> ,WORKSHOP)
	       (T
		<TELL "There is only wall to the east, so far as you can
tell." CR>
		<RFALSE>)>>
