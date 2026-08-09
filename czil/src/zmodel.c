/* czil - C port of ZILF (Copyright 2010-2023 Tara McGrew).
 * GPL-3.0-or-later; see czil/LICENSE.
 *
 * Stage 4: Z-model building. The game directives are SUBRs/FSUBRs that
 * append to the zm_game hanging off cz_ctx->user, so plain evaluation of
 * the source files (including directives inside top-level CONDs) builds
 * the model, exactly as MDL compilation worked.
 *
 * Upstream: Subrs.ZModel.cs (OBJECT/ROOM/ROUTINE/GLOBAL/CONSTANT/...),
 * ZModel/Syntax.cs (SYNTAX parsing), Compiler/Compilation.Objects.cs
 * (vocab from SYNONYM/ADJECTIVE/PSEUDO/FLAGS), Context.cs (standard
 * globals: ZILCH/ZILF/PREDGEN = T, SIBREAKS = ",.\"").
 */
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdarg.h>
#include "zmodel.h"
#include "czil_internal.h"

static cz_result zerr(cz_ctx *c, const char *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    vsnprintf(c->err, sizeof c->err, fmt, ap);
    va_end(ap);
    return (cz_result){ CZ_F_ERROR, NULL };
}

static cz_result ok(cz_val *v) { return (cz_result){ CZ_F_NORMAL, v }; }

static bool zm_load_source(cz_ctx *c, zm_game *g, const char *src, size_t len,
                           const char *path);
static char *slurp(const char *path, size_t *len);

#define GAME(c) ((zm_game *)(c)->user)

/* generic growable-array push */
#define ZPUSH(g, arr, count, cap, val) do { \
    if ((g)->count >= (g)->cap) { \
        (g)->cap = (g)->cap ? (g)->cap * 2 : 16; \
        (g)->arr = realloc((g)->arr, (g)->cap * sizeof(*(g)->arr)); \
        if (!(g)->arr) abort(); \
    } \
    (g)->arr[(g)->count++] = (val); \
} while (0)

zm_game *zm_new(void) {
    zm_game *g = calloc(1, sizeof(*g));
    if (!g) abort();
    g->zversion = 3;
    return g;
}

void zm_free(zm_game *g) {
    if (!g) return;
    for (size_t i = 0; i < g->object_count; i++) free(g->objects[i].props);
    free(g->objects); free(g->globals); free(g->constants);
    for (size_t i = 0; i < g->routine_count; i++) free(g->routines[i].body);
    free(g->routines); free(g->syntaxes); free(g->directions); free(g->buzz);
    for (size_t i = 0; i < g->synonym_count; i++) free(g->synonyms[i].rest);
    free(g->synonyms);
    for (size_t i = 0; i < g->propdef_count; i++) free(g->propdefs[i].body);
    free(g->propdefs); free(g->tables); free(g->flags); free(g->propnames);
    free(g->words);
    free(g);
}

/* ---- read-macro expansion pass ----
 * Upstream evaluates %<...> during parsing, so the expansion happens
 * everywhere, including inside quoted structures and FSUBR arguments.
 * Our reader defers them; this pass replays that: rebuild the tree with
 * every READEVAL replaced by its value (SPLICEs splice, READEVAL2
 * contributes nothing). */
static bool zm_expand(cz_ctx *c, cz_val *v, cz_val **out);

static bool expand_children(cz_ctx *c, cz_val *v, cz_val ***items_out, size_t *count_out) {
    cz_val **items = NULL;
    size_t n = 0, cap = 0;
    for (size_t i = 0; i < v->seq.count; i++) {
        cz_val *child = v->seq.items[i];
        if (child->type == CZ_READEVAL || child->type == CZ_READEVAL2) {
            cz_result r = cz_eval(c, child->seg.inner);
            if (r.flow != CZ_F_NORMAL) { free(items); return false; }
            if (child->type == CZ_READEVAL2) continue;
            cz_val *rv;
            if (!zm_expand(c, r.val, &rv)) { free(items); return false; }
            if (rv->type == CZ_SPLICE) {
                for (size_t j = 0; j < rv->seq.count; j++) {
                    if (n >= cap) { cap = cap ? cap * 2 : 8; items = realloc(items, cap * sizeof(*items)); if (!items) abort(); }
                    items[n++] = rv->seq.items[j];
                }
            } else {
                if (n >= cap) { cap = cap ? cap * 2 : 8; items = realloc(items, cap * sizeof(*items)); if (!items) abort(); }
                items[n++] = rv;
            }
        } else {
            cz_val *rv;
            if (!zm_expand(c, child, &rv)) { free(items); return false; }
            if (n >= cap) { cap = cap ? cap * 2 : 8; items = realloc(items, cap * sizeof(*items)); if (!items) abort(); }
            items[n++] = rv;
        }
    }
    *items_out = items;
    *count_out = n;
    return true;
}

