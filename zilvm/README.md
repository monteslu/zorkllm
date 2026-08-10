# zilvm - running ZIL source directly

An interpreter for ZIL source, so a game's structure survives to runtime
instead of being compiled away. See [../docs/ZILVM.md](../docs/ZILVM.md)
for why and for the full plan.

Built additively: nothing here is on the path of a player's game yet.

## Where it is

- **`differ.mjs`** - the acceptance gate, built first. Drives two engines
  over identical commands and reports the first divergence with the
  command that caused it. Backends are pluggable; today both are the
  Z-machine, so it proves itself and the games' determinism under a fixed
  seed. `--selftest` includes a control that must fail.
- **`src/load.c`** - stage 1. Links czil's front end (never copies it) and
  loads a whole game from source, keeping the names the compiler discards.

## Try it

```sh
node zilvm/differ.mjs --selftest          # harness + the control that must fail
node zilvm/differ.mjs --game dracula      # 218 commands, byte-identical

make -C czil libczilfront.a
cc -std=c11 -Iczil/include zilvm/src/load.c czil/libczilfront.a -o zilvm/zilvm-load
./zilvm/zilvm-load zil/zork1/zork1.zil --rooms
```

## Why this already matters

The compiled story file assigns `NORTH` a property number and forgets the
name. Recovering that mapping from bytes took four attempts over one
session, three of which were wrong in ways that looked right - one told a
player "the way out is north" while standing on a ship's deck whose only
exit was down.

From source it is one line of output:

```
room DECK    exits: DOWN WEST LAND OUT EXIT
```

## Stage 2: the queryable world

`src/world.c` lifts czil's compiler-shaped model into a runtime one -
rooms, exits, flags and vocabulary with every name intact - and exports it
as JSON so a JS host holds the same structure the C runtime does.

```sh
./zilvm/zilvm --summary zil/zork1/zork1.zil
./zilvm/zilvm --room LIVING-ROOM zil/zork1/zork1.zil
./zilvm/zilvm --json zil/zork1/zork1.zil > zork.json
```

Exits keep their meaning rather than becoming a property whose byte length
you must interpret:

```
LIVING-ROOM (Living Room)
  action  LIVING-ROOM-FCN
  exit    EAST   -> KITCHEN
  exit    WEST   -> STRANGE-PASSAGE if MAGIC-FLAG
  exit    DOWN   -> computed by TRAP-DOOR-EXIT
```

The last two lines are the point. `WEST` is gated on a named global, and
`DOWN` is the hidden trap door - computed by a routine, so its destination
genuinely cannot be read statically. From bytes those are indistinguishable
from each other and from a refusal string; here they say what they are.
