"OZDUNGEON - the world of THE SILVER SHOES: rooms, objects, GO, stubs."

<DIRECTIONS NORTH EAST WEST SOUTH NE NW SE SW UP DOWN IN OUT LAND>

"=== Local-global scenery, referenceable from listed rooms ==="

<OBJECT YELLOW-ROAD-LG
	(IN LOCAL-GLOBALS)
	(SYNONYM ROAD BRICKS BRICK)
	(ADJECTIVE YELLOW)
	(DESC "road of yellow brick")
	(FLAGS NDESCBIT)
	(ACTION ROAD-LG-FCN)>

<OBJECT TREES-LG
	(IN LOCAL-GLOBALS)
	(SYNONYM TREES FOREST WOODS)
	(DESC "trees")
	(FLAGS NDESCBIT)
	(ACTION TREES-LG-FCN)>

<OBJECT GORGE-LG
	(IN LOCAL-GLOBALS)
	(SYNONYM GORGE DITCH GULF)
	(ADJECTIVE WIDE DEEP JAGGED)
	(DESC "gorge")
	(FLAGS NDESCBIT)
	(ACTION GORGE-LG-FCN)>

<OBJECT RIVER-LG
	(IN LOCAL-GLOBALS)
	(SYNONYM RIVER CURRENT)
	(ADJECTIVE BROAD SWIFT)
	(DESC "river")
	(FLAGS NDESCBIT)
	(ACTION RIVER-LG-FCN)>

<OBJECT CASTLE-LG
	(IN LOCAL-GLOBALS)
	(SYNONYM CASTLE)
	(ADJECTIVE YELLOW)
	(DESC "castle")
	(FLAGS NDESCBIT)
	(ACTION CASTLE-LG-FCN)>

"=== Global word-objects (always in scope) ==="

<OBJECT KISS-MARK
	(IN GLOBAL-OBJECTS)
	(SYNONYM MARK FOREHEAD)
	(ADJECTIVE ROUND SHINING)
	(DESC "round, shining mark")
	(FLAGS NDESCBIT)
	(ACTION KISS-MARK-FCN)>

<OBJECT DOROTHY-W
	(IN GLOBAL-OBJECTS)
	(SYNONYM DOROTHY)
	(DESC "your own name")
	(FLAGS NDESCBIT)
	(ACTION DOROTHY-W-FCN)>

<OBJECT CITY-W
	(IN GLOBAL-OBJECTS)
	(SYNONYM CITY EMERALDS)
	(ADJECTIVE EMERALD)
	(DESC "Emerald City")
	(FLAGS NDESCBIT)
	(ACTION CITY-W-FCN)>

<OBJECT KANSAS-W
	(IN GLOBAL-OBJECTS)
	(SYNONYM KANSAS HOME)
	(DESC "Kansas")
	(FLAGS NDESCBIT)
	(ACTION KANSAS-W-FCN)>

<OBJECT EPPE-W
	(IN GLOBAL-OBJECTS)
	(SYNONYM EPPE PEPPE KAKKE)
	(DESC "first line of the charm")
	(FLAGS NDESCBIT)>

<OBJECT HILLO-W
	(IN GLOBAL-OBJECTS)
	(SYNONYM HILLO HOLLO)
	(DESC "second line of the charm")
	(FLAGS NDESCBIT)>

<OBJECT ZIZZY-W
	(IN GLOBAL-OBJECTS)
	(SYNONYM ZIZZY ZUZZY ZIK)
	(DESC "third line of the charm")
	(FLAGS NDESCBIT)>

<OBJECT JOURNEY-W
	(IN GLOBAL-OBJECTS)
	(SYNONYM JOURNEY STORY TALE TRIP)
	(DESC "story of your journey")
	(FLAGS NDESCBIT)>

<OBJECT MESSAGE-W
	(IN GLOBAL-OBJECTS)
	(SYNONYM MESSAGE)
	(DESC "message")
	(FLAGS NDESCBIT)>

<OBJECT FRIEND-W
	(IN GLOBAL-OBJECTS)
	(SYNONYM FRIEND SCARECROW)
	(DESC "the Scarecrow")
	(FLAGS NDESCBIT)
	(ACTION FRIEND-W-FCN)>

<OBJECT WOOD-W
	(IN LOCAL-GLOBALS)
	(SYNONYM WOOD LOGS STICKS)
	(DESC "firewood")
	(FLAGS NDESCBIT)>

<OBJECT HELP-W
	(IN GLOBAL-OBJECTS)
	(SYNONYM HELP AID)
	(DESC "help")
	(FLAGS NDESCBIT)>

"=== ACT I ROOMS ==="

