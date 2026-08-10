"AACTION2 - WONDERLAND part 2: Act Two. The shore and the Caucus-race,
the Rabbit's house and its siege, the wood and the puppy, the
Caterpillar and the mushroom, the crossroads and the Cheshire Cat, the
Duchess's kitchen, and the mad tea party."

"=================== QUEER SHORE ==================="

<ROUTINE SHORE-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<COND (,RACE-RUN
		       <TELL
"The gravel shore, lately a racecourse. The company has mostly wandered
off to be dry somewhere else. A sandy path leads east." CR>)
		      (T
		       <TELL
"A gravel shore, crowded with the queerest company: a Mouse, a Dodo, a
Lory, an Eaglet, a Duck, and an old Crab with her daughter -- all
dripping wet, cross, and uncomfortable, yourself included. A sandy path
leads east." CR>)>
		<RTRUE>)
	       (<EQUAL? .RARG ,M-END>
		<COND (<G? ,SHORE-SCATTER 0>
		       <SETG SHORE-SCATTER <- ,SHORE-SCATTER 1>>
		       <COND (<==? ,SHORE-SCATTER 0>
			      <TELL CR
"The company drifts back along the gravel, on various pretexts, having
forgiven you on the general principle that it is too wet to sulk." CR>)>)>
		<WORLD-PULSE>)>>

<ROUTINE MOUSE-LECTURE ()
	 <SETG MOUSE-TALKED T>
	 <SETG P-CONT <>>
	 <SETG QUOTE-FLAG <>>
	 <TELL
"\"Ahem!\" says the Mouse, with an important air. \"Are you all ready?
This is the driest thing I know. William the Conqueror, whose cause was
favoured by the pope, was soon submitted to by the English...\"" CR CR
"It goes on for some time. Nobody gets any drier. \"How are you getting
on now, my dear?\" it asks at last, and you have to admit: not one bit."
CR>
	 <RTRUE>>

<ROUTINE MOUSE-TALE ()
	 <SETG MOUSE-TALE-TOLD T>
	 <SETG P-CONT <>>
	 <SETG QUOTE-FLAG <>>
	 <TELL
"\"Mine is a long and a sad tale!\" says the Mouse, sighing. It recites:
\"Fury said to a mouse, that he met in the house, Let us both go to law:
I will prosecute you. Come, I'll take no denial; we must have the trial;
for really this morning I've nothing to do. Said the mouse to the cur,
Such a trial, dear sir, with no jury or judge, would be wasting our
breath. I'll be judge, I'll be jury, said cunning old Fury; I'll try the
whole cause, and condemn you to death.\"" CR CR
"\"You are not attending!\" says the Mouse. \"What are you thinking of?\"
-- \"I beg your pardon,\" you say humbly, \"you had got to the fifth
bend, I think?\" -- \"I had NOT!\" cries the Mouse, sharply and very
angrily. -- \"A knot!\" you say. \"Oh, do let me help to undo it!\" --
\"I shall do nothing of the sort!\" says the Mouse, and walks a little
way off, offended." CR>
	 <RTRUE>>

<ROUTINE DINAH-SCATTER ()
	 <SETG SHORE-SCATTER 3>
	 <TELL
"You mention Dinah, who is a cat, and very good at catching mice and
birds. The effect on the company is remarkable: on various pretexts they
all move off, the old Crab remarking to her daughter that this is a
lesson to her never to lose HER temper. In a minute the shore is
yours." CR>
	 <RTRUE>>

<ROUTINE DO-CAUCUS ()
	 <COND (,RACE-RUN
		<TELL
"The race is over, and won by everybody. Running it twice would only
confuse the prizes." CR>
		<RTRUE>)
	       (<G? ,SHORE-SCATTER 0>
		<TELL
"There is nobody left on the shore to race with, and racing alone is
merely exercise." CR>
		<RTRUE>)
	       (<NOT ,MOUSE-TALKED>
		<TELL
"There is no race yet. Wonderland is strict about the order of its
nonsense; somebody must first try something dry and fail." CR>
		<RTRUE>)
	       (T
		<SETG RACE-RUN T>
		<COND (<NOT ,F-RACE>
		       <SETG F-RACE T>
		       <SCORE-UPD 3>)>
		<TELL
"\"I move,\" says the Dodo solemnly, \"that the meeting adjourn, for the
immediate adoption of more energetic remedies.\" -- \"Speak English!\"
says the Eaglet. \"I don't know the meaning of half those long words,
and, what's more, I don't believe you do either.\" So the Dodo marks out
a race-course, in a sort of circle, and there is no \"One, two, three,
and away!\": everybody begins running when they like and leaves off when
they like." CR CR
"After half an hour, and quite dry, the Dodo calls out \"The race is
over!\" -- and everybody crowds round it, panting, asking \"But who has
won?\" The Dodo thinks a long while with one finger pressed upon its
forehead, and at last says, \"EVERYBODY has won, and all must have
prizes.\" -- \"But who is to give the prizes?\" -- \"Why, SHE, of
course,\" says the Dodo, pointing at you with one finger; and the whole
party at once crowds round you, calling out, \"Prizes! Prizes!\"" CR>
		<RTRUE>)>>

<ROUTINE GIVE-PRIZES ()
	 <COND (,F-COMFITS
		<TELL
"The comfits are distributed already, and the company is exactly as dry
as it means to get." CR>)
	       (<NOT ,RACE-RUN>
		<TELL
"Nobody has won anything yet, and prizes given in advance would set a
dangerous precedent." CR>)
	       (T
		<SETG F-COMFITS T>
		<SCORE-UPD 2>
		<REMOVE ,COMFIT-BOX>
		<TELL
"You hand round the comfits, and there is exactly one a-piece, all
round, which is a considerable relief to everybody, yourself included.
\"But she must have a prize herself, you know,\" says the Mouse. --
\"Of course,\" the Dodo replies very gravely. \"What else have you got
in your pocket?\"" CR>)>
	 <RTRUE>>

<ROUTINE GIVE-THIMBLE ()
	 <COND (,F-THIMBLE
		<TELL
"The ceremony has been performed once, and Wonderland does not repeat a
ceremony that worked." CR>)
	       (<NOT ,F-COMFITS>
		<TELL
"The Dodo waves the thimble away. \"Prizes first,\" it says, \"and the
prize for the prize-giver afterwards. There is an order to these
things.\"" CR>)
	       (T
		<SETG F-THIMBLE T>
		<SCORE-UPD 3>
		<TELL
"The Dodo takes the thimble, and then, holding it out solemnly with both
hands, presents it back to you, saying, \"We beg your acceptance of this
elegant thimble\"; and when it has finished this short speech, they all
cheer. You think the whole thing very absurd, but they all look so grave
that you do not dare to laugh; and, as you cannot think of anything to
say, you simply bow, and take the thimble, looking as solemn as you
can." CR>)>
	 <RTRUE>>

<ROUTINE THE-DODO-FCN ()
	 <COND (<AND <VERB? GIVE> <EQUAL? ,PRSO ,COMFIT-BOX>>
		<GIVE-PRIZES>
		<RTRUE>)
	       (<AND <VERB? GIVE> <EQUAL? ,PRSO ,THIMBLE>>
		<GIVE-THIMBLE>
		<RTRUE>)
	       (<VERB? TELL HELLO>
		<SETG P-CONT <>>
		<SETG QUOTE-FLAG <>>
		<COND (,RACE-RUN
		       <TELL
"\"A most energetic remedy,\" says the Dodo, \"and the prizes were the
best part of it.\"" CR>)
		      (T
		       <TELL
"\"In that case,\" says the Dodo solemnly, rising to its feet, \"I move
that the meeting adjourn, for the immediate adoption of more energetic
remedies.\"" CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A Dodo, rather damp, entirely certain of procedure, and pointing at
things with one finger as though it were chairing a committee, which in
a sense it is." CR>
		<RTRUE>)>>

<ROUTINE SHORE-BIRDS-FCN ()
	 <COND (<AND <VERB? GIVE> <EQUAL? ,PRSO ,COMFIT-BOX>>
		<GIVE-PRIZES>
		<RTRUE>)
	       (<AND <VERB? GIVE> <EQUAL? ,PRSO ,THIMBLE>>
		<GIVE-THIMBLE>
		<RTRUE>)
	       (<VERB? TELL HELLO>
		<SETG P-CONT <>>
		<SETG QUOTE-FLAG <>>
		<TELL
"The Lory says it is older than you and must know better; the Eaglet
asks for English; the Duck wants to know what \"it\" means; and the old
Crab tells her daughter that this is a lesson to her never to lose HER
temper." CR>
		<RTRUE>)
	       (<VERB? EXAMINE COUNT>
		<TELL
"A Lory, an Eaglet, a Duck, an old Crab and her daughter, and several
other curious creatures, all dripping and all of the opinion that
somebody else should do something." CR>
		<RTRUE>)>>

"=================== SANDY PATH ==================="

<ROUTINE SANDY-PATH-FCN (RARG)
	 <COND (<AND <EQUAL? .RARG ,M-ENTER> <NOT ,MARY-ANN>>
		<SETG MARY-ANN T>
		<TELL
"The White Rabbit trots up the path, sees you, and stops dead. \"Why,
Mary Ann, what ARE you doing out here? Run home this moment, and fetch
me a pair of gloves and a fan! Quick, now!\" -- and he hurries off east
before you can explain that you are nothing of the sort." CR>)
	       (<EQUAL? .RARG ,M-END> <WORLD-PULSE>)>>

"=================== OUTSIDE THE RABBIT'S HOUSE ==================="

<ROUTINE RABBIT-LAWN-FCN (RARG)
	 <COND (<AND <EQUAL? .RARG ,M-BEG>
		      <VERB? WALK>
		      <EQUAL? ,PRSO ,P?IN>>
		<COND (<RABBIT-HOUSE-IN> <GOTO ,RABBIT-ROOM>)>
		<RTRUE>)
	       (<EQUAL? .RARG ,M-END>
		<COND (<AND <G? ,SIEGE-PHASE 0> <NOT ,HOUSE-DONE>>
		       <TELL CR
"From inside the little house comes a great deal of shouting, and one
window is entirely occupied by an arm." CR>)>
		<WORLD-PULSE>)>>

<ROUTINE RABBIT-HOUSE-IN ()
	 <COND (<G? ,SIEGE-PHASE 0>
		<TELL
"The house is full. You know exactly how full, having been the filling."
CR>
		<RFALSE>)
	       (<LARGE?>
		<TELL
"You would wear the house like a boot. Better to be smaller, or to stay
outside and be admired." CR>
		<RFALSE>)
	       (T <RETURN ,RABBIT-ROOM>)>>

<ROUTINE RABBIT-HOUSE-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"A neat little house, about the height of a tall gentleman, with a brass
plate on the door and not one thing out of place outside it." CR>
		<RTRUE>)
	       (<VERB? THROUGH BOARD ENTER>
		<DO-WALK ,P?IN>
		<RTRUE>)
	       (<VERB? KNOCK>
		<TELL
"You knock. Nobody answers; the owner is elsewhere, being late." CR>
		<RTRUE>)>>

<ROUTINE RADISHES-FCN ()
	 <COND (<VERB? TAKE PICK EAT>
		<TELL
"You do not take a rabbit's radishes. There are rules, and this is one
of the few here that holds." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"Radishes in rows so straight they look nervous." CR>
		<RTRUE>)>>

"=================== THE TIDY LITTLE ROOM AND THE SIEGE ==================="

<ROUTINE RABBIT-ROOM-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<COND (<G? ,SIEGE-PHASE 0>
		       <TELL
"You ARE the room, more or less. One arm out of the window, one foot up
the chimney, and your elbow hard against the door. The ceiling makes a
personal remark of itself against your head." CR>)
		      (T
		       <TELL
"A tidy little room with a table in the window. On the table lie a fan
and two or three pairs of tiny white kid gloves, and by the
looking-glass stands a little bottle with no label at all." CR>)>
		<RTRUE>)
	       (<EQUAL? .RARG ,M-END>
		<COND (<G? ,SIEGE-PHASE 0> <SIEGE-BEAT>)
		      (T <WORLD-PULSE>)>)>>

<ROUTINE RABBIT-ROOM-OUT ()
	 <COND (<G? ,SIEGE-PHASE 0>
		<TELL
"In your present acreage you no longer fit through anything the house
has to offer." CR>
		<RFALSE>)
	       (T <RETURN ,RABBIT-LAWN>)>>

<ROUTINE SPARE-FAN-FCN ()
	 <COND (<VERB? TAKE>
		<COND (<IN? ,THE-FAN ,WINNER>
		       <TELL
"You have a fan already, and one fan is a convenience where two are a
collection." CR>)
		      (T
		       <MOVE ,THE-FAN ,WINNER>
		       <TELL
"You take a fan from the table. It is exactly the fan you were sent
for, which is a suspicious sort of luck." CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A spare fan, kept where a tidy rabbit keeps spares: in plain sight and
squared to the table edge." CR>
		<RTRUE>)>>

<ROUTINE SPARE-GLOVES-FCN ()
	 <COND (<VERB? TAKE>
		<COND (<IN? ,KID-GLOVES ,WINNER>
		       <TELL
"You take another pair; another pair can only improve matters. Gloves
are like that." CR>)
		      (T
		       <MOVE ,KID-GLOVES ,WINNER>
		       <TELL
"You take a pair of tiny white kid gloves from the table: the very
errand you were given, discharged before you were asked twice." CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"Two or three pairs of tiny white kid gloves, laid out like a small
white argument for order." CR>
		<RTRUE>)>>

<ROUTINE PLAIN-BOTTLE-FCN ()
	 <COND (<VERB? DRINK EAT>
		<COND (<G? ,SIEGE-PHASE 0>
		       <TELL
"There is nothing left in it, and no room left in you." CR>)
		      (T <DO-PLAIN-BOTTLE>)>
		<RTRUE>)
	       (<VERB? EXAMINE READ>
		<TELL
"A little bottle with no label at all, which is somehow far more
alarming than a label would be. You know SOMETHING interesting is sure
to happen whenever you eat or drink anything here." CR>
		<RTRUE>)>>

<ROUTINE DO-PLAIN-BOTTLE ()
	 <SETG SIEGE-PHASE 1>
	 <SETG ALICE-SIZE 3>
	 <TELL
"\"I know something interesting is sure to happen,\" you say, \"whenever
I eat or drink anything here; so I'll just see what this bottle does.\"
You drink about half of it, and before you have drunk half of that your
head is pressing against the ceiling." CR CR
"You put one arm out of the window and one foot up the chimney, and say
to yourself: now I can do no more, whatever happens. Fortunately the
bottle has now had its full effect, and you grow no larger; but you are
extremely uncomfortable, and there seems no sort of chance of your ever
getting out of the room again." CR>
	 <RTRUE>>

<ROUTINE SIEGE-BEAT ()
	 <COND (<==? ,SIEGE-PHASE 1>
		<TELL CR
"Feet on the gravel outside, and the door tried, and the door failing.
\"Mary Ann! Mary Ann! Fetch me my gloves this moment!\" A hand scrabbles
at the door; your elbow declines. \"Then I'll go round and get in at the
window.\"" CR>)
	       (<==? ,SIEGE-PHASE 2>
		<SETG SIEGE-PHASE 3>
		<TELL CR
"Voices below, in a good deal of alarm. \"Where did it come down?\" --
\"Catch him, you by the hedge!\" -- then, quite clearly: \"Sure, it's an
arm, yer honour!\" -- \"An arm, you goose! Who ever saw one that size?
Why, it fills the whole window!\" -- \"Sure, it does, yer honour: but
it's an arm for all that.\"" CR>)
	       (<==? ,SIEGE-PHASE 3>
		<TELL CR
"A scraping of claws in the chimney above you, and a shower of soot.
\"This is Bill,\" you think, and you draw your foot as far down as it
will go, and wait." CR>)
	       (<==? ,SIEGE-PHASE 4>
		<TELL CR
"A dreadful silence outside, and then: \"We must burn the house down!\"
says the Rabbit's voice. Somebody agrees with him, which is the worst
part." CR>)
	       (<==? ,SIEGE-PHASE 5>
		<SETG SIEGE-PHASE 6>
		<MOVE ,FLOOR-CAKES ,RABBIT-ROOM>
		<MOVE ,SPARE-CAKE ,RABBIT-ROOM>
		<TELL CR
"\"A barrowful of WHAT?\" you think -- and the next moment a shower of
little pebbles comes rattling in at the window, and some of them hit you
in the face. Then, as you watch, the pebbles on the floor all turn into
little cakes, and a bright idea arrives with them." CR>)
	       (T <TELL CR
"Outside, the siege confers with itself in whispers, and gets no
further." CR>)>
	 <RFALSE>>

<ROUTINE SIEGE-SNATCH ()
	 <COND (<G? ,SIEGE-PHASE 1>
		<TELL
"You have snatched at that window once already, and the cucumber-frames
of Wonderland have suffered enough for one afternoon." CR>)
	       (T
		<SETG SIEGE-PHASE 2>
		<TELL
"You spread your hand out and make a snatch in the air. Nothing comes of
it -- but you hear a little shriek, and a fall, and a crash of broken
glass, from which you conclude that it is just possible he has fallen
into a cucumber-frame, or something of the sort. What a number of
cucumber-frames there must be!" CR>)>
	 <RTRUE>>

<ROUTINE SIEGE-KICK ()
	 <SETG SIEGE-PHASE 4>
	 <COND (<NOT ,F-BILL-KICK>
		<SETG F-BILL-KICK T>
		<SCORE-UPD 2>)>
	 <TELL
"\"That's Bill,\" you think, and you give one sharp kick up the chimney
and wait to see what happens next." CR CR
"There is a general chorus of \"There goes Bill!\" -- then the Rabbit's
voice alone: \"Catch him, you by the hedge!\" -- then silence, and then
a confusion of voices: \"Hold up his head\" -- \"Brandy now\" -- \"Don't
choke him\" -- \"What happened to you?\" -- and a little feeble squeaking
voice, which you take to be Bill's: \"Well, I hardly know -- something
comes at me like a Jack-in-the-box, and up I goes like a sky-rocket!\""
CR>
	 <RTRUE>>

<ROUTINE SIEGE-SILENCE ()
	 <COND (<L? ,SIEGE-PHASE 4>
		<TELL
"You shout. The shout goes round the room twice and gives up." CR>)
	       (<G? ,SIEGE-PHASE 4>
		<TELL
"They are already as silent as a crowd can manage, which is not very."
CR>)
	       (T
		<SETG SIEGE-PHASE 5>
		<TELL
"\"If you do,\" you call out at the top of your voice, \"I'll set Dinah
at you!\" There is a dead silence instantly, and you think to yourself:
I wonder what they WILL do next! If they had any sense, they'd take the
roof off." CR>)>
	 <RTRUE>>

<ROUTINE FLOOR-CAKES-FCN ()
	 <COND (<VERB? TAKE>
		<TELL
"You take one of the little cakes; the rest are underfoot and, being
made of pebbles, are patient." CR>
		<MOVE ,SPARE-CAKE ,WINNER>
		<COND (<NOT ,F-SPARE-CAKE>
		       <SETG F-SPARE-CAKE T>
		       <SCORE-UPD 2>)>
		<RTRUE>)
	       (<VERB? EAT>
		<DO-PEBBLE-CAKE>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"Little cakes, lately pebbles, scattered over the floor of a room you
are wearing." CR>
		<RTRUE>)>>

<ROUTINE SPARE-CAKE-FCN ()
	 <COND (<AND <VERB? TAKE> <IN? ,SPARE-CAKE ,RABBIT-ROOM>>
		<MOVE ,SPARE-CAKE ,WINNER>
		<COND (<NOT ,F-SPARE-CAKE>
		       <SETG F-SPARE-CAKE T>
		       <SCORE-UPD 2>)>
		<TELL
"You pocket one little pebble-cake against future emergencies, of which
Wonderland has a good supply." CR>
		<RTRUE>)
	       (<VERB? EAT>
		<DO-PEBBLE-CAKE>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A little cake that was a pebble ten minutes ago and has not entirely
forgiven the change." CR>
		<RTRUE>)>>

<ROUTINE DO-PEBBLE-CAKE ()
	 <COND (<G? ,SIEGE-PHASE 0>
		<REMOVE ,FLOOR-CAKES>
		<REMOVE ,SPARE-CAKE>
		<SETG SIEGE-PHASE 0>
		<SETG HOUSE-DONE T>
		<SETG ALICE-SIZE 1>
		<COND (<NOT ,F-HOUSE>
		       <SETG F-HOUSE T>
		       <SCORE-UPD 3>)>
		<TELL
"You swallow one of the cakes, and are delighted to find that you begin
shrinking directly. As soon as you are small enough to get through the
door, you run out of the house, and find quite a crowd of little animals
and birds waiting outside." CR CR
"They all make a rush at you the moment you appear; but you run off as
hard as you can, and soon find yourself safe in a thick wood." CR CR>
		<GOTO ,THICK-WOOD>)
	       (<SMALL?>
		<REMOVE ,SPARE-CAKE>
		<TELL
"You eat the pebble-cake. Nothing whatever happens, which at ten inches
high is the best available outcome." CR>)
	       (T
		<REMOVE ,SPARE-CAKE>
		<TELL
"You eat the pebble-cake and shrink at once, down to about ten inches
high, in a manner you are beginning to think of as ordinary." CR>
		<CHANGE-SIZE 1 T>)>
	 <RTRUE>>

<ROUTINE LOOKING-GLASS-FCN ()
	 <COND (<VERB? EXAMINE LOOK-INSIDE>
		<TELL
"It reflects rather more of you than you remembered owning." CR>
		<RTRUE>)>>

<ROUTINE ROOM-WINDOW-FCN ()
	 <COND (<AND <VERB? REACH> <==? ,SIEGE-PHASE 1>>
		<SIEGE-SNATCH>
		<RTRUE>)
	       (<VERB? EXAMINE LOOK-INSIDE>
		<COND (<G? ,SIEGE-PHASE 0>
		       <TELL
"The window is entirely full of your arm, and there is a good deal of
Wonderland on the other side of it, complaining." CR>)
		      (T
		       <TELL
"A small window with a table under it, looking out on radishes." CR>)>
		<RTRUE>)>>

<ROUTINE ROOM-CHIMNEY-FCN ()
	 <COND (<AND <VERB? KICK> <==? ,SIEGE-PHASE 3>>
		<SIEGE-KICK>
		<RTRUE>)
	       (<VERB? EXAMINE LOOK-INSIDE>
		<COND (<G? ,SIEGE-PHASE 0>
		       <TELL
"Your foot is in the chimney. Something with claws is coming down it,
which is either bad manners or Bill." CR>)
		      (T
		       <TELL
"A narrow chimney, swept within an inch of its life." CR>)>
		<RTRUE>)>>

"=================== THICK WOOD AND THE PUPPY ==================="

<ROUTINE THICK-WOOD-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<COND (<SMALL?>
		       <TELL
"The wood from down here is a country of huge stems and towering
thistles. To the west, a tunnel runs under the bramble bank --
comfortably your size, which is to say tiny.">
		       <COND (<NOT ,PUPPY-BUSY>
			      <TELL
" Above you stands AN ENORMOUS PUPPY, with round eyes the size of
cart-wheels, feebly stretching out one paw to touch you.">)
			     (T
			      <TELL
" A good way off, an enormous puppy lies panting over a stick.">)>
		       <CRLF>)
		      (<LARGE?>
		       <TELL
"Your head is up among the branches. Below, the wood spreads its leaves
like a green sea; above, there is only sky and a very disapproving
pigeon." CR>)
		      (T
		       <TELL
"A thick wood of quite ordinary trees, with a bramble bank to the west
and something scuffling hopefully about your ankles: a puppy, delighted
with you. Paths run north and south." CR>)>
		<RTRUE>)
	       (<EQUAL? .RARG ,M-END> <WORLD-PULSE>)>>

<ROUTINE BRAMBLE-TUNNEL-EXIT ()
	 <COND (<NOT <SMALL?>>
		<TELL
"The tunnel under the brambles would suit a rabbit, or a very small
girl; you are at present neither." CR>
		<RFALSE>)
	       (<NOT ,PUPPY-BUSY>
		<TELL
"Between you and the tunnel stands the puppy, feebly stretching out one
paw, trying to touch you. It might be hungry. You would be extremely
convenient." CR>
		<RFALSE>)
	       (T <RETURN ,MUSHROOM-CLEARING>)>>

<ROUTINE TREETOPS-EXIT ()
	 <COND (<LARGE?> <RETURN ,TREETOPS>)
	       (T
		<TELL
"You would need to be a great deal more girl than this to reach the
treetops." CR>
		<RFALSE>)>>

<ROUTINE THE-PUPPY-FCN ()
	 <COND (<AND <VERB? THROW> <EQUAL? ,PRSO ,DEAD-STICK>>
		<PUPPY-STICK>
		<RTRUE>)
	       (<VERB? ATTACK KICK MUNG>
		<TELL
"It is a dear little puppy the size of a dray-horse, and you are a
person of firm principles about puppies." CR>
		<RTRUE>)
	       (<VERB? KISS>
		<TELL
"You kiss the puppy, or as much of the puppy as presents itself, which
is chiefly nose." CR>
		<RTRUE>)
	       (<VERB? TELL HELLO>
		<SETG P-CONT <>>
		<SETG QUOTE-FLAG <>>
		<TELL
"\"Poor little thing,\" you say, in a coaxing tone. The puppy takes this
as an invitation and makes a rush, and you only just save yourself from
being run over." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<COND (<SMALL?>
		       <TELL
"An enormous puppy, looking down at you with large round eyes, and
feebly stretching out one paw. Its tail is a weather event." CR>)
		      (T
		       <TELL
"A puppy of ordinary size and extraordinary enthusiasm, at present
occupied with your shoes." CR>)>
		<RTRUE>)
	       (<VERB? TAKE>
		<TELL
"You could as easily pick up the weather." CR>
		<RTRUE>)>>

<ROUTINE PUPPY-STICK ()
	 <COND (,PUPPY-BUSY
		<TELL
"The puppy has a stick already, and is a one-stick dog." CR>)
	       (T
		<SETG PUPPY-BUSY T>
		<MOVE ,DEAD-STICK ,THICK-WOOD>
		<COND (<NOT ,F-PUPPY>
		       <SETG F-PUPPY T>
		       <SCORE-UPD 3>)>
		<TELL
"You hold out the little bit of stick. The puppy jumps into the air off
all its feet at once, with a yelp of delight, and rushes at the stick,
and makes believe to worry it. Then it runs a good way off and back
again, and back and off, making a noise like a cart-horse in a hurry."
CR CR
"At last it sits down a good way off, panting, with its tongue hanging
out of its mouth and its great eyes half shut. The way west is clear,
and the stick belongs to somebody now, which is the whole purpose of
sticks." CR>)>
	 <RTRUE>>

<ROUTINE DEAD-STICK-FCN ()
	 <COND (<AND <VERB? THROW> <EQUAL? ,HERE ,THICK-WOOD>>
		<PUPPY-STICK>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A little bit of dead stick, of no value to anybody except a dog, which
is exactly the value required." CR>
		<RTRUE>)>>

<ROUTINE THISTLE-FCN ()
	 <COND (<VERB? EXAMINE>
		<COND (<SMALL?>
		       <TELL
"A thistle the size of a church, and armed accordingly." CR>)
		      (T
		       <TELL "A thistle, doing what thistles do." CR>)>
		<RTRUE>)
	       (<VERB? TAKE>
		<TELL "It objects, at length, with points." CR>
		<RTRUE>)>>

<ROUTINE BRAMBLES-FCN ()
	 <COND (<VERB? EXAMINE LOOK-INSIDE>
		<TELL
"A bramble bank with a tunnel under it, running west. The tunnel is
rabbit-sized, which is a compliment or an obstacle depending on the
hour." CR>
		<RTRUE>)
	       (<VERB? THROUGH ENTER BOARD>
		<DO-WALK ,P?WEST>
		<RTRUE>)>>

"=================== TREETOPS AND THE PIGEON ==================="

<ROUTINE TREETOPS-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-ENTER>
		<COND (<NOT ,F-TREETOPS>
		       <SETG F-TREETOPS T>
		       <SCORE-UPD 3>)>
		<COND (<==? ,PIGEON-PHASE 0>
		       <SETG PIGEON-PHASE 1>
		       <TELL
"\"Serpent!\" screams the Pigeon, flying into your face and beating you
with its wings. \"I have tried the roots of trees, and I have tried
banks, and I have tried hedges, but those serpents! There's no pleasing
them!\"" CR>)>)
	       (<EQUAL? .RARG ,M-END> <WORLD-PULSE>)>>

<ROUTINE THE-PIGEON-FCN ()
	 <COND (<VERB? TELL HELLO ANSWER>
		<PIGEON-PROMISE>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A pigeon in a state of maternal fury, which is the most dangerous state
there is and the least dangerous to you." CR>
		<RTRUE>)
	       (<VERB? ATTACK TAKE>
		<TELL
"You would not strike a mother, and she knows it, and it makes her
worse." CR>
		<RTRUE>)>>

<ROUTINE PIGEON-PROMISE ()
	 <SETG P-CONT <>>
	 <SETG QUOTE-FLAG <>>
	 <COND (<G? ,PIGEON-PHASE 1>
		<TELL
"\"Well, be off, then!\" says the Pigeon in a sulky tone, and settles
down into her nest." CR>)
	       (T
		<SETG PIGEON-PHASE 2>
		<TELL
"\"But I'm NOT a serpent, I tell you!\" you say. \"I'm a -- I'm a --\"
-- \"Well! WHAT are you?\" says the Pigeon. \"I can see you're trying to
invent something!\" -- \"I'm a little girl,\" you say, rather doubtfully,
remembering the number of changes you have gone through that day. --
\"A likely story indeed! I've seen a good many little girls in my time,
but never ONE with such a neck as that. No, no! You're a serpent; and
there's no use denying it. I suppose you'll be telling me next that you
never tasted an egg!\"" CR CR
"\"I HAVE tasted eggs, certainly,\" you say, being a very truthful
child, \"but little girls eat eggs quite as much as serpents do, you
know.\" The Pigeon considers this, and at last says, \"Well, be off,
then!\" in a sulky tone, and settles down into her nest." CR>)>
	 <RTRUE>>

"=================== THE CATERPILLAR ==================="

<ROUTINE MUSHROOM-CLEARING-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<COND (<AND <SMALL?> <IN? ,CATERPILLAR ,MUSHROOM-CLEARING>>
		       <TELL
"A clearing ruled by one large mushroom exactly your own height. On top
of it, arms folded, sits a large blue caterpillar, quietly smoking a
long hookah and taking not the smallest notice of you or of anything
else." CR>)
		      (<IN? ,CATERPILLAR ,MUSHROOM-CLEARING>
		       <TELL
"A clearing with a knee-high mushroom in it. Something small and blue on
top of it is pointedly ignoring you, and succeeding." CR>)
		      (T
		       <TELL
"A quiet clearing with a large round mushroom in the middle of it, and a
faint smell of hookah smoke that has nowhere in particular to be." CR>)>
		<RTRUE>)
	       (<EQUAL? .RARG ,M-END>
		<COND (<==? ,CATERPILLAR-PHASE 3>
		       <SETG CATERPILLAR-PHASE 4>
		       <REMOVE ,CATERPILLAR>
		       <REMOVE ,HOOKAH>
		       <TELL CR
"The Caterpillar yawns once or twice, shakes itself, gets down off the
mushroom and crawls away into the grass, merely remarking as it goes:
\"One side will make you grow taller, and the other side will make you
grow shorter.\"" CR CR
"\"One side of WHAT? The other side of WHAT?\" you think. -- \"Of the
mushroom,\" says the Caterpillar, just as if you had asked it aloud; and
in another moment it is out of sight." CR>)>
		<WORLD-PULSE>)>>

<ROUTINE CLEARING-EAST ()
	 <COND (<SMALL?> <RETURN ,THICK-WOOD>)
	       (<LARGE?>
		<TELL
"You are far too tall for the bramble tunnel, so you simply stand up
through the branches and step over the whole bank, which is the one
advantage of being nine feet of girl." CR CR>
		<RETURN ,THICK-WOOD>)
	       (T
		<TELL
"The tunnel back under the brambles would suit a rabbit, or a very small
girl; you are at present neither. A nibble either way would settle it."
CR>
		<RFALSE>)>>

<ROUTINE CATERPILLAR-FCN ()
	 <COND (<AND <VERB? TELL> ,PRSI>
		<CATERPILLAR-TOPIC>
		<RTRUE>)
	       (<VERB? TELL HELLO ANSWER>
		<CATERPILLAR-TALK>
		<RTRUE>)
	       (<VERB? ATTACK CURSES MUNG>
		<TELL
"\"Keep your temper,\" says the Caterpillar, and puts the hookah back in
its mouth. Nothing else whatever happens, at some length." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A large blue caterpillar, exactly three inches high, sitting with its
arms folded on the top of the mushroom, smoking. Three inches is a very
good height to be, and it is prepared to argue the point." CR>
		<RTRUE>)>>

<ROUTINE CATERPILLAR-TALK ()
	 <SETG P-CONT <>>
	 <SETG QUOTE-FLAG <>>
	 <COND (<==? ,CATERPILLAR-PHASE 0>
		<SETG CATERPILLAR-PHASE 1>
		<TELL
"\"Who are YOU?\" says the Caterpillar, at last, in a languid sleepy
voice. It is not an encouraging opening. \"I -- I hardly know, sir, just
at present,\" you reply, rather shyly; \"at least I know who I WAS when
I got up this morning, but I think I must have been changed several
times since then.\"" CR CR
"\"What do you mean by that?\" says the Caterpillar, sternly. \"Explain
yourself!\"" CR>)
	       (T
		<SETG CONTRADICTION <+ ,CONTRADICTION 1>>
		<COND (<==? ,CONTRADICTION 1>
		       <TELL
"\"I can't explain MYSELF, I'm afraid, sir,\" you say, \"because I'm not
myself, you see.\" -- \"I don't see,\" says the Caterpillar." CR>)
		      (<==? ,CONTRADICTION 2>
		       <TELL
"\"I'm afraid I can't put it more clearly,\" you say very politely, \"for
I can't understand it myself to begin with.\" -- \"It isn't,\" says the
Caterpillar." CR>)
		      (<==? ,CONTRADICTION 3>
		       <TELL
"\"Well, perhaps your feelings may be different,\" you say. -- \"Not a
bit,\" says the Caterpillar. -- Then, after a pause: \"You! Who are
YOU?\" which brings the conversation neatly back to where it began."
CR>)
		      (T
		       <SETG CONTRADICTION 0>
		       <TELL
"\"Why?\" says the Caterpillar. It is a complete argument, and it wins."
CR>)>)>
	 <RTRUE>>

<ROUTINE CATERPILLAR-TOPIC ()
	 <SETG P-CONT <>>
	 <SETG QUOTE-FLAG <>>
	 <COND (<AND <EQUAL? ,PRSI ,T-SIZE ,T-MUSHROOM>
		     <L? ,CATERPILLAR-PHASE 2>>
		<SETG CATERPILLAR-PHASE 2>
		<TELL
"\"I should like to be a LITTLE larger, sir, if you wouldn't mind,\" you
say; \"three inches is such a wretched height to be.\" -- \"It is a very
good height indeed!\" says the Caterpillar angrily, rearing itself
upright as it speaks; it is exactly three inches high." CR CR
"Then, more calmly: \"So you think you're changed, do you? Can't
remember WHAT things?\" -- and, before you can answer: \"Repeat, 'YOU
ARE OLD, FATHER WILLIAM.'\"" CR>)
	       (<EQUAL? ,PRSI ,T-SIZE ,T-MUSHROOM>
		<COND (<==? ,CATERPILLAR-PHASE 2>
		       <TELL
"\"Repeat, 'YOU ARE OLD, FATHER WILLIAM,'\" says the Caterpillar, with
the patience of something that has all day and intends to spend it."
CR>)
		      (T
		       <TELL
"\"One side will make you grow taller,\" says the Caterpillar, \"and the
other side will make you grow shorter. Of the mushroom. You might have
asked it aloud.\"" CR>)>)
	       (<EQUAL? ,PRSI ,W-POEM>
		<TELL
"\"Repeat it, then,\" says the Caterpillar. \"Do not describe it.\"" CR>)
	       (T
		<TELL
"The Caterpillar takes the hookah out of its mouth, considers the
subject from a great height of three inches, and says, \"Why?\"" CR>)>
	 <RTRUE>>

<ROUTINE DO-FATHER-WILLIAM ()
	 <COND (<G? ,CATERPILLAR-PHASE 2>
		<TELL
"You have recited it once, and it was wrong from beginning to end. A
second wrongness would only be showing off." CR>
		<RTRUE>)
	       (<L? ,CATERPILLAR-PHASE 2>
		<TELL
"You recite \"You are old, Father William\" to nobody in particular. It
comes out queerly, but there is no critic present, which is the ideal
condition for poetry." CR>
		<RTRUE>)
	       (T
		<SETG CATERPILLAR-PHASE 3>
		<COND (<NOT ,F-RECITE>
		       <SETG F-RECITE T>
		       <SCORE-UPD 3>)>
		<TELL
"You cross your hands on your lap and begin: \"'You are old, Father
William,' the young man said, 'and your hair has become very white; and
yet you incessantly stand on your head -- do you think, at your age, it
is right?' -- 'In my youth,' Father William replied to his son, 'I
feared it might injure the brain; but, now that I'm perfectly sure I
have none, why, I do it again and again.'\"" CR CR
"\"'You are old,' said the youth, 'and your jaws are too weak for
anything tougher than suet; yet you finished the goose, with the bones
and the beak -- pray, how did you manage to do it?' -- 'In my youth,'
said his father, 'I took to the law, and argued each case with my wife;
and the muscular strength which it gave to my jaw has lasted the rest of
my life.' -- 'You are old,' said the youth, 'one would hardly suppose
that your eye was as steady as ever; yet you balanced an eel on the end
of your nose -- what made you so awfully clever?' -- 'I have answered
three questions, and that is enough,' said his father. 'Don't give
yourself airs! Do you think I can listen all day to such stuff? Be off,
or I'll kick you down stairs!'\"" CR CR
"\"That is not said right,\" says the Caterpillar. -- \"Not QUITE
right, I'm afraid,\" you say timidly; \"some of the words have got
altered.\" -- \"It is wrong from beginning to end,\" says the
Caterpillar decidedly, and there is silence for some minutes." CR>
		<RTRUE>)>>

<ROUTINE THE-MUSHROOM-FCN ()
	 <COND (<VERB? TAKE MUNG EAT>
		<COND (<L? ,CATERPILLAR-PHASE 4>
		       <COND (<IN? ,CATERPILLAR ,MUSHROOM-CLEARING>
			      <TELL
"The Caterpillar is sitting on it, and has views about being moved."
CR>)
			     (T
			      <TELL
"You look at the mushroom thoughtfully, and cannot for the life of you
think which side is which." CR>)>)
		      (,F-MUSHROOM
		       <TELL
"You have your two pieces. The mushroom, which is round, declines to
have any further sides." CR>)
		      (T <BREAK-MUSHROOM>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A large round mushroom. As it is perfectly round, which is the two
sides of it is a very difficult question." CR>
		<RTRUE>)
	       (<VERB? CLIMB-ON BOARD LOOK-UNDER>
		<TELL
"You stretch yourself up on tiptoe and peep over the edge of the
mushroom. Your eyes meet those of a large blue caterpillar, or, if it
has gone, those of the sky." CR>
		<RTRUE>)>>

<ROUTINE BREAK-MUSHROOM ()
	 <SETG F-MUSHROOM T>
	 <SCORE-UPD 5>
	 <MOVE ,LEFT-PIECE ,WINNER>
	 <MOVE ,RIGHT-PIECE ,WINNER>
	 <TELL
"You stretch your arms round the mushroom as far as they will go, and
break off a bit of the edge with each hand. Now you have a left-hand
piece and a right-hand piece, and the only remaining difficulty is
which is which -- a difficulty that experiment will settle, as
experiment settles everything here." CR>
	 <RTRUE>>

<ROUTINE HOOKAH-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"A long hookah, smoked with enormous deliberation by somebody who has
nowhere to be until the end of the world." CR>
		<RTRUE>)
	       (<VERB? TAKE>
		<TELL
"\"Keep your temper,\" says the Caterpillar, without moving anything at
all." CR>
		<RTRUE>)>>

"The mushroom pieces: the first nibble overshoots (canon), every nibble
after that is exactly one step, forever. Mushroom magic is gradual;
doors never notice."

<ROUTINE LEFT-PIECE-FCN ()
	 <COND (<VERB? EAT>
		<NIBBLE 1>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A bit of mushroom broken off with the left hand. It looks exactly like
the other one, which is the joke." CR>
		<RTRUE>)>>

<ROUTINE RIGHT-PIECE-FCN ()
	 <COND (<VERB? EAT>
		<NIBBLE -1>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A bit of mushroom broken off with the right hand. It looks exactly like
the other one, which is still the joke." CR>
		<RTRUE>)>>

<ROUTINE NIBBLE (DIR "AUX" NEW)
	 <COND (,MUSHROOM-VIRGIN
		<SETG MUSHROOM-VIRGIN <>>
		<COND (<G? .DIR 0>
		       <TELL
"You nibble the left-hand piece, and your chin strikes nothing at all,
because your chin is already a great way off. Your shoulders are nowhere
to be found; all you can see, when you look down, is an immense length
of neck, rising like a stalk out of a sea of green leaves far below."
CR CR
"An indignant pigeon somewhere calls you a serpent. You have overshot,
handsomely, and are now as tall as this game gets." CR>
		       <CHANGE-SIZE 3>)
		      (T
		       <TELL
"You nibble the right-hand piece, and are so startled that you swallow a
large piece of it. Your chin strikes your foot with a sharp blow; there
is hardly any room to open your mouth, but you do it at last, and manage
to swallow a morsel of the other." CR CR
"You have overshot the other way, and are ten inches high, which at
least is a size you have met before." CR>
		       <CHANGE-SIZE 1>)>
		<RTRUE>)>
	 <SET NEW <+ ,ALICE-SIZE .DIR>>
	 <COND (<G? .NEW 3>
		<TELL
"You nibble, and nothing happens, there being no larger size available
in this part of the country." CR>)
	       (<L? .NEW 1>
		<TELL
"You nibble, and nothing happens. Below ten inches, Wonderland stops
taking requests." CR>)
	       (T
		<COND (<==? .NEW 3>
		       <TELL
"You nibble, and grow steadily upward until your head is a good nine
feet from your feet. Nothing slams; mushroom magic is gradual, and
doors never notice." CR>)
		      (<==? .NEW 1>
		       <TELL
"You nibble, and shrink smoothly down to about ten inches. Nothing
slams; mushroom magic is gradual, and doors never notice." CR>)
		      (T
		       <TELL
"You nibble, and settle at exactly your own right size, which after
today feels like a considerable achievement." CR>)>
		<CHANGE-SIZE .NEW>)>
	 <RTRUE>>

"=================== CROSSROADS AND THE CHESHIRE CAT ==================="

<ROUTINE CROSSROADS-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-ENTER>
		<COND (,PIGFIG-PENDING
		       <COND (<NOT <IN? ,CHESHIRE-CAT ,CROSSROADS>>
			      <MOVE ,CHESHIRE-CAT ,CROSSROADS>)>
		       <TELL
"The Cheshire Cat reappears on a bough of the tree. \"By-the-bye, what
became of the baby?\" it says. \"I'd nearly forgotten to ask.\"" CR>)>)
	       (<EQUAL? .RARG ,M-BEG>
		<COND (<AND <VERB? SAY>
			    <NOT ,PRSO>
			    ,P-CONT
			    <EQUAL? <GET ,P-LEXV ,P-CONT> ,W?PIG ,W?FIG>>
		       <SETG P-CONT <>>
		       <SETG QUOTE-FLAG <>>
		       <SAY-PIG>
		       <RTRUE>)>)
	       (<EQUAL? .RARG ,M-END> <WORLD-PULSE>)>>

<ROUTINE SAY-PIG ()
	 <COND (,PIGFIG-PENDING
		<SETG PIGFIG-PENDING <>>
		<SETG PIGFIG-DONE T>
		<TELL
"\"I said pig,\" you reply; \"and I wish you wouldn't keep appearing and
vanishing so suddenly: you make one quite giddy.\" -- \"All right,\"
says the Cat; and this time it vanishes quite slowly, beginning with the
end of the tail and ending with the grin, which remains some time after
the rest of it has gone." CR>
		<REMOVE ,CHESHIRE-CAT>)
	       (T
		<TELL
"\"Pig!\" you say, to nobody in particular, and feel briefly like a
duchess." CR>)>
	 <RTRUE>>

<ROUTINE CAT-RETURNS ()
	 <MOVE ,CHESHIRE-CAT ,CROSSROADS>
	 <SETG CAT-QUESTIONS 0>
	 <TELL
"A grin appears on the bough, and a cat gradually appears round it,
which is the wrong order for cats and the right one for this cat." CR>
	 <RTRUE>>

<ROUTINE CHESHIRE-CAT-FCN ()
	 <COND (<AND <VERB? TELL> ,PRSI>
		<CAT-HINT>
		<RTRUE>)
	       (<VERB? TELL HELLO ANSWER>
		<SETG P-CONT <>>
		<SETG QUOTE-FLAG <>>
		<TELL
"\"Cheshire Puss,\" you begin, rather timidly, \"would you tell me,
please, which way I ought to go from here?\" -- \"That depends a good
deal on where you want to get to,\" says the Cat. -- \"I don't much care
where --\" -- \"Then it doesn't matter which way you go.\" -- \"-- so
long as I get SOMEWHERE.\" -- \"Oh, you're sure to do that, if only you
walk long enough.\"" CR CR
"\"But I don't want to go among mad people,\" you remark. -- \"Oh, you
can't help that; we're all mad here. I'm mad. You're mad.\" -- \"How do
you know I'm mad?\" -- \"You must be, or you wouldn't have come here.\""
CR>
		<RTRUE>)
	       (<VERB? STROKE>
		<TELL
"You stroke the Cat. It grins wider, which you would not have said was
available." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A large cat with very long claws and a great many teeth, grinning from
ear to ear, sitting on a bough as though the bough were a favour it was
doing the tree." CR>
		<RTRUE>)
	       (<VERB? ATTACK TAKE>
		<TELL
"You would have to catch it first, and it is already only mostly here."
CR>
		<RTRUE>)>>

"The Cat is the hint system: never lies, never answers straight."
<ROUTINE CAT-HINT ()
	 <SETG P-CONT <>>
	 <SETG QUOTE-FLAG <>>
	 <SETG CAT-QUESTIONS <+ ,CAT-QUESTIONS 1>>
	 <COND (<EQUAL? ,PRSI ,T-MUSHROOM ,T-SIZE>
		<TELL
"\"He wants poetry. They always want poetry. Give him the one about
Father William and he will give you the mushroom; that is the economy of
this place.\"" CR>)
	       (<EQUAL? ,PRSI ,T-GARDEN>
		<TELL
"\"Doors are only ever locked in the wrong order,\" says the Cat.
\"Unlock first; shrink second. Bottle magic is sudden, and doors take
advantage. Mushroom magic is gradual, and doors never notice. That is
why we are all so fond of mushrooms here.\"" CR>)
	       (<EQUAL? ,PRSI ,T-TIME ,T-HATTER>
		<TELL
"\"In THAT direction,\" says the Cat, waving its right paw round, \"lives
a Hatter: and in THAT direction lives a March Hare. Visit either you
like: they're both mad. Butter was the wrong ointment, by the way. Ask
the Dormouse what wells are for.\"" CR>)
	       (<EQUAL? ,PRSI ,T-QUEEN>
		<TELL
"\"Say nonsense to her,\" says the Cat. \"It is the one language she
respects. And nobody is ever executed here; the Gryphon will tell you
so, if you can wake it.\"" CR>)
	       (<EQUAL? ,PRSI ,T-TRIAL>
		<TELL
"\"When they reach the sentence,\" says the Cat, \"say what it is.
Loudly.\"" CR>)
	       (<EQUAL? ,PRSI ,T-DUCHESS>
		<TELL
"\"She is under sentence of execution,\" says the Cat comfortably, \"for
being late. She was always going to be late; she left without her
invitation. Somebody has it now.\"" CR>)
	       (<EQUAL? ,PRSI ,T-WONDERLAND>
		<TELL
"\"We're all mad here,\" says the Cat. \"I'm mad. You're mad. You must
be, or you wouldn't have come here.\"" CR>)
	       (<EQUAL? ,PRSI ,T-RABBIT>
		<TELL
"\"Late,\" says the Cat. \"He has been late since before you were born,
and will be late after. Give him his gloves and he will be late more
comfortably.\"" CR>)
	       (<EQUAL? ,PRSI ,T-DINAH>
		<TELL
"\"A cat,\" says the Cheshire Cat, with the faintest possible
professional interest, \"is a thing that is somewhere else.\"" CR>)
	       (T
		<TELL
"The Cat considers the question, and grins at it until it goes away."
CR>)>
	 <COND (<G? ,CAT-QUESTIONS 2>
		<SETG CAT-QUESTIONS 0>
		<REMOVE ,CHESHIRE-CAT>
		<TELL
"Then it vanishes, tail first, grin last, leaving the bough looking
rather bare and slightly amused." CR>)>
	 <RTRUE>>

<ROUTINE CAT-TREE-FCN ()
	 <COND (<VERB? CLIMB-UP CLIMB-ON BOARD CLIMB-FOO>
		<TELL
"You get a little way up the tree. There is nothing in it but bough, and
a strong suggestion that the bough is spoken for." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A broad-boughed tree with one bough polished smooth, in the way of a
bough that is sat on by something heavy and frequently absent." CR>
		<RTRUE>)>>

"=================== THE DUCHESS'S DOORSTEP ==================="

<ROUTINE DUCHESS-LAWN-FCN (RARG)
	 <COND (<AND <EQUAL? .RARG ,M-BEG>
		      <VERB? WALK>
		      <EQUAL? ,PRSO ,P?IN>>
		<COND (<DUCHESS-DOOR-IN> <GOTO ,KITCHEN>)>
		<RTRUE>)
	       (<AND <EQUAL? .RARG ,M-ENTER> <==? ,KNOCK-COUNT 0>>
		<SETG KNOCK-COUNT 1>
		<TELL
"As you arrive, a Fish-Footman comes running out of the wood with a
great letter under his arm, and delivers it to the Frog-Footman with
the words: \"For the Duchess. An invitation from the Queen to play
croquet.\" The Frog-Footman repeats it back in the same solemn tone,
only changing the order of the words a little, and they both bow so low
that their curls get entangled together." CR>)
	       (<EQUAL? .RARG ,M-END> <WORLD-PULSE>)>>

<ROUTINE DUCHESS-DOOR-IN ()
	 <COND (<NOT <SMALL?>>
		<TELL
"The doorway is a fine doorway for a four-foot house. You are not a
four-foot person." CR>
		<RFALSE>)
	       (T
		<COND (<NOT ,F-KITCHEN>
		       <SETG F-KITCHEN T>
		       <SCORE-UPD 2>)>
		<RETURN ,KITCHEN>)>>

<ROUTINE DUCHESS-DOOR-FCN ()
	 <COND (<VERB? KNOCK>
		<DO-KNOCKING>
		<RTRUE>)
	       (<VERB? OPEN>
		<TELL
"You open the door. \"Anything you like,\" says the Footman, and begins
whistling. The door was never locked; nobody had thought to try it,
which is the commonest sort of lock there is." CR>
		<RTRUE>)
	       (<VERB? THROUGH ENTER BOARD>
		<DO-WALK ,P?IN>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"The front door of a four-foot house, shut, and not in the least
locked." CR>
		<RTRUE>)>>

<ROUTINE DO-KNOCKING ()
	 <SETG KNOCK-COUNT <+ ,KNOCK-COUNT 1>>
	 <COND (<==? ,KNOCK-COUNT 2>
		<TELL
"\"There's no sort of use in knocking,\" says the Footman, \"and that
for two reasons. First, because I'm on the same side of the door as you
are; secondly, because they're making such a noise inside, no one could
possibly hear you.\" And indeed there is a most extraordinary noise
going on within: a constant howling and sneezing, and every now and
then a great crash, as if a dish had been broken to pieces." CR>)
	       (<==? ,KNOCK-COUNT 3>
		<TELL
"\"How am I to get in?\" you ask. -- \"THAT'S the first question, you
know,\" says the Footman, and it is, though he does not say what the
second is." CR>)
	       (<==? ,KNOCK-COUNT 4>
		<TELL
"\"I shall sit here,\" the Footman remarks, \"on and off, for days and
days.\" -- \"But what am I to DO?\" -- \"Anything you like,\" says the
Footman, and begins whistling." CR>)
	       (T
		<TELL
"You knock again. The Footman looks up into the sky, which he has been
doing all along, and which is at least consistent." CR>)>
	 <RTRUE>>

<ROUTINE FROG-FOOTMAN-FCN ()
	 <COND (<AND <VERB? TELL> ,PRSI>
		<SETG P-CONT <>>
		<SETG QUOTE-FLAG <>>
		<TELL
"\"There's no sort of use in asking HIM,\" you think, and there is not.
\"Anything you like,\" says the Footman, and looks up into the sky."
CR>
		<RTRUE>)
	       (<VERB? TELL HELLO ANSWER>
		<DO-KNOCKING>
		<SETG P-CONT <>>
		<SETG QUOTE-FLAG <>>
		<RTRUE>)
	       (<VERB? KNOCK>
		<DO-KNOCKING>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A footman in livery with the face of a frog, sitting on the doorstep
and staring stupidly up into the sky. His eyes are extremely near the
top of his head, which is a great advantage for looking at sky." CR>
		<RTRUE>)
	       (<VERB? ATTACK>
		<TELL
"You would be striking a public servant in the performance of no duty
whatever, which is worse." CR>
		<RTRUE>)>>

"=================== THE KITCHEN ==================="

<ROUTINE KITCHEN-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-END>
		<SETG KITCHEN-TURNS <+ ,KITCHEN-TURNS 1>>
		<COND (<AND <IN? ,THE-DUCHESS ,KITCHEN>
			    <G? ,KITCHEN-TURNS 2>>
		       <DUCHESS-DEPARTS>)
		      (<AND <NOT <IN? ,THE-DUCHESS ,KITCHEN>>
			    <IN? ,THE-BABY ,KITCHEN>
			    <G? ,KITCHEN-TURNS 5>>
		       <REMOVE ,THE-BABY>
		       <TELL CR
"The baby, left to itself, grunts once, gets down off the hearth, and
trots quietly out of the door on four feet, having settled the question
of what it was going to be." CR>)
		      (T <SNEEZE-TEXT>)>
		<WORLD-PULSE>)>>

<ROUTINE SNEEZE-TEXT ()
	 <COND (<EQUAL? ,HERE ,KITCHEN>
		<TELL CR
"You sneeze. So does the baby. The Duchess sneezes occasionally. The
cook and the cat do not." CR>)
	       (<IN? ,PEPPERBOX ,WINNER>
		<TELL
"You get a noseful of pepper and sneeze twice, handsomely. Somewhere a
baby answers you, out of solidarity." CR>)
	       (T
		<TELL "You sneeze once, on general principle." CR>)>
	 <RFALSE>>

<ROUTINE DUCHESS-DEPARTS ()
	 <SETG KITCHEN-TURNS 0>
	 <MOVE ,THE-BABY ,WINNER>
	 <SETG BABY-STATE 1>
	 <MOVE ,INVITATION ,KITCHEN>
	 <REMOVE ,THE-DUCHESS>
	 <TELL CR
"The Duchess sings a sort of lullaby to the baby, giving it a violent
shake at the end of every line: \"Speak roughly to your little boy, and
beat him when he sneezes: he only does it to annoy, because he knows it
teases. Wow! wow! wow!\"" CR CR
"\"Here! you may nurse it a bit, if you like!\" she says suddenly, and
flings the baby at you as she speaks. \"I must go and get ready to play
croquet with the Queen,\" and she hurries out of the room. As she goes,
a stiff card flutters out of her sleeve and settles on the floor." CR>
	 <RFALSE>>

<ROUTINE THE-DUCHESS-FCN ()
	 <COND (<AND <VERB? TELL> ,PRSI>
		<DUCHESS-TOPIC>
		<RTRUE>)
	       (<VERB? TELL HELLO ANSWER>
		<DUCHESS-TOPIC>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<COND (,DUCHESS-FREED
		       <TELL
"The Duchess, out of prison and remarkably good-humoured about it, with
a very uncomfortable chin." CR>)
		      (T
		       <TELL
"An extremely ugly Duchess on a three-legged stool, nursing a baby as
one might nurse a grievance." CR>)>
		<RTRUE>)
	       (<VERB? ATTACK>
		<TELL
"\"Chop off her head!\" says the Duchess, hopefully, about you, and the
moment passes." CR>
		<RTRUE>)>>

<ROUTINE DUCHESS-TOPIC ()
	 <SETG P-CONT <>>
	 <SETG QUOTE-FLAG <>>
	 <COND (,DUCHESS-FREED <MORAL-LINE> <RTRUE>)>
	 <SETG DUCHESS-TALKS <+ ,DUCHESS-TALKS 1>>
	 <COND (<EQUAL? ,PRSI ,T-QUEEN ,W-CROQUET>
		<TELL
"\"Talking of axes,\" says the Duchess, who was not, \"chop off her
head!\" You look up in some alarm, but she is looking at the soup." CR>)
	       (<EQUAL? ,PRSI ,T-DINAH>
		<TELL
"\"It's a Cheshire cat,\" says the Duchess, \"and that's why. Pig!\" You
jump; but she means the baby, probably." CR>)
	       (<EQUAL? ,PRSI ,T-WONDERLAND>
		<TELL
"\"Everything's got a moral, if only you can find it,\" says the
Duchess, and sneezes." CR>)
	       (T
		<TELL
"\"If everybody minded their own business,\" the Duchess says in a hoarse
growl, \"the world would go round a deal faster than it does.\" -- \"Which
would NOT be an advantage,\" you say, rather glad of a chance to show off
a little knowledge; \"just think what work it would make with the day and
night!\" -- \"Talking of axes,\" says the Duchess, \"chop off her head!\""
CR>)>
	 <RTRUE>>

<ROUTINE THE-COOK-FCN ()
	 <COND (<VERB? TELL HELLO ANSWER>
		<SETG P-CONT <>>
		<SETG QUOTE-FLAG <>>
		<TELL
"\"Shan't,\" says the cook, and throws a saucepan at nobody in
particular. It misses, as everything here does." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A cook stirring a large cauldron of soup and, at intervals, throwing
everything within reach at the Duchess and the baby: fire-irons, then
saucepans, plates, and dishes. Her aim is remarkable in that it never
once succeeds." CR>
		<RTRUE>)
	       (<VERB? ATTACK>
		<TELL
"She has more crockery than you have arms." CR>
		<RTRUE>)>>

<ROUTINE THE-BABY-FCN ()
	 <COND (<VERB? TAKE>
		<COND (<IN? ,THE-BABY ,WINNER>
		       <TELL "You have it already, and it has you." CR>)
		      (<IN? ,THE-DUCHESS ,KITCHEN>
		       <TELL
"The Duchess is nursing it, after her fashion, and is not yet finished
being tired of it." CR>)
		      (T
		       <MOVE ,THE-BABY ,WINNER>
		       <SETG BABY-STATE 1>
		       <TELL
"You catch the baby, which is a queer-shaped little creature and holds
out its arms and legs in all directions, like a star-fish." CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<COND (<G? ,BABY-STATE 1>
		       <TELL
"It has a very turn-up nose, much more like a snout than a real nose;
and its eyes are getting extremely small for a baby." CR>)
		      (T
		       <TELL
"A queer-shaped little creature, howling, and grunting alternately, with
no possible way of telling which it means." CR>)>
		<RTRUE>)
	       (<VERB? TELL HELLO>
		<SETG P-CONT <>>
		<SETG QUOTE-FLAG <>>
		<TELL
"\"Don't grunt,\" you say; \"that's not at all a proper way of
expressing yourself.\" The baby grunts again." CR>
		<RTRUE>)
	       (<VERB? DROP>
		<COND (<IN? ,THE-BABY ,WINNER>
		       <MOVE ,THE-BABY ,HERE>
		       <SETG BABY-STATE 0>
		       <TELL
"You set the baby down. It lies where it is put, radiating grievance."
CR>)
		      (T <RFALSE>)>
		<RTRUE>)>>

<ROUTINE HEARTH-CAT-FCN ()
	 <COND (<VERB? TELL HELLO ANSWER EXAMINE>
		<SETG P-CONT <>>
		<SETG QUOTE-FLAG <>>
		<TELL
"The cat only grins, from ear to ear, and says nothing at all in the
kitchen, on the grounds that the kitchen is already saying quite
enough." CR>
		<RTRUE>)
	       (<VERB? STROKE>
		<TELL
"You stroke the hearth-cat. The grin travels up your arm and stays
there a moment." CR>
		<RTRUE>)>>

<ROUTINE CAULDRON-FCN ()
	 <COND (<VERB? EXAMINE LOOK-INSIDE>
		<TELL
"A cauldron of soup which is, as far as anybody can tell by breathing,
entirely pepper." CR>
		<RTRUE>)
	       (<VERB? TAKE EAT DRINK>
		<TELL
"There is far, far too much pepper in that soup for any appetite you
own." CR>
		<RTRUE>)>>

<ROUTINE PEPPERBOX-FCN ()
	 <COND (<AND <VERB? TAKE> <NOT <IN? ,PEPPERBOX ,WINNER>>>
		<MOVE ,PEPPERBOX ,WINNER>
		<COND (<NOT ,F-PEPPERBOX>
		       <SETG F-PEPPERBOX T>
		       <SCORE-UPD 1>)>
		<TELL
"You take the second pepper-box off the dresser. The cook has the other
one and would not notice the loss of a stove." CR>
		<RTRUE>)
	       (<VERB? SMELL>
		<SNEEZE-TEXT>
		<RTRUE>)
	       (<VERB? OPEN THROW>
		<COND (<EQUAL? ,HERE ,COURTROOM>
		       <PEPPER-THE-COURT>)
		      (T
		       <TELL
"You open the pepper-box experimentally, and everything within a yard of
you sneezes, including you." CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A pepper-box, full, heavy, and of an obvious tactical value you have
not yet had occasion to use." CR>
		<RTRUE>)>>

<ROUTINE INVITATION-FCN ()
	 <COND (<AND <VERB? TAKE> <NOT <IN? ,INVITATION ,WINNER>>>
		<MOVE ,INVITATION ,WINNER>
		<COND (<NOT ,F-INVITE>
		       <SETG F-INVITE T>
		       <SCORE-UPD 2>)>
		<TELL
"You pick up the stiff card. The Duchess has gone off to play croquet
without her invitation, which is going to be somebody's problem, and for
once it is not yours." CR>
		<RTRUE>)
	       (<VERB? EXAMINE READ>
		<TELL
"An invitation from the Queen to the Duchess, to play croquet. It is very
stiff, very royal, and entirely silent on the question of who presents
it." CR>
		<RTRUE>)
	       (<AND <VERB? GIVE SHOW> <EQUAL? ,PRSI ,THE-QUEEN>>
		<SHOW-INVITATION>
		<RTRUE>)>>

"=================== THE MAD TEA PARTY ==================="

<ROUTINE TEA-GARDEN-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<COND (,WATCH-FIXED
		       <TELL
"The long tea table, at peace for the first time in months. The things
are being washed. The Dormouse sleeps in the exact center of the table,
by common consent, as an ornament. Behind the house stands an old stone
well." CR>)
		      (T
		       <TELL
"A long table set out under a tree in front of a house with a
fur-thatched roof and chimneys shaped like ears. The table is laid for a
great many more than three, but the March Hare, the Hatter, and a
sleeping Dormouse are all crowded together at one corner of it, crying
\"No room! No room!\" -- which is nonsense, and you say so. Behind the
house stands an old stone well." CR>)>
		<RTRUE>)
	       (<EQUAL? .RARG ,M-ENTER>
		<SETG SEATED <>>)
	       (<EQUAL? .RARG ,M-END>
		<COND (<AND ,SEATED <NOT ,WATCH-FIXED>>
		       <TEA-AMBIENT>)>
		<WORLD-PULSE>)>>

<ROUTINE TEA-WELL-EXIT ()
	 <COND (<SMALL?>
		<COND (<NOT ,F-TREACLE-WELL>
		       <SETG F-TREACLE-WELL T>
		       <SCORE-UPD 3>)>
		<RETURN ,TREACLE-WELL>)
	       (T
		<TELL
"The bucket rope would hold a person of very modest tonnage. Yours is
presently immodest." CR>
		<RFALSE>)>>

<ROUTINE DO-TEA-SIT ()
	 <COND (,SEATED
		<TELL "You are sitting already, and comfortably." CR>)
	       (T
		<SETG SEATED T>
		<TELL
"\"No room! No room!\" they cry when they see you coming. -- \"There's
PLENTY of room!\" you say indignantly, and sit down in a large arm-chair
at one end of the table." CR CR
"\"Have some wine,\" the March Hare says in an encouraging tone. You
look all round the table, but there is nothing on it but tea. \"I don't
see any wine,\" you remark. -- \"There isn't any,\" says the March
Hare. -- \"Then it wasn't very civil of you to offer it,\" you say
angrily. -- \"It wasn't very civil of you to sit down without being
invited,\" says the March Hare. Your hair, the Hatter observes, wants
cutting." CR>)>
	 <RTRUE>>

<ROUTINE TEA-AMBIENT ()
	 <SETG TEA-LINE <+ ,TEA-LINE 1>>
	 <COND (<==? ,TEA-LINE 1>
		<TELL CR
"\"Why is a raven like a writing-desk?\" says the Hatter suddenly, as
though it had only just occurred to him, which it has, several hundred
times." CR>)
	       (<==? ,TEA-LINE 2>
		<TELL CR
"\"Take some more tea,\" the March Hare says earnestly. -- \"I've had
nothing yet, so I can't take more.\" -- \"You mean you can't take LESS,\"
says the Hatter: \"it's very easy to take MORE than nothing.\"" CR>)
	       (<==? ,TEA-LINE 3>
		<TELL CR
"\"It's always six o'clock now,\" the Hatter says mournfully. \"It's
always tea-time, and we've no time to wash the things between whiles.\""
CR>)
	       (T
		<SETG TEA-LINE 0>
		<TELL CR
"Everybody moves one place on. The Hatter gets a clean cup; you get the
March Hare's, which had milk in it." CR>)>
	 <RFALSE>>

<ROUTINE THE-HATTER-FCN ()
	 <COND (<AND <VERB? GIVE SHOW PUT>
		     <EQUAL? ,PRSO ,MARMALADE-JAR ,TREACLE-GOO>>
		<FIX-THE-WATCH>
		<RTRUE>)
	       (<AND <VERB? TELL> ,PRSI>
		<HATTER-TOPIC>
		<RTRUE>)
	       (<VERB? TELL HELLO ANSWER>
		<HATTER-TOPIC>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A hatter in a very large hat with a ticket in the band reading IN THIS
STYLE 10/6. He has the face of a man whose quarrel with Time has gone to
arbitration and been lost." CR>
		<RTRUE>)>>

<ROUTINE HATTER-TOPIC ()
	 <SETG P-CONT <>>
	 <SETG QUOTE-FLAG <>>
	 <COND (<AND ,WATCH-FIXED <==? ,STAY-OFFER 0>>
		<SETG STAY-OFFER 1>
		<TELL
"\"There's room now, you know,\" says the Hatter, moving up and patting
the chair beside him. \"All the room in the world. Stay for ever?\""
CR>)
	       (<EQUAL? ,PRSI ,T-TIME ,W-CROQUET>
		<TELL
"\"We quarrelled last March,\" says the Hatter, \"just before HE went
mad, you know -- I had to sing at the great concert given by the Queen
of Hearts, and I'd hardly finished the first verse when the Queen bawled
out, 'He's murdering the time! Off with his head!' -- and ever since
that, he won't do a thing I ask. It's always six o'clock now.\"" CR>)
	       (<EQUAL? ,PRSI ,T-QUEEN>
		<TELL
"\"She said I was murdering the time,\" says the Hatter darkly. \"You
can't say I murdered it. It stopped.\"" CR>)
	       (<EQUAL? ,PRSI ,T-TRIAL>
		<TELL
"\"I'm a poor man, your Majesty,\" says the Hatter, rehearsing." CR>)
	       (T
		<TELL
"\"Why is a raven like a writing-desk?\" says the Hatter. It is his one
conversational move, and he plays it well." CR>)>
	 <RTRUE>>

<ROUTINE MARCH-HARE-FCN ()
	 <COND (<VERB? TELL HELLO ANSWER>
		<SETG P-CONT <>>
		<SETG QUOTE-FLAG <>>
		<TELL
"\"Have some wine,\" the March Hare says encouragingly. There is no
wine. \"It was the BEST butter,\" he adds, apropos of nothing, and
meekly, as though the subject had come up." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A March Hare, still slightly mad from March, with butter on his paws
and no opinion of clocks." CR>
		<RTRUE>)>>

<ROUTINE DORMOUSE-FCN ()
	 <COND (<VERB? ALARM TELL HELLO ANSWER>
		<WAKE-DORMOUSE>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A Dormouse, fast asleep between the other two, being used as a cushion
by both of them, and not objecting, being asleep." CR>
		<RTRUE>)
	       (<VERB? TAKE>
		<TELL
"You could take it; it would not wake; but you would then own a
Dormouse." CR>
		<RTRUE>)>>

<ROUTINE WAKE-DORMOUSE ()
	 <SETG P-CONT <>>
	 <SETG QUOTE-FLAG <>>
	 <COND (,DORMOUSE-TOLD
		<TELL
"The Dormouse says \"Treacle,\" without opening its eyes, and goes back
to sleep, having made its contribution for the day." CR>)
	       (T
		<SETG DORMOUSE-TOLD T>
		<TELL
"The Dormouse wakes up with a little shriek and goes on, without any
introduction whatever: \"Once upon a time there were three little
sisters, and their names were Elsie, Lacie, and Tillie; and they lived
at the bottom of a well.\"" CR CR
"\"What did they live on?\" you ask. -- \"They lived on treacle,\" says
the Dormouse, after thinking a minute or two. -- \"They couldn't have
done that, you know; they'd have been ill.\" -- \"So they were,\" says
the Dormouse; \"VERY ill.\" -- \"But why did they live at the bottom of
a well?\" -- \"It was a treacle-well,\" says the Dormouse, and falls
asleep, having said the only useful thing anybody says all afternoon."
CR>)>
	 <RTRUE>>

<ROUTINE THE-RIDDLE-FCN ()
	 <COND (<VERB? ANSWER TELL REPLY EXAMINE>
		<DO-RIDDLE>
		<RTRUE>)>>

<ROUTINE DO-RIDDLE ()
	 <SETG P-CONT <>>
	 <SETG QUOTE-FLAG <>>
	 <COND (,RIDDLE-DONE
		<TELL
"Nobody has an answer to it today either. It is a very stable riddle."
CR>)
	       (T
		<SETG RIDDLE-DONE T>
		<TELL
"\"Do you mean that you think you can find out the answer to it?\" says
the March Hare. -- \"Exactly so,\" you say. -- \"Then you should say
what you mean,\" the March Hare goes on. -- \"I do,\" you reply
hastily; \"at least -- at least I mean what I say -- that's the same
thing, you know.\" -- \"Not the same thing a bit!\" says the Hatter."
CR CR
"You wait some time. \"Have you guessed the riddle yet?\" the Hatter
says, turning to you again. -- \"No, I give it up. What's the answer?\"
-- \"I haven't the slightest idea,\" says the Hatter. -- \"Nor I,\" says
the March Hare. The subject is considered closed and entirely
satisfactory." CR>)>
	 <RTRUE>>

<ROUTINE HATTER-WATCH-FCN ()
	 <COND (<AND <VERB? PUT PUT-ON>
		     <EQUAL? ,PRSO ,MARMALADE-JAR ,TREACLE-GOO>>
		<FIX-THE-WATCH>
		<RTRUE>)
	       (<AND <VERB? PUT PUT-ON>
		     <EQUAL? ,PRSO ,BREAD-AND-BUTTER>>
		<TELL
"\"It was the best butter,\" the March Hare says, defensively. It was
also the whole problem." CR>
		<RTRUE>)
	       (<VERB? EXAMINE READ>
		<COND (,WATCH-FIXED
		       <TELL
"A watch that tells the day of the month, and tells it correctly, which
in this house counts as a miracle and is treated as one." CR>)
		      (T
		       <TELL
"It tells the day of the month, and is exactly two days wrong. There are
crumbs in the works, from when the March Hare buttered it with the
bread-knife. \"It was the BEST butter,\" the March Hare says, meekly."
CR>)>
		<RTRUE>)
	       (<VERB? TAKE>
		<TELL
"The Hatter's hand closes over it. Whatever else he has lost, he has not
lost the watch." CR>
		<RTRUE>)>>

<ROUTINE FIX-THE-WATCH ()
	 <COND (,WATCH-FIXED
		<TELL
"Time and the Hatter are reconciled already; a second treacling would be
gloating." CR>
		<RTRUE>)
	       (<NOT <IN? ,TREACLE-GOO ,MARMALADE-JAR>>
		<TELL
"The jar is empty, and an empty jar mends nothing. Something thick and
sweet is wanted, and there is a well behind the house." CR>
		<RTRUE>)
	       (T
		<SETG WATCH-FIXED T>
		<SCORE-UPD 4>
		<REMOVE ,TREACLE-GOO>
		<MOVE ,TALL-HAT ,WINNER>
		<TELL
"The Hatter dips the watch solemnly into the treacle, holds it to his
ear, and goes quite white, then quite pink. \"It ticks the RIGHT day,\"
he whispers. \"Time and I are reconciled. It is a quarter past
washing-up time!\"" CR CR
"The table erupts. The March Hare begins carrying cups to the well; the
Dormouse is moved to the middle of the table and left there as an
ornament; and the Hatter takes off his enormous hat and presses it upon
you. \"I keep them to sell. I've none of my own. But this one is yours:
you mended six o'clock.\"" CR>
		<COND (<NOT ,F-HAT>
		       <SETG F-HAT T>
		       <SCORE-UPD 1>)>
		<RTRUE>)>>

<ROUTINE TALL-HAT-FCN ()
	 <COND (<VERB? EXAMINE READ>
		<TELL
"A very large hat with a ticket in the band: IN THIS STYLE 10/6. It is
not your size, and it does not care." CR>
		<RTRUE>)>>

<ROUTINE TEA-THINGS-FCN ()
	 <COND (<VERB? DRINK EAT TAKE>
		<TELL
"You take some tea, and some bread-and-butter, and feel a good deal
better about the general situation." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A great many cups, most of them used, arranged in the pattern that
results when nobody may wash up and everybody must move along." CR>
		<RTRUE>)>>

<ROUTINE BREAD-AND-BUTTER-FCN ()
	 <COND (<VERB? EAT TAKE>
		<TELL
"You have some bread-and-butter. It was the best butter." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"Bread-and-butter, buttered with the best butter, by somebody who also
butters watches." CR>
		<RTRUE>)>>

<ROUTINE ARM-CHAIR-FCN ()
	 <COND (<VERB? SIT BOARD CLIMB-ON>
		<DO-TEA-SIT>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A large arm-chair at one end of the table, unoccupied, and quite
plainly room." CR>
		<RTRUE>)>>

<ROUTINE STONE-WELL-FCN ()
	 <COND (<VERB? THROUGH ENTER BOARD CLIMB-DOWN>
		<DO-WALK ,P?DOWN>
		<RTRUE>)
	       (<VERB? LOOK-INSIDE EXAMINE>
		<TELL
"An old stone well with a bucket on a rope. Whatever is at the bottom of
it smells sweet, and dark, and slow." CR>
		<RTRUE>)>>

"=================== THE TREACLE WELL ==================="

<ROUTINE TREACLE-WELL-FCN (RARG)
	 <COND (<AND <EQUAL? .RARG ,M-BEG> <VERB? FILL PUT>>
		<FILL-THE-JAR>
		<RTRUE>)
	       (<EQUAL? .RARG ,M-END> <WORLD-PULSE>)>>

<ROUTINE TREACLE-GOO-FCN ()
	 <COND (<VERB? TAKE FILL PUT>
		<FILL-THE-JAR>
		<RTRUE>)
	       (<VERB? EAT DRINK>
		<TELL
"You taste the treacle. It is exactly as sweet as three sisters could
draw in a day, and you stop before you are VERY ill." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"Treacle, glistening brown down every wall of the well, on tap and
apparently on principle." CR>
		<RTRUE>)>>

<ROUTINE FILL-THE-JAR ()
	 <COND (<IN? ,TREACLE-GOO ,MARMALADE-JAR>
		<TELL "The jar is already full to the brim." CR>)
	       (<NOT <IN? ,MARMALADE-JAR ,WINNER>>
		<TELL
"You have nothing to put it in, and treacle carried by hand is a lesson
rather than a substance." CR>)
	       (T
		<MOVE ,TREACLE-GOO ,MARMALADE-JAR>
		<TELL
"The marmalade jar has waited all day for a purpose. This is it: you
fill it to the brim with treacle, and the label becomes a small
untruth." CR>)>
	 <RTRUE>>

<ROUTINE THREE-SISTERS-FCN ()
	 <COND (<AND <VERB? TELL> ,PRSI>
		<SISTERS-TALK>
		<RTRUE>)
	       (<VERB? TELL HELLO ANSWER>
		<SISTERS-TALK>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"Elsie, Lacie, and Tillie, at the bottom of a well, learning to draw:
very ill, entirely content, and covered in treacle to the elbow." CR>
		<RTRUE>)>>

<ROUTINE SISTERS-TALK ()
	 <SETG P-CONT <>>
	 <SETG QUOTE-FLAG <>>
	 <TELL
"\"What did you draw?\" you ask. -- \"Treacle,\" says Elsie. -- \"And
everything that begins with an M,\" says Lacie: \"mouse-traps, and the
moon, and memory, and muchness -- you know you say things are 'much of a
muchness' -- did you ever see such a thing as a drawing of a
muchness?\" -- \"Really, now you ask me,\" you say, very much confused,
\"I don't think --\" -- \"Then you shouldn't talk,\" says Tillie." CR>
	 <RTRUE>>

"=================== WOOD OF DOORS ==================="

<ROUTINE DOOR-TREE-WOOD-FCN (RARG)
	 <COND (<AND <EQUAL? .RARG ,M-BEG>
		      <VERB? WALK>
		      <EQUAL? ,PRSO ,P?IN>>
		<GOTO <TREE-DOOR-IN>>
		<RTRUE>)
	       (<EQUAL? .RARG ,M-END> <WORLD-PULSE>)>>

<ROUTINE TREE-DOOR-IN ()
	 <RESET-THE-HALL>
	 <TELL
"\"That's very curious!\" you think. \"But everything's curious today. I
think I may as well go in at once.\" And in you go." CR CR
"The hall has tidied itself for company: the little golden key is back
on the glass table, and the little door is shut, and locked, and looks
as though it had never been anything else." CR CR>
	 <RETURN ,HALL>>

<ROUTINE RESET-THE-HALL ()
	 <MOVE ,GOLDEN-KEY ,GLASS-TABLE>
	 <FSET ,LITTLE-DOOR ,LOCKEDBIT>
	 <FCLEAR ,LITTLE-DOOR ,OPENBIT>
	 <FCLEAR ,LITTLE-DOOR ,INVISIBLE>
	 <SETG CURTAIN-MOVED T>
	 <SETG POOL-GONE T>
	 <RTRUE>>

<ROUTINE TREE-DOOR-FCN ()
	 <COND (<VERB? OPEN THROUGH ENTER BOARD>
		<DO-WALK ,P?IN>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A proper door, with hinges and a handle, in the bark of a tree. Whoever
hung it did a workmanlike job and then, presumably, went home." CR>
		<RTRUE>)
	       (<VERB? KNOCK>
		<TELL
"You knock on the tree. The tree, which is a tree, does not answer." CR>
		<RTRUE>)>>
