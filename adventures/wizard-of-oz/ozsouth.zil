"OZSOUTH - Act IV: the humbug, the balloon, the road south, and Kansas."

"=== The screen and the little old man ==="

<ROUTINE SEND-THREAT ()
	 <SETG SUMMONED T>
	 <TELL
"You send the green girl in with the Scarecrow's message: that if Oz does
not see all four of you at once, you will call the Winged Monkeys and ask
them what they think about it." CR CR
"The word comes back within the hour, and the soldier delivers it with the
air of a man carrying something hot. \"Oz will see you in the Throne
Room, tomorrow morning, at four minutes after nine.\"" CR>
	 <RTRUE>>

<ROUTINE V-SEND-MSG ()
	 <COND (<G? ,AUDIENCE 3> <SOLDIER-TALK>)
	       (T
		<TELL "There is nobody here to carry a message." CR>
		<RTRUE>)>>

<ROUTINE V-THREATEN ()
	 <COND (<G? ,AUDIENCE 3> <SOLDIER-TALK>)
	       (T
		<TELL "You are not really the threatening sort, and it shows." CR>
		<RTRUE>)>>

<ROUTINE SCREEN-FCN ()
	 <COND (<VERB? LOOK-BEHIND MOVE PUSH EXAMINE TAKE OPEN>
		<COND (<VERB? EXAMINE>
		       <TELL "A tall green screen standing in the corner, which
you had not noticed, because nobody notices a screen." CR>
		       <RTRUE>)
		      (T <SCREEN-FALLS <>>)>)>>

