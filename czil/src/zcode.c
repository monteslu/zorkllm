/* czil - C port of ZILF (Copyright 2010-2023 Tara McGrew).
 * GPL-3.0-or-later; see czil/LICENSE.
 *
 * Stage 5: compile the Z-model to a v3 story file.
 * Upstream: Zilf/Compiler (routine codegen, syntax tables, objects),
 * Zilf.Emit/Zap (numbering: properties and flags descend from 31, verbs/
 * preps/adjectives/buzzwords descend from 255), Zapf (assembly).
 *
 * Layout: header, abbrev table (empty), object table (defaults + entries
 * + property tables), globals, impure tables, [static] pure + syntax
 * tables, dictionary, [high] code, strings. Packed addresses are byte/2.
 */
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "zmodel.h"
#include "czil_internal.h"

/* v3: 31 props, 32 flags, byte tree links, /2 packing.
 * v5/v8: 63 props, 48 flags, word tree links, /4 (/8) packing. */
static int ZV = 3;
#define MAXPROP (ZV >= 4 ? 63 : 31)
#define MAXFLAG (ZV >= 4 ? 47 : 31)
#define PACK (ZV >= 8 ? 8 : ZV >= 4 ? 4 : 2)
#define OBJENT (ZV >= 4 ? 14 : 9)
#define DICTTEXT (ZV >= 4 ? 6 : 4)

/* ---------- error plumbing ---------- */

typedef struct zc zc;
static char *zc_errbuf;
static size_t zc_errsz;
static bool zc_failed;

#define FAIL(...) do { \
    if (!zc_failed) snprintf(zc_errbuf, zc_errsz, __VA_ARGS__); \
    zc_failed = true; \
} while (0)

/* ---------- byte buffers ---------- */

typedef struct { uint8_t *b; size_t n, cap; } buf;

static void put8(buf *b, uint8_t v) {
    if (b->n >= b->cap) {
        b->cap = b->cap ? b->cap * 2 : 256;
        b->b = realloc(b->b, b->cap);
        if (!b->b) abort();
    }
    b->b[b->n++] = v;
}
static void put16(buf *b, uint16_t v) { put8(b, (uint8_t)(v >> 8)); put8(b, (uint8_t)v); }
static void patch16(buf *b, size_t off, uint16_t v) {
    b->b[off] = (uint8_t)(v >> 8);
    b->b[off + 1] = (uint8_t)v;
}

/* ---------- sections and fixups ---------- */

enum { SEC_OBJTAB, SEC_GLOBALS, SEC_IMPTAB, SEC_PURETAB, SEC_DICT, SEC_CODE, SEC_STRINGS, NSEC };
/* FX_SECBASE: add the base address of section `idx` to the stored word
 * (for intra-section offsets recorded before bases are known) */
enum { FX_NONE = 0, FX_ROUTINE, FX_STRING, FX_TABLE, FX_WORD, FX_SECBASE };

typedef struct { int sec; size_t off; int kind; int idx; } fixup;

/* ---------- per-word vocab data ---------- */

typedef struct {
    const char *text;
    unsigned pos;            /* ZM_POS_* bits */
    int first;               /* 0 obj/prep/buzz, 1 verb, 2 adj, 3 dir */
    bool first_set;
    bool via_synonym_prep;   /* preposition-ness came from SYNONYM */
    int verb_val, adj_val, prep_val, buzz_val, dir_idx;
    uint8_t enc[6];
    int dict_index;          /* after sorting */
} vword;

/* ---------- compiler state ---------- */

struct zc {
    cz_ctx *c;
    zm_game *g;

    /* numbering */
    int *obj_num;                 /* per g->objects index, 1-based */
    cz_val **propname; int *propnum; size_t nprops;
    cz_val **flagname; int *flagnum; size_t nflags;
    cz_val **globname; int *globnum; size_t nglobs;   /* includes reserved+scratch */
    int g_dummy, g_tmp[3];        /* scratch global numbers */
    int glob_reserved[4];         /* PREPOSITIONS ACTIONS PREACTIONS VERBS */

    vword *words; size_t nwords;
    size_t declared_dirs;         /* <DIRECTIONS> count; the rest are implicit */
    int low_direction;            /* prop number of the last declared direction */

    /* actions */
    cz_val **act_name; cz_val **act_routine; cz_val **act_pre; size_t nacts;

    /* string pool */
    const char **strs; size_t nstrs, strcap;
    size_t *str_off;              /* offset in SEC_STRINGS */

    /* tables: parallel to g->tables + synthetic syntax tables at the end */
    size_t ntables;
    int *tab_sec; size_t *tab_off;

    /* routines */
    size_t *rtn_off;              /* offset in SEC_CODE */

    buf sec[NSEC];
    size_t sec_base[NSEC];
    fixup *fx; size_t nfx, fxcap;
};

static void add_fixup(zc *z, int sec, size_t off, int kind, int idx) {
    if (z->nfx >= z->fxcap) {
        z->fxcap = z->fxcap ? z->fxcap * 2 : 256;
        z->fx = realloc(z->fx, z->fxcap * sizeof(*z->fx));
        if (!z->fx) abort();
    }
    z->fx[z->nfx++] = (fixup){ sec, off, kind, idx };
}

/* ZIL string translation (upstream TranslateString, v3 defaults):
 * '|' is the newline character; source CRs vanish; source newlines become
 * spaces (or vanish after '|'); a doubled space after '.' or '|' collapses.
 * Returns malloc'd text (leaked; compiler is one-shot). */
static char *translate_zil_string(const char *text) {
    size_t len = strlen(text);
    char *out = malloc(len + 1);
    if (!out) abort();
    size_t n = 0;
    char last = 0;
    bool saw_dot_space = false;
    for (size_t i = 0; i < len; i++) {
        char c = text[i];
        /* shipped ZILCH output shows the collapse applied after '.' only,
         * not after the '|' newline character (ZILF does both) */
        if (last == '.' && c == ' ') {
            saw_dot_space = true;
        } else if (saw_dot_space && c == ' ') {
            saw_dot_space = false;
            last = c;
            continue;                   /* drop the second space */
        } else {
            saw_dot_space = false;
        }
        if (c == '\r') continue;
        if (c == '\n') {
            if (last == '|') { last = c; continue; }
            out[n++] = ' ';
            last = c;
            continue;
        }
        out[n++] = c == '|' ? '\n' : c;
        last = c;
    }
    out[n] = '\0';
    return out;
}

static int intern_string(zc *z, const char *raw) {
    char *text = translate_zil_string(raw);
    for (size_t i = 0; i < z->nstrs; i++)
        if (strcmp(z->strs[i], text) == 0) { free(text); return (int)i; }
    if (z->nstrs >= z->strcap) {
        z->strcap = z->strcap ? z->strcap * 2 : 64;
        z->strs = realloc(z->strs, z->strcap * sizeof(*z->strs));
        z->str_off = realloc(z->str_off, z->strcap * sizeof(*z->str_off));
        if (!z->strs || !z->str_off) abort();
    }
    z->strs[z->nstrs] = text;
    return (int)z->nstrs++;
}

static bool atom_is(const cz_val *v, const char *name) {
    return v->type == CZ_ATOM && strcmp(v->atom.name, name) == 0;
}

static int find_object(zc *z, cz_val *atom) {
    for (size_t i = 0; i < z->g->object_count; i++)
        if (z->g->objects[i].name == atom) return (int)i;
    return -1;
}
static int find_routine(zc *z, cz_val *atom) {
    /* redefinition wins: the overlay pattern replaces engine routines */
    for (size_t i = z->g->routine_count; i > 0; i--)
        if (z->g->routines[i - 1].name == atom) return (int)(i - 1);
    return -1;
}
static int find_propnum(zc *z, cz_val *atom) {
    for (size_t i = 0; i < z->nprops; i++)
        if (z->propname[i] == atom) return z->propnum[i];
    return -1;
}
static int find_flagnum(zc *z, cz_val *atom) {
    for (size_t i = 0; i < z->nflags; i++)
        if (z->flagname[i] == atom) return z->flagnum[i];
    return -1;
}
static int find_globnum(zc *z, cz_val *atom) {
    for (size_t i = 0; i < z->nglobs; i++)
        if (z->globname[i] == atom) return z->globnum[i];
    return -1;
}
static vword *find_word(zc *z, const char *text) {
    for (size_t i = 0; i < z->nwords; i++)
        if (strcmp(z->words[i].text, text) == 0) return &z->words[i];
    return NULL;
}
static int find_table(zc *z, cz_val *tv) {
    for (size_t i = 0; i < z->g->table_count; i++)
        if (z->g->tables[i] == tv) return (int)i;
    return -1;
}
static int find_action(zc *z, cz_val *name) {
    for (size_t i = 0; i < z->nacts; i++)
        if (z->act_name[i] == name) return (int)i;
    return -1;
}
static cz_val *game_constant(zc *z, cz_val *atom) {
    /* redefinition wins */
    for (size_t i = z->g->constant_count; i > 0; i--)
        if (z->g->constants[i - 1].name == atom) return z->g->constants[i - 1].value;
    return NULL;
}
static cz_val *game_global_value(zc *z, cz_val *atom) {
    for (size_t i = 0; i < z->g->global_count; i++)
        if (z->g->globals[i].name == atom) return z->g->globals[i].value;
    return NULL;
}

/* ---------- constant operand resolution ---------- */

typedef struct {
    bool ok;
    int32_t val;
    int fixkind, fixidx;
} constref;

static constref cref_val(int32_t v) { return (constref){ true, v, FX_NONE, 0 }; }
static constref cref_fix(int kind, int idx) { return (constref){ true, 0, kind, idx }; }
static constref cref_bad(void) { return (constref){ false, 0, FX_NONE, 0 }; }

static constref resolve_constant(zc *z, cz_val *v);

static constref resolve_constant_atom(zc *z, cz_val *atom) {
    const char *nm = atom->atom.name;
    if (strcmp(nm, "T") == 0) return cref_val(1);

    /* generated symbol families */
    if (strncmp(nm, "W?", 2) == 0) {
        const char *wt = nm + 2;
        if (strcmp(wt, "PERIOD") == 0) wt = ".";
        else if (strcmp(wt, "COMMA") == 0) wt = ",";
        else if (strcmp(wt, "QUOTE") == 0) wt = "\"";
        else if (strcmp(wt, "APOSTROPHE") == 0) wt = "'";
        vword *w = find_word(z, wt);
        if (w) return cref_fix(FX_WORD, (int)(w - z->words));
    }
    if (strncmp(nm, "A?", 2) == 0) {
        vword *w = find_word(z, nm + 2);
        if (w && (w->pos & ZM_POS_ADJ)) return cref_val(w->adj_val);
    }
    if (strncmp(nm, "ACT?", 4) == 0) {
        vword *w = find_word(z, nm + 4);
        if (w && (w->pos & ZM_POS_VERB)) return cref_val(w->verb_val);
    }
    if (strncmp(nm, "PR?", 3) == 0) {
        vword *w = find_word(z, nm + 3);
        if (w && (w->pos & ZM_POS_PREP)) return cref_val(w->prep_val);
    }
    if (strncmp(nm, "P?", 2) == 0) {
        int pn = find_propnum(z, cz_intern(z->c, nm + 2, strlen(nm + 2)));
        if (pn > 0) return cref_val(pn);
    }
    if (strncmp(nm, "V?", 2) == 0) {
        int ai = find_action(z, atom);
        if (ai >= 0) return cref_val(ai);
    }

    static const struct { const char *n; int v; } psp1[] = {
        { "P1?OBJECT", 0 }, { "P1?VERB", 1 }, { "P1?ADJECTIVE", 2 }, { "P1?DIRECTION", 3 },
        { "PS?BUZZ-WORD", 4 }, { "PS?PREPOSITION", 8 }, { "PS?DIRECTION", 16 },
        { "PS?ADJECTIVE", 32 }, { "PS?VERB", 64 }, { "PS?OBJECT", 128 },
    };
    for (size_t i = 0; i < sizeof(psp1) / sizeof(psp1[0]); i++)
        if (strcmp(nm, psp1[i].n) == 0) return cref_val(psp1[i].v);

    if (strcmp(nm, "LOW-DIRECTION") == 0 && z->g->direction_count > 0)
        return cref_val(z->low_direction);

    cz_val *cv = game_constant(z, atom);
    if (cv) return resolve_constant(z, cv);

    int fn = find_flagnum(z, atom);
    if (fn >= 0) return cref_val(fn);   /* flag names are constants upstream */

    int oi = find_object(z, atom);
    if (oi >= 0) return cref_val(z->obj_num[oi]);

    int ri = find_routine(z, atom);
    if (ri >= 0) return cref_fix(FX_ROUTINE, ri);

    /* a global whose value is a table can be used as a constant table ref */
    cz_val *gv = game_global_value(z, atom);
    if (gv && gv->type == CZ_TABLE) {
        int ti = find_table(z, gv);
        if (ti >= 0) return cref_fix(FX_TABLE, ti);
    }
    return cref_bad();
}

static constref resolve_constant(zc *z, cz_val *v) {
    switch (v->type) {
    case CZ_FIX: return cref_val(v->fix.value);
    case CZ_FALSE: return cref_val(0);
    case CZ_STRING: return cref_fix(FX_STRING, intern_string(z, v->str.text));
    case CZ_TABLE: {
        int ti = find_table(z, v);
        if (ti >= 0) return cref_fix(FX_TABLE, ti);
        return cref_bad();
    }
    case CZ_ATOM: return resolve_constant_atom(z, v);
    case CZ_CHTYPE:
        if (atom_is(v->chtype.type_atom, "BYTE"))
            return resolve_constant(z, v->chtype.value);
        return cref_bad();
    case CZ_FORM:
        /* <GVAL X> resolves as the constant X (upstream IsGVAL path) */
        if (v->seq.count == 2 && atom_is(v->seq.items[0], "GVAL")
            && v->seq.items[1]->type == CZ_ATOM)
            return resolve_constant_atom(z, v->seq.items[1]);
        {
            cz_result r = cz_eval(z->c, v);
            if (r.flow != CZ_F_NORMAL) return cref_bad();
            if (r.val->type == CZ_FORM) return cref_bad();
            return resolve_constant(z, r.val);
        }
    default: return cref_bad();
    }
}

/* ================= numbering ================= */

/* a property clause shaped like an exit implicitly defines a new
 * direction (upstream PreBuildProperty): body of 2+ values starting
 * TO/SORRY/PER, or room-atom IF ... */
static bool exit_shaped(zm_prop *pr) {
    if (pr->count < 2) return false;
    if (atom_is(pr->head, "IN") || atom_is(pr->head, "LOC")) {
        /* (IN TO X) is an exit; plain (IN ROOMS) was already filtered */
    }
    cz_val *first = pr->body[0];
    if (atom_is(first, "TO") || atom_is(first, "SORRY") || atom_is(first, "PER"))
        return true;
    if (first->type == CZ_ATOM && pr->count >= 3 && atom_is(pr->body[1], "IF"))
        return true;
    return false;
}

