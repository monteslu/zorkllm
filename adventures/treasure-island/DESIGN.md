# TREASURE ISLAND — game design

A text adventure adaptation of Robert Louis Stevenson's novel for the
zorkllm toolchain (czil compiler + Zork I engine files in `zil/zork1`).
This document is the complete build spec: someone should be able to
implement the game from this file alone, without reading the book.
Companion file: `STUDY.md` (source quotes and chapter notes).

Working title: **TREASURE ISLAND: A Tale of the Sea-Cook**
Files: `treasure.zil` (main), `tidungeon.zil`, `tiactions.zil`.
Recommended target: **v8 story file** (see §11 — flag count and text size
both argue for it; the v3 build would fit rooms/objects but is tight).

---

## 1. Vision & tone

**The player fantasy:** you are Jim Hawkins, fourteen, landlord's son,
and everyone underestimates you. Every famous thing in this story — the
map, the eavesdrop, the ship, the duel — ends up in *your* hands because
you poked your nose where a sensible boy wouldn't. The game's core loop
is Stevenson's own: *hide, listen, act at the exact right moment.* The
player is rarely the strongest person in the room and always the most
dangerous one, because the player knows things.

**What makes it fun as a game:**

- **Three acts, three genres.** Act I is a heist under a ticking clock
  (loot the dead man's chest before the tapping stick comes back). Act II
  is a stealth scene in a barrel (the tension of *not* typing anything
  rash). Act III is open-world island adventure: a siege, a one-boy naval
  operation, a duel in the rigging, and a treasure hunt where the X on
  the map is a lie — and the player who really *read* the map knows more
  than the pirates dragging him around on a rope.
- **The map is a real object with real clues.** "Tall tree, Spy-glass
  shoulder... Skeleton Island E.S.E. and by E. Ten feet." Those bearings
  genuinely identify the cache room. And the neglected second note on the
  back — the bar silver "ten fathoms south of the black crag with the
  face on it" — is a diggable optional treasure the pirates never
  bother with. Reading comprehension pays in points.
- **Silver.** Dangerous and charming in exactly the book's proportions:
  he flatters you, murders a man in front of you, saves your life, and
  robs the till on the way out. The player should never be sure which
  Silver they are talking to, and neither should Silver.
- **The parrot** is a free fun generator: random profanity, "Pieces of
  eight!", and — the book's own idea — a jump-scare burglar alarm.

**Voice:** Stevenson's narrator filtered through Zork's grin. Turn
responses are period-flavored but punchy; failure text teases rather
than punishes ("You address the ocean. The ocean, an older and larger
body than yourself, declines to answer."). Direct quotes from the novel
are used at the big beats — they are public domain and better than
anything we will write.

**Fidelity policy:** compress ruthlessly (the doctor's three narration
chapters become one arrival scene; the voyage is a montage), reorder
where it helps (the pirates confiscate the map from Jim, which replaces
the book's oddball "doctor gives Silver the chart" beat with cleaner
cause and effect), but every iconic scene in STUDY.md §5 is present and
playable or witnessed.

---

## 2. Act structure

**Act I — The Admiral Benbow (7 rooms, ~20 turns).** Cold open: Blind
Pew has just tipped Billy Bones the black spot and Billy has dropped
dead at your feet; your mother has run for the hamlet and will not be
back in time to matter. You have until the tapping stick returns: read
the spot, search the body, take the gully knife, cut the key from the
dead man's neck, open the sea-chest upstairs, dig down to the oilskin
packet, and get out — then hide under the bridge while Pew's crew
wrecks your home, and hear the blind man die under the revenue horses.
Coda at the squire's hall: the packet is opened, the map is read, and
the expedition is born. *Cut from the book:* the earlier Billy-Bones
chapters (compressed into the intro), the hamlet visit, Black Dog's
first visit (he appears in Act II instead).

**Act II — The Sea-Cook (5 rooms, ~20 turns).** Bristol docks: deliver
the squire's note to the Spy-glass tavern, meet Long John Silver at his
most charming, watch Black Dog bolt out the door. Board the Hispaniola;
the voyage passes as a montage; on the last evening you fancy an apple.
The apple barrel is the act's set piece: five turns of overheard
mutiny, frozen in place, with death waiting if you climb out early.
"Land ho!" springs you loose; you carry the news aft, and the council
of war counts seven true men against nineteen. *Cut:* Mr. Arrow (one
line of montage), the powder-and-berths dispute, most of the voyage.

**Act III — The Island (18 rooms + the ship, ~120 turns).** Open
exploration in phases: ashore with the mutineers (the marsh murder
heard, Ben Gunn met, cheese negotiable); the stockade (embassy, siege
with real melee); the escapade (white rock, coracle, cutting the hawser
between puffs of wind, boarding the runaway schooner, striking the
Jolly Roger, Israel Hands, the cross-trees); the return in the dark
("Pieces of eight!"), captivity, the Bible-page black spot; and the
treasure hunt on a rope — skeleton pointer, Flint's voice, the empty
cache, the ambush — ending in Ben Gunn's cave of gold and the sail
home, minus one sea-cook and one sack of coin. *Cut:* the doctor's
jolly-boat chapters (summarized on arrival), the gun-crew bombardment
(kept as offstage cannon fire), the Spanish-American port (moved into
the outro).

Pacing rule: Acts I and II are short and hot; nothing in them requires
wandering. Act III opens up but funnels at night. One-way gates between
acts; the only Act I items that matter later are the gully knife and
the map, and both are guaranteed by the puzzle chain (§4).

---

## 3. The map

30 rooms. DESC (status line) in title case; the LDESC given here is the
actual proposed room text, written for the ear (short, concrete, no
visual formatting). Exits use engine forms from AUTHORING.md.

### ASCII overview

```
ACT I  (Black Hill Cove)               ACT II (Bristol / ship)

  CAPTAINS-ROOM                          SPYGLASS-TAVERN
       | up                                   | n
   PARLOUR --- BAR                          QUAY --(board)-- DECK ---up--- CROSS-TREES
       | out                                                /  \
   COVE-ROAD --e-- BRIDGE                            GALLEY    CABIN
                     | down                        (fore,down) (aft,down)
                UNDER-BRIDGE  ==(scripted)==>  HALL

ACT III (Treasure Island; north is up)

                      NORTH-INLET ......(beached ship: DECK)
                           |s
   BLACK-CRAG              |
       |s                  |
   SKELETON --w-- SPYGLASS-SHOULDER --nw-- TALL-PINE
       | e (down slope)
   PLATEAU-SLOPE --e-- OPEN-WOODS --e-- HILL-FOOT --up-- BEN-CAVE
                          |s   \se           |s
                        MARSH   \        SHORE-WOODS --e-- STOCKADE-CLEARING
                          |s     \______/    |s                  | in
                     LANDING-BEACH --e------/                LOG-HOUSE
                                          SANDY-SPIT
                                             |s
                                         WHITE-ROCK
        (SANDY-SPIT --launch, night--> ANCHORAGE water room --board--> DECK)
```

### Act I rooms

**PARLOUR** — "Benbow Parlour". *The parlour of the Admiral Benbow,
your whole world until tonight. The fire is down to embers, the
overturned chair is where he knocked it, and Billy Bones lies full
length on the floor, one arm thrown out, dead of a thundering apoplexy.
The road door is out; the bar is west; the stairs go up.* Exits: OUT/
NORTH -> COVE-ROAD; WEST -> BAR; UP -> CAPTAINS-ROOM. Contents: body of
Billy Bones (with black spot near his hand; gully, compass, tobacco in
pockets; key on tarry string round his neck), overturned chair
(scenery), embers (scenery).

**BAR** — "Benbow Bar". *Bottles, the rum tap your poor father was so
proud of, and the till the neighbours swear will be robbed by morning.
A candle burns here. The parlour is back east.* Exits: EAST -> PARLOUR.
Contents: candle (takeable, lit-flavor only; the game never needs a
light source in Act I), rum bottle (takeable; DRINK responses, see
easter eggs), till (scenery).

**CAPTAINS-ROOM** — "Captain's Room". *The captain's room, smelling of
tobacco and tar. His great sea-chest stands at the bed's foot where it
has stood since the day he came, the initial B burned into the lid with
a hot iron. The stairs go down.* Exits: DOWN -> PARLOUR. Contents:
sea-chest (locked container; layered contents, §4 P2), bed (scenery),
window (scenery; LOOK THROUGH -> moonlit road flavor + timer hint).

**COVE-ROAD** — "Road by the Cove". *The frosty road outside the inn.
Fog is thinning off the cove and the moon is coming up fast, which is
bad news for anyone hoping to run unseen. The inn door stands south;
the road runs east toward the bridge and west toward Kitt's Hole.*
Exits: SOUTH/IN -> PARLOUR; EAST -> BRIDGE; WEST -> "You'd walk
straight into the smugglers' cove the lugger lies in. Even you are not
that curious tonight." Contents: signboard (scenery; EXAMINE -> the
notch from Black Dog's fight, a nod for readers).

**BRIDGE** — "Little Bridge". *A little stone bridge over the dell
stream, barely tall enough for a dog to walk under. The road runs on
toward the hamlet, but lights are bobbing on the hill behind you and
they are not friendly ones. The bank drops down to the arch below.*
Exits: WEST -> COVE-ROAD; DOWN/HIDE -> UNDER-BRIDGE; EAST -> "Moonlit
road all the way to the hamlet — they would run you down in a hundred
yards" (after the raid resolves, EAST works and is how stragglers
rejoin the plot).

**UNDER-BRIDGE** — "Under the Bridge". *You crouch in the black under
the arch, knees in the stream, close enough to the inn to hear
everything. Which is rather the problem with hiding here.* Exits: UP ->
BRIDGE (blocked with a warning while the raid runs). This room hosts
the Pew raid script (§6 T2).

**HALL** — "Squire's Hall". *The squire's library: bookcases to the
ceiling, busts on top of them, a sea-coal fire, and two gentlemen with
pipes who have just heard your story — Doctor Livesey, neat as new
paint, and Squire Trelawney, six feet of enthusiasm in a travelling
coat.* Exits: none (scene room; act transition fires from here).
Contents: Dr. Livesey (actor), Squire Trelawney (actor), fire, pigeon
pie (EAT -> "You make a supper the like of which you never had at the
Benbow. You were, as the squire observes, hungry as a hawk.").

### Act II rooms

**QUAY** — "Bristol Quayside". *Bristol docks at their busiest: tar and
salt, figureheads leaning overhead, sailors with rings in their ears
singing at the capstans. You could stand here a year. The Spy-glass
tavern is up the street north; the Hispaniola's boat waits at the
steps.* Exits: NORTH -> SPYGLASS-TAVERN; EAST/BOARD -> DECK (blocked
until the note is delivered: "The squire's note first, lad — the sign
of the Spy-glass, up the street.").

**SPYGLASS-TAVERN** — "The Spy-Glass". *A bright little tavern with a
great brass telescope for a sign, red curtains, sanded floor, and a
fog of pipe smoke full of loud seafaring men. The door back to the quay
is south.* Exits: SOUTH -> QUAY. Contents: Long John Silver (actor,
state TAVERN), Black Dog (actor; bolts on the note-delivery beat),
customers (scenery), telescope sign (scenery, EXAMINE from outside).

**DECK** — "Hispaniola, Deck". Description varies by phase flag. Act
II: *The deck of the Hispaniola, two hundred tons, the sweetest
schooner a boy ever stood on. Forward, the fore companion drops to the
galley; aft, the companion goes down to the cabin. Amidships stands
Long Tom, the brass nine, and beside it the apple barrel, broached for
any hand with a fancy.* Sea phase (after boarding from the coracle):
derelict details — no soul at the helm, a broken bottle rolling in the
scuppers, the Jolly Roger at the peak, two watchmen fallen aft. Exits:
DOWN/FORE -> GALLEY; AFT -> CABIN; UP/CLIMB MAST -> CROSS-TREES (sea
phase only); LAND -> NORTH-INLET (only after beaching). Contents: apple
barrel (open container, big enough to enter), Long Tom (scenery),
Jolly Roger (sea phase; LOWER/STRIKE it), Israel Hands + O'Brien's body
(sea phase), water-breaker (DRINK), tiller (scenery).

**GALLEY** — "Galley". *Silver's galley, clean as a new pin, dishes
burnished and hanging, and Cap'n Flint the parrot in her cage in the
corner, sidling and swearing. It smells of bacon and better days.*
Exits: UP -> DECK. Contents: parrot in cage (actor/scenery hybrid, §5),
wedge of cheese (takeable — THE key optional item), bacon, dishes
(scenery). Sea phase: ransacked flavor, cage empty ("Silver has taken
her ashore").

**CABIN** — "Stern Cabin". Act II: *The stern cabin, snug as a strong-
box: chart table, lockers, the stern window open on the wake.* Sea
phase: *wrecked — every lockfast place broken open in the hunt for the
chart, the floor thick with marsh mud, dozens of empty bottles
clinking in the corners, the lamp still burning umber over the table.*
Exits: UP -> DECK; FORE (sea phase only) -> the sparred gallery sneak
(§4 P13). Contents Act II: chart table, raisins. Sea phase: brandy
bottle, wine bottle, biscuit, medical book with gutted leaves
(EXAMINE -> "half the leaves torn out for pipelights, which tells you
everything about the new owners").

**CROSS-TREES** — "Cross-Trees". *You sit the cross-trees of the
mizzen, the whole tilted deck below you and green water below that.
Because the ship lies canted on the sand, the mast hangs far out over
the bay: a bad place to drop from, a worse one to be caught in.*
Exits: DOWN -> DECK (blocked while Hands is climbing). Scene room for
the duel (§4 P14).

### Act III rooms

**LANDING-BEACH** — "Anchorage Beach". *A curve of grey sand inside
Captain Kidd's Anchorage, dead still, smelling of sodden leaves and
rotting tree trunks. The doctor would stake his wig there's fever
here. The two gigs are drawn up on the sand. Marsh lies north, and
woods run east along the shore.* Exits: NORTH -> MARSH; EAST ->
SHORE-WOODS. Contents: gigs (scenery; endgame flavor).

**MARSH** — "The Marsh". *Willows, bulrushes, and outlandish swampy
trees; the ground quakes and steams under the sun. Somewhere a duck
gets up with a clatter, then a whole screaming cloud of them — 
something is moving on the far side of the fen. Higher ground lies
north; the beach is south.* Exits: NORTH -> OPEN-WOODS; SOUTH ->
LANDING-BEACH. Scene: the Tom murder, heard once on first entry after
going ashore (§6 T5). Contents: rattlesnake (scenery hazard; EXAMINE/
TAKE -> warned off with the book's "famous rattle" line, ATTACK ->
snake retreats; it never actually bites — it is atmosphere with teeth).

**OPEN-WOODS** — "Open Woods". *Live oaks growing low and twisted like
brambles, scattered pines fifty and seventy feet high, and the
Spy-glass trembling through the haze above everything. Paths go all
ways: marsh south, a two-peaked hill east, a long slope rising west,
sandy lowlands north, and the shore southeast.* Exits: SOUTH -> MARSH;
EAST -> HILL-FOOT; WEST -> PLATEAU-SLOPE; NORTH -> NORTH-INLET; SE ->
SHORE-WOODS.

**HILL-FOOT** — "Foot of the Two-Peaked Hill". *The ground climbs
toward a hill with two craggy peaks. Gravel spouts rattle down from
ledge to ledge as if something up there moves when you move. Among the
rocks there are mounds laid out in rows — a cemetery, of goats, with
every grave tended.* Exits: WEST -> OPEN-WOODS; SOUTH -> SHORE-WOODS;
UP -> BEN-CAVE (blocked — "The cliff wants a guide who knows it" —
until BEN-FRIEND flag; in the endgame this is the way to the gold).
Scene: first entry triggers the Ben Gunn meeting (§5). Contents: Ben
Gunn (actor), goat cemetery (scenery; PRAY here -> easter egg).

**SHORE-WOODS** — "Woods by the Shore". *Fir and live-oak growing
almost to the tide line. Through the trunks you can see the anchorage
one way and white surf the other. Paths: beach west, the two-peaked
hill north, a cleared knoll east where a British flag flies, and a
long sandy spit south.* Exits: WEST -> LANDING-BEACH; NORTH ->
HILL-FOOT; EAST -> STOCKADE-CLEARING; SOUTH -> SANDY-SPIT.

**STOCKADE-CLEARING** — "Outside the Stockade". *A wide cleared slope
around a knoll, stumps everywhere, and on the knoll a log-house behind
a six-foot paling with never a door in it — you go over or you stay
out. The Union Jack snaps overhead, which is the best thing you have
seen all day.* Exits: WEST -> SHORE-WOODS; IN/CLIMB FENCE ->
LOG-HOUSE. During the siege phase, leaving is blocked ("Musket fire in
the woods — over the fence now or die on it.").

**LOG-HOUSE** — "The Log-House". *The log-house: unsquared pine, sand
underfoot and in your teeth, loopholes on every side, and a clear
spring rising in a sunken ship's kettle by the porch. It smells of
woodsmoke and crowded men.* Exits: OUT -> STOCKADE-CLEARING (blocked
at scripted moments). Contents by phase: garrison actors (doctor,
squire, Smollett, Gray), musket rack, cutlasses (pile; TAKE CUTLASS),
biscuit bags, brandy cask; later: the pirates, Silver, the parrot,
fire.

**SANDY-SPIT** — "Sandy Spit". *A low spit of dunes and scrub running
south between the anchorage and the open sea, joined at half-water to
Skeleton Island. The surf on the sea side never stops — you believe
now that nowhere on this island is out of earshot of it. A tall rock,
peculiarly white, shows above the brush to the south.* Exits: NORTH ->
SHORE-WOODS; SOUTH -> WHITE-ROCK. Water action: PUT CORACLE IN WATER /
LAUNCH CORACLE here (night only) -> ANCHORAGE.

**WHITE-ROCK** — "The White Rock". *The white rock, taller than a man,
over a small hollow of green turf hidden by banks and knee-deep
underwood. Down in the hollow crouches a little tent of goat-skins,
like what the gipsies carry about in England.* Exits: NORTH ->
SANDY-SPIT; DOWN -> the hollow is part of the room (no sub-room).
Contents: goatskin tent (container, openable: LIFT/OPEN TENT);
inside: the coracle (takeable "vehicle", light and portable) and Ben's
old spade (takeable — the digging tool).

**ANCHORAGE** — "On the Anchorage" (water room; player is in the
coracle). *Black water, black fog, and two lights: the glow of the
pirates' camp fire ashore, and a blur at the stern window of the
Hispaniola. The ebb carries you down on her; the coracle turns any way
but the one you paddle. Her hawser rises dead ahead, taut as a
bowstring.* Exits: none walkable; scene logic only (§4 P11–P12; §6
T6). Contents: hawser (scenery, cuttable), trailing cord (after the
cut), the ship's side.

**NORTH-INLET** — "North Inlet". *A narrow northern anchorage like a
river's mouth, flat sand, trees to the water on every side, and two
ships for company: the Hispaniola lying beached on her side with your
handiwork trailing from her, and a nameless three-masted wreck so old
that shore bushes flower on her deck.* Exits: SOUTH -> OPEN-WOODS;
BOARD/CLIMB SHIP -> DECK (until the endgame departure). Contents: old
wreck (scenery; EXAMINE -> flowers, dripping seaweed; SEARCH ->
"Nothing but seaweed, flowers, and forty years of other people's bad
luck.").

**PLATEAU-SLOPE** — "Slope of the Plateau". *A long climb west: miry
ground at the bottom, then broom and flowering shrubs, nutmeg thickets,
and the red columns of great pines. The air turns fresh as you rise.
The plateau levels off above; the woods are back east.* Exits: EAST ->
OPEN-WOODS; UP/WEST -> SKELETON.

**SKELETON** — "Plateau of the Pines". *The open top of the plateau,
big pines wide apart. At the foot of one, half swallowed in a green
creeper, a human skeleton lies stretched on the ground — dead straight,
feet one way, hands raised over its head the other way, like a diver
frozen mid-plunge. Nothing about it is natural.* Exits: DOWN/EAST ->
PLATEAU-SLOPE; WEST -> SPYGLASS-SHOULDER; NORTH -> BLACK-CRAG.
Contents: skeleton (scenery; EXAMINE -> "It points. Sight along the
bones and you are looking east-southeast and by east — the line for
Skeleton Island astern of you, and for the tall trees ahead."; SEARCH
-> "Not a copper doit nor a baccy box. Somebody has been here before
the birds."). If the player has Billy's pocket compass: READ/CONSULT
COMPASS here gives the bearing explicitly.

**SPYGLASS-SHOULDER** — "Spy-Glass Shoulder". *The lower shoulder of
the Spy-glass, sheer rock above, the whole island below: the anchorage
and Skeleton Island behind you, the Cape of the Woods fringed with surf
ahead, open sea both sides. Three pines on this line could be called
tall, but one, northwest of here, is a giant — a red column big as a
cottage.* Exits: EAST -> SKELETON; NW -> TALL-PINE; UP -> "The
Spy-glass goes up sheer as a pedestal. Goats manage it. You are not a
goat."

**TALL-PINE** — "The Tall Pine". *The giant pine, two hundred feet of
it, with a shadow a ship's company could drill in. Under it the ground
has already told the whole story: a great pit, sides fallen in, grass
sprouted on the bottom, a pick-shaft broken in two, and packing boards
branded with a hot iron: WALRUS.* Exits: SE -> SPYGLASS-SHOULDER.
Contents: excavation (scenery), broken pick (scenery), boards (READ ->
"WALRUS — Flint's ship."), buried two-guinea piece (SEARCH PIT / DIG ->
find it; takeable souvenir).

**BLACK-CRAG** — "Below the Black Crag". *A black crag rises off the
north slope, and weather has beaten a face into it — brows, a broken
nose, a mouth full of shadow, watching the sea. A long hummock of sand
trends away east below it. Ten fathoms south of the crag... but that is
the map's phrase, not yours.* Exits: SOUTH -> SKELETON. Action: DIG
SAND WITH SPADE (two turns) -> the bar silver (§4 P16).

**BEN-CAVE** — "Ben Gunn's Cave". *A large airy cave with a sandy
floor, a spring rising into a pool of clear water overhung with ferns,
and — once you see it you can see nothing else — great heaps of coin
and quadrilaterals built of bars of gold, glowing back at the fire.
Flint's treasure, that seventeen men of the Hispaniola have already
died for.* Exits: DOWN -> HILL-FOOT. Contents: the treasure (scenery-
plus; TAKE -> "You fill both fists and let it run — English and
French and Spanish and Portuguese, doubloons and double guineas and
moidores and sequins, pictures of all the kings of Europe. Loading it
is tomorrow's work."), Smollett on a mattress (endgame), goat meat,
fire. Entering with the rescue party triggers the victory sequence.

---

## 4. Objects & puzzles

### Global inventory of takeable/usable objects

| object | first seen | use |
|---|---|---|
| black spot #1 (paper round) | Parlour floor | READ: "You have till ten tonight." Starts the clock in the fiction; souvenir. |
| gully knife (Billy's clasp-knife, crooked handle) | Billy's pocket | cuts key string; cuts the hawser; general knife. KEEP-FOREVER item. |
| pocket compass | Billy's pocket | flavor + explicit bearing at SKELETON. |
| pigtail tobacco, thimble, needles | Billy's pocket | flavor (one "odds and ends" object). |
| brass key | string round Billy's neck | unlocks sea-chest. |
| suit of good clothes, quadrant, canikin, sticks of tobacco, Spanish watch, brace of pistols (old), compasses, West Indian shells | sea-chest layer 1–2 | flavor layer; must be moved/taken out to reach layer 3. One composite "seaman's oddments" object plus a separate old boat-cloak. |
| boat-cloak | sea-chest layer 3 | MOVE/LOOK UNDER reveals packet + bag. |
| canvas coin bag | under the cloak | optional; heavy jingle; mother's-due jokes; no later use. |
| oilskin packet | under the cloak | THE Act I objective. GIVE to doctor at HALL. |
| account book | inside packet (doctor opens) | READ: crosses, "Offe Caraccas", "Bones, his pile." |
| treasure map | inside packet | READ anytime after HALL (two faces: the island + the note on the back with all three clues). Confiscated at the capture (§ act III phase E); Silver flourishes it thereafter. |
| squire's note to Silver | given at QUAY start of Act II | GIVE NOTE TO SILVER. |
| apple | inside barrel | EAT: "Scarce an apple left — but you find one, sweet and withered. It may be the last quiet bite of your life." |
| wedge of cheese | GALLEY | GIVE TO BEN GUNN (+10, extra hints). Toasted-cheese jokes. |
| cutlass | LOG-HOUSE pile | melee weapon in the siege; secondary hawser cutter. |
| brace of pistols + powder horn + biscuits | auto-equipped when slipping out of the stockade (phase C) | the Hands duel; biscuits are flavor food. |
| coracle | goatskin tent at WHITE-ROCK | portable boat; LAUNCH at SANDY-SPIT; destroyed on boarding the ship. |
| spade | goatskin tent | DIG at BLACK-CRAG (and anywhere, for jokes: "You dig. Sand. The island is nine miles of this."). |
| brandy bottle | sea-phase CABIN | GIVE TO HANDS -> pilot bargain. |
| wine bottle | sea-phase CABIN | GIVE TO HANDS -> completes the wine-errand trick. |
| Jolly Roger | DECK peak, sea phase | LOWER/STRIKE -> +10, "God save the King!" |
| dirk | thrown into the mast beside you | souvenir after the duel; TAKE -> "You work Israel's dirk out of the mast. You will not sleep better for owning it." |
| two-guinea piece | TALL-PINE pit | souvenir; Merry's "That's your seven hundred thousand pounds, is it?" is quoted when found. |
| black spot #2 (Bible page) | tossed to you by Silver | READ both sides: "Depposed" / "Without are dogs and murderers." Souvenir. |
| bar silver | dug at BLACK-CRAG | scores on discovery; too heavy to carry — Jim marks the spot (see P16). |

Scenery-but-referencable (need SYNONYMs): body, chest, signboard,
barrel, hawser, cord, skeleton, crag, excavation, boards, wreck, flag,
colours, parrot, cage, spring, kettle, loopholes, palisade/fence,
tiller, mast, shrouds, snake, gigs, till, stumps.

### Puzzle chain (P1–P17) with solutions, verbs, failure text, hints

Stock-engine verbs are used everywhere unless flagged NEW (see §11).

**P1. The black spot.** Room: PARLOUR. TAKE SPOT; READ SPOT -> "A
little round of paper, blackened on the one side. On the other, in a
good clear hand: You have till ten tonight." Failure/hints: doing
nothing for 3 turns -> "The clock ticks. Ten o'clock, the spot said."
The spot is optional but scores; the real gate is P2.

**P2. Key and chest.** SEARCH BODY (or EXAMINE BODY twice) reveals the
pockets (gully, compass, oddments) and "a bit of tarry string round
his neck, with something under the shirt." OPEN SHIRT or PULL STRING ->
reveals the key; TAKE KEY -> "The string is tarred and tough. Fingers
won't do it." CUT STRING WITH GULLY (gully must be taken first) -> key
in hand, and the game notes: "You pocket the captain's gully too. A
boy going where you are going wants a knife." (This line guarantees
the gully is carried.) Upstairs: UNLOCK CHEST WITH KEY ("The lock is
stiff, but the key turns and the lid throws back"), OPEN CHEST, then
layers: LOOK IN CHEST -> clothes; TAKE/MOVE CLOTHES -> oddments; MOVE
ODDMENTS or SEARCH CHEST -> boat-cloak; MOVE CLOAK / LOOK UNDER CLOAK
-> "and there, the last things in the chest: a bundle sewn up in
oilcloth, and a canvas bag that gives out, at a touch, the jingle of
gold." TAKE PACKET (+15). TAKE BAG optional -> "Your mother would
count out her due and not a farthing over. You have no time to be as
honest as your mother." Failure: trying to leave the inn without the
packet -> allowed (see T2 dead-man's-branch: the raid finds nothing OR
finds the packet — if the packet is still in the chest when the raid
runs, the pirates get Flint's fist and the game ends in a failure
outro, §8). Hints: each timer warning mentions the chest ("Whatever
Flint's crew wants, it is in that chest upstairs.").

**P3. The escape and the hiding.** With packet in hand, OUT, EAST,
DOWN (or HIDE — NEW verb, synonym for the DOWN exit at BRIDGE). At
UNDER-BRIDGE the raid script runs (T2): tapping, the door going down,
"Bill's dead!", "Scatter and find 'em!", the hill whistle twice, horses,
pistol shot, Pew's scream under the hoofs. Player just has to stay put
(UP during the raid -> "You put your head up; a lantern swings your
way. Down, fool, down." — second attempt is fatal). After: Supervisor
Dance's riders find you; scripted ride to HALL. Failure: still in the
inn or on the road when the timer expires -> death outro D1.

**P4. The map.** At HALL: GIVE PACKET TO DOCTOR (+10). Scripted beat:
the doctor snips the stitches, tries the account book (quotes), breaks
the seal — "the map of an island, nine miles long and five across,
shaped like a fat dragon standing up... three crosses of red ink, and
by the last, in a small neat hand: Bulk of treasure here." Squire's "I
fit out a ship in Bristol dock" speech. The doctor hands Jim the map:
"Keep it close, Jim. A landlord's boy is the last pocket they'll pick."
READ MAP (+5) prints both faces, including the full back-of-map note
(the three clues verbatim from the book). Reading the map is the act
gate: next turn, act transition to QUAY.

**P5. The note and the tavern.** At QUAY Jim starts with the squire's
note. NORTH; GIVE NOTE TO SILVER (+10). Scripted: Silver's start at
the letter, the man rising at the far side and bolting — "Oh, stop
him! It's Black Dog!" — Harry sent running, Morgan interrogated
("We was a-talkin' of keel-hauling"), Silver's score joke, "You and me
should get on well, Hawkins, for I'll take my davy I should be rated
ship's boy." Then Silver says he'll follow to report to the squire.
Failure: READ NOTE -> "Sealed with the squire's arms. Some things a
cabin-boy does not do." SOUTH, then BOARD SHIP -> voyage montage
(three paragraphs; Arrow goes overboard in one clause) ending at
evening before landfall: "You have a fancy for an apple."

**P6. The apple barrel.** DECK, ENTER BARREL (+5) -> "In you get
bodily. Scarce an apple left; you sit in the dark on the staves, and
the ship rocks you half to sleep — until a heavy man sits down with a
clash against the barrel." Then five WAIT/LISTEN turns, each printing
one movement of the council (Silver's pitch to Dick with "smart as
paint"; the pension speech; Hands wanting "their pickles and wines";
"the last moment I can manage"; "I claim Trelawney"; Dick sent for
rum, "Not another man of them'll jine"). Any turn the player types
EXIT/STAND/SHOUT etc. before "Land ho!" -> death outro D2 (one
warning first: on the first attempt, "Silver's shoulder is against
the staves. Move now and you die with an apple in your hand."). After
the toast — "Land ho!" rings out, the rush of feet — EXIT BARREL is
free (+20 for having heard it all). Go AFT/ENTER CABIN -> the council
of war runs scripted (+10): seven of twenty-six, "Jim here can help us
more than anyone." Morning: anchored; shore party forming; GO ASHORE /
ENTER BOAT -> LANDING-BEACH (+5). (Player may first grab the cheese in
the galley; the galley stays reachable until going ashore.)

**P7. The marsh.** First trip N from the beach triggers, one room
away, the murder heard: the angry cry, the long-drawn scream, every
marsh bird up at once. "Tom had a name and a dooty; Silver had a
crutch and a knife. You did not see it, and you will hear it the rest
of your life." Pure scene; teaches the player Silver's other face
before he is ever charming to them again.

**P8. Ben Gunn and the cheese.** First entry to HILL-FOOT: gravel
spout, the flitting figure, then Ben on his knees: "Ben Gunn... I
haven't spoke with a Christian these three years." Scripted Q&A
compresses the chapter: marooned, "I'm rich," terror of one-legged
men, "a precious sight more confidence in a gen'leman born," and —
always — "You mightn't happen to have a piece of cheese about you,
now? Toasted, mostly, I dream of it." GIVE CHEESE TO BEN (+10) -> he
capers, and pays in coin better than gold: "Under the white rock,
south down the spit, that's where Ben Gunn's boat lies — made with my
two hands, mate. And a word in your ear: him that digs under the tall
pine will dig up pig-nuts. Ben Gunn has reasons of his own." (Without
the cheese, Ben still mentions the boat once, buried mid-babble; the
cheese buys the clear version plus the cache spoiler-hint.) Then the
cannon fire event (T5) sends everyone plotward: "The whole island
wakes and bellows to a cannon. They have begun to fight."

**P9. The stockade and the siege.** First entry to LOG-HOUSE:
compressed arrival scene — the flag, the garrison's story told in six
lines (jolly-boat, lost stores, Redruth dead and under the Union Jack,
the doctor's Ben Gunn interest), night falling, then morning and
SILVER'S EMBASSY run scripted from the loopholes: flag of truce,
terms, Smollett's broadside answer, "Them that die'll be the lucky
ones." One turn later: "If you please, sir, if I see anyone, am I to
fire?" — the ATTACK (T4): a volley, boarders over the north fence, and
one pirate is suddenly IN the house through the porch. The player
must TAKE CUTLASS (the captain roars "Out, lads, out, and fight 'em in
the open! Cutlasses!") and ATTACK PIRATE WITH CUTLASS — Zork-style
randomized melee, tuned friendly: the pirate needs two good hits;
player "wounds" are staggering text, and only three consecutive turns
of doing nothing/fleeing lose the fight (death outro D3). Victory
(+15): the boarders break, five pirates down, Smollett wounded, the
count now four to nine. Lull; the doctor takes his hat and pistols
and walks off into the trees ("If I am right, he is going to see Ben
Gunn," you tell Gray). The game states the garrison is napping in the
heat — the standing invitation to the escapade.

**P10. The escapade and the coracle.** OUT from LOG-HOUSE in the lull
-> "Nobody is watching. You fill your pockets with biscuit, take a
brace of pistols with powder-horn and ball, and are over the fence
before your conscience can vote. This is your second folly, and it
will save every life you love — but you do not know that yet." (Auto-
equip guarantees the duel is winnable.) Travel S to SANDY-SPIT, S to
WHITE-ROCK. OPEN TENT / LIFT TENT -> coracle + spade. TAKE CORACLE
(+15), TAKE SPADE. Night falls (T6 starts). Back N to SANDY-SPIT, PUT
CORACLE IN WATER (or LAUNCH CORACLE) -> +5, ANCHORAGE.

**P11. The hawser.** In ANCHORAGE the ebb carries you against the
hawser automatically (one turn). CUT HAWSER (with gully or cutlass) ->
first attempt refused with the book's physics: "Taut as a bowstring.
A taut hawser suddenly cut is a thing as dangerous as a kicking horse.
Your nerve — for once — does you a service. Wait for the wind." Every
third turn a puff of wind swings the schooner and the game prints "the
hawser dips slack in your hand" (2-turn window). CUT HAWSER during
slack -> "You cut strand after strand till she rides by two." Second
slack window, CUT HAWSER again -> free (+15 total), the drift begins;
the trailing cord appears. If the player cuts while taut (they must
type CUT a second time against the refusal — CUT HAWSER when taut
after the first refusal prints a stronger warning; a third insistence
is honored and fatal, D4). Voices above: Hands and red-cap quarreling
drunk; the camp fire singing "But one man of her crew alive..."

**P12. Boarding.** GRAB/PULL CORD -> the stern-window glimpse: "Hands
and his mate locked together in a deadly wrestle, each a hand on the
other's throat." Then the current turns; a scripted drift-to-sea
sequence of 3 turns begins, ending in exhaustion, dawn, the west
coast (all narrated in compressed montage inside the ANCHORAGE room —
the room DESC updates: "Off the West Coast"), sea lions barking on
Haulbowline Head, and then the Hispaniola bearing down under sail
with nobody at the helm. On the prompt turn ("the bowsprit is over
your head — now or never"): JUMP / CLIMB BOWSPRIT / BOARD SHIP ->
aboard (+10), "a dull blow tells you the schooner has charged down and
struck the coracle, and you are left without retreat on the
Hispaniola." Any other action on the prompt turn gets one more swell
("One more chance, on the next swell —"); missing that is death D5.

**P13. Captain Hawkins.** DECK, sea phase. LOWER FLAG / STRIKE
COLOURS (V-LOWER; SYNONYM ROGER, COLOURS, FLAG) -> +10, "Down comes
the cursed black flag, and overboard. God save the King, and there's
an end to Captain Silver!" Hands, propped against the bulwarks, white
as tallow: "Brandy." CABIN: TAKE BRANDY (and WINE while you are
there; also biscuit). GIVE BRANDY TO HANDS -> the bargain: "you gives
me food and drink, and I'll tell you how to sail her. North Inlet,
says you? Why, I haven't no ch'ice, not I! I'd help you sail her up
to Execution Dock, by thunder!" Sailing montage begins (T7). Mid-
passage, the trick: Hands hesitates artfully — "you get me a bottle
of wine, Jim — this here brandy's too strong for my head." DOWN to
CABIN; the room text offers the sneak: "the sparred gallery runs
forward under the deck; the fore companion is open." GO FORE / SNEAK
FORE -> the peek: Hands on hands and knees, hauling a blood-stained
dirk from a coil of rope, hiding it in his jacket, trundling back.
Sets WARNED flag (+ no points, but changes duel text and doubles your
grace turns). UP (via fore companion), GIVE WINE TO HANDS ("Here's
luck!" — he knocks the neck off like a man who has done it often).
Skipping the sneak is survivable — the duel below still works — the
peek exists to reward paranoia and give the "densely stupid" comedy
its due. Beaching: two more WAITs; Hands pilots ("Starboard a little
— so — steady — now, my hearty, luff!"); the ship strikes and cants
45 degrees (+10 for beaching); both of you go rolling into the
scuppers, dead O'Brien on top.

**P14. Israel Hands.** The instant after the cant: "when you look
round, there is Hands, already half-way toward you, dirk in hand."
The only correct move: CLIMB MAST / UP / CLIMB SHROUDS ->
CROSS-TREES ("the dirk strikes not half a foot below you"). Any other
action: one grace turn (two if WARNED) with escalating text ("He is
between you and the bow. The shrouds, Jim, the shrouds!"), then D6.
At CROSS-TREES: the game reminds — "Your pistols! You snap one at
him: click. The priming is soaked with sea-water. Powder and ball you
have; a dry recharge is the work of a moment — if he gives you a
moment." PRIME PISTOLS (NEW verb; also LOAD/RECHARGE PISTOLS) ->
"You draw the useless charges and reprime, one pistol, then the
other. Below you, Hands, dirk in his teeth, hauls his wounded leg
into the shrouds and begins — slowly, with groans — to climb." (He
takes 2 turns to climb; PRIME needed before he arrives.) Then the
parley, verbatim-flavored: "'One more step, Mr. Hands,' said I, 'and
I'll blow your brains out! Dead men don't bite, you know.'" He stops,
swallows, speaks — "I reckon I'll have to strike, which comes hard,
you see, for a master mariner to a ship's younker like you, Jim" —
and his hand goes back: the thrown dirk pins your shoulder to the
mast (scripted, painful, non-fatal). SHOOT HANDS (NEW verb; also FIRE
PISTOLS, SHOOT HANDS WITH PISTOLS) -> both barrels; Hands drops
head-first into the bay (+25): "He rose once to the surface in a
lather of foam and blood, and then sank again for good. Being both
shot and drowned, he was food for fish in the very place he had
designed your slaughter." If pistols unprimed when he reaches the
cross-trees: D6. Aftermath in DECK: the dirk tears free ("it held you
by a pinch of skin, and the shudder tore it loose"), optional THROW
OBRIEN OVERBOARD (V-OVERBOARD exists; response uses the bald-head-
across-the-knees image), then LAND -> NORTH-INLET, wading ashore at
dusk.

**P15. "Pieces of eight!"** The trek back: S to OPEN-WOODS, SE, E, IN
at the stockade — all in dark-night text; the glow of a big fire where
the garrison never wasted wood is the fair-play clue that something is
wrong ("It had not been our way to build great fires"). Entering
LOG-HOUSE: snoring, then the shrill alarm out of the dark — "Pieces of
eight! Pieces of eight! Pieces of eight!" — Silver's voice: "Who
goes?" — captured (+10 for surviving what follows). The pirates turn
out your pockets and find the map: "So the doctor's chart weren't the
only one! Well, well — first and last, we've split upon Jim Hawkins."
(This is the game's replacement for the book's off-screen chart
hand-over: from here Silver holds the map.) Then the scripted
black-spot council over ~6 turns, with Jim's defiance speech offered
as a prompt (the game supplies it when the player types anything
defiant — ATTACK, SHOUT, TELL — or after two WAITs): the apple
barrel confession, "The laugh's on my side." George Merry's four
grievances; Silver's answer; the chart flourished; "Silver! Barbecue
forever!"; Dick's ruined Bible; Silver tosses you the spot — TAKE
PAGE/SPOT, READ -> "Depposed" / "Without are dogs and murderers."
Sleep. Morning: the doctor's sick-call runs scripted (lemon-peel
eyes, "prison doctor, I prefer to call it"), then the parley at the
fence. The one interactive beat: the doctor whispers "Whip over, and
we'll run for it." Player choice: FOLLOW DOCTOR / CLIMB FENCE / YES ->
the pirates' muskets speak; D7 ("You broke your word. It saved
nobody."). Refuse (NO / STAY / WAIT) -> Jim's honor kept, the
North-Inlet secret passed through the spars, and the doctor's exit
line to Silver: "look out for squalls when you find it."

**P16. The bar silver (optional, the map-reader's prize).** Open in
phases C and D (after the escapade, before returning to the
stockade), i.e. the natural moment is right after beaching the ship:
from NORTH-INLET go S, W, UP, N to BLACK-CRAG with the spade. The
room text plants the crag's face and the east hummock; the map's
back-note gives the rest. DIG SAND WITH SPADE -> "Two feet down the
spade rings on something that is not stone." DIG again -> "Silver in
bars, laid close as books on a shelf — Flint's north cache, that no
cross ever marked. A boy cannot carry a fortune and his life both.
You heap the sand back, set three stones on it, and carry the
knowing instead." (+15; sets SILVER-FOUND; changes the outro — the
squire's men fetch it off on the last day. Without a spade: "You dig
like a terrier. Sand runs back into sand. Whatever is under here
wants iron.") DIG anywhere else with the spade -> one of several
jokes, e.g. "You dig. The island fails to object. Ten feet, the map
said — and not here."

**P17. The hunt, the ghost, and the empty cache.** Next morning the
hunt departs (T8): Jim on a rope "like a dancing bear," Silver with
two guns and the parrot on his shoulder. Movement is on rails: each
WAIT/FOLLOW advances the party (any attempt to walk off -> "The rope
is Silver's answer, and it is a good one."). Beats, one room per
scene: PLATEAU-SLOPE (the fan-out, pig-nut country); SKELETON (the
find, the bearing taken along the bones — E.S.E. and by E. — Merry's
"this is good sea-cloth," the rifled pockets, "Great guns! Messmates,
but if Flint was living, this would be a hot spot for you and me");
SPYGLASS-SHOULDER (the rest halt, then the thin high voice out of the
trees — "Fifteen men on the dead man's chest" — Morgan grovelling,
then the wail: "Darby M'Graw! Darby M'Graw! Fetch aft the rum,
Darby!" — Silver, ashen but unbeaten: "there was an echo... no man
ever seen a sperrit with a shadow; well then, what's he doing with an
echo to him?"; Merry's slow realization: "it was liker — By the
powers, Ben Gunn!" — "dead or alive, nobody minds Ben Gunn");
TALL-PINE (the run, the halt, the pit: "The CACHE had been found and
rifled; the seven hundred thousand pounds were gone!"). The standoff:
Silver passes Jim the double-barrelled pistol ("Jim, take that, and
stand by for trouble" — TAKE PISTOL, and the player who read Ben's
cheese-hint has known for hours what the pirates just learned).
Morgan's two-guinea piece; Merry's speech; the charge — and the
three musket-shots from the nutmeg thicket; Merry and the bandaged
man down; Silver's two barrels into Merry ("George, I reckon I
settled you"); doctor, Gray, and Ben Gunn out of the trees. Surviving
the ambush: +15. The pursuit is called off ("we could see the three
survivors still running, right for Mizzenmast Hill"), and the party
walks — free movement now, but the doctor leads and any dawdling gets
a gentle "This way, Jim" — down and east to HILL-FOOT, UP to
BEN-CAVE.

**Endgame.** Entering BEN-CAVE (+40): the gold, Smollett's "You're a
good boy in your line, Jim, but I don't think you and me'll go to sea
again," the supper with Silver at the edge of the firelight. Next
turns run the loading montage (bread-bags of coin, "pieces of eight"
counted by the parrot), the three maroons left kneeling on the spit
(one musket-shot through the main-sail as a good-bye), and the last
prompt: SAIL (or BOARD SHIP then SAIL) -> +25 -> outro O1, adjusted
for SILVER-FOUND and cheese/score flourishes, ending with the final
score and rank.

### Hint escalation policy

Every timed or fatal beat warns once in flavor, then warns once
plainly, then acts. Every "stuck" room mentions its own exit verbs on
the third LOOK. The map object is itself the hint system for the
island: READ MAP re-prints the clues, and consulting it in a relevant
room appends a nudge ("You are standing on the Spy-glass shoulder the
note names."). Ben Gunn, once cheesed, answers ASK BEN ABOUT TREASURE
/ BOAT / SILVER with his three hints re-worded. Nothing in the
critical path depends on a missable object (gully and map are woven
into required scenes; pistols/powder are auto-equipped; the spade is
only needed for the optional treasure).

---

## 5. NPCs

The engine's actor ceiling is Zork's thief: scripted scene beats plus
a few states, driven by room-entry triggers and clock demons. Nobody
here free-roams; everyone is a stage actor who appears where the play
needs them. All "conversation" is beat-triggered; ASK/TELL fall back
to in-character brush-offs so the LLM layer always has something good
to relay.

**Long John Silver.** One object, five states:
- TAVERN (Act II): warm host; GIVE NOTE triggers the Black Dog scene.
  Default responses drip charm ("You and me should get on well,
  Hawkins, for I'll take my davy I should be rated ship's boy.").
- GALLEY (voyage): yarns and parrot patter; foreshadow only.
- ENEMY (blockhouse, phases E): captor-protector; drives the council
  scripts. ATTACK SILVER -> "He is twice your size, half your legs,
  and ten times your wickedness. He looks almost hurt at the thought."
- HUNT (phase F): holds your rope; increasingly cold as gold nears
  ("From time to time he turns his eyes on you with a deadly look —
  and you read him like print."), flips warm at the cache.
- TAME (endgame): "the same bland, polite, obsequious seaman of the
  voyage out." Gone in the outro with his sack of coin.
  Kill-rule: none. Silver cannot die and cannot be fought; the game is
  explicit that surviving him is the achievement.

**Captain Flint (the parrot).** A portable ambience machine. In any
room with the cage or Silver(HUNT/ENEMY), a 1-in-4 demon prints one
of: "Pieces of eight! Pieces of eight!", "Stand by to go about!",
an unprintable oath ("The parrot says something that would curl a
chaplain's wig."), or pecking at the bars. Scripted star turns: the
blockhouse alarm (P15) and counting coins in the outro. GIVE anything
-> she bites. TAKE PARROT -> "She has sailed with England the pirate
and watched the fishing-up of the plate ships. She is not going in a
boy's pocket."

**Dr. Livesey.** Scene anchor in HALL, LOG-HOUSE, the parley, and the
rescue. States: HALL (opens packet), GARRISON, PAROLE (offers the
escape you must refuse), RESCUE. Voice: dry, "I'll stake my wig."

**Squire Trelawney.** HALL and endgame flavor, plus the garrison. Big,
loud, quotable; the game's designated exposition cannon.

**Captain Smollett.** GARRISON (runs the siege script) and BEN-CAVE
(wounded, on the mattress, gets the "born favourite" line). Serves as
the voice of consequences in death outros ("I'll have no favourites
on my ship.").

**Ben Gunn.** HILL-FOOT resident until the rescue. States: FERAL
(first meeting script), FRIEND (after the scene; CHEESED sub-flag if
fed). Beat-triggered hints (§4 P8). Offstage he is the ghost voice of
P17 — the game credits him by name in the rescue scene. Endgame: on
deck in the outro, and the thousand-pounds-in-nineteen-days epitaph.

**Israel Hands.** Sea-phase antagonist: states WRECKED (begging
brandy), PILOT (sailing montage, wine errand), MURDER (the duel),
DEAD (visible on the sand under the clear water — EXAMINE from deck
gives the fish-steering-over-him image). His dialogue carries the
duel's hint escalation.

**Billy Bones** is a body; **Blind Pew** is a sound design (tapping,
voice) and one off-screen death; **Black Dog** is three sentences of
panic in a tavern. The **pirates** in Act III are one collective
object ("the buccaneers") plus named lightweights — George Merry
(council antagonist), Tom Morgan (superstition), Dick (Bible, fever)
— who exist as SYNONYMs and beat-text, not independent actors. The
**boarding pirate** in the siege is the one real combat actor
(VILLAIN-style melee tables, generous odds, see §6 T4).

---

## 6. Timers & danger

All via GCLOCK interrupts (Zork lantern/thief pattern). Death routes
through JIGS-UP with piratical text (§8), then the engine's standard
restart/restore offer. The design has no starvation, no light-source
bookkeeping, and no inventory-loss traps; every timer is local to its
scene and telegraphed twice.

**T1. The Benbow clock (Act I).** 22 turns from the first prompt.
Warnings at ~8 ("Far off on the frozen road: tap — tap — tap. It
stops. It starts again."), ~14 ("The tapping again, nearer, and this
time a low whistle answers it from the hill. You have minutes, not
hours."), ~19 ("Feet on the road — many feet, running."), 22: if the
player is in any inn room or COVE-ROAD -> D1. Hiding at UNDER-BRIDGE
before expiry -> T2. The clock is generous: the whole heist takes 12
turns at a walk.

**T2. The raid (scripted, safe if hidden).** 6 turns of theatre heard
from under the arch, ending with Pew's death and the riders. If the
packet was left behind, the raid finds it: failure outro O3 ("they
have got Flint's fist after all...").

**T3. The barrel (Act II).** Not a countdown but a lock-in: 5
dialogue turns + the Land-ho release. One warning against standing
up, then death D2. (Deliberately the inverse of T1: the challenge is
patience, and it reads beautifully over TTS.)

**T4. The siege melee.** Zork-style randomized combat, tuned fair:
the boarding pirate has 2 hit-points of narrative; player attacks hit
on 75%; pirate "hits" only stagger (lose-a-turn) with colorful text;
actual death only after 3 consecutive turns of not fighting (fleeing
the house mid-fight = D3's cousin, shot crossing the clearing).
FIND-WEAPON returns the cutlass so DIAGNOSE/combat verbs behave.

**T5. Island ambience clock.** Fires the murder scene (first MARSH
entry), the cannon shot (2 turns after the Ben Gunn scene ends),
distant "Lillibullero" whistling near the beach, and nightfall when
the coracle is taken. Pure pacing; no fail states.

**T6. The ebb-tide sequence.** From LAUNCH: the wind-puff cycle
(slack windows every 3rd turn, 2 turns wide) for the hawser; after
the second cut, a fixed 5-turn drift script (cord glimpse -> current
turns -> "so you must have lain for hours" montage -> dawn off the
west coast -> the bearing-down schooner and the one-swell,
two-chance boarding prompt). Failure states: cutting taut (D4, needs
three insistences), missing both boarding swells (D5).

**T7. The Hands duel.** Sailing montage of 6 turns with the wine
errand in the middle; then the strike-and-cant trigger; 1 grace turn
(2 if WARNED) to climb; Hands' 2-turn climb to the cross-trees
against the PRIME requirement; the throw; SHOOT. Failures all -> D6
with cause-specific first lines.

**T8. The treasure hunt rails.** Party advances on WAIT/FOLLOW; 12
turns of scenes end at the ambush regardless; the only player-fatal
move is repeatedly fighting the rope (3 attempts -> "Silver hauls you
in like a fish and the crew votes with its knives" -> D8 — this
exists so the rails never feel like glass).

**Death handling.** JIGS-UP prints the scene-specific outro paragraph
(see §8), then: "Your adventures end here — as Blind Pew's did, as
Israel Hands' did, as seventeen men of the Hispaniola's did. The sea
keeps no favourites." + score + RESTART/RESTORE/QUIT. No resurrection
mechanic; scenes are short enough that death-and-retry is cheap.

---

## 7. Scoring

`SCORE-MAX 350`, Zork convention. Awards (SETG SCORE in action
routines; no TVALUE trophy case — the island is the case):

| # | deed | pts | running |
|---|---|---|---|
| 1 | take the black spot | 5 | 5 |
| 2 | cut the key from Billy's neck | 10 | 15 |
| 3 | open the sea-chest | 5 | 20 |
| 4 | take the oilskin packet | 15 | 35 |
| 5 | survive the raid under the bridge | 10 | 45 |
| 6 | give the packet to Dr. Livesey | 10 | 55 |
| 7 | read the treasure map | 5 | 60 |
| 8 | deliver the note to Silver | 10 | 70 |
| 9 | enter the apple barrel | 5 | 75 |
| 10 | overhear the whole council | 20 | 95 |
| 11 | council of war in the cabin | 10 | 105 |
| 12 | go ashore with the landing party | 5 | 110 |
| 13 | meet Ben Gunn | 10 | 120 |
| 14 | give Ben Gunn the cheese | 10 | 130 |
| 15 | reach the log-house | 10 | 140 |
| 16 | beat off the boarder in the siege | 15 | 155 |
| 17 | find the coracle | 15 | 170 |
| 18 | launch the coracle | 5 | 175 |
| 19 | cut the hawser (on the slack) | 15 | 190 |
| 20 | board the drifting Hispaniola | 10 | 200 |
| 21 | strike the Jolly Roger | 10 | 210 |
| 22 | beach the ship in North Inlet | 10 | 220 |
| 23 | defeat Israel Hands | 25 | 245 |
| 24 | discover the bar silver (optional) | 15 | 260 |
| 25 | survive the black spot council | 10 | 270 |
| 26 | survive the ambush at the cache | 15 | 285 |
| 27 | enter Ben Gunn's cave | 40 | 325 |
| 28 | sail for home | 25 | 350 |

Ranks (printed with score; the LLM layer reads these off the status
data, so keep them short):

| score | rank |
|---|---|
| 0–34 | Swab |
| 35–74 | Cabin Boy |
| 75–119 | Ship's Boy |
| 120–169 | Able Seaman |
| 170–219 | Coxswain |
| 220–269 | Quartermaster |
| 270–324 | Sea-Cook |
| 325–349 | Cap'n |
| 350 | Gentleman o' Fortune |

(The joke of the ladder: the best pirates in the book are the cook
and the quartermaster — both of whom are Silver.)

---

## 8. Intro & outro drafts

### Intro (printed by GO before the first prompt; ~40 seconds of TTS)

> Squire Trelawney, Doctor Livesey, and the rest of these gentlemen
> having asked me to write down the whole particulars about Treasure
> Island, I take up my pen in the year of grace seventeen-something,
> and go back to the night it all began — the night of the black spot.
>
> You are Jim Hawkins, fourteen, of the Admiral Benbow inn, Black Hill
> Cove. For months an old buccaneer called Billy Bones has lodged
> under your roof, drinking rum against doctor's orders and paying you
> a silver fourpenny a month to keep your weather-eye open for a
> seafaring man with one leg. This afternoon a blind beggar came
> tap-tapping up the frozen road, gripped your arm like a vise, and
> pressed something into the captain's palm. "And now that's done,"
> said the blind man, and skipped out into the fog.
>
> The captain read his palm just once. "Ten o'clock!" he cried. "Six
> hours. We'll do them yet" — and sprang up, and reeled, and went down
> like a felled mast. Thundering apoplexy, the doctor would call it.
> Dead, is what it is, on the parlour floor, with the little black
> round of paper still lying by his hand.
>
> Your mother has run for help to the hamlet; you know already what
> help the neighbours will be. The fire is low. The clock ticks. Out
> on the road, faint and far off for now, you can hear it if you hold
> your breath: tap. Tap. Tap.
>
> TREASURE ISLAND: A Tale of the Sea-Cook — freely adapted from
> Robert Louis Stevenson. Type as you please; the inn, at least for
> the moment, is yours.

### O1 — Victory outro (sail for home; ~45 seconds)

> The Hispaniola stands out of North Inlet with the same colours
> flying that the captain fought under at the stockade. On the spit,
> three marooned men kneel in the sand with their arms out; the
> doctor hails them the news of the stores you have left, and one of
> them, by way of thanks, puts a musket-ball through the main-sail.
> [If SILVER-FOUND: "In the hold, along with the gold, lie certain
> bars of silver from under a black crag — fetched off on the last
> morning by the squire's men, to the everlasting glory of the only
> soul aboard who ever read a map to the bottom."]
>
> At the first port with lights and fruit-boats, Long John Silver
> goes over the side in a shore boat, quietly, in the dark, with a
> sack of coin worth three or four hundred guineas to help him on his
> further wanderings. Ben Gunn confesses everything at dawn. You are
> all of you, on the whole, pleased to be so cheaply quit of him.
>
> Home, then: five men of all that sailed, and the gold notched into
> every one of your natures. Smollett retires; Gray saves and rises;
> Ben Gunn gets a thousand pounds and spends it in nineteen days. And
> you — you have money enough, and no wish on earth to see that
> accursed island again. Oxen and wain-ropes would not bring you
> back. Though on the worst nights you still hear the surf booming on
> its coasts, and start upright in bed with the sharp voice of Captain
> Flint ringing in your ears: "Pieces of eight! Pieces of eight!"
>
> [score, rank]

### O2 — Death outro D5, lost at sea (the interesting failure; ~25 s)

> The swell lifts, the bowsprit passes over you like a church door
> closing, and the moment — the one moment — is gone. The current has
> the coracle now, and the current wants the open sea. You bail with
> your sea-cap and steer with a prayer; the island shrinks to a
> smudge, to a thought, to nothing. Gulls ask after you. Nobody else
> does. Somewhere behind you, on a beach you will never see, a man
> with one leg is explaining to the last honest men in the world that
> the boy was lost, poor lad — brave, but never what you'd call smart
> as paint. The worst of drowning at sea, you find, is the time it
> gives you to review your decisions.

### O3 — Failure outro (raid finds the packet; game over, not death)

> From under the arch you hear it all: the door going down, boots on
> your mother's stairs, and then the cry from the captain's window —
> "It's here! Flint's fist, by thunder!" Cheering. Blind Pew laughing
> like a gull. They are gone before the riders come, out through
> Kitt's Hole on the ebb, and the map with them. Doctor Livesey says,
> gently, that no boy could have done more. The squire says nothing at
> all, which is worse. Somewhere past the horizon, a crew of merry
> gentlemen is beating up for a certain island — and the age of your
> adventures is over at fourteen, in a wrecked inn, with the kettle
> on.

Other death texts (one paragraph each, same register): D1 caught at
the Benbow ("Them that die'll be the lucky ones, a wise man will say
of another occasion..."), D2 the barrel ("You stand up with an apple
in your hand..."), D3 the siege, D4 the hawser ("A taut hawser,
suddenly cut, is a thing as dangerous as a kicking horse. You were
told."), D6 Hands ("him as strikes first is my fancy — his views,
amen, so be it"), D7 broken parole, D8 fighting the rope.

---

## 9. Walkthrough (the test spec)

Raw parser commands, start to 350. Bracketed lines are events, not
input. This is the transcript the CI walkthrough file should encode.

```
 1. TAKE SPOT
 2. READ SPOT
 3. SEARCH BODY
 4. TAKE GULLY
 5. TAKE COMPASS
 6. CUT STRING WITH GULLY          [key drops into your hand]
 7. UP
 8. UNLOCK CHEST WITH KEY
 9. OPEN CHEST
10. TAKE CLOTHES
11. MOVE ODDMENTS
12. MOVE CLOAK                     [packet and coin bag revealed]
13. TAKE PACKET
14. DOWN
15. OUT                            [tapping nearer]
16. EAST
17. DOWN                           [under the bridge]
18. WAIT
19. WAIT                           [raid; whistle; horses; Pew dies]
20. WAIT                           [Dance takes you up; ride to the hall]
21. GIVE PACKET TO DOCTOR
22. READ MAP                       [act transition: Bristol]
23. NORTH
24. GIVE NOTE TO SILVER            [Black Dog bolts; Silver's turn]
25. SOUTH
26. BOARD SHIP                     [voyage montage; evening of landfall]
27. DOWN                           [galley]
28. TAKE CHEESE
29. UP
30. ENTER BARREL
31. WAIT                           [Silver and Dick: smart as paint]
32. WAIT                           [the pension speech]
33. WAIT                          [Hands: pickles and wines; when? the last moment]
34. WAIT                           [I claim Trelawney; Dick sent for rum]
35. WAIT                           [the toast; LAND HO!]
36. EXIT
37. ENTER CABIN                    [council of war; morning; shore party]
38. GO ASHORE
39. NORTH                          [the marsh; the scream]
40. NORTH
41. EAST                           [Ben Gunn scene]
42. GIVE CHEESE TO BEN             [white rock + pig-nuts hints; cannon]
43. SOUTH
44. EAST
45. IN                             [garrison; night; embassy; the attack]
46. TAKE CUTLASS
47. ATTACK PIRATE WITH CUTLASS
48. ATTACK PIRATE WITH CUTLASS     [boarder down; victory; lull; doctor leaves]
49. OUT                            [the escapade: biscuit, pistols, powder]
50. WEST
51. SOUTH
52. SOUTH                          [the white rock]
53. OPEN TENT
54. TAKE CORACLE
55. TAKE SPADE                     [night falls]
56. NORTH
57. LAUNCH CORACLE                 [the anchorage; the taut hawser]
58. CUT HAWSER WITH GULLY          [refused: wait for the wind]
59. WAIT
60. WAIT                           [a puff; the hawser dips slack]
61. CUT HAWSER WITH GULLY          [strands part; she rides by two]
62. WAIT                           [second slack]
63. CUT HAWSER WITH GULLY          [free; drifting]
64. PULL CORD                      [the cabin-window glimpse; the ebb runs]
65. WAIT
66. WAIT                           [dawn; sea lions; the Hispaniola bears down]
67. JUMP                           [aboard; the coracle stove under her forefoot]
68. LOWER FLAG                     [God save the King]
69. DOWN                           [the wrecked cabin]
70. TAKE BRANDY
71. TAKE WINE
72. UP
73. GIVE BRANDY TO HANDS           [the bargain; under way]
74. WAIT                           [Hands wants wine]
75. DOWN
76. GO FORE                        [the peek: the dirk in the coil of rope]
77. UP
78. GIVE WINE TO HANDS             [Here's luck!]
79. WAIT
80. WAIT                           [luff! — she strikes and cants; Hands comes]
81. CLIMB MAST                     [the cross-trees; pistols wet]
82. PRIME PISTOLS                  [Hands starts up the shrouds]
83. SHOOT HANDS                    [the dirk pins you; both barrels; he falls]
84. DOWN
85. LAND                           [North Inlet, dusk]
86. SOUTH
87. WEST
88. UP                             [the skeleton, by moonlight]
89. NORTH                          [the black crag]
90. DIG SAND WITH SPADE
91. DIG SAND WITH SPADE            [the bar silver; you mark the spot]
92. SOUTH
93. DOWN
94. EAST
95. SE
96. EAST
97. IN                             [PIECES OF EIGHT! — captured; the council;
                                    the map found on you; the black spot again]
98. TAKE PAGE
99. READ PAGE                      [Depposed]
100. WAIT                          [sleep; morning; the doctor's rounds; parley]
101. STAY                          [you passed your word; squalls warning]
102. WAIT                          [the hunt forms; the rope; the boats]
103. WAIT                          [up the slope]
104. WAIT                          [the skeleton pointer, ESE and by E]
105. WAIT                          [Fifteen Men — the voice — Darby M'Graw]
106. WAIT                          [nobody minds Ben Gunn; the tall tree ahead]
107. WAIT                          [the empty cache]
108. TAKE PISTOL                   [Silver: stand by for trouble]
109. WAIT                          [Merry's charge; three shots; the rescue]
110. FOLLOW DOCTOR                 [down to the hill; the story of Ben's dig]
111. UP                            [Ben Gunn's cave: the gold]
112. WAIT                          [supper; days of loading; the maroons]
113. SAIL                          [outro; 350 points; Gentleman o' Fortune]
```

Minimal-path variant (for a second CI transcript): skip 5, 27–28, 42,
86–95 (no compass, no cheese, no bar silver) -> finishes at 325,
rank Cap'n — proves optional content is optional and the top rank is
reserved for the completionist.

---

## 10. Writing style guide for all in-game text

The game will be voiced by TTS through the LLM layer. Every string in
the source obeys these rules:

1. **Write for the ear.** No ASCII art, no tables, no ALL-CAPS
   emphasis (ship names take no special casing in running text: "the
   Hispaniola"), no asterisks, no visual layout tricks. Punctuation
   does the acting: dashes, colons, short sentences.
2. **Length discipline.** Normal turn responses: 1–3 sentences. Room
   descriptions: 2–4 sentences. Hard cap for any response: two short
   paragraphs, and only scene beats (embassy, council, cache) get
   two. The intro and outros are the only longer texts.
3. **Register: Stevenson at the helm, Zork in the crow's nest.**
   Period vocabulary, concrete nouns, sea-rhythm — and a dry modern
   wit underneath for failure text. Never anachronistic slang, never
   a wink so broad it breaks the fiction. Good: "The ocean, an older
   and larger body than yourself, declines to answer." Bad: "Nice
   try, matey!"
4. **Quote the book at the summits.** The famous lines (STUDY.md §6)
   appear verbatim at their moments and are never paraphrased.
   Dialect spelling is kept in quoted dialogue ("dooty," "sperrit")
   but never used in narration — TTS handles quoted dialect
   acceptably if narration around it is clean.
5. **Failure text is a genre.** Every common wrong verb gets a
   bespoke line in key rooms; the default engine refusals are the
   backstop, not the norm. Examples to implement: SWIM at any beach
   ("You have seen what the surf does to boats. It is not waiting to
   do better by boys."); KISS PARROT ("She has the vocabulary of two
   hundred wicked years and she uses all of it."); SING ("You give
   them a stave of Fifteen Men. Somewhere your mother's ears burn.").
6. **Second person, past-shadowed.** Present-tense narration ("The
   tapping stops."), with Jim's retrospective voice reserved for
   scene codas ("You will hear it the rest of your life.") — used
   sparingly, one per scene at most.
7. **Easter eggs** (all one-liners, all optional): XYZZY -> "That is
   the other kind of magic, and a different ocean entirely."; YOHO or
   SING -> a verse of the shanty; SAY PIECES OF EIGHT near the parrot
   -> she answers forever; DRINK RUM -> "The name of rum for you is
   death, said the doctor — and you are fourteen."; PRAY at the goat
   cemetery -> "It weren't quite a chapel, but it seemed more solemn
   like."; COUNT COINS in the cave -> the kings-of-Europe catalogue;
   DIAGNOSE after the duel mentions the shoulder-pinch scar; ZORK ->
   "Wrong cellar."
8. **Status line** (v3 only; absent in v8 — see §11): room DESC in
   title case, short: "Cross-Trees", "The Log-House".

---

## 11. Build notes

**Version target: v8** (`-I zil/engine-v8 -v 8`, plus the
`<VERSION? (ZIP) ...>` guard line per AUTHORING.md). Reasons: (a) the
engine already uses most of v3's 32 flags and this design wants
~12–15 story flags (act/phase, BEN-FRIEND, CHEESED, WARNED,
SILVER-FOUND, HAWSER-SLACK, PRIMED, PAROLE, plus scene indices packed
into globals where possible — globals preferred over flags wherever
the state is a counter); (b) the text budget above (long intro/outros,
bespoke failure text everywhere) will strain 128KB with abbreviations
on; v8's 512KB removes the worry. Cost: no status bar, acceptable for
the LLM/TTS front end. A v3 build should still be attempted first as
a stretch check — if it fits, ship both like Tiny Quest.

**Counts vs limits.** Rooms 30 + objects ~85 (including GGLOBALS' 18
and stubs) ≈ 115 objects — far under 255. Properties: standard set
only. Verbs: ~6 new syntaxes (below) against ~100 stock.

**Object-number ordering.** GGLOBALS before TIDUNGEON, per
AUTHORING.md, so the parser's IT stays below object 19.

**Dictionary (6-character truncation) watch-list.**
- SILVER the man vs the bar silver: fatal collision if both are noun
  SILVER. Resolution: the dug treasure is the **INGOT** / "bars"
  (SYNONYM INGOT, BARS; DESC "bars of silver"); narration may say
  "bar silver" but the parser noun is INGOT. Long John owns SILVER,
  JOHN, COOK, BARBEC.
- CAPTAIN is claimed by three: Billy ("the captain"), Smollett, the
  parrot ("Cap'n Flint"). Resolution: CAPTAI belongs to Billy in Act
  I rooms only (local object), to Smollett in garrison rooms; the
  parrot answers to PARROT, FLINT, BIRD, POLLY. Never give two of
  them CAPTAI in the same room's scope.
- SPYGLA: the tavern (Act II room) vs Spy-glass hill (Act III
  scenery). Different acts, no live conflict, but the global scenery
  object for the hill should live only in island rooms.
- STOCKA (stockade), PALISA (palisade), HISPAN (ship), TREASU,
  CORACL, HAWSER, POWDER, PISTOL (one object = the brace), CUTLAS,
  COMPAS vs COMPAN(ION): distinct at 6, fine. BARREL vs BAR: BARREL
  is 6 exactly, BAR is the room word — keep BAR out of object
  synonyms (the bar room needs no noun).
- PACKET vs PAGE vs PAPER: black spot #1 takes SPOT+PAPER; #2 takes
  PAGE+SPOT (Act III only; #1 is long gone or in inventory —
  disambiguate by adjective BLACK/BIBLE if both carried).
- BODY: Billy in Act I, O'Brien at sea — different rooms, fine.

**New syntax needed** (everything else uses stock gverbs — TAKE,
OPEN, UNLOCK, READ, SEARCH, MOVE, LOOK-UNDER, CUT...WITH, GIVE,
ENTER/BOARD/EXIT, LAUNCH, CLIMB, JUMP, WAIT, LISTEN, ATTACK...WITH,
DIG...WITH, LOWER, THROW/V-OVERBOARD, FOLLOW, PRAY, COUNT):
```zil
<SYNTAX SHOOT OBJECT = V-SHOOT>
<SYNTAX SHOOT OBJECT WITH OBJECT = V-SHOOT>
<SYNTAX PRIME OBJECT = V-PRIME>          ;"also LOAD, RECHARGE as verb synonyms"
<SYNTAX HIDE = V-HIDE>                   ;"sugar for the bridge exit"
<SYNTAX SAIL = V-SAIL>                   ;"endgame trigger; elsewhere: a wistful refusal"
<SYNTAX STAY = V-STAY-PAROLE>            ;"the parole choice; STAY exists as V-STAY - verify and reuse if compatible"
```
Note V-STAY already exists in gverbs — check its semantics; if it is
the vehicle-stay verb, reuse it with a room-scoped action override
instead of new syntax. GO FORE: implement as a FORE exit on the
sea-phase CABIN plus SYNTAX-less direction word? Simpler: make FORE a
direction is wrong — use `<SYNTAX SNEAK = V-SNEAK>` scoped to the
cabin, with EXITS also accepting NORTH as the mundane route back up.
Decide at implementation; the design only requires *some* discoverable
phrasing, and the room text names it explicitly.

**Engine mechanics reused.** GCLOCK demons for T1–T8 and the parrot;
Zork melee tables for the siege (define VILLAIN pirate + best-weapon
cutlass; FIND-WEAPON returns it); VEHBIT for the coracle and barrel
(barrel as enterable container in the room, coracle as carried object
that becomes a vehicle only via the LAUNCH scene — while carried it
is just a heavy portable); door-gated and flag-gated exits per
AUTHORING.md forms; INVISIBLE for the key-under-shirt and the
tent contents; the required stubs (WATER, GLOBAL-WATER, WALL,
ON-LAKE/IN-LAKE, FLAG-CARRIER) copied from Tiny Quest — note the
ANCHORAGE water room wants NONLANDBIT handling exactly like those
stubs anticipate.

**Engine risks / open questions.**
1. Multi-turn scripted scenes (barrel, councils, hunt) are just
   room-action + global counter patterns — Zork's own Loud Room and
   thief scenes prove the shape — but they are the bulk of the
   implementation effort and each needs a "player typed something
   weird mid-scene" fallback line.
2. The rails of Phase F (movement denial + forced party movement)
   must not fight the parser's GOTO; implement as: rooms' action
   routines intercept WALK while ON-ROPE flag set.
3. The DECK/GALLEY/CABIN triple serves two acts with phase-switched
   text; verify that changing LDESC via room-action M-LOOK branches
   (not swapped rooms) keeps the walkthrough transcript stable.
4. Scoring uses direct SETG SCORE like Tiny Quest; each award behind
   a once-flag.
5. Combat randomness vs frozen-transcript CI: seed or de-randomize
   the siege in test mode (fixed hit sequence when a test global is
   set, mirroring how Zork's own tests handle the thief), or make the
   boarder deterministic (2 hits, staggers on fixed turns) — the
   design prefers deterministic-with-flavor-variance so the CI
   transcript is byte-stable.
6. Dialect words in dictionary: none needed — players type standard
   English; dialect lives only in output.

**Estimated effort.** ~2,700 lines of ZIL against Tiny Quest's ~600;
the walkthrough above is the acceptance test; the minimal-path
variant is the regression test for optional content.
