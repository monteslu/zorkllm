# Lessons from building THE COUNT OF MONTE CRISTO

Written for the next person adapting a different novel onto the zorkllm
toolchain (czil + `zil/zork1` + `zil/engine-v8`). You have a design doc
and no scar tissue; this is the scar tissue.

Engine *defects and constraints* are in `BUILD-ISSUES.md` with the exact
symptom and fix. This file is the part that generalizes: idioms that
worked, dead ends, where the design fought the implementation, and how to
sequence the work.

The short version, if you read nothing else:

1. **A walkthrough proves the game is completable, not that it is
   survivable.** This is the finding I would most want the next person to
   have. See §0 — it is first because it cost a real player the game while
   every test was green.
2. **Audit your vocabulary for adjective/noun collisions before you write
   a line of action code.** In v8 a word that is both is unusable as a
   noun, silently. One five-line shell command finds them all; finding
   them late costs a day.
3. **Conversation topics go in `GLOBAL-OBJECTS`, and the cast gets retired
   at every act boundary.** That combination is the whole ASK/TELL system.
4. **Preactions are per action, not per syntax line.** Adding a syntax
   line does not escape the stock preaction that will veto it.
5. **`VERB?` takes action names, not verb words.** `<VERB? PULL>` does not
   compile; PULL's action is MOVE.
6. **Compile and replay after every scene.** The engine's error messages
   are your test suite, and a scripted replay of the whole walkthrough
   takes two seconds.

---

## 0. The walkthrough proves completable, not survivable

This game shipped at 400/400 across 195 commands, with four branch tests,
a frozen transcript and a clean verify. A real player then opened it,
typed eight reasonable things on the opening screen, found no way off the
ship, and quit at turn three.

```
DROP ANCHOR          -> "Anchor under sail? ... Furl first."
PICK UP ANCHOR       -> same
TALK TO MORREL       -> "Come to the counting-house when she is squared away."
GO TO COUNTING HOUSE -> "That sentence isn't one I recognize."
LOOK                 -> a description that never says the quay is WEST
DEBARK               -> "I don't know the word 'debark'."
LEAVE SHIP           -> "That is a subject, not a thing."
LEAVE BOAT           -> "You can't see any boat here!"
```

Every one of those is a sensible thing to type. The walkthrough could
never have caught any of it, because **I wrote the walkthrough, so it
encodes the answer I already knew.** `WEST` is in it at line 6 and the
question "how would a stranger find WEST?" never came up.

Three distinct defects, and the third is the general one:

**(a) The room named no exit.** The Deck's description mentioned "the
quay" but never said the quay was west. Mentioning a *place* is scenery;
a player can only act on a *direction*. Every other Act I room named its
exits properly, which made this room the outlier and made it invisible to
me — I had read the good ones and generalised.

**(b) An NPC directed the player somewhere unspeakable.** Morrel says
"come to the counting-house" and COUNTING was not in the dictionary. An
NPC instructing the player in words the parser refuses is a dead end by
construction, and it is worse than silence: it actively spends the
player's remaining patience on a phrasing that cannot work.

**(c) The refusal named no action.** `"The ship is not yet at her rest.
She is your charge before she is your triumph."` is good prose and useless
instruction. It says the gate is closed; it never says what opens it. My
own style guide (DESIGN.md §10 rule 6) says *"Every 'you can't' says why
in-world and points somewhere"* — I wrote the rule and then broke it on
the game's very first gate. It now reads:

> She is still under way, and a captain does not step ashore off a moving
> ship. Furl the sails first, and then let the anchor go.

That single sentence is the difference between a player who continues and
a player who quits.

### The fix: a wanderer test

`walkthrough-wanderer.txt` contains **no part of the intended solution**.
It opens with that player's session verbatim, continues with scenery,
junk and verbs the parser rejects, and then does what the game's own
refusals tell it to. `verify.mjs` asserts it reaches Marseilles Quay,
with at least three inputs of headroom, without dying, and **without
scoring more than 15** — that last check is what stops the wanderer from
quietly drifting into being a second walkthrough. A wanderer that knows
the answer has stopped testing anything.

It fails loudly and usefully:

```
FAIL
  - WANDERER STRANDED: never reached Marseilles Quay in 55 inputs
    (4 rejected by the parser). A player who does not guess FURL SAILS
    must still get off the ship.
```

I hit that exact failure mid-build, after fixing (a) and (b) but before
(c) — which is how I found out that naming the exit was not enough while
the refusal still named no action. **The test found a real bug I had not
diagnosed**, which is the whole argument for it.

### The generalisation

The three defects are one shape: **the game knows something the player
needs and does not say it.** Where the exit is; what a place is called in
words the parser accepts; what would open a gate. So, three questions to
ask of every room and every refusal, none of which a walkthrough asks:

