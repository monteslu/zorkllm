# DESIGN — THE SILVER SHOES
### A text adventure of The Wonderful Wizard of Oz (Baum, 1900), for the zorkllm engine

Source of truth: `book.txt` + `STUDY.md` in this directory. Book-only:
SILVER shoes, one-eyed water-fearing Witch with an umbrella, locked-on green
spectacles, the Golden Cap's three commands, the Deadly Poppy Field, the
china country, the Hammer-Heads. No film material anywhere (see STUDY.md
section 8 for the trap list).

Target: czil compiler + Zork I engine files (`zil/zork1`), per AUTHORING.md.
Player character: Dorothy. Constant companion: Toto (automatic). Recruited
companions: Scarecrow, Tin Woodman, Cowardly Lion — the heart of the game.

---

## 1. Vision & tone

The player fantasy: you are a small, sensible person leading a found family
of gentle misfits through a storybook country, and every one of your friends
is secretly already the thing they think they lack. The game's engine of fun
is the companion trio as a living toolkit — the Scarecrow plans, the Woodman
chops and builds, the Lion leaps and roars — plus Toto as a chaos gremlin
who eventually saves the day by knocking over a screen.

Tone: Baum's matter-of-fact wonder. Miracles are narrated like farm chores;
violence is sudden, cartoon-clean, and immediately followed by politeness
("It was a good fight, friend"). Jokes come from character, never snark:
the Scarecrow explains why his good ideas prove he has no brains; the
Woodman beheads forty wolves and then weeps over a beetle; the Lion
announces his terror while doing the brave thing. Warmth is the default;
menace is real in Act III but always resolves to capture and rescue, not
death. Zork responsiveness on top: everything examinable, lots of loving
failure text, the parser always has something in-character to say.

---

## 2. Structure

- **Act I — The Road of Yellow Brick** (9 rooms). Cyclone cold open; the
  landing; shoes and kiss; recruit the Scarecrow (pole), the Tin Woodman
  (oil-can), and the Lion (nose slap); first companion tricks (chopped
  brambles, the beetle-and-rusted-jaws tutorial for the oil-can).
- **Act II — To the Emerald City** (16 rooms). The gorge (Lion express),
  the Kalidah bridge (chop, cross, chop), the river (raft, marooned
  Scarecrow, the Stork), the Deadly Poppy Field (soft timer; the mouse
  debt earned and repaid), the gate and the locked-on spectacles, four
  audiences with four different Wizards, one terrible price.
- **Act III — The Winkie Campaign** (9 rooms). March west; the Witch's four
  minion waves, each broken by the right companion; the unbeatable Winged
  Monkeys and the capture; the castle as the game's dungeon — servitude,
  night feedings, the shoe theft, THROW WATER; the two rescues; the Golden
  Cap; lost in the fields; the mouse whistle pays off; Cap command #1.
