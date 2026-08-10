# Adventures in progress

Five classic public-domain novels studied and designed as text adventures
for this engine (czil compiler + the Zork engine files in `zil/`), chosen
for fame, film pedigree, and how naturally they decompose into rooms,
objects, and puzzles.

Each directory holds:

- `STUDY.md` — deep study notes from a full read of the novel: locations
  with atmospheric quotes, characters with reusable public-domain dialogue,
  object inventories, mechanics as the book states them, timelines.
- `DESIGN.md` — a complete buildable game design: act structure, full
  room-by-room map, every puzzle with its solution, NPCs, timers, scoring,
  drafted intro/outro text, a start-to-victory walkthrough (the future test
  transcript), a TTS-first writing style guide, and build notes against the
  z-machine limits.

The raw novel texts are not committed; run `./fetch-books.sh` to download
them from Project Gutenberg.

| Game | Rooms | Puzzles | Structure |
| --- | --- | --- | --- |
| treasure-island | 30 | 17 | Benbow heist, voyage, open island hunt |
| dracula | 42 | 22 | Castle escape, Whitby/London hunt, race home |
| monte-cristo | 40 | ~25 | Frame-up, Chateau d'If, treasure, four revenge capers |
| alice | 26 | 17 | Size-mechanic picaresque to the garden and trial |
| wizard-of-oz | 44 | 31 | Companion-driven road quest, Witch campaign, journey south |

All in-game text follows the TTS rule: turn responses of at most two short
paragraphs (usually less), longer prose only in intros and outros, nothing
written for the eye that can't be read aloud.