static bool zm_expand(cz_ctx *c, cz_val *v, cz_val **out) {
    switch (v->type) {
    case CZ_READEVAL: {
        cz_result r = cz_eval(c, v->seg.inner);
        if (r.flow != CZ_F_NORMAL) return false;
        return zm_expand(c, r.val, out);
    }
    case CZ_READEVAL2: {
        cz_result r = cz_eval(c, v->seg.inner);
        if (r.flow != CZ_F_NORMAL) return false;
        *out = cz_new_seq(c, CZ_SPLICE, NULL, 0);
        return true;
    }
    case CZ_LIST: case CZ_FORM: case CZ_VECTOR: case CZ_FALSE: {
        cz_val **items; size_t n;
        if (!expand_children(c, v, &items, &n)) return false;
        *out = cz_new_seq(c, v->type, items, n);
        free(items);
        return true;
    }
    case CZ_SEGMENT: {
        cz_val *inner;
        if (!zm_expand(c, v->seg.inner, &inner)) return false;
        *out = inner == v->seg.inner ? v : cz_new_wrap(c, CZ_SEGMENT, inner);
        return true;
    }
    case CZ_ADECL: {
        cz_val *val, *decl;
        if (!zm_expand(c, v->adecl.value, &val)) return false;
        if (!zm_expand(c, v->adecl.decl, &decl)) return false;
        *out = cz_new_adecl(c, val, decl);
        return true;
    }
    default:
        *out = v;
        return true;
    }
}

/* ---- helpers ---- */

static bool atom_is(const cz_val *v, const char *name) {
    return v->type == CZ_ATOM && strcmp(v->atom.name, name) == 0;
}

static void add_flag(cz_ctx *c, cz_val *flag) {
    zm_game *g = GAME(c);
    for (size_t i = 0; i < g->flag_count; i++)
        if (g->flags[i] == flag) return;
    ZPUSH(g, flags, flag_count, flag_cap, flag);
}

static void add_propname(cz_ctx *c, cz_val *name) {
    zm_game *g = GAME(c);
    for (size_t i = 0; i < g->propname_count; i++)
        if (g->propnames[i] == name) return;
    ZPUSH(g, propnames, propname_count, propname_cap, name);
}

static void add_word(zm_game *g, const char *text, unsigned pos) {
    for (size_t i = 0; i < g->word_count; i++) {
        if (strcmp(g->words[i].text, text) == 0) {
            g->words[i].pos |= pos;
            return;
        }
    }
    zm_word w = { text, pos };
    ZPUSH(g, words, word_count, word_cap, w);
}

/* ---- directives ---- */

static cz_result zm_f_version(cz_ctx *c, cz_val **a, size_t n) {
    zm_game *g = GAME(c);
    if (n < 1) return zerr(c, "VERSION: missing argument");
    if (g->version_locked) return ok(cz_new_fix(c, g->zversion));
    if (a[0]->type == CZ_FIX) g->zversion = a[0]->fix.value;
    else if (atom_is(a[0], "ZIP")) g->zversion = 3;
    else if (atom_is(a[0], "EZIP")) g->zversion = 4;
    else if (atom_is(a[0], "XZIP")) g->zversion = 5;
    else if (atom_is(a[0], "YZIP")) g->zversion = 6;
    else return zerr(c, "VERSION: unknown version");
    return ok(cz_new_fix(c, g->zversion));
}

static cz_result def_value(cz_ctx *c, cz_val **a, size_t n, bool constant) {
    zm_game *g = GAME(c);
    const char *what = constant ? "CONSTANT" : "GLOBAL";
    if (n != 2) return zerr(c, "%s: expected name and value", what);
    if (a[0]->type != CZ_ATOM) return zerr(c, "%s: name must be an atom", what);
    cz_result r = cz_eval(c, a[1]);
    if (r.flow != CZ_F_NORMAL) return r;
    zm_binding_rec rec = { a[0], r.val };
    if (constant) ZPUSH(g, constants, constant_count, constant_cap, rec);
    else ZPUSH(g, globals, global_count, global_cap, rec);
    cz_setg(c, a[0], r.val);
    return ok(a[0]);
}

static cz_result zm_f_constant(cz_ctx *c, cz_val **a, size_t n) { return def_value(c, a, n, true); }
static cz_result zm_f_global(cz_ctx *c, cz_val **a, size_t n) { return def_value(c, a, n, false); }