static void find_implicit_directions(zc *z) {
    zm_game *g = z->g;
    z->declared_dirs = g->direction_count;
    for (size_t i = 0; i < g->object_count; i++) {
        zm_object *o = &g->objects[i];
        for (size_t p = 0; p < o->prop_count; p++) {
            zm_prop *pr = &o->props[p];
            bool known = false;
            for (size_t d = 0; d < g->direction_count; d++)
                if (g->directions[d] == pr->head) { known = true; break; }
            if (known || !exit_shaped(pr)) continue;
            if (g->direction_count >= g->direction_cap) {
                g->direction_cap = g->direction_cap ? g->direction_cap * 2 : 16;
                g->directions = realloc(g->directions,
                                        g->direction_cap * sizeof(*g->directions));
                if (!g->directions) abort();
            }
            g->directions[g->direction_count++] = pr->head;
        }
    }
}

static void number_model(zc *z) {
    zm_game *g = z->g;

    z->obj_num = calloc(g->object_count, sizeof(int));
    if (!z->obj_num) abort();
    for (size_t i = 0; i < g->object_count; i++)
        z->obj_num[i] = (int)i + 1;
    if (g->object_count > 255) FAIL("v3 allows 255 objects");

    /* properties: directions first, then propdefs, then the rest, all
     * descending from 31 (upstream GameBuilder.DefineProperty) */
    size_t cap = g->direction_count + g->propdef_count + g->propname_count + 4;
    z->propname = calloc(cap, sizeof(cz_val *));
    z->propnum = calloc(cap, sizeof(int));
    if (!z->propname || !z->propnum) abort();
    int next = MAXPROP;
    #define ADDPROP(atom) do { \
        cz_val *a_ = (atom); \
        if (find_propnum(z, a_) < 0) { \
            if (next < 1) { FAIL("too many properties for v3"); break; } \
            z->propname[z->nprops] = a_; \
            z->propnum[z->nprops++] = next--; \
        } \
    } while (0)
    for (size_t i = 0; i < g->direction_count; i++) ADDPROP(g->directions[i]);
    for (size_t i = 0; i < g->propdef_count; i++) ADDPROP(g->propdefs[i].name);
    for (size_t i = 0; i < g->propname_count; i++) ADDPROP(g->propnames[i]);
    #undef ADDPROP
    z->low_direction = z->declared_dirs > 0
        ? find_propnum(z, g->directions[z->declared_dirs - 1]) : 0;

    /* flags: syntax FIND flags first, then the rest, descending from 31 */
    z->flagname = calloc(g->flag_count + 4, sizeof(cz_val *));
    z->flagnum = calloc(g->flag_count + 4, sizeof(int));
    if (!z->flagname || !z->flagnum) abort();
    int fnext = MAXFLAG;
    #define ADDFLAG(atom) do { \
        cz_val *a_ = (atom); \
        if (find_flagnum(z, a_) < 0) { \
            if (fnext < 0) { FAIL("too many flags for v3"); break; } \
            z->flagname[z->nflags] = a_; \
            z->flagnum[z->nflags++] = fnext--; \
        } \
    } while (0)
    for (size_t i = 0; i < g->syntax_count; i++) {
        if (g->syntaxes[i].find[0]) ADDFLAG(g->syntaxes[i].find[0]);
        if (g->syntaxes[i].find[1]) ADDFLAG(g->syntaxes[i].find[1]);
    }
    for (size_t i = 0; i < g->flag_count; i++) ADDFLAG(g->flags[i]);
    #undef ADDFLAG

    /* globals: HERE/SCORE/MOVES pinned to 16/17/18 (the v3 status line
     * reads them), then reserved parser globals, then definition order,
     * then czil's scratch globals */
    size_t gcap = g->global_count + 16;
    z->globname = calloc(gcap, sizeof(cz_val *));
    z->globnum = calloc(gcap, sizeof(int));
    if (!z->globname || !z->globnum) abort();
    int gnext = 16;
    #define ADDGLOB(atom) do { \
        cz_val *a_ = (atom); \
        if (find_globnum(z, a_) < 0) { \
            if (gnext > 255) { FAIL("too many globals"); break; } \
            z->globname[z->nglobs] = a_; \
            z->globnum[z->nglobs++] = gnext++; \
        } \
    } while (0)
    const char *pinned[] = { "HERE", "SCORE", "MOVES" };
    for (int i = 0; i < 3; i++) {
        cz_val *a = cz_intern(z->c, pinned[i], strlen(pinned[i]));
        if (game_global_value(z, a)) ADDGLOB(a);
    }
    const char *reserved[] = { "PREPOSITIONS", "ACTIONS", "PREACTIONS", "VERBS" };
    for (int i = 0; i < 4; i++) {
        cz_val *a = cz_intern(z->c, reserved[i], strlen(reserved[i]));
        ADDGLOB(a);
        z->glob_reserved[i] = find_globnum(z, a);
    }
    for (size_t i = 0; i < g->global_count; i++) ADDGLOB(g->globals[i].name);
    cz_val *dummy = cz_intern(z->c, "?DUMMY", 6);
    ADDGLOB(dummy);
    z->g_dummy = find_globnum(z, dummy);
    for (int i = 0; i < 3; i++) {
        char nm[8];
        snprintf(nm, sizeof nm, "?TMP%d", i);
        cz_val *a = cz_intern(z->c, nm, strlen(nm));
        ADDGLOB(a);
        z->g_tmp[i] = find_globnum(z, a);
    }
    #undef ADDGLOB
}

/* ---------- vocabulary values ---------- */

static void number_vocab(zc *z) {
    zm_game *g = z->g;
    z->words = calloc(g->word_count + g->direction_count, sizeof(vword));
    if (!z->words) abort();
    z->nwords = g->word_count;
    for (size_t i = 0; i < g->word_count; i++) {
        vword *w = &z->words[i];
        w->text = g->words[i].text;
        w->pos = g->words[i].pos;
        w->verb_val = w->adj_val = w->prep_val = w->buzz_val = -1;
        w->dir_idx = -1;
        zt_encode_word_v(w->text, w->enc, ZV);
    }
    /* implicitly-defined directions may introduce new words (or add the
     * direction sense to an existing word) */
    for (size_t i = z->declared_dirs; i < g->direction_count; i++) {
        const char *text = g->directions[i]->atom.name;
        vword *w = find_word(z, text);
        if (!w) {
            w = &z->words[z->nwords++];
            memset(w, 0, sizeof(*w));
            w->text = text;
            w->verb_val = w->adj_val = w->prep_val = w->buzz_val = -1;
            w->dir_idx = -1;
            zt_encode_word_v(text, w->enc, ZV);
        }
        w->pos |= ZM_POS_DIR;
    }

    /* acquisition chronology mirrors upstream compile order:
     * directions (ingest), syntax verbs+preps (ingest, in order),
     * buzzwords, object nouns/adjectives/pseudo (definition order),
     * synonyms last (copying values from the base word) */
    #define TOUCH(w, posbit, firstv) do { \
        if (!(w)->first_set) { (w)->first = (firstv); (w)->first_set = true; } \
    } while (0)

    for (size_t i = 0; i < g->direction_count; i++) {
        vword *w = find_word(z, g->directions[i]->atom.name);
        if (!w) continue;
        w->dir_idx = (int)i;
        TOUCH(w, ZM_POS_DIR, 3);
    }
    int nextverb = 255, nextprep = 255, nextadj = 255, nextbuzz = 255;
    for (size_t i = 0; i < g->syntax_count; i++) {
        zm_syntax *s = &g->syntaxes[i];
        vword *w = find_word(z, s->verb->atom.name);
        if (w && w->verb_val < 0) {
            w->verb_val = nextverb--;
            TOUCH(w, ZM_POS_VERB, 1);
        }
        for (int k = 0; k < 2; k++) {
            if (!s->prep[k]) continue;
            vword *p = find_word(z, s->prep[k]->atom.name);
            if (p && p->prep_val < 0) {
                p->prep_val = nextprep--;
                /* upstream SetPreposition clears the First bits: the
                 * preposition value always occupies the first slot */
                p->first = 0;
                p->first_set = true;
            }
        }
    }
    for (size_t i = 0; i < g->buzz_count; i++) {
        vword *w = find_word(z, g->buzz[i]->atom.name);
        if (w && w->buzz_val < 0) {
            w->buzz_val = nextbuzz--;
            /* upstream SetBuzzword clears the First bits too */
            w->first = 0;
            w->first_set = true;
        }
    }
    for (size_t i = 0; i < g->object_count; i++) {
        zm_object *o = &g->objects[i];
        for (size_t p = 0; p < o->prop_count; p++) {
            zm_prop *pr = &o->props[p];
            if (atom_is(pr->head, "SYNONYM")) {
                for (size_t j = 0; j < pr->count; j++) {
                    if (pr->body[j]->type != CZ_ATOM) continue;
                    vword *w = find_word(z, pr->body[j]->atom.name);
                    if (w) TOUCH(w, ZM_POS_NOUN, 0);
                }
            } else if (atom_is(pr->head, "ADJECTIVE")) {
                for (size_t j = 0; j < pr->count; j++) {
                    if (pr->body[j]->type != CZ_ATOM) continue;
                    vword *w = find_word(z, pr->body[j]->atom.name);
                    if (w && w->adj_val < 0) {
                        w->adj_val = nextadj--;
                        TOUCH(w, ZM_POS_ADJ, 2);
                    }
                }
            } else if (atom_is(pr->head, "PSEUDO")) {
                for (size_t j = 0; j < pr->count; j++) {
                    if (pr->body[j]->type != CZ_STRING) continue;
                    vword *w = find_word(z, pr->body[j]->str.text);
                    if (w) TOUCH(w, ZM_POS_NOUN, 0);
                }
            }
        }
    }
    /* synonyms: copy every value from the base word */
    for (size_t i = 0; i < g->synonym_count; i++) {
        zm_synonym *syn = &g->synonyms[i];
        vword *base = find_word(z, syn->first->atom.name);
        if (!base) continue;
        for (size_t j = 0; j < syn->count; j++) {
            vword *w = find_word(z, syn->rest[j]->atom.name);
            if (!w) continue;
            if ((base->pos & ZM_POS_VERB) && w->verb_val < 0) {
                w->verb_val = base->verb_val;
                TOUCH(w, ZM_POS_VERB, 1);
            }
            if ((base->pos & ZM_POS_ADJ) && w->adj_val < 0) {
                w->adj_val = base->adj_val;
                TOUCH(w, ZM_POS_ADJ, 2);
            }
            if ((base->pos & ZM_POS_PREP) && w->prep_val < 0) {
                w->prep_val = base->prep_val;
                w->via_synonym_prep = true;
                w->first = 0;
                w->first_set = true;
            }
            if ((base->pos & ZM_POS_DIR) && w->dir_idx < 0) {
                w->dir_idx = base->dir_idx;
                TOUCH(w, ZM_POS_DIR, 3);
            }
            if ((base->pos & ZM_POS_BUZZ) && w->buzz_val < 0)
                w->buzz_val = base->buzz_val;
        }
    }
    #undef TOUCH
}

/* ---------- actions ---------- */

static cz_val *action_name_for(zc *z, zm_syntax *s) {
    /* V-TAKE becomes V?TAKE; anything else gets a V? prefix */
    const char *a = s->action->atom.name;
    char nm[128];
    if (a[0] == 'V' && a[1] == '-')
        snprintf(nm, sizeof nm, "V?%s", a + 2);
    else
        snprintf(nm, sizeof nm, "V?%s", a);
    return cz_intern(z->c, nm, strlen(nm));
}

static void number_actions(zc *z) {
    zm_game *g = z->g;
    z->act_name = calloc(g->syntax_count, sizeof(cz_val *));
    z->act_routine = calloc(g->syntax_count, sizeof(cz_val *));
    z->act_pre = calloc(g->syntax_count, sizeof(cz_val *));
    if (!z->act_name || !z->act_routine || !z->act_pre) abort();
    for (size_t i = 0; i < g->syntax_count; i++) {
        zm_syntax *s = &g->syntaxes[i];
        cz_val *nm = action_name_for(z, s);
        if (find_action(z, nm) >= 0) continue;
        z->act_name[z->nacts] = nm;
        z->act_routine[z->nacts] = s->action;
        z->act_pre[z->nacts] = s->preaction;
        z->nacts++;
    }
    if (z->nacts > 255) FAIL("too many actions (max 255)");
}

/* ================= data sections ================= */

/* dictionary sorted by encoded text */
static int dict_cmp(const void *a, const void *b) {
    return memcmp(((const vword *)a)->enc, ((const vword *)b)->enc, (size_t)DICTTEXT);
}

