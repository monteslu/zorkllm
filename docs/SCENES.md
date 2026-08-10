# Scene descriptions

A text adventure already knows what every room looks like. This document
is about getting that knowledge out of a story file in a structured form,
so it can drive anything that needs to depict a place: illustration,
narration, a map, a summary, an accessibility layer.

The tool is `tools/scene-manifest.mjs`. The idea is one sentence long:
**ask the engine what the player sees, never ask the object tree what is
there.** Everything else follows from why those two answers differ.

## Why the object tree is the wrong source

Every object in a Z-machine game has a parent, so it is tempting to list
a room's children and call that its contents. That list is wrong in two
specific ways, and both matter.

**Hidden objects are present but unseen.** Zork's trap door is defined
as `(IN LIVING-ROOM)` from the moment the game starts - it sits there on
turn one, under the rug, carrying the `INVISIBLE` flag. Moving the rug
clears the flag. Dump the Living Room's children and you get:

    sword, wooden door, brass lantern, trap door, carpet, trophy case

A description built from that list describes a room the player cannot
see yet, and gives away the game's best surprise before they have earned
it.

**Some objects are described, not listed.** The rug carries `NDESCBIT`:
it is real, referenceable, and part of the room's prose, but the engine
never lists it as a separate item. A naive renderer either omits it or
mentions it twice.

The engine already resolves both cases correctly every time it prints a
room, because that is exactly what `LOOK` is for. So the manifest is
built by playing the game and capturing what it prints.

## What the manifest contains

```sh
node tools/scene-manifest.mjs <story file> [walkthrough.txt] [-o out.json]
```

Given a walkthrough, it visits every room that playthrough reaches and
records, per room:

- **`scenery`** - the room's own description, the part that is true
  whenever the player is standing there. This is the scene.
- **`variants`** - alternate descriptions of the same room, captured when
  a state change makes the engine describe it differently (a rug moved
  aside, a passage revealed, a door opened). Each is a distinct depiction
  of the same place at a different point in the story.
- **`occupants`** - lines describing things that happened to be standing
  in the room on a visit: people, animals, dropped items. These change
  constantly and belong to a separate layer, not to the room itself.
- **`dark`** - true when the engine reports the room as unlit. A dark
  room has no derivable description; it looks like darkness.

Splitting scenery from occupants is what keeps the output stable. Without
it, a companion who follows the player around produces a near-duplicate
entry on every single visit ("Toto is here, being a dog about it"), and a
room with four such visits looks like four different rooms.

## Coverage

A walkthrough only reaches the rooms it visits. For the games in
`adventures/` the shipped walkthrough covers most of the map, but not the
optional corners - the manifest is a floor, not a census. Options, in
increasing order of effort: add a second walkthrough that tours the
optional rooms, write brief hand descriptions for what remains, or accept
partial coverage and let the missing rooms fall back to text.

Dark rooms are a deliberate hole. The engine will not describe them and
neither should anything downstream.

## Consistency: style and mood

Accuracy comes from the engine. **Consistency has to be authored**, and
nothing in a story file supplies it - two rooms in the same game will
look like two different artists made them unless something says
otherwise. A `--style` sidecar (see
`adventures/wizard-of-oz/scenes.style.json`) carries that authored part:

- **`style`** - one clause describing medium and treatment, applied
  byte-identically to every scene in the game. This is what makes a set
  read as a set. Vary the scene, never the style block.
- **`negative`** - the standing exclusions: no text, no figures the scene
  does not name, no objects the room does not contain, plus whatever this
  particular story is prone to attracting.
- **`acts`** - the mood arc. A single unvarying style flattens a story
  that is meant to change: Baum's Kansas is deliberately gray, Munchkin
  country is saturated, the Winkie country is menacing. Each act carries
  a `mood` clause layered on top of the shared style.

Acts are assigned by the turn a room was first entered, because visit
order is the only act signal a story file actually carries. That is a
guess, and a good one for a linear story - hand-correct the `act` field
for rooms a walkthrough happens to reach early or late.

**Everything in a style file is authored, not extracted, and the composed
prompt hides that distinction.** The scenery sentence is ground truth
from the engine; the mood clause beside it is somebody's reading. That
matters because mood decides things the game never states - a room whose
description mentions no sky can still come back as a bright sunny day,
purely because an act said so. It is the same class of invention as an
imaginary cave, just wearing better clothes.

The fix is cheap: give every mood a `source` field quoting the passage it
derives from, as `adventures/wizard-of-oz/scenes.style.json` does. A mood
that cannot cite anything is a preference, which is allowed - but label
it, so a reviewer can tell an interpretation from a fact.

One thing this does **not** solve: a recurring subject looking like
itself across rooms. The same white house seen from two sides will drift.
For *characters* the answer is simply to leave them out (see below); for
landmarks, treat drift as a known limitation to be caught in review
rather than something the pipeline guarantees.

## Do not feed the source files in

