"AACTIONS - WONDERLAND part 1: globals, the size system, engine-required
routines, new verbs, and Act One (riverbank through the pool of tears)."

"=================== GLOBALS ==================="

"Size: 1 = SMALL, 2 = NORMAL, 3 = LARGE."
<GLOBAL ALICE-SIZE 2>
<GLOBAL MUSHROOM-VIRGIN T>

<GLOBAL RABBIT-SEEN <>>
<GLOBAL RIVER-WAITS 0>
<GLOBAL FALL-PHASE 0>
<GLOBAL CURTAIN-MOVED <>>
<GLOBAL F-UNLOCKED <>>
<GLOBAL BOTTLE-APPEARED <>>
<GLOBAL BOTTLE-DRUNK <>>
<GLOBAL F-DRINKME <>>
<GLOBAL BOX-REVEALED <>>
<GLOBAL F-EATME <>>
<GLOBAL ENTRY-FAILS 0>
<GLOBAL POOL-EXISTS <>>
<GLOBAL POOL-GONE <>>
<GLOBAL F-POOL <>>
<GLOBAL F-FANOUT <>>
<GLOBAL RABBIT-DUE <>>
<GLOBAL RABBIT-IN-HALL <>>
<GLOBAL FAN-DROPPED <>>
<GLOBAL POOL-WAITS 0>

<GLOBAL MOUSE-TALKED <>>
<GLOBAL RACE-RUN <>>
<GLOBAL F-COMFITS <>>
<GLOBAL F-THIMBLE <>>
<GLOBAL SHORE-SCATTER 0>
<GLOBAL MOUSE-TALE-TOLD <>>
<GLOBAL MARY-ANN <>>
<GLOBAL SIEGE-PHASE 0>
<GLOBAL F-BILL-KICK <>>
<GLOBAL F-HOUSE <>>
<GLOBAL HOUSE-DONE <>>
<GLOBAL PUPPY-BUSY <>>
<GLOBAL CATERPILLAR-PHASE 0>
<GLOBAL CONTRADICTION 0>
<GLOBAL F-RECITE <>>
<GLOBAL F-MUSHROOM <>>
<GLOBAL F-TREETOPS <>>
<GLOBAL PIGEON-PHASE 0>
<GLOBAL CAT-QUESTIONS 0>
<GLOBAL PIGFIG-PENDING <>>
<GLOBAL PIGFIG-DONE <>>
<GLOBAL KNOCK-COUNT 0>
<GLOBAL F-KITCHEN <>>
<GLOBAL KITCHEN-TURNS 0>
<GLOBAL DUCHESS-TALKS 0>
<GLOBAL BABY-STATE 0>
<GLOBAL F-BABY <>>
<GLOBAL SEATED <>>
<GLOBAL TEA-LINE 0>
<GLOBAL RIDDLE-DONE <>>
<GLOBAL DORMOUSE-TOLD <>>
<GLOBAL WATCH-FIXED <>>
<GLOBAL F-WATCH <>>
<GLOBAL F-TREACLE-WELL <>>
<GLOBAL STAY-OFFER 0>
<GLOBAL F-GARDEN <>>
<GLOBAL PROC-COUNT 0>
<GLOBAL PROCESSION <>>
<GLOBAL QUEEN-PHASE 0>
<GLOBAL QUEEN-DAWDLE 0>
<GLOBAL F-QUEEN <>>
<GLOBAL F-ROSES <>>
<GLOBAL GARDENERS-DOOMED <>>
<GLOBAL CROQUET-OPEN <>>
<GLOBAL FLAMINGO-TAME <>>
<GLOBAL ARCH-READY <>>
<GLOBAL HEDGEHOG-DONE <>>
<GLOBAL F-HEDGEHOG <>>
<GLOBAL MISHAP 0>
<GLOBAL CROQ-STAGE 0>
<GLOBAL CROQ-TURNS 0>
<GLOBAL F-VERDICT <>>
<GLOBAL DUCHESS-FREED <>>
<GLOBAL MORALS 0>
<GLOBAL F-GLOVES <>>
<GLOBAL SEASIDE-OPEN <>>
<GLOBAL TURTLE-TALKS 0>
<GLOBAL F-QUADRILLE <>>
<GLOBAL TRIAL-PHASE 0>
<GLOBAL TRIAL-NUDGE 0>
<GLOBAL F-PENCIL <>>
<GLOBAL F-PEPPERED <>>
<GLOBAL F-BILLBOX <>>
<GLOBAL F-MILE <>>
<GLOBAL F-SIXPENCE <>>
<GLOBAL BEHEAD-ASKS 0>
<GLOBAL F-RACE <>>
<GLOBAL F-SPARE-CAKE <>>
<GLOBAL F-PUPPY <>>
<GLOBAL F-PEPPERBOX <>>
<GLOBAL F-INVITE <>>
<GLOBAL F-HAT <>>
<GLOBAL F-DUCHESS <>>
<GLOBAL F-JAR <>>
<GLOBAL F-SIX <>>
<GLOBAL GAME-OVER <>>
<GLOBAL CROQ-DAWDLE 0>
<GLOBAL GRYPHON-WOKE <>>
<GLOBAL SOUP-SUNG <>>
<GLOBAL TRIAL-CALLED <>>
<GLOBAL F-FINALE <>>

<GLOBAL SCORE-MAX 100>

"=================== HELPERS ==================="

<ROUTINE SMALL? () <==? ,ALICE-SIZE 1>>
<ROUTINE NORMAL? () <==? ,ALICE-SIZE 2>>
<ROUTINE LARGE? () <==? ,ALICE-SIZE 3>>

