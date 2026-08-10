# Adapting a novel into an adventure

AUTHORING.md teaches the mechanics: ZIL, the engine files, the compiler.
This document teaches the other half - how to get from a large public
domain story to a design an agent (or a person) can actually build. It
is the distilled process behind the games in `adventures/`, written so
an LLM can follow it for a new book.

The pipeline is three phases with a hard artifact between each:

    book.txt  ->  STUDY.md  ->  DESIGN.md  ->  playable .z8

Never skip a phase and never merge two. A design written without a
study invents details the book contradicts; a build started without a
complete design stalls the moment the first puzzle needs a decision
nobody made.

## Phase 0: Choosing a book

What makes a novel adaptable, in rough priority order:

1. **Spatial structure.** The story visits places that connect: an
   island, a castle, a road, a house of rooms. If you can sketch the
   map from memory, the book wants to be an adventure. Interior novels
   (the drama happens in conversations or heads) fight the medium.
2. **Objects that matter.** Books where physical things drive the plot
   (a map, a potion, a lamp, a stake) hand you puzzles. The classic
   test: could a character solve a chapter's problem by USING something?
3. **A goal statable in one sentence.** Find the treasure. Escape the
   castle. Get home. The parser player needs to know what winning is.
4. **Fame.** Players forgive an adaptation's compressions when they
   already love the shape of the story - and famous scenes are free
   design (players WANT the apple barrel, the trial, the bucket of
   water).
5. **Rights hygiene.** The BOOK being public domain does not make its
   FAMOUS FILM public domain. Design strictly from the text: silver
   shoes, not ruby; the book's own incantations and iconography. Keep a
   FILM TRAP checklist in the study of every detail popular memory gets
   wrong, and audit the finished text against it.

## Phase 1: Study (STUDY.md)

**Read the actual book.** All of it if it fits in a few hundred
Read-tool calls (anything under ~200k words); for doorstops, close-read
every chapter the game will dramatize and skim the rest for voice.
Training-data memory of a classic is a summary contaminated by its
adaptations - the study's whole value is SPECIFICS: what the room
actually contained, what the character actually said, what order things
actually happened.

Harvest into STUDY.md, with page-of-text quotes for everything:

- **Locations** as they appear, with the sentences that give each its
  atmosphere. These quotes seed room descriptions later.
- **Characters** with voice notes and verbatim reusable dialogue. The
  book's dialogue is public domain gold - a game that can quote the
  Cheshire Cat or Long John Silver at the right moment feels authentic
  in a way paraphrase never does.
- **Objects**, every physical thing a character touches that matters.
  This list usually IS the puzzle inventory.
- **Mechanics as the book states them.** The rules the story runs on:
  how vampires are repelled, what each size change enabled or blocked,
  the exact terms of the three wishes. Quote the passages - these
  become game systems, and the book's own version is always more
  interesting (and more defensible) than the folklore version.
- **Timeline** of beats, chapter by chapter, brief.
- **Iconic scenes** - the moments any player who knows the story will
  arrive expecting. This is the checklist fidelity is measured against;
  everything else is negotiable.

## Phase 2: Design (DESIGN.md)

One rule above all: **fun first, fidelity as fuel.** Compress the slow
middle, reorder freely, invent connective tissue - but hit every iconic
scene, in the book's voice. A four-hour game that FEELS like the whole
novel beats a faithful slog. Specific moves that worked:

- **The book's rules become the mechanics.** Don't bolt Zork puzzles
  onto the story; promote the story's own logic. Garlic on the window
  sash is a checklist timer. The mushroom's two sides are a portable
  size toggle. The Golden Cap's three commands are a scarce resource.
  If the study did its job, the mechanics are already written.
- **Spatialize the social.** When a stretch of book is conversations
  and scheming (the revenge half of Monte Cristo), convert each thread
  into a compact caper: rooms, evidence as carryable items, a
  confrontation gated on what you hold. Information wants to be an
  object: letters, ledgers, journals, telegrams.
