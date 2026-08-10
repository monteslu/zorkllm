"CACT2 - The Count of Monte Cristo, ACT TWO: the Chateau d'If.
The dig, Faria, the education, the deduction, the sack swap, the sea."

"=== The cell, phase by phase ==="

<ROUTINE CELL34-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<COND (<G? ,ACT 4> <CELL34-TOUR> <RTRUE>)>
		<TELL
"Stone below, stone above, stone on every side, and the sea grinding at
the roots of all of it. A bed, a chair, a table, a pail, and a jug.
High in one wall, a loophole with three iron bars lets in a ration of
sky, and the only door lies north and does not open." CR>
		<COND (,TUNNEL-OPEN
		       <TELL
"Behind the bed the hewn stone stands aside, and the burrow goes down
into the dark." CR>)
		      (,BED-MOVED
		       <TELL
"Your bed stands out from the wall, and only you know why." CR>)>
		<RTRUE>)
	       (<EQUAL? .RARG ,M-ENTER>
		<FARIA-FOLLOW>
		<RFALSE>)
	       (<EQUAL? .RARG ,M-END>
		<CELL-TICK>
		<RFALSE>)
	       (T <RFALSE>)>>

<ROUTINE CELL34-TOUR ()
	 <TELL
"Cell number thirty-four, by the guide's reckoning: a bed, a chair, a
table, and the same ration of sky. The guide is explaining that one of
the famous prisoners went mad here. He is nearly right." CR>>

<ROUTINE CELL-DOOR-EXIT ()
	 <TELL
"The oak door has a grate for the jailer's eyes and no handle on your
side." CR>
	 <RFALSE>>

