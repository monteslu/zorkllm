"CACT3 - The Count of Monte Cristo, ACT THREE: the island, the coffer,
Caderousse's confession, and the saving of M. Morrel."

"=== Identity: the three coats ==="

;"Costumes are mutually exclusive. The engine has no worn state - WEARBIT
 only changes a message - so a costume the player is not currently in has
 to leave their hands, or INVENTORY reports a man wearing a cassock, a
 drab coat and a sailor's jacket at once. They go back to the baggage,
 not out of the game: WEAR COAT still has to find one."
<ROUTINE DOFF-ALL ()
	 <COND (<IN? ,CASSOCK ,WINNER> <MOVE ,CASSOCK ,COSTUME-BAG>)>
	 <COND (<IN? ,WIG ,WINNER> <MOVE ,WIG ,COSTUME-BAG>)>
	 <COND (<IN? ,ENGLISH-COAT ,WINNER> <MOVE ,ENGLISH-COAT ,COSTUME-BAG>)>
	 <COND (<IN? ,SAILOR-JACKET ,WINNER>
		<MOVE ,SAILOR-JACKET ,COSTUME-BAG>)>
	 <RTRUE>>

<ROUTINE SET-IDENTITY (N)
	 <SETG IDENTITY .N>
	 <DOFF-ALL>
	 <COND (<EQUAL? .N 1>
		<MOVE ,CASSOCK ,WINNER>
		<MOVE ,WIG ,WINNER>
		<FCLEAR ,WIG ,NDESCBIT>
		<TELL
"The cassock, the gray tonsure, the stoop, and the Italian of a Roman
seminary. You are the Abbe Busoni, and men tell priests what they tell
no one living." CR>)
	       (<EQUAL? .N 2>
		<MOVE ,ENGLISH-COAT ,WINNER>
		<TELL
"The drab coat, the flat vowels, the small unfriendly smile of a
Northern man with a ledger. You are Lord Wilmore, agent of the house of
Thomson and French." CR>)
	       (<EQUAL? .N 4>
		<MOVE ,SAILOR-JACKET ,WINNER>
		<FCLEAR ,SAILOR-JACKET ,NDESCBIT>
		<TELL
"A sailor's jacket, a sailor's hat, and your hair fallen loose out of
it. Twenty-three years old in the glass, for about a second." CR>)
	       (T
		<TELL "You are the Count of Monte Cristo again, which is to
say nobody at all." CR>)>
	 <RTRUE>>

<ROUTINE CASSOCK-FCN ()
	 <COND (<VERB? WEAR>
		<COND (<EQUAL? ,IDENTITY 1>
		       <TELL "You are wearing it." CR>)
		      (T <SET-IDENTITY 1>)>
		<RTRUE>)
	       (<AND <VERB? TAKE> <NOT <IN? ,CASSOCK ,WINNER>>> <RFALSE>)>>

<ROUTINE WIG-FCN ()
	 <COND (<VERB? TAKE MOVE>
		;"REMOVE is a TAKE synonym in this engine, so REMOVE WIG
		 arrives here as a take of a thing already in hand: that is
		 the unmasking."
		<COND (<AND <EQUAL? ,IDENTITY 1> <IN? ,WIG ,WINNER>>
		       <DOFF-THE-WIG>
		       <RTRUE>)>
		<RFALSE>)
	       (<VERB? WEAR>
		<COND (<EQUAL? ,IDENTITY 1> <TELL "You are wearing it." CR>)
		      (T <SET-IDENTITY 1>)>
		<RTRUE>)>>

<ROUTINE DOFF-THE-WIG ()
	 <COND (<NOT <EQUAL? ,IDENTITY 1>>
		<TELL "You are not wearing the abbe's face." CR>
		<RTRUE>)>
	 <REMOVE ,WIG>
	 <REMOVE ,CASSOCK>
	 <SETG IDENTITY 4>
	 <THE-COUNT-UNMASKS>
	 <RTRUE>>

<ROUTINE THE-COUNT-UNMASKS ()
	 <COND (<AND ,CAD-DYING <NOT ,CAD-DEAD>>
		<CADEROUSSE-DEATHBED>)
	       (<AND <EQUAL? ,HERE ,NOIRTIER-ROOM> ,ASSIZES-DONE>
		<VILLEFORT-UNMASKED>)
	       (T
		<TELL
"You take off the gray wig and stand as yourself, and nobody in this
room is the right person to see it. You put it back on." CR>
		<SET-IDENTITY 1>)>
	 <RTRUE>>

<ROUTINE ENGLISH-COAT-FCN ()
	 <COND (<VERB? WEAR>
		<COND (<EQUAL? ,IDENTITY 2>
		       <TELL "You are wearing it." CR>)
		      (T <SET-IDENTITY 2>)>
		<RTRUE>)>>

<ROUTINE SAILOR-JACKET-FCN ()
	 <COND (<VERB? WEAR>
		<COND (<AND ,SALON-SCENE
			    <EQUAL? ,HERE ,SALON ,CSTUDY>>
		       <MORCERF-REVEAL>
		       <RTRUE>)>
		<SET-IDENTITY 4>
		<RTRUE>)>>

"=== The island ==="

<ROUTINE ROCKS-FCN ()
	 <COND (<VERB? COUNT>
		<COUNT-THE-ROCKS>
		<RTRUE>)
	       (<VERB? EXAMINE SEARCH>
		<COND (<EQUAL? ,HERE ,CLEARING>
		       <TELL
"The notches end here, at the circular boulder. Whoever cut them meant
somebody to arrive." CR>)
		      (T
		       <TELL
"Old notches cut in the rock at the waterline and marching away east in
a right line, weathered but unmistakable, and older than anyone on this
island has been alive." CR>)>
		<RTRUE>)>>

<ROUTINE COUNT-THE-ROCKS ()
	 <COND (<NOT <EQUAL? ,HERE ,CLEARING>>
		<TELL
"You can count them where they end, not where they start. Follow them
east." CR>)
	       (,ROCKS-COUNTED
		<TELL "Twenty. It was twenty the first time too." CR>)
	       (T
		<SETG ROCKS-COUNTED T>
		<ADD-SCORE 5>
		<TELL
"From the creek, east in a right line: eighteen, nineteen, twenty." CR CR
"The twentieth rock is no rock. It is a door with moss for manners."
CR>)>>

<ROUTINE CLEARING-FCN (RARG)
	 <COND (<AND <EQUAL? .RARG ,M-ENTER> <NOT ,SUPPLIES-LEFT>>
		<SETG SUPPLIES-LEFT T>
		<MOVE ,PICKAXE ,CLEARING>
		<MOVE ,POWDER-HORN ,CLEARING>
		<MOVE ,SUPPLIES ,CLEARING>
		<FCLEAR ,PICKAXE ,NDESCBIT>
		<FCLEAR ,POWDER-HORN ,NDESCBIT>
		<TELL
"You went over the side among the rocks this morning and lay very still
until they were sure you had cracked your skull. Jacopo wanted to carry
you back aboard on his own shoulders; you had to be sharp with him to
be left." CR CR
"The Jeune-Amelie is a sail on the horizon now. On the moss beside you,
Jacopo has left a pickaxe, a powder horn, a gun, biscuits and rum, out
of his own share." CR CR>
		<RFALSE>)
	       (T <RFALSE>)>>

<ROUTINE CLEARING-DOWN ()
	 <COND (,GROTTO-OPEN ,GROTTO1)
	       (,BOULDER-GONE
		<TELL "The flagstone is bare and shut. It has a ring." CR>
		<RFALSE>)
	       (T
		<TELL "There is nothing under you but the island." CR>
		<RFALSE>)>>

<ROUTINE BOULDER-FCN ()
	 <COND (<VERB? EXAMINE>
		<COND (,BOULDER-GONE
		       <TELL "It is in the sea. You watched it go." CR>)
		      (,ROCKS-COUNTED
		       <TELL
"It rests on a made bed: a wedge stone, packed flints, old masonry
playing at geology. Nature does not lay courses." CR>)
		      (T
		       <TELL
"A circular boulder as big as a cottage, squatting on a bed of smaller
stones. It has sat here since the Flood, if you believe the moss." CR>)>
		<RTRUE>)
	       (<VERB? MOVE TURN TAKE PUSH RAISE>
		<PRY-THE-BOULDER>
		<RTRUE>)>>

<ROUTINE PRY-THE-BOULDER ()
	 <COND (,BOULDER-GONE
		<TELL "There is nothing left to lever." CR>)
	       (<NOT <IN? ,BRANCH ,WINNER>>
		<TELL
"You get your shoulder to it and it does not notice. You want a lever
long enough to be a joke." CR>)
	       (T
		<TELL
"You set the olive bough under the lip and throw your whole weight on
it. The boulder stirs, and settles." CR CR
"Too heavy for any one man, were he Hercules himself. It will want
something quicker than muscle." CR>)>>

<ROUTINE WEDGE-FCN ()
	 <COND (<AND <VERB? DIG MUNG MOVE> <EQUAL? ,PRSI ,PICKAXE>>
		<DIG-THE-WEDGE>
		<RTRUE>)
	       (<VERB? DIG>
		<COND (<IN? ,PICKAXE ,WINNER> <DIG-THE-WEDGE>)
		      (T <TELL "Not with your hands. There is a pickaxe on
the moss." CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A single wedge stone under the boulder's lip, with packed flints
around it. Pull that tooth and the whole jaw goes." CR>
		<RTRUE>)>>

<ROUTINE DIG-THE-WEDGE ()
	 <COND (,BOULDER-GONE
		<TELL "That work is finished." CR>)
	       (,WEDGE-DUG
		<TELL "The hole under the wedge is dug and waiting." CR>)
	       (<NOT <IN? ,PICKAXE ,WINNER>>
		<TELL "You would need the pickaxe." CR>)
	       (T
		<SETG WEDGE-DUG T>
		<MOVE ,BLAST-HOLE ,CLEARING>
		<TELL
"Ten minutes' work with the pickaxe opens a hole under the wedge big
enough for your arm." CR>)>>

<ROUTINE OLIVE-TREE-FCN ()
	 <COND (<VERB? CUT MUNG>
		<COND (<IN? ,BRANCH ,WINNER>
		       <TELL "You have a bough already." CR>)
		      (T
		       <MOVE ,BRANCH ,WINNER>
		       <TELL
"You cut and strip the strongest olive bough on the island: eight feet
of stubborn wood." CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL "A wild olive bent double by forty winters of mistral.
Its boughs are iron." CR>
		<RTRUE>)>>

<ROUTINE BLAST-HOLE-FCN ()
	 <COND (<AND <VERB? PUT> <EQUAL? ,PRSO ,POWDER-HORN>>
		<PACK-THE-POWDER>
		<RTRUE>)
	       (<VERB? EXAMINE LOOK-INSIDE>
		<COND (,POWDER-SET
		       <TELL "Packed with powder, with a twist of handkerchief
for a slow-match." CR>)
		      (T
		       <TELL "A hole under the wedge stone, a foot deep and
empty." CR>)>
		<RTRUE>)>>

<ROUTINE PACK-THE-POWDER ()
	 <COND (,POWDER-SET
		<TELL "The charge is laid." CR>)
	       (<NOT ,WEDGE-DUG>
		<TELL "There is nowhere to put it yet." CR>)
	       (<NOT <IN? ,POWDER-HORN ,WINNER>>
		<TELL "You would need the horn." CR>)
	       (T
		<SETG POWDER-SET T>
		<MOVE ,FUSE ,CLEARING>
		<TELL
"You pack the horn's powder deep under the wedge and roll your
handkerchief into a slow-match." CR>)>>

<ROUTINE FUSE-FCN ()
	 <COND (<VERB? BURN LAMP-ON>
		<LIGHT-THE-FUSE>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL "A twist of handkerchief, dusted with powder, lying in
the mouth of the hole." CR>
		<RTRUE>)>>

<ROUTINE LIGHT-THE-FUSE ()
	 <COND (,BOULDER-GONE
		<TELL "There is nothing left to blow up." CR>)
	       (<NOT ,POWDER-SET>
		<TELL "There is no charge to light." CR>)
	       (T
		<SETG BOULDER-GONE T>
		<REMOVE ,FUSE>
		<REMOVE ,BOULDER>
		<REMOVE ,WEDGE>
		<REMOVE ,BLAST-HOLE>
		<MOVE ,IRON-RING ,CLEARING>
		<MOVE ,FLAGSTONE ,CLEARING>
		<TELL
"You touch fire to the match with the horn's flint and walk, not run,
behind the tallest rock." CR CR
"The island answers. The wedge is gravel; the boulder tips, rolls,
bounds twice, and buries itself in the sea below with a noise like a
door closing on three hundred years." CR CR
"Where it sat, a square flagstone with an iron ring in it." CR>)>>

<ROUTINE IRON-RING-FCN ()
	 <COND (<VERB? MOVE TAKE TURN RAISE OPEN>
		<COND (,GROTTO-OPEN
		       <TELL "The stair is open." CR>)
		      (T
		       <SETG GROTTO-OPEN T>
		       <ADD-SCORE 10>
		       <TELL
"The flagstone rises on the ring, easily, on a bevel cut by a mason
who was paid to be forgotten." CR CR
"Steps, going down into a blue-lit dark." CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL "An iron ring set in a square flagstone, and not one
day of rust on it that the sea did not put there." CR>
		<RTRUE>)>>

"=== The grottoes ==="

<ROUTINE GROTTO1-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<COND (<G? ,ACT 4> <GROTTO-FINALE-LOOK> <RTRUE>)>
		<RFALSE>)
	       (T <RFALSE>)>>

<ROUTINE GROTTO1-EAST ()
	 <COND (,COFFER-FOUND ,GROTTO2)
	       (,HOLLOW-FOUND
		<TELL
"The hollow angle is found; the stones behind the stucco are not
broken yet." CR>
		<RFALSE>)
	       (T
		<TELL
"Granite, and more granite, and somewhere in this glitter a second door
pretending to be a wall." CR>
		<RFALSE>)>>

<ROUTINE SOUND-GROTTO-WALL ()
	 <COND (,COFFER-FOUND
		<TELL "The wall is opened. Go east." CR>)
	       (<AND <EQUAL? ,PRSI ,PICKAXE> ,HOLLOW-FOUND>
		<BREAK-THE-STUCCO>)
	       (,HOLLOW-FOUND
		<TELL
"You have your hollow angle. Now it wants the pickaxe, not your
knuckles." CR>)
	       (T
		<SETG HOLLOW-FOUND T>
		<TELL
"You go along the wall with your knuckles: solid, solid, solid." CR CR
"And then, in the far angle, one part of the wall gives forth a hollow
and deeper echo." CR>)>
	 <RTRUE>>

<ROUTINE STUCCO-FCN ()
	 <COND (<VERB? MUNG ATTACK CUT DIG MOVE TURN>
		<BREAK-THE-STUCCO>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A patch of the wall with a faint sheen the granite does not have. Some
patient man painted stucco to imitate stone, three hundred years ago,
and it nearly worked." CR>
		<RTRUE>)>>

<ROUTINE BREAK-THE-STUCCO ()
	 <COND (,COFFER-FOUND
		<TELL "The way is open." CR>)
	       (<NOT <IN? ,PICKAXE ,WINNER>>
		<TELL "Your hands are not enough. The pickaxe." CR>)
	       (T
		<SETG COFFER-FOUND T>
		<ADD-SCORE 10>
		<TELL
"Stucco flakes fall away in sheets, painted to imitate granite.
Beneath it: dressed white stones, laid without mortar." CR CR
"Three blows and the first stone comes out, and then the rest are only
work. Beyond is a second grotto, lower and older." CR>)>>

<ROUTINE DIG-CORNER-FCN ()
	 <COND (<VERB? DIG MUNG MOVE>
		<DIG-THE-CORNER>
		<RTRUE>)
	       (<VERB? EXAMINE SEARCH>
		<TELL
"The farthest angle, at the left of the opening. The will's last word,
and the ground has been waiting under it since fourteen ninety-eight."
CR>
		<RTRUE>)>>

<ROUTINE DIG-THE-CORNER ()
	 <COND (,COFFER-OPEN
		<TELL "The coffer is open and the ground is empty." CR>)
	       (<IN? ,COFFER ,GROTTO2>
		<TELL "The coffer is out. Open it." CR>)
	       (<NOT <IN? ,PICKAXE ,WINNER>>
		<TELL "Two feet of packed earth, and no pickaxe in your
hand." CR>)
	       (T
		<MOVE ,COFFER ,GROTTO2>
		<FCLEAR ,COFFER ,NDESCBIT>
		<TELL
"Two feet down, at the fifth blow, the pickaxe rings on iron." CR CR
"Never did funeral knell produce a greater effect. You clear it with
your hands: an oaken coffer bound in steel, and on the lid, in silver,
a sword on an oval shield surmounted by a cardinal's hat." CR>)>>

<ROUTINE COFFER-FCN ()
	 <COND (<VERB? OPEN MUNG MOVE TURN>
		<OPEN-THE-COFFER>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"Oak, steel-banded, and the arms of the house of Spada on the lid.
A lock and two padlocks: faithful guardians, and three centuries late."
CR>
		<RTRUE>)>>

<ROUTINE OPEN-THE-COFFER ()
	 <COND (,COFFER-OPEN
		<TELL "It stands open, and you are still not used to it." CR>)
	       (<NOT <IN? ,PICKAXE ,WINNER>>
		<TELL
"A lock and two padlocks, faithful guardians. Fingers will not answer
them." CR>)
	       (T
		<SETG COFFER-OPEN T>
		<FSET ,COFFER ,OPENBIT>
		<FCLEAR ,TREASURE ,NDESCBIT>
		<TELL
"You set the pickaxe point under the hasp and the fastenings burst."
CR CR
"Gold coin in blazing piles; bars of unpolished gold; and diamonds,
pearls and rubies that fall through your fingers and sound like hail
against glass." CR>)>>

<ROUTINE TREASURE-FCN ()
	 <COND (<VERB? TAKE MOVE>
		<TAKE-THE-TREASURE>
		<RTRUE>)
	       (<VERB? EXAMINE COUNT>
		<TELL
"A thousand ingots, twenty-five thousand crowns of gold, and ten double
handfuls of stones. The arithmetic is not the point. The arithmetic is
never the point again." CR>
		<RTRUE>)>>

<ROUTINE TAKE-THE-TREASURE ()
	 <COND (,RICH
		<TELL "It is yours. All of it. Still." CR>)
	       (<NOT ,COFFER-OPEN>
		<TELL "The coffer is shut." CR>)
	       (T
		<SETG RICH T>
		<MOVE ,DIAMOND ,WINNER>
		<MOVE ,GEM ,WINNER>
		<ADD-SCORE 25>
		<TELL
"You are alone; alone with countless, unheard-of treasure." CR CR
"You kneel down on the floor of the second grotto and say something
that is intelligible to God alone. When you rise your voice is quite
steady. \"Now for Marseilles.\"" CR CR>
		<LEGHORN-INTERSTITIAL>)>>

<ROUTINE LEGHORN-INTERSTITIAL ()
	 <SETG ACT 3>
	 <MOVE ,COSTUME-BAG ,WINNER>
	 <MOVE ,CASSOCK ,COSTUME-BAG>
	 <MOVE ,WIG ,COSTUME-BAG>
	 <MOVE ,ENGLISH-COAT ,COSTUME-BAG>
	 <MOVE ,CADEROUSSE ,INN>
	 <MOVE ,MORREL ,OFFICE>
	 <MOVE ,RED-PURSE ,CUPBOARD>
	 <REMOVE ,FATHER>
	 ;"the 1829 rooms are the 1815 rooms with fourteen years on them;
	  clearing TOUCHBIT makes the engine print the new description
	  instead of skipping it as already seen"
	 <FCLEAR ,OFFICE ,TOUCHBIT>
	 <FCLEAR ,MEILHAN ,TOUCHBIT>
	 <FCLEAR ,QUAY ,TOUCHBIT>
	 <TELL
"Leghorn, and a barber, and a tailor; papers bought from a man who does
not ask; a yacht; a name off a chart in the Tyrrhenian Sea." CR CR
"Fourteen years dead, you come back to Marseilles a priest, an
Englishman, anything at all but a ghost. In your baggage: a black
cassock, an Englishman's drab coat, and the habit of patience." CR CR>
	 <GOTO ,BEAUCAIRE-ROAD>
	 <RTRUE>>

<ROUTINE ROAD-IN ()
	 <COND (<EQUAL? ,IDENTITY 1> ,INN)
	       (T
		<TELL
"You have your hand on the door and take it off again. The man inside
knew Edmond Dantes, and a face is a poor way to open a conversation you
mean to control. There is a cassock in your baggage." CR>
		<RFALSE>)>>

"=== Caderousse at the Pont du Gard ==="

;"Travel between the Beaucaire road and Marseilles is narrated coach
work, per the design; the road has one exit and it goes to the
counting-house."
<ROUTINE ROAD-SOUTH ()
	 <TELL
"A day and a night on the Beaucaire road behind post horses, and
Marseilles at the end of it: the same quay, the same white stones, and
not one of Morrel's ships in the harbor." CR CR>
	 ,OFFICE>

<ROUTINE INN-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK> <RFALSE>)
	       (T <RFALSE>)>>

<ROUTINE CADEROUSSE3 ()
	 <COND (<AND <VERB? TELL> ,PRSI> <CADEROUSSE3-TOPIC>)
	       (<VERB? TELL> <CADEROUSSE3-OPEN>)
	       (<AND <VERB? GIVE> <EQUAL? ,PRSO ,DIAMOND>>
		<GIVE-THE-DIAMOND>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"Gray, sour, and forty-five going on seventy. Poverty has been at work
on him the way the sea works on a wreck." CR>
		<RTRUE>)>>

<ROUTINE CADEROUSSE3-OPEN ()
	 <COND (,CAD-TALKED
		<TELL
"\"Ask, monsieur l'abbe. It is a relief to say it out loud, which is a
thing I did not expect.\"" CR>)
	       (T
		<SETG CAD-TALKED T>
		<TELL
"\"I am the Abbe Busoni,\" you say, \"and I attended a prisoner who
died in the Chateau d'If. Edmond Dantes. He left a diamond, to be
divided among the few who loved him.\"" CR CR
"He bolts the door, and his wife listens through the floorboards, and
the whole of it comes out of him like water out of a split cask." CR>)>
	 <RTRUE>>

<ROUTINE CADEROUSSE3-TOPIC ()
	 <COND (<NOT ,CAD-TALKED>
		<TELL "\"I know nothing, monsieur. I keep an inn.\"" CR>
		<RTRUE>)>
	 <COND (<EQUAL? ,PRSI ,LETTER-T>
		<CONFIRM-THE-GUILT>)
	       (<EQUAL? ,PRSI ,FATHER-T>
		<TELL
"\"He starved, monsieur. Not all at once; men do not, here. He sold the
coat off his back and then he stopped coming down the stairs.\"" CR CR
"\"He died with his hand in Mercedes's, and the red purse M. Morrel
left on his mantel paid for the burying.\"" CR>)
	       (<EQUAL? ,PRSI ,MERCEDES-T>
		<TELL
"\"She waited eighteen months, and mourned him, and then she married
Fernand, because the living must eat. She is the Countess de Morcerf
now, in Paris, and I do not think she has been warm since.\"" CR>)
	       (<EQUAL? ,PRSI ,DANGLARS-T>
		<TELL
"\"Banker. Baron. A hundred thousand a year and a wife who despises
him. God is not always in a hurry, monsieur l'abbe, but he keeps very
good books.\"" CR>)
	       (<EQUAL? ,PRSI ,FERNAND-T>
		<TELL
"\"Count de Morcerf, lieutenant-general, peer of France. He came back
from Greece rich, and nobody in Marseilles asked how, because nobody in
Marseilles was invited.\"" CR>)
	       (<EQUAL? ,PRSI ,VILLEFORT-T>
		<TELL
"\"Procureur du roi. He left Marseilles the week after and he has been
rising ever since, like something in a pond.\"" CR>)
	       (<EQUAL? ,PRSI ,CMORR-T>
		<TELL
"\"Ah. There is your good man, and see what it buys.\" He wipes the
table. \"Ruined. One ship left of ten, and September coming, and
everybody in this town knows the date.\"" CR>)
	       (<EQUAL? ,PRSI ,PURSE-T ,RED-PURSE>
		<FETCH-THE-PURSE>)
	       (<EQUAL? ,PRSI ,DIAMOND-T ,DIAMOND>
		<TELL
"\"Fifty thousand francs,\" he says, and cannot stop saying it. \"For
the whole of it?\"" CR CR
"From under the floor his wife's voice: \"Suppose it's false?\"" CR>)
	       (T
		<TELL
"\"That I could not tell you, monsieur l'abbe. I only ever knew what
was said at that table, and I was drunk at that table.\"" CR>)>
	 <RTRUE>>

<ROUTINE CONFIRM-THE-GUILT ()
	 <COND (,CONFIRMED-GUILT
		<TELL
"\"Danglars wrote it. Fernand posted it. I said nothing. I have told
you the whole of it and I would tell it again.\"" CR>)
	       (T
		<SETG CONFIRMED-GUILT T>
		<ADD-SCORE 10>
		<TELL
"\"Danglars wrote it, at La Reserve, with his left hand, on a leaf out
of the arbor. Fernand carried it to the post.\"" CR CR
"\"And I was there, monsieur l'abbe, and I said nothing. God forgive
me, I was drunk. Wine was invented because of men like me.\"" CR>)>
	 <RTRUE>>

<ROUTINE FETCH-THE-PURSE ()
	 <COND (,PURSE-OUT
		<TELL "It lies on the table between you." CR>)
	       (T
		<SETG PURSE-OUT T>
		<MOVE ,RED-PURSE ,INN>
		<FCLEAR ,RED-PURSE ,NDESCBIT>
		<TELL
"\"That, monsieur? A red silk purse. M. Morrel left it on old Dantes's
chimney-piece with two hundred francs in it, and the old man was too
proud to spend it and too hungry to throw it away.\"" CR CR
"He fetches it out of the cupboard and sets it on the table, and does
not quite let go of it." CR>)>
	 <RTRUE>>

<ROUTINE CUPBOARD-FCN ()
	 <COND (<VERB? OPEN SEARCH LOOK-INSIDE>
		<FETCH-THE-PURSE>
		<RTRUE>)>>

<ROUTINE GIVE-THE-DIAMOND ()
	 <COND (,DIAMOND-GIVEN
		<TELL "He has it, and he has not put it down." CR>)
	       (<NOT ,CONFIRMED-GUILT>
		<TELL
"You keep your hand closed on it. The stone is a price, and he has not
finished telling you what you are buying. Ask him about the letter."
CR>)
	       (T
		<SETG DIAMOND-GIVEN T>
		<REMOVE ,DIAMOND>
		<MOVE ,RED-PURSE ,WINNER>
		<SETG PURSE-OUT T>
		<ADD-SCORE 10>
		<TELL
"\"For the whole of it? Ah, monsieur l'abbe, do not jest with the
happiness or despair of a man!\"" CR CR
"He trades the purse for the stone without being asked twice, and holds
it up to the one candle, and under the floor his wife says again,
quite clearly: \"Suppose it's false?\"" CR>)>
	 <RTRUE>>

"=== Marseilles, 1829: saving Morrel ==="

<ROUTINE COCLES-FCN ()
	 <COND (<VERB? TELL>
		<TELL
"\"Thirty-five years I have kept these books, monsieur, and they have
never been wrong, and they have never been so short.\"" CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL "The cashier, deaf and faithful, guarding a cash-box
with nothing in it." CR>
		<RTRUE>)>>

<ROUTINE MORREL3-TALK ()
	 <COND (<NOT <EQUAL? ,IDENTITY 2>>
		<TELL
"He looks up, and something crosses his face that you cannot afford to
watch. \"Forgive me, monsieur. For a moment you put me in mind of
somebody.\" He will take nothing from a stranger with that face; an
Englishman's coat would be a kindness to you both." CR>
		<RTRUE>)
	       (,MORREL-TOLD
		<TELL
"\"The fifth of September, monsieur. There is nothing else in my head.\""
CR>)
	       (T
		<SETG MORREL-TOLD T>
		<TELL
"\"Thomson and French have bought my paper? Then I will tell you
plainly what you have bought.\"" CR CR
"\"On the fifth of September, at eleven o'clock, I must pay two hundred
and eighty-seven thousand francs. Or.\" He does not finish it, and you
both hear the pistol he does not name." CR>)>
	 <RTRUE>>

<ROUTINE MORREL3-TOPIC ()
	 <COND (<EQUAL? ,PRSI ,DEBT-T ,SEPTEMBER-T>
		<TELL
"\"Two hundred and eighty-seven thousand francs, on the fifth. I have
one ship at sea and she is three weeks overdue.\"" CR>)
	       (<EQUAL? ,PRSI ,SHIP-T>
		<TELL
"\"The Pharaon. She was the first and she will be the last.\" He looks
out of the window at a harbor with none of his ships in it." CR>)
	       (<EQUAL? ,PRSI ,DANTES-T ,FATHER-T>
		<TELL
"\"The best heart that ever beat under a sailor's jacket. I petitioned
four governments for him and got four silences.\" He turns away. \"Do
not speak of him, monsieur. I shall disgrace myself.\"" CR>)
	       (T
		<TELL
"\"Forgive me. I am poor company this season.\"" CR>)>
	 <RTRUE>>

<ROUTINE PAY-THE-DEBT ()
	 <COND (,DEBT-PAID
		<TELL "It is bought and receipted. What remains is the
theater of it." CR>)
	       (<NOT ,RICH>
		<TELL "With what? You have the manners of a rich man and
nothing else." CR>)
	       (<NOT <EQUAL? ,IDENTITY 2>>
		<TELL
"Not as yourself. He would not take it, and refusing it would cost him
the last thing he owns. Thomson and French can pay where a friend
cannot." CR>)
	       (T
		<SETG DEBT-PAID T>
		<MOVE ,RECEIPTED-BILL ,WINNER>
		<TELL
"In one morning the house of Thomson and French buys every bill of
Morrel and Son that is out in France, and marks the whole of it paid."
CR CR
"You fold the receipted bill into your pocket. It is worth two hundred
and eighty-seven thousand francs and it weighs nothing at all." CR>)>
	 <RTRUE>>

<ROUTINE RED-PURSE-FCN ()
	 <COND (<AND <VERB? PUT> <EQUAL? ,PRSI ,RED-PURSE>>
		<COND (<EQUAL? ,PRSO ,RECEIPTED-BILL>
		       <MOVE ,RECEIPTED-BILL ,RED-PURSE>
		       <TELL
"You fold the receipted bill into the faded red silk, where a proud old
man once kept two hundred francs he would not spend." CR>
		       <RTRUE>)
		      (<EQUAL? ,PRSO ,GEM>
		       <MOVE ,GEM ,RED-PURSE>
		       <TELL
"You drop the second great stone in after the bill, and on a slip of
parchment you write two words: Julie's Dowry." CR>
		       <RTRUE>)>
		<RFALSE>)
	       (<AND <VERB? PUT PUT-ON> <EQUAL? ,PRSO ,RED-PURSE>
		     <EQUAL? ,PRSI ,MANTEL>>
		<PURSE-ON-MANTEL>
		<RTRUE>)
	       (<VERB? EXAMINE LOOK-INSIDE SEARCH>
		<TELL
"A faded red silk purse, and everything in Marseilles that mattered has
passed through it." CR>
		<RFALSE>)>>

<ROUTINE PURSE-ON-MANTEL ()
	 <COND (<NOT <IN? ,RECEIPTED-BILL ,RED-PURSE>>
		<TELL
"An empty purse on a cold mantel is a cruelty. Put the bill in it
first." CR>
		<RTRUE>)>
	 <MOVE ,RED-PURSE ,MANTEL>
	 <ADD-SCORE 20>
	 <SETG SCENE-LOCK T>
	 <TELL
"You set the red purse on the mantelpiece where M. Morrel set it
fourteen years ago, and go out, and send a boy with a word to Julie
Morrel about a house in the Allees de Meilhan." CR CR
"THE FIFTH OF SEPTEMBER. Eleven o'clock. In a room over the
counting-house a good man puts the muzzle of a pistol between his
teeth, and hears his daughter's voice on the stair: \"Father! Saved!
You are saved!\"" CR CR
"The purse in her hand. The bill receipted. The stone for her dowry.
And then, from the port, the cry that no accounting can explain: the
Pharaon! The Pharaon is entering harbor! A new ship, built in secret to
the old lines, coming in under all sail with her name in fresh gold."
CR CR
"The good are repaid. Now Paris. Now the others." CR CR
"Nine years pass like nine waves. It is eighteen thirty-eight, and
Paris believes in you." CR CR>
	 <ENTER-ACT-FOUR>
	 <RTRUE>>

<ROUTINE ENTER-ACT-FOUR ()
	 <SETG ACT 4>
	 <SETG IDENTITY 3>
	 <SETG SCENE-LOCK <>>
	 <RETIRE-CAST>
	 <REMOVE ,FARIA>
	 <REMOVE ,BODY>
	 <REMOVE ,SACK>
	 <REMOVE ,CASSOCK>
	 <REMOVE ,WIG>
	 <REMOVE ,ENGLISH-COAT>
	 <REMOVE ,RED-CAP>
	 <REMOVE ,SPAR>
	 <REMOVE ,PICKAXE>
	 <REMOVE ,BRANCH>
	 <REMOVE ,RECEIPTED-BILL>
	 ;"nine years and a fortune later, the Count is not still carrying
	  a broken jug shard and a saucepan handle"
	 <REMOVE ,SHARD>
	 <REMOVE ,PAN-HANDLE>
	 <REMOVE ,KNIFE>
	 <REMOVE ,NEEDLE>
	 <REMOVE ,PHIAL>
	 <REMOVE ,PARCHMENT>
	 <REMOVE ,POWDER-HORN>
	 <REMOVE ,LOOSE-STONE>
	 <REMOVE ,PRISON-LAMP>
	 <REMOVE ,CHISEL>
	 <REMOVE ,SUPPLIES>
	 <REMOVE ,RED-PURSE>
	 <REMOVE ,GEM>
	 <MOVE ,COSTUME-BAG ,WINNER>
	 <MOVE ,CASSOCK ,COSTUME-BAG>
	 <MOVE ,WIG ,COSTUME-BAG>
	 <MOVE ,ENGLISH-COAT ,COSTUME-BAG>
	 <MOVE ,CREDIT-LETTER ,WINNER>
	 <MOVE ,BANKNOTES ,WINNER>
	 <MOVE ,PILL ,CSTUDY>
	 <MOVE ,SPADE ,CSTUDY>
	 <MOVE ,MORCERF ,PEERS>
	 <TELL
"    ***  ACT FOUR: PARIS, 1838  ***" CR CR>
	 <GOTO ,SALON>
	 <RTRUE>>
