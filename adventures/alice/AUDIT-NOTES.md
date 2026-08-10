# AUDIT-NOTES: triage of `tools/audit-game.mjs` dead-end findings

`node tools/audit-game.mjs adventures/alice/alice.z8 adventures/alice/walkthrough.txt --verbose`

The audit flags a room whose description never names a direction out. The
player's correct instinct when stuck is LOOK; if LOOK does not name a way out,
LOOK cannot help them. That is a real bug class — it is how a player got
stranded on the opening deck of Monte Cristo — and this game had eight of them.

Opening run: 10 findings. After triage: **3 findings, all deliberate**, listed
at the bottom with reasons.

---

## Fixed (8)

Each of these was confirmed by playing to the room at the right size and
typing LOOK, not by reading source. In every case a player who was doing
everything right still had no way to learn where to go.

| Room | Was | Now |
|---|---|---|
| Under the Hedge | hole "gapes under the hedge"; never says the way in is DOWN | "a large rabbit-hole going straight down... The field lies south." |
| Tidy Little Room | no exit named at all | "The way out is down the stairs and out the front door." |
| Mushroom Clearing (3 variants) | east tunnel never named in any variant | "The bramble tunnel runs back east." |
| Duchess's Doorstep | never named the crossroads or the door | "The door leads in; the crossroads lie east." |
| Duchess's Kitchen | never said OUT | "The door out leads east." |
| Mad Tea Table (2 variants) | named the well but not that it is DOWN, nor the path west | "an old stone well goes down, and a path leads west" |
| Treacle Well | never said UP | "The bucket rope goes back up." |
| Mock Turtle's Rock | no exit named | "The ledge runs back west." |
| Riverbank | the rabbit's exit is announced in a scripted line that scrolls away; LOOK never named north | "A hedge runs along the field to the north." |
| Thick Wood (LARGE variant) | named no exits at all — and this is the state the mushroom overshoot drops you into | "You could climb up into the treetops, or walk north or south" |
| Above the Wood | named southeast/southwest/south as *scenery*; the only real exit, DOWN, was unstated | "The only way from here is back down into the wood." |

The Thick Wood and Above the Wood entries are the ones I would have missed by
inspection. Thick Wood *does* name its exits at SMALL and at NORMAL — the size
variant a player lands in after the serpent-neck overshoot was the one that
named nothing. Above the Wood is worse: it was full of compass words, which
reads like directions and is actually a view. A player could stare at
"southeast... southwest... far south" and never guess the answer was DOWN.

---

## Deliberate (3)

**Hall of Doors** — the little door is behind a curtain and passable only at
SMALL; the mouse-hole exists only at SMALL. The concealment IS the puzzle, and
the room does name SOUTH (whence you came) in the passage that leads to it.
Once the curtain is drawn the description names the little door permanently.

**Falling** — not a room the player can act in beyond taking the jar; the fall
resolves itself in three turns no matter what. There is no exit to name and no
way to be stranded.

**Court of Hearts** — the trial has no exits by design ("Silence in the
court!"). It ends by script, either on the player's "Stuff and nonsense!" or,
if they dawdle, on the King's pardon. Naming an exit would be a lie.

---

## What the audit could not see

Two of its ten findings were artifacts of how it captures room text
(`entry.text ||=` keeps only the *first* line-1 match, so a room re-entered by
a scripted `GOTO` can be recorded as an object listing — "There is a little bit
of dead stick here."). Thick Wood at SMALL and Duchess's Doorstep were both
already correct at the time they were flagged.

That is not a complaint about the tool: a check that reads only the game's own
text will always need a human to judge the findings, and its false positives
cost minutes while the eight true positives were real player-stranding bugs.
The right posture is the one the tool's own header takes — candidates, not
proven bugs.

But it is worth recording the limit, because it means **a clean audit run is
not proof**. The audit sees only rooms the walkthrough visits, and only the
first description it captures for each. Size-variant rooms have descriptions
the audit will never see; I found the Thick Wood LARGE bug by playing to it
deliberately, not from the report.