static void emit_dictionary(zc *z) {
    buf *b = &z->sec[SEC_DICT];
    qsort(z->words, z->nwords, sizeof(vword), dict_cmp);
    /* drop duplicate encodings (distinct raw words truncating identically
     * merge; parts of speech OR together, first-come values win) */
    size_t out = 0;
    for (size_t i = 0; i < z->nwords; i++) {
        if (out > 0 && memcmp(z->words[out - 1].enc, z->words[i].enc, (size_t)DICTTEXT) == 0) {
            vword *a = &z->words[out - 1], *w = &z->words[i];
            a->pos |= w->pos;
            if (a->verb_val < 0) a->verb_val = w->verb_val;
            if (a->adj_val < 0) a->adj_val = w->adj_val;
            if (a->prep_val < 0) a->prep_val = w->prep_val;
            if (a->dir_idx < 0) a->dir_idx = w->dir_idx;
            if (a->buzz_val < 0) a->buzz_val = w->buzz_val;
            /* keep both raw spellings findable */
            continue;
        }
        z->words[out++] = z->words[i];
    }
    /* words dropped by the dedup still need lookup by text: point them at
     * the survivor via a second pass in find below; simplest is to keep
     * nwords trimmed and rely on find_word matching the survivor text.
     * Raw-text lookups for dropped spellings go through encoding: */
    z->nwords = out;
    for (size_t i = 0; i < z->nwords; i++) z->words[i].dict_index = (int)i;

    const char *seps = ",.\"";
    put8(b, (uint8_t)strlen(seps));
    for (const char *p = seps; *p; p++) put8(b, (uint8_t)*p);
    put8(b, (uint8_t)(DICTTEXT + 3));  /* text + 3 data bytes */
    put16(b, (uint16_t)z->nwords);
    for (size_t i = 0; i < z->nwords; i++) {
        vword *w = &z->words[i];
        for (int k = 0; k < DICTTEXT; k++) put8(b, w->enc[k]);

        uint8_t pos = 0;
        if (w->pos & ZM_POS_BUZZ) pos |= 4;
        if (w->pos & ZM_POS_PREP) pos |= 8;
        if (w->pos & ZM_POS_DIR) pos |= 16;
        if (w->pos & ZM_POS_ADJ) pos |= 32;
        if (w->pos & ZM_POS_VERB) pos |= 64;
        if (w->pos & ZM_POS_NOUN) pos |= 128;
        if (w->first_set) pos |= (uint8_t)w->first;
        put8(b, pos);

        /* value bytes, ordered per OldParserWord.WriteToBuilder */
        uint8_t vals[2] = { 0, 0 };
        int nv = 0;
        int parts[6]; int np = 0;
        enum { PV_ADJ, PV_DIR, PV_VERB, PV_OBJ, PV_BUZZ, PV_PREP };
        if ((w->pos & ZM_POS_ADJ) && ZV == 3) {
            if ((pos & 3) == 2) { memmove(parts + 1, parts, np * sizeof(int)); parts[0] = PV_ADJ; np++; }
            else parts[np++] = PV_ADJ;
        }
        if (w->pos & ZM_POS_DIR) {
            if ((pos & 3) == 3) { memmove(parts + 1, parts, np * sizeof(int)); parts[0] = PV_DIR; np++; }
            else parts[np++] = PV_DIR;
        }
        if (w->pos & ZM_POS_VERB) {
            if ((pos & 3) == 1) { memmove(parts + 1, parts, np * sizeof(int)); parts[0] = PV_VERB; np++; }
            else parts[np++] = PV_VERB;
        }
        if (w->pos & ZM_POS_NOUN) {
            if ((pos & 3) == 0) { memmove(parts + 1, parts, np * sizeof(int)); parts[0] = PV_OBJ; np++; }
            else parts[np++] = PV_OBJ;
        }
        if (w->pos & ZM_POS_BUZZ) {
            memmove(parts + 1, parts, np * sizeof(int)); parts[0] = PV_BUZZ; np++;
        }
        if (w->pos & ZM_POS_PREP) {
            memmove(parts + 1, parts, np * sizeof(int)); parts[0] = PV_PREP; np++;
        }
        for (int k = 0; k < np && nv < 2; k++) {
            int v = 0;
            switch (parts[k]) {
            case PV_ADJ: v = w->adj_val; break;
            case PV_DIR:
                /* the dictionary direction value is the property number */
                v = w->dir_idx >= 0
                    ? find_propnum(z, z->g->directions[w->dir_idx]) : 0;
                break;
            case PV_VERB: v = w->verb_val; break;
            case PV_OBJ: v = 1; break;   /* upstream OldParserWord.SetObject */
            case PV_BUZZ: v = w->buzz_val; break;
            case PV_PREP: v = w->prep_val; break;
            }
            vals[nv++] = (uint8_t)(v < 0 ? 0 : v);
        }
        put8(b, vals[0]);
        put8(b, vals[1]);
    }
}

/* ---------- tables ---------- */

static void emit_table_element(zc *z, buf *b, int sec, cz_val *el, bool as_byte) {
    constref r = resolve_constant(z, el);
    if (!r.ok) {
        char *s = NULL; size_t l = 0, cp = 0;
        cz_print(el, &s, &l, &cp);
        FAIL("non-constant table element: %.100s", s ? s : "?");
        free(s);
        return;
    }
    if (as_byte) {
        if (r.fixkind != FX_NONE) { FAIL("byte table element needs an address"); return; }
        put8(b, (uint8_t)r.val);
    } else {
        if (r.fixkind != FX_NONE) add_fixup(z, sec, b->n, r.fixkind, r.fixidx);
        put16(b, (uint16_t)r.val);
    }
}

static void emit_game_tables(zc *z) {
    zm_game *g = z->g;
    z->ntables = g->table_count;
    z->tab_sec = calloc(z->ntables + 8, sizeof(int));
    z->tab_off = calloc(z->ntables + 8, sizeof(size_t));
    if (!z->tab_sec || !z->tab_off) abort();

    for (size_t i = 0; i < g->table_count; i++) {
        cz_val *t = g->tables[i];
        int sec = (t->tab.tflags & ZM_TBL_PURE) ? SEC_PURETAB : SEC_IMPTAB;
        buf *b = &z->sec[sec];
        z->tab_sec[i] = sec;

        bool lexv = (t->tab.tflags & ZM_TBL_LEXV) != 0;

        if (lexv) {
            z->tab_off[i] = b->n;
            put8(b, (uint8_t)(t->tab.count / 3));
            put8(b, 0);
            for (size_t k = 0; k < t->tab.count; k++)
                emit_table_element(z, b, sec, t->tab.items[k], k % 3 != 0);
            continue;
        }

        bool bytes = (t->tab.tflags & ZM_TBL_BYTE) != 0;
        if (t->tab.tflags & ZM_TBL_LENGTH) {
            z->tab_off[i] = b->n;
            if (bytes) put8(b, (uint8_t)t->tab.count);
            else put16(b, (uint16_t)t->tab.count);
        } else {
            z->tab_off[i] = b->n;
        }
        for (size_t k = 0; k < t->tab.count; k++) {
            cz_val *el = t->tab.items[k];
            bool as_byte = bytes;
            if (el->type == CZ_CHTYPE && atom_is(el->chtype.type_atom, "BYTE"))
                as_byte = true;
            emit_table_element(z, b, sec, el, as_byte);
        }
    }
}

/* ---------- syntax tables ---------- */

static uint8_t scope_opts(zc *z, cz_val *raw_syntax, int slot) {
    /* re-derive the options byte for OBJECT slot `slot` from the raw
     * syntax form: option lists after that OBJECT token, minus FIND */
    (void)z;
    uint8_t result = 0;
    bool any = false;
    int obj_seen = 0;
    for (size_t i = 0; i < raw_syntax->seq.count; i++) {
        cz_val *tok = raw_syntax->seq.items[i];
        if (atom_is(tok, "=")) break;
        if (tok->type == CZ_ATOM && strcmp(tok->atom.name, "OBJECT") == 0 && i > 0) {
            obj_seen++;
            continue;
        }
        if (tok->type == CZ_LIST && obj_seen == slot + 1 && tok->seq.count >= 1
            && !atom_is(tok->seq.items[0], "FIND")) {
            for (size_t j = 0; j < tok->seq.count; j++) {
                cz_val *o = tok->seq.items[j];
                if (atom_is(o, "HAVE")) { result |= 2; any = true; }
                else if (atom_is(o, "MANY")) { result |= 4; any = true; }
                else if (atom_is(o, "TAKE")) { result |= 8; any = true; }
                else if (atom_is(o, "ON-GROUND")) { result |= 16; any = true; }
                else if (atom_is(o, "IN-ROOM")) { result |= 32; any = true; }
                else if (atom_is(o, "CARRIED")) { result |= 64; any = true; }
                else if (atom_is(o, "HELD")) { result |= 128; any = true; }
            }
        }
    }
    return any ? result : (uint8_t)(16 | 32 | 64 | 128);   /* Original.Default */
}

static void emit_syntax_tables(zc *z, int *vtbl_tab, int *atbl_tab, int *patbl_tab, int *prtbl_tab) {
    zm_game *g = z->g;
    buf *b = &z->sec[SEC_PURETAB];

    /* ST? tables grouped by verb value, lines in reverse definition order */
    size_t nst = 0;
    int st_verbval[256];
    size_t st_off[256];
    for (size_t i = 0; i < g->syntax_count; i++) {
        vword *vw = find_word(z, g->syntaxes[i].verb->atom.name);
        if (!vw || vw->verb_val < 0) { FAIL("syntax verb has no verb value"); return; }
        int vv = vw->verb_val;
        bool seen = false;
        for (size_t k = 0; k < nst; k++) if (st_verbval[k] == vv) { seen = true; break; }
        if (seen) continue;

        /* count lines for this verb value */
        size_t lines = 0;
        for (size_t j = 0; j < g->syntax_count; j++) {
            vword *w2 = find_word(z, g->syntaxes[j].verb->atom.name);
            if (w2 && w2->verb_val == vv) lines++;
        }
        st_verbval[nst] = vv;
        st_off[nst] = b->n;
        nst++;
        put8(b, (uint8_t)lines);
        /* reverse definition order */
        for (size_t jj = g->syntax_count; jj > 0; jj--) {
            size_t j = jj - 1;
            zm_syntax *s = &g->syntaxes[j];
            vword *w2 = find_word(z, s->verb->atom.name);
            if (!w2 || w2->verb_val != vv) continue;
            /* 8 bytes: nobj prep1 prep2 find1 find2 opts1 opts2 action */
            put8(b, (uint8_t)s->num_objects);
            for (int k = 0; k < 2; k++) {
                int pv = 0;
                if (s->prep[k]) {
                    vword *pw = find_word(z, s->prep[k]->atom.name);
                    if (pw && pw->prep_val >= 0) pv = pw->prep_val;
                }
                put8(b, (uint8_t)pv);
            }
            for (int k = 0; k < 2; k++) {
                int fv = 0;
                if (s->find[k]) fv = find_flagnum(z, s->find[k]);
                put8(b, (uint8_t)(fv < 0 ? 0 : fv));
            }
            put8(b, scope_opts(z, s->raw, 0));
            put8(b, scope_opts(z, s->raw, 1));
            int ai = find_action(z, action_name_for(z, s));
            put8(b, (uint8_t)(ai < 0 ? 0 : ai));
        }
    }

    /* VTBL: one word per verb value 255..1 */
    size_t vtbl_off = b->n;
    for (int vv = 255; vv >= 1; vv--) {
        size_t off = 0;
        bool have = false;
        for (size_t k = 0; k < nst; k++)
            if (st_verbval[k] == vv) { off = st_off[k]; have = true; break; }
        if (have) {
            add_fixup(z, SEC_PURETAB, b->n, FX_SECBASE, SEC_PURETAB);
            put16(b, (uint16_t)off);
        } else {
            put16(b, 0);
        }
    }

    /* ATBL / PATBL */
    size_t atbl_off = b->n;
    for (size_t i = 0; i < z->nacts; i++) {
        int ri = find_routine(z, z->act_routine[i]);
        if (ri < 0) { FAIL("action routine not found"); return; }
        add_fixup(z, SEC_PURETAB, b->n, FX_ROUTINE, ri);
        put16(b, 0);
    }
    size_t patbl_off = b->n;
    for (size_t i = 0; i < z->nacts; i++) {
        if (z->act_pre[i]) {
            int ri = find_routine(z, z->act_pre[i]);
            if (ri < 0) { FAIL("preaction routine not found"); return; }
            add_fixup(z, SEC_PURETAB, b->n, FX_ROUTINE, ri);
            put16(b, 0);
        } else {
            put16(b, 0);
        }
    }

    /* PRTBL: count, then (word-addr, prep-value) pairs for non-synonym preps */
    size_t prtbl_off = b->n;
    size_t nprep = 0;
    for (size_t i = 0; i < z->nwords; i++)
        if ((z->words[i].pos & ZM_POS_PREP) && !z->words[i].via_synonym_prep) nprep++;
    put16(b, (uint16_t)nprep);
    for (size_t i = 0; i < z->nwords; i++) {
        vword *w = &z->words[i];
        if (!(w->pos & ZM_POS_PREP) || w->via_synonym_prep) continue;
        add_fixup(z, SEC_PURETAB, b->n, FX_WORD, (int)i);
        put16(b, 0);
        put16(b, (uint16_t)w->prep_val);
    }

    /* register the four tables as synthetic entries so constants and
     * globals can reference them via FX_TABLE */
    z->tab_sec[z->ntables] = SEC_PURETAB; z->tab_off[z->ntables] = vtbl_off; *vtbl_tab = (int)z->ntables++;
    z->tab_sec[z->ntables] = SEC_PURETAB; z->tab_off[z->ntables] = atbl_off; *atbl_tab = (int)z->ntables++;
    z->tab_sec[z->ntables] = SEC_PURETAB; z->tab_off[z->ntables] = patbl_off; *patbl_tab = (int)z->ntables++;
    z->tab_sec[z->ntables] = SEC_PURETAB; z->tab_off[z->ntables] = prtbl_off; *prtbl_tab = (int)z->ntables++;
}

/* ---------- objects ---------- */

typedef struct { int parent, sibling, child; } treelink;

static void build_tree(zc *z, treelink *tree) {
    zm_game *g = z->g;
    for (size_t i = 0; i < g->object_count; i++)
        tree[i] = (treelink){ 0, 0, 0 };

    /* insert in plain definition order, each child prepending to its
     * parent's chain, so FIRST? sees reverse definition order. This is
     * what the shipped Infocom files do (upstream TreeOrdering.
     * ReverseDefined); ZILF's Default mode adds a first-child exception
     * the shipped games don't have. */
    for (size_t i = 0; i < g->object_count; i++) {
        if (!g->objects[i].parent) continue;
        int pi = find_object(z, g->objects[i].parent);
        if (pi < 0) continue;
        tree[i].parent = z->obj_num[pi];
        tree[i].sibling = tree[pi].child;
        tree[pi].child = z->obj_num[i];
    }
}

typedef struct { void *z; buf *b; } strsink;
static void sink_word(void *ud, uint16_t w) {
    strsink *s = ud;
    put16(s->b, w);
}

