"CACT4 - The Count of Monte Cristo, ACTS FOUR AND FIVE: the four capers
in Paris, the three reveals, the pardon, and the white sail."

"=== The hub ==="

<ROUTINE SALON-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-END> <PARIS-TICK> <RFALSE>)
	       (<AND <EQUAL? .RARG ,M-ENTER> ,PRESS-RUN <NOT ,MERCEDES-CAME>>
		<SETG MERCEDES-CAME T>
		<MERCEDES-VISIT>
		<RFALSE>)
	       (T <RFALSE>)>>

<GLOBAL MERCEDES-CAME <>>

<ROUTINE MERCEDES-VISIT ()
	 <TELL
"A woman is waiting in your salon at midnight, veiled, and she does not
unveil, and she does not need to." CR CR
"\"Edmond,\" she says. Nobody unmasks you; she simply knows. \"Do what
you must to my husband. Leave me my son.\" You give her your word, and
she goes out into the Champs-Elysees on foot, like a servant." CR>
	 <RTRUE>>

<ROUTINE ALI-FCN ()
	 <COND (<VERB? TELL>
		<COND (<AND ,PRESS-RUN <NOT ,JANINA-DOCS>>
		       <TELL
"Ali bars the door with a bow, and touches the satin satchel that is
not in your hand. Master: the papers?" CR>)
		      (T
		       <TELL
"Ali bows. He has no tongue and no need of one; he agrees with you
about everything except your own safety." CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL "A Nubian in white, at the door, with a hand like a
gate." CR>
		<RTRUE>)>>

<ROUTINE CSTUDY-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-END> <PARIS-TICK> <RFALSE>)
	       (T <RFALSE>)>>

<ROUTINE STREET-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-END> <PARIS-TICK> <RFALSE>)
	       (T <RFALSE>)>>

<ROUTINE STREET-SE ()
	 <COND (,MORCERF-DONE
		<TELL "The Chamber has voted. There is nothing left in that
gallery but velvet." CR>
		<RFALSE>)
	       (T ,PEERS)>>

<ROUTINE STREET-S ()
	 <COND (,DINNER-HELD ,ASSIZES)
	       (T
		<TELL
"The Assizes are sitting on somebody else's business today. Yours is
not yet on the list." CR>
		<RFALSE>)>>

<ROUTINE STREET-SW () ,VHALL>

<ROUTINE STREET-IN ()
	 <TELL
"The coach goes out through the barrier and down to Auteuil, and
Bertuccio, on the box, does not say one word the whole way." CR CR>
	 ,AUTSALON>

<ROUTINE AUT-OUT ()
	 <TELL "Back through the barrier, into the gaslight." CR CR>
	 ,STREET>

"=== Caper A: Danglars, the bleeding ==="