static cz_result def_object(cz_ctx *c, cz_val **a, size_t n, bool is_room) {
    zm_game *g = GAME(c);
    const char *what = is_room ? "ROOM" : "OBJECT";
    if (n < 1 || a[0]->type != CZ_ATOM)
        return zerr(c, "%s: expected name atom", what);

    zm_object obj = { 0 };
    obj.name = a[0];
    obj.is_room = is_room;

    for (size_t i = 1; i < n; i++) {
        cz_val *clause = a[i];
        if (clause->type != CZ_LIST || clause->seq.count < 1
            || clause->seq.items[0]->type != CZ_ATOM)
            return zerr(c, "%s %s: bad property clause", what, a[0]->atom.name);
        cz_val *head = clause->seq.items[0];

        if (atom_is(head, "DESC") && clause->seq.count == 2
            && clause->seq.items[1]->type == CZ_STRING) {
            obj.desc = clause->seq.items[1]->str.text;
        } else if ((atom_is(head, "IN") || atom_is(head, "LOC"))
                   && clause->seq.count == 2
                   && clause->seq.items[1]->type == CZ_ATOM) {
            obj.parent = clause->seq.items[1];
        } else if (atom_is(head, "FLAGS")) {
            for (size_t j = 1; j < clause->seq.count; j++)
                if (clause->seq.items[j]->type == CZ_ATOM)
                    add_flag(c, clause->seq.items[j]);
        } else {
            add_propname(c, head);
        }

        zm_prop p = { head, clause->seq.items + 1, clause->seq.count - 1 };
        if (obj.prop_count % 8 == 0) {
            obj.props = realloc(obj.props, (obj.prop_count + 8) * sizeof(zm_prop));
            if (!obj.props) abort();
        }
        obj.props[obj.prop_count++] = p;
    }
    ZPUSH(g, objects, object_count, object_cap, obj);
    return ok(a[0]);
}

static cz_result zm_f_object(cz_ctx *c, cz_val **a, size_t n) { return def_object(c, a, n, false); }
static cz_result zm_f_room(cz_ctx *c, cz_val **a, size_t n) { return def_object(c, a, n, true); }

static cz_result zm_f_routine(cz_ctx *c, cz_val **a, size_t n) {
    zm_game *g = GAME(c);
    if (n < 3 || a[0]->type != CZ_ATOM || a[1]->type != CZ_LIST)
        return zerr(c, "ROUTINE: expected name, argspec, body");
    zm_routine r = { 0 };
    r.name = a[0];
    r.spec = a[1];
    r.body_count = n - 2;
    r.body = malloc(r.body_count * sizeof(cz_val *));
    if (!r.body) abort();
    memcpy(r.body, a + 2, r.body_count * sizeof(cz_val *));
    ZPUSH(g, routines, routine_count, routine_cap, r);
    return ok(a[0]);
}

static cz_result zm_f_syntax(cz_ctx *c, cz_val **a, size_t n) {
    zm_game *g = GAME(c);
    zm_syntax s = { 0 };
    s.raw = cz_new_seq(c, CZ_LIST, a, n);

    size_t i = 0;
    /* pattern up to '=' */
    for (; i < n && !atom_is(a[i], "="); i++) {
        cz_val *tok = a[i];
        if (tok->type == CZ_ATOM) {
            if (!s.verb) { s.verb = tok; continue; }
            if (atom_is(tok, "OBJECT")) {
                if (s.num_objects >= 2)
                    return zerr(c, "SYNTAX: more than 2 OBJECT slots");
                s.num_objects++;
            } else {
                /* preposition for the next OBJECT slot */
                if (s.num_objects >= 2 || s.prep[s.num_objects])
                    return zerr(c, "SYNTAX: misplaced preposition %s", tok->atom.name);
                s.prep[s.num_objects] = tok;
            }
        } else if (tok->type == CZ_LIST && tok->seq.count >= 1) {
            /* (FIND FLAG) or search options; attaches to the last OBJECT */
            if (s.num_objects == 0)
                return zerr(c, "SYNTAX: options before any OBJECT");
            if (atom_is(tok->seq.items[0], "FIND")) {
                if (tok->seq.count != 2 || tok->seq.items[1]->type != CZ_ATOM)
                    return zerr(c, "SYNTAX: bad FIND clause");
                s.find[s.num_objects - 1] = tok->seq.items[1];
                add_flag(c, tok->seq.items[1]);
            }
            /* search options (HELD CARRIED ON-GROUND IN-ROOM...) stay in raw */
        } else {
            return zerr(c, "SYNTAX: unexpected token");
        }
    }
    if (!s.verb) return zerr(c, "SYNTAX: missing verb");
    if (i >= n) return zerr(c, "SYNTAX: missing '='");
    i++; /* skip '=' */
    if (i >= n || a[i]->type != CZ_ATOM)
        return zerr(c, "SYNTAX: missing action routine");
    s.action = a[i++];
    if (i < n && a[i]->type == CZ_ATOM) s.preaction = a[i++];
    if (i < n) return zerr(c, "SYNTAX: trailing tokens after actions");

    ZPUSH(g, syntaxes, syntax_count, syntax_cap, s);
    return ok(s.verb);
}

