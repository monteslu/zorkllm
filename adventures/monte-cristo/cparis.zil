"CPARIS - The Count of Monte Cristo, Acts IV-V:
Paris 1838, and the expiation. Rooms, objects, topics."

"=== ACT IV - PARIS, 1838 ==="

<ROOM SALON
      (IN ROOMS)
      (DESC "Salon of the Count of Monte Cristo")
      (LDESC
"No. 30, Champs-Elysees. Silk, bronze, and rumor. Paris has decided
you are a Balkan prince, a vampire, or the devil; you have not
corrected Paris. Ali stands at the door; your study lies east; the
city waits south.")
      (EAST TO CSTUDY)
      (NORTH TO HAYDEE-ROOM)
      (SOUTH TO STREET)
      (OUT TO STREET)
      (EXIT TO STREET)
      (ACTION SALON-FCN)
      (FLAGS RLANDBIT ONBIT)>

<ROOM CSTUDY
      (IN ROOMS)
      (DESC "The Count's Study")
      (LDESC
"Maps, dossiers, and a wardrobe deeper than it looks: a priest's
cassock, an Englishman's drab coat, and, folded at the very bottom,
paid for with fourteen years, a sailor's jacket and hat.")
      (WEST TO SALON)
      (ACTION CSTUDY-FCN)
      (FLAGS RLANDBIT ONBIT)>

<ROOM HAYDEE-ROOM
      (IN ROOMS)
      (DESC "Haydee's Apartments")
      (LDESC
"Incense, cushions, and a silence from farther east than Greece.
Haydee rises as you enter: the daughter of Ali Pasha of Janina, whom
you bought out of slavery and who looks at you as if you were the sun.
The salon is back through the curtain, south.")
      (SOUTH TO SALON)
      (FLAGS RLANDBIT ONBIT)>

<ROOM STREET
      (IN ROOMS)
      (DESC "The Champs-Elysees")
      (LDESC
"Carriages, gossip, and gaslight. From here the city is yours. The
bank lies west and the press east; the Chamber of Peers southeast, the
law courts south, the telegraph northwest, the Villefort house
southwest. Your own house is north, and a coach at the kerb will take
you in to Auteuil.")
      (NORTH TO SALON)
      (EAST TO PRESS)
      (SE PER STREET-SE)
      (SOUTH PER STREET-S)
      (WEST TO BANKHALL)
      (NW TO TELEGARDEN)
      (SW PER STREET-SW)
      (IN PER STREET-IN)
      (ENTRANCE PER STREET-IN)
      (ACTION STREET-FCN)
      (FLAGS RLANDBIT ONBIT)>

<ROOM BANKHALL
      (IN ROOMS)
      (DESC "Danglars's Bank - Antechamber")
      (LDESC
"Marble bought with margins. Clerks scratch in ledgers; above the
double doors, a gilt baron's crest that smells of fresh paint. The
Baron's office is west, the street east.")
      (EAST TO STREET)
      (WEST TO BANKOFF)
      (FLAGS RLANDBIT ONBIT)>

<ROOM BANKOFF
      (IN ROOMS)
      (DESC "Danglars's Office")
      (LDESC
"Baron Danglars fills his chair like a sack of coin. On the wall, a
portrait of his wife he did not choose; on his desk, the only faith he
keeps: the daily quotations. The way out is east.")
      (EAST TO BANKHALL)
      (FLAGS RLANDBIT ONBIT)>

<ROOM TELEGARDEN
      (IN ROOMS)
      (DESC "Garden Below the Telegraph")
      (LDESC
"A kitchen garden at the foot of an old tower crowned with black
jointed arms. A ladder climbs up into it; the street is southeast. The
keeper is on his knees among the peas, at war with the dormice, a man
of a thousand francs a year.")
      (SE TO STREET)
      (UP TO TELETOWER)
      (FLAGS RLANDBIT ONBIT)>

<ROOM TELETOWER
      (IN ROOMS)
      (DESC "The Telegraph Platform")
      (LDESC
"Up here the signal arms creak overhead like a gallows-tree of news.
Through the glass you can see the next tower's semaphore twitching out
the fortunes of France, one angle at a time. The ladder goes back
down.")
      (DOWN TO TELEGARDEN)
      (FLAGS RLANDBIT ONBIT)>

<ROOM PRESS
      (IN ROOMS)
      (DESC "Offices of l'Impartial")
      (LDESC
"Ink-fog, proof sheets, and the guillotine-thump of the press below.
Beauchamp the journalist can smell a story through wax seals. The
street is west.")
      (WEST TO STREET)
      (FLAGS RLANDBIT ONBIT)>

<ROOM PEERS
      (IN ROOMS)
      (DESC "Gallery of the Chamber of Peers")
      (LDESC
"Velvet benches above a floor of old men and older honors, and a
staircase down to the street northwest. Today the Count de Morcerf
answers a question of history: what happened at Janina?")
      (NW TO STREET)
      (ACTION PEERS-FCN)
      (FLAGS RLANDBIT ONBIT)>

<ROOM ASSIZES
      (IN ROOMS)
      (DESC "The Court of Assizes")
      (LDESC
"The great criminal court, packed to the cornices, with the doors to
the street behind you to the north. Villefort prosecutes the prisoner
Benedetto with his usual marble calm; the prisoner wears a curious
smile, as if he alone knows the last line.")
      (NORTH TO STREET)
      (ACTION ASSIZES-FCN)
      (FLAGS RLANDBIT ONBIT)>

<ROOM AUTSALON
      (IN ROOMS)
      (DESC "The House at Auteuil - Salon")
      (LDESC
"A pleasure-house with its shutters' eyes put out; you have had it lit
and aired, and still the walls hold their breath. The garden lies east,
and the coach out to Paris waits at the door. Bertuccio, your steward,
will not look at the garden door.")
      (OUT PER AUT-OUT)
      (EXIT PER AUT-OUT)
      (WEST PER AUT-OUT)
      (EAST TO AUTGARDEN)
      (ACTION AUTSALON-FCN)
      (FLAGS RLANDBIT ONBIT)>

<ROOM AUTGARDEN
      (IN ROOMS)
      (DESC "The Auteuil Garden")
      (LDESC
"A walled garden gone half wild, with the salon back through the door
west. One plantain tree stands over turned earth like a mourner who has
forgotten whom he mourns.")
      (WEST TO AUTSALON)
      (FLAGS RLANDBIT ONBIT)>

<ROOM VHALL
      (IN ROOMS)
      (DESC "Villefort's House - Hall")
      (LDESC
"The procureur's house in the Faubourg Saint-Honore: cold marble,
hushed servants, and lately a smell of medicine on every landing.
Noirtier's room is north, Valentine's east, and the street northeast.
Death has been a frequent caller this season.")
      (NE TO STREET)
      (NORTH TO NOIRTIER-ROOM)
      (EAST TO VALROOM)
      (ACTION VHALL-FCN)
      (FLAGS RLANDBIT ONBIT)>

<ROOM NOIRTIER-ROOM
      (IN ROOMS)
      (DESC "Noirtier's Room")
      (LDESC
"The old conventionist sits paralyzed in his great chair, alive only
in his eyes; and his eyes are two loaded pistols. A dictionary and a
bell-cord serve him for a voice. The hall is south.")
      (SOUTH TO VHALL)
      (ACTION NOIRTIER-ROOM-FCN)
      (FLAGS RLANDBIT ONBIT)>

<ROOM VALROOM
      (IN ROOMS)
      (DESC "Valentine's Room")
      (LDESC
"White curtains, a glass of lemonade on the night table, and a girl
growing paler by the week while her family calls it nerves. The hall
is west.")
      (WEST TO VHALL)
      (FLAGS RLANDBIT ONBIT)>

"=== ACT V - EXPIATION ==="

<ROOM CATHALL
      (IN ROOMS)
      (DESC "Catacombs of Saint Sebastian")
      (LDESC
"Under Rome, among the politely stacked dead, Luigi Vampa's men play
mora by torchlight. Vampa rises and uncovers his head: to him you are
something between a king and a saint, and he is not sure which
frightens him more.")
      (EAST TO LARDER)
      (FLAGS RLANDBIT ONBIT)>

<ROOM LARDER
      (IN ROOMS)
      (DESC "The Larder Cell")
      (LDESC
"A barred recess in the tufa where a fat man in a torn coat sits among
the finest dinners in Italy, priced at one hundred thousand francs the
fowl. Danglars has eaten down five millions, and is hungry.")
      (WEST TO CATHALL)
      (FLAGS RLANDBIT ONBIT)>

"=== ACT IV objects ==="

<OBJECT ALI
	(IN SALON)
	(SYNONYM ALI NUBIAN SERVANT)
	(DESC "Ali")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION ALI-FCN)>

<OBJECT SAILOR-JACKET
	(IN CSTUDY)
	(SYNONYM JACKET HAT)
	(ADJECTIVE SEAMANS ROUGH)
	(DESC "sailor's jacket and hat")
	(FLAGS TAKEBIT WEARBIT NDESCBIT)
	(SIZE 4)
	(ACTION SAILOR-JACKET-FCN)
	(TEXT
"A young sailor's jacket and hat, folded with more care than any silk
in this house. The last suit of clothes Edmond Dantes ever owned.")>

<OBJECT CREDIT-LETTER
	(SYNONYM LETTER CREDIT)
	(ADJECTIVE UNLIMITED BANKING)
	(DESC "letter of credit")
	(FLAGS TAKEBIT READBIT)
	(SIZE 1)
	(TEXT
"On the house of Thomson and French, Rome, to the Count of Monte
Cristo: credit unlimited. The word sits on the page like a loaded
gun.")>

<OBJECT BANKNOTES
	(SYNONYM BANKNOTES NOTES FRANCS)
	(ADJECTIVE FIFTEEN)
	(DESC "fifteen bank-notes")
	(FLAGS TAKEBIT)
	(SIZE 1)
	(TEXT
"Fifteen notes of a thousand francs each. Fifteen years of a telegraph
keeper's wages, in one hand.")>

<OBJECT DOSSIER
	(IN CSTUDY)
	(SYNONYM DOSSIER FILES NOTES)
	(DESC "dossier")
	(FLAGS NDESCBIT READBIT)
	(ACTION DOSSIER-FCN)>

<OBJECT PILL
	(SYNONYM PILL DRAUGHT LOZENGE)
	(DESC "gray pill")
	(FLAGS TAKEBIT)
	(SIZE 1)
	(TEXT
"Hashish and opiate, dosed to counterfeit death for a night and a day.
Your theater, in one gray pill.")>

<OBJECT SPADE
	(SYNONYM SPADE SHOVEL)
	(DESC "spade")
	(FLAGS TAKEBIT TOOLBIT)
	(SIZE 8)
	(TEXT "A gardener's spade from the Auteuil shed.")>

<OBJECT HAYDEE
	(IN HAYDEE-ROOM)
	(SYNONYM HAYDEE PRINCESS)
	(ADJECTIVE GREEK)
	(DESC "Haydee")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION HAYDEE-FCN)>

<OBJECT SATCHEL
	(SYNONYM SATCHEL DOCUMENTS RECORDS)
	(ADJECTIVE SATIN)
	(DESC "satin satchel")
	(FLAGS TAKEBIT READBIT)
	(SIZE 2)
	(ACTION SATCHEL-FCN)
	(TEXT
"Her birth record, her baptism record, and the bill of her own sale,
signed by a French colonel: Fernand Mondego. Janina, in a satin
satchel.")>

<OBJECT DANGLARS4
	(IN BANKOFF)
	(SYNONYM DANGLARS BANKER BARON)
	(DESC "Baron Danglars")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION DANGLARS4-FCN)>

<OBJECT OPERATOR
	(IN TELEGARDEN)
	(SYNONYM OPERATOR KEEPER GARDENER MAN)
	(DESC "telegraph keeper")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION OPERATOR-FCN)>

<OBJECT SIGNAL-LEVERS
	(IN TELETOWER)
	(SYNONYM SIGNAL LEVERS ARMS SEMAPHORE)
	(ADJECTIVE JOINTED)
	(DESC "signal levers")
	(FLAGS NDESCBIT)
	(ACTION SIGNAL-LEVERS-FCN)>

<OBJECT BEAUCHAMP
	(IN PRESS)
	(SYNONYM BEAUCHAMP JOURNALIST EDITOR)
	(DESC "Beauchamp")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION BEAUCHAMP-FCN)>

<OBJECT MORCERF
	(SYNONYM MORCERF FERNAND COUNT GENERAL)
	(DESC "Count de Morcerf")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION MORCERF-FCN)>

<OBJECT COMMITTEE
	(IN PEERS)
	(SYNONYM COMMITTEE PEERS CHAMBER)
	(DESC "committee of peers")
	(FLAGS ACTORBIT NDESCBIT)
	(TEXT
"Old men and older honors, arranged in judgment. They wanted to
believe Morcerf. They want more to believe documents.")>

<OBJECT BERTUCCIO
	(IN AUTSALON)
	(SYNONYM BERTUCCIO STEWARD CORSICAN)
	(DESC "Bertuccio")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION BERTUCCIO-FCN)>

<OBJECT PLANTAIN
	(IN AUTGARDEN)
	(SYNONYM PLANTAIN TREE)
	(DESC "plantain tree")
	(FLAGS NDESCBIT)
	(TEXT
"A plantain tree over turned earth. Bertuccio will not come within
sight of it.")>

<OBJECT GARDEN-EARTH
	(IN AUTGARDEN)
	(SYNONYM EARTH GROUND DIRT)
	(ADJECTIVE TURNED)
	(DESC "turned earth")
	(FLAGS NDESCBIT)
	(ACTION GARDEN-EARTH-FCN)>

<OBJECT IRON-BOX
	(SYNONYM BOX IRONWORK)
	(ADJECTIVE IRON SMALL)
	(DESC "rusted iron box")
	(FLAGS TAKEBIT)
	(SIZE 5)
	(TEXT
"The ironwork of a small box, rusted to lace. What it held is a
question you will ask at dinner.")>

<OBJECT DINNER
	(IN AUTSALON)
	(SYNONYM DINNER GUESTS PARTY)
	(DESC "dinner")
	(FLAGS NDESCBIT)
	(ACTION DINNER-FCN)>

<OBJECT VILLEFORT4
	(IN ASSIZES)
	(SYNONYM VILLEFORT PROCUREUR)
	(DESC "Villefort")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION VILLEFORT4-FCN)>

<OBJECT BENEDETTO
	(IN ASSIZES)
	(SYNONYM BENEDETTO PRISONER CAVALCANTI ANDREA)
	(DESC "the prisoner Benedetto")
	(FLAGS ACTORBIT NDESCBIT)
	(TEXT
"A handsome forger in a prisoner's box, smiling like a man holding
the last card in the deck.")>

<OBJECT NOIRTIER-NPC
	(IN NOIRTIER-ROOM)
	(SYNONYM NOIRTIER CONVENTIONIST GRANDFATHER)
	(ADJECTIVE OLD)
	(DESC "M. Noirtier")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION NOIRTIER-NPC-FCN)>

<OBJECT VALENTINE
	(IN VALROOM)
	(SYNONYM VALENTINE GIRL)
	(DESC "Valentine")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION VALENTINE-FCN)>

<OBJECT LEMONADE-GLASS
	(IN VALROOM)
	(SYNONYM GLASS LEMONADE)
	(DESC "glass of lemonade")
	(FLAGS NDESCBIT)
	(TEXT
"Barrois drank from a glass like it and died in twenty minutes; the
doctors said apoplexy, once. They have stopped saying it.")>

<OBJECT WARNING-NOTE
	(SYNONYM NOTE WARNING)
	(ADJECTIVE ANONYMOUS)
	(DESC "anonymous note")
	(FLAGS TAKEBIT READBIT)
	(SIZE 1)
	(TEXT
"A friend warns the Count: a man will enter his house by the study
window tonight. No signature. The hand is a forger's, disguising
itself out of habit.")>

<OBJECT CADEROUSSE4
	(SYNONYM CADEROUSSE BURGLAR)
	(DESC "Caderousse")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION CADEROUSSE4-FCN)>

"Act IV topics"

<OBJECT JANINA-T
	(IN GLOBAL-OBJECTS)
	(SYNONYM JANINA YANINA ALI-PASHA)
	(DESC "Janina")
	(FLAGS NDESCBIT)
	(ACTION TOPIC-FCN)>

<OBJECT PROOF-T
	(IN GLOBAL-OBJECTS)
	(SYNONYM PROOF PAPERS TESTIMONY)
	(DESC "proof")
	(FLAGS NDESCBIT)
	(ACTION TOPIC-FCN)>

<OBJECT MONEY-T
	(IN GLOBAL-OBJECTS)
	(SYNONYM MONEY MILLIONS CREDIT)
	(DESC "money")
	(FLAGS NDESCBIT)
	(ACTION TOPIC-FCN)>

<OBJECT SPAIN-T
	(IN GLOBAL-OBJECTS)
	(SYNONYM SPAIN BONDS)
	(ADJECTIVE SPANISH)
	(DESC "Spanish bonds")
	(FLAGS NDESCBIT)
	(ACTION TOPIC-FCN)>

<OBJECT VENDETTA-T
	(IN GLOBAL-OBJECTS)
	(SYNONYM VENDETTA BOX INFANT CHILD)
	(DESC "the buried box")
	(FLAGS NDESCBIT)
	(ACTION TOPIC-FCN)>

<OBJECT POISONER-T
	(IN GLOBAL-OBJECTS)
	(SYNONYM POISONER POISON BRUCINE)
	(DESC "the poisoner")
	(FLAGS NDESCBIT)
	(ACTION TOPIC-FCN)>

"=== ACT V objects ==="

<OBJECT VAMPA
	(IN CATHALL)
	(SYNONYM VAMPA LUIGI BANDIT CHIEF)
	(DESC "Luigi Vampa")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION VAMPA-FCN)>

<OBJECT DANGLARS5
	(IN LARDER)
	(SYNONYM DANGLARS)
	(ADJECTIVE STARVED)
	(DESC "Danglars")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION DANGLARS5-FCN)>

<OBJECT REPENT-T
	(IN GLOBAL-OBJECTS)
	(SYNONYM REPENTANCE FORGIVENESS MERCY)
	(DESC "repentance")
	(FLAGS NDESCBIT)
	(ACTION TOPIC-FCN)>

<OBJECT MAXIMILIAN
	(SYNONYM MAXIMILIAN MORREL)
	(ADJECTIVE YOUNG)
	(DESC "Maximilian Morrel")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION MAXIMILIAN-FCN)>

<OBJECT VALENTINE5
	(SYNONYM VALENTINE)
	(DESC "Valentine")
	(FLAGS ACTORBIT NDESCBIT)
	(TEXT
"Alive, alive. She holds Maximilian's arm the way the drowning hold a
spar.")>

<OBJECT FAREWELL-LETTER
	(SYNONYM LETTER)
	(ADJECTIVE FAREWELL SEALED)
	(DESC "farewell letter")
	(FLAGS TAKEBIT READBIT)
	(SIZE 1)
	(ACTION FAREWELL-LETTER-FCN)>