1. If a player types LOOK here, does the text name a **direction**?
2. Does anything the game says direct the player to a place, and can the
   parser **hear** that place's name?
3. Does every refusal name the **action** that would lift it?

`tools/audit-game.mjs` answers 1 and 2 statically. Run it early — it
found twenty-one rooms in this game, of which nineteen were real. The two
it still reports (Villefort's Study, Tiboulen) genuinely have no exits;
both are scripted scenes that end themselves, and both now say so in
their own text, because a player standing in a room with no way out
deserves to be told that is deliberate.

Question 3 has no static check. It is the one to hold in your head while
writing every failure message, and the wanderer test is what catches it.

**Cost of retrofitting all this: about an hour.** Cost of writing the
wanderer file first, before Act I: perhaps ten minutes. Write it first.

### Second-order lesson: fixing the message is not fixing the map

Naming exits in twenty rooms is a prose edit. The deeper fix was
**vocabulary for places**: twenty-two global objects that make every
destination the game names in its prose into a word the parser knows, and
a `GO TO <place>` handler that either walks the player there or says which
way it lies. `GO TO COUNTING HOUSE`, `GO TO QUAY`, `LEAVE SHIP` and
`GO TO MEILHAN` all work now. That is the piece worth copying wholesale —
see §2.8.

---

## 1. Engine gotchas, with the fix

### 1.1 The two the coordinator warned about — both confirmed here

**`VALUE` properties are dead on TAKE.** `SCORE-OBJ` is only called from
`V-PUT` and from a take path guarded by
`%<COND (<OR <==? ,ZORK-NUMBER 1> <==? ,ZORK-NUMBER 2>> '<SCORE-OBJ ,PRSO>)
(T '<NULL-F>)>` in `gverbs.zil`. New games set `<SETG ZORK-NUMBER 0>`, so
that compiles to nothing and `(VALUE n)` never scores. Award points
explicitly. This game does it through one helper and never touches VALUE:

```zil
<ROUTINE ADD-SCORE (N)
	 <SETG BASE-SCORE <+ ,BASE-SCORE .N>>
	 <SETG SCORE <+ ,SCORE .N>>
	 T>
```

Having every award go through one routine also makes the score auditable:
`grep -ohE "<ADD-SCORE [0-9]+>" *.zil | grep -oE "[0-9]+" | paste -sd+ | bc`
told me the game only offered 380 of a claimed 400 long before a player
would have.

**Implicit takes bypass object ACTION routines.** `TAKE-CHECK` calls
`ITAKE-CHECK`, which calls `<ITAKE <>>` **directly**, not through
`PERFORM`. So a syntax line carrying `STAKE` silently moves the object
into the player's hands without the object's own action ever running. Any
gate you implemented as "TAKE this and I'll refuse" is defeated by any
verb whose syntax says TAKE. Gate on state you own (a global), not on the
take.

The neighbouring trap: `SHAVE` on a syntax line makes the parser print
"You don't have the X" for any object you are not holding, *before* the
action runs. This is why `DROP ANCHOR` needs its syntax widened **without**
`HAVE` — see BUILD-ISSUES §5.

### 1.2 A v8 word cannot be both a noun and an adjective

The costliest single defect in this build; full detail in BUILD-ISSUES §1.
Symptom: a noun that is declared, present in the dictionary, and the only
match in scope is refused with "You can't see any X here!" — while
`EXAMINE <adjective> X` works.

Run this before you write any actions:

```sh
{ grep -ohE "\(SYNONYM [A-Z0-9 -]+\)" ../../zil/zork1/gglobals.zil *.zil \
    | sed 's/(SYNONYM //; s/)//' | tr ' ' '\n' | sed 's/^/N /'
  grep -ohE "\(ADJECTIVE [A-Z0-9 -]+\)" ../../zil/zork1/gglobals.zil *.zil \
    | sed 's/(ADJECTIVE //; s/)//' | tr ' ' '\n' | sed 's/^/A /'
} | awk 'NF==2' | sort -u \
  | awk '{s[$2]=s[$2] $1} END {for (w in s) if (s[w]~/A/ && s[w]~/N/) print w}'
```

Include `gglobals.zil` in the sweep. It contributed `STONE`, `SAILOR` and
`WATER` to my collision list, and because you cannot edit it, any word it
claims as an adjective is permanently unavailable as a noun.

The same defect kills `IN` and `OUT` as directions (they are also
prepositions). If your map has interior/exterior exits, declare two
direction words that are nothing else:

```zil
<DIRECTIONS NORTH EAST WEST SOUTH NE NW SE SW UP DOWN IN OUT LAND
	    ENTRANCE EXIT>
<SYNONYM ENTRANCE INWARD>
<SYNONYM EXIT OUTWARD>
```

and put `(ENTRANCE PER ...)` beside every `(IN PER ...)`.

**Diagnostic worth keeping.** When a word misbehaves, dump its dictionary
entry rather than guessing:

```js
const b = require('fs').readFileSync('game.z8');
let p = b.readUInt16BE(0x08); p += 1 + b[p];
const len = b[p++], n = b.readUInt16BE(p); p += 2;
const dec = a => { let s=''; const A="      abcdefghijklmnopqrstuvwxyz";
  for (let i=0;i<6;i+=2){const w=b.readUInt16BE(a+i);
    for (const z of [(w>>10)&31,(w>>5)&31,w&31]) s += z>=6 ? A[z] : '';} return s; };
for (let i=0;i<n;i++){const a=p+i*len;
  console.log(dec(a), 'ps=0x'+b[a+6].toString(16), b[a+7], b[a+8]);}
```

`ps` is a bitmask: 0x80 noun, 0x40 verb, 0x20 adjective, 0x10 direction,
0x08 preposition. A clean noun reads `0x80`. Anything else sharing 0x80 is
suspect.

### 1.3 Preactions are indexed by action, not syntax line

`PERFORM` does `<GET ,PREACTIONS .A>`. Adding `<SYNTAX DESTROY OBJECT =
V-MUNG>` does not escape `PRE-MUNG`, which vetoes every bare BREAK before
your object ever sees the verb. czil applies the last definition of a
routine, so redefining the preaction in your own file is legal and leaves
`zil/zork1` untouched. Redefine narrowly and fall through otherwise:

```zil
<ROUTINE PRE-MUNG ()
	 <COND (<AND ,PRSI <NOT <FSET? ,PRSI ,WEAPONBIT>>
		     <NOT <FSET? ,PRSI ,TOOLBIT>>>
		<TELL "Trying to destroy the " D ,PRSO " with a " D ,PRSI
" is futile." CR>
		<RTRUE>)
	       (T <RFALSE>)>>
```

I had to do this for `PRE-MUNG` (BREAK), `PRE-BURN` (BURN with no flame)
and `PRE-TAKE` (REMOVE of a worn thing — which is the whole disguise
system, so it was not optional).

### 1.4 `VERB?` names actions, not verbs

`<VERB? PULL>` → `unknown global V?PULL`. The valid tokens are the
action-routine suffixes. The ones that bit me: PULL→MOVE, POUR→DROP or
POUR-ON, KILL→ATTACK, REPLY→ANSWER, CLIMB-IN→BOARD, LIFT→RAISE,
SET→TURN, REMOVE→TAKE, ASK→TELL, BREAK→MUNG, HIT→ATTACK.

Corollary when adding verbs: check `gsyntax.zil`'s `<SYNONYM>` list first.
`SET` is already a TURN synonym and `LIFT` a RAISE synonym, so a new
`SET`/`LIFT` verb shadows an existing action. I renamed the telegraph verb
to `SEND`.

### 1.5 There is no worn state

`V-WEAR` is literally `<PERFORM ,V?TAKE ,PRSO>`. `WEARBIT` changes one
message and nothing else. There is no `WORNBIT`, no `V-DISROBE`, and
`REMOVE` is a `TAKE` synonym. Costume state is yours to keep.

### 1.6 Room descriptions vanish on revisit

`DESCRIBE-ROOM` calls the room's `M-LOOK` only when the room is untouched
or VERBOSE is set. If your story revisits a location with a changed
description (mine revisits Marseilles fourteen years later and the prison
twenty-four years later), the new text never prints. One line at each act
transition:

```zil
<FCLEAR ,OFFICE ,TOUCHBIT>
```

### 1.7 v3-shaped calls take three arguments

`<JIGS-UP "one" CR CR "two">` fails to compile. Print the obituary
yourself and call `<JIGS-UP "">`, with a local `JIGS-UP` that suppresses
the empty string.

### 1.8 The inventory limit will ambush you at an act boundary

`LOAD-ALLOWED` refused a pickup in Act IV because the player was still
carrying prison junk from Act II. Retire props at act transitions — it is
better narrative anyway. The Count is not still carrying a jug shard.

---

## 2. ZIL idioms that worked

### 2.1 ASK/TELL ABOUT topic routing — the reusable one

This is the piece every future book with dialogue needs, and the design
correctly flagged it as the main engine risk. The good news: it works, and
it is small. The bad news is entirely about **scope**, not syntax.

**The syntax already exists.** `zil/zork1/gsyntax.zil` ships:

```zil
<SYNTAX TELL OBJECT (FIND ACTORBIT) (IN-ROOM) ABOUT OBJECT = V-TELL>
<SYNONYM TELL ASK>
```

So `ASK FARIA ABOUT TREASURE` parses out of the box with `PRSO` = the
actor and `PRSI` = the topic. No new verb is needed. Do **not** try to
make `TALK TO X ABOUT Y` work — see §3.

**The one thing you must know about dispatch order:** `PERFORM` runs the
**PRSI** action before the PRSO action. So a topic object with an ACTION
routine intercepts the conversation before the NPC does. Keep topic
objects action-free for routing (or make their action fall through when
`PRSO` is an actor — mine does, see §2.2), and put all the routing in the
NPC:

```zil
<ROUTINE FARIA-FCN ()
	 <COND (,FARIA-DEAD <FARIA-CORPSE>)
	       (<AND <VERB? TELL> ,PRSI> <FARIA-TOPIC>)   ;"ASK/TELL ABOUT"
	       (<VERB? TELL> <FARIA-GREET>)               ;"bare TALK TO"
	       (<VERB? EXAMINE> ... )>>

<ROUTINE FARIA-TOPIC ()
	 <COND (<EQUAL? ,PRSI ,DANGLARS-T> <NAME-DANGLARS>)
	       (<EQUAL? ,PRSI ,LETTER-T ,ARREST-T> ...)
	       (<EQUAL? ,PRSI ,TREASURE-T ,SPADA-T> <TELL-THE-SPADA>)
	       (T <TELL "\"Later, perhaps...\"" CR>)>            ;"in-voice default"
	 <RTRUE>>
```

`<EQUAL? ,PRSI ,A ,B>` gives you free topic aliasing (LETTER and ARREST
reach the same answer), and the `T` clause is where the NPC's voice lives
— never let it fall through to the engine's shrug.

**Scope is the whole problem, and here is the answer.** Topics are
abstractions; they are not in any room. Three options, and only one scales:

- `(IN LOCAL-GLOBALS)` + a `(GLOBAL ...)` list on each room. Correct Zork
  idiom, and it collapses the moment you have four acts: I had eleven
  topics listed on three cells and then had to repeat the exercise for
  sixteen Paris rooms. Do not.
- Put the topic in the room where it is asked about. Works until the
  player asks a second NPC about the same thing.
- **`(IN GLOBAL-OBJECTS)`.** Always in scope, one declaration, done.

```zil
<OBJECT TREASURE-T
	(IN GLOBAL-OBJECTS)
	(SYNONYM TREASURE FORTUNE)
	(DESC "treasure")
	(FLAGS NDESCBIT)
	(ACTION TOPIC-FCN)>
```

**Global scope has two consequences you must handle.**

*(a) Every topic word collides with any object using the same word.* Two
objects answering to `danglars` produce "Which Danglars do you mean, the
Danglars or the Danglars?" — the worst error message in the game, because
both print identically. The fix is a rule: **one word, one live object at
a time.** Person-topics stay global; the person objects get retired from
play the moment their act ends.

```zil
;"Retire everyone whose scene is over. The proper names live on the
global topic objects; a used-up NPC left lying in a room nobody will
enter again only creates ASK ABOUT ambiguity."
<ROUTINE RETIRE-CAST ()
	 <REMOVE ,MORREL> <REMOVE ,DANGLARS> <REMOVE ,MERCEDES>
	 <REMOVE ,FERNAND> <REMOVE ,CADEROUSSE> <REMOVE ,FATHER>
	 <REMOVE ,VILLEFORT> <REMOVE ,COCLES>
	 <RTRUE>>
```

Called at every act transition. Where an NPC genuinely must share a scene
with its own name (Act IV Danglars in his own office), the NPC wins the
noun and the topic is what you ask *other people* about — which is exactly
what you want anyway.

Audit for duplicates the same way you audit adjectives:

```sh
python3 - <<'PY'
import re, collections
w = collections.defaultdict(list)
for p in ['dungeon.zil','paris.zil']:
    for m in re.finditer(r'<OBJECT ([A-Z0-9-]+)\n\t\(IN ([A-Z0-9-]+)\)\n\t\(SYNONYM ([A-Z0-9 -]+)\)', open(p).read()):
        for word in m.group(3).split(): w[word].append((m.group(1), m.group(2)))
for word, objs in sorted(w.items()):
    if len(objs) > 1 and any(o[1] in ('GLOBAL-OBJECTS','LOCAL-GLOBALS') for o in objs):
        print(word, objs)
PY
```

*(b) Topics are now reachable by every other verb.* `EXAMINE MERCEDES` in
a prison cell answered "There's nothing special about the Mercedes."
One shared action fixes all of them:

```zil
<ROUTINE TOPIC-FCN ()
	 ;"fall through when a real actor is being addressed"
	 <COND (<AND <VERB? TELL> ,PRSO <FSET? ,PRSO ,ACTORBIT>> <RFALSE>)
	       (<VERB? EXAMINE READ SEARCH LOOK-INSIDE>
		<TELL "You think about " D ,PRSO " for a moment. There is
nobody here to say it to." CR>
		<RTRUE>)
	       (<VERB? TELL>
		<TELL "There is nobody here to tell." CR>
		<RTRUE>)
	       (<VERB? TAKE MOVE DROP PUT GIVE SHOW ATTACK MUNG KISS>
		<TELL "That is a subject, not a thing." CR>
		<RTRUE>)
	       (T <RFALSE>)>>
```

The first clause is load-bearing: it is what lets the NPC's own action get
the ASK, since PRSI runs first.

**Budget.** Twenty-ish topic objects was about right for a novel with a
large cast; the design's estimate held. Aliasing with `<EQUAL? ,PRSI ,A ,B>`
means you need fewer objects than topics.

### 2.2 Disguise as a wearable identity

There is no worn state (§1.5), so identity is a global you own and the
costume objects are the only things that set it. The whole system:

```zil
<GLOBAL IDENTITY 0>   ;"0 Edmond 1 Busoni 2 Wilmore 3 the Count 4 revealed"

<ROUTINE SET-IDENTITY (N)
	 <SETG IDENTITY .N>
	 <COND (<EQUAL? .N 1>
		<MOVE ,CASSOCK ,WINNER> <MOVE ,WIG ,WINNER>
		<TELL "The cassock, the gray tonsure, the stoop... You are
the Abbe Busoni, and men tell priests what they tell no one living."
CR>)
	       ...>
	 <RTRUE>>

<ROUTINE CASSOCK-FCN ()
	 <COND (<VERB? WEAR>
		<COND (<EQUAL? ,IDENTITY 1> <TELL "You are wearing it." CR>)
		      (T <SET-IDENTITY 1>)>
		<RTRUE>)>>
```

Three things make it feel like a system rather than a flag:

**Wearing one coat removes the others.** `SET-IDENTITY` and the individual
handlers `<REMOVE>` the competing costume objects, so identity is always
exactly one value and inventory never lies about it.

**Gates refuse in character and name the fix.** This is the part that
sells it. Never "you can't"; always the in-world reason plus a pointer:

```zil
<ROUTINE ROAD-IN ()
	 <COND (<EQUAL? ,IDENTITY 1> ,INN)
	       (T
		<TELL "You have your hand on the door and take it off
again. The man inside knew Edmond Dantes, and a face is a poor way to
open a conversation you mean to control. There is a cassock in your
baggage." CR>
		<RFALSE>)>>
```

Gating a *room exit* on identity is cheaper and more legible than gating
every conversation inside the room, and it makes the disguise feel like a
key.

**Un-masking is `REMOVE`, and `REMOVE` is `TAKE`.** So the reveal arrives
at the wig's action as a take of a thing already held, and stock
`PRE-TAKE` answers "You are already wearing it" first. Redefine `PRE-TAKE`
to let costume pieces through (BUILD-ISSUES §4) and then:

```zil
<ROUTINE WIG-FCN ()
	 <COND (<VERB? TAKE MOVE>
		<COND (<AND <EQUAL? ,IDENTITY 1> <IN? ,WIG ,WINNER>>
		       <DOFF-THE-WIG> <RTRUE>)>
		<RFALSE>)
	       ...>>
```

`DOFF-THE-WIG` calls one dispatcher, `THE-COUNT-UNMASKS`, which asks *who
is in the room* and runs the right reveal — or, if nobody is, puts the wig
back on with a line rather than burning the moment. That dispatcher is
what makes three separate scripted reveals share one verb.

### 2.3 Daemon suspension during scripted scenes

The design flagged this and it was exactly right: the jailer's every-12-
turns round walked straight into the sack-swap and hanged the player for
tidying a corpse. The interlock is one global that every scene sets, and
the demon's **first** act is to requeue itself so suspension never costs
a tick:

```zil
<GLOBAL SCENE-LOCK <>>

<ROUTINE I-JAILER ()
	 <ENABLE <QUEUE I-JAILER 12>>        ;"requeue FIRST, unconditionally"
	 <COND (<NOT <EQUAL? ,ACT 2>> <RFALSE>)
	       (,SCENE-LOCK <RFALSE>)        ;"a scripted scene owns the turn"
	       (<OR ,FARIA-DEAD ,IN-SACK ,SACK-SEWN> <RFALSE>)
	       (<G? ,SWAP-TURNS 0> <RFALSE>)>
	 ... the round ...>
```

Requeue-first matters: if you requeue at the end you will eventually
return early on some path and kill the demon permanently, which is a much
harder bug to see than a demon that fires once too often.

Every scene that must not be interrupted sets `SCENE-LOCK` on entry and
clears it when the player regains control. Act transitions set it too,
which is free insurance.

### 2.4 Scene scripting: room `M-END` counters, not one big demon

Every scripted scene here is a turn counter in the room's own action:

```zil
<ROUTINE RESERVE-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-END>
		<COND (<G? ,FEAST-TURNS 0> <FEAST-TICK>)>
		<RFALSE>)
	       ...>>
```

Scenes are then local, independently testable, and cannot interfere. One
central demon would have needed to know about all of them. The cost is a
line of boilerplate per room; pay it.

### 2.5 Act transitions as one routine each

`ENTER-ACT-TWO`, `ENTER-ACT-THREE`, `ENTER-ACT-FOUR`, `ENTER-ACT-FIVE`.
Each one does exactly five things: bump `ACT`, retire the cast, move the
new cast and props into place, clear `TOUCHBIT` on rooms whose description
changed, `GOTO` the first room. Having them be routines rather than inline
code meant I could reach Act IV from three different endings of Act III
without duplicating setup.

### 2.6 Phase machines beat scattered flags for a long act

Act II is a fourteen-year act with nine puzzle beats. One `PHASE` integer
plus a `PHASE-TICK` routine driven off the cells' `M-END` kept the
sequencing in one readable place. Individual puzzle state stayed in named
booleans (`BED-MOVED`, `STONE-PRIED`) so the puzzles could be solved in
any workable order, while `PHASE` owned only the irreversible narrative
progression. That split is worth copying: **phase for the story, booleans
for the puzzles.**

### 2.7 The diegetic quest log

`READ DOSSIER` prints the state of all four revenge plots in the Count's
own voice. It is thirty lines of `COND`, it is the best debugging tool in
the game, and it is in-fiction. If your book has parallel threads, build
one on day one and read it after every change.

### 2.8 Places as objects, so GO TO <place> works

The second half of the stranded-player fix (§0), and the piece I would
lift into any new game unchanged. A novel's prose is full of place names —
the counting-house, the quay, Auteuil, the Chamber of Peers — and a player
who reads them will type them. By default the parser knows none of them
and the engine's `V-WALK-TO` answers *"You should supply a direction!"*,
which is exactly backwards: the player has supplied one, in the only terms
the game gave them.

Every destination the game names in its prose becomes a global object:

```zil
<OBJECT P-OFFICE
	(IN GLOBAL-OBJECTS)
	;"COUNTING is the adjective and HOUSE the noun, so GO TO COUNTING
	  HOUSE parses as an adjective-noun pair. COUNTING must not ALSO be
	  a SYNONYM here - that is the v8 collision from section 1.2."
	(SYNONYM HOUSE OFFICE COUNTINGH COUNTIN)
	(ADJECTIVE COUNTING MORRELS)
	(DESC "counting-house")
	(FLAGS NDESCBIT)
	(ACTION PLACE-FCN)>
```

Three routines drive them all:

- **`PLACE-HERE`** — which place object stands for the room you are in.
  Lets `GO TO QUAY` answer "You are there."
- **`PLACE-DIR`** — a direction code from here to there, or false. One
  `COND` per room; tedious to write, trivial to read, and it is the only
  place the map is stated in words rather than exits.
- **`GO-TO-PLACE`** — says which way and takes the step. If the
  destination is more than one room off it says so honestly (*"not next
  door, but the way to it starts off in this direction"*) and walks one
  leg, rather than pretending the whole map is adjacent.

Then redefine `V-WALK-TO` to route place objects through it, and give
`PLACE-FCN` the other verbs a player aims at a place: `EXAMINE QUAY`
describes the way without teleporting; `LEAVE SHIP` (which the parser
delivers as `DROP SHIP`) takes the way out.

Four things learned building it:

**Multi-word place names need adjective-noun splitting.** "counting
house" is two words; the parser reads the first as an adjective. So
COUNTING is the ADJECTIVE and HOUSE the SYNONYM — and per §1.2 the word
must not be both, which is a real constraint on naming.

**Places collide with topics and with props.** SHIP was three objects
here: a place, Morrel's grief in 1829, and a Genoese tartan. One object
must own the noun. I merged the place into the existing topic and gave it
a handler that behaves as a place aboard ship and as a topic everywhere
else. The audit script in §2.1 finds these.

**Say "X lies west", not "X is west".** Trivial-sounding, but
`tools/audit-game.mjs` matches direction phrasings, and more importantly
so does a reader skimming for an actionable word. "The way out leads
east" and "the stair goes back up" also read as instructions. "The street
is west" reads as decoration.

**Watch the articles and the plurals.** `<TELL "The " D .PLACE>` on a
DESC of "La Reserve" prints *"The La Reserve"*, and "The Allees de
Meilhan lies north" is wrong in the other direction. One tiny helper for
the verb, and DESCs written without their article.

---

## 3. Things that did not work

**`TALK TO X ABOUT Y`.** There is no such syntax and adding one is a trap:
`TALK TO` is already `V-TELL` with a different preposition, and a third
form gets you into orphan-merge territory in the parser. Use the stock
`ASK X ABOUT Y` / `TELL X ABOUT Y` and let the LLM layer normalize.

**`<SYNONYM WALK SWIM>` to make SWIM take a direction.** Directions only
parse when the sentence verb *is* `WALK`, compared by action value in
`GPARSER`; a late SYNONYM does not retarget an existing verb. Verified in
the dictionary dump: `swim` kept action 140, `walk` is 128. Abandoned;
the open sea uses bare compass words and the room narrates the swimming.

**Making a topic object and an NPC share a noun.** Produces "Which
Danglars do you mean, the Danglars or the Danglars?" — both `PRINTD` the
same string, so the disambiguation question is unanswerable. Retire the
cast instead (§2.1).

**Deleting the topic objects and routing on the NPC objects.** My first
attempt at the collision. It works only while the NPC is on stage, which
is precisely when you do not need the topic. Reverted within twenty
minutes.

**`(IN LOCAL-GLOBALS)` for topics.** Requires a `(GLOBAL ...)` clause on
every room where the topic can be raised. Fine for one act, unmaintainable
across five. `GLOBAL-OBJECTS` from the start.

**Renaming a noun to dodge an ambiguity, without checking the walkthrough.**
I renamed the wedge stone's noun away to break a clash, then spent a
compile cycle on `I don't know the word "wedge"` because DESIGN.md's
walkthrough says `DIG WEDGE WITH PICKAXE`. Any rename is a walkthrough
edit; make both in the same commit.

**Design fidelity on the jailer death.** The design makes absence from
cell 34 fatal once the tunnel exists. Implemented literally, that makes
Faria's cell — where the education, the phial and the parchment all live —
a coin flip, and my first full Act II run died three times in a row doing
nothing wrong. Softened to: fatal before Faria (you have no craft), a
near-miss with the straw dummy afterwards (his first practical lesson),
and the real danger relocated to the ten-o'clock clock during the swap.
Same number of reachable deaths, all fair. **A death that punishes the
player for visiting the act's best content is a design bug, not a
difficulty setting.**

**A stub-generation script.** I wrote `genstubs.sh` to emit no-op routines
for everything the world files referenced but the actions files did not
yet define, so the skeleton would compile from day one. This was genuinely
useful for the first three hours and then became a hazard: a stub is
indistinguishable from a finished routine that returns false, so a
forgotten one is a silent no-op rather than a compile error. Keep it, but
regenerate constantly and treat "the stub file is empty" as a completion
gate (mine ended empty and I deleted both files).

---

## 4. Design-to-implementation friction

DESIGN.md was unusually good — every puzzle had its exact solution, every
gate listed its key, and the solvability audit at the end was accurate.
The friction was all in three places.

**Compass directions and exact command wording are guesses until they are
compiled.** The design says so itself ("final exit letters get fixed in
implementation"), and it is right, but the §9 walkthrough still reads as
authoritative and eight of its commands do not parse against the finished
game (`PRY STONE`, `SWIM WEST`, `IN`, `OUT`, `SET SIGNAL`, `DIG CORNER`,
`CUT BRANCH`, `TAKE STONE`). **Suggestion for ADAPTING.md:** write the
design walkthrough as *intent* — "lever the block out with the iron" —
and generate `walkthrough.txt` from the built game. It is the artifact
that has to be exact, and it can only be exact after the fact.

**Act IV held up better than expected, and the reason is worth recording.**
It was flagged as the densest scene scripting in the batch. It was, but the
design's own mitigation worked: each caper is a linear flag chain with no
cross-dependencies except the evidence flags, and every caper's steps are
in one room or two adjacent rooms. I built all four in a single pass and
only two bugs came out of it, both about *staging* rather than logic:

- **Scenes that summon the player were not specified.** The design says
  Morcerf comes to the salon "that evening" after the Peers vote, but the
  player is standing in the Peers gallery when the vote lands and there is
  no way to get to the scene. The fix is one line — the scene `GOTO`s the
  player home and stages the NPC — but the design should say who moves.
  **Every scene wants an explicit answer to "where is the player standing
  when this fires, and who moved them there?"**
- **Reveals gated on a room are fragile.** The Caderousse deathbed was
  specified in the salon; the burglary it follows happens in the study.
  Gating on a `CAD-DYING` state instead of a room made it robust and cost
  nothing.

**Point budgets drift and need auditing, not trusting.** The act totals
(35/130/90/100/45) are load-bearing for the 400 target and for the rank
table, but the per-beat awards in §4 do not quite sum to them — Act IV's
listed beats came to 95 and the missing 5 had to be assigned (I gave it to
PRESS-RUN, which is a scored beat in the prose but has no number). Sum the
design's own numbers before you build, and put one `grep | bc` in your
loop after.

**Underspecified in a way that mattered:** the design never says what the
player is *carrying* between acts, and the Z-machine's load limit does not
care about narrative. Add an inventory line to each act transition in the
design.

**Right in a way worth calling out:** the TTS style guide (§10) made the
prose faster to write, not slower. "One image per response, concrete and
physical" and "failure text teaches" are directly actionable at the
keyboard. The certified-quotes list in STUDY.md §7 meant the load-bearing
lines were transcription rather than composition.

---

## 5. Process notes

**Order that worked, and I would repeat exactly:**

1. Read the design end to end, then the engine's `gsyntax.zil` verb list
   and `gverbs.zil` for the verbs your puzzles need. An hour here saves
   several.
2. **Vocabulary audit** (§1.2) before any action code.
3. Get the skeleton compiling with auto-generated no-op stubs, and *boot
   it*. A game that boots is a much better place to work from than a game
   that compiles.
4. **Syntax spike.** Prove the risky mechanic in the skeleton before
   building anything that depends on it. Mine was `TELL MERCEDES ABOUT
   FEAST` in Act I, working, at hour two. That single command validated
   the whole conversation system and let me write twenty topic tables
   without fear.
5. **Write `walkthrough-wanderer.txt` and wire its assertion into
   verify.mjs before building Act I** (§0). Ten minutes now; an hour
   later, and in my case only after a real player had already quit. Make
   it fail first, so you know it can.
6. Act by act, in story order, compiling and replaying the whole
   walkthrough-so-far after every scene. Never more than ~150 lines
   between compiles. Run `tools/audit-game.mjs` at each act boundary, not
   at the end — the findings are one-line prose edits while the act is
   fresh and a slog in a batch of twenty-one.
7. Branch tests, then freeze the transcript, then the docs.

**Test by replaying the accumulating walkthrough, always from the top.**
`node czil/tests/play.mjs game.z8 script.txt` takes about two seconds for
a 200-command run, so there is no reason to test a scene in isolation.
Every run re-tests everything before it, which is how I caught the topic
refactor breaking Act III (the score at the act boundary dropped from 255
to 215 and the diff told me exactly where).

**Score checkpoints are the cheapest regression test there is.** The
design's act totals are cumulative checkpoints: 35 at the end of Act I,
165 at the end of Act II, 255 at the end of Act III. Watching those exact
numbers appear was how I knew each act was actually complete rather than
merely walkable. Do not interleave `score` into the walkthrough to trace
this, though — it consumes turns and shifts every WAIT-timed scene. Run
the plain walkthrough and read the final number.

**Where the effort went**, roughly: 15% reading design and engine, 10%
world-file verification and the vocabulary audit, 45% writing action code,
**25% fighting the parser** (nearly all of it the adjective/noun defect and
its consequences), 5% tests and docs. The parser fraction should be much
smaller for the next person now that the collision class is documented.

**On scoping a very large novel.** *The Count of Monte Cristo* is ~460k
words and the design cut it to 40 rooms without feeling thin. What made
that work, in order of importance:

- **Adapt the set pieces the novel already wrote as puzzles.** The Château
  d'If is a third of the game because Dumas wrote it as one: object
  puzzles, a failure state, a mentor NPC, an escape sequence. Find your
  book's Château d'If and give it the most room. Do not distribute effort
  evenly across the plot.
- **Convert social plot into rooms, props and information-as-items.** The
  entire Paris half of the novel is drawing rooms and conversation; it
  became four capers with a hub, an evidence flag each, and documents you
  can carry. "Information is an item" is the single conversion that makes
  a 19th-century novel playable.
- **Narrate time, don't simulate it.** Fourteen years pass in six
  interstitials of two sentences each. The dated one-liner ("It is 1838,
  and Paris believes in you") does more work than any amount of mechanism.
- **Let the protagonist's arc be the difficulty curve.** Act I is on rails
  because Edmond has no agency; Act II is the hardest because he is
  learning; Acts IV-V are wide because he is the Count. Scope follows
  character, and the player feels it as pacing rather than as budget.
- **Cut subplots whose cause-and-effect you can replace with one scene.**
  The Albert duel is gone; Mercédès's midnight visit carries its
  consequence in six lines. Ask of every subplot: what does the endgame
  need from this, and is there a single scene that delivers it?

**What I would do differently:** write the wanderer test before Act I
(§0) and run the vocabulary audit first (§1.2). Those two habits between
them account for nearly every hour I lost and the one bug that reached a
player. Also: keep `walkthrough.txt` as a living file from Act I rather
than reconstructing it at the end - I kept it in a scratch directory and
had to reassemble it, when it could have been the test artifact all
along.

**The thing I got most wrong** was not a bug, it was a belief: that a
green test suite meant a working game. Mine was as green as it gets -
400/400, four branch tests, a frozen transcript - while the opening
screen was a wall. Tests written by the author test the author's
understanding. Anything that only a stranger would discover needs a test
that does not know the answer.