static cz_result zm_s_synonym(cz_ctx *c, cz_val **a, size_t n) {
    zm_game *g = GAME(c);
    if (n < 2) return zerr(c, "SYNONYM: expected at least 2 words");
    for (size_t i = 0; i < n; i++)
        if (a[i]->type != CZ_ATOM) return zerr(c, "SYNONYM: words must be atoms");
    zm_synonym syn = { a[0], NULL, n - 1 };
    syn.rest = malloc((n - 1) * sizeof(cz_val *));
    if (!syn.rest) abort();
    memcpy(syn.rest, a + 1, (n - 1) * sizeof(cz_val *));
    ZPUSH(g, synonyms, synonym_count, synonym_cap, syn);
    return ok(a[0]);
}

static cz_result zm_s_buzz(cz_ctx *c, cz_val **a, size_t n) {
    zm_game *g = GAME(c);
    for (size_t i = 0; i < n; i++) {
        if (a[i]->type != CZ_ATOM) return zerr(c, "BUZZ: words must be atoms");
        ZPUSH(g, buzz, buzz_count, buzz_cap, a[i]);
    }
    return ok(cz_intern(c, "T", 1));
}

static cz_result zm_f_directions(cz_ctx *c, cz_val **a, size_t n) {
    zm_game *g = GAME(c);
    if (n == 0) return zerr(c, "DIRECTIONS: no directions");
    for (size_t i = 0; i < n; i++) {
        if (a[i]->type != CZ_ATOM) return zerr(c, "DIRECTIONS: expected atoms");
        ZPUSH(g, directions, direction_count, direction_cap, a[i]);
    }
    return ok(cz_intern(c, "T", 1));
}

static cz_result zm_f_propdef(cz_ctx *c, cz_val **a, size_t n) {
    zm_game *g = GAME(c);
    if (n < 2 || a[0]->type != CZ_ATOM) return zerr(c, "PROPDEF: expected name");
    zm_propdef pd = { a[0], NULL, n - 1 };
    pd.body = malloc((n - 1) * sizeof(cz_val *));
    if (!pd.body) abort();
    memcpy(pd.body, a + 1, (n - 1) * sizeof(cz_val *));
    ZPUSH(g, propdefs, propdef_count, propdef_cap, pd);
    return ok(a[0]);
}

static cz_result zm_s_sname(cz_ctx *c, cz_val **a, size_t n) {
    zm_game *g = GAME(c);
    if (n != 1 || a[0]->type != CZ_STRING) return zerr(c, "SNAME: expected string");
    g->sname = a[0]->str.text;
    return ok(a[0]);
}

/* <VERSION? (ZIP ...) (XZIP ...) (T ...)>: evaluate the clause matching
 * the target version (upstream Subrs.ZModel VERSION?) */
static cz_result zm_f_versionp(cz_ctx *c, cz_val **a, size_t n) {
    zm_game *g = GAME(c);
    for (size_t i = 0; i < n; i++) {
        if (a[i]->type != CZ_LIST || a[i]->seq.count < 1)
            return zerr(c, "VERSION?: clauses must be lists");
        cz_val *head = a[i]->seq.items[0];
        int want = -1;
        if (atom_is(head, "ZIP")) want = 3;
        else if (atom_is(head, "EZIP")) want = 4;
        else if (atom_is(head, "XZIP")) want = 5;
        else if (atom_is(head, "YZIP")) want = 6;
        else if (head->type == CZ_FIX) want = head->fix.value;
        else if (atom_is(head, "T") || atom_is(head, "ELSE")) want = g->zversion;
        if (want != g->zversion) continue;
        cz_result r = ok(cz_intern(c, "T", 1));
        for (size_t j = 1; j < a[i]->seq.count; j++) {
            r = cz_eval(c, a[i]->seq.items[j]);
            if (r.flow != CZ_F_NORMAL) return r;
        }
        return r;
    }
    return ok(cz_false(c));
}

