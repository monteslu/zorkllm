"OZWEST - Act III: the Winkie campaign, the castle, the bucket, the Cap."

"=== The march west and the four waves ==="

<ROUTINE WFIELDS-FCN (RARG)
	 <COND (<==? .RARG ,M-ENTER>
		<COND (<AND <==? ,WAVE 0> <NOT ,CAPTURED>>
		       <SETG WAVE 1>
		       <SETG WAVE-TURNS 0>
		       <SETG SCENE-FLAG T>
		       <MOVE ,WOLVES ,WEST-FIELDS>
		       <ENABLE <QUEUE I-WAVE -1>>
		       <TELL CR
"Your dress, which was green in the city, is white again out here, and
nobody remarks on it except the Scarecrow, who says he has a theory about
that city." CR CR
"Far off on the hill, the castle's one window turns toward you, and a
silver whistle blows, once. Out of the grass come forty great wolves with
long teeth, running." CR>)>
		<RFALSE>)
	       (<==? .RARG ,M-BEG>
		<COND (<AND <G? ,WAVE 0> <L? ,WAVE 3> <VERB? WALK>>
		       <TELL "There is no getting past this pack by walking." CR>
		       <RTRUE>)>)>>

<ROUTINE WHILLS-FCN (RARG)
	 <COND (<==? .RARG ,M-ENTER>
		<COND (<AND <==? ,WAVE 3> <NOT ,CAPTURED>>
		       <SETG WAVE-TURNS 0>
		       <SETG SCENE-FLAG T>
		       <MOVE ,BEES ,WEST-HILLS>
		       <ENABLE <QUEUE I-WAVE -1>>
		       <TELL CR
"The whistle blows a third time, and the chattering in the air becomes a
black cloud: a swarm of bees, coming fast, and there is no shade and
nowhere to hide." CR>)>
		<RFALSE>)
	       (<==? .RARG ,M-BEG>
		<COND (<AND <G? ,WAVE 2> <L? ,WAVE 5> <VERB? WALK>>
		       <TELL "Not through this." CR>
		       <RTRUE>)>)>>

<ROUTINE WFIELDS-WEST ()
	 <COND (<G? ,WAVE 2> ,WEST-HILLS)
	       (T
		<TELL "Not with this lot in the grass." CR>
		<RFALSE>)>>

<ROUTINE WHILLS-WEST ()
	 <TELL "The castle stands on the hill, and there is no road to it, and
something in the air is getting louder." CR>
	 <RFALSE>>

<ROUTINE I-WAVE ()
	 <COND (,CAPTURED <RFALSE>)>
	 <SETG WAVE-TURNS <+ ,WAVE-TURNS 1>>
	 <COND (<L? ,WAVE-TURNS 3>
		<COND (<==? ,WAVE-TURNS 2> <WAVE-HINT>)>
		<RFALSE>)
	       (T
		;"Companions never let you lose a scene battle."
		<TELL CR "Nobody waits to be asked." CR>
		<COND (<==? ,WAVE 1> <WAVE1-WIN>)
		      (<==? ,WAVE 2> <DO-SCARE-CROWS>)
		      (<==? ,WAVE 3> <DO-STRAW>)
		      (T <WAVE4-WIN>)>
		<RTRUE>)>>

<ROUTINE WAVE-HINT ()
	 <COND (<==? ,WAVE 1>
		<TELL CR "\"This is my fight,\" says the Tin Woodman, and
sharpens his axe on the sole of his tin foot, and waits to be told." CR>)
	       (<==? ,WAVE 2>
		<TELL CR "\"This is my fight,\" says the Scarecrow. \"Lie down
beside me and you will not be harmed.\"" CR>)
	       (<==? ,WAVE 3>
		<TELL CR "\"Take out my straw and scatter it over the little
girl and the dog and the Lion,\" says the Scarecrow, \"and the bees
cannot sting them. Then let them try the tin one.\"" CR>)
	       (T
		<TELL CR "The Lion clears his throat, several times,
significantly." CR>)>
	 <RTRUE>>

<ROUTINE WAVE1-WIN ()
	 <COND (<N==? ,WAVE 1> <RFALSE>)>
	 <SETG WAVE 2>
	 <SETG WAVE-TURNS 0>
	 <SETG WAVES-WON <+ ,WAVES-WON 1>>
	 <SCORE-IT 5>
	 <REMOVE ,WOLVES>
	 <MOVE ,CROWS ,WEST-FIELDS>
	 <TELL
"The Tin Woodman stands in the road with his axe, and as each wolf comes
he swings, and the wolf stops being a wolf. Forty times. Then he sits
down on the pile of them, which is quite high, and rests." CR CR
"\"It was a good fight, friend,\" says the Scarecrow." CR CR
"The whistle blows a second time, and out of the sky comes a flock of
forty wild crows, so many that the sun goes dim." CR>
	 <RTRUE>>

<ROUTINE DO-SCARE-CROWS ()
	 <COND (<N==? ,WAVE 2>
		<COND (<HAS-SCARE?>
		       <TELL "\"There is nothing here to frighten,\" says the
Scarecrow, \"and I am not sure I could.\"" CR>
		       <RTRUE>)
		      (T
		       <TELL "There is nothing here to scare off." CR>
		       <RTRUE>)>)>
	 <SETG WAVE 3>
	 <SETG WAVE-TURNS 0>
	 <SETG WAVES-WON <+ ,WAVES-WON 1>>
	 <SCORE-IT 5>
	 <REMOVE ,CROWS>
	 <TELL
"You lie down in the grass beside the Woodman and the Lion and Toto, and
the Scarecrow stands up alone, tall and still, with his arms out." CR CR
"The King Crow is frightened of him and says so, loudly, and comes at his
head anyway, and the Scarecrow catches him by the neck and wrings it.
Then the next, and the next, until there are forty crows in a heap and
not one of them is bothering anybody." CR CR
"\"Get up,\" says the Scarecrow, pleased. \"It is quite safe now.\"" CR>
	 <SETG SCENE-FLAG <>>
	 <RTRUE>>

<ROUTINE DO-STRAW ()
	 <COND (<N==? ,WAVE 3>
		<TELL "There is no reason to unstuff anybody just now." CR>
		<RTRUE>)>
	 <SETG WAVE 4>
	 <SETG WAVE-TURNS 0>
	 <SETG WAVES-WON <+ ,WAVES-WON 1>>
	 <SCORE-IT 5>
	 <REMOVE ,BEES>
	 <MOVE ,WINKIES ,WEST-HILLS>
	 <SETG SCENE-FLAG T>
	 <ENABLE <QUEUE I-WAVE -1>>
	 <TELL
"You pull the straw out of the Scarecrow's clothes and heap it over
yourself and Toto and the Lion, and there is nothing left showing but tin." CR CR
"The bees come down and find nothing to sting but the Tin Woodman, and
break their stings on him, and a bee cannot live when its sting is broken.
They fall around his feet like little heaps of fine coal." CR CR
"You gather the straw and stuff the Scarecrow back into shape, patting him
straight, and he says it is a great deal better than being carried." CR CR
"Then the whistle blows a fourth time, and a dozen Winkies come over the
hill with spears." CR>
	 <RTRUE>>

<ROUTINE WAVE4-WIN ()
	 <COND (<N==? ,WAVE 4> <RFALSE>)>
	 <SETG WAVE 5>
	 <SETG WAVES-WON <+ ,WAVES-WON 1>>
	 <SCORE-IT 5>
	 <REMOVE ,WINKIES>
	 <TELL
"The Lion gives a great loud roar and springs forward, and the Winkies
discover urgent business elsewhere. They run so fast that some of them run
out of their shoes." CR CR
"Faintly, from the direction of the castle, you can hear somebody being
beaten with an umbrella, and a voice complaining about the quality of
help." CR>
	 <ENABLE <QUEUE I-MONKEYS 2>>
	 <RTRUE>>

"=== The Winged Monkeys: capture, not defeat ==="

<ROUTINE I-MONKEYS ()
	 <COND (,CAPTURED <RFALSE>)>
	 <DISABLE <INT I-WAVE>>
	 <SETG CAPTURED T>
	 <SETG SCENE-FLAG T>
	 <SETG WOOD-STATE 2>
	 <SETG SCARE-STATE 3>
	 <SETG LION-STATE 3>
	 <MOVE ,WOODMAN ,ROCKY-PLAIN>
	 <MOVE ,CLOTHES ,TALL-TREE>
	 <REMOVE ,SCARECROW>
	 <MOVE ,LION ,COURTYARD>
	 <TELL CR
"The sky goes dark, and it is not a cloud: it is wings, a great many
wings, and chattering, and laughing." CR CR
"The Tin Woodman swings his axe and is picked up and carried high over the
rocks and dropped, and lies there battered out of all shape. The Scarecrow
is pulled apart, straw and all, and his clothes are tossed into the top of
a tall tree. The Lion roars, and is simply picked up, and roped, and
carried away to a yard behind iron bars." CR CR
"Then a Monkey comes for you, and stops with his long arms out, and does
not touch you. \"We dare not harm this little girl,\" he says, \"for she
is protected by the Power of Good, and that is greater than the Power of
Evil.\" And so, in the politest possible way, the Winged Monkeys carry
you and Toto gently through the air and set you down on the doorstep of
the castle of the Wicked Witch of the West." CR CR
"You have arrived. You were always going to arrive; this was simply the
road." CR CR>
	 <MOVE ,WINNER ,CASTLE-KITCHEN>
	 <SETG HERE ,CASTLE-KITCHEN>
	 <MOVE ,TOTO ,CASTLE-KITCHEN>
	 <MOVE ,WITCH-WEST ,CASTLE-KITCHEN>
	 <SETG SCENE-FLAG <>>
	 <SETG ACT 3>
	 <V-LOOK>
	 <RTRUE>>

<ROUTINE WOLVES-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "Forty great gray wolves with long teeth, coming in a
line." CR>
		<RTRUE>)
	       (<VERB? ATTACK CHOP STOP SCARE> <WAVE1-WIN>)>>

<ROUTINE CROWS-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "Forty wild crows, wheeling, and the sun dim behind
them." CR>
		<RTRUE>)
	       (<VERB? ATTACK SCARE STOP CHOP> <DO-SCARE-CROWS>)>>

<ROUTINE BEES-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "A black swarm of bees, and no shade anywhere to hide
in." CR>
		<RTRUE>)
	       (<VERB? ATTACK SCARE STOP COVER SCATTER> <DO-STRAW>)>>

<ROUTINE HIS-STRAW-FCN ()
	 <COND (<VERB? TAKE SCATTER COVER PUT> <DO-STRAW>)
	       (<VERB? EXAMINE>
		<TELL "Good dry straw, currently doing duty as a Scarecrow." CR>
		<RTRUE>)>>

<ROUTINE WINKIES-FCN ()
	 <COND (<AND <==? ,WAVE 4> <VERB? ATTACK SCARE ROAR STOP>>
		<WAVE4-WIN>)
	       (<VERB? EXAMINE>
		<COND (<==? ,WAVE 4>
		       <TELL "A dozen small yellow people with spears, who
plainly wish they were somewhere else." CR>)
		      (T
		       <TELL "Small, kind, yellow people who have been slaves
so long they are surprised by good weather." CR>)>
		<RTRUE>)
	       (<AND <VERB? TELL ASK-FOR RESCUE COMMAND HELLO>
		     ,WITCH-DEAD>
		<WINKIE-HELP>)
	       (<==? ,WINNER ,WINKIES> <WINKIE-HELP>)>>

<ROUTINE MONKEY-KING-FCN ()
	 <COND (<VERB? EXAMINE>
		<COND (,CAP-GIVEN
		       <TELL "The King of the Winged Monkeys, who bows a good
deal less like a servant this time, and rather more like a friend." CR>)
		      (T
		       <TELL "A great Monkey with wings, courteous, bound, and
tired of it. He bows to the Cap, not to you." CR>)>
		<RTRUE>)
	       (<AND <VERB? TELL FLY COMMAND> ,MONKEYS-HERE> <DO-FLY>)
	       (<==? ,WINNER ,MONKEY-KING> <DO-FLY>)>>

"=== The castle: servitude ==="

<ROUTINE KITCHEN-FCN (RARG)
	 <COND (<==? .RARG ,M-ENTER>
		<COND (<AND <==? ,CDAY 3> <NOT ,THEFT-DONE> ,CAPTURED
			    <NOT ,WITCH-DEAD>>
		       <SHOE-THEFT>)>
		<RFALSE>)
	       (<==? .RARG ,M-LOOK>
		<COND (<AND ,WITCH-DEAD <NOT ,MESS-SWEPT>>
		       <TELL "A brown, spreading mess is drying slowly on the
flagstones." CR>)>
		<RFALSE>)
	       (<==? .RARG ,M-BEG>
		<COND (<AND <VERB? PUT PUT-ON THROW BURN>
			    <EQUAL? ,PRSO ,FIREWOOD ,WOOD-W>>
		       <DO-CHORE 3>)
		      (<AND <VERB? THROW POUR-ON PUT PUT-ON SPRAY DROP>
			    <EQUAL? ,PRSO ,WATER ,BUCKET ,GLOBAL-WATER>
			    <IN? ,WITCH-WEST ,HERE>
			    <NOT ,WITCH-DEAD>>
		       <MELT-WITCH>)
		      (<AND <VERB? THROW POUR-ON SPRAY>
			    <EQUAL? ,PRSI ,WITCH-WEST>
			    <NOT ,WITCH-DEAD>>
		       <MELT-WITCH>)>)>>

<ROUTINE HEARTH-FIRE-FCN ()
	 <COND (<AND <VERB? PUT PUT-ON THROW BURN> <EQUAL? ,PRSO ,FIREWOOD>>
		<DO-CHORE 3>)
	       (<VERB? EXAMINE>
		<TELL "A wood fire on a great hearth, kept going because the
Witch is always cold." CR>
		<RTRUE>)>>

<ROUTINE FIREWOOD-FCN ()
	 <COND (<AND <VERB? PUT PUT-ON THROW> <EQUAL? ,PRSI ,HEARTH-FIRE>>
		<DO-CHORE 3>)
	       (<VERB? BURN>
		<DO-CHORE 3>)
	       (<VERB? EXAMINE>
		<TELL "Split wood, stacked by the hearth, and always needing
more." CR>
		<RTRUE>)>>

<ROUTINE KITCHEN-POTS-FCN ()
	 <COND (<VERB? BRUSH SWEEP RUB> <DO-CHORE 2>)
	       (<VERB? EXAMINE>
		<TELL "Black pots and kettles, sooty on the outside and
scoured on the inside, which is your doing." CR>
		<RTRUE>)>>

<ROUTINE BROOM-FCN ()
	 <COND (<VERB? SWEEP BRUSH> <DO-CHORE 1>)
	       (<VERB? EXAMINE>
		<TELL "A plain kitchen broom. It is not for flying; nothing in
this country flies except monkeys and one balloon." CR>
		<RTRUE>)>>

<ROUTINE V-SWEEP ()
	 <COND (<AND <==? ,HERE ,CASTLE-KITCHEN> ,WITCH-DEAD <NOT ,MESS-SWEPT>>
		<SETG MESS-SWEPT T>
		<REMOVE ,WITCH-MESS>
		<TELL "You get the broom and sweep what is left of the Wicked
Witch of the West out of the door and into the yard, and then you sweep
the step, because you were raised properly." CR>
		<RTRUE>)
	       (<==? ,HERE ,CASTLE-KITCHEN> <DO-CHORE 1>)
	       (T
		<TELL "There is nothing here that wants sweeping." CR>
		<RTRUE>)>>

<ROUTINE DO-CHORE (WHICH)
	 <COND (<N==? ,HERE ,CASTLE-KITCHEN>
		<TELL "Not here." CR>
		<RTRUE>)
	       (,WITCH-DEAD
		<TELL "The Winkies will not hear of you doing another stroke of
work in this castle." CR>
		<RTRUE>)
	       (<BTST ,CHORES .WHICH>
		<TELL "You have done that one today, and it stayed done." CR>
		<RTRUE>)
	       (T
		<SETG CHORES <BOR ,CHORES .WHICH>>
		<COND (<==? .WHICH 1>
		       <TELL "You sweep the great sooty floor, and the Witch
watches you do it, and crosses the room the long way round afterward,
keeping her skirts well clear of the damp flagstones." CR>)
		      (<==? .WHICH 2>
		       <TELL "You scour the black pots until your arms ache.
Toto sits in the doorway and supervises." CR>)
		      (T
		       <TELL "You build the fire up. The Witch comes near it,
and holds out her hands, and does not thank you." CR>)>
		<COND (<AND <BTST ,CHORES 1> <BTST ,CHORES 2>>
		       <CHORE-DAY-DONE>)
		      (<AND <BTST ,CHORES 1> <BTST ,CHORES 3>>
		       <CHORE-DAY-DONE>)
		      (<AND <BTST ,CHORES 2> <BTST ,CHORES 3>>
		       <CHORE-DAY-DONE>)>
		<RTRUE>)>>

<ROUTINE CHORE-DAY-DONE ()
	 <SETG FED-TONIGHT <>>
	 <TELL CR
"The light goes out of the little window, and the Witch goes up to her own
rooms, because she is afraid of the dark, and the castle is yours until
morning." CR>
	 <RTRUE>>

<ROUTINE WITCH-CUPBOARD-FCN ()
	 <COND (<VERB? OPEN SEARCH LOOK-INSIDE EXAMINE>
		<FSET ,WITCH-CUPBOARD ,OPENBIT>
		<COND (<AND ,WITCH-DEAD <FSET? ,GOLDEN-CAP ,INVISIBLE>>
		       <FCLEAR ,GOLDEN-CAP ,INVISIBLE>
		       <TELL "The cupboard holds cold meat, and bread, and, at
the very back where nobody was ever meant to look, a Golden Cap with a
circle of diamonds and rubies round it." CR>)
		      (T
		       <TELL "There is cold meat in the cupboard, and bread." CR>)>
		<RTRUE>)>>

<ROUTINE MEAT-FCN ()
	 <COND (<AND <VERB? GIVE> <EQUAL? ,PRSI ,LION>> <DO-FEED>)
	       (<VERB? EXAMINE>
		<TELL "A good deal of cold meat, more than one girl needs and
exactly what one Lion needs." CR>
		<RTRUE>)>>

<ROUTINE DO-FEED ()
	 <COND (<N==? ,HERE ,COURTYARD>
		<TELL "The Lion is in the yard behind the castle." CR>
		<RTRUE>)
	       (<NOT <IN? ,MEAT ,WINNER>>
		<TELL "You have nothing to give him. There is meat in the
kitchen cupboard." CR>
		<RTRUE>)
	       (,FED-TONIGHT
		<TELL "He has eaten, and is asleep with his chin on his paws." CR>
		<RTRUE>)
	       (T
		<SETG FED-TONIGHT T>
		<SETG FEEDINGS <+ ,FEEDINGS 1>>
		<REMOVE ,MEAT>
		<TELL
"You push the meat through the bars, and the Lion eats it in a way that
suggests he has not been eating much, and then lies down with his head
against the bars so you can put your own head on his mane." CR CR
"\"If I could only get out of this yard,\" he says, \"we would go away
together, and we would never come back. She is more afraid than we
are.\" You talk about escaping until you are almost asleep, and then you
go up to the cold little garret before anybody misses you." CR>
		<COND (<AND <==? ,FEEDINGS 2> <NOT ,SC-FEED>>
		       <SETG SC-FEED T>
		       <SCORE-IT 10>)>
		<MOVE ,MEAT ,WITCH-CUPBOARD>
		<RTRUE>)>>

<ROUTINE COURTYARD-FCN (RARG)
	 <COND (<==? .RARG ,M-LOOK>
		<COND (<AND <==? ,LION-STATE 3> <NOT ,LION-FREED>>
		       <TELL "Behind the bars paces the Cowardly Lion, trying
to look dangerous and mostly looking hungry." CR>)>
		<RFALSE>)>>

<ROUTINE IRON-GATE-FCN ()
	 <COND (<VERB? OPEN UNLOCK UNTIE>
		<COND (,LION-FREED <TELL "It stands open." CR>)
		      (,WITCH-DEAD <FREE-LION>)
		      (T
		       <TELL "The gate is locked, and the Witch keeps the key
somewhere about her, and she is watching." CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL "A high iron fence with a barred gate, "
		      <COND (,LION-FREED "standing open") (T "locked")> "." CR>
		<RTRUE>)>>

<ROUTINE FREE-LION ()
	 <SETG LION-FREED T>
	 <SETG LION-STATE 1>
	 <MOVE ,LION ,HERE>
	 <MOVE ,WINKIES ,CASTLE-HALL>
	 <TELL
"The lock has no more power in it than she had; the gate swings open, and
the Lion comes out and puts his great head against you and nearly knocks
you over." CR CR
"All over the castle the Winkies are shouting. They have been slaves for
years, and they declare a holiday on the spot, and keep it for the rest of
the week." CR>
	 <RTRUE>>

<ROUTINE STRAW-PILE-FCN ()
	 <COND (<VERB? STUFF PUT TAKE> <DO-STUFF>)
	       (<VERB? EXAMINE>
		<TELL "A pile of clean straw in the corner of the yard,
bedding for a Lion who never used it." CR>
		<RTRUE>)>>

<ROUTINE GARRET-BED-FCN ()
	 <COND (<VERB? SLEEP ENTER BOARD CLIMB-ON> <V-SLEEP>)
	       (<VERB? EXAMINE>
		<TELL "A narrow hard bed under the roof, and out of the little
window all the Winkie country lies yellow in the moonlight." CR>
		<RTRUE>)>>

<ROUTINE GARRET-FCN (RARG) <RFALSE>>

<ROUTINE CASTLE-NIGHT ()
	 <COND (,WITCH-DEAD
		<TELL "You sleep, and nothing in this castle frightens anybody
any more." CR>
		<RTRUE>)
	       (<L? ,CDAY 3>
		<SETG CDAY <+ ,CDAY 1>>
		<SETG CHORES 0>
		<SETG FED-TONIGHT <>>
		<TELL "You sleep in the cold garret with Toto against your
back, and in the morning the Witch is banging on the door with her
umbrella." CR>
		<RTRUE>)
	       (T
		<TELL "You cannot sleep. Tomorrow is going to be a day; you can
feel it through the floor." CR>
		<RTRUE>)>>

<ROUTINE HALL-FCN (RARG) <RFALSE>>

<ROUTINE HALL-WEST ()
	 <COND (<AND ,WITCH-DEAD <==? ,WOOD-STATE 2>> ,ROCKY-PLAIN)
	       (,WITCH-DEAD ,ROCKY-PLAIN)
	       (T
		<TELL "The great west door is barred, and you are not going
anywhere until this business is finished." CR>
		<RFALSE>)>>

<ROUTINE HALL-OUT ()
	 <COND (<NOT ,WITCH-DEAD>
		<TELL "The doors are barred and the Witch has the keys." CR>
		<RFALSE>)
	       (<OR <NOT ,WOOD-FIXED> <NOT ,SCARE-FIXED>>
		<TELL "Not yet. There are two friends of yours out in that
country in a bad way." CR>
		<RFALSE>)
	       (T <LEAVE-CASTLE>)>>

<ROUTINE LEAVE-CASTLE ()
	 <TELL
"The Winkies beg you all to stay, and when you will not, they load you
with presents: a golden collar for Toto, a diamond bracelet for you, a
gold-headed walking stick for the Scarecrow, and a silver oil-can studded
with jewels for the Woodman, who cries a little and has to be wiped." CR CR
"Then you set out east across the yellow country to find the Emerald City
again." CR>
	 <MOVE ,BRACELET ,WINNER>
	 ,LOST-FIELDS>

"=== The Witch, the theft, and the bucket ==="

<ROUTINE WITCH-WEST-FCN ()
	 <COND (,WITCH-DEAD <RFALSE>)
	       (<VERB? EXAMINE>
		<TELL "A little old woman, thin and bent, with one eye only,
but that eye is as powerful as a telescope. She carries an umbrella
everywhere and has never once been seen to drink anything." CR>
		<RTRUE>)
	       (<VERB? THROW POUR-ON SPRAY>
		<COND (<OR <EQUAL? ,PRSO ,WATER ,BUCKET ,GLOBAL-WATER>
			   <EQUAL? ,PRSI ,WATER ,BUCKET ,GLOBAL-WATER>>
		       <MELT-WITCH>)
		      (T
		       <TELL "It bounces off her, and she laughs at you." CR>
		       <RTRUE>)>)
	       (<VERB? ATTACK SLAP CHOP STOP>
		<TELL "She is twice your reach, and anyway you were raised
polite. She raises her umbrella, looks at the mark on your forehead, and
thinks better of it, and you both stand there being unable to hurt each
other." CR>
		<RTRUE>)
	       (<VERB? TELL HELLO>
		<TELL "\"Work,\" says the Wicked Witch of the West, \"or I
shall make an end of you.\" She does not, and cannot, and both of you
know it, which is the worst thing about her." CR>
		<RTRUE>)>>

<ROUTINE SHOE-THEFT ()
	 <SETG THEFT-DONE T>
	 <SETG SCENE-FLAG T>
	 <SETG DITHER 0>
	 <MOVE ,WITCH-WEST ,CASTLE-KITCHEN>
	 <ENABLE <QUEUE I-DITHER -1>>
	 <TELL CR
"Your foot catches on something in the middle of the clean floor, where
there is nothing at all, and you go down full length. There is no mark on
the flagstones and nothing to trip on: only an iron bar the Witch has made
invisible, and her laughing." CR CR
"One silver shoe has come off in the fall. Before you can reach it she has
snatched it up and put it on her own thin foot." CR CR
"\"I shall keep it, just the same,\" she says, \"and someday I shall get
the other one from you, too.\"" CR CR
"You are angry. You are, in fact, angrier than you have ever been in your
life." CR>
	 <RTRUE>>

<ROUTINE I-DITHER ()
	 <COND (<OR ,WITCH-DEAD <NOT ,THEFT-DONE>> <RFALSE>)>
	 <SETG DITHER <+ ,DITHER 1>>
	 <COND (<==? ,DITHER 5>
		<TELL CR "Toto stands in front of the bucket by the door and
growls at it, which is not like him." CR>
		<RTRUE>)
	       (<==? ,DITHER 10>
		<TELL CR
"\"And there's not a thing you can do about it,\" says the Witch, dancing
a little on her stolen shoe, \"for you'd never dare splash me. Nobody
would dare splash me.\"" CR>
		<RTRUE>)>
	 <RFALSE>>

<ROUTINE BUCKET-FCN ()
	 <COND (<AND <VERB? THROW POUR-ON PUT SPRAY>
		     <IN? ,WITCH-WEST ,HERE>
		     <NOT ,WITCH-DEAD>>
		<MELT-WITCH>)
	       (<VERB? EXAMINE LOOK-INSIDE>
		<TELL "A wooden bucket, standing by the door, full to the brim
with cold water from the well." CR>
		<RTRUE>)
	       (<VERB? TAKE>
		<COND (<IN? ,BUCKET ,WINNER>
		       <TELL "You have it, and it is heavy, and it is
slopping." CR>)
		      (T
		       <MOVE ,BUCKET ,WINNER>
		       <TELL "You lift the bucket of water. It is heavy, and
some of it goes on the floor." CR>)>
		<RTRUE>)>>

<ROUTINE MELT-WITCH ()
	 <COND (<OR ,WITCH-DEAD <NOT <IN? ,WITCH-WEST ,HERE>>> <RFALSE>)>
	 <DISABLE <INT I-DITHER>>
	 <SETG WITCH-DEAD T>
	 <SETG SCENE-FLAG <>>
	 <REMOVE ,WITCH-WEST>
	 <REMOVE ,BUCKET>
	 <MOVE ,WITCH-MESS ,CASTLE-KITCHEN>
	 <MOVE ,STOLEN-SHOE ,CASTLE-KITCHEN>
	 <COND (<NOT ,SC-MELT> <SETG SC-MELT T> <SCORE-IT 26>)>
	 <TELL
"You seize the bucket of water and dash it over her, from head to foot." CR CR
"Instantly she gives a loud cry of fear, and then, as you look at her in
wonder, she begins to shrink away and fall down." CR CR
"\"See what you have done!\" she screams. \"In a minute I shall melt
away.\"" CR CR
"\"I'm very sorry, indeed,\" you say, truthfully, for you are." CR CR
"\"Didn't you know water would be the end of me?\" she asks, in a wailing,
despairing voice. \"Of course not,\" you answer. \"How should I?\"" CR CR
"\"Well, in a few minutes I shall be all melted, and you will have the
castle to yourself. I have been wicked in my day, but I never thought a
little girl like you would ever be able to melt me and end my wicked
deeds. Look out, here I go!\"" CR CR
"And with these words she falls down in a brown, melted, shapeless mass
and begins to spread over the clean boards of the kitchen floor. And in
the middle of it, when it stops spreading, sits one silver shoe." CR>
	 <RTRUE>>

<ROUTINE WITCH-MESS-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "A brown, spreading, shapeless mess, which is all that is
left of the Wicked Witch of the West. It is not even frightening." CR>
		<RTRUE>)
	       (<VERB? SWEEP BRUSH TAKE> <V-SWEEP>)>>

<ROUTINE STOLEN-SHOE-FCN ()
	 <COND (<VERB? TAKE>
		<COND (<IN? ,STOLEN-SHOE ,WINNER>
		       <TELL "You have it." CR>)
		      (T
		       <MOVE ,STOLEN-SHOE ,WINNER>
		       <TELL "You pick the silver shoe out of the mess. It is
wet, and horrible, and yours." CR>)>
		<RTRUE>)
	       (<VERB? WIPE BRUSH RUB>
		<COND (<NOT <IN? ,STOLEN-SHOE ,WINNER>>
		       <TELL "Pick it up first." CR>)
		      (T
		       <TELL "You wipe the shoe clean on your apron, twice,
and then a third time for luck." CR>
		       <FCLEAR ,STOLEN-SHOE ,INVISIBLE>)>
		<RTRUE>)
	       (<VERB? WEAR>
		<COND (,SHOE-BACK
		       <TELL "It is on your foot where it belongs." CR>)
		      (T
		       <COND (<NOT <IN? ,STOLEN-SHOE ,WINNER>>
			      <MOVE ,STOLEN-SHOE ,WINNER>)>
		       <SETG SHOE-BACK T>
		       <REMOVE ,STOLEN-SHOE>
		       <COND (<NOT ,SC-SHOE2> <SETG SC-SHOE2 T> <SCORE-IT 5>)>
		       <TELL "You wipe the shoe on your apron and put it back
on your foot, and stand up, and you are wearing both silver shoes again,
and nobody in this country is ever going to take one off you." CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL "One silver shoe, wet through, sitting in a brown mess on
a clean kitchen floor." CR>
		<RTRUE>)>>

"=== The rescues ==="

<ROUTINE WINKIE-HELP ()
	 <COND (<AND <==? ,HERE ,ROCKY-PLAIN> <==? ,WOOD-STATE 2>>
		<FIX-WOODMAN>)
	       (T
		<TELL "\"Anything at all,\" says the Winkie foreman. \"You have
only to say it. Is there anything out in the country that wants
carrying?\"" CR>
		<RTRUE>)>>

<ROUTINE PLAIN-FCN (RARG)
	 <COND (<AND <==? .RARG ,M-ENTER> <==? ,WOOD-STATE 2>>
		<MOVE ,WINKIES ,ROCKY-PLAIN>
		<TELL CR
"On the rocks lies the Tin Woodman, so battered and dented that he can
neither move nor groan. His axe lies beside him, the blade rusted and the
handle broken short." CR>
		<RFALSE>)>>

<ROUTINE FIX-WOODMAN ()
	 <SETG WOOD-STATE 3>
	 <SETG WOOD-FIXED T>
	 <MOVE ,WOODMAN ,CASTLE-HALL>
	 <COND (<NOT ,SC-WFIX> <SETG SC-WFIX T> <SCORE-IT 10>)>
	 <TELL
"The Winkies pick him up, tenderly, and carry him back to the castle, and
you walk beside him the whole way." CR CR
"Then the Winkie tinsmiths, who are very good at their trade because they
have had a great deal of practice, work on him for three days and four
nights, hammering and twisting and bending and soldering and polishing,
until at last he is straight and shining and himself. The goldsmiths make
him a new handle for his axe, of solid gold, because they will not be told
otherwise." CR CR
"He cries when he thanks you, and his jaws begin to stick, and you wipe
his face with your apron before it goes any further, which is a thing you
are getting good at." CR CR
"\"If we could only find the Scarecrow,\" he says, \"I should be quite
happy.\"" CR>
	 <MOVE ,WINNER ,CASTLE-HALL>
	 <SETG HERE ,CASTLE-HALL>
	 <V-LOOK>
	 <RTRUE>>

<ROUTINE PLAIN-NORTH ()
	 <COND (,SCARE-FIXED ,TALL-TREE)
	       (<==? ,WOOD-STATE 3> ,TALL-TREE)
	       (T
		<TELL "One tree stands taller than the rest up north, and there
is something blue in the top of it. You will want an axe, and the only axe
in this country is lying right here in pieces." CR>
		<RFALSE>)>>

<ROUTINE TALL-TREE-FCN (RARG)
	 <COND (<AND <==? .RARG ,M-LOOK> <NOT ,SCARE-FIXED>
		     <IN? ,CLOTHES ,TALL-TREE>>
		<TELL "High in its branches hangs a small bundle of blue
clothes and a pointed hat." CR>
		<RFALSE>)>>

<ROUTINE TALL-TREE-OBJ-FCN ()
	 <COND (<VERB? CHOP CUT> <DO-CHOP>)
	       (<VERB? CLIMB-FOO CLIMB-UP>
		<TELL "The trunk is too smooth to climb." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL "A tall tree with a trunk too smooth to climb, and a
bundle of blue clothes caught in the very top." CR>
		<RTRUE>)>>

<ROUTINE TALL-TREE-CHOP ()
	 <MOVE ,CLOTHES ,TALL-TREE>
	 <TELL
"The Tin Woodman sets to work with his gold-handled axe, and the tall tree
comes down with a crash, and the bundle of clothes falls out of the
branches and rolls to your feet." CR>
	 <RTRUE>>

<ROUTINE CLOTHES-FCN ()
	 <COND (<VERB? STUFF PUT> <DO-STUFF>)
	       (<VERB? EXAMINE>
		<TELL "A suit of faded blue clothes and a pointed blue hat,
quite empty, and looking dreadfully like nobody." CR>
		<RTRUE>)>>

<ROUTINE DO-STUFF ()
	 <COND (,SCARE-FIXED
		<TELL "He is stuffed, thank you, and rather full." CR>
		<RTRUE>)
	       (<NOT <IN? ,CLOTHES ,WINNER>>
		<TELL "You would need his clothes, and they are in the top of
a tall tree west of here." CR>
		<RTRUE>)
	       (<N==? ,HERE ,COURTYARD>
		<TELL "You need straw, and there is a good clean pile of it in
the castle courtyard." CR>
		<RTRUE>)
	       (T
		<SETG SCARE-FIXED T>
		<SETG SCARE-STATE 1>
		<MOVE ,SCARECROW ,COURTYARD>
		<REMOVE ,CLOTHES>
		<COND (<NOT ,SC-SFIX> <SETG SC-SFIX T> <SCORE-IT 10>)>
		<TELL
"You carry the clothes to the straw pile, and the Winkies bring armfuls of
the cleanest straw, and the Tin Woodman shapes the head with his own
careful hands." CR CR
"And behold: here is the Scarecrow, as good as ever, thanking you over and
over again. He shakes hands all round, and finds his hat, and puts it on
at the wrong angle on purpose, because he knows it makes the Lion
laugh." CR>
		<RTRUE>)>>

"=== The Golden Cap ==="

<ROUTINE GOLDEN-CAP-FCN ()
	 <COND (<VERB? TAKE>
		<COND (<IN? ,GOLDEN-CAP ,WINNER>
		       <TELL "You have it." CR>)
		      (T
		       <MOVE ,GOLDEN-CAP ,WINNER>
		       <TELL "You take the Golden Cap. It is heavier than it
looks, and warm." CR>)>
		<RTRUE>)
	       (<VERB? WEAR>
		<COND (<NOT <IN? ,GOLDEN-CAP ,WINNER>>
		       <MOVE ,GOLDEN-CAP ,WINNER>)>
		<TELL "You put the Golden Cap on your head. It fits exactly, as
though it had been made for you, which is a thing that keeps happening in
this country." CR>
		<RTRUE>)
	       (<VERB? READ LOOK-INSIDE EXAMINE>
		<COND (<VERB? EXAMINE>
		       <TELL "A cap of gold with a circle of diamonds and
rubies round it, and writing on the lining." CR>
		       <RTRUE>)>
		<SETG CAP-READ T>
		<COND (<NOT ,SC-CAP> <SETG SC-CAP T> <SCORE-IT 5>)>
		<TELL "Written on the lining of the Golden Cap is a charm, and
under it a note saying that whoever owns the Cap may call the Winged
Monkeys three times, and no more." CR CR
"Left foot: Ep-pe, pep-pe, kak-ke!" CR
"Right foot: Hil-lo, hol-lo, hel-lo!" CR
"Both feet: Ziz-zy, zuz-zy, zik!" CR CR
"You have " N ,CAP-USES " command">
		<COND (<N==? ,CAP-USES 1> <TELL "s">)>
		<TELL " of the Winged Monkeys remaining." CR>
		<RTRUE>)>>

"The ritual. Words work as bare verbs or via SAY."

<ROUTINE V-EPPE ()
	 <COND (<NOT <CAP-OK?>> <RTRUE>)>
	 <SETG RITUAL 1>
	 <TELL "(standing on your left foot) \"Ep-pe, pep-pe, kak-ke!\"" CR>
	 <RTRUE>>

<ROUTINE V-HILLO ()
	 <COND (<NOT <CAP-OK?>> <RTRUE>)>
	 <COND (<L? ,RITUAL 1>
		<TELL "You say it, but you have not begun properly. The charm
starts on the left foot." CR>
		<RTRUE>)>
	 <SETG RITUAL 2>
	 <TELL "(standing on your right foot) \"Hil-lo, hol-lo, hel-lo!\"" CR>
	 <COND (<HAS-WOOD?>
		<TELL "\"Hello!\" replies the Tin Woodman, politely, and then
looks embarrassed." CR>)>
	 <RTRUE>>

<ROUTINE V-ZIZZY ()
	 <COND (<NOT <CAP-OK?>> <RTRUE>)>
	 <COND (<L? ,RITUAL 2>
		<TELL "You say it out of order, and nothing at all happens.
The charm has three lines and they go in order." CR>
		<RTRUE>)>
	 <COND (<CAP-BLOCKED?> <RTRUE>)>
	 <SETG RITUAL 0>
	 <TELL "(standing on both feet) \"Ziz-zy, zuz-zy, zik!\"" CR>
	 <SUMMON-MONKEYS>
	 <RTRUE>>

<ROUTINE CAP-OK? ()
	 <COND (<NOT ,CAP-READ>
		<TELL "The words mean nothing to you; you have not read the
charm." CR>
		<RFALSE>)
	       (<NOT <IN? ,GOLDEN-CAP ,WINNER>>
		<TELL "The charm belongs to the Cap, and you have not got the
Cap." CR>
		<RFALSE>)
	       (<L? ,CAP-USES 1>
		<TELL "You say the words, and nothing comes. The Cap's three
commands are spent, and it is only a hat now." CR>
		<RFALSE>)
	       (T <RTRUE>)>>

"The Scarecrow's anti-waste rail: if a required use lies ahead, he
interrupts before the third word. Insisting is allowed only when nothing
required remains."

<GLOBAL CAP-INSIST <>>

<ROUTINE CAP-BLOCKED? ()
	 <COND (<OR <==? ,HERE ,LOST-FIELDS> <==? ,HERE ,HAMMER-HILL>>
		<RFALSE>)
	       (<AND <==? ,CAP-USES 1> <NOT ,HH-DONE> <HAS-SCARE?>>
		<COND (,CAP-INSIST
		       <SETG CAP-INSIST <>>
		       <RFALSE>)
		      (T
		       <SETG CAP-INSIST T>
		       <TELL "\"Wait!\" cries the Scarecrow, and puts a stuffed
hand over your mouth before the last word. \"If the Monkeys could have
carried you to Kansas, Oz would not have needed a balloon. Save our last
command. I have a feeling about that hill in the south.\"" CR CR
"(Say it again if you insist.)" CR>
		       <RTRUE>)>)
	       (T <RFALSE>)>>

<GLOBAL HH-DONE <>>

<ROUTINE V-SUMMON ()
	 <COND (<NOT <CAP-OK?>> <RTRUE>)>
	 <SETG RITUAL 2>
	 <COND (<CAP-BLOCKED?> <RTRUE>)>
	 <SETG RITUAL 0>
	 <TELL "You stand on your left foot: \"Ep-pe, pep-pe, kak-ke!\" Then
on your right: \"Hil-lo, hol-lo, hel-lo!\" Then on both: \"Ziz-zy,
zuz-zy, zik!\"" CR>
	 <SUMMON-MONKEYS>
	 <RTRUE>>

<ROUTINE SUMMON-MONKEYS ()
	 <MOVE ,MONKEY-KING ,HERE>
	 <SETG MONKEYS-HERE T>
	 <TELL CR
"A great chattering and flapping of wings, and the band of Winged Monkeys
comes flying to you. The King bows low." CR CR
"\"What is your command?\"" CR>
	 <RTRUE>>

<ROUTINE V-FLY ()
	 <COND (,MONKEYS-HERE <DO-FLY>)
	       (T
		<TELL "You have no wings, and neither has anybody here." CR>
		<RTRUE>)>>

<ROUTINE DO-FLY ()
	 <COND (<==? ,HERE ,LOST-FIELDS> <CAP-USE-CITY>)
	       (<==? ,HERE ,HAMMER-HILL> <CAP-USE-HILL>)
	       (<AND ,BALLOON-GONE <EQUAL? ,PRSO ,KANSAS-W>> <CAP-USE-KANSAS>)
	       (<EQUAL? ,PRSO ,KANSAS-W> <CAP-USE-KANSAS>)
	       (T
		<REMOVE ,MONKEY-KING>
		<SETG MONKEYS-HERE <>>
		<TELL "The King bows again. \"There is nothing here we can
carry you from. Call us when you are truly stuck.\" And they go, and the
Cap is not the poorer for it." CR>
		<RTRUE>)>>

<ROUTINE SPEND-CAP ()
	 <SETG CAP-USES <- ,CAP-USES 1>>
	 <REMOVE ,MONKEY-KING>
	 <SETG MONKEYS-HERE <>>
	 <RTRUE>>

<ROUTINE CAP-USE-KANSAS ()
	 <SPEND-CAP>
	 <TELL
"\"We cannot,\" says the King of the Winged Monkeys, and he is grave about
it, and does not laugh at all. \"We belong to this country alone, and
cannot leave it. There has never been a Winged Monkey in Kansas yet, and I
suppose there never will be, for they don't belong there.\"" CR CR
"He bows, and they are gone, and that command is spent, and you have "
	       N ,CAP-USES " left." CR>
	 <RTRUE>>

<ROUTINE CAP-USE-CITY ()
	 <SPEND-CAP>
	 <COND (<NOT ,SC-CAP1> <SETG SC-CAP1 T> <SCORE-IT 5>)>
	 <SETG ACT 4>
	 <TELL
"\"Carry us to the Emerald City,\" you say, and it is done before you have
finished being frightened: four monkeys for you and one apiece for the
rest, and the yellow country going by underneath very fast." CR CR
"The King flies beside you and tells you, courteously, how the Monkeys
came to be bound: how Gayelette the sorceress had the Cap made for her
wedding, and how his grandfather's band ducked her bridegroom Quelala in
the river for a joke, and how she was going to drown them all until
Quelala begged her not to, and so the Cap owns them three commands at a
time, forever, and has been passed from hand to hand ever since, and the
Wicked Witch of the West had it last." CR CR
"\"And now you have it,\" he says, and sets you down gently before the
gate of the Emerald City, and the whole band goes up into the sky like
smoke." CR>
	 <MOVE ,WINNER ,CITY-GATE>
	 <SETG HERE ,CITY-GATE>
	 <SETG SPECS-ON <>>
	 <V-LOOK>
	 <RTRUE>>

"=== Lost in the fields ==="

<ROUTINE LOST-FCN (RARG)
	 <COND (<==? .RARG ,M-ENTER>
		<SETG LOST-TURNS 0>
		<ENABLE <QUEUE I-LOST -1>>
		<RFALSE>)>>

<ROUTINE I-LOST ()
	 <COND (<N==? ,HERE ,LOST-FIELDS> <RFALSE>)>
	 <SETG LOST-TURNS <+ ,LOST-TURNS 1>>
	 <COND (<==? ,LOST-TURNS 3>
		<TELL CR "\"My brains feel damp out here,\" says the Scarecrow.
\"That cannot be right.\"" CR>
		<RTRUE>)
	       (<==? ,LOST-TURNS 6>
		<TELL CR "Toto noses at the little whistle hanging round your
neck, twice, and looks up at you." CR>
		<RTRUE>)
	       (<==? ,LOST-TURNS 9>
		<TELL CR "The Queen of the Field Mice did say to call if you
ever needed them." CR>
		<RTRUE>)>
	 <RFALSE>>

<ROUTINE LOST-EXIT ()
	 <TELL "You walk for an hour. Buttercups, daisies, buttercups. You are
quite sure you have seen this particular buttercup before." CR>
	 <RFALSE>>

<ROUTINE BUTTERCUPS-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "Buttercups and daisies, in every direction, all exactly
alike, and not one of them is a landmark." CR>
		<RTRUE>)>>

<ROUTINE LOST-WHISTLE ()
	 <DISABLE <INT I-LOST>>
	 <COND (,WHISTLE-BLOWN
		<TELL "The mice have gone; they think it great fun to plague
them, they said, and they were not staying." CR>
		<RTRUE>)
	       (T
		<SETG WHISTLE-BLOWN T>
		<TELL
"You blow the little whistle, and in a minute you hear the pattering of
small feet, and here is the Queen of the Field Mice with hundreds of her
people." CR CR
"\"I cannot guide you,\" she says, when she has heard. \"You have had the
Emerald City at your backs this whole time, which is a thing that happens
to everybody.\" Then she notices the Cap. \"But why don't you use the
charm of the Cap, and call the Winged Monkeys? They will carry you to the
City in less than an hour.\"" CR CR
"\"I did not know there was a charm,\" you say, and she tells you it is
written inside the lining. Then the mice run away in every direction at
once, because the Monkeys think it great fun to plague them." CR>
		<RTRUE>)>>

<ROUTINE CASTLE-LG-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "A castle of yellow stone on a low hill, keeping one
round window turned toward you like an eye." CR>
		<RTRUE>)>>

<ROUTINE HILL-FCN ()
	 <COND (<VERB? CLIMB-FOO CLIMB-UP EXAMINE> <HH-TRY>)>>

<ROUTINE HH-FCN (RARG)
	 <COND (<==? .RARG ,M-BEG>
		<COND (<AND <VERB? CLIMB-FOO CLIMB-UP LEAP> <NOT ,HH-DONE>>
		       <HH-TRY>)>)>>

<ROUTINE HAMMER-HEADS-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "Men without arms at all, and flat heads on long
wrinkled necks that fold up like a telescope. They are watching you from
behind every rock, and they seem to enjoy this." CR>
		<RTRUE>)
	       (<VERB? ATTACK CHOP ROAR SCARE CLIMB-FOO> <HH-TRY>)
	       (<VERB? TELL HELLO>
		<TELL "\"Keep back!\" they say. \"This hill belongs to us, and
we allow no one to cross it.\" They seem to have practiced this." CR>
		<RTRUE>)>>

<ROUTINE HH-TRY ()
	 <COND (,HH-DONE
		<TELL "You are past the hill. Do not go back." CR>
		<RTRUE>)
	       (T
		<SETG HH-TRIED T>
		<TELL
"The Scarecrow starts up the hill, and a head shoots out on its long neck
and strikes him, and he goes rolling over and over down to the bottom. The
Lion, furious, springs after him, and a head shoots out and hits the Lion
as though he had been struck by a cannon ball, and he comes down the hill
too, in a great deal of noise and no damage at all." CR CR
"\"It is useless to fight people with shooting heads,\" pants the Lion.
\"No one can withstand them.\"" CR CR
"\"Call the Winged Monkeys,\" says the Tin Woodman quietly. \"You have
still the right to command them once more.\"" CR>
		<RTRUE>)>>

<ROUTINE CAP-USE-HILL ()
	 <SPEND-CAP>
	 <SETG HH-DONE T>
	 <COND (<NOT ,SC-CAP3> <SETG SC-CAP3 T> <SCORE-IT 5>)>
	 <TELL
"\"Carry us over the hill to the country of the Quadlings,\" you say, and
the Winged Monkeys pick you all up and are over the rocky hill before the
Hammer-Heads have finished shouting. You can hear them a long way,
yelling with vexation, and shooting their heads high into the air, and not
one of them can reach so far." CR CR
"The Monkeys set you down in a beautiful country of red fences and ripening
grain, and the King bows for the last time." CR CR
"\"This is the last time you can summon us,\" he says. \"So good-bye, and
good luck to you.\"" CR>
	 <MOVE ,WINNER ,QUADLING-FARM>
	 <SETG HERE ,QUADLING-FARM>
	 <V-LOOK>
	 <RTRUE>>

<ROUTINE HH-SOUTH ()
	 <COND (,HH-DONE ,QUADLING-FARM)
	       (T <HH-TRY> <RFALSE>)>>