<ROOM FARMHOUSE
      (IN ROOMS)
      (DESC "Farmhouse, Kansas")
      (OUT PER FARMHOUSE-OUT)
      (EAST PER FARMHOUSE-OUT)
      (DOWN PER CELLAR-EXIT)
      (ACTION FARMHOUSE-FCN)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM CLEARING
      (IN ROOMS)
      (DESC "Munchkin Clearing")
      (LDESC
"The house sits crookedly on a green lawn beside a sparkling brook, with
fruit trees and banks of flowers all around. The road of yellow brick
begins here and runs away to the west.")
      (WEST PER CLEARING-WEST)
      (IN TO FARMHOUSE)
      (ACTION CLEARING-FCN)
      (GLOBAL YELLOW-ROAD-LG)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM YELLOW-ROAD
      (IN ROOMS)
      (DESC "Road Of Yellow Brick")
      (LDESC
"Yellow bricks run straight and true between dainty blue fences, past
round blue houses with domed roofs. Munchkins bow to you from their
fields. The road runs on to the west; a blue fence borders a cornfield
to the south.")
      (EAST TO CLEARING)
      (SOUTH TO CORNFIELD)
      (WEST TO FOREST-ROAD)
      (ACTION YELLOW-ROAD-FCN)
      (GLOBAL YELLOW-ROAD-LG)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM CORNFIELD
      (IN ROOMS)
      (DESC "Cornfield")
      (LDESC
"Ripe corn stretches away beyond a blue fence. The road lies back to the
north.")
      (NORTH TO YELLOW-ROAD)
      (ACTION CORNFIELD-FCN)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM FOREST-ROAD
      (IN ROOMS)
      (DESC "Forest Road")
      (LDESC
"The bricks here are broken and full of holes, and great trees meet
overhead so that the road runs through a green twilight. The road goes
east and west; a footpath leads north toward a log cottage.")
      (EAST TO YELLOW-ROAD)
      (WEST TO BRAMBLE-ROAD)
      (NORTH TO WOODMAN-COTTAGE)
      (ACTION FOREST-ROAD-FCN)
      (GLOBAL YELLOW-ROAD-LG TREES-LG)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM WOODMAN-COTTAGE
      (IN ROOMS)
      (DESC "Log Cottage")
      (LDESC
"A snug cottage of logs and branches with a bed of dried leaves in one
corner. The forest road is back to the south, and among the trees to the
north you can hear water running.")
      (SOUTH TO FOREST-ROAD)
      (NORTH TO SPRING-GLADE)
      (ACTION COTTAGE-FCN)
      (GLOBAL TREES-LG)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM SPRING-GLADE
      (IN ROOMS)
      (DESC "Forest Spring")
      (LDESC
"A little spring rises clear and cold among the trees. The cottage lies
back to the south.")
      (SOUTH TO WOODMAN-COTTAGE)
      (ACTION GLADE-FCN)
      (GLOBAL TREES-LG)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM BRAMBLE-ROAD
      (IN ROOMS)
      (DESC "Choked Road")
      (LDESC
"Branches and whole trees have grown so thick across the road here that
not even Toto could squeeze through to the west. The clear road lies
back to the east.")
      (EAST TO FOREST-ROAD)
      (WEST PER BRAMBLE-WEST)
      (ACTION BRAMBLE-FCN)
      (GLOBAL YELLOW-ROAD-LG TREES-LG)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM DEEP-FOREST
      (IN ROOMS)
      (DESC "Deep Forest")
      (LDESC
"The forest is old and dark here, and the road of yellow brick picks its
way through, east to west.")
      (EAST TO BRAMBLE-ROAD)
      (WEST PER DEEP-WEST)
      (ACTION DEEP-FOREST-FCN)
      (GLOBAL YELLOW-ROAD-LG TREES-LG)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

"=== ACT II ROOMS ==="

<ROOM GORGE-EDGE
      (IN ROOMS)
      (DESC "Edge Of The Gorge")
      (LDESC
"The road ends at a gorge so wide and deep that the jagged rocks at the
bottom look like gray teeth. The far side, to the west, is a long, long
jump away. The forest lies back east.")
      (EAST TO DEEP-FOREST)
      (WEST PER GORGE-WEST)
      (ACTION GORGE-FCN)
      (GLOBAL GORGE-LG TREES-LG YELLOW-ROAD-LG)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM KALIDAH-WOOD
      (IN ROOMS)
      (DESC "Gloomy Wood")
      (LDESC
"The trees crowd close and dark, and strange heavy footfalls circle you
just out of sight. The gorge you leapt is behind you to the east; the
road struggles on west.")
      (EAST PER KWOOD-EAST)
      (WEST TO SECOND-GORGE)
      (ACTION KWOOD-FCN)
      (GLOBAL TREES-LG YELLOW-ROAD-LG)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM SECOND-GORGE
      (IN ROOMS)
      (DESC "Second Gorge")
      (LDESC
"This gulf is far too broad for any leap. One great tree stands right at
the edge, tall enough to reach the other side, if only it were lying
down. The gloomy wood is back east.")
      (EAST PER SGORGE-EAST)
      (WEST PER SGORGE-WEST)
      (ACTION SGORGE-FCN)
      (GLOBAL GORGE-LG TREES-LG)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM RIVERBANK
      (IN ROOMS)
      (DESC "Riverbank")
      (LDESC
"A broad river slides swiftly past, west across your way. On the far
side the road of yellow brick sets off again through meadows dotted with
bright flowers. Good straight trees stand near the bank.")
      (EAST
"The felled tree is gone into the gorge behind you; there is no going
back east now.")
      (WEST PER RIVER-WEST)
      (ACTION RIVERBANK-FCN)
      (GLOBAL RIVER-LG TREES-LG YELLOW-ROAD-LG RAFT)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM MIDRIVER
      (IN ROOMS)
      (DESC "Middle Of The River")
      (LDESC
"Water everywhere, moving faster than it looked from shore. The raft has
ideas of its own about where you are going.")
      (ACTION MIDRIVER-FCN)
      (GLOBAL RIVER-LG RAFT)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM FAR-BANK
      (IN ROOMS)
      (DESC "Grassy Bank")
      (LDESC
"Soft green grass, flowers, fruit trees, and no road anywhere. The river
has carried you a long way past the road of yellow brick. The bank runs
north, upriver.")
      (NORTH TO STORK-BEND)
      (SOUTH "The river bars the way south.")
      (EAST "The river bars the way east.")
      (WEST "Trackless meadows; better to follow the river north.")
      (ACTION FAR-BANK-FCN)
      (GLOBAL RIVER-LG TREES-LG)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM STORK-BEND
      (IN ROOMS)
      (DESC "Bend In The River")
      (LDESC
"From here you can see, far out in the water, a small blue-hatted figure
clinging to a pole. A stork stands in the shallows, resting. The bank
runs south; to the north a red haze of flowers begins.")
      (SOUTH TO FAR-BANK)
      (NORTH TO POPPY-FIELD)
      (ACTION STORK-BEND-FCN)
      (GLOBAL RIVER-LG)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM POPPY-FIELD
      (IN ROOMS)
      (DESC "Deadly Poppy Field")
      (LDESC
"Scarlet poppies crowd so thick and bright they dazzle the eyes, and
their spicy scent makes the whole world feel like a warm bed. Green
grass shows far to the north.")
      (SOUTH TO STORK-BEND)
      (NORTH PER POPPY-NORTH)
      (ACTION POPPY-FCN)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM GREEN-BANK
      (IN ROOMS)
      (DESC "Green Bank")
      (LDESC
"Fresh sweet grass beyond the last of the poppies. The road of yellow
brick shows again to the east, running through green country.")
      (EAST TO GREEN-ROAD)
      (WEST PER GREEN-BANK-WEST)
      (SOUTH PER GREEN-BANK-WEST)
      (ACTION GREEN-BANK-FCN)
      (GLOBAL YELLOW-ROAD-LG)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM GREEN-ROAD
      (IN ROOMS)
      (DESC "Green Country Road")
      (LDESC
"The road of yellow brick again, smooth and well paved, running east
between green fences and green farmhouses. A farmer's family watches you
pass. Mostly they watch the Lion.")
      (WEST TO GREEN-BANK)
      (EAST TO CITY-GATE)
      (ACTION GREEN-ROAD-FCN)
      (GLOBAL YELLOW-ROAD-LG)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM CITY-GATE
      (IN ROOMS)
      (DESC "Before The Gate")
      (LDESC
"A wall of green stone, high and thick, and in it a great gate studded
with emeralds that burn in the sun. Beside the gate is a button for a
bell.")
      (WEST PER CITY-GATE-WEST)
      (IN PER CITY-GATE-IN)
      (EAST PER CITY-GATE-IN)
      (ACTION CITY-GATE-FCN)
      (GLOBAL YELLOW-ROAD-LG)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM GATE-ROOM
      (IN ROOMS)
      (DESC "Arched Gate Room")
      (LDESC
"A high arched room whose walls glisten with countless emeralds. A
little green man stands by a big green box, jingling a small key on a
chain. The city is in through the inner gate; the country is out the
other way.")
      (OUT TO CITY-GATE)
      (WEST TO CITY-GATE)
      (IN PER GATE-ROOM-IN)
      (EAST PER GATE-ROOM-IN)
      (NORTH PER GATE-ROOM-IN)
      (ACTION GATE-ROOM-FCN)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM EMERALD-STREET
      (IN ROOMS)
      (DESC "Emerald City Street")
      (LDESC
"Green marble houses, green glass windows, green sky, green everything;
children with green skins buy green lemonade with green pennies. It is
either the most beautiful city in the world or the best pair of
spectacles. The palace lies north, the gate room south, and a great
plaza opens east.")
      (NORTH TO PALACE-COURT)
      (SOUTH TO GATE-ROOM)
      (EAST PER STREET-EAST)
      (ACTION STREET-FCN)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM PALACE-COURT
      (IN ROOMS)
      (DESC "Palace Of Oz")
      (LDESC
"A soldier with a long green beard guards the palace door, and a big
room with green furniture waits beyond it. Everyone here is very polite
and nobody has ever seen Oz. Your chamber is up the stairs; the throne
room is north; the street is south.")
      (UP TO GREEN-CHAMBER)
      (NORTH PER COURT-NORTH)
      (SOUTH TO EMERALD-STREET)
      (ACTION PALACE-COURT-FCN)
      (GLOBAL OZ-WIZARD)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM GREEN-CHAMBER
      (IN ROOMS)
      (DESC "Green Chamber")
      (LDESC
"The sweetest little room in the world: green silk sheets, a fountain
that sprays green perfume, and a shelf of little green books full of
queer pictures. Stairs lead down.")
      (DOWN TO PALACE-COURT)
      (ACTION CHAMBER-FCN)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM THRONE-ROOM
      (IN ROOMS)
      (DESC "Throne Room")
      (LDESC
"A big round room with a high arched roof, walls and floor crusted with
great emeralds, and a marble throne in the middle under a light as
bright as the sun. The doors are to the south.")
      (SOUTH TO PALACE-COURT)
      (EAST PER THRONE-EAST)
      (ACTION THRONE-FCN)
      (GLOBAL OZ-WIZARD SCREEN)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

"=== ACT III ROOMS ==="

<ROOM WEST-FIELDS
      (IN ROOMS)
      (DESC "Trackless Fields")
      (LDESC
"No road leads west, only soft grass, daisies, and buttercups, with the
sun hot in your faces. Far off, on a hill to the west, a yellow castle
keeps one window toward you like an eye. The city gate is back east.")
      (EAST TO CITY-GATE)
      (WEST PER WFIELDS-WEST)
      (ACTION WFIELDS-FCN)
      (GLOBAL CASTLE-LG HIS-STRAW)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM WEST-HILLS
      (IN ROOMS)
      (DESC "Rough Hills")
      (LDESC
"The ground is rougher and hillier here, and there are no trees and no
shade. The castle is close now, and something in the air is chattering.
The fields are back east.")
      (EAST TO WEST-FIELDS)
      (WEST PER WHILLS-WEST)
      (ACTION WHILLS-FCN)
      (GLOBAL CASTLE-LG HIS-STRAW)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM CASTLE-KITCHEN
      (IN ROOMS)
      (DESC "Castle Kitchen")
      (LDESC
"A great sooty kitchen of yellow stone: a hearth with a wood fire, black
pots and kettles, a broom, and a wooden bucket of well water standing by
the door. The hall is north.")
      (NORTH TO CASTLE-HALL)
      (ACTION KITCHEN-FCN)
      (GLOBAL CASTLE-LG WATER WOOD-W)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM CASTLE-HALL
      (IN ROOMS)
      (DESC "Castle Hall")
      (LDESC
"A long hall hung with yellow banners. The kitchen is south, the
courtyard east, and a narrow stair climbs up under the roof.")
      (SOUTH TO CASTLE-KITCHEN)
      (EAST TO COURTYARD)
      (UP TO GARRET)
      (WEST PER HALL-WEST)
      (OUT PER HALL-OUT)
      (NORTH PER HALL-OUT)
      (ACTION HALL-FCN)
      (GLOBAL CASTLE-LG)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM COURTYARD
      (IN ROOMS)
      (DESC "Castle Courtyard")
      (LDESC
"A small yard closed in by a high iron fence, with a pile of clean straw
in one corner. The hall is back west.")
      (WEST TO CASTLE-HALL)
      (ACTION COURTYARD-FCN)
      (GLOBAL CASTLE-LG)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM GARRET
      (IN ROOMS)
      (DESC "Cold Garret")
      (LDESC
"A narrow bed under the castle roof. From the little window, all the
Winkie country lies yellow below. The stair goes down.")
      (DOWN TO CASTLE-HALL)
      (ACTION GARRET-FCN)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM ROCKY-PLAIN
      (IN ROOMS)
      (DESC "Rocky Plain")
      (LDESC
"A country thickly covered with sharp rocks, west of the castle. One
tree, far to the north, stands taller than all the rest.")
      (EAST TO CASTLE-HALL)
      (NORTH PER PLAIN-NORTH)
      (ACTION PLAIN-FCN)
      (GLOBAL CASTLE-LG)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM TALL-TREE
      (IN ROOMS)
      (DESC "Foot Of A Tall Tree")
      (LDESC
"One tree stands taller than all the rest, its trunk too smooth to
climb. The rocky plain is back south.")
      (SOUTH TO ROCKY-PLAIN)
      (ACTION TALL-TREE-FCN)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM LOST-FIELDS
      (IN ROOMS)
      (DESC "Endless Yellow Fields")
      (LDESC
"Buttercups and daisies in every direction, and no road, and no shadow
to say which way is east.")
      (NORTH PER LOST-EXIT)
      (SOUTH PER LOST-EXIT)
      (EAST PER LOST-EXIT)
      (WEST PER LOST-EXIT)
      (NE PER LOST-EXIT)
      (NW PER LOST-EXIT)
      (SE PER LOST-EXIT)
      (SW PER LOST-EXIT)
      (ACTION LOST-FCN)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

"=== ACT IV ROOMS ==="

<ROOM WORKSHOP
      (IN ROOMS)
      (DESC "Little Room Behind The Throne")
      (LDESC
"A cluttered chamber of wonders: a great papier-mache head in a corner,
a gauzy dress and mask on a hook, a bundle of sewn skins, and a ball of
cotton on a wire. The throne room is west.")
      (WEST TO THRONE-ROOM)
      (ACTION WORKSHOP-FCN)
      (GLOBAL OZ-WIZARD)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM BALLOON-PLAZA
      (IN ROOMS)
      (DESC "Plaza Before The Palace")
      (LDESC
"A great open plaza of green marble east of the palace street. The road
south leaves the city toward the country of the Quadlings.")
      (WEST TO EMERALD-STREET)
      (SOUTH PER PLAZA-SOUTH)
      (ACTION PLAZA-FCN)
      (GLOBAL OZ-WIZARD BALLOON CROWD KITTEN)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM FIGHTING-TREES
      (IN ROOMS)
      (DESC "Edge Of A Thick Wood")
      (LDESC
"The first row of trees stands shoulder to shoulder like a fence of
policemen across the way south. As you watch, one of them flexes its
branches. At you. The city lies back north.")
      (NORTH TO BALLOON-PLAZA)
      (SOUTH PER FTREES-SOUTH)
      (ACTION FTREES-FCN)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM CHINA-WALL
      (IN ROOMS)
      (DESC "Foot Of A White Wall")
      (LDESC
"A wall higher than your head and smooth as the inside of a dish, made,
as far as you can tell, of white china. It runs left and right as far as
sight, barring the way south. The wood is back north.")
      (NORTH TO FIGHTING-TREES)
      (SOUTH PER CWALL-SOUTH)
      (UP PER CWALL-UP)
      (ACTION CWALL-FCN)
      (GLOBAL LADDER WALL)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM CHINA-COUNTRY
      (IN ROOMS)
      (DESC "Dainty China Country")
      (LDESC
"A floor as smooth and shining as a big platter, set with china houses
no taller than your waist, china barns, china cows, and little china
people, none higher than your knee, going carefully about their tiny
lives. A lower wall closes the country to the south.")
      (NORTH "The great wall is behind you now, and it has no ladder on this side.")
      (SOUTH PER CHINA-SOUTH)
      (ACTION CHINA-FCN)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM QUADLING-FOREST
      (IN ROOMS)
      (DESC "Grand Old Forest")
      (LDESC
"The oldest, mossiest forest you have ever seen. The way runs south,
downhill out of the trees.")
      (NORTH "The china wall closes the country behind you.")
      (SOUTH TO HAMMER-HILL)
      (ACTION QFOREST-FCN)
      (GLOBAL TREES-LG)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM HAMMER-HILL
      (IN ROOMS)
      (DESC "Rocky Hill")
      (LDESC
"A steep hill covered with great rocks bars the way south, and from
behind every rock a flat-topped head on a wrinkled neck is watching you.
A rough voice says: \"Keep back!\"")
      (NORTH TO QUADLING-FOREST)
      (SOUTH PER HH-SOUTH)
      (UP PER HH-SOUTH)
      (ACTION HH-FCN)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM QUADLING-FARM
      (IN ROOMS)
      (DESC "Quadling Country")
      (LDESC
"Fields of ripening grain, red fences, red farmhouses, and short, fat,
cheerful people dressed all in red. Glinda's castle shines to the
south.")
      (SOUTH TO GLINDA-THRONE)
      (NORTH "The hill of the Hammer-Heads bars the way north, and once was enough.")
      (ACTION FARM-FCN)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM GLINDA-THRONE
      (IN ROOMS)
      (DESC "Glinda's Castle")
      (LDESC
"A throne room the color of sunrise. On a throne of rubies sits a witch
young and beautiful, with red hair and kind blue eyes, and three girl
soldiers by the door try not to stare at the Lion.")
      (NORTH TO QUADLING-FARM)
      (ACTION GLINDA-FCN)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<ROOM KANSAS-PRAIRIE
      (IN ROOMS)
      (DESC "Kansas Prairie")
      (LDESC
"Flat gray prairie under a wide sky, and there, brand new against it, a
little farmhouse.")
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

"=== ACT I OBJECTS ==="

<OBJECT TOTO
	(IN FARMHOUSE)
	(SYNONYM TOTO DOG)
	(ADJECTIVE SMALL BLACK LITTLE)
	(DESC "Toto")
	(FLAGS ACTORBIT TRYTAKEBIT)
	(DESCFCN TOTO-DESCFCN)
	(ACTION TOTO-FCN)>

<OBJECT FARM-BED
	(IN FARMHOUSE)
	(SYNONYM BED BEDS)
	(ADJECTIVE BIG LITTLE)
	(DESC "bed")
	(FLAGS NDESCBIT)
	(ACTION FARM-BED-FCN)>

<OBJECT TRAP-DOOR
	(IN FARMHOUSE)
	(SYNONYM TRAPDOOR DOOR RING)
	(ADJECTIVE TRAP)
	(DESC "trap door")
	(FLAGS NDESCBIT DOORBIT)
	(ACTION TRAP-DOOR-FCN)>

<OBJECT KANSAS-CUPBOARD
	(IN FARMHOUSE)
	(SYNONYM CUPBOARD)
	(DESC "cupboard")
	(FLAGS NDESCBIT CONTBIT)
	(CAPACITY 20)
	(ACTION KANSAS-CUPBOARD-FCN)>

<OBJECT BREAD
	(IN KANSAS-CUPBOARD)
	(SYNONYM BREAD LOAF FOOD)
	(DESC "loaf of bread")
	(FLAGS TAKEBIT FOODBIT)
	(SIZE 2)
	(ACTION BREAD-FCN)>

<OBJECT BASKET
	(IN FARMHOUSE)
	(SYNONYM BASKET)
	(ADJECTIVE LITTLE)
	(DESC "little basket")
	(FLAGS TAKEBIT CONTBIT OPENBIT)
	(CAPACITY 20)
	(SIZE 4)
	(ACTION BASKET-FCN)>

<OBJECT COOKSTOVE
	(IN FARMHOUSE)
	(SYNONYM COOKSTOVE STOVE TABLE CHAIRS)
	(ADJECTIVE RUSTY)
	(DESC "rusty cookstove")
	(FLAGS NDESCBIT)
	(ACTION COOKSTOVE-FCN)>

<OBJECT WITCH-NORTH
	(SYNONYM WITCH WOMAN)
	(ADJECTIVE NORTH LITTLE OLD)
	(DESC "Witch of the North")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION WITCH-NORTH-FCN)>

<OBJECT MUNCHKINS
	(SYNONYM MUNCHKINS MUNCHKIN MEN)
	(ADJECTIVE BLUE)
	(DESC "three Munchkins")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION MUNCHKINS-FCN)>

<OBJECT DEAD-FEET
	(SYNONYM FEET FOOT)
	(ADJECTIVE TWO SILVER)
	(DESC "two feet in silver shoes")
	(FLAGS NDESCBIT)
	(ACTION DEAD-FEET-FCN)>

<OBJECT BROOK
	(IN CLEARING)
	(SYNONYM BROOK STREAM)
	(ADJECTIVE SPARKLING)
	(DESC "sparkling brook")
	(FLAGS NDESCBIT)
	(ACTION BROOK-FCN)>

<OBJECT SILVER-SHOES
	(SYNONYM SHOES HEELS HEEL PAIR)
	(ADJECTIVE SILVER POINTED)
	(DESC "silver shoes")
	(FLAGS TAKEBIT WEARBIT)
	(SIZE 2)
	(ACTION SILVER-SHOES-FCN)>

<OBJECT BOQ
	(IN YELLOW-ROAD)
	(SYNONYM BOQ MUNCHKIN FARMER)
	(ADJECTIVE RICH)
	(DESC "rich Munchkin")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION BOQ-FCN)>

<OBJECT SCARECROW
	(IN CORNFIELD)
	(SYNONYM SCARECROW)
	(ADJECTIVE STUFFED BLUE)
	(DESC "Scarecrow")
	(FLAGS ACTORBIT TRYTAKEBIT)
	(DESCFCN SCARECROW-DESCFCN)
	(ACTION SCARECROW-FCN)>

<OBJECT POLE
	(IN CORNFIELD)
	(SYNONYM POLE)
	(DESC "pole")
	(FLAGS NDESCBIT)
	(ACTION POLE-FCN)>

<OBJECT CORN
	(IN CORNFIELD)
	(SYNONYM CORN EARS)
	(ADJECTIVE RIPE)
	(DESC "ripe corn")
	(FLAGS NDESCBIT)
	(ACTION CORN-FCN)>

<OBJECT OIL-CAN
	(IN WOODMAN-COTTAGE)
	(SYNONYM OILCAN CAN)
	(ADJECTIVE BATTERED TIN JEWELED)
	(DESC "battered oil-can")
	(FDESC "On a shelf sits a battered oil-can.")
	(FLAGS TAKEBIT)
	(SIZE 2)
	(ACTION OIL-CAN-FCN)>

<OBJECT LEAF-BED
	(IN WOODMAN-COTTAGE)
	(SYNONYM BED LEAVES)
	(ADJECTIVE LEAF DRIED)
	(DESC "bed of dried leaves")
	(FLAGS NDESCBIT)
	(ACTION LEAF-BED-FCN)>

<OBJECT WOODMAN
	(IN SPRING-GLADE)
	(SYNONYM WOODMAN JOINTS JAWS NECK ARMS LEGS NICK)
	(ADJECTIVE TIN)
	(DESC "Tin Woodman")
	(FLAGS ACTORBIT TRYTAKEBIT)
	(DESCFCN WOODMAN-DESCFCN)
	(ACTION WOODMAN-FCN)>

<OBJECT AXE
	(IN WOODMAN)
	(SYNONYM AXE)
	(ADJECTIVE SHARP GLEAMING)
	(DESC "axe")
	(FLAGS NDESCBIT TRYTAKEBIT)
	(ACTION AXE-FCN)>

<OBJECT SPRING
	(IN SPRING-GLADE)
	(SYNONYM SPRING WATER POOL)
	(ADJECTIVE CLEAR COLD)
	(DESC "clear spring")
	(FLAGS NDESCBIT DRINKBIT)
	(ACTION SPRING-FCN)>

<OBJECT HALF-TREE
	(IN SPRING-GLADE)
	(SYNONYM TREE)
	(ADJECTIVE HALF-CHOPPED CHOPPED)
	(DESC "half-chopped tree")
	(FLAGS NDESCBIT)
	(ACTION HALF-TREE-FCN)>

<OBJECT BRAMBLES
	(IN BRAMBLE-ROAD)
	(SYNONYM BRANCHES BRAMBLES TREES BRANCH THICKET)
	(ADJECTIVE THICK WOVEN)
	(DESC "woven branches")
	(FLAGS NDESCBIT)
	(ACTION BRAMBLES-FCN)>

<OBJECT LION
	(SYNONYM LION BEAST MANE)
	(ADJECTIVE COWARDLY GREAT BIG)
	(DESC "Lion")
	(FLAGS ACTORBIT TRYTAKEBIT)
	(DESCFCN LION-DESCFCN)
	(ACTION LION-FCN)>

"=== ACT II OBJECTS ==="

<OBJECT BEETLE
	(SYNONYM BEETLE BUG)
	(ADJECTIVE SMALL)
	(DESC "small beetle")
	(FLAGS NDESCBIT)
	(ACTION BEETLE-FCN)>

<OBJECT KALIDAHS
	(SYNONYM KALIDAHS KALIDAH FOOTFALLS)
	(ADJECTIVE MONSTROUS)
	(DESC "Kalidahs")
	(FLAGS NDESCBIT ACTORBIT)
	(ACTION KALIDAHS-FCN)>

<OBJECT BRIDGE-TREE
	(IN SECOND-GORGE)
	(SYNONYM TREE BRIDGE TRUNK END)
	(ADJECTIVE GREAT TALL FELLED)
	(DESC "great tree")
	(FLAGS NDESCBIT)
	(ACTION BRIDGE-TREE-FCN)>

<OBJECT RAFT
	(IN LOCAL-GLOBALS)
	(SYNONYM RAFT LOGS)
	(ADJECTIVE LOG WOODEN)
	(DESC "log raft")
	(FLAGS NDESCBIT)
	(ACTION RAFT-FCN)>

<OBJECT STORK
	(IN STORK-BEND)
	(SYNONYM STORK BIRD)
	(ADJECTIVE GREAT WHITE)
	(DESC "stork")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION STORK-FCN)>

<OBJECT POPPIES
	(IN POPPY-FIELD)
	(SYNONYM POPPIES POPPY FLOWERS SCENT)
	(ADJECTIVE SCARLET BRIGHT SPICY)
	(DESC "scarlet poppies")
	(FLAGS NDESCBIT)
	(ACTION POPPIES-FCN)>

<OBJECT WILDCAT
	(SYNONYM WILDCAT CAT)
	(ADJECTIVE YELLOW GREAT)
	(DESC "Wildcat")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION WILDCAT-FCN)>

<OBJECT MOUSE-QUEEN
	(SYNONYM QUEEN MOUSE MICE)
	(ADJECTIVE GRAY LITTLE FIELD)
	(DESC "Queen of the Field Mice")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION QUEEN-FCN)>

<OBJECT MOUSE-WHISTLE
	(SYNONYM WHISTLE)
	(ADJECTIVE LITTLE MOUSE)
	(DESC "little whistle")
	(FLAGS TAKEBIT WEARBIT)
	(SIZE 1)
	(ACTION WHISTLE-FCN)>

<OBJECT FARMFOLK
	(IN GREEN-ROAD)
	(SYNONYM FAMILY FARMER MAN PEOPLE)
	(ADJECTIVE GREEN)
	(DESC "farmer's family")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION FARMFOLK-FCN)>

<OBJECT GATE-BUTTON
	(IN CITY-GATE)
	(SYNONYM BUTTON BELL)
	(DESC "button")
	(FLAGS NDESCBIT)
	(ACTION GATE-BUTTON-FCN)>

<OBJECT EMERALD-GATE
	(IN CITY-GATE)
	(SYNONYM GATE)
	(ADJECTIVE GREAT GREEN EMERALD)
	(DESC "great gate")
	(FLAGS NDESCBIT DOORBIT)
	(ACTION EMERALD-GATE-FCN)>

<OBJECT GUARDIAN
	(IN GATE-ROOM)
	(SYNONYM GUARDIAN MAN)
	(ADJECTIVE GREEN LITTLE)
	(DESC "Guardian of the Gates")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION GUARDIAN-FCN)>

<OBJECT GREEN-BOX
	(IN GATE-ROOM)
	(SYNONYM BOX KEY)
	(ADJECTIVE BIG GREEN)
	(DESC "big green box")
	(FLAGS NDESCBIT)
	(ACTION GREEN-BOX-FCN)>

<OBJECT SPECTACLES
	(IN GATE-ROOM)
	(SYNONYM SPECTACLES GLASSES)
	(ADJECTIVE GREEN)
	(DESC "green spectacles")
	(FLAGS TAKEBIT WEARBIT INVISIBLE)
	(SIZE 1)
	(ACTION SPECTACLES-FCN)>

<OBJECT CITYFOLK
	(IN EMERALD-STREET)
	(SYNONYM PEOPLE CHILDREN LEMONADE)
	(ADJECTIVE GREEN)
	(DESC "green-skinned people")
	(FLAGS NDESCBIT)
	(ACTION CITYFOLK-FCN)>

<OBJECT SOLDIER
	(IN PALACE-COURT)
	(SYNONYM SOLDIER BEARD WHISKERS)
	(ADJECTIVE GREEN)
	(DESC "soldier with the green whiskers")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION SOLDIER-FCN)>

<OBJECT GREEN-GIRL
	(IN PALACE-COURT)
	(SYNONYM GIRL MAID)
	(ADJECTIVE GREEN PRETTY)
	(DESC "green girl")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION GREEN-GIRL-FCN)>

<OBJECT GREEN-BED
	(IN GREEN-CHAMBER)
	(SYNONYM BED SHEETS FOUNTAIN BOOKS)
	(ADJECTIVE GREEN SILK)
	(DESC "green silk bed")
	(FLAGS NDESCBIT)
	(ACTION GREEN-BED-FCN)>

<OBJECT THRONE
	(IN THRONE-ROOM)
	(SYNONYM THRONE)
	(ADJECTIVE MARBLE BIG)
	(DESC "marble throne")
	(FLAGS NDESCBIT)
	(ACTION THRONE-OBJ-FCN)>

<OBJECT OZ-WIZARD
	(IN LOCAL-GLOBALS)
	(SYNONYM OZ WIZARD LADY VOICE HUMBUG)
	(ADJECTIVE GREAT TERRIBLE LITTLE OLD BALD)
	(DESC "Wizard of Oz")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION OZ-FCN)>

<OBJECT SCREEN
	(IN LOCAL-GLOBALS)
	(SYNONYM SCREEN CORNER)
	(ADJECTIVE GREEN TALL)
	(DESC "tall screen")
	(FLAGS NDESCBIT)
	(ACTION SCREEN-FCN)>

"=== ACT III OBJECTS ==="

<OBJECT WOLVES
	(SYNONYM WOLVES WOLF PACK)
	(ADJECTIVE GREAT GRAY FORTY)
	(DESC "pack of wolves")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION WOLVES-FCN)>

<OBJECT CROWS
	(SYNONYM CROWS CROW FLOCK)
	(ADJECTIVE WILD BLACK FORTY)
	(DESC "flock of wild crows")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION CROWS-FCN)>

<OBJECT BEES
	(SYNONYM BEES BEE SWARM)
	(ADJECTIVE BLACK)
	(DESC "swarm of black bees")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION BEES-FCN)>

<OBJECT HIS-STRAW
	(IN LOCAL-GLOBALS)
	(SYNONYM STRAW)
	(DESC "straw")
	(FLAGS NDESCBIT TRYTAKEBIT)
	(ACTION HIS-STRAW-FCN)>

<OBJECT WINKIES
	(SYNONYM WINKIES WINKIE SPEARMEN FOREMAN TINSMITHS)
	(ADJECTIVE YELLOW)
	(DESC "Winkies")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION WINKIES-FCN)>

<OBJECT MONKEY-KING
	(SYNONYM MONKEYS MONKEY KING WINGS)
	(ADJECTIVE WINGED)
	(DESC "King of the Winged Monkeys")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION MONKEY-KING-FCN)>

<OBJECT WITCH-WEST
	(SYNONYM WITCH EYE UMBRELLA)
	(ADJECTIVE WICKED WEST ONE-EYED OLD)
	(DESC "Wicked Witch of the West")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION WITCH-WEST-FCN)>

<OBJECT HEARTH-FIRE
	(IN CASTLE-KITCHEN)
	(SYNONYM FIRE HEARTH)
	(ADJECTIVE WOOD)
	(DESC "hearth fire")
	(FLAGS NDESCBIT)
	(ACTION HEARTH-FIRE-FCN)>

<OBJECT KITCHEN-POTS
	(IN CASTLE-KITCHEN)
	(SYNONYM POTS KETTLES POT KETTLE)
	(ADJECTIVE BLACK)
	(DESC "black pots and kettles")
	(FLAGS NDESCBIT)
	(ACTION KITCHEN-POTS-FCN)>

<OBJECT BROOM
	(IN CASTLE-KITCHEN)
	(SYNONYM BROOM)
	(DESC "broom")
	(FLAGS TAKEBIT NDESCBIT)
	(SIZE 3)
	(ACTION BROOM-FCN)>

<OBJECT FIREWOOD
	(IN CASTLE-KITCHEN)
	(SYNONYM FIREWOOD)
	(DESC "firewood")
	(FLAGS TAKEBIT NDESCBIT)
	(SIZE 4)
	(ACTION FIREWOOD-FCN)>

<OBJECT BUCKET
	(IN CASTLE-KITCHEN)
	(SYNONYM BUCKET PAIL)
	(ADJECTIVE WOODEN WELL)
	(DESC "wooden bucket")
	(FLAGS TAKEBIT CONTBIT OPENBIT)
	(CAPACITY 10)
	(SIZE 6)
	(ACTION BUCKET-FCN)>

<OBJECT WITCH-CUPBOARD
	(IN CASTLE-KITCHEN)
	(SYNONYM CUPBOARD)
	(ADJECTIVE WITCH)
	(DESC "cupboard")
	(FLAGS NDESCBIT CONTBIT)
	(CAPACITY 30)
	(ACTION WITCH-CUPBOARD-FCN)>

<OBJECT MEAT
	(IN WITCH-CUPBOARD)
	(SYNONYM MEAT SUPPER)
	(ADJECTIVE COLD)
	(DESC "cold meat")
	(FLAGS TAKEBIT FOODBIT)
	(SIZE 3)
	(ACTION MEAT-FCN)>

<OBJECT GOLDEN-CAP
	(IN WITCH-CUPBOARD)
	(SYNONYM CAP CHARM LINING)
	(ADJECTIVE GOLDEN GOLD)
	(DESC "Golden Cap")
	(FLAGS TAKEBIT WEARBIT READBIT INVISIBLE)
	(SIZE 2)
	(ACTION GOLDEN-CAP-FCN)>

<OBJECT IRON-BAR
	(IN CASTLE-KITCHEN)
	(SYNONYM BAR)
	(ADJECTIVE IRON INVISIBLE)
	(DESC "iron bar")
	(FLAGS NDESCBIT INVISIBLE)>

<OBJECT WITCH-MESS
	(SYNONYM MESS PUDDLE SUGAR)
	(ADJECTIVE BROWN MELTED)
	(DESC "brown, spreading mess")
	(FLAGS NDESCBIT)
	(ACTION WITCH-MESS-FCN)>

<OBJECT STOLEN-SHOE
	(SYNONYM SHOE)
	(ADJECTIVE SILVER STOLEN WET LEFT)
	(DESC "silver shoe")
	(FLAGS TAKEBIT)
	(SIZE 1)
	(ACTION STOLEN-SHOE-FCN)>

<OBJECT IRON-GATE
	(IN COURTYARD)
	(SYNONYM GATE FENCE BARS)
	(ADJECTIVE IRON HIGH)
	(DESC "iron gate")
	(FLAGS NDESCBIT DOORBIT)
	(ACTION IRON-GATE-FCN)>

<OBJECT STRAW-PILE
	(IN COURTYARD)
	(SYNONYM STRAW PILE)
	(ADJECTIVE CLEAN)
	(DESC "pile of clean straw")
	(FLAGS NDESCBIT TRYTAKEBIT)
	(ACTION STRAW-PILE-FCN)>

<OBJECT GARRET-BED
	(IN GARRET)
	(SYNONYM BED COT WINDOW)
	(ADJECTIVE NARROW)
	(DESC "narrow bed")
	(FLAGS NDESCBIT)
	(ACTION GARRET-BED-FCN)>

<OBJECT SHARP-ROCKS
	(IN ROCKY-PLAIN)
	(SYNONYM ROCKS ROCK)
	(ADJECTIVE SHARP)
	(DESC "sharp rocks")
	(FLAGS NDESCBIT)>

<OBJECT TALL-TREE-OBJ
	(IN TALL-TREE)
	(SYNONYM TREE TRUNK BRANCHES)
	(ADJECTIVE TALL SMOOTH)
	(DESC "tall tree")
	(FLAGS NDESCBIT)
	(ACTION TALL-TREE-OBJ-FCN)>

<OBJECT CLOTHES
	(SYNONYM CLOTHES BUNDLE SCARECROW HAT)
	(ADJECTIVE BLUE POINTED)
	(DESC "bundle of blue clothes")
	(FLAGS TAKEBIT)
	(SIZE 3)
	(ACTION CLOTHES-FCN)>

<OBJECT BUTTERCUPS
	(IN LOST-FIELDS)
	(SYNONYM BUTTERCUP DAISIES FLOWERS DAISY)
	(ADJECTIVE YELLOW)
	(DESC "buttercups and daisies")
	(FLAGS NDESCBIT)
	(ACTION BUTTERCUPS-FCN)>

<OBJECT BRACELET
	(SYNONYM BRACELET)
	(ADJECTIVE DIAMOND)
	(DESC "diamond bracelet")
	(FLAGS TAKEBIT WEARBIT)
	(SIZE 1)
	(ACTION BRACELET-FCN)>

"=== ACT IV OBJECTS ==="

<OBJECT PROP-HEAD
	(IN WORKSHOP)
	(SYNONYM HEAD)
	(ADJECTIVE GREAT PAPER)
	(DESC "great papier-mache head")
	(FLAGS NDESCBIT)
	(ACTION PROP-HEAD-FCN)>

<OBJECT PROP-MASK
	(IN WORKSHOP)
	(SYNONYM MASK DRESS GAUZE HOOK)
	(ADJECTIVE GAUZY LOVELY)
	(DESC "gauzy dress and mask")
	(FLAGS NDESCBIT)
	(ACTION PROP-MASK-FCN)>

<OBJECT PROP-SKINS
	(IN WORKSHOP)
	(SYNONYM SKINS BEAST SLATS)
	(ADJECTIVE SEWN)
	(DESC "bundle of sewn skins")
	(FLAGS NDESCBIT)
	(ACTION PROP-SKINS-FCN)>

<OBJECT PROP-COTTON
	(IN WORKSHOP)
	(SYNONYM BALL COTTON WIRE)
	(ADJECTIVE COTTON)
	(DESC "ball of cotton")
	(FLAGS NDESCBIT)
	(ACTION PROP-COTTON-FCN)>

<OBJECT BALLOON
	(IN LOCAL-GLOBALS)
	(SYNONYM BALLOON BAG SILK ROPE ROPES)
	(ADJECTIVE GREEN GREAT)
	(DESC "great green balloon")
	(FLAGS NDESCBIT)
	(ACTION BALLOON-FCN)>

<OBJECT CROWD
	(IN LOCAL-GLOBALS)
	(SYNONYM CROWD PEOPLE)
	(DESC "crowd")
	(FLAGS NDESCBIT)
	(ACTION CROWD-FCN)>

<OBJECT KITTEN
	(IN LOCAL-GLOBALS)
	(SYNONYM KITTEN)
	(DESC "kitten")
	(FLAGS NDESCBIT)
	(ACTION KITTEN-FCN)>

<OBJECT FIGHT-TREE
	(IN FIGHTING-TREES)
	(SYNONYM TREE TREES BRANCH BRANCHES)
	(ADJECTIVE FIGHTING FIRST BIG)
	(DESC "fighting tree")
	(FLAGS NDESCBIT)
	(ACTION FIGHT-TREE-FCN)>

<OBJECT LADDER
	(IN LOCAL-GLOBALS)
	(SYNONYM LADDER)
	(ADJECTIVE WOODEN)
	(DESC "wooden ladder")
	(FLAGS NDESCBIT CLIMBBIT)
	(ACTION LADDER-FCN)>

<OBJECT MILKMAID
	(IN CHINA-COUNTRY)
	(SYNONYM MILKMAID MAID)
	(ADJECTIVE CHINA PRETTY)
	(DESC "china milkmaid")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION MILKMAID-FCN)>

<OBJECT CHINA-COW
	(IN CHINA-COUNTRY)
	(SYNONYM COW)
	(ADJECTIVE CHINA)
	(DESC "china cow")
	(FLAGS NDESCBIT)
	(ACTION CHINA-COW-FCN)>

<OBJECT COW-LEG
	(SYNONYM LEG)
	(ADJECTIVE COW BROKEN CHINA)
	(DESC "china cow's leg")
	(FLAGS TAKEBIT INVISIBLE)
	(SIZE 1)
	(ACTION COW-LEG-FCN)>

<OBJECT PRINCESS
	(IN CHINA-COUNTRY)
	(SYNONYM PRINCESS)
	(ADJECTIVE CHINA BEAUTIFUL)
	(DESC "china Princess")
	(FLAGS ACTORBIT TRYTAKEBIT NDESCBIT)
	(ACTION PRINCESS-FCN)>

<OBJECT JOKER
	(IN CHINA-COUNTRY)
	(SYNONYM JOKER CLOWN)
	(ADJECTIVE MENDED FUNNY)
	(DESC "Mr. Joker")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION JOKER-FCN)>

<OBJECT CHINA-CHURCH
	(IN CHINA-COUNTRY)
	(SYNONYM CHURCH)
	(ADJECTIVE CHINA LITTLE)
	(DESC "china church")
	(FLAGS NDESCBIT)
	(ACTION CHINA-CHURCH-FCN)>

<OBJECT BEASTS
	(IN QUADLING-FOREST)
	(SYNONYM BEASTS ANIMALS TIGER BEARS)
	(ADJECTIVE ASSEMBLED)
	(DESC "assembly of beasts")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION BEASTS-FCN)>

<OBJECT SPIDER
	(IN QUADLING-FOREST)
	(SYNONYM SPIDER MONSTER ENEMY)
	(ADJECTIVE GREAT TREMENDOUS)
	(DESC "great spider")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION SPIDER-FCN)>

<OBJECT HAMMER-HEADS
	(IN HAMMER-HILL)
	(SYNONYM HEADS NECKS)
	(ADJECTIVE HAMMER FLAT ARMLESS)
	(DESC "Hammer-Heads")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION HAMMER-HEADS-FCN)>

<OBJECT HILL
	(IN HAMMER-HILL)
	(SYNONYM HILL ROCKS)
	(ADJECTIVE STEEP ROCKY)
	(DESC "steep hill")
	(FLAGS NDESCBIT)
	(ACTION HILL-FCN)>

<OBJECT FARMWIFE
	(IN QUADLING-FARM)
	(SYNONYM WIFE WOMAN QUADLINGS CAKE COOKIES)
	(ADJECTIVE RED CHEERFUL)
	(DESC "farmer's wife")
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION FARMWIFE-FCN)>

<OBJECT GLINDA
	(SYNONYM GLINDA SORCERESS)
	(ADJECTIVE GOOD RED YOUNG BEAUTIFUL)
	(DESC "Glinda")
	(IN GLINDA-THRONE)
	(FLAGS ACTORBIT NDESCBIT)
	(ACTION GLINDA-OBJ-FCN)>

<OBJECT RUBY-THRONE
	(IN GLINDA-THRONE)
	(SYNONYM THRONE RUBIES)
	(ADJECTIVE RUBY)
	(DESC "throne of rubies")
	(FLAGS NDESCBIT)>

<OBJECT GIRL-SOLDIERS
	(IN GLINDA-THRONE)
	(SYNONYM SOLDIERS GIRLS)
	(ADJECTIVE THREE GIRL)
	(DESC "three girl soldiers")
	(FLAGS NDESCBIT)
	(ACTION GIRL-SOLDIERS-FCN)>

<OBJECT AUNT-EM
	(IN KANSAS-PRAIRIE)
	(SYNONYM EM AUNT CABBAGES)
	(DESC "Aunt Em")
	(FLAGS ACTORBIT NDESCBIT)>

"=== GO and engine stubs ==="

<ROUTINE GO ()
	<SETG HERE ,FARMHOUSE>
	<SETG LIT T>
	<SETG WINNER ,ADVENTURER>
	<SETG PLAYER ,WINNER>
	<SETG VERBOSE T>
	<MOVE ,WINNER ,HERE>
	<INTRO-TEXT>
	<V-LOOK>
	<ENABLE <QUEUE I-OZ -1>>
	<MAIN-LOOP>
	<AGAIN>>

"Stub objects the generic engine verbs reference."

<OBJECT WATER
	(IN LOCAL-GLOBALS)
	(SYNONYM WATER)
	(ADJECTIVE WELL)
	(DESC "well water")
	(FLAGS TRYTAKEBIT TAKEBIT DRINKBIT)
	(SIZE 1)
	(ACTION WATER-FCN)>

<OBJECT GLOBAL-WATER
	(IN GLOBAL-OBJECTS)
	(SYNONYM WATER)
	(ADJECTIVE GLOBAL)
	(DESC "water")
	(FLAGS DRINKBIT)>

<OBJECT WALL
	(IN GLOBAL-OBJECTS)
	(SYNONYM WALL WALLS)
	(DESC "wall")
	(ACTION WALL-FCN)>

<PROPDEF TEXT 0>

"Unreachable stub rooms for generic engine verb branches."

<ROOM ON-LAKE (IN ROOMS) (DESC "On the Lake") (FLAGS RLANDBIT)>
<ROOM IN-LAKE (IN ROOMS) (DESC "In the Lake") (FLAGS RLANDBIT)>

"Unplaced stub carrying engine-referenced flags no real object uses."

<OBJECT FLAG-CARRIER
	(DESC "flag carrier")
	(FLAGS NONLANDBIT)>