static cz_result zm_f_frequent_words(cz_ctx *c, cz_val **a, size_t n) {
    (void)a; (void)n;
    return ok(cz_intern(c, "T", 1));
}

/* ---- tables ---- */

static cz_val *make_table(cz_ctx *c, cz_val **items, size_t n, uint32_t tflags) {
    zm_game *g = GAME(c);
    cz_val *v = cz_alloc(c->arena, sizeof(*v));
    memset(v, 0, sizeof(*v));
    v->type = CZ_TABLE;
    v->tab.items = n ? cz_alloc(c->arena, n * sizeof(cz_val *)) : NULL;
    if (n) memcpy(v->tab.items, items, n * sizeof(cz_val *));
    v->tab.count = n;
    v->tab.tflags = tflags;
    ZPUSH(g, tables, table_count, table_cap, v);
    return v;
}

static uint32_t table_flags_from_list(cz_val *list) {
    uint32_t f = 0;
    for (size_t i = 0; i < list->seq.count; i++) {
        cz_val *item = list->seq.items[i];
        if (atom_is(item, "BYTE")) f |= ZM_TBL_BYTE;
        if (atom_is(item, "PURE")) f |= ZM_TBL_PURE;
        if (atom_is(item, "LENGTH")) f |= ZM_TBL_LENGTH;
        if (atom_is(item, "LEXV")) f |= ZM_TBL_LEXV;
        /* KILL/PARSER-TABLE etc. matter at emit, not here */
    }
    return f;
}

static cz_result table_common(cz_ctx *c, cz_val **a, size_t n, uint32_t tflags) {
    size_t i = 0;
    if (n > 0 && a[0]->type == CZ_LIST) {
        tflags |= table_flags_from_list(a[0]);
        i = 1;
    }
    return ok(make_table(c, a + i, n - i, tflags));
}

static cz_result zm_s_table(cz_ctx *c, cz_val **a, size_t n) { return table_common(c, a, n, 0); }
static cz_result zm_s_ltable(cz_ctx *c, cz_val **a, size_t n) { return table_common(c, a, n, ZM_TBL_LENGTH); }
static cz_result zm_s_ptable(cz_ctx *c, cz_val **a, size_t n) { return table_common(c, a, n, ZM_TBL_PURE); }
static cz_result zm_s_pltable(cz_ctx *c, cz_val **a, size_t n) { return table_common(c, a, n, ZM_TBL_PURE | ZM_TBL_LENGTH); }

/* <ITABLE [NONE|BYTE|WORD] count [(flags...)] [init...]>: count repetitions */
static cz_result zm_s_itable(cz_ctx *c, cz_val **a, size_t n) {
    size_t i = 0;
    uint32_t tflags = 0;
    if (i < n && a[i]->type == CZ_ATOM) {
        if (atom_is(a[i], "BYTE")) tflags |= ZM_TBL_BYTE;
        else if (!atom_is(a[i], "NONE") && !atom_is(a[i], "WORD"))
            return zerr(c, "ITABLE: unknown specifier %s", a[i]->atom.name);
        i++;
    }
    if (i >= n || a[i]->type != CZ_FIX || a[i]->fix.value < 0)
        return zerr(c, "ITABLE: expected element count");
    size_t count = (size_t)a[i]->fix.value;
    i++;
    if (i < n && a[i]->type == CZ_LIST) {
        tflags |= table_flags_from_list(a[i]);
        i++;
    }
    cz_val **inits = a + i;
    size_t init_count = n - i;

    size_t total = count * (init_count ? init_count : 1);
    cz_val **items = malloc(total * sizeof(cz_val *));
    if (!items) abort();
    cz_val *zero = cz_new_fix(c, 0);
    for (size_t k = 0; k < total; k++)
        items[k] = init_count ? inits[k % init_count] : zero;
    cz_result r = ok(make_table(c, items, total, tflags));
    free(items);
    return r;
}

/* ---- INSERT-FILE ---- */

