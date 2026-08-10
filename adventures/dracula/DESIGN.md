# DRACULA — Game Design Document

A text adventure adaptation of Bram Stoker's novel for the zorkllm
toolchain (czil compiler + Zork I engine files). Companion document:
STUDY.md (source notes with verbatim quotes; quote references below point
there). This document is intended to be sufficient to build the game
without re-reading the novel.

Working title: **DRACULA: The Un-Dead**
Target: v8 story file (see Build Notes for why), playable as v3 if flags
allow. Roughly 42 rooms, ~55 objects, 3 acts + prologue text.

---

## 1. Vision & tone

**The player fantasy:** you own the classic vampire-hunting kit — garlic,
crucifix, stake, sacred Host — and the game takes every piece of it
seriously. Every rule Van Helsing lectures about in the novel is a real
mechanic: garlic rubbed on window sashes keeps the thing out, the Host
crumbled into a box of earth denies him that lair forever, a mirror shows
you the empty room behind the man standing at your shoulder, and sunset
and sunrise are announced clocks that decide who is hunting whom.

**Why it's fun:** Stoker's dread and Zork's responsiveness are not
enemies. Dread comes from the clock and the stakes; responsiveness comes
from the game always having something to say. EXAMINE anything in Castle
Dracula and get a sentence with teeth in it. Try something hopeless and
get a reply with wit in it (the failure text is playful-but-gothic, never
snarky out of period). The horror is punctuated, not wall-to-wall: Van
Helsing's mangled English, Renfield's fly-arithmetic, and the Texan's
drawl are the pressure valves, exactly as they are in the book.

**The epistolary frame is the UI.** Every act and player-switch is headed
"From the journal of ...". Death does not say "you have died"; it says
the journal breaks off. This gives TTS listeners natural chapter breaks
and makes the whole game feel like the bundle of documents the novel is.

**Compression promise:** the novel's slow middle (August correspondence,
weeks of transfusions, three separate cockney interviews) is compressed
hard. Every iconic scene survives: the caleche and the blue flames, the
shaving mirror, the wall crawl, the brides, the Demeter's log, the
churchyard rescue, Lucy's tomb, Renfield's bargain, the blood baptism and
the brand, the Piccadilly taunt, the holy circle, the brides staked, and
the knife kill at sunset.

---

## 2. Structure & character switching

Four playable segments, each introduced by a journal header. The engine
keeps a single ADVENTURER object as WINNER throughout; a "switch" is a
scripted scene change: inventory is banked, HERE is reset, a global ACT
variable changes what rooms/NPCs are live, and the game prints the new
journal header (see Build Notes 11.4).

- **ACT I — "Jonathan Harker's Journal."** May. You are Harker, trapped
  in Castle Dracula. Survival-horror tutorial dungeon: learn the vampire
  facts by observation (no reflection, sleeps by day, commands wolves),
  survive the brides, and escape down the castle wall. The act ends with
  the wall climb; an interstitial paragraph covers the brain fever and
  the letter to Mina.
- **ACT II, scene 1 — "Mina Murray's Journal."** August, Whitby. Short
  playable vignette (6 rooms): the storm, the Demeter and her log, and
  the churchyard rescue of sleepwalking Lucy. Teaches the England-side
  cast and plants the wound on Lucy's throat.
- **ACT II, scene 2 — "Dr. Seward's Diary."** September. The long act.
  You are Dr. Seward at the Purfleet asylum: fight the staged timer of
  Lucy's decline (winnable!), mine Renfield for truth, raid Carfax with
  the hunters, trace and sanctify the boxes of earth, endure the attack
  on Mina, and drive Dracula out of England at Piccadilly.
- **ACT III — "The Journals of the Hunters."** October-November. Three
  short chained segments: (a) Mina at Varna/Galatz — the trance and the
  river deduction; (b) Van Helsing at the castle — the holy circle, the
  brides staked, the great tomb sealed; (c) Jonathan on the frozen road —
  the sunset kill. Fast, cinematic, each 10-25 turns.

Why this structure and not one hero: the book's power is that nobody
sees the whole shape alone — and mechanically each segment gets the
verbs that fit its character (Harker climbs and hides; Seward doctors
and investigates; Mina deduces; Van Helsing consecrates; Harker, at the
end, kills). Infocom precedent: Suspended/Border Zone reseat the player
identity; here it is pure narration plus map gating, which is even safer.

Switch points and narration (exact):
1. End of Act I (after the climb): "Here the shorthand journal of
   Jonathan Harker breaks off. Weeks later a sick man will wake in a
   hospital at Buda-Pesth, and a letter will go to England. -- From the
   journal of Mina Murray, Whitby, August."
2. End of Whitby scene (telegram about Lucy): "From the diary of Dr.
   John Seward, kept in phonograph. Purfleet, September."
3. End of Act II (the Czarina Catherine sails): "From the journal of
   Mina Harker, aboard the Orient Express."
4. Within Act III: "From the memorandum of Abraham Van Helsing" and
   finally "From the journal of Jonathan Harker, the sixth of November."

---

## 3. The map

Convention: DESC is the status-line name; the "ear" text below is the
LDESC, written to be heard, 1-3 sentences. Contents listed are the
notable objects placed there at act start.

### 3.1 Act I — Castle Dracula (16 rooms)

```
                          [South Landing]---(window)---[Castle Ledge]
                                |                          |
 [Library]--[Dining Room]--[Upper Passage]--(stuck door)--[Ladies' Wing]
                 |               |                         (window to Ledge)
          [Octagonal Room]  [Winding Stair]           [Dracula's Room]
                 |               |                     (window to Ledge)
            [Bedroom]      [Entrance Hall]                 |
                                |                    [Circular Stair]
                          (great door)                     |
                                |                    [Dark Passage]
                          [Courtyard]                      |
                                                     [Ruined Chapel]
                                                           |
                                                        [Vault]
```

1. **Courtyard** — "Castle Courtyard". A vast courtyard of black stone
   under broken battlements; dark archways yawn on every side, all
   barred beyond. The great nail-studded door of the keep stands north.
   Exits: NORTH to Entrance Hall (if great door open; else "The great
   door is shut fast."). Archways: scenery, "cold air breathes out of
   the dark; iron gates bar every one." Contents: great door (scenery
   door), later the pile of boxes and the Szgany (scripted).
2. **Entrance Hall** — "Entrance Hall". A stone hall lit by a hanging
   silver lamp; the great outer door is bound with chains and massive
   bolts, and the stone stair winds upward into gloom. Exits: SOUTH to
   Courtyard (through great door, locked from Day 2), UP to Winding
   Stair. Contents: great door (bolts and chains openable, lock has no
   key — see puzzle P8), silver lamp (scenery).
3. **Winding Stair** — "Winding Stair". Steps of worn stone circle
   upward, ringing under your feet; the draught carries the far howling
   of wolves. Exits: DOWN Hall, UP Upper Passage.
4. **Upper Passage** — "Upper Passage". A long stone corridor of locked
   doors — doors, doors everywhere, and every one locked and bolted. At
   its end a heavy door sags against the floor, and a narrower stair
   climbs south. Exits: DOWN Winding Stair, WEST Dining Room, UP South
   Landing, EAST through the stuck door to Ladies' Wing (blocked until
   P4 solved: "The heavy door is jammed; its hinges have sunk, and it
   rests upon the floor."). Contents: stuck door, locked doors (scenery
   with good EXAMINE/OPEN responses).
5. **Dining Room** — "Dining Room". A table of gold plate stands before
   a mighty hearth where a log fire roars; there is warmth here, and no
   mirror anywhere. Exits: EAST Upper Passage, WEST Library, SOUTH
   Octagonal Room. Contents: table (surface), gold service (scenery),
   fire (scenery), Dracula's card ("I have to be absent for a while. Do
   not wait for me. -- D.", readable).
6. **Library** — "Library". Shelves of English books climb the walls —
   law, history, an atlas — and a sofa faces the cold hearth; someone
   has studied your country the way a hunter studies a covert. Exits:
   EAST Dining Room. Contents: atlas (READ: falls open at England,
   rings inked round Whitby, Exeter, and Purfleet — foreshadowing),
   Bradshaw's railway guide, English books (scenery), Harker's papers
   (deeds — scripted in the supper scene).
7. **Octagonal Room** — "Octagonal Room". A small eight-sided chamber
   without a single window, lit by one lamp; doors face each other like
   patient sentries. Exits: NORTH Dining Room, SOUTH Bedroom.
8. **Bedroom** — "Great Bedroom". Your bedroom: a curtained bed, a fresh
   log fire, and a barred window on the courtyard. Above the bed hangs
   the crucifix the innkeeper's wife pressed on you. It is the one room
   where sleep is safe. Exits: NORTH Octagonal Room. Contents: crucifix
   (worn from start; over bed if dropped), travelling bag (container:
   shaving glass, letter paper), bed, barred window (throwing letters:
   P7), hand lamp (takeable light source), wardrobe (Harker's clothes —
   stolen after Day 2, scripted).
9. **South Landing** — "South Landing". A tall stone-mullioned window
   fills this landing with sky; below the sill the wall drops a thousand
   feet, sheer as a cut, to a sea of green treetops. Exits: DOWN Upper
   Passage; OUT/CLIMB through window to Castle Ledge (P5: boots must be
   off). Scripted: looking out at night triggers the lizard-crawl scene
   the first time (Dracula face-down on the wall, cloak spread like
   wings).
10. **Ladies' Wing** — "Ladies' Wing". A wide chamber deep in dust,
    where moonlight through diamond panes falls on a little oak table
    and a great couch; ladies sat here once, singing, while their
    menfolk rode to war. Exits: WEST through stuck door to Upper
    Passage; OUT window to Castle Ledge. Contents: oak table, couch,
    dust (footprints readable), diamond panes. Night hazard: the brides
    (NPC section 5.2).
11. **Castle Ledge** — "Narrow Ledge". You stand on a hand's-breadth of
    crumbling stone above a gulf of moonlit air; the wind pulls at your
    coat like a living thing. Do not look down. Exits: window IN to
    South Landing / Ladies' Wing (whichever you came from), NORTH along
    the ledge to Dracula's window, DOWN = the final escape climb (P9;
    fatal before conditions are met — always warned first).
12. **Dracula's Room** — "The Count's Room". A bare, dusty chamber no
    servant tends; in one corner, dulled by grave-dust, lies a mound of
    old gold — Roman, Turkish, British — none of it newer than three
    hundred years. A heavy door stands in the corner. Exits: window OUT
    to Castle Ledge; CORNER DOOR / DOWN to Circular Stair. Hall door:
    locked always ("The lock is new, and the key is wherever HE is.").
    Contents: gold heap (take some: P6), jewelled chains (scenery).
13. **Circular Stair** — "Circular Stair". A stone screw of a stair,
    lit only through loopholes, going steeply down into an odour you
    know before you can name it: old earth, newly turned. Exits: UP
    Dracula's Room, DOWN Dark Passage.