<ROUTINE SCREEN-FALLS (BY-ROAR)
	 <COND (<G? ,REVEAL 0>
		<TELL "The little man is already out from behind it, and
looking much better for the fresh air." CR>
		<RTRUE>)>
	 <SETG REVEAL 1>
	 <SETG SCENE-FLAG <>>
	 <COND (<NOT ,SC-SCREEN> <SETG SC-SCREEN T> <SCORE-IT 10>)>
	 <COND (.BY-ROAR
		<TELL
"The Lion gives a roar so loud and terrible that Toto jumps in fright, and
tips over the screen that stands in the corner." CR>)
	       (T
		<TELL
"You reach for the screen, and Toto gets there first, because that moment
was always going to be his: he leaps at it barking and the whole thing
goes over with a clatter." CR>)>
	 <TELL CR
"And behind it, blinking, stands a little old man with a bald head and a
wrinkled face, who seems to be as much surprised as you are." CR CR
"The Tin Woodman raises his axe. \"Who are you?\"" CR CR
"\"I am Oz, the Great and Terrible,\" says the little man, in a trembling
voice, \"but don't strike me, please don't, and I'll do anything you want
me to.\"" CR>
	 <RTRUE>>

<ROUTINE HUMBUG-TALK ()
	 <COND (<VERB? EXAMINE>
		<TELL "A little old man with a bald head and a wrinkled face,
in a shabby coat, standing in the middle of his own throne room looking
extremely relieved to be found out." CR>
		<RTRUE>)
	       (<VERB? PROMISE ANSWER REPLY>
		<COND (<G? ,REVEAL 1> <OZ-DEAL>)
		      (T <OZ-CONFESS>)>)
	       (<VERB? TELL HELLO SAY-OBJ>
		<COND (<==? ,REVEAL 1> <OZ-CONFESS>)
		      (<==? ,REVEAL 2> <OZ-DEAL>)
		      (T
		       <TELL "\"Tomorrow,\" says the little man. \"You shall
have everything I can give you tomorrow, and I shall be glad to be rid of
the secret.\"" CR>
		       <RTRUE>)>)>>

<ROUTINE OZ-CONFESS ()
	 <SETG REVEAL 2>
	 <TELL
"\"I thought you were a great Head,\" says Dorothy. \"And I thought you
were a lovely Lady,\" says the Scarecrow. \"And I thought you were a
terrible Beast,\" says the Woodman. \"And I thought you were a Ball of
Fire,\" says the Lion." CR CR
"\"No,\" says the little man meekly. \"You are all wrong. I have been
making believe.\"" CR CR
"\"Making believe! Are you not a great Wizard?\"" CR CR
"\"Hush, my dear; don't speak so loud, or you will be overheard, and I
should be ruined. I'm supposed to be a Great Wizard.\"" CR CR
"\"And aren't you?\"" CR CR
"\"Not a bit of it, my dear; I'm just a common man.\"" CR CR
"\"You're more than that,\" says the Scarecrow, in a grieved tone. \"You're
a humbug.\"" CR CR
"\"Exactly so!\" declares the little man, rubbing his hands together as if
it pleased him. \"I am a humbug.\" He nods toward a small door in the east
wall. \"Come and see how it was done, and then perhaps you will not think
so badly of me.\"" CR>
	 <RTRUE>>

<ROUTINE OZ-DEAL ()
	 <SETG REVEAL 3>
	 <SETG SUMMONED <>>
	 <TELL
"\"Keep my secret,\" says the little man, \"and tell no one I am a
humbug, and I will do my best by all of you. Come to me tomorrow morning,
and you shall have what you came for. All of you.\"" CR CR
"You promise. It costs nothing, and he looks so relieved that the
Scarecrow shakes his hand twice, once for each of them." CR>
	 <RTRUE>>

<ROUTINE V-PROMISE ()
	 <COND (<==? ,REVEAL 2> <OZ-DEAL>)
	       (<G? ,REVEAL 1> <HUMBUG-TALK>)
	       (T
		<TELL "You promise, solemnly, and nobody is listening." CR>
		<RTRUE>)>>

"=== The workshop ==="

<ROUTINE WORKSHOP-FCN (RARG)
	 <COND (<==? .RARG ,M-ENTER>
		<RFALSE>)>>

<ROUTINE PROP-SEEN ()
	 <SETG PROPS-SEEN <+ ,PROPS-SEEN 1>>
	 <RTRUE>>

<ROUTINE PROP-HEAD-FCN ()
	 <COND (<VERB? EXAMINE LOOK-BEHIND>
		<PROP-SEEN>
		<TELL "A great head made of many thicknesses of paper, with a
carefully painted face, and threads at the back of the eyes and jaw. \"I
hung it from the ceiling by a wire,\" says the little man, \"and stood
behind the screen and pulled the threads. The voice was mine. It always
was.\"" CR>
		<RTRUE>)>>

<ROUTINE PROP-MASK-FCN ()
	 <COND (<VERB? EXAMINE>
		<PROP-SEEN>
		<TELL "A dress of green silk gauze on a hook, and a mask
painted like a beautiful face. \"I dressed up in that and floated a
little, on wires,\" says Oz. \"The Scarecrow was very taken with her. I
have never known how to feel about that.\"" CR>
		<RTRUE>)>>

<ROUTINE PROP-SKINS-FCN ()
	 <COND (<VERB? EXAMINE>
		<PROP-SEEN>
		<TELL "A great bundle of skins sewn together, with slats to
keep the sides out and five stuffed legs. \"I crawled inside,\" says the
little man. \"It was hot in there. I used a good many strings for the
eyes.\"" CR>
		<RTRUE>)>>

<ROUTINE PROP-COTTON-FCN ()
	 <COND (<VERB? EXAMINE>
		<PROP-SEEN>
		<TELL "A big ball of cotton hanging on a wire, with a bottle of
oil beside it. \"I lit it, and it floated in the air, and nobody could
come near for the heat,\" says Oz. \"The Lion did not stay long enough for
me to explain, which was a relief.\"" CR>
		<RTRUE>)>>

"=== The gifts ==="

<ROUTINE THRONE-GIFTS ()
	 <SETG GIFTS-GIVEN T>
	 <SETG SUMMONED <>>
	 <COND (<NOT ,SC-GIFTS> <SETG SC-GIFTS T> <SCORE-IT 5>)>
	 <TELL
"The little man keeps his word, and he does it seriously, which is what
makes it work." CR CR
"He unpins the Scarecrow's head, empties out the straw, and fills it with
a mixture of bran and a great many pins and needles, and sews it up again.
\"Hereafter you will be a great man,\" he says, \"for I have given you a
lot of bran-new brains.\" The Scarecrow is so pleased he cannot speak
sensibly for several minutes, which he says proves it." CR CR
"He cuts a small square hole in the Tin Woodman's chest with the tin
shears, and puts in a pretty heart of silk stuffed with sawdust, and
solders the patch back neatly. \"Is it a kind heart?\" asks the Woodman.
\"Oh, very!\" says Oz. The Woodman listens to it all afternoon." CR CR
"He fetches a green bottle and pours it into a green dish and gives it to
the Lion, who sniffs at it. \"What is it?\" \"Well,\" says Oz, \"if it
were inside of you, it would be courage. You know, of course, that courage
is always inside one; so that this really cannot be called courage until
you have swallowed it.\" The Lion drinks it to the last drop and declares
himself full of courage, and nobody argues, because he is." CR CR
"Then he turns to you, and rubs his bald head, and says: \"Give me two or
three days to think it over. I shall have to build a balloon.\"" CR>
	 <RTRUE>>

"=== The balloon ==="

<ROUTINE PLAZA-FCN (RARG)
	 <COND (<==? .RARG ,M-ENTER>
		<COND (<AND ,GIFTS-GIVEN <NOT ,BALLOON-GONE>>
		       <COND (<L? ,BALLOON-DAY 3>
			      <SETG BALLOON-DAY 3>)>
		       <ENABLE <QUEUE I-BALLOON 2>>
		       <TELL CR
"The whole Emerald City has turned out. Above the crowd swells a great
balloon of green silk, tugging at its ropes, with a clothes basket swinging
beneath it, and the little man standing in the basket in his best coat." CR>)>
		<RFALSE>)>>

<ROUTINE I-BALLOON ()
	 <COND (,BALLOON-GONE <RFALSE>)>
	 <SETG BALLOON-DAY <+ ,BALLOON-DAY 1>>
	 <COND (<==? ,BALLOON-DAY 4>
		<TELL CR
"\"I am going away to visit my brother wizards,\" the little man announces
to the crowd, \"and while I am gone the Scarecrow will rule over you. I
command you to obey him as you would me.\" The crowd cheers, having no
strong feelings either way about wizards." CR CR
"\"Come, Dorothy!\" he calls. \"Hurry up, or the balloon will fly
away.\"" CR>
		<ENABLE <QUEUE I-BALLOON 2>>
		<RTRUE>)
	       (T
		<TELL CR
"Toto sees a kitten in the crowd and bolts after it, barking, and is gone
between a hundred green legs." CR>
		<REMOVE ,TOTO>
		<SETG TOTO-GONE T>
		<ENABLE <QUEUE I-BALLOON-GO 2>>
		<RTRUE>)>>

<ROUTINE I-BALLOON-GO ()
	 <COND (,BALLOON-GONE <RFALSE>)>
	 <BALLOON-LEAVES>
	 <RTRUE>>

<ROUTINE BALLOON-LEAVES ()
	 <SETG BALLOON-GONE T>
	 <SETG TOTO-GONE <>>
	 <MOVE ,TOTO ,BALLOON-PLAZA>
	 <TELL CR
"The ropes crack like a whip. The great green bag leaps for the sky as if
it has been wanting to all along, and the little man peers down at you
over the edge of the basket, getting smaller." CR CR
"\"Come back!\" you scream. \"I want to go, too!\"" CR CR
"\"I can't come back, my dear,\" calls the Wizard of Oz. \"Good-bye!\"" CR CR
"And the whole Emerald City watches its Wizard shrink to a green speck and
vanish, going home the way he came, alone. He was a humbug and a good man
and the only person in two worlds who knew the way to Kansas, and you are
standing in a palace plaza holding a small warm dog who is extremely
pleased with himself about a kitten." CR CR
"     *** You have not won ***" CR CR
"But you have not lost, either, whatever the sky says. Because the
Scarecrow is already thinking, you can tell, because the pins are starting
to stick out, and somewhere south of here, past soldiers' woods and a
country made of china, lives the one person in Oz older and wiser and
kinder than wizards. The story is not over." CR>
	 <RTRUE>>

<ROUTINE BALLOON-FCN ()
	 <COND (<VERB? BOARD ENTER CLIMB-ON TAKE>
		<COND (,BALLOON-GONE
		       <TELL "It is a green speck, and then it is nothing." CR>
		       <RTRUE>)
		      (T
		       <TELL "You put a hand on the edge of the basket, and
that is the moment the ropes choose." CR>
		       <BALLOON-LEAVES>
		       <RTRUE>)>)
	       (<VERB? EXAMINE>
		<TELL "A great bag of green silk, glued and sewn, straining at
its ropes, with a clothes basket swinging under it." CR>
		<RTRUE>)>>

<ROUTINE KITTEN-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "A green kitten, entirely unbothered, being pursued by a
dog with no plan." CR>
		<RTRUE>)>>

<ROUTINE CROWD-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "The whole Emerald City, green and cheerful, come out to
watch a wizard leave." CR>
		<RTRUE>)>>

<ROUTINE V-SEW ()
	 <COND (<AND <==? ,HERE ,BALLOON-PLAZA> <NOT ,BALLOON-GONE>>
		<TELL "You sew a long seam of green silk, and the little man
paints it over with glue, and thanks you sincerely." CR>
		<RTRUE>)
	       (T
		<TELL "There is nothing here that wants sewing." CR>
		<RTRUE>)>>

<ROUTINE PLAZA-SOUTH ()
	 <COND (,BALLOON-GONE ,FIGHTING-TREES)
	       (,GIFTS-GIVEN
		<TELL "Not yet. There is a balloon here, and a crowd, and a
little man who thinks he is about to do you a kindness." CR>
		<RFALSE>)
	       (T ,FIGHTING-TREES)>>

"=== The fighting trees ==="

<ROUTINE FTREES-FCN (RARG)
	 <COND (<==? .RARG ,M-BEG>
		<COND (<AND <VERB? WALK> <NOT ,TREES-CHOPPED>
			    <==? ,P-WALK-DIR ,P?SOUTH>>
		       <FTREES-BLOCK>)>)>>

<ROUTINE FTREES-BLOCK ()
	 <TELL
"The Scarecrow walks under the first tree, cheerfully, and its branches
bend down and twine round him and lift him off his feet and fling him back
among his friends. He is not hurt, only dizzy." CR CR
"\"It doesn't hurt me to be thrown about,\" he says from the ground, \"and
I begin to see why nobody visits the south.\"" CR>
	 <RTRUE>>

<ROUTINE FTREES-SOUTH ()
	 <COND (,TREES-CHOPPED ,CHINA-WALL)
	       (T <FTREES-BLOCK> <RFALSE>)>>

<ROUTINE FIGHT-TREE-FCN ()
	 <COND (<VERB? CHOP CUT ATTACK> <DO-CHOP>)
	       (<VERB? EXAMINE>
		<TELL "A row of trees standing shoulder to shoulder like a
fence of policemen, with branches that flex when they think you are not
looking." CR>
		<RTRUE>)>>

<ROUTINE FTREES-CHOP ()
	 <SETG TREES-CHOPPED T>
	 <TELL
"The tree reaches for the Woodman and he takes its branch off at the joint
with one swing. The whole tree shakes as if in pain, and draws its
branches back, and the party walks under it unhindered." CR CR
"A twig from the next tree snatches Toto up by the collar, and the Woodman
has that branch off before anybody has finished shouting. Toto lands on
his feet and barks at the tree from behind the Lion." CR>
	 <RTRUE>>

"=== The china wall and country ==="

<ROUTINE CWALL-FCN (RARG)
	 <COND (<AND <==? .RARG ,M-BEG> <VERB? LEAP> ,WALL-CLIMBED>
		<CHINA-JUMP>)
	       (<AND <==? .RARG ,M-BEG> <VERB? LEAP> ,LADDER-BUILT>
		<CWALL-CLIMB>)
	       (<==? .RARG ,M-LOOK>
		<COND (,LADDER-BUILT
		       <TELL "A tall wooden ladder leans against the white
wall." CR>)>
		<RFALSE>)>>

<ROUTINE BUILD-LADDER ()
	 <SETG LADDER-BUILT T>
	 <TELL
"\"Then I will make a ladder,\" says the Tin Woodman, \"for we certainly
must climb over the wall.\" He goes into the wood and cuts and trims until
it is dark, and works on by feel, and in the morning there is a ladder
leaning against the white wall and a Woodman looking modest about it." CR>
	 <RTRUE>>

<ROUTINE LADDER-FCN ()
	 <COND (<VERB? CLIMB-FOO CLIMB-UP BOARD> <CWALL-CLIMB>)
	       (<VERB? EXAMINE>
		<TELL "A tall wooden ladder, cut and pegged in one night by
somebody who never gets tired." CR>
		<RTRUE>)>>

<ROUTINE CWALL-CLIMB ()
	 <COND (<NOT ,LADDER-BUILT>
		<TELL "The wall is smooth as the inside of a dish, and higher
than your head, and there is nothing to climb." CR>
		<RTRUE>)
	       (T
		<SETG WALL-CLIMBED T>
		<TELL
"The Scarecrow goes up first, and when he reaches the top he says \"Oh,
my!\" Then Dorothy, and she says \"Oh, my!\" Then Toto, who barks. Then
the Lion, and then the Woodman, and each of them says \"Oh, my!\" in turn,
and nobody can think of anything better, because below the wall is a
country made entirely of china." CR CR
"You pull the ladder up after you and let it down the other side, and then
you look at the drop, and the Scarecrow says: \"Jump. I will go first, so
you have something soft to land on.\"" CR>
		<RTRUE>)>>

<ROUTINE CWALL-UP ()
	 <COND (<NOT ,LADDER-BUILT>
		<TELL "Nothing to climb, and the wall is smooth as a dish." CR>
		<RFALSE>)
	       (<NOT ,WALL-CLIMBED> <CWALL-CLIMB> <RFALSE>)
	       (T <CHINA-JUMP> <RFALSE>)>>

<ROUTINE CWALL-SOUTH ()
	 <COND (<NOT ,LADDER-BUILT>
		<TELL "The wall bars the way south, smooth as the inside of a
dish. A ladder would settle it." CR>
		<RFALSE>)
	       (<NOT ,WALL-CLIMBED> <CWALL-CLIMB> <RFALSE>)
	       (T <CHINA-JUMP> <RFALSE>)>>

<ROUTINE CHINA-JUMP ()
	 <TELL
"The Scarecrow jumps down first and lies flat, and the rest of you land on
him one after another, taking pains not to light on his head and get the
pins in your feet. When everybody is down you pat him back into shape,
and he says it is the most useful he has ever been, which is not true, and
nobody corrects him." CR>
	 <MOVE ,WINNER ,CHINA-COUNTRY>
	 <SETG HERE ,CHINA-COUNTRY>
	 <V-LOOK>
	 <RTRUE>>

<ROUTINE CHINA-FCN (RARG)
	 <COND (<==? .RARG ,M-BEG>
		<COND (<AND <VERB? WALK> <==? ,P-WALK-DIR ,P?SOUTH>> <RFALSE>)
		      (<VERB? FOLLOW>
		       <SETG CHINA-CLEAN <>>
		       <TELL "You start after her, and a china cow kicks over
a china milking stool, and everybody looks at you." CR>
		       <RTRUE>)>)>>

<ROUTINE MILKMAID-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "A china milkmaid the height of your knee, beside a china
cow with one leg missing, and she is not pleased about the leg." CR>
		<RTRUE>)
	       (<AND <VERB? GIVE> <EQUAL? ,PRSO ,COW-LEG>> <GIVE-LEG>)
	       (<VERB? TELL HELLO>
		<TELL "\"My cow's leg came off,\" says the milkmaid, \"and the
mender charges the earth. If you should find it, I would be glad, and I
would try to forgive you for the noise you are making.\"" CR>
		<RTRUE>)>>

<ROUTINE CHINA-COW-FCN ()
	 <COND (<VERB? EXAMINE SEARCH>
		<FCLEAR ,COW-LEG ,INVISIBLE>
		<MOVE ,COW-LEG ,CHINA-COUNTRY>
		<TELL "A china cow standing on three legs. The fourth is lying
in the grass a little way off, quite clean, and easily found once you
look." CR>
		<RTRUE>)>>

<ROUTINE COW-LEG-FCN ()
	 <COND (<AND <VERB? GIVE PUT> <EQUAL? ,PRSI ,MILKMAID>> <GIVE-LEG>)
	       (<VERB? EXAMINE>
		<TELL "A little china leg, broken clean off, which is the sort
of thing that mends well." CR>
		<RTRUE>)>>

<ROUTINE GIVE-LEG ()
	 <COND (,LEG-BACK
		<TELL "She has it, and the cow is standing on it." CR>
		<RTRUE>)
	       (T
		<SETG LEG-BACK T>
		<REMOVE ,COW-LEG>
		<TELL "You give the milkmaid her cow's leg, and she takes it
without a word and holds it up against the cow, and then she looks at you
and forgives you a little." CR>
		<RTRUE>)>>

<ROUTINE PRINCESS-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "A china Princess in a gown of white and gold, no higher
than your knee, watching you carefully from a safe distance." CR>
		<RTRUE>)
	       (<VERB? FOLLOW>
		<SETG CHINA-CLEAN <>>
		<TELL "\"Don't chase me!\" she cries, and runs, and something
small breaks somewhere behind you." CR>
		<RTRUE>)
	       (<VERB? TAKE>
		<TELL
"\"Please don't,\" says the Princess. \"We are very brittle here. If you
took me away, and stood me on a mantel in your country, I should stand
stiff and straight and look pretty, and that is all I should ever do
again.\" She looks up at you. \"Here I am alive.\" Your hand stops an inch
away, and comes back." CR>
		<COND (<NOT ,PRINCESS-FREED>
		       <SETG PRINCESS-FREED T>
		       <SCORE-IT 0>)>
		<RTRUE>)
	       (<VERB? TELL HELLO KISS HUG>
		<TELL
"\"Don't chase me!\" says the china Princess, and, when you do not: \"You
see, we are not like your people. We break. Mr. Joker over there has been
mended so many times he is more glue than clown, and one is never so
pretty after being mended.\"" CR>
		<RTRUE>)>>