static cz_result zm_s_insert_file(cz_ctx *c, cz_val **a, size_t n) {
    zm_game *g = GAME(c);
    if (n < 1 || a[0]->type != CZ_STRING)
        return zerr(c, "INSERT-FILE: expected file name string");
    char lower[256];
    size_t len = a[0]->str.len < sizeof(lower) - 1 ? a[0]->str.len : sizeof(lower) - 1;
    for (size_t i = 0; i < len; i++) {
        char ch = a[0]->str.text[i];
        lower[i] = ch >= 'A' && ch <= 'Z' ? (char)(ch + 32) : ch;
    }
    lower[len] = '\0';

    /* search the main file's directory, then any -I include directories
     * (lets a new game reuse engine files from another tree) */
    char path[1400];
    char *src = NULL;
    size_t srclen = 0;
    for (size_t d = 0; !src && d <= g->include_count; d++) {
        const char *dir = d == 0 ? g->base_dir : g->include_dirs[d - 1];
        snprintf(path, sizeof path, "%s/%s.zil", dir, lower);
        src = slurp(path, &srclen);
        if (!src) {
            snprintf(path, sizeof path, "%s/%.*s.zil", dir,
                     (int)a[0]->str.len, a[0]->str.text);
            src = slurp(path, &srclen);
        }
    }
    if (!src) return zerr(c, "INSERT-FILE: cannot find %.*s in %s or include dirs",
                          (int)a[0]->str.len, a[0]->str.text, g->base_dir);
    bool okload = zm_load_source(c, g, src, srclen, path);
    free(src);
    if (!okload) return (cz_result){ CZ_F_ERROR, NULL };  /* g->err set */
    return ok(cz_intern(c, "T", 1));
}

/* ---- loading ---- */

static char *slurp_stdio(const char *path, size_t *len) {
    FILE *f = fopen(path, "rb");
    if (!f) return NULL;
    fseek(f, 0, SEEK_END);
    long size = ftell(f);
    fseek(f, 0, SEEK_SET);
    char *buf = malloc(size + 1);
    if (!buf || fread(buf, 1, size, f) != (size_t)size) { fclose(f); free(buf); return NULL; }
    fclose(f);
    buf[size] = '\0';
    *len = size;
    return buf;
}

static zm_read_fn zm_reader = slurp_stdio;

void zm_set_file_reader(zm_read_fn fn) {
    zm_reader = fn ? fn : slurp_stdio;
}

static char *slurp(const char *path, size_t *len) {
    return zm_reader(path, len);
}

static bool zm_load_source(cz_ctx *c, zm_game *g, const char *src, size_t len,
                           const char *path) {
    cz_parse_result res = cz_parse(c, src, len);
    if (!res.ok) {
        snprintf(g->err, sizeof g->err, "%s:%d: parse error: %s",
                 path, res.error_line, res.error);
        return false;
    }
    for (size_t i = 0; i < res.count; i++) {
        cz_val *expanded;
        if (!zm_expand(c, res.items[i], &expanded)) {
            snprintf(g->err, sizeof g->err, "%s: read-macro expansion failed: %s",
                     path, cz_error(c));
            return false;
        }
        cz_result r = cz_eval(c, expanded);
        if (r.flow != CZ_F_NORMAL) {
            char *buf = NULL; size_t blen = 0, bcap = 0;
            cz_print(expanded, &buf, &blen, &bcap);
            snprintf(g->err, sizeof g->err, "%s: eval error: %s\n  in: %.300s",
                     path, cz_error(c), buf ? buf : "?");
            free(buf);
            return false;
        }
    }
    return true;
}

bool zm_load_file(cz_ctx *c, zm_game *g, const char *path) {
    size_t len;
    char *src = slurp(path, &len);
    if (!src) {
        snprintf(g->err, sizeof g->err, "%s: cannot read", path);
        return false;
    }
    bool okload = zm_load_source(c, g, src, len, path);
    free(src);
    return okload;
}

/* ---- install ---- */

void zm_install(cz_ctx *c, zm_game *g) {
    c->user = g;

    /* ZILF-standard globals (Context.cs InitGlobals) */
    cz_val *t = cz_intern(c, "T", 1);
    cz_setg(c, cz_intern(c, "ZILCH", 5), t);
    cz_setg(c, cz_intern(c, "ZILF", 4), t);
    cz_setg(c, cz_intern(c, "PREDGEN", 7), t);
    cz_setg(c, cz_intern(c, "PLUS-MODE", 9), cz_false(c));
    cz_setg(c, cz_intern(c, "SIBREAKS", 8), cz_new_string(c, ",.\"", 3));

    cz_def_subr(c, "VERSION", zm_f_version, true);
    cz_def_subr(c, "VERSION?", zm_f_versionp, true);
    cz_def_subr(c, "CONSTANT", zm_f_constant, true);
    cz_def_subr(c, "GLOBAL", zm_f_global, true);
    cz_def_subr(c, "OBJECT", zm_f_object, true);
    cz_def_subr(c, "ROOM", zm_f_room, true);
    cz_def_subr(c, "ROUTINE", zm_f_routine, true);
    cz_def_subr(c, "SYNTAX", zm_f_syntax, true);
    cz_def_subr(c, "SYNONYM", zm_s_synonym, false);
    cz_def_subr(c, "BUZZ", zm_s_buzz, false);
    cz_def_subr(c, "DIRECTIONS", zm_f_directions, true);
    cz_def_subr(c, "PROPDEF", zm_f_propdef, true);
    cz_def_subr(c, "SNAME", zm_s_sname, false);
    cz_def_subr(c, "FREQUENT-WORDS?", zm_f_frequent_words, true);
    cz_def_subr(c, "TABLE", zm_s_table, false);
    cz_def_subr(c, "LTABLE", zm_s_ltable, false);
    cz_def_subr(c, "PTABLE", zm_s_ptable, false);
    cz_def_subr(c, "PLTABLE", zm_s_pltable, false);
    cz_def_subr(c, "ITABLE", zm_s_itable, false);
    cz_def_subr(c, "INSERT-FILE", zm_s_insert_file, false);
}