<ROUTINE DANGLARS4-FCN ()
	 <COND (<AND <VERB? SHOW GIVE> <EQUAL? ,PRSO ,CREDIT-LETTER>>
		<OPEN-THE-CREDIT>
		<RTRUE>)
	       (<AND <VERB? TELL> ,PRSI> <DANGLARS4-TOPIC>)
	       (<VERB? TELL>
		<COND (,TELEGRAPH-DONE
		       <TELL
"\"Monsieur le Comte.\" He is sweating through his collar. \"Do you
ever have the feeling that the sun rises for somebody else?\"" CR>)
		      (,CREDIT-OPEN
		       <TELL
"\"Unlimited,\" he says again, to himself, the way other men say their
prayers." CR>)
		      (T
		       <TELL
"\"Monsieur le Comte de Monte Cristo. Sit. What can the house of
Danglars do for a man of your reputation?\" He is already valuing your
coat." CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"Baron Danglars, filling his chair like a sack of coin. Twenty-three
years and a hundred thousand a year, and the eyes have not changed at
all." CR>
		<RTRUE>)>>

<ROUTINE DANGLARS4-TOPIC ()
	 <COND (<EQUAL? ,PRSI ,DANTES-T>
		<TELL
"\"A sailor? I knew a sailor once. Drowned, I believe.\" He rings for
wine. \"Everyone drowns eventually, monsieur le Comte. It is the
principal business of the sea.\"" CR>)
	       (<EQUAL? ,PRSI ,SPAIN-T>
		<COND (,TELEGRAPH-DONE
		       <TELL
"\"Do not,\" he says, \"speak to me of Spain.\"" CR>)
		      (T
		       <TELL
"\"Spanish bonds? Solid. Don Carlos is in Bourges under guard and the
funds know it. I am in rather deep, since you ask, and rather happy
about it.\"" CR>)>)
	       (<EQUAL? ,PRSI ,MONEY-T>
		<TELL
"\"Money is the only honest man I have ever met. It never pretends to
be anything else.\"" CR>)
	       (T
		<TELL
"\"I am a banker, monsieur, not a philosopher. Ask me a question with a
number in it.\"" CR>)>
	 <RTRUE>>

<ROUTINE OPEN-THE-CREDIT ()
	 <COND (,CREDIT-OPEN
		<TELL "The credit is open. He is still not over it." CR>)
	       (T
		<SETG CREDIT-OPEN T>
		<SETG CAPERS-STARTED <+ ,CAPERS-STARTED 1>>
		<ADD-SCORE 5>
		<TELL
"\"On the house of Thomson and French, of Rome. Unlimited.\" He reads
the word three times and looks up at you with the expression of a man
who has heard a noise in the cellar." CR CR
"\"Unlimited,\" he agrees. You draw your first million with the smile
of a man taking back his own." CR>)>
	 <RTRUE>>

<ROUTINE OPERATOR-FCN ()
	 <COND (<AND <VERB? GIVE> <EQUAL? ,PRSO ,BANKNOTES>>
		<PAY-THE-OPERATOR>
		<RTRUE>)
	       (<VERB? TELL>
		<COND (,OPERATOR-PAID
		       <TELL
"\"Up the ladder then, monsieur, and tell me what to send, and let us
neither of us ever speak of it.\"" CR>)
		      (T
		       <TELL
"\"A thousand francs a year, monsieur, and a hundred off for every
signal I miss, and a pension at the end if I live to see it.\" He goes
back to his peas. \"My only real enemy is the dormice.\"" CR CR
"\"And what would you do,\" you ask, \"with fifteen years of it at
once?\"" CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A man of a thousand francs a year on his knees among the peas, who has
never in his life read a word of what passes over his head." CR>
		<RTRUE>)>>

<ROUTINE PAY-THE-OPERATOR ()
	 <COND (,OPERATOR-PAID
		<TELL "He has the notes, and he has counted them twice." CR>)
	       (T
		<SETG OPERATOR-PAID T>
		<REMOVE ,BANKNOTES>
		<ADD-SCORE 5>
		<TELL
"Fifteen notes of a thousand francs, laid on the wall between the pea
sticks." CR CR
"\"Sir,\" he says, without touching them, \"you are tempting me?\"" CR
"\"Just so.\" He puts them in his shirt and stands up, and he is a
different man, and he knows it." CR>)>
	 <RTRUE>>

<ROUTINE SIGNAL-LEVERS-FCN ()
	 <COND (<VERB? SET TURN MOVE TAKE PUSH RAISE>
		<WORK-THE-SIGNAL>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"Black jointed arms on a spindle, and a cord to each. Through the glass
the next tower is twitching out the fortunes of France, one angle at a
time." CR>
		<RTRUE>)>>

<ROUTINE WORK-THE-SIGNAL ()
	 <COND (,TELEGRAPH-DONE
		<TELL "The dispatch has run. It cannot be recalled, which is
the beauty of it." CR>)
	       (<NOT ,OPERATOR-PAID>
		<TELL
"The keeper's hand hovers over the cord, and falls. \"Sir, my
right-hand correspondent is signalling. I should be fined.\"" CR>)
	       (T
		<SETG TELEGRAPH-DONE T>
		<ADD-SCORE 5>
		<TELL
"He works the arms to your dictation without once asking what they
mean, and down the line, tower after tower, a lie goes to Paris at the
speed of light: Don Carlos has crossed the Bidassoa. Spain is in
revolt." CR CR
"By evening the funds are falling. By morning the Baron has sold every
Spanish bond he owns into the panic, and by noon the government prints
the denial." CR CR
"The Baron is lighter by a million, and heavier by a suspicion." CR>)>
	 <RTRUE>>

"=== Caper B: Morcerf, the exposure ==="

<ROUTINE HAYDEE-FCN ()
	 <COND (<AND <VERB? TELL> ,PRSI> <HAYDEE-TOPIC>)
	       (<VERB? TELL>
		<TELL
"\"My lord.\" She rises when you come in and stays standing until you
sit, and no argument of yours has ever changed that." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"The daughter of Ali Pasha of Janina, twenty years old, in a room that
smells of somewhere farther east than Greece." CR>
		<RTRUE>)>>

<ROUTINE HAYDEE-TOPIC ()
	 <COND (<EQUAL? ,PRSI ,JANINA-T>
		<SETG JANINA-ASKED T>
		<TELL
"\"I was four years old. The French officer my father trusted with the
castle of Yanina took the Sultan's money and opened the gate.\"" CR CR
"\"My father's head went to Constantinople in a bag. My mother died on
the road. I was sold in the market at eleven, and the officer who sold
me signed the receipt.\"" CR>)
	       (<EQUAL? ,PRSI ,PROOF-T ,SATCHEL>
		<GIVE-THE-SATCHEL>)
	       (<EQUAL? ,PRSI ,FATHER-T>
		<TELL
"\"Ali Tepelini, pasha of Yanina. He kept a lion in the courtyard and
he was gentler than the lion.\"" CR>)
	       (<EQUAL? ,PRSI ,DANTES-T>
		<TELL
"\"He bought my freedom and then gave it to me, which is a different
thing, and rarer. A man does not do that twice in a world.\"" CR>)
	       (T
		<TELL
"\"Ask me about Yanina, my lord. Everything else in me is only
waiting.\"" CR>)>
	 <RTRUE>>

<ROUTINE GIVE-THE-SATCHEL ()
	 <COND (,JANINA-DOCS
		<TELL "\"You have them. Use them, and let me stand up in
front of those old men and say my father's name.\"" CR>)
	       (<NOT ,JANINA-ASKED>
		<TELL
"\"Proof of what, my lord?\" She waits. She will not open that door
unless you name Yanina out loud." CR>)
	       (T
		<SETG JANINA-DOCS T>
		<SETG CAPERS-STARTED <+ ,CAPERS-STARTED 1>>
		<MOVE ,SATCHEL ,WINNER>
		<ADD-SCORE 5>
		<TELL
"She brings out a satin satchel: her birth record, her baptism record,
and the bill of her own sale, signed by a French colonel. Fernand
Mondego." CR CR
"\"If they ask me to say it in front of France,\" she says, \"I am
ready.\"" CR>)>
	 <RTRUE>>

<ROUTINE SATCHEL-FCN ()
	 <COND (<VERB? DROP PUT GIVE>
		<COND (<AND <VERB? GIVE> <EQUAL? ,PRSI ,BEAUCHAMP>>
		       <RFALSE>)
		      (T
		       <TELL "Haydee put it in your hands. It stays there."
CR>
		       <RTRUE>)>)>>

<ROUTINE BEAUCHAMP-FCN ()
	 <COND (<AND <VERB? TELL GIVE SHOW>
		     <OR <EQUAL? ,PRSI ,JANINA-T>
			 <EQUAL? ,PRSO ,SATCHEL>>>
		<RUN-THE-STORY>
		<RTRUE>)
	       (<VERB? TELL>
		<COND (,PRESS-RUN
		       <TELL
"\"The Chamber has taken it up. You have made me the most disliked man
in Paris, monsieur, and I have never been happier.\"" CR>)
		      (T
		       <TELL
"\"Beauchamp, of l'Impartial. I can smell a story through a wax seal,
monsieur le Comte, and you smell like a whole edition.\"" CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL "A journalist with ink to the elbow and the pleasant
amorality of a man who prints what is true." CR>
		<RTRUE>)>>

<ROUTINE RUN-THE-STORY ()
	 <COND (,PRESS-RUN
		<TELL "It has run. Paris is reading it in the cafes." CR>)
	       (<NOT ,JANINA-ASKED>
		<TELL
"\"Yanina? What of Yanina?\" You have nothing to tell him yet but a
place name, and he prints better things than place names." CR>)
	       (T
		<SETG PRESS-RUN T>
		<ADD-SCORE 5>
		<TELL
"He listens with his pen down, which from Beauchamp is reverence." CR CR
"Next morning, four lines at the foot of a column: We hear from Yanina
that the castle was delivered to the Turks by a French officer in whom
Ali Pasha had reposed entire confidence, and who was then called
Fernand." CR CR
"Within the week the Chamber of Peers appoints a committee of inquiry,
and the Count de Morcerf demands to be heard." CR>)>
	 <RTRUE>>

<ROUTINE PEERS-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-END> <PEERS-TICK> <RFALSE>)
	       (<AND <EQUAL? .RARG ,M-ENTER> ,JANINA-DOCS ,PRESS-RUN>
		<MOVE ,HAYDEE ,PEERS>
		<RFALSE>)
	       (T <RFALSE>)>>

<GLOBAL PEERS-TURNS 0>

<ROUTINE PEERS-TICK ()
	 <COND (,MORCERF-DONE <RFALSE>)
	       (<NOT ,PRESS-RUN>
		<TELL
"The gallery is empty and the benches are covered. The committee sits
when there is something to sit on." CR>
		<RTRUE>)
	       (<NOT ,JANINA-DOCS>
		<THE-DUEL>
		<RTRUE>)>
	 <SETG PEERS-TURNS <+ ,PEERS-TURNS 1>>
	 <COND (<EQUAL? ,PEERS-TURNS 1>
		<TELL
"Morcerf is magnificent. Thirty years of service, a wound at
Ligny, the honor of a soldier; and the committee is halfway to
apologizing when the usher announces a witness." CR>
		<RTRUE>)
	       (T <THE-TESTIMONY> <RTRUE>)>>

<ROUTINE THE-TESTIMONY ()
	 <SETG MORCERF-DONE T>
	 <SETG SALON-SCENE T>
	 <REMOVE ,SATCHEL>
	 <ADD-SCORE 15>
	 <TELL
"A veiled woman comes down to the floor of the Chamber and puts back
her veil." CR CR
"\"I am Haydee, the daughter of Ali Tepelini, pasha of Yanina, and of
Vasiliki, his beloved wife.\" The documents go along the bench from
hand to hand; the seal of the Sublime Porte is verified; the bill of
sale is read out with the signature on it." CR CR
"The vote is taken by standing. Nobody stays seated. Morcerf goes out
of the Chamber through a corridor of turned backs." CR CR>
	 <MOVE ,MORCERF ,SALON>
	 <GOTO ,SALON>
	 <TELL CR
"That evening he is in your salon with his hat on, not sitting down."
CR CR
"\"I know you only as an adventurer sewn up in gold and jewellery. It
is your real name I want, monsieur. Say it.\"" CR CR
"There is a wardrobe in your study, one room east, with something
folded at the very bottom of it. The scene will wait. Scenes like this
always wait." CR>
	 <RTRUE>>

<ROUTINE THE-DUEL ()
	 <SETG SCENE-LOCK T>
	 <TELL
"You go up into the gallery with a rumor and no papers, and the
committee adjourns for want of proof, and the Count de Morcerf leaves
the Chamber a wronged soldier." CR CR
"His seconds call at eight that evening. At dawn in the Bois de
Vincennes he puts his ball through the adventurer nobody in Paris could
quite name." CR CR
"They bury you under the only title you ever showed them. The abbe's
treasure keeps its last secret; Danglars dines well for thirty more
years; a paralyzed old man in the Faubourg Saint-Honore waits for a
visitor who never comes." CR CR
"Vengeance is a science, Edmond. Faria told you: first, the proof." CR>
	 <JIGS-UP "">>

<ROUTINE MORCERF-FCN ()
	 <COND (<VERB? TELL>
		<COND (<AND <EQUAL? ,HERE ,SALON> ,SALON-SCENE>
		       <TELL
"\"I know you only as an adventurer sewn up in gold and jewellery. It
is your real name I want, monsieur. Say it.\"" CR>)
		      (T
		       <TELL
"The Count de Morcerf does not converse with foreigners of uncertain
extraction. Fuses do not chat." CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A lieutenant-general and a peer of France, with a Catalan fisherman
somewhere inside him, screaming." CR>
		<RTRUE>)>>

<ROUTINE MORCERF-REVEAL ()
	 <COND (,JACKET-REVEAL <RFALSE>)>
	 <SETG JACKET-REVEAL T>
	 <SETG SALON-SCENE <>>
	 <SETG IDENTITY 4>
	 <MOVE ,SAILOR-JACKET ,WINNER>
	 <REMOVE ,MORCERF>
	 <COND (<NOT <EQUAL? ,HERE ,SALON>> <GOTO ,SALON <>>)>
	 <ADD-SCORE 5>
	 <TELL
"You go east to the study, and the scene waits for you the way a
duelist waits, and you come back in a sailor's jacket and hat with your
hair fallen loose out of it." CR CR
"\"Look at me. A face you must often have seen in your dreams since
your marriage with Mercedes, my betrothed.\"" CR CR
"He goes out backwards, feeling for the doorframe. From the courtyard,
one cry: Edmond Dantes! And then, when his wife's and his son's coach
has cleared the gate, one shot." CR>
	 <RTRUE>>

"=== Caper C: Villefort, the house of poison ==="

<ROUTINE AUTSALON-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-END> <PARIS-TICK> <RFALSE>)
	       (T <RFALSE>)>>

<ROUTINE BERTUCCIO-FCN ()
	 <COND (<AND <VERB? TELL> ,PRSI> <BERTUCCIO-TOPIC>)
	       (<VERB? TELL> <BERTUCCIO-CONFESS>)
	       (<VERB? EXAMINE>
		<TELL
"Your steward, a Corsican with a vendetta behind him, standing with his
back to the garden door and sweating in a cold room." CR>
		<RTRUE>)>>

<ROUTINE BERTUCCIO-CONFESS ()
	 <COND (,BERTUCCIO-TOLD
		<TELL
"\"Under the plantain tree, excellency. I have said it once and it did
not kill me, so I can say it again.\"" CR>)
	       (T
		<SETG BERTUCCIO-TOLD T>
		<SETG CAPERS-STARTED <+ ,CAPERS-STARTED 1>>
		<ADD-SCORE 10>
		<TELL
"\"I declared the vendetta against him because he would not avenge my
brother. I followed him to this house. One night in September I saw him
come down into that garden with a spade and a box, and I put my knife
in his back under the plantain tree.\"" CR CR
"\"And then I dug up what he had buried, excellency, because I thought
it was money.\" He has to stop. \"It was a child, monsieur. A living
child.\"" CR>)>
	 <RTRUE>>

<ROUTINE BERTUCCIO-TOPIC ()
	 <COND (<EQUAL? ,PRSI ,VENDETTA-T>
		<BERTUCCIO-CONFESS>)
	       (<EQUAL? ,PRSI ,BENEDETTO-T>
		<TELL
"\"I raised him, excellency, on my sister-in-law's milk and my own bad
judgment. He robbed her, and he burned her feet to make her say where
the money was, and he is in Paris now calling himself a prince.\"" CR>)
	       (<EQUAL? ,PRSI ,VILLEFORT-T ,VILLEFORT4>
		<TELL
"\"He did not die of my knife. God did not want him yet.\" Bertuccio
crosses himself with his left hand, which is a Corsican thing." CR>)
	       (T
		<TELL "\"Ask me in the salon, excellency. Not out here.\"" CR>)>
	 <RTRUE>>

<ROUTINE GARDEN-EARTH-FCN ()
	 <COND (<VERB? DIG MUNG MOVE>
		<DIG-THE-GARDEN>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"Turned earth under a plantain tree, and it has been turned before." CR>
		<RTRUE>)>>

<ROUTINE DIG-THE-GARDEN ()
	 <COND (,AUTEUIL-BOX
		<TELL "The hole is open and the ironwork is in your hands."
CR>)
	       (<NOT <IN? ,SPADE ,WINNER>>
		<TELL "Two feet of packed earth, and no spade. There is one
in the study." CR>)
	       (T
		<SETG AUTEUIL-BOX T>
		<MOVE ,IRON-BOX ,WINNER>
		<ADD-SCORE 5>
		<TELL
"Two feet down, the spade turns up the ironwork of a small box, rusted
to lace, with nothing at all inside it." CR CR
"Nothing at all is exactly what you need. What your guests will see in
it is their own business." CR>)>
	 <RTRUE>>

<ROUTINE DINNER-FCN ()
	 <COND (<VERB? HOST EXAMINE TELL>
		<HOLD-THE-DINNER>
		<RTRUE>)>>

<ROUTINE HOLD-THE-DINNER ()
	 <COND (,DINNER-HELD
		<TELL "The dinner is given. Paris is still talking about it."
CR>)
	       (<NOT ,BERTUCCIO-TOLD>
		<TELL
"You could set a table here tonight, and say nothing over it, and the
whole thing would be wasted. Bertuccio knows what this house is. Get it
out of him first." CR>)
	       (<NOT ,AUTEUIL-BOX>
		<TELL
"A story wants a thing in a hand. There is turned earth under the
plantain tree and a spade in your study." CR>)
	       (T
		<SETG DINNER-HELD T>
		<SETG VILLEFORT-SHAKEN T>
		<ADD-SCORE 5>
		<TELL
"Your guests arrive at eight: Danglars and his wife, the Villeforts,
the Cavalcantis. After dinner you take them into the garden with
candles, to see the improvements." CR CR
"\"A crime has been committed in this house. Digging, my man found a
box, and in it the skeleton of a newly born infant.\" Madame Danglars's
arm turns to stone on yours. Villefort's trembles like a wire, and does
not stop." CR>)>
	 <RTRUE>>

"=== The poison thread ==="

<ROUTINE VHALL-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-END> <PARIS-TICK> <RFALSE>)
	       (T <RFALSE>)>>

<ROUTINE NOIRTIER-ROOM-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-END> <PARIS-TICK> <RFALSE>)
	       (<AND <EQUAL? .RARG ,M-ENTER> ,ASSIZES-DONE
		     <NOT ,WRATH-CHECKED>>
		<VILLEFORT-BURSTS-IN>
		<RFALSE>)
	       (T <RFALSE>)>>

<ROUTINE NOIRTIER-NPC-FCN ()
	 <COND (<AND <VERB? TELL> ,PRSI> <NOIRTIER-TOPIC>)
	       (<VERB? TELL> <NOIRTIER-SPEAKS>)
	       (<VERB? EXAMINE>
		<TELL
"A corpse with living eyes. The dictionary and the bell-cord on the
table beside him are his whole vocabulary, and he is more eloquent than
his son." CR>
		<RTRUE>)>>

<ROUTINE NOIRTIER-SPEAKS ()
	 <COND (,NOIRTIER-TOLD
		<TELL
"The eyes go to the dictionary, and to the door his son's wife uses,
and back to you. He has said it once. He is not a man who repeats
himself." CR>)
	       (T
		<SETG NOIRTIER-TOLD T>
		<TELL
"You read to him from the dictionary and he blinks once for the letter
he wants, and it takes an hour, and at the end of the hour he has spelt
out two things." CR CR
"The first is that Barrois drank from Valentine's glass and died in
twenty minutes. The second is that he has been feeding his
granddaughter brucine, a grain at a time, for a year, so that when the
poison came it would find her ready." CR>)>
	 <RTRUE>>

<ROUTINE NOIRTIER-TOPIC ()
	 <COND (<EQUAL? ,PRSI ,POISONER-T>
		<COND (<NOT ,NOIRTIER-TOLD> <NOIRTIER-SPEAKS>)
		      (T
		       <TELL
"The eyes leave yours and go to the door that Madame de Villefort uses,
and stay there, and come back." CR CR
"He has named her without a word, and there is not a court in France
that could use it." CR>)>)
	       (<EQUAL? ,PRSI ,VALENTINE-T ,VALENTINE>
		<TELL
"Something happens in the eyes that is very close to weeping and is not
allowed to become it." CR>)
	       (<EQUAL? ,PRSI ,LETTER-T ,DANTES-T>
		<TELL
"You tell him, because he is the only man alive who could care, that a
letter was once addressed to him at the Rue Coq-Heron, and that it was
burnt by his son, and that the man who carried it paid for it." CR CR
"The old eyes go to the dictionary and spell out one word, slowly, and
the word is: forgive." CR>)
	       (T
		<TELL "The eyes wait. They are two loaded pistols and they
are in no hurry." CR>)>
	 <RTRUE>>

<ROUTINE VALENTINE-FCN ()
	 <COND (<AND <VERB? GIVE> <EQUAL? ,PRSO ,PILL>>
		<SAVE-VALENTINE>
		<RTRUE>)
	       (<VERB? TELL>
		<TELL
"\"They tell me it is my nerves,\" she says. \"Barrois had nerves too,
apparently.\" She is nineteen and quite unafraid, which is worse." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"White as the curtains, and paler every week, and beside her a glass of
lemonade nobody will take away." CR>
		<RTRUE>)>>

<ROUTINE SAVE-VALENTINE ()
	 <COND (,VALENTINE-SAVED
		<TELL "She is buried, and alive, and both are your doing."
CR>)
	       (<NOT ,NOIRTIER-TOLD>
		<TELL
"You could give it to her now and be guessing. Her grandfather knows
what is in that glass and who puts it there. Ask him first." CR>)
	       (T
		<SETG VALENTINE-SAVED T>
		<REMOVE ,PILL>
		<REMOVE ,VALENTINE>
		<ADD-SCORE 10>
		<TELL
"\"Trust me as you would trust Providence. Sleep, and whatever you
hear, do not wake.\"" CR CR
"She dies that night, to the satisfaction of everyone who wanted her
to, and the house fills with the particular horror of a family counting
its own. Two nights later you take her out of the vault yourself, warm,
and asleep, and nineteen." CR>)>
	 <RTRUE>>

"=== The Assizes ==="

<ROUTINE ASSIZES-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-END> <ASSIZES-TICK> <RFALSE>)
	       (T <RFALSE>)>>

<GLOBAL ASSIZES-TURNS 0>

<ROUTINE ASSIZES-TICK ()
	 <COND (,ASSIZES-DONE <PARIS-TICK> <RFALSE>)>
	 <SETG ASSIZES-TURNS <+ ,ASSIZES-TURNS 1>>
	 <COND (<EQUAL? ,ASSIZES-TURNS 1>
		<TELL
"Villefort opens for the crown with his usual marble calm. The prisoner
Benedetto, who was arrested at his own betrothal to Mademoiselle
Danglars, listens as though the whole thing were a play he has already
read." CR>
		<RTRUE>)
	       (T <THE-PARENTAGE-BOMB> <RTRUE>)>>

<ROUTINE THE-PARENTAGE-BOMB ()
	 <SETG ASSIZES-DONE T>
	 <SETG VILL-EXPIRE 1>
	 <ADD-SCORE 10>
	 <TELL
"\"Your name?\" \"Benedetto.\" \"Your profession?\" \"First an
assassin, then a thief.\" The court laughs, because it does not yet
know." CR CR
"\"Your father's name?\"" CR CR
"\"My father is procureur du roi. His name is Villefort.\"" CR CR>
	 <COND (,CADEROUSSE-LETTER
		<TELL
"The signed letter Caderousse wrote in your study goes up to the bench
and is read aloud, and there is nothing left to argue about." CR CR>)>
	 <TELL
"Uproar. Villefort, gray as his own gown, does not deny it. His
carriage goes home at a gallop." CR>
	 <RTRUE>>

<ROUTINE VILLEFORT4-FCN ()
	 <COND (<VERB? TELL>
		<COND (,ASSIZES-DONE
		       <TELL "He is past hearing anybody." CR>)
		      (T
		       <TELL
"\"Monsieur le Comte. You keep an interesting house at Auteuil.\" The
marble has a hairline crack in it now, and he knows you can see it."
CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"The procureur du roi, prosecuting: marble, with a hairline crack
running from the dinner at Auteuil straight down." CR>
		<RTRUE>)>>

<ROUTINE VILLEFORT-BURSTS-IN ()
	 <COND (<NOT <EQUAL? ,IDENTITY 1>>
		<TELL
"Down the corridor, a door goes back against a wall: Villefort, home at
a gallop, going from room to room in his own house looking for
something to hold on to." CR CR
"He would say anything to a priest tonight. He will say nothing at all
to a foreign count." CR>
		<RTRUE>)>
	 <TELL
"The door goes back against the wall and Villefort is in the room,
still in his gown, and stops dead at the sight of a priest." CR CR
"\"Busoni. Always Busoni. Do you never appear but to escort death?\""
CR>
	 <RTRUE>>

<ROUTINE VILLEFORT-UNMASKED ()
	 <COND (,WRATH-CHECKED <RFALSE>)>
	 <SETG WRATH-CHECKED T>
	 <ADD-SCORE 5>
	 <TELL
"You take off the gray wig." CR CR
"\"It is the face of the Count of Monte Cristo!\"" CR
"\"You must go farther back.\"" CR
"He looks, and the years come off, and his mouth opens." CR CR
"\"I am Edmond Dantes!\"" CR CR
"And then he takes your wrist, which nobody has done in twenty years,
and says \"Then come here!\" and pulls you up the stairs to a room
where his wife has taken her own poison, and the boy Edouard is lying
across her knees." CR CR
"Something goes out of you like a fever breaking: the certainty that
God was with you." CR CR
"\"Are you well avenged?\" He asks it quite reasonably. Then his mind
goes out like a lamp, and he begins, on his hands and knees, to look
for his papers." CR CR>
	 <REMOVE ,VILLEFORT4>
	 <MOVE ,WIG ,WINNER>
	 <MOVE ,CASSOCK ,WINNER>
	 <SETG IDENTITY 1>
	 <DANGLARS-FLEES>
	 <RTRUE>>

<ROUTINE DANGLARS-FLEES ()
	 <TELL
"That same week the Baron Danglars draws his last five millions on a
Roman house and leaves Paris by the Italian road, and his wife is not
told." CR CR
"Peppino reads over his shoulder at the banker's. Vampa reads Peppino.
You read everyone." CR CR
"    ***  ACT FIVE: EXPIATION  ***" CR CR>
	 <ENTER-ACT-FIVE>
	 <RTRUE>>

"=== Caper D: Caderousse and the study window ==="

<ROUTINE DOSSIER-FCN ()
	 <COND (<VERB? READ EXAMINE>
		<READ-THE-DOSSIER>
		<RTRUE>)>>

<ROUTINE READ-THE-DOSSIER ()
	 <TELL "Four names, and what is done to each." CR CR>
	 <TELL "Danglars: ">
	 <COND (,TELEGRAPH-DONE <TELL "a million gone, and frightened." CR>)
	       (,CREDIT-OPEN <TELL "bleeding. The telegraph is next." CR>)
	       (T <TELL "untouched. He honors letters of credit." CR>)>
	 <TELL "Morcerf: ">
	 <COND (,JACKET-REVEAL <TELL "finished, and knows the name." CR>)
	       (,MORCERF-DONE <TELL "disgraced. He will come here." CR>)
	       (,PRESS-RUN <TELL "in the papers. The Chamber wants proof." CR>)
	       (,JANINA-DOCS <TELL "still a peer. Beauchamp prints." CR>)
	       (T <TELL "still a peer. Haydee has the papers." CR>)>
	 <TELL "Villefort: ">
	 <COND (,WRATH-CHECKED <TELL "mad, among his dead." CR>)
	       (,ASSIZES-DONE <TELL "unfathered in open court. Go to him." CR>)
	       (,DINNER-HELD <TELL "shaken. The Assizes are sitting." CR>)
	       (,BERTUCCIO-TOLD <TELL "steady. Dig the garden." CR>)
	       (T <TELL "steady. Bertuccio will not look at the garden." CR>)>
	 <TELL "Caderousse: ">
	 <COND (,CAD-DEAD <TELL "dead on the steps, naming God." CR>)
	       (,BURGLARY-SET <TELL "coming tonight, by the window." CR>)
	       (T <TELL "somewhere in Paris, being used by somebody." CR>)>
	 <COND (,VALENTINE-SAVED
		<TELL "Valentine Villefort: alive, and buried." CR>)
	       (<AND ,DINNER-HELD <NOT ,VALENTINE-SAVED>>
		<TELL "Valentine Villefort: dying by grains, in that house."
CR>)>
	 <RTRUE>>

<ROUTINE PARIS-TICK ()
	 <COND (<NOT <EQUAL? ,ACT 4>> <RFALSE>)>
	 <COND (<AND <G? ,CAPERS-STARTED 1> <NOT ,BURGLARY-SET>>
		<SETG BURGLARY-SET T>
		<MOVE ,WARNING-NOTE ,WINNER>
		<TELL
"A note is brought up on a tray, in a hand disguising itself out of
habit: a friend warns the Count that a man will enter his house by the
study window tonight." CR>
		<RTRUE>)
	       (<AND ,BURGLARY-SET <NOT ,CAD-VISIT> <NOT ,CAD-DEAD>
		     <EQUAL? ,HERE ,CSTUDY>>
		<CADEROUSSE-ARRIVES>
		<RTRUE>)
	       (<G? ,VILL-EXPIRE 0>
		<SETG VILL-EXPIRE <+ ,VILL-EXPIRE 1>>
		<COND (<EQUAL? ,VILL-EXPIRE 6>
		       <TELL
"Word from the Faubourg Saint-Honore: the procureur is at home, and
will not come out of his study, and is asking for a priest." CR>
		       <RTRUE>)
		      (<G? ,VILL-EXPIRE 11>
		       <SETG VILL-EXPIRE 0>
		       <SETG WRATH-CHECKED T>
		       <REMOVE ,VILLEFORT4>
		       <TELL
"Word from the Faubourg Saint-Honore: Madame de Villefort has poisoned
herself and her son, and the procureur has been found in the garden
digging a hole with his hands." CR CR
"He never learned who you were. That is a loss, and it is yours." CR CR>
		       <DANGLARS-FLEES>
		       <RTRUE>)>
		<RFALSE>)
	       (T <RFALSE>)>>

<ROUTINE CADEROUSSE-ARRIVES ()
	 <COND (<NOT <EQUAL? ,IDENTITY 1>>
		<TELL
"Downstairs a pane of glass comes out of the study window with a
glazier's diamond, very quietly, and somebody who is not a servant
walks about among your things." CR CR
"You could go down as the Count of Monte Cristo and have him taken by
the gendarmes; or you could go down as somebody he is afraid of." CR>
		<RTRUE>)>
	 <SETG CAD-VISIT T>
	 <MOVE ,CADEROUSSE4 ,CSTUDY>
	 <TELL
"The pane comes out of the window with a glazier's diamond, and a leg
comes over the sill, and a man drops into your dark study and finds a
priest sitting in the chair." CR CR
"\"You! The abbe! Always the abbe, like a bad conscience.\"" CR>
	 <RTRUE>>

<ROUTINE CADEROUSSE4-FCN ()
	 <COND (<AND <VERB? TELL SHOW GIVE>
		     <OR <EQUAL? ,PRSI ,BENEDETTO-T>
			 <EQUAL? ,PRSO ,WARNING-NOTE>>>
		<CORNER-CADEROUSSE>
		<RTRUE>)
	       (<VERB? TELL>
		<COND (,CADEROUSSE-LETTER
		       <TELL
"\"Let me go out the way I came, monsieur l'abbe. I have signed your
paper and I would like some air.\"" CR>)
		      (T
		       <TELL
"\"I am a poor man, monsieur l'abbe, and a friend told me the house was
empty, and I have not touched a thing.\" He has your candlesticks in
his coat." CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"Caderousse at fifty: the galleys, the diamond, the jeweler he killed
for it, and a coat too thin for the weather." CR>
		<RTRUE>)>>

<ROUTINE CORNER-CADEROUSSE ()
	 <COND (,CADEROUSSE-LETTER
		<TELL "He has signed it. There is nothing more in him." CR>)
	       (T
		<SETG CADEROUSSE-LETTER T>
		<ADD-SCORE 5>
		<REMOVE ,CADEROUSSE4>
		<SETG CAD-DYING T>
		<TELL
"\"The friend who told you the house was empty is the same young prince
who is marrying Mademoiselle Danglars. His name is Benedetto and he was
in the galleys at Toulon with you.\"" CR CR
"He writes it and signs it at your desk, in a hand like a schoolboy's,
and then you let him go out the window, because the knife waiting for
him at the gate is not yours." CR CR
"Two minutes later there is a cry at the gate, and your servants carry
him back in and lay him on the study floor with Benedetto's knife in
him. He is asking for the abbe." CR>)>
	 <RTRUE>>

<GLOBAL CAD-DYING <>>

<ROUTINE CADEROUSSE-DEATHBED ()
	 <COND (<OR ,CAD-DEAD <NOT ,CAD-DYING>> <RFALSE>)>
	 <SETG CAD-DYING <>>
	 <SETG CAD-DEAD T>
	 <REMOVE ,CADEROUSSE4>
	 <ADD-SCORE 5>
	 <TELL
"They carry him back in off your own steps with Benedetto's knife in
him, and he asks for the abbe, and gets him." CR CR
"\"Look well at me.\" \"The abbe. Busoni.\" \"Look again.\"" CR
"The gray wig comes off." CR CR
"\"I am neither the Abbe Busoni nor Lord Wilmore. I am he you sold at
La Reserve. I am Edmond Dantes.\"" CR CR
"\"Oh, my God, my God,\" says Caderousse, \"forgive me for having
denied you,\" and dies believing, which is more than he managed in
fifty years of living." CR>
	 <MOVE ,WIG ,WINNER>
	 <MOVE ,CASSOCK ,WINNER>
	 <SETG IDENTITY 1>
	 <RTRUE>>

"=== ACT FIVE ==="

<ROUTINE ENTER-ACT-FIVE ()
	 <SETG ACT 5>
	 <SETG SCENE-LOCK T>
	 <SETG IDENTITY 3>
	 <REMOVE ,WIG>
	 <REMOVE ,CASSOCK>
	 <REMOVE ,SAILOR-JACKET>
	 <REMOVE ,IRON-BOX>
	 <REMOVE ,WARNING-NOTE>
	 <REMOVE ,CREDIT-LETTER>
	 <TELL
"Rome, and under Rome the catacombs of Saint Sebastian, where Luigi
Vampa keeps what he is holding for you." CR CR>
	 <GOTO ,CATHALL>
	 <RTRUE>>

<ROUTINE VAMPA-FCN ()
	 <COND (<VERB? TELL>
		<TELL
"\"Excellency. He has eaten five millions in twelve days at my prices,
and he has fifty thousand francs left, and he weeps at night.\" Vampa
is uncomfortable. \"He asks for you. He does not know he asks for
you.\"" CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"Luigi Vampa, bandit chief, holding his hat. To him you are something
between a king and a saint and he is not sure which frightens him
more." CR>
		<RTRUE>)>>

<ROUTINE DANGLARS5-FCN ()
	 <COND (<VERB? FORGIVE> <PARDON-DANGLARS> <RTRUE>)
	       (<VERB? ATTACK MUNG>
		<TELL
"Fourteen years you carried the knife. You did not become it." CR>
		<RTRUE>)
	       (<AND <VERB? TELL> ,PRSI> <DANGLARS5-ASK> <RTRUE>)
	       (<VERB? TELL> <DANGLARS5-ASK> <RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A fat man gone loose in his own skin, in a torn coat, among the finest
dinners in Italy at a hundred thousand francs the fowl." CR>
		<RTRUE>)>>

<ROUTINE DANGLARS5-ASK ()
	 <COND (,DANGLARS-ASKED
		<TELL "\"Yes! Yes! I repent, I repent!\" He says it to
anyone who comes near the bars now." CR>)
	       (T
		<SETG DANGLARS-ASKED T>
		<TELL
"\"Take my last gold,\" he says through the bars, without pride,
without anything. \"Take it and let me live. I only ask to live.\"" CR CR
"\"Do you repent?\"" CR CR
"\"Of the evil I have done? Yes! Yes!\"" CR>)>
	 <RTRUE>>

<ROUTINE PARDON-DANGLARS ()
	 <COND (,PARDONED
		<TELL "It is done. Mercy does not need doing twice." CR>)
	       (<NOT ,DANGLARS-ASKED>
		<TELL
"Not yet. A pardon nobody has asked for is only another way of being
the biggest man in the room. Speak to him first." CR>)
	       (T
		<SETG PARDONED T>
		<ADD-SCORE 15>
		<TELL
"You put back the hood." CR CR
"\"I am he whom you sold and dishonored; I am he whose betrothed you
prostituted; I am he you trampled upon that you might raise yourself to
fortune. I am Edmond Dantes.\"" CR CR
"\"And I forgive you, because I hope to be forgiven.\"" CR CR
"He keeps the fifty thousand francs. The hospitals of Rome are repaid
out of the rest. By morning his hair is white, and he walks out of the
catacombs into the sun a free man, which is the worst thing you could
have done to him." CR CR
"    ***  MARSEILLES  ***" CR CR
"The Chateau d'If is a monument now, and they charge to go in." CR CR>
		<SETG ACT 6>
		<SETG SCENE-LOCK T>
		<REMOVE ,DANGLARS5>
		<FCLEAR ,CELL34 ,TOUCHBIT>
		<FCLEAR ,TUNNEL ,TOUCHBIT>
		<FCLEAR ,GROTTO1 ,TOUCHBIT>
		<GOTO ,CELL34>)>
	 <RTRUE>>

"=== The return to If, and the island ==="

<ROUTINE GROTTO-FINALE-LOOK ()
	 <TELL
"The first grotto, lit properly for the first time in three hundred and
forty years. Maximilian Morrel stands where the treasure stood, and he
has not spoken since Marseilles, because the girl he loved was buried
in October." CR>
	 <RTRUE>>

<ROUTINE MAXIMILIAN-FCN ()
	 <COND (<AND <VERB? GIVE> <EQUAL? ,PRSO ,FAREWELL-LETTER>>
		<THE-VICTORY>
		<RTRUE>)
	       (<VERB? TELL>
		<TELL
"\"You told me to wait until the fifth of October,\" he says. \"It is
the fifth of October. I have kept my word and I would like to go
now.\" He means somewhere permanent." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A captain of Spahis, thirty years old, grief-broken and perfectly
polite about it." CR>
		<RTRUE>)>>

<ROUTINE FAREWELL-LETTER-FCN ()
	 <COND (<VERB? READ EXAMINE>
		<TELL
"Sealed, and addressed to Maximilian Morrel, and written on the deck
coming down from Marseilles with the manuscript of the Abbe Faria open
beside you." CR>
		<RTRUE>)
	       (<VERB? DROP PUT>
		<TELL "It has one reader and he is standing in front of you."
CR>
		<RTRUE>)>>

<ROUTINE THE-VICTORY ()
	 <ADD-SCORE 25>
	 <REMOVE ,FAREWELL-LETTER>
	 <TELL
"The letter passes from your hand to Maximilian Morrel's, on the floor
of your own grotto isle." CR CR>
	 <COND (,VALENTINE-SAVED
		<MOVE ,VALENTINE5 ,GROTTO1>
		<TELL
"And out of the second grotto, into the blue light, walks Valentine de
Villefort, alive, alive, and takes his arm the way the drowning take a
spar." CR CR>)
	       (T
		<TELL
"He reads it alone. There is a name in it that should have been said
over a living girl and was not, because you were busy." CR CR>)>
	 <TELL
"\"There is neither happiness nor misery in the world; there is only
the comparison of one state with another. He who has felt the deepest
grief is best able to experience supreme happiness. We must have felt
what it is to die, that we may appreciate the enjoyments of living." CR CR
"\"Live, then, and be happy, beloved children of my heart, and never
forget, until the day God deigns to reveal the future to man, that all
human wisdom is summed up in these two words: Wait and hope.\"" CR CR
"Signed: Edmond Dantes, Count of Monte Cristo." CR CR>
	 <TELL
"A sailor gone fourteen years came back to Marseilles wearing four
faces, and the men who buried him met every one before the end: the
priest, the Englishman, the Count, and last, always last, the young man
in the sailor's jacket whose name they cried out like the damned." CR CR
"Danglars begged, and was forgiven. Fernand heard it, and fired.
Villefort touched it, and went mad. Caderousse saw it, and believed in
God." CR CR
"And on the blue line where the sky meets the sea, a white sail grows
small: the Count, and Haydee, and the horizon." CR CR
"Wait, and hope." CR CR
"    ****  You have won  ****" CR CR>
	 <SETG WON-FLAG T>
	 <V-SCORE>
	 <QUIT>>

"=== Act V room plumbing ==="

<ROUTINE IF-TOUR-TICK ()
	 <COND (<AND <EQUAL? ,ACT 6> ,MANUSCRIPT-TAKEN>
		<SETG ACT 7>
		<SETG SCENE-LOCK T>
		<MOVE ,MAXIMILIAN ,GROTTO1>
		<MOVE ,FAREWELL-LETTER ,WINNER>
		<TELL CR
"The yacht is at Marseilles and Maximilian Morrel is aboard her,
because you asked him to wait until the fifth of October and he is a
man who keeps his word." CR CR
"    ***  MONTE CRISTO  ***" CR CR>
		<GOTO ,GROTTO1>
		<RTRUE>)
	       (T <RFALSE>)>>
