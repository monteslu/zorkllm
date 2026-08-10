"DWORLD - DRACULA: The Un-Dead. Rooms, objects, stubs, and GO.
Act I: Castle Dracula (16 rooms). Act II-1: Whitby (7 rooms).
Act II-2: London/Purfleet (16 rooms). Act III: the chase (4 rooms),
plus three castle rooms revisited."

<DIRECTIONS NORTH EAST WEST SOUTH NE NW SE SW UP DOWN IN OUT LAND>

"====================================================================
ACT I - CASTLE DRACULA"

<ROOM COURTYARD
      (IN ROOMS)
      (DESC "Castle Courtyard")
      (NORTH PER COURTYARD-NORTH)
      (IN PER COURTYARD-NORTH)
      (SOUTH "The way you came is night and forest and the howling of
wolves. There is no going back on foot.")
      (UP PER COURTYARD-NORTH)
      (ACTION COURTYARD-FCN)
      (GLOBAL GREAT-DOOR CASTLE-G)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<OBJECT GREAT-DOOR
	(IN LOCAL-GLOBALS)
	(SYNONYM DOOR GATE)
	(ADJECTIVE GREAT NAILED OUTER)
	(DESC "great door")
	(FLAGS DOORBIT NDESCBIT)
	(ACTION GREAT-DOOR-FCN)>

<OBJECT ARCHWAYS
	(IN COURTYARD)
	(SYNONYM ARCHWAYS ARCHES GATES ARCHWAY)
	(ADJECTIVE DARK BARRED IRON)
	(DESC "dark archways")
	(FLAGS NDESCBIT)
	(TEXT
"Cold air breathes out of the dark, and iron gates bar every one. Whatever
the archways lead to, they lead there without you.")>

<OBJECT CASTLE-G
	(IN GLOBAL-OBJECTS)
	(SYNONYM CASTLE KEEP BATTLEMENTS RUIN)
	(ADJECTIVE VAST RUINED BLACK)
	(DESC "castle")
	(FLAGS NDESCBIT)
	(TEXT
"A vast ruined pile, its tall black windows empty of light, its broken
battlements a jagged line against the sky. It has stood so for centuries,
and looks willing to stand so for centuries more.")>

<ROOM ENTRANCE-HALL
      (IN ROOMS)
      (DESC "Entrance Hall")
      (LDESC
"A stone hall lit by a hanging silver lamp. The great outer door is bound
with chains and massive bolts, and a stone stair winds upward into gloom.")
      (SOUTH PER HALL-SOUTH)
      (OUT PER HALL-SOUTH)
      (UP TO WINDING-STAIR)
      (ACTION ENTRANCE-HALL-FCN)
      (GLOBAL GREAT-DOOR STAIRS)
      (FLAGS RLANDBIT ONBIT)>

<ROOM WINDING-STAIR
      (IN ROOMS)
      (DESC "Winding Stair")
      (LDESC
"Steps of worn stone circle upward, ringing under your feet. The draught
carries the far howling of wolves.")
      (DOWN TO ENTRANCE-HALL)
      (UP TO UPPER-PASSAGE)
      (ACTION ACT1-STAIR-FCN)
      (GLOBAL STAIRS WOLVES-G)
      (FLAGS RLANDBIT ONBIT)>

<ROOM UPPER-PASSAGE
      (IN ROOMS)
      (DESC "Upper Passage")
      (LDESC
"A long stone corridor of doors, doors everywhere, and every one locked
and bolted. At its end a heavy door sags against the floor, and a
narrower stair climbs up to a landing full of sky. The winding stair goes
down; a doorway opens west.")
      (DOWN TO WINDING-STAIR)
      (WEST TO DINING-ROOM)
      (UP TO SOUTH-LANDING)
      (EAST PER STUCK-EAST)
      (ACTION UPPER-PASSAGE-FCN)
      (GLOBAL STAIRS LOCKED-DOORS STUCK-DOOR)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT LOCKED-DOORS
	(IN LOCAL-GLOBALS)
	(SYNONYM DOORS)
	(ADJECTIVE LOCKED BOLTED)
	(DESC "locked doors")
	(FLAGS NDESCBIT)
	(ACTION LOCKED-DOORS-FCN)>

<OBJECT STUCK-DOOR
	(IN LOCAL-GLOBALS)
	(SYNONYM DOOR)
	(ADJECTIVE STUCK HEAVY JAMMED EAST)
	(DESC "heavy door")
	(FLAGS DOORBIT NDESCBIT)
	(ACTION STUCK-DOOR-FCN)>

<ROOM DINING-ROOM
      (IN ROOMS)
      (DESC "Dining Room")
      (LDESC
"A table of gold plate stands before a mighty hearth where a log fire
roars. There is warmth here, and welcome of a kind, and no mirror
anywhere. Doorways lead east, west, and south.")
      (EAST TO UPPER-PASSAGE)
      (WEST TO LIBRARY)
      (SOUTH TO OCTAGONAL-ROOM)
      (ACTION DINING-ROOM-FCN)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT DINING-TABLE
	(IN DINING-ROOM)
	(SYNONYM TABLE)
	(ADJECTIVE LONG)
	(DESC "long table")
	(FLAGS NDESCBIT SURFACEBIT CONTBIT OPENBIT)
	(CAPACITY 50)
	(TEXT
"Gold plate, old and heavy, laid for one. Whoever keeps this house serves
at it, and is never seen to eat.")>

<OBJECT GOLD-SERVICE
	(IN DINING-ROOM)
	(SYNONYM SERVICE PLATE CUPS)
	(ADJECTIVE GOLD GOLDEN)
	(DESC "golden service")
	(FLAGS NDESCBIT TRYTAKEBIT)
	(ACTION GOLD-SERVICE-FCN)>

<OBJECT DINING-FIRE
	(IN DINING-ROOM)
	(SYNONYM FIRE HEARTH LOGS)
	(ADJECTIVE LOG MIGHTY)
	(DESC "log fire")
	(FLAGS NDESCBIT)
	(TEXT
"Great logs, freshly replenished, though you have never once heard a
servant. The fire is the only thing in this castle that behaves as if
nothing were wrong.")>

<OBJECT DRACULA-CARD
	(IN DINING-ROOM)
	(SYNONYM CARD NOTE)
	(DESC "written card")
	(FLAGS TAKEBIT READBIT)
	(SIZE 1)
	(FDESC
"A card in a strange, spidery hand is propped against the salt.")
	(TEXT
"I have to be absent for a while. Do not wait for me. -- D.")>

<ROOM LIBRARY
      (IN ROOMS)
      (DESC "Library")
      (LDESC
"Shelves of English books climb the walls: law, history, an atlas, a
railway guide. A sofa faces the cold hearth. Someone has studied your
country the way a hunter studies a covert. The only door is east.")
      (EAST TO DINING-ROOM)
      (ACTION LIBRARY-FCN)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT ATLAS
	(IN LIBRARY)
	(SYNONYM ATLAS)
	(ADJECTIVE ENGLISH)
	(DESC "atlas of England")
	(FLAGS READBIT NDESCBIT)
	(ACTION ATLAS-FCN)>

<OBJECT BRADSHAW
	(IN LIBRARY)
	(SYNONYM GUIDE BRADSHAW)
	(ADJECTIVE RAILWAY)
	(DESC "railway guide")
	(FLAGS READBIT NDESCBIT)
	(TEXT
"Bradshaw's Guide, its timetables pencil-marked in a small, exact hand:
the trains from Galatz, from Varna, from Whitby to King's Cross. He has
learned your railways the way you never learned them yourself.")>

<OBJECT ENGLISH-BOOKS
	(IN LIBRARY)
	(SYNONYM BOOKS SHELVES VOLUMES)
	(ADJECTIVE ENGLISH)
	(DESC "English books")
	(FLAGS NDESCBIT READBIT)
	(TEXT
"History, geography, politics, law, even an Army List and a Navy List.
The pages are worn with use. \"Through them,\" he told you, \"I have come
to know your great England.\"")>

<OBJECT LIBRARY-SOFA
	(IN LIBRARY)
	(SYNONYM SOFA)
	(DESC "sofa")
	(FLAGS NDESCBIT)
	(TEXT "A deep sofa, much sat in, facing a hearth long cold.")>

<ROOM OCTAGONAL-ROOM
      (IN ROOMS)
      (DESC "Octagonal Room")
      (LDESC
"A small eight-sided chamber without a single window, lit by one lamp.
Doors face each other like patient sentries, north and south.")
      (NORTH TO DINING-ROOM)
      (SOUTH TO BEDROOM)
      (ACTION ACT1-PLAIN-FCN)
      (FLAGS RLANDBIT ONBIT)>

<ROOM BEDROOM
      (IN ROOMS)
      (DESC "Great Bedroom")
      (LDESC
"Your bedroom: a curtained bed, a fresh log fire, and a barred window on
the courtyard. It is the one room in the castle where sleep feels safe.
The only door is north.")
      (NORTH TO OCTAGONAL-ROOM)
      (ACTION BEDROOM-FCN)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<OBJECT BEDROOM-BED
	(IN BEDROOM)
	(SYNONYM BED CURTAINS)
	(ADJECTIVE CURTAINED)
	(DESC "curtained bed")
	(FLAGS NDESCBIT)
	(ACTION BEDROOM-BED-FCN)>

<OBJECT BEDROOM-WINDOW
	(IN BEDROOM)
	(SYNONYM WINDOW BARS)
	(ADJECTIVE BARRED)
	(DESC "barred window")
	(FLAGS NDESCBIT DOORBIT)
	(ACTION BEDROOM-WINDOW-FCN)>

<OBJECT TRAVELLING-BAG
	(IN BEDROOM)
	(SYNONYM BAG)
	(ADJECTIVE TRAVELLING LEATHER)
	(DESC "travelling bag")
	(FLAGS CONTBIT)
	(CAPACITY 20)
	(TEXT
"Your own good leather bag, packed in Exeter a lifetime ago.")>

<OBJECT SHAVING-GLASS
	(IN TRAVELLING-BAG)
	(SYNONYM GLASS MIRROR)
	(ADJECTIVE SHAVING LITTLE)
	(DESC "shaving glass")
	(FLAGS TAKEBIT)
	(SIZE 2)
	(ACTION SHAVING-GLASS-FCN)>

<OBJECT LETTER-PAPER
	(IN TRAVELLING-BAG)
	(SYNONYM PAPER PEN)
	(ADJECTIVE LETTER WRITING)
	(DESC "letter paper")
	(FLAGS TAKEBIT READBIT)
	(SIZE 1)
	(ACTION LETTER-PAPER-FCN)>

<OBJECT SHARD
	(SYNONYM SHARD SLIVER GLASS)
	(ADJECTIVE SILVERED BROKEN)
	(DESC "sliver of mirror")
	(FLAGS TAKEBIT)
	(SIZE 1)
	(ACTION SHARD-FCN)>

<OBJECT HAND-LAMP
	(IN BEDROOM)
	(SYNONYM LAMP LIGHT)
	(ADJECTIVE HAND OIL)
	(DESC "hand lamp")
	(FLAGS TAKEBIT LIGHTBIT ONBIT)
	(SIZE 3)
	(FDESC
"On the mantel stands a hand lamp, trimmed and burning.")
	(ACTION HAND-LAMP-FCN)>

<OBJECT WARDROBE
	(IN BEDROOM)
	(SYNONYM WARDROBE CLOTHES SUIT)
	(DESC "wardrobe")
	(FLAGS NDESCBIT)
	(ACTION WARDROBE-FCN)>

<OBJECT BOOTS
	(IN ADVENTURER)
	(SYNONYM BOOTS BOOT SHOES)
	(DESC "pair of boots")
	(FLAGS TAKEBIT WEARBIT)
	(SIZE 3)
	(ACTION BOOTS-FCN)>

<OBJECT CRUCIFIX
	(IN ADVENTURER)
	(SYNONYM CRUCIFIX CROSS ROSARY BEADS)
	(DESC "crucifix")
	(FLAGS TAKEBIT WEARBIT)
	(SIZE 1)
	(ACTION CRUCIFIX-FCN)>

<ROOM SOUTH-LANDING
      (IN ROOMS)
      (DESC "South Landing")
      (LDESC
"A tall stone-mullioned window fills this landing with sky. Below the
sill the wall drops a thousand feet, sheer as a cut, to a sea of green
treetops. The narrow stair goes down.")
      (DOWN TO UPPER-PASSAGE)
      (OUT PER LANDING-OUT)
      (ACTION SOUTH-LANDING-FCN)
      (GLOBAL STAIRS)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT LANDING-WINDOW
	(IN SOUTH-LANDING)
	(SYNONYM WINDOW SILL)
	(ADJECTIVE TALL MULLIONED STONE)
	(DESC "tall window")
	(FLAGS NDESCBIT DOORBIT)
	(ACTION LANDING-WINDOW-FCN)>

<ROOM LADIES-WING
      (IN ROOMS)
      (DESC "Ladies' Wing")
      (LDESC
"A wide chamber deep in dust, where moonlight through diamond panes falls
on a little oak table and a great couch. Ladies sat here once, singing,
while their menfolk rode to war. The heavy door is west; the window
looks out on nothing but air.")
      (WEST PER STUCK-WEST)
      (OUT PER WING-OUT)
      (ACTION LADIES-WING-FCN)
      (GLOBAL STUCK-DOOR)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT WING-WINDOW
	(IN LADIES-WING)
	(SYNONYM WINDOW PANES)
	(ADJECTIVE DIAMOND)
	(DESC "diamond-paned window")
	(FLAGS NDESCBIT DOORBIT)
	(ACTION WING-WINDOW-FCN)>

<OBJECT OAK-TABLE
	(IN LADIES-WING)
	(SYNONYM TABLE)
	(ADJECTIVE OAK LITTLE)
	(DESC "little oak table")
	(FLAGS NDESCBIT)
	(TEXT
"A little oak table where ladies wrote their letters once. In the dust
your finger could write one now, to nobody, to be read by nothing.")>

<OBJECT WING-COUCH
	(IN LADIES-WING)
	(SYNONYM COUCH)
	(ADJECTIVE GREAT)
	(DESC "great couch")
	(FLAGS NDESCBIT)
	(TEXT
"A great couch, its silk gone grey with dust. The hollow in its cushions
might be centuries of settling. It might not.")>

<OBJECT WING-DUST
	(IN LADIES-WING)
	(SYNONYM DUST FOOTPRINTS PRINTS)
	(DESC "dust")
	(FLAGS NDESCBIT)
	(TEXT
"The dust lies thick as felt, and it is not unmarked. Small bare
footprints cross it, three sets, light as birds, and none of them lead
in through the door.")>

<OBJECT BRIDES
	(SYNONYM WOMEN SISTERS BRIDES WOMAN SISTER LADIES)
	(ADJECTIVE THREE FAIR DARK YOUNG)
	(DESC "three women")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION BRIDES-FCN)>

<ROOM CASTLE-LEDGE
      (IN ROOMS)
      (DESC "Narrow Ledge")
      (NORTH PER LEDGE-NORTH)
      (SOUTH PER LEDGE-SOUTH)
      (IN PER LEDGE-IN)
      (DOWN PER LEDGE-DOWN)
      (UP "The wall above overhangs. Down is the only way the stone
offers, and it barely offers that.")
      (ACTION CASTLE-LEDGE-FCN)
      (FLAGS RLANDBIT ONBIT)>

<ROOM DRACULA-ROOM
      (IN ROOMS)
      (DESC "The Count's Room")
      (LDESC
"A bare, dusty chamber no servant tends. In one corner, dulled with
grave-dust, lies a mound of old gold, and near it a heavy door stands
ajar on a descending stair. The door to the hall is locked, and its lock
is new. The window opens on the ledge.")
      (OUT PER DRACULA-ROOM-OUT)
      (DOWN PER DRACULA-ROOM-DOWN)
      (ACTION DRACULA-ROOM-FCN)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT GOLD
	(IN DRACULA-ROOM)
	(SYNONYM GOLD COINS MONEY MOUND)
	(ADJECTIVE OLD ROMAN TURKISH BRITISH)
	(DESC "heap of old gold")
	(FLAGS NDESCBIT TRYTAKEBIT)
	(ACTION GOLD-FCN)>

<OBJECT JEWELLED-CHAINS
	(IN DRACULA-ROOM)
	(SYNONYM CHAINS JEWELS ORNAMENTS)
	(ADJECTIVE JEWELLED)
	(DESC "jewelled chains")
	(FLAGS NDESCBIT)
	(TEXT
"Chains and ornaments, some jewelled, all of them old and stained. None
of the coins, none of the gold, none of any of it is less than three
hundred years old. Whatever has been gathered here stopped needing money
a long time ago.")>

<OBJECT CORNER-DOOR
	(IN DRACULA-ROOM)
	(SYNONYM DOOR)
	(ADJECTIVE CORNER HEAVY)
	(DESC "corner door")
	(FLAGS DOORBIT NDESCBIT)
	(ACTION CORNER-DOOR-FCN)>

<OBJECT DRACULA-WINDOW
	(IN DRACULA-ROOM)
	(SYNONYM WINDOW)
	(DESC "window")
	(FLAGS NDESCBIT DOORBIT)
	(ACTION DRACULA-WINDOW-FCN)>

<ROOM CIRCULAR-STAIR
      (IN ROOMS)
      (DESC "Circular Stair")
      (LDESC
"A stone screw of a stair, lit only through loopholes, going steeply down
into an odour you know before you can name it: old earth, newly turned.")
      (UP TO DRACULA-ROOM)
      (DOWN PER CSTAIR-DOWN)
      (ACTION CIRCULAR-STAIR-FCN)
      (GLOBAL STAIRS)
      (FLAGS RLANDBIT ONBIT)>

<ROOM DARK-PASSAGE
      (IN ROOMS)
      (DESC "Dark Passage")
      (LDESC
"A tunnel of dressed stone. The deathly, sickly odour of fresh-dug earth
thickens with every step. The passage runs north and south.")
      (NORTH TO CIRCULAR-STAIR)
      (SOUTH TO RUINED-CHAPEL)
      (ACTION ACT1-PLAIN-FCN)
      (GLOBAL EARTH-G)
      (FLAGS RLANDBIT)>

<ROOM RUINED-CHAPEL
      (IN ROOMS)
      (DESC "Ruined Chapel")
      (NORTH PER CHAPEL-NORTH)
      (DOWN PER CHAPEL-DOWN)
      (OUT PER CHAPEL-OUT)
      (UP PER CHAPEL-OUT)
      (ACTION RUINED-CHAPEL-FCN)
      (GLOBAL EARTH-G)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT EARTH-G
	(IN LOCAL-GLOBALS)
	(SYNONYM EARTH MOULD SOIL)
	(ADJECTIVE FRESH DUG HOLY)
	(DESC "fresh-dug earth")
	(FLAGS NDESCBIT)
	(ACTION EARTH-G-FCN)>

<OBJECT CASTLE-BOXES
	(IN RUINED-CHAPEL)
	(SYNONYM BOXES CASES)
	(ADJECTIVE GREAT WOODEN SQUARE)
	(DESC "great wooden boxes")
	(FLAGS NDESCBIT)
	(ACTION CASTLE-BOXES-FCN)>

<OBJECT SHOVEL
	(IN RUINED-CHAPEL)
	(SYNONYM SHOVEL SPADE)
	(ADJECTIVE WORKMANS)
	(DESC "workman's shovel")
	(FLAGS TAKEBIT TOOLBIT WEAPONBIT)
	(SIZE 6)
	(FDESC
"A workman's shovel leans against a heap of turned earth.")
	(TEXT
"Wood-hafted, iron-bladed, left by whoever has been digging here. It is
not much of a weapon. It is, however, the only one in the castle.")>

<OBJECT CHAPEL-DOOR
	(IN RUINED-CHAPEL)
	(SYNONYM DOOR DOORWAY ENTRANCE ENTRANCES)
	(ADJECTIVE CHAPEL LOW)
	(DESC "chapel door")
	(FLAGS NDESCBIT DOORBIT)
	(ACTION CHAPEL-DOOR-FCN)>

<ROOM VAULT
      (IN ROOMS)
      (DESC "Old Vault")
      (UP PER VAULT-UP)
      (ACTION VAULT-FCN)
      (GLOBAL EARTH-G)
      (FLAGS RLANDBIT)>

<OBJECT GREAT-BOX
	(IN VAULT)
	(SYNONYM BOX CHEST LID)
	(ADJECTIVE GREAT SQUARE PIERCED)
	(DESC "great box")
	(FLAGS NDESCBIT CONTBIT)
	(CAPACITY 90)
	(ACTION GREAT-BOX-FCN)>

<OBJECT COFFIN-FRAGMENTS
	(IN VAULT)
	(SYNONYM FRAGMENTS COFFINS PILES)
	(ADJECTIVE ANCIENT BROKEN)
	(DESC "coffin fragments")
	(FLAGS NDESCBIT)
	(TEXT
"Fragments of ancient coffins and piles of dust: the honest dead, long
quiet. Only the third recess holds anything new.")>

<OBJECT GREAT-TOMB
	(IN VAULT)
	(SYNONYM TOMB)
	(ADJECTIVE GREAT LORDLY)
	(DESC "great tomb")
	(FLAGS NDESCBIT INVISIBLE CONTBIT OPENBIT)
	(CAPACITY 90)
	(ACTION GREAT-TOMB-FCN)>

<OBJECT SISTER-TOMBS
	(IN VAULT)
	(SYNONYM TOMBS)
	(ADJECTIVE THREE)
	(DESC "three tombs")
	(FLAGS NDESCBIT INVISIBLE)
	(ACTION SISTER-TOMBS-FCN)>

"NPCs and floating objects of Act I."

<OBJECT DRACULA
	(SYNONYM DRACULA COUNT HIMSELF NOBLEMAN MASTER)
	(ADJECTIVE TALL OLD)
	(DESC "Count Dracula")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION DRACULA-FCN)>

<OBJECT SZGANY
	(SYNONYM SZGANY GYPSIES GYPSY)
	(DESC "Szgany")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION SZGANY-FCN)>

<OBJECT LETTER
	(SYNONYM LETTER LETTERS)
	(ADJECTIVE SHORTHAND SECRET)
	(DESC "shorthand letter")
	(FLAGS TAKEBIT READBIT)
	(SIZE 1)
	(ACTION LETTER-FCN)>

<OBJECT WOLVES-G
	(IN GLOBAL-OBJECTS)
	(SYNONYM WOLVES HOWLING)
	(DESC "wolves")
	(FLAGS NDESCBIT)
	(ACTION WOLVES-G-FCN)>

<OBJECT WOLF
	(SYNONYM WOLF HEAD)
	(ADJECTIVE GREY GAUNT GREAT)
	(DESC "great grey wolf")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION WOLF-FCN)>

"Global atmosphere."

<OBJECT SUN-G
	(IN GLOBAL-OBJECTS)
	(SYNONYM SUN SUNSET SUNRISE)
	(DESC "sun")
	(FLAGS NDESCBIT)
	(ACTION SUN-G-FCN)>

<OBJECT MOON-G
	(IN GLOBAL-OBJECTS)
	(SYNONYM MOON MOONLIGHT)
	(DESC "moon")
	(FLAGS NDESCBIT)
	(TEXT
"The moon rides the clouds like a ship in weather, and the light it
spills is nobody's friend.")>

<OBJECT SKY-G
	(IN GLOBAL-OBJECTS)
	(SYNONYM SKY CLOUDS)
	(DESC "sky")
	(FLAGS NDESCBIT)
	(TEXT "The sky goes about its old business, taking no sides.")>

<OBJECT WIND-G
	(IN GLOBAL-OBJECTS)
	(SYNONYM WIND DRAUGHT AIR)
	(DESC "wind")
	(FLAGS NDESCBIT)
	(TEXT
"The wind is the one voice here that owes nothing to anybody.")>

<OBJECT SNOW-G
	(IN GLOBAL-OBJECTS)
	(SYNONYM SNOW FLURRIES)
	(DESC "snow")
	(FLAGS NDESCBIT)
	(TEXT
"Snow, fine and dry, walking the air in slow companies. In this country
you have learned to watch what walks in it.")>

"Conversation topic objects (always in scope)."

<OBJECT GT-ENGLAND
	(IN GLOBAL-OBJECTS)
	(SYNONYM ENGLAND LONDON EXETER)
	(DESC "England")
	(FLAGS NDESCBIT)>

<OBJECT GT-HISTORY
	(IN GLOBAL-OBJECTS)
	(SYNONYM HISTORY SZEKELYS RACE WAR)
	(DESC "history")
	(FLAGS NDESCBIT)>

<OBJECT GT-RIVER
	(IN GLOBAL-OBJECTS)
	(SYNONYM RIVER SERETH BISTRITZA FUNDU RIVERS)
	(DESC "river country")
	(FLAGS NDESCBIT)>

"====================================================================
ACT II SCENE 1 - WHITBY"

<ROOM CRESCENT-BEDROOM
      (IN ROOMS)
      (DESC "Bedroom at the Crescent")
      (LDESC
"The room you share with Lucy at the Crescent. The window looks over the
harbour to the East Cliff, where the abbey stands against the sky like a
memory. The stairs lead down to the door.")
      (DOWN TO WEST-CLIFF)
      (OUT TO WEST-CLIFF)
      (ACTION CRESCENT-BEDROOM-FCN)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<OBJECT LUCY-BED-W
	(IN CRESCENT-BEDROOM)
	(SYNONYM BED BEDS)
	(DESC "Lucy's bed")
	(FLAGS NDESCBIT)
	(ACTION LUCY-BED-W-FCN)>

<OBJECT CRESCENT-WINDOW
	(IN CRESCENT-BEDROOM)
	(SYNONYM WINDOW)
	(DESC "window")
	(FLAGS NDESCBIT DOORBIT)
	(ACTION CRESCENT-WINDOW-FCN)>

<OBJECT SHAWL
	(IN CRESCENT-BEDROOM)
	(SYNONYM SHAWL WRAP)
	(ADJECTIVE BIG HEAVY)
	(DESC "big heavy shawl")
	(FLAGS TAKEBIT NDESCBIT)
	(SIZE 2)
	(ACTION SHAWL-FCN)>

<OBJECT WORKBASKET
	(IN CRESCENT-BEDROOM)
	(SYNONYM WORKBASKET BASKET)
	(DESC "workbasket")
	(FLAGS NDESCBIT CONTBIT OPENBIT SEARCHBIT)
	(CAPACITY 10)>

<OBJECT SAFETY-PIN
	(IN WORKBASKET)
	(SYNONYM PIN)
	(ADJECTIVE SAFETY BIG)
	(DESC "big safety pin")
	(FLAGS TAKEBIT)
	(SIZE 1)
	(TEXT
"A big safety pin from the workbasket: the humblest weapon anyone ever
carried against the dark.")>

<OBJECT MINA-JOURNAL
	(IN CRESCENT-BEDROOM)
	(SYNONYM JOURNAL DIARY)
	(DESC "journal")
	(FLAGS NDESCBIT READBIT)
	(TEXT
"Your journal, kept in shorthand, as practice for helping Jonathan when
you are married. If you are married. The letter from Buda-Pesth says he
is ill, and coming home to you slowly.")>

<ROOM WEST-CLIFF
      (IN ROOMS)
      (DESC "West Cliff")
      (LDESC
"The paved walk above the harbour. Below, red roofs piled anyhow like a
picture of Nuremberg, and one long granite pier curving into the sea
with a lighthouse at its elbow. The Crescent door is behind you; the way
down to the drawbridge is east.")
      (UP TO CRESCENT-BEDROOM)
      (IN TO CRESCENT-BEDROOM)
      (EAST TO DRAWBRIDGE)
      (DOWN TO DRAWBRIDGE)
      (ACTION WEST-CLIFF-FCN)
      (GLOBAL HARBOUR-G ABBEY-G)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT HARBOUR-G
	(IN LOCAL-GLOBALS)
	(SYNONYM HARBOUR SEA PIER LIGHTHOUSE ROOFS)
	(ADJECTIVE GRANITE)
	(DESC "harbour")
	(FLAGS NDESCBIT)
	(ACTION HARBOUR-G-FCN)>

<OBJECT ABBEY-G
	(IN LOCAL-GLOBALS)
	(SYNONYM ABBEY)
	(ADJECTIVE NOBLE RUINED)
	(DESC "abbey")
	(FLAGS NDESCBIT)
	(TEXT
"The ruin of Whitby Abbey stands over the East Cliff, all empty windows
and broken arches. They say a white lady shows herself in one of the
windows. Today every window is only sky.")>

<ROOM DRAWBRIDGE
      (IN ROOMS)
      (DESC "The Drawbridge")
      (LDESC
"The one bridge over the Esk, and the only way between the cliffs.
Fishermen's houses crowd the far bank, and the church steps rise beyond
to the east.")
      (WEST TO WEST-CLIFF)
      (EAST TO CHURCH-STEPS)
      (ACTION ACT2-PLAIN-FCN)
      (GLOBAL HARBOUR-G)
      (FLAGS RLANDBIT ONBIT)>

<ROOM CHURCH-STEPS
      (IN ROOMS)
      (DESC "The 199 Steps")
      (LDESC
"The famous stairs wind up the East Cliff in a long, gentle curve, a
hundred and ninety-nine of them, and every one an eternity when you are
running. The churchyard is up; the drawbridge is down; a path runs north
along the shore to Tate Hill Pier.")
      (DOWN TO DRAWBRIDGE)
      (UP TO CHURCHYARD)
      (NORTH TO TATE-HILL-PIER)
      (ACTION ACT2-PLAIN-FCN)
      (GLOBAL STAIRS ABBEY-G)
      (FLAGS RLANDBIT ONBIT)>

<ROOM CHURCHYARD
      (IN ROOMS)
      (DESC "St. Mary's Churchyard")
      (LDESC
"Tombstones lean over the town where the cliff has fallen away. Walks
and seats thread the graves, and the harbour glitters far below. Lucy's
favourite seat rests on the slab of a suicide's grave. The steps lead
down; the abbey ruin is south.")
      (DOWN TO CHURCH-STEPS)
      (SOUTH TO ABBEY-RUIN)
      (ACTION CHURCHYARD-FCN)
      (GLOBAL HARBOUR-G ABBEY-G)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT SUICIDE-SEAT
	(IN CHURCHYARD)
	(SYNONYM SEAT TOMBSTONE SLAB EPITAPH)
	(ADJECTIVE FAVOURITE FLAT)
	(DESC "seat on the tombstone")
	(FLAGS NDESCBIT READBIT)
	(ACTION SUICIDE-SEAT-FCN)>

<OBJECT TOMBSTONES
	(IN CHURCHYARD)
	(SYNONYM TOMBSTONES GRAVES STONES)
	(ADJECTIVE LEANING)
	(DESC "tombstones")
	(FLAGS NDESCBIT READBIT)
	(TEXT
"Edward Spencelagh, master mariner, murdered by pirates off the coast of
Andres, April, 1854. Braithwaite Lowrey, lost aboard the Lively. John
Paxton, drowned in the Gulf of Finland. Half the stones, Mr. Swales
says, stand over no man at all: the sea kept them.")>

<OBJECT SWALES
	(IN CHURCHYARD)
	(SYNONYM SWALES MAN SAILOR)
	(ADJECTIVE OLD)
	(DESC "Mr. Swales")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION SWALES-FCN)>

<ROOM ABBEY-RUIN
      (IN ROOMS)
      (DESC "Whitby Abbey")
      (LDESC
"A noble ruin of immense size, all empty windows and broken arches. They
say a white lady shows herself in one of the windows. The wind talks
here. The churchyard lies north.")
      (NORTH TO CHURCHYARD)
      (ACTION ABBEY-RUIN-FCN)
      (GLOBAL ABBEY-G)
      (FLAGS RLANDBIT ONBIT)>

<ROOM TATE-HILL-PIER
      (IN ROOMS)
      (DESC "Tate Hill Pier")
      (SOUTH TO CHURCH-STEPS)
      (ACTION TATE-HILL-PIER-FCN)
      (GLOBAL HARBOUR-G)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT SCHOONER
	(IN TATE-HILL-PIER)
	(SYNONYM SCHOONER SHIP DEMETER VESSEL)
	(ADJECTIVE RUSSIAN GROUNDED)
	(DESC "schooner")
	(FLAGS NDESCBIT INVISIBLE)
	(ACTION SCHOONER-FCN)>

<OBJECT DEAD-CAPTAIN
	(IN TATE-HILL-PIER)
	(SYNONYM CAPTAIN CORPSE MAN)
	(ADJECTIVE DEAD LASHED)
	(DESC "dead captain")
	(FLAGS NDESCBIT INVISIBLE)
	(ACTION DEAD-CAPTAIN-FCN)>

<OBJECT CAPTAINS-LOG
	(IN TATE-HILL-PIER)
	(SYNONYM LOG BOOK)
	(ADJECTIVE CAPTAINS SHIPS)
	(DESC "captain's log")
	(FLAGS NDESCBIT INVISIBLE READBIT)
	(ACTION CAPTAINS-LOG-FCN)>

<OBJECT CART-TRACKS
	(IN TATE-HILL-PIER)
	(SYNONYM TRACKS RUTS CART)
	(ADJECTIVE WHEEL)
	(DESC "cart tracks")
	(FLAGS NDESCBIT INVISIBLE)
	(TEXT
"Deep fresh wheel-ruts climb from the pier toward the road south, cut by
something heavily laden. Fifty boxes of earth went ashore as lawful
cargo, signed for, carted, and gone.")>

<OBJECT LUCY
	(SYNONYM LUCY FIGURE GIRL)
	(ADJECTIVE WHITE SNOWY)
	(DESC "Lucy")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION LUCY-FCN)>

"====================================================================
ACT II SCENE 2 - LONDON / PURFLEET"

<ROOM STUDY
      (IN ROOMS)
      (DESC "Dr. Seward's Study")
      (LDESC
"Your study at the asylum: the phonograph with its wax cylinders, a
locked safe, a case-bottle of brandy, and a window giving on the
grounds. The corridor is east.")
      (EAST TO CORRIDOR)
      (ACTION STUDY-FCN)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<OBJECT PHONOGRAPH
	(IN STUDY)
	(SYNONYM PHONOGRAPH CYLINDER CYLINDERS)
	(ADJECTIVE WAX)
	(DESC "phonograph")
	(FLAGS NDESCBIT READBIT)
	(ACTION PHONOGRAPH-FCN)>

<OBJECT STUDY-SAFE
	(IN STUDY)
	(SYNONYM SAFE MANUSCRIPT COPY)
	(ADJECTIVE LOCKED)
	(DESC "locked safe")
	(FLAGS NDESCBIT)
	(ACTION STUDY-SAFE-FCN)>

<OBJECT BRANDY
	(IN STUDY)
	(SYNONYM BRANDY CASE-BOTTLE)
	(DESC "case-bottle of brandy")
	(FLAGS TAKEBIT NDESCBIT DRINKBIT)
	(SIZE 2)
	(ACTION BRANDY-FCN)>

<OBJECT STUDY-DRAWER
	(IN STUDY)
	(SYNONYM DRAWER DESK)
	(DESC "desk drawer")
	(FLAGS NDESCBIT CONTBIT)
	(CAPACITY 10)>

<OBJECT NOTEBOOK
	(IN STUDY-DRAWER)
	(SYNONYM NOTEBOOK SUMS FIGURES)
	(ADJECTIVE LITTLE CONFISCATED)
	(DESC "little notebook")
	(FLAGS TAKEBIT READBIT)
	(SIZE 1)
	(TEXT
"Renfield's confiscated notebook: whole pages of little numbers, single
figures added up in batches, and the totals added in batches again, the
bookkeeping of a man banking lives. He asks after it daily.")>

<ROOM CORRIDOR
      (IN ROOMS)
      (DESC "Asylum Corridor")
      (LDESC
"Whitewashed and echoing. Somewhere down the ward a patient laughs, and
stops. Your study is west, Renfield's room north, the guest room east,
and the door to the grounds south.")
      (WEST TO STUDY)
      (NORTH TO RENFIELD-CELL)
      (EAST TO GUEST-ROOM)
      (SOUTH TO ASYLUM-GROUNDS)
      (OUT TO ASYLUM-GROUNDS)
      (ACTION ACT3-PLAIN-FCN)
      (FLAGS RLANDBIT ONBIT)>

<ROOM RENFIELD-CELL
      (IN ROOMS)
      (DESC "Renfield's Room")
      (LDESC
"A bare room smelling of sugar and something older. Flies stitch the
sunbeam, and the window, screwed shut, looks toward the trees of the
neighbouring park. The corridor is south.")
      (SOUTH TO CORRIDOR)
      (ACTION RENFIELD-CELL-FCN)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT RENFIELD
	(IN RENFIELD-CELL)
	(SYNONYM RENFIELD PATIENT)
	(DESC "Renfield")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION RENFIELD-FCN)>

<OBJECT FLY
	(IN RENFIELD-CELL)
	(SYNONYM FLY FLIES)
	(ADJECTIVE FAT)
	(DESC "fat fly")
	(FLAGS TAKEBIT NDESCBIT)
	(SIZE 1)
	(ACTION FLY-FCN)>

<OBJECT CELL-WINDOW
	(IN RENFIELD-CELL)
	(SYNONYM WINDOW SASH)
	(ADJECTIVE SCREWED)
	(DESC "screwed window")
	(FLAGS NDESCBIT DOORBIT)
	(TEXT
"Screwed shut, and the screws painted over. It looks toward the heavier
trees of the park next door: Carfax. Renfield stands at it for hours,
like a dog at a larder door.")>

<ROOM GUEST-ROOM
      (IN ROOMS)
      (DESC "The Harkers' Room")
      (LDESC
"The room given to Jonathan and Mina: a bed by the window, her typewriter
on the table, his kukri knife on the mantel. A married couple's tidy
courage. The corridor is west.")
      (WEST TO CORRIDOR)
      (ACTION GUEST-ROOM-FCN)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT TYPEWRITER
	(IN GUEST-ROOM)
	(SYNONYM TYPEWRITER)
	(DESC "typewriter")
	(FLAGS NDESCBIT)
	(TEXT
"Mina's typewriter, ribbon fresh, a stack of manifold paper squared
beside it. She has copied every diary and letter of this business in
triplicate. \"We want no proofs,\" the professor says, but she makes
them anyway. Somebody in this house is methodical about hope.")>

<OBJECT KUKRI
	(IN GUEST-ROOM)
	(SYNONYM KUKRI KNIFE)
	(ADJECTIVE GREAT GURKHA)
	(DESC "kukri knife")
	(FLAGS TAKEBIT WEAPONBIT NDESCBIT)
	(SIZE 3)
	(ACTION KUKRI-FCN)>

<OBJECT MINA
	(SYNONYM MINA MADAM WIFE)
	(ADJECTIVE YOUNG)
	(DESC "Mina")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION MINA-FCN)>

<ROOM ASYLUM-GROUNDS
      (IN ROOMS)
      (DESC "Asylum Grounds")
      (LDESC
"Lawn and old trees inside a high wall. Beyond the wall eastward rise the
heavier trees of Carfax, and its ruined roofs. The asylum door is north;
the London road runs south.")
      (IN TO CORRIDOR)
      (NORTH TO CORRIDOR)
      (EAST PER GROUNDS-EAST)
      (SOUTH TO LONDON-ROAD)
      (ACTION ASYLUM-GROUNDS-FCN)
      (GLOBAL ASYLUM-WALL)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT ASYLUM-WALL
	(IN LOCAL-GLOBALS)
	(SYNONYM WALL)
	(ADJECTIVE HIGH)
	(DESC "high wall")
	(FLAGS NDESCBIT)
	(TEXT
"The wall between the asylum grounds and Carfax is twelve feet if it is
an inch, old brick under older ivy.")>

<OBJECT LADDER
	(IN ASYLUM-GROUNDS)
	(SYNONYM LADDER SHED)
	(ADJECTIVE GARDEN POTTING)
	(DESC "garden ladder")
	(FLAGS NDESCBIT TRYTAKEBIT)
	(ACTION LADDER-FCN)>

<OBJECT KENNELS
	(IN ASYLUM-GROUNDS)
	(SYNONYM KENNELS TERRIERS DOGS)
	(DESC "kennels")
	(FLAGS NDESCBIT)
	(TEXT
"Three rough-coated terriers, professional ratters, watch you through the
kennel wire with bright commercial interest.")>

<ROOM CARFAX-LAWN
      (IN ROOMS)
      (DESC "Carfax")
      (LDESC
"Twenty acres of black pond and older trees around a house of all
periods, part of it a keep with barred windows high up. Against it leans
a chapel of old times. The place holds its breath. The asylum wall is
west; the front door is north.")
      (WEST PER GROUNDS-EAST)
      (NORTH PER CARFAX-IN)
      (IN PER CARFAX-IN)
      (ACTION CARFAX-LAWN-FCN)
      (GLOBAL ASYLUM-WALL)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT CARFAX-DOOR
	(IN CARFAX-LAWN)
	(SYNONYM DOOR)
	(ADJECTIVE FRONT OAK IRON-BOUND)
	(DESC "front door")
	(FLAGS NDESCBIT DOORBIT)
	(ACTION CARFAX-DOOR-FCN)>

<OBJECT CARFAX-LOCK
	(IN CARFAX-LAWN)
	(SYNONYM LOCK)
	(ADJECTIVE OLD RUSTY)
	(DESC "old lock")
	(FLAGS NDESCBIT)
	(ACTION CARFAX-DOOR-FCN)>

<OBJECT DARK-POND
	(IN CARFAX-LAWN)
	(SYNONYM POND)
	(ADJECTIVE BLACK DARK)
	(DESC "dark pond")
	(FLAGS NDESCBIT)
	(TEXT
"Black water under black trees. It does not reflect the house. You find
you are glad of that, and then you wonder why.")>

<ROOM CARFAX-HALL
      (IN ROOMS)
      (DESC "Carfax Hall")
      (LDESC
"Dust lies inches deep, torn by hobnailed footprints; cobwebs hang like
old rags. A low, arched, iron-ribbed door stands east. The way out is
south.")
      (OUT TO CARFAX-LAWN)
      (SOUTH TO CARFAX-LAWN)
      (EAST TO CARFAX-CHAPEL)
      (ACTION CARFAX-HALL-FCN)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT KEY-BUNCH
	(IN CARFAX-HALL)
	(SYNONYM BUNCH LABELS LABEL)
	(ADJECTIVE LABELLED YELLOWED)
	(DESC "labelled bunch of keys")
	(FLAGS TAKEBIT READBIT)
	(SIZE 2)
	(FDESC
"On a table lies a great bunch of keys, every one with a time-yellowed
label.")
	(ACTION KEY-BUNCH-FCN)>

<OBJECT HALL-DUST
	(IN CARFAX-HALL)
	(SYNONYM DUST FOOTPRINTS COBWEBS)
	(ADJECTIVE HOBNAILED)
	(DESC "dust")
	(FLAGS NDESCBIT)
	(TEXT
"The dust is torn by hobnailed boots: the carriers who brought the boxes
in. Under those, older marks. Someone has paced this hall barefoot, many
nights, alone.")>

<ROOM CARFAX-CHAPEL
      (IN ROOMS)
      (DESC "Carfax Chapel")
      (LDESC
"The smell arrives before the sight of it: earth, blood, and something
worse, as though corruption had become itself corrupt. Great wooden
boxes stand ranked in the gloom. The iron-ribbed door back to the hall
is west; the outer door south is bolted on the inside.")
      (WEST TO CARFAX-HALL)
      (SOUTH "The outer door is bolted fast, and tonight you are glad
of every bolt in England.")
      (ACTION CARFAX-CHAPEL-FCN)
      (GLOBAL EARTH-G)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT CARFAX-BOXES
	(IN CARFAX-CHAPEL)
	(SYNONYM BOXES CASES)
	(ADJECTIVE GREAT WOODEN EARTH)
	(DESC "great boxes")
	(FLAGS NDESCBIT)
	(ACTION CARFAX-BOXES-FCN)>

<OBJECT RATS
	(IN CARFAX-CHAPEL)
	(SYNONYM RATS MASS EYES)
	(ADJECTIVE PHOSPHORESCENT)
	(DESC "rats")
	(FLAGS NDESCBIT INVISIBLE ACTORBIT)
	(ACTION RATS-FCN)>

<ROOM LONDON-ROAD
      (IN ROOMS)
      (DESC "The London Road")
      (LDESC
"From here the day's errands run: north to the asylum, west to
Hillingham, south to the churchyard at Kingstead, east to Piccadilly,
and the mean streets of Walworth southeast between.")
      (NORTH TO ASYLUM-GROUNDS)
      (WEST TO HILLINGHAM)
      (SOUTH TO KINGSTEAD)
      (EAST TO PICCADILLY-STEPS)
      (SE TO WALWORTH)
      (ACTION LONDON-ROAD-FCN)
      (FLAGS RLANDBIT ONBIT)>

<ROOM HILLINGHAM
      (IN ROOMS)
      (DESC "Hillingham")
      (LDESC
"The Westenra hall: flowers, good furniture, and a stillness that has
learned to listen for a sickroom bell. Lucy's room is up the stair; the
road is east.")
      (EAST TO LONDON-ROAD)
      (UP TO LUCYS-ROOM)
      (ACTION HILLINGHAM-FCN)
      (GLOBAL STAIRS)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT MRS-WESTENRA
	(IN HILLINGHAM)
	(SYNONYM WESTENRA MOTHER LADY)
	(ADJECTIVE MRS POOR)
	(DESC "Mrs. Westenra")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION MRS-WESTENRA-FCN)>

<OBJECT MAIDS
	(IN HILLINGHAM)
	(SYNONYM MAIDS MAID SERVANTS)
	(ADJECTIVE FOUR)
	(DESC "maids")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION MAIDS-FCN)>

<OBJECT SHERRY
	(IN HILLINGHAM)
	(SYNONYM SHERRY DECANTER)
	(DESC "sherry decanter")
	(FLAGS NDESCBIT)
	(ACTION SHERRY-FCN)>

<ROOM LUCYS-ROOM
      (IN ROOMS)
      (DESC "Lucy's Room")
      (LDESC
"A pretty bedroom trying to stay one: the bed, the fireplace, and the
window on the shrubbery, its latch bright with use. On the air,
sometimes, a beating of wings. The stair goes down.")
      (DOWN TO HILLINGHAM)
      (ACTION LUCYS-ROOM-FCN)
      (GLOBAL STAIRS)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT LUCY-WINDOW
	(IN LUCYS-ROOM)
	(SYNONYM WINDOW SASH SASHES LATCH)
	(DESC "window")
	(FLAGS NDESCBIT DOORBIT OPENBIT)
	(ACTION LUCY-WINDOW-FCN)>

<OBJECT LUCY-DOOR
	(IN LUCYS-ROOM)
	(SYNONYM DOOR JAMB)
	(DESC "door")
	(FLAGS NDESCBIT DOORBIT OPENBIT)
	(ACTION LUCY-DOOR-FCN)>

<OBJECT FIREPLACE
	(IN LUCYS-ROOM)
	(SYNONYM FIREPLACE GRATE HEARTH CHIMNEY)
	(DESC "fireplace")
	(FLAGS NDESCBIT)
	(ACTION FIREPLACE-FCN)>

<OBJECT LUCY-BED
	(IN LUCYS-ROOM)
	(SYNONYM BED)
	(DESC "bed")
	(FLAGS NDESCBIT)
	(TEXT
"A pretty bed trying hard to be only a bed, and not a battlefield.")>

<OBJECT VELVET-BAND
	(IN LUCYS-ROOM)
	(SYNONYM BAND THROAT NECK)
	(ADJECTIVE BLACK VELVET)
	(DESC "black velvet band")
	(FLAGS NDESCBIT)
	(ACTION VELVET-BAND-FCN)>

<OBJECT GARLIC
	(SYNONYM GARLIC FLOWERS BLOSSOMS HANDFUL)
	(ADJECTIVE WHITE WITHERED)
	(DESC "garlic flowers")
	(FLAGS TAKEBIT)
	(SIZE 2)
	(ACTION GARLIC-FCN)>

<OBJECT WREATH
	(SYNONYM WREATH)
	(ADJECTIVE GARLIC)
	(DESC "garlic wreath")
	(FLAGS TAKEBIT)
	(SIZE 2)
	(ACTION WREATH-FCN)>

<OBJECT WAFER
	(SYNONYM WAFER HOST ENVELOPE)
	(ADJECTIVE SACRED)
	(DESC "envelope of the Sacred Wafer")
	(FLAGS TAKEBIT)
	(SIZE 1)
	(ACTION WAFER-FCN)>

<OBJECT STAKE
	(SYNONYM STAKE)
	(ADJECTIVE WOODEN CHARRED ROUND)
	(DESC "wooden stake")
	(FLAGS TAKEBIT WEAPONBIT)
	(SIZE 4)
	(TEXT
"A round wooden stake, some three feet long, hardened by charring in the
fire and sharpened to a fine point. It means exactly what it looks like
it means.")>

<OBJECT HAMMER
	(SYNONYM HAMMER)
	(ADJECTIVE HEAVY COAL-CELLAR)
	(DESC "heavy hammer")
	(FLAGS TAKEBIT TOOLBIT)
	(SIZE 4)
	(TEXT
"A heavy hammer, such as in households is used in the coal-cellar. In
Roumania they would call it the Veresti hammer, and cross themselves.")>

<OBJECT TURNSCREW
	(SYNONYM TURNSCREW SCREWDRIVER FRET-SAW TOOLS SAW)
	(DESC "turnscrew and fret-saw")
	(FLAGS TAKEBIT TOOLBIT)
	(SIZE 2)
	(TEXT
"A turnscrew for coffin screws and a fret-saw for lead: the professor's
terrible honest luggage.")>

<OBJECT SKELETON-KEYS
	(SYNONYM KEYS)
	(ADJECTIVE SKELETON)
	(DESC "skeleton keys")
	(FLAGS TAKEBIT TOOLBIT)
	(SIZE 1)
	(TEXT
"A surgeon's fingers and a burglar's tools: between them, few locks in
England would care to argue.")>

<OBJECT WHISTLE
	(SYNONYM WHISTLE)
	(ADJECTIVE SILVER LITTLE)
	(DESC "silver whistle")
	(FLAGS TAKEBIT)
	(SIZE 1)
	(ACTION WHISTLE-FCN)>

<OBJECT ELECTRIC-LAMP
	(SYNONYM LAMP LAMPS)
	(ADJECTIVE ELECTRIC BREAST)
	(DESC "electric lamp")
	(FLAGS TAKEBIT LIGHTBIT ONBIT)
	(SIZE 2)
	(TEXT
"A small electric lamp that clips to the breast, leaving both hands
free. The professor thinks of everything, which is another way of
saying he has done this before.")>

<OBJECT BEER
	(SYNONYM BEER BOTTLE)
	(DESC "bottle of beer")
	(FLAGS TAKEBIT DRINKBIT)
	(SIZE 2)
	(TEXT
"A quart of honest beer. Quincey calls it interviewing fluid.")>

<OBJECT SHILLINGS
	(SYNONYM SHILLINGS SHILLING)
	(ADJECTIVE HALF-SOVEREIGN)
	(DESC "handful of shillings")
	(FLAGS TAKEBIT)
	(SIZE 1)
	(TEXT "Silver enough to loosen most tongues in Walworth.")>

<ROOM KINGSTEAD
      (IN ROOMS)
      (DESC "Kingstead Churchyard")
      (LDESC
"Yews and junipers black against the sky, headstones adrift in the
grass, and among them a lordly death-house of marble: the Westenra tomb.
The road is north.")
      (NORTH TO LONDON-ROAD)
      (IN PER TOMB-IN)
      (ACTION KINGSTEAD-FCN)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT TOMB-DOOR
	(IN KINGSTEAD)
	(SYNONYM DOOR TOMB)
	(ADJECTIVE MARBLE IRON WESTENRA)
	(DESC "tomb door")
	(FLAGS NDESCBIT DOORBIT)
	(ACTION TOMB-DOOR-FCN)>

<OBJECT YEWS
	(IN KINGSTEAD)
	(SYNONYM YEWS JUNIPERS TREES)
	(ADJECTIVE BLACK)
	(DESC "yew trees")
	(FLAGS NDESCBIT)
	(TEXT
"Trees that made their peace with graveyards centuries ago. They keep
what they see to themselves.")>

<ROOM WESTENRA-TOMB
      (IN ROOMS)
      (DESC "The Westenra Tomb")
      (LDESC
"Candlelight makes it worse: time-discoloured stone, rusted iron,
clouded silver-plate, and the coffin on its stone shelf. The way out is
the iron door.")
      (OUT TO KINGSTEAD)
      (ACTION WESTENRA-TOMB-FCN)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT LUCY-COFFIN
	(IN WESTENRA-TOMB)
	(SYNONYM COFFIN LID FLANGE)
	(ADJECTIVE LEAD WOODEN)
	(DESC "coffin")
	(FLAGS NDESCBIT CONTBIT)
	(CAPACITY 90)
	(ACTION LUCY-COFFIN-FCN)>

<OBJECT OTHER-COFFINS
	(IN WESTENRA-TOMB)
	(SYNONYM COFFINS SHELVES)
	(ADJECTIVE OTHER)
	(DESC "other coffins")
	(FLAGS NDESCBIT)
	(TEXT
"The Westenra dead, decently shelved, decently quiet. Lately quiet has
stopped being something you take for granted.")>

<OBJECT MISSAL
	(SYNONYM MISSAL PRAYER BOOK)
	(ADJECTIVE LITTLE)
	(DESC "missal")
	(FLAGS TAKEBIT READBIT)
	(SIZE 1)
	(ACTION MISSAL-FCN)>

<ROOM PICCADILLY-STEPS
      (IN ROOMS)
      (DESC "No. 347, Piccadilly")
      (LDESC
"A high house with a stone bow front and steps up to the door. Dust
crusts the windows, and behind the area railings hangs the white scar of
a torn-down For Sale board. London flows past without looking. The road
home is west.")
      (WEST TO LONDON-ROAD)
      (IN PER PICC-IN)
      (UP PER PICC-IN)
      (ACTION PICC-STEPS-FCN)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT PICC-DOOR
	(IN PICCADILLY-STEPS)
	(SYNONYM DOOR HOUSE)
	(ADJECTIVE FRONT HIGH)
	(DESC "front door")
	(FLAGS NDESCBIT DOORBIT)
	(ACTION PICC-DOOR-FCN)>

<OBJECT GREEN-BENCH
	(IN PICCADILLY-STEPS)
	(SYNONYM BENCH PARK)
	(ADJECTIVE GREEN)
	(DESC "bench in Green Park")
	(FLAGS NDESCBIT)
	(TEXT
"A bench across the way in Green Park, well placed for watching a house
without appearing to watch anything at all.")>

<ROOM PICCADILLY-HOUSE
      (IN ROOMS)
      (DESC "The House in Piccadilly")
      (LDESC
"The dining-room of an empty mansion, smelling like the chapel at
Carfax. Eight great boxes stand against the wall. On the table lie deeds
in a bundle, a clothes brush, a jug and basin, and a little heap of keys
of all sorts and sizes. The door is out and down the steps.")
      (OUT TO PICCADILLY-STEPS)
      (DOWN TO PICCADILLY-STEPS)
      (ACTION PICC-HOUSE-FCN)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT PICC-BOXES
	(IN PICCADILLY-HOUSE)
	(SYNONYM BOXES CASES)
	(ADJECTIVE GREAT WOODEN EIGHT)
	(DESC "eight great boxes")
	(FLAGS NDESCBIT)
	(ACTION PICC-BOXES-FCN)>

<OBJECT DEEDS
	(IN PICCADILLY-HOUSE)
	(SYNONYM DEEDS PAPERS BUNDLE TITLE)
	(ADJECTIVE TITLE)
	(DESC "bundle of title deeds")
	(FLAGS NDESCBIT READBIT)
	(ACTION DEEDS-FCN)>

<OBJECT KEY-HEAP
	(IN PICCADILLY-HOUSE)
	(SYNONYM HEAP)
	(ADJECTIVE LITTLE)
	(DESC "heap of keys")
	(FLAGS TAKEBIT NDESCBIT)
	(SIZE 2)
	(TEXT
"Keys of all sorts and sizes, the keys of every house he bought. They
open nothing you now need opened; he had duplicates cut, of course. You
pocket the proof and leave the convenience.")>

<OBJECT JUG-BASIN
	(IN PICCADILLY-HOUSE)
	(SYNONYM JUG BASIN BRUSH)
	(ADJECTIVE CLOTHES)
	(DESC "jug and basin")
	(FLAGS NDESCBIT)
	(TEXT
"A clothes brush, a comb, a jug and basin. The water in the basin is
dirty, and reddened as if with blood. He washes here. He brushes his
coat. The ordinariness of it is the worst thing in the room.")>

<OBJECT MEWS-WINDOW
	(IN PICCADILLY-HOUSE)
	(SYNONYM WINDOW MEWS)
	(DESC "window to the mews")
	(FLAGS NDESCBIT DOORBIT)
	(TEXT
"A tall window giving on the stable-mews behind the house: a back way
out for anything that does not mind a fall.")>

<ROOM WALWORTH
      (IN ROOMS)
      (DESC "A Court off Walworth")
      (LDESC
"A brick court of drying-lines and doorsteps. The carter Bloxam lodges
here, and will remember with his throat what his head forgets. The road
back is northwest.")
      (NW TO LONDON-ROAD)
      (ACTION ACT3-PLAIN-FCN)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT BLOXAM
	(IN WALWORTH)
	(SYNONYM BLOXAM SAM CARTER)
	(DESC "Sam Bloxam")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION BLOXAM-FCN)>

"London NPCs (the hunters)."

<OBJECT VAN-HELSING
	(SYNONYM HELSING PROFESSOR DOCTOR ABRAHAM)
	(ADJECTIVE VAN OLD)
	(DESC "Van Helsing")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION VAN-HELSING-FCN)>

<OBJECT GODALMING
	(SYNONYM GODALMING ARTHUR LORD)
	(DESC "Lord Godalming")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION GODALMING-FCN)>

<OBJECT MORRIS
	(SYNONYM MORRIS QUINCEY TEXAN)
	(DESC "Quincey Morris")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION MORRIS-FCN)>

<OBJECT JONATHAN
	(SYNONYM JONATHAN HARKER HUSBAND)
	(DESC "Jonathan Harker")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION JONATHAN-FCN)>

<OBJECT MEMORANDUM
	(SYNONYM MEMORANDUM ACCOUNT)
	(ADJECTIVE LUCYS)
	(DESC "Lucy's memorandum")
	(FLAGS TAKEBIT READBIT)
	(SIZE 1)
	(TEXT
"An account of the wolf night in Lucy's hand, written for whoever should
find her: the flapping at the window, the low howl in the shrubbery, the
crash of glass, her mother's hand tearing the wreath away as she fell.
\"The air seems full of specks, floating and circling... I shall hide
this paper in my breast, where they shall find it when they come to lay
me out.\"")>

"====================================================================
ACT III - THE CHASE"

<ROOM VARNA-HOTEL
      (IN ROOMS)
      (DESC "Hotel Odessus, Varna")
      (LDESC
"A shuttered hotel room grown small with waiting: maps on the table, the
kukri whetted daily, and every dawn and dusk the professor's hands
making passes before Mina's closed eyes. There is nowhere to go. There
is only news to wait for.")
      (ACTION VARNA-FCN)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<OBJECT RIVER-MAP
	(SYNONYM MAP MAPS)
	(ADJECTIVE RIVER)
	(DESC "map of the rivers")
	(FLAGS NDESCBIT READBIT)
	(ACTION RIVER-MAP-FCN)>

<OBJECT TIMETABLE
	(SYNONYM TIMETABLE BRADSHAW)
	(DESC "timetable")
	(FLAGS NDESCBIT READBIT)
	(TEXT
"Mina knows it by heart. \"I am the train fiend,\" she says, and the
professor laughs his terrible fond laugh, and the waiting goes on.")>

<OBJECT TELEGRAM
	(SYNONYM TELEGRAM WIRE)
	(DESC "telegram")
	(FLAGS TAKEBIT READBIT NDESCBIT)
	(SIZE 1)
	(TEXT
"28 October. -- Czarina Catherine reported entering Galatz at one
o'clock to-day. Three weeks you waited at Varna; he was never coming to
Varna. He read the plan in Mina's sleeping mind as the professor reads
the sea in hers.")>

<ROOM GALATZ-WHARF
      (IN ROOMS)
      (DESC "The Wharf at Galatz")
      (LDESC
"Brown river, tarred rope, and the Czarina Catherine warping in. A Scots
captain glares from the rail at the devil's own luck that blew him here.
The box is gone ashore already; what remains is paper, and the truth at
the bottom of it.")
      (ACTION GALATZ-FCN)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<OBJECT DONELSON
	(IN GALATZ-WHARF)
	(SYNONYM DONELSON CAPTAIN SCOT)
	(DESC "Captain Donelson")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION DONELSON-FCN)>

<OBJECT BILL-OF-LADING
	(IN GALATZ-WHARF)
	(SYNONYM BILL LADING)
	(DESC "bill of lading")
	(FLAGS NDESCBIT READBIT)
	(ACTION BILL-FCN)>

<ROOM CAMP
      (IN ROOMS)
      (DESC "Camp below the Castle")
      (LDESC
"A hollow in the rock like a doorway between two boulders. Snow flurries
walk the dark like women in trailing garments. Far above, the castle
cuts its jagged line against the sky; the road up to it climbs from
here. East lies the long way down to the Borgo road.")
      (UP PER CAMP-UP)
      (EAST "Not yet. The work above is not done, and until it is done
nobody leaves this camp but you.")
      (ACTION CAMP-FCN)
      (GLOBAL CASTLE-G)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<OBJECT HOLY-CIRCLE
	(IN CAMP)
	(SYNONYM CIRCLE RING)
	(ADJECTIVE HOLY)
	(DESC "circle")
	(FLAGS NDESCBIT)
	(ACTION HOLY-CIRCLE-FCN)>

<OBJECT CAMP-FIRE
	(IN CAMP)
	(SYNONYM FIRE)
	(ADJECTIVE CAMP)
	(DESC "fire")
	(FLAGS NDESCBIT)
	(TEXT
"A small stubborn fire. Mina sits close to it and does not feel the
cold, and that frightens you more than the cold would.")>

<OBJECT HORSES
	(IN CAMP)
	(SYNONYM HORSES HORSE)
	(DESC "horses")
	(FLAGS NDESCBIT)
	(ACTION HORSES-FCN)>

<OBJECT FIELD-GLASSES
	(IN CAMP)
	(SYNONYM GLASSES BINOCULARS)
	(ADJECTIVE FIELD)
	(DESC "field-glasses")
	(FLAGS TAKEBIT NDESCBIT)
	(SIZE 2)
	(TEXT
"Good field-glasses. From the ridge east you could count the buttons on
a rider an hour away.")>

<OBJECT WOLF-COAT
	(SYNONYM COAT)
	(ADJECTIVE WOLF-SKIN FUR)
	(DESC "wolf-skin coat")
	(FLAGS TAKEBIT WEARBIT)
	(SIZE 4)
	(TEXT
"A wolf-skin coat bought at Veresti. Warm as guilt, and in this weather
twice as welcome.")>

<ROOM FROZEN-ROAD
      (IN ROOMS)
      (DESC "The Borgo Road")
      (LDESC
"The last light lies red on the snow. Down the winding road comes the
leiter-wagon at the gallop, gypsies about it like a river round a stone,
and on the cart a great square chest. The sun stands a hand's-breadth
above the peaks.")
      (ACTION FROZEN-ROAD-FCN)
      (GLOBAL CASTLE-G WOLVES-G)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<OBJECT WAGON
	(IN FROZEN-ROAD)
	(SYNONYM WAGON CART LEITER-WAGON WHEEL)
	(DESC "leiter-wagon")
	(FLAGS NDESCBIT)
	(ACTION WAGON-FCN)>

<OBJECT THROAT
	(IN FROZEN-ROAD)
	(SYNONYM THROAT NECK)
	(DESC "throat")
	(FLAGS NDESCBIT INVISIBLE)
	(ACTION THROAT-FCN)>

<OBJECT WINCHESTER
	(SYNONYM WINCHESTER RIFLE)
	(DESC "Winchester rifle")
	(FLAGS TAKEBIT WEAPONBIT)
	(SIZE 4)
	(ACTION WINCHESTER-FCN)>

"====================================================================
GO and engine stubs"

<ROUTINE GO ()
	<SETG HERE ,COURTYARD>
	<TELL
"Third of May. Bistritz. -- The landlady's husband would not speak of
the castle. The landlady wept, and hung her own rosary about your neck.
For your mother's sake, she said, and would not take it back." CR CR>
	<TELL
"Now it is midnight in the Borgo Pass, and the coach has gone on to
Bukovina, glad to be rid of you. A caleche waits where no caleche
should be, drawn by four coal-black horses, driven by a tall man whose
hat brim hides everything but the red of his eyes. The dead travel
fast, a passenger whispered, and crossed himself." CR CR>
	<TELL
"You ride. Blue flames burn small and cold above the treasure-graves of
this country, and once, a ring of wolves closes round the carriage
until the driver sweeps his arm and they fall away like beaten dogs.
You are Jonathan Harker, solicitor, of Exeter. You have papers for a
nobleman to sign. That is all. That is surely all." CR CR>
	<TELL
"The horses stop." CR CR>
	<TELL
"DRACULA: The Un-Dead" CR
"Based on the novel by Bram Stoker. Type HELP for guidance." CR CR
"From the journal of Jonathan Harker." CR CR>
	<SETG LIT T>
	<SETG WINNER ,ADVENTURER>
	<SETG PLAYER ,WINNER>
	<MOVE ,WINNER ,HERE>
	<SETG FUMBLE-NUMBER 90> ;"no random fumbles: determinism"
	<SETG CRUCIFIX-WORN T>
	<SETG BOOTS-WORN T>
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
	(SYNONYM WATER)
	(ADJECTIVE GLOBAL)
	(DESC "water")
	(FLAGS DRINKBIT)>

<OBJECT WALL
	(IN GLOBAL-OBJECTS)
	(SYNONYM WALL WALLS STONES MORTAR)
	(ADJECTIVE STONE)
	(DESC "wall")
	(ACTION WALL-FCN)>

<PROPDEF TEXT 0>

<ROOM ON-LAKE
      (IN ROOMS)
      (DESC "On the Lake")
      (FLAGS RLANDBIT)>

<ROOM IN-LAKE
      (IN ROOMS)
      (DESC "In the Lake")
      (FLAGS RLANDBIT)>

<OBJECT FLAG-CARRIER
	(DESC "flag carrier")
	(FLAGS NONLANDBIT)>
