/*
 * zilvm stage 3: executing ZIL.
 *
 * czil's evaluator already runs MDL - COND, PROG, arithmetic, function
 * application. What it does not have is the *game* runtime: mutable
 * object locations, flags, globals that change during play, and the ~40
 * ZIL builtins the engine files call (MOVE, FSET, TELL, IN?, GETP...).
 *
 * This adds that layer. Objects and globals become mutable state, the
 * builtins register as SUBRs on the same evaluator, and PRINC output goes
 * to a buffer the host reads back - so a routine can be called directly
 * and its printed text compared against the Z-machine's.
 *
 * State lives here rather than in czil so the front end stays a pure
 * loader: it is linked by the compiler too, and a compiler must not carry
 * a play-time world.
 */
#ifndef ZILVM_RUNTIME_H
#define ZILVM_RUNTIME_H

#include "world.h"

/* Mutable per-object state. The world model is the immutable shape; this
 * is what changes during play. */
typedef struct {
    int parent;              /* index into objects, or -1 */
    int child;
    int sibling;
    unsigned long flags;     /* bit per flag index in zr_runtime.flag_names */
} zr_object_state;

typedef struct zr_runtime {
    zw_world *world;
    cz_ctx *ctx;

    zr_object_state *objects;
    size_t object_count;

    /* Flag atoms, interned once so FSET/FCLEAR/FSET? are bit ops. */
    const char **flag_names;
    size_t flag_count;

    /* Globals that change during play, by name. */
    struct { const char *name; cz_val *value; } *globals;
    size_t global_count, global_cap;

    /* Host-supplied RNG, so RANDOM-driven play is comparable against the
     * Z-machine rather than excluded from the comparison. */
    int (*random)(int range);

    /* Set by RFATAL/QUIT so the main loop can act rather than a builtin
     * calling exit(). */
    bool fatal;
    bool quit;

    /* Property writes: the declared model is immutable, so PUTP records
     * an override here. */
    struct { int obj; const char *prop; cz_val *value; } *puts;
    size_t put_count, put_cap;

    /* The clock. The engine keeps these in a ZIL table and indexes it
     * with vector arithmetic; a parallel list keyed by routine name has
     * the same semantics and survives being read by the host. */
    struct { const char *routine; int tick; bool enabled; } *timers;
    size_t timer_count, timer_cap;

    char err[512];
} zr_runtime;

/** Build runtime state from a loaded world and register the ZIL builtins. */
zr_runtime *zr_new(zw_world *world);
void zr_free(zr_runtime *r);

/** Call a routine by name; returns false on error (message in r->err). */
bool zr_call(zr_runtime *r, const char *routine, cz_val **result);
bool zr_call_args(zr_runtime *r, const char *routine, cz_val **args, size_t argc,
                  cz_val **result);

/** Text printed since the last clear, and a way to clear it. */
const char *zr_output(zr_runtime *r);
void zr_clear_output(zr_runtime *r);

/* Object queries the host and the LLM layer need. Indices are into
 * world->objects, so they line up with the model. */
int zr_object_index(const zr_runtime *r, const char *name);
int zr_parent(const zr_runtime *r, int obj);
void zr_move(zr_runtime *r, int obj, int dest);
bool zr_flag(const zr_runtime *r, int obj, const char *flag);
void zr_set_flag(zr_runtime *r, int obj, const char *flag, bool on);

/** Globals, by name. */
void zr_put_property(zr_runtime *r, int obj, const char *prop, cz_val *value);
cz_val *zr_get_property(zr_runtime *r, int obj, const char *prop);
cz_val *zr_global(zr_runtime *r, const char *name);
void zr_set_global(zr_runtime *r, const char *name, cz_val *value);

#endif
