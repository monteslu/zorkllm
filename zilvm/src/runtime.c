/* zilvm stage 3: the play-time runtime. See runtime.h for the split
 * between immutable world shape and mutable game state. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "runtime.h"

/* The evaluator's SUBRs take no user data, so the active runtime is
 * process-global. One game runs at a time in this process; a host that
 * needs more runs more processes, which is also how it will be sandboxed
 * on a phone. */
static zr_runtime *ACTIVE;

static const char *atom_name(const cz_val *v) {
    return (v && v->type == CZ_ATOM) ? v->atom.name : NULL;
}

static cz_result ok_val(cz_val *v) { cz_result r = {0}; r.flow = CZ_F_NORMAL; r.val = v; return r; }

static cz_val *truth(cz_ctx *c) { return cz_new_fix(c, 1); }

int zr_object_index(const zr_runtime *r, const char *name) {
    if (!name) return -1;
    for (size_t i = 0; i < r->world->object_count; i++) {
        if (r->world->objects[i].name && strcmp(r->world->objects[i].name, name) == 0) {
            return (int)i;
        }
    }
    return -1;
}

/** Resolve an argument that may be an atom naming an object. */
static int arg_object(const zr_runtime *r, cz_val *v) {
    const char *n = atom_name(v);
    if (n) return zr_object_index(r, n);
    if (v && v->type == CZ_FIX) return (int)v->fix.value;
    return -1;
}

static int flag_index(zr_runtime *r, const char *name) {
    for (size_t i = 0; i < r->flag_count; i++) {
        if (strcmp(r->flag_names[i], name) == 0) return (int)i;
    }
    return -1;
}

bool zr_flag(const zr_runtime *r, int obj, const char *flag) {
    if (obj < 0 || (size_t)obj >= r->object_count) return false;
    int f = flag_index((zr_runtime *)r, flag);
    if (f < 0 || f >= 64) return false;
    return (r->objects[obj].flags >> f) & 1ul;
}

void zr_set_flag(zr_runtime *r, int obj, const char *flag, bool on) {
    if (obj < 0 || (size_t)obj >= r->object_count) return;
    int f = flag_index(r, flag);
    if (f < 0 || f >= 64) return;
    if (on) r->objects[obj].flags |= (1ul << f);
    else r->objects[obj].flags &= ~(1ul << f);
}

int zr_parent(const zr_runtime *r, int obj) {
    if (obj < 0 || (size_t)obj >= r->object_count) return -1;
    return r->objects[obj].parent;
}

/** Unlink obj from its parent's child chain, then link under dest. */
void zr_move(zr_runtime *r, int obj, int dest) {
    if (obj < 0 || (size_t)obj >= r->object_count) return;
    int old = r->objects[obj].parent;
    if (old >= 0) {
        int *link = &r->objects[old].child;
        while (*link >= 0 && *link != obj) link = &r->objects[*link].sibling;
        if (*link == obj) *link = r->objects[obj].sibling;
    }
    r->objects[obj].sibling = -1;
    r->objects[obj].parent = dest;
    if (dest >= 0 && (size_t)dest < r->object_count) {
        r->objects[obj].sibling = r->objects[dest].child;
        r->objects[dest].child = obj;
    }
}

cz_val *zr_global(zr_runtime *r, const char *name) {
    for (size_t i = 0; i < r->global_count; i++) {
        if (strcmp(r->globals[i].name, name) == 0) return r->globals[i].value;
    }
    return cz_false(r->ctx);
}

void zr_set_global(zr_runtime *r, const char *name, cz_val *value) {
    for (size_t i = 0; i < r->global_count; i++) {
        if (strcmp(r->globals[i].name, name) == 0) { r->globals[i].value = value; return; }
    }
    if (r->global_count == r->global_cap) {
        r->global_cap = r->global_cap ? r->global_cap * 2 : 64;
        r->globals = realloc(r->globals, r->global_cap * sizeof *r->globals);
    }
    r->globals[r->global_count].name = name;
    r->globals[r->global_count].value = value;
    r->global_count++;
}

/* ---- ZIL builtins ---------------------------------------------------
 * The engine files call these constantly. Each is small; the value is
 * that they operate on named state, so a divergence from the Z-machine
 * points at a routine rather than a byte offset. */