- **The player does what the book's hero did** - but as a puzzle, not a
  cutscene. The best moments let the player CONCEIVE the famous plan
  (the sack swap, the water bucket) rather than watch it. Where the
  book's hero was told the answer, hide the telling somewhere
  examinable.
- **Structure picaresques with a spine.** Episodic books (Alice, Oz)
  need a stated goal early, a through-line character to chase, and a
  finale where collected things pay off. Quests-for-residents gating a
  destination is a reliable spine.
- **Character switching and companions are engine-supported.** The
  parser attributes commands to WINNER/PLAYER - reseating them (or
  act-gating a single adventurer with journal-header narration, which
  needs no engine tricks at all) supports multi-protagonist books.
  Companion NPCs with addressed commands ("WOODMAN, CHOP TREE") plus
  auto-solve grace periods make a found-family story playable without
  ever soft-locking a scene.
- **Deaths and dead ends are content.** Write them in the book's voice,
  make them fair (warned, or free to retry), and mark every
  intentionally losable state. Design the failure outros with as much
  care as the victory - for a forgiving book (Alice), absurdist failure
  text replaces death entirely.

DESIGN.md must contain, at minimum: vision and tone; act structure; the
complete map (every room: name, 1-3 sentence ear-first description,
exits, contents); every object and every puzzle WITH ITS SOLUTION,
required verbs, failure text, and hints; NPC behavior specs within the
Zork-actor complexity ceiling; timers and the death policy; scoring
with themed ranks; drafted intro and outro text (all endings); a
complete numbered start-to-victory walkthrough; a writing style guide;
and build notes (object/flag/text budgets, dictionary collisions, new
verb syntax needed).

Two quality gates before calling a design done:

1. **Solvability audit**: walk the walkthrough on paper. No consumable
   needed twice, no gate key losable, no unmarked unwinnable state.
2. **Implementability test**: could someone build this WITHOUT the
   book? If any puzzle or scene still needs the novel to disambiguate,
   the design isn't finished.

## Phase 3: Build

Covered mechanically by AUTHORING.md. **Read [ENGINE-NOTES.md](ENGINE-NOTES.md)
before writing any game logic** - it is the distilled trap list, ZIL idiom
set, and process order from five shipped adaptations, and several of its
entries cost a full day each to learn. The process rules that matter:

- **Skeleton first.** All rooms, descriptions, exits - compiling and
  bootable - before a single puzzle. Then implement act by act,
  compiling and PLAYING after each increment. Never write more than a
  few hundred lines between compiles.
- **Spike the risky syntax early.** Any new verb form the design needs
  (ASK X ABOUT Y, addressed companion commands, bare-word answers)
  gets proven in the skeleton before content depends on it, with the
  design's fallback used if the parser fights.
- **Deterministic critical path.** No RANDOM between the player and
  victory. The reward: the full walkthrough replays byte-identically,
  so the frozen transcript (tinyquest's `expected-transcript.txt`
  pattern) becomes the game's regression test forever.
- **A self-contained verify script** that loads the .z8 in the JS
  interpreter, replays walkthrough.txt, and asserts the victory text
  and final score. That script is the acceptance gate; "it compiled"
  proves nothing.

## The build checklist

Design rules that cannot be run do not get followed - all five briefs said
"no unmarked dead ends" and all five games shipped rooms that name no
exit. So the checklist is tooling, not prose:

```sh
node tools/audit-game.mjs  --all      # rooms naming no exit; unspeakable destinations
node tools/audit-mlook.mjs            # M-LOOK overrides that dropped an exit sentence
node tools/audit-reach.mjs  --all     # unreachable rooms (static maps only)
node adventures/<game>/verify.mjs     # walkthrough + wanderer assertions
```

Per game, before calling it done:

1. The walkthrough passes and asserts no parser-failure string appears.
2. The score table sums to SCORE-MAX **along a single path** - two games
   shipped totals that counted mutually exclusive branches, so no
   playthrough could reach the stated maximum.
3. A wanderer test exists, in both typed-junk and unparseable-input
   variants, and has been proven able to fail.
4. Audit findings are triaged and the deliberate ones documented with a
   one-line reason.
