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

## Using a manifest to describe a scene

The manifest gives ground truth. Anything that turns it into a depiction
should hold to a few rules, all of which come from the same principle -
**the description may only contain what the room actually contains**:

- **Work from a closed list.** The `scenery` text names everything
  present. Nothing else belongs in the depiction. An invented cave in a
  room with no cave is not a stylistic liberty; it is a lie about the
  world model, and a player who acts on it wastes turns being refused.
- **Depict the room, not the moment.** Use `scenery` for the standing
  image and treat `occupants` as optional overlay. A permanent
  illustration containing a character who wandered off is wrong from the
  second visit onward.
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