A room's `LDESC` in the ZIL source is the same text the engine prints -
there is no extra detail hiding in the source, so parsing it gains
nothing. What the source *does* carry is everything a depiction must not
include: exits, flags, action-routine names, and full definitions of
objects that are flagged invisible. Feeding source in adds no signal and
smuggles in the spoilers the manifest exists to filter out.

The same caution applies to the game's own prose more generally. Only the
room's opening block describes the place. Lines announcing what is
present ("Toto is here, being a dog about it") and idle events ("Toto
chases a butterfly and loses") arrive in the same output and are pure
noise for a standing depiction - the manifest separates them into
`occupants`, and they should stay out of the scene.

## Using a manifest to describe a scene

The manifest gives ground truth. Anything that turns it into a depiction
should hold to a few rules, all of which come from the same principle -
**the description may only contain what the room actually contains**:

- **Work from a closed list.** The `scenery` text names everything
  present. Nothing else belongs in the depiction. An invented cave in a
  room with no cave is not a stylistic liberty; it is a lie about the
  world model, and a player who acts on it wastes turns being refused.
- **Depict places, not people.** Use `scenery` and ignore `occupants`
  entirely. This is the strongest single rule here, and it holds for four
  independent reasons: characters wander, so a permanent image containing
  one is wrong from the second visit onward; recurring characters drift
  the most visibly of anything a generator produces, because people read
  faces far more sharply than they read trees; a character is the likeliest
  route for film iconography to contaminate a book-sourced depiction; and
  an empty room lets the player occupy it. Classic adventure illustration
  is nearly all unpeopled places for the same reason.

  The exception is a character the room's own `scenery` names, because
  they are part of the place rather than passing through it: Oz's Forest
  Spring *is* a man of tin rusted mid-swing, and omitting him leaves an
  unexplained clearing. The test is which field the character appears in.
  If they are in `occupants`, leave them out. If the LDESC itself puts
  them there, they belong - and that is also where a review pass should
  look hardest, since a named character is exactly where film iconography
  creeps in.
- **No text in a depiction.** Signage, labels, and lettering are almost
  always rendered wrong, and a room's readable objects are handled by the
  game's own `READ` verb anyway.
- **Keep it plain.** A busy scene invites the player to investigate
  detail that has no game meaning. One clear subject and honest
  atmosphere survive scaling to a phone screen and stay consistent across
  a set.
- **Respect the source, not its adaptations.** For a public-domain novel,
  the book is canon and its films are not - both legally and factually.
  The Wizard of Oz wears silver shoes, and the Witch is not green. Carry
  the adaptation's own contamination checklist (see each game's
  `STUDY.md`) into whatever produces the depiction, and check the output
  against it.

## Cleaning a description for depiction

Room prose is written for someone navigating, so it carries three things
a depiction cannot use: exits ("the road runs on to the west"), non-visual
detail ("and groaning"), and second person ("Munchkins bow to you"). A
regex removes the clean cases and mangles the rest, because the useless
clause is usually welded to a useful one inside a single sentence.

`tools/scene-clean.mjs` does this with a model held to one rule: **it may
only delete and rephrase.** Every content word in the output must already
appear in the input, which is checked mechanically afterwards - any new
word is reported as `introduced` rather than trusted. A cleanup step that
can add things is precisely the failure this whole pipeline exists to
prevent, so it is not enough to ask a model nicely; verify it.

Worked examples, all three of which defeat a regex:

    in   Yellow bricks run straight and true between dainty blue fences,
         past round blue houses with domed roofs. Munchkins bow to you
         from their fields. The road runs on to the west; a blue fence
         borders a cornfield to the south.
    out  Yellow bricks run straight and true between dainty blue fences,
         past round blue houses with domed roofs. Munchkins bow from
         their fields.

    in   Beside a half-chopped tree stands a man made entirely of tin,
         his axe lifted over his head, perfectly still. And groaning.
         A little spring rises clear and cold among the trees. The
         cottage lies back to the south.
    out  Beside a half-chopped tree stands a man made entirely of tin,
         his axe lifted over his head, perfectly still. A little spring
         rises clear and cold among the trees.

Note what survived: the fence and the cornfield are gone from the first
because they were named only as directions, while the blue fences the
road runs between stayed. The tin man stayed because the LDESC puts him
there; his groaning did not, because it is a sound.

## Keying artifacts to rooms

Room *names* are not unique - Zork has two rooms both called "Forest" -
so anything stored per room (an image, a recording, a note) must be keyed
by something stable. The manifest assigns a sequential `id` per story
file, which is stable for a given build. If a story file is rebuilt with
rooms added, regenerate the manifest and re-key.

A per-game sidecar directory alongside the story file keeps this tidy and
lets a story with no sidecar degrade cleanly to text:

    mygame.z8
    mygame.scenes.json
    mygame.art/1.webp, 2.webp, ...

## Content boundaries

Only ship depictions of stories you have the right to distribute. The
adaptations in `adventures/` are built from public-domain novels, so
their scene descriptions and any artwork derived from them are yours to
ship. A story file a user supplies is theirs; generate locally if you
like, but it is not part of the package.