static cz_result f_move(cz_ctx *c, cz_val **a, size_t n) {
    if (n < 2) return ok_val(cz_false(c));
    zr_move(ACTIVE, arg_object(ACTIVE, a[0]), arg_object(ACTIVE, a[1]));
    return ok_val(truth(c));
}

static cz_result f_remove(cz_ctx *c, cz_val **a, size_t n) {
    if (n < 1) return ok_val(cz_false(c));
    zr_move(ACTIVE, arg_object(ACTIVE, a[0]), -1);
    return ok_val(truth(c));
}

static cz_result f_loc(cz_ctx *c, cz_val **a, size_t n) {
    if (n < 1) return ok_val(cz_false(c));
    int p = zr_parent(ACTIVE, arg_object(ACTIVE, a[0]));
    if (p < 0) return ok_val(cz_false(c));
    return ok_val(cz_intern(c, ACTIVE->world->objects[p].name,
                            strlen(ACTIVE->world->objects[p].name)));
}

static cz_result f_inp(cz_ctx *c, cz_val **a, size_t n) {
    if (n < 2) return ok_val(cz_false(c));
    int obj = arg_object(ACTIVE, a[0]), want = arg_object(ACTIVE, a[1]);
    return ok_val(zr_parent(ACTIVE, obj) == want ? truth(c) : cz_false(c));
}

static cz_result f_fset(cz_ctx *c, cz_val **a, size_t n) {
    if (n < 2) return ok_val(cz_false(c));
    zr_set_flag(ACTIVE, arg_object(ACTIVE, a[0]), atom_name(a[1]), true);
    return ok_val(truth(c));
}

static cz_result f_fclear(cz_ctx *c, cz_val **a, size_t n) {
    if (n < 2) return ok_val(cz_false(c));
    zr_set_flag(ACTIVE, arg_object(ACTIVE, a[0]), atom_name(a[1]), false);
    return ok_val(truth(c));
}

static cz_result f_fsetp(cz_ctx *c, cz_val **a, size_t n) {
    if (n < 2) return ok_val(cz_false(c));
    bool set = zr_flag(ACTIVE, arg_object(ACTIVE, a[0]), atom_name(a[1]));
    return ok_val(set ? truth(c) : cz_false(c));
}

/* TELL is a macro in the engine files, but games call it with a mix of
 * strings, CR/CRLF and D <object>; handling it directly means routines
 * that print can be executed and compared before macros are wired up. */
static cz_result f_tell(cz_ctx *c, cz_val **a, size_t n) {
    for (size_t i = 0; i < n; i++) {
        const char *kw = atom_name(a[i]);
        if (kw && (strcmp(kw, "CR") == 0 || strcmp(kw, "CRLF") == 0)) {
            cz_princ(c, "\n");
        } else if (kw && strcmp(kw, "D") == 0 && i + 1 < n) {
            int obj = arg_object(ACTIVE, a[++i]);
            const char *desc = obj >= 0 ? ACTIVE->world->objects[obj].desc : NULL;
            if (desc) cz_princ(c, desc);
        } else if (a[i] && a[i]->type == CZ_STRING) {
            cz_princ(c, a[i]->str.text);
        }
    }
    return ok_val(truth(c));
}

/* GETP/PUTP: property access by NAME. In a story file this is a numbered
 * lookup whose meaning you must reverse-engineer; here the property atom
 * is the key, which is the entire point of running from source. */
static cz_result f_getp(cz_ctx *c, cz_val **a, size_t n) {
    if (n < 2) return ok_val(cz_false(c));
    int obj = arg_object(ACTIVE, a[0]);
    const char *want = atom_name(a[1]);
    if (obj < 0 || !want) return ok_val(cz_false(c));
    /* Strip the P? prefix the engine files use: <GETP .RM ,P?LDESC>. */
    if (want[0] == 'P' && want[1] == '?') want += 2;
    const zm_object *src = &ACTIVE->world->game->objects[obj];
    for (size_t p = 0; p < src->prop_count; p++) {
        const char *head = atom_name(src->props[p].head);
        if (head && strcmp(head, want) == 0 && src->props[p].count > 0) {
            return ok_val(src->props[p].body[0]);
        }
    }
    return ok_val(cz_false(c));
}

static cz_result f_printn(cz_ctx *c, cz_val **a, size_t n) {
    if (n < 1) return ok_val(cz_false(c));
    char buf[32];
    long v = (a[0] && a[0]->type == CZ_FIX) ? (long)a[0]->fix.value : 0;
    snprintf(buf, sizeof buf, "%ld", v);
    cz_princ(c, buf);
    return ok_val(truth(c));
}