14. **Dark Passage** — "Dark Passage". DARK ROOM (needs the hand lamp).
    A tunnel of dressed stone; the deathly, sickly odour of fresh-dug
    earth thickens with every step. Exits: NORTH Circular Stair, SOUTH
    Ruined Chapel.
15. **Ruined Chapel** — "Ruined Chapel". The roof is broken and the
    moon or sun looks in; the ground has been dug over, and great
    wooden boxes stand ranked like coffins waiting for a congregation.
    Steps descend into the vaults. Exits: NORTH Dark Passage, DOWN
    Vault. Contents: the fifty boxes (collective object), shovel,
    freshly turned earth (scenery).
16. **Vault** — "Old Vault". DARK ROOM. Fragments of ancient coffins
    and piles of dust; in the third recess a single great box rests on
    new earth, its lid leaning against the wall, holes pierced through
    it. Exits: UP Chapel. Contents: the great box (container with THE
    COUNT in it by day — P10), coffin fragments, dust.

### 3.2 Act II scene 1 — Whitby (6 rooms)

```
 [Crescent Bedroom]
        |
   [West Cliff]--[Drawbridge]--[Church Steps foot ... 199 steps ...]
                                     |
                     [Tate Hill Pier]-+-[Churchyard]--[Abbey Ruin]
```

17. **Crescent Bedroom** — "Bedroom at the Crescent". The room you share
    with Lucy at the Crescent; the window looks over the harbour to the
    East Cliff, where the abbey stands against the sky like a memory.
    Exits: DOWN/OUT to West Cliff. Contents: Lucy's bed, window, Mina's
    shawl, safety pin (in workbasket), journal.
18. **West Cliff** — "West Cliff". The paved walk above the harbour:
    below, red roofs piled anyhow like a picture of Nuremberg, and one
    long granite pier curving into the sea with a lighthouse at its
    elbow. Exits: UP/IN to Crescent Bedroom, EAST/DOWN to Drawbridge.
19. **Drawbridge** — "The Drawbridge". The one bridge over the Esk; the
    only way between the cliffs. Fishermen's houses crowd the far bank,
    and the church steps rise beyond. Exits: WEST West Cliff, EAST
    Church Steps.
20. **Church Steps** — "The 199 Steps". The famous stairs wind up the
    East Cliff in a long, gentle curve — a hundred and ninety-nine of
    them, and every one an eternity when you are running. Exits: DOWN
    Drawbridge, UP Churchyard, NORTH along the shore to Tate Hill Pier.
