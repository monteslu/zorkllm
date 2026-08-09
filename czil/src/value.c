/* czil - C port of ZILF (Copyright 2010-2023 Tara McGrew).
 * GPL-3.0-or-later; see czil/LICENSE.
 * Value constructors, atom interning, and the printer.
 * Upstream: Zilf/Interpreter/Values/ and ZilAtom.Parse. */
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "czil_internal.h"

/* ---- context ---- */

uint32_t cz_hash_ptr(const void *p) {
    uint64_t x = (uint64_t)(uintptr_t)p;
    x ^= x >> 9;
    x *= 0x9e3779b97f4a7c15ull;
    return (uint32_t)(x >> 32) ^ (uint32_t)x;
}

cz_ctx *cz_ctx_new(void) {
    cz_ctx *c = calloc(1, sizeof(*c));
    if (!c) abort();
    c->arena = cz_arena_new();
    c->env = &c->root_frame;
    cz_eval_init(c);
    return c;
}

cz_arena *cz_ctx_arena(cz_ctx *c) {
    return c->arena;
}

void cz_ctx_free(cz_ctx *c) {
    free(c->out);
    cz_arena_free(c->arena);
    free(c);
}

static uint32_t hash_str(const char *s, size_t len) {
    uint32_t h = 2166136261u;
    for (size_t i = 0; i < len; i++) {
        h ^= (unsigned char)s[i];
        h *= 16777619u;
    }
    return h;
}

static cz_val *new_val(cz_ctx *c, cz_type t) {
    cz_val *v = cz_alloc(c->arena, sizeof(*v));
    memset(v, 0, sizeof(*v));
    v->type = t;
    return v;
}

cz_val *cz_intern(cz_ctx *c, const char *name, size_t len) {
    /* FOO!- names the root oblist explicitly; with czil's single oblist
     * that is the same atom as FOO */
    while (len >= 2 && name[len - 2] == '!' && name[len - 1] == '-')
        len -= 2;
    uint32_t h = hash_str(name, len) % INTERN_BUCKETS;
    for (intern_entry *e = c->buckets[h]; e; e = e->next) {
        const char *n = e->atom->atom.name;
        if (strlen(n) == len && memcmp(n, name, len) == 0) return e->atom;
    }
    cz_val *atom = new_val(c, CZ_ATOM);
    atom->atom.name = cz_strdup(c->arena, name, len);
    intern_entry *e = cz_alloc(c->arena, sizeof(*e));
    e->atom = atom;
    e->next = c->buckets[h];
    c->buckets[h] = e;
    return atom;
}

cz_val *cz_new_fix(cz_ctx *c, int32_t value) {
    cz_val *v = new_val(c, CZ_FIX);
    v->fix.value = value;
    return v;
}

cz_val *cz_new_string(cz_ctx *c, const char *text, size_t len) {
    cz_val *v = new_val(c, CZ_STRING);
    v->str.text = cz_strdup(c->arena, text, len);
    v->str.len = len;
    return v;
}

cz_val *cz_new_char(cz_ctx *c, int ch) {
    cz_val *v = new_val(c, CZ_CHAR);
    v->chr.ch = ch;
    return v;
}

cz_val *cz_new_seq(cz_ctx *c, cz_type t, cz_val **items, size_t count) {
    cz_val *v = new_val(c, t);
    v->seq.items = count ? cz_alloc(c->arena, count * sizeof(cz_val *)) : NULL;
    if (count) memcpy(v->seq.items, items, count * sizeof(cz_val *));
    v->seq.count = count;
    return v;
}

cz_val *cz_new_wrap(cz_ctx *c, cz_type t, cz_val *inner) {
    cz_val *v = new_val(c, t);
    v->seg.inner = inner;
    return v;
}

cz_val *cz_new_adecl(cz_ctx *c, cz_val *value, cz_val *decl) {
    cz_val *v = new_val(c, CZ_ADECL);
    v->adecl.value = value;
    v->adecl.decl = decl;
    return v;
}

cz_val *cz_new_chtype(cz_ctx *c, cz_val *type_atom, cz_val *value) {
    cz_val *v = new_val(c, CZ_CHTYPE);
    v->chtype.type_atom = type_atom;
    v->chtype.value = value;
    return v;
}

/* ---- printer ---- */

static void emit(char **buf, size_t *len, size_t *cap, const char *s, size_t n) {
    if (*len + n + 1 > *cap) {
        *cap = (*cap ? *cap * 2 : 256);
        while (*cap < *len + n + 1) *cap *= 2;
        *buf = realloc(*buf, *cap);
        if (!*buf) abort();
    }
    memcpy(*buf + *len, s, n);
    *len += n;
    (*buf)[*len] = '\0';
}