static cz_result f_crlf(cz_ctx *c, cz_val **a, size_t n) {
    (void)a; (void)n;
    cz_princ(c, "\n");
    return ok_val(truth(c));
}

/* Bit operations the engine uses for flag words and version checks. */
static cz_result f_band(cz_ctx *c, cz_val **a, size_t n) {
    long v = -1;
    for (size_t i = 0; i < n; i++) v &= (a[i] && a[i]->type == CZ_FIX) ? a[i]->fix.value : 0;
    return ok_val(cz_new_fix(c, (int32_t)v));
}

static cz_result f_bor(cz_ctx *c, cz_val **a, size_t n) {
    long v = 0;
    for (size_t i = 0; i < n; i++) v |= (a[i] && a[i]->type == CZ_FIX) ? a[i]->fix.value : 0;
    return ok_val(cz_new_fix(c, (int32_t)v));
}

/* GET/GETB read table elements. Tables are first-class values in the
 * model, so this indexes the real thing rather than raw memory. */
static cz_result f_get(cz_ctx *c, cz_val **a, size_t n) {
    if (n < 2 || !a[0] || a[0]->type != CZ_TABLE) return ok_val(cz_false(c));
    long idx = (a[1] && a[1]->type == CZ_FIX) ? a[1]->fix.value : 0;
    if (idx < 0 || (size_t)idx >= a[0]->tab.count) return ok_val(cz_false(c));
    return ok_val(a[0]->tab.items[idx]);
}

static cz_result f_printc(cz_ctx *c, cz_val **a, size_t n) {
    if (n < 1 || !a[0] || a[0]->type != CZ_FIX) return ok_val(cz_false(c));
    char ch[2] = { (char)a[0]->fix.value, 0 };
    cz_princ(c, ch);
    return ok_val(truth(c));
}

static cz_result f_princ(cz_ctx *c, cz_val **a, size_t n) {
    for (size_t i = 0; i < n; i++) {
        if (a[i] && a[i]->type == CZ_STRING) cz_princ(c, a[i]->str.text);
    }
    return ok_val(truth(c));
}

zr_runtime *zr_new(zw_world *world) {
    zr_runtime *r = calloc(1, sizeof *r);
    r->world = world;
    r->ctx = world->ctx;
    r->object_count = world->object_count;
    r->objects = calloc(r->object_count ? r->object_count : 1, sizeof *r->objects);

    /* Distinct flag atoms, so FSET? is a bit test rather than a string
     * compare in the hot path. */
    size_t cap = 64;
    r->flag_names = calloc(cap, sizeof *r->flag_names);
    for (size_t i = 0; i < world->object_count; i++) {
        for (size_t f = 0; f < world->objects[i].flag_count; f++) {
            const char *name = world->objects[i].flags[f];
            bool seen = false;
            for (size_t k = 0; k < r->flag_count; k++) {
                if (strcmp(r->flag_names[k], name) == 0) { seen = true; break; }
            }
            if (seen) continue;
            if (r->flag_count == cap) {
                cap *= 2;
                r->flag_names = realloc(r->flag_names, cap * sizeof *r->flag_names);
            }
            r->flag_names[r->flag_count++] = name;
        }
    }

    /* Initial tree and flags from the declared model. */
    for (size_t i = 0; i < r->object_count; i++) {
        r->objects[i].parent = r->objects[i].child = r->objects[i].sibling = -1;
    }
    for (size_t i = 0; i < r->object_count; i++) {
        int parent = zr_object_index(r, world->objects[i].parent);
        if (parent >= 0) zr_move(r, (int)i, parent);
        for (size_t f = 0; f < world->objects[i].flag_count; f++) {
            zr_set_flag(r, (int)i, world->objects[i].flags[f], true);
        }
    }

    /* The engine refers to properties and flags as P?NAME / F?NAME
     * constants. In a compiled game these are numbers; here the atom
     * itself is the key, so bind each to itself and let GETP/FSET? read
     * the name. This is the metadata that compilation destroys, kept. */
    for (size_t i = 0; i < world->game->propname_count; i++) {
        const char *pn = atom_name(world->game->propnames[i]);
        if (!pn) continue;
        char buf[128];
        snprintf(buf, sizeof buf, "P?%s", pn);
        cz_setg(r->ctx, cz_intern(r->ctx, buf, strlen(buf)),
                cz_intern(r->ctx, pn, strlen(pn)));
    }
    for (size_t i = 0; i < r->flag_count; i++) {
        char buf[128];
        snprintf(buf, sizeof buf, "F?%s", r->flag_names[i]);
        cz_setg(r->ctx, cz_intern(r->ctx, buf, strlen(buf)),
                cz_intern(r->ctx, r->flag_names[i], strlen(r->flag_names[i])));
    }

    ACTIVE = r;
    cz_def_subr(r->ctx, "MOVE", f_move, false);
    cz_def_subr(r->ctx, "REMOVE", f_remove, false);
    cz_def_subr(r->ctx, "LOC", f_loc, false);
    cz_def_subr(r->ctx, "IN?", f_inp, false);
    cz_def_subr(r->ctx, "FSET", f_fset, false);
    cz_def_subr(r->ctx, "FCLEAR", f_fclear, false);
    cz_def_subr(r->ctx, "FSET?", f_fsetp, false);
    cz_def_subr(r->ctx, "TELL", f_tell, false);
    cz_def_subr(r->ctx, "PRINTI", f_princ, false);
    cz_def_subr(r->ctx, "PRINTR", f_princ, false);
    cz_def_subr(r->ctx, "GETP", f_getp, false);
    cz_def_subr(r->ctx, "PRINTN", f_printn, false);
    cz_def_subr(r->ctx, "CRLF", f_crlf, false);
    cz_def_subr(r->ctx, "BAND", f_band, false);
    cz_def_subr(r->ctx, "BOR", f_bor, false);
    cz_def_subr(r->ctx, "GET", f_get, false);
    cz_def_subr(r->ctx, "GETB", f_get, false);
    cz_def_subr(r->ctx, "PRINTC", f_printc, false);
    return r;
}

