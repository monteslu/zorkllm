# THE COUNT OF MONTE CRISTO — Game Design
### A text adventure in five acts for the zorkllm engine (czil / Zork 1 engine files)

Companion documents: `STUDY.md` (source analysis with verified quotes),
`book.txt` (Gutenberg #1184). Target: v8 story file (`-I zil/engine-v8 -v 8`)
— see Build Notes for why.

---

## 1. VISION & TONE

The player fantasy: **wronged, buried, reborn, unstoppable.** You are given
one perfect day of happiness, and it is stolen with a sheet of paper. You
claw through a fortress wall with a saucepan handle. You are thrown into
the sea inside a corpse's sack, and you cut your way out. You rise dripping
from your own grave richer than kings — and then, one by one, you visit
your enemies wearing faces they do not know, until the moment you choose to
say the name: *Edmond Dantès.*

Tone: Dumas's melodrama at Zork tempo. Every response is short, spoken,
and a little grand. The game is generous with atmosphere and strict with
justice: the wicked fall by their own vices (greed, vanity, ambition,
envy), never by the player's sword. The player's own arc bends the same
way the novel's does — vengeance runs hot until it costs an innocent, and
the final points are earned by mercy, not murder.

Design center of gravity: **Act II (the Château d'If) is the game's heart**
— Dumas practically wrote an adventure game there, with object puzzles,
failure states, and a mentor NPC. Acts I and III bracket it with a short
on-rails tragedy and a treasure hunt. Act IV converts the social Paris
half into four compact capers with rooms, props, disguises, and
information-as-items. Act V is the descent from wrath to "wait and hope."

A full run is designed for roughly 3-4 hours / ~130 essential commands.

---

## 2. ACT STRUCTURE

- **ACT I — Marseilles, 1815** (8 rooms, ~25 turns). One perfect day: bring
  the Pharaon home, secure the captaincy, embrace your father, kiss your
  betrothed — and be arrested at your own wedding feast. On rails but
  interactive; the player performs the happiness so the theft lands.
  Villefort's examination ends the act with the letter burning in the
  grate. No deaths possible.
- **ACT II — The Château d'If, 1815-1829** (6 rooms, the long act). Years
  pass in narrated compressions between playable set pieces: the sound in
  the wall, the improvised dig, Faria, the education, the treasure secret,
  Faria's death, the burial-sack swap (the player must conceive it), the
  underwater escape, the storm swim to Tiboulen, rescue by smugglers.
  Deaths possible and fair.
- **ACT III — Monte Cristo & Marseilles, 1829** (8 new rooms + 2 revisited).
  The treasure grotto (count the rocks, blast the boulder, sound the
  walls, break the coffer); then the first two uses of the fortune: the
  diamond buys Caderousse's confession and the red silk purse; the purse
  on the old mantel saves Morrel at the pistol's mouth. The player learns
  what fourteen years cost everyone.
- **ACT IV — Paris, 1838** (16 rooms). The Count's hub, plus four capers
  the player may interleave: **the banking sabotage** (credit letter +
  telegraph bribe vs. Danglars), **the public exposure** (Haydée's
  documents and the Chamber of Peers vs. Morcerf, ending in the sailor-
  jacket reveal), **the house of poison** (Auteuil's buried box, Bertuccio's
  testimony, protecting Valentine, the Assizes bomb vs. Villefort), and
  **the diamond trap sprung** (Caderousse's burglary and deathbed). Key
  confrontations gate on evidence; premature confrontation is punished.
- **ACT V — Expiation, 1838-39** (2 new rooms + 2 revisited). Edouard's
  death has already checked the rampage; now the player pardons the
  starving Danglars in Vampa's catacombs, revisits cell 34 for Faria's
  manuscript, and gives the grotto — and the letter that ends "wait and
  hope" — to Maximilian Morrel. The white sail. No deaths.

40 rooms total.

---

## 3. THE MAP

Room names below are the ZIL object names; quoted strings are the DESC
(status line). LDESCs are written final, for the ear.

### ACT I — Marseilles, 1815 (8 rooms)

```
                    [MEILHAN]
                        |
   [OFFICE] -- [QUAY] --+-- [RESERVE]
                 |  \
          (ship) |   [CATALANS]
   [DECK]--------+
     |
   [CABIN]                     [VSTUDY] (reached only by arrest)
```

**DECK — "Deck of the Pharaon"** (start)
LDESC: "You stand at the helm of the three-master Pharaon, gliding into
Marseilles harbor under a February sun. The crew waits on your word, for
Captain Leclere lies sewn in his hammock at the bottom of the sea, and at
nineteen you have brought his ship home. On the quay, all Marseilles has
turned out to watch."
Exits: DOWN to CABIN; WEST/LAND/OUT to QUAY (blocked until sails furled
and anchor dropped: "The ship is not yet at her rest. She is your charge
before she is your triumph.").
Contents: MORREL (arrives by skiff, turn 2), DANGLARS (sulking by the
mast), SAILS, ANCHOR, CREW (scenery).

**CABIN — "Captain's Cabin"**
LDESC: "Captain Leclere's little cabin still smells of pipe smoke and
sea-damp charts. His sword and cross of honor lie boxed for his widow.
It was here, dying, he made you swear to touch at Elba."
Exits: UP to DECK.
Contents: SEA-CHEST (openable; sword, cross — flavor), a mirror line
about the ELBA-LETTER in your coat.

**QUAY — "Marseilles Quay"**
LDESC: "Fishwives, porters, and half the town crowd the sun-white stones
of the quay. North lie the Allées de Meilhan where your father lives;
south, the Catalan village; west, Morrel's counting-house. Eastward, under
its arbor by the water, the tables of La Réserve are being laid for a
feast — yours."
Exits: N MEILHAN, S CATALANS, W OFFICE, E RESERVE, IN/BOARD to DECK.

**OFFICE — "Morrel's Counting-House"**
LDESC: "Ledgers, sealing wax, and the smell of ink and tar. Portraits of
Morrel ships line the wall. M. Morrel does business here the way other
men keep faith."
Exits: E QUAY. Contents: MORREL (after ship squared away), COCLES the
cashier (scenery in Act I, speaking role in Act III).

**MEILHAN — "A Room in the Allées de Meilhan"**
LDESC: "Your father's narrow fifth-floor room: a bed, a crucifix, a few
nasturtiums in a window box, and a bare cupboard he is too proud to
mention. A faded red purse lies on the mantelpiece."
Exits: S QUAY. Contents: FATHER, CADEROUSSE (arrives a turn after you),
MANTEL (scenery, crucial in Act III), RED-PURSE (scenery here; Morrel's
charity — taking it: "It is your father's. You will remember it.").

**CATALANS — "The Catalan Village"**
LDESC: "White cottages above a bright cove; nets drying in the wind. At
her doorway stands Mercédès, and the sea behind her is nothing to her
eyes. In the shadow of the wall, her cousin Fernand watches you with a
Catalan's stillness."
Exits: N QUAY. Contents: MERCEDES, FERNAND.

**RESERVE — "The Arbor at La Réserve"**
LDESC: "Under the leafless arbor of La Réserve the wedding table is laid:
Arles sausages, boiled crawfish, wine of La Malgue. Everyone you love is
here. The morning sun touches the foamy waves into a network of
ruby-tinted light."
Exits: W QUAY (leaving after the feast starts: "Leave your own betrothal
feast? Mercédès has your arm.").
Contents: the feast (scenery), all Act I NPCs; the ARBOR-CORNER
(examinable: "Nothing but a wine stain and a crumpled shadow. Danglars
watches you look, and smiles thinly." — dramatic irony).

**VSTUDY — "Villefort's Study"**
LDESC: "A magistrate's room in the Palais de Justice: files, a fire in
the grate, the king's portrait. M. de Villefort studies you like a man
reading two letters at once — yours, and his own future."
Exits: none (rails). Contents: VILLEFORT, GRATE (fire).

### ACT II — The Château d'If (6 rooms)

```
  [CELL34] ==tunnel== [CELL27]          (the sack goes over the rampart)
      \                   |
       (jailer door,      +--> thrown --> [UNDERSEA] -> [OPENSEA] -> [TIBOULEN]
        never passable)
```

**CELL34 — "Cell Number 34"**
LDESC (phase-dependent; arrival): "Stone below, stone above, stone on
every side, and the sea grinding at the roots of all of it. A bed, a
chair, a table, a pail, and a jug. High in one wall, a loophole with
three iron bars lets in a ration of sky." Later phases append the state
of the dig ("Your bed stands against the wall, and only you know why.").
Exits: DOWN/WEST into TUNNEL (once open). Door: never passable ("The oak
door has a grate for the jailer's eyes and no handle on your side.").
Contents: BED, TABLE, CHAIR, PAIL, JUG, PLATE (after first meal),
LOOPHOLE, WALL, LOOSE-STONE, STRAW (bed straw hides shards/spoil).

**TUNNEL — "The Tunnel"**
LDESC: "A burrow a man may pass on his elbows, fifty feet of clawed-out
dark between your cell and the abbé's. The air tastes of earth and
patience."
Exits: EAST/UP to CELL34, WEST/UP to CELL27. (Also the spoil cache and,
in Act V, Faria's manuscript.)

**CELL27 — "Cell Number 27 — the Abbé's Cell"**
LDESC: "Faria's cell is the same stone as yours, and entirely different:
a disused hearth, a bed, and everywhere the invisible library of a free
mind. You could believe the walls here were thinner. They are not."
Exits: EAST into TUNNEL. Contents: FARIA, HEARTH (hearth-stone lifts:
cache with TOOLS: CHISEL, KNIFE, NEEDLE, LAMP, PHIAL, MANUSCRIPT,
PARCHMENT), FARIA-BED (rope ladder behind — flavor), SACK (phase E).

**UNDERSEA — "Beneath the Waves"** (dark-ish, timed)
LDESC: "Cold black water, roaring in your ears. Something enormous and
heavy is falling, and it is tied to your feet, and it is you."
Exits: UP to OPENSEA (only when free of sack and cord).

**OPENSEA — "The Open Sea"**
LDESC: "Black waves under a black sky; the mistral is rising. Behind you
the Château d'If stands on its rock like a scaffold. Far off, one steady
spark: the light of Planier."
Exits: WEST (x3, with fatigue) to TIBOULEN; EAST/NORTH lead back toward
If and the searchers (fatal on the third stubborn swim).

**TIBOULEN — "The Island of Tiboulen"**
LDESC: "A grotesque mass of bare rocks, like a vast fire petrified at the
moment of its most fervent combustion. No tree, no soul, no shelter but
an overhanging stone. It is the most beautiful place you have ever seen."
Contents: OVERHANG (shelter), HOLLOW (rainwater), then WRECKAGE, RED-CAP,
SPAR after the storm; the TARTAN (offshore, dawn).

### ACT III — Monte Cristo & the mainland, 1829 (8 new rooms)

```
 [TARTAN] ~~> [CREEK] -- [PATH] -- [CLEARING] -- (stairs) [GROTTO1] -- [GROTTO2]
                           |
                        [HIGHROCK]
 then by sea:  [INN]  ...  [OFFICE] -- [QUAY] -- [MEILHAN]   (Act I rooms revisited)
```

**TARTAN — "Deck of the Jeune-Amélie"**
LDESC: "A smuggler tartan heeling under lateen sails, bound for the
island of Monte Cristo with contraband and no questions. Jacopo splices a
line and watches you the way honest men watch lucky ones."
Exits: LAND/OUT to CREEK (at the island).

**CREEK — "The Hidden Creek"**
LDESC: "A small creek hidden like the bath of some ancient nymph, deep
enough at the center for a little vessel. From the waterline, a line of
old notches cut in the rocks marches away to the east."
Exits: E PATH; BOARD tartan (before it departs).

**PATH — "Goat Path"**
LDESC: "A scramble of myrtle and hot granite. Lizards flash like
emeralds; somewhere above, wild goats clatter. The notch marks continue
east in a right line."
Exits: W CREEK, E CLEARING, UP HIGHROCK.

**HIGHROCK — "The High Rock"**
LDESC: "The island's summit — a statue's view from a granite pedestal.
Corsica to the north, Elba, the far smudge of Genoa; and below, the sails
of the Jeune-Amélie shrinking toward the horizon. You are alone."
Exits: DOWN PATH.

**CLEARING — "The Circular Rock"**
LDESC: "The notches end at a huge circular boulder squatting on a bed of
smaller stones. Moss and myrtle have sworn it has sat here since the
Flood. Cardinal Spada's men swore the same thing, in 1498."
Exits: W PATH, DOWN (once flagstone raised) GROTTO1. Contents: BOULDER,
WEDGE (under it), OLIVE-TREE, then HOLE, RING, FLAGSTONE, STAIRS.

**GROTTO1 — "The First Grotto"**
LDESC: "A dim and bluish light seeps through crevices; the granite walls
sparkle as if sown with diamond dust. The air is warm and dry. Somewhere
in this glitter, a second door is pretending to be a wall."
Exits: UP CLEARING, (opening) EAST GROTTO2. Contents: WALLS (soundable),
STUCCO patch.

**GROTTO2 — "The Second Grotto"**
LDESC: "Lower, darker, closer. The air is old. In the farthest angle to
the left, the ground has been waiting three hundred and forty years for
a man with a pickaxe."
Exits: WEST GROTTO1. Contents: CORNER (diggable), COFFER (buried).

**INN — "The Pont du Gard Inn"**
LDESC: "A failing inn on the Beaucaire road, its signboard groaning in
the wind. Caderousse, gone gray and sour, wipes a table that no traveler
will sit at. Poverty has been at work on him the way the sea works on a
wreck."
Exits: OUT (road — travel is by narrated coach between INN, OFFICE, QUAY,
MEILHAN in Act III). Contents: CADEROUSSE, CUPBOARD (the red purse).

*(Act III also reuses OFFICE, QUAY, MEILHAN with 1829 descriptions:
Morrel gray and hunted, the quay empty of Morrel ships, the father's room
bare and let to strangers.)*

### ACT IV — Paris, 1838 (16 rooms)

```
                [HAYDEE]
                   |
 [TELEGARDEN]   [SALON] -- [STUDY]          [AUTSALON] -- [GARDEN]
      |            |                             (Auteuil, by coach)
 [TELETOWER]    [STREET] -- [PRESS]
                   |    \
      [BANKHALL]--[+]    [PEERS]     [VHALL] -- [NOIRTIER]
          |        |                    |
      [BANKOFF] [ASSIZES]           [VALROOM]
```
(STREET is the hub connector; coach travel from STREET reaches Auteuil
and back. All Act IV rooms connect through STREET except suite interiors.)

**SALON — "Salon of the Count of Monte Cristo"** (hub)
LDESC: "No. 30, Champs-Élysées. Silk, bronze, and rumor. Paris has
decided you are a Balkan prince, a vampire, or the devil; you have not
corrected Paris. Ali stands at the door; your study lies east; the city
waits south."
Exits: E STUDY, N HAYDEE, S/OUT STREET.

**STUDY — "The Count's Study"**
LDESC: "Maps, dossiers, and a wardrobe deeper than it looks: a priest's
cassock, an Englishman's drab coat, and — folded at the very bottom,
paid for with fourteen years — a sailor's jacket and hat."
Exits: W SALON. Contents: CASSOCK, ENGLISH-COAT, SAILOR-JACKET,
CREDIT-LETTER, BANKNOTES, DOSSIER (recaps evidence state when read),
PILL (Valentine's draught), SPADE.

**HAYDEE — "Haydée's Apartments"**
LDESC: "Incense, cushions, and a silence from farther east than Greece.
Haydée rises as you enter — the daughter of Ali Pasha of Janina, whom
you bought out of slavery and who looks at you as if you were the sun."
Exits: S SALON. Contents: HAYDEE, SATCHEL (hers to give).

**STREET — "The Champs-Élysées"**
LDESC: "Carriages, gossip, and gaslight. From here the city is yours:
the bank, the press, the Chamber of Peers, the law courts — and, by
coach, the quiet house at Auteuil and a certain house in the Faubourg
Saint-Honoré."
Exits: N SALON, E PRESS, SE PEERS, S ASSIZES, W BANKHALL, NW TELEGARDEN,
SW VHALL, and AUTEUIL (IN/COACH) to AUTSALON.

**BANKHALL — "Danglars's Bank — Antechamber"**
LDESC: "Marble bought with margins. Clerks scratch in ledgers; above the
double doors, a gilt baron's crest that smells of fresh paint."
Exits: E STREET, W BANKOFF.

**BANKOFF — "Danglars's Office"**
LDESC: "Baron Danglars fills his chair like a sack of coin. On the wall,
a portrait of his wife he did not choose; on his desk, the only faith he
keeps — the daily quotations."
Exits: E BANKHALL. Contents: DANGLARS.

**TELEGARDEN — "Garden Below the Telegraph"**
LDESC: "A kitchen garden at the foot of an old tower crowned with black
jointed arms. The keeper is on his knees among the peas, at war with the
dormice, a man of a thousand francs a year."
Exits: SE STREET, UP TELETOWER. Contents: OPERATOR.

**TELETOWER — "The Telegraph Platform"**
LDESC: "Up here the signal arms creak overhead like a gallows-tree of
news. Through the glass you can see the next tower's semaphore twitching
out the fortunes of France, one angle at a time."
Exits: DOWN TELEGARDEN. Contents: SIGNAL-LEVERS.

**PRESS — "Offices of l'Impartial"**
LDESC: "Ink-fog, proof sheets, and the guillotine-thump of the press
below. Beauchamp the journalist can smell a story through wax seals."
Exits: W STREET. Contents: BEAUCHAMP.

**PEERS — "Gallery of the Chamber of Peers"**
LDESC: "Velvet benches above a floor of old men and older honors. Today
the Count de Morcerf answers a question of history: what happened at
Janina?"
Exits: NW STREET. Contents: the committee (scenery), MORCERF (during
trial), HAYDEE (when brought).

**ASSIZES — "The Court of Assizes"**
LDESC: "The great criminal court, packed to the cornices. Villefort
prosecutes the prisoner Benedetto with his usual marble calm; the
prisoner wears a curious smile, as if he alone knows the last line."
Exits: N STREET. Contents: VILLEFORT, BENEDETTO (during trial).

**AUTSALON — "The House at Auteuil — Salon"**
LDESC: "A pleasure-house with its shutters' eyes put out; you have had
it lit and aired, and still the walls hold their breath. Bertuccio, your
steward, will not look at the garden door."
Exits: OUT/COACH to STREET, E GARDEN. Contents: BERTUCCIO; dinner scene.

**GARDEN — "The Auteuil Garden"**
LDESC: "A walled garden gone half wild. One plantain tree stands over
turned earth like a mourner who has forgotten whom he mourns."
Exits: W AUTSALON. Contents: PLANTAIN, EARTH (diggable), IRON-BOX
(buried).

**VHALL — "Villefort's House — Hall"**
LDESC: "The procureur's house in the Faubourg Saint-Honoré: cold marble,
hushed servants, and lately a smell of medicine on every landing. Death
has been a frequent caller this season."
Exits: NE STREET, N NOIRTIER, E VALROOM.

**NOIRTIER — "Noirtier's Room"**
LDESC: "The old conventionist sits paralyzed in his great chair, alive
only in his eyes — and his eyes are two loaded pistols. A dictionary
and a bell-cord serve him for a voice."
Exits: S VHALL. Contents: NOIRTIER-NPC.

**VALROOM — "Valentine's Room"**
LDESC: "White curtains, a glass of lemonade on the night table, and a
girl growing paler by the week while her family calls it nerves."
Exits: W VHALL. Contents: VALENTINE, GLASS.

### ACT V — Expiation (2 new rooms; CELL34, TUNNEL, GROTTO1 revisited)

**CATHALL — "Catacombs of Saint Sebastian"**
LDESC: "Under Rome, among the politely stacked dead, Luigi Vampa's men
play mora by torchlight. Vampa rises and uncovers his head: to him you
are something between a king and a saint, and he is not sure which
frightens him more."
Exits: E LARDER. Contents: VAMPA.

**LARDER — "The Larder Cell"**
LDESC: "A barred recess in the tufa where a fat man in a torn coat sits
among the finest dinners in Italy — priced at one hundred thousand
francs the fowl. Danglars has eaten down five millions, and is hungry."
Exits: W CATHALL. Contents: DANGLARS.

*(CELL34/TUNNEL revisit: guided-tour framing, new descriptions. GROTTO1
finale: Maximilian and Valentine, the letter, the white sail.)*

---

## 4. OBJECTS & PUZZLES

### Global mechanics

**Identity (disguises).** A global `IDENTITY` (0 = Edmond/sailor, 1 =
Abbé Busoni, 2 = Lord Wilmore/English agent, 3 = the Count, 4 = the
sailor jacket — Edmond revealed). Set by WEAR CASSOCK / WEAR COAT / WEAR
JACKET; wearing fine dress (default in Act IV) = the Count. NPC reactions
key off it:
- CADEROUSSE and VILLEFORT will only open up to **Busoni** (confession
  logic). Caderousse (Act III): if you arrive undisguised he half-knows
  you ("You put me in mind of... no. The dead are dead.") and clams up.
- MORREL (Act III) must be helped as **Wilmore** ("Thomson & French"):
  he would never accept charity from a friend's ghost. Attempting it
  undisguised: he weeps, refuses the money, honor intact — quest fails
  until you change coats.
- The Peers, Danglars, Beauchamp deal with **the Count**.
- MORCERF's final confrontation requires **the sailor jacket**; the
  reveal line only fires in that costume.
Removing a disguise mid-scene is allowed and sometimes the point
(REMOVE WIG / WEAR JACKET are reveal verbs — see the three reveals).

**Time-skip narration.** Key transitions print a dated interstitial
("The seasons grind past the loophole. It is 1821." / "Nine years pass
like nine waves. It is 1838, and Paris believes in you."). Implemented
as room-action events on flag thresholds; the clock demon (GCLOCK) runs
jailer visits and scene timers.

**Score object model.** Points via SETG SCORE in action routines (Tiny
Quest style); SCORE-MAX 400.

### ACT I objects & beats (35 points)

| Object | Where | Notes |
|---|---|---|
| SAILS, ANCHOR | DECK | FURL SAILS (+ synonyms LOWER/STRIKE), then DROP ANCHOR → +5, DOCKED flag, Morrel's praise, Danglars's "he fancies himself captain already." |
| ELBA-LETTER | carried | READ → address only: "To Monsieur Noirtier, Rue Coq-Héron, Paris." The player cannot lose it (dropping it: "It is a dying man's trust. You keep it."). The doom seed. |
| SEA-CHEST, SWORD, CROSS | CABIN | Flavor; EXAMINE deepens Leclere's death. |
| COIN-PURSE | carried | Your pay. GIVE PURSE TO FATHER → +10; he protests, you insist; Caderousse watches with hungry eyes. |
| RED-PURSE | MEILHAN mantel | Scenery now; Chekhov's purse for Act III. |
| Feast | RESERVE | Turn-timed toasts; EXAMINE guests for foreboding (Fernand pale, Danglars whispering). |

Beats: TALK TO MORREL at OFFICE → captaincy promised (+10: "At twenty,
captain of the Pharaon!"). KISS MERCEDES (+5). TELL MERCEDES ABOUT FEAST
(schedules the feast; the act's second half unlocks when father visited +
Mercédès invited + captaincy secured). At RESERVE, after 4-5 turns of
toasts: knocking; the magistrate ("Edmond Dantès, I arrest you in the name
of the law!"); rails to VSTUDY.

**VSTUDY scene (on rails, 5 points).** Villefort questions; any answers
work (TALK TO VILLEFORT advances; honest flavor for ANSWER/TELL). He asks
for the letter: GIVE LETTER TO VILLEFORT (or he takes it after 3 turns).
He reads the address, goes white, burns it in the grate — "You see, I
destroy it?... deny it boldly, and you are saved." (+5 for witnessing —
the player now owns the game's central grievance with full knowledge.)
Gendarmes; the night boat; the black rock. "The Château d'If?" you cry.
The gendarme smiles. Act II.

### ACT II objects & puzzles (130 points)

Furniture per the text: BED, CHAIR, TABLE, PAIL, JUG (+PLATE, LOOSE-STONE,
STRAW, LOOPHOLE, WALL, DOOR).

**Phase A — burial (turns, then years).** The player may rage: YELL
("Your voice comes back off the stone with nothing added."), PRAY
(tracked for a later echo), EXAMINE everything. The inspector-visit
vignette plays (a voice: "he is number 34"). After ~8 turns or on PRAY +
WAIT, the first time-skip: hunger strike, despair, "It is the sixth
year." Phase B opens.

**Puzzle II-1: The sound (5).** LISTEN or LISTEN TO WALL → "A faint,
continuous scratching, low in the wall — stone on stone, patient as the
sea." Test it the way Dantès did: TAKE STONE (a loose corner stone),
KNOCK ON WALL → three deliberate knocks → the scratching stops "as if by
magic." (+5.) Failure texts: KNOCK before hearing it → "On which of four
walls, and why?"; SHOUT AT WALL → the sound stops for good that day
(recoverable; a day passes). Hint channel: repeated LISTEN gives the
workman-vs-prisoner reasoning from the text.
After WAIT/SLEEP: "Three days of silence. Then, at evening — the
scratching again, deeper now." Phase C.

**Puzzle II-2: First tool (5).** The player needs an edge. TAKE CLAMPS /
UNSCREW CLAMPS → "Screwed fast; you would need a screwdriver." EXAMINE
PAIL → "Its handle was removed long ago. The jailers know their trade."
BREAK JUG (BREAK/SMASH = stock DESTROY) → "The jug bursts on the stones.
You palm the three sharpest shards into the straw; the rest you leave
lying, an accident." Jailer event next visit: grumbles, replaces jug.
DIG WALL WITH SHARD (after MOVE BED — required, else "The bed hides
nothing yet; nothing to hide.") → plaster comes away ("The damp has made
the mortar friable. A handful in half an hour. A mathematician might
give it two years — a prisoner has them."), +5, hewn stone exposed.
Continued digging: shards snap on the stone ("The fragment breaks in
your fingers. The hewn block does not care."). Nails: "Too weak, and you
would spend them to the quick."

**Puzzle II-3: The saucepan lever (10).** The jailer pours soup from an
iron-handled SAUCEPAN into your one PLATE each evening. Solution exactly
as written: PUT PLATE BY DOOR (or DROP PLATE / PUT PLATE ON FLOOR near
door — accept NEAR/BY/AT DOOR forms) → that evening the jailer steps on
it: "He grinds your plate underfoot, curses you, looks for anything to
pour the soup into — and leaves the saucepan." Next morning he makes it
official ("You destroy everything... I shall leave you the saucepan.").
TAKE HANDLE / STRAIGHTEN HANDLE → "You straighten the iron handle
against the floor: a lever the length of your forearm. You would not
trade it for ten years of life." PRY STONE WITH HANDLE (also MOVE/LEVER
STONE WITH HANDLE) → "A slow oscillation... then the hewn stone comes
away like a tooth. A cavity, a foot and a half across." +10. Spoil
management is automatic with flavor (plaster hidden in the straw and
scattered at the loophole).

**Jailer rhythm & discovery (the act's danger).** The jailer visits every
12 turns (morning/evening alternating). Two turns before, footsteps:
"Boots, far off on the stair." Safe state = bed against wall (BED-MOVED
false) and player in CELL34 (or, later, tunnel mouth stone replaced —
handled automatically when passing through: "You draw the bed to the
wall behind you"). If caught mid-dig or absent: first offense is a
near-miss if the tunnel isn't open yet ("You slam your back to the wall;
his lantern sweeps past the bed's shadow..."); after the tunnel exists,
discovery = endgame: "They tear the bed aside. The hole gapes like a
mouth with no more to say. — The governor moves you to the dungeons
below the waterline. The years there are not described. (You have died
in the Château d'If.)" — RESTART/RESTORE offer.

**Puzzle II-4: Breakthrough (15).** DIG TUNNEL WITH HANDLE (in cavity) →
progress messages over 3 efforts, then: "The iron rings on something
that is not stone. A beam — a ceiling beam square across your burrow."
Auto-despair line (kept verbatim-adjacent): "Oh, my God, my God! Do not
let me die in despair!" — and the wall answers: "**Who talks of God and
despair at the same time?**" The catechism plays as dialogue (2 turns,
any input advances; TELL VOICE ABOUT... accepted): name, country, crime,
date — his four years' seniority — his crushing arithmetic ("I took the
wrong angle... fifteen feet from where I intended"). "It is well —
tomorrow." Next turn-block: the floor gives way; "first the head, then
the shoulders, and lastly the body of a man" — FARIA enters CELL34. +15.

**Faria's cell & the cache.** In CELL27: LIFT HEARTH-STONE (or MOVE
HEARTH) → cache: CHISEL ("a blade with a beechwood handle — a bed-clamp,
four years in the making"), KNIFE ("made of an old iron candlestick; it
cuts and it thrusts"), PENKNIFE, NEEDLE ("a fish-bone, eyed, still
threaded"), LAMP + FLINT, PHIAL ("a small bottle half full of red
liquor"), MANUSCRIPT (the 68 linen strips), PARCHMENT (guarded — Faria
produces it himself at the right beat). The rope LADDER lives behind the
bed-head (flavor; "against one of those unforeseen opportunities").
Taking tools before Faria offers: "The abbé's hand closes gently over
yours. 'Everything I have is yours — when you can use it.'"

**Puzzle II-5: The deduction (15).** TELL FARIA ABOUT LETTER (or ABOUT
ARREST) → the maxim: "seek first to discover the person to whom the bad
action could be in any way advantageous." He then Socratic-prompts: "Who
gained by your fall?" The player must name them: TELL FARIA ABOUT
DANGLARS → the cabin-door recollection, the left-hand writing demo (+5).
TELL FARIA ABOUT FERNAND → "An assassination they will unhesitatingly
commit, but an act of cowardice, never — yet he carried the letter" (+5).
TELL FARIA ABOUT VILLEFORT → the burned letter reread: who was Noirtier?
"He burned it because the name was his father's. He buried you to bury
it." (+5.) Wrong names (MORREL, CADEROUSSE) get reasoned rejections
(Caderousse: "A drunkard's silence is a sin, not a plot. Remember him,
though."). All three named → KNOWS-ENEMIES; Faria's grief: "I repent me
of my work. I have put hatred into a heart that had none." Player may
PRAY or answer; either way the vow lands: "Not hatred, father.
*Justice.*"

**Puzzle II-6: The education (20).** STUDY WITH FARIA (new verb STUDY,
or LEARN; also TELL FARIA ABOUT MATHEMATICS/LANGUAGES/HISTORY/CHEMISTRY)
— four lessons, each a scene with a time-skip ("Six months. You dream in
Italian now."), +5 each. Gated: at least 2 lessons before the treasure
beat; all 4 unlock flavor mastery lines used later (the chemistry lesson
foreshadows brucine and the cordial; languages let the Count exist).
This is where the Faria relationship is invested: each lesson ends with
one warm, quotable exchange ("To learn is not to know... Memory makes
the one, philosophy the other.").

**Beat: the second attack & the phial (5).** Scene trigger after
education ≥2 and enemies known: Faria seizes mid-sentence ("the
cataleptic fit"). The player must act in 3 turns: LIFT HEARTH-STONE, TAKE
PHIAL, POUR PHIAL IN MOUTH (accept GIVE PHIAL TO FARIA / POUR DROPS) →
he shudders back, half-paralyzed. +5. Too slow → he survives anyway
(the text's own logic) but the delay costs the warm line; no death here.

**Puzzle II-7: The parchment (10).** Recovering, Faria: "My arm is dead,
my leg is dead; the treasure must not die with me." He tells the Spada
story (compressed to ~6 short paragraphs over EXAMINE/ASK beats), then
produces the PARCHMENT half. READ PARCHMENT → the right-edge fragment
only (rendered as broken phrases — "...ing invited to dine by his
Holiness... the caves of the small... ...ck from the small"). ASK FARIA
ABOUT PARCHMENT → he recites his reconstruction; the game then treats
the parchment as complete: READ PARCHMENT now yields the full will —
"...the twentieth rock from the small creek to the east in a right
line... in the farthest angle in the second [opening]" (+10, knowledge
MONTE-CRISTO). "If we escape together, half is yours. If I die here —
it is yours alone." Player keeps the parchment henceforth (auto-carried
through the escape sewn into your rags: one line covers it).

**Beat: the third attack — Faria dies.** Timed a few scenes later, at
night: the phial fails ("It is useless," he whispers. "Only now the fit
is stronger."). His last words paraphrase the bequest + "Monte Cristo!"
Morning brings the officials, heard from hiding (auto-moves you to the
tunnel mouth if you linger — one free pass; if the player insists on
staying in CELL27, capture-death as above): the doctor, the brutal
jokes, the hot iron ("this burn in the heel is decisive" — the player
smells it through the wall), the sack sewn, "This evening... about ten
or eleven o'clock. Shut the dungeon as if he were alive — that is all."

**Puzzle II-8: THE SACK SWAP (15) — the centerpiece.** The player is
left alone with a sewn sack on Faria's bed and roughly 30 turns until
ten o'clock (clock messages at intervals: distant bells count seven,
eight, nine...). The game gives no direct instruction. Nudges, in
order, if the player flails: (1) EXAMINE SACK → "Canvas, coarse, sewn
with a strong seam. Faria's last winding-sheet. It is the only thing in
this fortress that will pass the walls tonight." (2) After 8 idle turns:
"None but the dead pass freely from this dungeon." (3) After 16: the
thought verbatim: "Since none but the dead pass freely — *let me take
the place of the dead.*"
Required chain (order flexible where sensible):
1. TAKE KNIFE (from cache; also NEEDLE — see below).
2. CUT SACK / OPEN SACK WITH KNIFE → "The seam parts. The abbé's face
   is calm. Forgive me, father."
3. TAKE BODY / DRAG BODY → carrying is special-cased (heavy; you cannot
   carry anything else in hand while dragging; humane failure texts).
4. Move body: EAST (into tunnel — "You bear him through the earth you
   dug together, an inch at a time.") then to CELL34: PUT BODY IN BED
   (accept ON BED).
5. COVER BODY (blanket auto) → optional TURN BODY: covered includes
   "you tie your own night-rag about his head and turn his face to the
   wall." (One command does all three with full text.)
6. Return EAST→ CELL27. ENTER SACK (accept GET IN SACK) → check: if
   KNIFE not carried → "You settle into the dead man's place... and
   your hands are empty. Something cold crosses your mind: whatever
   comes, you cannot so much as scratch your way out." (Player can still
   exit and fetch; the warning is the fairness line. If they sew anyway
   without the knife, the sea kills them — see below.)
7. SEW SACK (new verb SEW; accept SEW SACK WITH NEEDLE; requires
   NEEDLE) → "From the inside, stitch by stitch, you close your own
   shroud. Your heart is so loud they will surely hear it." +15.
   (SLEEP/WAIT inside → the gravediggers come.)
Failure paths: ten o'clock arrives with the swap incomplete → the
bearers find the opened sack/moved corpse → capture-death ending. Sewing
yourself in in CELL34 (wrong room) → they collect nothing from cell 27,
alarm raised → capture-death. All deaths here name the true cause
("The sea is the cemetery of the Château d'If. You never saw it.").

**The drop (auto-scene).** Rendered close to the text: the "heavy though,
for an old man" exchange, the pause — "a heavy metallic substance laid
down beside him" — the cord biting the ankles ("'What's the knot for?'
you have one second to wonder"), fifty paces, the sea-noise, "One! two!
three!" — UNDERSEA.

**Puzzle II-9: Underwater (15).** Breath counter: 6 turns, escalating
("Your chest begins to burn." / "Red stars crowd your eyes."). Required:
CUT SACK WITH KNIFE (1) → "You rip the canvas from top to bottom and
shed it like a skin — but the shot still has your feet." CUT CORD (2)
→ "Bent double in the black, you saw the cord through at the moment the
strangling starts." UP / SWIM UP (3) → OPENSEA, +15. No knife → the
death the player was warned toward: "You claw at the canvas with your
nails. The sack is strong; the sea is stronger. The thirty-six-pound
shot knows the way." Panic verbs (YELL, OPEN SACK bare-handed) burn
breath with fair text.

**Puzzle II-10: The swim (5).** In OPENSEA a torch watches from the
rampart (first turn: DIVE / SWIM DOWN dodges it — optional, flavor).
EXAMINE HORIZON / LOOK → "One steady spark low in the south: the light
of Planier. Faria's geography, in your ear: *leave Planier on your left
hand, and Tiboulen lies west.*" SWIM WEST x3 (fatigue text between;
WAIT/tread → "The sea is too violent to rest in."). Wrong headings:
EAST/NORTH → "Behind you the château shows a moving torch..." twice
warned, third = recapture death. After the third WEST: "Something tears
your knee — rock. Blessed, merciful rock." TIBOULEN, +5.

**Beat: Tiboulen night (rescue, 10).** Scripted storm night: SHELTER /
ENTER OVERHANG (else soaked, no harm), DRINK WATER (hollow — flavor
+care), the fishing-boat wreck plays (cries, splinters — nothing can be
done; "you run down the rocks; the sea gives back nothing"). Dawn: the
If cannon thuds ("They have found the grave empty."). WRECKAGE ashore:
RED-CAP and SPAR. TAKE + WEAR CAP, TAKE SPAR; the TARTAN rounds
Pomègue: WAVE AT SHIP / YELL (either, cap worn) → picked up; the lie
("a Maltese sailor, sole survivor") is delivered by the narrator in one
paragraph. Cap not worn → they stand off ("Naked castaways swimming off
a prison island invite questions") — retry next turn after wearing it.
+10. Act interstitial: months among the smugglers, the island ahead.

### ACT III objects & puzzles (90 points)

**Puzzle III-1: The twentieth rock (5).** CREEK: EXAMINE ROCKS → the
notches. Follow east (PATH → CLEARING). Ship-departure cutscene fires on
first entering CLEARING: the feigned fall among the rocks, Jacopo's
worried face, supplies left: PICKAXE, GUN, POWDER-HORN, BISCUITS, RUM.
COUNT ROCKS (stock verb) → "From the creek, east in a right line: ...
eighteen, nineteen — twenty. The twentieth rock is no rock. It is a
door with moss for manners." (+5; also EXAMINE BOULDER works once
counted.)

**Puzzle III-2: Opening the earth (10).** EXAMINE BOULDER → "It rests on
a made bed: a wedge stone, packed flints, old masonry playing at
geology." DIG WEDGE WITH PICKAXE → "Ten minutes' work opens a hole big
enough for your arm." PRY BOULDER WITH BRANCH → need it first: CUT
BRANCH (at OLIVE-TREE, knife or pickaxe) → "You cut and strip the
strongest olive bough on the island." Pry attempt → "The boulder stirs
— and settles. Too heavy for any one man, were he Hercules himself."
PUT POWDER IN HOLE → "You pack the horn's powder deep under the wedge
and roll your handkerchief into a slow-match." LIGHT POWDER (accept
LIGHT MATCH / LIGHT FUSE; flint from the horn) → "You touch fire to the
match and walk, not run, behind the tallest rock. — The island answers.
The wedge is gravel; the boulder tips, rolls, bounds, and buries itself
in the sea below." Reveals RING + FLAGSTONE. PULL RING (or PRY FLAGSTONE
WITH BRANCH) → "The flagstone rises on the ring: steps, going down into
blue-lit dark." +10. Skipping the lever attempt is fine (powder direct);
standing too near the blast → knocked flat, comic-grim, no death.

**Puzzle III-3: The second opening (10).** GROTTO1: the wall hunt.
KNOCK ON WALL / HIT WALL (roams: "solid... solid...") until the far
angle: "one part of the wall gives forth a hollow and deeper echo."
(EXAMINE WALLS also hints stucco sheen.) HIT WALL WITH PICKAXE → "Stucco
flakes fall — painted to imitate granite. Beneath: dressed white stones,
laid without mortar." Strike again / PRY STONES → opening → EAST →
GROTTO2. +10.

**Puzzle III-4: The treasure (25).** GROTTO2: EXAMINE CORNER → "The
farthest angle, at the left of the opening. The will's last word." DIG
CORNER WITH PICKAXE → iron ring of sound at the fifth blow ("Never did
funeral knell produce a greater effect") → COFFER exposed: oak, steel
bands, the Spada arms on silver ("a sword on an oval shield, surmounted
by a cardinal's hat"). OPEN COFFER → "Lock and two padlocks — faithful
guardians." OPEN COFFER WITH PICKAXE (accept PRY/BREAK) → "The
fastenings burst. — Gold coin in blazing piles; bars of unpolished
gold; and diamonds, pearls, rubies that fall through your fingers like
hail against glass." TAKE TREASURE (or GOLD/GEMS — one command sets
RICH; individual DIAMOND and GEM objects split off for later use) →
+25 and the act's emotional beat: "You are alone — alone with countless,
unheard-of treasure. You kneel. What you say is intelligible to God
alone. When you rise, your voice is steady: *Now for Marseilles.*"
Interstitial: Leghorn, clothes, papers, a yacht; CASSOCK and
ENGLISH-COAT added to inventory. "Fourteen years dead, you return to
Marseilles a priest, an Englishman — anything but a ghost."

**Puzzle III-5: The diamond for the truth (20).** INN, as Busoni (WEAR
CASSOCK before entering; else Caderousse is frightened and evasive).
TALK TO CADEROUSSE → the deathbed-legacy frame ("Dantès died in prison;
he left a diamond to be divided among his friends") and the history
pours out across ASK beats: ASK CADEROUSSE ABOUT LETTER → "Danglars
wrote it left-handed at La Réserve; Fernand posted it. I was drunk. God
forgive me, I was drunk." (+10 CONFIRMED-GUILT — the revenge licenses
in Act IV check this flag.) ABOUT FATHER → the starvation ("He died
with his hand in Mercédès'... the red purse of M. Morrel paid for his
burying."). ABOUT MERCEDES → married Fernand, now Countess de Morcerf.
ABOUT DANGLARS → banker, baron. ABOUT VILLEFORT → procureur du roi.
ABOUT MORREL → ruin; "one ship left, and September coming." ASK ABOUT
PURSE → he fetches it from the cupboard. GIVE DIAMOND TO CADEROUSSE →
"For the whole of it? Ah, monsieur l'abbé, do not jest with the
happiness or despair of a man!" — he trades the RED-PURSE for it
willingly (+10). (The player keeps a second great stone, GEM, for
Julie's dowry.) La Carconte's "Suppose it's false?" closes the scene
with its chill. — The diamond is now a lit fuse; it detonates in
Act IV without further player action.

**Puzzle III-6: Saving Morrel (20).** Marseilles, as Wilmore (WEAR
COAT). OFFICE 1829: Cocles faithful at an empty cash-box; Morrel aged
twenty years. TALK TO MORREL → the fifth of September confession ("On
that day, at eleven o'clock, I must pay two hundred and eighty-seven
thousand francs... or"— he does not finish, and you both hear the
pistol he does not name). PAY DEBT (accept GIVE GOLD TO MORREL/COCLES;
requires RICH) → as Thomson & French's agent you buy every Morrel bill
→ you now hold the RECEIPTED-BILL. PUT BILL IN PURSE. PUT GEM IN PURSE
("...and on a slip of parchment you write two words: *Julie's Dowry*").
MEILHAN (the old room, rented and bare, the mantel enduring): PUT PURSE
ON MANTEL (+ note to Julie handled by narration) → leave → the Fifth of
September cutscene: the study, the clock, the pistol at his mouth,
"Father! — saved! you are saved!", the purse in her hand, and the
impossible cry from the port: "The Pharaon! The Pharaon is entering
harbor!" (a new-built twin, your gift). +20. Act closes: "The good are
repaid. Now, Paris. Now the others. — Nine years pass like nine waves.
It is 1838, and Paris believes in you." (Wrong identity here: see
Identity rules; undisguised approach softly fails with Morrel's honor.)

### ACT IV objects & puzzles (100 points)

Evidence flags: CONFIRMED-GUILT (from Act III), JANINA-DOCS, PRESS-RUN,
AUTEUIL-BOX, BERTUCCIO-TOLD, DINNER-HELD, VALENTINE-SAVED,
CADEROUSSE-LETTER. The DOSSIER in STUDY summarizes current state when
read (the game's quest log, diegetic).

**Caper A — Danglars, the bleeding (15).**
1. BANKOFF: SHOW CREDIT-LETTER TO DANGLARS (or GIVE) → "Unlimited,"
   he repeats, sweating gold. "On Thomson and French... unlimited." You
   draw your first million with the smile of a man taking back his own
   (+5, CREDIT-OPEN).
2. TELEGARDEN: TALK TO OPERATOR → his economics: a thousand francs a
   year, fined a hundred per missed signal, pension at stake; he fears
   only the dormice. GIVE BANKNOTES TO OPERATOR → fifteen notes of a
   thousand ("Sir, you are tempting me?" — "Just so."). +5.
3. TELETOWER: SET SIGNAL (accept MOVE LEVERS / PULL LEVERS; operator,
   pocketing his orchard-money, works the arms to your dictation) → the
   false dispatch runs down the line: *Don Carlos has crossed the
   Bidassoa — Spain in revolt.* Cutscene next day at the salon:
   Danglars sold his Spanish bonds into the panic; the dementi followed;
   "the Baron is lighter by a million, and heavier by a suspicion that
   the sun rises for someone else." +5 (TELEGRAPH-DONE).
   Failure: SET SIGNAL without paying → "The keeper's hand hovers — and
   falls. 'Sir, my right-hand correspondent is signalling. I should be
   fined.'" No harm, retry after paying.
The final ruin (deposits called, Cavalcanti scandal, flight to Rome) is
narrated when both other capers conclude — it feeds Act V.

**Caper B — Morcerf, the exposure (30).**
1. HAYDEE: ASK HAYDEE ABOUT JANINA → her testimony as memory: the
   palace, the betrayal ("the French officer sold the castle of
   Yanina"), her mother dead at Constantinople, herself sold. ASK
   HAYDEE ABOUT PROOF → the SATCHEL: birth record, baptism record, and
   the bill of sale "signed by a French colonel — Fernand Mondego."
   She gives it to your keeping (+5, JANINA-DOCS). (Asking her to
   testify: she answers with the novel's steel — "I am ready.")
2. PRESS: TELL BEAUCHAMP ABOUT JANINA (needs JANINA-DOCS or at least
   the interview) → next morning's paper carries the squib "We hear
   from Yanina..." (+5, PRESS-RUN). The Chamber demands an inquiry the
   same week (cutscene).
3. PEERS (with PRESS-RUN + JANINA-DOCS; Haydée comes when you go):
   WAIT through Morcerf's bluster; Haydée descends to the floor —
   "I am Haydée, the daughter of Ali Tepelini, pasha of Yanina, and of
   Vasiliki, his beloved wife" — documents read, seal verified, the
   vote by standing: disgrace (+15). Going early (no docs): the
   committee adjourns for lack of proof, and that night Morcerf's
   seconds call — the duel dawn scene ends in your death OR (if you
   fire wide) his; either way the score text brands it vengeance
   spoiled ("You have killed the soldier and left the traitor
   unjudged") → losing ending. The game warns: Ali bars the door with
   a bow: "Master — the papers?"
4. SALON, that evening (auto): Morcerf storms in demanding your true
   name ("I know you only as an adventurer sewn up in gold and
   jewellery... it is your real name I want"). WEAR SAILOR-JACKET (the
   study is one room east; the scene waits, pacing like a duelist) →
   you return in the sailor's jacket and hat, hair fallen loose — "a
   face you must often have seen in your dreams since your marriage
   with Mercédès, my betrothed." He goes out backwards, one cry in the
   courtyard: "**Edmond Dantès!**" A single shot, offstage, when his
   wife and son's coach clears the gate (+5). Mercédès's midnight
   visit is folded in as a preceding scene the first night after
   PRESS-RUN: she names you Edmond unprompted, asks for Albert's life,
   and receives it — this is why the duel-with-Albert subplot can stay
   cut without breaking cause and effect.

**Caper C — Villefort, the house of poison (35).**
1. AUTSALON: TALK TO BERTUCCIO → the confession, in his shaking voice:
   the vendetta, the night he stabbed a man burying a box beneath the
   plantain tree, and what the box held — "a child, monsieur, a living
   child" — Benedetto (+10, BERTUCCIO-TOLD).
2. GARDEN: DIG EARTH WITH SPADE (under PLANTAIN) → the IRON-BOX
   ironwork (+5, AUTEUIL-BOX). (The infant skeleton is your stagecraft
   — the box was empty of death; the horror is for your guests.)
3. AUTSALON with both flags: HOST DINNER (accept WAIT — the scene offers
   itself: "Your guests arrive at eight: Danglars, the Villeforts, the
   Cavalcantis...") → the declaration at the plantain tree, Dumas's
   scene compressed: "'A crime has been committed in this house...
   digging, my man found a box, and in it the skeleton of a newly born
   infant.' Madame Danglars's arm turns to stone on yours; Villefort's
   trembles like a wire." (+5, DINNER-HELD, VILLEFORT-SHAKEN.)
4. The poison thread, at VHALL/NOIRTIER/VALROOM (open after the
   dinner): Valentine pale; the lemonade GLASS ("Barrois drank from it
   and died in twenty minutes; the doctors said apoplexy, once");
   TALK TO NOIRTIER → the eye-alphabet scene, letter by letter, until
   the old man's gaze has spelled a name and a defense: he has been
   feeding Valentine brucine grain by grain — tolerance ("the poison
   found her ready"). ASK NOIRTIER ABOUT POISONER → the eyes go to the
   door Madame de Villefort uses (knowledge, no flag needed).
   GIVE PILL TO VALENTINE (the study's PILL, your hashish-and-opiate
   theater) → "Trust me as you would trust Providence — sleep, and
   whatever you hear, do not wake." Her "death," the house's horror,
   and your midnight extraction are narrated; +10, VALENTINE-SAVED.
   (Skipping this: the game continues, but the endgame text and 10
   points are lost, and the finale's Valentine is a grave — the
   novel's own alternate almost.)
5. ASSIZES (opens once DINNER-HELD; Benedetto's arrest is narrated with
   the Danglars engagement collapse): WAIT → the parentage bomb: asked
   his father's name, the prisoner smiles — "My father is procureur du
   roi. His name is Villefort." Uproar; Villefort, gray as his gown,
   does not deny it (+10). 
6. VHALL, immediately after (the game nudges: "His carriage went home
   at a gallop"): WEAR CASSOCK, then NOIRTIER → Villefort bursts in on
   Busoni — "do you never appear but to escort death?" — REMOVE WIG
   (accept WEAR JACKET / REVEAL) → the ladder: "It is the face of the
   Count of Monte Cristo!" — "You must go farther back." — "**I am
   Edmond Dantès!**" (+5). Then the check on wrath, unskippable: he
   seizes your wrist — "Then come here!" — his wife self-poisoned,
   and the boy Edouard beside her. "You feel it pass out of you like a
   fever breaking: the certainty that God was with you. *Are you well
   avenged?*" Villefort's mind goes out like a lamp. (No points for
   the horror; it is the price. Sets WRATH-CHECKED, required for the
   best ending text.)

**Caper D — Caderousse, the trap sprung (10).** Trigger: the first
night after any two capers have begun (evidence of your habits abroad):
an anonymous note (from Benedetto) reaches the SALON: "A friend warns
the Count: a man will enter his house by the study window tonight."
That evening: WEAR CASSOCK, WAIT in STUDY (lights doused, narration) →
Caderousse through the window with a glazier's diamond; recognizes
Busoni with a housebreaker's despair ("You! the abbé! — always the
abbé, like a bad conscience"). TELL CADEROUSSE ABOUT BENEDETTO (or SHOW
NOTE) → cornered, he writes and signs the letter unmasking "Prince
Cavalcanti" as Benedetto the galley-slave (+5, CADEROUSSE-LETTER — this
is what arms the Assizes scene). You let him go out the window. The
knife at the gate is Benedetto's, not yours. Dying on your steps, the
ladder once more: "the abbé... Busoni..." — "Look well at me." — wig
off — "I am neither the Abbé Busoni nor Lord Wilmore... I am he you
sold at La Réserve. I am Edmond Dantès." He dies naming God at last
(+5). (If the player skips the vigil: Caderousse robs the study,
Benedetto kills him anyway, the letter is never signed — the ASSIZES
scene still runs on Bertuccio's evidence but scores 5 less and the
dossier notes the loose thread.)

### ACT V — beats (45 points)

1. Cutscene on completing capers B and C (and A's two blows): Danglars
   flees with his last five millions drawn on Rome. "Peppino reads
   over his shoulder at the banker's. Vampa reads Peppino. You read
   everyone."
2. CATHALL/LARDER: Danglars at the bars, past pride: "Take my last
   gold... I only ask to live!" ASK DANGLARS ABOUT REPENT / TALK →
   "Do you repent?" — "Of the evil I have done — yes! yes!" FORGIVE
   DANGLARS (new verb FORGIVE; accept PARDON) → the cloak drops:
   "I am he whom you sold and dishonored... and who yet forgives you,
   because he hopes to be forgiven — I am Edmond Dantès." Keep the
   50,000; the hospitals are repaid; his hair is white by morning
   (+15). Alternative KILL DANGLARS → refused by the game's soul:
   "Fourteen years you carried the knife. You did not become it." (No
   dark-path ending here; mercy is the design.)
3. IF-CELL34 (guided tour, the guide's patter about "the famous
   prisoners, number 34 and number 27"): ENTER TUNNEL / SEARCH TUNNEL →
   Faria's MANUSCRIPT (TAKE IT, +5): "Two shirts' worth of linen, a
   life's worth of mind. The guide asks if monsieur is unwell.
   Monsieur is only breathing the air of his own grave."
4. GROTTO1 finale: Maximilian (grief-broken since Valentine's "death")
   brought by yacht; GIVE LETTER TO MAXIMILIAN (the letter writes
   itself when you arrive — one command) and Valentine steps from the
   second grotto if VALENTINE-SAVED → the reading: the fortune, the
   houses, "There is neither happiness nor misery in the world...
   *Wait and hope.*" (+25.) The white sail takes you and Haydée over
   the horizon. THE END, with rank.

---

## 5. NPCS

Actor model: Zork-simple. Each NPC is an ACTORBIT object with a room
action or demon for scene behavior; no free navigation. Conversation =
TALK TO X (scene-advance) + TELL/ASK X ABOUT Y (topic table per NPC,
default: a characterful shrug). WINNER-addressed commands ("FARIA,
HELLO") route to the same handlers.

- **FARIA** — mentor and quest engine of Act II. States: VOICE (through
  the wall) → COMPANION (moves via tunnel between cells with you; his
  presence lines vary by cell) → PARALYZED (cell 27 only) → DEAD/SACK.
  Topic table is the game's largest: LETTER, ARREST, DANGLARS, FERNAND,
  VILLEFORT, NOIRTIER, ESCAPE ("Patience. My tools took four years"),
  TOOLS, LAMP, TREASURE, PARCHMENT, SPADA, GOD, MERCEDES ("Love waits
  differently than hate. Both wait."), each of the four STUDY subjects,
  plus warm defaults. He refuses escape talk until education ≥2
  ("First become a man worth freeing"). His dialogue carries the game's
  heart; write him verbose by this game's standards (2 short paragraphs).
- **JAILER** — a rhythm, not a person: the every-12-turns demon; three
  interactions (jug replaced, plate broken, saucepan ceded) and the
  discovery logic.
- **MORREL** — Act I warm authority; Act III broken honor (topics: SHIP,
  DEBT, SEPTEMBER, DANTES — "the best heart that ever beat under a
  sailor's jacket; do not speak of him, monsieur, I shall disgrace
  myself"); Act V absent (his son inherits the thread).
- **MERCEDES** — Act I radiance (topics: FERNAND — "my cousin scowls
  because the sea gave me you"); Act IV one scene of terrible
  recognition (she alone needs no unmasking). Kept scene-scripted.
- **DANGLARS** — Act I sneer; Act IV BANKOFF fixture with a greed
  state-machine: CREDIT-OPEN → post-telegraph paranoia → (narrated)
  ruin → LARDER beggar. Topics: MONEY, SPAIN, CAVALCANTI, DANTES ("A
  sailor? I knew a sailor once. Drowned, I believe. Wine?").
- **FERNAND/MORCERF** — Act I glowering shadow; Act IV appears only in
  scenes (PEERS, the salon confrontation). No free topics; he is a
  fuse, and fuses do not chat.
- **VILLEFORT** — Act I examiner (scene); Act IV cold fixture at
  ASSIZES/VHALL with the SHAKEN flag altering his lines; final scene as
  above.
- **CADEROUSSE** — the everyman mirror: Act I hungry neighbor, Act III
  innkeeper confessor (biggest topic table after Faria: LETTER, FATHER,
  MERCEDES, DANGLARS, FERNAND, VILLEFORT, MORREL, PURSE, DIAMOND,
  DANTES — "He was my friend. I said nothing. Wine was invented
  because of men like me."), Act IV burglar and deathbed.
- **HAYDEE** — evidence with a soul. Topics: JANINA, FATHER, MOTHER,
  PROOF, COUNT ("He bought my freedom and gave it to me. A man does
  not do that twice in a world."). Accompanies to PEERS by flag.
- **BERTUCCIO** — one great confession scene + topics (VENDETTA, BOX,
  BENEDETTO, VILLEFORT).
- **NOIRTIER** — the blink-speech set piece; topics answered in
  narrated eye-language (POISONER, VALENTINE, LETTER — on the 1815
  letter his eyes say what no one else living can: *forgive*).
- **VALENTINE, MAXIMILIAN** — scene NPCs for the rescue and finale.
- **VAMPA, JACOPO, BEAUCHAMP, OPERATOR, COCLES, FATHER** — single-scene
  functionaries, each with 3-5 topics of flavor.

## 6. TIMERS & DANGER

| Act | Clock | Death? |
|---|---|---|
| I | Feast countdown (arrest at turn ~6 of feast); examination on rails. | None. Player cannot avert the arrest (attempts get foreboding text: "The magistrate's hand is already on the door of this day."). |
| II | Jailer every 12 turns (2-turn footstep warning). Sack-swap window ~30 turns to 10 o'clock, bell-counts as clock. Breath counter (6) underwater. Swim heading strikes (3). | Yes, all fair and themed: discovery (dungeon), incomplete swap, no knife / slow underwater, wrong-way swim. Every If death ends "The sea is the cemetery of the Château d'If" or the dungeon line. |
| III | None hard. The tartan departs by cutscene; no stranding. Blast proximity = knockdown only. | None (design: the treasure act is release, not stress). |
| IV | Caper gating via evidence flags, not clocks, EXCEPT: (a) Peers inquiry convenes 1 scene after PRESS-RUN — going without docs = duel = death/spoiled ending; (b) burglary night happens on schedule whether or not you keep vigil (missable points, not death); (c) after ASSIZES, the Villefort house scene expires in ~10 turns (he is mad by then — reveal lost, points lost, not death). | One death (the duel) and several missable-glory branches. Direct assault on any target at any time → "arrested in your own salon; the Count's mask is torn off by gendarmes, not by justice" → losing ending (the revenge-exposes-you failure). |
| V | None. | None. |

Death policy: every death prints a themed obituary, then the standard
RESTART/RESTORE/QUIT offer via JIGS-UP. No undo lecture; If deaths are
short and cold, Paris deaths ironic.

## 7. SCORING

SCORE-MAX 400. Act totals: I=35, II=130, III=90, IV=100, V=45.

Ranks (printed by V-SCORE and on death/victory):
- 0 — **Ship's Boy**
- 25 — **First Mate of the Pharaon**
- 50 — **Prisoner Number 34**
- 100 — **Pupil of the Abbé Faria**
- 150 — **The Man Who Escaped the Château d'If**
- 200 — **Sinbad the Sailor**
- 250 — **Master of Monte Cristo**
- 300 — **The Avenger**
- 350 — **The Count of Monte Cristo**
- 400 — **"Wait and Hope"** (only with VALENTINE-SAVED, the pardon, and
  the manuscript — mercy completes the score, not wrath)

## 8. INTRO & OUTRO DRAFTS

### Intro (cold open, TTS)

> On the twenty-fourth of February, eighteen hundred and fifteen, the
> lookout at Notre-Dame de la Garde signals the three-master Pharaon,
> from Smyrna, Trieste, and Naples. All Marseilles turns out to watch
> her come in, for she comes in strangely — slow, and sedate, and
> trimmed in mourning.
>
> Her captain is dead. Off Civita Vecchia the fever took brave Captain
> Leclere, and he went to his rest sewn in his hammock with a
> thirty-six-pound shot at his head and his heels. The man at the helm,
> who brought her home through the February gales, is nineteen years
> old.
>
> He is you. Edmond Dantès: first mate, about to be captain; son of a
> good father; betrothed of the most beautiful girl in the Catalan
> village. You are, this morning, the happiest man in Marseilles — and
> three men on this quay are already sick with wanting what you have.
>
> Bring your ship to her rest. Then go collect your happiness, all of
> it, piece by piece. You will want to remember where each piece came
> from.
>
> THE COUNT OF MONTE CRISTO — an interactive tragedy of patience.
> (Type HELP for guidance.)

### Victory outro (full revenge + mercy)

> The letter passes from your hand to Maximilian Morrel's, on the deck
> of your own grotto isle, while Valentine — alive, alive — holds his
> arm the way the drowning hold a spar.
>
> "There is neither happiness nor misery in the world; there is only
> the comparison of one state with another. He who has felt the deepest
> grief is best able to experience supreme happiness. We must have felt
> what it is to die, that we may appreciate the enjoyments of living.
>
> "Live, then, and be happy, beloved children of my heart, and never
> forget, until the day God deigns to reveal the future to man, that
> all human wisdom is summed up in these two words — Wait and hope."
>
> Signed: Edmond Dantès, Count of Monte Cristo.
>
> A sailor gone fourteen years came back to Marseilles wearing four
> faces, and the men who buried him met every one before the end: the
> priest, the Englishman, the Count — and last, always last, the young
> man in the sailor's jacket whose name they cried out like the damned.
> Danglars begged, and was forgiven. Fernand heard it, and fired. 
> Villefort touched it, and went mad. Caderousse saw it, and believed
> in God.
>
> And on the blue line where the sky meets the sea, a white sail grows
> small: the Count, and Haydée, and the horizon. Wait — and hope.
>
> [Your score is 400 of 400, in NNN turns. Your rank: "WAIT AND HOPE."]

### Failure outro — dying in the Château d'If

> The governor's report is four lines. A tunnel between cells
> thirty-four and twenty-seven; the prisoner moved to the dungeons
> below the waterline; the register amended.
>
> The sea is the cemetery of the Château d'If, and in the end it keeps
> its ledger like Danglars kept his: every soul accounted, none
> remembered. Mercédès waits eighteen months longer than anyone in
> Marseilles believes possible. The Pharaon sails under another
> captain. On the fifth of September, 1829, a good man in a counting-
> house puts a pistol in his mouth, and no hand knocks at the door.
>
> Nobody comes. That was always the other ending, and now it is yours.
>
> [You have died in the Château d'If. Score: NN of 400. Rank: Prisoner
> Number 34.]

### Failure outro — the duel (a revenge exposing you)

> The committee wanted documents. You gave them a rumor, and rumors
> have seconds and pistols. At dawn in the Bois de Vincennes the Count
> de Morcerf — soldier of Janina, traitor of Janina — puts his ball
> through the adventurer nobody in Paris could quite name.
>
> They bury you under the only title you ever showed them. The abbé's
> treasure keeps its last secret; Danglars dines well for thirty more
> years; a paralyzed old man in the Faubourg Saint-Honoré waits for a
> visitor who never comes.
>
> Vengeance is a science, Edmond. Faria told you: first, the proof.
>
> [Slain by the Count de Morcerf. Score: NNN of 400. Rank: The Avenger,
> revoked.]

## 9. WALKTHROUGH (complete, numbered, start → 400)

Act I
1. TALK TO MORREL
2. FURL SAILS
3. DROP ANCHOR
4. DOWN
5. OPEN CHEST
6. UP
7. WEST                      (quay)
8. WEST                      (counting-house)
9. TALK TO MORREL            (+10 captaincy)
10. EAST
11. NORTH                    (Meilhan)
12. GIVE PURSE TO FATHER     (+10)
13. TALK TO CADEROUSSE
14. SOUTH
15. SOUTH                    (Catalans)
16. KISS MERCEDES            (+5)
17. TELL MERCEDES ABOUT FEAST
18. NORTH
19. EAST                     (La Réserve; feast begins)
20. WAIT
21. WAIT
22. WAIT                     (arrest; auto to Villefort)
23. TALK TO VILLEFORT
24. GIVE LETTER TO VILLEFORT (+5; he burns it; night boat; If)

Act II
25. PRAY
26. WAIT                     (years-pass interstitial)
27. LISTEN TO WALL
28. TAKE STONE
29. KNOCK ON WALL            (+5; silence)
30. WAIT                     (three days; sound resumes)
31. BREAK JUG
32. TAKE SHARD
33. MOVE BED
34. DIG WALL WITH SHARD      (+5; hewn stone blocks)
35. PUT PLATE BY DOOR
36. WAIT                     (jailer breaks plate, leaves saucepan)
37. TAKE HANDLE              (straightened into lever)
38. PRY STONE WITH HANDLE    (+10)
39. DIG TUNNEL WITH HANDLE
40. DIG TUNNEL WITH HANDLE   (beam; despair; "Who talks of God...")
41. TALK TO VOICE            (catechism; "tomorrow")
42. WAIT                     (floor opens; Faria; +15)
43. TELL FARIA ABOUT LETTER
44. TELL FARIA ABOUT DANGLARS   (+5)
45. TELL FARIA ABOUT FERNAND    (+5)
46. TELL FARIA ABOUT VILLEFORT  (+5)
47. DOWN                     (tunnel)
48. WEST                     (cell 27)
49. STUDY WITH FARIA         (+5, languages)
50. STUDY WITH FARIA         (+5, mathematics)
51. STUDY WITH FARIA         (+5, history)
52. STUDY WITH FARIA         (+5, chemistry; second attack follows)
53. LIFT HEARTH
54. TAKE PHIAL
55. POUR PHIAL IN MOUTH      (+5; Faria half-paralyzed)
56. ASK FARIA ABOUT TREASURE
57. READ PARCHMENT           (fragments)
58. ASK FARIA ABOUT PARCHMENT   (+10; the will complete)
59. WAIT                     (the third attack, at night; Faria dies;
                              morning: doctor, hot iron, sack; evening set)
60. LIFT HEARTH
61. TAKE KNIFE
62. TAKE NEEDLE
63. CUT SACK WITH KNIFE
64. DRAG BODY
65. EAST                     (into tunnel, bearing him)
66. EAST                     (cell 34)
67. PUT BODY IN BED
68. COVER BODY
69. WEST
70. WEST                     (cell 27)
71. ENTER SACK
72. SEW SACK                 (+15)
73. WAIT                     (bearers; the shot; "One! two! three!")
74. CUT SACK WITH KNIFE
75. CUT CORD WITH KNIFE
76. UP                       (+15; the open sea)
77. LOOK                     (Planier light)
78. SWIM WEST
79. SWIM WEST
80. SWIM WEST                (+5; Tiboulen)
81. ENTER OVERHANG
82. DRINK WATER
83. WAIT                     (storm; the wreck; dawn; cannon)
84. TAKE CAP
85. WEAR CAP
86. TAKE SPAR
87. WAVE AT SHIP             (+10; rescued; months pass; the island)

Act III
88. LAND                     (the creek)
89. EXAMINE ROCKS            (notches)
90. EAST
91. EAST                     (clearing; ship departs; supplies)
92. COUNT ROCKS              (+5)
93. EXAMINE BOULDER
94. DIG WEDGE WITH PICKAXE
95. CUT BRANCH
96. PRY BOULDER WITH BRANCH  (fails — Hercules line)
97. PUT POWDER IN HOLE
98. LIGHT POWDER             (the blast; ring)
99. PULL RING                (+10; stairs)
100. DOWN
101. KNOCK ON WALL           (hollow echo)
102. HIT WALL WITH PICKAXE   (+10; opening)
103. EAST
104. DIG CORNER WITH PICKAXE (the coffer)
105. OPEN COFFER WITH PICKAXE
106. TAKE TREASURE           (+25; Leghorn interstitial; the mainland)
107. WEAR CASSOCK
108. ENTER INN
109. TALK TO CADEROUSSE
110. ASK CADEROUSSE ABOUT LETTER   (+10; the guilt confirmed)
111. ASK CADEROUSSE ABOUT FATHER
112. ASK CADEROUSSE ABOUT MORREL
113. ASK CADEROUSSE ABOUT PURSE
114. GIVE DIAMOND TO CADEROUSSE    (+10; the red purse)
115. WEAR COAT                     (Lord Wilmore; to Marseilles)
116. TALK TO MORREL
117. PAY DEBT                (+the receipted bill)
118. PUT BILL IN PURSE
119. PUT GEM IN PURSE        ("Julie's Dowry")
120. NORTH                   (Meilhan)
121. PUT PURSE ON MANTEL     (+20; the Fifth of September; 1838; Paris)

Act IV
122. NORTH                   (Haydée)
123. ASK HAYDEE ABOUT JANINA
124. ASK HAYDEE ABOUT PROOF  (+5; the satchel)
125. SOUTH
126. SOUTH                   (the street)
127. WEST                    (bank)
128. WEST                    (Danglars's office)
129. SHOW LETTER TO DANGLARS (+5; unlimited credit)
130. EAST
131. EAST
132. NORTHWEST               (telegraph garden)
133. GIVE BANKNOTES TO OPERATOR   (+5)
134. UP
135. SET SIGNAL              (+5; the false dispatch; the million lost)
136. DOWN
137. SOUTHEAST               (street)
138. IN                      (coach to Auteuil)
139. TALK TO BERTUCCIO       (+10; the confession)
140. EAST
141. DIG EARTH WITH SPADE    (+5; the iron box)
142. WEST
143. HOST DINNER             (+5; the declaration; Villefort shaken)
144. OUT                     (street; night falls; the warning note)
145. NORTH                   (salon)
146. EAST                    (study)
147. WEAR CASSOCK
148. WAIT                    (Caderousse through the window)
149. TELL CADEROUSSE ABOUT BENEDETTO   (+5; the signed letter; the
                              knife at the gate; the deathbed)
150. REMOVE WIG              (+5; "I am Edmond Dantès"; he dies)
151. WEST
152. SOUTH                   (street; morning)
153. EAST                    (the press)
154. TELL BEAUCHAMP ABOUT JANINA   (+5; the article runs)
155. WEST
156. SOUTHEAST               (Peers; Haydée follows with the satchel)
157. WAIT                    (the testimony; the vote; +15; that
                              evening, Morcerf comes)
158. WEAR JACKET             (+5; "Edmond Dantès!"; the shot)
159. SOUTH → SOUTHWEST       (Villefort's hall)
160. NORTH                   (Noirtier)
161. TALK TO NOIRTIER        (the blink alphabet; the poisoner)
162. SOUTH
163. EAST                    (Valentine)
164. GIVE PILL TO VALENTINE  (+10; the staged death)
165. WEST
166. NORTHEAST               (street)
167. SOUTH                   (Assizes)
168. WAIT                    (+10; "His name is Villefort")
169. NORTH → SOUTHWEST       (Villefort's hall, at the gallop)
170. WEAR CASSOCK
171. NORTH                   (Noirtier's room; Villefort bursts in)
172. REMOVE WIG              (+5; "I am Edmond Dantès"; Edouard; the
                              wrath breaks; Danglars flees — Rome)

Act V
173. EAST                    (the larder cell)
174. TALK TO DANGLARS        ("Do you repent?")
175. FORGIVE DANGLARS        (+15; white hair by morning; Marseilles)
176. ENTER TUNNEL            (the guided tour looks away)
177. TAKE MANUSCRIPT         (+5; the island)
178. GIVE LETTER TO MAXIMILIAN   (+25; Valentine from the grotto;
                              "Wait and hope"; the white sail)
                              *** YOU HAVE WON ***  400/400

(Compass connectives between Paris scenes are illustrative; final exit
letters get fixed in implementation. The walkthrough.txt for CI is this
list with pure parser commands and WAIT-padding at scene boundaries.)

## 10. WRITING STYLE GUIDE (TTS-voiced — CRITICAL)

1. **Length.** Most responses 1-3 sentences. Hard cap: 2 short
   paragraphs, and only for scene beats (arrival, reveal, death).
   Room LDESCs: 3 sentences max.
2. **For the ear.** No ASCII art, no maps, no tables, no bracketed
   stage directions in game text. Numbers spelled out ("thirty-six-
   pound shot"). Em-dash sparingly; prefer the period. Semicolons are
   Dumas's — allowed, one per response.
3. **Dumas flavor, Zork economy.** One image per response, concrete
   and physical: iron, stone, salt, gold, ink. Melodrama lives in nouns
   and cadence, not adjectives. Wrong: "You feel an overwhelming sense
   of profound despair." Right: "The door shuts. The sound it makes is
   final, like a ledger closing."
4. **Second person, present tense,** matching the engine's defaults.
   The narrator knows more than the player and lets it show only as
   dread or irony, never as spoilers.
5. **Names as music.** The four enemies' names are drumbeats; the game
   says them rarely so scenes can spend them. "Edmond Dantès" appears
   in narration only at the three reveals and the endings.
6. **Failure text teaches.** Every "you can't" says why in-world and
   points somewhere: "The bars have argued with better men than you.
   The wall, though, is damp." Never a bare "You can't do that."
7. **Quotes.** The certified lines from STUDY.md §7 are load-bearing;
   use them verbatim at their moments and do not paraphrase them
   elsewhere.
8. **Interstitials** (years passing) are 2-3 sentences, dated, and end
   looking forward: "It is 1838, and Paris believes in you."
9. **NPC voice tags:** Faria = warm, exact, Latin-flavored aphorism.
   Caderousse = self-pity with truth leaking through. Danglars =
   numbers and appetite. Villefort = marble with hairline cracks.
   Mercédès = plain words, unbearable. Haydée = formal, vivid, oath-
   like. The Count's own lines = short, courteous, terrifying.
10. **The LLM layer** rewrites player phrasing but passes game text
    through; therefore the game text IS the voice — keep it clean of
    parser-ese ("Taken." is fine; "You take the brass key." better).

## 11. BUILD NOTES

**Version: compile v8** (`-I zil/engine-v8 -v 8` + the `V8PATCH`
insert line). Rationale: 40 rooms + ~95 objects + heavy scene text will
crowd v3's 128KB; v8 gives 512KB and 48 flags (the engine already eats
most of v3's 32, and this design wants ~10 custom flags: DOCKED,
BED-MOVED, KNOWS-ENEMIES, RICH, CONFIRMED-GUILT, JANINA-DOCS, PRESS-RUN,
AUTEUIL-BOX, DINNER-HELD, VALENTINE-SAVED, WRATH-CHECKED... — several
can be globals instead of flags; still, v8 is the safe envelope). No
status bar in v8 is acceptable (zorkllm CLI handles it).

**Counts vs limits.** Rooms 40 + objects ~95 + engine's 18 GGLOBALS
objects + scenery ≈ 170 — comfortably under 255 either way. Properties:
stock set suffices (SIZE/CAPACITY/VALUE/TVALUE + engine's). GGLOBALS
before the dungeon file, ZORK-NUMBER 0, per AUTHORING.md.

**Dictionary (6-char truncation) — reserved truncations, all distinct:**
CHATEA(U), VILLEF(ORT), DANGLA(RS), MERCED(ES), CADERO(USSE),
MORCER(F), FERNAN(D), NOIRTI(ER), VALENT(INE), BENEDE(TTO),
BERTUC(CIO), MAXIMI(LIAN), BEAUCH(AMP), TELEGR(APH), PARCHM(ENT),
SAUCEP(AN), MANUSC(RIPT), TREASU(RE), DIAMON(D), FLAGST(ONE),
BOULDE(R), OPERAT(OR), GOVERN(OR), HANDKE(RCHIEF). Watch-outs:
**MORREL vs MORCER** differ at char 4 — safe. **VALENT vs VALISE** —
don't add a valise. **LETTER collides with itself**: four letters exist
(Elba letter, credit letter, warning note, final letter) — disambiguate
by ADJECTIVE (ELBA, CREDIT, ANONYM, FAREWE) and keep at most two in
scope at once (the design already does). PURSE ×2 (coin purse Act I,
red purse) — never in scope together; still give ADJECTIVE COIN / RED.
STONE ×3 (loose stone, hewn stone, hearth stone) — adjectives LOOSE,
HEWN, HEARTH and scope discipline. SACK, SHARD, HANDLE, CORD, CAP,
SPAR, RING, COFFER, PHIAL, SATCHE(L) all unique.

**Verbs.** Stock covers: TAKE, DROP, OPEN, CLOSE, READ, EXAMINE,
LISTEN, KNOCK ON, DIG (+ WITH), MOVE/PUSH (MOVE X WITH Y exists), CUT
(WITH), BREAK (DESTROY), BURN, LIGHT, POUR, PUT (IN/ON/BY), TIE, UNTIE,
WEAR (+ PUT ON), WAVE (AT), SWIM, YELL, PRAY, WAIT, SLEEP?, ENTER,
CLIMB, COUNT, SEARCH, GIVE, SHOW, TALK TO (=V-TELL), TELL X ABOUT Y
(ASK is a TELL synonym), KISS, FOLLOW. New SYNTAX needed (small):
- `<SYNTAX STUDY WITH OBJECT = V-STUDY>` (+ LEARN synonym)
- `<SYNTAX SEW OBJECT = V-SEW>` (+ SEW OBJECT WITH OBJECT)
- `<SYNTAX PRY OBJECT WITH OBJECT = V-PRY>` (routes to the same
  handlers as MOVE X WITH Y; PRY reads better in transcripts)
- `<SYNTAX FORGIVE OBJECT = V-FORGIVE>` (+ PARDON synonym)
- `<SYNTAX FURL OBJECT = V-FURL>` (+ synonym via LOWER? LOWER exists
  as verb? if not: FURL/STRIKE both new, trivial)
- `<SYNTAX PAY OBJECT = V-PAY>` (PAY DEBT; also accept GIVE GOLD TO
  MORREL via GIVE handler)
- `<SYNTAX HOST OBJECT = V-HOST>` (HOST DINNER; WAIT also triggers)
- `<SYNTAX REMOVE OBJECT = ...>` exists (take off) — REMOVE WIG works
  as TAKE OFF WIG if WIG is worn with WEARBIT; implement WIG as part
  of CASSOCK costume (one object, adjective handling).
- SET SIGNAL: `<SYNTAX SET OBJECT = V-SET>`? Zork has TURN/MOVE —
  simplest: make SIGNAL-LEVERS a PUSH/PULL/MOVE target and accept SET
  as a new verb. DRAG as synonym of TAKE for the BODY special-case.

**Identity/disguise state.** One global `IDENTITY` (small int) + three
WEARBIT costume objects (CASSOCK, ENGLISH-COAT, SAILOR-JACKET; fine
dress implied when none worn in Act IV). WEAR sets IDENTITY and prints
a mirror line; REMOVE resets to Count/Edmond per act. NPC action
routines branch on `,IDENTITY`. The three reveal commands (WEAR JACKET
in salon scene; REMOVE WIG at two deathbed/confrontation scenes) are
scene-gated in the NPC/room actions, not in the verb.

**Act gating.** A global `ACT` (1-5) drives room LDESC variants
(CELL34 revisit, OFFICE/MEILHAN 1829 versions) via room-action M-LOOK
branches; exits gated on ACT prevent wandering into dead sets. The
Act II phase machine is a global `PHASE` with the jailer demon
(GCLOCK C-INTS) and threshold events. Scene scripts (feast, trial,
dinner, drop) are room-action turn counters — the Zork thief/cyclops
machinery is precedent that this scale of scripting fits the engine.

**Body-carry special case.** BODY has TRYTAKEBIT; DRAG/TAKE sets a
CARRYING-BODY flag limiting movement to the tunnel path with custom
travel messages; PUT BODY IN BED clears it. Simpler than real weight.

**Underwater/breath.** UNDERSEA room action counts turns on M-END;
breath messages by count; death at 7. OPENSEA heading logic in the
room's direction handling (PER routines returning false with warning
text for wrong headings).

**Engine risks (ranked).**
1. *Scene density in Act IV* — many one-shot scripts; mitigate by
   making each caper a linear flag chain (done above) and testing each
   caper standalone with walkthrough fragments.
2. *TELL/ASK ABOUT topic routing* — V-TELL in the stock engine is
   thin; we implement per-NPC topic tables in the NPC action routines
   keyed on PRSI (the ABOUT object) — topics must exist as (mostly
   NDESCBIT, INVISIBLE) vocabulary objects: LETTER, JANINA, PROOF,
   FEAST, DEBT, REPENT etc. Budget ~20 topic pseudo-objects (counted
   in the 95).
3. *Two-word truncation traps in player input* — the LLM layer
   normalizes phrasing but the raw parser must still work: keep every
   noun's first six letters unique in scope (audited above).
4. *Jailer demon vs scene scripts* — the demon must suspend during
   scripted scenes (a SUSPEND flag the scenes set) or it will walk
   into the sack-swap; explicit in the phase machine.
5. *Text budget* — the style guide's brevity is also the memory
   budget; abbreviation pass on; if v8 text still bloats, trim Act IV
   flavor topics first, never Act II.

**Testing plan.** walkthrough.txt = §9 verbatim (plus WAIT padding);
`node czil/tests/play.mjs game.z8 walkthrough.txt` must reach 400 and
print the victory outro. Add three death-walkthroughs (no-knife sack,
jailer discovery, duel) asserting the themed obituaries. Freeze
transcripts, diff on every change, per AUTHORING.md.

---

*Solvability audit:* every gate lists its key above — (arrest) none;
(tunnel) shard→saucepan chain, all props in the start room; (Faria
beats) conversation-only; (swap) knife+needle both in one cache the
player has already opened twice; (sea) knife retained by design;
(rescue) cap on the beach where the player must stand; (island)
supplies granted by cutscene, parchment carried by design; (Morrel)
requires RICH which precedes it; (each caper) evidence chains are
intra-caper and signposted by the DOSSIER; (finale) letter is
auto-provided. No unmarked dead ends: nothing consumable is needed
twice; no gate's key can be lost (drop-guards on ELBA-LETTER, KNIFE
during phase E, PARCHMENT sewn into rags, SATCHEL undroppable by
Haydée's trust line).*
