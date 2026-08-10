"CDUNGEON - The Count of Monte Cristo, Acts I-III:
Marseilles 1815, the Chateau d'If, the island. Rooms, objects, GO,
and the engine-required stubs."

;"IN and OUT are also prepositions, and a v8 dictionary entry that is
both a direction and a preposition cannot have its direction value read
back (see BUILD-ISSUES). ENTRANCE and EXIT are direction words that are
nothing else, and every IN/OUT exit below carries one as its working
alias; IN and OUT stay declared so the LLM layer's phrasings still hit
something in v3 builds."
<DIRECTIONS NORTH EAST WEST SOUTH NE NW SE SW UP DOWN IN OUT LAND
	    ENTRANCE EXIT>
<SYNONYM ENTRANCE INWARD>
<SYNONYM EXIT OUTWARD>

"=== ACT I - MARSEILLES, 1815 ==="

<ROOM DECK
      (IN ROOMS)
      (DESC "Deck of the Pharaon")
      (LDESC
"You stand at the helm of the three-master Pharaon, gliding into
Marseilles harbor under a February sun. The crew waits on your word,
for Captain Leclere lies sewn in his hammock at the bottom of the sea,
and at nineteen you have brought his ship home. The quay lies west,
close enough to hear, and all Marseilles has turned out on it to watch.
Captain Leclere's cabin is below, down the companion ladder.")
      (DOWN TO CABIN)
      (WEST PER DECK-ASHORE)
      (LAND PER DECK-ASHORE)
      (OUT PER DECK-ASHORE)
      (EXIT PER DECK-ASHORE)
      (ACTION DECK-FCN)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM CABIN
      (IN ROOMS)
      (DESC "Captain's Cabin")
      (LDESC
"Captain Leclere's little cabin still smells of pipe smoke and sea-damp
charts. His sword and cross of honor lie boxed for his widow. It was
here, dying, he made you swear to touch at Elba. The companion ladder
goes back up to the deck.")
      (UP TO DECK)
      (FLAGS RLANDBIT ONBIT)>

<ROOM QUAY
      (IN ROOMS)
      (DESC "Marseilles Quay")
      (LDESC
"Fishwives, porters, and half the town crowd the sun-white stones of
the quay. North lie the Allees de Meilhan where your father lives;
south, the Catalan village; west, Morrel's counting-house. Eastward,
under its arbor by the water, the tables of La Reserve are being laid
for a feast. Yours.")
      (NORTH TO MEILHAN)
      (SOUTH TO CATALANS)
      (WEST TO OFFICE)
      (EAST TO RESERVE)
      (IN TO DECK)
      (ENTRANCE TO DECK)
      (FLAGS RLANDBIT ONBIT)>

<ROOM OFFICE
      (IN ROOMS)
      (DESC "Morrel's Counting-House")
      (LDESC
"Ledgers, sealing wax, and the smell of ink and tar. Portraits of
Morrel ships line the wall. M. Morrel does business here the way other
men keep faith. The door east opens on the quay.")
      (EAST PER OFFICE-EAST)
      (NORTH PER OFFICE-NORTH)
      (ACTION OFFICE-FCN)
      (FLAGS RLANDBIT ONBIT)>

<ROOM MEILHAN
      (IN ROOMS)
      (DESC "A Room in the Allees de Meilhan")
      (LDESC
"Your father's narrow fifth-floor room: a bed, a crucifix, a few
nasturtiums in a window box, and a bare cupboard he is too proud to
mention. A faded red purse lies on the mantelpiece. Five flights of
stairs lead back down, and the quay lies south.")
      (SOUTH PER MEILHAN-SOUTH)
      (ACTION MEILHAN-FCN)
      (FLAGS RLANDBIT ONBIT)>

<ROOM CATALANS
      (IN ROOMS)
      (DESC "The Catalan Village")
      (LDESC
"White cottages above a bright cove; nets drying in the wind. At her
doorway stands Mercedes, and the sea behind her is nothing to her
eyes. In the shadow of the wall, her cousin Fernand watches you with a
Catalan's stillness. The road back to the quay runs north.")
      (NORTH TO QUAY)
      (FLAGS RLANDBIT ONBIT)>

<ROOM RESERVE
      (IN ROOMS)
      (DESC "The Arbor at La Reserve")
      (LDESC
"Under the leafless arbor of La Reserve the wedding table is laid:
Arles sausages, boiled crawfish, wine of La Malgue. Everyone you love
is here, and the quay lies west through the vines. The morning sun
touches the foamy waves into a network of ruby-tinted light.")
      (WEST PER RESERVE-WEST)
      (ACTION RESERVE-FCN)
      (FLAGS RLANDBIT ONBIT)>

<ROOM VSTUDY
      (IN ROOMS)
      (DESC "Villefort's Study")
      (LDESC
"A magistrate's room in the Palais de Justice: files, a fire in the
grate, the king's portrait. M. de Villefort studies you like a man
reading two letters at once. Yours, and his own future.")
      (ACTION VSTUDY-FCN)
      (FLAGS RLANDBIT ONBIT)>

"Act I objects"

<OBJECT MORREL
	(IN DECK)
	(SYNONYM MORREL OWNER)
	(ADJECTIVE GOOD OLD)
	(DESC "M. Morrel")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION MORREL-FCN)>

<OBJECT DANGLARS
	(IN DECK)
	(SYNONYM DANGLARS SUPERCARGO)
	(DESC "Danglars")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION DANGLARS-FCN)>

<OBJECT SAILS
	(IN DECK)
	(SYNONYM SAILS SAIL TOPSAILS CANVAS)
	(DESC "sails")
	(FLAGS NDESCBIT)
	(ACTION SAILS-FCN)>

<OBJECT ANCHOR
	(IN DECK)
	(SYNONYM ANCHOR)
	(DESC "anchor")
	(FLAGS NDESCBIT)
	(ACTION ANCHOR-FCN)>

<OBJECT CREW
	(IN DECK)
	(SYNONYM CREW HANDS MEN)
	(DESC "crew")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION CREW-FCN)>

<OBJECT SEA-CHEST
	(IN CABIN)
	(SYNONYM CHEST BOX)
	(ADJECTIVE CAPTAINS SEAGOING)
	(DESC "sea-chest")
	(FLAGS CONTBIT NDESCBIT)
	(CAPACITY 30)
	(ACTION CHEST-FCN)>

<OBJECT LECLERE-SWORD
	(IN SEA-CHEST)
	(SYNONYM SWORD)
	(ADJECTIVE CAPTAINS)
	(DESC "captain's sword")
	(TEXT
"Captain Leclere's sword, wrapped for his widow. It crossed half the
world and never left its scabbard in anger.")>

<OBJECT LECLERE-CROSS
	(IN SEA-CHEST)
	(SYNONYM CROSS HONOR)
	(DESC "cross of honor")
	(TEXT
"The cross of the Legion of Honor. The Emperor pinned it on a living
man. The sea unpinned everything else.")>

<OBJECT ELBA-LETTER
	(SYNONYM LETTER PACKET)
	(ADJECTIVE ELBA SEALED)
	(DESC "sealed letter")
	(FLAGS TAKEBIT READBIT)
	(SIZE 1)
	(ACTION ELBA-LETTER-FCN)>

<OBJECT COIN-PURSE
	(SYNONYM PURSE PAY WAGES)
	(ADJECTIVE LEATHER SILVER)
	(DESC "purse of your pay")
	(FLAGS TAKEBIT)
	(SIZE 2)
	(TEXT
"Three months' wages in silver. To a father too proud to mention an
empty cupboard, it is a fortune.")>

<OBJECT FATHER
	(IN MEILHAN)
	(SYNONYM FATHER DANTES LOUIS)
	(ADJECTIVE OLD)
	(DESC "your father")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION FATHER-FCN)>

<OBJECT CADEROUSSE
	(SYNONYM CADEROUSSE TAILOR NEIGHBOR INNKEEPER)
	(DESC "Caderousse")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION CADEROUSSE-FCN)>

<OBJECT MANTEL
	(IN MEILHAN)
	(SYNONYM MANTEL MANTELPIECE CHIMNEY SHELF)
	(DESC "mantelpiece")
	(FLAGS NDESCBIT SURFACEBIT CONTBIT OPENBIT)
	(CAPACITY 20)
	(ACTION MANTEL-FCN)>

<OBJECT MERCEDES
	(IN CATALANS)
	(SYNONYM MERCEDES GIRL BETROTHED)
	(ADJECTIVE CATALAN BEAUTIFUL)
	(DESC "Mercedes")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION MERCEDES-FCN)>

<OBJECT FERNAND
	(IN CATALANS)
	(SYNONYM FERNAND MORCERF COUSIN)
	(ADJECTIVE CATALAN)
	(DESC "Fernand")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION FERNAND-FCN)>

<OBJECT FEAST-TOPIC
	(IN CATALANS)
	(SYNONYM FEAST BETROTHAL MARRIAGE)
	(DESC "betrothal feast")
	(FLAGS NDESCBIT)
	(ACTION FEAST-TOPIC-FCN)>

<OBJECT FEAST-TABLE
	(IN RESERVE)
	(SYNONYM TABLE FEAST SAUSAGES CRAWFISH WINE)
	(ADJECTIVE WEDDING)
	(DESC "wedding table")
	(FLAGS NDESCBIT)
	(ACTION FEAST-TABLE-FCN)>

<OBJECT ARBOR-CORNER
	(IN RESERVE)
	(SYNONYM ARBOR SHADOW)
	(DESC "corner of the arbor")
	(FLAGS NDESCBIT)
	(TEXT
"Nothing but a wine stain and a crumpled shadow. Danglars watches you
look, and smiles thinly.")>

<OBJECT VILLEFORT
	(IN VSTUDY)
	(SYNONYM VILLEFORT MAGISTRATE PROCUREUR DEPUTY)
	(DESC "M. de Villefort")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION VILLEFORT-FCN)>

<OBJECT GRATE
	(IN VSTUDY)
	(SYNONYM GRATE FIRE FLAME)
	(DESC "fire in the grate")
	(FLAGS NDESCBIT)
	(TEXT
"A small politic fire, the kind kept burning for burning things.")>

"=== ACT II - THE CHATEAU D'IF ==="

<ROOM CELL34
      (IN ROOMS)
      (DESC "Cell Number 34")
      (NORTH PER CELL-DOOR-EXIT)
      (DOWN PER CELL34-DIG-EXIT)
      (WEST PER CELL34-DIG-EXIT)
      (ACTION CELL34-FCN)
      (FLAGS RLANDBIT ONBIT)>

<ROOM TUNNEL
      (IN ROOMS)
      (DESC "The Tunnel")
      (EAST TO CELL34)
      (UP TO CELL34)
      (WEST PER TUNNEL-WEST)
      (ACTION TUNNEL-FCN)
      (FLAGS RLANDBIT ONBIT)>

<ROOM CELL27
      (IN ROOMS)
      (DESC "Cell Number 27 - the Abbe's Cell")
      (LDESC
"Faria's cell is the same stone as yours, and entirely different: a
disused hearth, a bed, and everywhere the invisible library of a free
mind. You could believe the walls here were thinner. They are not. The
burrow leads back east, under the bed.")
      (EAST TO TUNNEL)
      (ACTION CELL27-FCN)
      (FLAGS RLANDBIT ONBIT)>

<ROOM UNDERSEA
      (IN ROOMS)
      (DESC "Beneath the Waves")
      (LDESC
"Cold black water, roaring in your ears. Something enormous and heavy
is falling, and it is tied to your feet, and it is you. Air lies up,
if you can reach it.")
      (UP PER UNDERSEA-UP)
      (ACTION UNDERSEA-FCN)
      (FLAGS RLANDBIT ONBIT)>

<ROOM OPENSEA
      (IN ROOMS)
      (DESC "The Open Sea")
      (LDESC
"Black waves under a black sky; the mistral is rising. Behind you the
Chateau d'If stands on its rock like a scaffold. Far off, one steady
spark low in the south: the light of Planier. Faria's geography, in
your ear: leave Planier on your left hand, and Tiboulen lies west.")
      (WEST PER OPENSEA-WEST)
      (EAST PER OPENSEA-BAD)
      (NORTH PER OPENSEA-BAD)
      (SOUTH "South is Planier and the open Mediterranean. No man swims
to Africa.")
      (ACTION OPENSEA-FCN)
      (FLAGS RLANDBIT ONBIT)>

<ROOM TIBOULEN
      (IN ROOMS)
      (DESC "The Island of Tiboulen")
      (ACTION TIBOULEN-FCN)
      (FLAGS RLANDBIT ONBIT)>

"Act II objects"

<OBJECT CELL-DOOR
	(IN CELL34)
	(SYNONYM DOOR GRATING)
	(ADJECTIVE OAKEN IRON)
	(DESC "oak door")
	(FLAGS NDESCBIT DOORBIT)
	(ACTION CELL-DOOR-FCN)>

<OBJECT PRISON-BED
	(IN CELL34)
	(SYNONYM BED BEDSTEAD)
	(DESC "bed")
	(FLAGS NDESCBIT SURFACEBIT CONTBIT OPENBIT)
	(CAPACITY 60)
	(ACTION PRISON-BED-FCN)>

<OBJECT PRISON-TABLE
	(IN CELL34)
	(SYNONYM TABLE)
	(DESC "table")
	(FLAGS NDESCBIT)
	(TEXT
"A table, a chair, a pail, and a jug. The inventory of a life, by
order of the crown.")>

<OBJECT PRISON-CHAIR
	(IN CELL34)
	(SYNONYM CHAIR)
	(DESC "chair")
	(FLAGS NDESCBIT)
	(TEXT "One chair, for one man, forever.")>

<OBJECT PAIL
	(IN CELL34)
	(SYNONYM PAIL BUCKET)
	(DESC "pail")
	(FLAGS NDESCBIT)
	(TEXT
"Its handle was removed long ago. The jailers know their trade.")>

<OBJECT JUG
	(IN CELL34)
	(SYNONYM JUG PITCHER)
	(ADJECTIVE EARTHEN)
	(DESC "water jug")
	(FLAGS NDESCBIT)
	(ACTION JUG-FCN)>

<OBJECT PLATE
	(IN CELL34)
	(SYNONYM PLATE DISH)
	(ADJECTIVE EARTHEN)
	(DESC "earthen plate")
	(FLAGS NDESCBIT TAKEBIT)
	(SIZE 2)
	(ACTION PLATE-FCN)>

<OBJECT LOOPHOLE
	(IN CELL34)
	(SYNONYM LOOPHOLE WINDOW BARS SKY)
	(ADJECTIVE IRON)
	(DESC "loophole")
	(FLAGS NDESCBIT)
	(ACTION LOOPHOLE-FCN)>

<OBJECT STRAW
	(IN CELL34)
	(SYNONYM STRAW BEDDING)
	(DESC "bed straw")
	(FLAGS NDESCBIT)
	(ACTION STRAW-FCN)>

<OBJECT LOOSE-STONE
	(IN CELL34)
	(SYNONYM PEBBLE COBBLE)
	(ADJECTIVE LOOSE)
	(DESC "loose stone")
	(FLAGS NDESCBIT TAKEBIT)
	(SIZE 3)
	(ACTION LOOSE-STONE-FCN)>

<OBJECT HEWN-STONE
	(SYNONYM STONE BLOCK)
	(ADJECTIVE HEWN DRESSED)
	(DESC "hewn stone")
	(FLAGS NDESCBIT)
	(ACTION HEWN-STONE-FCN)>

<OBJECT SHARD
	(SYNONYM SHARD SHARDS FRAGMENT)
	(ADJECTIVE SHARP)
	(DESC "sharp shard")
	(FLAGS NDESCBIT TAKEBIT TOOLBIT)
	(SIZE 1)
	(ACTION SHARD-FCN)>

<OBJECT SAUCEPAN
	(SYNONYM SAUCEPAN PAN)
	(ADJECTIVE IRON)
	(DESC "iron saucepan")
	(FLAGS NDESCBIT)
	(ACTION SAUCEPAN-FCN)>

<OBJECT PAN-HANDLE
	(SYNONYM HANDLE LEVER)
	(ADJECTIVE IRON)
	(DESC "iron handle")
	(FLAGS NDESCBIT TAKEBIT TOOLBIT)
	(SIZE 3)
	(ACTION PAN-HANDLE-FCN)>

<OBJECT TUNNEL-HOLE
	(SYNONYM TUNNEL CAVITY HOLE BURROW)
	(DESC "tunnel mouth")
	(FLAGS NDESCBIT)
	(ACTION TUNNEL-HOLE-FCN)>

<OBJECT VOICE
	(SYNONYM VOICE)
	(DESC "voice")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION VOICE-FCN)>

<OBJECT FARIA
	(SYNONYM FARIA ABBE PRIEST)
	(ADJECTIVE OLD)
	(DESC "Abbe Faria")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION FARIA-FCN)>

<OBJECT HEARTH
	(IN CELL27)
	(SYNONYM HEARTH HEARTHSTONE FIREPLACE)
	(ADJECTIVE DISUSED)
	(DESC "disused hearth")
	(FLAGS NDESCBIT)
	(ACTION HEARTH-FCN)>

<OBJECT CACHE
	(SYNONYM CACHE HIDING)
	(DESC "hollow beneath the hearth")
	(FLAGS NDESCBIT CONTBIT OPENBIT)
	(CAPACITY 50)
	(ACTION CACHE-FCN)>

<OBJECT CHISEL
	(IN CACHE)
	(SYNONYM CHISEL CLAMP)
	(ADJECTIVE BEECHWOOD)
	(DESC "chisel")
	(FLAGS TAKEBIT TOOLBIT)
	(SIZE 2)
	(TEXT
"A blade set in a beechwood handle: a bed-clamp, four years in the
making.")>

<OBJECT KNIFE
	(IN CACHE)
	(SYNONYM KNIFE BLADE)
	(ADJECTIVE IRON)
	(DESC "iron knife")
	(FLAGS TAKEBIT TOOLBIT WEAPONBIT)
	(SIZE 2)
	(ACTION KNIFE-FCN)
	(TEXT
"Made of an old iron candlestick. It cuts and it thrusts.")>

<OBJECT NEEDLE
	(SYNONYM NEEDLE THREAD)
	(ADJECTIVE FISHBONE)
	(DESC "fish-bone needle")
	(FLAGS TAKEBIT TOOLBIT)
	(SIZE 1)
	(TEXT "A fish-bone, eyed, still threaded.")>

<OBJECT PRISON-LAMP
	(IN CACHE)
	(SYNONYM LAMP FLINT)
	(DESC "little lamp")
	(FLAGS TAKEBIT)
	(SIZE 2)
	(TEXT
"A lamp of meat-fat oil, with flint and burnt linen for its lighting.
Faria made fire itself from patience.")>

<OBJECT PHIAL
	(SYNONYM PHIAL BOTTLE CORDIAL DROPS)
	(ADJECTIVE RED SMALL)
	(DESC "small phial")
	(FLAGS TAKEBIT)
	(SIZE 1)
	(ACTION PHIAL-FCN)
	(TEXT
"A small bottle half full of red liquor. Ten drops of it once called
the abbe back from the edge.")>

<OBJECT MANUSCRIPT
	(SYNONYM MANUSCRIPT TREATISE STRIPS LINEN)
	(DESC "linen manuscript")
	(FLAGS TAKEBIT READBIT)
	(SIZE 3)
	(ACTION MANUSCRIPT-FCN)>

<OBJECT PARCHMENT
	(SYNONYM PARCHMENT WILL PAPER)
	(ADJECTIVE BURNED SCORCHED)
	(DESC "Spada parchment")
	(FLAGS TAKEBIT READBIT)
	(SIZE 1)
	(ACTION PARCHMENT-FCN)>

<OBJECT FARIA-BED
	(IN CELL27)
	(SYNONYM BED BEDSTEAD LADDER)
	(ADJECTIVE ABBES)
	(DESC "abbe's bed")
	(FLAGS NDESCBIT)
	(ACTION FARIA-BED-FCN)>

<OBJECT SACK
	(SYNONYM SACK SHROUD CANVAS SEAM)
	(ADJECTIVE BURIAL COARSE)
	(DESC "burial sack")
	(FLAGS NDESCBIT)
	(ACTION SACK-FCN)>

<OBJECT BODY
	(SYNONYM BODY CORPSE ABBE FARIA)
	(ADJECTIVE DEAD)
	(DESC "abbe's body")
	(FLAGS NDESCBIT TRYTAKEBIT)
	(SIZE 40)
	(ACTION BODY-FCN)>

<OBJECT CORD
	(IN UNDERSEA)
	(SYNONYM CORD ROPE KNOT SHOT)
	(DESC "cord at your feet")
	(FLAGS NDESCBIT)
	(ACTION CORD-FCN)>

<OBJECT OVERHANG
	(IN TIBOULEN)
	(SYNONYM OVERHANG ROCK SHELTER)
	(ADJECTIVE OVERHANGING)
	(DESC "overhanging rock")
	(FLAGS NDESCBIT)
	(ACTION OVERHANG-FCN)>

<OBJECT HOLLOW
	(IN TIBOULEN)
	(SYNONYM HOLLOW RAINWATER)
	(DESC "rock hollow")
	(FLAGS NDESCBIT)
	(ACTION HOLLOW-FCN)>

<OBJECT WRECKAGE
	(SYNONYM WRECKAGE WRECK SPLINTERS)
	(DESC "wreckage")
	(FLAGS NDESCBIT)
	(TEXT
"Splinters of a fishing boat, and of the men who sailed her. The sea
gives back only what it does not want.")>

<OBJECT RED-CAP
	(SYNONYM CAP)
	(ADJECTIVE RED WOOLEN)
	(DESC "red woolen cap")
	(FLAGS TAKEBIT WEARBIT)
	(SIZE 1)
	(ACTION RED-CAP-FCN)>

<OBJECT SPAR
	(SYNONYM SPAR PLANK TIMBER)
	(DESC "wreck spar")
	(FLAGS TAKEBIT)
	(SIZE 8)
	(TEXT
"A spar off the wreck, big enough to bear a swimmer's chest.")>

<OBJECT TARTAN-SHIP
	(SYNONYM TARTAN LATEEN)
	(ADJECTIVE GENOESE)
	(DESC "Genoese tartan")
	(FLAGS NDESCBIT)
	(ACTION TARTAN-SHIP-FCN)>

"Act II conversation topics (local-globals for the cells)"

<OBJECT LETTER-T
	(IN GLOBAL-OBJECTS)
	(SYNONYM LETTER)
	(DESC "letter")
	(FLAGS NDESCBIT)
	(ACTION TOPIC-FCN)>

<OBJECT ARREST-T
	(IN GLOBAL-OBJECTS)
	(SYNONYM ARREST ACCUSATION DENUNCIATION)
	(DESC "arrest")
	(FLAGS NDESCBIT)
	(ACTION TOPIC-FCN)>

;"Conversation topics. Every one of these words also names a person who
appears somewhere in the game; the person objects are retired from play
the moment their act ends (RETIRE-CAST), so only one of the two is ever
in scope and ASK X ABOUT DANGLARS never asks which Danglars."

<OBJECT DANGLARS-T
	(IN GLOBAL-OBJECTS)
	(SYNONYM DANGLARS BANKER)
	(DESC "Danglars")
	(FLAGS NDESCBIT)
	(ACTION TOPIC-FCN)>

<OBJECT FERNAND-T
	(IN GLOBAL-OBJECTS)
	(SYNONYM FERNAND MORCERF)
	(DESC "Fernand")
	(FLAGS NDESCBIT)
	(ACTION TOPIC-FCN)>

<OBJECT VILLEFORT-T
	(IN GLOBAL-OBJECTS)
	(SYNONYM VILLEFORT PROCUREUR)
	(DESC "Villefort")
	(FLAGS NDESCBIT)
	(ACTION TOPIC-FCN)>

<OBJECT MERCEDES-T
	(IN GLOBAL-OBJECTS)
	(SYNONYM MERCEDES)
	(DESC "Mercedes")
	(FLAGS NDESCBIT)
	(ACTION TOPIC-FCN)>

<OBJECT CMORR-T
	(IN GLOBAL-OBJECTS)
	(SYNONYM MORREL)
	(DESC "M. Morrel")
	(FLAGS NDESCBIT)
	(ACTION TOPIC-FCN)>

<OBJECT FATHER-T
	(IN GLOBAL-OBJECTS)
	(SYNONYM FATHER)
	(DESC "old Dantes")
	(FLAGS NDESCBIT)
	(ACTION TOPIC-FCN)>

<OBJECT NOIRTIER-T
	(IN GLOBAL-OBJECTS)
	(SYNONYM NOIRTIER)
	(DESC "Noirtier")
	(FLAGS NDESCBIT)
	(ACTION TOPIC-FCN)>

<OBJECT DANTES-T
	(IN GLOBAL-OBJECTS)
	(SYNONYM DANTES EDMOND)
	(DESC "Edmond Dantes")
	(FLAGS NDESCBIT)
	(ACTION TOPIC-FCN)>

<OBJECT BENEDETTO-T
	(IN GLOBAL-OBJECTS)
	(SYNONYM BENEDETTO CAVALCANTI)
	(DESC "Benedetto")
	(FLAGS NDESCBIT)
	(ACTION TOPIC-FCN)>

<OBJECT VALENTINE-T
	(IN GLOBAL-OBJECTS)
	(SYNONYM VALENTINE)
	(DESC "Valentine")
	(FLAGS NDESCBIT)
	(ACTION TOPIC-FCN)>

<OBJECT TREASURE-T
	(IN GLOBAL-OBJECTS)
	(SYNONYM TREASURE FORTUNE GOLD)
	(DESC "treasure")
	(FLAGS NDESCBIT)
	(ACTION TOPIC-FCN)>

<OBJECT ESCAPE-T
	(IN GLOBAL-OBJECTS)
	(SYNONYM ESCAPE FREEDOM)
	(DESC "escape")
	(FLAGS NDESCBIT)
	(ACTION TOPIC-FCN)>

<OBJECT GOD-T
	(IN GLOBAL-OBJECTS)
	(SYNONYM GOD PROVIDENCE DESPAIR)
	(DESC "God")
	(FLAGS NDESCBIT)
	(ACTION TOPIC-FCN)>

<OBJECT SPADA-T
	(IN GLOBAL-OBJECTS)
	(SYNONYM SPADA CARDINAL)
	(DESC "Spada")
	(FLAGS NDESCBIT)
	(ACTION TOPIC-FCN)>

"=== ACT III - MONTE CRISTO AND THE MAINLAND, 1829 ==="

<ROOM TARTAN
      (IN ROOMS)
      (DESC "Deck of the Jeune-Amelie")
      (LDESC
"A smuggler tartan heeling under lateen sails, bound for the island of
Monte Cristo with contraband and no questions. The boat that takes you
ashore lies west. Jacopo splices a line and watches you the way honest
men watch lucky ones.")
      (LAND TO CREEK)
      (OUT TO CREEK)
      (EXIT TO CREEK)
      (WEST TO CREEK)
      (FLAGS RLANDBIT ONBIT)>

<ROOM CREEK
      (IN ROOMS)
      (DESC "The Hidden Creek")
      (LDESC
"A small creek hidden like the bath of some ancient nymph, deep enough
at the center for a little vessel. From the waterline, a line of old
notches cut in the rocks marches away to the east.")
      (EAST TO ISLE-PATH)
      (GLOBAL ROCKS)
      (FLAGS RLANDBIT ONBIT)>

<ROOM ISLE-PATH
      (IN ROOMS)
      (DESC "Goat Path")
      (LDESC
"A scramble of myrtle and hot granite. Lizards flash like emeralds;
somewhere above, wild goats clatter. The notch marks continue east in
a right line.")
      (WEST TO CREEK)
      (EAST TO CLEARING)
      (UP TO HIGHROCK)
      (GLOBAL ROCKS)
      (FLAGS RLANDBIT ONBIT)>

<ROOM HIGHROCK
      (IN ROOMS)
      (DESC "The High Rock")
      (LDESC
"The island's summit: a statue's view from a granite pedestal. Corsica
to the north, Elba, the far smudge of Genoa; and below, the sails of
the Jeune-Amelie shrinking toward the horizon. You are alone.")
      (DOWN TO ISLE-PATH)
      (FLAGS RLANDBIT ONBIT)>

<ROOM CLEARING
      (IN ROOMS)
      (DESC "The Circular Rock")
      (LDESC
"The notches end at a huge circular boulder squatting on a bed of
smaller stones. Moss and myrtle have sworn it has sat here since the
Flood. Cardinal Spada's men swore the same thing, in 1498. The goat
path runs back west toward the creek.")
      (WEST TO ISLE-PATH)
      (DOWN PER CLEARING-DOWN)
      (ACTION CLEARING-FCN)
      (GLOBAL ROCKS STAIRS)
      (FLAGS RLANDBIT ONBIT)>

<ROOM GROTTO1
      (IN ROOMS)
      (DESC "The First Grotto")
      (LDESC
"A dim and bluish light seeps through crevices; the granite walls
sparkle as if sown with diamond dust. The air is warm and dry. The
stair goes back up to the daylight, and somewhere in this glitter a
second door is pretending to be a wall.")
      (UP TO CLEARING)
      (EAST PER GROTTO1-EAST)
      (ACTION GROTTO1-FCN)
      (GLOBAL STAIRS)
      (FLAGS RLANDBIT ONBIT)>

<ROOM GROTTO2
      (IN ROOMS)
      (DESC "The Second Grotto")
      (LDESC
"Lower, darker, closer. The air is old. In the farthest angle to the
left, the ground has been waiting three hundred and forty years for a
man with a pickaxe.")
      (WEST TO GROTTO1)
      (FLAGS RLANDBIT ONBIT)>

<ROOM BEAUCAIRE-ROAD
      (IN ROOMS)
      (DESC "The Beaucaire Road")
      (LDESC
"A white dusty road between Bellegarde and Beaucaire. A failing inn
stands here, its signboard groaning in the wind: the Pont du Gard. The
door leads east; the road to Marseilles runs south.")
      (IN PER ROAD-IN)
      (ENTRANCE PER ROAD-IN)
      (EAST PER ROAD-IN)
      (SOUTH PER ROAD-SOUTH)
      (WEST PER ROAD-SOUTH)
      (OUT PER ROAD-SOUTH)
      (EXIT PER ROAD-SOUTH)
      (FLAGS RLANDBIT ONBIT)>

<ROOM INN
      (IN ROOMS)
      (DESC "The Pont du Gard Inn")
      (LDESC
"A failing inn on the Beaucaire road; the way out leads west, to the
road. Caderousse, gone gray and sour, wipes a table that no traveler
will sit at. Poverty has been at work on him the way the sea works on
a wreck.")
      (OUT TO BEAUCAIRE-ROAD)
      (EXIT TO BEAUCAIRE-ROAD)
      (WEST TO BEAUCAIRE-ROAD)
      (ACTION INN-FCN)
      (FLAGS RLANDBIT ONBIT)>

"Act III objects"

<OBJECT ROCKS
	(IN LOCAL-GLOBALS)
	(SYNONYM ROCKS NOTCHES MARKS NOTCH)
	(DESC "notched rocks")
	(FLAGS NDESCBIT)
	(ACTION ROCKS-FCN)>

<OBJECT BOULDER
	(IN CLEARING)
	(SYNONYM BOULDER ROCK)
	(ADJECTIVE CIRCULAR HUGE)
	(DESC "circular boulder")
	(FLAGS NDESCBIT)
	(ACTION BOULDER-FCN)>

<OBJECT WEDGE
	(IN CLEARING)
	(SYNONYM WEDGE BASE FLINTS)
	(ADJECTIVE PACKED)
	(DESC "wedge stone")
	(FLAGS NDESCBIT)
	(ACTION WEDGE-FCN)>

<OBJECT OLIVE-TREE
	(IN CLEARING)
	(SYNONYM TREE BOUGH)
	(ADJECTIVE OLIVE)
	(DESC "olive tree")
	(FLAGS NDESCBIT)
	(ACTION OLIVE-TREE-FCN)>

<OBJECT BRANCH
	(SYNONYM BRANCH)
	(ADJECTIVE OLIVE STRONG)
	(DESC "olive branch")
	(FLAGS TAKEBIT TOOLBIT)
	(SIZE 8)
	(TEXT "The strongest olive bough on the island, cut and stripped.")>

<OBJECT BLAST-HOLE
	(SYNONYM HOLE)
	(ADJECTIVE BLAST)
	(DESC "hole under the wedge")
	(FLAGS NDESCBIT CONTBIT OPENBIT)
	(CAPACITY 10)
	(ACTION BLAST-HOLE-FCN)>

<OBJECT PICKAXE
	(SYNONYM PICKAXE PICK)
	(DESC "pickaxe")
	(FLAGS TAKEBIT TOOLBIT WEAPONBIT)
	(SIZE 8)
	(TEXT "Jacopo's pickaxe, left with the supplies. It opens everything.")>

<OBJECT POWDER-HORN
	(SYNONYM HORN)
	(ADJECTIVE POWDER)
	(DESC "powder horn")
	(FLAGS TAKEBIT)
	(SIZE 3)
	(TEXT
"A smuggler's powder horn, full, with flint in the cap.")>

<OBJECT SUPPLIES
	(SYNONYM SUPPLIES GUN BISCUITS RUM)
	(DESC "small store of supplies")
	(FLAGS NDESCBIT)
	(TEXT
"A gun, biscuits, and rum: a week's worry from Jacopo's own share.")>

<OBJECT FUSE
	(SYNONYM MATCH FUSE HANDKE)
	(ADJECTIVE SLOW)
	(DESC "slow-match")
	(FLAGS NDESCBIT)
	(ACTION FUSE-FCN)>

<OBJECT IRON-RING
	(SYNONYM RING)
	(ADJECTIVE IRON)
	(DESC "iron ring")
	(FLAGS NDESCBIT)
	(ACTION IRON-RING-FCN)>

<OBJECT FLAGSTONE
	(SYNONYM FLAGSTONE FLAG SLAB)
	(ADJECTIVE SQUARE)
	(DESC "square flagstone")
	(FLAGS NDESCBIT)
	(ACTION IRON-RING-FCN)>

<OBJECT STUCCO
	(IN GROTTO1)
	(SYNONYM STUCCO PATCH STONES)
	(ADJECTIVE PAINTED WHITE DRESSED)
	(DESC "stucco patch")
	(FLAGS NDESCBIT)
	(ACTION STUCCO-FCN)>

<OBJECT DIG-CORNER
	(IN GROTTO2)
	(SYNONYM ANGLE GROUND EARTH)
	(ADJECTIVE FARTHEST DARK)
	(DESC "farthest angle")
	(FLAGS NDESCBIT)
	(ACTION DIG-CORNER-FCN)>

<OBJECT COFFER
	(SYNONYM COFFER)
	(ADJECTIVE OAK OAKEN)
	(DESC "oaken coffer")
	(FLAGS NDESCBIT CONTBIT)
	(CAPACITY 90)
	(ACTION COFFER-FCN)>

<OBJECT TREASURE
	(IN COFFER)
	(SYNONYM TREASURE GOLD COIN INGOTS GEMS JEWELS)
	(DESC "Spada treasure")
	(FLAGS NDESCBIT TRYTAKEBIT)
	(ACTION TREASURE-FCN)>

<OBJECT DIAMOND
	(SYNONYM DIAMOND)
	(ADJECTIVE GREAT)
	(DESC "great diamond")
	(FLAGS TAKEBIT)
	(SIZE 1)
	(TEXT
"A diamond worth fifty thousand francs, cold as a confessor's eye.")>

<OBJECT GEM
	(SYNONYM GEM RUBY)
	(ADJECTIVE SECOND)
	(DESC "second great stone")
	(FLAGS TAKEBIT)
	(SIZE 1)
	(TEXT
"Another great stone from the coffer. You have plans for this one
too.")>

<OBJECT CASSOCK
	(SYNONYM CASSOCK ROBE)
	(ADJECTIVE PRIESTS BLACK)
	(DESC "priest's cassock")
	(FLAGS TAKEBIT WEARBIT)
	(SIZE 4)
	(ACTION CASSOCK-FCN)
	(TEXT
"The black cassock of the Abbe Busoni. Men tell priests what they
tell no one living.")>

<OBJECT WIG
	(SYNONYM WIG TONSURE)
	(ADJECTIVE PRIESTS)
	(DESC "priest's wig")
	(FLAGS TAKEBIT WEARBIT NDESCBIT)
	(SIZE 1)
	(ACTION WIG-FCN)
	(TEXT
"The gray tonsured wig that finishes the Abbe Busoni. Under it, black
hair; under the hair, Edmond Dantes.")>

<OBJECT ENGLISH-COAT
	(SYNONYM COAT)
	(ADJECTIVE ENGLISH DRAB ENGLISHMANS)
	(DESC "Englishman's drab coat")
	(FLAGS TAKEBIT WEARBIT)
	(SIZE 4)
	(ACTION ENGLISH-COAT-FCN)
	(TEXT
"The drab coat of Lord Wilmore, agent of Thomson and French. The
English may be eccentric; their money never is.")>

<OBJECT CUPBOARD
	(IN INN)
	(SYNONYM CUPBOARD)
	(DESC "cupboard")
	(FLAGS NDESCBIT CONTBIT)
	(ACTION CUPBOARD-FCN)>

<OBJECT RED-PURSE
	(SYNONYM PURSE)
	(ADJECTIVE RED SILK)
	(DESC "red silk purse")
	(FLAGS TAKEBIT CONTBIT OPENBIT)
	(CAPACITY 10)
	(SIZE 2)
	(ACTION RED-PURSE-FCN)>

<OBJECT RECEIPTED-BILL
	(SYNONYM BILL RECEIPT)
	(ADJECTIVE RECEIPTED)
	(DESC "receipted bill")
	(FLAGS TAKEBIT READBIT)
	(SIZE 1)
	(TEXT
"Every Morrel debt, bought and marked paid by the house of Thomson
and French. Two hundred and eighty-seven thousand francs of mercy.")>

"Act III inn topics"

<OBJECT PURSE-T
	(IN GLOBAL-OBJECTS)
	(SYNONYM PURSE)
	(DESC "red purse")
	(FLAGS NDESCBIT)
	(ACTION TOPIC-FCN)>

<OBJECT DIAMOND-T
	(IN GLOBAL-OBJECTS)
	(SYNONYM DIAMOND LEGACY)
	(DESC "diamond")
	(FLAGS NDESCBIT)
	(ACTION TOPIC-FCN)>

"Act III Marseilles topics (counting-house)"

<OBJECT DEBT-T
	(IN GLOBAL-OBJECTS)
	(SYNONYM DEBT BILLS CREDITORS)
	(DESC "debt")
	(FLAGS NDESCBIT)
	(ACTION TOPIC-FCN)>

<OBJECT SEPTEMBER-T
	(IN GLOBAL-OBJECTS)
	(SYNONYM SEPTEMBER FIFTH)
	(DESC "fifth of September")
	(FLAGS NDESCBIT)
	(ACTION TOPIC-FCN)>

<OBJECT SHIP-T
	(IN GLOBAL-OBJECTS)
	(SYNONYM SHIP PHARAON BOAT VESSEL)
	(DESC "Pharaon")
	(FLAGS NDESCBIT)
	(ACTION SHIP-FCN)>

<OBJECT COCLES
	(IN OFFICE)
	(SYNONYM COCLES CASHIER)
	(DESC "Cocles")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION COCLES-FCN)>

"=== GO and engine-required stubs ==="

<ROUTINE GO ()
	<SETG HERE ,DECK>
	<SETG LIT T>
	<SETG WINNER ,ADVENTURER>
	<SETG PLAYER ,WINNER>
	<MOVE ,WINNER ,HERE>
	<MOVE ,ELBA-LETTER ,WINNER>
	<MOVE ,COIN-PURSE ,WINNER>
	<TELL
"On the twenty-fourth of February, eighteen hundred and fifteen, the
lookout at Notre-Dame de la Garde signals the three-master Pharaon,
from Smyrna, Trieste, and Naples. All Marseilles turns out to watch
her come in, for she comes in strangely: slow, and sedate, and trimmed
in mourning." CR CR
"Her captain is dead. Off Civita Vecchia the fever took brave Captain
Leclere, and he went to his rest sewn in his hammock with a
thirty-six-pound shot at his head and his heels. The man at the helm,
who brought her home through the February gales, is nineteen years
old." CR CR
"He is you. Edmond Dantes: first mate, about to be captain; son of a
good father; betrothed of the most beautiful girl in the Catalan
village. You are, this morning, the happiest man in Marseilles. And
three men on this quay are already sick with wanting what you have." CR CR
"Bring your ship to her rest. Then go collect your happiness, all of
it, piece by piece. You will want to remember where each piece came
from." CR CR
"THE COUNT OF MONTE CRISTO" CR
"An interactive tragedy of patience." CR CR>
	<V-LOOK>
	<MAIN-LOOP>
	<AGAIN>>

"Stub objects the generic engine verbs reference."

<OBJECT WATER
	(SYNONYM WATER)
	(DESC "quantity of water")
	(FLAGS TRYTAKEBIT TAKEBIT DRINKBIT)>

<OBJECT GLOBAL-WATER
	(IN GLOBAL-OBJECTS)
	(SYNONYM WATER SEA)
	(ADJECTIVE GLOBAL)
	(DESC "water")
	(FLAGS DRINKBIT)
	(ACTION GLOBAL-WATER-FCN)>

<OBJECT WALL
	(IN GLOBAL-OBJECTS)
	(SYNONYM WALL WALLS)
	(DESC "wall")
	(ACTION CWALL-FCN)>

"=== PLACES ===

A player who is told to come to the counting-house types GO TO
COUNTING HOUSE, and a player standing on a deck types GO TO QUAY. Every
destination this game names in its own prose is a global object here, so
those words are in the dictionary and PLACE-FCN can either walk the
player there or say which way it lies. Without these the game directs
the player in words its own parser refuses to hear, which is how one
real player got stranded on the Pharaon at turn three."

<OBJECT P-QUAY
	(IN GLOBAL-OBJECTS)
	(SYNONYM QUAY WHARF DOCK HARBOR SHORE)
	(DESC "quay")
	(FLAGS NDESCBIT)
	(ACTION PLACE-FCN)>

<OBJECT P-OFFICE
	(IN GLOBAL-OBJECTS)
	;"COUNTING is the adjective and HOUSE the noun, so GO TO COUNTING
	  HOUSE parses as an adjective-noun pair; the hyphenated and
	  run-together spellings are separate nouns because the parser
	  splits on the hyphen. COUNTING must not also be a SYNONYM here
	  (see BUILD-ISSUES section 1)."
	(SYNONYM HOUSE OFFICE COUNTINGH COUNTIN)
	(ADJECTIVE COUNTING MORRELS)
	(DESC "counting-house")
	(FLAGS NDESCBIT)
	(ACTION PLACE-FCN)>

<OBJECT P-MEILHAN
	(IN GLOBAL-OBJECTS)
	(SYNONYM MEILHAN ALLEES)
	(DESC "Allees de Meilhan")
	(FLAGS NDESCBIT)
	(ACTION PLACE-FCN)>

<OBJECT P-CATALANS
	(IN GLOBAL-OBJECTS)
	(SYNONYM CATALANS VILLAGE COTTAGES)
	(ADJECTIVE CATALAN)
	(DESC "Catalan village")
	(FLAGS NDESCBIT)
	(ACTION PLACE-FCN)>

<OBJECT P-RESERVE
	(IN GLOBAL-OBJECTS)
	(SYNONYM RESERVE)
	(DESC "arbor of La Reserve")
	(FLAGS NDESCBIT)
	(ACTION PLACE-FCN)>

<OBJECT P-DECK
	(IN GLOBAL-OBJECTS)
	(SYNONYM DECK HELM)
	(DESC "deck")
	(FLAGS NDESCBIT)
	(ACTION PLACE-FCN)>

<OBJECT P-CABIN
	(IN GLOBAL-OBJECTS)
	(SYNONYM CABIN)
	(ADJECTIVE CAPTAINS)
	(DESC "captain's cabin")
	(FLAGS NDESCBIT)
	(ACTION PLACE-FCN)>

<OBJECT P-INN
	(IN GLOBAL-OBJECTS)
	(SYNONYM INN TAVERN)
	(DESC "Pont du Gard inn")
	(FLAGS NDESCBIT)
	(ACTION PLACE-FCN)>

<OBJECT P-BANK
	(IN GLOBAL-OBJECTS)
	(SYNONYM BANK)
	(DESC "bank")
	(FLAGS NDESCBIT)
	(ACTION PLACE-FCN)>

<OBJECT P-PRESS
	(IN GLOBAL-OBJECTS)
	(SYNONYM NEWSPAPER IMPARTIAL)
	(DESC "newspaper offices")
	(FLAGS NDESCBIT)
	(ACTION PLACE-FCN)>

<OBJECT P-PEERS
	(IN GLOBAL-OBJECTS)
	(SYNONYM CHAMBER GALLERY)
	(DESC "Chamber of Peers")
	(FLAGS NDESCBIT)
	(ACTION PLACE-FCN)>

<OBJECT P-ASSIZES
	(IN GLOBAL-OBJECTS)
	(SYNONYM ASSIZES COURT COURTS)
	(DESC "Court of Assizes")
	(FLAGS NDESCBIT)
	(ACTION PLACE-FCN)>

<OBJECT P-TELEGRAPH
	(IN GLOBAL-OBJECTS)
	(SYNONYM TELEGRAP TOWER)
	(DESC "telegraph")
	(FLAGS NDESCBIT)
	(ACTION PLACE-FCN)>

<OBJECT P-AUTEUIL
	(IN GLOBAL-OBJECTS)
	(SYNONYM AUTEUIL COACH CARRIAGE)
	(DESC "house at Auteuil")
	(FLAGS NDESCBIT)
	(ACTION PLACE-FCN)>

<OBJECT P-VHALL
	(IN GLOBAL-OBJECTS)
	(SYNONYM FAUBOURG)
	(DESC "Villefort's house")
	(FLAGS NDESCBIT)
	(ACTION PLACE-FCN)>

<OBJECT P-SALON
	(IN GLOBAL-OBJECTS)
	(SYNONYM SALON)
	(DESC "salon")
	(FLAGS NDESCBIT)
	(ACTION PLACE-FCN)>

<OBJECT P-STUDY
	(IN GLOBAL-OBJECTS)
	(SYNONYM WARDROBE)
	(DESC "study")
	(FLAGS NDESCBIT)
	(ACTION PLACE-FCN)>

<OBJECT P-GARDEN
	(IN GLOBAL-OBJECTS)
	(SYNONYM GARDEN)
	(DESC "garden")
	(FLAGS NDESCBIT)
	(ACTION PLACE-FCN)>

<OBJECT P-CELL27
	(IN GLOBAL-OBJECTS)
	(SYNONYM ABBES)
	(ADJECTIVE TWENTYSEV)
	(DESC "abbe's cell")
	(FLAGS NDESCBIT)
	(ACTION PLACE-FCN)>

<OBJECT P-CELL34
	(IN GLOBAL-OBJECTS)
	(SYNONYM CELL)
	(ADJECTIVE THIRTYFOU)
	(DESC "your cell")
	(FLAGS NDESCBIT)
	(ACTION PLACE-FCN)>

<OBJECT P-GROTTO
	(IN GLOBAL-OBJECTS)
	(SYNONYM GROTTO GROTTOES)
	(DESC "grotto")
	(FLAGS NDESCBIT)
	(ACTION PLACE-FCN)>

<OBJECT P-ISLAND
	(IN GLOBAL-OBJECTS)
	(SYNONYM ISLAND CRISTO MONTECRIS)
	(DESC "island of Monte Cristo")
	(FLAGS NDESCBIT)
	(ACTION PLACE-FCN)>

<OBJECT P-TOWN
	(IN GLOBAL-OBJECTS)
	(SYNONYM MARSEILLE TOWN CITY PARIS)
	(DESC "town")
	(FLAGS NDESCBIT)
	(ACTION PLACE-FCN)>

"Unreachable stub rooms for generic engine verb branches."

<ROOM ON-LAKE
      (IN ROOMS)
      (DESC "On the Lake")
      (FLAGS RLANDBIT)>

<ROOM IN-LAKE
      (IN ROOMS)
      (DESC "In the Lake")
      (FLAGS RLANDBIT)>

"Unplaced stub carrying engine-referenced flags no real object uses."

<OBJECT FLAG-CARRIER
	(DESC "flag carrier")
	(FLAGS NONLANDBIT VEHBIT SEARCHBIT TURNBIT CLIMBBIT BURNBIT
	       FLAMEBIT LIGHTBIT FOODBIT DRINKBIT)>