static void emit_objects(zc *z) {
    zm_game *g = z->g;
    buf *b = &z->sec[SEC_OBJTAB];

    /* property defaults: 31 (v3) or 63 (v4+) words */
    uint16_t defaults[64] = { 0 };
    for (size_t i = 0; i < g->propdef_count; i++) {
        int pn = find_propnum(z, g->propdefs[i].name);
        if (pn < 1) continue;
        constref r = resolve_constant(z, g->propdefs[i].body[0]);
        if (!r.ok || r.fixkind != FX_NONE) { FAIL("PROPDEF default must be a plain constant"); return; }
        defaults[pn] = (uint16_t)r.val;
    }
    for (int pn = 1; pn <= MAXPROP; pn++) put16(b, defaults[pn]);

    treelink *tree = calloc(g->object_count, sizeof(treelink));
    if (!tree) abort();
    build_tree(z, tree);

    /* entries: 9 (v3) or 14 (v4+) bytes; prop pointers patched below */
    size_t entries_off = b->n;
    for (size_t i = 0; i < g->object_count; i++) {
        uint64_t attrs = 0;
        zm_object *o = &g->objects[i];
        int nattr = ZV >= 4 ? 48 : 32;
        for (size_t p = 0; p < o->prop_count; p++) {
            if (!atom_is(o->props[p].head, "FLAGS")) continue;
            for (size_t j = 0; j < o->props[p].count; j++) {
                if (o->props[p].body[j]->type != CZ_ATOM) continue;
                int fn = find_flagnum(z, o->props[p].body[j]);
                if (fn < 0) { FAIL("unknown flag"); free(tree); return; }
                attrs |= 1ull << (nattr - 1 - fn);
            }
        }
        for (int k = nattr / 8 - 1; k >= 0; k--)
            put8(b, (uint8_t)(attrs >> (8 * k)));
        if (ZV >= 4) {
            put16(b, (uint16_t)tree[i].parent);
            put16(b, (uint16_t)tree[i].sibling);
            put16(b, (uint16_t)tree[i].child);
        } else {
            put8(b, (uint8_t)tree[i].parent);
            put8(b, (uint8_t)tree[i].sibling);
            put8(b, (uint8_t)tree[i].child);
        }
        put16(b, 0);   /* prop table addr, patched below */
    }
    free(tree);

    /* property tables */
    for (size_t i = 0; i < g->object_count; i++) {
        zm_object *o = &g->objects[i];
        size_t ptoff = b->n;

        /* short name */
        if (o->desc) {
            char *desc = translate_zil_string(o->desc);
            buf tmp = { 0 };
            strsink sink = { z, &tmp };
            size_t words = zt_encode_string(desc, strlen(desc), sink_word, &sink);
            put8(b, (uint8_t)words);
            for (size_t k = 0; k < tmp.n; k++) put8(b, tmp.b[k]);
            free(tmp.b);
            free(desc);
        } else {
            put8(b, 0);
        }

        /* collect props: number + payload + local fixups */
        struct pfx { size_t off; int kind, idx; };
        struct pent { int num; buf data; struct pfx fx[8]; size_t nfx; };
        struct pent props[64];
        size_t np = 0;
        #define PFX(pb_, kind_, idx_) do { \
            if (props[np].nfx < 8) \
                props[np].fx[props[np].nfx++] = (struct pfx){ (pb_)->n, kind_, idx_ }; \
        } while (0)

        for (size_t p = 0; p < o->prop_count; p++) {
            zm_prop *pr = &o->props[p];
            if (atom_is(pr->head, "DESC") || atom_is(pr->head, "FLAGS")) continue;
            if ((atom_is(pr->head, "IN") || atom_is(pr->head, "LOC"))
                && pr->count == 1 && pr->body[0]->type == CZ_ATOM
                && find_object(z, pr->body[0]) >= 0
                && find_propnum(z, pr->head) < 0)
                continue;   /* pure location clause */

            int pn = find_propnum(z, pr->head);
            if (pn < 1) { FAIL("no property number for %s", pr->head->atom.name); return; }
            if (np >= 64) { FAIL("too many properties on %s", o->name->atom.name); return; }
            props[np].num = pn;
            memset(&props[np].data, 0, sizeof(buf));
            props[np].nfx = 0;
            buf *pb = &props[np].data;

            bool is_dir = false;
            for (size_t d = 0; d < g->direction_count; d++)
                if (g->directions[d] == pr->head) { is_dir = true; break; }

            if (is_dir) {
                /* exit props record fixups locally, mirroring emit_exit_prop */
                cz_val **eb = pr->body;
                size_t en = pr->count;
                if (en == 2 && atom_is(eb[0], "PER") && eb[1]->type == CZ_ATOM) {
                    int ri = find_routine(z, eb[1]);
                    if (ri < 0) { FAIL("PER exit: unknown routine %s", eb[1]->atom.name); return; }
                    PFX(pb, FX_ROUTINE, ri);
                    put16(pb, 0);
                    put8(pb, 0);
                } else if ((en == 2 && atom_is(eb[0], "SORRY") && eb[1]->type == CZ_STRING)
                           || (en == 1 && eb[0]->type == CZ_STRING)) {
                    cz_val *s = en == 2 ? eb[1] : eb[0];
                    PFX(pb, FX_STRING, intern_string(z, s->str.text));
                    put16(pb, 0);
                } else {
                    size_t ei = 0;
                    if (ei < en && atom_is(eb[ei], "TO")) ei++;
                    if (ei >= en || eb[ei]->type != CZ_ATOM) {
                        FAIL("unrecognized exit clause on %s", o->name->atom.name);
                        return;
                    }
                    int room = find_object(z, eb[ei]);
                    if (room < 0) { FAIL("exit to unknown room %s", eb[ei]->atom.name); return; }
                    ei++;
                    if (ei == en) {
                        put8(pb, (uint8_t)z->obj_num[room]);   /* UEXIT */
                    } else if (atom_is(eb[ei], "IF")) {
                        ei++;
                        if (ei >= en || eb[ei]->type != CZ_ATOM) { FAIL("bad conditional exit"); return; }
                        cz_val *cond = eb[ei++];
                        bool is_door = ei < en && atom_is(eb[ei], "IS");
                        if (is_door) {
                            ei++;
                            if (ei < en && atom_is(eb[ei], "OPEN")) ei++;
                        }
                        cz_val *elsestr = NULL;
                        if (ei < en && atom_is(eb[ei], "ELSE")) {
                            ei++;
                            if (ei < en && eb[ei]->type == CZ_STRING) elsestr = eb[ei++];
                        }
                        if (ei != en) { FAIL("bad conditional exit tail"); return; }
                        put8(pb, (uint8_t)z->obj_num[room]);
                        if (is_door) {
                            int di = find_object(z, cond);
                            if (di < 0) { FAIL("DEXIT: unknown door %s", cond->atom.name); return; }
                            put8(pb, (uint8_t)z->obj_num[di]);
                        } else {
                            int gn = find_globnum(z, cond);
                            if (gn < 0) { FAIL("CEXIT: unknown global %s", cond->atom.name); return; }
                            put8(pb, (uint8_t)gn);
                        }
                        if (elsestr) PFX(pb, FX_STRING, intern_string(z, elsestr->str.text));
                        put16(pb, 0);
                        if (is_door) put8(pb, 0);
                    } else {
                        FAIL("unrecognized exit clause on %s", o->name->atom.name);
                        return;
                    }
                }
            } else if (atom_is(pr->head, "SYNONYM")) {
                for (size_t j = 0; j < pr->count; j++) {
                    if (pr->body[j]->type != CZ_ATOM) continue;
                    vword *w = find_word(z, pr->body[j]->atom.name);
                    if (!w) { FAIL("SYNONYM word missing from vocab"); return; }
                    PFX(pb, FX_WORD, (int)(w - z->words));
                    put16(pb, 0);
                }
            } else if (atom_is(pr->head, "ADJECTIVE")) {
                for (size_t j = 0; j < pr->count; j++) {
                    if (pr->body[j]->type != CZ_ATOM) continue;
                    vword *w = find_word(z, pr->body[j]->atom.name);
                    if (!w) { FAIL("ADJECTIVE word missing"); return; }
                    if (ZV >= 4) {
                        /* v4+: adjectives are dictionary words, not numbers */
                        PFX(pb, FX_WORD, (int)(w - z->words));
                        put16(pb, 0);
                    } else {
                        if (w->adj_val < 0) { FAIL("ADJECTIVE word missing"); return; }
                        put8(pb, (uint8_t)w->adj_val);
                    }
                }
            } else if (atom_is(pr->head, "PSEUDO")) {
                for (size_t j = 0; j < pr->count; j++) {
                    if (pr->body[j]->type == CZ_STRING) {
                        vword *w = find_word(z, pr->body[j]->str.text);
                        if (!w) { FAIL("PSEUDO word missing"); return; }
                        PFX(pb, FX_WORD, (int)(w - z->words));
                        put16(pb, 0);
                    } else {
                        constref r = resolve_constant(z, pr->body[j]);
                        if (!r.ok) { FAIL("bad PSEUDO element"); return; }
                        if (r.fixkind != FX_NONE) PFX(pb, r.fixkind, r.fixidx);
                        put16(pb, (uint16_t)r.val);
                    }
                }
            } else if (atom_is(pr->head, "GLOBAL")) {
                for (size_t j = 0; j < pr->count; j++) {
                    int oi = pr->body[j]->type == CZ_ATOM ? find_object(z, pr->body[j]) : -1;
                    if (oi < 0) { FAIL("GLOBAL prop: unknown object"); return; }
                    put8(pb, (uint8_t)z->obj_num[oi]);
                }
            } else {
                for (size_t j = 0; j < pr->count; j++) {
                    constref r = resolve_constant(z, pr->body[j]);
                    if (!r.ok) {
                        char *s = NULL; size_t l = 0, cp = 0;
                        cz_print(pr->body[j], &s, &l, &cp);
                        FAIL("non-constant value for property %s on %s: %.80s",
                             pr->head->atom.name, o->name->atom.name, s ? s : "?");
                        free(s);
                        return;
                    }
                    if (r.fixkind != FX_NONE) PFX(pb, r.fixkind, r.fixidx);
                    put16(pb, (uint16_t)r.val);
                }
            }
            if (pb->n < 1 || pb->n > (ZV >= 4 ? 63u : 8u)) {
                FAIL("property %s on %s is %zu bytes (limit %d)",
                     pr->head->atom.name, o->name->atom.name, pb->n,
                     ZV >= 4 ? 63 : 8);
                return;
            }
            np++;
        }
        #undef PFX

        /* sort descending by property number (payload and fixups travel) */
        for (size_t a = 0; a < np; a++)
            for (size_t k = a + 1; k < np; k++)
                if (props[k].num > props[a].num) {
                    struct pent t = props[a];
                    props[a] = props[k];
                    props[k] = t;
                }

        for (size_t a = 0; a < np; a++) {
            if (ZV >= 4) {
                size_t plen = props[a].data.n;
                if (plen <= 2) {
                    put8(b, (uint8_t)(((plen - 1) << 6) | props[a].num));
                } else {
                    put8(b, (uint8_t)(0x80 | props[a].num));
                    put8(b, (uint8_t)(0x80 | (plen & 0x3f)));
                }
            } else
            put8(b, (uint8_t)(((props[a].data.n - 1) << 5) | props[a].num));
            size_t base = b->n;
            for (size_t k = 0; k < props[a].data.n; k++) put8(b, props[a].data.b[k]);
            for (size_t f = 0; f < props[a].nfx; f++)
                add_fixup(z, SEC_OBJTAB, base + props[a].fx[f].off,
                          props[a].fx[f].kind, props[a].fx[f].idx);
            free(props[a].data.b);
        }
        put8(b, 0);

        /* the entry's prop table pointer: offset now, section base later */
        patch16(b, entries_off + i * (size_t)OBJENT + OBJENT - 2, (uint16_t)ptoff);
        add_fixup(z, SEC_OBJTAB, entries_off + i * (size_t)OBJENT + OBJENT - 2,
                  FX_SECBASE, SEC_OBJTAB);
    }
}

static void emit_globals(zc *z, int vtbl_tab, int atbl_tab, int patbl_tab, int prtbl_tab) {
    zm_game *g = z->g;
    buf *b = &z->sec[SEC_GLOBALS];
    /* 240 words, G16..G255 */
    uint16_t init[240] = { 0 };
    size_t fxg[240];
    int fxk[240], fxi[240];
    for (int i = 0; i < 240; i++) { fxk[i] = FX_NONE; fxg[i] = 0; fxi[i] = 0; }

    for (size_t i = 0; i < g->global_count; i++) {
        int gn = find_globnum(z, g->globals[i].name);
        if (gn < 16) continue;
        constref r = resolve_constant(z, g->globals[i].value);
        if (!r.ok) {
            /* atoms that never resolve (forward-named tables etc.) are
             * left at 0; report to be safe */
            char *s = NULL; size_t l = 0, cp = 0;
            cz_print(g->globals[i].value, &s, &l, &cp);
            FAIL("global %s: non-constant initial value %.80s",
                 g->globals[i].name->atom.name, s ? s : "?");
            free(s);
            return;
        }
        init[gn - 16] = (uint16_t)r.val;
        fxk[gn - 16] = r.fixkind;
        fxi[gn - 16] = r.fixidx;
    }
    int rtabs[4] = { prtbl_tab, atbl_tab, patbl_tab, vtbl_tab };
    for (int i = 0; i < 4; i++) {
        int gn = z->glob_reserved[i];
        init[gn - 16] = 0;
        fxk[gn - 16] = FX_TABLE;
        fxi[gn - 16] = rtabs[i];
    }
    for (int i = 0; i < 240; i++) {
        if (fxk[i] != FX_NONE) add_fixup(z, SEC_GLOBALS, b->n, fxk[i], fxi[i]);
        put16(b, init[i]);
    }
    (void)fxg;
}

/* ================= routine compiler ================= */

enum { OT_LARGE = 0, OT_SMALL = 1, OT_VAR = 2 };

typedef struct {
    int type;
    uint16_t val;
    int fixkind, fixidx;
} opnd;

static opnd op_imm(int32_t v) {
    if (v >= 0 && v <= 255) return (opnd){ OT_SMALL, (uint16_t)v, FX_NONE, 0 };
    return (opnd){ OT_LARGE, (uint16_t)v, FX_NONE, 0 };
}
static opnd op_var(int v) { return (opnd){ OT_VAR, (uint16_t)v, FX_NONE, 0 }; }
static opnd op_cref(constref r) {
    if (r.fixkind != FX_NONE) return (opnd){ OT_LARGE, (uint16_t)r.val, r.fixkind, r.fixidx };
    return op_imm(r.val);
}

#define SP 0
#define NO_STORE (-1)

/* branch targets: label >= 0, or: */
#define BR_NONE   (-1)
#define BR_RFALSE (-2)
#define BR_RTRUE  (-3)

typedef struct { int again, end; bool want_value; } blockrec;
typedef struct { size_t off; int label; bool pol; bool is_jump; } brrec;

typedef struct {
    zc *z;
    buf *b;
    cz_val *local_name[15];
    int nlocals;
    blockrec blocks[32];
    int nblocks;
    size_t labels[512]; int nlabels;
    brrec brs[1024]; int nbrs;
    const char *rname;
} rt;

static int new_label(rt *r) {
    if (r->nlabels >= 512) { FAIL("%s: too many labels", r->rname); return 0; }
    r->labels[r->nlabels] = SIZE_MAX;
    return r->nlabels++;
}
static void place_label(rt *r, int l) { r->labels[l] = r->b->n; }

static void emit_operand(rt *r, opnd o) {
    if (o.type == OT_LARGE) {
        if (o.fixkind != FX_NONE) add_fixup(r->z, SEC_CODE, r->b->n, o.fixkind, o.fixidx);
        put16(r->b, o.val);
    } else {
        put8(r->b, (uint8_t)o.val);
    }
}

static void emit_branch(rt *r, int target, bool pol) {
    if (target == BR_RFALSE || target == BR_RTRUE) {
        put8(r->b, (uint8_t)((pol ? 0x80 : 0) | 0x40 | (target == BR_RTRUE ? 1 : 0)));
        return;
    }
    if (r->nbrs >= 1024) { FAIL("%s: too many branches", r->rname); return; }
    r->brs[r->nbrs++] = (brrec){ r->b->n, target, pol, false };
    put16(r->b, 0);
}

static void emit_jump(rt *r, int label) {
    put8(r->b, 0x8C);   /* short 1OP, large const: jump */
    if (r->nbrs >= 1024) { FAIL("%s: too many branches", r->rname); return; }
    r->brs[r->nbrs++] = (brrec){ r->b->n, label, false, true };
    put16(r->b, 0);
}