"CHANGE-SIZE owns every consequence of a size change: the key-drop rule,
the bottle-slams-doors rule (VIOLENT changes only; mushroom magic is
gradual, and doors never notice), and the pool-slip check."
<ROUTINE CHANGE-SIZE (NEW "OPTIONAL" (VIOLENT <>) "AUX" OLD)
	 <SET OLD ,ALICE-SIZE>
	 <SETG ALICE-SIZE .NEW>
	 <COND (<AND <L? .NEW .OLD> <IN? ,GOLDEN-KEY ,WINNER>>
		<COND (<EQUAL? ,HERE ,HALL>
		       <MOVE ,GOLDEN-KEY ,GLASS-TABLE>
		       <TELL
"The golden key grows in your hand from a key to an oar, slips from your
grip, and rings down onto the glass table-top." CR>)
		      (T
		       <MOVE ,GOLDEN-KEY ,HERE>
		       <TELL
"The golden key, suddenly the size of an oar, slips from your grip and
falls at your feet." CR>)>)>
	 <COND (<AND .VIOLENT
		     <EQUAL? ,HERE ,HALL>
		     <FSET? ,LITTLE-DOOR ,OPENBIT>>
		<FCLEAR ,LITTLE-DOOR ,OPENBIT>
		<FSET ,LITTLE-DOOR ,LOCKEDBIT>
		<TELL
"Across the hall, the little door slams in the draught from the garden,
and its lock clicks shut. Doors here are quick to take advantage." CR>)>
	 <COND (<AND <==? .NEW 1>
		     <EQUAL? ,HERE ,HALL>
		     ,POOL-EXISTS
		     <NOT ,POOL-GONE>>
		<POOL-SLIP>)>
	 T>

<ROUTINE POOL-SLIP ()
	 <COND (<NOT ,F-FANOUT>
		<SETG F-FANOUT T>
		<SCORE-UPD 3>)>
	 <TELL
"Your foot slides -- splash! You are up to your chin in salt water, and
the pool has opinions about where you are going." CR CR>
	 <GOTO ,POOL>>

<ROUTINE RANK-NAME ()
	 <COND (<G? ,SCORE 99> <TELL "Quite Mad, Thank You">)
	       (<G? ,SCORE 74> <TELL "Almost Entirely Mad">)
	       (<G? ,SCORE 49> <TELL "Uncommonly Nonsensical">)
	       (<G? ,SCORE 24> <TELL "Curiouser and Curiouser">)
	       (T <TELL "Perfectly Sensible Child">)>>

"Baby-and-ambient heartbeat, called from every room action at M-END."
<ROUTINE WORLD-PULSE ()
	 <COND (<AND <IN? ,THE-BABY ,WINNER>
		     <G? ,BABY-STATE 0>
		     <NOT <EQUAL? ,HERE ,KITCHEN>>>
		<COND (<==? ,BABY-STATE 1>
		       <SETG BABY-STATE 2>
		       <TELL
"The baby wriggles in your arms and says nothing, which from this baby
is a mercy." CR>)
		      (<==? ,BABY-STATE 2>
		       <SETG BABY-STATE 3>
		       <TELL
"The baby grunts. You look anxiously into its face: it has a very
turn-up nose, much more like a snout than a real nose." CR>)
		      (<==? ,BABY-STATE 3>
		       <SETG BABY-STATE 4>
		       <COND (<NOT ,F-BABY>
			      <SETG F-BABY T>
			      <SCORE-UPD 4>)>
		       <REMOVE ,THE-BABY>
		       <TELL
"This time there can be NO mistake about it: it is neither more nor less
than a pig. It wriggles free of your arms and trots quietly into the
wood. If it had grown up, it would have made a dreadfully ugly child;
but it makes rather a handsome pig, you think." CR>
		       <COND (<NOT ,PIGFIG-DONE>
			      <SETG PIGFIG-PENDING T>)>)>)>
	 <RFALSE>>

<ROUTINE PLAIN-ROOM-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-END> <WORLD-PULSE>)>
	 <RFALSE>>

"=================== ENGINE-REQUIRED ROUTINES ==================="

<ROUTINE V-SCORE ("OPTIONAL" (ASK? T))
	 <TELL "Your score is " N ,SCORE " of a possible " N ,SCORE-MAX
	       ", in " N ,MOVES>
	 <COND (<1? ,MOVES> <TELL " move.">)
	       (T <TELL " moves.">)>
	 <TELL " That earns you the rank of ">
	 <RANK-NAME>
	 <TELL "." CR>
	 ,SCORE>

<ROUTINE V-DIAGNOSE ()
	 <TELL
"You are in perfect health, and exactly ">
	 <COND (<SMALL?> <TELL "ten inches">)
	       (<NORMAL?> <TELL "the right number of inches">)
	       (T <TELL "nine feet">)>
	 <TELL " tall, which is worth knowing." CR>>

"Nothing bad ever really happens. JIGS-UP is the engine's death handler;
here it is a pardon machine."
<ROUTINE JIGS-UP (DESC "OPTIONAL" (PLAYER? <>))
	 <TELL .DESC CR>
	 <TELL
"-- or so it would go, anywhere else. Nothing of the sort happens here.
Nobody is ever the worse for anything in Wonderland; you feel slightly
embarrassed instead, which passes." CR>
	 <RTRUE>>

<ROUTINE FIND-WEAPON (WHO)
	 <RFALSE>>

"=================== REDEFINED ENGINE DEFAULTS (in voice) ==================="

<ROUTINE V-PRAY ()
	 <TELL
"You put your hands together. Somewhere a queen shouts about heads, a
kettle sings, and the afternoon continues, which is as much answer as
afternoons give." CR>>

<ROUTINE V-WISH ()
	 <TELL
"You wish, on the whole, that you were the right size, in the right
place, at the right time. The wish files itself for later." CR>>

<ROUTINE V-CURSES ()
	 <TELL
"You think of a very cross word, and decide against it. Temper never
answers here; it only makes the furniture smug." CR>>

<ROUTINE V-YELL ()
	 <COND (<AND <==? ,SIEGE-PHASE 4> <EQUAL? ,HERE ,RABBIT-ROOM>>
		<SIEGE-SILENCE>)
	       (T
		<TELL
"You shout, and the shout comes back a moment later, a little improved
by travel." CR>)>>

<ROUTINE V-LEAP ("AUX" TX S)
	 <TELL
"You jump on the spot. The spot bears it patiently." CR>>

<ROUTINE V-WALK-AROUND ()
	 <COND (<EQUAL? ,HERE ,SHORE> <DO-CAUCUS>)
	       (T
		<TELL
"You run a little way and back again. The exercise is its own reward,
which is fortunate, as it is certainly nobody else's." CR>)>>

<ROUTINE V-SWIM ()
	 <COND (<EQUAL? ,HERE ,POOL> <POOL-SWIM-WEST>)
	       (T
		<TELL
"There is nothing here to swim in but air, and you never learned." CR>)>>

<ROUTINE V-SMELL ()
	 <COND (<EQUAL? ,PRSO ,PEPPERBOX> <SNEEZE-TEXT>)
	       (T
		<TELL "It smells exactly as it looks, only fainter." CR>)>>

"=================== NEW VERB ROUTINES ==================="

<ROUTINE V-CRY ()
	 <COND (<AND <EQUAL? ,HERE ,HALL> <LARGE?> <NOT ,POOL-EXISTS>>
		<MAKE-POOL>)
	       (<AND <EQUAL? ,HERE ,HALL> <NOT ,POOL-EXISTS>>
		<TELL
"You cry a very small puddle, suitable for a beetle's boating holiday.
Grief on the useful scale wants a larger girl." CR>)
	       (<EQUAL? ,HERE ,POOL>
		<TELL
"You add to your own pool, which hardly needs the encouragement." CR>)
	       (T
		<TELL
"You feel about for a sorrow and find only curiosity, which does not
water well." CR>)>>

<ROUTINE MAKE-POOL ()
	 <SETG POOL-EXISTS T>
	 <SETG RABBIT-DUE T>
	 <COND (<NOT ,F-POOL>
		<SETG F-POOL T>
		<SCORE-UPD 3>)>
	 <TELL
"You sit down and cry -- being nine feet tall, you do it wholesale. You
shed gallons of tears, until there is a large pool all round you, four
inches deep and reaching half down the hall." CR>>

<ROUTINE V-SING ()
	 <COND (<EQUAL? ,HERE ,POOL ,SHORE>
		<TELL
"You sing, treading water: \"How doth the little crocodile improve his
shining tail, and pour the waters of the Nile on every golden scale! How
cheerfully he seems to grin, how neatly spread his claws, and welcome
little fishes in, with gently smiling jaws!\" It is not the lesson you
meant to know, but it is the one that came." CR>)
	       (<EQUAL? ,HERE ,TEA-GARDEN>
		<TELL
"You try a verse: \"Twinkle, twinkle, little bat! How I wonder what
you're at! Up above the world you fly, like a tea-tray in the sky.\"">
		<COND (<IN? ,THE-HATTER ,TEA-GARDEN>
		       <TELL
" The Hatter goes pale. \"That's the very song,\" he whispers. \"He's
murdering the time! they said. And it was never me murdered it at
all.\"">)>
		<CRLF>)
	       (<AND <EQUAL? ,HERE ,TURTLE-ROCK> <NOT ,SEASIDE-OPEN>>
		<TELL "You hum a bar or two; the sea sighs along." CR>)
	       (<EQUAL? ,HERE ,TURTLE-ROCK>
		<TURTLE-SOUP-SONG>)
	       (<AND <==? ,CATERPILLAR-PHASE 2>
		     <EQUAL? ,HERE ,MUSHROOM-CLEARING>>
		<DO-FATHER-WILLIAM>)
	       (T
		<TELL
"You sing a verse about a crocodile. Nobody asked, but nobody minds;
that is the great advantage of the open air." CR>)>>

<ROUTINE V-DANCE ()
	 <COND (<AND <EQUAL? ,HERE ,TURTLE-ROCK> <G? ,TURTLE-TALKS 0>>
		<DO-QUADRILLE>)
	       (T
		<TELL
"You dance a few figures of a quadrille with nobody, and keep your own
toes clear of your own feet, mostly." CR>)>>

<ROUTINE V-RECITE ()
	 <COND (<AND <==? ,CATERPILLAR-PHASE 2>
		     <EQUAL? ,HERE ,MUSHROOM-CLEARING>>
		<DO-FATHER-WILLIAM>)
	       (T
		<TELL
"You fold your hands and begin the multiplication table, which comes out
four times five is twelve, and four times six is thirteen, and you stop
before arithmetic suffers further." CR>)>>

<ROUTINE V-PAINT ()
	 <COND (<AND <EQUAL? ,HERE ,GARDEN>
		     <EQUAL? ,PRSO ,ROSE-TREE>>
		<DO-PAINT-ROSES>)
	       (T
		<TELL
"You have neither the paint nor the standing to redecorate that." CR>)>>

<ROUTINE V-CURTSEY ()
	 <COND (<EQUAL? ,PRSO ,THE-QUEEN>
		<TELL
"You drop your best curtsey. The Queen inclines her head one royal
quarter-inch, which from her is a parade." CR>)
	       (<EQUAL? ,PRSO ,THE-KING>
		<TELL
"You curtsey. The King bows back so mildly that his crown slips over
his wig, and he rights it with an apology to the crown." CR>)
	       (<EQUAL? ,PRSO ,CATERPILLAR>
		<TELL
"You curtsey to the Caterpillar, who watches the whole operation and
says, \"Why?\"" CR>)
	       (<EQUAL? ,PRSO ,FROG-FOOTMAN>
		<TELL
"You curtsey. The Footman bows so low that his curls tangle in his own
buttons, and he stays that way some time, on principle." CR>)
	       (<AND ,PRSO <FSET? ,PRSO ,ACTORBIT>>
		<TELL
"You curtsey to " D ,PRSO ", who returns it after the fashion of the
house." CR>)
	       (<EQUAL? ,HERE ,FALLING>
		<TELL
"You attempt a curtsey in mid-air. Fancy curtseying as you're falling!
Do you think you could manage it?" CR>)
	       (T
		<TELL
"You drop a very correct curtsey. Wonderland, which is always watching,
approves." CR>)>>

<ROUTINE V-STROKE ()
	 <COND (<EQUAL? ,PRSO ,FLAMINGO> <TAME-FLAMINGO>)
	       (<EQUAL? ,PRSO ,THE-PUPPY>
		<TELL
"You pat what you can reach of the puppy, which is delighted beyond the
scale of the event." CR>)
	       (<EQUAL? ,PRSO ,CHESHIRE-CAT ,HEARTH-CAT>
		<TELL
"You stroke the cat, carefully, starting from the grin and working
outward." CR>)
	       (<AND ,PRSO <FSET? ,PRSO ,ACTORBIT>>
		<TELL "You give " D ,PRSO " a friendly pat, which is
received as a state occasion." CR>)
	       (T
		<TELL "You give it a pat. It bears up." CR>)>>

<ROUTINE V-WHISTLE ()
	 <COND (<AND <EQUAL? ,HERE ,THICK-WOOD>
		     <SMALL?>
		     <NOT ,PUPPY-BUSY>>
		<TELL
"You whistle. The puppy cocks its head at an angle suggesting deep
thought in a shallow vessel. It is charmed; it is not moved." CR>)
	       (T
		<TELL
"You whistle a bar of something. A bird somewhere corrects your
pitch." CR>)>>

<ROUTINE V-RACE ()
	 <COND (<EQUAL? ,HERE ,SHORE> <DO-CAUCUS>)
	       (T
		<TELL
"There is no race here. Wonderland is strict about the order of its
nonsense." CR>)>>

<ROUTINE V-SHOW ()
	 <COND (<AND <EQUAL? ,PRSO ,INVITATION>
		     <EQUAL? ,PRSI ,THE-QUEEN>>
		<SHOW-INVITATION>)
	       (<AND ,PRSI <FSET? ,PRSI ,ACTORBIT>>
		<TELL
"You hold up " D ,PRSO " for inspection. " D ,PRSI " inspects it with
the expression of one who has seen better." CR>)
	       (T
		<TELL "It declines to look." CR>)>>

<ROUTINE V-REACH ()
	 <COND (<AND <==? ,SIEGE-PHASE 1> <EQUAL? ,HERE ,RABBIT-ROOM>>
		<SIEGE-SNATCH>)
	       (T
		<TELL
"You reach out. The world stays exactly where it was, at arm's length
plus one inch." CR>)>>

<ROUTINE V-FAN ()
	 <COND (<AND <NOT <IN? ,THE-FAN ,WINNER>>
		     <NOT <IN? ,SPARE-FAN ,WINNER>>>
		<TELL "You have no fan, and hands make poor ones." CR>)
	       (T <DO-FANNING>)>>

<ROUTINE DO-FANNING ("AUX" F)
	 <COND (<IN? ,THE-FAN ,WINNER> <SET F ,THE-FAN>)
	       (T <SET F ,SPARE-FAN>)>
	 <COND (<G? ,SIEGE-PHASE 0>
		<TELL
"There is no room in here to wave anything, including doubts." CR>)
	       (<SMALL?>
		<MOVE .F ,HERE>
		<TELL
"You go on fanning, and shrink so fast that you are nearly snuffed out
altogether, like a candle -- you drop the fan just in time, and it lies
at your feet, looking innocent. You remain exactly as small as is
survivable." CR>)
	       (<NORMAL?>
		<TELL
"You fan yourself, and shrink with alarming enthusiasm: down past
shelves, past hopes, to ten inches or so." CR>
		<CHANGE-SIZE 1 T>)
	       (T
		<TELL
"You fan yourself as you talk, and find with a start that you have
shrunk back to your usual height. The fan is rapid work." CR>
		<CHANGE-SIZE 2 T>)>>

<ROUTINE V-REFUSE ()
	 <COND (<AND <EQUAL? ,HERE ,COURTROOM> <==? ,TRIAL-PHASE 8>>
		<DO-MILE-HIGH>)
	       (T
		<TELL
"You refuse, on general principles. The principles accept." CR>)>>

<ROUTINE V-THREATEN ()
	 <COND (<AND <==? ,SIEGE-PHASE 4> <EQUAL? ,HERE ,RABBIT-ROOM>>
		<SIEGE-SILENCE>)
	       (T
		<TELL
"You assume your most dangerous expression. Wonderland, which has met
queens, is not visibly moved." CR>)>>

<ROUTINE V-NONSENSE ()
	 <SAY-NONSENSE>>

<ROUTINE V-YES ()
	 <COND (<AND <EQUAL? ,HERE ,GARDEN> <==? ,QUEEN-PHASE 4>>
		<START-CROQUET>)
	       (<AND <EQUAL? ,HERE ,TEA-GARDEN> <G? ,STAY-OFFER 0>>
		<STAY-FOREVER>)
	       (T
		<TELL "You sound rather positive." CR>)>>

<ROUTINE V-NO ()
	 <COND (<AND <EQUAL? ,HERE ,COURTROOM> <==? ,TRIAL-PHASE 8>>
		<DO-MILE-HIGH>)
	       (<AND <EQUAL? ,HERE ,TREETOPS> <L? ,PIGEON-PHASE 2>>
		<PIGEON-PROMISE>)
	       (T
		<TELL "You sound rather negative." CR>)>>

<ROUTINE V-SIT ()
	 <COND (<EQUAL? ,HERE ,TEA-GARDEN> <DO-TEA-SIT>)
	       (<EQUAL? ,HERE ,RIVERBANK>
		<TELL
"You are sitting already, as hard as can be managed on so warm an
afternoon." CR>)
	       (T
		<TELL
"You sit down for a moment. Wonderland continues at its usual pace,
which is headlong." CR>)>>

<ROUTINE V-KICK-BARE ()
	 <COND (<AND <==? ,SIEGE-PHASE 3> <EQUAL? ,HERE ,RABBIT-ROOM>>
		<SIEGE-KICK>)
	       (T
		<TELL
"You kick at nothing in particular, and hit it squarely." CR>)>>

<ROUTINE V-LISTEN-BARE ()
	 <COND (<EQUAL? ,HERE ,TURTLE-ROCK> <TURTLE-HISTORY>)
	       (<EQUAL? ,HERE ,DUCHESS-LAWN>
		<TELL
"From inside: a howl, a sneeze, and the death of another dish." CR>)
	       (T
		<TELL
"You listen. Somewhere far off, crockery is being decided against." CR>)>>

"SAY <word> dispatch. Quoted SAY is intercepted at M-BEG by the rooms
that care; this handles the unquoted object form."
<ROUTINE V-SAY-WORD ()
	 <COND (<EQUAL? ,PRSO ,W-NONSENSE> <SAY-NONSENSE>)
	       (<EQUAL? ,PRSO ,W-ALICE>
		<COND (<AND <EQUAL? ,HERE ,GARDEN> <==? ,QUEEN-PHASE 1>>
		       <QUEEN-NAME-GIVEN>)
		      (T
		       <TELL
"\"Alice,\" you say, to be going on with. It is a good name and you are
glad of the practice." CR>)>)
	       (<EQUAL? ,PRSO ,W-PIG>
		<COND (<AND <EQUAL? ,HERE ,CROSSROADS> ,PIGFIG-PENDING>
		       <SETG PIGFIG-PENDING <>>
		       <SETG PIGFIG-DONE T>
		       <TELL
"\"Pig,\" you say. \"I thought it would,\" says the Cat, and vanishes
quite slowly, beginning with the end of the tail and ending with the
grin, which remains some time after the rest of it has gone." CR>)
		      (T
		       <TELL
"\"Pig!\" you say, to nobody in particular, and feel briefly like a
duchess." CR>)>)
	       (<EQUAL? ,PRSO ,W-MILE>
		<COND (<EQUAL? ,HERE ,COURTROOM> <DO-MILE-HIGH>)
		      (T
		       <TELL
"You mention a mile. Nobody here has ever measured anything, and they
are not going to start." CR>)>)
	       (<EQUAL? ,PRSO ,W-NOTHING>
		<COND (<AND <EQUAL? ,HERE ,COURTROOM> <==? ,TRIAL-PHASE 5>>
		       <DO-NOTHING-WHATEVER>)
		      (T
		       <TELL "You say nothing, at some length." CR>)>)
	       (<EQUAL? ,PRSO ,T-DINAH>
		<COND (<EQUAL? ,HERE ,SHORE> <DINAH-SCATTER>)
		      (<AND <EQUAL? ,HERE ,CROSSROADS>
			    <NOT <IN? ,CHESHIRE-CAT ,CROSSROADS>>>
		       <CAT-RETURNS>)
		      (T
		       <TELL
"\"Dinah!\" you say fondly. Dinah, being a cat and elsewhere, does not
come." CR>)>)
	       (<EQUAL? ,PRSO ,W-POEM> <V-RECITE>)
	       (T
		<TELL
"You say it, clearly and with feeling. Wonderland listens politely and
files it under evidence." CR>)>>

<ROUTINE SAY-NONSENSE ()
	 <COND (<AND <EQUAL? ,HERE ,COURTROOM> <==? ,TRIAL-PHASE 10>>
		<DO-FINALE>)
	       (<AND <EQUAL? ,HERE ,GARDEN> <==? ,QUEEN-PHASE 3>>
		<QUEEN-NONSENSED>)
	       (<AND <EQUAL? ,HERE ,COURTROOM> <G? ,TRIAL-PHASE 0>>
		<TELL
"\"Nonsense!\" you say. Several jurors write it down as evidence. The
moment for it, you feel, is coming but not come." CR>)
	       (T
		<TELL
"\"Nonsense!\" you say, very loudly and decidedly. Nothing in particular
was being sensible just then, but it does no harm to be ahead of
events." CR>)>>

"=================== INTRO ==================="

<ROUTINE INTRO-TEXT ()
	 <TELL
"You are beginning to get very tired of sitting by your sister on the
bank, and of having nothing to do. Once or twice you have peeped into
the book she is reading, but it has no pictures or conversations in it
-- and what is the use of a book without pictures or conversations? The
day is hot, and you feel very sleepy and stupid, and you are considering
whether the pleasure of making a daisy-chain is worth the trouble of
getting up, when a White Rabbit with pink eyes runs close by you." CR CR
"There is nothing so very remarkable in that. Nor is it so very much out
of the way to hear the Rabbit say to itself, \"Oh dear! Oh dear! I shall
be late!\" But when the Rabbit actually takes a watch out of its
waistcoat-pocket, and looks at it, and hurries on -- you start to your
feet. You have never before seen a rabbit with either a
waistcoat-pocket, or a watch to take out of it." CR CR
"Burning with curiosity, you are Alice; the afternoon is golden; and
somewhere under the hedge ahead of you, a large rabbit-hole is waiting,
going down and down and down." CR CR
"WONDERLAND -- an interactive nonsense, after Lewis Carroll." CR CR>>

"=================== ACT ONE: RIVERBANK ==================="

<ROUTINE RIVERBANK-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-END>
		<COND (<NOT ,RABBIT-SEEN>
		       <SETG RABBIT-SEEN T>
		       <MOVE ,WHITE-RABBIT ,RIVERBANK>
		       <TELL CR
"The White Rabbit runs close by your feet, crying \"Oh dear! Oh dear! I
shall be late!\" -- takes the watch out of its waistcoat-pocket, looks
at it, and hurries on toward the hedge to the north." CR>)
		      (<AND ,RABBIT-SEEN
			    <IN? ,WHITE-RABBIT ,RIVERBANK>>
		       <SETG RIVER-WAITS <+ ,RIVER-WAITS 1>>
		       <COND (<==? ,RIVER-WAITS 2>
			      <TELL CR
"The daisies consider making a chain of you. Northward, a white scut
disappears under the hedge." CR>)>)>
		<WORLD-PULSE>)>>

<ROUTINE RIVERBANK-NORTH ()
	 <COND (,RABBIT-SEEN
		<MOVE ,WHITE-RABBIT ,LOCAL-GLOBALS>
		<RETURN ,HEDGE-FIELD>)
	       (T
		<TELL "There is nothing worth getting up for. Yet." CR>
		<RFALSE>)>>

<ROUTINE SISTER-FCN ()
	 <COND (<VERB? TELL HELLO>
		<TELL
"\"Mmm,\" says your sister, in the voice of somebody nine chapters deep.
\"That's nice, dear.\"" CR>
		<SETG P-CONT <>>
		<SETG QUOTE-FLAG <>>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"Your sister is reading with the terrible concentration of the grown,
or nearly grown. She has not looked up in an hour." CR>
		<RTRUE>)
	       (<VERB? KISS>
		<TELL
"You kiss her cheek. \"Mmm,\" she says, and turns a page." CR>
		<RTRUE>)>>

<ROUTINE STORY-BOOK-FCN ()
	 <COND (<VERB? EXAMINE READ>
		<TELL
"It has no pictures or conversations in it. What is the use of a book
without pictures or conversations?" CR>
		<RTRUE>)
	       (<VERB? TAKE>
		<TELL
"Your sister holds it in the grip of the truly absorbed. Easier to take
the river." CR>
		<RTRUE>)>>

<ROUTINE DAISIES-FCN ()
	 <COND (<VERB? TAKE PICK>
		<TELL
"You gather a few, for a chain you will never finish." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"White, gold-hearted, and almost worth the trouble of getting up." CR>
		<RTRUE>)>>

<ROUTINE WHITE-RABBIT-FCN ()
	 <COND (<AND <VERB? TELL HELLO CURTSEY>
		     ,RABBIT-IN-HALL
		     <EQUAL? ,HERE ,HALL>>
		<RABBIT-DROPS-THINGS>
		<RTRUE>)
	       (<AND <VERB? GIVE>
		     <EQUAL? ,PRSI ,WHITE-RABBIT>
		     <EQUAL? ,PRSO ,KID-GLOVES ,THE-FAN>>
		<GIVE-GLOVES-BACK>
		<RTRUE>)
	       (<VERB? FOLLOW>
		<COND (<EQUAL? ,HERE ,RIVERBANK>
		       <DO-WALK ,P?NORTH>
		       <RTRUE>)
		      (T
		       <TELL
"He is faster than you at every size you have tried so far." CR>
		       <RTRUE>)>)
	       (<VERB? EXAMINE>
		<TELL
"A white rabbit in a waistcoat, with pink eyes and a watch, in a state
of lateness so advanced it has become a way of life." CR>
		<RTRUE>)
	       (<VERB? TELL HELLO>
		<TELL
"\"Oh dear! Oh dear!\" says the Rabbit, to itself rather than to you; it
has no time for conversation, or indeed anything else; time is exactly
what it is short of." CR>
		<SETG P-CONT <>>
		<SETG QUOTE-FLAG <>>
		<RTRUE>)
	       (<VERB? TAKE ATTACK>
		<TELL
"He is off before your hand arrives. Lateness has made him quick." CR>
		<RTRUE>)>>

<ROUTINE HEDGE-FIELD-FCN (RARG)
	 <COND (<AND <EQUAL? .RARG ,M-BEG>
		      <VERB? WALK>
		      <EQUAL? ,PRSO ,P?IN>>
		<GOTO <HEDGE-DOWN>>
		<RTRUE>)
	       (<EQUAL? .RARG ,M-END> <WORLD-PULSE>)>>

<ROUTINE HEDGE-DOWN ()
	 <SETG FALL-PHASE 1>
	 <TELL
"In another moment down you go after it, never once considering how in
the world you are to get out again. The hole dips suddenly down, and you
are falling -- slowly, comfortably, absurdly -- past shelves and
cupboards set into the walls of the well. A jar drifts by at arm's
length, labelled ORANGE MARMALADE." CR CR>
	 <RETURN ,FALLING>>

<ROUTINE RABBIT-HOLE-FCN ()
	 <COND (<VERB? KNOCK>
		<TELL
"You knock politely at the mouth of the rabbit-hole. The hole, having no
door, no owner, and no manners, does not reply." CR>
		<RTRUE>)
	       (<VERB? EXAMINE LOOK-INSIDE>
		<TELL
"A large rabbit-hole, going down. From somewhere in it, faintly: \"Oh my
ears and whiskers, how late it's getting!\"" CR>
		<RTRUE>)
	       (<VERB? THROUGH BOARD CLIMB-DOWN>
		<DO-WALK ,P?DOWN>
		<RTRUE>)>>

"=================== THE FALL ==================="

<ROUTINE FALLING-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<TELL
"You are falling, slowly and comfortably, past shelves and cupboards set
into the walls of the well. Down, down, down." CR>
		<RTRUE>)
	       (<EQUAL? .RARG ,M-END>
		<COND (<VERB? INVENTORY EXAMINE>
		       <RFALSE>)
		      (<==? ,FALL-PHASE 1>
		       <SETG FALL-PHASE 2>
		       <TELL CR
"Down, down, down. You wonder how many miles you have fallen, and
whether cats eat bats, and whether bats eat cats, and find you cannot
answer either question, which makes them equally good questions." CR>)
		      (<==? ,FALL-PHASE 2>
		       <SETG FALL-PHASE 3>
		       <TELL CR
"Shelves, and cupboards, and here and there a map or a picture hung upon
a peg, and still no bottom to speak of. After a fall like this, you
think, you shall think nothing of tumbling down stairs." CR>)
		      (<==? ,FALL-PHASE 3>
		       <SETG FALL-PHASE 4>
		       ;"The jar rides the whole way down with you. A player who
			 spends the fall typing words the parser does not know
			 must not lose a scoreable item for it."
		       <COND (<IN? ,MARMALADE-JAR ,FALLING>
			      <MOVE ,MARMALADE-JAR ,LOCAL-GLOBALS>)>
		       <TELL CR
"Thump! Thump! You land on a heap of sticks and dry leaves, not a bit
hurt." CR CR>
		       <GOTO ,LEAF-HEAP>)>)>>

<ROUTINE MARMALADE-JAR-FCN ()
	 <COND (<AND <VERB? GIVE SHOW PUT>
		     <EQUAL? ,HERE ,TEA-GARDEN>
		     <IN? ,TREACLE-GOO ,MARMALADE-JAR>>
		<FIX-THE-WATCH>
		<RTRUE>)
	       (<AND <VERB? FILL> <EQUAL? ,HERE ,TREACLE-WELL>>
		<FILL-THE-JAR>
		<RTRUE>)
	       (<AND <VERB? TAKE> <NOT <IN? ,MARMALADE-JAR ,ADVENTURER>>>
		<MOVE ,MARMALADE-JAR ,ADVENTURER>
		;"A custom MOVE skips what the engine's take path does for free:
		  clear NDESCBIT or the jar stays invisible to INVENTORY."
		<FCLEAR ,MARMALADE-JAR ,NDESCBIT>
		<FSET ,MARMALADE-JAR ,TOUCHBIT>
		<COND (<NOT ,F-JAR>
		       <SETG F-JAR T>
		       <SCORE-UPD 2>)>
		<TELL
"You take the jar as it drifts past. It is empty, but a jar is a jar,
and you are falling past a great many cupboards with nothing else to
show for it." CR>
		<RTRUE>)
	       (<VERB? EXAMINE LOOK-INSIDE>
		<COND (<IN? ,TREACLE-GOO ,MARMALADE-JAR>
		       <TELL
"The label still says ORANGE MARMALADE, which is now a lie, because the
jar is full to the brim with treacle." CR>)
		      (T
		       <TELL
"A jar labelled ORANGE MARMALADE -- but to your great disappointment it
is empty. A jar this determined to be useful will surely find its
moment." CR>)>
		<RTRUE>)
	       (<VERB? EAT>
		<TELL
"There is no marmalade in it. Eating the label would be showing
off." CR>
		<RTRUE>)>>

<ROUTINE WELL-SHELVES-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"Cupboards and book-shelves, with here and there a map or a picture
hung upon a peg, all going up -- or rather, you are going down." CR>
		<RTRUE>)
	       (<VERB? TAKE>
		<TELL
"They pass at exactly the speed of your falling, which is a polite way
of staying out of reach." CR>
		<RTRUE>)>>

<ROUTINE LEAF-HEAP-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-ENTER>
		<TELL
"Down a long passage to the north, still in sight, hurries the White
Rabbit." CR>)
	       (<EQUAL? .RARG ,M-END> <WORLD-PULSE>)>>

<ROUTINE DRY-LEAVES-FCN ()
	 <COND (<VERB? EXAMINE SEARCH LOOK-UNDER>
		<TELL
"Sticks and dry leaves, arranged by providence for the reception of
falling children. Nothing underneath but more of the same." CR>
		<RTRUE>)
	       (<VERB? TAKE>
		<TELL
"You have outgrown collecting leaves, or at any rate you tell yourself
so." CR>
		<RTRUE>)>>

"=================== THE HALL OF DOORS ==================="

<ROUTINE HALL-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<HALL-LOOK>
		<RTRUE>)
	       (<EQUAL? .RARG ,M-ENTER>
		<COND (<SMALL?>
		       <COND (<NOT <IN? ,MOUSE-HOLE-DOOR ,HALL>>
			      <MOVE ,MOUSE-HOLE-DOOR ,HALL>)>)>)
	       (<EQUAL? .RARG ,M-BEG>
		<COND (<AND <VERB? SAY>
			    <NOT ,PRSO>
			    ,P-CONT
			    <EQUAL? <GET ,P-LEXV ,P-CONT> ,W?NONSENSE>>
		       <SETG P-CONT <>>
		       <SETG QUOTE-FLAG <>>
		       <SAY-NONSENSE>
		       <RTRUE>)>)
	       (<EQUAL? .RARG ,M-END>
		<COND (<AND ,RABBIT-DUE <NOT ,RABBIT-IN-HALL>>
		       <SETG RABBIT-DUE <>>
		       <SETG RABBIT-IN-HALL T>
		       <MOVE ,WHITE-RABBIT ,HALL>
		       <TELL CR
"A pattering of feet: the White Rabbit returns, splendidly dressed, a
pair of white kid gloves in one hand and a large fan in the other,
muttering \"Oh! the Duchess, the Duchess! Oh! won't she be savage if
I've kept her waiting!\" He has not noticed you, which at your present
size takes doing." CR>)>
		<WORLD-PULSE>)>>

<ROUTINE HALL-LOOK ()
	 <COND (<SMALL?>
		<TELL
"The hall is a cathedral now, its lamps far off as stars. The glass
table stands over you like a monument on stilts; its top might as well
be the moon. Down by the skirting-board, quite at your own scale, is a
tidy little mouse-hole.">)
	       (<NORMAL?>
		<TELL
"You are in a long, low hall, lit by a row of lamps hanging from the
roof. Doors stand all round it, every one of them locked. In the middle
is a little three-legged table made of solid glass.">)
	       (T
		<TELL
"You fill a startling amount of this hall, and stoop so your head does
not strike the roof. The doors look like doll-house furnishings, and
the glass table stands about knee-high.">)>
	 <COND (<NOT ,CURTAIN-MOVED>
		<TELL " Along one wall hangs a low curtain.">)
	       (T
		<TELL
" Behind the drawn-back curtain is the little door, fifteen inches
high">
		<COND (<FSET? ,LITTLE-DOOR ,OPENBIT>
		       <TELL ", standing open">)>
		<TELL ".">)>
	 <COND (<IN? ,GOLDEN-KEY ,GLASS-TABLE>
		<COND (<SMALL?>
		       <TELL
" Through the glass of the table-top, plain as anything and utterly out
of reach, gleams the golden key.">)
		      (T
		       <TELL
" On the table lies a tiny golden key.">)>)>
	 <COND (<IN? ,DRINK-BOTTLE ,GLASS-TABLE>
		<TELL
" On the table stands a little bottle with a paper label round its
neck.">)>
	 <COND (<AND ,BOX-REVEALED <IN? ,GLASS-BOX ,HALL>>
		<TELL
" Under the table sits the little glass box.">)>
	 <COND (<AND ,POOL-EXISTS <NOT ,POOL-GONE>>
		<TELL
" The low end of the hall is a sheet of salt water, four inches deep and
entirely your own work.">)>
	 <CRLF>>

<ROUTINE LITTLE-DOOR-EXIT ()
	 <COND (<NOT ,CURTAIN-MOVED>
		<TELL
"You walk the length of the west wall. Nothing offers but the locked
doors and a low curtain, hanging to the floor." CR>
		<RFALSE>)
	       (<NOT <FSET? ,LITTLE-DOOR ,OPENBIT>>
		<COND (<FSET? ,LITTLE-DOOR ,LOCKEDBIT>
		       <TELL
"The little door is locked. It is the sort of door that means it." CR>)
		      (T
		       <TELL
"The door is unlocked, shut, and fifteen inches of solid smugness." CR>)>
		<RFALSE>)
	       (<SMALL?>
		<COND (<NOT ,F-GARDEN>
		       <SETG F-GARDEN T>
		       <SCORE-UPD 6>)>
		<TELL
"You walk down the little passage, no larger than a rat-hole -- and
THEN -- you find yourself at last in the beautiful garden, among the
bright flower-beds and the cool fountains." CR CR>
		<RETURN ,GARDEN>)
	       (<NORMAL?>
		<SETG ENTRY-FAILS <+ ,ENTRY-FAILS 1>>
		<TELL
"Beyond the little door, down a passage not much larger than a rat-hole,
lies the loveliest garden you ever saw: beds of bright flowers and cool
fountains. You kneel and try -- and cannot even get your head through
the doorway; and even if your head would go through, it would be of very
little use without your shoulders. Oh, how you wish you could shut up
like a telescope!" CR>
		<COND (<NOT ,BOTTLE-APPEARED>
		       <SETG BOTTLE-APPEARED T>
		       <MOVE ,DRINK-BOTTLE ,GLASS-TABLE>
		       <TELL CR
"You go back to the table, half hoping to find another key on it, or at
any rate a book of rules for shutting people up like telescopes. Instead
there is a little bottle (\"which certainly was not here before,\" you
think), with a paper label round its neck: DRINK ME, beautifully printed
in large letters." CR>)>
		<RFALSE>)
	       (T
		<SETG ENTRY-FAILS <+ ,ENTRY-FAILS 1>>
		<TELL
"You lie down on one side and look into the garden with one eye, which
is as much of you as will ever fit. The flowers are very bright, and
very far beyond the fifteen inches of doorway." CR>
		<COND (<AND <G? ,ENTRY-FAILS 1>
			    <LARGE?>
			    <NOT ,POOL-EXISTS>>
		       <TELL CR "There is nothing else for it. ">
		       <MAKE-POOL>)>
		<RFALSE>)>>

<ROUTINE MOUSE-HOLE-EXIT ()
	 <COND (<SMALL?> <RETURN ,MOUSE-HOLE>)
	       (T
		<TELL
"Down by the skirting-board there may or may not be a mouse-hole; at
your height it is beneath notice, and you are above fitting." CR>
		<RFALSE>)>>

<ROUTINE GLASS-TABLE-FCN ()
	 <COND (<VERB? LOOK-UNDER>
		<COND (<AND <SMALL?> <NOT ,BOX-REVEALED>>
		       <REVEAL-BOX>
		       <RTRUE>)
		      (<AND ,BOX-REVEALED <IN? ,GLASS-BOX ,HALL>>
		       <TELL
"The little glass box sits under there, waiting with the patience of
furniture." CR>
		       <RTRUE>)
		      (T
		       <TELL
"Nothing under there but shadow and a certain smugness." CR>
		       <RTRUE>)>)
	       (<AND <VERB? CLIMB-UP CLIMB-FOO CLIMB-ON BOARD> <SMALL?>>
		<TELL
"You try your best to climb up one of the legs of the table, but it is
far too slippery; you slide down politely, twice, and sit down to get
your breath." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<COND (<SMALL?>
		       <TELL
"Three glass legs like frozen waterfalls, and a top as far away as
weather.">)
		      (T
		       <TELL
"A little three-legged table, all made of solid glass.">)>
		<COND (<IN? ,GOLDEN-KEY ,GLASS-TABLE>
		       <TELL " The golden key lies on it.">)>
		<COND (<IN? ,DRINK-BOTTLE ,GLASS-TABLE>
		       <TELL " The little bottle stands on it.">)>
		<CRLF>
		<RTRUE>)>>

<ROUTINE REVEAL-BOX ()
	 <SETG BOX-REVEALED T>
	 <MOVE ,GLASS-BOX ,HALL>
	 <TELL
"Down here you can see under the table, and there, quite overlooked from
above, lies a little glass box. Through its sides you can make out a
very small cake." CR>>

<ROUTINE GOLDEN-KEY-FCN ()
	 <COND (<VERB? EAT>
		<TELL
"It is gold, and you are a child of some breeding." CR>
		<RTRUE>)
	       (<AND <VERB? TAKE> <SMALL?> <IN? ,GOLDEN-KEY ,GLASS-TABLE>>
		<TELL
"You can see it quite plainly through the glass, and you try your best
to climb up one of the legs of the table, but it is too slippery. The
key might as well be the moon's." CR>
		<RTRUE>)
	       (<AND <VERB? TAKE> <SMALL?>>
		<TELL
"The key is nearly as long as you are; you could no more walk off with
it than with a ladder." CR>
		<RTRUE>)
	       (<AND <VERB? TAKE> <LARGE?> <IN? ,GOLDEN-KEY ,GLASS-TABLE>>
		<MOVE ,GOLDEN-KEY ,WINNER>
		<TELL "You pick the key up like a crumb." CR>
		<RTRUE>)
	       (<VERB? EAT>
		<TELL
"It is gold, and you are a child of some breeding." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A tiny key of bright gold, sized for exactly one door in the world, and
honest about it." CR>
		<RTRUE>)>>

<ROUTINE HALL-CURTAIN-FCN ()
	 <COND (<VERB? OPEN MOVE RAISE LOOK-BEHIND PUSH SEARCH>
		<COND (,CURTAIN-MOVED
		       <TELL
"The curtain is already drawn back from the little door." CR>)
		      (T
		       <SETG CURTAIN-MOVED T>
		       <FCLEAR ,LITTLE-DOOR ,INVISIBLE>
		       <TELL
"You draw the low curtain aside, and behind it is a little door about
fifteen inches high -- a door you are quite sure was not on the
architect's plans." CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<COND (,CURTAIN-MOVED
		       <TELL "Drawn back, its work done." CR>)
		      (T
		       <TELL
"A low curtain, the height of a spaniel, hanging where no window
is." CR>)>
		<RTRUE>)>>

<ROUTINE BIG-DOORS-FCN ()
	 <COND (<VERB? COUNT>
		<TELL
"You count the doors twice and get two different answers, both of them
respectable." CR>
		<RTRUE>)
	       (<VERB? OPEN>
		<TELL
"Locked. You go all round the hall trying them: locked, still locked,
locked and smug about it." CR>
		<RTRUE>)
	       (<VERB? UNLOCK>
		<TELL
"Either the locks are too large, or the key is too small; at any rate
the key will open none of them, and none of them is sorry." CR>
		<RTRUE>)
	       (<VERB? KNOCK>
		<TELL
"You knock. The doors, being locked, consider the matter settled." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"Grand doors, all round the hall, every one of them locked, every one of
them certain it is the important one." CR>
		<RTRUE>)>>

<ROUTINE LITTLE-DOOR-FCN ()
	 <COND (<VERB? UNLOCK>
		<COND (<AND <SMALL?> <EQUAL? ,PRSI ,GOLDEN-KEY>>
		       <COND (<IN? ,GOLDEN-KEY ,WINNER>
			      <MOVE ,GOLDEN-KEY ,GLASS-TABLE>)>
		       <TELL
"The key is nearly as long as you are; you could no more turn it in that
lock than swing a ladder by the handle. It stays where it is." CR>)
		      (<NOT <EQUAL? ,PRSI ,GOLDEN-KEY>>
		       <TELL
"The lock considers your offer and declines." CR>)
		      (<NOT <FSET? ,LITTLE-DOOR ,LOCKEDBIT>>
		       <TELL "It is already unlocked." CR>)
		      (T
		       <FCLEAR ,LITTLE-DOOR ,LOCKEDBIT>
		       <COND (<NOT ,F-UNLOCKED>
			      <SETG F-UNLOCKED T>
			      <SCORE-UPD 3>)>
		       <TELL
"You try the little golden key in the lock and, to your great delight,
it fits!" CR>)>
		<RTRUE>)
	       (<VERB? LOCK>
		<TELL
"The door locks itself quite often enough without help." CR>
		<RTRUE>)
	       (<VERB? OPEN>
		<COND (<FSET? ,LITTLE-DOOR ,OPENBIT>
		       <TELL "It is already open." CR>)
		      (<FSET? ,LITTLE-DOOR ,LOCKEDBIT>
		       <TELL
"The little door is locked, and fifteen inches of it can hold out
against any number of feet of you." CR>)
		      (T
		       <FSET ,LITTLE-DOOR ,OPENBIT>
		       <TELL
"The little door swings open on a passage not much larger than a
rat-hole, and beyond it -- the loveliest garden you ever saw." CR>)>
		<RTRUE>)
	       (<VERB? CLOSE>
		<COND (<FSET? ,LITTLE-DOOR ,OPENBIT>
		       <FCLEAR ,LITTLE-DOOR ,OPENBIT>
		       <TELL
"You shut the little door, which accepts the state with enthusiasm." CR>)
		      (T <TELL "It is already shut." CR>)>
		<RTRUE>)
	       (<VERB? THROUGH>
		<DO-WALK ,P?WEST>
		<RTRUE>)
	       (<VERB? KNOCK>
		<TELL
"You knock, politely. On the other side is a garden, and gardens do not
answer." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A door about fifteen inches high, with a keyhole sized for one key in
the world">
		<COND (<FSET? ,LITTLE-DOOR ,OPENBIT>
		       <TELL ". It stands open on green and gold.">)
		      (<FSET? ,LITTLE-DOOR ,LOCKEDBIT>
		       <TELL ". It is locked.">)
		      (T <TELL ". It is shut.">)>
		<CRLF>
		<RTRUE>)>>

<ROUTINE HALL-LAMPS-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"A row of lamps hanging from the roof, burning steadily on no fuel
anyone has asked about." CR>
		<RTRUE>)>>

<ROUTINE DRINK-BOTTLE-FCN ()
	 <COND (<VERB? DRINK EAT>
		<COND (,BOTTLE-DRUNK
		       <TELL
"The bottle has been empty since it mattered." CR>)
		      (T
		       <DO-DRINK-ME>)>
		<RTRUE>)
	       (<VERB? EXAMINE READ>
		<COND (,BOTTLE-DRUNK
		       <TELL
"Empty, and the label -- DRINK ME -- now reads as a boast." CR>)
		      (T
		       <TELL
"A little bottle with DRINK ME beautifully printed on a paper label. It
is all very well to say \"Drink me,\" but you look first to see whether
it is marked \"poison\" -- for if you drink much from a bottle marked
\"poison,\" it is almost certain to disagree with you, sooner or later.
This bottle is NOT marked \"poison.\"" CR>)>
		<RTRUE>)>>

<ROUTINE DO-DRINK-ME ()
	 <SETG BOTTLE-DRUNK T>
	 <COND (<NOT ,F-DRINKME>
		<SETG F-DRINKME T>
		<SCORE-UPD 2>)>
	 <TELL
"It has a sort of mixed flavour of cherry-tart, custard, pine-apple,
roast turkey, toffee, and hot buttered toast, and you finish it off." CR
CR
"What a curious feeling! You are shutting up like a telescope: down,
down -- ten inches high, and the hall is a cathedral." CR>
	 <CHANGE-SIZE 1 T>>

<ROUTINE GLASS-BOX-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"A little glass box. Through its sides you can see a very small cake, on
which the words EAT ME are beautifully marked in currants." CR>
		<RTRUE>)>>

<ROUTINE EATME-CAKE-FCN ()
	 <COND (<VERB? EAT>
		<DO-EAT-ME>
		<RTRUE>)
	       (<VERB? EXAMINE READ>
		<TELL
"A very small cake, with EAT ME beautifully marked in currants. Well,
you think, if it makes me grow larger, I can reach the key; and if it
makes me grow smaller, I can creep under the door: so either way I'll
get into the garden." CR>
		<RTRUE>)>>

<ROUTINE DO-EAT-ME ()
	 <REMOVE ,EATME-CAKE>
	 <COND (<NOT ,F-EATME>
		<SETG F-EATME T>
		<SCORE-UPD 2>)>
	 <TELL
"You eat a little bit, and say anxiously to yourself \"Which way? Which
way?\" -- and then finish the cake entirely." CR CR
"Curiouser and curiouser! You are opening out like the largest telescope
that ever was -- nine feet if you are an inch, and your head presses the
roof of the hall. Good-bye, feet!" CR>
	 <CHANGE-SIZE 3 T>>

<ROUTINE MOUSE-HOLE-DOOR-FCN ()
	 <COND (<VERB? EXAMINE LOOK-INSIDE>
		<TELL
"A tidy little mouse-hole in the skirting-board, exactly your present
size, with a swept doorstep." CR>
		<RTRUE>)
	       (<VERB? THROUGH>
		<DO-WALK ,P?EAST>
		<RTRUE>)>>

<ROUTINE THE-FAN-FCN ()
	 <COND (<AND <VERB? WAVE> <EQUAL? ,PRSO ,THE-FAN>>
		<DO-FANNING>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A large fan of white kid, rabbit-sized, which is to say small, which is
to say it fits your hand exactly at the moment. It moves more than
air." CR>
		<RTRUE>)>>

<ROUTINE KID-GLOVES-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"A pair of tiny white kid gloves, immaculate, and plainly somebody's
pride." CR>
		<RTRUE>)
	       (<AND <VERB? GIVE> <EQUAL? ,PRSI ,WHITE-RABBIT>>
		<GIVE-GLOVES-BACK>
		<RTRUE>)>>

<ROUTINE RABBIT-DROPS-THINGS ()
	 <SETG RABBIT-IN-HALL <>>
	 <SETG FAN-DROPPED T>
	 <MOVE ,THE-FAN ,HALL>
	 <MOVE ,KID-GLOVES ,HALL>
	 <MOVE ,WHITE-RABBIT ,LOCAL-GLOBALS>
	 <TELL
"The Rabbit starts violently, drops the white kid gloves and the fan,
and skurries away into the darkness as hard as he can go. Which is one
way of answering a civil greeting, and the usual way here." CR>>

<ROUTINE SIXPENCE-FCN ()
	 <COND (<AND <VERB? TAKE> <NOT <IN? ,SIXPENCE ,WINNER>>>
		<MOVE ,SIXPENCE ,WINNER>
		<COND (<NOT ,F-SIX>
		       <SETG F-SIX T>
		       <SCORE-UPD 1>)>
		<TELL
"You pocket the sixpence. Somebody polished it; you feel the debt, and
resolve to spend it well, which you will." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A silver sixpence, polished to a shine by somebody with high standards
and small hands." CR>
		<RTRUE>)>>

<ROUTINE SAVED-COMFIT-FCN ()
	 <COND (<VERB? EAT>
		<TELL
"You eat somebody's carefully saved comfit, and the guilt improves the
flavour considerably." CR>
		<REMOVE ,SAVED-COMFIT>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"One comfit, set aside against a rainy day by a mouse of prudent
habits." CR>
		<RTRUE>)>>

"=================== POOL OF TEARS ==================="

<ROUTINE POOL-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-END>
		<SETG POOL-WAITS <+ ,POOL-WAITS 1>>
		<COND (<G? ,POOL-WAITS 2>
		       <TELL CR
"Being drowned in your own tears would be a queer thing, to be sure; the
pool declines to allow it, and the current delivers you, dripping,
westward." CR CR>
		       <MOVE ,THE-MOUSE ,SHORE>
		       <GOTO ,SHORE>)>
		<WORLD-PULSE>)>>

<ROUTINE POOL-WEST ()
	 <TELL
"You strike out westward, and something furry strikes out beside you: it
is only a mouse, that has slipped in like yourself. \"O Mouse,\" you
say, \"do you know the way out of this pool?\" The Mouse says nothing,
but swims with you, looking dignified about it." CR CR>
	 <MOVE ,THE-MOUSE ,SHORE>
	 <RETURN ,SHORE>>

<ROUTINE POOL-SWIM-WEST ()
	 <POOL-WEST>
	 <GOTO ,SHORE>>

<ROUTINE POOL-DOWN ()
	 <TELL
"You duck under. Salt, and your own fault. You come up again." CR>
	 <RFALSE>>

<ROUTINE THE-MOUSE-FCN ()
	 <COND (<AND <VERB? TELL HELLO> <EQUAL? ,HERE ,POOL>>
		<TELL
"\"O Mouse, do you know the way out of this pool?\" you try -- it is the
first sentence in your brother's Latin Grammar, more or less. The Mouse
looks at you with what you take for encouragement and swims on,
westward." CR>
		<SETG P-CONT <>>
		<SETG QUOTE-FLAG <>>
		<RTRUE>)
	       (<AND <VERB? TELL>
		     <EQUAL? ,PRSI ,T-DINAH>>
		<COND (<EQUAL? ,HERE ,SHORE>
		       <DINAH-SCATTER>)
		      (T
		       <TELL
"The Mouse quivers all over with fright. \"Not like cats!\" it cries.
\"Would YOU like cats, if you were me? Our family always HATED cats:
nasty, low, vulgar things! Don't let me hear the name again!\"" CR>)>
		<RTRUE>)
	       (<AND <VERB? TELL>
		     <EQUAL? ,PRSI ,T-TALE>>
		<MOUSE-TALE>
		<RTRUE>)
	       (<AND <VERB? TELL HELLO> <EQUAL? ,HERE ,SHORE>>
		<MOUSE-LECTURE>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A mouse of consequence, or so its whiskers insist, at present rather
damp for dignity." CR>
		<RTRUE>)
	       (<VERB? TAKE ATTACK>
		<TELL
"One does not pick up a mouse of consequence. One is introduced." CR>
		<RTRUE>)>>

<ROUTINE GLOBAL-WATER-FCN ()
	 <COND (<VERB? DRINK>
		<COND (<EQUAL? ,HERE ,POOL>
		       <TELL
"Salt, and tears, and your own. You have standards." CR>)
		      (T
		       <TELL
"There is no water within reach, which in Wonderland counts as
dry." CR>)>
		<RTRUE>)
	       (<AND <VERB? SWIM> <EQUAL? ,HERE ,POOL>>
		<POOL-SWIM-WEST>
		<RTRUE>)>>
