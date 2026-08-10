"DACT3 - Act III. Varna, Galatz, the river deduction, the camp and the
holy circle, the castle purged, and the sunset on the Borgo road.
(The ACT global is 4 throughout this file.)"

"====================================================================
ACT III STATE"

<GLOBAL VARNA-TICKS 0>
<GLOBAL TRANCE-DONE <>>
<GLOBAL TELEGRAM-CAME <>>
<GLOBAL TELEGRAM-READ <>>
<GLOBAL AT-GALATZ <>>
<GLOBAL BILL-READ <>>
<GLOBAL MAP-READ <>>
<GLOBAL RIVER-SOLVED <>>
<GLOBAL CAMP-DUSK 0>       ;"0 day, 1 dusk warned, 2 night, 3 morning"
<GLOBAL CIRCLE-DRAWN <>>
<GLOBAL CIRCLE-TESTED <>>
<GLOBAL IN-CIRCLE <>>
<GLOBAL CIRCLE-WARNED 0>
<GLOBAL CAMP-TICKS 0>
<GLOBAL SUN 0>             ;"the Borgo road sun clock, 0..8"
<GLOBAL BOX-DOWN <>>
<GLOBAL LID-OFF <>>
<GLOBAL ROAD-STALL 0>
<GLOBAL SZGANY-CHARGED <>>
<GLOBAL QUINCEY-HIT <>>
<GLOBAL ENDED <>>

"====================================================================
VARNA - the waiting"

<ROUTINE ACT4-COMMON (RARG)
	 <COND (<EQUAL? .RARG ,M-BEG>
		<COND (<AND <VERB? WAIT SLEEP> <EQUAL? ,HERE ,VARNA-HOTEL>>
		       <VARNA-ADVANCE>
		       <RTRUE>)
		      (<AND <VERB? WAIT SLEEP> <EQUAL? ,HERE ,GALATZ-WHARF>>
		       <GALATZ-NUDGE>
		       <RTRUE>)>)>
	 <RFALSE>>

<ROUTINE VARNA-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<TELL
"A shuttered hotel room grown small with waiting: maps on the table,
the kukri whetted daily, and every dawn and dusk the professor's hands
making passes before Mina's closed eyes. There is nowhere to go. There
is only news to wait for.">
		<COND (,TELEGRAM-CAME
		       <TELL CR
"The telegram lies open on the maps.">)>
		<TELL CR>
		<RTRUE>)
	       (T <ACT4-COMMON .RARG>)>>

<ROUTINE VARNA-ADVANCE ()
	 <SETG VARNA-TICKS <+ ,VARNA-TICKS 1>>
	 <COND (<AND <EQUAL? ,VARNA-TICKS 1> <NOT ,TRANCE-DONE>>
		<SETG TRANCE-DONE T>
		<TELL CR
"Dawn. The professor makes his passes and she goes under between one
breath and the next, and speaks in a voice flat as a reading of the
weather: \"I hear the lapping of water. It is level with me, and the
creaking of a chain, and the sound of men running overhead. There is no
sun.\" So he is still afloat, and still boxed, and still ours to catch."
CR CR
"Three weeks of this. The Czarina Catherine does not come to Varna."
CR>)
	       (<NOT ,TELEGRAM-CAME>
		<SETG TELEGRAM-CAME T>
		<MOVE ,TELEGRAM ,VARNA-HOTEL>
		<TELL CR
"A boy runs up the stairs with a wire from Lloyd's, and the professor
reads it standing, and then sits down without looking for the chair."
CR CR
"Twenty-eighth of October. Czarina Catherine reported entering Galatz
at one o'clock to-day. Galatz. Not Varna. He read our plan in her
sleeping mind while we read his in it, and he has beaten us by a
hundred miles of coast." CR>)
	       (T
		<GO-TO-GALATZ>)>>

<ROUTINE TELEGRAM-FCN ()
	 <COND (<VERB? READ EXAMINE>
		<COND (<NOT ,TELEGRAM-READ>
		       <SETG TELEGRAM-READ T>
		       <AWARD 1>)>
		<TELL
"Twenty-eighth of October. Czarina Catherine reported entering Galatz
at one o'clock to-day. Three weeks you waited at Varna; he was never
coming to Varna. He read the plan out of Mina's sleeping mind as surely
as the professor reads the sea in it." CR>
		<RTRUE>)>>

<ROUTINE GO-TO-GALATZ ()
	 <SETG AT-GALATZ T>
	 <MOVE ,RIVER-MAP ,GALATZ-WHARF>
	 <MOVE ,VAN-HELSING ,GALATZ-WHARF>
	 <MOVE ,JONATHAN ,GALATZ-WHARF>
	 <MOVE ,MINA ,GALATZ-WHARF>
	 <TELL CR
"Thirty hours by train, and the whole company of you off it at Galatz
in the raw river morning, and down to the wharf before the ship has her
warps ashore." CR CR>
	 <SETG HERE ,GALATZ-WHARF>
	 <MOVE ,WINNER ,HERE>
	 <SETG LIT T>
	 <V-FIRST-LOOK>>

"====================================================================
GALATZ - the deduction"

<ROUTINE GALATZ-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<TELL
"Brown river, tarred rope, and the Czarina Catherine warping in. A Scots
captain glares from the rail at the devil's own luck that blew him here.
The box is gone ashore already; what remains is paper, and the truth at
the bottom of it." CR>
		<RTRUE>)
	       (T <ACT4-COMMON .RARG>)>>