/* 2OP: long form when both operands are byte-sized, else VAR form */
static void emit_2op(rt *r, uint8_t op, opnd a, opnd b, int store, int btarget, bool bpol) {
    if (a.type != OT_LARGE && b.type != OT_LARGE) {
        put8(r->b, (uint8_t)((a.type == OT_VAR ? 0x40 : 0)
                           | (b.type == OT_VAR ? 0x20 : 0) | op));
        put8(r->b, (uint8_t)a.val);
        put8(r->b, (uint8_t)b.val);
    } else {
        put8(r->b, (uint8_t)(0xC0 | op));
        uint8_t types = (uint8_t)((a.type << 6) | (b.type << 4) | 0x0F);
        put8(r->b, types);
        emit_operand(r, a);
        emit_operand(r, b);
    }
    if (store >= 0) put8(r->b, (uint8_t)store);
    if (btarget != BR_NONE) emit_branch(r, btarget, bpol);
}

static void emit_1op(rt *r, uint8_t op, opnd a, int store, int btarget, bool bpol) {
    put8(r->b, (uint8_t)(0x80 | (a.type << 4) | op));
    emit_operand(r, a);
    if (store >= 0) put8(r->b, (uint8_t)store);
    if (btarget != BR_NONE) emit_branch(r, btarget, bpol);
}

static void emit_0op(rt *r, uint8_t op, int btarget, bool bpol) {
    put8(r->b, (uint8_t)(0xB0 | op));
    if (btarget != BR_NONE) emit_branch(r, btarget, bpol);
}

static void emit_varop(rt *r, uint8_t op, bool is_2op_var, opnd *ops, size_t n,
                       int store, int btarget, bool bpol) {
    put8(r->b, (uint8_t)((is_2op_var ? 0xC0 : 0xE0) | op));
    uint8_t types = 0;
    for (size_t i = 0; i < 4; i++) {
        int t = i < n ? ops[i].type : 3;
        types = (uint8_t)(types | (t << (6 - 2 * i)));
    }
    put8(r->b, types);
    for (size_t i = 0; i < n; i++) emit_operand(r, ops[i]);
    if (store >= 0) put8(r->b, (uint8_t)store);
    if (btarget != BR_NONE) emit_branch(r, btarget, bpol);
}

static void emit_print_inline(rt *r, const char *raw, bool print_ret) {
    put8(r->b, (uint8_t)(0xB0 | (print_ret ? 0x03 : 0x02)));
    char *text = translate_zil_string(raw);
    strsink sink = { r->z, r->b };
    zt_encode_string(text, strlen(text), sink_word, &sink);
    free(text);
}

/* ---------- variable resolution ---------- */

static int find_local(rt *r, cz_val *atom) {
    for (int i = 0; i < r->nlocals; i++)
        if (r->local_name[i] == atom) return i + 1;
    return -1;
}

/* variable number for SET/VALUE/IGRTR?/etc: local first, then global */
static int find_variable(rt *r, cz_val *atom) {
    int l = find_local(r, atom);
    if (l > 0) return l;
    return find_globnum(r->z, atom);
}

/* ---------- expression compiler ---------- */

static opnd compile_value(rt *r, cz_val *v);
static void compile_stmt(rt *r, cz_val *v);
static void compile_pred(rt *r, cz_val *v, int target, bool branch_when_true);

/* ensure a just-computed operand can be reused after more code runs:
 * pull stack values into a scratch global (call-free window only) */
static opnd stash(rt *r, opnd o, int which) {
    if (o.type != OT_VAR || o.val != SP) return o;
    int gv = r->z->g_tmp[which];
    opnd ov = op_var(gv);
    opnd args[1] = { op_imm(gv) };
    emit_varop(r, 0x09, false, args, 1, NO_STORE, BR_NONE, false);   /* pull */
    return ov;
}

/* compile a list of operands left to right; resolve multi-stack ordering
 * by pulling all but the first stack operand into scratch globals */
static bool compile_operands(rt *r, cz_val **args, size_t n, opnd *out) {
    int sp_count = 0;
    for (size_t i = 0; i < n; i++) {
        out[i] = compile_value(r, args[i]);
        if (out[i].type == OT_VAR && out[i].val == SP) sp_count++;
    }
    if (sp_count > 1) {
        if (sp_count - 1 > 3) { FAIL("%s: too many stacked operands", r->rname); return false; }
        /* pull from the top: the LAST sp operands come off first */
        int t = 0;
        for (size_t i = n; i > 0; i--) {
            size_t k = i - 1;
            if (out[k].type == OT_VAR && out[k].val == SP) {
                if (sp_count == 1) break;   /* leave the first on the stack */
                out[k] = stash(r, out[k], t++);
                sp_count--;
            }
        }
    }
    return true;
}


/* ---------- builtin dispatch ---------- */

typedef enum {
    CTX_VALUE, CTX_STMT
} ectx;

static bool head_is(cz_val *form, const char *name) {
    return form->seq.count > 0 && atom_is(form->seq.items[0], name);
}

/* predicate primitive classification */
typedef struct {
    const char *name;
    int cls;         /* 0=2op, 1=1op, 2=0op, 3=var-2op-je */
    uint8_t op;
    bool invert;     /* result sense inverted (N==?) */
    bool var_first;  /* first arg is a variable NAME (dec_chk/inc_chk) */
} predspec;

static const predspec PREDS[] = {
    { "EQUAL?", 3, 0x01, false, false },
    { "==?",    3, 0x01, false, false },
    { "=?",     3, 0x01, false, false },
    { "N==?",   3, 0x01, true, false },
    { "L?",     0, 0x02, false, false },
    { "LESS?",  0, 0x02, false, false },
    { "G?",     0, 0x03, false, false },
    { "GRTR?",  0, 0x03, false, false },
    { "G=?",    0, 0x02, true, false },   /* not less-than */
    { "L=?",    0, 0x03, true, false },   /* not greater-than */
    { "DLESS?", 0, 0x04, false, true },
    { "IGRTR?", 0, 0x05, false, true },
    { "IN?",    0, 0x06, false, false },
    { "BTST",   0, 0x07, false, false },
    { "FSET?",  0, 0x0A, false, false },
    { "0?",     1, 0x00, false, false },
    { "ZERO?",  1, 0x00, false, false },
    { "SAVE",   2, 0x05, false, false },
    { "RESTORE",2, 0x06, false, false },
    { "VERIFY", 2, 0x0D, false, false },
};

static const predspec *find_pred(const char *name) {
    for (size_t i = 0; i < sizeof(PREDS) / sizeof(PREDS[0]); i++)
        if (strcmp(PREDS[i].name, name) == 0) return &PREDS[i];
    return NULL;
}

/* store-op primitives: name -> (class, opcode) */
typedef struct { const char *name; int cls; uint8_t op; int min_args, max_args; } storespec;
static const storespec STORES[] = {
    { "+",      0, 0x14, 0, 8 }, { "ADD", 0, 0x14, 2, 8 },
    { "-",      0, 0x15, 0, 8 }, { "SUB", 0, 0x15, 2, 8 },
    { "*",      0, 0x16, 0, 8 }, { "MUL", 0, 0x16, 2, 8 },
    { "/",      0, 0x17, 0, 8 }, { "DIV", 0, 0x17, 2, 8 },
    { "MOD",    0, 0x18, 2, 2 },
    { "BAND",   0, 0x09, 2, 2 }, { "ANDB", 0, 0x09, 2, 2 },
    { "BOR",    0, 0x08, 2, 2 }, { "ORB", 0, 0x08, 2, 2 },
    { "GET",    0, 0x0F, 2, 2 }, { "NTH", 0, 0x0F, 2, 2 }, { "ZGET", 0, 0x0F, 2, 2 },
    { "GETB",   0, 0x10, 2, 2 },
    { "GETP",   0, 0x11, 2, 2 },
    { "GETPT",  0, 0x12, 2, 2 },
    { "NEXTP",  0, 0x13, 2, 2 },
    { "LOC",    1, 0x03, 1, 1 },
    { "PTSIZE", 1, 0x04, 1, 1 },
    { "RANDOM", 4, 0x07, 1, 1 },
    { "BACK",   0, 0x15, 1, 2 },   /* sub, default 1 */
    { "REST",   0, 0x14, 1, 2 },   /* add, default 1 */
};
static const storespec *find_store(const char *name) {
    for (size_t i = 0; i < sizeof(STORES) / sizeof(STORES[0]); i++)
        if (strcmp(STORES[i].name, name) == 0) return &STORES[i];
    return NULL;
}

/* void primitives */
typedef struct { const char *name; int cls; uint8_t op; int nargs; } voidspec;
static const voidspec VOIDS[] = {
    { "PUT",    4, 0x01, 3 },   /* storew */
    { "PUTB",   4, 0x02, 3 },
    { "PUTP",   4, 0x03, 3 },
    { "FSET",   0, 0x0B, 2 },
    { "FCLEAR", 0, 0x0C, 2 },
    { "MOVE",   0, 0x0E, 2 },
    { "REMOVE", 1, 0x09, 1 },
    { "PUSH",   4, 0x08, 1 },
    { "READ",   4, 0x04, 2 },
    { "PRINTD", 1, 0x0A, 1 },   /* print_obj */
    { "PRINT",  1, 0x0D, 1 },   /* print_paddr */
    { "PRINTB", 1, 0x07, 1 },   /* print_addr */
    { "PRINTN", 4, 0x06, 1 },
    { "PRINTC", 4, 0x05, 1 },
    { "DIROUT", 4, 0x13, 1 },
    { "DIRIN",  4, 0x14, 1 },
    { "CRLF",   2, 0x0B, 0 },
    { "QUIT",   2, 0x0A, 0 },
    { "RESTART",2, 0x07, 0 },
    { "USL",    2, 0x0C, 0 },
};
static const voidspec *find_void(const char *name) {
    for (size_t i = 0; i < sizeof(VOIDS) / sizeof(VOIDS[0]); i++)
        if (strcmp(VOIDS[i].name, name) == 0) return &VOIDS[i];
    return NULL;
}

static void emit_store_generic(rt *r, const storespec *s, cz_val **args, size_t n, int store) {
    opnd ops[8];
    /* BACK/REST default second operand */
    cz_val *one = NULL;
    if ((strcmp(s->name, "BACK") == 0 || strcmp(s->name, "REST") == 0) && n == 1)
        one = cz_new_fix(r->z->c, 1);

    if (s->cls == 1) {
        if (n != 1) { FAIL("%s: %s takes 1 argument", r->rname, s->name); return; }
        if (!compile_operands(r, args, 1, ops)) return;
        emit_1op(r, s->op, ops[0], store, BR_NONE, false);
        return;
    }
    if (s->cls == 4) {   /* true VAR op with store */
        if (!compile_operands(r, args, n, ops)) return;
        emit_varop(r, s->op, false, ops, n, store, BR_NONE, false);
        return;
    }
    /* 2OP, possibly folded left for + and * etc. */
    if (one) {
        if (!compile_operands(r, args, 1, ops)) return;
        ops[1] = op_imm(1);
        emit_2op(r, s->op, ops[0], ops[1], store, BR_NONE, false);
        return;
    }
    if (n == 0) {
        /* <+> = 0, <*> = 1, </> = 1, <-> = 0 as constants */
        int32_t v = (s->op == 0x16 || s->op == 0x17) ? 1 : 0;
        opnd zero = op_imm(0), val = op_imm(v);
        emit_2op(r, 0x14, zero, val, store, BR_NONE, false);   /* add 0 v */
        return;
    }
    if (n == 1) {
        if (s->op == 0x15) {   /* unary minus: sub 0 x */
            if (!compile_operands(r, args, 1, ops + 1)) return;
            ops[0] = op_imm(0);
            emit_2op(r, s->op, ops[0], ops[1], store, BR_NONE, false);
        } else if (s->op == 0x17) {   /* </ x> = 1/x */
            if (!compile_operands(r, args, 1, ops + 1)) return;
            ops[0] = op_imm(1);
            emit_2op(r, s->op, ops[0], ops[1], store, BR_NONE, false);
        } else {
            /* <+ x> = x, <* x> = x: add x 0 */
            if (!compile_operands(r, args, 1, ops)) return;
            emit_2op(r, 0x14, ops[0], op_imm(0), store, BR_NONE, false);
        }
        return;
    }
    /* left fold: op(op(a,b),c)... intermediate results on the stack */
    opnd acc;
    {
        if (!compile_operands(r, args, 2, ops)) return;
        emit_2op(r, s->op, ops[0], ops[1], (n == 2) ? store : SP, BR_NONE, false);
        acc = op_var(SP);
    }
    for (size_t i = 2; i < n; i++) {
        opnd next[2];
        next[0] = acc;
        next[1] = compile_value(r, args[i]);
        if (next[1].type == OT_VAR && next[1].val == SP) {
            /* acc(SP) below next(SP): fetch order would swap them */
            next[1] = stash(r, next[1], 0);
        }
        emit_2op(r, s->op, next[0], next[1], (i == n - 1) ? store : SP, BR_NONE, false);
        acc = op_var(SP);
    }
}

/* multi-operand je: branch to target when x equals any of vals */
static void emit_je_chain(rt *r, cz_val **args, size_t n, int target, bool bwt) {
    opnd ops[4];
    if (n < 2) { FAIL("%s: EQUAL? needs 2+ args", r->rname); return; }
    if (n <= 4) {
        if (!compile_operands(r, args, n, ops)) return;
        if (n == 2)
            emit_2op(r, 0x01, ops[0], ops[1], NO_STORE, target, bwt);
        else
            emit_varop(r, 0x01, true, ops, n, NO_STORE, target, bwt);
        return;
    }
    /* x against >3 values: keep x in a temp, chain je groups */
    opnd x = compile_value(r, args[0]);
    x = stash(r, x, 2);
    if (x.type == OT_VAR && x.val == SP) x = stash(r, x, 2);
    int done = -1;
    if (!bwt) done = new_label(r);
    size_t i = 1;
    while (i < n) {
        size_t take = n - i > 3 ? 3 : n - i;
        opnd grp[4];
        grp[0] = x;
        cz_val **sub = args + i;
        opnd tmp[3];
        if (!compile_operands(r, sub, take, tmp)) return;
        for (size_t k = 0; k < take; k++) grp[k + 1] = tmp[k];
        bool last = i + take >= n;
        if (bwt) {
            emit_varop(r, 0x01, true, grp, take + 1, NO_STORE, target, true);
        } else {
            if (!last)
                emit_varop(r, 0x01, true, grp, take + 1, NO_STORE, done, true);
            else
                emit_varop(r, 0x01, true, grp, take + 1, NO_STORE, target, false);
        }
        i += take;
    }
    if (done >= 0) place_label(r, done);
}