<ROUTINE JOKER-FCN ()
	 <COND (<VERB? EXAMINE TELL HELLO>
		<TELL
"A little china clown with cracks running all over him, who stands on his
head and says:" CR CR
"\"My lady fair, why do you stare at poor old Mr. Joker? You're quite as
stiff and prim as if you'd eaten up a poker!\"" CR CR
"\"Be quiet,\" says the Princess. \"You are cracked all over.\" \"That,\"
says Mr. Joker, \"is why I am funny.\"" CR>
		<RTRUE>)>>

<ROUTINE CHINA-CHURCH-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "A little china church with a steeple, no higher than
your waist, and quite whole. So far." CR>
		<RTRUE>)>>

<ROUTINE CHINA-SOUTH ()
	 <COND (<HAS-LION?> <CHINA-EXIT> <RFALSE>)
	       (T
		<TELL "The wall on this side is lower, but still higher than
you, and the ladder is on the other side." CR>
		<RFALSE>)>>

<ROUTINE CHINA-EXIT ()
	 <SETG CHURCH-BROKE T>
	 <SCORE-IT -1>
	 <COND (<AND ,CHINA-CLEAN <NOT ,SC-CHINA>>
		<SETG SC-CHINA T>
		<SCORE-IT 5>)>
	 <TELL
