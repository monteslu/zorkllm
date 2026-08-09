# czil - a C port of ZILF

A from-scratch C11 port of [ZILF](https://foss.heptapod.net/zilf/zilf)
(Tara McGrew's ZIL compiler, upstream in this repo's `src/`), built for
compilation to WebAssembly. Zero dependencies, no libc surprises, arena
allocation only.

**License: GPL-3.0-or-later** - czil is a derivative work of ZILF
(Copyright 2010-2023 Tara McGrew); see `LICENSE`.

## Status / roadmap

| Stage | Upstream (C#) | czil | Status |
|---|---|---|---|
| 1. Value model | `Zilf/Interpreter/Values/*` (atoms, FIX, string, list, form, vector, segment, adecl...) | `src/value.c` | **done** (reader subset) |
| 2. Reader | `Zilf/Language/Parsing/Parser.cs` + `CharBuffer.cs` (1.4k lines) | `src/reader.c` | **done** - parses the full Zork trilogy sources |
| 3. Evaluator core | `Zilf/Interpreter/Context.cs`, `Subrs.*` (17k lines) | `src/eval.c` | **done** - 237 assertions + full-trilogy `%<...>` sweep |
| 4. Z-model | `Zilf/ZModel`, `Subrs.ZModel.cs` | `src/zmodel.c` | **done** - trilogy ingest; dictionaries + object names match the shipped .z3 files |
| 5. Compiler + emit + assemble | `Zilf/Compiler`, `Zilf.Emit`, `Zapf` (40k lines) | `src/zcode.c` | **done** - all three games compile to playable .z3 with transcripts identical to the shipped binaries |

Acceptance gate for each stage is the real thing: stage 2 must parse every
`.zil` file in the MIT-licensed Zork I/II/III source trees byte-for-byte
structurally; stage 3 must evaluate every `%<...>` read-macro in all three
games without error; stage 4 must ingest each complete game from its root
file and match the shipped `.z3` binaries on object count, object short
names, and the entire dictionary; stage 5 must compile each game to a
story file whose play transcript, under a deterministic RNG and a scripted
walkthrough, is byte-identical to the shipped Infocom binary's.

## The evaluator (stage 3)

`src/eval.c` ports the MDL semantics the games and upstream tests pin down:

- Only type `FALSE` is falsy. Atoms, FIXes, strings, chars, and applicables
  self-evaluate; LIST/VECTOR evaluate elements with `!segment` splicing
  (string segments splice as characters); FORM resolves an atom head
  GVAL-then-LVAL and applies (a FIX head is NTH: `<2 (A B C)>` is `B`).
- Dynamic scoping: `PROG`/`REPEAT`/`BIND`/function calls push binding
  frames; `RETURN`/`AGAIN`/`MAPRET`/`MAPSTOP` travel in `cz_result.flow`
  (no exceptions, WASM-friendly).
- Argspecs: required, `'quoted`, `"OPT"`/`"OPTIONAL"`, `"AUX"`/`"EXTRA"`,
  `"ARGS"` (raw), `"TUPLE"` (evaluated), `(name default)`, adecl-stripped;
  optionals without defaults are bound-but-unassigned (`ASSIGNED?` false).
- ~70 SUBRs/FSUBRs: arithmetic (`</ 2>` = 0, LSH is uint32-logical),
  predicates, SET/SETG/GVAL/LVAL/(G)ASSIGNED?/(G)UNASSIGN,
  COND/AND/OR/PROG/REPEAT/BIND, DEFINE/DEFMAC (REDEFINE-gated)/FUNCTION,
  LIST/VECTOR/FORM/CONS/NTH/REST/PUT/PUTREST/MEMQ/MEMBER/LENGTH/EMPTY?,
  STRING/SPNAME/PARSE/CHTYPE, MAPF/MAPR/MAPRET/MAPSTOP, EVAL/ID/EXPAND/
  APPLY, PRINC/CRLF (to a context buffer), GDECL (no-op until the decl
  checker).
- The printer sugars `<LVAL X>`/`<GVAL X>`/`<QUOTE X>` as `.X`/`,X`/`'X`,
  matching upstream `ZilForm.ToString`.

### Upstream test conversion map

Converted into `tests/eval.t` (in-scope assertions): `ArithmeticTests`,
`AtomTests`, `FunctionTests`, `StructureTests` (list/vector subset),
`FlowControlTests` (COND/PROG/REPEAT/RETURN/AGAIN subset), plus
czil-specific additions (segments, READEVAL, sweep controls).

Deferred with the feature that needs them: `TableTests`/`ZGET` (stage 5
table emission), `SyntaxTests`/`CompilationFlagTests` (stage 5 codegen),
`DeclTests` (decl checker), `PackageTests` (oblists/packages),
`TemplateTests`, `IdeInfoTests`/`WeakCountingSetTests` (ZILF
infrastructure, not ported).

## The Z-model (stage 4)

`src/zmodel.c` registers the game directives as SUBRs/FSUBRs on top of the
stage-3 evaluator, so plain evaluation of the sources builds the model,
exactly as MDL compilation worked. Directives inside top-level `<COND>`s
(the trilogy's ZORK-NUMBER switches) come along for free.

- Directives: VERSION, CONSTANT, GLOBAL (both also SETG their value for
  later read-time references), OBJECT, ROOM, ROUTINE, SYNTAX, SYNONYM,
  BUZZ, DIRECTIONS, PROPDEF, SNAME, FREQUENT-WORDS?, INSERT-FILE, and the
  TABLE family (TABLE/LTABLE/PTABLE/PLTABLE/ITABLE) as a first-class
  `CZ_TABLE` value type.
- Loading replays upstream's read-time semantics: every `%<...>` in a file
  is expanded (with SPLICE handling) before the top-level form is
  evaluated, so read-macros inside quoted ROUTINE bodies and clause lists
  land in the model already resolved.
- The ZILF-standard globals are pre-assigned (Context.cs): ZILCH, ZILF,
  and PREDGEN are true, SIBREAKS is `",.\""` - that is what routes the
  trilogy's `<OR <GASSIGNED? ZILCH> ...>` and PREDGEN guards the same way
  ZILF routes them.
- SYNTAX lines parse into verb + up to two OBJECT slots with prepositions
  and FIND flags; actions and preactions are cross-checked against defined
  routines at finalize.
- Vocabulary is assembled the way `Compilation.Objects.cs` does it:
  object SYNONYM words as nouns, ADJECTIVE as adjectives, PSEUDO strings
  as nouns, SYNTAX verbs and prepositions, DIRECTIONS words, BUZZ words,
  and SYNONYM directives copying the base word's part of speech.

### The differ is the acceptance gate

`tools/z3dict.c` decodes the shipped story files (v3 dictionary text and
the object table's short names, abbreviations included), and
`tools/czil-build.c --vocab` prints czil's vocabulary after a round-trip
through the same v3 z-char encoding (`src/ztext.c`), so 6-z-char
truncation matches the real dictionary exactly. Results against the
shipped MIT-licensed binaries:

| Game | Objects | Object short names | Dictionary |
|---|---|---|---|
| Zork I | 250 = shipped | exact match | 684/684 exact |
| Zork II | 251 = shipped | exact match | 689/689 exact |
| Zork III | 228 = shipped | exact match | 600/600 + 1 documented delta |

The single delta: ZILF (and czil) add every `<DIRECTIONS>` word to the
vocabulary; the original ZILCH only emitted directions some room exit
actually used. Zork III declares LAND but never uses it, so the shipped
dictionary lacks `land`. czil follows ZILF, and the test pins the diff to
exactly that one word.

## The compiler (stage 5)

`src/zcode.c` compiles the Z-model to a complete v3 story file: routine
bodies to Z-code, objects/properties/flags/globals numbered the way the
Zap emitter numbers them (properties and flags descend from 31 with
directions and syntax FIND flags first; verbs, prepositions, adjectives,
and buzzwords descend from 255), the old-parser dictionary with exact
part-of-speech and First-bit encoding, per-verb syntax tables
(ST?/VTBL/ATBL/PATBL/PRTBL), the UEXIT/NEXIT/FEXIT/CEXIT/DEXIT exit
property layouts, implicit directions from exit-shaped properties
(Zork III's `(ENTER PER MIRIN)`), game DEFMACs (TELL, VERB?, ...)
expanded through the stage-3 evaluator at compile time, and v3 z-text
with ZIL string translation ('|' newlines, '. '-collapse).

Codegen notes: predicates compile to native branch instructions with
polarity, value-context predicates materialize 1/0 via the stack,
RETURN prefers block exit inside PROG/REPEAT (the v3 quirk mode),
discarded results store to a scratch global instead of leaking stack
slots in loops, and stacked operand ordering is fixed with `pull` into
scratch globals inside call-free windows. The entry point is a two
instruction bootstrap (`call GO; quit`) so GO's shape doesn't matter.

### The transcript differ is the acceptance gate

`tests/play.mjs` runs a story file through zorkllm's Z-machine with a
deterministic RNG and a scripted walkthrough. `make test` compiles all
three games (release/serial matched to the shipped banners) and requires
the transcript to be **byte-identical** to the shipped Infocom binary's:
same prose, same object listing order, same combat rolls, same scores,
same move counters, same status lines. Zork I's walkthrough reaches the
Cellar and the troll fight and dies to a grue; a corrupted-story control
proves the differ notices single-byte differences. Getting to zero diffs
surfaced real bugs upstream ZILF also had to handle: object words carry
value 1, prepositions and buzzwords clear the dictionary First bits, and
the whole MULTIFROB macro family silently truncates without MDL list
structure sharing (REST views + PUTREST through the owner, which czil's
evaluator now implements).

## Known deviations from upstream

- **`#type` CHTYPE literals are deferred** to eval time (`CZ_CHTYPE` node);
  `#2`/`#16` binary/hex literals are evaluated in the reader as upstream
  does; `#BYTE n` stays wrapped for table emission.
- **Read-macros inside `;`-commented forms never run.** The reader drops
  the whole commented object; upstream evaluates `%` while reading it. The
  only such node in the trilogy (gmain.zil's commented-out debug PERFORM)
  is a pure `GASSIGNED?` check, so nothing observable is lost.
- **EVAL takes no environment argument** (upstream's 2-arg form errors).
- **One global oblist.** Atom names are interned whole, including `!-`
  oblist suffixes (`FOO!-INITIAL` is one atom for now).
- **`{...}` template substitution** is parsed but errors out (only used by
  ZILF's internal templates, never by game source).
- **Arena memory** - values are never freed individually; destroy the
  arena to release everything. Right shape for a batch compiler and for
  WASM.
- **Shipped-file parity over ZILF parity** where the two disagree, since
  the shipped binaries are the only oracle on this machine: object tree
  children link in reverse definition order (upstream TreeOrdering.
  ReverseDefined; ZILF's default moves each parent's first-defined child
  to the front), and the two-spaces collapse applies after '.' only, not
  after the '|' newline character.
- **No abbreviations** are emitted, so story files run ~25% larger than
  the shipped ones (still well under the 128K v3 limit).
- **PUTREST through stale views** keeps the detached old tail (arena
  copy-grow), which matches MDL cons behavior for every idiom the games
  use; simultaneous live views past the splice point would see the old
  content.

## Layout

    include/czil.h      public API: value types, reader, evaluator, printer
    include/zmodel.h    Z-model: game structures, directives, z-text codec
    src/czil_internal.h shared context internals (bindings, frames, globals)
    src/arena.c         bump allocator
    src/value.c         value constructors, atom interning, printer
    src/reader.c        the Parser.cs port (bang encoding and all)
    src/eval.c          the MDL evaluator (Context + Subrs port)
    src/zmodel.c        game directives, INSERT-FILE loading, vocabulary
    src/ztext.c         v3 dictionary-word z-char codec
    src/zcode.c         the v3 compiler: codegen, tables, dictionary, assembly
    tools/czil-read.c   CLI: parse .zil files, dump or summarize
    tools/czil-eval.c   CLI: -e exprs | -t test file | --sweep READEVAL nodes
    tools/czil-build.c  CLI: build the Z-model; --stats/--vocab/--objects/--descs
    tools/czil-compile.c CLI: compile a game to .z3 (-o out -r release -s serial)
    tools/z3dict.c      CLI: oracle extractor for shipped .z3 files
    tests/run.sh        acceptance: parse, eval, sweep, z3 differs, transcripts
    tests/eval.t        239 evaluator assertions (converted upstream + czil)
    tests/play.mjs      deterministic walkthrough player (zorkllm Z-machine)
    tests/objdump.mjs   object table / property dumper for story files
    tests/dbg.mjs       raw-io interpreter harness for debugging hangs

## Build & test

    make          # builds czil-read, czil-eval, czil-build, czil-compile, z3dict
    make test     # everything above, ending in the shipped-transcript differs

### Abbreviations and version 8

Abbreviation compression (standard Z-machine text compression) is on by
default: a deterministic greedy selector selects up to 96 substrings
from every string the compiler encodes; Zork I shrinks from 111KB to
98KB with a transcript-identical result. `--no-abbrevs` disables it.

`-v 8` (or `-v 5`) targets the larger story-file formats: /8 packed
addresses (512KB ceiling), 63 properties, 48 flags, 14-byte object
entries, 9-z-char dictionary words, v5 opcode forms (aread, EXT
save/restore, no header initial values). The v3 Zork engine files adapt
through the `zil/engine-v8` overlay (two constants and two routines
redefined; czil applies the last definition, so the originals are never
touched). The suite gates this with: Tiny Quest compiled as v8 must play
the byte-identical gameplay transcript to its v3 build.

`make wasm` builds `dist/czil.wasm` (~140 KB): a bare WebAssembly module
with no emscripten runtime. Its whole ABI is one host import
(`host.read_file`) plus stdio writes; `dist/czil-compile.mjs` is a
hand-rolled ~90 line Node loader. The wasm build produces byte-identical
story files to the native compiler and compiles all of Zork I in about
0.1 s - roughly 17x faster end to end than the original C# ZILF+ZAPF
pipeline on the same sources (1.7 s, dotnet 10, same machine).