/* ---- finalize: vocabulary + cross-checks ---- */

static zm_object *find_object(zm_game *g, cz_val *name) {
    for (size_t i = 0; i < g->object_count; i++)
        if (g->objects[i].name == name) return &g->objects[i];
    return NULL;
}

static zm_routine *find_routine(zm_game *g, cz_val *name) {
    for (size_t i = 0; i < g->routine_count; i++)
        if (g->routines[i].name == name) return &g->routines[i];
    return NULL;
}

bool zm_finalize(cz_ctx *c, zm_game *g) {
    (void)c;

    /* directions */
    for (size_t i = 0; i < g->direction_count; i++)
        add_word(g, g->directions[i]->atom.name, ZM_POS_DIR);

    /* objects: SYNONYM nouns, ADJECTIVE adjectives, PSEUDO string nouns */
    for (size_t i = 0; i < g->object_count; i++) {
        zm_object *o = &g->objects[i];
        for (size_t p = 0; p < o->prop_count; p++) {
            zm_prop *pr = &o->props[p];
            if (atom_is(pr->head, "SYNONYM")) {
                for (size_t j = 0; j < pr->count; j++)
                    if (pr->body[j]->type == CZ_ATOM)
                        add_word(g, pr->body[j]->atom.name, ZM_POS_NOUN);
            } else if (atom_is(pr->head, "ADJECTIVE")) {
                for (size_t j = 0; j < pr->count; j++)
                    if (pr->body[j]->type == CZ_ATOM)
                        add_word(g, pr->body[j]->atom.name, ZM_POS_ADJ);
            } else if (atom_is(pr->head, "PSEUDO")) {
                for (size_t j = 0; j < pr->count; j++)
                    if (pr->body[j]->type == CZ_STRING)
                        add_word(g, pr->body[j]->str.text, ZM_POS_NOUN);
            }
        }
    }

    /* syntax: verbs and prepositions */
    for (size_t i = 0; i < g->syntax_count; i++) {
        zm_syntax *s = &g->syntaxes[i];
        add_word(g, s->verb->atom.name, ZM_POS_VERB);
        for (int k = 0; k < 2; k++)
            if (s->prep[k])
                add_word(g, s->prep[k]->atom.name, ZM_POS_PREP);
    }

    /* buzzwords */
    for (size_t i = 0; i < g->buzz_count; i++)
        add_word(g, g->buzz[i]->atom.name, ZM_POS_BUZZ);

    /* synonyms copy the part of speech of the base word */
    for (size_t i = 0; i < g->synonym_count; i++) {
        zm_synonym *syn = &g->synonyms[i];
        unsigned pos = 0;
        for (size_t w = 0; w < g->word_count; w++)
            if (strcmp(g->words[w].text, syn->first->atom.name) == 0) {
                pos = g->words[w].pos;
                break;
            }
        if (!pos) {
            snprintf(g->err, sizeof g->err,
                     "SYNONYM: base word %s is not in the vocabulary",
                     syn->first->atom.name);
            return false;
        }
        for (size_t j = 0; j < syn->count; j++)
            add_word(g, syn->rest[j]->atom.name, pos);
    }

    /* cross-checks */
    for (size_t i = 0; i < g->syntax_count; i++) {
        zm_syntax *s = &g->syntaxes[i];
        if (!find_routine(g, s->action)) {
            snprintf(g->err, sizeof g->err,
                     "SYNTAX %s: action routine %s is not defined",
                     s->verb->atom.name, s->action->atom.name);
            return false;
        }
        if (s->preaction && !find_routine(g, s->preaction)) {
            snprintf(g->err, sizeof g->err,
                     "SYNTAX %s: preaction routine %s is not defined",
                     s->verb->atom.name, s->preaction->atom.name);
            return false;
        }
    }
    for (size_t i = 0; i < g->object_count; i++) {
        zm_object *o = &g->objects[i];
        if (o->parent && !find_object(g, o->parent)) {
            snprintf(g->err, sizeof g->err,
                     "%s: parent %s is not a defined object",
                     o->name->atom.name, o->parent->atom.name);
            return false;
        }
    }

    if (g->zversion == 3) {
        if (g->flag_count > 32) {
            snprintf(g->err, sizeof g->err,
                     "v3 allows 32 flags; model has %zu", g->flag_count);
            return false;
        }
        /* every direction is a property; the rest of the clause heads are
         * properties too, except direction heads already counted */
        size_t props = g->direction_count;
        for (size_t i = 0; i < g->propname_count; i++) {
            bool is_dir = false;
            for (size_t d = 0; d < g->direction_count; d++)
                if (g->propnames[i] == g->directions[d]) { is_dir = true; break; }
            if (!is_dir) props++;
        }
        if (props > 31) {
            snprintf(g->err, sizeof g->err,
                     "v3 allows 31 properties; model has %zu", props);
            return false;
        }
    }
    return true;
}