"The far wall is lower. You climb onto the Lion's back and he gathers
himself and jumps, and as he goes his tail catches a little china church
and knocks it over, and it breaks all to pieces." CR CR
"\"That was too bad,\" says the Lion, on the other side. \"But really, we
were lucky not to do these little people more harm than breaking a cow's
leg and a church. They are all so brittle.\"" CR CR
"\"They are,\" says the Scarecrow, \"and I am glad I am made of straw and
cannot be easily damaged. There are worse things in the world than being a
Scarecrow.\"" CR>
	 <MOVE ,WINNER ,QUADLING-FOREST>
	 <SETG HERE ,QUADLING-FOREST>
	 <V-LOOK>
	 <RTRUE>>

"=== The forest of beasts and the spider ==="

<ROUTINE QFOREST-FCN (RARG)
	 <COND (<AND <==? .RARG ,M-ENTER> <NOT ,SPIDER-DEAD>>
		<TELL CR
"The clearing ahead is full of animals: tigers and elephants and bears and
wolves and foxes, all growling together like a town meeting gone wrong.
The Lion walks into the middle of them, and they stop." CR CR
"\"We are choosing a king,\" says a great tiger, bowing. \"A monster has
come into our forest, as big as an elephant with legs as long as tree
trunks and a mouth full of teeth, and it is eating us one at a time. We
were choosing a king to protect us, and then you came.\"" CR CR
"\"If I put an end to your enemy,\" says the Lion, \"will you bow down to
me as King of the Forest?\" And all the beasts say yes." CR>
		<RFALSE>)>>

<ROUTINE BEASTS-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "Tigers, elephants, bears, wolves, foxes, and a great
many others, all of them frightened and pretending not to be." CR>
		<RTRUE>)
	       (<VERB? TELL HELLO>
		<TELL "\"Kill the spider,\" says the great tiger, \"and he is
our King, and we will do whatever he says forever.\"" CR>
		<RTRUE>)>>

<ROUTINE SPIDER-FCN ()
	 <COND (<VERB? ATTACK CHOP STOP> <KILL-SPIDER>)
	       (<VERB? EXAMINE>
		<TELL "You have not seen it. What you have seen are the tracks,
and the beasts' faces when they speak of it." CR>
		<RTRUE>)>>