static void compile_pred(rt *r, cz_val *v, int target, bool bwt) {
    if (zc_failed) return;
    /* atoms and literals */
    if (v->type == CZ_ATOM) {
        if (atom_is(v, "T") || atom_is(v, "ELSE")) {
            if (bwt) emit_jump(r, target);
            return;
        }
        opnd o = compile_value(r, v);
        emit_1op(r, 0x00, o, NO_STORE, target, !bwt);   /* jz */
        return;
    }
    if (v->type == CZ_FALSE) {
        if (!bwt) emit_jump(r, target);
        return;
    }
    if (v->type == CZ_FIX) {
        if ((v->fix.value != 0) == bwt) emit_jump(r, target);
        return;
    }
    if (v->type != CZ_FORM || v->seq.count == 0) {
        FAIL("%s: cannot compile predicate", r->rname);
        return;
    }

    cz_val *head = v->seq.items[0];
    cz_val **args = v->seq.items + 1;
    size_t n = v->seq.count - 1;

    if (head->type == CZ_ATOM) {
        /* macro expansion */
        cz_val *gv = cz_getg(r->z->c, head);
        if (gv && gv->type == CZ_MACRO) {
            cz_result e = cz_apply(r->z->c, gv->seg.inner, args, n, false);
            if (e.flow != CZ_F_NORMAL) { FAIL("macro %s failed", head->atom.name); return; }
            compile_pred(r, e.val, target, bwt);
            return;
        }
        const char *nm = head->atom.name;
        if (strcmp(nm, "NOT") == 0 && n == 1) {
            compile_pred(r, args[0], target, !bwt);
            return;
        }
        if (strcmp(nm, "AND") == 0) {
            if (n == 0) { if (bwt) emit_jump(r, target); return; }
            if (bwt) {
                int out = new_label(r);
                for (size_t i = 0; i + 1 < n; i++) compile_pred(r, args[i], out, false);
                compile_pred(r, args[n - 1], target, true);
                place_label(r, out);
            } else {
                for (size_t i = 0; i < n; i++) compile_pred(r, args[i], target, false);
            }
            return;
        }
        if (strcmp(nm, "OR") == 0) {
            if (n == 0) { if (!bwt) emit_jump(r, target); return; }
            if (bwt) {
                for (size_t i = 0; i < n; i++) compile_pred(r, args[i], target, true);
            } else {
                int out = new_label(r);
                for (size_t i = 0; i + 1 < n; i++) compile_pred(r, args[i], out, true);
                compile_pred(r, args[n - 1], target, false);
                place_label(r, out);
            }
            return;
        }
        if (strcmp(nm, "1?") == 0 && n == 1) {
            opnd ops[1];
            if (!compile_operands(r, args, 1, ops)) return;
            emit_2op(r, 0x01, ops[0], op_imm(1), NO_STORE, target, bwt);   /* je x 1 */
            return;
        }
        const predspec *p = find_pred(nm);
        if (p) {
            bool sense = p->invert ? !bwt : bwt;
            switch (p->cls) {
            case 3:
                if (p->invert) emit_je_chain(r, args, n, target, sense);
                else emit_je_chain(r, args, n, target, sense);
                return;
            case 2:
                if (n != 0) { FAIL("%s: %s takes no args", r->rname, nm); return; }
                if (ZV >= 5 && (p->op == 0x05 || p->op == 0x06)) {
                    /* v5 save/restore are EXT store ops; test the value */
                    put8(r->b, 0xBE);
                    put8(r->b, p->op == 0x05 ? 0x00 : 0x01);
                    put8(r->b, 0xFF);            /* no operands */
                    put8(r->b, SP);
                    emit_1op(r, 0x00, op_var(SP), NO_STORE, target, !sense);  /* jz */
                    return;
                }
                emit_0op(r, p->op, target, sense);
                return;
            case 1: {
                opnd ops[1];
                if (n != 1 || !compile_operands(r, args, 1, ops)) { FAIL("%s: bad %s", r->rname, nm); return; }
                emit_1op(r, p->op, ops[0], NO_STORE, target, sense);
                return;
            }
            case 0: {
                opnd ops[2];
                if (n != 2) { FAIL("%s: %s takes 2 args", r->rname, nm); return; }
                if (p->var_first) {
                    if (args[0]->type != CZ_ATOM &&
                        !(args[0]->type == CZ_FORM && head_is(args[0], "QUOTE")))
                        { FAIL("%s: %s needs a variable name", r->rname, nm); return; }
                    cz_val *va = args[0]->type == CZ_ATOM ? args[0] : args[0]->seq.items[1];
                    int vn = find_variable(r, va);
                    if (vn < 0) { FAIL("%s: unknown variable %s", r->rname, va->atom.name); return; }
                    ops[0] = op_imm(vn);
                    ops[1] = compile_value(r, args[1]);
                } else {
                    if (!compile_operands(r, args, 2, ops)) return;
                }
                emit_2op(r, p->op, ops[0], ops[1], NO_STORE, target, sense);
                return;
            }
            }
        }
        if (strcmp(nm, "FIRST?") == 0 || strcmp(nm, "NEXT?") == 0) {
            opnd ops[1];
            if (n != 1 || !compile_operands(r, args, 1, ops)) { FAIL("%s: bad %s", r->rname, nm); return; }
            emit_1op(r, strcmp(nm, "FIRST?") == 0 ? 0x02 : 0x01, ops[0],
                     r->z->g_dummy, target, bwt);
            return;
        }
    }

    /* fall back: compute the value and test it */
    opnd o = compile_value(r, v);
    emit_1op(r, 0x00, o, NO_STORE, target, !bwt);   /* jz, inverted */
}

/* value context: preds materialize as 1/0 on the stack */
static opnd materialize_pred(rt *r, cz_val *v) {
    int ltrue = new_label(r), lend = new_label(r);
    compile_pred(r, v, ltrue, true);
    opnd zero[1] = { op_imm(0) };
    emit_varop(r, 0x08, false, zero, 1, NO_STORE, BR_NONE, false);   /* push 0 */
    emit_jump(r, lend);
    place_label(r, ltrue);
    opnd onev[1] = { op_imm(1) };
    emit_varop(r, 0x08, false, onev, 1, NO_STORE, BR_NONE, false);   /* push 1 */
    place_label(r, lend);
    return op_var(SP);
}

/* push an operand (for COND/AND/OR value joins) */
static void push_opnd(rt *r, opnd o) {
    if (o.type == OT_VAR && o.val == SP) return;   /* already on the stack */
    opnd ops[1] = { o };
    emit_varop(r, 0x08, false, ops, 1, NO_STORE, BR_NONE, false);
}

static opnd compile_call(rt *r, cz_val *target_routine, cz_val **args, size_t n,
                         int store) {
    if (n > 3) { FAIL("%s: v3 calls take at most 3 arguments", r->rname); return op_imm(0); }
    opnd ops[4];
    int ri = find_routine(r->z, target_routine);
    if (ri < 0) { FAIL("%s: call to unknown routine %s", r->rname, target_routine->atom.name); return op_imm(0); }
    ops[0] = (opnd){ OT_LARGE, 0, FX_ROUTINE, ri };
    opnd tmp[3];
    if (!compile_operands(r, args, n, tmp)) return op_imm(0);
    for (size_t i = 0; i < n; i++) ops[i + 1] = tmp[i];
    emit_varop(r, 0x00, false, ops, n + 1, store, BR_NONE, false);
    return op_var(store == SP ? SP : (uint16_t)store);
}

static void compile_block(rt *r, cz_val **args, size_t n, bool repeat, bool want_value);

static void compile_cond(rt *r, cz_val **args, size_t n, bool want_value) {
    int lend = new_label(r);
    bool always_taken = false;
    for (size_t i = 0; i < n && !always_taken; i++) {
        cz_val *clause = args[i];
        if (clause->type != CZ_LIST || clause->seq.count == 0) {
            FAIL("%s: bad COND clause", r->rname);
            return;
        }
        cz_val *cond = clause->seq.items[0];
        bool is_true_literal = (cond->type == CZ_ATOM && (atom_is(cond, "T") || atom_is(cond, "ELSE")))
                             || cond->type == CZ_FIX;
        int lnext = new_label(r);

        if (clause->seq.count == 1 && !is_true_literal) {
            /* value of the clause is the condition itself */
            opnd v = compile_value(r, cond);
            if (want_value) {
                if (v.type == OT_VAR && v.val == SP) v = stash(r, v, 2);
                emit_1op(r, 0x00, v, NO_STORE, lnext, true);   /* jz -> next */
                push_opnd(r, v);
                emit_jump(r, lend);
            } else {
                emit_1op(r, 0x00, v, NO_STORE, lnext, true);
                emit_jump(r, lend);
            }
            place_label(r, lnext);
            continue;
        }

        if (!is_true_literal)
            compile_pred(r, cond, lnext, false);
        else
            always_taken = true;

        size_t body_n = clause->seq.count - 1;
        for (size_t j = 0; j + 1 < body_n; j++)
            compile_stmt(r, clause->seq.items[1 + j]);
        if (body_n > 0) {
            cz_val *last = clause->seq.items[clause->seq.count - 1];
            if (want_value) push_opnd(r, compile_value(r, last));
            else compile_stmt(r, last);
        } else if (want_value) {
            push_opnd(r, op_imm(1));   /* literal-true condition, empty body */
        }
        if (!(always_taken && i == n - 1))
            emit_jump(r, lend);
        place_label(r, lnext);
    }
    if (!always_taken && want_value)
        push_opnd(r, op_imm(0));       /* no clause matched */
    place_label(r, lend);
}

static void compile_andor(rt *r, cz_val **args, size_t n, bool is_and, bool want_value) {
    if (!want_value) {
        int l = new_label(r);
        /* evaluate with short-circuit; both outcomes converge */
        if (n > 0) {
            for (size_t i = 0; i + 1 < n; i++)
                compile_pred(r, args[i], l, !is_and);
            compile_stmt(r, args[n - 1]);
        }
        place_label(r, l);
        return;
    }
    int lend = new_label(r);
    if (n == 0) {
        push_opnd(r, op_imm(is_and ? 1 : 0));
        place_label(r, lend);
        return;
    }
    for (size_t i = 0; i + 1 < n; i++) {
        opnd v = compile_value(r, args[i]);
        if (v.type == OT_VAR && v.val == SP) v = stash(r, v, 2);
        if (is_and) {
            int lnext = new_label(r);
            emit_1op(r, 0x00, v, NO_STORE, lnext, false);   /* nonzero: continue */
            push_opnd(r, op_imm(0));
            emit_jump(r, lend);
            place_label(r, lnext);
        } else {
            int lnext = new_label(r);
            emit_1op(r, 0x00, v, NO_STORE, lnext, true);    /* zero: continue */
            push_opnd(r, v);
            emit_jump(r, lend);
            place_label(r, lnext);
        }
    }
    push_opnd(r, compile_value(r, args[n - 1]));
    place_label(r, lend);
}

static opnd compile_value(rt *r, cz_val *v) {
    if (zc_failed) return op_imm(0);
    switch (v->type) {
    case CZ_FIX: return op_imm(v->fix.value);
    case CZ_FALSE: return op_imm(0);
    case CZ_STRING:
        return (opnd){ OT_LARGE, 0, FX_STRING, intern_string(r->z, v->str.text) };
    case CZ_ATOM: {
        if (atom_is(v, "T")) return op_imm(1);
        constref cr = resolve_constant_atom(r->z, v);
        if (cr.ok) return op_cref(cr);
        FAIL("%s: cannot resolve atom %s", r->rname, v->atom.name);
        return op_imm(0);
    }
    case CZ_ADECL: return compile_value(r, v->adecl.value);
    case CZ_LIST:
        /* misplaced COND clause; upstream reports and skips it */
        fprintf(stderr, "warning: %s: misplaced bracketed list ignored\n", r->rname);
        return op_imm(1);
    case CZ_FORM: break;
    default:
        FAIL("%s: cannot compile value of this type", r->rname);
        return op_imm(0);
    }

    if (v->seq.count == 0) return op_imm(0);
    cz_val *head = v->seq.items[0];
    cz_val **args = v->seq.items + 1;
    size_t n = v->seq.count - 1;
    if (head->type != CZ_ATOM) { FAIL("%s: non-atom form head", r->rname); return op_imm(0); }
    const char *nm = head->atom.name;

    if (strcmp(nm, "LVAL") == 0 && n == 1) {
        int l = find_local(r, args[0]);
        if (l < 0) {
            /* fall back to a global: dynamic scoping leaks through here */
            int gn = find_globnum(r->z, args[0]);
            if (gn >= 16) return op_var(gn);
            FAIL("%s: unknown local %s", r->rname, args[0]->atom.name);
            return op_imm(0);
        }
        return op_var(l);
    }
    if (strcmp(nm, "GVAL") == 0 && n == 1) {
        int gn = find_globnum(r->z, args[0]);
        if (gn >= 16) {
            /* game GLOBALs are variables; anything else is a constant */
            if (game_global_value(r->z, args[0]) || gn >= 16) {
                bool reserved = false;
                for (int i = 0; i < 4; i++)
                    if (gn == r->z->glob_reserved[i]) reserved = true;
                if (game_global_value(r->z, args[0]) || reserved
                    || gn == r->z->g_dummy)
                    return op_var(gn);
            }
        }
        constref cr = resolve_constant_atom(r->z, args[0]);
        if (cr.ok) return op_cref(cr);
        FAIL("%s: unknown global %s", r->rname, args[0]->atom.name);
        return op_imm(0);
    }

    /* macro? */
    cz_val *gv = cz_getg(r->z->c, head);
    if (gv && gv->type == CZ_MACRO) {
        cz_result e = cz_apply(r->z->c, gv->seg.inner, args, n, false);
        if (e.flow != CZ_F_NORMAL) { FAIL("macro %s failed: %s", nm, cz_error(r->z->c)); return op_imm(0); }
        return compile_value(r, e.val);
    }

    if (strcmp(nm, "QUOTE") == 0 && n == 1)
        return compile_value(r, args[0]);   /* 'FOO as operand */

    if (strcmp(nm, "SET") == 0 || strcmp(nm, "SETG") == 0) {
        if (n != 2 || args[0]->type != CZ_ATOM) { FAIL("%s: bad %s", r->rname, nm); return op_imm(0); }
        int vn = strcmp(nm, "SET") == 0 ? find_variable(r, args[0])
                                        : find_globnum(r->z, args[0]);
        if (vn < 0) { FAIL("%s: unknown variable %s", r->rname, args[0]->atom.name); return op_imm(0); }
        opnd val = compile_value(r, args[1]);
        emit_2op(r, 0x0D, op_imm(vn), val, NO_STORE, BR_NONE, false);   /* store */
        return op_var(vn);
    }
    if (strcmp(nm, "VALUE") == 0 && n == 1) {
        opnd vo;
        if (args[0]->type == CZ_ATOM) {
            int vn = find_variable(r, args[0]);
            if (vn < 0) { FAIL("%s: unknown variable %s", r->rname, args[0]->atom.name); return op_imm(0); }
            vo = op_imm(vn);
        } else {
            /* indirect: the variable number is computed at runtime */
            if (!compile_operands(r, args, 1, &vo)) return op_imm(0);
        }
        emit_1op(r, 0x0E, vo, SP, BR_NONE, false);   /* load */
        return op_var(SP);
    }

    if (strcmp(nm, "COND") == 0) { compile_cond(r, args, n, true); return op_var(SP); }
    if (strcmp(nm, "AND") == 0) { compile_andor(r, args, n, true, true); return op_var(SP); }
    if (strcmp(nm, "OR") == 0) { compile_andor(r, args, n, false, true); return op_var(SP); }
    if (strcmp(nm, "PROG") == 0 || strcmp(nm, "BIND") == 0) {
        compile_block(r, args, n, false, true);
        return op_var(SP);
    }
    if (strcmp(nm, "REPEAT") == 0) {
        compile_block(r, args, n, true, true);
        return op_var(SP);
    }
    if (strcmp(nm, "NOT") == 0 || strcmp(nm, "1?") == 0 || find_pred(nm))
        return materialize_pred(r, v);

    if (strcmp(nm, "FIRST?") == 0 || strcmp(nm, "NEXT?") == 0) {
        opnd ops[1];
        if (n != 1 || !compile_operands(r, args, 1, ops)) { FAIL("%s: bad %s", r->rname, nm); return op_imm(0); }
        int l = new_label(r);
        emit_1op(r, strcmp(nm, "FIRST?") == 0 ? 0x02 : 0x01, ops[0], SP, l, true);
        place_label(r, l);
        return op_var(SP);
    }

    const storespec *s = find_store(nm);
    if (s) {
        emit_store_generic(r, s, args, n, SP);
        return op_var(SP);
    }

    if (strcmp(nm, "APPLY") == 0) {
        if (n < 1 || n > 4) { FAIL("%s: bad APPLY", r->rname); return op_imm(0); }
        opnd ops[4];
        if (!compile_operands(r, args, n, ops)) return op_imm(0);
        emit_varop(r, 0x00, false, ops, n, SP, BR_NONE, false);
        return op_var(SP);
    }

    if (strcmp(nm, "RETURN") == 0 || strcmp(nm, "AGAIN") == 0
        || strcmp(nm, "RTRUE") == 0 || strcmp(nm, "RFALSE") == 0
        || strcmp(nm, "RSTACK") == 0) {
        compile_stmt(r, v);
        return op_imm(0);   /* unreachable */
    }

    const voidspec *vd = find_void(nm);
    if (vd) {
        compile_stmt(r, v);
        return op_imm(1);   /* void ops evaluate to true */
    }
    if (strcmp(nm, "PRINTI") == 0 || strcmp(nm, "TELL") == 0) {
        compile_stmt(r, v);
        return op_imm(1);
    }

    int ri = find_routine(r->z, head);
    if (ri >= 0) return compile_call(r, head, args, n, SP);

    FAIL("%s: unknown form head %s", r->rname, nm);
    return op_imm(0);
}

