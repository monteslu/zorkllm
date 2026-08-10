"AACTION3 - WONDERLAND part 3: Act Three and the finale. The beautiful
garden, the roses and the procession, the croquet-ground and the cat
dispute, the Gryphon and the Mock Turtle, the trial of the Knave, and
both endings."

"=================== THE BEAUTIFUL GARDEN ==================="

<ROUTINE GARDEN-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<COND (<SMALL?>
		       <TELL
"The beautiful garden at last -- and you a very small guest in it. The
flower-beds are bright counties, the fountains are thunderstorms of cool
silver, and the gravel path is a boulder-field.">)
		      (T
		       <TELL
"The beautiful garden: bright flower-beds, cool fountains, and gravel
walks.">)>
		<COND (,PROCESSION
		       <TELL
" The royal procession stands about the rose-tree, and the croquet-ground
lies north.">)
		      (,F-ROSES
		       <TELL
" Near the entrance stands a large rose-tree, its roses a convincing and
entirely recent red.">)
		      (T
		       <TELL
" Near the entrance stands a large rose-tree. Its roses are white, but
three gardeners -- flat, oblong fellows patterned like playing cards --
are busily painting them red.">)>
		<TELL " A cool walk leads east." CR>
		<RTRUE>)
	       (<EQUAL? .RARG ,M-BEG>
		<COND (<AND <VERB? SAY>
			    <NOT ,PRSO>
			    ,P-CONT
			    <EQUAL? <GET ,P-LEXV ,P-CONT> ,W?NONSENSE ,W?STUFF>>
		       <SETG P-CONT <>>
		       <SETG QUOTE-FLAG <>>
		       <SAY-NONSENSE>
		       <RTRUE>)
		      (<AND <VERB? SAY>
			    <NOT ,PRSO>
			    ,P-CONT
			    <EQUAL? <GET ,P-LEXV ,P-CONT> ,W?ALICE>>
		       <SETG P-CONT <>>
		       <SETG QUOTE-FLAG <>>
		       <COND (<==? ,QUEEN-PHASE 1> <QUEEN-NAME-GIVEN>)
			     (T
			      <TELL
"\"Alice,\" you say, to be going on with." CR>)>
		       <RTRUE>)>)
	       (<EQUAL? .RARG ,M-END>
		<GARDEN-PULSE>
		<WORLD-PULSE>)>>

<ROUTINE GARDEN-PULSE ()
	 <COND (,CROQUET-OPEN <RFALSE>)
	       (<NOT ,PROCESSION>
		<COND (<SMALL?>
		       <COND (<==? ,PROC-COUNT 0>
			      <SETG PROC-COUNT 1>
			      <TELL CR
"Somewhere beyond the flower-beds a great many feet are marching in
time. At your present height you are entirely beneath the notice of
processions, and the garden politely waits." CR>)>
		       <RFALSE>)
		      (T
		       <SETG PROC-COUNT <+ ,PROC-COUNT 1>>
		       <COND (<G? ,PROC-COUNT 5> <ARRIVE-PROCESSION>)
			     (T
			      <TELL CR
"Trumpets, somewhere near, and the tramp of a great many flat feet."
CR>)>
		       <RFALSE>)>)
	       (T <QUEEN-PULSE>)>>

<ROUTINE ARRIVE-PROCESSION ()
	 <SETG PROCESSION T>
	 <SETG QUEEN-PHASE 1>
	 <MOVE ,THE-QUEEN ,GARDEN>
	 <MOVE ,THE-KING ,GARDEN>
	 <MOVE ,WHITE-RABBIT ,GARDEN>
	 <MOVE ,SOLDIERS ,GARDEN>
	 <TELL CR
"First come ten soldiers carrying clubs, then ten courtiers ornamented
with diamonds, then the royal children, then the guests, mostly Kings
and Queens, and among them the White Rabbit; then the Knave of Hearts,
carrying the King's crown on a crimson velvet cushion; and last of all,
THE KING AND QUEEN OF HEARTS." CR CR
"The procession comes opposite to you and stops. \"Who is THIS?\" says
the Queen of Hearts severely, to the Knave, who only bows and smiles in
reply. \"Idiot!\" says the Queen, tossing her head impatiently; and,
turning to you: \"What's your name, child?\"" CR>
	 <COND (,GARDENERS-DOOMED <RFALSE>)
	       (<NOT ,F-ROSES>
		<SETG GARDENERS-DOOMED T>
		<TELL CR
"Her eye falls on the rose-tree, which is still white in patches.
\"Off with their heads!\" she says, without even looking round, and the
three gardeners instantly throw themselves flat and run to you for
protection." CR>)>
	 <RFALSE>>

<ROUTINE QUEEN-PULSE ()
	 <COND (<==? ,QUEEN-PHASE 1>
		<SETG QUEEN-DAWDLE <+ ,QUEEN-DAWDLE 1>>
		<COND (<G? ,QUEEN-DAWDLE 2>
		       <SETG QUEEN-DAWDLE 0>
		       <TELL CR
"\"What's your name, child?\" the Queen repeats, in the voice of
somebody who does not repeat things." CR>)>)
	       (<==? ,QUEEN-PHASE 2>
		<SETG QUEEN-PHASE 3>
		<TELL CR
"\"And who are THESE?\" says the Queen, pointing to the three gardeners
lying round the rose-tree. You look at them, and say, \"How should I
know? It is no business of MINE.\" The Queen turns crimson with fury,
and begins screaming: \"Off with her head! Off --\"" CR>)
	       (<==? ,QUEEN-PHASE 3>
		<SETG QUEEN-DAWDLE <+ ,QUEEN-DAWDLE 1>>
		<COND (<G? ,QUEEN-DAWDLE 2>
		       <SETG QUEEN-DAWDLE 0>
		       <QUEEN-PARDON>)
		      (T
		       <TELL CR
"\"-- off with her --\" the Queen goes on, gathering breath. Somewhere
behind you a cat you cannot see remarks that nonsense is the one
language she respects." CR>)>)>
	 <RFALSE>>

<ROUTINE QUEEN-NAME-GIVEN ()
	 <SETG QUEEN-PHASE 2>
	 <SETG QUEEN-DAWDLE 0>
	 <TELL
"\"My name is Alice, so please your Majesty,\" you say very politely;
but you add, to yourself, \"Why, they're only a pack of cards, after
all. I needn't be afraid of them!\"" CR>
	 <RTRUE>>

<ROUTINE QUEEN-NONSENSED ()
	 <SETG QUEEN-PHASE 4>
	 <COND (<NOT ,F-QUEEN>
		<SETG F-QUEEN T>
		<SCORE-UPD 2>)>
	 <TELL
"\"Nonsense!\" you say, very loudly and decidedly, and the Queen is
silent. The King lays his hand upon her arm, and says timidly,
\"Consider, my dear: she is only a child!\"" CR CR
"The Queen turns away from him and says to the Knave, \"Turn them
over!\" -- and then, to you, in quite another voice: \"Can you play
croquet?\"" CR>
	 <RTRUE>>

<ROUTINE QUEEN-PARDON ()
	 <SETG QUEEN-PHASE 4>
	 <TELL CR
"\"-- off with her --\" The King lays his hand upon her arm and says
timidly, \"Consider, my dear: she is only a child!\" The Queen turns
away from him in disgust, and says to you, in quite another voice: \"Can
you play croquet?\"" CR>
	 <RFALSE>>

<ROUTINE SHOW-INVITATION ()
	 <COND (<L? ,QUEEN-PHASE 1>
		<TELL
"There is nobody royal here to show it to, and the card is not impressed
by you." CR>
		<RTRUE>)
	       (<G? ,QUEEN-PHASE 3>
		<TELL
"The Queen has already decided about you, which is as close to safety as
this garden offers." CR>
		<RTRUE>)
	       (T
		<SETG QUEEN-PHASE 4>
		<COND (<NOT ,F-QUEEN>
		       <SETG F-QUEEN T>
		       <SCORE-UPD 2>)>
		<TELL
"You hold out the stiff card. The Queen squints at it. \"You are not the
Duchess,\" she says. -- \"No,\" you say; \"she is detained.\" This is
perfectly true, and the Queen, who likes detentions, is charmed by it.
You are admitted as a substitute." CR CR
"\"Can you play croquet?\" she says." CR>
		<RTRUE>)>>

<ROUTINE START-CROQUET ()
	 <SETG QUEEN-PHASE 5>
	 <SETG CROQUET-OPEN T>
	 <MOVE ,FLAMINGO ,WINNER>
	 <FCLEAR ,FLAMINGO ,NDESCBIT>
	 <MOVE ,HEDGEHOG ,CROQUET-GROUND>
	 <MOVE ,THE-QUEEN ,CROQUET-GROUND>
	 <MOVE ,THE-KING ,CROQUET-GROUND>
	 <MOVE ,WHITE-RABBIT ,CROQUET-GROUND>
	 <MOVE ,SOLDIERS ,CROQUET-GROUND>
	 <TELL
"\"Yes!\" you shout. -- \"Come on, then!\" roars the Queen, and you join
the procession, wondering very much what will happen next. Somebody
hands you a live flamingo, and somebody else sets a hedgehog down in
front of you, and the whole company moves north." CR CR>
	 <GOTO ,CROQUET-GROUND>>

"--- the gardeners and the roses ---"

<ROUTINE GARDENERS-FCN ()
	 <COND (<AND <VERB? TELL> ,PRSI>
		<GARDENERS-TALK>
		<RTRUE>)
	       (<VERB? TELL HELLO ANSWER>
		<GARDENERS-TALK>
		<RTRUE>)
	       (<AND <VERB? PUT> <EQUAL? ,PRSI ,FLOWER-POT>>
		<POT-THE-GARDENERS>
		<RTRUE>)
	       (<VERB? EXAMINE COUNT>
		<TELL
"Three gardeners, flat and oblong, with their hands and feet at the
corners: Two, Five, and Seven, patterned on the back like the rest of
the pack and, in front, entirely painters." CR>
		<RTRUE>)>>

<ROUTINE GARDENERS-TALK ()
	 <SETG P-CONT <>>
	 <SETG QUOTE-FLAG <>>
	 <COND (,GARDENERS-DOOMED
		<TELL
"\"Don't let her know we're here!\" they whisper from the ground.
\"She'll have our heads. She always does, and it never takes, but it is
very wearing.\"" CR>)
	       (,F-ROSES
		<TELL
"\"That's a good job done,\" says Five, \"and no thanks to Seven.\" --
\"You'd better not talk!\" says Seven. \"I heard the Queen say only
yesterday you deserved to be beheaded.\"" CR>)
	       (T
		<TELL
"\"Would you tell me, please,\" you say, \"why you are painting those
roses?\" Five and Seven look at Two, and Two says, in a low voice,
\"Why, the fact is, you see, Miss, this here ought to have been a RED
rose-tree, and we put a white one in by mistake; and if the Queen was to
find it out, we should all have our heads cut off, you know. So you see,
Miss, we're doing our best, afore she comes, to --\"" CR CR
"At this moment Five, who has been looking anxiously across the garden,
calls out \"The Queen! The Queen!\" -- prematurely, as it turns out, but
it is the sort of thing that is always nearly true here." CR>)>
	 <RTRUE>>

<ROUTINE DO-PAINT-ROSES ()
	 <COND (,F-ROSES
		<TELL
"The tree is as red as paint can make it, and redder than roses
generally manage." CR>
		<RTRUE>)
	       (<AND <NOT <IN? ,PAINT-BRUSH ,WINNER>>
		     <NOT <IN? ,PAINT-POT ,WINNER>>>
		<TELL
"You would need the brush, at least. The gardeners are using theirs with
a will and no skill whatever." CR>
		<RTRUE>)
	       (T
		<SETG F-ROSES T>
		<SCORE-UPD 3>
		<TELL
"You lay on the red in workmanlike coats while Two whispers which petals
the Queen checks first. The tree passes for crimson by the time the
trumpets sound, and three flat gentlemen look at you as though you had
personally repealed an execution." CR>
		<RTRUE>)>>

<ROUTINE POT-THE-GARDENERS ()
	 <COND (<NOT ,GARDENERS-DOOMED>
		<TELL
"They are busy, upright, and in no present danger; being potted would
only confuse them." CR>
		<RTRUE>)
	       (,F-ROSES
		<TELL
"They are already safe, and one rescue a day is the ration." CR>
		<RTRUE>)
	       (T
		<SETG F-ROSES T>
		<SCORE-UPD 3>
		<TELL
"You put the three gardeners carefully, head downwards, into the large
flower-pot. The soldiers look for them for a minute or two, then march
quietly off after the others." CR CR
"\"Are their heads off?\" shouts the Queen. -- \"Their heads are gone,
if it please your Majesty!\" the soldiers shout in reply. -- \"That's
right!\" shouts the Queen, and is perfectly satisfied, which is the
whole art of dealing with her." CR>
		<RTRUE>)>>

<ROUTINE ROSE-TREE-FCN ()
	 <COND (<VERB? PAINT>
		<DO-PAINT-ROSES>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<COND (,F-ROSES
		       <TELL
"A large rose-tree covered in red roses, some of which are roses and the
rest of which are paint." CR>)
		      (T
		       <TELL
"A large rose-tree covered in white roses, three of which are turning
red under the brush as you watch." CR>)>
		<RTRUE>)
	       (<VERB? TAKE PICK>
		<TELL
"Picking the Queen's roses would be a beheading offence, and you have
seen how these people are about heads." CR>
		<RTRUE>)>>

<ROUTINE PAINT-BRUSH-FCN ()
	 <COND (<AND <VERB? TAKE> <NOT <IN? ,PAINT-BRUSH ,WINNER>>>
		<MOVE ,PAINT-BRUSH ,WINNER>
		<FCLEAR ,PAINT-BRUSH ,NDESCBIT>
		<TELL
"You take up a brush. It is heavy with red, and the gardeners make room
for you with the relief of men who have found a professional." CR>
		<RTRUE>)
	       (<VERB? PAINT>
		<DO-PAINT-ROSES>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL "A large brush, dripping red, and quite willing." CR>
		<RTRUE>)>>

<ROUTINE PAINT-POT-FCN ()
	 <COND (<VERB? PAINT>
		<DO-PAINT-ROSES>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A pot of red paint, the exact red of a rose that has never existed."
CR>
		<RTRUE>)>>

<ROUTINE FLOWER-POT-FCN ()
	 <COND (<VERB? EXAMINE LOOK-INSIDE>
		<TELL
"A large empty flower-pot, exactly the size of three flat gentlemen."
CR>
		<RTRUE>)>>

<ROUTINE GARDEN-FOUNTAINS-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"Cool fountains, throwing silver about with both hands, in beds of very
bright flowers." CR>
		<RTRUE>)
	       (<VERB? DRINK>
		<TELL
"You drink from a fountain. It is the first thing all day that has
tasted of nothing whatever, and it is wonderful." CR>
		<RTRUE>)>>

<ROUTINE GARDEN-NORTH ()
	 <COND (,CROQUET-OPEN <RETURN ,CROQUET-GROUND>)
	       (T
		<TELL
"North is the croquet-ground, and nobody walks onto the Queen's
croquet-ground uninvited. That is how the ground stays a ground and the
walkers stay walkers." CR>
		<RFALSE>)>>

<ROUTINE GARDEN-WEST ()
	 <COND (<SMALL?>
		<TELL
"You creep back up the little passage, no larger than a rat-hole, into
the hall." CR CR>
		<RETURN ,HALL>)
	       (T
		<TELL
"The rat-hole passage back to the hall is fifteen inches of nothing
much, and you are more than that." CR>
		<RFALSE>)>>

"=================== FOUNTAIN WALK AND THE DUCHESS'S MORALS ==========="

<ROUTINE FOUNTAIN-WALK-FCN (RARG)
	 <COND (<AND <EQUAL? .RARG ,M-ENTER>
		     ,DUCHESS-FREED
		     <NOT <IN? ,THE-DUCHESS ,FOUNTAIN-WALK>>>
		<MOVE ,THE-DUCHESS ,FOUNTAIN-WALK>
		<TELL
"The Duchess is here, out of prison, and very much pleased to see you.
She tucks her arm affectionately into yours and they walk off together,
her chin fitting itself uncomfortably into your shoulder. It is an
uncomfortably sharp chin, but you do not like to be rude." CR>)
	       (<EQUAL? .RARG ,M-END>
		<COND (<IN? ,THE-DUCHESS ,FOUNTAIN-WALK> <MORAL-LINE>)>
		<WORLD-PULSE>)>>

<ROUTINE MORAL-LINE ()
	 <SETG MORALS <+ ,MORALS 1>>
	 <COND (<==? ,MORALS 1>
		<TELL CR
"\"And the moral of THAT is,\" says the Duchess, \"'Oh, 'tis love, 'tis
love, that makes the world go round!'\"" CR>)
	       (<==? ,MORALS 2>
		<TELL CR
"\"And the moral of THAT is,\" says the Duchess, \"'Take care of the
sense, and the sounds will take care of themselves.'\"" CR>)
	       (<==? ,MORALS 3>
		<TELL CR
"\"And the moral of THAT is,\" says the Duchess, \"'Be what you would
seem to be' -- or, if you'd like it put more simply -- 'Never imagine
yourself not to be otherwise than what it might appear to others that
what you were or might have been was not otherwise than what you had
been would have appeared to them to be otherwise.'\" -- \"I think I
should understand that better,\" you say very politely, \"if I had it
written down.\" -- \"That's nothing to what I could say if I chose,\"
the Duchess replies, pleased. \"You have a clear way of putting
things.\"" CR>)
	       (<==? ,MORALS 4>
		<REMOVE ,THE-DUCHESS>
		<TELL CR
"A shadow falls across the walk. \"Now, I give you fair warning,\" shouts
the Queen, stamping on the ground as she speaks; \"either you or your
head must be off, and that in about half no time! Take your choice!\"
The Duchess takes her choice, and is gone." CR>)
	       (T <RFALSE>)>
	 <RFALSE>>

"=================== THE CROQUET GROUND ==================="

<ROUTINE CROQUET-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<TELL
"The Queen's croquet-ground, which is all ridges and furrows. The balls
are live hedgehogs, the mallets live flamingoes, and the soldiers double
themselves up on hands and feet to make the arches -- when they are not
strolling off to be elsewhere. Everyone plays at once, without waiting
for turns, and the Queen's voice carries over all of it: \"Off with his
head! Off with her head!\"">
		<COND (,SEASIDE-OPEN
		       <TELL " A path east leads down to the sea.">)>
		<TELL " The garden lies south." CR>
		<RTRUE>)
	       (<EQUAL? .RARG ,M-BEG>
		<COND (<AND <VERB? SAY>
			    <NOT ,PRSO>
			    ,P-CONT
			    <EQUAL? <GET ,P-LEXV ,P-CONT> ,W?NONSENSE ,W?STUFF>>
		       <SETG P-CONT <>>
		       <SETG QUOTE-FLAG <>>
		       <SAY-NONSENSE>
		       <RTRUE>)>)
	       (<EQUAL? .RARG ,M-END>
		<CROQUET-PULSE>
		<WORLD-PULSE>)>>

<ROUTINE CROQUET-PULSE ()
	 <SETG CROQ-TURNS <+ ,CROQ-TURNS 1>>
	 <COND (<AND <NOT ,ARCH-READY> ,FLAMINGO-TAME>
		<SETG ARCH-READY T>
		<TELL CR
"A doubled-up soldier nearby yawns, gives up on being elsewhere, and
settles into place as a perfectly serviceable arch." CR>
		<RFALSE>)>
	 <COND (<AND ,HEDGEHOG-DONE <==? ,CROQ-STAGE 0>>
		<SETG CROQ-STAGE 1>
		<MOVE ,CAT-HEAD ,CROQUET-GROUND>
		<TELL CR
"A grin appears in the air above the ground, and after a minute a head
grows under it: the Cheshire Cat, head only, watching the game with
interest. The King notices it at once. \"I don't like the look of it at
all,\" he says. \"However, it may kiss my hand if it likes.\" -- \"I'd
rather not,\" the Cat remarks." CR>
		<RFALSE>)>
	 <COND (<==? ,CROQ-STAGE 1>
		<SETG CROQ-STAGE 2>
		<TELL CR
"\"Who are you talking to?\" says the King, coming up and looking at the
Cat's head with great curiosity. -- \"It's a friend of mine, a Cheshire
Cat,\" you say. -- \"I don't like the look of it at all: however, it may
kiss my hand if it likes.\" -- \"I'd rather not,\" says the Cat. --
\"Don't be impertinent,\" says the King, \"and don't look at me like
that!\" and he gets behind you as he speaks. \"Off with his head!\" he
calls to the Queen, without looking round." CR>
		<RFALSE>)
	       (<==? ,CROQ-STAGE 2>
		<SETG CROQ-STAGE 3>
		<TELL CR
"The executioner argues that you cannot cut off a head unless there is a
body to cut it off from. The King argues that anything that has a head
can be beheaded. The Queen argues that if something is not done about it
in less than no time she will have everybody executed all round. The
court turns, as one, to you." CR>
		<RFALSE>)
	       (<==? ,CROQ-STAGE 3>
		<SETG CROQ-DAWDLE <+ ,CROQ-DAWDLE 1>>
		<COND (<G? ,CROQ-DAWDLE 3>
		       <CAT-VERDICT <>>)
		      (T
		       <TELL CR
"The dispute goes round again. The Cat's head grins at the argument, and
begins, very slowly, to fade at the ears." CR>)>
		<RFALSE>)
	       (<AND <==? ,CROQ-STAGE 4> <NOT ,SEASIDE-OPEN>>
		<SETG CROQ-DAWDLE <+ ,CROQ-DAWDLE 1>>
		<COND (<G? ,CROQ-DAWDLE 2>
		       <SETG SEASIDE-OPEN T>
		       <TELL CR
"\"Have you seen the Mock Turtle yet?\" the Queen asks you abruptly. --
\"No,\" you say. \"I don't even know what a Mock Turtle is.\" -- \"It's
the thing Mock Turtle Soup is made from,\" says the Queen. \"Come on,
then, and he shall tell you his history.\" She points east, where a path
goes down to a grey and sighing sea, and then goes off to sentence
somebody else." CR>)>
		<RFALSE>)>
	 <RFALSE>>

<ROUTINE CAT-VERDICT (SCORED)
	 <SETG CROQ-STAGE 4>
	 <SETG CROQ-DAWDLE 0>
	 <SETG DUCHESS-FREED T>
	 <REMOVE ,CAT-HEAD>
	 <COND (.SCORED
		<COND (<NOT ,F-VERDICT>
		       <SETG F-VERDICT T>
		       <SCORE-UPD 3>)>
		<TELL
"\"It belongs to the Duchess,\" you say: \"you'd better ask HER about
it.\" -- \"She's in prison,\" the Queen says to the executioner:
\"fetch her here.\" And the executioner goes off like an arrow." CR CR
"By the time he returns with the Duchess, the Cat's head has faded quite
away, and the King and the executioner are running wildly up and down
looking for it, which they continue to do for some time, being
comfortable in the search." CR>)
	       (T
		<TELL CR
"The Cat's head fades quite away while they are arguing, and the King
and the executioner run wildly up and down looking for it. Nobody
thinks to ask whose cat it was, and the Duchess stays in prison a while
longer." CR>)>
	 <RFALSE>>

<ROUTINE FLAMINGO-FCN ()
	 <COND (<VERB? STROKE>
		<TAME-FLAMINGO>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<COND (,FLAMINGO-TAME
		       <TELL
"A live flamingo, tucked under your arm, consenting to be a mallet and
quietly proud of the appointment." CR>)
		      (T
		       <TELL
"A live flamingo, which you are expected to hold head downwards and
strike a hedgehog with. It has other plans, all of them involving
looking you in the face." CR>)>
		<RTRUE>)
	       (<VERB? TAKE>
		<COND (<IN? ,FLAMINGO ,WINNER>
		       <TELL "You have it, more or less." CR>)
		      (T
		       <MOVE ,FLAMINGO ,WINNER>
		       <FCLEAR ,FLAMINGO ,NDESCBIT>
		       <TELL
"You get the flamingo under your arm, with its legs hanging down." CR>)>
		<RTRUE>)
	       (<VERB? ATTACK>
		<TELL
"You are not going to hit a flamingo. You are going to hit a hedgehog
WITH a flamingo, which is completely different and perfectly normal
here." CR>
		<RTRUE>)>>

<ROUTINE TAME-FLAMINGO ()
	 <COND (,FLAMINGO-TAME
		<TELL
"The flamingo is already yours, and settles further under your arm to
prove it." CR>)
	       (T
		<SETG FLAMINGO-TAME T>
		<COND (<NOT <IN? ,FLAMINGO ,WINNER>>
		       <MOVE ,FLAMINGO ,WINNER>
		       <FCLEAR ,FLAMINGO ,NDESCBIT>)>
		<TELL
"You smooth the flamingo's feathers the right way for some time. It
settles its neck under your arm with a pleased grunt, and consents to be
a mallet." CR>)>
	 <RTRUE>>

<ROUTINE HEDGEHOG-FCN ()
	 <COND (<VERB? ATTACK KICK>
		<HIT-THE-HEDGEHOG>
		<RTRUE>)
	       (<VERB? TAKE>
		<TELL
"The hedgehog unrolls itself and is crawling away before your fingers
close. It is a ball only by royal decree." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A live hedgehog, being a croquet ball under protest, with a strong
private opinion about ridges and furrows." CR>
		<RTRUE>)>>

<ROUTINE HIT-THE-HEDGEHOG ()
	 <COND (,HEDGEHOG-DONE
		<TELL
"You have sent one hedgehog cleanly through one arch, which in this game
is a career." CR>
		<RTRUE>)
	       (<NOT ,FLAMINGO-TAME>
		<SETG MISHAP <+ ,MISHAP 1>>
		<COND (<==? ,MISHAP 1>
		       <TELL
"Just as you get the flamingo's neck nicely straightened out and are
going to give the hedgehog a blow with its head, it twists itself round
and looks up into your face with such a puzzled expression that you
cannot help bursting out laughing." CR>)
		      (<==? ,MISHAP 2>
		       <TELL
"By the time you have got the flamingo's head down again, the hedgehog
has unrolled itself and is crawling away. The flamingo watches it go
with the air of a colleague." CR>)
		      (T
		       <SETG MISHAP 0>
		       <TELL
"You raise the flamingo; the hedgehog waits; and the soldier who was
being your arch gets up and strolls away to another part of the ground.
Everybody plays at once, and nobody plays at all." CR>)>
		<RTRUE>)
	       (<NOT ,ARCH-READY>
		<TELL
"The flamingo is willing and the hedgehog is resigned, but every arch
within reach has got up and walked off. You will have to wait for a
soldier with nothing better to do." CR>
		<RTRUE>)
	       (T
		<SETG HEDGEHOG-DONE T>
		<COND (<NOT ,F-HEDGEHOG>
		       <SETG F-HEDGEHOG T>
		       <SCORE-UPD 4>)>
		<TELL
"You strike the hedgehog with the flamingo's head. Clean through the
arch! The arch says \"oof\" and stays put out of professional pride, the
hedgehog rolls to a stop looking rather pleased with itself, and the
Queen almost smiles, which frightens everybody." CR>
		<RTRUE>)>>

<ROUTINE SOLDIERS-FCN ()
	 <COND (<VERB? EXAMINE COUNT>
		<TELL
"Soldiers doubled up on their hands and feet to make arches, except for
the ones who have quietly stopped being arches and are strolling about
being soldiers." CR>
		<RTRUE>)
	       (<VERB? TELL HELLO ANSWER>
		<SETG P-CONT <>>
		<SETG QUOTE-FLAG <>>
		<TELL
"The nearest arch says nothing, being an arch, but shifts slightly to
make the shape more convenient for you, which is the politest thing
anybody has done all day." CR>
		<RTRUE>)>>

<ROUTINE THE-QUEEN-FCN ()
	 <COND (<AND <VERB? GIVE SHOW> <EQUAL? ,PRSO ,INVITATION>>
		<SHOW-INVITATION>
		<RTRUE>)
	       (<AND <VERB? TELL> <EQUAL? ,PRSI ,T-DUCHESS>>
		<COND (<AND <EQUAL? ,HERE ,CROQUET-GROUND>
			    <G? ,CROQ-STAGE 0>
			    <L? ,CROQ-STAGE 4>>
		       <CAT-VERDICT T>)
		      (T
		       <SETG P-CONT <>>
		       <SETG QUOTE-FLAG <>>
		       <TELL
"\"The Duchess?\" says the Queen. \"In prison. Off with her head.\" She
says it the way other people say good morning." CR>)>
		<RTRUE>)
	       (<AND <VERB? TELL> ,PRSI>
		<SETG P-CONT <>>
		<SETG QUOTE-FLAG <>>
		<TELL
"\"Off with her head!\" says the Queen, on the subject, whatever the
subject was. Nobody moves; nobody ever does." CR>
		<RTRUE>)
	       (<VERB? TELL HELLO ANSWER>
		<SETG P-CONT <>>
		<SETG QUOTE-FLAG <>>
		<TELL
"\"Off with her head!\" the Queen shouts at the top of her voice, on
principle, and then, having got that out of the way, ignores you
entirely." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"The Queen of Hearts: crimson with a permanent fury she clearly enjoys,
and, if the Gryphon is to be believed, entirely harmless." CR>
		<RTRUE>)
	       (<VERB? ATTACK>
		<TELL
"You would be beheaded for it, which is to say nothing whatever would
happen, but you have been brought up better." CR>
		<RTRUE>)>>

<ROUTINE THE-KING-FCN ()
	 <COND (<AND <VERB? TELL> <EQUAL? ,PRSI ,T-DUCHESS>>
		<COND (<AND <EQUAL? ,HERE ,CROQUET-GROUND>
			    <G? ,CROQ-STAGE 0>
			    <L? ,CROQ-STAGE 4>>
		       <CAT-VERDICT T>)
		      (<AND <EQUAL? ,HERE ,COURTROOM> <G? ,TRIAL-PHASE 0>>
		       <SETG P-CONT <>>
		       <SETG QUOTE-FLAG <>>
		       <TELL
"\"The Duchess is not on trial,\" says the King, \"today.\"" CR>)
		      (T
		       <SETG P-CONT <>>
		       <SETG QUOTE-FLAG <>>
		       <TELL
"\"A Duchess,\" says the King vaguely, \"is a thing my wife deals
with.\"" CR>)>
		<RTRUE>)
	       (<AND <VERB? GIVE> <EQUAL? ,PRSO ,SIXPENCE>>
		<OFFER-SIXPENCE>
		<RTRUE>)
	       (<AND <VERB? TELL> ,PRSI>
		<SETG P-CONT <>>
		<SETG QUOTE-FLAG <>>
		<TELL
"\"That's very important,\" says the King; and then, after a pause,
\"UNimportant, of course, is what I meant.\"" CR>
		<RTRUE>)
	       (<VERB? TELL HELLO ANSWER>
		<SETG P-CONT <>>
		<SETG QUOTE-FLAG <>>
		<TELL
"The King says something mild, pardons somebody quietly, and rights his
crown, which he wears over his wig and which does not agree with it."
CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"The King of Hearts, in his crown worn over a judge's wig, looking very
uncomfortable and pardoning people under his breath." CR>
		<RTRUE>)>>

<ROUTINE CAT-HEAD-FCN ()
	 <COND (<AND <VERB? TELL> ,PRSI>
		<SETG P-CONT <>>
		<SETG QUOTE-FLAG <>>
		<TELL
"\"How are you getting on?\" says the Cat's head, as soon as there is
mouth enough to speak with. \"I don't think they play at all fairly,\"
you begin, \"and they don't seem to have any rules in particular.\""
CR>
		<RTRUE>)
	       (<VERB? TELL HELLO ANSWER EXAMINE>
		<SETG P-CONT <>>
		<SETG QUOTE-FLAG <>>
		<TELL
"A head, and a grin, and no more of the Cat than that. It winks at you
with the eye it can spare." CR>
		<RTRUE>)>>

<ROUTINE GIVE-GLOVES-BACK ()
	 <COND (,F-GLOVES
		<TELL
"He has his gloves. He is still late, but he is late in gloves." CR>
		<RTRUE>)
	       (T
		<SETG F-GLOVES T>
		<SCORE-UPD 3>
		<COND (<IN? ,KID-GLOVES ,WINNER> <REMOVE ,KID-GLOVES>)>
		<COND (<IN? ,THE-FAN ,WINNER> <REMOVE ,THE-FAN>)>
		<TELL
"You hand over the white kid gloves, and the fan with them. The Rabbit's
ears turn quite pink with relief. \"Oh, my fur and whiskers -- my
GLOVES!\" he says, and puts them on at once, and is instantly a
different and much better rabbit, though no less late." CR>
		<RTRUE>)>>

<ROUTINE CROQUET-EAST ()
	 <COND (,SEASIDE-OPEN <RETURN ,SEASIDE>)
	       (T
		<TELL
"East is the sea, and the sea is not on the programme until the Queen
says it is." CR>
		<RFALSE>)>>

"=================== THE GRYPHON AND THE MOCK TURTLE ==================="

<ROUTINE SEASIDE-FCN (RARG)
	 <COND (<AND <EQUAL? .RARG ,M-ENTER> <NOT ,GRYPHON-WOKE>>
		<SETG GRYPHON-WOKE T>
		<TELL
"\"Up, lazy thing!\" says the Queen's voice behind you, and the Gryphon
sits up and rubs its eyes and watches her out of sight. Then it
chuckles. \"What fun!\" -- \"What IS the fun?\" you say. -- \"Why, SHE.
It's all her fancy, that: they never executes nobody, you know. Come
on!\"" CR>)
	       (<EQUAL? .RARG ,M-END> <WORLD-PULSE>)>>

<ROUTINE GRYPHON-FCN ()
	 <COND (<VERB? ALARM>
		<SETG P-CONT <>>
		<SETG QUOTE-FLAG <>>
		<TELL
"\"Up, lazy thing!\" you say, in the Queen's own manner, and the Gryphon
opens one eye and grants that this is a fair imitation." CR>
		<RTRUE>)
	       (<AND <VERB? TELL> ,PRSI>
		<SETG P-CONT <>>
		<SETG QUOTE-FLAG <>>
		<TELL
"\"It's all his fancy, that,\" says the Gryphon: \"he hasn't got no
sorrow, you know. Come on!\"" CR>
		<RTRUE>)
	       (<VERB? TELL HELLO ANSWER>
		<SETG P-CONT <>>
		<SETG QUOTE-FLAG <>>
		<TELL
"\"They never executes nobody,\" the Gryphon says comfortably, \"and
that's the whole of the law here, whatever they tell you. Come on.\""
CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A Gryphon, lying fast asleep in the sun, made of the front half of one
impossible animal and the back half of another, and entirely at ease
about it." CR>
		<RTRUE>)>>

<ROUTINE TURTLE-ROCK-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-END>
		<COND (<AND ,F-QUADRILLE ,SOUP-SUNG <NOT ,TRIAL-CALLED>>
		       <CALL-THE-TRIAL>)>
		<WORLD-PULSE>)>>

<ROUTINE MOCK-TURTLE-FCN ()
	 <COND (<AND <VERB? TELL> ,PRSI>
		<TURTLE-TOPIC>
		<RTRUE>)
	       (<VERB? TELL HELLO ANSWER LISTEN>
		<TURTLE-HISTORY>
		<RTRUE>)
	       (<VERB? SING>
		<TURTLE-SOUP-SONG>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A Mock Turtle: large, sad, with the head and hind hooves and tail of a
calf, sighing as if his heart would break. It is all his fancy, that; he
hasn't got no sorrow, you know." CR>
		<RTRUE>)>>

<ROUTINE TURTLE-HISTORY ()
	 <SETG P-CONT <>>
	 <SETG QUOTE-FLAG <>>
	 <SETG TURTLE-TALKS <+ ,TURTLE-TALKS 1>>
	 <COND (<==? ,TURTLE-TALKS 1>
		<TELL
"The Mock Turtle draws a long breath and says, \"Once, I was a real
Turtle.\" These words are followed by a very long silence, broken only
by an occasional exclamation of \"Hjckrrh!\" from the Gryphon, and the
constant heavy sobbing of the Mock Turtle." CR CR
"\"When we were little,\" he goes on at last, \"we went to school in the
sea. The master was an old Turtle -- we used to call him Tortoise --\"
-- \"Why did you call him Tortoise, if he wasn't one?\" you ask. -- \"We
called him Tortoise because he taught us,\" says the Mock Turtle
angrily. \"Really you are very dull!\"" CR>)
	       (<==? ,TURTLE-TALKS 2>
		<TELL
"\"We had the best of educations,\" the Mock Turtle says: \"Reeling and
Writhing, of course, to begin with, and then the different branches of
Arithmetic -- Ambition, Distraction, Uglification, and Derision.\" --
\"And how many hours a day did you do lessons?\" -- \"Ten hours the
first day,\" says the Mock Turtle, \"nine the next, and so on.\" --
\"What a curious plan!\" -- \"That's the reason they're called
lessons,\" the Gryphon remarks: \"because they lessen from day to
day.\"" CR>)
	       (T
		<TELL
"\"You may not have lived much under the sea,\" the Mock Turtle says,
\"and perhaps you were never even introduced to a lobster. So you can
have no idea what a delightful thing a Lobster Quadrille is!\" -- \"No
indeed,\" you say. \"What sort of a dance is it?\" -- \"Why,\" says the
Gryphon, \"you first form into a line along the sea-shore --\" -- \"Two
lines!\" cries the Mock Turtle. \"Seals, turtles, salmon, and so on;
then, when you've cleared all the jelly-fish out of the way --\" --
\"THAT generally takes some time,\" interrupts the Gryphon. \"Shall we
try the first figure?\"" CR>)>
	 <RTRUE>>

<ROUTINE TURTLE-TOPIC ()
	 <SETG P-CONT <>>
	 <SETG QUOTE-FLAG <>>
	 <COND (<EQUAL? ,PRSI ,T-SCHOOL>
		<TURTLE-HISTORY>)
	       (T
		<TELL
"The Mock Turtle sighs deeply, and draws the back of one flapper across
his eyes, and says nothing at all about it, at length." CR>
		<RTRUE>)>>

<ROUTINE DO-QUADRILLE ()
	 <COND (,F-QUADRILLE
		<TELL
"You have danced it once. Twice would be greedy, and the Gryphon's
breath is not what it was." CR>
		<RTRUE>)
	       (T
		<SETG F-QUADRILLE T>
		<SCORE-UPD 3>
		<TELL
"\"Come, let's try the first figure!\" says the Mock Turtle to the
Gryphon. \"We can do it without lobsters, you know.\" So they begin
solemnly dancing round and round you, every now and then treading on
your toes when they pass too close, and waving their forepaws to mark
the time, while the Mock Turtle sings, very slowly and sadly:" CR CR
"\"Will you walk a little faster? said a whiting to a snail, there's a
porpoise close behind us, and he's treading on my tail. See how eagerly
the lobsters and the turtles all advance! They are waiting on the
shingle -- will you come and join the dance? Will you, won't you, will
you, won't you, will you join the dance?\"" CR>
		<RTRUE>)>>

<ROUTINE TURTLE-SOUP-SONG ()
	 <COND (,SOUP-SUNG
		<TELL
"\"Soo -- oop of the e -- e -- evening,\" the Mock Turtle repeats, and
chokes with sobs, and cannot go on." CR>
		<RTRUE>)
	       (T
		<SETG SOUP-SUNG T>
		<TELL
"The Mock Turtle sighs deeply, and begins, in a voice choked with sobs:
\"Beautiful Soup, so rich and green, waiting in a hot tureen! Who for
such dainties would not stoop? Soup of the evening, beautiful Soup!
Beau -- ootiful Soo -- oop! Beau -- ootiful Soo -- oop! Soo -- oop of
the e -- e -- evening, beautiful, beautiful Soup!\"" CR CR
"He is just beginning to repeat it when a cry of \"The trial's
beginning!\" is heard in the distance." CR>
		<RTRUE>)>>

<ROUTINE CALL-THE-TRIAL ()
	 <SETG TRIAL-CALLED T>
	 <SETG TRIAL-PHASE 1>
	 <MOVE ,THE-KING ,COURTROOM>
	 <MOVE ,THE-QUEEN ,COURTROOM>
	 <MOVE ,WHITE-RABBIT ,COURTROOM>
	 <MOVE ,THE-HATTER ,COURTROOM>
	 <MOVE ,DORMOUSE ,COURTROOM>
	 <TELL CR
"\"Come on!\" cries the Gryphon, and, taking you by the hand, it hurries
off without waiting for the end of the song. \"What trial is it?\" you
pant as you run; but the Gryphon only answers \"Come on!\" and runs the
faster, while more and more faintly, carried on the breeze that follows
you, come the melancholy words: \"Soo -- oop of the e -- e --
evening, beautiful, beautiful Soup!\"" CR CR>
	 <GOTO ,COURTROOM>>

"=================== THE TRIAL ==================="

<ROUTINE COURTROOM-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-ENTER>
		<COND (<==? ,TRIAL-PHASE 1> <TRIAL-OPENING>)>)
	       (<EQUAL? .RARG ,M-BEG>
		<COND (<AND <VERB? PUT TAKE> <EQUAL? ,PRSO ,BILL-LIZARD>>
		       <RIGHT-BILL>
		       <RTRUE>)
		      (<AND <VERB? SAY>
			    <NOT ,PRSO>
			    ,P-CONT
			    <EQUAL? <GET ,P-LEXV ,P-CONT> ,W?MILE>>
		       <SETG P-CONT <>>
		       <SETG QUOTE-FLAG <>>
		       <DO-MILE-HIGH>
		       <RTRUE>)
		      (<AND <VERB? SAY>
			    <NOT ,PRSO>
			    ,P-CONT
			    <EQUAL? <GET ,P-LEXV ,P-CONT>
				    ,W?NONSENSE ,W?STUFF>>
		       <SETG P-CONT <>>
		       <SETG QUOTE-FLAG <>>
		       <SAY-NONSENSE>
		       <RTRUE>)
		      (<AND <VERB? SAY>
			    <NOT ,PRSO>
			    ,P-CONT
			    <EQUAL? <GET ,P-LEXV ,P-CONT> ,W?NOTHING>>
		       <SETG P-CONT <>>
		       <SETG QUOTE-FLAG <>>
		       <COND (<==? ,TRIAL-PHASE 5> <DO-NOTHING-WHATEVER>)
			     (T
			      <TELL "You say nothing, at some length." CR>)>
		       <RTRUE>)>)
	       (<EQUAL? .RARG ,M-END>
		<COND (<NOT ,GAME-OVER> <TRIAL-BEAT>)>
		<WORLD-PULSE>)>>

<ROUTINE TRIAL-OPENING ()
	 <TELL
"The White Rabbit blows three blasts on the trumpet, unrolls the
parchment scroll, and reads: \"The Queen of Hearts, she made some tarts,
all on a summer day: the Knave of Hearts, he stole those tarts, and took
them quite away!\"" CR CR
"\"Consider your verdict,\" the King says to the jury. -- \"Not yet, not
yet!\" the Rabbit interrupts hastily. \"There's a great deal to come
before that!\"" CR>
	 <RFALSE>>

"The trial advances one beat per turn; nothing the player does can stall
it forever, and nothing ends it early except the ending."
<ROUTINE TRIAL-BEAT ()
	 <COND (<==? ,TRIAL-PHASE 1>
		<SETG TRIAL-PHASE 2>
		<TELL CR
"\"Call the first witness,\" says the King; and the White Rabbit blows
three blasts on the trumpet and calls out, \"First witness!\" The first
witness is the Hatter, who comes in with a teacup in one hand and a
piece of bread-and-butter in the other. \"I'm a poor man, your
Majesty,\" he begins." CR>)
	       (<==? ,TRIAL-PHASE 2>
		<SETG TRIAL-PHASE 3>
		<COND (,WATCH-FIXED
		       <TELL CR
"\"You ought to have finished,\" says the King. \"When did you begin?\"
-- \"I came PUNCTUALLY,\" says the Hatter, bewildered by the novelty of
the word in his own mouth. The court, which has never heard the Hatter
claim punctuality, writes it all down. He then bites a large piece out
of his teacup, is dismissed, and leaves without waiting to put his shoes
on." CR>)
		      (T
		       <TELL CR
"\"You're a very poor speaker,\" says the King. The Hatter explains that
his tea was not ready, that it is always six o'clock, and that the March
Hare said -- \"I didn't!\" says the March Hare. He bites a large piece
out of his teacup, is dismissed, and leaves without waiting to put his
shoes on." CR>)>)
	       (<==? ,TRIAL-PHASE 3>
		<SETG TRIAL-PHASE 4>
		<TELL CR
"\"Call the next witness!\" The next witness is the Duchess's cook, who
carries the pepper-box, so that the people near the door begin sneezing
all at once. \"What are tarts made of?\" says the King. -- \"Pepper,
mostly,\" says the cook. -- \"Treacle,\" says a sleepy voice behind her.
-- \"Collar that Dormouse!\" the Queen shrieks. \"Behead that Dormouse!
Turn that Dormouse out of court! Suppress him! Pinch him! Off with his
whiskers!\"" CR>)
	       (<==? ,TRIAL-PHASE 4>
		<SETG TRIAL-PHASE 5>
		<COND (<SMALL?> <SETG ALICE-SIZE 2>)>
		<TELL CR
"In the confusion the cook disappears, and nobody misses her. You have
begun, meanwhile, to grow, quite gently, in the way of somebody standing
up in a story." CR CR
"\"I wish you wouldn't squeeze so,\" says the Dormouse, who is sitting
next to you. \"I can hardly breathe.\" -- \"I can't help it,\" you say
meekly: \"I'm growing.\" -- \"You've no right to grow HERE,\" says the
Dormouse. -- \"Don't talk nonsense,\" you say more boldly: \"you know
you're growing too.\" -- \"Yes, but I grow at a REASONABLE pace,\" says
the Dormouse, \"not in that ridiculous fashion.\" And he gets up very
sulkily and crosses over to the other side of the court." CR CR
"\"Alice!\" calls the White Rabbit, reading from his list. \"What do you
know about this business?\" says the King." CR>)
	       (<==? ,TRIAL-PHASE 5>
		<SETG TRIAL-NUDGE <+ ,TRIAL-NUDGE 1>>
		<COND (<G? ,TRIAL-NUDGE 2>
		       <SETG TRIAL-NUDGE 0>
		       <DO-NOTHING-WHATEVER>)
		      (T
		       <TELL CR
"\"What do you know about this business?\" the King repeats. The jurors
wait, pencils poised, hoping for something long." CR>)>)
	       (<==? ,TRIAL-PHASE 6>
		<SETG TRIAL-PHASE 7>
		<SETG ALICE-SIZE 3>
		<MOVE ,BILL-LIZARD ,COURTROOM>
		<TELL CR
"You have grown so large by now that you get up in such a hurry that you
tip over the jury-box with the edge of your skirt, upsetting all the
jurymen on to the heads of the crowd below, where they lie sprawling
about, reminding you very much of a globe of goldfish you upset last
week." CR CR
"\"Oh, I BEG your pardon!\" you exclaim in a tone of great dismay, and
begin picking them up again as quickly as you can. Bill the Lizard is on
the floor by your foot, head downwards, waving his tail about in a
melancholy way, quite unable to move." CR>)
	       (<==? ,TRIAL-PHASE 7>
		<SETG TRIAL-NUDGE <+ ,TRIAL-NUDGE 1>>
		<COND (<G? ,TRIAL-NUDGE 2>
		       <SETG TRIAL-NUDGE 0>
		       <SETG TRIAL-PHASE 8>
		       <TELL CR
"The jurors are righted, more or less, and set to writing again. Then
the King calls out, \"Silence!\" and reads out from his note-book, \"Rule
Forty-two. ALL PERSONS MORE THAN A MILE HIGH TO LEAVE THE COURT.\"
Everybody looks at you." CR>)
		      (T
		       <TELL CR
"The jurors are collected up and put back, some of them the right way
round." CR>)>)
	       (<==? ,TRIAL-PHASE 8>
		<SETG TRIAL-NUDGE <+ ,TRIAL-NUDGE 1>>
		<COND (<G? ,TRIAL-NUDGE 2>
		       <SETG TRIAL-NUDGE 0>
		       <SETG TRIAL-PHASE 9>
		       <TELL CR
"Nobody moves, and the King, after waiting a moment, decides not to
press Rule Forty-two, which he has begun to suspect of being new." CR CR
"\"There's more evidence to come yet, please your Majesty,\" says the
White Rabbit, jumping up in a great hurry: \"this paper has just been
picked up. It seems to be a set of verses, and it isn't directed to
anybody at all.\"" CR>)
		      (T
		       <TELL CR
"\"All persons more than a mile high to leave the court,\" the King
repeats, looking hard at you and hoping." CR>)>)
	       (<==? ,TRIAL-PHASE 9>
		<SETG TRIAL-NUDGE <+ ,TRIAL-NUDGE 1>>
		<COND (<G? ,TRIAL-NUDGE 2>
		       <SETG TRIAL-NUDGE 0>
		       <SETG TRIAL-PHASE 10>
		       <READ-THE-VERSES>)
		      (T
		       <TELL CR
"\"Begin at the beginning,\" the King says gravely, \"and go on till you
come to the end: then stop.\" The Rabbit begins to read." CR>)>)
	       (<==? ,TRIAL-PHASE 10>
		<SETG TRIAL-NUDGE <+ ,TRIAL-NUDGE 1>>
		<COND (<==? ,TRIAL-NUDGE 3>
		       <TELL CR
"High among the rafters a grin fades slowly in, and mouths a single
word, without any sound at all, twice: \"Nonsense.\"" CR>)
		      (<G? ,TRIAL-NUDGE 7>
		       <NEGLECTED-ENDING>)
		      (T
		       <TELL CR
"\"Let the jury consider their verdict,\" the King says, for about the
twentieth time that day. -- \"No, no!\" says the Queen. \"Sentence
first -- verdict afterwards.\"" CR>)>)>
	 <RFALSE>>

<ROUTINE READ-THE-VERSES ()
	 <TELL CR
"The Rabbit reads: \"They told me you had been to her, and mentioned me
to him: she gave me a good character, but said I could not swim. He sent
them word I had not gone (we know it to be true): if she should push the
matter on, what would become of you?\"" CR CR
"\"That's the most important piece of evidence we've heard yet,\" says
the King, rubbing his hands. The Knave shakes his head sadly: \"Do I
look like it?\" -- and he certainly does not, being made entirely of
cardboard. \"If there's no meaning in it,\" says the King, \"that saves
a world of trouble, you know, as we needn't try to find any.\" -- \"Let
the jury consider their verdict.\" -- \"No, no!\" says the Queen.
\"Sentence first -- verdict afterwards.\"" CR>
	 <RFALSE>>

<ROUTINE DO-NOTHING-WHATEVER ()
	 <SETG TRIAL-PHASE 6>
	 <SETG TRIAL-NUDGE 0>
	 <TELL
"\"Nothing,\" you say. -- \"Nothing WHATEVER?\" persists the King. --
\"Nothing whatever.\" -- \"That's very important,\" the King says,
turning to the jury. They are just beginning to write this down on their
slates when the White Rabbit interrupts: \"UNimportant, your Majesty
means, of course,\" he says, in a very respectful tone, but frowning and
making faces at him as he speaks. -- \"UNimportant, of course, I
meant,\" the King says hastily, and goes on to himself in an undertone,
\"important -- unimportant -- unimportant -- important --\" as if he
were trying which word sounded best." CR>
	 <RTRUE>>

<ROUTINE DO-MILE-HIGH ()
	 <COND (<AND <NOT <==? ,TRIAL-PHASE 8>> <NOT <==? ,TRIAL-PHASE 7>>>
		<TELL
"Nobody has accused you of being a mile high just at present, and it
would be strange to bring it up." CR>
		<RTRUE>)
	       (T
		<SETG TRIAL-PHASE 9>
		<SETG TRIAL-NUDGE 0>
		<COND (<NOT ,F-MILE>
		       <SETG F-MILE T>
		       <SCORE-UPD 2>)>
		<TELL
"\"I'M not a mile high,\" you say. -- \"You are,\" says the King. --
\"Nearly two miles high,\" adds the Queen. -- \"Well, I shan't go, at
any rate,\" you say; \"besides, that's not a regular rule: you invented
it just now.\" -- \"It's the oldest rule in the book,\" says the King.
-- \"Then it ought to be Number One,\" you say." CR CR
"The King turns pale, and shuts his note-book hastily. \"Consider your
verdict,\" he says to the jury, in a low, trembling voice." CR CR
"\"There's more evidence to come yet, please your Majesty,\" says the
White Rabbit, jumping up in a great hurry: \"this paper has just been
picked up.\"" CR>
		<RTRUE>)>>

<ROUTINE OFFER-SIXPENCE ()
	 <COND (,F-SIXPENCE
		<TELL
"The sixpence has already entered the record, and the record is not
greedy." CR>
		<RTRUE>)
	       (<L? ,TRIAL-PHASE 8>
		<TELL
"There is nothing to explain yet, and a sixpence offered too early is
merely a sixpence." CR>
		<RTRUE>)
	       (T
		<SETG F-SIXPENCE T>
		<SCORE-UPD 2>
		<TELL
"\"If any one of them can explain it,\" you say, \"I'll give him
sixpence.\" You are holding an actual sixpence, which alarms the court
considerably: nobody attempts the explanation, and the sixpence enters
the record as the day's only honest evidence." CR CR
"\"I don't believe there's an atom of meaning in it,\" you add. -- \"If
there's no meaning in it,\" says the King, \"that saves a world of
trouble.\"" CR>
		<RTRUE>)>>

<ROUTINE PEPPER-THE-COURT ()
	 <COND (,F-PEPPERED
		<TELL
"The court has sneezed once already on your account, and twice would be
a policy." CR>
		<RTRUE>)
	       (T
		<SETG F-PEPPERED T>
		<SCORE-UPD 2>
		<TELL
"You open the pepper-box and give it a good shake. The pepper goes
through the court in waves: the jurors sneeze onto their slates, the
soldiers sneeze in ranks, the King sneezes with great dignity, and in
the middle of it the Duchess's cook, who wanted nothing else in the
world, walks quietly out of the door and is not seen again." CR>
		<RTRUE>)>>

"--- courtroom objects ---"

<ROUTINE SQUEAKY-PENCIL-FCN ()
	 <COND (<AND <VERB? TAKE> <NOT <IN? ,SQUEAKY-PENCIL ,WINNER>>>
		<MOVE ,SQUEAKY-PENCIL ,WINNER>
		<FCLEAR ,SQUEAKY-PENCIL ,NDESCBIT>
		<COND (<NOT ,F-PENCIL>
		       <SETG F-PENCIL T>
		       <SCORE-UPD 1>)>
		<TELL
"One of the jurors has a pencil that squeaks, which of course you cannot
stand, so you go round the court and get behind him, and very soon find
an opportunity of taking it away. You do it so quickly that the poor
little juror (it is Bill, the Lizard) cannot make out at all what has
become of it; so, after hunting all about for it, he is obliged to write
with one finger for the rest of the day." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A slate-pencil that squeaks abominably, which is why it is now yours."
CR>
		<RTRUE>)>>

<ROUTINE BILL-LIZARD-FCN ()
	 <COND (<AND <VERB? PUT> <EQUAL? ,PRSI ,JURY-BOX>>
		<RIGHT-BILL>
		<RTRUE>)
	       (<VERB? TAKE>
		<RIGHT-BILL>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<COND (,F-BILLBOX
		       <TELL
"Bill the Lizard, head upwards in the jury-box, writing with one finger
and quite content." CR>)
		      (T
		       <TELL
"Bill the Lizard, head downwards on the floor, waving his tail about in
a melancholy way, quite unable to move." CR>)>
		<RTRUE>)
	       (<VERB? TELL HELLO ANSWER>
		<SETG P-CONT <>>
		<SETG QUOTE-FLAG <>>
		<TELL
"Bill says nothing. He has been up a chimney and down a jury-box today,
and is reserving his remarks." CR>
		<RTRUE>)>>

<ROUTINE V-RIGHT ()
	 <COND (<EQUAL? ,PRSO ,BILL-LIZARD> <RIGHT-BILL>)
	       (T
		<TELL
"It is as right as it is going to get, which in this court is not very."
CR>)>>

<ROUTINE RIGHT-BILL ()
	 <COND (,F-BILLBOX
		<TELL
"Bill is the right way up, and intends to stay that way." CR>
		<RTRUE>)
	       (<L? ,TRIAL-PHASE 7>
		<TELL
"Bill is in the jury-box with the others, writing busily, and would not
thank you for the attention." CR>
		<RTRUE>)
	       (T
		<SETG F-BILLBOX T>
		<SCORE-UPD 2>
		<MOVE ,BILL-LIZARD ,JURY-BOX>
		<TELL
"You pick up Bill the Lizard and set him in the jury-box, head upwards
this time. Not that it signifies much, you think: he would be quite as
much use in the trial one way up as the other. But it signifies to
Bill." CR>
		<RTRUE>)>>

<ROUTINE JURORS-FCN ()
	 <COND (<VERB? COUNT>
		<TELL
"Twelve. You are rather proud of knowing the word \"jurors,\" and think
that very few little girls of your age would know the meaning of it at
all." CR>
		<RTRUE>)
	       (<AND <VERB? GIVE> <EQUAL? ,PRSO ,SIXPENCE>>
		<OFFER-SIXPENCE>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"Twelve jurors -- little birds and beasts, one of them a lizard you have
met before -- all writing very busily on slates. \"What are they
doing?\" you whisper. \"They can't have anything to put down yet.\" --
\"They're putting down their names,\" the Gryphon whispers back, \"for
fear they should forget them before the end of the trial.\"" CR>
		<RTRUE>)
	       (<VERB? TELL HELLO ANSWER>
		<SETG P-CONT <>>
		<SETG QUOTE-FLAG <>>
		<TELL
"The jury writes down everything you say, including this, and one of
them writes down \"including this.\"" CR>
		<RTRUE>)>>

<ROUTINE JURY-BOX-FCN ()
	 <COND (<VERB? EXAMINE LOOK-INSIDE>
		<TELL
"A jury-box with twelve places in it, at present containing rather fewer
than twelve jurors." CR>
		<RTRUE>)>>

<ROUTINE THE-TARTS-FCN ()
	 <COND (<VERB? EAT TAKE>
		<TELL
"You are many things, but you are not about to become Exhibit B." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A large dish of tarts in the very middle of the court, being evidence,
refreshments, and motive all at once. They look SO good. It is against
the law to be hungry in court, probably." CR>
		<RTRUE>)>>

<ROUTINE THE-KNAVE-FCN ()
	 <COND (<VERB? TELL HELLO ANSWER>
		<SETG P-CONT <>>
		<SETG QUOTE-FLAG <>>
		<TELL
"\"Do I look like it?\" says the Knave, and he certainly does not, being
made entirely of cardboard, and standing in chains, and looking about as
guilty as a playing card can look, which is not at all." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"The Knave of Hearts, in chains between two soldiers, made of cardboard
and accused of tarts." CR>
		<RTRUE>)>>

<ROUTINE COURT-PROPS-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"A trumpet, a scroll of parchment, the King's note-book, a throne, and a
number of guinea-pigs who have already been suppressed once today, in a
large canvas bag, head first." CR>
		<RTRUE>)>>

<ROUTINE TRIAL-VERSES-FCN ()
	 <COND (<VERB? EXAMINE READ>
		<TELL
"A set of verses in somebody's handwriting, not directed to anybody at
all, and not signed at the end. \"That's the queerest thing about it,\"
says the King: \"if he didn't sign it, that only makes the matter worse.
You MUST have meant some mischief, or else you'd have signed your name
like an honest man.\"" CR>
		<RTRUE>)
	       (<AND <VERB? GIVE> <EQUAL? ,PRSO ,SIXPENCE>>
		<OFFER-SIXPENCE>
		<RTRUE>)>>

"=================== ENDINGS ==================="

<ROUTINE DO-FINALE ()
	 <SETG GAME-OVER T>
	 <COND (<NOT ,F-FINALE>
		<SETG F-FINALE T>
		<SCORE-UPD 5>)>
	 <TELL
"\"Stuff and nonsense!\" you say loudly. \"The idea of having the
sentence first!\"" CR CR
"\"Hold your tongue!\" says the Queen, turning purple. -- \"I won't!\"
you say. -- \"Off with her head!\" the Queen shouts at the top of her
voice. Nobody moves. -- \"Who cares for YOU?\" you say -- you have grown
to your full size by now -- \"You're nothing but a pack of cards!\""
CR CR>
	 <WAKE-OUTRO>
	 <RTRUE>>

<ROUTINE NEGLECTED-ENDING ()
	 <SETG GAME-OVER T>
	 <TELL CR
"\"You are all pardoned,\" the King murmurs at last, to nobody in
particular, and the court dissolves into a swirl of cards, and the dream
ends itself, feeling somewhat neglected." CR CR>
	 <WAKE-OUTRO>
	 <RFALSE>>

<ROUTINE WAKE-OUTRO ()
	 <TELL
"At this the whole pack rises up into the air and comes flying down upon
you. You give a little scream, half of fright and half of anger, and try
to beat them off -- and find them only dead leaves, fluttering down from
the trees onto your face." CR CR
"\"Wake up, Alice dear!\" says your sister. \"Why, what a long sleep
you've had!\"" CR CR
"\"Oh, I've had such a curious dream!\" you say. And you tell her, as
well as you can remember them, all these strange adventures -- the
Rabbit, the pool, the Caterpillar exactly three inches high, the tea
that was always six o'clock, the Queen who never once got anybody's
head. Your sister kisses you and says it certainly was a curious dream,
but now run in to your tea: it's getting late." CR CR
"And you run in, thinking while you run -- as well you might -- what a
wonderful dream it has been. Behind you on the bank, the long grass
rustles, just once, the way it would if a white rabbit had hurried by."
CR CR>
	 <TELL "Your score is " N ,SCORE " of 100, which earns the rank of ">
	 <RANK-NAME>
	 <TELL ". Everybody has won, and all must have prizes." CR CR>
	 <FINISH-GAME>
	 <RTRUE>>

<ROUTINE STAY-FOREVER ()
	 <COND (<==? ,STAY-OFFER 1>
		<SETG STAY-OFFER 2>
		<TELL
"\"Are you quite sure?\" says the Hatter, pausing with the milk-jug.
\"The tea is eternal. There is no clock to argue with any more, and
nobody ever has to go in.\"" CR>
		<RTRUE>)
	       (T
		<SETG GAME-OVER T>
		<TELL
"\"There's room now, you know,\" says the Hatter, moving up. \"All the
room in the world.\" The March Hare pours; the Dormouse, by way of
welcome, does not wake; and the watch on the table ticks round to
exactly tea-time, which it now is, and will remain, for as long as you
care to stay -- and you find you care to stay a very long time indeed."
CR CR
"Somewhere far above, an afternoon ends without you. Down here the bread
and butter goes round, and the riddles have no answers, and nobody's
head is ever off. You have considered the matter carefully, from every
side, like a mushroom, and your conclusion is this: they were quite
right. You ARE mad. You wouldn't have come here otherwise." CR CR
"Rank attained: Quite Mad, Thank You. (There is no score. Scores are for
people who leave.)" CR CR>
		<FINISH-GAME>
		<RTRUE>)>>

<ROUTINE FINISH-GAME ()
	 <TELL "    ****  You have woken up  ****" CR CR>
	 <QUIT>>

"=================== POCKET OBJECTS ==================="

<ROUTINE COMFIT-BOX-FCN ()
	 <COND (<AND <VERB? GIVE> <EQUAL? ,PRSI ,THE-DODO ,SHORE-BIRDS>>
		<GIVE-PRIZES>
		<RTRUE>)
	       (<VERB? EAT OPEN>
		<TELL
"You eat one comfit. There are exactly as many left as there will need
to be, which is a property comfits have in this country." CR>
		<RTRUE>)
	       (<VERB? EXAMINE COUNT>
		<TELL
"A box of comfits from your pocket. There appear to be enough for a
party, which is fortunate, as there is going to be one." CR>
		<RTRUE>)>>

<ROUTINE THIMBLE-FCN ()
	 <COND (<AND <VERB? GIVE> <EQUAL? ,PRSI ,THE-DODO ,SHORE-BIRDS>>
		<GIVE-THIMBLE>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<COND (,F-THIMBLE
		       <TELL
"Your own thimble, formally presented to you by a Dodo, and therefore an
elegant thimble, which is a considerable promotion." CR>)
		      (T
		       <TELL
"An ordinary thimble, out of your own pocket, of no distinction
whatever. Yet." CR>)>
		<RTRUE>)
	       (<VERB? WEAR>
		<TELL
"You put the thimble on. It fits whichever finger you are currently
scaled to, which is more than most things manage today." CR>
		<RTRUE>)>>