<ROUTINE KILL-SPIDER ()
	 <COND (,SPIDER-DEAD
		<TELL "It is dead, and the forest is calmer than it has been in
years." CR>
		<RTRUE>)
	       (<NOT <HAS-LION?>>
		<TELL "Somebody would have to fight it, and the only one here
who could is not here." CR>
		<RTRUE>)
	       (T
		<SETG SPIDER-DEAD T>
		<SETG LION-STATE 4>
		<REMOVE ,SPIDER>
		<COND (<NOT ,SC-CROWN> <SETG SC-CROWN T> <SCORE-IT 5>)>
		<TELL
"\"I shall go alone,\" says the Lion. \"You would only be in the way, and
besides, I would rather nobody watched me be frightened.\" And he goes." CR CR
"He finds the great spider lying asleep, so ugly that he turns up his nose
in disgust, with a body as big as an elephant, a mouth with a row of sharp
teeth a foot long, and a neck as slender as a wasp's waist. The Lion knows
at once that this is the best place to attack, and he springs, and strikes
it with one heavy blow of his paw, and the head comes off, and that is
the end of it." CR CR
"He comes back and stands before the beasts, and they bow down to him as
King of the Forest, and he says he will come and rule over them as soon as
Dorothy is safely home. He is trying very hard to be modest about it, and
failing, and everybody lets him." CR>
		<RTRUE>)>>

"=== Quadling country and Glinda ==="

<ROUTINE FARM-FCN (RARG)
	 <COND (<==? .RARG ,M-ENTER>
		<TELL CR
"The Quadlings are short and fat and cheerful and dressed all in red, and
they take one look at your party and put out cake and cookies and cream
and milk and will not hear of payment. A farmer's wife points the way
south to the castle of Glinda the Good." CR>
		<RFALSE>)>>

<ROUTINE FARMWIFE-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "A short, fat, cheerful woman all in red, holding out
cake with the air of a person who will not be argued with." CR>
		<RTRUE>)
	       (<VERB? TELL HELLO>
		<TELL "\"Glinda is beautiful and she is good,\" says the
farmer's wife, \"and she has been young for a great many years, and she
is kind to everybody who asks her properly. South, dear.\"" CR>
		<RTRUE>)>>

<GLOBAL STAY-ASKED <>>

<ROUTINE V-STAY ()
	 <COND (<AND ,STAY-OFFERED <==? ,HERE ,GLINDA-THRONE>>
		<COND (,STAY-ASKED <STAY-IN-OZ>)
		      (T
		       <SETG STAY-ASKED T>
		       <TELL "\"Stay?\" says Glinda, and she does not say it
unkindly. \"Think, my dear. Say it once more and I will believe you.\"" CR>
		       <RTRUE>)>)
	       (T
		<TELL "You stay where you are. Nothing much comes of it." CR>
		<RTRUE>)>>

<ROUTINE GLINDA-FCN (RARG)
	 <COND (<AND <==? .RARG ,M-BEG> ,STAY-OFFERED
		     <VERB? STAY>>
		<V-STAY>)
	       (<==? .RARG ,M-ENTER>
		<COND (<NOT ,GLINDA-TOLD>
		       <TELL CR
"Glinda looks at you for a long moment, kindly. \"What can I do for you,
my child?\"" CR>)>
		<RFALSE>)>>

<ROUTINE GIRL-SOLDIERS-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "Three girl soldiers in red uniform, standing very
straight and trying not to stare at the Lion, and failing, entirely." CR>
		<RTRUE>)>>

<ROUTINE GLINDA-OBJ-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "A witch young and beautiful, with hair the color of rich
red and eyes blue and kind, on a throne of rubies. She is the oldest
person in this room by a great many years and it does not show at all." CR>
		<RTRUE>)
	       (<AND <VERB? GIVE PUT> <EQUAL? ,PRSO ,GOLDEN-CAP>> <GIVE-CAP>)
	       (<VERB? TELL HELLO ANSWER SAY-OBJ> <GLINDA-TALK>)
	       (<VERB? KISS HUG>
		<TELL "Glinda bends and kisses your forehead, on the mark the
Witch of the North left, and it does not fade, and she says nothing about
it." CR>
		<RTRUE>)>>