void zr_free(zr_runtime *r) {
    if (!r) return;
    if (ACTIVE == r) ACTIVE = NULL;
    free(r->objects);
    free((void *)r->flag_names);
    free(r->globals);
    free(r);
}

bool zr_call_args(zr_runtime *r, const char *name, cz_val **args, size_t argc,
                  cz_val **result) {
    ACTIVE = r;
    zm_game *g = r->world->game;
    for (size_t i = 0; i < g->routine_count; i++) {
        const char *rn = atom_name(g->routines[i].name);
        if (!rn || strcmp(rn, name) != 0) continue;
        /* A ROUTINE is a FUNCTION: argspec plus body. Applying it through
         * the evaluator binds parameters and "AUX" locals properly, which
         * evaluating the body forms directly does not - that reports
         * "atom has no local value" on the first parameter reference. */
        /* Build #FUNCTION ((argspec) body...) from public pieces rather
         * than reaching into the evaluator: CHTYPE of a list to FUNCTION
         * is exactly what <FUNCTION ...> evaluates to. */
        size_t parts = g->routines[i].body_count + 1;
        cz_val **items = calloc(parts, sizeof *items);
        items[0] = g->routines[i].spec;
        for (size_t b = 0; b < g->routines[i].body_count; b++) {
            items[b + 1] = g->routines[i].body[b];
        }
        cz_val *list = cz_new_seq(r->ctx, CZ_LIST, items, parts);
        cz_val *fn = cz_new_chtype(r->ctx, cz_intern(r->ctx, "FUNCTION", 8), list);
        cz_result made = cz_eval(r->ctx, fn);
        free(items);
        if (made.flow == CZ_F_ERROR) {
            snprintf(r->err, sizeof r->err, "%s: %s", name, cz_error(r->ctx));
            return false;
        }
        fn = made.val;
        cz_result out = cz_apply(r->ctx, fn, args, argc, false);
        if (out.flow == CZ_F_ERROR) {
            snprintf(r->err, sizeof r->err, "%s: %s", name, cz_error(r->ctx));
            return false;
        }
        if (result) *result = out.val;
        return true;
    }
    snprintf(r->err, sizeof r->err, "no such routine: %s", name);
    return false;
}

bool zr_call(zr_runtime *r, const char *name, cz_val **result) {
    return zr_call_args(r, name, NULL, 0, result);
}

const char *zr_output(zr_runtime *r) { return cz_output(r->ctx); }
void zr_clear_output(zr_runtime *r) { cz_clear_output(r->ctx); }
