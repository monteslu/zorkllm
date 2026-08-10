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

All five are **complete, playable, and verified**: each rebuilds
byte-identically from its committed source, and each ships a `verify.mjs`
that replays its walkthrough and asserts the victory text, the final
score, and that no parser-failure string appears anywhere in the
transcript.

| Game | Rooms | Objects | Walkthrough | Score |
| --- | --- | --- | --- | --- |
| treasure-island | 32 | 103 | 119 commands | 350/350 |
| dracula | 45 | 146 | 218 commands | 204/210 |
| monte-cristo | 43 | 145 | 195 commands | 400/400 |
| alice | 29 | 121 | 135 commands | 100/100 |
| wizard-of-oz | 46 | 117 | 187 commands | 250/250 |

```sh
node adventures/alice/verify.mjs          # replay + assert
node src/cli.js adventures/alice/alice.z8 # play it with an LLM
```

Each game also carries `LESSONS.md` (what the build taught, for the next
adaptation) and `BUILD-ISSUES.md` (engine defects and design adaptations).
The cross-cutting distillation of all five lives in
[docs/ENGINE-NOTES.md](../docs/ENGINE-NOTES.md).