5. Rebuild from source and `cmp` - the story file must reproduce
   byte-identically.

## Writing for the ear

All of it - rooms, responses, deaths - may be spoken by TTS:

- Turn responses: at most two short paragraphs; most should be one to
  three sentences. Intros and outros may run longer (they're set
  pieces); scene transitions can breathe.
- Nothing that only works visually: no ASCII art, no typography jokes,
  no ALL-CAPS emphasis, no maps-as-text. If a book gag is visual (the
  mouse's tale), design an ear-version.
- Read every drafted paragraph aloud in your head. If a sentence needs
  its punctuation to be understood, rewrite it.

## Atmosphere has a context cost

A literary adaptation prints far more text per turn than Zork does - richer
room descriptions, longer scene beats, a bigger dictionary - and that text
lands in the LLM's context window every turn. Measured across the five
games here: ~3.5k tokens of system prompt (the dictionary dominates) and
roughly 3x Zork's room text, which puts the practical floor at **16k
context** for any model. Below that the window evicts every second turn and
the model stops being able to hold a puzzle in mind. A full walkthrough of
these five costs 17k-25k tokens; a real player wanders, so **32k is the
comfortable target** for an uncompacted exploratory game.

This is a consequence of the design choice, not the engine, so it belongs
in the design: state the game's context requirement in DESIGN.md alongside
the story-file target. Prose written for the ear is worth its cost - just
know the cost exists, and do not also pay it in a needlessly large
dictionary.

Two more findings from playtesting adaptations through an LLM front end:

- **Every room's description must name a way out.** This is the single
  most common defect found across five finished games, and it is invisible
  to a walkthrough because the author knows the route. The player's
  correct instinct when stuck is LOOK; if LOOK names no direction, LOOK
  cannot help them. Exceptions are legitimate and should be deliberate: a
  scripted scene, a room you genuinely cannot leave yet, or an impasse
  whose refusal text names the answer ("There is a button beside it, for
  a bell"). The rule is not "always name an exit" - it is *never leave a
  player with no way to learn one*.
- **An NPC must not name a place the parser cannot hear.** "Come to the
  counting-house" is a dead end the moment COUNTING is not a dictionary
  word. Anything the game tells the player to do, the game must accept.
- **A timer should punish failing to solve the puzzle, not failing to
  walk fast enough afterwards.** Every countdown has a window between
  "solved it" and "reached safety" that should be unkillable. One game's
  wanderer test died on the bridge one move from safety, following the
  game's own hints.
- **Scripted openings strand non-ideal players.** Zork drops you in a free
  world where any input does something; a plotted novel wants Act I to
  happen in order. A player typing natural chaos may never produce the one
  command the script waits for. Give every scripted sequence an escalating
  nudge and then an automatic resolution, or the story simply never starts.
  Then write the wanderer as a permanent test: a walkthrough of nothing but
  junk that must still reach the next act.
- **Timed beats starve behind an LLM front end.** The parser clock only
  ticks on a *successful parse*, and natural-language play produces far
  fewer than typed play: measured over 50 chatty inputs, a third never
  became a command at all (the translator answered them conversationally)
  and many of the rest bounced off the parser, yielding roughly **one clock
  tick per three player inputs**. Any timer tuned against typed commands
  will fire three times later than intended, or never. Tune against a real
  LLM transcript, and prefer beats keyed to player readiness over turn
  counts.
- **Advice needs a bigger model than translation does.** Below roughly 4B a
  model translates well but invents world facts when asked to coach. That
  is a player-facing quality decision, not an engine one.

## Calibration

The five shipped designs, for scoping a new one: 26-44 rooms, 17-31
puzzles, 55-95 objects, 100-400 points, 113-198 command walkthroughs.
That's roughly half a Zork I per game - about the most game a single
sustained build pass can verify, and about the most story a player can
hold in their head from a TTS voice. When in doubt, cut rooms before
cutting responsiveness: a small world that answers everything beats a
large one that shrugs.

Target v8, always (it's the compiler default for new games): the 128KB
v3 text ceiling is the first wall every text-rich adaptation hits, and
book adaptations are text-rich by nature.
