/* czil - C port of ZILF (Copyright 2010-2023 Tara McGrew).
 * GPL-3.0-or-later; see czil/LICENSE.
 *
 * Stage 4: the Z-model. Game directives (OBJECT/ROOM/ROUTINE/SYNTAX/
 * GLOBAL/CONSTANT/TABLE family/SYNONYM/BUZZ/DIRECTIONS/PROPDEF/
 * INSERT-FILE/VERSION) register as SUBRs on the stage-3 evaluator and
 * populate this model as the sources evaluate.
 * Upstream: Zilf/ZModel/ZEnvironment.cs, Zilf/Interpreter/Subrs.ZModel.cs.
 */
#ifndef CZIL_ZMODEL_H
#define CZIL_ZMODEL_H

#include "czil.h"

/* part-of-speech bits for vocabulary words */
enum {
    ZM_POS_NOUN = 1, ZM_POS_ADJ = 2, ZM_POS_VERB = 4,
    ZM_POS_PREP = 8, ZM_POS_DIR = 16, ZM_POS_BUZZ = 32,
};

/* table flags (cz_val.tab.tflags) */
enum {
    ZM_TBL_BYTE = 1,      /* elements are bytes */
    ZM_TBL_LENGTH = 2,    /* length-prefixed (LTABLE) */
    ZM_TBL_PURE = 4,      /* read-only (PTABLE / (PURE)) */
    ZM_TBL_LEXV = 8,      /* sread parse buffer: count/pad prefix + word-byte-byte */
};

typedef struct { cz_val *head; cz_val **body; size_t count; } zm_prop;

typedef struct {
    cz_val *name;
    bool is_room;
    const char *desc;     /* DESC string, or NULL */
    cz_val *parent;       /* (IN atom) / (LOC atom), or NULL */
    zm_prop *props;       /* every clause, raw, in source order */
    size_t prop_count;
} zm_object;

typedef struct { cz_val *name; cz_val *value; } zm_binding_rec;
typedef struct { cz_val *name; cz_val *spec; cz_val **body; size_t body_count; } zm_routine;

typedef struct {
    cz_val *verb;
    int num_objects;      /* 0..2 */
    cz_val *prep[2];      /* preposition before each OBJECT slot, or NULL */
    cz_val *find[2];      /* (FIND flag) for each slot, or NULL */
    cz_val *action;       /* V-... routine atom */
    cz_val *preaction;    /* PRE-... routine atom, or NULL */
    cz_val *raw;          /* the whole <SYNTAX ...> form for stage 5 */
} zm_syntax;

typedef struct { const char *text; unsigned pos; } zm_word;
typedef struct { cz_val *first; cz_val **rest; size_t count; } zm_synonym;
typedef struct { cz_val *name; cz_val **body; size_t count; } zm_propdef;

typedef struct zm_game {
    int zversion;
    const char *sname;                 /* SNAME, or NULL */
    char base_dir[1024];               /* for INSERT-FILE resolution */
    char include_dirs[4][1024];        /* extra INSERT-FILE search paths (-I) */
    size_t include_count;

    zm_object *objects;      size_t object_count, object_cap;
    zm_binding_rec *globals; size_t global_count, global_cap;
    zm_binding_rec *constants; size_t constant_count, constant_cap;
    zm_routine *routines;    size_t routine_count, routine_cap;
    zm_syntax *syntaxes;     size_t syntax_count, syntax_cap;
    cz_val **directions;     size_t direction_count, direction_cap;
    cz_val **buzz;           size_t buzz_count, buzz_cap;
    zm_synonym *synonyms;    size_t synonym_count, synonym_cap;
    zm_propdef *propdefs;    size_t propdef_count, propdef_cap;
    cz_val **tables;         size_t table_count, table_cap;
    cz_val **flags;          size_t flag_count, flag_cap;       /* distinct flag atoms */
    cz_val **propnames;      size_t propname_count, propname_cap; /* distinct property heads */
    zm_word *words;          size_t word_count, word_cap;       /* built by zm_finalize */

    char err[1024];
} zm_game;

zm_game *zm_new(void);
void zm_free(zm_game *g);

/* Register the directive SUBRs and the ZILF-standard globals
 * (ZILCH/ZILF/PREDGEN = T, SIBREAKS = ",.\"", PLUS-MODE = <>). */
void zm_install(cz_ctx *c, zm_game *g);

/* Load one .zil file: parse, expand read-macros, evaluate each top-level
 * object. INSERT-FILE recurses through here. false on error (g->err). */
bool zm_load_file(cz_ctx *c, zm_game *g, const char *path);

/* Pluggable file reader (WASM hosts route this to an import). Returns a
 * malloc'd buffer or NULL; default implementation uses stdio. */
typedef char *(*zm_read_fn)(const char *path, size_t *len);
void zm_set_file_reader(zm_read_fn fn);

/* Build the vocabulary and run cross-checks (syntax actions defined,
 * parents exist, v3 flag/property limits). false on error (g->err). */
bool zm_finalize(cz_ctx *c, zm_game *g);

/* Debug survey: print distinct FORM heads in routine bodies after macro
 * expansion, with counts and a classification. */
void zm_survey_heads(cz_ctx *c, zm_game *g);

/* ---- v3 dictionary word codec (src/ztext.c) ---- */

/* Encode text as a v3 dictionary entry: 6 z-chars in 4 bytes. */
void zt_encode_word(const char *text, uint8_t out[4]);
/* Decode a 4-byte v3 dictionary entry; returns length. */
size_t zt_decode_word(const uint8_t in[4], char *out, size_t cap);
/* Encode arbitrary text as v3 z-text (no abbreviations); emits packed
 * words via the callback, returns the word count. */
size_t zt_encode_string(const char *text, size_t len,
                        void (*emit_word)(void *ud, uint16_t w), void *ud);

/* ---- stage 5: compile the model to a .z3 story file (src/zcode.c) ---- */

typedef struct {
    int release;            /* header release number (default 1) */
    const char *serial;     /* 6-char serial (default "000000") */
} zc_options;

bool zc_compile(cz_ctx *c, zm_game *g, const zc_options *opt,
                const char *out_path, char *err, size_t errsz);

/* With out_path NULL, zc_compile keeps the story bytes in memory instead
 * of writing a file; fetch them here (valid until the next compile). */
const unsigned char *zc_output_bytes(size_t *len);

#endif