static void compile_stmt(rt *r, cz_val *v) {
    if (zc_failed) return;
    if (v->type == CZ_ATOM || v->type == CZ_FIX || v->type == CZ_FALSE
        || v->type == CZ_STRING)
        return;   /* constants in statement position have no effect */
    if (v->type == CZ_CHTYPE) return;   /* #DECL etc. */
    if (v->type == CZ_LIST) {
        fprintf(stderr, "warning: %s: misplaced bracketed list ignored\n", r->rname);
        return;
    }
    if (v->type != CZ_FORM || v->seq.count == 0) return;

    cz_val *head = v->seq.items[0];
    cz_val **args = v->seq.items + 1;
    size_t n = v->seq.count - 1;
    if (head->type != CZ_ATOM) { FAIL("%s: non-atom form head", r->rname); return; }
    const char *nm = head->atom.name;

    cz_val *gv = cz_getg(r->z->c, head);
    if (gv && gv->type == CZ_MACRO) {
        cz_result e = cz_apply(r->z->c, gv->seg.inner, args, n, false);
        if (e.flow != CZ_F_NORMAL) { FAIL("macro %s failed: %s", nm, cz_error(r->z->c)); return; }
        compile_stmt(r, e.val);
        return;
    }

    if (strcmp(nm, "PRINTI") == 0) {
        if (n != 1 || args[0]->type != CZ_STRING) { FAIL("%s: bad PRINTI", r->rname); return; }
        emit_print_inline(r, args[0]->str.text, false);
        return;
    }
    if (strcmp(nm, "PRINTR") == 0) {
        if (n != 1 || args[0]->type != CZ_STRING) { FAIL("%s: bad PRINTR", r->rname); return; }
        emit_print_inline(r, args[0]->str.text, true);
        return;
    }
    if (strcmp(nm, "RTRUE") == 0) { emit_0op(r, 0x00, BR_NONE, false); return; }
    if (strcmp(nm, "RFALSE") == 0) { emit_0op(r, 0x01, BR_NONE, false); return; }
    if (strcmp(nm, "RSTACK") == 0) { emit_0op(r, 0x08, BR_NONE, false); return; }

    if (strcmp(nm, "RETURN") == 0) {
        /* v3 quirk mode: RETURN inside a PROG/REPEAT exits the block */
        if (r->nblocks > 0 && r->blocks[r->nblocks - 1].end >= 0) {
            int bi = r->nblocks - 1;
            if (r->blocks[bi].want_value) {
                if (n == 0) push_opnd(r, op_imm(1));
                else push_opnd(r, compile_value(r, args[0]));
            } else if (n == 1) {
                compile_stmt(r, args[0]);
            }
            emit_jump(r, r->blocks[bi].end);
            return;
        }
        if (n == 0) { emit_0op(r, 0x00, BR_NONE, false); return; }   /* rtrue */
        opnd val = compile_value(r, args[0]);
        if (val.type == OT_VAR && val.val == SP) { emit_0op(r, 0x08, BR_NONE, false); return; }
        if (val.type == OT_SMALL && val.fixkind == FX_NONE && val.val == 1) { emit_0op(r, 0x00, BR_NONE, false); return; }
        if (val.type == OT_SMALL && val.fixkind == FX_NONE && val.val == 0) { emit_0op(r, 0x01, BR_NONE, false); return; }
        emit_1op(r, 0x0B, val, NO_STORE, BR_NONE, false);   /* ret */
        return;
    }
    if (strcmp(nm, "AGAIN") == 0) {
        int lbl = r->nblocks > 0 ? r->blocks[r->nblocks - 1].again : -1;
        if (lbl < 0) { FAIL("%s: AGAIN outside a block", r->rname); return; }
        emit_jump(r, lbl);
        return;
    }

    if (strcmp(nm, "COND") == 0) { compile_cond(r, args, n, false); return; }
    if (strcmp(nm, "AND") == 0) { compile_andor(r, args, n, true, false); return; }
    if (strcmp(nm, "OR") == 0) { compile_andor(r, args, n, false, false); return; }
    if (strcmp(nm, "PROG") == 0 || strcmp(nm, "BIND") == 0) { compile_block(r, args, n, false, false); return; }
    if (strcmp(nm, "REPEAT") == 0) { compile_block(r, args, n, true, false); return; }

    if (strcmp(nm, "SET") == 0 || strcmp(nm, "SETG") == 0) {
        compile_value(r, v);
        return;
    }

    const voidspec *vd = find_void(nm);
    if (vd) {
        if (vd->cls == 2) {
            if (n != 0) { FAIL("%s: %s takes no args", r->rname, nm); return; }
            emit_0op(r, vd->op, BR_NONE, false);
            return;
        }
        opnd ops[4];
        if ((int)n != vd->nargs) { FAIL("%s: %s takes %d args", r->rname, nm, vd->nargs); return; }
        if (!compile_operands(r, args, n, ops)) return;
        if (strcmp(nm, "READ") == 0 && ZV >= 5) {
            /* v5 aread stores its terminator */
            emit_varop(r, 0x04, false, ops, n, r->z->g_dummy, BR_NONE, false);
            return;
        }
        if (vd->cls == 4) emit_varop(r, vd->op, false, ops, n, NO_STORE, BR_NONE, false);
        else if (vd->cls == 1) emit_1op(r, vd->op, ops[0], NO_STORE, BR_NONE, false);
        else emit_2op(r, vd->op, ops[0], ops[1], NO_STORE, BR_NONE, false);
        return;
    }

    const storespec *s = find_store(nm);
    if (s) {
        emit_store_generic(r, s, args, n, r->z->g_dummy);
        return;
    }
    const predspec *p = find_pred(nm);
    if (p || strcmp(nm, "NOT") == 0 || strcmp(nm, "1?") == 0
        || strcmp(nm, "FIRST?") == 0 || strcmp(nm, "NEXT?") == 0) {
        /* predicate in statement position: evaluate for side effects */
        int l = new_label(r);
        compile_pred(r, v, l, true);
        place_label(r, l);
        return;
    }
    if (strcmp(nm, "APPLY") == 0) {
        if (n < 1 || n > 4) { FAIL("%s: bad APPLY", r->rname); return; }
        opnd ops[4];
        if (!compile_operands(r, args, n, ops)) return;
        emit_varop(r, 0x00, false, ops, n, r->z->g_dummy, BR_NONE, false);
        return;
    }
    if (strcmp(nm, "GVAL") == 0 || strcmp(nm, "LVAL") == 0 || strcmp(nm, "QUOTE") == 0)
        return;   /* bare variable reference as a statement: no effect */

    int ri = find_routine(r->z, head);
    if (ri >= 0) {
        compile_call(r, head, args, n, r->z->g_dummy);
        return;
    }

    FAIL("%s: unknown statement head %s", r->rname, nm);
}

/* PROG/REPEAT/BIND */
static void compile_block(rt *r, cz_val **args, size_t n, bool repeat, bool want_value) {
    size_t i = 0;
    if (i < n && args[i]->type == CZ_ATOM) i++;   /* activation atom */
    if (i >= n || args[i]->type != CZ_LIST) { FAIL("%s: bad block bindings", r->rname); return; }
    cz_val *bindings = args[i++];

    /* bind: allocate or reuse locals, emit initializers */
    for (size_t bi = 0; bi < bindings->seq.count; bi++) {
        cz_val *item = bindings->seq.items[bi];
        if (item->type == CZ_ADECL) item = item->adecl.value;
        cz_val *atom = NULL, *init = NULL;
        if (item->type == CZ_ATOM) atom = item;
        else if (item->type == CZ_LIST && item->seq.count == 2) {
            atom = item->seq.items[0];
            if (atom->type == CZ_ADECL) atom = atom->adecl.value;
            init = item->seq.items[1];
        }
        if (!atom || atom->type != CZ_ATOM) { FAIL("%s: bad block binding", r->rname); return; }
        int slot = find_local(r, atom);
        if (slot < 0) {
            if (r->nlocals >= 15) { FAIL("%s: more than 15 locals", r->rname); return; }
            r->local_name[r->nlocals++] = atom;
            slot = r->nlocals;
        }
        opnd val = init ? compile_value(r, init) : op_imm(0);
        emit_2op(r, 0x0D, op_imm(slot), val, NO_STORE, BR_NONE, false);
    }

    if (r->nblocks >= 32) { FAIL("%s: block nesting too deep", r->rname); return; }
    int again = new_label(r), end = new_label(r);
    r->blocks[r->nblocks++] = (blockrec){ again, end, want_value };
    place_label(r, again);

    bool ended = false;
    for (size_t j = i; j < n; j++) {
        cz_val *stmt = args[j];
        bool last = j == n - 1;
        if (last && !repeat && want_value) {
            push_opnd(r, compile_value(r, stmt));
            ended = true;
        } else {
            compile_stmt(r, stmt);
        }
    }
    if (repeat) {
        emit_jump(r, again);
        /* REPEAT only exits via RETURN; if value wanted, RETURN pushed it */
    } else if (want_value && !ended) {
        push_opnd(r, op_imm(1));
    }
    place_label(r, end);
    r->nblocks--;
}

/* ---------- routine assembly ---------- */

static void patch_branches(rt *r) {
    for (int i = 0; i < r->nbrs; i++) {
        size_t off = r->brs[i].off;
        size_t dest = r->labels[r->brs[i].label];
        if (dest == SIZE_MAX) { FAIL("%s: unplaced label", r->rname); return; }
        int32_t delta = (int32_t)dest - (int32_t)off;
        if (r->brs[i].is_jump) {
            patch16(r->b, off, (uint16_t)(int16_t)delta);
        } else {
            if (delta < -8192 || delta > 8191) { FAIL("%s: branch out of range", r->rname); return; }
            uint16_t enc = (uint16_t)(((r->brs[i].pol ? 1 : 0) << 15) | (delta & 0x3FFF));
            patch16(r->b, off, enc);
        }
    }
}

/* pre-scan a routine body for PROG/REPEAT/BIND binding names so the
 * local count (and header size) is known before emission */
static void scan_block_locals(cz_val *v, cz_val **names, int *n) {
    if (v->type != CZ_FORM && v->type != CZ_LIST && v->type != CZ_VECTOR) return;
    bool is_block = v->type == CZ_FORM && v->seq.count > 0
        && (atom_is(v->seq.items[0], "PROG") || atom_is(v->seq.items[0], "REPEAT")
            || atom_is(v->seq.items[0], "BIND"));
    if (is_block) {
        size_t i = 1;
        if (i < v->seq.count && v->seq.items[i]->type == CZ_ATOM) i++;
        if (i < v->seq.count && v->seq.items[i]->type == CZ_LIST) {
            cz_val *bindings = v->seq.items[i];
            for (size_t bi = 0; bi < bindings->seq.count; bi++) {
                cz_val *item = bindings->seq.items[bi];
                if (item->type == CZ_ADECL) item = item->adecl.value;
                cz_val *atom = NULL;
                if (item->type == CZ_ATOM) atom = item;
                else if (item->type == CZ_LIST && item->seq.count >= 1) {
                    atom = item->seq.items[0];
                    if (atom->type == CZ_ADECL) atom = atom->adecl.value;
                }
                if (atom && atom->type == CZ_ATOM) {
                    bool seen = false;
                    for (int k = 0; k < *n; k++)
                        if (names[k] == atom) { seen = true; break; }
                    if (!seen && *n < 15) names[(*n)++] = atom;
                }
            }
        }
    }
    for (size_t i = 0; i < v->seq.count; i++)
        scan_block_locals(v->seq.items[i], names, n);
}