<ROUTINE GALATZ-NUDGE ()
	 <COND (,RIVER-SOLVED
		<TELL
"There is nothing more to wait for. The horses are bought, the launch
is hired, and the professor is looking at you." CR>)
	       (T
		<TELL
"The captain has his say, the bill of lading is in your hand, and the
map is on the crate beside you. Somewhere in the paper is a road." CR>)>>

<ROUTINE DONELSON-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"A short, hard Scots shipmaster with a grievance and a fine turn of
phrase for it." CR>
		<RTRUE>)
	       (<VERB? TELL HELLO TELL>
		<TELL
"\"Yon was the queerest run I ever made. We had a fog wi' us frae the
Dardanelles, and yet the wind was fair behind -- as though the Deil
himself were blawin' on our sail for his ain purpose. And a mon came
aboard at dawn wi' a paper and had yon box off her before the customs
was rightly awake, and I was that glad to see the back o' it I gie'd
him a hand mysel'.\"" CR>
		<RTRUE>)>>

<ROUTINE BILL-FCN ()
	 <COND (<VERB? READ EXAMINE>
		<COND (<NOT ,BILL-READ>
		       <SETG BILL-READ T>
		       <AWARD 1>)>
		<TELL
"One box, earth, consigned to Immanuel Hildesheim of Burgen-strasse; and
Hildesheim, for five pounds, says he passed it to Petrof Skinsky, who
deals with the Slovaks that trade down the river to the port. And
Skinsky, when they go to find him, is found instead: in a churchyard,
with his throat torn open as if by a wild beast. So the box is on the
water, going up." CR>
		<COND (<AND ,MAP-READ <NOT ,RIVER-SOLVED>>
		       <TELL CR
"Mina spreads the map on the crate and puts her finger on it." CR>)>
		<RTRUE>)>>

<ROUTINE RIVER-MAP-FCN ()
	 <COND (<VERB? READ EXAMINE LOOK-INSIDE>
		<COND (<NOT ,MAP-READ>
		       <SETG MAP-READ T>
		       <AWARD 1>)>
		<TELL
"The rivers of the country, drawn fine: the Danube, and out of it the
Sereth going north, and into the Sereth at Fundu the Bistritza, and the
Bistritza climbing up and up into the mountains toward a pass the map
calls Borgo." CR>
		<COND (<AND ,BILL-READ <NOT ,RIVER-SOLVED>>
		       <TELL CR
"Mina has her finger on Fundu and is not moving it." CR>)>
		<RTRUE>)
	       (<AND <VERB? TELL> <EQUAL? ,PRSI ,GT-RIVER>>
		<RIVER-DEDUCTION>
		<RTRUE>)>>

<ROUTINE RIVER-DEDUCTION ()
	 <COND (,RIVER-SOLVED
		<TELL
"\"It is decided,\" says the professor. \"Three roads, and the river
between them.\"" CR>
		<RTRUE>)
	       (<NOT <AND ,BILL-READ ,MAP-READ>>
		<TELL
"\"Not yet, friend,\" says Van Helsing. \"First the paper, then the
map, and then I shall have something to be clever about.\"" CR>
		<RTRUE>)
	       (T
		<SETG RIVER-SOLVED T>
		<AWARD 5>
		<TELL
"Mina reads it out in the flat clear voice she uses for timetables, and
it is the finest piece of work anybody does in this whole affair." CR CR
"\"He must go by water, for he cannot cross running water of himself,
and he is in his box and helpless in the day. The Sereth is, at Fundu,
joined by the Bistritza, and the Bistritza runs up round the Borgo
Pass. The loop it makes is manifestly as close to Dracula's castle as
can be got by water. Therefore: the launch up the river, the horses by
the Bistritza road, and the carriage to the Borgo Pass -- and one of us
must go to the castle itself and do what is there to be done.\"" CR CR
"\"I go to the castle,\" says Van Helsing, \"and Madam Mina come with
me, for I dare not leave her, and I dare not take her, and of two
things I dare not I choose the one I can watch.\"" CR CR
"-- From the memorandum of Abraham Van Helsing. --" CR CR
"The launch went up the river; Godalming and Jonathan on it. Morris and
Seward rode the bank. I took Madam Mina by carriage, up and up into the
snow, and on the fifth of November, near sunset, I made a camp in a
hollow of the rock below the castle, and I am afraid, and it is a long
time since I was afraid." CR CR>
		<GO-TO-CAMP>)>>

<ROUTINE GO-TO-CAMP ()
	 <BANK-ALL>
	 <MOVE ,VAN-HELSING ,BANK>
	 <MOVE ,JONATHAN ,BANK>
	 <MOVE ,MINA ,CAMP>
	 <MOVE ,WAFER ,WINNER>
	 <MOVE ,CRUCIFIX ,WINNER>
	 <MOVE ,GARLIC ,WINNER>
	 <MOVE ,WOOD-STAKE ,WINNER>
	 <MOVE ,HAMMER ,WINNER>
	 <MOVE ,WINCHESTER ,WINNER>
	 <MOVE ,KUKRI ,WINNER>
	 <MOVE ,WOLF-COAT ,WINNER>
	 ;"The vault below the chapel is a DARK ROOM in every act."
	 <MOVE ,ELECTRIC-LAMP ,WINNER>
	 <FSET ,ELECTRIC-LAMP ,ONBIT>
	 <SETG HERE ,CAMP>
	 <MOVE ,WINNER ,HERE>
	 <SETG LIT T>
	 <V-FIRST-LOOK>>

"====================================================================
THE CAMP AND THE HOLY CIRCLE"

<ROUTINE CAMP-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<TELL
"A hollow in the rock like a doorway between two boulders. Snow
flurries walk the dark like women in trailing garments. Far above, the
castle cuts its jagged line against the sky; the road up to it climbs
from here.">
		<COND (,CIRCLE-DRAWN
		       <TELL CR
"A ring is drawn in the snow about the fire, and Madam Mina sits inside
it.">)
		      (T
		       <TELL CR
"Madam Mina sits by the fire, too quiet, and does not feel the cold.">)>
		<TELL CR>
		<RTRUE>)
	       (<EQUAL? .RARG ,M-BEG>
		<COND (<AND <VERB? WAIT SLEEP>>
		       <CAMP-ADVANCE>
		       <RTRUE>)
		      (<AND <EQUAL? ,CAMP-DUSK 2> <NOT ,IN-CIRCLE>
			    <NOT <VERB? LOOK EXAMINE SCORE ENTER WALK>>>
		       <OUTSIDE-CIRCLE-WARN>
		       <RTRUE>)>
		<RFALSE>)
	       (<EQUAL? .RARG ,M-END>
		<COND (<AND <EQUAL? ,CAMP-DUSK 2> <NOT ,IN-CIRCLE>>
		       <OUTSIDE-CIRCLE-DEATH>)>
		<RFALSE>)>
	 <RFALSE>>

<ROUTINE CAMP-ADVANCE ()
	 <COND (<EQUAL? ,CAMP-DUSK 0>
		<SETG CAMP-DUSK 1>
		<TELL CR
"The sun goes down behind the ranges and the cold comes up out of the
rock like water filling a cellar. Madam Mina shivers, and it is not the
cold: she is strange and quiet, and her eyes have gone somewhere I
cannot follow. Mem.: before dark. Whatever is to be done, before dark."
CR>)
	       (<EQUAL? ,CAMP-DUSK 1>
		<SETG CAMP-DUSK 2>
		<COND (<NOT ,CIRCLE-DRAWN>
		       <PANIC-CIRCLE>)
		      (T
		       <SETG IN-CIRCLE T>)>
		<CIRCLE-NIGHT>)
	       (<EQUAL? ,CAMP-DUSK 2>
		<CIRCLE-MORNING>)
	       (T
		<TELL
"The morning is here and the work is above. There is nothing to wait
for now but the sun, and the sun is not on our side today." CR>)>>

<ROUTINE HOLY-CIRCLE-FCN ()
	 <COND (<VERB? DRAWRING MAKE>
		<DRAW-THE-CIRCLE>
		<RTRUE>)
	       (<AND <VERB? PUT PUT-ON>
		     <EQUAL? ,PRSO ,WAFER>>
		<DRAW-THE-CIRCLE>
		<RTRUE>)
	       (<VERB? ENTER BOARD CLIMB-ON THROUGH>
		<COND (<NOT ,CIRCLE-DRAWN>
		       <TELL "There is no circle yet." CR>)
		      (T
		       <SETG IN-CIRCLE T>
		       <TELL
"You step over the ring and sit down by Madam Mina, and the snow
outside it goes on falling in a perfectly ordinary way." CR>)>
		<RTRUE>)
	       ;"Leaving is the one fatal act at the camp, so it needs a
	       phrasing of its own; the warnings have already fired twice
	       by the time anybody types this."
	       (<VERB? EXIT DISEMBARK DROP>
		<COND (<NOT ,CIRCLE-DRAWN>
		       <TELL "You are not in any circle." CR>)
		      (<EQUAL? ,CAMP-DUSK 2>
		       <SETG IN-CIRCLE <>>
		       <OUTSIDE-CIRCLE-DEATH>)
		      (T
		       <SETG IN-CIRCLE <>>
		       <TELL
"You step out of the ring into ordinary snow. It is still daylight, and
that is the only reason this is a harmless thing to do." CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<COND (,CIRCLE-DRAWN
		       <TELL
"A ring trodden in the snow, and over the ring, crumbled fine, the
Wafer. It is a foot wide and nothing at all, and it is the strongest
wall in this country." CR>)
		      (T
		       <TELL
"There is no circle. There is snow, and a fire, and a woman who is
half something else, and about two hours of daylight." CR>)>
		<RTRUE>)>>

<ROUTINE DRAW-THE-CIRCLE ()
	 <COND (,CIRCLE-DRAWN
		<TELL "The ring is drawn and the Wafer is on it." CR>
		<RTRUE>)
	       (T
		<SETG CIRCLE-DRAWN T>
		<SETG IN-CIRCLE T>
		<COND (<L? ,CAMP-DUSK 2>
		       <AWARD 3>)>
		<TELL
"I took of the Wafer, and crumbled it fine, and I drew a ring round
Madam Mina in the snow, wide enough for the fire and the two of us, and
over the ring I passed the crumbs of the Host, and said what one says."
CR CR
"Then the test, which I hated. \"Come to me, Madam Mina,\" I said, and
held out my hands." CR CR
"She rose, and took one step, and stood as one stricken. \"I cannot,\"
she said, and put her hands to her face. And I rejoiced -- God forgive
me, I rejoiced -- for what she could not do, none of those we dread
could do either. She is inside the ring, and the ring holds both ways,
and that is the whole of my comfort tonight." CR>
		<SETG CIRCLE-TESTED T>)>>

<ROUTINE PANIC-CIRCLE ()
	 <SETG CIRCLE-DRAWN T>
	 <SETG IN-CIRCLE T>
	 <SETG CIRCLE-TESTED T>
	 <AWARD -5>
	 <TELL CR
"The dark comes down all at once, the way it does in mountains, and
something laughs in the snow not forty yards off -- and I am on my
knees in the snow like an old fool with the envelope torn open,
crumbling the Wafer and dragging the ring round us both with my heel
and my hands, and finishing it with the shapes already standing at the
edge of the firelight, watching me work. It is done. It is badly done,
and it is done." CR>>

<ROUTINE CIRCLE-NIGHT ()
	 <MOVE ,BRIDES ,CAMP>
	 <FCLEAR ,BRIDES ,NDESCBIT>
	 <PUTP ,BRIDES ,P?LDESC
"Outside the ring, in the whirling snow, three women wait.">
	 <TELL CR
"They come with the snow, and at first they are only the snow: whirling
figures of mist and dust that resolve, if you look too long, into three
women. Two dark, one fair, and I know them from a young man's journal
which I have read until I dream it." CR CR
"They call to her in a voice like the tingling of glasses played on by
a cunning hand. \"Come, sister. Come to us. Come! Come!\" And Madam
Mina, inside the ring, weeps, and does not move, and holds my hand hard
enough to hurt. The horses scream in the dark, and after a while they
stop." CR>>

<ROUTINE OUTSIDE-CIRCLE-WARN ()
	 <SETG CIRCLE-WARNED <+ ,CIRCLE-WARNED 1>>
	 <COND (<EQUAL? ,CIRCLE-WARNED 1>
		<TELL
"Madam Mina's hand closes on your sleeve. \"Not out of the ring,\" she
says. \"Whatever you hear. Whatever they say to me.\"" CR>)
	       (T
		<TELL
"Outside the ring the snow-shapes sharpen, and turn their faces toward
you, gladly, and stop pretending to be snow. Stay inside the ring."
CR>)>>

<ROUTINE OUTSIDE-CIRCLE-DEATH ()
	 <JIGS-UP
"You step over the ring, and the snow is on you before your foot is
down, and the last thing the memorandum records is that they were
laughing, and that one of them had a fair face, and that it was very
cold and then not cold at all.">>

<ROUTINE CIRCLE-MORNING ()
	 <SETG CAMP-DUSK 3>
	 <SETG IN-CIRCLE <>>
	 <MOVE ,BRIDES ,BANK>
	 ;"Dress the castle for Act III: the boxes are gone to England and
	 the tombs, invisible until now, are what is left down there."
	 <FCLEAR ,GREAT-TOMB ,INVISIBLE>
	 <FCLEAR ,SISTER-TOMBS ,INVISIBLE>
	 <MOVE ,CASTLE-BOXES ,BANK>
	 <MOVE ,GREAT-BOX ,BANK>
	 <TELL CR
"Morning, the sixth of November, and a red sun coming up over the snow
with a bad grace. The three of them are gone from the ring's edge as
the light comes, going up toward the castle like blown paper." CR CR
"The horses are dead. All of them, and no mark on them, and the snow
about them not much trodden. Well. We do not need horses to go up, only
to come down, and I am not certain we shall be coming down." CR>>

<ROUTINE HORSES-FCN ()
	 <COND (<VERB? EXAMINE>
		<COND (<G? ,CAMP-DUSK 2>
		       <TELL
"Dead in the traces, all of them, with no wound and no mark, and their
eyes open. Nothing ate them. Something drank from the whole night at
once." CR>)
		      (T
		       <TELL
"Four hired horses, blowing steam, and unhappy about the smell of this
place, which is a professional opinion I respect." CR>)>
		<RTRUE>)>>

<ROUTINE MINA-CAMP-TALK ()
	 <COND (<EQUAL? ,CAMP-DUSK 3>
		<TELL
"\"Go up,\" she says. \"I shall be here in the ring, and I shall be
quite safe, and if I am not, you will know what to do, and I have your
promise that you will do it.\"" CR>)
	       (,CIRCLE-DRAWN
		<TELL
"\"I cannot come out,\" she says, with the scar showing red on her
white forehead, \"and I have never in my life been so glad of anything.
Read to me. Anything. Read me the timetable.\"" CR>)
	       (T
		<TELL
"She is strange and quiet, and answers a little late, as though your
voice reached her from the other side of a door. \"There is something
up there,\" she says, \"that is glad we came.\"" CR>)>>

<ROUTINE CAMP-UP ()
	 <COND (<EQUAL? ,CAMP-DUSK 3> <RETURN ,COURTYARD>)
	       (<EQUAL? ,CAMP-DUSK 2>
		<TELL
"Not in the dark. Not up that road, not tonight, not for anything." CR>
		<RFALSE>)
	       (T
		<TELL
"The work up there is day-work, and there is not day enough left. To
morning, then, and the ring first." CR>
		<RFALSE>)>>

"====================================================================
THE CASTLE PURGED"

<ROUTINE BREAK-THE-DOORS ()
	 <COND (,DOORS-BROKEN
		<TELL "The doors hang wide, and shall not close again." CR>
		<RTRUE>)
	       (<NOT <HELD? ,HAMMER>>
		<TELL
"Bare hands on those doors? There was a blacksmith's hammer bought at
Veresti for exactly this." CR>
		<RTRUE>)
	       (T
		<SETG DOORS-BROKEN T>
		<AWARD 2>
		<TELL
"I beat the great doors off their rusty hinges with the smith's hammer,
and threw them down, lest some ill-intent or ill-chance should close
them behind me and leave me shut in a place I could not get out of.
Bitter experience of another man's journal has taught me this." CR>)>>

<ROUTINE SEAL-THE-CASTLE ()
	 <COND (,CASTLE-SEALED
		<TELL "It is sealed. He has no home." CR>
		<RTRUE>)
	       (<NOT ,SISTERS-DEAD>
		<TELL
"Not yet. There are three sleepers below who would wake in a sealed
house and be sealed in it with me." CR>
		<RTRUE>)
	       (<NOT ,TOMB-WAFERED>
		<TELL
"The great tomb first. Seal the house with his own earth still sweet to
him and I have done nothing but lock a door he has the key of." CR>
		<RTRUE>)
	       (T
		<SETG CASTLE-SEALED T>
		<AWARD 5>
		<TELL
"Then I went about the castle, and to every door and every window and
every crack of the entrances I put the crumbs of the Host, and sealed
them, so that never more can the Count enter there, Un-Dead. And when
the last one was done I stood in the courtyard in the snow and found
that my hands were shaking and had been for some time." CR CR
"Far below, on the road out of the pass, there is a black speck moving
fast, and behind it other specks, and the sun is going down the sky
much too quickly for the fifth hour of the afternoon." CR CR
"-- From the journal of Jonathan Harker, the sixth of November. --" CR CR>
		<GO-TO-ROAD>)>>

<ROUTINE WOOD-STAKE-THE-SISTERS ()
	 <COND (,SISTERS-DEAD
		<TELL
"Three handfuls of dust, and nothing more to do for them but be glad."
CR>
		<RTRUE>)
	       (<NOT <HELD? ,WOOD-STAKE>>
		<TELL
"With what? This is not work for hands." CR>
		<RTRUE>)
	       (<AND <NOT ,TOMB-WAFERED> <L? ,FASCINATION 2>>
		<FASCINATION-TRAP>
		<RTRUE>)
	       (T
		<SETG SISTERS-DEAD T>
		<AWARD 6>
		<TELL
"It was butcher work; had I not been upheld by thoughts of other dead,
and of the living over whom hung such a pall of fear, I could not have
gone on. I tremble and tremble even yet, though till all was over, God
be thanked, my nerve did stand." CR CR
"And then the wonderful thing: in the very moment of the stroke, before
the dust took them, each face was such a face as I could look on
without loathing -- a look of gladness, of peace, of a thing let out
of a trap. Then they crumbled into their native dust, as though the
death that should have come centuries ago had at last had its way."
CR>)>>

<ROUTINE FASCINATION-TRAP ()
	 <SETG FASCINATION <+ ,FASCINATION 1>>
	 <COND (<EQUAL? ,FASCINATION 1>
		<TELL
"I raised the stake over the fair one -- and she was so radiantly
beautiful, so exquisitely voluptuous, that the very instinct of man in
me, which calls some of my sex to love and to protect one of hers, made
my head whirl with new emotion. I shuddered as though I had come to do
murder, and a yearning for delay clogged my very soul, and my hands
would not come down." CR>)
	       (T
		<SETG FASCINATION 2>
		<AWARD -2>
		<TELL
"I stood there with the stake in my hands like a man in a dream, and
how long I do not know -- and then from far below, out of the camp, came
Madam Mina's voice crying my name in a wail of fear, and it went
through the horrid spell like a knife. I am an old fool, and I nearly
lay down in a tomb because a dead thing was pretty. The soul that is
put in a body by God is not to be sold for a face. Now. To work." CR CR
"Do the great tomb first, old man, as your own memorandum says." CR>)>>

"====================================================================
THE FROZEN ROAD"

<ROUTINE GO-TO-ROAD ()
	 <BANK-ALL>
	 <MOVE ,KUKRI ,WINNER>
	 <MOVE ,WINCHESTER ,WINNER>
	 <MOVE ,CRUCIFIX ,WINNER>
	 <MOVE ,DRACULA ,FROZEN-ROAD>
	 <FSET ,DRACULA ,NDESCBIT>
	 <MOVE ,SZGANY ,FROZEN-ROAD>
	 <FCLEAR ,SZGANY ,NDESCBIT>
	 <PUTP ,SZGANY ,P?LDESC
"The Szgany ring the cart, forty of them, with knives out.">
	 <SETG SUN 0>
	 <SETG ACT 5>
	 <TELL
"You are Jonathan Harker, and you have ridden this road all day with a
horse under you that is finished, and the sun is going down." CR CR>
	 <SETG HERE ,FROZEN-ROAD>
	 <MOVE ,WINNER ,HERE>
	 <SETG LIT T>
	 <V-FIRST-LOOK>
	 <TELL CR
"Then Morris and Seward come up out of the river-road at the gallop, one
on each flank, and Godalming behind you, and the Winchesters come down
level across four saddles. Twice you shout Halt, and the leader of the
Szgany points his whip at the sun and then at the castle above, and
says something in his own tongue, and every man of them puts a hand to
his knife." CR>>

<ROUTINE FROZEN-ROAD-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<COND (,LID-OFF
		       <TELL
"The wagon stands broadside in the road, and the great box lies where it
was flung, its lid thrown back. The gypsies are a ring of knives, and
the wolves are coming up the snow behind them.">)
		      (,BOX-DOWN
		       <TELL
"The wagon stands broadside in the road, and the great box lies in the
snow where it was flung, still shut. The gypsies press in with knives;
Morris is on his feet among them.">)
		      (T
		       <TELL
"The last light lies red on the snow. The leiter-wagon stands in the
road with the Szgany about it like a river round a stone, and on the
cart is a great square chest.">)>
		<TELL CR>
		<ROAD-SUN-REPORT>
		<RTRUE>)
	       (<EQUAL? .RARG ,M-END>
		<COND (<NOT ,ENDED> <ROAD-TICK>)>
		<RFALSE>)>
	 <RFALSE>>

<ROUTINE ROAD-SUN-REPORT ()
	 <COND (<L? ,SUN 2>
		<TELL
"The sun stands a hand's-breadth above the peaks." CR>)
	       (<L? ,SUN 4>
		<TELL
"The sun is down to a finger's-breadth above the peaks." CR>)
	       (<L? ,SUN 6>
		<TELL "The rim of the sun touches the peaks." CR>)
	       (<L? ,SUN 8>
		<TELL "Half the sun is gone behind the mountain." CR>)
	       (T
		<TELL "There is a red line on the snow and nothing above it."
CR>)>>

<ROUTINE ROAD-TICK ()
	 <SETG SUN <+ ,SUN 1>>
	 <COND (<G? ,SUN 8>
		<SUNSET-FAILURE>
		<RTRUE>)>
	 <COND (<EQUAL? ,SUN 4>
		<TELL CR
"\"The box, Jonathan!\" Van Helsing is not here to shout it, so Morris
shouts it for him, from somewhere inside the press of knives. \"Get the
box down!\"" CR>)
	       (<EQUAL? ,SUN 6>
		<TELL CR
"Godalming's voice, cracking: \"The sun, man! Look at the sun!\"" CR>)
	       (<EQUAL? ,SUN 7>
		<TELL CR
"There is a hand's-breadth of daylight left in the whole world and it is
going out along the snow toward you like a tide." CR>)>>

<ROUTINE ROAD-WAGON-FCN ()
	 <COND (<VERB? STOPOBJ ATTACK SIMPLE-KILL BOARD CLIMB-ON THROUGH
		       TAKE MOVE PUSH>
		<CHARGE-THE-WAGON>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A leiter-wagon with its team half dead, and on it one great square
chest of earth, roped down, with the daylight running off the snow
about it." CR>
		<RTRUE>)>>

<ROUTINE WAGON-FCN ()
	 <ROAD-WAGON-FCN>>

<ROUTINE CHARGE-THE-WAGON ()
	 <COND (,BOX-DOWN
		<TELL "The box is down. The lid is the thing now." CR>
		<RTRUE>)
	       (T
		<SETG BOX-DOWN T>
		<SETG SZGANY-CHARGED T>
		<AWARD 5>
		<MOVE ,GREAT-BOX ,FROZEN-ROAD>
		<FCLEAR ,GREAT-BOX ,NDESCBIT>
		<PUTP ,GREAT-BOX ,P?LDESC
"The great box lies in the trodden snow.">
		<TELL
"You do not remember deciding. You are off the horse and through the
gypsies and up on the cart, and with a strength that seems to belong to
somebody else you get your hands under the great box and heave it over
the wheel, and it goes down into the snow with a sound like a door
closing in an empty house." CR CR
"The Szgany come at you with their knives, and Morris comes through
them from the other side to reach the box, and does not stop when they
cut him. There is blood on the snow and some of it is his; he has his
hand pressed to his side and it is coming through his fingers, and he
gets to the box anyway." CR>
		<SETG QUINCEY-HIT T>)>>

<ROUTINE ROAD-BOX-FCN ()
	 <COND (<VERB? OPEN THROUGH LOOK-INSIDE>
		<OPEN-THE-BOX>
		<RTRUE>)
	       (<AND <VERB? ATTACK SIMPLE-KILL STAKEV CUT> <NOT ,LID-OFF>>
		<OPEN-THE-BOX>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<COND (,LID-OFF
		       <TELL
"The lid is thrown back, and in the box, on his earth, lies the Count,
waxen and red-eyed, and looking at the sun." CR>)
		      (,BOX-DOWN
		       <TELL
"A great square chest of earth in the snow, nailed down. The nails are
new and the wood is soft." CR>)
		      (T
		       <TELL
"The chest is roped to the cart, and the cart is going up the road, and
it will be at the castle gate by dark." CR>)>
		<RTRUE>)>>

<ROUTINE OPEN-THE-BOX ()
	 <COND (,LID-OFF
		<TELL
"The lid is off, and he is looking at the sun, and there is one thing
left to do." CR>
		<RTRUE>)
	       (<NOT ,BOX-DOWN>
		<TELL
"Not while it is on the cart, and the cart is moving, and forty men are
between you and it." CR>
		<RTRUE>)
	       (T
		<SETG LID-OFF T>
		<AWARD 5>
		<MOVE ,DRACULA ,FROZEN-ROAD>
		<FCLEAR ,DRACULA ,NDESCBIT>
		<PUTP ,DRACULA ,P?LDESC
"In the box, on the earth, the Count lies looking at the sun.">
		<FCLEAR ,THROAT ,INVISIBLE>
		<TELL
"You get the point of the great kukri under the lid and throw your
weight on it, and the nails draw with a quick screeching sound, and the
lid is thrown back." CR CR
"He lies on the earth, the box half full of it: waxen-pale, deathly, the
red eyes open, with that horrible vindictive look you know so well. And
as you look, the eyes see the sinking sun, and the hate in them turns to
triumph." CR>)>>

<ROUTINE ROAD-DRACULA-FCN ()
	 <COND (<VERB? EXAMINE>
		<COND (,LID-OFF
		       <TELL
"The Count in his box in the snow: waxen, gorged, the white hair and
moustache stained, the mouth red, the scar of an old shovel-blow white
above the brows. He is looking at the sun, and counting." CR>)
		      (T
		       <TELL
"He is in the box, and the box is nailed, and that is the only good
news on this road." CR>)>
		<RTRUE>)
	       (<VERB? ATTACK SIMPLE-KILL STAB MUNG CUT STAKEV>
		<THE-KILL>
		<RTRUE>)
	       (<VERB? SHOW>
		<TELL
"Not now. Not with the sun going. Steel is the argument left." CR>
		<RTRUE>)
	       (<VERB? TELL HELLO TELL>
		<TELL
"The look in the eyes says everything it has to say, and it says it in
the future tense." CR>
		<RTRUE>)>>

<ROUTINE THROAT-FCN ()
	 <COND (<VERB? ATTACK SIMPLE-KILL STAB CUT MUNG TAKE>
		<THE-KILL>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"The throat of the thing in the box, above the collar, white as candle
wax." CR>
		<RTRUE>)>>

<ROUTINE THE-KILL ()
	 <COND (<NOT ,LID-OFF>
		<TELL
"Through an inch of nailed deal? Get the lid off." CR>
		<RTRUE>)
	       (T
		<SETG ENDED T>
		<AWARD 25>
		<VICTORY>)>>

<ROUTINE ROAD-SZGANY-FCN ()
	 <COND (<VERB? ATTACK SIMPLE-KILL STOPOBJ>
		<COND (,BOX-DOWN
		       <TELL
"They are all round you and none of them matter. The box is the whole
world." CR>)
		      (T
		       <CHARGE-THE-WAGON>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"Forty Szgany about the cart, fearless, and without religion, and paid.
They will fight for the boyar until the sun is down, and the moment it
is down they will not need to." CR>
		<RTRUE>)
	       (<VERB? TELL HELLO YELL>
		<TELL
"You shout Halt in three languages. The leader points his whip at the
sun, and then at the castle, and laughs." CR>
		<RTRUE>)>>

<ROUTINE WINCHESTER-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"A Winchester repeating rifle, Morris's contribution to the theological
debate. He bought four and would not be argued with." CR>
		<RTRUE>)
	       (<VERB? ATTACK SIMPLE-KILL>
		<TELL
"There are four rifles levelled on this road already and not one of
them is going to fire in time. It is the box, and the knife, and the
sun." CR>
		<RTRUE>)>>

<ROUTINE VICTORY ()
	 <TELL CR
"The sweep and flash of the great kukri -- and Quincey's bowie driven
home in the same breath. Before your eyes, almost in the drawing of a
breath, the whole body crumbles into dust and passes from your sight."
CR CR
"In that moment of final dissolution there is in the face a look of
peace, such as you would never have believed could have rested there."
CR CR
"The sun goes behind the peaks. The Szgany turn and ride for their
lives, and the wolves stream after them into the dark, and the snow is
suddenly only snow." CR CR
"Quincey Morris is down in it, his hand pressed to his side, smiling.
Mina kneels by him and takes his head on her knee, and he looks up at
her forehead, and says: \"It was worth for this to die. Look! The snow
is not more stainless than her forehead! The curse has passed away!\"
And with a smile, and in silence, he dies, a gallant gentleman." CR CR
"Seven years after, you will bring a boy to this country: a boy with a
bundle of names that links our little band of men together, though we
call him Quincey. There is no proof of any of it -- only a mass of
typewriting, and the professor's word, standing with the boy on his
knee: \"We want no proofs; we ask none to believe us.\"" CR CR>
	 <TELL "*** You have won ***" CR CR>
	 <V-SCORE>
	 <FINISH>>

<ROUTINE SUNSET-FAILURE ()
	 <SETG ENDED T>
	 <TELL CR
"The rim of the sun touches the peaks -- and is gone." CR CR
"In the box the red eyes open, and the look of hate in them turns to
triumph. The lid is flung wide from within. What rises out of the
grave-earth does not trouble itself with the men and their rifles; it
looks past them all, to the woman standing where the holy circle used
to hold, and it smiles as a host smiles, welcoming a guest over a
threshold." CR CR
"Mina does not scream. That is the worst of it. She puts back her veil,
and her forehead is white, quite white, and her eyes are somebody
else's, and she says, in a voice like the tingling of glasses played on
by a cunning hand: \"You yourself never loved; you never love.\"" CR CR
"Snow covers the wagon, the road, the year. In the spring the peasants
of the pass will nail wild roses over every door, and name three women
walking in the dusk -- and a fourth, new, fair, whom none of them
know." CR CR>
	 <TELL "*** The sun set ***" CR CR>
	 <V-SCORE>
	 <FINISH>>

"---- The ports, so the chase's place-names are speakable ----"

<ROUTINE PORT-G-FCN ()
	 <COND (<VERB? EXAMINE TELL>
		<COND (<EQUAL? ,HERE ,VARNA-HOTEL>
		       <TELL
"Varna, on the Black Sea, where the Czarina Catherine was to make port
and did not. There is nothing to do in Varna but wait for a wire, and
that is precisely what he counted on." CR>)
		      (<EQUAL? ,HERE ,GALATZ-WHARF>
		       <TELL
"Galatz, a hundred miles up the coast from where you waited, with the
river going north out of it into his own country. He read the plan out
of Madam Mina's sleeping mind and landed where we were not." CR>)
		      (T
		       <TELL
"Varna and Galatz are behind you now, and the river after them, and
what is left is this road and the sun going down it." CR>)>
		<RTRUE>)
	       (<VERB? WALK-TO FOLLOW>
		<TELL
"Not on your own feet. This part of the chase is done by telegram, by
train, and by launch." CR>
		<RTRUE>)>>