21. **Churchyard** — "St. Mary's Churchyard". Tombstones lean over the
    town where the cliff has fallen away; walks and seats thread the
    graves, and the harbour glitters far below. Lucy's favourite seat
    rests on the slab of a suicide's grave. Exits: DOWN Church Steps,
    SOUTH Abbey Ruin. Contents: the seat (on George Canon's tombstone —
    READ TOMBSTONE), tombstones ("Edward Spencelagh, master mariner,
    murdered by pirates..."), Mr. Swales (day NPC).
22. **Abbey Ruin** — "Whitby Abbey". A noble ruin of immense size, all
    empty windows and broken arches; they say a white lady shows herself
    in one of the windows. The wind talks here. Exits: NORTH Churchyard.
    (Pure atmosphere + one hint: at night after the storm, wolfish
    paw-prints in the dew, leading toward the churchyard.)
23. **Tate Hill Pier** — "Tate Hill Pier". A tongue of sand and gravel
    beneath the East Cliff. After the storm night, the Demeter lies
    here, driven ashore with all sail set, her dead captain lashed to
    the wheel. Exits: SOUTH Church Steps. Contents (post-storm): the
    schooner (ENTER-able scenery), the dead captain (crucifix bound to
    his hands — examinable, not takeable: "Let the dead keep what held
    the dead safe"), the captain's log (readable — the compressed
    Demeter log, the act's centerpiece document), silver sand, box
    cart-tracks leading away.

### 3.3 Act II scene 2 — London/Purfleet (16 rooms)

```
                     [Renfield's Cell]
                          |
 [Study]--[Corridor]--[Asylum Grounds]--(wall)--[Carfax Lawn]
              |            |                        |
        [Guest Room]   [London Road]           [Carfax Hall]
                        /    |    \  \              |
              [Hillingham] [Kingstead] [Piccadilly] [Carfax Chapel]
                   |         |        \    |
             [Lucy's Room] [Westenra  [Walworth]
                            Tomb]      [Piccadilly House]
```

24. **Study** — "Dr. Seward's Study". Your study at the asylum: the
    phonograph with its wax cylinders, a locked safe, a case-bottle of
    brandy, and a window giving on the grounds. Exits: EAST Corridor.
    Contents: phonograph (READ/PLAY = recap of the story so far — the
    built-in "what do I know" device), safe (typed manuscript copy —
    plot armor, referenced after the burning), brandy, telegrams
    (arrive here), Van Helsing (when in residence).
25. **Corridor** — "Asylum Corridor". Whitewashed and echoing; somewhere
    down the ward a patient laughs, and stops. Exits: WEST Study, NORTH
    Renfield's Cell, EAST Guest Room, SOUTH/OUT Asylum Grounds.
26. **Renfield's Cell** — "Renfield's Room". A bare room smelling of
    sugar and something older; flies stitch the sunbeam, and the window
    — screwed shut — looks toward the trees of the neighbouring park.
    Exits: SOUTH Corridor. Contents: Renfield (NPC), fly-box, sugar,
    his notebook (columns of little numbers added and added again).
27. **Guest Room** — "The Harkers' Room". The room given to Jonathan and
    Mina: a bed by the window, her typewriter on the table, his kukri
    knife on the mantel — a married couple's tidy courage. Exits: WEST
    Corridor. Contents: Mina (nights), Jonathan (comes and goes),
    typewriter, kukri knife (Jonathan's; borrowable in Act II endgame).
28. **Asylum Grounds** — "Asylum Grounds". Lawn and old trees inside a
    high wall; beyond the wall eastward rise the heavier trees of
    Carfax, and its ruined roofs. Exits: IN Corridor, EAST over the
    wall to Carfax Lawn (needs the garden ladder or after the raid
    begins: "The wall is twelve feet if it is an inch."), SOUTH London
    Road. Contents: ladder (against the potting shed), kennels (the
    three terriers — needed at Carfax).
29. **Carfax Lawn** — "Carfax". Twenty acres of black pond and older
    trees around a house of all periods, part of it a keep with barred
    windows high up; against it leans a chapel of old times. The place
    holds its breath. Exits: WEST over wall to Asylum Grounds, IN/NORTH
    to Carfax Hall (front door: skeleton keys, P13). Contents: front
    door, dark pond (scenery).
30. **Carfax Hall** — "Carfax Hall". Dust lies inches deep, torn by
    hobnailed footprints; cobwebs hang like old rags. On a table lies a
    great bunch of keys, every one with a time-yellowed label. Exits:
    OUT Carfax Lawn, EAST through the low arched iron-ribbed door to
    Carfax Chapel. Contents: labelled key bunch (takeable — opens the
    chapel and, later, reads as a hint list of Dracula's properties).
31. **Carfax Chapel** — "Carfax Chapel". The smell arrives before the
    sight of it: earth, blood, and something worse — as though
    corruption had become itself corrupt. Great wooden boxes stand in
    the gloom. Exits: WEST Carfax Hall, SOUTH outer door to the grounds
    (bolted inside). Contents: the twenty-nine boxes (collective), rats
    (event, P14), outer door.
32. **London Road** — "The London Road". A hansom-and-train abstraction:
    from here the day's errands run — west to Hillingham, south to the
    churchyard at Kingstead, east to Piccadilly, and the mean streets
    of Walworth between. (Travel text varies by destination; one turn
    each way.) Exits: NORTH Asylum Grounds, WEST Hillingham Hall, SOUTH
    Kingstead Churchyard, EAST Piccadilly Steps, SE Walworth Lodging.
33. **Hillingham Hall** — "Hillingham". The Westenra hall: flowers,
    good furniture, and a stillness that has learned to listen for a
    sickroom bell. Exits: EAST London Road, UP Lucy's Room. Contents:
    Mrs. Westenra (NPC, fragile), decanter of sherry (after the wolf
    night: smells of laudanum — clue), the maids (scenery NPC).
34. **Lucy's Room** — "Lucy's Room". A pretty bedroom trying to stay
    one: the bed, the fireplace, and the window on the shrubbery, its
    latch bright with use. On the air, sometimes, a beating of wings.
    Exits: DOWN Hillingham Hall. Contents: Lucy (the timer), window,
    door, fireplace, black velvet band, garlic staging (P11), Lucy's
    memorandum (after the wolf night, clutched to her breast).
35. **Kingstead Churchyard** — "Kingstead Churchyard". Yews and junipers
    black against the sky, headstones adrift in the grass, and among
    them a lordly death-house of marble: the Westenra tomb. Exits:
    NORTH London Road, IN Westenra Tomb (locked; VH has the key from
    the coffin-man). Contents: tomb door, yew trees, (night) the white
    figure.
36. **Westenra Tomb** — "The Westenra Tomb". Candlelight makes it worse:
    time-discoloured stone, rusted iron, clouded silver-plate, and the
    coffin on its stone shelf. Exits: OUT Churchyard. Contents: Lucy's
    coffin (wooden lid + lead flange: turnscrew and fret-saw, P15), the
    other coffins, VH's kit when the staking is on (stake, hammer).
37. **Piccadilly Steps** — "No. 347, Piccadilly". A high house with a
    stone bow front and steps up to the door; dust crusts the windows,
    and behind the area railings the white scar of a torn-down FOR SALE
    board. London flows past without looking. Exits: WEST London Road,
    IN/UP to Piccadilly House (locked till the locksmith ruse, P17).
    Contents: front door, Green Park bench opposite (scenery; the
    hunters wait here in the ruse).
38. **Piccadilly House** — "The House in Piccadilly". The dining-room of
    an empty mansion, smelling like the chapel at Carfax. Eight great
    boxes; on the table, deeds in a bundle, a clothes brush, a jug and
    basin — the water in the basin reddened as if with blood — and a
    little heap of keys of all sorts and sizes. Exits: OUT Piccadilly
    Steps. Contents: eight boxes (collective), title deeds (READ:
    reveals ALL the lair addresses — the investigation payoff), heap of
    keys, jug and basin, window to the mews (Dracula's exit).
39. **Walworth Lodging** — "A Court off Walworth". A brick court of
    drying-lines and doorsteps; the carter Bloxam lodges here, and will
    remember with his throat what his head forgets. Exits: NW London
    Road. Contents: Sam Bloxam (NPC; beer-and-shillings interview,
    P16).

### 3.4 Act III — the chase and the return (4 new rooms + 3 reused)

```
 [Hotel Room, Varna] ==> [Galatz Wharf] ==> (journals) ==>
 [Camp below the Castle] -- [Castle Courtyard*] -- [Ruined Chapel*] -- [Vault*]
                     \
                      [The Frozen Road]   (* = Act I rooms revisited)
```

40. **Hotel Room, Varna** — "Hotel Odessus, Varna". A shuttered hotel
    room grown small with waiting: maps on the table, the Kukri knife
    whetted daily, and every dawn and dusk the professor's hands making
    passes before Mina's closed eyes. Exits: none (scene advances by
    events: the trance, the telegram). Contents: map of the rivers,
    Bradshaw/timetable, telegram (arrives: "Czarina Catherine reported
    entering Galatz..."), Van Helsing, Jonathan.
41. **Galatz Wharf** — "The Wharf at Galatz". Brown river, tarred
    rope, and the Czarina Catherine warping in; a Scots captain glares
    from the rail at the devil's own luck that blew him here. Exits:
    scene-gated. Contents: Captain Donelson (NPC), bill of lading
    (Immanuel Hildesheim -> Petrof Skinsky -> the Slovaks and the
    river), the map (P19 deduction happens here).
42. **Camp below the Castle** — "Camp below the Castle". A hollow in
    the rock like a doorway between two boulders; snow flurries walk
    the dark like women in trailing garments. Above, far up, the castle
    cuts its jagged line against the sky. Exits: UP the road to Castle
    Courtyard (day only), EAST to the Frozen Road (final morning).
    Contents: the holy circle (P20), fire, Mina (in the circle), the
    horses (die overnight — scripted), field-glasses.
43. **The Frozen Road** — "The Borgo Road". The last light lies red on
    the snow; down the winding road comes a leiter-wagon at the gallop,
    gypsies about it like a river round a stone, and on the cart a
    great square chest. The sun stands a hand's-breadth above the
    peaks. Exits: none — this is the endgame arena (P22). Contents:
    the wagon, the box, the Szgany, Quincey Morris, Seward, Godalming,
    wolves (closing ring, scenery-with-teeth).

Reused Act I rooms in Act III (as Van Helsing): Castle Courtyard, Ruined
Chapel, Vault — same geography, rewritten LDESC variants for winter and
daylight ("You know this place from a dead man's journal you have read
until you dream it").

---

## 4. Objects & puzzles

### 4.1 Master object list

Portable (P), scenery (S), NPC (N), document (D). Dictionary word in
CAPS (6-letter truncation noted where it matters).

| Object | Act | Type | Notes |
|---|---|---|---|
| crucifix (CRUCIF/ROSARY/CROSS/BEADS) | I, II, III | P | The innkeeper's wife's rosary. Wards vampires when held/shown. Harker's is banked at act end; the hunters get silver ones from VH. |
| shaving glass (GLASS/MIRROR) | I | P | In the travelling bag. Reveals no-reflection; destroyed in the scripted shaving scene; leaves a SHARD (P) the player may keep — usable in II to test a face in a doorway (pure flavor + 2 points). |
| hand lamp (LAMP/LIGHT) | I | P | Light source for Dark Passage/Vault. Always lit (oil, no timer — mercy design). |
| gold coins (GOLD/COINS/MONEY) | I | P | From the heap in Dracula's room. Needed for full escape score; narratively funds the journey home. |
| shovel (SHOVEL/SPADE) | I | P | Workmen's shovel in the chapel. The one Act I weapon; scripted glancing blow (P10). |
| letters (LETTER/PAPER) | I | D | Three post-dated letters subplot + the secret shorthand letter (P7). |
| boots (BOOTS) | I | P (worn) | Must be removed to climb (P5). |
| the fifty boxes (BOXES/BOX/CASES) | I | S | Collective; EXAMINE, OPEN one in the vault only. |
| the great box (BOX/COFFIN) | I, III | S/container | Dracula's box in the vault; the same object rides the wagon in Act III. |
| shawl (SHAWL) | II-1 | P | Mina's; rescue puzzle. |
| safety pin (PIN) | II-1 | P | Rescue puzzle; pricks Lucy's throat — the false explanation planted. |
| captain's log (LOG/BOOK) | II-1 | D | The Demeter compressed into ~12 short dated entries; READ twice for full text (paged). |
| phonograph (PHONOG/DIARY) | II-2 | S | PLAY = recap of current goals (the game's LOOK-at-your-notes device). |
| garlic flowers (GARLIC/FLOWER/WREATH) | II-2 | P | Boxfuls from Haarlem; RUB on SASH/DOOR/FIREPLACE, HANG/PUT wreath ON LUCY (P11). |
| silver crucifixes (CRUCIF) | II-2 | P | Issued by VH before the Carfax raid. |
| sacred wafer (WAFER/HOST) | II-2, III | P | In envelopes; the sanctifier. PUT WAFER IN BOX(ES). Guarded verb text: the game never lets you waste it. |
| wooden stake (STAKE) | II-2, III | P | "Some three feet long, charred and sharpened." |
| hammer (HAMMER) | II-2, III | P | Coal-cellar hammer; also the Veresti blacksmith hammer in III (same object, re-described). |
| turnscrew & fret-saw (TURNSC/SAW/TOOLS) | II-2 | P | VH's kit; opens the lead coffin (P15). |
| skeleton keys (KEYS/SKELET) | II-2 | P | Seward's surgical dexterity opens Carfax (P13). |
| labelled key bunch (BUNCH/LABELS) | II-2 | P/D | From Carfax hall; READ = property hints. |
| silver whistle (WHISTL) | II-2 | P | Godalming's; summons the terriers (P14). |
| electric lamp (LAMP) | II-2 | P | Breast-clip lamp for the raid (re-uses light logic). |
| beer & shillings (BEER, SHILLI) | II-2 | P | Interview lubricant for Bloxam (P16). |
| notebook (NOTEBO) | II-2 | D | Renfield's sums; GIVE it back = trust (P12). |
| sugar (SUGAR) | II-2 | P | Renfield currency (P12). |
| flies (FLY/FLIES) | II-2 | P-ish | CATCH FLY in the cell; Renfield currency (P12). |
| memorandum (MEMORA/NOTE) | II-2 | D | Lucy's account of the wolf night. |
| velvet band (BAND/VELVET) | II-2 | S | MOVE/LOOK UNDER = the two punctures. |
| sherry decanter (SHERRY/DECANT) | II-2 | S | SMELL = laudanum (clue the maids were drugged). |
| title deeds (DEEDS/PAPERS) | II-2 | D | In Piccadilly; READ = all lair addresses. |
| heap of keys (HEAP/KEYS) | II-2 | P | Dracula's own keys; unlocks nothing the player needs (he had duplicates) — flavor + proof. |
| kukri knife (KUKRI/KNIFE) | II-2, III | P | Jonathan's; the Piccadilly slash and the killing blow. |
| bowie knife (BOWIE) | III | N-held | Quincey's; the heart blow (NPC action). |
| winchester (WINCHE/RIFLE) | III | P | Carried in the endgame; FIRE/SHOOT covers the gypsy standoff. |
| map & timetable (MAP, TIMETA) | III | D | The deduction puzzle (P19). |
| telegram (TELEGR) | II, III | D | Event carriers. |
| field-glasses (GLASSE/BINOCU) | III | P | LOOK THROUGH = the wagon sighting that starts the endgame. |
| wolf-skin coat (COAT) | III | P (worn) | Cold flavor; WEAR before the camp or VH nags gently. |
| typewriter (TYPEWR) | II | S | Mina's; scenery with heart. |
| brandy (BRANDY) | II | P | Restorative; used on Renfield and after the attack (flavor). |

### 4.2 Puzzle chain (exact solutions, failure text, hints)

Numbered P1-P22. "Hints" escalate: first a nudge in room/NPC text, then
Van Helsing (or the journal) states it nearly outright. No puzzle
requires knowledge outside this document. No unmarked dead ends: every
missable item is either re-obtainable or its absence is warned at the
moment of no return.

**P1. Supper with the Count (tutorial, no-fail).** Arrival night. The
Count serves supper; the game teaches ASK/EXAMINE. ASK DRACULA ABOUT
CASTLE/ENGLAND/WOLVES/HIMSELF each yield voice-bank lines ("Listen to
them--the children of the night..."). At dawn he withdraws. SLEEP (in
bed) advances time. Nothing can hurt you tonight.

**P2. The locked castle (realization beat).** Day 1: trying the great
door → "The bolts draw and the chains come free — and the door is
locked, and the key is gone. The castle is a veritable prison, and you
are the prisoner in it." This sets the act goal. (OPEN DOOR anywhere on
locked doors gives varied, informative refusals.)

**P3. The shaving mirror (scripted scene, survivable always).** Dawn of
Day 2, in the Bedroom, when the player EXAMINEs or USEs the shaving
glass (or on a turn-trigger if they never do): the Count is suddenly
behind you — no reflection; you nick your chin; his hand darts for your
throat and breaks on the touch of the beads. "Take care how you cut
yourself. It is more dangerous than you think in this country." He
flings the glass into the courtyard. Leaves the SHARD in the courtyard
(retrievable Day 3+). Teaches: the crucifix protects you; the Count is
not a man. +5 points for having worn the crucifix (it is worn by
default; removing it beforehand converts this scene to a near-death with
a one-turn escape window — fair, because the game warns when you remove
it: "Something in you clings to it. Are you sure? The old woman's eyes
said: for your mother's sake.").

**P4. The stuck door.** The Ladies' Wing door "rests upon the floor."
PUSH DOOR → "It gives an inch, gritting on stone. Your shoulder aches."
PUSH DOOR again → same +"It wants more than an arm." PUSH DOOR a third
time (or PUSH DOOR WITH SHOVEL any time) → "You set your whole frame to
it. With a shriek of hinges the heavy door grinds back." Hint ladder:
examine door ("not locked — fallen"); after two pushes, "A lever might
spare your shoulder." Required for: brides scene, west-window escape
route knowledge.

**P5. The wall crawl.** At South Landing (or Ladies' Wing window): CLIMB
OUT WINDOW while wearing boots → warned failure: "Your boot-soles skid
on the first stone. You scramble back, heart hammering. Fingers and
toes, like the lizard went — bare ones." REMOVE BOOTS, then CLIMB OUT →
Castle Ledge. On the ledge: any command except NORTH/SOUTH along ledge,
IN at a window, or WAIT gets vertigo flavor; JUMP/DOWN before endgame →
warned: "A thousand feet of moonlight below. At its foot a man may
sleep — as a man. Not yet. Not while Mina waits." (The book's suicide
line, repurposed as a guard.) Hints: the scripted lizard-crawl scene
says "where his body has gone, why may not another body go?"; VH not
present, so the journal voice hints ("Mem., the mortar is washed clean
between the stones — handholds every yard").

**P6. The Count's gold.** In Dracula's room: TAKE GOLD → "You fill your
pockets with coins three centuries cold. If you live, you will need
them." (+5; needed for the best ending text of Act I; without it the
escape still works but the interstitial notes you begged your way home,
-5 from max score.)

**P7. The letters (optional subplot, +5).** Writing/throwing letters:
GIVE LETTER TO SZGANY or THROW LETTER THROUGH BARS (Day 3, Szgany in
courtyard) → that night, scripted: the Count produces both letters,
burns the shorthand one. "Your letters are sacred to me... this other
is a vile thing, an outrage upon friendship and hospitality!" No damage
— but the player who WROTE the shorthand letter to Mina first (WRITE
LETTER) gets +5 and a payoff in Act II (Mina has "the letter that never
came" framed — pure sentiment). Marked optional; no dead end.

**P8. The bolted door trap (fair-death gate).** After Day 3, the great
door stands unlocked once (scripted: the Count offers freedom, wolves
howl in the gap). LEAVE/GO SOUTH → the wolves surge: one-turn window to
retreat (NORTH) with a clear warning; persisting = death ("given to the
wolves, and at your own instigation"). Staying = canonical path.

**P9. The escape climb (act finale).** Conditions: Day 4 after the
scripted Szgany departure ("The door is shut, and the chains rattle;
there is a grinding of the key in the lock... I am alone in the castle
with those awful women."), daylight remaining, boots off. From Castle
Ledge: CLIMB DOWN → three-turn descent sequence, one command each
("keep climbing" prompts; any panic command gets steadying text), then
the act-end interstitial. If the player dawdles until dusk (the game
announces "The sun is dropping toward the western peaks" two phases
early), the brides take the castle interior: being anywhere but the
ledge/descent at nightfall = death scene. Hint ladder: the journal
literally plans it ("I shall scale the wall farther than I have yet
attempted... And then away for home!"); at dusk warning, "now or never."

**P10. The Count in his box (optional, the shovel).** Day 3+, in the
Vault by day: OPEN BOX → the gorged Count, "a filthy leech, exhausted
with his repletion." SEARCH BODY/COUNT → no key; the dead eyes hold
you; you flee a step (moved to Chapel — dramatized refusal, not
punishment). ATTACK COUNT (WITH SHOVEL) → the scripted glancing blow:
"the head turned, and the eyes fell full upon me... the shovel turned
in my hand and glanced from the face, merely making a deep gash above
the forehead." +5 points, and the scar persists to the Piccadilly scene
("we all recognised the Count — in every way, even to the scar on his
forehead" — the game calls back YOUR blow). At night the box is empty
and the vault is lethal after one warning ("the lid lies aside. The box
is empty. Behind you, in the dark of the stair, something breathes like
a man remembering how."). Fair: night entry warned at the chapel.

**P11. Save Lucy (the central Act II timer — winnable).** See section
6.2 for the stage machine. Player actions that matter, per night:
- Night 1 (scripted intro): VH examines Lucy, transfusion #1 happens in
  scene. VH: "There must be transfusion of blood at once." Teaches the
  stakes; garlic arrives at dawn.
- Nights 2-4, the defense checklist in Lucy's Room before dusk:
  (a) CLOSE WINDOW / LOCK WINDOW; (b) RUB GARLIC ON SASH (also accepts
  PUT GARLIC ON WINDOW), RUB GARLIC ON DOOR, RUB GARLIC ON FIREPLACE
  (any two of three suffices; all three = bonus point); (c) HANG WREATH
  ON LUCY (or PUT WREATH ON LUCY / GIVE WREATH TO LUCY).
  Done → safe night text ("Peace in its smell, she says, and sleeps like
  a child."). Not done → a decline stage fires at dawn.
- Night 3 special: Mrs. Westenra threat. If the player has not warned
  her (TELL MRS WESTENRA ABOUT GARLIC → "You explain, gravely, that the
  doctor's flowers are medicine, strange but sovereign; she promises to
  let them be" / also accepted: SHOW NOTE TO MRS WESTENRA using VH's
  note), she removes the wreath and opens the window that night
  regardless of the checklist → stage fires + her heart-death is
  averted in this adaptation only if warned (kindness bonus +3).
- Night 4 special: the wolf. Defense checklist alone is NOT enough; the
  player must also WATCH LUCY (stay in Lucy's Room through the night;
  WAIT accepted). Present: the wolf's head smashes the window — SHOW
  CRUCIFIX TO WOLF or THROW GARLIC AT WOLF drives it off ("the great
  gaunt grey head withdraws; little specks of dust swirl at the broken
  pane, and find no way in"). Absent: catastrophic stage (double
  decline).
- Failure = 3 decline stages before dawn of Day 5: Lucy dies (canonical
  path; the tomb sequence P15 opens). Success (fewer than 3): Lucy
  lives; VH: "The first gain is ours! Check to the King!" (+15, same
  as the staking path — no dominant strategy, two stories).
Hints: VH states every rule as an instruction the first time ("even if
the room feel close, do not to-night open the window or the door");
the phonograph recap lists tonight's checklist; failure text always
names the cause ("the window stood open; the flowers lay in the
grate").

**P12. Renfield, the information vendor.** Renfield trades truth for
life, literally. Mechanic: bring him currency — a FLY (CATCH FLY in his
cell or the study window), SUGAR (Hillingham or asylum kitchen via a
maid — GET SUGAR), or his confiscated NOTEBOOK (in the study drawer;
GIVE NOTEBOOK TO RENFIELD). Each gift unlocks one tier:
1. Fly → the creed: "The blood is the life! The blood is the life!"
   (and the game notes VH's interest — flags the vampire logic).
2. Sugar → the neighbor: "He is at hand. The Master. In the house of
   the chapel, in his boxes of holy earth. Count the boxes, doctor —
   he counts them." (Points the Carfax raid; reveals the earth matters.)
3. Notebook → the warning (late Act II, after the raid): "Don't keep me
   here. You don't know what you do... He can come in only if he is
   asked. The mad and the sleeping ask so easily." (Foreshadows the
   invitation and the Mina attack; also the player's fair warning.)
ASK RENFIELD ABOUT anything gets in-character deflection until the tier
is paid. His lucid plea scene fires on the eve of the attack regardless
(scripted): refusing him is canonical and tragic; the game does not let
you release him (attendants intervene) — the tragedy is fixed, the
UNDERSTANDING is the reward.

**P13. The Carfax door.** Locked, old. UNLOCK DOOR WITH KEYS / PICK
LOCK (with skeleton keys, issued in the kit scene) → "A surgeon's
fingers and a burglar's tools. After a little play, the bolt shoots
back with a rusty clang." Without keys: "Massive oak, iron-bound; your
shoulder is not the instrument." VH gives the kit + the porch briefing
(crucifix, garlic wreath, revolver, lamp, envelope of the Wafer) as a
scripted scene when the raid party forms (after Lucy resolution + tier
2 Renfield or reading the deeds trail).

**P14. The rats.** Entering Carfax Chapel: the count first ("You count
the great boxes: twenty-nine. Twenty-nine, out of fifty."), then eyes:
"a mass of phosphorescence twinkles like stars — the whole place is
becoming alive with rats, multiplying in thousands." Any turn spent
without acting → they close (no damage yet, mounting text). Solution:
BLOW WHISTLE (Godalming hands it over if you ASK GODALMING ABOUT RATS
or automatically on turn 2) → the three terriers arrive and the swarm
melts. Then: PUT WAFER IN BOXES → one command sanctifies the
twenty-nine (the game narrates the hour's work in one paragraph: lid by
lid, "and in each a portion of the Host"). +10. Failure text if you try
to sanctify mid-swarm: "Not with ten thousand eyes watching your
hands."

**P15. Lucy's tomb (only on the Lucy-dies path).** Two visits:
- Night: VH brings you over the low wall, unlocks the tomb, opens the
  coffin (turnscrew, fret-saw through the lead flange): "The coffin was
  empty." Outside, the white figure with a child; SHOW CRUCIFIX →
  she recoils; she slips "through the interstice where scarce a
  knife-blade could have gone." (Player action required: HOLD/SHOW
  CRUCIFIX when she turns to you — warned by VH one turn prior. Failing
  = she touches you: not death, but -3 and VH pulls you back with a
  scar of frost on your wrist. Fair and memorable.)
- Next day, all four: the staking. The game gives Arthur's role to the
  player-as-Seward only if Arthur is absent (he never is): the player's
  commands are supportive ritual — GIVE STAKE TO ARTHUR, READ PRAYER
  (VH's missal), then the strike is narrated in Stoker's own beats
  ("He looked like a figure of Thor..."). Then VH and you: CUT OFF
  HEAD / the game asks once "Steady your hands?" — YES → "We sawed the
  top from the stake, and cut off the head, and filled the mouth with
  garlic. And the holy calm lay like sunshine over the wasted face."
  +15. (All gore kept at the book's own diction.)

**P16. The box trail.** After Carfax: 21 boxes are elsewhere. Leads:
(a) Renfield tier 2 ("he counts them"), (b) the labelled key bunch
(READ LABELS → "Chicksand Street. Jamaica Lane. And one label newer
than the rest: Piccadilly."), (c) canonical interview: go to Walworth,
GIVE BEER TO BLOXAM (or GIVE SHILLING) → "Nine big 'uns to a house off
Piccadilly — a 'igh 'un, stone front with a bow, 'igh steps up. Old
gent took 'is end o' the boxes like they was pounds of tea." Both (b)
and (c) mark Piccadilly on the London Road exits (the deeds inside
later confirm Bermondsey/Mile End, which Godalming and Morris destroy
off-screen — the game says so, keeping the player's count honest:
29 + 6 + 6 + 8 = 49; one missing).

**P17. Piccadilly entry (the locksmith ruse).** The door is respectable
Piccadilly — no skeleton keys in daylight with policemen about.
Solution: bring Godalming and let the title work: ASK GODALMING ABOUT
DOOR / SHOW HOUSE TO GODALMING → scripted ruse: the party waits on the
Green Park bench; a locksmith in a four-wheeler picks it "as such
things are rightly done, and at the time such things are rightly done";
a constable nods; a new key changes hands. "Not a soul took the
slightest notice." IN → the house.

**P18. Piccadilly: sanctify and survive.** PUT WAFER IN BOXES → eight
sanctified (+8). READ DEEDS → full property list (+3; closes the
investigation). Then the trap springs (scripted on the following turn —
Mina's warning telegram arrives first for fairness: "LOOK OUT FOR D.").
Dracula's panther leap through the door. Player has agency in a 3-turn
set piece: ATTACK DRACULA WITH KUKRI (Jonathan hands it over / if
player borrowed it earlier they strike personally) → the coat-slash,
gold and banknotes spilling; SHOW CRUCIFIX / SHOW WAFER → he cowers
back; he crashes through the window and delivers the taunt from the
stable door, verbatim: "You think to baffle me, you--with your pale
faces all in a row, like sheep in a butcher's... My revenge is just
begun!" No action loses the scene (he was always going to flee — VH
says so: "he fear time, he fear want"), but striking and warding each
score +2. The Mina attack has already happened (see 6.3, scripted the
night before); his flight ends Act II.

**P19. Mina's deduction (Act III opener).** In the Varna hotel then
Galatz wharf: the trance (scripted at dawn: "The lapping of water; the
creaking of a chain..."), the telegram, Donelson's testimony, the bill
of lading. Puzzle: READ MAP → the rivers; READ BILL → Skinsky and "the
Slovaks who trade down the river"; then the player must connect: LOOK
UP FUNDU / EXAMINE BISTRITZA on the map, or simply ASK VAN HELSING
ABOUT RIVER after both documents are read → Mina's memorandum composes
itself: "the Sereth is, at Fundu, joined by the Bistritza, which runs
up round the Borgo Pass. The loop it makes is manifestly as close to
Dracula's castle as can be got by water." +5. This unlocks the
three-way split (narrated) and the jump to the camp.

**P20. The holy circle.** At the camp, dusk falling, as Van Helsing:
Mina shivers, strange and quiet. DRAW CIRCLE (also accepted: MAKE
CIRCLE, PUT WAFER ON RING, CRUMBLE WAFER — the parser is generous; VH's
memorandum hints verbatim: "I drew a ring, and over the ring I passed
some of the wafer") → the circle exists. Then the test, one command:
ASK MINA TO COME (or WAIT) → "She rose, and took one step, and stood as
one stricken. 'I cannot,' she said. And I rejoiced: what she could
not, none of those we dreaded could." Night scene: the three sisters
in the whirling snow, "Come, sister. Come to us. Come! Come!" —
inside the circle, nothing can touch you; stepping OUT of the circle at
night = death (warned twice: Mina's hand, then "the snow-shapes
sharpen, gladly"). Skipping the circle before nightfall = the game
draws it for you at the last moment with a -5 and a scare (VH is the
player, but he is also the hint system: his own memorandum nags).
Morning: the horses are dead; the sisters melt toward the castle.

**P21. The castle purged.** By day, up to the courtyard and in through
the broken doors (BREAK DOORS WITH HAMMER → "lest some ill-intent or
ill-chance should close them" — required, else the chapel door swings
shut behind you at a cost of turns). In the chapel/vault: the three
tombs and the great tomb marked only DRACULA. Sequence:
(1) PUT WAFER IN TOMB (the great one) FIRST — banishes him from it
    (+5). If the player stakes the fair sister first, the fascination
    trap fires: "so full of life and voluptuous beauty that I shudder
    as though I have come to do murder... a yearning for delay clogs
    your very soul" — two turns of paralysis text, broken by Mina's
    far-off wail (auto-rescue, -2, and VH scolds himself). Doing the
    Wafer first hardens you (no trap). Hint: the memorandum: "Before I
    began my awful work, I laid in Dracula's tomb some of the Wafer."
(2) STAKE SISTER / KILL SISTERS (each: STAKE then the game completes
    the beheading in one grim sentence; three times or the collective
    KILL SISTERS runs the montage) → "it was butcher work... but then
    the repose, and the gladness, and the crumbling into native dust."
    +6.
(3) SEAL ENTRANCES (PUT WAFER ON DOOR / SEAL DOOR) → "never more can
    the Count enter there, Un-Dead." +5. Act jumps to the road.

**P22. The sunset kill (endgame, timed).** The Frozen Road. A visible
turn-clock in the text: each turn, the sun drops ("a hand's-breadth
above the peaks" → "its rim touches" → "half gone"). Approximately 8
turns of slack; the sequence needs 5 if played cleanly:
1. (scripted) The riders converge; two shouts of Halt; Winchesters
   level. The leader points to the sun and the castle; the Szgany
   whirl forward.
2. STOP WAGON / ATTACK SZGANY → Jonathan's charge: "he jumped upon the
   cart, and with a strength that seemed incredible, raised the great
   box and flung it over the wheel to the ground." (Player IS Jonathan;
   the command accepted is also JUMP ON CART, THROW BOX.)
3. (event) Quincey fights through the knives, "clutching at his side...
   the blood spurting through his fingers."
4. OPEN BOX / PRY LID (with kukri as lever, any phrasing) → "the nails
   drew with a quick screeching sound; the lid was thrown back." The
   Count: waxen, red-eyed; "the eyes saw the sinking sun, and the look
   of hate in them turned to triumph."
5. CUT THROAT / KILL DRACULA / ATTACK DRACULA WITH KUKRI → the double
   blow, verbatim outcome: the kukri shears through the throat as
   Quincey's bowie plunges into the heart — "the whole body crumbled
   into dust and passed from our sight," the look of peace, the scar
   gone from Mina's forehead, Quincey's death speech. +25 → VICTORY
   outro.
Failure: the clock runs out → the sun sets with the lid open → the
FAILURE-AT-SUNSET outro (section 8.4). Any turn wasted gets urgent but
fair text; VH shouts the needed action if the player stalls twice
("The box, Jonathan! The box!" — hint escalation to the end).

---

## 5. NPCs

### 5.1 Count Dracula (Act I: the wandering menace; II-III: set pieces)

Act I behavior — deterministic schedule, not random (testability):
- DAY: in his box (vault). The castle is "safe"; dread is architectural.
- NIGHT: he walks a fixed circuit keyed to the game clock: Library ->
  Dining Room -> Entrance Hall -> Courtyard -> Library... The player
  always gets an arrival line ("A step in the passage, unhurried. He
  has all the nights there are.") one turn before he enters.
- In the room with you: courtly, talkative, chilling. ASK DRACULA ABOUT
  <topic> draws on the voice bank (STUDY.md 1.4): CASTLE, ENGLAND,
  HIMSELF, HISTORY/SZEKELYS, WOLVES, DOORS, MIRROR, BRIDES ("There are
  bad dreams for those who sleep unwisely"), LETTERS. Unknown topics:
  "He turns the question as a man turns a card he does not mean to
  play."
- Lethal ONLY under defined conditions (fair-play contract): (1) ATTACK
  him — one warning ("His hand closes on your wrist like a steel vice,
  and he smiles. 'Not yet, my friend. I have use for you.' Next time he
  will not."), second attack = death; (2) found in Dracula's Room or
  below at NIGHT (warned at the stair); (3) the P8 wolf door; (4)
  nightfall on the final day. Everything else, he toys: he confiscates,
  he quotes, he leaves.
- He never blocks daytime exploration; he IS the reason night matters.

Acts II-III: he appears only in authored scenes (Piccadilly leap and
taunt; the box at sunset), plus traces (the reddened basin, the
white-faced figure at Whitby narrated in documents).

### 5.2 The three brides (Act I timed trap; Act III targets)

Act I: entering the Ladies' Wing at night begins the seduction
sequence: 3 turns of escalating trance text ("honey-sweet breath...
two sharp teeth, just touching, pausing"). Escapes: LEAVE/WEST (turn
1-2), SHOW CRUCIFIX (any turn; they recoil hissing). Turn 3 without
action: the scripted first time, Dracula bursts in ("How dare you touch
him! This man belongs to me!") and you wake in your bed (one-time
rescue, canonical); any later time = death ("To-night is mine.
To-morrow night is yours!" was a promise). At the very end of Act I
they hunt the whole castle interior at dusk (see P9). Act III: the
staking targets of P21, plus the snow-shapes outside the circle.

### 5.3 Van Helsing (the hint system personified)

Present through Act II-2 and III. ASK VAN HELSING ABOUT <anything
relevant> yields, in order: (1) the in-fiction lecture line, (2) on
re-ask, a concrete instruction ("Rub the garlic on the sash, so; every
whiff of air that enter, it must pass the flower."). He reacts to the
player's state: if a defense step is missing at dusk he says which one
("The wreath, friend John. The wreath is not on her neck."). Voice:
STUDY.md Part 3.5/4.1 — inverted clauses, "friend John," "Madam Mina,"
"Gott in Himmel!", King Laugh. He performs the transfusions, the
lecture (scripted scene = rules dump the player can re-hear via PLAY
PHONOGRAPH), the tomb work, and IS the player in Act III's castle
segment (his memorandum voice narrates to itself — the hint system
hinting at itself is the joke that keeps the segment light).

### 5.4 Renfield (information-vending puzzle)

See P12. States: BASE (fly-chasing patter), each gift advances TIER.
Independent scripted beats: the lucid plea (eve of the attack; quotes
from STUDY.md 4.4 — "a sane man fighting for his soul"), and the death
confession (found broken after the attack night; VH's trephine scene
compressed to his dying speech: the rats, "Come in, Lord and Master,"
and why he fought — "it made me mad to know that He had been taking
the life out of her"). If the player earned tier 3, his last line is
to YOU: "I told you, doctor. I did what I could."

### 5.5 Lucy (the timer made flesh)

Warm in Whitby (sleepwalk scene), then the patient. Her room text
tracks her stage (rosy → pale → "the gums drawn back from the teeth")
so the player reads the timer in her face, not in numbers. If lost:
the two-voice deathbed and the Bloofer Lady sequence. If saved: she
appears once more at the Act II close, at the window with color in her
cheeks, waving them off to war — worth the harder path.

### 5.6 The supporting hunters

- **Mina**: Whitby playable; then the record-keeper ("I am the train
  fiend"); then the attacked; then the compass (trances). Never a
  damsel in text tone — the game keeps Stoker's own line close: "she
  has man's brain... and woman's heart."
- **Arthur/Godalming**: the title (locksmith ruse), the terrier
  whistle, the stake arm at the tomb.
- **Quincey Morris**: Winchester advocacy, the Pampas bat story if
  asked, the bowie, the death that names the victory.
- **Seward**: the player's own Act II voice — clinical, doubting,
  honest. His skepticism is the tutorial's permission structure ("I
  am beginning to wonder if my long habit of life amongst the insane
  is beginning to tell upon my own brain").
- **Mr. Swales**: Whitby color + the first death; dialect kept light
  (two or three "aud" words a line, no more — TTS mercy).
- **Mrs. Westenra**: the tragedy switch (P11 night 3).
- **Captain Donelson**: one scene of Scots ("as though the Deil himself
  were blawin' on yer sail").

---

## 6. Timers & danger

### 6.1 The day/night cycle

One global clock per act, driven by a QUEUE'd interrupt; transitions are
always announced in one clean line for TTS:
- "The sun drops behind the western peaks. Night, and the castle wakes."
- "A cock crows, thin and far. Morning. You are safe — as safe as this
  place allows."
Act I: cycle also advances by SLEEP (in the bedroom = safe skip to the
next phase; sleeping anywhere else at night = the brides, with one
warning: "Sleep tugs at you. Not here. His words: haste to your own
chamber; there are bad dreams for those who sleep unwisely."). A soft
turn cap (35 turns per phase) keeps a stalled player moving; two-phase
warnings precede every hard deadline.
Act II: nights are event boundaries (the Lucy stage machine fires at
dusk/dawn); daytime is free investigation. The game states the date in
the journal-header style each morning ("11 September. Morning.").
Act III: the sunset clock at the camp (circle before dusk) and on the
Frozen Road (P22, per-turn sun line).

### 6.2 Lucy's decline (the winnable timer)

A stage counter LUCY-STAGE 0..3. Dusk checks, in order:
window shut? garlic on sash/door? wreath on Lucy? night-3 mother
warned? night-4 watch kept + wolf repelled? Each failed night =
+1 stage (night 4 unwatched = +2). Dawn narration always names the
cause. Stage 3 before dawn of Day 5 = death scene that evening (the
two-voice deathbed) and the tomb branch opens. Under 3 = saved. Both
branches converge on VH's council/lecture scene, which gates the
Carfax raid. There is no way to lose the GAME here — only Lucy, and
the score and the story remember.

### 6.3 The Mina attack (scripted, foreshadowed, not preventable)

Fires on the night after the Carfax raid: Renfield's plea that evening,
the broken body at midnight, the bedroom tableau (kitten-and-saucer
line kept), the Wafer rout, the "Unclean!" and the brand at dawn. The
player cannot prevent it (canon; Renfield's confession explains the
invitation loophole so it lands as tragedy, not cheat). The player CAN
have earned tier-3 Renfield, which softens nothing and explains
everything — the Zork-grade reward here is understanding.

### 6.4 Danger inventory & fair-death policy

Every death is (a) preceded by an explicit one-turn warning or a stated
standing rule, and (b) narrated as the record breaking off, with the
next line offering RESTORE/RESTART/UNDO in period dress ("The journal
ends here. (Type RESTORE to take up an earlier page, or RESTART to
begin the record anew.)").
- Act I deaths: second ATTACK on Dracula; brides (sleep out / linger in
  wing at night / caught at nightfall on the final day / third turn of
  the seduction after the one-time rescue); the wolf door (P8, after
  warning); night vault (after warning); CLIMB DOWN before endgame
  (warned; the JUMP text is a guard, not a death).
- Act II deaths: none by design (the horror is losing OTHERS). The
  churchyard un-dead touch and rat swarm cost points/turns, not life —
  Seward's diary must survive to be the game.
- Act III deaths: leaving the circle at night (two warnings); sunset
  expiring on the Frozen Road (failure outro, not a standard death —
  the game is lost at the finish line, and says so beautifully).
Death in Act I = Harker never escapes (failure outro 8.5 available as
flavor for the "give up" case). Death/failure in Act III = the world
loses (outro 8.4). The design never uses instant undeserved death; the
one "gotcha" (removing the crucifix) triple-warns.

---

## 7. Scoring

SCORE-MAX 250. GLOBAL SCORE via SETG in action routines (Tiny Quest
style). DIAGNOSE reports wounds/fatigue in period voice.

| Points | For |
|---|---|
| 5 | Surviving the mirror scene with the crucifix worn |
| 3 | Forcing the stuck door |
| 5 | Warding the brides with the crucifix |
| 5 | The wall crawl (first reaching Dracula's room) |
| 5 | Taking the Count's gold |
| 5 | Finding the Count in his box |
| 5 | The shovel blow (the scar) |
| 5 | Writing + smuggling the shorthand letter |
| 15 | Escaping the castle (act finale) |
| 3 | Reading the Demeter's log |
| 5 | The churchyard rescue (shawl + pin) |
| 2 | Keeping the mirror shard through Act II |
| 15 | Lucy resolved: SAVED (all defenses) or LAID TO REST (staking) |
| 3 | Warning Mrs. Westenra (kindness bonus, save-path only) |
| 9 | Renfield tiers (3 each) |
| 10 | Sanctifying the 29 boxes at Carfax |
| 2 | The rats routed with the whistle |
| 5 | The box trail (Bloxam or labels to Piccadilly) |
| 8 | Sanctifying the 8 Piccadilly boxes |
| 3 | Reading the deeds (investigation closed) |
| 4 | Striking (2) and warding (2) at the Piccadilly confrontation |
| 5 | The river deduction |
| 3 | The holy circle before dusk |
| 5 | The Wafer in the great tomb (before the sisters) |
| 6 | The three sisters at rest |
| 5 | Sealing the castle |
| 25 | The sunset kill |
| ~9 | Misc. flavor finds (atlas rings, tombstone, laudanum sherry, etc.) |

(Sums to 250 counting the misc pool; exact per-find allocation at build
time.) Ranks (Van Helsing flavored):

- 0-24: Solicitor's Clerk
- 25-59: Journal-Keeper
- 60-99: Believer in Things You Cannot
- 100-149: Pupil of Van Helsing
- 150-199: Sterilizer of Earth
- 200-234: Philosopher and Metaphysician
- 235-250: King Laugh (the full-score rank; VH would approve)

---

## 8. Intro & outro drafts (actual text)

### 8.1 Intro (cold open, TTS-first; ~40 seconds read aloud)

"Third of May. Bistritz. -- The landlady's husband would not speak of
the castle. The landlady wept, and hung her own rosary about your neck.
For your mother's sake, she said, and would not take it back.

Now it is midnight in the Borgo Pass, and the coach has gone on to
Bukovina, glad to be rid of you. A caleche waits where no caleche
should be, drawn by four coal-black horses, driven by a tall man whose
hat brim hides everything but the red of his eyes. The dead travel
fast, a passenger whispered, and crossed himself.

You ride. Blue flames burn small and cold above the treasure-graves of
this country, and once, a ring of wolves closes round the carriage
until the driver sweeps his arm and they fall away like beaten dogs.
You are Jonathan Harker, solicitor, of Exeter. You have papers for a
nobleman to sign. That is all. That is surely all.

The horses stop. Above you stands a vast ruined castle, its tall black
windows empty of light, its broken battlements a jagged line against
the moonlit sky.

DRACULA: The Un-Dead. Based on the novel by Bram Stoker. Type HELP for
guidance. From the journal of Jonathan Harker."

[Then: Castle Courtyard description; the great door opens on the first
KNOCK or WAIT — "Welcome to my house! Enter freely and of your own
will!"]

### 8.2 Outro: FULL VICTORY (Dracula destroyed, Mina freed)

"The sweep and flash of your great knife — and Quincey's bowie, driven
home in the same breath. Before your eyes, almost in the drawing of a
breath, the whole body crumbles into dust and passes from sight. In the
moment of dissolution there is in the face a look of peace, such as you
would never have believed could have rested there.

The sun is gone behind the peaks. The gypsies turn and ride for their
lives, and the wolves stream after them, and the snow is suddenly only
snow.

Quincey Morris is down, his hand pressed to his side, smiling. 'It was
worth for this to die,' he says. 'Look! The snow is not more stainless
than her forehead! The curse has passed away!' And with a smile and in
silence, he dies, a gallant gentleman.

Seven years after, you will bring a boy to this country, a boy with a
bundle of names that links a little band of men together — but the name
you call him by is Quincey. There is no proof of any of it; only a mass
of typewriting, and one word of a great professor's: we want no proofs.
We ask none to believe us.

*** You have won, with a score of [N] out of 250. Rank: [rank]. ***"

### 8.3 Outro: HARKER FAILS TO ESCAPE (Act I death / surrender)

"The door is shut, and the chains rattle; there is a grinding of the
key in the lock. Down the rocky way roll the heavy wheels, and the
chorus of the Szgany dies into the distance.

You are alone in the castle with those awful women. The light fails
early, this far east. Somewhere below, a door you never found opens
without a sound, and a silvery, musical laughter comes up the winding
stair — such a laugh as never came through human lips.

'Your time is not yet come,' he told them once. It has come now.

Here the shorthand journal of Jonathan Harker breaks off. In England, a
schoolmistress will wait for a letter through the summer, and the
autumn, and always. The boxes sail in July, fifty in number, and no one
living knows what they carry.

*** The record ends here. (RESTORE, RESTART, or UNDO.) ***"

### 8.4 Outro: FAILURE AT SUNSET (the haunting one)

"The rim of the sun touches the peaks — and is gone.

In the box, the red eyes open, and the look of hate in them turns to
triumph. The lid you pried up is flung wide from within. What rises out
of the grave-earth does not trouble itself with the men and their
rifles; it looks past them all, to the woman standing where the holy
circle used to hold, and it smiles as a host smiles, welcoming a guest
over a threshold.

Mina does not scream. That is the worst of it. She puts back her veil,
and her forehead is white, quite white, and her eyes are someone
else's, and she says, in a voice like the tingling of glasses when
played on by a cunning hand: 'You yourself never loved; you never
love.'

Snow covers the wagon, the road, the year. In the spring, the peasants
of the pass will nail wild roses over every door, and name three women
walking in the dusk — and a fourth, new, fair, whom none of them
know.

*** The sun set, with a score of [N] out of 250. The dead travel
fast. (RESTORE, RESTART.) ***"

### 8.5 Outro variant: MINA LOST, HUNTERS SCATTERED

(Used if the design later allows a chase-phase collapse; kept as the
third failure register.) "Van Helsing's memorandum ends in the middle
of a word. Seward's diary was found at Veresti, wrapped and addressed,
with no letter inside. Of the launch, the river people say only that a
boat burned at the rapids in the night. And in Exeter, the office of
Hawkins and Harker stands closed, its brass plate gone green, waiting
for a young couple who went abroad on business, seven years ago now,
and are expected daily by no one at all."

---

## 9. Walkthrough (the future test spec)

Canonical full-score-path notes: this walkthrough takes the SAVE-LUCY
branch (the alternate staking branch is listed after). Commands are
numbered; bracketed lines are expected scripted events, not commands.
Dracula's Act I circuit and all timers are deterministic, so this
replays byte-for-byte.

ACT I — CASTLE (Harker)
1. WAIT                      [caleche gone; the great door]
2. KNOCK ON DOOR             [bolts, chains; "Welcome to my house!"]
3. NORTH                     [Entrance Hall; the Count carries the bags]
4. UP
5. WEST                      [Dining Room; supper scene begins]
6. ASK DRACULA ABOUT CASTLE
7. ASK DRACULA ABOUT ENGLAND
8. ASK DRACULA ABOUT WOLVES  ["children of the night" — night wears on]
9. SOUTH                     [Octagonal Room]
10. SOUTH                    [Bedroom]
11. SLEEP                    [Day 1 dawn]
12. EXAMINE BAG
13. TAKE LAMP
14. NORTH
15. NORTH
16. WEST                     [Library]
17. READ ATLAS               [rings: Whitby, Exeter, Purfleet; +1 misc]
18. EAST
19. EAST                     [Upper Passage]
20. DOWN
21. DOWN                     [Entrance Hall]
22. OPEN DOOR                [bolts yield, lock holds: "a prisoner!"]
23. UP
24. UP                       [Upper Passage]
25. UP                       [South Landing]
26. LOOK OUT WINDOW          [the precipice; the view south]
27. DOWN
28. WEST
29. SOUTH
30. SOUTH
31. SLEEP                    [Night 2 falls; safe in bed... dawn scene:]
32. EXAMINE GLASS            [shaving scene: no reflection, the grab,
                              the crucifix, glass flung to courtyard;
                              +5]
33. NORTH
34. NORTH
35. EAST                     [Upper Passage]
36. PUSH DOOR
37. PUSH DOOR
38. PUSH DOOR                [the stuck door grinds back; +3]
39. EAST                     [Ladies' Wing, daylight — safe]
40. EXAMINE TABLE
41. WEST
42. UP                       [South Landing]
43. WAIT                     [dusk announced]
44. LOOK OUT WINDOW          [the lizard-crawl: Dracula down the wall]
45. DOWN
46. EAST                     [Ladies' Wing at night — the brides come]
47. SHOW CRUCIFIX TO WOMEN   [they recoil, hissing; +5]
48. WEST
49. WEST
50. SOUTH
51. SOUTH
52. SLEEP                    [Day 3: Szgany arrive in the courtyard]
53. WRITE LETTER             [the shorthand letter to Mina]
54. THROW LETTER THROUGH BARS [+5; the gold piece goes with it]
55. NORTH
56. NORTH
57. EAST
58. UP                       [South Landing]
59. REMOVE BOOTS
60. CLIMB OUT WINDOW         [Castle Ledge]
61. NORTH                    [along the ledge to the Count's window]
62. IN                       [Dracula's Room; +5]
63. TAKE GOLD                [+5]
64. OPEN CORNER DOOR
65. DOWN                     [Circular Stair]
66. DOWN                     [Dark Passage — lamp needed, carried]
67. SOUTH                    [Ruined Chapel; the fifty boxes]
68. TAKE SHOVEL
69. DOWN                     [Vault]
70. OPEN BOX                 [the Count, gorged; +5]
71. ATTACK COUNT WITH SHOVEL [the glancing blow, the scar; +5]
72. UP
73. NORTH
74. UP
75. UP                       [Dracula's Room]
76. OUT                      [Ledge]
77. SOUTH
78. IN                       [South Landing]
79. DOWN
80. WEST
81. SOUTH
82. SOUTH
83. SLEEP                    [Night 4: "To-morrow night is yours!"
                              Day 4 dawn: hammering, wheels; the Szgany
                              load and go; the door locks forever]
84. NORTH
85. NORTH
86. EAST
87. UP                       [South Landing]
88. CLIMB OUT WINDOW         [boots still off]
89. CLIMB DOWN
90. CLIMB DOWN
91. CLIMB DOWN               [the descent; act ends; +15]
     [Interstitial. From the journal of Mina Murray, Whitby.]

ACT II SCENE 1 — WHITBY (Mina)
92. LOOK OUT WINDOW          [grey sea; the coming storm]
93. DOWN                     [West Cliff]
94. EAST                     [Drawbridge]
95. EAST                     [Church Steps]
96. UP                       [Churchyard; Swales on the seat]
97. TALK TO SWALES           [aud Man whettin' his scythe]
98. READ TOMBSTONE           [George Canon; +1 misc]
99. DOWN
100. WEST
101. WEST
102. UP                      [bedroom; night: THE STORM — the schooner,
                             the dead man at the wheel, the great dog]
103. SLEEP                   [morning]
104. DOWN
105. EAST
106. EAST
107. NORTH                   [Tate Hill Pier; the Demeter aground]
108. READ LOG                [the Demeter's log, compressed; +3]
109. SOUTH
110. WEST
111. WEST
112. UP                      [bedroom; night falls; Lucy's bed empty]
113. TAKE SHAWL
114. TAKE PIN
115. DOWN
116. EAST
117. EAST
118. UP                      [Churchyard: the white figure on the seat,
                             something long and black bending over her;
                             red eyes; it is gone as you cry out]
119. PUT SHAWL ON LUCY
120. PIN SHAWL               [+5; the pin pricks — or did it?]
121. WAKE LUCY               [home through the grey dawn]
     [Telegram. From the diary of Dr. Seward. Purfleet.]

ACT II SCENE 2 — LONDON (Seward)
122. PLAY PHONOGRAPH         [recap: Lucy ill; VH summoned; Renfield]
123. EAST                    [Corridor]
124. NORTH                   [Renfield's Cell]
125. CATCH FLY
126. GIVE FLY TO RENFIELD    ["The blood is the life!"; +3]
127. SOUTH
128. SOUTH                   [Asylum Grounds]
129. SOUTH                   [London Road]
130. WEST                    [Hillingham; VH arrives with you — scene:
                             examination, transfusion #1, the garlic
                             arrives: the rules stated]
131. UP                      [Lucy's Room]
132. CLOSE WINDOW
133. RUB GARLIC ON SASH
134. RUB GARLIC ON DOOR
135. HANG WREATH ON LUCY     [defense complete; dusk; safe night text]
136. DOWN
137. TELL MRS WESTENRA ABOUT GARLIC   [+3; night 3 defused]
138. UP
139. CLOSE WINDOW            [nightly re-check: sash rub persists,
                             wreath persists unless events remove]
140. WAIT                    [safe night 2 passes; morning]
141. DOWN
142. EAST                    [London Road]
143. NORTH                   [Grounds]
144. IN
145. NORTH                   [Renfield]
146. GIVE SUGAR TO RENFIELD  [tier 2: "Count the boxes, doctor"; +3]
147. SOUTH
148. OUT
149. SOUTH
150. WEST                    [Hillingham, day 4]
151. UP
152. WATCH LUCY              [night 4: the flapping; the wolf's head
                             smashes the window—]
153. SHOW CRUCIFIX TO WOLF   [it withdraws; dust motes find no way in;
                             Lucy sleeps; dawn: SHE IS MENDING]
154. DOWN
155. EAST                    [Lucy saved: +15. VH calls the council.
                             THE LECTURE (scripted): the rules, the
                             compact; the kit is issued; +the raid
                             plan. Night.]
156. NORTH                   [Grounds]
157. EAST                    [over the wall with the party; Carfax Lawn]
158. PICK LOCK WITH KEYS     [the rusty clang; +misc]
159. IN                      [Carfax Hall]
160. TAKE BUNCH
161. READ LABELS             [Chicksand, Jamaica Lane... Piccadilly]
162. EAST                    [Carfax Chapel: 29 boxes; the smell; RATS]
163. BLOW WHISTLE            [the terriers; the swarm melts; +2]
164. PUT WAFER IN BOXES      [twenty-nine, one by one; +10]
165. WEST
166. OUT
167. WEST                    [back over the wall; night ends.
                             EVENING EVENT: Renfield's lucid plea —
                             "a sane man fighting for his soul."
                             MIDNIGHT: the attendant's cry—]
     [Scripted sequence: Renfield broken; the confession ("Come in,
      Lord and Master!"); the bedroom door; the tableau; the Wafer
      rout; "Unclean! unclean!"; dawn, the brand. No commands are
      required; any input advances the scenes. From the diary of
      Dr. Seward, the third of October.]
168. SOUTH                   [London Road]
169. SE                      [Walworth]
170. GIVE BEER TO BLOXAM     [nine boxes, the high house; +5]
171. NW
172. EAST                    [Piccadilly Steps]
173. ASK GODALMING ABOUT DOOR [the locksmith ruse; the new key]
174. IN                      [Piccadilly House]
175. READ DEEDS              [every lair; Bermondsey & Mile End are
                             assigned to Godalming & Morris; +3]
176. PUT WAFER IN BOXES      [eight of nine; +8. Mina's telegram:
                             "LOOK OUT FOR D." A key turns softly—]
177. ATTACK DRACULA WITH KUKRI [the coat slashed, gold spilling; +2]
178. SHOW WAFER TO DRACULA   [he cowers, leaps the window; the taunt:
                             "My revenge is just begun!"; +2]
     [VH: "he fear time, he fear want." The trance clue; the Czarina
      Catherine; the act ends. From the journal of Mina Harker.]

ACT III — THE CHASE
179. WAIT                    [Varna: dawn trance — lapping water;
                             days pass in a paragraph; the telegram:
                             GALATZ]
180. READ TELEGRAM
181. WAIT                    [the wharf; Donelson's account]
182. READ BILL               [Hildesheim; Skinsky; the Slovaks]
183. READ MAP
184. ASK VAN HELSING ABOUT RIVER [the deduction: Sereth, Fundu, the
                             Bistritza — "as close to Dracula's castle
                             as can be got by water"; +5; the split.
                             From the memorandum of Van Helsing.]
185. DRAW CIRCLE             [wafer crumbled over the ring; +3]
186. WAIT                    [Mina: "I cannot!" — night: the sisters:
                             "Come, sister. Come to us. Come!";
                             morning: the horses dead]
187. UP                      [Castle Courtyard, winter daylight]
188. BREAK DOORS WITH HAMMER [off their hinges, forever open]
189. IN                      [through the known ways: Ruined Chapel]
190. DOWN                    [Vault — the three tombs; the great tomb:
                             one word, DRACULA]
191. PUT WAFER IN TOMB       [+5; banished from it, Un-Dead, for ever]
192. KILL SISTERS            [the butcher work; the dust; +6]
193. UP
194. SEAL DOOR               [wafer in the entrances; +5]
195. OUT                     [the camp; LOOK: the leiter-wagon far off,
                             racing the sunset. From the journal of
                             Jonathan Harker. The Frozen Road.]
196. STOP WAGON              [the charge; the box flung down; Quincey
                             through the knives, wounded]
197. OPEN BOX                [the nails screech; the waxen face; the
                             red eyes see the sinking sun—]
198. CUT THROAT WITH KUKRI   [and the bowie in the heart; the dust;
                             the peace; the scar gone; Quincey's
                             farewell; +25 — VICTORY OUTRO 8.2]

ALTERNATE BRANCH (Lucy lost — for coverage testing): omit commands
132-135/137/139/152-153 (mount no defense). Lucy dies on schedule;
insert after the council: night vigil at Kingstead (IN TOMB, OPEN
COFFIN [empty], OUT, SHOW CRUCIFIX to the white figure), then next
day GIVE STAKE TO ARTHUR, READ PRAYER, YES — +15 via the staking; the
walkthrough then rejoins at command 156.

---

## 10. Writing style guide (TTS-voiced — binding rules)

1. **Length.** A turn response is at most two short paragraphs; most
   are 1-3 sentences. Scripted scenes may run longer but break on the
   player's ENTER (each beat ≤ 2 paragraphs).
2. **For the ear.** No ASCII art, no maps-in-text, no ALL-CAPS words
   (Z-machine text is spoken; "DRACULA" on the tomb is rendered as:
   On it is one word: Dracula.). No tables, no bullet responses. Em
   dashes sparingly; commas and full stops carry the rhythm. Numbers
   under twenty spelled out.
3. **Register.** Stoker-gothic, present tense for room text, but never
   purple for more than one sentence at a stretch; follow a rich
   sentence with a plain one. The plain sentence lands the dread.
   ("The earth in the box is fresh. Something sleeps on it.")
4. **Period voice.** No anachronisms, no modern idioms, no jokes that
   wink at the player. Wit is allowed in the Stoker registers: Van
   Helsing's inversions, Renfield's logic, Morris's drawl, Seward's
   dryness. Failure text may be playful in-period: "The wall declines
   the interview."
5. **Documents.** READ text is diary-flavored and dated. Long documents
   (the Demeter log) are paged: 8-12 short entries, "The log goes on"
   between pages, never more than ~120 words a page.
6. **Announcements.** Day/night, dates, act headers, and timer warnings
   are single clean lines, always in the same format, so a listener
   learns the game's bell-sounds: "The sun is low." / "Night." /
   "Morning, the eleventh of September."
7. **Quotes.** Dracula, Van Helsing, Renfield, and the brides speak
   Stoker's own lines wherever one exists (see STUDY.md voice banks);
   paraphrase only to fit length. Never invent new powers or rules the
   lecture doesn't state.
8. **Death text.** The record-breaks-off convention (6.4). Never
   mock the player at death; the game's sympathy is the horror's
   fixative.
9. **Sensory economy.** One smell, one sound, or one texture per room
   description beats three adjectives on one noun. The chapel is
   allowed two: it earned them.

---

## 11. Build notes (v3/v8, dictionary, engine mapping)

### 11.1 Scope vs limits

- Rooms: 42 + 2 engine stub rooms (ON-LAKE/IN-LAKE) — fine.
- Objects: ~55 designed + scenery + GGLOBALS' 18 + stubs → est. 120-150
  total, well under 255 even for v3.
- Properties: within v3's 31 (we add SIZE/CAPACITY/VALUE/TVALUE/TEXT as
  Tiny Quest does; no new PROPDEFs needed beyond maybe VOICE for NPC
  topic tables — prefer routine dispatch over properties).
- FLAGS: the engine leaves only ~12 free in v3. We need custom bits:
  night flag can be a GLOBAL (not a flag); Lucy stages a GLOBAL;
  per-object states (garlic-rubbed sash, wreath-on-lucy, circle-drawn,
  tomb-sealed) should be GLOBALs/bit-tables, NOT object flags, to stay
  inside v3. Even so, NPC actors + doors + containers may squeeze us.
  **Recommendation: compile v8 from day one** (`-I zil/engine-v8 -v 8`,
  with the `<VERSION? (ZIP) ...>` line): 512KB, 48 flags, 63
  properties. Cost: no v3 status bar — acceptable; our journal-header
  convention replaces it, and DESC still names rooms for the LLM layer.
  Keep the source v3-clean anyway (both compile) until flags actually
  overflow; the walkthrough must replay identically on both (Tiny
  Quest's suite proves the engine does this).
- Text volume: the novel-flavored prose will dominate; with
  abbreviation compression a game this size lands well under 512KB
  (Zork I itself is ~90KB; we may be 1.5-2x Zork text — fine in v8,
  tight-but-plausible in v3's 128KB; another reason to default v8).

### 11.2 Dictionary (6-character truncation) — collision audit

Safe as distinct: CRUCIF(ix), GARLIC, WREATH, WAFER, HOST, STAKE,
HAMMER, KUKRI, BOWIE, SHOVEL, MIRROR, GLASS, SHARD, LAMP, GOLD, BOOTS,
SHAWL, PIN, LOG, ATLAS, DEEDS, BUNCH, LABELS, BEER, SUGAR, FLY,
WHISTL(e), TELEGR(am), NOTEBO(ok), MEMORA(ndum), TIMETA(ble), CIRCLE,
TOMB, COFFIN, BOX/BOXES (distinct words), WINDOW, DOOR, WALL, WAGON.
Name truncations (document for testers): DRACUL(a), HARKER, WESTEN(ra),
RENFIE(ld), HELSIN(g) (+ synonyms PROFES(sor), DOCTOR, ABRAHA(m) — note
DOCTOR may collide with Seward's title: give Seward SYNONYM SEWARD only
and reserve DOCTOR+PROFES for VH in acts where both appear), GODALM(ing)
(+ARTHUR), QUINCE(y) (+MORRIS), SWALES, BLOXAM, DONELS(on), LUCY, MINA.
Known hazards:
- CHURCH vs CHURCHYARD: same word after truncation — make the
  churchyard rooms respond to CHURCH as scenery and never need the
  noun for movement.
- WOMAN/WOMEN for the brides: WOMEN truncates fine; add SISTER, BRIDES.
- BOX vs BOXES: parser treats separately; give the collective object
  both, the vault box ADJECTIVE GREAT.
- COUNT is both noun (Dracula) and verb-ish player habit ("count
  boxes"): give Dracula SYNONYM COUNT and let EXAMINE BOXES report the
  count — do not define a COUNT verb (engine has one: SYNTAX COUNT —
  check gsyntax; it exists, so COUNT BOXES works natively and COUNT
  alone disambiguates by context; test this early).
- SHOW does not exist in gsyntax: add `<SYNTAX SHOW OBJECT TO OBJECT =
  V-SHOW>` (and PRE- route so SHOW X TO Y with held X). Also new:
  `<SYNTAX ASK OBJECT ABOUT OBJECT = V-ASK>`, `<SYNTAX WATCH OBJECT =
  V-WATCH>`, `<SYNTAX WRITE OBJECT = V-WRITE>`, `<SYNTAX DRAW OBJECT =
  V-DRAW>`, `<SYNTAX SEAL OBJECT = V-SEAL>`, `<SYNTAX CATCH OBJECT =
  V-CATCH>`, `<SYNTAX STOP OBJECT = V-STOP>`, `<SYNTAX PLAY OBJECT>`
  exists (PLAY), TALK exists, KNOCK exists, PRAY exists (nice free
  flavor: PRAY in the chapel/tomb gets a real response), DIG exists
  (shovel flavor), BLOW exists (whistle), RUB exists (garlic on sash —
  RUB is `<SYNTAX RUB OBJECT WITH OBJECT>` in gverbs; add `RUB OBJECT
  ON OBJECT` form), TIE exists, BURN exists (letters), CLIMB exists
  (CLIMB DOWN/OUT forms confirmed in gsyntax), CUT exists (CUT THROAT
  handled via ATTACK synonym routing too), OPEN/CLOSE/LOCK/UNLOCK,
  SEARCH, SMELL, LISTEN all stock.
- HYPNOTIZE not needed (VH acts in scripted scenes).

### 11.3 Timers & events (engine mapping)

- GCLOCK's QUEUE/CLOCKER drive: I-NIGHTFALL (per-phase turn cap),
  I-LUCY (dusk/dawn stage checks), I-DRACULA-MOVE (his Act I circuit,
  every 3rd turn at night), I-SUNSET (Frozen Road per-turn sun line),
  I-BRIDES (Ladies' Wing 3-turn seduction counter). All deterministic;
  NO RANDOM in any puzzle-relevant path (walkthrough must replay
  byte-for-byte; flavor variety can key off turn number parity instead
  of RANDOM).
- SLEEP: implement as a verb that validates location/phase and calls
  the phase-advance routine directly.
- Scene scripts (supper, lecture, Mina attack, Piccadilly leap): a
  SCENE global + room ACTION M-BEG hooks that consume turns and print
  the next beat regardless of input (accept anything, nudge with "the
  night carries you along"), Border Zone style but simpler.

### 11.4 Character switching (engine sketch)

Single ADVENTURER object stays WINNER/PLAYER for the whole game (no
reseat actually required — simplest correct implementation):
```zil
<ROUTINE SWITCH-ACT (NEW-HERE HEADER-STR)
  <ROB ,WINNER ,BANK>          ;"bank the old life's inventory"
  <SETG ACT <+ ,ACT 1>>
  <TELL CR .HEADER-STR CR CR>
  <SETG HERE .NEW-HERE>
  <MOVE ,WINNER ,HERE>
  <FSET ,HERE ,TOUCHBIT>       ;"suppress double-describe if needed"
  <V-LOOK>>
```
If a later need arises for distinct actor objects (e.g., NPC versions
of Harker walking around in Act II while you are Seward), keep the
playable body as ADVENTURER and give "Jonathan" a separate NPC object;
never two candidate WINNERs. This dodges every PERFORM/IT edge case
the AUTHORING notes warn about. Room availability per act: gate exits
on the ACT global (`(EAST TO CARFAX-LAWN IF ACT2-FLAG ELSE "That was
another life, and another country.")`) and/or move whole map clusters'
connecting doors.
- The revisited castle rooms in Act III: same ROOM objects, LDESC via
  ACTION routine branching on ACT (M-LOOK), contents swapped by the
  act-switch routine (boxes gone, tombs present).

### 11.5 Content-side obligations (from AUTHORING)

Provide: GO (banner + intro 8.1, SETG HERE castle courtyard... actually
start in COURTYARD after intro), V-SCORE, V-DIAGNOSE, JIGS-UP override
for the record-breaks-off framing, FIND-WEAPON (return the kukri/stake
contextually or false — combat is scripted, so false + custom ATTACK
handling), GLOBAL SCORE-MAX 250, the WATER/GLOBAL-WATER/WALL stubs,
ON-LAKE/IN-LAKE stub rooms, FLAG-CARRIER with NONLANDBIT, `<DIRECTIONS
NORTH EAST WEST SOUTH NE NW SE SW UP DOWN IN OUT LAND>` first in the
dungeon file, GGLOBALS inserted before the dungeon file, SETG
ZORK-NUMBER 0.

### 11.6 Engine risks & mitigations

1. **Flag pressure (v3)** — mitigated by v8 default; states in globals.
2. **Scene scripts vs parser** — scripted beats must still answer
   sensible commands (LOOK, EXAMINE) mid-scene; test each scene with
   hostile input in the scripted player.
3. **Collective objects** (BOXES, SISTERS): PUT WAFER IN BOXES must not
   fight the parser's plural handling — implement BOXES as one object
   with plural-flavored text; never require addressing an individual
   box except the vault's GREAT BOX (separate object).
4. **NPC-heavy rooms**: the council/lecture rooms hold 5+ actors; keep
   them NDESCBIT during scenes and narrate presence in prose to avoid
   the room-lister reading a phone book.
5. **Two-word verbs** (LOOK OUT WINDOW, CLIMB OUT): confirm gsyntax
   forms early with a spike build; fall back to THROUGH forms if OUT
   preposition fights the parser.
6. **The LLM layer masks bugs**: per AUTHORING, all testing through
   `czil/tests/play.mjs` with the walkthrough above frozen as the
   transcript; the LLM plays only after the scripted replay is green.
7. **Determinism**: no RANDOM on the walkthrough path (11.3). Flavor
   variation keyed to turn parity is allowed because it replays
   identically.
8. **Length of scripted text**: Z-machine TELL strings are unlimited
   practically, but keep beats ≤ 2 paragraphs (style rule 1) — also
   protects the LLM context at play time.

### 11.7 Suggested file layout

```
adventures/dracula/
  dracula.zil      ;"main file, Tiny Quest pattern + V8PATCH line"
  ddungeon.zil     ;"DIRECTIONS, all rooms/objects/stubs, GO"
  dactions.zil     ;"action routines, scenes, timers, V-* verbs"
  dtext.zil        ;"(optional) long document texts: log, lecture"
  walkthrough.txt  ;"section 9, commands only"
  walkthrough-lucy-lost.txt  ;"alternate branch spec"
```
Build: `node czil/dist/czil-compile.mjs adventures/dracula/dracula.zil
-I zil/zork1 -I zil/engine-v8 -v 8 -o dracula.z8`