static void compile_routine(zc *z, size_t idx, bool is_entry) {
    zm_routine *rn = &z->g->routines[idx];
    rt r = { 0 };
    r.z = z;
    r.b = &z->sec[SEC_CODE];
    r.rname = rn->name->atom.name;

    /* alignment for packed addresses */
    while (r.b->n % (size_t)PACK) put8(r.b, 0);
    z->rtn_off[idx] = r.b->n;

    /* parse argspec */
    struct { cz_val *atom; cz_val *dflt; int mode; } spec[15];
    int nspec = 0, mode = 0;   /* 0 required, 1 opt, 2 aux */
    for (size_t i = 0; i < rn->spec->seq.count; i++) {
        cz_val *item = rn->spec->seq.items[i];
        if (item->type == CZ_STRING) {
            const char *s = item->str.text;
            if (strcmp(s, "OPT") == 0 || strcmp(s, "OPTIONAL") == 0) mode = 1;
            else if (strcmp(s, "AUX") == 0 || strcmp(s, "EXTRA") == 0) mode = 2;
            else { FAIL("%s: unsupported argspec string \"%s\"", r.rname, s); return; }
            continue;
        }
        if (item->type == CZ_ADECL) item = item->adecl.value;
        cz_val *atom = NULL, *dflt = NULL;
        if (item->type == CZ_ATOM) atom = item;
        else if (item->type == CZ_FORM && item->seq.count == 2
                 && atom_is(item->seq.items[0], "QUOTE"))
            atom = item->seq.items[1];
        else if (item->type == CZ_LIST && item->seq.count == 2) {
            atom = item->seq.items[0];
            if (atom->type == CZ_ADECL) atom = atom->adecl.value;
            dflt = item->seq.items[1];
        }
        if (!atom || atom->type != CZ_ATOM) { FAIL("%s: bad argspec item", r.rname); return; }
        if (nspec >= 15) { FAIL("%s: more than 15 arguments", r.rname); return; }
        spec[nspec].atom = atom;
        spec[nspec].dflt = dflt;
        spec[nspec].mode = mode;
        nspec++;
        r.local_name[r.nlocals++] = atom;
    }

    /* pre-scan block bindings into additional locals */
    {
        cz_val *extra[15];
        int nextra = 0;
        for (size_t i = 0; i < rn->body_count; i++)
            scan_block_locals(rn->body[i], extra, &nextra);
        for (int i = 0; i < nextra; i++) {
            if (find_local(&r, extra[i]) > 0) continue;
            if (r.nlocals >= 15) { FAIL("%s: more than 15 locals", r.rname); return; }
            r.local_name[r.nlocals++] = extra[i];
        }
    }

    /* header */
    put8(r.b, (uint8_t)r.nlocals);
    uint16_t initvals[15] = { 0 };
    bool init_deferred[15] = { false };
    for (int i = 0; i < nspec; i++) {
        if (!spec[i].dflt) continue;
        constref cr = resolve_constant(z, spec[i].dflt);
        if (cr.ok && cr.fixkind == FX_NONE) {
            initvals[i] = (uint16_t)cr.val;
        } else if (spec[i].mode == 2) {
            init_deferred[i] = true;
        } else {
            FAIL("%s: unsupported OPT default", r.rname);
            return;
        }
    }
    if (ZV < 5) {
        for (int i = 0; i < r.nlocals; i++) put16(r.b, i < nspec ? initvals[i] : 0);
    } else {
        /* v5+ headers carry no initial values: locals start at 0 and
         * defaults become explicit stores, with OPT defaults guarded by
         * check_arg_count so passed arguments are not clobbered */
        for (int i = 0; i < nspec; i++) {
            if (initvals[i] == 0) continue;
            int skip = -1;
            if (spec[i].mode != 2) {
                skip = new_label(&r);
                opnd argn[1] = { op_imm(i + 1) };
                emit_varop(&r, 0x1F, false, argn, 1, NO_STORE, skip, true);
            }
            emit_2op(&r, 0x0D, op_imm(i + 1), op_imm(initvals[i]), NO_STORE, BR_NONE, false);
            if (skip >= 0) place_label(&r, skip);
        }
    }

    /* deferred non-constant AUX defaults */
    for (int i = 0; i < nspec; i++) {
        if (!init_deferred[i]) continue;
        opnd val = compile_value(&r, spec[i].dflt);
        emit_2op(&r, 0x0D, op_imm(i + 1), val, NO_STORE, BR_NONE, false);
    }

    /* the routine itself is a block: AGAIN restarts it, RETURN returns
     * (marked by end = -1) */
    int routine_start = new_label(&r);
    place_label(&r, routine_start);
    r.blocks[r.nblocks++] = (blockrec){ routine_start, -1, false };

    for (size_t i = 0; i < rn->body_count; i++) {
        cz_val *stmt = rn->body[i];
        if (stmt->type == CZ_CHTYPE) continue;   /* #DECL */
        bool last = i == rn->body_count - 1;
        if (is_entry || !last) {
            compile_stmt(&r, stmt);
        } else {
            /* return the value of the last statement */
            opnd val = compile_value(&r, stmt);
            if (val.type == OT_VAR && val.val == SP)
                emit_0op(&r, 0x08, BR_NONE, false);        /* ret_popped */
            else if (val.type == OT_SMALL && val.fixkind == FX_NONE && val.val == 1)
                emit_0op(&r, 0x00, BR_NONE, false);        /* rtrue */
            else if (val.type == OT_SMALL && val.fixkind == FX_NONE && val.val == 0)
                emit_0op(&r, 0x01, BR_NONE, false);        /* rfalse */
            else
                emit_1op(&r, 0x0B, val, NO_STORE, BR_NONE, false);
        }
    }
    if (is_entry) emit_0op(&r, 0x0A, BR_NONE, false);      /* quit */
    else emit_0op(&r, 0x00, BR_NONE, false);               /* implicit rtrue */

    patch_branches(&r);
}

/* ================= final assembly ================= */

static uint8_t *zc_result_buf;
static size_t zc_result_len;

bool zc_compile(cz_ctx *c, zm_game *g, const zc_options *opt,
                const char *out_path, char *err, size_t errsz) {
    zc_errbuf = err;
    zc_errsz = errsz;
    zc_failed = false;
    if (g->zversion != 3 && g->zversion != 5 && g->zversion != 8) {
        snprintf(err, errsz, "supported output versions: 3, 5, 8");
        return false;
    }

    zc z0;
    memset(&z0, 0, sizeof z0);
    zc *z = &z0;
    z->c = c;
    z->g = g;
    ZV = g->zversion;

    find_implicit_directions(z);
    number_model(z);
    number_vocab(z);
    number_actions(z);
    if (zc_failed) return false;

    /* data sections; the dictionary must come first because vocab word
     * indices feed the syntax and object emitters */
    emit_dictionary(z);
    emit_game_tables(z);
    int vtbl_tab = -1, atbl_tab = -1, patbl_tab = -1, prtbl_tab = -1;
    emit_syntax_tables(z, &vtbl_tab, &atbl_tab, &patbl_tab, &prtbl_tab);
    emit_objects(z);
    emit_globals(z, vtbl_tab, atbl_tab, patbl_tab, prtbl_tab);
    if (zc_failed) return false;

    /* code */
    z->rtn_off = calloc(g->routine_count, sizeof(size_t));
    if (!z->rtn_off) abort();
    cz_val *go = cz_intern(c, "GO", 2);
    int go_idx = find_routine(z, go);
    if (go_idx < 0) { FAIL("no GO routine"); return false; }

    /* bootstrap: call GO -> ?DUMMY; quit */
    buf *cb = &z->sec[SEC_CODE];
    size_t boot_off = cb->n;
    {
        put8(cb, 0xE0);                    /* call */
        put8(cb, 0x3F);                    /* one large operand */
        add_fixup(z, SEC_CODE, cb->n, FX_ROUTINE, go_idx);
        put16(cb, 0);
        put8(cb, (uint8_t)z->g_dummy);     /* store */
        put8(cb, 0xBA);                    /* quit */
    }
    for (size_t i = 0; i < g->routine_count && !zc_failed; i++)
        compile_routine(z, i, (int)i == go_idx);
    if (zc_failed) return false;

    /* strings */
    buf *sb = &z->sec[SEC_STRINGS];
    for (size_t i = 0; i < z->nstrs; i++) {
        while (sb->n % (size_t)PACK) put8(sb, 0);
        z->str_off[i] = sb->n;
        strsink sink = { z, sb };
        zt_encode_string(z->strs[i], strlen(z->strs[i]), sink_word, &sink);
    }

    /* abbreviation table + its strings live right after the header */
    buf ab = { 0 };
    {
        size_t nab = zt_abbrev_count();
        for (int i = 0; i < 96; i++) put16(&ab, 0);
        zt_abbrev_suppress(true);
        for (size_t i = 0; i < nab; i++) {
            size_t alen;
            const char *atext = zt_abbrev_text(i, &alen);
            size_t off = ab.n;
            strsink sink = { z, &ab };
            zt_encode_string(atext, alen, sink_word, &sink);
            patch16(&ab, i * 2, (uint16_t)((0x40 + off) / 2));
        }
        zt_abbrev_suppress(false);
    }

    /* layout */
    size_t abbrev_size = ab.n;
    z->sec_base[SEC_OBJTAB] = 64 + abbrev_size;
    z->sec_base[SEC_GLOBALS] = z->sec_base[SEC_OBJTAB] + z->sec[SEC_OBJTAB].n;
    z->sec_base[SEC_IMPTAB] = z->sec_base[SEC_GLOBALS] + z->sec[SEC_GLOBALS].n;
    size_t static_base = z->sec_base[SEC_IMPTAB] + z->sec[SEC_IMPTAB].n;
    z->sec_base[SEC_PURETAB] = static_base;
    z->sec_base[SEC_DICT] = z->sec_base[SEC_PURETAB] + z->sec[SEC_PURETAB].n;
    size_t high_base = z->sec_base[SEC_DICT] + z->sec[SEC_DICT].n;
    while (high_base % (size_t)PACK) high_base++;
    z->sec_base[SEC_CODE] = high_base;
    z->sec_base[SEC_STRINGS] = high_base + z->sec[SEC_CODE].n;
    while (z->sec_base[SEC_STRINGS] % (size_t)PACK) z->sec_base[SEC_STRINGS]++;
    size_t file_end = z->sec_base[SEC_STRINGS] + z->sec[SEC_STRINGS].n;

    if (getenv("CZIL_MAP")) {
        fprintf(stderr, "[map] objtab=%zx globals=%zx imptab=%zx puretab=%zx dict=%zx code=%zx strings=%zx end=%zx\n",
                z->sec_base[SEC_OBJTAB], z->sec_base[SEC_GLOBALS], z->sec_base[SEC_IMPTAB],
                z->sec_base[SEC_PURETAB], z->sec_base[SEC_DICT], z->sec_base[SEC_CODE],
                z->sec_base[SEC_STRINGS], file_end);
        fprintf(stderr, "[map] nstrs=%zu strings_bytes=%zx last_off=%zx\n",
                z->nstrs, z->sec[SEC_STRINGS].n,
                z->nstrs ? z->str_off[z->nstrs - 1] : 0);
    }

    size_t file_limit = (size_t)PACK * 65536;
    if (static_base > 0xFFFF) { FAIL("static memory exceeds 64K (%zu)", static_base); return false; }
    if (file_end > file_limit) { FAIL("story exceeds %zuK (%zu)", file_limit / 1024, file_end); return false; }

    /* apply fixups */
    for (size_t i = 0; i < z->nfx && !zc_failed; i++) {
        fixup *f = &z->fx[i];
        buf *b = &z->sec[f->sec];
        uint16_t cur = (uint16_t)((b->b[f->off] << 8) | b->b[f->off + 1]);
        uint32_t v = 0;
        switch (f->kind) {
        case FX_ROUTINE:
            v = (uint32_t)((z->sec_base[SEC_CODE] + z->rtn_off[f->idx]) / (size_t)PACK);
            break;
        case FX_STRING:
            v = (uint32_t)((z->sec_base[SEC_STRINGS] + z->str_off[f->idx]) / (size_t)PACK);
            break;
        case FX_TABLE:
            v = (uint32_t)(z->sec_base[z->tab_sec[f->idx]] + z->tab_off[f->idx]);
            break;
        case FX_WORD: {
            /* dict entry address: dict base + header + index*entry */
            size_t hdr = 1 + 3 + 1 + 2;   /* nseps + seps + entlen + count */
            size_t ent = (size_t)DICTTEXT + 3;
            v = (uint32_t)(z->sec_base[SEC_DICT] + hdr + (size_t)f->idx * ent);
            break;
        }
        case FX_SECBASE:
            v = (uint32_t)(z->sec_base[f->idx] + cur);
            cur = 0;
            break;
        default:
            FAIL("bad fixup");
            continue;
        }
        v += cur;
        if (f->kind == FX_SECBASE) { /* cur already folded */ }
        if (v > 0xFFFF) { FAIL("fixup overflow"); break; }
        patch16(b, f->off, (uint16_t)v);
    }
    if (zc_failed) return false;

    /* assemble the file */
    buf out = { 0 };
    /* header */
    put8(&out, (uint8_t)ZV);                        /* version */
    put8(&out, 0);                                  /* flags1: score/turns status */
    put16(&out, (uint16_t)(opt && opt->release ? opt->release : 1));
    put16(&out, (uint16_t)high_base);               /* high memory base */
    add_fixup(z, 0, 0, 0, 0);                       /* (unused; keep nfx sane) */
    z->nfx--;
    /* initial PC: the bootstrap's first instruction */
    put16(&out, (uint16_t)(z->sec_base[SEC_CODE] + boot_off));
    put16(&out, (uint16_t)z->sec_base[SEC_DICT]);   /* dictionary */
    put16(&out, (uint16_t)z->sec_base[SEC_OBJTAB]); /* object table */
    put16(&out, (uint16_t)z->sec_base[SEC_GLOBALS]);/* globals */
    put16(&out, (uint16_t)static_base);             /* static memory base */
    put16(&out, 0);                                 /* flags2 */
    const char *serial = opt && opt->serial ? opt->serial : "000000";
    for (int i = 0; i < 6; i++) put8(&out, (uint8_t)(serial[i] ? serial[i] : '0'));
    put16(&out, 64);                                /* abbreviations table */
    put16(&out, 0);                                 /* file length (below) */
    put16(&out, 0);                                 /* checksum (below) */
    while (out.n < 64) put8(&out, 0);

    for (size_t i = 0; i < abbrev_size; i++) put8(&out, ab.b[i]);
    free(ab.b);
    for (int s = 0; s < NSEC; s++) {
        int order[] = { SEC_OBJTAB, SEC_GLOBALS, SEC_IMPTAB, SEC_PURETAB,
                        SEC_DICT, SEC_CODE, SEC_STRINGS };
        int sec = order[s];
        while (out.n < z->sec_base[sec]) put8(&out, 0);
        for (size_t k = 0; k < z->sec[sec].n; k++) put8(&out, z->sec[sec].b[k]);
    }
    while (out.n % 2) put8(&out, 0);

    while (out.n % (size_t)PACK) put8(&out, 0);
    patch16(&out, 0x1A, (uint16_t)(out.n / (size_t)(ZV >= 6 ? 8 : ZV >= 4 ? 4 : 2)));
    uint32_t sum = 0;
    for (size_t i = 0x40; i < out.n; i++) sum += out.b[i];
    patch16(&out, 0x1C, (uint16_t)sum);

    if (out_path) {
        FILE *f = fopen(out_path, "wb");
        if (!f) { FAIL("cannot write %s", out_path); return false; }
        fwrite(out.b, 1, out.n, f);
        fclose(f);
        free(out.b);
    } else {
        free(zc_result_buf);
        zc_result_buf = out.b;
        zc_result_len = out.n;
    }

    /* leak the working arrays; the process exits after compiling */
    return !zc_failed;
}

const unsigned char *zc_output_bytes(size_t *len) {
    *len = zc_result_len;
    return zc_result_buf;
}