<ROUTINE CELL34-DIG-EXIT ()
	 <COND (<G? ,ACT 5>
		<MOVE ,MANUSCRIPT ,TUNNEL>
		<FCLEAR ,MANUSCRIPT ,NDESCBIT>
		<TELL
"The guide is telling a party of English about the mad abbe. You step
over the rope and go down into your own tunnel." CR CR>
		,TUNNEL)
	       (,TUNNEL-OPEN
		<COND (,CARRYING-BODY
		       <TELL
"You go down into the burrow feet first, bearing him, an inch at a
time." CR>)>
		,TUNNEL)
	       (,STONE-PRIED
		<TELL
"The cavity is a foot and a half across and goes nowhere yet. Dig." CR>
		<RFALSE>)
	       (T
		<TELL "There is no way out of cell thirty-four. That is
rather the point of it." CR>
		<RFALSE>)>>

<ROUTINE CELL-DOOR-FCN ()
	 <COND (<VERB? OPEN MOVE ATTACK>
		<TELL
"No handle, no hinge you can reach, and four inches of oak. It has
argued with better men than you." CR>
		<RTRUE>)
	       (<VERB? KNOCK>
		<COND (<EQUAL? ,PHASE 1>
		       <TELL
"You beat on the oak until your hands are raw. A voice on the stair
says, without interest, \"He is number thirty-four.\"" CR>)
		      (T
		       <TELL "You do not knock on that door. You have learned
better." CR>)>
		<RTRUE>)
	       (<VERB? LISTEN>
		<TELL "Boots, sometimes. Nothing else, ever." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"Oak and iron, with a grate at eye height for the jailer to look
through and nothing at all for you." CR>
		<RTRUE>)>>

<ROUTINE LOOPHOLE-FCN ()
	 <COND (<VERB? EXAMINE LOOK-INSIDE>
		<TELL
"Three iron bars and a hand's breadth of sky. On a clear evening you
can see the light of Planier, and beyond it nothing you are allowed to
want." CR>
		<RTRUE>)
	       (<VERB? MOVE ATTACK OPEN>
		<TELL
"The bars have argued with better men than you. The wall, though, is
damp." CR>
		<RTRUE>)>>

<ROUTINE PRISON-BED-FCN ()
	 <COND (<VERB? MOVE PUSH MOVE RAISE>
		<COND (,BED-MOVED
		       <TELL "The bed already stands out from the wall." CR>)
		      (T
		       <SETG BED-MOVED T>
		       <TELL
"You draw the bed away from the wall. Behind it, damp stone, and a
mortar line a fingernail could argue with." CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A plank bed and a sack of straw. It is the only furniture in this
kingdom that can be moved." CR>
		<RTRUE>)
	       (<AND <VERB? PUT> <EQUAL? ,PRSI ,PRISON-BED>>
		<RFALSE>)>>

<ROUTINE STRAW-FCN ()
	 <COND (<VERB? SEARCH EXAMINE LOOK-INSIDE MOVE>
		<TELL
"Bed straw, and what you have hidden in it: plaster dust by the
handful, and the sharpest of the jug's shards." CR>
		<RTRUE>)>>

<ROUTINE JUG-FCN ()
	 <COND (<VERB? MUNG ATTACK THROW>
		<COND (,JUG-BROKEN
		       <TELL "It is already so much gravel." CR>)
		      (T
		       <SETG JUG-BROKEN T>
		       <MOVE ,SHARD ,CELL34>
		       <FCLEAR ,SHARD ,NDESCBIT>
		       <TELL
"The jug bursts on the stones. You palm the three sharpest shards into
the straw; the rest you leave lying, an accident." CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL "A water jug of coarse earthenware, refilled each evening by a man
who does not look at you." CR>
		<RTRUE>)>>

<ROUTINE SHARD-FCN ()
	 <COND (<AND <VERB? DIG> <EQUAL? ,PRSI ,SHARD>>
		<DIG-WITH-SHARD>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL "A wedge of broken jug, and the first edged thing you
have owned in years." CR>
		<RTRUE>)>>

<ROUTINE CWALL-FCN ()
	 <COND (<NOT <EQUAL? ,ACT 2>> <WALL-ELSEWHERE>)
	       (<VERB? LISTEN>
		<LISTEN-TO-WALL>
		<RTRUE>)
	       (<VERB? KNOCK ATTACK>
		<KNOCK-ON-WALL>
		<RTRUE>)
	       (<VERB? DIG MUNG>
		<COND (<EQUAL? ,PRSI ,SHARD> <DIG-WITH-SHARD>)
		      (<EQUAL? ,PRSI ,PAN-HANDLE> <DIG-WITH-HANDLE>)
		      (T
		       <TELL
"The damp has made the mortar friable, but your nails are not enough.
You want an edge." CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"Damp stone, and mortar that crumbles at a thumbnail. A mathematician
might give the wall two years. A prisoner has them." CR>
		<RTRUE>)
	       (T <RFALSE>)>>

<ROUTINE WALL-ELSEWHERE ()
	 <COND (<AND <EQUAL? ,HERE ,GROTTO1> <VERB? KNOCK ATTACK LISTEN>>
		<SOUND-GROTTO-WALL>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL "A wall, and nothing behind it but more of the world."
CR>
		<RTRUE>)
	       (T <RFALSE>)>>

"=== Puzzle II-1: the sound ==="

<ROUTINE LISTEN-TO-WALL ()
	 <COND (<L? ,PHASE 2>
		<TELL
"Stone, and the sea in it, and your own blood. Nothing that means
anything." CR>)
	       (,KNOCKED
		<COND (,SOUND-BACK
		       <TELL
"The scratching again, deeper now, and coming your way." CR>)
		      (T
		       <TELL
"Silence, since your three knocks. He is thinking about you." CR>)>)
	       (T
		<SETG HEARD-SOUND T>
		<TELL
"A faint, continuous scratching, low in the wall: stone on stone,
patient as the sea." CR CR
"A workman would work by day and stop at noon. This one works at all
hours. It is a prisoner." CR>)>>

<ROUTINE KNOCK-ON-WALL ()
	 <COND (<NOT ,HEARD-SOUND>
		<TELL "On which of four walls, and why?" CR>)
	       (,KNOCKED
		<TELL "You have said what you had to say. Now you wait." CR>)
	       (T
		<SETG KNOCKED T>
		<ADD-SCORE 5>
		<TELL
"You take up the loose corner stone and strike the wall three times,
deliberately." CR CR
"The scratching stops, as if by magic. Somewhere behind three feet of
rock, a man is holding his breath and thinking exactly what you are
thinking." CR>)>>

<ROUTINE LOOSE-STONE-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "A corner stone the damp has loosened. It comes out in
your hands, and it is heavy enough to be heard." CR>
		<RTRUE>)
	       (<VERB? TAKE MOVE>
		<COND (<IN? ,LOOSE-STONE ,WINNER>
		       <TELL "You have it." CR>)
		      (T
		       <MOVE ,LOOSE-STONE ,WINNER>
		       <TELL
"You work the loose corner stone out of the floor. It is a poor tool
and a good hammer." CR>)>
		<RTRUE>)
	       (<VERB? KNOCK ATTACK THROW>
		<KNOCK-ON-WALL>
		<RTRUE>)>>

"=== Puzzle II-2/3: shard, plate, saucepan handle ==="

<ROUTINE DIG-WITH-SHARD ()
	 <COND (<NOT <IN? ,SHARD ,WINNER>>
		<TELL "You would need the shard in your hand." CR>)
	       (<NOT ,BED-MOVED>
		<TELL "The bed hides nothing yet, and you have nothing to
hide. Move it first." CR>)
	       (,WALL-DUG
		<TELL
"The fragment breaks in your fingers. The hewn block behind the plaster
does not care." CR>)
	       (T
		<SETG WALL-DUG T>
		<MOVE ,HEWN-STONE ,CELL34>
		;"the loose corner stone has done its one job; retiring it
		keeps the noun STONE pointing at the block from here on"
		<REMOVE ,LOOSE-STONE>
		<ADD-SCORE 5>
		<TELL
"The damp has made the mortar friable: a handful in half an hour, and
the plaster hidden in the straw and shaken out at the loophole a little
each morning." CR CR
"Behind it, a single hewn block, dressed and set by masons who were
paid. Your shard snaps against it. You want iron." CR>)>>

<ROUTINE HEWN-STONE-FCN ()
	 <COND (<AND <VERB? MOVE TURN TAKE PUSH MOVE RAISE>
		     <EQUAL? ,PRSI ,PAN-HANDLE>>
		<PRY-THE-STONE>
		<RTRUE>)
	       (<VERB? MOVE TURN TAKE PUSH MOVE RAISE>
		<COND (,STONE-PRIED
		       <TELL "It is out, and the cavity behind it is yours."
CR>)
		      (T
		       <TELL
"You get your fingers to it and nothing else. This wants a lever, and a
long one." CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A dressed block a foot and a half square, bedded in mortar the sea has
been softening since before you were born." CR>
		<RTRUE>)>>

<ROUTINE PLATE-FCN ()
	 <COND (<AND <VERB? PUT DROP> <NOT ,PAN-LEFT> <EQUAL? ,PHASE 3 4>>
		<SETG PLATE-SET T>
		<MOVE ,PLATE ,CELL34>
		<TELL
"You set the earthen plate down just inside the door, where a man
carrying soup in the dark would put his foot." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL "One earthen plate. The whole service of the crown."
CR>
		<RTRUE>)>>

<ROUTINE SAUCEPAN-FCN ()
	 <COND (<VERB? TAKE>
		<TELL
"The pan is nothing. It is the handle you want." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"An iron saucepan with a straight iron handle a forearm long. You have
been looking at it every evening for six years without seeing it." CR>
		<RTRUE>)>>

<ROUTINE PAN-HANDLE-FCN ()
	 <COND (<AND <VERB? TAKE MOVE> <NOT ,HANDLE-OUT>>
		<SETG HANDLE-OUT T>
		<MOVE ,PAN-HANDLE ,WINNER>
		<FCLEAR ,PAN-HANDLE ,NDESCBIT>
		<TELL
"You work the handle off and straighten it against the floor: a lever
the length of your forearm. You would not trade it for ten years of
life." CR>
		<RTRUE>)
	       (<AND <VERB? MOVE TURN> <EQUAL? ,PRSO ,PAN-HANDLE>>
		<TELL "It is straight already, and it is a lever." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL "A straightened iron bar, the first tool of your
freedom." CR>
		<RTRUE>)>>

<ROUTINE PRY-THE-STONE ()
	 <COND (,STONE-PRIED
		<TELL "The stone is already out." CR>)
	       (<NOT <IN? ,PAN-HANDLE ,WINNER>>
		<TELL "Not with your hands. Iron, or nothing." CR>)
	       (T
		<SETG STONE-PRIED T>
		<SETG PHASE 5>
		<REMOVE ,HEWN-STONE>
		<MOVE ,TUNNEL-HOLE ,CELL34>
		<ADD-SCORE 10>
		<TELL
"You set the iron in the mortar line and lean, and the wall gives a
slow oscillation, and then the hewn stone comes away like a tooth." CR CR
"A cavity, a foot and a half across, breathing cold air at you out of
the thickness of the fortress." CR>)>>

<ROUTINE TUNNEL-HOLE-FCN ()
	 <COND (<AND <VERB? DIG> <EQUAL? ,PRSI ,PAN-HANDLE>>
		<DIG-WITH-HANDLE>
		<RTRUE>)
	       (<VERB? GETIN CLIMB-DOWN BOARD THROUGH>
		<COND (,TUNNEL-OPEN <GOTO ,TUNNEL> <RTRUE>)
		      (T
		       <TELL "It goes nowhere yet. Dig." CR>
		       <RTRUE>)>)
	       (<VERB? EXAMINE SEARCH LOOK-INSIDE>
		<COND (,TUNNEL-OPEN
		       <TELL "The burrow, fifty feet of it, going west under
the fortress." CR>)
		      (T
		       <TELL
"A cavity in the wall, and the beginning of an argument with the
Chateau d'If." CR>)>
		<RTRUE>)>>

"=== Puzzle II-4: breakthrough and the voice ==="

<ROUTINE DIG-WITH-HANDLE ()
	 <COND (<NOT <IN? ,PAN-HANDLE ,WINNER>>
		<TELL "You would need the iron in your hand." CR>)
	       (<NOT ,STONE-PRIED>
		<TELL "Pry the hewn stone out first. There is nothing to dig
into." CR>)
	       (,TUNNEL-OPEN
		<TELL "The burrow is dug. It goes where it goes." CR>)
	       (,BEAM-HIT
		<TELL "The beam is square across your way, and no amount of
iron will argue with it tonight." CR>)
	       (T
		<SETG DIG-COUNT <+ ,DIG-COUNT 1>>
		<COND (<EQUAL? ,DIG-COUNT 1>
		       <TELL
"Six inches a day, and the spoil scattered at the loophole. The seasons
grind past. It is 1826." CR>)
		      (<EQUAL? ,DIG-COUNT 2>
		       <TELL
"Ten feet, then twenty. You have learned to work in the dark by feel,
and to sleep with your ear against the stone, listening for a man you
have never seen." CR>)
		      (T <THE-BEAM>)>)>>

<ROUTINE THE-BEAM ()
	 <SETG BEAM-HIT T>
	 <SETG PHASE 6>
	 <MOVE ,VOICE ,CELL34>
	 <TELL
"The iron rings on something that is not stone. A beam, square across
your burrow, set there by builders who thought of everything." CR CR
"Something in you gives way at last. \"Oh, my God, my God! Do not let
me die in despair!\"" CR CR
"And the wall answers, in a voice like a file on iron:" CR
"\"Who talks of God and despair at the same time?\"" CR>>

<ROUTINE VOICE-FCN ()
	 <COND (<VERB? TELL ANSWER REPLY>
		<THE-CATECHISM>
		<RTRUE>)
	       (<VERB? LISTEN EXAMINE>
		<TELL "A voice out of three feet of rock, and the most
beautiful sound you have ever heard." CR>
		<RTRUE>)>>

<ROUTINE THE-CATECHISM ()
	 <COND (,CATECHISM
		<TELL "\"It is well. Tomorrow.\" And then nothing more, all
night." CR>)
	       (T
		<SETG CATECHISM T>
		<TELL
"\"A Frenchman,\" you say. \"Edmond Dantes, a sailor. Arrested in
eighteen fifteen, for a crime I did not commit.\"" CR CR
"\"Eighteen fifteen. I have been here four years longer than you, and I
have dug four years in the wrong direction.\" A pause you could build a
house in. \"I took the wrong angle: I am fifteen feet from where I
intended, and I have come out under your bed. It is well. Tomorrow.\""
CR>)>>

<ROUTINE FARIA-ARRIVES ()
	 <SETG PHASE 7>
	 <SETG TUNNEL-OPEN T>
	 <SETG FARIA-STATE 2>
	 <REMOVE ,VOICE>
	 <MOVE ,FARIA ,CELL34>
	 <ADD-SCORE 15>
	 <TELL
"In the night the floor of your cavity gives way in a slither of earth,
and out of the hole comes first the head, then the shoulders, and
lastly the body of a man." CR CR
"He is small and white-haired, with a black beard and eyes set deep
enough to hold a library. \"I am the Abbe Faria, prisoner since
eighteen eleven. And you, my friend, have saved me the trouble of dying
alone.\"" CR>
	 <RTRUE>>

"=== The tunnel and cell 27 ==="

<ROUTINE TUNNEL-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<COND (<G? ,ACT 4>
		       <TELL
"The burrow between the cells, propped and dusty, shown to tourists
now. Fifty feet of two men's patience." CR>
		       <COND (<NOT ,MANUSCRIPT-TAKEN>
			      <TELL
"Something pale is wedged in the roof timbers, where nobody thought to
look." CR>)>)
		      (T
		       <TELL
"A burrow a man may pass on his elbows, fifty feet of clawed-out dark
between your cell and the abbe's. The air tastes of earth and
patience." CR>)>
		<RTRUE>)
	       (<EQUAL? .RARG ,M-END>
		<CELL-TICK>
		<RFALSE>)
	       (T <RFALSE>)>>

<ROUTINE TUNNEL-WEST ()
	 <COND (,CARRYING-BODY
		<TELL "You bear him through the earth you dug together, an
inch at a time." CR>)>
	 ,CELL27>

<ROUTINE CELL27-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-ENTER>
		<FARIA-FOLLOW>
		<RFALSE>)
	       (<EQUAL? .RARG ,M-END>
		<CELL-TICK>
		<RFALSE>)
	       (<EQUAL? .RARG ,M-LOOK>
		<COND (,IN-SACK
		       <TELL
"You see nothing but coarse canvas an inch from your eyes, and you hear
your own heart." CR>
		       <RTRUE>)>
		<RFALSE>)
	       (T <RFALSE>)>>

<ROUTINE FARIA-BED-FCN ()
	 <COND (<VERB? MOVE LOOK-BEHIND SEARCH EXAMINE>
		<TELL
"Behind the bed-head hangs a rope ladder of raveled sheets, thirty feet
of it, hemmed so no laundress would ever notice. \"Against one of those
unforeseen opportunities,\" the abbe says." CR>
		<RTRUE>)>>

<ROUTINE HEARTH-FCN ()
	 <COND (<VERB? MOVE RAISE OPEN SEARCH TAKE MOVE PUSH LOOK-INSIDE>
		<COND (,CACHE-OPEN
		       <TELL "The hearth-stone is up, and the hollow beneath
it open." CR>)
		      (T
		       <SETG CACHE-OPEN T>
		       <MOVE ,CACHE ,CELL27>
		       <MOVE ,NEEDLE ,CACHE>
		       <MOVE ,PHIAL ,CACHE>
		       <MOVE ,MANUSCRIPT ,CACHE>
		       <TELL
"The hearth-stone lifts on a hidden bevel, and the hollow beneath it
holds the whole estate of a free mind: a chisel, a knife, a fish-bone
needle, a little lamp, a small phial of red liquor, and a manuscript
written on two shirts." CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL "A disused hearth in a cell with no fire allowed in it.
The abbe smiles when you look at it." CR>
		<RTRUE>)>>

<ROUTINE CACHE-FCN ()
	 <COND (<VERB? EXAMINE SEARCH LOOK-INSIDE> <RFALSE>)>>

<ROUTINE KNIFE-FCN ()
	 <COND (<AND <VERB? TAKE> <L? ,FARIA-STATE 3> <NOT ,FARIA-DEAD>>
		<TELL
"The abbe's hand closes gently over yours. \"Everything I have is
yours. When you can use it.\"" CR>
		<RTRUE>)
	       (<AND <VERB? DROP PUT> ,IN-SACK>
		<TELL "Not now. Not for anything." CR>
		<RTRUE>)>>

<ROUTINE PHIAL-FCN ()
	 <COND (<AND <VERB? GIVE PUT DROP POUR-ON>
		     <OR ,FIT-ACTIVE <EQUAL? ,PRSI ,FARIA>>>
		<POUR-THE-PHIAL>
		<RTRUE>)
	       (<AND <VERB? TAKE> ,FIT-ACTIVE> <RFALSE>)
	       (<AND <VERB? TAKE> <L? ,FARIA-STATE 3> <NOT ,FARIA-DEAD>>
		<TELL
"\"Not that one, my friend. That one is my last argument with God.\""
CR>
		<RTRUE>)>>

<ROUTINE POUR-THE-PHIAL ()
	 <COND (<NOT ,FIT-ACTIVE>
		<TELL "He is not dying this minute. Keep it for when he is."
CR>)
	       (,FARIA-SAVED
		<TELL "He has had the drops. Now he only needs time." CR>)
	       (<NOT <IN? ,PHIAL ,WINNER>>
		<TELL "You would have to be holding the phial." CR>)
	       (T
		<SETG FARIA-SAVED T>
		<SETG FIT-ACTIVE <>>
		<SETG SCENE-LOCK <>>
		<SETG FARIA-STATE 3>
		<ADD-SCORE 5>
		<TELL
"You force the clenched teeth and count ten drops of the red liquor
onto his tongue." CR CR
"He shudders, and his eyes come back from wherever they had gone. \"My
arm is dead,\" he says at last, quite calmly. \"My leg is dead. The
next one will take the rest. Sit down, Edmond. The treasure must not
die with me.\"" CR>)>>

"=== Faria: conversation, topics, lessons ==="

<ROUTINE FARIA-FCN ()
	 <COND (,FARIA-DEAD <FARIA-CORPSE>)
	       (<AND <VERB? TELL> ,PRSI> <FARIA-TOPIC>)
	       (<VERB? TELL> <FARIA-GREET>)
	       (<VERB? STUDY> <FARIA-LESSON> <RTRUE>)
	       (<VERB? EXAMINE>
		<COND (<EQUAL? ,FARIA-STATE 3>
		       <TELL
"Half of him will not move any more. The other half is still the
sharpest thing in France." CR>)
		      (T
		       <TELL
"Small, white-haired, black-bearded, and about sixty-five; and when he
looks at you it is the first time in years that anyone has." CR>)>
		<RTRUE>)
	       (<VERB? ATTACK MUNG>
		<TELL "He is the only friend you have in the world." CR>
		<RTRUE>)
	       (<VERB? KISS>
		<TELL "You take his hands instead. He lets you." CR>
		<RTRUE>)>>

<ROUTINE FARIA-CORPSE ()
	 <COND (<VERB? TELL EXAMINE>
		<TELL "He is dead, and the fortress does not care." CR>
		<RTRUE>)>>

<ROUTINE FARIA-GREET ()
	 <COND (<EQUAL? ,FARIA-STATE 3>
		<TELL
"\"Talk to me, Edmond. While the voice lasts.\"" CR>)
	       (,KNOWS-ENEMIES
		<TELL
"\"Then it is settled, and I am sorry I settled it. Come. There is
mathematics, and there is Italian, and there is a great deal you do not
know.\"" CR>)
	       (T
		<TELL
"\"Sit. Tell me everything, from the ship to this cell, and leave
nothing out because it seems small. It is always the small thing.\"" CR>)>
	 <RTRUE>>

<ROUTINE FARIA-LESSON ()
	 <COND (<EQUAL? ,FARIA-STATE 4>
		<TELL "There is no one left to teach you." CR>
		<RTRUE>)
	       (<G? ,LESSONS 3>
		<TELL
"\"There is nothing left in me that is not already in you. To learn is
not to know; there are the learners and the learned. Memory makes the
one, philosophy the other.\"" CR>
		<RTRUE>)>
	 <SETG LESSONS <+ ,LESSONS 1>>
	 <ADD-SCORE 5>
	 <COND (<EQUAL? ,LESSONS 1>
		<TELL
"Italian first, because it is the language of the treasure; then
Spanish, English, German, Greek. He has no books, so he is the book."
CR CR
"Six months. You dream in Italian now." CR>)
	       (<EQUAL? ,LESSONS 2>
		<TELL
"Mathematics next, scratched on the floor with a fish-bone: the angle
of his own mistaken tunnel, worked out to the inch, offered as a
lesson in humility." CR CR
"\"Two years. You reckon faster than I do, which is how a teacher
learns he is finished.\"" CR>)
	       (<EQUAL? ,LESSONS 3>
		<TELL
"History, which he says is only accounting kept by the winners. Cardinal
this, Emperor that, and always the same question underneath: who
gained?" CR CR
"Three years. Your voice has changed, and your handwriting is his." CR>)
	       (T
		<TELL
"Chemistry last, and he is oddly grave about it: brucine, which kills
by grains and cures by grains; the opiates, which counterfeit death for
a night and a day." CR CR
"\"Learn the poisons, Edmond. Not to use. To recognize. It is 1829, and
you know as much as I do myself.\"" CR>
		<START-THE-FIT>)>
	 <RTRUE>>

<ROUTINE START-THE-FIT ()
	 <COND (<OR ,FARIA-SAVED ,FIT-ACTIVE> <RFALSE>)>
	 <SETG FIT-ACTIVE T>
	 <SETG FIT-TURNS 0>
	 <SETG SCENE-LOCK T>
	 <TELL CR
"He stops in the middle of a word. His face goes the color of the
floor, his eyes roll back, and he goes down among the straw with his
teeth locked and his hands like claws." CR CR
"The cataleptic fit. He told you about it once, and told you where the
phial was kept." CR>
	 <RTRUE>>

<ROUTINE FARIA-TOPIC ()
	 <COND (<EQUAL? ,PRSI ,DANGLARS-T ,DANGLARS>
		<NAME-DANGLARS>)
	       (<EQUAL? ,PRSI ,FERNAND-T ,FERNAND>
		<NAME-FERNAND>)
	       (<EQUAL? ,PRSI ,VILLEFORT-T ,VILLEFORT>
		<NAME-VILLEFORT>)
	       (<EQUAL? ,PRSI ,LETTER-T ,ARREST-T>
		<COND (,KNOWS-ENEMIES
		       <TELL
"\"The letter is ashes and the men are not. Which is the whole of the
matter.\"" CR>)
		      (T
		       <TELL
"He listens to the whole of it without once interrupting, and at the end
he says: \"Seek first to discover the person to whom the bad action
could be in any way advantageous.\"" CR CR
"\"So. Who gained by your fall? Name them to me, one at a time.\"" CR>)>)
	       (<EQUAL? ,PRSI ,MORREL ,CMORR-T>
		<TELL
"\"Your shipowner lost a captain and gained a scandal. Cross him off.
Not every honest man is a fool, but every accusation of an honest man
is.\"" CR>)
	       (<EQUAL? ,PRSI ,CADEROUSSE ,CADEROUSSE4>
		<TELL
"\"A drunkard's silence is a sin, not a plot. Remember him, though. Men
like that are witnesses, and witnesses can be bought back.\"" CR>)
	       (<EQUAL? ,PRSI ,NOIRTIER-T>
		<TELL
"\"Noirtier. A Bonapartist of the old iron kind, and, if I have not
forgotten my Paris, the father of a rising royalist magistrate. Think
about that name, Edmond. Think about who would burn it.\"" CR>)
	       (<EQUAL? ,PRSI ,MERCEDES-T ,MERCEDES>
		<TELL
"\"Love waits differently than hate. Both wait.\" He does not say which
of them keeps better." CR>)
	       (<EQUAL? ,PRSI ,ESCAPE-T>
		<COND (<L? ,LESSONS 2>
		       <TELL
"\"Patience. My tools took four years and my tunnel took eight, and
both were wrong. First become a man worth freeing.\"" CR>)
		      (T
		       <TELL
"\"Two men, one crippled. The sea below, the sentries above, and the
sack that goes over the rampart every time a prisoner dies.\" He says
that last part slowly, and looks at you to see whether you heard it."
CR>)>)
	       (<EQUAL? ,PRSI ,TREASURE-T ,SPADA-T>
		<TELL-THE-SPADA>)
	       (<EQUAL? ,PRSI ,PARCHMENT>
		<RECONSTRUCT-PARCHMENT>)
	       (<EQUAL? ,PRSI ,GOD-T>
		<TELL
"\"God is patient, which men mistake for absence. I have had fourteen
years to consider the difference.\"" CR>)
	       (<EQUAL? ,PRSI ,MANUSCRIPT>
		<TELL
"\"A treatise on the monarchy of Italy, written on two shirts with soot
and Sunday wine. If it never leaves this rock, it will still have been
worth writing.\"" CR>)
	       (T
		<TELL
"\"Later, perhaps. There are only two subjects in this fortress worth
the breath: what was done to you, and what you will make of yourself.\""
CR>)>
	 <RTRUE>>

"=== Puzzle II-5: the deduction ==="

<ROUTINE NAME-DANGLARS ()
	 <COND (,SAID-DANG
		<TELL "\"Danglars. Yes. We have had him.\"" CR>)
	       (T
		<SETG SAID-DANG T>
		<ADD-SCORE 5>
		<TELL
"\"The supercargo, who wanted your ship. Tell me again about the
cabin.\" And you remember it: Danglars at the door while Leclere gave
you the packet." CR CR
"\"He wrote it. With his left hand, so that the writing would betray
nobody. Writing done with the left hand is invariably uniform.\"" CR>
		<CHECK-ENEMIES>)>>

<ROUTINE NAME-FERNAND ()
	 <COND (,SAID-FERN
		<TELL "\"The Catalan. Yes. We have had him too.\"" CR>)
	       (T
		<SETG SAID-FERN T>
		<ADD-SCORE 5>
		<TELL
"\"The cousin who wanted your girl. An assassination such a man will
commit unhesitatingly; an act of cowardice, never.\" He turns it over."
CR CR
"\"Yet somebody carried that letter to the post. He did not write it.
He posted it. That is the worse of the two.\"" CR>
		<CHECK-ENEMIES>)>>

<ROUTINE NAME-VILLEFORT ()
	 <COND (,SAID-VILL
		<TELL "\"The magistrate. Yes. He is the deepest of them.\""
CR>)
	       (T
		<SETG SAID-VILL T>
		<ADD-SCORE 5>
		<TELL
"\"Now think. He told you the letter was your ruin, and then he burned
it. A magistrate does not burn evidence against a prisoner. He burns
evidence against himself.\"" CR CR
"\"Whose name was on it? Noirtier. He burned it because the name was
his father's. He buried you to bury it.\"" CR>
		<CHECK-ENEMIES>)>>

<ROUTINE CHECK-ENEMIES ()
	 <COND (<AND ,SAID-DANG ,SAID-FERN ,SAID-VILL <NOT ,KNOWS-ENEMIES>>
		<SETG KNOWS-ENEMIES T>
		<TELL CR
"The abbe is quiet a long time. \"I repent me of my work,\" he says at
last. \"I have put hatred into a heart that had none.\"" CR CR
"\"Not hatred, father. Justice.\"" CR>)>
	 <RTRUE>>

"=== Puzzle II-7: the parchment ==="

<ROUTINE TELL-THE-SPADA ()
	 <COND (<L? ,FARIA-STATE 3>
		<TELL
"\"When I am past helping, I will tell you. Not before. A treasure is a
weight on a young man's patience.\"" CR>)
	       (,SPADA-TOLD
		<TELL
"\"The island of Monte Cristo, a creek to the west, and the twentieth
rock in a right line east. Say it back to me.\"" CR>)
	       (T
		<SETG SPADA-TOLD T>
		<MOVE ,PARCHMENT ,WINNER>
		<TELL
"\"In fourteen ninety-eight Cardinal Spada was invited to dine by his
Holiness Alexander the Sixth, and the Spada fortune was never seen
again. His nephew inherited a breviary and a bad dinner.\"" CR CR
"\"Three hundred years later the last Spada left the breviary to me,
and I burned a paper in it by accident, and the fire wrote on it.\" He
draws a scorched half-sheet out of his rags and puts it in your hand."
CR>)>
	 <RTRUE>>

<ROUTINE PARCHMENT-FCN ()
	 <COND (<VERB? READ EXAMINE>
		<COND (,PARCH-WHOLE
		       <TELL
"The will entire, the burnt half restored in the abbe's hand: the
island of Monte Cristo; the creek to the west; the twentieth rock in a
right line to the east; the second opening; and in the farthest angle,
all that a cardinal could carry away from a poisoning." CR>)
		      (T
		       <SETG PARCH-READ T>
		       <TELL
"Fire has eaten the left half of every line. What is left reads: \"ing
invited to dine by his Holi ... the caves of the small ... ck from the
small cr ... angle in the second op ...\"" CR CR
"It is a will with half its words burnt off, and it is worth asking the
abbe about." CR>)>
		<RTRUE>)
	       (<VERB? DROP PUT GIVE MUNG>
		<TELL "It stays sewn into your rags, where it has been since
he gave it to you." CR>
		<RTRUE>)>>

<ROUTINE RECONSTRUCT-PARCHMENT ()
	 <COND (<NOT ,SPADA-TOLD>
		<TELL "\"What parchment?\" he says, and smiles, which is not
a denial." CR>)
	       (,PARCH-WHOLE
		<TELL
"\"You have it by heart now, which is the only safe place for it.\""
CR>)
	       (T
		<SETG PARCH-WHOLE T>
		<MOVE ,PARCHMENT ,WINNER>
		<ADD-SCORE 10>
		<TELL
"He recites the missing half without hesitating once, and as he says it
the burnt lines close up in your head like a wound healing." CR CR
"\"The twentieth rock from the small creek to the east in a right line;
the second opening; and in the farthest angle. If we escape together,
half is yours. If I die here, it is yours alone.\"" CR>)>
	 <RTRUE>>

<ROUTINE MANUSCRIPT-FCN ()
	 <COND (<AND <VERB? TAKE> <G? ,ACT 4>>
		<COND (,MANUSCRIPT-TAKEN <RFALSE>)
		      (T
		       <SETG MANUSCRIPT-TAKEN T>
		       <MOVE ,MANUSCRIPT ,WINNER>
		       <ADD-SCORE 5>
		       <TELL
"Two shirts' worth of linen, a life's worth of mind, wedged in the roof
timbers where the masons never looked." CR CR
"The guide asks whether monsieur is unwell. Monsieur is only breathing
the air of his own grave." CR>
		       <RTRUE>)>)
	       (<VERB? READ>
		<TELL
"A treatise on a general monarchy of Italy, in a hand so small the
linen looks printed. He wrote it twice: once on the shirts, and once
into you." CR>
		<RTRUE>)>>

"=== Faria's death and the sack ==="

<ROUTINE THE-THIRD-ATTACK ()
	 <SETG FARIA-DEAD T>
	 <SETG FARIA-STATE 4>
	 <SETG SCENE-LOCK T>
	 <TELL
"It comes at night, and this time the drops do nothing. \"It is
useless,\" he whispers. \"Only now the fit is stronger.\"" CR CR
"\"The treasure is yours, Edmond. Do not forget you have your
executioners to punish, and perhaps, too, who knows, some friends to
reward.\" His hand tightens once. \"Monte Cristo!\"" CR CR>
	 <MOVE ,BODY ,CELL27>
	 <REMOVE ,FARIA>
	 <RTRUE>>

<ROUTINE THE-MORNING-AFTER ()
	 <SETG PHASE 9>
	 <SETG SWAP-TURNS 1>
	 <MOVE ,SACK ,CELL27>
	 <TELL
"Morning brings the governor's doctor, and you listen to it all from
the mouth of the burrow." CR CR
"The jokes; the hot iron laid on the heel, which is decisive, and which
you smell through three feet of rock; the needle going in and out of
the canvas. \"This evening. About ten or eleven o'clock. Shut the
dungeon as if he were alive; that is all.\"" CR CR
"They go. On the bed lies a sewn sack, and in the sack lies the only
thing in this fortress that will pass the walls tonight." CR>
	 <RTRUE>>

<ROUTINE SACK-FCN ()
	 <COND (<VERB? EXAMINE>
		<COND (,SACK-SEWN
		       <TELL "Canvas an inch from your face, and your own
breath coming back at you off it." CR>)
		      (,SACK-OPEN
		       <TELL "The seam is parted the length of a man." CR>)
		      (T
		       <TELL
"Canvas, coarse, sewn with a strong seam. Faria's last winding-sheet.
It is the only thing in this fortress that will pass the walls
tonight." CR>)>
		<RTRUE>)
	       (<VERB? CUT MUNG OPEN>
		<COND (<EQUAL? ,HERE ,UNDERSEA> <CUT-SACK-UNDERWATER>)
		      (T <OPEN-THE-SACK>)>
		<RTRUE>)
	       (<VERB? GETIN BOARD THROUGH>
		<ENTER-THE-SACK>
		<RTRUE>)
	       (<VERB? SEW>
		<SEW-THE-SACK>
		<RTRUE>)>>

<ROUTINE OPEN-THE-SACK ()
	 <COND (,SACK-OPEN
		<TELL "It is open already." CR>)
	       (<NOT <IN? ,KNIFE ,WINNER>>
		<TELL "The seam is strong and your nails are nothing. You
want the abbe's knife." CR>)
	       (T
		<SETG SACK-OPEN T>
		<TELL
"The seam parts under the iron blade. The abbe's face is calm, and a
little amused, the way it was in life." CR CR
"\"Forgive me, father.\"" CR>)>>

<ROUTINE BODY-FCN ()
	 <COND (<VERB? TAKE DRAG MOVE>
		<TAKE-THE-BODY>
		<RTRUE>)
	       (<AND <VERB? PUT> <EQUAL? ,PRSI ,PRISON-BED>>
		<PUT-BODY-IN-BED>
		<RTRUE>)
	       (<VERB? COVER>
		<COVER-THE-BODY>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"He weighs nothing at all. Fourteen years of prison rations and one
great mind, and this is what it comes to." CR>
		<RTRUE>)
	       (<VERB? DROP>
		<COND (,CARRYING-BODY
		       <SETG CARRYING-BODY <>>
		       <MOVE ,BODY ,HERE>
		       <TELL "You lay him down as gently as the floor
allows." CR>)
		      (T <TELL "You are not carrying him." CR>)>
		<RTRUE>)>>

<ROUTINE TAKE-THE-BODY ()
	 <COND (,CARRYING-BODY
		<TELL "You have him." CR>)
	       (<NOT ,SACK-OPEN>
		<TELL "He is sewn into the canvas. You would have to open it
first." CR>)
	       (T
		<SETG CARRYING-BODY T>
		<MOVE ,BODY ,WINNER>
		<TELL
"You gather him up. He is lighter than the idea of him. Your hands are
full now, and will stay full until he is where he is going." CR>)>>

<ROUTINE PUT-BODY-IN-BED ()
	 <COND (<NOT <EQUAL? ,HERE ,CELL34>>
		<TELL "Not this bed. Yours, in cell thirty-four, where the
jailer expects to find a man asleep." CR>)
	       (,BODY-PLACED
		<TELL "He lies in your bed already." CR>)
	       (T
		<SETG BODY-PLACED T>
		<SETG CARRYING-BODY <>>
		<MOVE ,BODY ,PRISON-BED>
		<TELL
"You lay the abbe in your own bed, on your own straw, in the place
where number thirty-four sleeps." CR>)>>

<ROUTINE COVER-THE-BODY ()
	 <COND (<NOT ,BODY-PLACED>
		<TELL "Get him into the bed first." CR>)
	       (,BODY-COVERED
		<TELL "He is covered, and turned, and could be anyone." CR>)
	       (T
		<SETG BODY-COVERED T>
		<TELL
"You draw the blanket to his chin, tie your own night-rag about his
head, and turn his face to the wall." CR CR
"By lamplight, from a grate, he is a prisoner sleeping. Any prisoner."
CR>)>>

<ROUTINE ENTER-THE-SACK ()
	 <COND (,SACK-SEWN
		<TELL "You are in it, and it is sewn." CR>)
	       (<NOT <EQUAL? ,HERE ,CELL27>>
		<TELL
"The sack is in the abbe's cell, and so must you be. They will not come
looking for a corpse in cell thirty-four." CR>)
	       (<NOT ,SACK-OPEN>
		<TELL "It is sewn shut, and occupied." CR>)
	       (<IN? ,BODY ,CELL27>
		<TELL
"You would be lying down beside him. He has to be in your bed before
you can be in his sack." CR>)
	       (,IN-SACK
		<TELL "You are in it." CR>)
	       (T
		<SETG IN-SACK T>
		<COND (<IN? ,KNIFE ,WINNER>
		       <TELL
"You settle into the dead man's place, and draw the canvas over your
face, and hold the knife against your chest with both hands." CR>)
		      (T
		       <TELL
"You settle into the dead man's place. The canvas smells of the sea it
was made for." CR CR
"Your hands are empty. Something cold crosses your mind: whatever comes
next, you cannot so much as scratch your way out of this." CR>)>)>>

<ROUTINE SEW-THE-SACK ()
	 <COND (<NOT ,IN-SACK>
		<TELL "You would have to be inside it first." CR>)
	       (,SACK-SEWN
		<TELL "It is sewn. Now you wait, and try not to breathe like
a living man." CR>)
	       (<NOT <IN? ,NEEDLE ,WINNER>>
		<TELL
"You have no needle. The abbe kept one under the hearth-stone, made of
a fish-bone and still threaded." CR>)
	       (T
		<SETG SACK-SEWN T>
		<SETG SWAP-TURNS 20>
		<SETG HAVE-KNIFE-IN-SACK <IN? ,KNIFE ,WINNER>>
		<ADD-SCORE 15>
		<TELL
"From the inside, stitch by stitch, you close your own shroud. Your
heart is so loud they will surely hear it." CR>)>>

"=== The drop ==="

<ROUTINE THE-DROP ()
	 <SETG SCENE-LOCK T>
	 <TELL
"Boots on the stair, and a lantern, and two men who have done this
before." CR CR
"\"Heavy, though, for an old man.\" \"They say the bones get heavier
every year.\" A pause; and a heavy metallic substance is laid down
beside you, and something is knotted hard about your ankles." CR CR
"\"What's the knot for?\" you have one second to wonder." CR CR
"Fifty paces. The sea-noise coming up. A swing, and a swing, and: One!
Two! Three!" CR CR>
	 <SETG BREATH 0>
	 <SETG SACK-OPEN <>>
	 <GOTO ,UNDERSEA>
	 <MOVE ,SACK ,UNDERSEA>
	 <RTRUE>>

"=== Puzzle II-9: underwater ==="

<ROUTINE UNDERSEA-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-END>
		<SETG BREATH <+ ,BREATH 1>>
		<COND (<EQUAL? ,BREATH 2>
		       <TELL "Your chest begins to burn." CR>)
		      (<EQUAL? ,BREATH 4>
		       <TELL "Red stars crowd the edges of your eyes." CR>)
		      (<EQUAL? ,BREATH 5>
		       <TELL "The cold is going away, which is the worst sign
there is." CR>)
		      (<G? ,BREATH 5> <DROWN>)>
		<RTRUE>)
	       (T <RFALSE>)>>

<ROUTINE DROWN ()
	 <COND (<NOT ,SACK-CUT>
		<TELL "You claw at the canvas with your nails. The sack is strong; the sea is
stronger; and the thirty-six-pound shot knows the way." CR CR
"The sea is the cemetery of the Chateau d'If. You never saw it." CR>
		<JIGS-UP "">)
	       (T
		<TELL "Free of the canvas and tied to the shot, you go down with the sack
floating open above you like a shed skin." CR CR
"The sea is the cemetery of the Chateau d'If. You never saw it." CR>
		<JIGS-UP "">)>>

<ROUTINE CUT-SACK-UNDERWATER ()
	 <COND (,SACK-CUT
		<TELL "The canvas is behind you." CR>)
	       (<NOT <IN? ,KNIFE ,WINNER>>
		<TELL
"You have nothing to cut with. Your nails find the seam and the seam
holds." CR>)
	       (T
		<SETG SACK-CUT T>
		<TELL
"You rip the canvas from top to bottom and shed it like a skin. But the
shot still has your feet." CR>)>>

<ROUTINE CORD-FCN ()
	 <COND (<VERB? CUT UNTIE MUNG OPEN TAKE MOVE>
		<COND (,CORD-CUT
		       <TELL "Your feet are free. Up." CR>)
		      (<NOT ,SACK-CUT>
		       <TELL "You cannot reach your own feet inside a sewn
sack." CR>)
		      (<NOT <IN? ,KNIFE ,WINNER>>
		       <TELL "With what? Your hands are empty." CR>)
		      (T
		       <SETG CORD-CUT T>
		       <TELL
"Bent double in the black, you saw the cord through at the moment the
strangling starts. The shot goes on down without you." CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL "A cord at your ankles, and a thirty-six-pound shot on
the other end of it." CR>
		<RTRUE>)>>

<ROUTINE UNDERSEA-UP ()
	 <COND (<AND ,SACK-CUT ,CORD-CUT>
		<ADD-SCORE 15>
		<SETG SCENE-LOCK <>>
		<TELL
"Three strokes, four, and your head comes out into air and rain and the
whole black roaring sky." CR CR
"You are free. You have been free for nine seconds and you are already
counting." CR CR>
		,OPENSEA)
	       (,SACK-CUT
		<TELL "The shot holds you down as surely as a hand." CR>
		<RFALSE>)
	       (T
		<TELL "The canvas is sewn over your face, and the sea is
sewn over the canvas." CR>
		<RFALSE>)>>

"=== Puzzle II-10: the swim ==="

<ROUTINE OPENSEA-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK> <RFALSE>)
	       (T <RFALSE>)>>

<ROUTINE OPENSEA-WEST ()
	 <SETG SWIM-COUNT <+ ,SWIM-COUNT 1>>
	 <COND (<EQUAL? ,SWIM-COUNT 1>
		<TELL
"You strike out west with the mistral behind you and the light of
Planier over your left shoulder, as the abbe said." CR>
		<RFALSE>)
	       (<EQUAL? ,SWIM-COUNT 2>
		<TELL
"An hour, perhaps two. Your arms have stopped belonging to you and go
on anyway." CR>
		<RFALSE>)
	       (T
		<ADD-SCORE 5>
		<TELL
"Something tears your knee. Rock. Blessed, merciful rock." CR CR>
		,TIBOULEN)>>

<ROUTINE OPENSEA-BAD ()
	 <SETG WRONG-SWIM <+ ,WRONG-SWIM 1>>
	 <COND (<G? ,WRONG-SWIM 2>
		<TELL "The boat is on you before you can dive. A hand in your hair, and a
lantern in your face, and a laugh." CR CR
"They take you back to a cell below the waterline, and the register is
amended, and the sea keeps its ledger as Danglars keeps his." CR>
		<JIGS-UP "">)
	       (T
		<TELL
"Behind you the chateau shows a moving torch on the rampart, and the
sound of oars comes down the wind. That way is the way back." CR>
		<RFALSE>)>>

<ROUTINE GLOBAL-WATER-FCN ()
	 <COND (<AND <VERB? DRINK DRINK-FROM> <EQUAL? ,HERE ,TIBOULEN>>
		<DRINK-THE-HOLLOW>
		<RTRUE>)
	       (<VERB? DRINK DRINK-FROM>
		<TELL "Salt, and more salt." CR>
		<RTRUE>)>>

"=== Tiboulen ==="

<ROUTINE TIBOULEN-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<TELL
"A grotesque mass of bare rocks, like a vast fire petrified at the
moment of its most fervent combustion. No tree, no soul, no shelter but
an overhanging stone." CR>
		<COND (,STORM-DONE
		       <TELL
"Wreckage from the night lies along the waterline, and out past the
point a tartan is standing in toward Pomegue." CR>)
		      (T
		       <TELL "It is the most beautiful place you have ever
seen." CR>)>
		<RTRUE>)
	       (<EQUAL? .RARG ,M-END>
		<COND (<NOT ,STORM-DONE> <TIBOULEN-TICK>)>
		<RFALSE>)
	       (T <RFALSE>)>>

<GLOBAL TIB-TURNS 0>
<GLOBAL SHELTERED <>>

<ROUTINE TIBOULEN-TICK ()
	 <SETG TIB-TURNS <+ ,TIB-TURNS 1>>
	 <COND (<EQUAL? ,TIB-TURNS 2>
		<TELL "The mistral turns to a gale and the rain comes in
sideways." CR>
		<RTRUE>)
	       (<EQUAL? ,TIB-TURNS 4>
		<TELL
"Out in the dark a fishing boat is shouting. Then splintering. Then
nothing you can do anything about." CR>
		<RTRUE>)
	       (<G? ,TIB-TURNS 5>
		<TIBOULEN-DAWN>
		<RTRUE>)>>

<ROUTINE TIBOULEN-DAWN ()
	 <SETG STORM-DONE T>
	 <MOVE ,WRECKAGE ,TIBOULEN>
	 <MOVE ,RED-CAP ,TIBOULEN>
	 <MOVE ,SPAR ,TIBOULEN>
	 <FCLEAR ,RED-CAP ,NDESCBIT>
	 <FCLEAR ,SPAR ,NDESCBIT>
	 <MOVE ,TARTAN-SHIP ,TIBOULEN>
	 <TELL
"Dawn, gray and washed. Far off across the water, the gun of the
Chateau d'If thuds twice: they have found the grave empty." CR CR
"Along the waterline lies what the sea did not want of a fishing boat:
splinters, a spar, and a red woolen cap. And rounding Pomegue with the
morning wind, a Genoese tartan." CR>
	 <RTRUE>>

<ROUTINE OVERHANG-FCN ()
	 <COND (<VERB? GETIN BOARD THROUGH>
		<SETG SHELTERED T>
		<TELL
"You wedge yourself under the overhang with your knees at your chin.
The rain goes past a foot from your face and does not touch you." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL "A leaning slab with a dry hollow under it: the only
roof between here and Africa." CR>
		<RTRUE>)>>

<ROUTINE HOLLOW-FCN ()
	 <COND (<VERB? DRINK DRINK-FROM EXAMINE SEARCH>
		<DRINK-THE-HOLLOW>
		<RTRUE>)>>

<ROUTINE DRINK-THE-HOLLOW ()
	 <TELL
"A basin of last night's rain in the rock. You drink it a palmful at a
time and it is better than the wine of La Malgue." CR>
	 <RTRUE>>

<ROUTINE RED-CAP-FCN ()
	 <COND (<VERB? WEAR>
		<MOVE ,RED-CAP ,WINNER>
		<SETG IDENTITY 0>
		<TELL
"You pull the dead man's cap over your wet hair. From a hundred yards
you are a Maltese sailor who has had a bad night." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL "A red woolen cap off a drowned fisherman. It is the
whole of your disguise, and it will do." CR>
		<RTRUE>)>>

<ROUTINE TARTAN-SHIP-FCN ()
	 <COND (<VERB? WAVEAT WAVE YELL TELL>
		<HAIL-THE-TARTAN>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL "A Genoese tartan under lateen sails, standing in close
enough to see a man on the rocks." CR>
		<RTRUE>)>>

<ROUTINE HAIL-THE-TARTAN ()
	 <COND (<NOT ,STORM-DONE>
		<TELL "There is nothing out there but weather." CR>)
	       (<NOT <IN? ,RED-CAP ,WINNER>>
		<TELL
"They put the helm over and stand off. A naked man swimming from the
direction of a prison island invites questions. You want the cap." CR>)
	       (T
		<ADD-SCORE 10>
		<TELL
"You climb the highest rock with the spar under your arm and shout
until your voice tears." CR CR
"A boat comes. You are a Maltese sailor, sole survivor of the tartan
Young Amelia, wrecked on Tiboulen in the night; and the lie holds,
because sailors want it to." CR CR>
		<ENTER-ACT-THREE>)>>

<ROUTINE ENTER-ACT-THREE ()
	 <SETG ACT 3>
	 <SETG SCENE-LOCK T>
	 <TELL
"Three months among the smugglers of the Jeune-Amelie, running
contraband from Leghorn to the Corsican coast, growing a beard and a
character. And then, in the ordinary way of business, a cargo to be
transferred off an uninhabited rock in the Tyrrhenian Sea." CR CR
"    ***  ACT THREE: MONTE CRISTO, 1829  ***" CR CR>
	 <GOTO ,TARTAN>
	 <RTRUE>>

"=== The jailer demon and the phase machine ==="

;"Faria is a companion, not a wanderer: while he can still crawl he is
wherever you are, and once he is paralyzed he is in his own cell and
you go to him."
<ROUTINE FARIA-FOLLOW ()
	 <COND (<OR ,FARIA-DEAD <L? ,FARIA-STATE 2>> <RFALSE>)
	       (<EQUAL? ,FARIA-STATE 3>
		<COND (<NOT <IN? ,FARIA ,CELL27>> <MOVE ,FARIA ,CELL27>)>
		<RFALSE>)
	       (<EQUAL? ,HERE ,TUNNEL> <RFALSE>)
	       (<NOT <IN? ,FARIA ,HERE>>
		<MOVE ,FARIA ,HERE>
		<RFALSE>)>>

<ROUTINE CELL-TICK ()
	 <COND (<G? ,ACT 5> <IF-TOUR-TICK> <RFALSE>)
	       (<NOT <EQUAL? ,ACT 2>> <RFALSE>)>
	 <FARIA-FOLLOW>
	 <PHASE-TICK>
	 <RFALSE>>

<GLOBAL PHASE-TURNS 0>

<ROUTINE PHASE-TICK ()
	 <SETG PHASE-TURNS <+ ,PHASE-TURNS 1>>
	 <COND (<AND <EQUAL? ,PHASE 1> <G? ,PHASE-TURNS 3>>
		<SETG PHASE 2>
		<SETG PHASE-TURNS 0>
		<TELL CR
"The seasons grind past the loophole. You count them for a while and
then you stop counting." CR CR
"You beg for a trial and are not answered. You refuse food for three
days and eat on the fourth, ashamed. You pray, and the praying wears
smooth like a step." CR CR
"It is the sixth year, and one night, low in the wall, you hear
something that is not the sea." CR>
		<RTRUE>)
	       (<AND <EQUAL? ,PHASE 2> ,KNOCKED>
		<SETG PHASE 3>
		<SETG PHASE-TURNS 0>
		<TELL CR
"Three days of silence, and you learn what hope costs when it is taken
back." CR CR
"Then, at evening: the scratching again, deeper now, and unmistakably
coming your way." CR>
		<SETG SOUND-BACK T>
		<RTRUE>)
	       (<AND <EQUAL? ,PHASE 3> ,PLATE-SET <G? ,PHASE-TURNS 0>>
		<THE-PLATE-BREAKS>
		<RTRUE>)
	       (<AND <EQUAL? ,PHASE 6> ,CATECHISM <G? ,PHASE-TURNS 1>>
		<FARIA-ARRIVES>
		<RTRUE>)
	       (<AND ,FIT-ACTIVE <NOT ,FARIA-SAVED>>
		<SETG FIT-TURNS <+ ,FIT-TURNS 1>>
		<COND (<EQUAL? ,FIT-TURNS 1>
		       <TELL "His breathing is a saw in a wet board. The
phial is under the hearth-stone." CR>)
		      (<EQUAL? ,FIT-TURNS 2>
		       <TELL "His lips are going blue." CR>)
		      (<G? ,FIT-TURNS 3>
		       <SETG FIT-ACTIVE <>>
		       <SETG SCENE-LOCK <>>
		       <SETG FARIA-STATE 3>
		       <TELL
"The fit lets go of him by itself, at last, and leaves half of him
behind. \"You were slow,\" he says, without reproach. \"My arm is dead.
My leg is dead. Sit down, Edmond. The treasure must not die with me.\""
CR>)>
		<RTRUE>)
	       (<AND <EQUAL? ,FARIA-STATE 3> ,PARCH-WHOLE
		     <NOT ,FARIA-DEAD>
		     <G? ,PHASE-TURNS 1>>
		<THE-THIRD-ATTACK>
		<RTRUE>)
	       (<AND ,FARIA-DEAD <EQUAL? ,PHASE 8>>
		<THE-MORNING-AFTER>
		<RTRUE>)
	       (<AND ,FARIA-DEAD <L? ,PHASE 8>>
		<SETG PHASE 8>
		<SETG PHASE-TURNS 0>
		<TELL
"The night goes by with him in it. Toward morning you hear boots on the
stair, more than one pair." CR>
		<RTRUE>)
	       (<G? ,SWAP-TURNS 0> <SWAP-TICK>)
	       (T <RFALSE>)>>

<ROUTINE SWAP-TICK ()
	 <COND (,SACK-SEWN
		<SETG SWAP-TURNS <- ,SWAP-TURNS 1>>
		<COND (<L? ,SWAP-TURNS 19>
		       <THE-DROP>
		       <RTRUE>)>
		<RFALSE>)>
	 <SETG SWAP-TURNS <+ ,SWAP-TURNS 1>>
	 <SETG SWAP-IDLE <+ ,SWAP-IDLE 1>>
	 <COND (<EQUAL? ,SWAP-TURNS 6>
		<TELL "Somewhere over the water a bell counts seven." CR>
		<RTRUE>)
	       (<EQUAL? ,SWAP-TURNS 9>
		<TELL
"None but the dead pass freely from this dungeon." CR>
		<RTRUE>)
	       (<EQUAL? ,SWAP-TURNS 14>
		<TELL "A bell counts eight, and does not hurry." CR>
		<RTRUE>)
	       (<EQUAL? ,SWAP-TURNS 18>
		<TELL
"Since none but the dead pass freely: let me take the place of the
dead." CR>
		<RTRUE>)
	       (<EQUAL? ,SWAP-TURNS 24>
		<TELL "Nine. Two hours, at the outside." CR>
		<RTRUE>)
	       (<G? ,SWAP-TURNS 31> <SWAP-FAILED> <RTRUE>)
	       (T <RFALSE>)>>

<ROUTINE SWAP-FAILED ()
	 <TELL "Ten o'clock, and the bearers come." CR CR>
	 <COND (,SACK-OPEN
		<TELL
"The lantern finds a cut seam and a dead man lying where nobody left
him, and one of them goes back up the stair at a run." CR CR>)
	       (T
		<TELL
"They take up the sack the way they took up the last one and carry the
abbe out over the rampart, and shut the dungeon as if he were alive.
The only thing in this fortress that would have passed the walls
tonight has passed them without you." CR CR
"The tunnel is found within the week, in the ordinary way." CR CR>)>
	 <TELL
"The governor's report is four lines. A tunnel between cells
thirty-four and twenty-seven; the prisoner moved to the dungeons below
the waterline; the register amended." CR CR
"The sea is the cemetery of the Chateau d'If, and it keeps its ledger
the way Danglars keeps his: every soul accounted, none remembered.
Nobody comes. That was always the other ending, and now it is yours."
CR>
		<JIGS-UP "">>

;"The jailer's round. SCENE-LOCK is the interlock the design calls for:
every scripted scene sets it, and while it is set the demon requeues
without ever looking into a cell. Without it the round walks straight
into the sack swap and hangs the player for tidying a corpse."
<ROUTINE I-JAILER ()
	 <ENABLE <QUEUE I-JAILER 12>>
	 <COND (<NOT <EQUAL? ,ACT 2>> <RFALSE>)
	       (,SCENE-LOCK <RFALSE>)
	       ;"Once the abbe is dead the clock in SWAP-TICK is the danger,
		not the round; the round would only walk into the scripted
		scene the design warns about."
	       (<OR ,FARIA-DEAD ,IN-SACK ,SACK-SEWN> <RFALSE>)
	       (<G? ,SWAP-TURNS 0> <RFALSE>)>
	 <SETG JAILER-TICK <+ ,JAILER-TICK 1>>
	 <COND (<AND ,JUG-BROKEN <EQUAL? ,JAILER-TICK 1>>
		<TELL
"The grate opens. The jailer looks in at the gravel of your jug,
grunts, and comes back with another. He does not ask." CR>
		<RTRUE>)
	       (<AND ,TUNNEL-OPEN <NOT <EQUAL? ,HERE ,CELL34>>>
		;"Absent, with a hole in the wall. Before Faria you have no
		 craft and the round is lethal; his first lesson is the straw
		 dummy, and from then on the grate finds a sleeping prisoner."
		<COND (<G? ,FARIA-STATE 1>
		       <TELL
"Far off on the stair, boots; and then, a long way behind you, the
grate of cell thirty-four sliding open and shut." CR CR
"He looked at the abbe's straw and your blanket arranged in your bed,
and he saw a prisoner asleep." CR>)
		      (T <JAILER-DISCOVERY>)>
		<RTRUE>)
	       (<AND ,BED-MOVED <NOT ,TUNNEL-OPEN>
		     <EQUAL? ,HERE ,CELL34>>
		<TELL
"Boots on the stair. You put your back against the bed and your heart
in your mouth, and his lantern sweeps past the shadow of it and finds
nothing worth a report." CR>
		<RTRUE>)
	       (T
		<TELL "Boots on the stair. The grate opens, and shuts, and
the day is over." CR>
		<RTRUE>)>>

<GLOBAL NEAR-MISS <>>

<ROUTINE JAILER-DISCOVERY ()
	 <TELL "Boots on the stair, and the grate, and a silence exactly the wrong
length." CR CR
"They tear the bed aside. The hole gapes like a mouth with nothing more
to say." CR CR
"The governor moves you to the dungeons below the waterline. The years
there are not described." CR>
		<JIGS-UP "">>

<ROUTINE THE-PLATE-BREAKS ()
	 <SETG PHASE 4>
	 <SETG PLATE-SET <>>
	 <SETG PAN-LEFT T>
	 <REMOVE ,PLATE>
	 <MOVE ,SAUCEPAN ,CELL34>
	 <MOVE ,PAN-HANDLE ,CELL34>
	 <TELL
"Evening, and the jailer comes in with the soup and puts his foot
squarely on your plate." CR CR
"He grinds it to powder, curses you at length, looks around for
anything at all to pour the soup into, and finding nothing, leaves you
the saucepan." CR CR
"\"You destroy everything,\" he says in the morning. \"Very well. I
shall leave you the saucepan.\"" CR>
	 <RTRUE>>
