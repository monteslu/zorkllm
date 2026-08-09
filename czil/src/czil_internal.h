/* czil - C port of ZILF (Copyright 2010-2023 Tara McGrew).
 * GPL-3.0-or-later; see czil/LICENSE.
 * Shared internals between value.c and eval.c. */
#ifndef CZIL_INTERNAL_H
#define CZIL_INTERNAL_H
#include "czil.h"

typedef struct intern_entry {
    struct intern_entry *next;
    cz_val *atom;
} intern_entry;

#define INTERN_BUCKETS 4096
#define GLOBAL_BUCKETS 1024

typedef struct binding {
    struct binding *next;
    cz_val *atom;
    cz_val *value;   /* NULL = unassigned */
} binding;

typedef struct frame {
    struct frame *parent;
    binding *bindings;
} frame;

struct cz_ctx {
    cz_arena *arena;
    intern_entry *buckets[INTERN_BUCKETS];
    /* evaluator state */
    binding *globals[GLOBAL_BUCKETS];
    frame *env;              /* innermost local frame (root frame at bottom) */
    frame root_frame;
    cz_val *false_obj;       /* canonical #FALSE () */
    char err[512];
    char *out;               /* PRINC output buffer */
    size_t out_len, out_cap;
    void *user;              /* zm_game during model building */
};

uint32_t cz_hash_ptr(const void *p);

/* eval.c internals shared with zmodel.c */
void cz_setg(cz_ctx *c, cz_val *atom, cz_val *value);
cz_val *cz_getg(cz_ctx *c, cz_val *atom);
void cz_def_subr(cz_ctx *c, const char *name, cz_subr_fn fn, bool fsubr);

#endif