<ROUTINE GLINDA-TALK ()
	 <COND (<NOT ,GLINDA-TOLD>
		<SETG GLINDA-TOLD T>
		<TELL
"You tell her the whole of it: the cyclone, and the silver shoes, and a
scarecrow on a pole, and a tin man in the rain, and a lion who was ashamed
of himself, and the Kalidahs and the river and the poppies and the mice">
		<COND (,LEG-BACK <TELL ", and a china cow's leg put back where
it belonged">)>
		<COND (,SPIDER-DEAD <TELL ", and a King crowned in a forest">)>
		<TELL ", and a bucket of water, and a balloon that would not
wait." CR CR
"\"My greatest wish now,\" you finish, \"is to get back to Kansas, for
Aunt Em will surely think something dreadful has happened to me.\"" CR CR
"Glinda leans forward and kisses your face. \"Bless your dear heart,\" she
says, \"I am sure I can tell you of a way to get back to Kansas.\" Then
she adds: \"But if I do, you must give me the Golden Cap.\"" CR>
		<RTRUE>)
	       (<NOT ,CAP-GIVEN>
		<TELL "\"The Cap first, my dear,\" says Glinda, gently." CR>
		<RTRUE>)
	       (T <SHOE-SECRET>)>>

<ROUTINE GIVE-CAP ()
	 <COND (<NOT ,GLINDA-TOLD>
		<TELL "\"Tell me everything first,\" says Glinda. \"I should
like to hear it all.\"" CR>
		<RTRUE>)
	       (,CAP-GIVEN
		<TELL "She has it." CR>
		<RTRUE>)
	       (T
		<SETG CAP-GIVEN T>
		<REMOVE ,GOLDEN-CAP>
		<COND (<NOT ,SC-GLINDA> <SETG SC-GLINDA T> <SCORE-IT 5>)>
		<TELL
"\"Willingly,\" you say, and give her the Golden Cap, \"for it is of no
use to me now, and when you have it you can command the Winged Monkeys
three times.\"" CR CR
"\"And I think I shall need their service just those three times,\" says
Glinda, smiling. She tells the Scarecrow the Monkeys will carry him to the
Emerald City, where the people will be glad to have him rule over them
again. She tells the Woodman they will carry him to the country of the
Winkies, who asked for him as their ruler and meant it. She tells the Lion
they will carry him to his own great forest, where he is King." CR CR
"\"And then,\" she says, \"I shall give the Golden Cap to the King of the
Monkeys, that he and his band may thereafter be free for evermore.\"" CR>
		<SHOE-SECRET>
		<RTRUE>)>>

<ROUTINE SHOE-SECRET ()
	 <SETG STAY-OFFERED T>
	 <TELL CR
"\"Your Silver Shoes will carry you over the desert,\" says Glinda. \"If
you had known their power you could have gone back to your Aunt Em the
very first day you came to this country.\"" CR CR
"\"But then I should not have had my wonderful brains!\" cries the
Scarecrow. \"And I should not have had my lovely heart,\" says the Tin
Woodman. \"And I should have lived a coward forever,\" says the Lion, \"and
no beast in all the forest would have had a good word to say to me.\"" CR CR
"\"All you have to do,\" says Glinda, \"is to knock the heels together
three times and command the shoes to carry you wherever you wish to
go.\"" CR>
	 <RTRUE>>

"=== Farewells, heels, Kansas ==="

<ROUTINE DO-FAREWELL (WHO)
	 <COND (<N==? ,HERE ,GLINDA-THRONE>
		<COND (<==? .WHO ,LION>
		       <TELL "You put your arms as far round the Lion's neck as
they will go, and he permits it, and pretends to mind." CR>)
		      (<==? .WHO ,WOODMAN>
		       <TELL "You hug the Tin Woodman, which is like hugging a
stove, and he is very pleased." CR>)
		      (T
		       <TELL "You hug the Scarecrow, and he crackles, and hugs
back too hard, as usual." CR>)>
		<RTRUE>)
	       (T
		<SETG FAREWELLS <+ ,FAREWELLS 1>>
		<COND (<==? .WHO ,LION>
		       <TELL "You put your arms round the Lion's great neck and
kiss him, and he lets you, and then puts his head down so you cannot see
his face. \"Come and visit,\" he says to the floor. \"Everyone in my
forest will be told about you. At length.\"" CR>)
		      (<==? .WHO ,WOODMAN>
		       <TELL "You kiss the Tin Woodman on the cheek, and he
begins to cry at once, and you have his face wiped dry with your apron
before it can rust, which is the last kind thing you do for him and by no
means the first." CR>)
		      (T
		       <TELL "You hug the Scarecrow, and he crackles, and you
both hold on a good deal longer than either of you meant to. \"You have
brains,\" you tell him. \"I always had,\" he says, \"but I did not know
it, which is the same as not having any, so thank you.\"" CR>)>
		<COND (<AND <G? ,FAREWELLS 2> <NOT ,SC-BYE>>
		       <SETG SC-BYE T>
		       <SCORE-IT 5>)>
		<RTRUE>)>>

<ROUTINE V-HUG ()
	 <COND (<EQUAL? ,PRSO ,LION ,WOODMAN ,SCARECROW> <DO-FAREWELL ,PRSO>)
	       (<EQUAL? ,PRSO ,TOTO>
		<TELL "You gather up the small warm dog and he licks your chin
once, briskly, as though signing a receipt." CR>
		<RTRUE>)
	       (T
		<TELL "That is not really a hugging sort of thing." CR>
		<RTRUE>)>>

<ROUTINE V-KNOCK-HEELS ()
	 <COND (<EQUAL? ,PRSO ,SILVER-SHOES> <DO-HEELS>)
	       (T
		<TELL "You knock on it. Nothing answers." CR>
		<RTRUE>)>>

<ROUTINE DO-HEELS ()
	 <COND (<NOT ,SHOES-WORN>
		<TELL "You are not wearing the silver shoes." CR>
		<RTRUE>)
	       (<NOT ,STAY-OFFERED>
		<TELL "You knock your heels together, feeling a little silly.
Nothing happens; you have not been told the words yet, and magic is
particular." CR>
		<RTRUE>)
	       (T
		<SETG HEELS-KNOCKED T>
		<TELL "You take Toto up in your arms and knock the heels of the
silver shoes together three times, and the shoes go still and attentive
under you." CR CR
"The shoes await your command." CR>
		<RTRUE>)>>

<ROUTINE V-KANSAS ()
	 <COND (,HEELS-KNOCKED <GO-HOME>)
	       (<AND ,STAY-OFFERED <==? ,HERE ,GLINDA-THRONE>>
		<TELL "\"Knock the heels together three times first,\" says
Glinda." CR>
		<RTRUE>)
	       (T
		<TELL "Kansas is a very long way from here, and flat, and gray,
and you would give a good deal to see it." CR>
		<RTRUE>)>>

<ROUTINE KANSAS-W-FCN ()
	 <COND (<AND <VERB? SAY-OBJ FLY WALK-TO TELL> ,HEELS-KNOCKED> <GO-HOME>)
	       (<AND <VERB? FLY> ,MONKEYS-HERE> <CAP-USE-KANSAS>)
	       (<VERB? EXAMINE>
		<TELL "Flat, and gray, and dry, and there is nobody in it who
loves you less than completely." CR>
		<RTRUE>)>>

<ROUTINE V-SAY-OBJ ()
	 <COND (<EQUAL? ,PRSO ,EPPE-W> <V-EPPE>)
	       (<EQUAL? ,PRSO ,HILLO-W> <V-HILLO>)
	       (<EQUAL? ,PRSO ,ZIZZY-W> <V-ZIZZY>)
	       (<AND <EQUAL? ,PRSO ,KANSAS-W> ,HEELS-KNOCKED> <GO-HOME>)
	       (<EQUAL? ,PRSO ,KANSAS-W> <V-KANSAS>)
	       (<AND <EQUAL? ,PRSO ,DOROTHY-W> <==? ,AUDIENCE 0> ,SUMMONED
		     <==? ,HERE ,THRONE-ROOM>>
		<HEAD-ANSWER>)
	       (<AND <==? ,HERE ,THRONE-ROOM> <==? ,AUDIENCE 0> ,SUMMONED>
		<HEAD-ANSWER>)
	       (<AND <EQUAL? ,PRSO ,GLINDA> <==? ,HERE ,GLINDA-THRONE>>
		<GLINDA-TALK>)
	       (T
		<TELL "You say it aloud. It sounds well, and nothing comes of
it." CR>
		<RTRUE>)>>

<ROUTINE GO-HOME ()
	 <SETG WON T>
	 <COND (<NOT ,SC-HOME> <SETG SC-HOME T> <SCORE-IT 20>)>
	 <TELL CR
"\"Take me home to Aunt Em!\" you say." CR CR
"Three steps. That is all the desert amounts to, in silver shoes: three
steps, each in the wink of an eye, with the wind whistling past your ears
and Toto pressed warm against you. On the third step you go rolling in
grass, and when you sit up, the shoes are gone from your feet, fallen
somewhere over the desert and lost forever, which somehow seems right.
Magic shouldn't stay in Kansas. Kansas wouldn't know what to do with
it." CR CR
"Because this is Kansas. Flat and gray and going on to the edge of the sky
in every direction, and there is a brand-new farmhouse Uncle Henry has
built, and there is Aunt Em, watering the cabbages, looking up now,
dropping her watering can." CR CR
"\"My darling child! Where in the world did you come from?\"" CR CR
"\"From the Land of Oz,\" you say gravely. \"And here is Toto, too. And
oh, Aunt Em, I'm so glad to be at home again!\"" CR CR
"Somewhere very far away, a scarecrow is ruling a city of emeralds, a tin
man is being gentle to a country of grateful people, and a lion is
sleeping in the good deep moss of his own forest, afraid of nothing. They
had what they wanted all along. So, it turns out, did you." CR CR
"    *** You have won ***" CR CR>
	 <V-SCORE>
	 <QUIT>
	 <RTRUE>>

<ROUTINE STAY-IN-OZ ()
	 <TELL CR
"Glinda looks at you a long time, and does not smile, and does not frown.
\"The shoes will keep,\" she says at last. \"Magic is patient.
Homesickness is patient too, my dear; it will wait for you like a dog by a
door.\"" CR CR
"So the Scarecrow rules his city, and you are welcome in it always; and
the Winkies bank the tinsmiths' fires for winter, and you are welcome
there too; and on warm nights a Lion walks you through his forest and
shows you, shyly, how none of it is frightening any more. It is a good
life, in the prettiest country in any world. And some evenings, on the
palace roof, under the green stars, you knock your heels together softly,
one, two, and stop, and look east, and go back down to dinner." CR CR
"Aunt Em is watering the cabbages. She looks up at the sky sometimes." CR CR
"    *** You have stayed ***" CR CR
"(There is another ending. You know the way home; you have always known
the way home.)" CR CR>
	 <V-SCORE>
	 <QUIT>
	 <RTRUE>>

"=== Remaining verb routines ==="

<ROUTINE V-CHOP () <DO-CHOP>>
<ROUTINE V-OIL () <DO-OIL>>
<ROUTINE V-ROAR () <DO-ROAR>>
<ROUTINE V-RIDE () <DO-RIDE>>
<ROUTINE V-BUILD () <DO-BUILD>>
<ROUTINE V-SCARE () <DO-SCARE-CROWS>>
<ROUTINE V-SCATTER () <DO-STRAW>>
<ROUTINE V-COVER () <DO-STRAW>>
<ROUTINE V-LIE-DOWN () <DO-SCARE-CROWS>>

<ROUTINE V-SLAP ()
	 <COND (<EQUAL? ,PRSO ,LION> <DO-SLAP>)
	       (<EQUAL? ,PRSO ,WILDCAT> <KILL-WILDCAT>)
	       (T
		<TELL "You were raised better than that." CR>
		<RTRUE>)>>

<ROUTINE V-ATTACK ()
	 <COND (<EQUAL? ,PRSO ,LION> <DO-SLAP>)
	       (<EQUAL? ,PRSO ,WILDCAT> <KILL-WILDCAT>)
	       (<EQUAL? ,PRSO ,WOLVES> <WAVE1-WIN>)
	       (<EQUAL? ,PRSO ,CROWS> <DO-SCARE-CROWS>)
	       (<EQUAL? ,PRSO ,BEES> <DO-STRAW>)
	       (<EQUAL? ,PRSO ,SPIDER> <KILL-SPIDER>)
	       (<EQUAL? ,PRSO ,WITCH-WEST>
		<TELL "She is twice your reach, and anyway you were raised
polite." CR>
		<RTRUE>)
	       (<EQUAL? ,PRSO ,HAMMER-HEADS> <HH-TRY>)
	       (<EQUAL? ,PRSO ,DOROTHY-W ,ME>
		<TELL "You have come a long way and you are not about to start
that." CR>
		<RTRUE>)
	       (<FSET? ,PRSO ,ACTORBIT>
		<TELL "You are not that sort of person, and neither is this
that sort of story." CR>
		<RTRUE>)
	       (T
		<TELL "Hitting it would accomplish nothing." CR>
		<RTRUE>)>>

<ROUTINE V-STOP ()
	 <COND (<EQUAL? ,PRSO ,WILDCAT> <KILL-WILDCAT>)
	       (<EQUAL? ,PRSO ,WOLVES> <WAVE1-WIN>)
	       (<EQUAL? ,PRSO ,CROWS> <DO-SCARE-CROWS>)
	       (<EQUAL? ,PRSO ,BEES> <DO-STRAW>)
	       (T
		<TELL "There is no stopping that." CR>
		<RTRUE>)>>

<ROUTINE V-RESCUE ()
	 <COND (<EQUAL? ,PRSO ,MOUSE-QUEEN ,WILDCAT> <KILL-WILDCAT>)
	       (<AND <EQUAL? ,PRSO ,LION> <==? ,WILDCAT-STATE 3>> <MICE-RESCUE>)
	       (<AND <EQUAL? ,PRSO ,SCARECROW> <==? ,SCARE-STATE 2>>
		<STORK-RESCUE>)
	       (<AND <EQUAL? ,PRSO ,WOODMAN> <==? ,WOOD-STATE 2>> <FIX-WOODMAN>)
	       (T
		<TELL "There is nothing you can do for that just now." CR>
		<RTRUE>)>>

<ROUTINE V-STUFF ()
	 <COND (<EQUAL? ,PRSO ,SCARECROW ,CLOTHES ,STRAW-PILE> <DO-STUFF>)
	       (<AND <EQUAL? ,PRSO ,FIREWOOD> <==? ,HERE ,CASTLE-KITCHEN>>
		<DO-CHORE 3>)
	       (T
		<TELL "You cannot usefully stuff that." CR>
		<RTRUE>)>>

<ROUTINE V-WIPE ()
	 <COND (<EQUAL? ,PRSO ,STOLEN-SHOE>
		<PERFORM ,V?BRUSH ,STOLEN-SHOE>
		<RTRUE>)
	       (<EQUAL? ,PRSO ,WOODMAN>
		<TELL "You wipe the Tin Woodman's face dry with your apron
before anything can rust. He thanks you, at length." CR>
		<RTRUE>)
	       (T
		<TELL "It does not need drying." CR>
		<RTRUE>)>>

<ROUTINE V-ASK-FOR ()
	 <COND (<AND <EQUAL? ,PRSO ,WINKIES> ,WITCH-DEAD> <WINKIE-HELP>)
	       (<EQUAL? ,PRSO ,STORK> <STORK-RESCUE>)
	       (<EQUAL? ,PRSO ,MOUSE-QUEEN> <MICE-RESCUE>)
	       (T
		<TELL "There is no help to be had there just now." CR>
		<RTRUE>)>>

<ROUTINE V-HELP ()
	 <TELL
"THE SILVER SHOES. You are Dorothy, and you are trying to get home." CR CR
"Ordinary commands work: LOOK, EXAMINE something, TAKE, DROP, INVENTORY,
NORTH and the other directions, WAIT, SCORE, SAVE, RESTORE, QUIT." CR CR
"Your friends are the puzzle. When something is in the way, ask yourself
which of them is shaped like the answer: the Scarecrow plans and is safe
to throw, the Tin Woodman chops and builds and cannot be stung, the Lion
leaps and roars and fights. You can name them (WOODMAN, CHOP THE TREE) or
just say what needs doing (CHOP THE TREE); both always work, and they
will act on their own if you leave them long enough." CR CR
"Nobody dies in this story except by very determined effort. Toto is
always safe. Go on." CR>
	 <RTRUE>>

<ROUTINE KISS-MARK-FCN ()
	 <COND (<VERB? EXAMINE>
		<COND (,WITCH-N-GONE
		       <TELL "A round shining mark on your forehead where the
Witch of the North kissed you. It does not come off and nothing wicked
will go near it." CR>)
		      (T
		       <TELL "Your forehead, so far as you know, is
ordinary." CR>)>
		<RTRUE>)>>

<ROUTINE DOROTHY-W-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "You are a small, sensible person from Kansas in a blue
and white gingham dress, and by local standards you are a great
sorceress." CR>
		<RTRUE>)>>

<ROUTINE CITY-W-FCN ()
	 <COND (<AND <VERB? FLY WALK-TO SAY-OBJ TELL> ,MONKEYS-HERE> <DO-FLY>)
	       (<VERB? EXAMINE>
		<TELL "The City of Emeralds, in the middle of the country,
where Oz the Great lives, or lived." CR>
		<RTRUE>)>>

<ROUTINE BRACELET-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL "A diamond bracelet from the Winkies, who would not take
no for an answer, and gave one to Toto as well." CR>
		<RTRUE>)>>

<ROUTINE WITCH-WEST-EYE-FCN () <RFALSE>>

<ROUTINE FOREST-ROAD-FCN (RARG)
	 <COND (<AND <==? .RARG ,M-ENTER> <==? ,SCARE-STATE 1>
		     <==? ,WOOD-STATE 0>>
		<TELL CR
"The Scarecrow steps into a hole in the broken bricks and falls full
length, and gets up, and dusts himself off. \"Why didn't you walk around
the hole?\" you ask. \"I don't know enough,\" he replies cheerfully. \"My
head is stuffed with straw, you know.\"" CR>
		<RFALSE>)>>

<ROUTINE TOTO-DESCFCN (ARG)
	 <COND (<==? .ARG ,M-OBJDESC>
		<COND (<AND <==? ,STORM-PHASE 0> <IN? ,TOTO ,FARMHOUSE>>
		       <TELL "Toto is under the bed, with only his nose
showing." CR>)
		      (T <TELL "Toto is here, being a dog about it." CR>)>
		<RTRUE>)>>

<ROUTINE V-LAUNCH-BARE ()
	 <COND (<AND <==? ,HERE ,RIVERBANK> ,RAFT-BUILT> <RIVER-LAUNCH>)
	       (T
		<TELL "There is nothing here to launch." CR>
		<RTRUE>)>>

<ROUTINE V-CROSS-BARE ()
	 <COND (<AND <==? ,HERE ,SECOND-GORGE> <==? ,BRIDGE-STATE 1>>
		<SGORGE-CROSS>)
	       (<AND <==? ,HERE ,RIVERBANK> ,RAFT-BUILT> <RIVER-LAUNCH>)
	       (<==? ,HERE ,GORGE-EDGE> <DO-LEAP>)
	       (T
		<TELL "There is nothing here to cross." CR>
		<RTRUE>)>>

<ROUTINE FRIEND-W-FCN ()
	 <COND (<AND <==? ,HERE ,STORK-BEND> <==? ,SCARE-STATE 2>
		     <VERB? TELL RESCUE ASK-FOR STOP EXAMINE>>
		<COND (<VERB? EXAMINE>
		       <TELL "Far out in the water, a small blue-hatted figure
clings to a pole, looking as lonely as a scarecrow can look." CR>
		       <RTRUE>)
		      (T <STORK-RESCUE>)>)
	       (<VERB? EXAMINE>
		<TELL "Your friends are here, or they are not, and either way
you are thinking about them." CR>
		<RTRUE>)>>

"THROW/POUR/SPLASH: the one command that ends a Wicked Witch."
<ROUTINE V-SPLASH ()
	 <COND (<AND <EQUAL? ,PRSO ,WATER ,BUCKET ,GLOBAL-WATER ,SPRING>
		     <IN? ,WITCH-WEST ,HERE>
		     <NOT ,WITCH-DEAD>>
		<MELT-WITCH>)
	       (<AND <EQUAL? ,PRSI ,WITCH-WEST> <NOT ,WITCH-DEAD>>
		<COND (<EQUAL? ,PRSO ,WATER ,BUCKET ,GLOBAL-WATER>
		       <MELT-WITCH>)
		      (T
		       <TELL "It bounces off her, and she laughs at you, and
goes on wearing your shoe." CR>
		       <RTRUE>)>)
	       (<AND <EQUAL? ,PRSO ,WITCH-WEST> <NOT ,WITCH-DEAD>
		     <IN? ,BUCKET ,HERE>>
		<MELT-WITCH>)
	       (<EQUAL? ,PRSO ,BUCKET ,WATER>
		<TELL "You tip the water out onto the flagstones, and it does
nothing at all except make a puddle. There is a well outside; the bucket
fills again." CR>
		<RTRUE>)
	       (T
		<TELL "There is nothing here worth throwing, and nobody here
worth throwing it at." CR>
		<RTRUE>)>>

<ROUTINE V-CARRY-TO ()
	 <COND (<EQUAL? ,PRSI ,KANSAS-W ,CITY-W> <PERFORM ,V?SAY-OBJ ,PRSI> <RTRUE>)
	       (T
		<TELL "You cannot carry that there." CR>
		<RTRUE>)>>

"Aunt Em is only reachable in the final tableau, but a proper name with
no ACTION routine gets the engine's \"The Aunt Em pauses...\" — so she
answers for herself."
<ROUTINE AUNT-EM-FCN ()
	 <COND (<TALKING?>
		<TELL "\"From the Land of Oz,\" you say again, and she says
\"Well, I never,\" again, and neither of you minds." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL "Aunt Em, who never smiled, smiling, with a watering can
at her feet and both arms out." CR>
		<RTRUE>)
	       (<VERB? KISS HUG>
		<TELL "You are already being hugged. It is going to go on for
some time." CR>
		<RTRUE>)>>