/* ---- stage-5 planning survey ---- */

typedef struct { const char *name; int count; } head_stat;

static void survey_form(cz_ctx *c, zm_game *g, cz_val *v,
                        head_stat **stats, size_t *n, size_t *cap);

static void survey_children(cz_ctx *c, zm_game *g, cz_val **items, size_t count,
                            head_stat **stats, size_t *n, size_t *cap) {
    for (size_t i = 0; i < count; i++)
        survey_form(c, g, items[i], stats, n, cap);
}

static void bump_head(const char *name, head_stat **stats, size_t *n, size_t *cap) {
    for (size_t i = 0; i < *n; i++)
        if (strcmp((*stats)[i].name, name) == 0) { (*stats)[i].count++; return; }
    if (*n >= *cap) {
        *cap = *cap ? *cap * 2 : 64;
        *stats = realloc(*stats, *cap * sizeof(**stats));
        if (!*stats) abort();
    }
    (*stats)[(*n)++] = (head_stat){ name, 1 };
}

static void survey_form(cz_ctx *c, zm_game *g, cz_val *v,
                        head_stat **stats, size_t *n, size_t *cap) {
    switch (v->type) {
    case CZ_FORM: {
        if (v->seq.count == 0) return;
        cz_val *head = v->seq.items[0];
        if (head->type == CZ_ATOM) {
            /* expand game macros and survey the expansion instead */
            cz_val *gv = cz_getg(c, head);
            if (gv && gv->type == CZ_MACRO) {
                cz_result r = cz_apply(c, gv->seg.inner, v->seq.items + 1,
                                       v->seq.count - 1, false);
                if (r.flow == CZ_F_NORMAL) {
                    survey_form(c, g, r.val, stats, n, cap);
                    return;
                }
                bump_head("!MACRO-EXPAND-FAILED", stats, n, cap);
                fprintf(stderr, "macro %s failed: %s\n", head->atom.name, cz_error(c));
                return;
            }
            bump_head(head->atom.name, stats, n, cap);
        } else {
            bump_head("!NON-ATOM-HEAD", stats, n, cap);
        }
        survey_children(c, g, v->seq.items + 1, v->seq.count - 1, stats, n, cap);
        break;
    }
    case CZ_LIST: case CZ_VECTOR: case CZ_FALSE: case CZ_SPLICE:
        survey_children(c, g, v->seq.items, v->seq.count, stats, n, cap);
        break;
    case CZ_SEGMENT:
        survey_form(c, g, v->seg.inner, stats, n, cap);
        break;
    default:
        break;
    }
}

void zm_survey_heads(cz_ctx *c, zm_game *g) {
    head_stat *stats = NULL;
    size_t n = 0, cap = 0;
    for (size_t i = 0; i < g->routine_count; i++)
        survey_children(c, g, g->routines[i].body, g->routines[i].body_count,
                        &stats, &n, &cap);
    /* classify: routine call, object, global, constant, or builtin */
    for (size_t i = 0; i < n; i++) {
        const char *cls = "builtin?";
        cz_val *atom = cz_intern(c, stats[i].name, strlen(stats[i].name));
        for (size_t r = 0; r < g->routine_count; r++)
            if (g->routines[r].name == atom) { cls = "routine"; break; }
        printf("%6d  %-20s %s\n", stats[i].count, stats[i].name, cls);
    }
    free(stats);
}