static void emit_str(char **buf, size_t *len, size_t *cap, const char *s) {
    emit(buf, len, cap, s, strlen(s));
}

static void print_seq(const cz_val *v, const char *open, const char *close,
                      char **buf, size_t *len, size_t *cap) {
    emit_str(buf, len, cap, open);
    for (size_t i = 0; i < v->seq.count; i++) {
        if (i) emit_str(buf, len, cap, " ");
        cz_print(v->seq.items[i], buf, len, cap);
    }
    emit_str(buf, len, cap, close);
}

void cz_print(const cz_val *v, char **buf, size_t *len, size_t *cap) {
    char tmp[32];
    switch (v->type) {
    case CZ_ATOM: emit_str(buf, len, cap, v->atom.name); break;
    case CZ_FIX:
        snprintf(tmp, sizeof tmp, "%d", v->fix.value);
        emit_str(buf, len, cap, tmp);
        break;
    case CZ_STRING:
        emit_str(buf, len, cap, "\"");
        for (size_t i = 0; i < v->str.len; i++) {
            char ch = v->str.text[i];
            if (ch == '"' || ch == '\\') emit(buf, len, cap, "\\", 1);
            emit(buf, len, cap, &ch, 1);
        }
        emit_str(buf, len, cap, "\"");
        break;
    case CZ_CHAR: {
        emit_str(buf, len, cap, "!\\");
        char ch = (char)v->chr.ch;
        emit(buf, len, cap, &ch, 1);
        break;
    }
    case CZ_LIST: print_seq(v, "(", ")", buf, len, cap); break;
    case CZ_FORM:
        /* upstream ZilForm.ToString sugars <LVAL X> as .X, <GVAL X> as ,X,
         * <QUOTE X> as 'X */
        if (v->seq.count == 2 && v->seq.items[0]->type == CZ_ATOM) {
            const char *h = v->seq.items[0]->atom.name;
            const char *sugar = strcmp(h, "LVAL") == 0 ? "."
                              : strcmp(h, "GVAL") == 0 ? ","
                              : strcmp(h, "QUOTE") == 0 ? "'" : NULL;
            if (sugar) {
                emit_str(buf, len, cap, sugar);
                cz_print(v->seq.items[1], buf, len, cap);
                break;
            }
        }
        print_seq(v, "<", ">", buf, len, cap);
        break;
    case CZ_VECTOR: print_seq(v, "[", "]", buf, len, cap); break;
    case CZ_SEGMENT:
        emit_str(buf, len, cap, "!");
        cz_print(v->seg.inner, buf, len, cap);
        break;
    case CZ_ADECL:
        cz_print(v->adecl.value, buf, len, cap);
        emit_str(buf, len, cap, ":");
        cz_print(v->adecl.decl, buf, len, cap);
        break;
    case CZ_READEVAL:
        emit_str(buf, len, cap, "%");
        cz_print(v->seg.inner, buf, len, cap);
        break;
    case CZ_READEVAL2:
        emit_str(buf, len, cap, "%%");
        cz_print(v->seg.inner, buf, len, cap);
        break;
    case CZ_CHTYPE:
        emit_str(buf, len, cap, "#");
        cz_print(v->chtype.type_atom, buf, len, cap);
        emit_str(buf, len, cap, " ");
        cz_print(v->chtype.value, buf, len, cap);
        break;
    case CZ_FALSE:
        emit_str(buf, len, cap, "#FALSE ");
        print_seq(v, "(", ")", buf, len, cap);
        break;
    case CZ_FUNCTION: {
        emit_str(buf, len, cap, "#FUNCTION (");
        cz_print(v->func.spec, buf, len, cap);
        for (size_t i = 0; i < v->func.body_count; i++) {
            emit_str(buf, len, cap, " ");
            cz_print(v->func.body[i], buf, len, cap);
        }
        emit_str(buf, len, cap, ")");
        break;
    }
    case CZ_MACRO:
        emit_str(buf, len, cap, "#MACRO ");
        cz_print(v->seg.inner, buf, len, cap);
        break;
    case CZ_SUBR:
        emit_str(buf, len, cap, "#SUBR \"");
        emit_str(buf, len, cap, v->subr.name);
        emit_str(buf, len, cap, "\"");
        break;
    case CZ_FSUBR:
        emit_str(buf, len, cap, "#FSUBR \"");
        emit_str(buf, len, cap, v->subr.name);
        emit_str(buf, len, cap, "\"");
        break;
    case CZ_SPLICE:
        print_seq(v, "#SPLICE (", ")", buf, len, cap);
        break;
    case CZ_TABLE:
        print_seq(v, "#TABLE [", "]", buf, len, cap);
        break;
    }
}
