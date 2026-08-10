# DESIGN: WONDERLAND — a text adventure of Alice's Adventures in Wonderland

Target: czil compiler + Zork I engine files (`zil/zork1`), v3 story file
(v8 fallback available if limits pinch). Companion document: STUDY.md (all
quotes sourced there). Everything below is implementable from this file alone.

---

## 1. Vision & tone

Wonderland is the one book in the language that already behaves like a great
text adventure: it is a chain of rooms, each owned by an unreasonable
character, navigated by a polite, stubborn child who tries verbs on the world
until something gives. The player fantasy is **being clever in a mad world**
— every absurd thing the player tries should get a Carroll-worthy answer, and
the game should feel like it has an answer for everything. Where Zork's
narrator is dry and slightly superior, Carroll's is dry, precise, and fond of
you; we play in exactly that register.

Three tone rules, enforced everywhere:

1. **Logic is the joke.** Failure text never says "You can't do that." It
   gives a *reason*, and the reason is airtight and insane. (KNOCK: "There's
   no sort of use in knocking, and that for two reasons...")
2. **Politeness works; temper never does.** NPCs reward civility with
   progress and punish rudeness with sulking, not damage.
3. **Nothing bad ever really happens.** Every execution is fancy, every fall
   is soft, every drowning is a swim. The game is forgiving BY CANON.

The core system is **size**. It is a single global state that the whole world
reads: which exits pass, what you can lift, who takes you seriously, and how
rooms are even described. Act 1 teaches it through Carroll's own tutorial
tragedy (one-shot consumables in the wrong order); the mushroom then converts
it into a reusable player tool for the rest of the game.

## 2. Structure

Carroll's picaresque gets a spine made of his own materials:

- **The goal, stated early and twice** (it is a quote): "The first thing I've
  got to do is to grow to my right size again; and the second thing is to
  find my way into that lovely garden."
- **The White Rabbit is the trail.** He appears at every act boundary
  (riverbank, hall, the Mary Ann errand, the procession, the herald at
  trial), always hurrying somewhere the player should go next.
- **Act 1 — The Hall of Doors (tutorial, lightly scripted).** The key/bottle/
  cake sequencing tragedy, the pool of tears, the fan. Ends swept into the
  pool. Unfailable, but it teaches: size gates exits, order matters,
  consumables are one-shot.
- **Act 2 — Wonderland at large (open).** Shore, Rabbit's house, the wood,
  the Caterpillar (mushroom = the key item), the Duchess's kitchen, the
  Cheshire Cat, the tea party. The player collects: mushroom pieces,
  invitation, pepper-box, treacle (in the act-1 marmalade jar), the Hatter's
  goodwill, the Rabbit's gloves. The tree-with-a-door loops back to the hall.
- **Act 3 — The hall done RIGHT, then the garden.** Unlock first, then
  shrink: the book's own stated solution, now performable at will with the
  mushroom. Garden, croquet, Gryphon, Mock Turtle.
- **Finale — The trial.** A soft-timer set piece where gathered items and
  learned facts pay out as points and jokes, ending on the player speaking
  the book's own winning move: "Stuff and nonsense!"
- **Outro** — waking on the riverbank, done warmly (the book's ending is a
  gift, not a cheat). One hidden alternate ending: stay mad for tea forever.

### 2.1 The size system (the one mechanic to build first)

Global `ALICE-SIZE`: 1 = SMALL (a few inches to a foot), 2 = NORMAL,
3 = LARGE (nine feet). Three states only; the book's finer gradations are
flavor text within a state.

Changers:

| Source | Effect | Notes |
|---|---|---|
| DRINK ME bottle | → SMALL, one shot | violent "telescope" shrink: you drop the golden key (it rings onto the glass table) and any open door in the hall slams in the draught. Scripted, announced, canon. |
| EAT ME cake | → LARGE, one shot | head against the hall roof |
| the fan | one step smaller per use, repeatable | using it at SMALL nearly snuffs you "like a candle": you drop it just in time (auto; never fatal) |
| unlabeled bottle (Rabbit's house) | → room-filling trap state | special state, see puzzle P7 |
| pebble-cake | → SMALL, one shot each | one eaten to escape the house; one pocketable spare |
| mushroom LEFT piece | one step larger, infinite | see overshoot rule below |
| mushroom RIGHT piece | one step smaller, infinite | see overshoot rule below |

Mushroom overshoot rule: the FIRST nibble of the mushroom (whichever piece)
plays its overshoot script — LEFT: the serpent-neck scene, ending at LARGE
regardless of start; RIGHT: the chin-strikes-foot scene, ending at SMALL —
and every nibble after the first moves exactly one step, forever. (One
scripted comedy beat, then a perfectly predictable tool.)
| the trial | creeping auto-growth | scripted, SMALL→NORMAL→LARGE across the trial beats |

World reads (implement as room/exit routines checking `ALICE-SIZE`):
- Exits: the little garden door and its passage (SMALL only); the Duchess's
  four-foot house (SMALL only); the bramble tunnel past the puppy (SMALL
  only); the old well (SMALL only); the hall mouse-hole (SMALL only); the
  treetops above the Thick Wood (LARGE only).
- Reach/strength: the golden key cannot be carried at SMALL ("nearly as long
  as you are; you could no more walk off with it than with a ladder"); the
  glass table cannot be climbed ("too slippery").
- Society: the Queen literally does not see a SMALL Alice; the Pigeon
  classifies a LARGE Alice as a serpent; the flamingo cannot be held except
  at NORMAL.
- Descriptions: rooms with size-variant text carry two or three LDESC
  variants (see map). This is free comedy; spend it.

The gentle/violent distinction is load-bearing: **mushroom nibbles never slam
doors**; only the bottle's telescoping does. (The Cheshire Cat will explain
if asked: "Bottle magic is sudden, and doors take advantage. Mushroom magic
is gradual, and doors never notice. That is why we are all so fond of
mushrooms here.") This is what makes Act 1's trap airtight while Act 3's
solution — unlock, open, nibble, walk through — works.

## 3. The map

26 rooms. Status-line DESCs in title case, 22 chars max.

```
ABOVE GROUND                    UNDERGROUND (Wonderland)

Riverbank                                    Treetops (LARGE only)
   |  (follow rabbit)                            |up
Hedge Field                     Mushroom <--- Thick Wood <- Rabbit Lawn -- Tidy Room
   |  down (one way,            Clearing tunnel  |            |   (in/up)
   |  the fall)                 (SMALL)          |         Sandy Path
Bottom of the Well                               |            |
   |north                                     Crossroads   Shore
Low Passage                                  /   |    \       |
   |north                       Duchess Lawn     |    Tea Garden   Pool of Tears
  HALL OF DOORS  -- e (SMALL) -> Mouse Hole      |        |well(SMALL)   (swim w->Shore)
   |  little door (SMALL,       (in: Kitchen)    |    Treacle Well
   |  unlocked+open)                          Door-Tree Wood
   v                                             |(enter tree)
Beautiful Garden --- e --- Fountain Walk         +--> back to HALL
   |north
Croquet Ground --- e --- Seaside Ledge --- e --- Turtle Rock
   |
Courtroom  (entered by Gryphon script; exits only by waking)
```

Pool of Tears floods the low end of the hall once it exists; entering it
happens by scripted slip, leaving it by swimming west to Shore.

Room-by-room. Format: NAME (status DESC) — description(s) — exits — contents.
All descriptions are written for the ear (see style guide) and are the
actual proposed text.

---

**1. RIVERBANK ("Riverbank")**
LDESC: "You are sitting on the riverbank beside your sister, who is reading
a book with no pictures or conversations in it. The afternoon is hot and
impossibly drowsy, and the daisies are almost worth picking."
- Events: turn 2, the White Rabbit runs past ("Oh dear! Oh dear! I shall be
  late!" — it takes a watch out of its waistcoat-pocket). It heads north.
- Exits: NORTH / FOLLOW RABBIT → HEDGE-FIELD (only after the rabbit passes;
  before that: "There is nothing worth getting up for. Yet.")
- Contents: sister (scenery NPC, deflects everything sweetly), book
  (scenery: "It has no pictures or conversations in it. What is the use of
  it?"), daisies (PICK DAISIES: "You gather a few, for a chain you will
  never finish.").
- This is also the outro room.

**2. HEDGE-FIELD ("Under the Hedge")**
LDESC: "You are at a great hedge at the edge of the field. Under it gapes a
large rabbit-hole, and from somewhere down it comes a fading voice: 'Oh my
ears and whiskers, how late it's getting!'"
- Exits: DOWN / ENTER HOLE → the fall (scripted, below). SOUTH → RIVERBANK
  ("Your sister would only tell you to stop imagining things.").

**The fall (scripted interlude, 3 turns, not a room the player can stay in).**
Turn 1: "In another moment down you go after it, never once considering how
in the world you are to get out again. The hole dips suddenly down, and you
are falling — slowly, comfortably, absurdly — past shelves and cupboards set
into the walls of the well. A jar drifts by at arm's length, labelled ORANGE
MARMALADE." (TAKE JAR works this turn and the next; it is empty.)
Turn 2: "Down, down, down. You wonder how many miles you have fallen, and
whether cats eat bats, and whether bats eat cats, and find you cannot answer
either question, which makes them equally good questions."
Turn 3: "Thump! Thump! You land on a heap of sticks and dry leaves, not a
bit hurt." → LEAF-HEAP. (Any command not TAKE JAR/inventory just advances
the fall with these texts; there is nothing to fail.)

**3. LEAF-HEAP ("Bottom of the Well")**
LDESC: "A heap of sticks and dry leaves at the bottom of the well, which is
all dark overhead. A long passage runs north, and down it, still in sight,
hurries the White Rabbit."
- Exits: NORTH → LOW-PASSAGE. UP: "It is all dark overhead, and rabbit-holes
  do not run backwards."

**4. LOW-PASSAGE ("Long Low Passage")**
LDESC: "A long, low passage. As you enter, the White Rabbit turns a corner
ahead, saying 'Oh my ears and whiskers, how late it's getting!' — and is
gone."
- Exits: NORTH → HALL, SOUTH → LEAF-HEAP.

**5. HALL ("Hall of Doors")**
LDESC (NORMAL): "You are in a long, low hall, lit by a row of lamps hanging
from the roof. Doors stand all round it, every one of them locked. In the
middle is a little three-legged table made of solid glass, and along one
wall hangs a low curtain."
LDESC (SMALL): "The hall is a cathedral now, its lamps far as stars. The
glass table stands over you like a monument on stilts; its top might as well
be the moon. Down by the skirting-board, quite at your own scale, is a
tidy little mouse-hole."
LDESC (LARGE): "You fill a startling amount of this hall, and stoop so your
head does not strike the roof. The doors look like doll-house furnishings,
and the glass table stands about knee-high."
- Contents: glass table (surface; golden key on it at start; DRINK ME bottle
  appears by script), curtain (concealing the little door), big doors
  (scenery, one object: locked forever, comedy responses), little door
  (behind curtain), glass box with EAT ME cake under the table (found only
  when SMALL: "Down here you can see under the table, and there, quite
  overlooked from above, lies a little glass box."), mouse-hole (visible and
  enterable only when SMALL), pool of tears (after crying; see events).
- Exits: SOUTH → LOW-PASSAGE. Little door (WEST) → GARDEN, passable only if
  door open AND SMALL; at NORMAL/LARGE: "You cannot even get your head
  through; and even if your head would go through, it would be of very
  little use without your shoulders." EAST → MOUSE-HOLE when SMALL. When the
  pool exists and you become SMALL in this room, a scripted slip carries you
  into POOL (see P5).
- Full puzzle script in section 4 (P2–P5).

**6. MOUSE-HOLE ("Mouse-Hole")** — SMALL-gated secret.
LDESC: "A snug hole behind the skirting-board, floored with a scrap of
carpet and furnished above your ambitions. Somebody keeps house here, and
keeps it better than you keep yours."
- Contents: sixpence ("a silver sixpence, polished to a shine"), a saved
  comfit (flavor food).
- Exits: WEST → HALL.

**7. POOL ("Pool of Tears")**
LDESC: "You are up to your chin in salt water, in a pool that was not here
this morning, on account of your having wept it yourself. Shores of the
hall rise dimly to the west."
- Contents: the Mouse (swimming; the conversation happens en route).
- Exits: WEST / SWIM → SHORE ("You strike out, and something furry strikes
  out beside you..."). All other directions: "Everything in every direction
  is regrettably tears."
- No drowning is possible: WAIT enough and the current delivers you west
  anyway ("Being drowned in your own tears would be a queer thing, to be
  sure; the pool declines to allow it.").

**8. SHORE ("Queer Shore")**
LDESC (first): "A gravel shore, crowded with the queerest company: a Mouse,
a Dodo, a Lory, an Eaglet, a Duck, and an old Crab with her daughter — all
dripping wet, cross, and uncomfortable, yourself included."
LDESC (after race): "The gravel shore, lately a racecourse. The company has
mostly wandered off to be dry somewhere else."
- Contents: Mouse, Dodo, birds (one collective object + Mouse + Dodo).
- Exits: EAST → SANDY-PATH. WEST → the pool has soaked away after the race
  ("The pool has quite soaked into the gravel, as pools of tears do once
  they have been properly raced beside.").

**9. SANDY-PATH ("Sandy Path")**
LDESC: "A neat sandy path between hedges, the sort a very house-proud
rabbit would rake twice daily."
- Event (first entry): the White Rabbit trots up, sees you: "Why, Mary Ann,
  what ARE you doing out here? Run home this moment, and fetch me a pair of
  gloves and a fan! Quick, now!" — then hurries off east.
- Exits: WEST → SHORE, EAST → RABBIT-LAWN.

**10. RABBIT-LAWN ("Outside Rabbit's House")**
LDESC: "A neat little house with a bright brass plate on the door, engraved
W. RABBIT. The garden beds are all radishes."
- Contents: brass plate (READ), house (ENTER).
- Exits: IN / ENTER → RABBIT-ROOM (blocked while you are LARGE inside — see
  P7 — and blocked at LARGE generally: "You would wear the house like a
  boot."), WEST → SANDY-PATH, SOUTH → THICK-WOOD.
- During P7 this lawn hosts the crowd (Rabbit, Pat, Bill, guinea-pigs).

**11. RABBIT-ROOM ("Tidy Little Room")**
LDESC: "A tidy little room with a table in the window. On the table lie a
fan and two or three pairs of tiny white kid gloves, and by the
looking-glass stands a little bottle with no label at all."
LDESC (while grown, trap state): "You ARE the room, more or less. One arm
out of the window, one foot up the chimney, and your elbow hard against the
door. The ceiling makes a personal remark of itself against your head."
- Contents: spare fan, white gloves, unlabeled bottle, looking-glass
  (EXAMINE: "It reflects rather more of you than you remembered owning."),
  window, chimney (both usable in P7).
- Exits: OUT / DOWN → RABBIT-LAWN (blocked while grown: "In your present
  acreage you no longer fit through anything the house has to offer.").

**12. THICK-WOOD ("Thick Wood")**
LDESC (NORMAL): "A thick wood of quite ordinary trees, with a bramble bank
to the west and something scuffling hopefully about your ankles — a puppy,
delighted with you."
LDESC (SMALL): "The wood from down here is a country of huge stems and
towering thistles. To the west, a tunnel runs under the bramble bank —
comfortably your size, which is to say tiny. Above you stands AN ENORMOUS
PUPPY, with round eyes the size of cart-wheels."
LDESC (LARGE): "Your head is up among the branches. Below, the wood spreads
its leaves like a green sea; above, there is only sky and a very
disapproving pigeon."
- Contents: puppy, stick ("a little bit of dead stick"), thistle, brambles.
- Exits: NORTH → RABBIT-LAWN, SOUTH → CROSSROADS, WEST (bramble tunnel) →
  MUSHROOM-CLEARING, SMALL only, and only when the puppy is occupied (P8);
  at NORMAL/LARGE: "The tunnel under the brambles would suit a rabbit, or a
  very small girl; you are at present neither." UP → TREETOPS, LARGE only
  ("You would need to be a great deal more girl than this to reach the
  treetops.").

**13. TREETOPS ("Above the Wood")** — LARGE-gated secret.
LDESC: "Your head and shoulders stand above the canopy, in bright air. The
wood is a sea of green leaves below. Southeast, a chimney shaped like an
ear smokes over a fur-thatched roof; southwest, peppery smoke rises from a
little house; and far south, past everything, walls of white and red close
round a garden so bright it hurts."
- Contents: the Pigeon (nest defense scene: "Serpent!" — full exchange as
  dialogue; she settles once you promise you are not looking for eggs — SAY
  NO / TALK TO PIGEON progresses it).
- Exits: DOWN → THICK-WOOD. First visit: +3 points (the survey — this is
  the game's in-fiction map).

**14. MUSHROOM-CLEARING ("Mushroom Clearing")**
LDESC (SMALL): "A clearing ruled by one large mushroom exactly your own
height. On top of it, arms folded, sits a large blue caterpillar, quietly
smoking a long hookah and taking not the smallest notice of you or of
anything else."
LDESC (not SMALL): "A clearing with a knee-high mushroom in it. Something
small and blue on top of it is pointedly ignoring you, and succeeding."
- Contents: Caterpillar, mushroom, hookah (scenery).
- Exits: EAST (tunnel) → THICK-WOOD (SMALL only, same gate text).

**15. CROSSROADS ("Wood Crossroads")**
LDESC: "Paths cross here under a broad-boughed tree. Something about the
tree suggests it is often sat in. Paths run north into the thick wood, west
toward a peppery smell, east toward a clatter of crockery, and south where
the trees grow doors."
- Contents: the Cheshire Cat (his home tree; appears/vanishes per section 5).
- Exits: NORTH → THICK-WOOD, WEST → DUCHESS-LAWN, EAST → TEA-GARDEN,
  SOUTH → DOOR-TREE-WOOD.

**16. DUCHESS-LAWN ("Duchess's Doorstep")**
LDESC: "A little house about four feet high, which is a comfortable height
for a house if you are nine inches tall. On the doorstep sits a footman
with the face of a frog, staring stupidly up into the sky. From inside
comes a most extraordinary noise — howling, sneezing, and every now and
then a great crash, as if a dish had been broken to pieces."
- Event (first arrival): the Fish-Footman scene plays out — the great
  letter, "For the Duchess. An invitation from the Queen to play croquet,"
  the entangled bows.
- Contents: Frog-Footman, door.
- Exits: EAST → CROSSROADS. IN / OPEN DOOR then IN → KITCHEN, SMALL only
  ("The doorway is a fine doorway for a four-foot house. You are not a
  four-foot person."). KNOCK gets the full Frog-Footman routine (P10).

**17. KITCHEN ("Duchess's Kitchen")**
LDESC: "A large kitchen full of smoke from one end to the other. The
Duchess sits on a three-legged stool nursing a howling baby; the cook
stirs a cauldron of soup and, at intervals, throws everything within reach.
On the hearth a large cat grins from ear to ear. There is far, far too
much pepper."
- Ambient: every third turn, "You sneeze. So does the baby. The Duchess
  sneezes occasionally. The cook and the cat do not." Random projectile
  near-misses (never hit; canon).
- Contents: Duchess, cook, baby, Cheshire Cat (grinning, mostly silent
  here), cauldron, pepper-box ("a second pepper-box on the dresser" —
  takeable), fire-irons/plates (scenery projectiles), invitation (appears
  on the floor when the Duchess leaves — see P11).
- Exits: OUT → DUCHESS-LAWN.

**18. TEA-GARDEN ("Mad Tea Table")**
LDESC: "A long table set out under a tree in front of a house with
fur-thatched roof and chimneys shaped like ears. The table is laid for a
great many more than three, but the March Hare, the Hatter, and a sleeping
Dormouse are all crowded together at one corner of it, crying 'No room! No
room!' — which is nonsense, and you say so. Behind the house stands an old
stone well."
LDESC (after watch fixed): "The long tea table, at peace for the first time
in months. The things are being washed. The Dormouse sleeps in the exact
center of the table, by common consent, as an ornament."
- Contents: Hatter, March Hare, Dormouse, teapot, teacups, bread-and-butter,
  butter ("the BEST butter"), milk-jug, the Hatter's watch, the well,
  arm-chair.
- Exits: WEST → CROSSROADS. DOWN (the well) → TREACLE-WELL, SMALL only
  ("The bucket rope would hold a person of very modest tonnage. Yours is
  presently immodest.").

**19. TREACLE-WELL ("Treacle Well")** — SMALL-gated secret.
LDESC: "The bottom of the well, and it is a treacle-well: the walls glisten
brown and the air is thick and sweet enough to slice. Three small sisters —
Elsie, Lacie, and Tillie — sit learning to draw, and what they draw is
treacle, and also everything that begins with an M."
- Contents: treacle (FILL JAR WITH TREACLE — requires the marmalade jar),
  the three sisters (flavor NPC, collective: ask them about M-things —
  "mouse-traps, and the moon, and memory, and muchness").
- Exits: UP → TEA-GARDEN.

**20. DOOR-TREE-WOOD ("Wood of Doors")**
LDESC: "In this part of the wood the trees have taken up carpentry. One of
them has a door leading right into it — a proper door, with hinges and a
handle, in the bark."
- Contents: tree-door.
- Exits: NORTH → CROSSROADS. IN / ENTER TREE / OPEN DOOR then IN → HALL
  ("But everything's curious today. You think you may as well go in at
  once."). On re-entry the hall has "reset itself for company": key on the
  glass table, little door shut and locked. (One line of scripted
  housekeeping, canon-adjacent — the book does exactly this reset.)

**21. GARDEN ("Beautiful Garden")**
LDESC (first, SMALL): "The beautiful garden at last — and you a very small
guest in it. The flower-beds are bright counties, the fountains are
thunderstorms of cool silver, and the gravel path is a boulder-field.
Near the entrance stands a rose-tree the size of a cathedral, white roses
overhead like clouds — and three enormous gardeners are painting them red."
LDESC (NORMAL): "The beautiful garden: bright flower-beds, cool fountains,
and gravel walks. Near the entrance stands a large rose-tree. Its roses are
white, but three gardeners — flat, oblong fellows patterned like playing
cards — are busily painting them red."
- Contents: rose-tree, white roses, paint pot and brush, gardeners (Two,
  Five, and Seven — one collective object with individual dialogue lines),
  large flower-pot, fountains (scenery).
- Exits: NORTH → CROQUET-GROUND (opens once the procession has arrived),
  EAST → FOUNTAIN-WALK, WEST (rat-hole passage) → HALL, SMALL only.
- Events: the royal procession (P14) on first reaching NORMAL size here (or
  after 4 turns if you arrive NORMAL).

**22. FOUNTAIN-WALK ("Fountain Walk")**
LDESC: "A cool walk between fountains, out of earshot of the croquet. A
good place to be told morals, if anybody offering morals were about."
- Contents: fountains; the Duchess promenades here after being freed (P15):
  arm-in-arm morals scene, chin on your shoulder, until the Queen scatters
  her.
- Exits: WEST → GARDEN.

**23. CROQUET-GROUND ("Croquet Ground")**
LDESC: "The Queen's croquet-ground, which is all ridges and furrows. The
balls are live hedgehogs, the mallets live flamingoes, and the soldiers
double themselves up on hands and feet to make the arches — when they are
not strolling off to be elsewhere. Everyone plays at once, without waiting
for turns, and the Queen's voice carries over all of it: 'Off with his
head! Off with her head!'"
- Contents: your flamingo, your hedgehog, soldiers/arches, Queen, King,
  White Rabbit (in the retinue, available for the gloves hand-back), the
  Cheshire Cat's head (event), executioner (event), Duchess (after P15).
- Exits: SOUTH → GARDEN, EAST → SEASIDE (opens when the Queen asks about
  the Mock Turtle).

**24. SEASIDE ("Seaside Ledge")**
LDESC: "A ledge above a grey, sighing sea, which is odd, because you are
fairly sure you are underground. On the warm rock lies a Gryphon, fast
asleep in the sun."
- Contents: Gryphon.
- Exits: WEST → CROQUET-GROUND, EAST → TURTLE-ROCK (the Gryphon leads:
  "Come on!").

**25. TURTLE-ROCK ("Mock Turtle's Rock")**
LDESC: "A little ledge of rock by the sea, where the Mock Turtle sits, sad
and lonely, sighing as if his heart would break. It is all his fancy, that;
he hasn't got no sorrow, you know."
- Contents: Mock Turtle, Gryphon (accompanies you).
- Exits: WEST → SEASIDE. To COURTROOM only by the Gryphon's scripted rush
  when the trial is called (P17).

**26. COURTROOM ("Court of Hearts")**
LDESC: "The court of the King and Queen of Hearts. The Knave stands in
chains between two soldiers; the White Rabbit, near the throne, holds a
trumpet in one hand and a scroll of parchment in the other. Twelve jurors
— little birds and beasts, one of them a lizard you have met — write
busily on slates. In the very middle stands a table with a large dish of
tarts upon it. They look uncommonly good."
- Contents: King (judge, crown over wig), Queen, Knave, White Rabbit,
  jurors (collective), Bill the Lizard, slates, squeaky pencil, tarts,
  trumpet, scroll, note-book, canvas bag (scenery), guinea-pigs (scenery,
  for suppressing).
- Exits: none until the ending fires. "Silence in the court!"

## 4. Objects & puzzles

### Portable object roster

| Object | SYNONYM (6-char safe) | Found | Purpose |
|---|---|---|---|
| marmalade jar | JAR, MARMAL | the fall | container; later filled with treacle (P12) |
| box of comfits | COMFIT, BOX (adj: COMFIT) | pocket at start | caucus prizes (P6) |
| thimble | THIMBL | pocket at start | caucus ceremony (P6) |
| golden key | KEY (adj GOLDEN) | glass table | little door; droppable-by-shrink |
| DRINK ME bottle | BOTTLE (adj LITTLE) | glass table (appears) | one-shot SMALL |
| EAT ME cake | CAKE (adj CURRAN) | glass box under table | one-shot LARGE |
| fan | FAN | Rabbit drops it; spare in his house | repeatable shrink, one step per use; returnable to Rabbit |
| white kid gloves | GLOVES (adj WHITE, KID) | with the fan | Rabbit's errand; returnable |
| unlabeled bottle | BOTTLE (adj UNLABE/PLAIN) | Rabbit's room | the grow-trap (P7) |
| pebble-cake | PEBBLE, CAKE (adj PEBBLE) | thrown into the house | spare one-shot SMALL |
| stick | STICK | Thick Wood | the puppy (P8) |
| mushroom, left piece | PIECE/MUSHRO (adj LEFT) | Caterpillar (P9) | grow one step, infinite |
| mushroom, right piece | PIECE/MUSHRO (adj RIGHT) | Caterpillar (P9) | shrink one step, infinite |
| pepper-box | PEPPER | kitchen dresser | trial comedy (P17); sniffing it anywhere: sneeze |
| invitation | INVITA, CARD | kitchen floor | smooth entry with the Queen (P13) |
| baby | BABY (becomes PIG) | flung at you | carry outside → pig (P11) |
| jar of treacle | (same jar) TREACL | Treacle Well | fixes the watch (P12) |
| the Hatter's hat | HAT | gift (P12) | wearable; trial comedy |
| sixpence | SIXPEN, COIN | Mouse-Hole | trial joke (P17) |
| flamingo | FLAMIN | croquet | mallet (P14) |
| hedgehog | HEDGEH | croquet | ball (P14) |
| squeaky pencil | PENCIL | juror Bill | trial (P17) |

Scenery and NPC objects are listed with their rooms and in section 5.

### Puzzles

**P1. Follow the White Rabbit (intro).** RIVERBANK. The rabbit passes on
turn 2. Any of FOLLOW RABBIT / NORTH works. Refusing to move: the drowsy
narrator gets drowsier ("The daisies consider making a chain of you.").
No failure possible.

**P2. The hall, first pass (key and curtain).** All big doors locked
("locked", "still locked", "locked, and smug about it"). LOOK BEHIND
CURTAIN or OPEN CURTAIN or a second LOOK reveals the little door. TAKE KEY
(NORMAL: fine). UNLOCK LITTLE DOOR WITH KEY → "it fits!" OPEN LITTLE DOOR →
through it, the loveliest garden you ever saw. ENTER → too big (the head
and shoulders line). **On that failure, the DRINK ME bottle materializes**
on the table: "You go back to the table, half hoping to find another key on
it, or at any rate a book of rules for shutting people up like telescopes.
Instead there is a little bottle ('which certainly was not here before,'
you think), with a paper label round its neck: DRINK ME, beautifully
printed in large letters."
- EXAMINE BOTTLE: the poison-checking lecture, verbatimish. It is not
  marked poison.

**P3. DRINK ME.** DRINK BOTTLE → "It has a sort of mixed flavour of
cherry-tart, custard, pine-apple, roast turkey, toffee, and hot buttered
toast, and you finish it off. What a curious feeling! You are shutting up
like a telescope: down, down — ten inches high, and the hall is a
cathedral." Side effects, scripted and explained: the golden key (if held)
"grows in your hand from a key to an oar, and slips from your grip, ringing
down onto the glass table-top far above"; the little door (if open) "slams
in the draught from the garden. Doors here are quick to take advantage."
The bottle is empty and stays empty. Now: door locked, key unreachable
(climbing the table: "too slippery; you slide down politely"), and the
mouse-hole east has become visible (optional sixpence detour).

**P4. EAT ME.** Only findable at SMALL: LOOK UNDER TABLE / LOOK reveals the
glass box; OPEN BOX; EAT CAKE → grow: "Curiouser and curiouser! You are
opening out like the largest telescope that ever was — nine feet if you are
an inch, and your head presses the roof." Now TAKE KEY is trivial ("You
pick the key up like a crumb."), UNLOCK/OPEN work, but the door is
fifteen inches high. Attempting entry: "You lie down on one side and look
into the garden with one eye, which is as much of you as will ever fit."

**P5. The pool of tears and the fan.** At LARGE, after the door failure,
CRY (new verb; also triggered by two consecutive failed entries: "you sit
down and cry — being nine feet tall, you do it wholesale") → "You shed
gallons of tears, until there is a large pool all round you, four inches
deep and reaching half down the hall." Next turn the White Rabbit patters
through, splendidly dressed, muttering "Oh! the Duchess, the Duchess!" Any
address (HELLO / TALK TO RABBIT / ASK RABBIT...) → he starts violently,
drops a white kid pair of gloves and a large fan, and skurries off. TAKE
FAN, TAKE GLOVES. FAN ME / WAVE FAN → shrink one step with escalating
alarm; at SMALL the slip fires: "Your foot slides — splash! You are up to
your chin in salt water, and the pool has opinions about where you are
going." → POOL room. (If the player cleverly fans down BEFORE crying, the
door is locked — bottle rule slammed it — and crying at NORMAL/SMALL makes
puddles, not pools: "You cry a very small puddle, suitable for a beetle's
boating holiday." The pool the game needs must be wept at LARGE; the
Cheshire Cat hints this if stuck. There is no way to lose the fan or
gloves before this; the Rabbit only drops them once the pool exists.)
- In POOL: the Mouse conversation plays over the swim (Où est ma chatte?
  as an incident: mentioning CAT or DINAH or DOG makes it quiver — flavor).
  SWIM / WEST → SHORE.

**P6. The Caucus-race.** SHORE. TALK TO MOUSE → the dry lecture ("This is
the driest thing I know") which dries nobody. The Dodo then moves "that the
meeting adjourn, for the immediate adoption of more energetic remedies" —
Eaglet: "Speak English!" — and proposes the race. RUN / RACE / JOIN RACE →
half an hour of running in a circle, everyone stops when they like: "The
race is over! ... EVERYBODY has won, and all must have prizes. — And who is
to give the prizes? Why, SHE, of course." GIVE COMFITS TO DODO (or TO
BIRDS) → "exactly one a-piece, all round." The company then demands a prize
for you: GIVE THIMBLE TO DODO → the ceremony: "We beg your acceptance of
this elegant thimble," and you receive your own thimble back, permanently
upgraded in its DESC to "elegant thimble". (+points both beats.)
- Failure texts: mentioning DINAH or CATS clears the shore for 3 turns
  ("On various pretexts they all move off." They drift back: forgiving).
  Racing before talking to the Mouse: the Dodo hasn't proposed it — "There
  is no race yet. Wonderland is strict about the order of its nonsense."
- The Mouse's tale plays if you ASK MOUSE ABOUT TALE/HISTORY: the Fury
  verses, with the fifth-bend/knot exchange as the ear-version of the
  page-shape joke.

**P7. The Rabbit's house (the grow trap).** SANDY-PATH event tags you as
Mary Ann; the errand is stated. In RABBIT-ROOM: TAKE FAN / TAKE GLOVES
(spares — if you already carry the originals, "another pair can only
improve matters; gloves are like that"). The unlabeled bottle is pure
temptation, and the game says so: "You know SOMETHING interesting is sure
to happen whenever you eat or drink anything here." DRINK BOTTLE → the
trap state: room-filling growth (special size state, treated as LARGE++,
no exits). Scripted siege, one beat per turn, each advanced by WAIT or by
the tagged action:
1. The Rabbit at the door; blocked by your elbow. ("Then I'll go round and
   get in at the window.")
2. REACH OUT WINDOW / GRAB → "a little shriek, a fall, and a crash of
   broken glass. What a number of cucumber-frames there must be!"
3. Voices: Pat, apples, "Sure, it's an arm, yer honour!" (WAIT)
4. Scrambling in the chimney: "This is Bill," you think. KICK → "There
   goes Bill!" — sky-rocket testimony from outside. (+points)
5. "We must burn the house down!" → SAY I'LL SET DINAH AT YOU / THREATEN
   / SHOUT → "dead silence instantly." (Any loud verb qualifies.)
6. The barrowful: pebbles rattle in at the window and turn to little cakes
   on the floor.
EAT CAKE / EAT PEBBLE-CAKE → SMALL; you run out past "quite a crowd of
little animals and birds" (auto-move to THICK-WOOD, canonically fleeing).
Before eating you may TAKE CAKE to pocket ONE spare pebble-cake (+points).
- The whole trap is optional (you can just take the spares and leave), but
  the game tempts hard, the reward is real, and nothing in it can kill you.
  If you never drink, the Rabbit eventually gets his gloves another way
  (he has spares of everything; returning HIS dropped pair still scores).

**P8. The enormous puppy.** THICK-WOOD at SMALL: the puppy blocks the
bramble tunnel west ("Between you and the tunnel stands the puppy, feebly
stretching out one paw, trying to touch you. It might be hungry. You would
be extremely convenient."). TAKE STICK; THROW STICK → "The puppy jumps
into the air off all its feet at once, with a yelp of delight, and rushes
at the stick, and makes believe to worry it" — it charges and tumbles and
finally "sits down a good way off, panting, with its tongue hanging out"
— the way west is clear (permanently; it keeps the stick, which was the
whole point of sticks). WHISTLE: it cocks its head; charming, useless.
Attacking it: "It is a dear little puppy the size of a dray-horse, and you
are a person of firm principles about puppies."
- At NORMAL the puppy is ankle-height and delighted; the tunnel is the
  gate, not the dog.

**P9. Advice from a Caterpillar (the mushroom).** MUSHROOM-CLEARING at
SMALL. The interview: "Who are YOU?" — any self-description gets his
contradiction engine ("Explain yourself!" / "I don't see." / "It isn't." /
"Why?"). The rules: rudeness (CURSE/ATTACK/shouting) → "Keep your temper,"
and the hookah resumes; you lose turns, nothing else. Progress path: ASK
CATERPILLAR ABOUT SIZE (or GROWING, MUSHROOM, HEIGHT — generous synonyms;
also triggered by saying you wish you were larger) → "Can't remember WHAT
things? ... Repeat, 'You are old, Father William.'" RECITE POEM / SING /
REPEAT POEM → the full eight stanzas play (paced over two responses) →
verdict: "That is not said right ... It is wrong from beginning to end."
Then, next turn, he yawns, gets down, and crawls away, "merely remarking
as it goes: 'One side will make you grow taller, and the other side will
make you grow shorter.' — One side of WHAT? — 'Of the mushroom,' says the
Caterpillar, just as if you had asked it aloud; and in another moment it
is out of sight."
BREAK MUSHROOM / TAKE MUSHROOM → "As it is perfectly round, which is the
two sides of it is a very difficult question. You stretch your arms round
it as far as they will go, and break off a bit of the edge with each
hand." → LEFT PIECE and RIGHT PIECE in inventory (+points; the game's key
item). The first nibble (either piece) plays its overshoot script per the
rule in 2.1, after which each piece moves you exactly one size step,
forever.
- If the player never recites: the Caterpillar smokes eternally and the
  Cat hints ("He wants poetry. They always want poetry. Give him the one
  about Father William and he will give you the mushroom; that is the
  economy of this place.")

**P10. The Frog-Footman's door.** DUCHESS-LAWN. KNOCK → the full "no sort
of use in knocking" routine, and each further knock gets a variation ("I
shall sit here, on and off, for days and days."). ASK FOOTMAN ABOUT
GETTING IN → "ARE you to get in at all? That's the first question, you
know." The solution is the book's: don't negotiate. OPEN DOOR, IN — at
SMALL only. The Footman never stops you ("Anything you like," said the
Footman, and began whistling.). This is a joke-shaped anti-puzzle: the
door was never locked.

**P11. Pig and pepper.** KITCHEN. Ambient sneezes and crockery. TALK TO
DUCHESS → "It's a Cheshire cat, and that's why. Pig!"; ASK DUCHESS ABOUT
QUEEN/CROQUET → "Talking of axes, chop off her head!" etc. On the third
exchange (or third turn), the lullaby ("Speak roughly to your little
boy...") and then: "Here! you may nurse it a bit, if you like! I must go
and get ready to play croquet with the Queen." — the baby lands in your
arms, the Duchess sweeps out, **and a stiff card flutters from her sleeve
to the floor: the invitation.** TAKE INVITATION (+points; she left
without it — which is why she will be late, which is why she will be
under sentence; the game knows this and will let the Cat say so).
Carry the baby OUT. Turn 1 outside: it grunts. EXAMINE BABY: "a very
turn-up nose, much more like a snout than a real nose." Turn 2: "This
time there can be NO mistake about it: it is neither more nor less than
a pig." It wriggles free and trots quietly into the wood (+points for
having carried it out: "If it had grown up, it would have made a
dreadfully ugly child; but it makes rather a handsome pig, you think.").
- Leaving the baby inside: the cook's aim never improves (nothing dies),
  and after 3 turns a small pig trots out the door unassisted; you just
  miss the points and the best lines.
- TAKE PEPPERBOX any time (the cook uses the other one).

**P12. It's always six o'clock (the watch, the well, the treacle).**
TEA-GARDEN. Sitting: "No room! No room!" → SIT → "There's PLENTY of
room," you say indignantly, and sit in a large arm-chair at one end.
Set dialogue: wine that isn't there, "Your hair wants cutting," the
raven-and-writing-desk riddle (ANSWER <anything> → "Do you mean you
think you can find out the answer to it?" → eventually "I haven't the
slightest idea," said the Hatter — attempting at all is worth the scene),
Time quarrel ("He won't stand beating"), "it's always six o'clock now...
always tea-time, and no time to wash the things between whiles."
EXAMINE WATCH → "It tells the day of the month, and is exactly two days
wrong. There are crumbs in the works, from when the March Hare buttered
it with the bread-knife. 'It was the BEST butter,' the March Hare says,
meekly." — The fault was never the butter's quality; it was the crumbs
and the wrong lubricant.
WAKE DORMOUSE → the treacle-well story (Elsie, Lacie, Tillie, "well in,"
drawing everything that begins with an M) — which is the hint: **the old
well behind the house is a treacle-well.**
STAND; EAT RIGHT PIECE (→ SMALL); DOWN → TREACLE-WELL. FILL JAR WITH
TREACLE ("The marmalade jar has waited all day for a purpose. This is
it.") (+points). UP; EAT LEFT PIECE; SIT.
GIVE TREACLE TO HATTER / PUT TREACLE ON WATCH → "The Hatter dips the
watch solemnly into the treacle, holds it to his ear, and goes quite
white, then quite pink. 'It ticks the RIGHT day,' he whispers. 'Time and
I are reconciled. It is a quarter past washing-up time!'" The table
erupts; the perpetual tea ends (+points). The Hatter presses his hat on
you ("I keep them to sell. I've none of my own. But this one is yours:
you mended six o'clock.") — wearable (+point).
- Wrong lubricants: PUT BUTTER ON WATCH → "'It was the best butter,' the
  March Hare says, defensively. It was also the whole problem."
- **Hidden alternate ending** (post-fix only): the Hatter offers you a
  permanent seat: "There's room now, you know. All the room in the world.
  Stay for ever?" STAY (twice — the game double-checks: "Are you quite
  sure? The tea is eternal.") → alternate outro (section 8).

**P13. The hall done right, and the garden.** Via DOOR-TREE-WOOD into the
reset HALL. Solution (the book's, verbatim in spirit): TAKE KEY (NORMAL),
UNLOCK LITTLE DOOR, OPEN LITTLE DOOR, EAT RIGHT PIECE (→ SMALL; the key
rings down onto the table where it lives; **the door stays open — mushroom
magic is gradual, and doors never notice**), WEST/ENTER DOOR → down the
rat-hole passage → GARDEN (+6, the game's biggest single award, with the
book's own music: "and THEN — you find yourself at last in the beautiful
garden, among the bright flower-beds and the cool fountains.")
- Any wrong order self-explains: shrink first → the key is furniture;
  unlock but forget to open → "The door is unlocked, shut, and fifteen
  inches of solid smugness."; arrive at the door LARGE → the one-eye view.

**P14. Roses, procession, croquet.** GARDEN: the gardeners' bickering
plays (Five, Seven, Two). TALK/ASK → the confession: white rose-tree
planted by mistake; heads at stake. Two cooperative solutions, either
scores (+3):
- Before the Queen arrives: TAKE BRUSH, PAINT ROSES → "You lay on the red
  in workmanlike coats while Two whispers which petals the Queen checks
  first. The tree passes for crimson by the time the trumpets sound."
- Or, if the Queen catches them: she orders their heads off; they run to
  you; PUT GARDENERS IN FLOWER-POT → the soldiers search, give up, and
  report: "'Their heads are gone, if it please your Majesty!' — 'That's
  right!' shouts the Queen."
The procession arrives on your first NORMAL-size presence (SMALL players
are literally beneath notice, and the garden politely waits). The Queen:
"Who is this? ... What's your name, child?" → SAY ALICE (any polite
answer). "And who are THESE?" → any answer → "Off with her head! Off—"
→ **SAY NONSENSE** → "'Nonsense!' you say, very loudly and decidedly,
and the Queen is silent. The King lays a hand on her arm: 'Consider, my
dear: she is only a child!'" (SHOW INVITATION at any point substitutes
for the whole exchange: the Queen squints at it — "You are not the
Duchess." — "No; she is detained," you say, which is true — and you are
admitted as a substitute, +2 either path.) Then: "Can you play croquet?"
→ YES → all move north; you are handed a flamingo and a hedgehog.
CROQUET-GROUND: the equipment misbehaves in rotation — HIT HEDGEHOG →
one of: flamingo twists round and looks up in your face (you cannot help
laughing); hedgehog has unrolled and is crawling away; the arch has got
up and walked off. Solution sequence, hinted by observation text:
1. STROKE FLAMINGO (or PET) → "It settles its neck under your arm with a
   pleased grunt, and consents to be a mallet."
2. WAIT until "a doubled-up soldier nearby yawns and settles into place."
3. HIT HEDGEHOG (WITH FLAMINGO) → "Clean through the arch! The Queen
   almost smiles, which frightens everybody." (+4)
- Cat dispute: the Cheshire Cat's head materializes; the King objects
  ("it may kiss my hand if it likes" / "I'd rather not"); executioner's
  paradox (no body to cut a head off from) vs the King ("anything that
  has a head can be beheaded") vs the Queen (everybody executed all
  round). The court appeals to you: SAY ASK THE DUCHESS / TELL KING
  ABOUT DUCHESS → "It belongs to the Duchess: you'd better ask HER about
  it." → the executioner fetches the Duchess (freeing her, +3); the head
  fades before anything can be done to it.
- GIVE GLOVES TO RABBIT (and FAN) here or at the trial → "His ears turn
  quite pink with relief. 'Oh, my fur and whiskers — my GLOVES!'" (+3)
- Queen closes the act: "Have you seen the Mock Turtle yet?" → east
  opens; the Gryphon scene.

**P15. The Duchess promenade (optional flavor).** After the Cat dispute,
the Duchess attaches herself arm-in-arm at FOUNTAIN-WALK: morals engine
(each turn a new one, cycling the book's set). Enduring three morals
politely: she calls you "a clear way of putting things" (no points; pure
voice). The Queen appears — "either you or your head must be off!" — and
the Duchess takes her choice.

**P16. The Mock Turtle.** SEASIDE: the Queen wakes the Gryphon ("Up, lazy
thing!"); it chuckles the secret that de-fangs the whole game: "It's all
her fancy, that: they never executes nobody, you know. Come on!" At
TURTLE-ROCK: the history plays in sighing installments (LISTEN, WAIT,
ASK TURTLE ABOUT SCHOOL/LESSONS → Reeling and Writhing, Uglification,
lessons that lessen). Then the Quadrille: they demonstrate; DANCE → they
dance solemnly round you, treading on your toes when they pass too close,
singing "Will you, won't you, will you, won't you, will you join the
dance?" (+3). SING / ASK TURTLE TO SING → Beautiful Soup, sobbed in full
— and mid-chorus, far off: "The trial's beginning!" The Gryphon takes
you by the hand and RUNS (scripted move to COURTROOM; the Mock Turtle's
"Soo—oop of the e—e—evening" follows on the breeze).

**P17. The trial of the Knave of Hearts (finale, soft timer ~20 turns).**
Beats advance on WAIT or on any player action; nothing the player does
stalls it forever, and nothing ends it early except the ending. The
tarts sit in the middle the whole time, being evidence, refreshments,
and motive all at once.
1. Herald: three trumpet blasts; the accusation verse in full.
2. Free actions any time: TAKE PENCIL (Bill's squeaks — "You take it so
   quickly the poor little juror cannot make out what has become of it;
   he writes with one finger for the rest of the day," +1); EXAMINE
   TARTS ("They look SO good. It is against the law to be hungry in
   court, probably."); EAT TART → "You are many things, but you are not
   about to become Exhibit B."
3. Witness: the Hatter (teacup, bread-and-butter, "I'm a poor man, your
   Majesty"). If you fixed his watch, one glorious variant line: "'I came
   PUNCTUALLY,' says the Hatter, bewildered by the novelty." He bites
   his teacup, is dismissed, flees shoeless.
4. Witness: the cook. "What are tarts made of?" — "Pepper, mostly." A
   sleepy voice: "Treacle." — the Dormouse ejection ("Collar that
   Dormouse! ... Off with his whiskers!"). If you visited the well, you
   alone in the court know the Dormouse is quoting geography.
   THROW/OPEN PEPPER here → the entire court sneezes in waves; the cook
   escapes in the confusion, exactly as she wished (+2).
5. You begin to grow (auto): the Dormouse objects ("You've no right to
   grow HERE." — "Don't talk nonsense; you know you're growing too." —
   "Yes, but I grow at a REASONABLE pace.").
6. "Alice!" — you are the next witness. Answer the King ("What do you
   know about this business?") with NOTHING → "Nothing WHATEVER?" →
   "Nothing whatever." → "That's very important — UNimportant, your
   Majesty means, of course."
7. Growing to LARGE tips the jury-box (goldfish-globe memory): PUT BILL
   IN BOX / RIGHT BILL → head upwards this time (+2; leaving him: he
   gazes at the roof, "quite as much use one way up as the other," no
   points).
8. Rule Forty-two ("All persons more than a mile high to leave the
   court."). SAY I'M NOT A MILE HIGH / NO / REFUSE → "'I'M not a mile
   high,' you say. — 'You are,' says the King. — 'Nearly two miles
   high,' adds the Queen. — 'Well, I shan't go, at any rate: that's not
   a regular rule; you invented it just now.' — 'It's the oldest rule
   in the book.' — 'Then it ought to be Number One.' The King turns
   pale and shuts his note-book hastily." (+2)
9. The unsigned verses, read in full ("Begin at the beginning, and go
   on till you come to the end: then stop."). GIVE SIXPENCE (TO KING /
   TO JURY) → "'If any one of them can explain it,' you say, 'I'll give
   him sixpence.' You are holding an actual sixpence, which alarms the
   court considerably; nobody attempts the explanation, and the
   sixpence enters the record as the day's only honest evidence." (+2)
   The King finds his meanings anyway; the cardboard Knave "Do I look
   like it?"; the pun ("Then the words don't FIT you") and its dead
   silence and its "It's a pun!"
10. THE ENDING. "Let the jury consider their verdict," the King says,
    for about the twentieth time that day. "No, no!" says the Queen.
    "Sentence first — verdict afterwards." **SAY NONSENSE (or STUFF AND
    NONSENSE, or TELL QUEEN NONSENSE)** → "'Stuff and nonsense!' you
    say loudly. 'The idea of having the sentence first!' — 'Hold your
    tongue!' says the Queen, turning purple. — 'I won't!' — 'Off with
    her head!' the Queen shouts at the top of her voice. Nobody moves.
    'Who cares for YOU?' you say — you have grown to your full size by
    now — 'You're nothing but a pack of cards!'" → the pack rises into
    the air and comes flying down upon you → wake outro (+5).
    If the player dawdles three turns at this beat, the Cheshire Cat's
    grin fades in among the rafters, mouthing a single word:
    "Nonsense." If they still don't, five more turns and the King
    murmurs "You are all pardoned," the court dissolves into the same
    swirl of cards, and the dream "ends itself, feeling somewhat
    neglected" — same outro, minus the 5 points and the best line.

## 5. NPCs

Each is a compact interaction puzzle; signature lines are in STUDY.md and
quoted in the puzzle specs above. Interaction rules of thumb: TALK TO X
gives the scene's opening move; ASK X ABOUT <topic> hits a per-NPC topic
table (5-10 topics each, one default deflection in-voice); GIVE/SHOW
drive the item beats. Politeness progresses, rudeness sulks, violence is
met with Wonderland's total invulnerability to consequence.

- **White Rabbit** — the trail. Riverbank (runs by), hall (drops fan and
  gloves), Sandy Path ("Mary Ann!"), procession, court herald. Accepting
  his errand and later returning the gloves/fan is his whole arc (+3).
  Always addressed mid-hurry; his topic table is mostly apologies.
- **Cheshire Cat — the hint system.** Home at CROSSROADS; also appears
  after the pig ("Did you say pig, or fig?"), at CROQUET (head only),
  and in the courtroom rafters at the last beat. ASK CAT ABOUT <topic>
  is the sanctioned hint channel; every major puzzle has a Cat riddle:
  mushroom ("He wants poetry..."), garden ("Doors are only ever locked
  in the wrong order. Unlock first; shrink second."), watch ("Butter was
  the wrong ointment. Ask the Dormouse what wells are for."), trial
  ("When they reach the sentence, say what it is. Loudly."), queen
  ("Say nonsense to her. It is the one language she respects."). He
  vanishes tail-first after three questions ("You make one quite giddy"
  if asked to stop appearing); CALL CAT / SAY CHESHIRE at the
  crossroads brings him back. Never lies, never answers straight.
- **Caterpillar** — P9. Contradiction engine; three-inch dignity.
- **Mouse / Dodo and the shore company** — P6. The Mouse's topic table
  includes TALE (the Fury verses) and the forbidden topics CAT and DOG.
- **Frog-Footman** — P10. An anti-puzzle with a speaking part.
- **Duchess** — two-state NPC: pepper-state (kitchen: savage, flings
  baby) and moral-state (fountain walk: attaches, moralizes). Her
  missing invitation is the player's croquet ticket.
- **Cook** — throws things; "Shan't." Never hits anyone; never speaks
  twice.
- **Hatter, March Hare, Dormouse** — P12 ensemble. The Dormouse is also
  the hint for the well and the "Treacle!" voice at trial. The Hatter
  reappears as witness (variant line if his watch was fixed).
- **Queen of Hearts** — a walking death-threat whose executions never
  happen. Systemic rule: any "Off with her head!" aimed at the player
  is survived by SAY NONSENSE (canon), by the King's "she is only a
  child," or simply by three turns passing (the Gryphon's secret is the
  game's safety net, stated in dialogue: "they never executes nobody").
  She is never killable, mollifiable, or wrong.
- **King of Hearts** — the soft counterweight; pardons everybody at the
  end of every scene, quietly.
- **Gryphon & Mock Turtle** — P16 double act: one all slang and
  impatience, one all sighs. The quadrille and two songs live here.
- **Gardeners Two, Five, Seven** — P14; one collective object with
  three voices.
- **Knave, Bill, Pat, Pigeon, puppy, guinea-pigs, Elsie/Lacie/Tillie,
  sister** — single-scene supporting objects, each with EXAMINE + one
  or two responses in voice.

## 6. Timers & danger

- **No deaths.** JIGS-UP is implemented (engine requires it) but every
  path into it is intercepted with an absurd rescue: over-fanning stops
  "just in time"; the pool refuses to drown you; the Queen's sentences
  are fancy; falling is what Wonderland is FOR. The one theoretically
  reachable JIGS-UP (repeatedly insisting on being beheaded — ASK QUEEN
  TO BEHEAD ME etc. three times) prints the executioner's paradox and a
  royal pardon, and moves you one room away, unharmed and slightly
  embarrassed.
- **Soft timers only:** the Rabbit-house siege and the trial advance
  beat-per-turn and wait indefinitely at player-input beats; the baby
  becomes a pig on schedule wherever it is; the door-drift and pool
  events in Act 1 are scripted, not raced. The only "missable" scoring
  is doing scenes without their optional flourishes, and the walkthrough
  collects everything.
- **No inventory loss** except the scripted key-drop on shrinking (the
  key always lands on the glass table, never in a void) and the fan
  auto-drop at the near-candle moment (it lands at your feet).

## 7. Scoring

`SCORE-MAX 100`. Points on first occurrence only.

| Award | Pts | | Award | Pts |
|---|---|---|---|---|
| Pocket the marmalade jar mid-fall | 2 | | Enter the kitchen (unknocked) | 2 |
| Unlock the little door (first time) | 3 | | Rescue the baby (pig delivered) | 4 |
| Drink DRINK ME | 2 | | Take the invitation | 2 |
| Find and eat EAT ME | 2 | | Take the pepper-box | 1 |
| Weep the pool (at LARGE) | 3 | | Find the treacle well | 3 |
| Escape by fan | 3 | | Fix the Hatter's watch | 4 |
| Find the sixpence | 1 | | Accept the hat | 1 |
| Run the Caucus-race | 3 | | ENTER THE BEAUTIFUL GARDEN | 6 |
| Prizes for everybody (comfits) | 2 | | Save the gardeners (paint or pot) | 3 |
| The elegant thimble ceremony | 3 | | Survive the Queen's introduction | 2 |
| There goes Bill (the kick) | 2 | | Hedgehog through the arch | 4 |
| Escape the Rabbit's house | 3 | | "Ask the Duchess" (cat verdict) | 3 |
| Pocket a spare pebble-cake | 2 | | Return the gloves and fan | 3 |
| Get past the puppy | 3 | | Dance the Lobster Quadrille | 3 |
| Recite Father William | 3 | | Take the squeaky pencil | 1 |
| Obtain the mushroom pieces | 5 | | Right Bill in the jury-box | 2 |
| Survey Wonderland from the treetops | 3 | | "I'm not a mile high" | 2 |
| | | | Offer the sixpence | 2 |
| | | | Pepper the court | 2 |
| | | | "Stuff and nonsense!" finale | 5 |

Ranks (printed with SCORE and at the end):
- 0–24: **Perfectly Sensible Child**
- 25–49: **Curiouser and Curiouser**
- 50–74: **Uncommonly Nonsensical**
- 75–99: **Almost Entirely Mad**
- 100: **Quite Mad, Thank You**

## 8. Intro & outro drafts (actual text)

### Intro (TTS cold open, printed before the first prompt)

"You are beginning to get very tired of sitting by your sister on the
bank, and of having nothing to do. Once or twice you have peeped into the
book she is reading, but it has no pictures or conversations in it — and
what is the use of a book without pictures or conversations? The day is
hot, and you feel very sleepy and stupid, and you are considering whether
the pleasure of making a daisy-chain is worth the trouble of getting up,
when a White Rabbit with pink eyes runs close by you.

There is nothing so very remarkable in that. Nor is it so very much out
of the way to hear the Rabbit say to itself, 'Oh dear! Oh dear! I shall
be late!' But when the Rabbit actually takes a watch out of its
waistcoat-pocket, and looks at it, and hurries on — you start to your
feet. You have never before seen a rabbit with either a
waistcoat-pocket, or a watch to take out of it.

Burning with curiosity, you are Alice; the afternoon is golden; and
somewhere under the hedge ahead of you, a large rabbit-hole is waiting,
going down and down and down.

WONDERLAND — an interactive nonsense, after Lewis Carroll."

(Then the RIVERBANK room description; the rabbit event fires on turn 2
so even a player who read nothing sees the trailhead immediately.)

### Main outro (victory: the pack of cards)

"At this the whole pack rises up into the air and comes flying down upon
you. You give a little scream, half of fright and half of anger, and try
to beat them off — and find them only dead leaves, fluttering down from
the trees onto your face.

'Wake up, Alice dear!' says your sister. 'Why, what a long sleep you've
had!'

'Oh, I've had such a curious dream!' you say. And you tell her, as well
as you can remember them, all these strange adventures — the Rabbit, the
pool, the Caterpillar exactly three inches high, the tea that was always
six o'clock, the Queen who never once got anybody's head. Your sister
kisses you and says it certainly was a curious dream, but now run in to
your tea: it's getting late.

And you run in, thinking while you run — as well you might — what a
wonderful dream it has been. Behind you on the bank, the long grass
rustles, just once, the way it would if a white rabbit had hurried by."

(Then score and rank: "Your score is X of 100, which earns the rank of
<rank>. Everybody has won, and all must have prizes.")

### Alternate outro (stay mad for tea forever)

"'There's room now, you know,' says the Hatter, moving up. 'All the room
in the world.' The March Hare pours; the Dormouse, by way of welcome,
does not wake; and the watch on the table ticks round to exactly
tea-time, which it now is, and will remain, for as long as you care to
stay — and you find you care to stay a very long time indeed.

Somewhere far above, an afternoon ends without you. Down here the bread
and butter goes round, and the riddles have no answers, and nobody's
head is ever off. You have considered the matter carefully, from every
side, like a mushroom, and your conclusion is this: they were quite
right. You ARE mad. You wouldn't have come here otherwise.

Rank attained: Quite Mad, Thank You. (There is no score. Scores are for
people who leave.)"

## 9. Walkthrough (complete, raw parser commands)

Assumes the scripted events fire as specified; WAITs are load-bearing.

```
1 WAIT                      (the Rabbit runs by)
2 FOLLOW RABBIT             (to Under the Hedge)
3 DOWN                      (the fall begins)
4 TAKE JAR                  (+2, mid-fall)
5 WAIT
6 WAIT                      (land: Bottom of the Well)
7 NORTH                     (Long Low Passage)
8 NORTH                     (Hall of Doors)
9 TAKE KEY
10 OPEN CURTAIN             (reveals the little door)
11 UNLOCK DOOR WITH KEY     (+3)
12 OPEN DOOR
13 WEST                     (too big; the bottle materializes)
14 DRINK BOTTLE             (+2; SMALL; key rings onto table; door slams)
15 EAST                     (Mouse-Hole)
16 TAKE SIXPENCE            (+1)
17 WEST                     (Hall)
18 LOOK UNDER TABLE         (the glass box)
19 OPEN BOX
20 EAT CAKE                 (+2; LARGE)
21 TAKE KEY
22 UNLOCK DOOR WITH KEY
23 OPEN DOOR                (still can't fit; grief accumulates)
24 CRY                      (+3; the pool forms; the Rabbit approaches)
25 HELLO RABBIT             (he drops fan and gloves, flees)
26 TAKE FAN AND GLOVES
27 FAN ME                   (shrinking...)
28 FAN ME                   (+3; SMALL; slip — splash: Pool of Tears)
29 WEST                     (swim; the Mouse; Queer Shore)
30 TALK TO MOUSE            (the dry lecture fails)
31 RUN                      (+3; the Caucus-race; everybody dry)
32 GIVE COMFITS TO DODO     (+2; one a-piece all round)
33 GIVE THIMBLE TO DODO     (+3; "We beg your acceptance...")
34 EAST                     (Sandy Path; "Why, Mary Ann!")
35 EAST                     (Outside Rabbit's House)
36 IN                       (Tidy Little Room)
37 TAKE GLOVES              (a spare pair)
38 DRINK BOTTLE             (the trap: you fill the house)
39 REACH OUT WINDOW         (shriek; cucumber-frames)
40 WAIT                     (Pat and the arrum)
41 KICK                     (+2; there goes Bill)
42 SHOUT                    ("I'll set Dinah at you!" — dead silence)
43 WAIT                     (pebbles rattle in, become cakes)
44 TAKE CAKE                (+2; a spare pebble-cake pocketed)
45 EAT CAKE                 (+3; SMALL; you flee to the Thick Wood)
46 TAKE STICK
47 THROW STICK              (+3; the puppy is dealt with)
48 WEST                     (bramble tunnel; Mushroom Clearing)
49 TALK TO CATERPILLAR      ("Who are YOU?")
50 ASK CATERPILLAR ABOUT SIZE   ("Repeat 'You are old, Father William'")
51 RECITE POEM              (+3; wrong from beginning to end)
52 WAIT                     ("One side will make you grow taller...")
53 TAKE MUSHROOM            (+5; left piece and right piece)
54 EAT LEFT PIECE           (overshoot: serpent neck; LARGE)
55 EAST                     (Thick Wood, head in the branches)
56 UP                       (+3; Treetops; the Pigeon; the survey)
57 DOWN
58 EAT RIGHT PIECE          (NORMAL; calibrated)
59 SOUTH                    (Crossroads; the Cheshire Cat)
60 ASK CAT ABOUT HATTER     (directions; "we're all mad here")
61 WEST                     (Duchess's Doorstep; Fish-Footman scene)
62 KNOCK ON DOOR            (the two reasons; pure pleasure)
63 EAT RIGHT PIECE          (SMALL)
64 OPEN DOOR
65 IN                       (+2; the Kitchen; sneezing)
66 TAKE PEPPERBOX           (+1)
67 ASK DUCHESS ABOUT QUEEN  ("Talking of axes...")
68 WAIT                     (lullaby; baby flung at you; invitation falls)
69 TAKE INVITATION          (+2)
70 OUT                      (carrying the baby)
71 WAIT                     (it grunts; the nose is a snout)
72 WAIT                     (+4; neither more nor less than a pig)
73 EAST                     (Crossroads; "Did you say pig, or fig?")
74 SAY PIG                  ("I thought it would.")
75 EAT LEFT PIECE           (NORMAL)
76 EAST                     (Mad Tea Table; "No room! No room!")
77 SIT                      ("There's PLENTY of room")
78 ANSWER RIDDLE            (nobody has the slightest idea)
79 EXAMINE WATCH            (two days wrong; the best butter)
80 WAKE DORMOUSE            (Elsie, Lacie, Tillie; the treacle-well)
81 STAND
82 EAT RIGHT PIECE          (SMALL)
83 DOWN                     (+3; the Treacle Well)
84 FILL JAR WITH TREACLE
85 UP
86 EAT LEFT PIECE           (NORMAL)
87 SIT
88 GIVE TREACLE TO HATTER   (+4; Time reconciled; +1 the hat)
89 WEAR HAT
90 STAND
91 WEST                     (Crossroads)
92 SOUTH                    (Wood of Doors)
93 ENTER TREE               (the Hall, reset)
94 TAKE KEY
95 UNLOCK DOOR WITH KEY
96 OPEN DOOR
97 EAT RIGHT PIECE          (SMALL; the key rings down; the door stays open)
98 WEST                     (+6; THE BEAUTIFUL GARDEN)
99 EAT LEFT PIECE           (NORMAL)
100 TALK TO GARDENERS       (the white rose-tree confession)
101 TAKE BRUSH
102 PAINT ROSES             (+3; crimson before the trumpets)
103 WAIT                    (the procession; "What's your name, child?")
104 SAY ALICE
105 SHOW INVITATION TO QUEEN  (+2; admitted as a substitute)
106 YES                     ("Can you play croquet?" — to the Croquet Ground)
107 STROKE FLAMINGO         (it consents to be a mallet)
108 WAIT                    (a soldier settles into an arch)
109 HIT HEDGEHOG            (+4; the Queen almost smiles)
110 WAIT                    (the Cat's head; the beheading dispute)
111 TELL KING ABOUT DUCHESS (+3; "you'd better ask HER")
112 GIVE GLOVES TO RABBIT   (+3; includes the fan; pink ears)
113 WAIT                    ("Have you seen the Mock Turtle yet?")
114 EAST                    (Seaside Ledge; "Up, lazy thing!")
115 EAST                    (Mock Turtle's Rock)
116 TALK TO TURTLE          ("Once, I was a real Turtle.")
117 ASK TURTLE ABOUT SCHOOL (Reeling and Writhing; lessons lessen)
118 DANCE                   (+3; the Lobster Quadrille)
119 SING                    (Beautiful Soup — "The trial's beginning!")
120 TAKE PENCIL             (+1; Bill writes with a finger)
121 WAIT                    (the Hatter's evidence, punctually)
122 WAIT                    (the cook; "Pepper, mostly." "Treacle!")
123 THROW PEPPER            (+2; the court sneezes; the cook escapes)
124 WAIT                    (you are growing; the Dormouse objects)
125 WAIT                    ("Alice!")
126 SAY NOTHING             ("Nothing whatever?" — "Nothing whatever.")
127 WAIT                    (LARGE; the jury-box tips)
128 PUT BILL IN BOX         (+2; head upwards this time)
129 WAIT                    (Rule Forty-two)
130 SAY I AM NOT A MILE HIGH  (+2; "Then it ought to be Number One")
131 WAIT                    (the unsigned verses)
132 GIVE SIXPENCE TO KING   (+2; the day's only honest evidence)
133 WAIT                    ("Sentence first — verdict afterwards!")
134 SAY NONSENSE            (+5; "You're nothing but a pack of cards!")
                            (the pack flies; you wake; 100/100:
                             Quite Mad, Thank You)
```

134 moves, all 100 points. A minimal (no-flourish) path is roughly 80
moves; nothing optional is ever required.

## 10. Writing style guide (CRITICAL — TTS-voiced)

1. **Length.** Most responses 1–3 sentences. Hard ceiling: two short
   paragraphs, and only for set pieces (the fall, the garden entry, the
   ending). Poems are the sanctioned exception, and even they are split
   across two turns when long (Father William).
2. **No visuals.** No ASCII art, no maps in text, no typography jokes,
   no reliance on layout, italics, or capital-letter shapes. Emphasis is
   carried by word order and by Carroll's own device — precise diction
   in absurd service. The Mouse's tail poem is delivered as SOUND: the
   verses spoken, then the fifth-bend/"A knot!" exchange, which is the
   ear-native version of the page joke.
3. **Voice.** Dry, precise, affectionate, second person. The narrator
   is fond of the player the way Carroll is fond of Alice, and treats
   the maddest events as administrative facts. Never wink at the
   player; Wonderland does not know it is funny.
4. **Failure text is content.** Every default is rewritten in voice
   (czil: the engine's "You can't do that" class messages get
   game-level overrides where the engine allows, and every important
   object gets bespoke refusals). A refusal must always contain a
   reason, and the reason must always be worse than the refusal.
5. **Answers for everything.** Budget bespoke responses for the whole
   Carroll-obvious verb set on every headline object: EAT the key
   ("It is gold, and you are a child of some breeding"), SING anywhere
   (a verse appropriate to the room: crocodile at the pool, Twinkle at
   the tea table, Turtle Soup at the rock), SMELL the pepper, KISS the
   puppy, CURTSEY to everyone (everyone returns it in character — the
   Queen: "The Queen inclines her head one royal quarter-inch"), JUMP,
   PRAY, WISH, COUNT the jurors ("Twelve. You are rather proud of
   knowing the word 'jurors.'").
6. **Size-flavor everywhere.** Any response that could differ by size,
   should. Minimum bar: the three hall LDESCs, the wood, the garden,
   and TAKE/reach refusals at SMALL.
7. **Status line** DESCs: short title-case names as listed; they are
   what the v3 status bar shows.
8. **Quotes.** Carroll's dialogue is used verbatim wherever an NPC
   speaks a book line (public domain; the crown jewels). Original
   connective text imitates but never parodies.

## 11. Build notes (czil / Zork engine, v3)

- **Counts vs limits.** 26 rooms + ~60 game objects + 18 engine objects
  ≈ 105 of 255 — comfortable. Text volume is the pressure point for the
  128KB v3 ceiling given the poems and set pieces; abbreviation
  compression buys ~11%. If it pinches, compile v8 (`-I zil/engine-v8
  -v 8` plus the `V8PATCH` line, already proven by tinyquest); cost is
  the status line, which we accept rather than cut poems.
- **File layout.** `alice.zil` (main, per AUTHORING.md skeleton with
  `<SETG ZORK-NUMBER 0>` and GGLOBALS **before** the dungeon file),
  `adungeon.zil` (DIRECTIONS first, rooms, objects, stub objects WATER/
  GLOBAL-WATER/WALL/ON-LAKE/IN-LAKE/FLAG-CARRIER copied from tinyquest),
  `aactions.zil` (room/object actions, new verbs, GO, V-SCORE,
  V-DIAGNOSE, JIGS-UP → the pardon handler, FIND-WEAPON → false,
  `SCORE-MAX 100`), `walkthrough.txt` (section 9 verbatim).
- **Size state.** `<GLOBAL ALICE-SIZE 2>` plus helpers `SMALL?` /
  `NORMAL?` / `LARGE?` and one `CHANGE-SIZE` routine that owns ALL
  transition text, the first-use overshoot flags, the key-drop rule,
  the bottle-slams-door rule, and the pool-slip check. Size-gated exits
  use `(WEST PER TUNNEL-EXIT)` routines returning the room or printing
  the gate line. Room descriptions switch on ALICE-SIZE inside room
  ACTION routines at M-LOOK (LDESC prop holds the NORMAL text;
  SMALL/LARGE variants printed by the routine).
- **Scripted sequences** (the fall, the house siege, the trial) are
  each one counter global advanced by a room-action M-END/M-ENTER hook
  plus tagged commands; the trial's `TRIAL-PHASE` counter is the
  biggest single routine in the game. Keep each beat's text in its own
  routine for sanity.
- **Stock verbs used as-is** (verified in gsyntax.zil): TAKE, DROP,
  OPEN, CLOSE, LOCK, UNLOCK, EAT, DRINK, READ, EXAMINE, LOOK-UNDER/
  BEHIND/INSIDE, THROW, GIVE, KICK, KNOCK, JUMP, SWIM, WAKE (V-ALARM),
  WAIT, SIT (BOARD/CLIMB-ON family — give the arm-chair VEHBIT or
  handle SIT via SYNTAX addition), STAND, STAY, FOLLOW, LISTEN, SMELL,
  RUB, SHAKE, WAVE, SEARCH, ENTER/EXIT, CLIMB, PUT/PUT-ON, TELL/TALK,
  ANSWER, HELLO, YELL (for SHOUT), CURSE (intercept in-voice), PRAY,
  WISH, COUNT, FILL, PICK, PLAY, RING, BURN (intercept: nothing in
  Wonderland agrees to burn), FIND, WEAR.
- **New verbs to add** (verified absent from gsyntax.zil): CRY (syn
  WEEP, SOB), SING, RECITE (syn REPEAT — check REPEAT isn't reserved;
  fall back to RECITE only), DANCE, FAN (SYNTAX FAN ME / FAN OBJECT;
  also wire WAVE FAN to it), PAINT (OBJECT / OBJECT WITH OBJECT),
  CURTSEY (syn BOW), STROKE (syn PET, PAT), WHISTLE, RACE (syn RUN —
  RUN may exist as WALK synonym; test and prefer RACE), HIT (exists
  via ATTACK? map HIT HEDGEHOG through V-ATTACK intercept on the
  hedgehog, or add SYNTAX HIT OBJECT), SHOW (OBJECT TO OBJECT — or
  alias to GIVE), NIBBLE (syn of EAT via SYNONYM), REACH (REACH OUT
  WINDOW — or accept GRAB/PUT HAND THROUGH WINDOW; simplest: SYNTAX
  REACH = V-REACH with room-state check), SAY (engine has V-SAY —
  verify it passes the quoted word; the finale accepts NONSENSE as a
  bare word too, via a BUZZ/SYNTAX on the word NONSENSE).
- **Six-character dictionary audit** (the parser sees 6 letters):
  CATERP(illar), DORMOU(se), FLAMIN(go), HEDGEH(og), MUSHRO(om),
  TREACL(e), MARMAL(ade), INVITA(tion), SIXPEN(ce), PEPPER(box),
  CURTAI(n), TRUMPE(t), FOOTMA(n), GRYPHO(n) — all distinct. Known
  collisions to avoid: **GARDENER truncates to GARDEN** — the gardeners
  object must NOT use that noun (use CARDS / PAINTER / TWO FIVE SEVEN;
  note TWO/FIVE/SEVEN risk colliding with number parsing via INTNUM —
  test early, keep PAINTER as the safe noun). CAKE is shared by EAT ME
  cake and pebble-cakes — distinct adjectives (CURRAN vs PEBBLE), and
  the two never coexist in scope except in inventory; acceptable.
  BOTTLE shared by DRINK ME and the unlabeled bottle — never in scope
  together (different rooms); still give adjectives (LITTLE vs PLAIN).
  PIECE needs LEFT/RIGHT adjectives; EAT LEFT / EAT RIGHT alone should
  work via GWIM when both are held (FIND FOODBIT). WHITE is an
  adjective on rabbit, gloves, and roses — all disambiguated by nouns.
  DOOR: big doors vs little door vs tree-door vs Duchess's door — one
  per room in scope except the hall (big DOORS object plural + LITTLE
  DOOR with adjective; the parser's 6-char world sees LITTLE, fine).
- **Flags.** No new flags needed for size (global int); reuse OPENBIT/
  LOCKEDBIT/CONTBIT/SURFACEBIT etc. Likely 2–3 new flags at most
  (e.g., NPC "sulking" bit); v3 budget (~12 free) holds.
- **Vehicles/misc.** The arm-chair and jury-box need no VEHBIT if SIT
  and PUT are handled by action routines. The pool room needs RLANDBIT
  absent + swim handling: simplest is to keep it a normal room whose
  non-west exits print water text (avoid the engine's boat machinery
  entirely; NONLANDBIT stub objects exist per tinyquest).
- **Risks, ranked.**
  1. Trial script complexity (TRIAL-PHASE): mitigate by making every
     beat WAIT-advanced with tagged-verb shortcuts, and testing the
     walkthrough transcript byte-for-byte in CI like tinyquest.
  2. Poem text volume vs v3 size: measure early with a text-only
     compile; v8 is the pressure valve.
  3. SAY/ANSWER parsing for the finale words (NONSENSE, ALICE, PIG,
     NOTHING): implement as both quoted-say and bare-word syntaxes;
     the LLM layer above the parser will phrase-match reliably, but
     the raw parser must accept the bare forms.
  4. Number-word nouns (TWO/FIVE/SEVEN): drop if INTNUM interferes;
     PAINTER/CARDS suffice.
  5. RUN as race trigger may collide with WALK synonyms: RACE is the
     canonical verb, RUN intercepted only on the Shore.
- **Testing:** `walkthrough.txt` = section 9. Compile, run
  `czil/tests/play.mjs`, read every turn of the transcript, freeze it,
  and diff on every change. Only then play through the LLM.
