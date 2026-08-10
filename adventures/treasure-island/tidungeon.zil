"TIDUNGEON - the world of Treasure Island: rooms, objects, GO, stubs."

<DIRECTIONS NORTH EAST WEST SOUTH NE NW SE SW UP DOWN OUT LAND>

"=== ACT I - Black Hill Cove ==="

<ROOM PARLOUR
      (IN ROOMS)
      (DESC "Benbow Parlour")
      (LDESC
"The parlour of the Admiral Benbow, your whole world until tonight. The
fire is down to embers, the overturned chair is where he knocked it,
and Billy Bones lies full length on the floor, one arm thrown out, dead
of a thundering apoplexy. The road door is out; the bar is west; the
stairs go up.")
      (OUT TO COVE-ROAD)
      (NORTH TO COVE-ROAD)
      (WEST TO BAR)
      (UP TO CAPTAINS-ROOM)
      (ACTION PARLOUR-FCN)
      (GLOBAL STAIRS)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<OBJECT BILLY-BODY
	(IN PARLOUR)
	(SYNONYM BODY CAPTAIN BONES BILLY CORPSE MAN)
	(ADJECTIVE DEAD OLD)
	(DESC "body of Billy Bones")
	(FLAGS NDESCBIT)
	(ACTION BILLY-BODY-FCN)>

<OBJECT BLACK-SPOT
	(IN PARLOUR)
	(SYNONYM SPOT PAPER ROUND)
	(ADJECTIVE BLACK LITTLE)
	(DESC "black spot")
	(FDESC
"By the dead man's hand lies a little round of paper, blackened on the
one side: the black spot itself.")
	(FLAGS TAKEBIT READBIT)
	(SIZE 1)
	(ACTION BLACK-SPOT-FCN)>

<OBJECT GULLY
	(IN PARLOUR)
	(SYNONYM GULLY KNIFE CLASP-KNIFE)
	(ADJECTIVE CROOKED)
	(DESC "gully knife")
	(FLAGS TAKEBIT WEAPONBIT INVISIBLE)
	(SIZE 2)
	(ACTION GULLY-FCN)>

<OBJECT POCKET-COMPASS
	(IN PARLOUR)
	(SYNONYM COMPASS)
	(ADJECTIVE POCKET BRASS)
	(DESC "pocket compass")
	(FLAGS TAKEBIT INVISIBLE)
	(SIZE 1)
	(ACTION COMPASS-FCN)>

<OBJECT ODDMENTS
	(IN PARLOUR)
	(SYNONYM TOBACCO THIMBLE NEEDLES PIGTAIL THREAD ENDS)
	(ADJECTIVE ODD)
	(DESC "captain's odds and ends")
	(FLAGS TAKEBIT INVISIBLE)
	(SIZE 2)
	(ACTION ODDMENTS-FCN)>

<OBJECT TARRY-STRING
	(IN PARLOUR)
	(SYNONYM STRING SHIRT NECK)
	(ADJECTIVE TARRY)
	(DESC "tarry string")
	(FLAGS NDESCBIT INVISIBLE)
	(ACTION STRING-FCN)>

<OBJECT BRASS-KEY
	(IN PARLOUR)
	(SYNONYM KEY)
	(ADJECTIVE BRASS)
	(DESC "brass key")
	(FLAGS TAKEBIT INVISIBLE TOOLBIT)
	(SIZE 1)
	(ACTION KEY-FCN)>

<OBJECT PARLOUR-CHAIR
	(IN PARLOUR)
	(SYNONYM CHAIR)
	(ADJECTIVE OVERTURNED)
	(DESC "overturned chair")
	(FLAGS NDESCBIT)
	(ACTION CHAIR-FCN)>

<OBJECT EMBERS
	(IN PARLOUR)
	(SYNONYM EMBERS FIRE COALS)
	(DESC "embers")
	(FLAGS NDESCBIT)
	(ACTION EMBERS-FCN)>

<ROOM BAR
      (IN ROOMS)
      (DESC "Benbow Bar")
      (LDESC
"Bottles, the rum tap your poor father was so proud of, and the till
the neighbours swear will be robbed by morning. A candle burns here.
The parlour is back east.")
      (EAST TO PARLOUR)
      (OUT TO PARLOUR)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT CANDLE
	(IN BAR)
	(SYNONYM CANDLE)
	(ADJECTIVE LIT)
	(DESC "candle")
	(FLAGS TAKEBIT NDESCBIT)
	(SIZE 1)
	(ACTION CANDLE-FCN)>

<OBJECT RUM-BOTTLE
	(IN BAR)
	(SYNONYM RUM BOTTLE TAP)
	(DESC "bottle of rum")
	(FLAGS TAKEBIT NDESCBIT DRINKBIT)
	(SIZE 2)
	(ACTION RUM-FCN)>

<OBJECT TILL
	(IN BAR)
	(SYNONYM TILL MONEY)
	(DESC "till")
	(FLAGS NDESCBIT)
	(ACTION TILL-FCN)>

<ROOM CAPTAINS-ROOM
      (IN ROOMS)
      (DESC "Captain's Room")
      (LDESC
"The captain's room, smelling of tobacco and tar. His great sea-chest
stands at the bed's foot where it has stood since the day he came, the
initial B burned into the lid with a hot iron. The stairs go down.")
      (DOWN TO PARLOUR)
      (OUT TO PARLOUR)
      (GLOBAL STAIRS)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT SEA-CHEST
	(IN CAPTAINS-ROOM)
	(SYNONYM CHEST SEA-CHEST LID LOCK)
	(ADJECTIVE SEA GREAT)
	(DESC "sea-chest")
	(FLAGS CONTBIT LOCKEDBIT NDESCBIT)
	(CAPACITY 60)
	(ACTION CHEST-FCN)>

<OBJECT CHEST-CLOTHES
	(IN SEA-CHEST)
	(SYNONYM CLOTHES SUIT)
	(ADJECTIVE GOOD)
	(DESC "suit of good clothes")
	(FLAGS TAKEBIT)
	(SIZE 4)
	(ACTION CLOTHES-FCN)>

<OBJECT CHEST-ODDMENTS
	(IN SEA-CHEST)
	(SYNONYM GEAR QUADRANT CANIKIN WATCH SHELLS ODDMENTS)
	(ADJECTIVE SEAMAN)
	(DESC "seaman's gear")
	(FLAGS TAKEBIT INVISIBLE)
	(SIZE 4)
	(ACTION CHEST-ODDMENTS-FCN)>

<OBJECT BOAT-CLOAK
	(IN SEA-CHEST)
	(SYNONYM CLOAK BOAT-CLOAK)
	(ADJECTIVE OLD BOAT)
	(DESC "old boat-cloak")
	(FLAGS TAKEBIT INVISIBLE)
	(SIZE 3)
	(ACTION CLOAK-FCN)>

<OBJECT COIN-BAG
	(IN SEA-CHEST)
	(SYNONYM BAG GOLD COINS)
	(ADJECTIVE CANVAS)
	(DESC "canvas bag")
	(FLAGS TAKEBIT INVISIBLE)
	(SIZE 4)
	(ACTION COIN-BAG-FCN)>

<OBJECT PACKET
	(IN SEA-CHEST)
	(SYNONYM PACKET BUNDLE PAPERS)
	(ADJECTIVE OILSKIN OILCLOTH)
	(DESC "oilskin packet")
	(FLAGS TAKEBIT INVISIBLE)
	(SIZE 2)
	(ACTION PACKET-FCN)>

<OBJECT CAPT-BED
	(IN CAPTAINS-ROOM)
	(SYNONYM BED)
	(DESC "bed")
	(FLAGS NDESCBIT)
	(ACTION BED-FCN)>

<OBJECT CAPT-WINDOW
	(IN CAPTAINS-ROOM)
	(SYNONYM WINDOW)
	(DESC "window")
	(FLAGS NDESCBIT TRANSBIT)
	(ACTION WINDOW-FCN)>

<ROOM COVE-ROAD
      (IN ROOMS)
      (DESC "Road by the Cove")
      (LDESC
"The frosty road outside the inn. Fog is thinning off the cove and the
moon is coming up fast, which is bad news for anyone hoping to run
unseen. The inn door stands south; the road runs east toward the bridge
and west toward Kitt's Hole.")
      (SOUTH TO PARLOUR)
      (EAST TO BRIDGE)
      (WEST
"You'd walk straight into the smugglers' cove the lugger lies in. Even
you are not that curious tonight.")
      (ACTION COVE-ROAD-FCN)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT SIGNBOARD
	(IN COVE-ROAD)
	(SYNONYM SIGNBOARD SIGN)
	(ADJECTIVE BIG)
	(DESC "signboard")
	(FLAGS NDESCBIT)
	(ACTION SIGNBOARD-FCN)>

<ROOM BRIDGE
      (IN ROOMS)
      (DESC "Little Bridge")
      (LDESC
"A little stone bridge over the dell stream, barely tall enough for a
dog to walk under. The road runs on toward the hamlet, but lights are
bobbing on the hill behind you and they are not friendly ones. The bank
drops down to the arch below.")
      (WEST TO COVE-ROAD)
      (DOWN TO UNDER-BRIDGE)
      (EAST
"Moonlit road all the way to the hamlet - they would run you down in a
hundred yards.")
      (ACTION BRIDGE-FCN)
      (FLAGS RLANDBIT ONBIT)>

<ROOM UNDER-BRIDGE
      (IN ROOMS)
      (DESC "Under the Bridge")
      (LDESC
"You crouch in the black under the arch, knees in the stream, close
enough to the inn to hear everything. Which is rather the problem with
hiding here.")
      (UP TO BRIDGE)
      (ACTION UNDER-BRIDGE-FCN)
      (FLAGS RLANDBIT ONBIT)>

<ROOM HALL
      (IN ROOMS)
      (DESC "Squire's Hall")
      (LDESC
"The squire's library: bookcases to the ceiling, busts on top of them,
a sea-coal fire, and two gentlemen with pipes who have just heard your
story - Doctor Livesey, neat as new paint, and Squire Trelawney, six
feet of enthusiasm in a travelling coat.")
      (ACTION HALL-FCN)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT DOCTOR
	(IN HALL)
	(SYNONYM DOCTOR LIVESEY)
	(DESC "Dr. Livesey")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION DOCTOR-FCN)>

<OBJECT SQUIRE
	(IN HALL)
	(SYNONYM SQUIRE TRELAWNEY)
	(DESC "Squire Trelawney")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION SQUIRE-FCN)>

<OBJECT HALL-FIRE
	(IN HALL)
	(SYNONYM FIRE)
	(ADJECTIVE SEA-COAL)
	(DESC "sea-coal fire")
	(FLAGS NDESCBIT)>

<OBJECT PIGEON-PIE
	(IN HALL)
	(SYNONYM PIE SUPPER)
	(ADJECTIVE PIGEON)
	(DESC "pigeon pie")
	(FLAGS NDESCBIT FOODBIT)
	(ACTION PIE-FCN)>

<OBJECT ACCOUNT-BOOK
	(IN HALL)
	(SYNONYM BOOK)
	(ADJECTIVE ACCOUNT)
	(DESC "account book")
	(FLAGS NDESCBIT READBIT INVISIBLE)
	(ACTION ACCOUNT-BOOK-FCN)>

<OBJECT TREASURE-MAP
	(SYNONYM MAP CHART)
	(ADJECTIVE TREASURE)
	(DESC "treasure map")
	(FLAGS TAKEBIT READBIT)
	(SIZE 1)
	(ACTION MAP-FCN)>

"=== ACT II - Bristol and the Hispaniola ==="

<ROOM QUAY
      (IN ROOMS)
      (DESC "Bristol Quayside")
      (LDESC
"Bristol docks at their busiest: tar and salt, figureheads leaning
overhead, sailors with rings in their ears singing at the capstans. You
could stand here a year. The Spy-glass tavern is up the street north;
the Hispaniola's boat waits at the steps east.")
      (NORTH TO SPYGLASS-TAVERN)
      (EAST PER QUAY-EAST-FCN)
      (ACTION QUAY-FCN)
      (GLOBAL SHIP)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT SQUIRE-NOTE
	(SYNONYM NOTE LETTER)
	(ADJECTIVE SQUIRE SEALED)
	(DESC "squire's note")
	(FLAGS TAKEBIT READBIT)
	(SIZE 1)
	(ACTION NOTE-FCN)>

<ROOM SPYGLASS-TAVERN
      (IN ROOMS)
      (DESC "The Spy-Glass")
      (LDESC
"A bright little tavern with a great brass telescope for a sign, red
curtains, sanded floor, and a fog of pipe smoke full of loud seafaring
men. The door back to the quay is south.")
      (SOUTH TO QUAY)
      (OUT TO QUAY)
      (ACTION TAVERN-FCN)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT SILVER
	(IN SPYGLASS-TAVERN)
	(SYNONYM SILVER JOHN COOK BARBECUE LANDLORD)
	(ADJECTIVE LONG SEA ONE-LEGGED)
	(DESC "Long John Silver")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION SILVER-FCN)>

<OBJECT BLACK-DOG
	(IN SPYGLASS-TAVERN)
	(SYNONYM DOG STRANGER)
	(ADJECTIVE BLACK TALLOWY)
	(DESC "pale customer")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION BLACK-DOG-FCN)>

<OBJECT CUSTOMERS
	(IN SPYGLASS-TAVERN)
	(SYNONYM CUSTOMERS SAILORS SEAMEN MEN CROWD)
	(ADJECTIVE LOUD SEAFARING)
	(DESC "seafaring men")
	(FLAGS NDESCBIT)
	(ACTION CUSTOMERS-FCN)>

<ROOM DECK
      (IN ROOMS)
      (DESC "Hispaniola, Deck")
      (DOWN PER DECK-DOWN-FCN)
      (UP PER DECK-UP-FCN)
      (LAND PER DECK-LAND-FCN)
      (ACTION DECK-FCN)
      (GLOBAL SHIP SHORE SEA)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT APPLE-BARREL
	(IN DECK)
	(SYNONYM BARREL STAVES)
	(ADJECTIVE APPLE)
	(DESC "apple barrel")
	(FLAGS CONTBIT OPENBIT VEHBIT NDESCBIT)
	(CAPACITY 60)
	(VTYPE RLANDBIT)
	(ACTION BARREL-FCN)>

<OBJECT APPLE
	(IN APPLE-BARREL)
	(SYNONYM APPLE)
	(ADJECTIVE WITHERED SWEET)
	(DESC "withered apple")
	(FLAGS TAKEBIT FOODBIT NDESCBIT)
	(SIZE 1)
	(ACTION APPLE-FCN)>

<OBJECT LONG-TOM
	(IN DECK)
	(SYNONYM TOM NINE GUN CANNON)
	(ADJECTIVE LONG BRASS)
	(DESC "brass nine")
	(FLAGS NDESCBIT)
	(ACTION LONG-TOM-FCN)>

<OBJECT SHIP-MAST
	(IN DECK)
	(SYNONYM MAST SHROUDS RIGGING MIZZEN)
	(ADJECTIVE MIZZEN)
	(DESC "mizzen mast")
	(FLAGS NDESCBIT CLIMBBIT)
	(ACTION MAST-FCN)>

<OBJECT TILLER
	(IN DECK)
	(SYNONYM TILLER HELM WHEEL)
	(DESC "tiller")
	(FLAGS NDESCBIT)
	(ACTION TILLER-FCN)>

<OBJECT WATER-BREAKER
	(IN DECK)
	(SYNONYM BREAKER)
	(ADJECTIVE WATER)
	(DESC "water-breaker")
	(FLAGS NDESCBIT DRINKBIT)
	(ACTION BREAKER-FCN)>

<OBJECT AFT-COMPANION
	(IN DECK)
	(SYNONYM CABIN COMPANION AFT)
	(ADJECTIVE AFT STERN)
	(DESC "aft companion")
	(FLAGS NDESCBIT)
	(ACTION AFT-COMPANION-FCN)>

<OBJECT FORE-HATCH
	(IN DECK)
	(SYNONYM GALLEY FORE FORECASTLE)
	(ADJECTIVE FORE)
	(DESC "fore companion")
	(FLAGS NDESCBIT)
	(ACTION FORE-HATCH-FCN)>

<OBJECT GIG-BOAT
	(IN DECK)
	(SYNONYM GIG BOATS)
	(ADJECTIVE SHORE)
	(DESC "shore boat")
	(FLAGS NDESCBIT INVISIBLE)
	(ACTION GIG-BOAT-FCN)>

<OBJECT JOLLY-ROGER
	(SYNONYM ROGER FLAG COLOURS COLORS)
	(ADJECTIVE JOLLY BLACK CURSED)
	(DESC "Jolly Roger")
	(FLAGS NDESCBIT)
	(ACTION ROGER-FCN)>

<OBJECT ISRAEL-HANDS
	(SYNONYM ISRAEL HANDS COXSWAIN MARINER)
	(ADJECTIVE WOUNDED)
	(DESC "Israel Hands")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION HANDS-FCN)>

<OBJECT OBRIEN
	(SYNONYM OBRIEN WATCHMAN)
	(ADJECTIVE DEAD RED-CAPPED)
	(DESC "body of O'Brien")
	(FLAGS NDESCBIT)
	(ACTION OBRIEN-FCN)>

<ROOM GALLEY
      (IN ROOMS)
      (DESC "Galley")
      (UP TO DECK)
      (OUT TO DECK)
      (ACTION GALLEY-FCN)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT PARROT
	(IN GALLEY)
	(SYNONYM PARROT FLINT BIRD POLLY)
	(ADJECTIVE GREEN)
	(DESC "Cap'n Flint the parrot")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION PARROT-FCN)>

<OBJECT PARROT-CAGE
	(IN GALLEY)
	(SYNONYM CAGE BARS)
	(DESC "parrot's cage")
	(FLAGS NDESCBIT)
	(ACTION CAGE-FCN)>

<OBJECT CHEESE
	(IN GALLEY)
	(SYNONYM CHEESE WEDGE)
	(DESC "wedge of cheese")
	(FLAGS TAKEBIT NDESCBIT FOODBIT)
	(SIZE 1)
	(ACTION CHEESE-FCN)>

<OBJECT GALLEY-STUFF
	(IN GALLEY)
	(SYNONYM DISHES BACON PANS)
	(ADJECTIVE BURNISHED)
	(DESC "burnished dishes")
	(FLAGS NDESCBIT)
	(ACTION GALLEY-STUFF-FCN)>

<ROOM CABIN
      (IN ROOMS)
      (DESC "Stern Cabin")
      (UP TO DECK)
      (OUT TO DECK)
      (ACTION CABIN-FCN)
      (GLOBAL SHORE)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT CHART-TABLE
	(IN CABIN)
	(SYNONYM TABLE LOCKERS)
	(ADJECTIVE CHART)
	(DESC "chart table")
	(FLAGS NDESCBIT)
	(ACTION CHART-TABLE-FCN)>

<OBJECT RAISINS
	(IN CABIN)
	(SYNONYM RAISINS)
	(DESC "box of raisins")
	(FLAGS TAKEBIT NDESCBIT FOODBIT)
	(SIZE 1)
	(ACTION RAISINS-FCN)>

<OBJECT BRANDY
	(SYNONYM BRANDY)
	(ADJECTIVE BRANDY)
	(DESC "bottle of brandy")
	(FLAGS TAKEBIT NDESCBIT DRINKBIT)
	(SIZE 1)
	(ACTION BRANDY-FCN)>

<OBJECT WINE
	(SYNONYM WINE)
	(DESC "bottle of wine")
	(FLAGS TAKEBIT NDESCBIT DRINKBIT)
	(SIZE 1)
	(ACTION WINE-FCN)>

<OBJECT SHIP-BISCUIT
	(SYNONYM BISCUIT BISCUITS BREAD)
	(ADJECTIVE HARD)
	(DESC "ship's biscuit")
	(FLAGS TAKEBIT NDESCBIT FOODBIT)
	(SIZE 1)
	(ACTION BISCUIT-FCN)>

<OBJECT MEDICAL-BOOK
	(SYNONYM BOOK LEAVES)
	(ADJECTIVE MEDICAL GUTTED)
	(DESC "gutted medical book")
	(FLAGS NDESCBIT READBIT)
	(ACTION MEDICAL-BOOK-FCN)>

<OBJECT EMPTY-BOTTLES
	(SYNONYM BOTTLES)
	(ADJECTIVE EMPTY)
	(DESC "empty bottles")
	(FLAGS NDESCBIT)
	(ACTION BOTTLES-FCN)>

<OBJECT SPARRED-GALLERY
	(SYNONYM GALLERY SNEAK PASSAGE)
	(ADJECTIVE SPARRED)
	(DESC "sparred gallery")
	(FLAGS NDESCBIT INVISIBLE)
	(ACTION GALLERY-FCN)>

<ROOM CROSS-TREES
      (IN ROOMS)
      (DESC "Cross-Trees")
      (LDESC
"You sit the cross-trees of the mizzen, the whole tilted deck below you
and green water below that. Because the ship lies canted on the sand,
the mast hangs far out over the bay: a bad place to drop from, a worse
one to be caught in.")
      (DOWN PER XTREES-DOWN-FCN)
      (ACTION XTREES-FCN)
      (GLOBAL SEA)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT DIRK
	(SYNONYM DIRK)
	(ADJECTIVE BLOOD-STAINED THROWN)
	(DESC "Israel's dirk")
	(FLAGS TAKEBIT NDESCBIT WEAPONBIT)
	(SIZE 1)
	(ACTION DIRK-FCN)>

"=== ACT III - Treasure Island ==="

<ROOM LANDING-BEACH
      (IN ROOMS)
      (DESC "Anchorage Beach")
      (LDESC
"A curve of grey sand inside Captain Kidd's Anchorage, dead still,
smelling of sodden leaves and rotting tree trunks. The doctor would
stake his wig there's fever here. The two gigs are drawn up on the
sand. Marsh lies north, and woods run east along the shore.")
      (NORTH TO MARSH)
      (EAST TO SHORE-WOODS)
      (ACTION BEACH-FCN)
      (GLOBAL SEA SPYGLASS-HILL)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT GIGS
	(IN LANDING-BEACH)
	(SYNONYM GIGS)
	(ADJECTIVE BEACHED)
	(DESC "beached gigs")
	(FLAGS NDESCBIT)
	(ACTION GIGS-FCN)>

<ROOM MARSH
      (IN ROOMS)
      (DESC "The Marsh")
      (LDESC
"Willows, bulrushes, and outlandish swampy trees; the ground quakes and
steams under the sun. Somewhere a duck gets up with a clatter, then a
whole screaming cloud of them - something is moving on the far side of
the fen. Higher ground lies north; the beach is south.")
      (NORTH TO OPEN-WOODS)
      (SOUTH TO LANDING-BEACH)
      (ACTION MARSH-FCN)
      (GLOBAL SPYGLASS-HILL)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT SNAKE
	(IN MARSH)
	(SYNONYM SNAKE RATTLESNAKE)
	(DESC "rattlesnake")
	(FLAGS NDESCBIT)
	(ACTION SNAKE-FCN)>

<ROOM OPEN-WOODS
      (IN ROOMS)
      (DESC "Open Woods")
      (LDESC
"Live oaks growing low and twisted like brambles, scattered pines fifty
and seventy feet high, and the Spy-glass trembling through the haze
above everything. Paths go all ways: the marsh lies south, a two-peaked
hill east, a long slope rising west, sandy lowlands north, and the
shore southeast.")
      (SOUTH TO MARSH)
      (EAST TO HILL-FOOT)
      (WEST TO PLATEAU-SLOPE)
      (NORTH TO NORTH-INLET)
      (SE TO SHORE-WOODS)
      (ACTION OPEN-WOODS-FCN)
      (GLOBAL SPYGLASS-HILL)
      (FLAGS RLANDBIT ONBIT)>

<ROOM HILL-FOOT
      (IN ROOMS)
      (DESC "Foot of the Two-Peaked Hill")
      (LDESC
"The ground climbs toward a hill with two craggy peaks. Gravel spouts
rattle down from ledge to ledge as if something up there moves when you
move. Among the rocks there are mounds laid out in rows - a cemetery,
of goats, with every grave tended.")
      (WEST TO OPEN-WOODS)
      (SOUTH TO SHORE-WOODS)
      (UP PER HILLFOOT-UP-FCN)
      (ACTION HILL-FOOT-FCN)
      (GLOBAL SPYGLASS-HILL)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT BEN-GUNN
	(SYNONYM BEN GUNN MAROON CHRISTIAN)
	(ADJECTIVE POOR RAGGED)
	(DESC "Ben Gunn")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION BEN-GUNN-FCN)>

<OBJECT GOAT-CEMETERY
	(IN HILL-FOOT)
	(SYNONYM CEMETERY GRAVES MOUNDS GOATS)
	(ADJECTIVE GOAT)
	(DESC "goat cemetery")
	(FLAGS NDESCBIT)
	(ACTION CEMETERY-FCN)>

<ROOM SHORE-WOODS
      (IN ROOMS)
      (DESC "Woods by the Shore")
      (LDESC
"Fir and live-oak growing almost to the tide line. Through the trunks
you can see the anchorage one way and white surf the other. The beach
lies west, the two-peaked hill north, a cleared knoll east where a
British flag flies, and a long sandy spit south.")
      (WEST TO LANDING-BEACH)
      (NORTH TO HILL-FOOT)
      (EAST TO STOCKADE-CLEARING)
      (SOUTH TO SANDY-SPIT)
      (ACTION SHORE-WOODS-FCN)
      (GLOBAL SEA SPYGLASS-HILL)
      (FLAGS RLANDBIT ONBIT)>

<ROOM STOCKADE-CLEARING
      (IN ROOMS)
      (DESC "Outside the Stockade")
      (LDESC
"A wide cleared slope around a knoll, stumps everywhere, and on the
knoll a log-house behind a six-foot paling with never a door in it -
you go over, or you stay out. The Union Jack snaps overhead, which is
the best thing you have seen all day. The woods are back west; the
log-house is in, over the fence.")
      (WEST TO SHORE-WOODS)
      (ACTION CLEARING-FCN)
      (GLOBAL SPYGLASS-HILL)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT PALING
	(IN STOCKADE-CLEARING)
	(SYNONYM PALING FENCE PALISADE STOCKADE)
	(ADJECTIVE SIX-FOOT)
	(DESC "paling")
	(FLAGS NDESCBIT CLIMBBIT)
	(ACTION PALING-FCN)>

<OBJECT UNION-JACK
	(IN STOCKADE-CLEARING)
	(SYNONYM JACK FLAG)
	(ADJECTIVE UNION BRITISH)
	(DESC "Union Jack")
	(FLAGS NDESCBIT)
	(ACTION JACK-FCN)>

<OBJECT STUMPS
	(IN STOCKADE-CLEARING)
	(SYNONYM STUMPS KNOLL)
	(DESC "stumps")
	(FLAGS NDESCBIT)>

<ROOM LOG-HOUSE
      (IN ROOMS)
      (DESC "The Log-House")
      (OUT PER LOGHOUSE-OUT-FCN)
      (ACTION LOG-HOUSE-FCN)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT SMOLLETT
	(IN LOG-HOUSE)
	(SYNONYM SMOLLETT CAPTAIN)
	(DESC "Captain Smollett")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION SMOLLETT-FCN)>

<OBJECT GRAY
	(IN LOG-HOUSE)
	(SYNONYM GRAY ABRAHAM)
	(DESC "Abraham Gray")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION GRAY-FCN)>

<OBJECT MUSKET-RACK
	(IN LOG-HOUSE)
	(SYNONYM MUSKETS RACK MUSKET)
	(DESC "musket rack")
	(FLAGS NDESCBIT)
	(ACTION MUSKET-RACK-FCN)>

<OBJECT CUTLASS
	(IN LOG-HOUSE)
	(SYNONYM CUTLASS CUTLASSES SWORD PILE)
	(DESC "cutlass")
	(FLAGS TAKEBIT NDESCBIT WEAPONBIT)
	(SIZE 3)
	(ACTION CUTLASS-FCN)>

<OBJECT BISCUIT-BAGS
	(IN LOG-HOUSE)
	(SYNONYM BAGS STORES)
	(ADJECTIVE BISCUIT)
	(DESC "biscuit bags")
	(FLAGS NDESCBIT)
	(ACTION BISCUIT-BAGS-FCN)>

<OBJECT BRANDY-CASK
	(IN LOG-HOUSE)
	(SYNONYM CASK)
	(ADJECTIVE BRANDY)
	(DESC "brandy cask")
	(FLAGS NDESCBIT)>

<OBJECT SPRING-KETTLE
	(IN LOG-HOUSE)
	(SYNONYM KETTLE SPRING)
	(ADJECTIVE IRON)
	(DESC "ship's kettle")
	(FLAGS NDESCBIT)
	(ACTION KETTLE-FCN)>

<OBJECT LOOPHOLES
	(IN LOG-HOUSE)
	(SYNONYM LOOPHOLES LOOPHOLE)
	(DESC "loopholes")
	(FLAGS NDESCBIT)
	(ACTION LOOPHOLES-FCN)>

<OBJECT BOARDER
	(SYNONYM PIRATE BOARDER BUCCANEER)
	(ADJECTIVE BOARDING)
	(DESC "boarding pirate")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION BOARDER-FCN)>

<OBJECT PIRATES
	(SYNONYM PIRATES MUTINEERS MERRY MORGAN DICK GEORGE CREW)
	(ADJECTIVE SIX)
	(DESC "buccaneers")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION PIRATES-FCN)>

<OBJECT BIBLE-PAGE
	(SYNONYM PAGE SPOT)
	(ADJECTIVE BIBLE)
	(DESC "black spot cut from a Bible")
	(FLAGS TAKEBIT READBIT NDESCBIT)
	(SIZE 1)
	(ACTION BIBLE-PAGE-FCN)>

<ROOM SANDY-SPIT
      (IN ROOMS)
      (DESC "Sandy Spit")
      (LDESC
"A low spit of dunes and scrub running south between the anchorage and
the open sea, joined at half-water to Skeleton Island. The surf on the
sea side never stops - you believe now that nowhere on this island is
out of earshot of it. A tall rock, peculiarly white, shows above the
brush to the south.")
      (NORTH TO SHORE-WOODS)
      (SOUTH TO WHITE-ROCK)
      (ACTION SPIT-FCN)
      (GLOBAL SEA SPYGLASS-HILL)
      (FLAGS RLANDBIT ONBIT)>

<ROOM WHITE-ROCK
      (IN ROOMS)
      (DESC "The White Rock")
      (LDESC
"The white rock, taller than a man, over a small hollow of green turf
hidden by banks and knee-deep underwood. Down in the hollow crouches a
little tent of goat-skins, like what the gipsies carry about in
England. The spit runs back north.")
      (NORTH TO SANDY-SPIT)
      (ACTION WHITE-ROCK-FCN)
      (GLOBAL SEA)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT ROCK
	(IN WHITE-ROCK)
	(SYNONYM ROCK HOLLOW)
	(ADJECTIVE WHITE TALL)
	(DESC "white rock")
	(FLAGS NDESCBIT)
	(ACTION ROCK-FCN)>

<OBJECT TENT
	(IN WHITE-ROCK)
	(SYNONYM TENT GOAT-SKINS GOATSKINS)
	(ADJECTIVE GOATSKIN LITTLE)
	(DESC "goatskin tent")
	(FLAGS CONTBIT NDESCBIT)
	(CAPACITY 60)
	(ACTION TENT-FCN)>

<OBJECT CORACLE
	(IN TENT)
	(SYNONYM CORACLE)
	(ADJECTIVE HOME-MADE LOP-SIDED)
	(DESC "coracle")
	(FLAGS TAKEBIT)
	(SIZE 20)
	(ACTION CORACLE-FCN)>

<OBJECT SPADE
	(IN TENT)
	(SYNONYM SPADE SHOVEL)
	(ADJECTIVE OLD)
	(DESC "old spade")
	(FLAGS TAKEBIT TOOLBIT)
	(SIZE 4)
	(ACTION SPADE-FCN)>

<ROOM ANCHORAGE
      (IN ROOMS)
      (DESC "On the Anchorage")
      (LAND
"The nearest land is the shore astern, and the ebb has views on that
subject.")
      (ACTION ANCHORAGE-FCN)
      (GLOBAL SHIP SEA)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT HAWSER
	(IN ANCHORAGE)
	(SYNONYM HAWSER CABLE)
	(ADJECTIVE TAUT)
	(DESC "hawser")
	(FLAGS NDESCBIT)
	(ACTION HAWSER-FCN)>

<OBJECT CORD
	(IN ANCHORAGE)
	(SYNONYM CORD LINE)
	(ADJECTIVE TRAILING)
	(DESC "trailing cord")
	(FLAGS NDESCBIT INVISIBLE)
	(ACTION CORD-FCN)>

<ROOM NORTH-INLET
      (IN ROOMS)
      (DESC "North Inlet")
      (LDESC
"A narrow northern anchorage like a river's mouth, flat sand, trees to
the water on every side, and two ships for company: the Hispaniola
lying beached on her side with your handiwork trailing from her, and a
nameless three-masted wreck so old that shore bushes flower on her
deck.")
      (SOUTH TO OPEN-WOODS)
      (ACTION INLET-FCN)
      (GLOBAL SHIP SEA SPYGLASS-HILL)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT OLD-WRECK
	(IN NORTH-INLET)
	(SYNONYM WRECK HULK)
	(ADJECTIVE OLD NAMELESS THREE-MASTED)
	(DESC "old wreck")
	(FLAGS NDESCBIT)
	(ACTION WRECK-FCN)>

<ROOM PLATEAU-SLOPE
      (IN ROOMS)
      (DESC "Slope of the Plateau")
      (LDESC
"A long climb west: miry ground at the bottom, then broom and flowering
shrubs, nutmeg thickets, and the red columns of great pines. The air
turns fresh as you rise. The plateau levels off above; the woods are
back east.")
      (EAST TO OPEN-WOODS)
      (UP TO SKELETON)
      (WEST TO SKELETON)
      (ACTION SLOPE-FCN)
      (GLOBAL SPYGLASS-HILL)
      (FLAGS RLANDBIT ONBIT)>

<ROOM SKELETON
      (IN ROOMS)
      (DESC "Plateau of the Pines")
      (LDESC
"The open top of the plateau, big pines wide apart. At the foot of one,
half swallowed in a green creeper, a human skeleton lies stretched on
the ground - dead straight, feet one way, hands raised over its head
the other way, like a diver frozen mid-plunge. Nothing about it is
natural. The shoulder of the Spy-glass lies west, the black crag north,
and the slope goes back down east.")
      (DOWN TO PLATEAU-SLOPE)
      (EAST TO PLATEAU-SLOPE)
      (WEST TO SPYGLASS-SHOULDER)
      (NORTH TO BLACK-CRAG)
      (ACTION SKELETON-ROOM-FCN)
      (GLOBAL SPYGLASS-HILL)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT SKELETON-BONES
	(IN SKELETON)
	(SYNONYM SKELETON BONES ALLARDYCE POINTER)
	(ADJECTIVE HUMAN)
	(DESC "human skeleton")
	(FLAGS NDESCBIT)
	(ACTION SKELETON-FCN)>

<ROOM SPYGLASS-SHOULDER
      (IN ROOMS)
      (DESC "Spy-Glass Shoulder")
      (LDESC
"The lower shoulder of the Spy-glass, sheer rock above, the whole
island below: the anchorage and Skeleton Island behind you, the Cape of
the Woods fringed with surf ahead, open sea both sides. Three pines on
this line could be called tall, but one, northwest of here, is a giant
- a red column big as a cottage.")
      (EAST TO SKELETON)
      (NW TO TALL-PINE)
      (UP
"The Spy-glass goes up sheer as a pedestal. Goats manage it. You are
not a goat.")
      (ACTION SHOULDER-FCN)
      (GLOBAL SEA SPYGLASS-HILL)
      (FLAGS RLANDBIT ONBIT)>

<ROOM TALL-PINE
      (IN ROOMS)
      (DESC "The Tall Pine")
      (LDESC
"The giant pine, two hundred feet of it, with a shadow a ship's company
could drill in. Under it the ground has already told the whole story: a
great pit, sides fallen in, grass sprouted on the bottom, a pick-shaft
broken in two, and packing boards branded with a hot iron: WALRUS.")
      (SE TO SPYGLASS-SHOULDER)
      (ACTION PINE-FCN)
      (GLOBAL SPYGLASS-HILL)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT EXCAVATION
	(IN TALL-PINE)
	(SYNONYM PIT EXCAVATION HOLE CACHE)
	(ADJECTIVE GREAT EMPTY)
	(DESC "great pit")
	(FLAGS NDESCBIT)
	(ACTION EXCAVATION-FCN)>

<OBJECT BROKEN-PICK
	(IN TALL-PINE)
	(SYNONYM PICK SHAFT PICK-SHAFT)
	(ADJECTIVE BROKEN)
	(DESC "broken pick")
	(FLAGS NDESCBIT)
	(ACTION PICK-FCN)>

<OBJECT WALRUS-BOARDS
	(IN TALL-PINE)
	(SYNONYM BOARDS BOARD)
	(ADJECTIVE PACKING BRANDED)
	(DESC "packing boards")
	(FLAGS NDESCBIT READBIT)
	(ACTION BOARDS-FCN)>

<OBJECT GUINEA
	(IN TALL-PINE)
	(SYNONYM GUINEA COIN PIECE)
	(ADJECTIVE TWO-GUINEA)
	(DESC "two-guinea piece")
	(FLAGS TAKEBIT NDESCBIT INVISIBLE)
	(SIZE 1)
	(ACTION GUINEA-FCN)>

<OBJECT SILVER-PISTOL
	(SYNONYM PISTOL)
	(ADJECTIVE DOUBLE-BARRELLED)
	(DESC "double-barrelled pistol")
	(FLAGS TAKEBIT NDESCBIT WEAPONBIT)
	(SIZE 2)
	(ACTION SILVER-PISTOL-FCN)>

<ROOM BLACK-CRAG
      (IN ROOMS)
      (DESC "Below the Black Crag")
      (LDESC
"A black crag rises off the north slope, and weather has beaten a face
into it - brows, a broken nose, a mouth full of shadow, watching the
sea. A long hummock of sand trends away east below it. Ten fathoms
south of the crag... but that is the map's phrase, not yours. The
plateau of the pines is back south.")
      (SOUTH TO SKELETON)
      (ACTION CRAG-FCN)
      (GLOBAL SEA SPYGLASS-HILL)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT CRAG-FACE
	(IN BLACK-CRAG)
	(SYNONYM CRAG FACE HUMMOCK)
	(ADJECTIVE BLACK)
	(DESC "black crag")
	(FLAGS NDESCBIT)
	(ACTION CRAG-FACE-FCN)>

<OBJECT INGOT
	(IN BLACK-CRAG)
	(SYNONYM INGOT BARS INGOTS)
	(ADJECTIVE BAR)
	(DESC "bars of silver")
	(FLAGS NDESCBIT INVISIBLE)
	(ACTION INGOT-FCN)>

<ROOM BEN-CAVE
      (IN ROOMS)
      (DESC "Ben Gunn's Cave")
      (LDESC
"A large airy cave with a sandy floor, a spring rising into a pool of
clear water overhung with ferns, and - once you see it you can see
nothing else - great heaps of coin and quadrilaterals built of bars of
gold, glowing back at the fire. Flint's treasure, that seventeen men of
the Hispaniola have already died for.")
      (DOWN TO HILL-FOOT)
      (ACTION CAVE-FCN)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT TREASURE-HEAP
	(IN BEN-CAVE)
	(SYNONYM TREASURE GOLD COIN COINS HEAPS DOUBLOONS)
	(ADJECTIVE GREAT)
	(DESC "Flint's treasure")
	(FLAGS NDESCBIT)
	(ACTION TREASURE-FCN)>

<OBJECT GOAT-MEAT
	(IN BEN-CAVE)
	(SYNONYM MEAT)
	(ADJECTIVE GOAT SALTED)
	(DESC "salted goat meat")
	(FLAGS NDESCBIT FOODBIT)
	(ACTION GOAT-MEAT-FCN)>

<OBJECT CAVE-FIRE
	(IN BEN-CAVE)
	(SYNONYM FIRE)
	(ADJECTIVE BIG)
	(DESC "big fire")
	(FLAGS NDESCBIT)>

"=== Items the player carries between acts (start unplaced) ==="

<OBJECT PISTOLS
	(SYNONYM PISTOLS BRACE)
	(ADJECTIVE LOADED)
	(DESC "brace of pistols")
	(FLAGS TAKEBIT WEAPONBIT)
	(SIZE 3)
	(ACTION PISTOLS-FCN)>

<OBJECT POWDER-HORN
	(SYNONYM POWDER HORN BALL)
	(ADJECTIVE POWDER)
	(DESC "powder horn")
	(FLAGS TAKEBIT)
	(SIZE 2)
	(ACTION POWDER-FCN)>

"=== Local-global scenery (listed in rooms' GLOBAL properties) ==="

<OBJECT SHIP
	(IN LOCAL-GLOBALS)
	(SYNONYM SHIP SCHOONER HISPANIOLA VESSEL BOWSPRIT)
	(ADJECTIVE SWEET RUNAWAY)
	(DESC "Hispaniola")
	(FLAGS NDESCBIT CLIMBBIT)
	(ACTION SHIP-FCN)>

<OBJECT SHORE
	(IN LOCAL-GLOBALS)
	(SYNONYM SHORE ASHORE)
	(DESC "shore")
	(FLAGS NDESCBIT)
	(ACTION SHORE-FCN)>

<OBJECT SEA
	(IN LOCAL-GLOBALS)
	(SYNONYM SEA OCEAN SURF OVERBOARD WAVES)
	(ADJECTIVE OPEN)
	(DESC "sea")
	(FLAGS NDESCBIT)
	(ACTION SEA-FCN)>

<OBJECT SPYGLASS-HILL
	(IN LOCAL-GLOBALS)
	(SYNONYM SPY-GLASS SPYGLASS HILL)
	(ADJECTIVE SHEER)
	(DESC "Spy-glass")
	(FLAGS NDESCBIT)
	(ACTION SPYGLASS-HILL-FCN)>

"=== Engine-required stubs (copied from Tiny Quest) ==="

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

"A catch-all topic so ASK/TELL ABOUT never dies on an unknown noun; the
actors' own routines answer in character and ignore the topic."

<OBJECT TOPICS
	(IN GLOBAL-OBJECTS)
	(SYNONYM FLINT MUTINY ISLAND TREASURE HIMSELF ME EVERYTHING PLAN)
	(ADJECTIVE BURIED)
	(DESC "that subject")
	(FLAGS NDESCBIT)
	(ACTION TOPICS-FCN)>

<OBJECT WALL
	(IN GLOBAL-OBJECTS)
	(SYNONYM WALL WALLS)
	(DESC "wall")>

<PROPDEF TEXT 0>

"Unreachable stub rooms: generic engine verb branches compare HERE
against them."

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
	(FLAGS NONLANDBIT VEHBIT STAGGERED FIGHTBIT VILLAIN BURNBIT
	       FLAMEBIT LIGHTBIT TURNBIT SEARCHBIT WEARBIT)>

<ROUTINE GO ()
	<SETG HERE ,PARLOUR>
	<SETG LIT T>
	<SETG WINNER ,ADVENTURER>
	<PUTP ,ADVENTURER ,P?ACTION ,ADVENTURER-FCN>
	<SETG PLAYER ,WINNER>
	<MOVE ,WINNER ,HERE>
	<SETG LOAD-ALLOWED 500>
	<SETG FUMBLE-NUMBER 100>
	<COND (<NOT <FSET? ,HERE ,TOUCHBIT>>
	       <INTRO-TEXT>)>
	<INIT-SCENES>
	<V-LOOK>
	<MAIN-LOOP>
	<AGAIN>>

<ROUTINE INTRO-TEXT ()
	<TELL
"Squire Trelawney, Doctor Livesey, and the rest of these gentlemen
having asked me to write down the whole particulars about Treasure
Island, I take up my pen in the year of grace seventeen-something, and
go back to the night it all began - the night of the black spot." CR CR>
	<TELL
"You are Jim Hawkins, fourteen, of the Admiral Benbow inn, Black Hill
Cove. For months an old buccaneer called Billy Bones has lodged under
your roof, drinking rum against doctor's orders and paying you a silver
fourpenny a month to keep your weather-eye open for a seafaring man
with one leg. This afternoon a blind beggar came tap-tapping up the
frozen road, gripped your arm like a vise, and pressed something into
the captain's palm. \"And now that's done,\" said the blind man, and
skipped out into the fog." CR CR>
	<TELL
"The captain read his palm just once. \"Ten o'clock!\" he cried. \"Six
hours. We'll do them yet\" - and sprang up, and reeled, and went down
like a felled mast. Thundering apoplexy, the doctor would call it.
Dead, is what it is, on the parlour floor, with the little black round
of paper still lying by his hand." CR CR>
	<TELL
"Your mother has run for help to the hamlet; you know already what help
the neighbours will be. The fire is low. The clock ticks. Out on the
road, faint and far off for now, you can hear it if you hold your
breath: tap. Tap. Tap." CR CR>
	<TELL
"TREASURE ISLAND: A Tale of the Sea-Cook - freely adapted from Robert
Louis Stevenson. Type as you please; the inn, at least for the moment,
is yours." CR CR>>