- **Act IV — The Humbug and the South** (10 rooms). The empty throne and
  the falling screen; the props room; bran brains, silk heart, bottled
  courage; the balloon that leaves without you (mid-game fake-out outro);
  the road south: Fighting Trees, the Dainty China Country, the Lion's
  crown, the Hammer-Heads (Cap command #3); Glinda's trade; three
  heel-knocks; Kansas.

The road of yellow brick is the literal spine of the map: in Acts I-II the
player is nearly always on it or one step off it, so the geography reads
cleanly by ear. Acts III-IV deliberately leave the road ("There is no road
to the Wicked Witch") — the absence is a mood cue.

---

## 3. The map

44 rooms. DESC in title case (status line), FOR-THE-EAR long descriptions
below (1-3 sentences each — these are the actual LDESC drafts).

### ASCII overview

```
ACT I (east, blue)                ACT II (center, green)
                                                          Emerald City
 FARMHOUSE                                               .-----------------.
    |in/out                                              | CITY-GATE       |
 CLEARING --w-- YELLOW-ROAD --w-- ... --w-- GREEN-ROAD --| GATE-ROOM       |
                   |s                                    | EMERALD-STREET  |
                CORNFIELD                                | PALACE-COURT    |
                                                         |  |-GREEN-CHAMBER|
 YELLOW-ROAD --w-- FOREST-ROAD --w-- BRAMBLE --w-- DEEP  | '-THRONE-ROOM   |
                     |n                    (chop) FOREST |    '-WORKSHOP    |
               WOODMAN-COTTAGE                    (lion) | BALLOON-PLAZA   |
                     |n                                  '-----------------'
               SPRING-GLADE (tin man)
 DEEP-FOREST --w-- GORGE-EDGE ~leap~ KALIDAH-WOOD --w-- SECOND-GORGE
 SECOND-GORGE ~tree bridge~ RIVERBANK ~raft~ MIDRIVER -> FAR-BANK
 FAR-BANK --n-- STORK-BEND --n-- POPPY-FIELD --n-- GREEN-BANK --e-- GREEN-ROAD

ACT III (west, yellow)                 ACT IV (south, red)
 CITY-GATE --w-- WEST-FIELDS --w-- WEST-HILLS ==captured==> CASTLE
   Witch's castle:  KITCHEN -- HALL -- COURTYARD      GARRET (up from hall)
   HALL --w-- ROCKY-PLAIN --n-- TALL-TREE
   CASTLE --e-- LOST-FIELDS ==monkeys==> CITY-GATE
 BALLOON-PLAZA --s-- FIGHTING-TREES --s-- CHINA-WALL --s-- CHINA-COUNTRY
 CHINA-COUNTRY ~lion leap~ QUADLING-FOREST --s-- HAMMER-HILL
 HAMMER-HILL ==monkeys==> QUADLING-FARM --s-- GLINDA-THRONE ==shoes==> KANSAS-PRAIRIE
```

`~x~` = companion-powered crossing; `==x==>` = scripted/one-way transition.

### Room list

**Act I**

1. **FARMHOUSE** — "Farmhouse, Kansas." *One gray room holds the whole
   house: a rusty cookstove, a cupboard, a table, and two beds, with a trap
   door to the cyclone cellar in the middle of the floor. Through the
   doorway the prairie runs flat and gray to the edge of the sky.* Three
   phases (Kansas / flying / landed-in-Oz); after landing, OUT → CLEARING.
   Contents: cupboard (bread), table, beds, trap door, Toto (under the bed
   during the storm).
2. **CLEARING** — "Munchkin Clearing." *The house sits crookedly on a green
   lawn beside a sparkling brook, with fruit trees and banks of flowers all
   around. From under one corner of the house, two feet in silver shoes
   stick out.* NPCs on first entry: Witch of the North, three Munchkins.
   Contents: silver shoes (after the feet dry up), brook. IN → FARMHOUSE,
   WEST → YELLOW-ROAD.
3. **YELLOW-ROAD** — "Road Of Yellow Brick." *Yellow bricks run
   straight and true between dainty blue fences, past round blue houses
   with domed roofs. Munchkins bow to you from their fields as you pass.*
   Flavor NPC: Boq at his gate offers good wishes and one hint. EAST →
   CLEARING, SOUTH → CORNFIELD, WEST → FOREST-ROAD.
4. **CORNFIELD** — "Cornfield." *Ripe corn stretches away beyond a blue
   fence. In the middle of the field a scarecrow in a pointed blue hat
   hangs on a pole — and, unless the sun is playing tricks, it just winked
   at you.* Contents: Scarecrow (on pole), pole. NORTH → YELLOW-ROAD.
5. **FOREST-ROAD** — "Forest Road." *The bricks here are broken and full
   of holes, and great trees meet overhead so that the road runs through a
   green twilight.* Scarecrow pratfall bark fires here. EAST → YELLOW-ROAD,
   WEST → BRAMBLE-ROAD, NORTH → WOODMAN-COTTAGE.
6. **WOODMAN-COTTAGE** — "Log Cottage." *A snug cottage of logs and
   branches with a bed of dried leaves in one corner. On a shelf sits a
   battered oil-can.* Contents: oil-can, leaf bed (SLEEP here advances to
   morning in Act I). SOUTH → FOREST-ROAD, NORTH → SPRING-GLADE.
7. **SPRING-GLADE** — "Forest Spring." *A little spring rises clear and
   cold among the trees. Beside a half-chopped tree stands a man made
   entirely of tin, his axe lifted over his head, perfectly still — and
   groaning.* Contents: Tin Woodman (rusted), axe, spring, half-chopped
   tree. SOUTH → WOODMAN-COTTAGE.
8. **BRAMBLE-ROAD** — "Choked Road." *Branches and whole trees have grown
   so thick across the road that not even Toto could squeeze through.*
   Woodman-chop gate. EAST → FOREST-ROAD, WEST (gated) → DEEP-FOREST.
9. **DEEP-FOREST** — "Deep Forest." *The forest is old and dark here, and
   now and then something large growls, deep among the trees.* Lion ambush
   on first entry. EAST → BRAMBLE-ROAD, WEST → GORGE-EDGE.

**Act II**

10. **GORGE-EDGE** — "Edge Of The Gorge." *The road ends at a gorge so wide
    and deep that the jagged rocks at the bottom look like gray teeth. The
    far side is a long, long jump away.* Lion-leap gate WEST. EAST →
    DEEP-FOREST.
11. **KALIDAH-WOOD** — "Gloomy Wood." *The trees crowd close and dark, and
    strange heavy footfalls circle you just out of sight. The Lion whispers
    one word: Kalidahs.* EAST → GORGE-EDGE (leap back), WEST → SECOND-GORGE.
12. **SECOND-GORGE** — "Second Gorge." *This gulf is far too broad for any
    leap. One great tree stands right at the edge, tall enough to reach the
    other side, if only it were lying down.* Tree-bridge puzzle; Kalidah
    chase scene. EAST → KALIDAH-WOOD, WEST (via bridge) → RIVERBANK.
13. **RIVERBANK** — "Riverbank." *A broad river slides swiftly past. On the
    far side the road of yellow brick sets off again through meadows dotted
    with bright flowers.* Raft puzzle. EAST → SECOND-GORGE, WEST (via raft)
    → MIDRIVER.
14. **MIDRIVER** — "Middle Of The River." *Water everywhere, moving faster
    than it looked from shore. The raft has ideas of its own about where
    you are going.* Scripted drift; Scarecrow marooned here. Auto → FAR-BANK.
15. **FAR-BANK** — "Grassy Bank." *Soft green grass, flowers, fruit trees —
    and no road anywhere. The river has carried you a long way past the
    road of yellow brick.* NORTH → STORK-BEND.
16. **STORK-BEND** — "Bend In The River." *From here you can see, far out
    in the water, a small blue-hatted figure clinging to a pole: the
    Scarecrow, looking as lonely as a scarecrow can look. A stork stands in
    the shallows, resting.* Stork puzzle. SOUTH → FAR-BANK, NORTH →
    POPPY-FIELD.
17. **POPPY-FIELD** — "Deadly Poppy Field." *Scarlet poppies crowd so thick
    and bright they dazzle the eyes, and their spicy scent makes the whole
    world feel like a warm bed. You are so very sleepy.* Sleep timer.
    SOUTH → STORK-BEND, NORTH → GREEN-BANK (you never quite make it awake).
18. **GREEN-BANK** — "Green Bank." *Fresh sweet grass beyond the last of
    the poppies. A little way back, the Lion lies in the flowers, fast
    asleep and much too heavy to carry.* Wildcat/mouse-queen scene; truck
    rescue. EAST → GREEN-ROAD.
19. **GREEN-ROAD** — "Green Country Road." *The road of yellow brick again,
    smooth and well paved, running between green fences and green farmhouses.
    A farmer's family watches you pass — mostly they watch the Lion.*
    Farmhouse flavor scene (the man with the hurt leg, Oz rumors). WEST →
    GREEN-BANK, EAST → CITY-GATE.
20. **CITY-GATE** — "Before The Gate." *A wall of green stone, high and
    thick, and in it a great gate studded with emeralds that burn in the
    sun. Beside the gate is a button for a bell.* PUSH BUTTON to enter.
    WEST → GREEN-ROAD, IN (after bell) → GATE-ROOM. (Also the arrival
    point for both monkey flights and the Act III departure.)
21. **GATE-ROOM** — "Arched Gate Room." *A high arched room whose walls
    glisten with countless emeralds. A little green man stands by a big
    green box, jingling a small key on a chain.* Guardian; spectacles
    ritual, both directions. OUT → CITY-GATE, IN (spectacles on) →
    EMERALD-STREET.
22. **EMERALD-STREET** — "Emerald City Street." *Green marble houses, green
    glass windows, green sky, green everything; children with green skins
    buy green lemonade with green pennies. It is either the most beautiful
    city in the world or the best pair of spectacles.* NORTH →
    PALACE-COURT, SOUTH → GATE-ROOM, EAST → BALLOON-PLAZA (Act IV only).
23. **PALACE-COURT** — "Palace Of Oz." *A soldier with a long green beard
    guards the palace door, and a big room with green furniture waits
    beyond it. Everyone here is very polite and nobody has ever seen Oz.*
    Soldier; green girl. UP → GREEN-CHAMBER, NORTH (when summoned) →
    THRONE-ROOM, SOUTH → EMERALD-STREET.
24. **GREEN-CHAMBER** — "Green Chamber." *The sweetest little room in the
    world: green silk sheets, a fountain that sprays green perfume, and a
    shelf of little green books full of queer pictures.* SLEEP here drives
    the audience-day cycle. DOWN → PALACE-COURT.
25. **THRONE-ROOM** — "Throne Room." *A big round room with a high arched
    roof, walls and floor crusted with great emeralds, and a marble throne
    in the middle under a light as bright as the sun.* The audience scene
    system; later the empty-voice scene, the screen. Contents: throne,
    screen (Act IV). SOUTH → PALACE-COURT, EAST (Act IV, after reveal) →
    WORKSHOP.

**Act III**

26. **WEST-FIELDS** — "Trackless Fields." *No road leads west — only soft
    grass, daisies, and buttercups, with the sun hot in your faces. Far
    off, on a hill, a castle keeps one window toward you like an eye.*
    Waves 1-2 (wolves, crows). EAST → CITY-GATE, WEST → WEST-HILLS.
27. **WEST-HILLS** — "Rough Hills." *The ground is rougher and hillier, and
    there are no trees and no shade. The castle is close now, and something
    in the air is chattering.* Waves 3-4 (bees, Winkies), then the Winged
    Monkeys (scripted capture). EAST → WEST-FIELDS.
28. **CASTLE-KITCHEN** — "Castle Kitchen." *A great sooty kitchen of yellow
    stone: a hearth with a wood fire, black pots and kettles, a broom, and
    a wooden bucket of well water standing by the door.* Servitude hub;
    cupboard (food, later the Golden Cap); iron-bar trap; THE bucket.
    NORTH → CASTLE-HALL.
29. **CASTLE-HALL** — "Castle Hall." *A long hall hung with yellow banners.
    The Witch's rooms are somewhere above, and you are not invited.* SOUTH
    → CASTLE-KITCHEN, EAST → COURTYARD, UP → GARRET, WEST (after victory) →
    ROCKY-PLAIN, OUT/EAST-beyond (after victory) → LOST-FIELDS.
30. **COURTYARD** — "Castle Courtyard." *A small yard closed in by a high
    iron fence. Behind the bars paces the Cowardly Lion, trying to look
    dangerous and mostly looking hungry.* Lion pen; gate (locked till the
    Witch melts); straw pile (for restuffing). WEST → CASTLE-HALL.
31. **GARRET** — "Cold Garret." *A narrow bed under the castle roof. From
    the little window, all the Winkie country lies yellow under the moon.*
    SLEEP here drives the castle night cycle. DOWN → CASTLE-HALL.
32. **ROCKY-PLAIN** — "Rocky Plain." *A country thickly covered with sharp
    rocks. On them lies the Tin Woodman, so battered and dented that he can
    neither move nor groan; his axe lies beside him, the blade rusted, the
    handle broken.* Woodman rescue. EAST → CASTLE-HALL (the Winkies carry
    him), NORTH → TALL-TREE.
33. **TALL-TREE** — "Foot Of A Tall Tree." *One tree stands taller than all
    the rest, its trunk too smooth to climb. High in its branches hangs a
    small bundle of blue clothes and a pointed hat.* Scarecrow rescue.
    SOUTH → ROCKY-PLAIN.
34. **LOST-FIELDS** — "Endless Yellow Fields." *Buttercups and daisies in
    every direction, and no road, and no shadow to say which way is east.
    Walking, you have a feeling you have seen this particular buttercup
    before.* All exits loop back here (gentle). Whistle + Cap puzzle;
    monkeys fly you out.

**Act IV**

35. **WORKSHOP** — "Little Room Behind The Throne." *A cluttered chamber of
    wonders: a great papier-mache head in a corner, a gauzy dress and mask
    on a hook, a bundle of sewn skins, and a ball of cotton on a wire.* The
    props tour; the gifts happen here and in the throne room. WEST →
    THRONE-ROOM.
36. **BALLOON-PLAZA** — "Plaza Before The Palace." *The whole Emerald City
    has turned out. Above the crowd swells a great balloon of green silk,
    tugging at its rope, with a clothes basket swinging beneath.* The
    launch fake-out. WEST → EMERALD-STREET, SOUTH → FIGHTING-TREES.
37. **FIGHTING-TREES** — "Edge Of A Thick Wood." *The first row of trees
    stands shoulder to shoulder like a fence of policemen. As you watch,
    one of them flexes its branches — at you.* Chop gate. NORTH →
    BALLOON-PLAZA, SOUTH (gated) → CHINA-WALL.
38. **CHINA-WALL** — "Foot Of A White Wall." *A wall higher than your head
    and smooth as the inside of a dish, made, as far as you can tell, of
    white china. It runs left and right as far as sight.* Ladder puzzle;
    comic dismount. NORTH → FIGHTING-TREES, SOUTH (via ladder) →
    CHINA-COUNTRY.
39. **CHINA-COUNTRY** — "Dainty China Country." *A floor as smooth and
    shining as a big platter, set with china houses no taller than your
    waist, china barns, china cows — and little china people, none higher
    than your knee, going carefully about their tiny lives.* Milkmaid, cow,
    Princess, Mr. Joker; care mechanics; Lion-back exit. SOUTH (via Lion) →
    QUADLING-FOREST.
40. **QUADLING-FOREST** — "Grand Old Forest." *The oldest, mossiest forest
    you have ever seen — and its clearing is full of animals: tigers and
    elephants and bears and wolves and foxes, all growling together like a
    town meeting gone wrong.* The spider scene; the Lion's crown. NORTH →
    CHINA-COUNTRY, SOUTH → HAMMER-HILL.
41. **HAMMER-HILL** — "Rocky Hill." *A steep hill covered with great rocks,
    and from behind every rock a flat-topped head on a wrinkled neck
    watching you. A rough voice says: 'Keep back!'* Cap command #3. NORTH
    → QUADLING-FOREST, SOUTH (impassable on foot; monkeys only) →
    QUADLING-FARM.
42. **QUADLING-FARM** — "Quadling Country." *Fields of ripening grain, red
    fences, red farmhouses, and short, fat, cheerful people dressed all in
    red. A farmer's wife waves from her door with what appears to be cake.*
    Rest + food; directions to Glinda. SOUTH → GLINDA-THRONE.
43. **GLINDA-THRONE** — "Glinda's Castle." *A throne room the color of
    sunrise. On a throne of rubies sits a witch young and beautiful, with
    red hair and kind blue eyes, and three girl soldiers by the door try
    not to stare at the Lion.* The trade; the farewells; the heel-knock.
    NORTH → QUADLING-FARM.
44. **KANSAS-PRAIRIE** — "Kansas Prairie." *Flat gray prairie under a wide
    sky — and there, brand new against it, a little farmhouse. Somebody is
    watering cabbages by the door.* Ending. No exits; the game ends here.

---

## 4. Objects & puzzles

### Key objects

| Object | Where | Notes |
|---|---|---|
| SILVER SHOES | CLEARING (after feet vanish) | Wearable; never referenced as removable after Act I except by the Witch's trick. Final-puzzle engine. VALUE 5. |
| KISS MARK | on Dorothy (scripted) | Not an inventory object; a flag. Referenced by monkeys/Witch. |
| BASKET | FARMHOUSE | Container; bread in it; the game's blessed carry-all. |
| BREAD | cupboard | Food; eaten across Act I (flavor hunger only, never a death). |
| OIL-CAN | WOODMAN-COTTAGE shelf | The Woodman's lifeline; used at SPRING-GLADE and for the beetle scene; replaced by the jeweled one in Act III (same object, upgraded DESC). |
| AXE | with Woodman | Companion prop; the player never wields it — CHOP commands route through the Woodman. |
| MOUSE WHISTLE | given at GREEN-BANK | BLOW WHISTLE; works only in open field rooms; critical in LOST-FIELDS. |
| SPECTACLES | GATE-ROOM box | Wearable, locked on inside the city; comic gate both directions. |
| GOLDEN CAP | Witch's cupboard | Wearable; READ CAP reveals the charm on the lining; powers the three summons. |
| BUCKET | CASTLE-KITCHEN | Full of well water. The murder weapon. |
| WATER | in bucket | Uses the engine's WATER stub object; POUR/THROW target. |
| STOLEN SHOE | on the Witch after the trick | Recoverable from the puddle; CLEAN/DRY then WEAR. |
| STRAW | COURTYARD pile | For restuffing the Scarecrow. |
| CLOTHES BUNDLE | TALL-TREE branches | Falls when the tree is chopped. |
| MEAT | kitchen cupboard | Night food for the caged Lion. |
| FIREWOOD, BROOM, POTS | CASTLE-KITCHEN | Chore props (PUT WOOD ON FIRE, SWEEP FLOOR, CLEAN POTS). |
| IRON BAR | kitchen floor | INVISIBLE flag, literally; the trip-trap. |
| SCREEN | THRONE-ROOM (Act IV) | The reveal. |
| HEAD, MASK, SKINS, COTTON BALL | WORKSHOP | The props tour; each EXAMINE is a punchline. |
| BRAINS, HEART, DISH OF COURAGE | Act IV gifts | Given in scripted scenes; live on the companions afterward (EXAMINE SCARECROW notes the bulges and pins). |
| BALLOON | BALLOON-PLAZA | Scenery + scene machine. |
| WALKING STICK, BRACELET, COLLARS, JEWELED OIL-CAN | Winkie gifts | Flavor treasures, small VALUE each. |
| LADDER | built at CHINA-WALL | Woodman product. |
| RAFT | built at RIVERBANK | Woodman product; VEHBIT. |

### Puzzles (exact solutions, failures, hints)

**P1. The cyclone & Toto (tutorial).** FARMHOUSE, storm phase. Aunt Em
cries "Run for the cellar!" and descends. Toto hides under the bed.
- Solution: `GET TOTO` (or LOOK UNDER BED then GET TOTO) — then the house
  lifts before you can reach the trap door (scripted; the cellar is never
  actually reachable — trying `DOWN` gets "You reach for the ring just as
  the whole house shudders and tips you off your feet.").
- One mid-flight beat: Toto slips through the open trap door; `GET TOTO` /
  `PULL TOTO` rescues him by the ear (air pressure holds him up, as in the
  book); then `CLOSE TRAP DOOR` for a point.
- Failure text (ignoring Toto): the house simply lifts with Toto under the
  bed and he creeps out later — forgiving, small score loss only.
- This teaches: the game will always keep Toto safe, but paying attention
  to him pays.

**P2. Shoes and kiss.** CLEARING. The feet "dry up in the sun" two turns
after the Witch of the North points them out, leaving the SILVER SHOES.
- Solution: `TAKE SHOES` then `WEAR SHOES` (old shoes discarded with a
  line about long walks). The Witch gives the kiss unprompted (scripted),
  reads the slate, says the road is paved with yellow brick, and whirls
  away on her left heel.
- Gate: leaving CLEARING west without wearing the shoes → Toto sits down
  and stares meaningfully at them ("Toto plants himself by the silver
  shoes and will not budge."). Soft gate; second attempt allowed but the
  Witch calls after you ("You will want stout shoes, my dear — those
  silver ones cannot wear out.").

**P3. The Scarecrow on the pole.** CORNFIELD.
- Solution: `LIFT SCARECROW` / `TAKE SCARECROW OFF POLE` / `REMOVE
  SCARECROW FROM POLE` → "being stuffed with straw, he is quite light."
  He joins: RECRUIT #1.
- Failure: `TALK TO SCARECROW` first gets the winking dialogue and his
  request ("If you will please take away the pole I shall be greatly
  obliged to you") — the puzzle states its own solution, Baum-style.
- `PULL POLE` also works (the pole stays, he comes off).

**P4. The rusted Tin Woodman.** SPRING-GLADE + WOODMAN-COTTAGE.
- Setup: entering WOODMAN-COTTAGE or SPRING-GLADE, a groan is heard. The
  Woodman, asked anything, can only groan through rusted jaws — EXAMINE
  reveals the rust; he manages one creaking word: "Oil... can..."
  (bending the book slightly: his jaws get the first drop so he can talk,
  which folds the book's oil-order into a hint).
- Solution: `TAKE OIL CAN` (cottage shelf), return, `OIL WOODMAN` (accept
  OIL/LUBRICATE + WOODMAN/JOINTS/NECK/ARMS/LEGS; three applications with
  escalating delight, or one command that plays all three beats). The
  Scarecrow assists ("The Scarecrow takes the tin head and works it gently
  from side to side."). RECRUIT #2. He lowers the axe at last: "I have
  been holding that axe in the air for more than a year."
- Failure: `OIL WOODMAN` with no can → "You haven't anything to oil him
  with. There must be a can about somewhere — he clearly kept himself
  tidy, before the rain." PUSH/PULL WOODMAN → a sad metallic squeak.
- Follow-up beat: he asks Dorothy to keep the oil-can in her basket, "in
  case I am caught in the rain." (Sets up P6.)

**P5. The choked road.** BRAMBLE-ROAD.
- Solution: with the Woodman present, `WEST` auto-triggers his
  intervention ("The Tin Woodman sets to work, and chips fly like green
  snow.") — or explicitly `CHOP BRANCHES` / `WOODMAN, CHOP TREES`.
- Without the Woodman: "The branches are woven like a basket. If only you
  had an axe — and arms like tin barrels to swing it."

**P6. The beetle and the rusted jaws (oil-can tutorial pays off).**
Scripted on the road after RECRUIT #3: the Woodman steps on a beetle,
weeps, jaws rust mid-sentence; he gestures desperately.
- Solution: `OIL WOODMAN` / `OIL JAWS`. The Scarecrow will do it himself
  after 3 turns if the player is stuck (companion as animated hint).
- Reward text: "'This will serve me a lesson,' says the Woodman, 'to look
  where I step. For if I should kill another bug or beetle I should
  surely cry again, and crying rusts my jaws so that I cannot speak.'"

**P7. The Lion's ambush.** DEEP-FOREST, first entry: the Lion bowls over
the Scarecrow, dents his claws on the Woodman, and turns on Toto.
- Solution: `SLAP LION` / `HIT LION` (accept ATTACK LION barehanded) →
  the nose slap, "You are nothing but a big coward," the shame, the
  confession, RECRUIT #3.
- Failures: `RUN` / going back east → the Lion pads after you apologizing
  ("Wait! I mostly never bite anybody!") — re-offer. Attacking with a
  weapon-ish object → "He's three times your size. Fortunately what he
  needs isn't fighting; it's telling off." (Nudges to the barehanded slap.)
- If the player just talks: the Lion moves to bite Toto after 2 turns and
  the game prompts — "Toto runs barking at the great beast. There is no
  time to think." (SLAP resolves any turn.)

**P8. The first gorge.** GORGE-EDGE.
- Solution: `RIDE LION` / `CLIMB ON LION` / `LION, JUMP` / plain `WEST`
  with the Lion present (asks "The Lion crouches: 'One at a time. Who's
  first?' " — any confirmation proceeds). Scripted triple crossing,
  Scarecrow first, book order, with "that isn't the way we Lions do these
  things."
- Without the Lion (impossible in normal flow, but): "The gorge is far
  too wide to jump and too steep to climb."
- `JUMP` / `JUMP OVER GORGE` as Dorothy → two warnings, then a JIGS-UP if
  truly insisted upon (the game's only death, guarded twice: "The
  Scarecrow catches your sleeve. 'I have no brains,' he says, 'and even I
  wouldn't.'").

**P9. The Kalidah bridge.** SECOND-GORGE. The set piece.
- Beat 1: `CHOP TREE` / `WOODMAN, CHOP TREE` → chopped nearly through;
  the Lion pushes; the tree falls as a bridge (scripted pair, one command).
- Beat 2: `CROSS TREE` / `WEST` → midway, two Kalidahs burst from the
  wood and start across behind you. The Lion turns and roars them into a
  moment's pause (automatic, buys the player time; 3-turn window).
- Beat 3: `CHOP TREE` again (or `WOODMAN, CHOP BRIDGE`; the Scarecrow
  shouts the hint on turn 2: "'Chop away our end of the tree!' cries the
  Scarecrow.") → the bridge falls, the Kalidahs are dashed to pieces, and
  the Lion draws a long breath: "I see we are going to live a little
  while longer, and I am glad of it, for it must be a very uncomfortable
  thing not to be alive."
- Failure: if the window lapses, the Lion holds the bridgehead and is
  mauled (not killed): party scrambles across, bridge falls in the
  struggle, Lion limps for a while (bark changes; small score loss). No
  death, real consequence.

**P10. The river.** RIVERBANK → MIDRIVER → FAR-BANK.
- Solution: `BUILD RAFT` / `WOODMAN, BUILD RAFT` (or CHOP TREES then
  BUILD RAFT; either works, one night passes) → `BOARD RAFT` → `LAUNCH`
  (or WEST). MIDRIVER is scripted: the current grabs the raft; the
  Scarecrow poles too hard and is left clinging to his pole midstream
  ("Good-bye!" he calls politely, marooned); the Lion swims towing the
  raft (automatic), landing at FAR-BANK.
- The marooning is not preventable — it's the story, and the game plays
  it for gentle comedy plus real worry (party barks change: the Woodman
  starts to cry, remembers rust, stops himself).

**P11. The Stork.** STORK-BEND.
- Solution: `TALK TO STORK` / `ASK STORK ABOUT SCARECROW` / `ASK STORK
  FOR HELP` / `STORK, HELP` → she asks if he's heavy; any reply
  mentioning straw, or just `SAY STRAW` fallback text, works — simplest
  accepted command: `TELL STORK ABOUT SCARECROW`. She fetches him;
  reunion hug; he sings "Tol-de-ri-de-oh!" at every step for the next few
  turns (bark override). RECRUIT #1 restored.
- Failure: `SWIM` → "The current there defeated even the Lion. But
  something with wings might manage it..." (points at the stork).

**P12. The Deadly Poppy Field (soft timer).** POPPY-FIELD.
- Mechanic: entering starts a drowsiness counter with escalating messages
  at each turn (yawns → heavy eyes → "the poppies are so soft..."). Toto
  falls asleep at turn 2 (the Woodman carries him). Any movement command
  makes progress; on turn 5 wherever you are, Dorothy collapses —
  scripted, book-true, NOT a fail: the Scarecrow and Woodman make a chair
  of their hands and carry her; she wakes at GREEN-BANK.
- The Lion: told to run (automatic per the Scarecrow's plan, narrated),
  he falls "only a short distance from the end" — visible asleep in the
  poppies from GREEN-BANK, too heavy to lift. Sets up P13.
- The only way to be hurt here is to deliberately go back in after being
  warned; even then: carried out again, with the Scarecrow remarking that
  flesh people are a great deal of upkeep.

**P13. The wildcat and the debt (the mice).** GREEN-BANK, on arrival +2
turns: a yellow Wildcat streaks past chasing a little gray mouse.
- Solution: `WOODMAN, KILL WILDCAT` / `KILL WILDCAT` (Woodman executes:
  one clean blow, book-style) — or, if the player hesitates, `STOP
  WILDCAT`, `SAVE MOUSE` also route to him. The mouse is the QUEEN OF THE
  FIELD MICE; gratitude scene; Toto restrained by the Woodman (comedy).
- Then: the Queen asks how to repay. Solution: `ASK QUEEN TO SAVE LION` /
  `TELL QUEEN ABOUT LION` / `QUEEN, SAVE LION` (the Scarecrow supplies
  the plan aloud as a hint after 2 turns). Scripted rescue: the Woodman
  builds the truck, thousands of mice with strings haul the sleeping Lion
  out. The Queen gives Dorothy the MOUSE WHISTLE: "If ever you need us
  again, come out into the field and blow."
- Failure path: if the player lets the Wildcat go (does nothing for 3
  turns), the Woodman acts on his own ("I have no heart, you know, so I
  am careful to help all those who may need a friend") — debt still
  earned, fewer points. FORGIVING BY DESIGN: this debt is required later.

**P14. The spectacles gate (mandatory and comic).** GATE-ROOM.
- Entering the city: the Guardian explains the brightness-and-glory rule.
  Solution: `WEAR SPECTACLES` (a pair for everyone including Toto —
  scripted fitting, locked with the little key). Attempting `IN` without
  them: "The Guardian bars the way, politely horrified. 'The brightness
  and the glory would blind you! Even I sleep in mine.'"
- Comic bits that must exist: `REMOVE SPECTACLES` inside the city → "They
  are locked on, and the Guardian of the Gates has the only key. The
  Emerald City is very committed to being emerald." EXAMINE anything in
  the city → its description is green. `EXAMINE SPECTACLES` → "Through
  them, everything is green. Around the edges... you decide not to think
  about the edges."
- Leaving for Act III: the Guardian unlocks and re-boxes them — and
  Dorothy's palace-gift dress quietly turns from green to white a room
  later (book detail; nobody comments except the Scarecrow: "I have a
  theory about this city.").

**P15. The four audiences (the Wizard scene system).** THRONE-ROOM over
four palace days; SLEEP in GREEN-CHAMBER advances days.
- Day 1 — Dorothy: interactive. The GIANT HEAD asks its three questions
  (who are you / where got you the shoes / where got you the mark). Any
  honest-sounding answers advance (the parser accepts SAY <anything>,
  ANSWER, or just talking; wrong-footed answers get the eyes rolling
  "queerly" and a re-ask). Then the price: "Kill the Wicked Witch of the
  West." Refusals ("I cannot!") get the book's answer: "That is my
  answer, and until the Wicked Witch dies you will not see your uncle and
  aunt again."
- Days 2-4 — Scarecrow (LOVELY LADY), Woodman (TERRIBLE BEAST), Lion
  (BALL OF FIRE): each morning the soldier fetches one companion; the
  player may WAIT in PALACE-COURT (or sleep); the companion returns and
  recounts his audience in voice — three monologue gems with group banter
  ("She needs a heart as much as the Tin Woodman," reports the Scarecrow
  of the Lady). Each retelling seeds the reveal: four shapes, one Wizard.
- Departure gate: after audience 4, the green girl refills the basket,
  the axe is sharpened on the green grindstone, fresh straw and new eye
  paint for the Scarecrow, and a bell for Toto. Then the gate, spectacles
  off, west.

**P16. The four minion waves (scene battles).** WEST-FIELDS (waves 1-2)
and WEST-HILLS (waves 3-4), triggered on entry and on subsequent turns.
Each wave names its counter through staging; the right single command
wins; a wrong command costs nothing but a turn of comic chaos, and after
two turns the correct companion acts on his own (companions never let
you lose these — the fun is calling the play yourself).
- Wolves (40): "This is my fight," says the Woodman. `WOODMAN, ATTACK
  WOLVES` / `ATTACK WOLVES` → forty swings, delivered deadpan. ("It was a
  good fight, friend," says the Scarecrow.)
- Crows (40): the Scarecrow's ("Lie down beside me and you will not be
  harmed."). `SCARECROW, SCARE CROWS` / `HIDE` / `LIE DOWN` → he stands
  tall, then wrings forty necks, King Crow first.
- Bees: the Scarecrow's plan, the Woodman's hide: `TAKE STRAW` prompts —
  proper command `COVER US WITH STRAW` / `SCARECROW, SCATTER STRAW` → the
  bees break their stings on tin and rain down "like little heaps of fine
  coal." Then restuff (scripted, one turn of patting him into shape).
- Winkies (12, with spears): the Lion's: `LION, ROAR` / `ROAR` → they
  flee so fast some run out of their shoes. (The Witch, offstage, beats
  them with her umbrella — heard faintly, establishing her.)

**P17. The Winged Monkeys (unbeatable — story beat, not fail state).**
WEST-HILLS after wave 4: darkness, wings, chattering. Nothing works and
nothing needs to: any commands during the two-turn arrival get in-fiction
denials ("The Lion roars — and is simply picked up."). Scripted: Woodman
dropped on the rocks, Scarecrow unstuffed into a tall tree, Lion roped
into the castle yard; the Monkey leader sees the kiss mark and stops
short — "We dare not harm this little girl." Dorothy and Toto are carried
gently to the castle doorstep. Act III proper begins. The score does NOT
go down: the game says plainly in text that being captured was the only
way in ("and so, in the politest possible way, the Winged Monkeys carry
you exactly where you needed to go").

**P18. Servitude & the night feedings.** CASTLE-KITCHEN days /
GARRET nights, a 3-day cycle.
- Daytime chores (any two per day advance the day): `SWEEP FLOOR`, `CLEAN
  POTS`, `PUT WOOD ON FIRE`. The Witch supervises with the umbrella and
  one telescope eye; she threatens but cannot strike (kiss). Toto bites
  her leg once; she doesn't bleed ("so wicked that the blood in her had
  dried up many years before" — EXAMINE WITCH after this reveals it).
- Nights: `TAKE MEAT` from the cupboard, `GO TO COURTYARD`, `GIVE MEAT TO
  LION`. Two feedings required across two nights; each is a warm scene
  (planning escape with your head on his mane). Skipping a feeding: the
  Lion is weaker and sadder next day (no fail; the third day still
  comes — but feeding both nights earns points and the best text).
- The Witch's fear of the dark keeps her out of the night scenes; her
  fear of water is planted twice: she never touches the bucket, and she
  skirts the wet flagstones after Dorothy scrubs ("she crosses the room
  the long way round, keeping her skirts from the damp").

**P19. The shoe theft and THE BUCKET.** Morning of day 3, scripted on
kitchen entry: Dorothy trips over something that is not there (the
invisible iron bar), and one silver shoe comes off; the Witch snatches it
and puts it on her own skinny foot, gloating (book dialogue: "I shall
keep it, just the same... and someday I shall get the other one from you,
too.").
- Solution: `THROW WATER AT WITCH` / `POUR WATER ON WITCH` / `THROW
  BUCKET AT WITCH` (bucket stands full by the door; TAKE BUCKET optional,
  the throw works either way). The melt: full book text adapted, ending
  "Look out—here I go!" — then a brown, spreading mess and one silver
  shoe sitting in it.
- Recovery: `TAKE SHOE` → it's wet and horrible; `CLEAN SHOE` / `DRY
  SHOE` (with cloth/apron; plain WEAR also triggers an automatic wipe) →
  `WEAR SHOE`. Sweep the mess out the door for a wicked little point
  (`SWEEP FLOOR` reprise — the chore verb gets its punchline).
- Hinting: this is the game's crown puzzle and it is fair: the Witch's
  hydrophobia is planted twice in P18, the bucket is in the first line of
  the kitchen description, and Dorothy is ANGRY (the narration says so —
  the one time in the game). If the player dithers 5 turns, Toto growls
  at the bucket. If 5 more, the Witch cackles "and there's not a thing
  you can do, for you'd never dare splash me—" — the hint of last resort,
  in her own voice, book-style hubris.
- No other solution works, and all failures are safe: the kiss protects
  Dorothy from every retaliation ("The Witch raises her umbrella, looks
  at your forehead, and thinks better of it.").

**P20. Freeing the Lion & the Winkies.** After the melt: `GO COURTYARD`,
`OPEN GATE` / `UNLOCK GATE` (unlocked now — her power melted with her) →
the Lion free, the Winkies' holiday begins. The Winkie foreman offers any
help; this unlocks the two rescues.

**P21. The two rescues.**
- Woodman: `WEST` from the hall → ROCKY-PLAIN with Winkie bearers.
  `EXAMINE WOODMAN` (battered, cannot move or groan). Solution: `TELL
  WINKIES TO CARRY WOODMAN` / `ASK WINKIES FOR HELP` → carried home;
  tinsmiths work "three days and four nights" (scripted montage);
  goldsmith fits the solid gold axe-handle. Reunion tears — `WIPE TEARS`
  with the apron for the tender little point (auto after 2 turns).
- Scarecrow: with the mended Woodman, `NORTH` → TALL-TREE. Solution:
  `CHOP TREE` / `WOODMAN, CHOP TREE` → the bundle falls. `TAKE CLOTHES`,
  return, `STUFF SCARECROW` / `STUFF CLOTHES WITH STRAW` at the courtyard
  straw pile → "and behold! here is the Scarecrow, as good as ever,
  thanking you over and over again."
- Order forced kindly: TALL-TREE needs the axe, so Woodman first; the
  game says so if tried backwards ("The trunk is too smooth to climb, and
  the only axe in the country is lying on a rocky plain, in no state to
  chop anything.").

**P22. The Golden Cap.** CASTLE-KITCHEN, `OPEN CUPBOARD` (any time after
the melt; also found when packing food): the GOLDEN CAP, circle of
diamonds and rubies. `WEAR CAP` → fits exactly. `READ CAP` / `LOOK IN
CAP` → the charm on the lining, printed in full:
  "Left foot: EP-PE, PEP-PE, KAK-KE. Right foot: HIL-LO, HOL-LO, HEL-LO.
   Both feet: ZIZ-ZY, ZUZ-ZY, ZIK."
Mechanics: the words EPPE, HILLO, ZIZZY are dictionary words (magic-word
style). Saying them in order while wearing the cap performs the ritual
(each prints its stage direction: "(standing on your left foot)" etc.).
`SAY CHARM` / `SUMMON MONKEYS` shortcuts the whole ritual for players who
hate typing. Before ZIZZY completes, the game prints the resource state:
"(You will then have N commands of the Winged Monkeys remaining.)"

**THE CAP ECONOMY** (classic scarce resource, exactly the book's three):
- Use #1 (required): LOST-FIELDS → carried to the Emerald City.
- Use #2 (optional, the book's beautiful waste): after the balloon
  departs, summoning the monkeys and commanding `FLY TO KANSAS` / `TAKE
  ME HOME` gets the King's grave refusal — "We belong to this country
  alone... There has never been a Winged Monkey in Kansas yet" — and the
  use IS spent, as in the book. Story beat, not a bug.
- Use #3 (required): HAMMER-HILL → carried over to the Quadling country.
- **Anti-dead-end rail:** when only ONE use remains and the player begins
  the ritual anywhere but HAMMER-HILL (or LOST-FIELDS if somehow
  returned), the Scarecrow interrupts before the third word: "Wait! If
  the Monkeys could have carried you to Kansas, Oz would not have needed
  a balloon. Save our last command — I have a feeling about that hill in
  the south." The block is diegetic, the game stays solvable, and the
  Scarecrow gets to visibly have brains. A player who insists (`SAY
  ZIZZY` again same turn) is allowed the waste ONLY if no required use
  remains ahead — i.e. after Hammer-Hill, spend freely.
- Summoning where there is nothing to do: the King bows — "There is
  nothing here we can carry you from. Call us when you are truly stuck."
  — and does NOT spend the use (generosity beats book-literalism here;
  the one canonical waste, Kansas, still spends).

**P23. Lost in the fields (the whistle pays its debt).** LOST-FIELDS: all
compass exits loop back with escalating gentle text ("You are quite sure
you have seen this particular buttercup before."). 
- Solution: `BLOW WHISTLE` → the Queen of the Field Mice arrives with her
  people; she can't guide you ("you have had the city at your backs all
  this time") but spots the cap: "Why don't you use the charm of the Cap,
  and call the Winged Monkeys?" — then the mice flee before the monkeys
  come (they "think it great fun to plague us"). `READ CAP` if not yet
  read; perform the ritual; command `FLY TO EMERALD CITY` / `EMERALD
  CITY` / `CITY` → carried to CITY-GATE, with the Monkey King telling the
  Gayelette-and-Quelala story in flight (two screens of lovely lore).
- Hint ladder: turn 3 the Scarecrow says his brains feel damp out here;
  turn 6 Toto noses the whistle around Dorothy's neck; turn 9 the
  narrator: "The Queen of the Field Mice did say to call if you ever
  needed them."

**P24. The humbug reveal (pull back the screen).** THRONE-ROOM, second
audience cycle (all four together, book-style, after the Guardian's
delighted "She could not help it, for she is melted"). Oz stalls three
days; the Scarecrow's monkey threat (scripted, with the player prompted
to `SEND MESSAGE` / `THREATEN OZ` via the green girl) lands the 9:04
appointment. The room is empty; the Voice comes from everywhere.
- Solution: `LION, ROAR` → Toto, startled, leaps and tips the screen
  (book-true, and the best version); or directly `LOOK BEHIND SCREEN` /
  `MOVE SCREEN` / `PUSH SCREEN`. Behind it: "a little old man, with a
  bald head and a wrinkled face, who seems as surprised as you are."
- The confession dialogue plays in beats the player paddles with any
  TALK/ASK: "I have been making believe." — "You're a humbug!" — "Exactly
  so! I am a humbug." Then `EAST` → WORKSHOP for the props tour: EXAMINE
  HEAD / MASK / SKINS / COTTON BALL each yields a debunk-punchline;
  ASK OZ ABOUT OMAHA / BALLOON / SPECTACLES for the backstory set.
- The deal: keep his secret; gifts tomorrow. (`PROMISE` / `YES`.)

**P25. The gifts.** Next morning, scripted trio with the book's props:
bran-and-pins brains ("bran-new brains" — the pun lands as narrator
deadpan), the silk-and-sawdust heart through the tin-shears hatch, the
green bottle of courage ("it cannot be called courage until you have
swallowed it"). Each companion's post-gift glow rewrites his idle barks
for the rest of the game (Scarecrow now cites his brains before every
plan; the Lion is afraid of nothing and says so, at length; the Woodman
keeps listening to his chest). Dorothy's turn: "Give me two or three
days," says Oz — the balloon.

**P26. The balloon (the mid-game fake-out outro).** Three build days
(light participation: `SEW SILK` once, `HELP OZ`, watching the glue go
on), then BALLOON-PLAZA, the crowd, the speech ("While I am gone the
Scarecrow will rule over you"). Then: Toto bolts into the crowd after a
kitten. The player will, of course, `GET TOTO` — and that's the trap
sprung lovingly by the story: as you catch him, "crack! go the ropes,"
and the balloon rises without you. Full fake-out outro text plays (see
section 8), then: "...but the story is not over. Not while somebody in
this crowd knows the way south." (If the player ignores Toto and boards:
Dorothy cannot; the basket is already lifting as she reaches it, because
she stopped for nothing and the ropes cracked anyway — the book's
outcome is inevitable, only the framing shifts. Toto is retrieved
automatically, reproachfully.)

**P27. The Fighting Trees.** FIGHTING-TREES.
- Solution: `CHOP BRANCH` / `WOODMAN, CHOP TREE` → the tree shakes "as if
  in pain" and the party passes under; Toto grabbed by a twig, chopped
  free (scripted beat).
- Failure: `SOUTH` unaided → the Scarecrow volunteers, is seized and
  flung back twice, dizzy and cheerful ("It doesn't hurt me to be thrown
  about, and I begin to see why nobody visits the south.").

**P28. The china wall & country (care as comedy).**
- Wall: `BUILD LADDER` / `WOODMAN, MAKE LADDER` (he gathers wood,
  overnight beat) → `CLIMB LADDER` → everyone up, everyone says "Oh, my!"
  in turn. Down the far side: `JUMP` → scripted: the Scarecrow falls
  first so everyone lands on him ("taking pains not to light on his head
  and get the pins in their feet"); pat him back into shape.
- Country: moving with `RUN` or `CHASE PRINCESS` causes tiny disasters
  (the cow kicks, the milkmaid's elbow is nicked, reproachful glances);
  `WALK` / normal movement is safe. The Princess conversation: `TALK TO
  PRINCESS` → "Don't chase me!... one is never so pretty after being
  mended." Optional micro-moral: `TAKE PRINCESS` → her mantel speech;
  `PUT PRINCESS DOWN` / relenting earns points; insisting is simply
  impossible ("Your hand stops an inch away. She is looking at you.").
  Mr. Joker recites his poem if EXAMINEd; the milkmaid wants her cow's
  leg found (`GIVE LEG TO MILKMAID`, one-move fetch, small points, she
  forgives you a little).
- Exit: the far wall is lower: `CLIMB ON LION` / `STAND ON LION` → all
  scramble up; his leap smashes a china church with his tail (score is
  docked one dry point, labeled "china church, one (1)" in the score
  breakdown — the game's sole negative point, played as a joke).

**P29. The great spider (the Lion's coronation).** QUADLING-FOREST: the
assembly of beasts; the tiger's plea; the bargain ("If I put an end to
your enemy, will you bow down to me as King?").
- Solution: `LION, KILL SPIDER` / `TELL LION TO FIGHT` — he insists on
  going alone (book): one turn of offstage quiet, then the return, the
  bow of the beasts, and the Lion trying to be modest and failing.
  Dorothy & co. can FOLLOW to watch from the thicket instead: same
  outcome, better view (the wasp-waist neck detail, the single blow).
- This is deliberately not a player-solved puzzle: it is the Lion's
  earned solo, post-courage. The player's job is to say yes and be proud
  of him.

**P30. The Hammer-Heads (Cap command #3).** HAMMER-HILL.
- Any climb attempt: a head shoots out on its telescoping neck and the
  climber rolls back down — Scarecrow first, then the Lion "as if he had
  been struck by a cannon ball" (no damage, great noises). "It is
  useless to fight people with shooting heads; no one can withstand
  them," pants the Lion — and the Woodman says the line that unlocks it:
  "Call the Winged Monkeys. You have still the right to command them
  once more."
- Solution: ritual + `FLY OVER HILL` / `FLY SOUTH` / `CARRY US OVER` →
  over the hill, Hammer-Heads yelling vexation below, set down in the
  Quadling country; the King's goodbye: "This is the last time you can
  summon us; so good-bye and good luck to you."

**P31. Glinda's trade & the Silver Shoes finale.** GLINDA-THRONE.
- `TELL GLINDA ABOUT JOURNEY` / any TALK → she listens to everything
  (one lovely summary paragraph — the game recaps the player's own
  adventure, including their optional deeds). Then: "I am sure I can
  tell you of a way to get back to Kansas... But, if I do, you must give
  me the Golden Cap."
- Solution: `GIVE CAP TO GLINDA`. She reveals her three planned uses
  (Scarecrow → Emerald City throne; Woodman → the Winkies; Lion → his
  forest; then the Cap to the Monkey King, "free for evermore") — the
  player's spent commands are mirrored by her generous ones; the economy
  closes with grace.
- The secret: "Your Silver Shoes will carry you over the desert... knock
  the heels together three times, and command the shoes to carry you
  wherever you wish to go." The gut-punch, delivered with the
  companions' own book lines pre-empting player outrage: "But then I
  should not have had my wonderful brains!" etc.
- Farewells: `KISS LION`, `KISS WOODMAN` (careful of rust — the game
  wipes his tears for you, one last time), `HUG SCARECROW`. Each goodbye
  earns a point and a bark you will remember. Skippable but who would.
- Finale: `KNOCK HEELS TOGETHER` / `CLICK HEELS` / `KNOCK HEELS THREE
  TIMES` → "The shoes await your command." → `SAY TAKE ME HOME` / `TAKE
  ME HOME TO AUNT EM` / `GO HOME` / `SAY KANSAS` → three whirling steps,
  the shoes falling away into the desert, and KANSAS-PRAIRIE.

---

## 5. NPCs & the companion system

### The trio as followers

State per companion: `IN-PARTY?` flag, `LOCATION` (object in a room),
plus a small state word (NORMAL / MAROONED / ASLEEP / CAPTURED / CAGED /
BATTERED / UNSTUFFED / CROWNED). Machinery (Zork actor model):

- **Follow:** one clock demon (GCLOCK C-INT, like the thief's) runs each
  turn: every IN-PARTY companion not in HERE is MOVEd to HERE, silently.
  Arrival is never narrated (they simply are with you); departure states
  (marooned/captured) clear IN-PARTY so the demon leaves them where the
  story put them. Companions are (FLAGS PERSON) objects with SYNONYM/
  ADJECTIVE so EXAMINE/TALK/commands resolve.
- **Interventions:** room ACTION routines own them. Pattern: on the
  gating verb or direction (`WEST` at BRAMBLE-ROAD, `CHOP` at
  SECOND-GORGE...), test the needed companion's presence + state; if
  present, print the intervention scene and do the world-change; if
  absent, print the locked text that names the missing capability ("If
  only you had an axe — and arms like tin barrels to swing it").
  Explicit orders ("WOODMAN, CHOP TREE") route through the actor's
  ACTION routine to the same code path — both phrasings always work, and
  the plain verb alone is always sufficient (the parser-friendly rule).
- **Idle banter:** the same demon, when no scene is active, rolls
  1-in-6ish (PROB 15) and prints one bark from the current bark table.
  Tables are swapped by act/state: road banter (Act I-II), post-gift
  banter (Act IV), Lion-limping banter (after a botched P9), grief
  banter (while the Scarecrow is marooned), reunion song
  ("Tol-de-ri-de-oh!"), castle-night whispers. ~8 lines per table, each
  a two-voice exchange so the trio talks to each other, not at the
  player. Sample road barks:
  - "'What makes you a coward?' asks the Scarecrow. 'It's a mystery,'
    says the Lion. 'I suppose I was born that way.'"
  - "The Woodman steps carefully over an ant, and looks proud of it."
  - "'If your heads were stuffed with straw like mine,' says the
    Scarecrow, 'you would probably all live in beautiful places, and
    then Kansas would have no people at all.'"
- **Capability index (for the LLM layer and for hints):** Scarecrow =
  plans and reaching and being safely thrown; Woodman = chop, build,
  behead, cannot be stung; Lion = leap, swim, roar, fight. Every gated
  obstacle's failure text names the shape of the missing key.

### Toto

A free-roaming fun generator: never speaks, always present (moves with
Dorothy outside scenes), with his own tiny demon: 1-in-8 barks (chases a
butterfly, growls at the right thing a turn early — Toto is the game's
subtle danger-sense), plus scripted star turns: the trap-door rescue
(P1), biting the Witch (P18), and the screen (P24 — if the player goes
for LOOK BEHIND SCREEN themselves, Toto beats them to it by a whisker,
because that moment belongs to him). GIVE FOOD TO TOTO, PET TOTO,
TAKE TOTO all lovingly implemented; `TOTO, SPEAK` → "Toto only wags his
tail; for, strange to say, he cannot speak."

### The Witch of the West

Present in Act III as a scene-driver, not a combatant: one telescope eye
(EXAMINE from afar in WEST-FIELDS: "far off, a castle keeps one window
toward you like an eye"), the silver whistle heard before each wave, the
umbrella, the gloating, the hydrophobia planted in behavior. She cannot
be attacked (the companions are captured/caged by then; Dorothy's
attempts get "She is twice your reach, and anyway you were raised
polite") until the bucket resolves her, by the player's hand, in anger,
per the book.

### Minion waves & monkeys

Waves are scene battles the companions win with flavor when the player
calls the play (P16) — the game never demands combat mechanics. The
monkeys are unbeatable on arrival (P17) and glorious as taxis
thereafter; their King is courteous, bound, and finally freed by Glinda
— the game's quietest arc, and EXAMINE MONKEY KING at each meeting
tracks it ("he bows a little less like a servant this time").

---

## 6. Timers & danger (fair-death policy)

This is the most forgiving game of the five, second only to Alice:

- **Deaths: exactly one possible**, jumping into a gorge after two
  explicit warnings and a companion physically catching your sleeve the
  first time. JIGS-UP text is gentle and the restart-encouraging kind.
- **The poppy field** is a soft timer whose "failure" is the canonical
  story: collapse leads to rescue, always. Danger is felt (drowsiness
  escalation, Toto going down, the Lion falling short) but never punished.
- **The Kalidah window** (3 turns) fails into a scarier, sadder, still
  non-fatal version (mauled Lion, changed barks, lost points).
- **Capture, not death:** the monkeys, the castle, the balloon — the
  three biggest reversals are all scripted story, explicitly not player
  error, and the text says so each time.
- **No unwinnable states:** the Cap economy is railed by the Scarecrow
  (P22); the mice debt cannot be missed (P13 fallback); nothing needed
  later can be lost (the basket, whistle, cap, shoes are un-droppable in
  the sense that DROP is allowed but Toto retrieves anything critical
  left behind, with a look).
- **Hunger/sleep:** flavor only. Bread runs low on schedule and
  companions solve it (nuts, fruit — book beats); SLEEP is a scene
  advancer at designated beds, never a failable need.
- **Turn-limit pressure:** none globally. Local windows only (Kalidah),
  always with a survivable miss.

---

## 7. Scoring

SCORE-MAX 250. Points on first-time events (VALUE-style flags, awarded in
action routines):

| Deed | Pts | | Deed | Pts |
|---|---|---|---|---|
| Toto saved in the cyclone (both beats) | 5 | | Wolves / Crows / Bees / Winkies waves (5 each, player-called) | 20 |
| Silver Shoes worn | 5 | | Both night feedings of the Lion | 10 |
| Scarecrow recruited | 10 | | The Witch melted | 30 |
| Tin Woodman oiled & recruited | 10 | | The stolen shoe recovered & worn | 5 |
| Beetle jaws re-oiled | 5 | | Woodman rescued & mended | 10 |
| Lion slapped & recruited | 10 | | Scarecrow rescued & restuffed | 10 |
| First gorge crossed | 5 | | Golden Cap found & charm read | 10 |
| Kalidah bridge (clean, in the window) | 15 | | Cap use #1 (city) | 5 |
| Raft built & river crossed | 5 | | The screen & the humbug | 15 |
| Scarecrow saved by the Stork | 5 | | The three gifts witnessed | 5 |
| Mouse debt earned (player-called wildcat) | 10 | | Cap use #3 (Hammer-Heads) | 5 |
| Lion hauled from the poppies | 5 | | China country crossed clean (+ leg returned) | 5 |
| Spectacles worn (city entered) | 5 | | The Lion crowned | 5 |
| All four audiences held | 10 | | Cap given to Glinda | 5 |
| | | | Farewells (all three) | 5 |
| | | | Home to Kansas | 20 |
| china church | -1 | | | |

Ranks (book-flavored ascent):
- 0-39: **Munchkin Tourist**
- 40-89: **Friend of Scarecrows**
- 90-139: **Companion of the Road**
- 140-179: **Slayer of Nothing, Melter of One** (awarded name after the bucket)
- 180-219: **Royal Guest of Oz**
- 220-249: **Wearer of the Golden Cap**
- 250: **Honorary Sorceress** (the Munchkins had it right all along)

---

## 8. Intro & outro drafts (actual text)

### Intro (TTS cold open — played straight until the landing)

> Dorothy lived in the middle of the great Kansas prairie, in a one-room
> house with Uncle Henry, who never laughed, and Aunt Em, who never
> smiled, and Toto, who was a small black dog and did enough of both for
> everybody. When the sun and the wind had made everything else gray —
> the grass, the house, even Aunt Em — Toto stayed black as a boot
> button, and that is the sort of dog he was.
>
> Today nobody is laughing. The sky is grayer than usual, and from the
> north comes a low wail of wind, and from the south a sharp whistling,
> and Uncle Henry stands up very fast and says, "There's a cyclone
> coming, Em," and runs for the cows. Aunt Em throws open the trap door
> in the floor and is gone down the ladder into the dark, calling one
> thing behind her: "Quick, Dorothy! Run for the cellar!"
>
> But Toto has just gone under the bed.
>
> THE SILVER SHOES
> An interactive wonder tale, from the book by L. Frank Baum.
> (Type HELP at any time. Aunt Em would want you to.)

*(...and the first scripted beat after P1: "The house whirls around two
or three times and rises slowly through the air, like a balloon. This is
the strangest thing that has ever happened to you. You decide, sensibly,
to wait and see what happens next." — Baum's matter-of-factness
established in the first minute of play.)*

### Main outro — home to Kansas (warm)

> Three steps. That is all the desert amounts to, in silver shoes — three
> steps, each in the wink of an eye, with the wind whistling past your
> ears and Toto pressed warm against you. On the third step you go
> rolling in grass, and when you sit up, the shoes are gone from your
> feet — fallen somewhere over the desert, and lost forever, which
> somehow seems right. Magic shouldn't stay in Kansas. Kansas wouldn't
> know what to do with it.
>
> Because this IS Kansas. Flat and gray and going on to the edge of the
> sky in every direction — and there is a brand-new farmhouse Uncle
> Henry has built, and there is Aunt Em, watering the cabbages, looking
> up now, dropping her watering can.
>
> "My darling child! Where in the world did you come from?"
>
> "From the Land of Oz," you say gravely. "And here is Toto, too. And
> oh, Aunt Em — I'm so glad to be at home again!"
>
> Somewhere very far away, a scarecrow is ruling a city of emeralds, a
> tin man is being gentle to a country of grateful people, and a lion is
> sleeping in the good deep moss of his own forest, afraid of nothing.
> They had what they wanted all along. So, it turns out, did you.
>
> *** You have won *** 

### Alternate outro A — the balloon leaves without you (mid-game fake-out)

*(Plays at P26 in full "ending" formatting, then subverts.)*

> The ropes crack like a whip. The great green bag leaps for the sky as
> if it has been wanting to all along, and the little man peers down at
> you over the edge of the basket, getting smaller.
>
> "Come back!" you scream. "I want to go, too!"
>
> "I can't come back, my dear," calls the Wizard of Oz. "Good-bye!"
>
> And the whole Emerald City watches its Wizard shrink to a green speck
> and vanish, going home the way he came, alone. He was a humbug and a
> good man and the only person in two worlds who knew the way to Kansas,
> and you are standing in a palace plaza holding a small warm dog who is
> extremely pleased with himself about a kitten.
>
>      *** You have not won ***
>
> ...but you have not lost, either, whatever the sky says. Because the
> Scarecrow is already thinking — you can tell, because the pins are
> starting to stick out — and somewhere south of here, past soldiers'
> woods and a country made of china, lives the one person in Oz older
> and wiser and kinder than wizards. The story is not over.

### Alternate outro B — choosing to stay (optional, at Glinda's)

*(If the player, offered the heel-knock, instead tells Glinda STAY, or
NO, and confirms once: a real ending, scored below the true one.)*

> Glinda looks at you a long time, and does not smile, and does not
> frown. "The shoes will keep," she says at last. "Magic is patient.
> Homesickness is patient too, my dear — it will wait for you like a dog
> by a door."
>
> So the Scarecrow rules his city, and you are welcome in it always; and
> the Winkies bank the tinsmiths' fires for winter, and you are welcome
> there too; and on warm nights a Lion walks you through his forest and
> shows you, shyly, how none of it is frightening anymore. It is a good
> life, in the prettiest country in any world. And some evenings, on the
> palace roof, under the green stars, you knock your heels together
> softly — one, two — and stop, and look east, and go back down to
> dinner.
>
> Aunt Em is watering the cabbages. She looks up at the sky sometimes.
>
> *** You have stayed *** 
>
> (There is another ending. You know the way home; you have always known
> the way home.)

---

## 9. Walkthrough (complete, numbered, minimal-but-scoring path)

Prologue & Act I:
1. `LOOK UNDER BED`
2. `GET TOTO`
3. `GET TOTO` (mid-flight, from the trap door)
4. `CLOSE TRAP DOOR`
5. `SLEEP` (the house lands; wake)
6. `OPEN DOOR` / `OUT` (→ CLEARING; Witch of the North scene plays; wait two turns while the feet dry)
7. `TAKE SHOES`
8. `WEAR SHOES` (kiss + slate scripted)
9. `WEST` (→ YELLOW-ROAD)
10. `SOUTH` (→ CORNFIELD)
11. `LIFT SCARECROW` (recruit #1)
12. `NORTH`, 13. `WEST` (→ FOREST-ROAD)
14. `NORTH` (→ WOODMAN-COTTAGE)
15. `TAKE OIL CAN`
16. `NORTH` (→ SPRING-GLADE; the groan)
17. `OIL WOODMAN` (three beats play; recruit #2; he lowers the axe)
18. `SOUTH`, 19. `SOUTH` (→ FOREST-ROAD), 20. `WEST` (→ BRAMBLE-ROAD)
21. `WEST` (Woodman chops through; → DEEP-FOREST; Lion ambush begins)
22. `SLAP LION` (recruit #3)
23. `WEST` (beetle scene fires en route; → GORGE-EDGE)
24. `OIL WOODMAN` (the jaws; +5)

Act II:
25. `RIDE LION` (gorge crossed; → KALIDAH-WOOD)
26. `WEST` (→ SECOND-GORGE)
27. `CHOP TREE` (bridge falls across)
28. `CROSS TREE` (Kalidahs charge mid-crossing)
29. `CHOP TREE` (bridge cut; Kalidahs fall; → RIVERBANK)
30. `BUILD RAFT` (night passes)
31. `BOARD RAFT`
32. `LAUNCH` (drift scripted; Scarecrow marooned; Lion tows; → FAR-BANK)
33. `NORTH` (→ STORK-BEND)
34. `TELL STORK ABOUT SCARECROW` (rescue; reunion; "Tol-de-ri-de-oh!")
35. `NORTH` (→ POPPY-FIELD; drowsiness begins)
36. `NORTH` (drowsier)
37. `NORTH` (collapse → carried → wake at GREEN-BANK; Lion asleep in the poppies; wildcat scene begins after 2 turns)
38. `KILL WILDCAT` (Woodman executes; Queen's gratitude)
39. `ASK QUEEN TO SAVE LION` (truck rescue scripted; receive MOUSE WHISTLE)
40. `EAST` (→ GREEN-ROAD; farmhouse rumors of Oz play)
41. `EAST` (→ CITY-GATE)
42. `PUSH BUTTON` (bell; gate opens; → GATE-ROOM)
43. `WEAR SPECTACLES` (all fitted & locked)
44. `IN` (→ EMERALD-STREET)
45. `NORTH` (→ PALACE-COURT; soldier takes the message)
46. `UP` (→ GREEN-CHAMBER)
47. `SLEEP` (morning; summoned)
48. `DOWN`, 49. `NORTH` (→ THRONE-ROOM; the HEAD)
50. `SAY DOROTHY` (or any honest answer; the interrogation plays)
51. `SAY FROM THE WITCH OF THE EAST` (shoes question)
52. `SAY THE WITCH OF THE NORTH KISSED ME` (mark question; the price is named; audience ends)
53. `SOUTH`, 54. `UP`, 55. `SLEEP` (Scarecrow's day — the LADY, retold)
56. `SLEEP` (Woodman's day — the BEAST, retold)
57. `SLEEP` (Lion's day — the BALL OF FIRE, retold; departure prep scripted)
58. `DOWN`, 59. `SOUTH`, 60. `SOUTH` (→ GATE-ROOM; spectacles unlocked)
61. `OUT`, 62. `WEST` (→ WEST-FIELDS; the dress turns white; distant whistle — one blast)

Act III:
63. `ATTACK WOLVES` (Woodman's forty; wave 1 down; second whistle-blast heard)
64. `LIE DOWN` (crows scattered & wrung by the Scarecrow; wave 2; third blast)
65. `WEST` (→ WEST-HILLS; bees swarm)
66. `SCATTER STRAW` (bees break on tin; Scarecrow restuffed; Winkie spearmen approach)
67. `ROAR` (Lion routs them; then darkness, wings — capture scripted; → castle doorstep → CASTLE-KITCHEN)
68. `SWEEP FLOOR`
69. `CLEAN POTS` (day 1 done; night falls)
70. `OPEN CUPBOARD`, 71. `TAKE MEAT`
72. `NORTH`, 73. `EAST` (→ COURTYARD)
74. `GIVE MEAT TO LION` (night feeding 1; escape talk on his mane)
75. `WEST`, 76. `UP`, 77. `SLEEP` (→ day 2), 78. `DOWN`, 79. `SOUTH`
80. `PUT WOOD ON FIRE`, 81. `SWEEP FLOOR` (day 2 done)
82. `TAKE MEAT`, 83. `NORTH`, 84. `EAST`, 85. `GIVE MEAT TO LION` (feeding 2)
86. `WEST`, 87. `UP`, 88. `SLEEP` (→ day 3), 89. `DOWN`, 90. `SOUTH` (→ KITCHEN: the trip, the theft — she has your shoe and she is laughing)
91. `THROW WATER AT WITCH` (the melt; +30; "Look out—here I go!")
92. `TAKE SHOE`, 93. `DRY SHOE`, 94. `WEAR SHOE`
95. `SWEEP FLOOR` (the mess, out the door; the chore verb's punchline)
96. `OPEN CUPBOARD`, 97. `TAKE CAP` (the GOLDEN CAP)
98. `WEAR CAP`, 99. `READ CAP` (the charm, in full)
100. `NORTH`, 101. `EAST` (→ COURTYARD), 102. `OPEN GATE` (Lion freed; Winkie holiday)
103. `WEST`, 104. `WEST` (→ ROCKY-PLAIN, with Winkie bearers)
105. `ASK WINKIES FOR HELP` (Woodman carried home; tinsmith montage; gold handle)
106. `WEST`, 107. `NORTH` (→ TALL-TREE)
108. `CHOP TREE` (the bundle falls)
109. `TAKE CLOTHES`, 110. `SOUTH`, 111. `EAST` (→ castle; courtyard straw)
112. `STUFF SCARECROW` (restuffed; reunion; Winkie gifts scripted at departure)
113. `EAST` (leaving; → LOST-FIELDS; wander once for flavor if you like)
114. `BLOW WHISTLE` (the Queen: "use the charm of the Cap!"; mice scatter)
115. `SAY EPPE` (left foot)
116. `SAY HILLO` (right foot — the Woodman calmly replies "Hello!")
117. `SAY ZIZZY` (both feet; wings; the King bows: "What is your command?")
118. `FLY TO EMERALD CITY` (Cap use #1; Gayelette story in flight; → CITY-GATE)

Act IV:
119. `PUSH BUTTON`, 120. `WEAR SPECTACLES`, 121. `IN`, 122. `NORTH` (the city cheers the Witch-melter; Oz stalls...)
123. `UP`, 124. `SLEEP` (no word), 125. `SLEEP` (no word)
126. `DOWN`, 127. `SEND MESSAGE TO OZ` (the monkey threat; 9:04 appointment set)
128. `NORTH` (→ THRONE-ROOM, all four together; the empty room; the Voice)
129. `LION, ROAR` (Toto leaps — the screen topples — a little old man)
130. `ASK OZ ABOUT HUMBUG` (confession beats; "Exactly so! I am a humbug.")
131. `EAST` (→ WORKSHOP; props tour)
132. `EXAMINE HEAD`, 133. `EXAMINE MASK`, 134. `EXAMINE SKINS`, 135. `EXAMINE COTTON BALL`
136. `PROMISE` (keep the secret; gifts tomorrow)
137. `WEST`, 138. `SOUTH`, 139. `UP`, 140. `SLEEP` (gift morning)
141. `DOWN`, 142. `NORTH` (the three gifts play: brains, heart, courage; +5)
143. `SOUTH`, 144. `SOUTH`, 145. `EAST` (→ BALLOON-PLAZA over build days, scripted with one `SEW SILK` if you linger)
146. `WAIT` (launch day; the speech; Toto bolts)
147. `GET TOTO` (the ropes crack — the balloon rises — fake-out outro plays)
148. *(optional, the book's beautiful waste — only if you accept spending a command:)* `SAY EPPE`, `SAY HILLO`, `SAY ZIZZY`, `FLY TO KANSAS` → the King's grave refusal (Cap use #2 spent; the Scarecrow will block this if it would strand you — see P22)
149. `SOUTH` (→ FIGHTING-TREES; a branch flexes at you)
150. `CHOP BRANCH` (the tree recoils; Toto snatched & freed; pass)
151. `SOUTH` (→ CHINA-WALL)
152. `BUILD LADDER` (overnight; ladder done)
153. `CLIMB LADDER` ("Oh, my!" ×4)
154. `JUMP` (onto the Scarecrow, carefully avoiding the pins; → CHINA-COUNTRY)
155. `TALK TO PRINCESS` ("Don't chase me!"; the mending speech)
156. `GIVE LEG TO MILKMAID` (if taken: fetched one room over; forgiveness, small points)
157. `SOUTH` (→ far wall), 158. `CLIMB ON LION` (up the wall; his leap; the china church, -1, worth it)
159. `SOUTH` (→ QUADLING-FOREST; the assembly of beasts; the tiger's plea)
160. `LION, KILL SPIDER` (his solo; the crown; pride all round)
161. `SOUTH` (→ HAMMER-HILL; "Keep back!")
162. `CLIMB HILL` (the Scarecrow demonstrates why not, involuntarily)
163. `SAY EPPE`, 164. `SAY HILLO`, 165. `SAY ZIZZY` (the last summons — "(You will then have no commands remaining.)")
166. `FLY OVER HILL` (Cap use #3; vexed heads below; → QUADLING-FARM; the King's goodbye)
167. `SOUTH` (cake & cookies scripted; → GLINDA-THRONE)
168. `TELL GLINDA ABOUT JOURNEY` (she hears everything; then her price)
169. `GIVE CAP TO GLINDA` (her three uses named; the Monkeys freed; the shoe secret told)
170. `KISS LION`, 171. `KISS WOODMAN`, 172. `HUG SCARECROW` (the farewells; bring a handkerchief)
173. `KNOCK HEELS TOGETHER` ("The shoes await your command.")
174. `SAY TAKE ME HOME` (three steps; the desert; the shoes falling away; → KANSAS-PRAIRIE; the true outro; 250/250 if all optional deeds done)

*(Solvability check: every gate above is passed by a command shown at or
before the gate, every consumable exists before its lock, the Cap's two
required uses are protected by the Scarecrow rail, and the two "lost"
companions are recoverable by forced-order puzzles with explanatory
failure text. No unmarked dead ends; the only death is double-guarded.)*

---

## 10. Writing style guide (CRITICAL — TTS-voiced)

1. **Length:** most responses 1-3 sentences; hard max two short
   paragraphs, and only for scene payoffs (the melt, the reveal, the
   outros). Room descriptions ≤3 sentences. Barks are one line.
2. **No visual formatting.** No ASCII art, no tables, no bullet lists in
   game text, no ALL-CAPS shouting (magic words excepted, and even those
   are printed hyphenated exactly as Baum spells them, which TTS reads
   charmingly: "Ep-pe, pep-pe, kak-ke!").
3. **Baum's register:** plainspoken warmth; miracles reported like
   weather; short declarative sentences with an occasional long,
   comfortable one. Never sarcastic, never winking at the player over
   the characters' heads. The narrator is kind.
4. **Jokes from character, not snark.** The comedy is the Scarecrow's
   logic, the Woodman's courtesy vs. his body count, the Lion's
   announced terror, Toto's timing. Failure text jokes are gentle and
   always end with a nudge toward the solution.
5. **Ear-first geography:** exits spoken in prose ("The road runs on to
   the west; a blue fence borders a cornfield to the south"), colors as
   region markers (blue → green → yellow → red, the book's own scheme —
   say the color often; it is the audio map).
6. **Names:** "the Scarecrow," "the Tin Woodman," "the Lion" with
   articles in narration, bare in address. The Witch of the West is "the
   Witch" only inside her castle — proximity shortens her name, which
   reads as dread.
7. **Quote Baum where he's best**, adapt where he's long. Signature
   lines land verbatim: "That isn't the way we Lions do these things";
   "I am a humbug"; "Look out—here I go!"; "I'm so glad to be at home
   again!"
8. **Second person, present tense** for play; the intro/outros may go
   past-tense storybook. Dorothy's speech is rendered when the player
   SAYs things — keep her voice plain and polite.
9. **Never describe the film's imagery.** Silver, not ruby; an umbrella,
   not a broom; a one-eyed Witch in her own castle, not a green face in
   a crystal ball.

---

## 11. Build notes (czil / zork1 engine, v3 limits)

**Counts vs limits:** 44 rooms + ~85 objects (companions, NPCs, props,
scenery, engine stubs) ≈ 130 objects — comfortably under 255. Dictionary
well under limits. Text volume (~all the scene prose) is the risk for
the 128KB v3 ceiling: with abbreviation compression on, a Zork-I-sized
game fits; this design is comparable. **Recommendation: author against
v3 from day one but keep the v8 line in the main file
(`<VERSION? (ZIP) (T <INSERT-FILE "V8PATCH" T>)>`) so an overflow of
text or flags is a one-flag rebuild, not a refactor** (per AUTHORING.md;
tinyquest already proves byte-identical transcripts across v3/v8).

**Flags budget (v3: 32 total, engine uses most):** stay under ~10 new by
using GLOBAL variables, not object flags, for all narrative state:
`ACT`, `DAY`, `POPPY-COUNT`, `CAP-USES`, `WITCH-STATE`, `WAVE`,
companion state words, etc. Object flags reserved for engine semantics
(TAKEBIT, WEARBIT, CONTBIT, INVISIBLE, PERSON, NDESCBIT). The iron bar
uses INVISIBLE literally.

**6-char dictionary plan** (parser sees only the first 6 letters):
- SCARECROW → `SCAREC` (fine; no collision; also SYNONYM STRAW-MAN? no —
  STRAW is its own object; do NOT give the Scarecrow a STRAW synonym).
- SPECTACLES → `SPECTA`; add SYNONYM GLASSES (distinct).
- WOODMAN → fits; also TIN adjective, NICK? no. WOODMAN vs WOOD
  (firewood): distinct words (≤6 letters each, no truncation collision).
- MONKEYS → `MONKEY` (fine); KING adjective for the King.
- WHISTLE → `WHISTL` — only the mouse whistle is referenceable (the
  Witch's silver whistle is scenery inside scripted scenes, no noun).
- SILVER: adjective on SHOES only. The Witch's whistle is never a noun,
  avoiding SILVER ambiguity.
- KALIDAHS → `KALIDA`; GUARDIAN → `GUARDI`; UMBRELLA → `UMBREL`;
  PRINCESS → `PRINCE` — **collision with PRINCE if one existed; none
  does, but note it**; BUTTERCUPS etc. scenery-only.
- HAMMER-HEADS: word HAMMER + HEADS; accept HAMMER as the noun
  (ADJECTIVE FLAT?) — simplest: SYNONYM HEADS, ADJECTIVE HAMMER.
- EPPE / HILLO / ZIZZY: safe short forms of the charm words (the printed
  text keeps Baum's full hyphenated spellings; the parser accepts the
  first word of each line, plus HELLO → engine already has HELLO verb —
  **hazard:** HIL-LO must not be entered as HELLO; accept HILLO and
  HOLLO; if the player types HELLO mid-ritual, the Woodman answers
  "Hello!" (book joke) and the ritual waits, unbroken.
- SAY: engine has SAY; magic-word style also allows bare `EPPE` as a
  command (define as verbs, like PLUGH in gsyntax — precedent exists,
  ODYSSEUS/PLUGH are in the table).
- Every takeable object: ≤4 SYNONYM words (v3 8-byte property cap).

**Stock verbs used (from `zil/zork1/gsyntax.zil` — no new machinery):**
TAKE/GET, DROP, OPEN, CLOSE, EXAMINE, READ, WEAR (via TAKE? engine has
WEARBIT; DRESS handled by TAKE/WEAR syntaxes), PUT, POUR, THROW, RUB,
FOLLOW, KISS, KNOCK, CLIMB, JUMP, RIDE→BOARD, CROSS, CUT/CHOP (CUT
exists; add CHOP as SYNONYM verb), OIL→LUBRICATE (exists as SYNTAX
LUBRICATE — map OIL as synonym), BLOW, ROAR→ (new, tiny), SLAP→ (map to
ATTACK/HIT with bare hands special-case), SWEEP→BRUSH (exists BRUSH; add
SWEEP synonym), CLEAN→RUB/BRUSH, FILL, GIVE, TELL/ASK (engine
conversation verbs), LISTEN, SMELL (poppies!), SLEEP (engine), WAIT,
SAY, PUSH, PULL, MOVE, LOOK UNDER, BOARD/DISEMBARK, LAUNCH (exists),
STAND, HELLO (exists — see hazard above).

**New verbs (few, small):** CHOP (synonym of CUT with better defaults),
OIL (synonym of LUBRICATE), SWEEP (synonym of BRUSH), ROAR, STUFF, SEW,
HUG (map to KISS handler), CLICK/KNOCK HEELS (special SYNTAX on SHOES),
SUMMON (convenience for the ritual), FLY (post-summon command routing),
PROMISE. Each is a one-routine SYNTAX per AUTHORING.md's POLISH example.

**Companion machinery on the Zork actor model:**
- Companions: `(FLAGS PERSON)` objects; a single `PARTY-DEMON` C-INT
  (enabled at first recruit) moves IN-PARTY companions to HERE each turn
  and rolls the bark table (PROB-gated, suppressed during scenes via a
  `SCENE-FLAG`).
- Orders ("WOODMAN, CHOP TREE") arrive via the engine's actor-command
  path (WINNER switching, as Zork II's robot); each companion's ACTION
  routine dispatches known orders to the same routines the plain verbs
  use, and answers unknown orders in voice ("'I would,' says the Lion,
  'but I don't see how, and I'm frightened besides.'").
- Scene battles are room-ACTION state machines keyed on `WAVE` /
  `SCENE-FLAG` globals with per-turn advancing text — the same shape as
  Zork's loud-room/dam sequences, well within engine idiom.
- Toto: separate tiny demon; never IN-PARTY-managed (he is scripted to
  Dorothy).

**Engine content stubs required** (copy the tinyquest pattern): GO
routine (banner, HERE=FARMHOUSE, V-LOOK, MAIN-LOOP), V-SCORE/V-DIAGNOSE,
JIGS-UP (one custom gorge death text), FIND-WEAPON returning false (all
"combat" is scene text — the engine's melee never runs), SCORE-MAX 250,
WATER/GLOBAL-WATER (reused meaningfully for the bucket!), WALL (reused
for the china wall's generic responses), ON-LAKE/IN-LAKE unreachable
stubs, FLAG-CARRIER with NONLANDBIT. GGLOBALS inserted BEFORE the
dungeon file (the IT-vs-direction-property trap in AUTHORING.md).

**Scene-heavy design risks & mitigations:**
1. *Text budget:* the biggest scenes (audiences, melt, reveal, outros)
   total a lot of prose. Mitigate: v8 escape hatch; abbreviations on;
   share phrasing via routines (e.g., one AUDIENCE-FRAME routine).
2. *Scripted-sequence brittleness:* MIDRIVER/capture/balloon are
   auto-advancing; ensure every player input during them gets an
   in-fiction response (a catch-all in the room ACTION) so the scripted
   turns never feel dead. Test each with the scripted player (play.mjs)
   including garbage input.
3. *Parser addressing:* "WOODMAN, CHOP" must never be the ONLY solution
   to anything — plain-verb routing is the guaranteed path everywhere
   (rule enforced in section 4's puzzle specs).
4. *The day/SLEEP loop:* days advance only at designated beds; guard
   with clear prompts ("You are not sleepy yet, and the green bed looks
   like it would take that personally") to avoid unintended skips.
5. *Walkthrough as CI:* freeze section 9 as `walkthrough.txt` from the
   first compile; every scene edit re-verified by transcript diff, per
   AUTHORING.md's loop. Add a second "chaos" walkthrough that tries
   wrong verbs at every gate to lock the failure text.
6. *LLM layer:* the fixed intro asks for HELP affordance; keep the
   dictionary generous with synonyms (LLM players rephrase — every gate
   accepts ≥3 phrasings above) and keep room DESCs short/title-case for
   the status line.
