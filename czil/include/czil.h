/* czil - C port of ZILF (Copyright 2010-2023 Tara McGrew).
 * GPL-3.0-or-later; see czil/LICENSE. */
#ifndef CZIL_H
#define CZIL_H

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>

/* ---- arena ---- */

typedef struct cz_arena cz_arena;

cz_arena *cz_arena_new(void);
void *cz_alloc(cz_arena *a, size_t size);
char *cz_strdup(cz_arena *a, const char *s, size_t len);
void cz_arena_free(cz_arena *a);

/* ---- values ----
 * The subset of ZILF's ZilObject hierarchy the reader produces.
 * (Upstream: Zilf/Interpreter/Values/)
 */

typedef enum {
    CZ_ATOM,      /* interned symbol */
    CZ_FIX,       /* 32-bit integer */
    CZ_STRING,
    CZ_CHAR,      /* !\x character literal */
    CZ_LIST,      /* (...) */
    CZ_FORM,      /* <...>  (empty form <> is FALSE) */
    CZ_VECTOR,    /* [...] and ![...] */
    CZ_SEGMENT,   /* !<...>, !.X, !,X, !'X */
    CZ_ADECL,     /* value:decl */
    CZ_READEVAL,  /* %<...>  - deferred read-time eval (stage 3) */
    CZ_READEVAL2, /* %%<...> - deferred, result dropped */
    CZ_CHTYPE,    /* #type value - deferred CHTYPE (stage 3) */
    /* evaluator types (stage 3) */
    CZ_FALSE,     /* #FALSE (...) - the only falsy type in MDL */
    CZ_FUNCTION,  /* #FUNCTION ((argspec) body...) */
    CZ_MACRO,     /* DEFMAC result: applies inner fn unevaluated, evals result */
    CZ_SUBR,      /* builtin; evaluates its args */
    CZ_FSUBR,     /* builtin; receives raw args */
    CZ_SPLICE,    /* multiple values spliced into the enclosing structure */
    CZ_TABLE,     /* Z-machine table (stage 4): TABLE/LTABLE/ITABLE/PTABLE */
} cz_type;

typedef struct cz_val cz_val;
struct cz_val {
    cz_type type;
    int line;
    union {
        struct { const char *name; } atom;   /* interned; pointer-comparable */
        struct { int32_t value; } fix;
        struct { const char *text; size_t len; } str;
        struct { int ch; } chr;
        struct {
            cz_val **items; size_t count;
            /* list-primtype sharing (MDL cons semantics): REST returns a
             * view into `owner`'s storage so PUTREST through any alias is
             * seen by the whole chain; NULL owner = this value owns items */
            cz_val *owner; size_t off;
        } seq;                                            /* LIST/FORM/VECTOR */
        struct { cz_val **items; size_t count; uint32_t tflags; } tab; /* TABLE;
            first two fields mirror seq so generic structure ops apply */
        struct { cz_val *inner; } seg;                    /* SEGMENT/READEVAL(2) */
        struct { cz_val *value; cz_val *decl; } adecl;
        struct { cz_val *type_atom; cz_val *value; } chtype;
        struct { cz_val *spec; cz_val **body; size_t body_count; const char *name; } func;
        struct { void *fn; const char *name; } subr;   /* cz_subr_fn */
    };
};

/* ---- context: arena + atom intern table ---- */

typedef struct cz_ctx cz_ctx;

cz_ctx *cz_ctx_new(void);
void cz_ctx_free(cz_ctx *c);
cz_arena *cz_ctx_arena(cz_ctx *c);
cz_val *cz_intern(cz_ctx *c, const char *name, size_t len); /* returns CZ_ATOM */

cz_val *cz_new_fix(cz_ctx *c, int32_t v);
cz_val *cz_new_string(cz_ctx *c, const char *text, size_t len);
cz_val *cz_new_char(cz_ctx *c, int ch);
cz_val *cz_new_seq(cz_ctx *c, cz_type t, cz_val **items, size_t count);
cz_val *cz_new_wrap(cz_ctx *c, cz_type t, cz_val *inner);
cz_val *cz_new_adecl(cz_ctx *c, cz_val *value, cz_val *decl);
cz_val *cz_new_chtype(cz_ctx *c, cz_val *type_atom, cz_val *value);

/* ---- reader ----
 * Port of Zilf/Language/Parsing/Parser.cs. Parses one source text into
 * top-level objects. Comments (;...) are dropped, as upstream does inside
 * structures; top-level comments are dropped too.
 */

typedef struct {
    cz_val **items;    /* top-level objects, arena-allocated */
    size_t count;
    bool ok;
    char error[256];   /* valid when !ok */
    int error_line;
} cz_parse_result;

cz_parse_result cz_parse(cz_ctx *c, const char *src, size_t len);

/* ---- evaluator (stage 3) ----
 * Port of the Zilf/Interpreter core: dynamic scoping, FORM application
 * (GVAL then LVAL lookup), COND/AND/OR/PROG/REPEAT, DEFINE/DEFMAC,
 * MAPF/MAPR with MAPRET/MAPSTOP, and ~60 SUBRs.
 * Control flow travels in cz_result rather than exceptions.
 */

typedef enum {
    CZ_F_NORMAL = 0,
    CZ_F_RETURN,   /* RETURN out of nearest PROG/REPEAT */
    CZ_F_AGAIN,    /* AGAIN: restart nearest PROG/REPEAT body */
    CZ_F_MAPRET,   /* MAPRET: val is a CZ_SPLICE of values for MAPF */
    CZ_F_MAPSTOP,  /* MAPSTOP: like MAPRET, then stop mapping */
    CZ_F_ERROR,    /* message in cz_error(ctx) */
} cz_flow;

typedef struct {
    cz_flow flow;
    cz_val *val;
} cz_result;

typedef cz_result (*cz_subr_fn)(cz_ctx *c, cz_val **args, size_t n);

void cz_eval_init(cz_ctx *c);            /* register builtins; call once */

/* Register a SUBR (arguments evaluated) or FSUBR (arguments raw). This is
 * how a consumer supplies its own builtins: the Z-model registers the
 * game directives this way, and an interpreter registers the play-time
 * primitives (MOVE, FSET, TELL) the same way. Public because supplying a
 * back end is the intended use of the front end. */
void cz_def_subr(cz_ctx *c, const char *name, cz_subr_fn fn, bool fsubr);
/* Set a global (GVAL) binding. A consumer seeding the constants a game
 * expects - P?LDESC, F?TAKEBIT - writes them through here. */
void cz_setg(cz_ctx *c, cz_val *atom, cz_val *value);
cz_result cz_eval(cz_ctx *c, cz_val *v);
cz_result cz_apply(cz_ctx *c, cz_val *target, cz_val **args, size_t n, bool eval_args);
const char *cz_error(cz_ctx *c);
cz_val *cz_false(cz_ctx *c);
bool cz_is_true(const cz_val *v);
const char *cz_output(cz_ctx *c);        /* accumulated PRINC/CRLF output */
/* Append to that output. A consumer supplying its own print builtins
 * (TELL, PRINTI) writes through here so all output lands in one place. */
void cz_princ(cz_ctx *c, const char *text);
void cz_clear_output(cz_ctx *c);

/* ---- printer (round-trip debugging) ---- */

/* Append the printed representation of v to a malloc'd growing buffer.
 * Caller frees *buf. */
void cz_print(const cz_val *v, char **buf, size_t *len, size_t *cap);

#endif
