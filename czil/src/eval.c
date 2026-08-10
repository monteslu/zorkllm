/* czil - C port of ZILF (Copyright 2010-2023 Tara McGrew).
 * GPL-3.0-or-later; see czil/LICENSE.
 *
 * Stage 3: the MDL evaluator core.
 * Upstream: Zilf/Interpreter/{Context,LocalEnvironment}.cs, Subrs.*.cs,
 * Values/{ZilForm,ZilList,ZilFunction,ZilEvalMacro}.cs.
 *
 * Semantics ported:
 *  - atoms/fixes/strings/chars self-evaluate; only type FALSE is falsy
 *  - LIST/VECTOR eval their elements, splicing SEGMENTs (EvalSequence)
 *  - FORM: empty -> FALSE; atom head resolves GVAL then LVAL and must be
 *    applicable; SUBRs get evaluated args, FSUBRs raw args, FUNCTIONs
 *    evaluate per their argspec, MACROs expand then eval, FIX heads do NTH
 *  - dynamic scoping: PROG/REPEAT/FUNCTION push binding frames
 *  - RETURN/AGAIN/MAPRET/MAPSTOP travel as cz_flow, not exceptions
 */
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "czil_internal.h"

#define ERR(c, ...) err_result(c, __VA_ARGS__)

static cz_result err_result(cz_ctx *c, const char *fmt, ...) {
    __builtin_va_list ap;
    __builtin_va_start(ap, fmt);
    vsnprintf(c->err, sizeof c->err, fmt, ap);
    __builtin_va_end(ap);
    return (cz_result){ CZ_F_ERROR, NULL };
}

static cz_result ok(cz_val *v) { return (cz_result){ CZ_F_NORMAL, v }; }

const char *cz_error(cz_ctx *c) { return c->err; }
cz_val *cz_false(cz_ctx *c) { return c->false_obj; }
bool cz_is_true(const cz_val *v) { return v->type != CZ_FALSE; }

/* ---- output buffer (PRINC and friends) ---- */

static void out_emit(cz_ctx *c, const char *s, size_t n);
void cz_princ(cz_ctx *c, const char *text) { out_emit(c, text, strlen(text)); }

static void out_emit(cz_ctx *c, const char *s, size_t n) {
    if (c->out_len + n + 1 > c->out_cap) {
        c->out_cap = c->out_cap ? c->out_cap * 2 : 256;
        while (c->out_cap < c->out_len + n + 1) c->out_cap *= 2;
        c->out = realloc(c->out, c->out_cap);
        if (!c->out) abort();
    }
    memcpy(c->out + c->out_len, s, n);
    c->out_len += n;
    c->out[c->out_len] = '\0';
}

const char *cz_output(cz_ctx *c) { return c->out ? c->out : ""; }
void cz_clear_output(cz_ctx *c) { c->out_len = 0; if (c->out) c->out[0] = '\0'; }

/* ---- global and local bindings ---- */

static binding *find_binding(binding *list, cz_val *atom) {
    for (; list; list = list->next)
        if (list->atom == atom) return list;
    return NULL;
}

static cz_val *get_global(cz_ctx *c, cz_val *atom) {
    binding *b = find_binding(c->globals[cz_hash_ptr(atom) % GLOBAL_BUCKETS], atom);
    return b ? b->value : NULL;
}

static void set_global(cz_ctx *c, cz_val *atom, cz_val *value) {
    uint32_t h = cz_hash_ptr(atom) % GLOBAL_BUCKETS;
    binding *b = find_binding(c->globals[h], atom);
    if (!b) {
        b = cz_alloc(c->arena, sizeof(*b));
        b->atom = atom;
        b->next = c->globals[h];
        c->globals[h] = b;
    }
    b->value = value;
}

static cz_val *get_local(cz_ctx *c, cz_val *atom) {
    for (frame *f = c->env; f; f = f->parent) {
        binding *b = find_binding(f->bindings, atom);
        if (b) return b->value;
    }
    return NULL;
}

/* SET: rebind existing binding anywhere in the chain, else bind at root
 * (top-level SETs behave like globals-for-locals, matching upstream). */
static void set_local(cz_ctx *c, cz_val *atom, cz_val *value) {
    for (frame *f = c->env; f; f = f->parent) {
        binding *b = find_binding(f->bindings, atom);
        if (b) { b->value = value; return; }
    }
    frame *root = c->env;
    while (root->parent) root = root->parent;
    binding *b = cz_alloc(c->arena, sizeof(*b));
    b->atom = atom;
    b->value = value;
    b->next = root->bindings;
    root->bindings = b;
}

/* bind in the CURRENT frame (function args, PROG bindings) */
static void bind_here(cz_ctx *c, cz_val *atom, cz_val *value) {
    binding *b = cz_alloc(c->arena, sizeof(*b));
    b->atom = atom;
    b->value = value;
    b->next = c->env->bindings;
    c->env->bindings = b;
}

static void unassign_local(cz_ctx *c, cz_val *atom) {
    for (frame *f = c->env; f; f = f->parent) {
        binding *b = find_binding(f->bindings, atom);
        if (b) { b->value = NULL; return; }
    }
}

/* ---- small helpers ---- */

static cz_val *new_list_of(cz_ctx *c, cz_type t, cz_val **items, size_t n) {
    return cz_new_seq(c, t, items, n);
}

static cz_val *empty_seq(cz_ctx *c, cz_type t) {
    return cz_new_seq(c, t, NULL, 0);
}

static bool is_seq(const cz_val *v) {
    return v->type == CZ_LIST || v->type == CZ_FORM || v->type == CZ_VECTOR
        || v->type == CZ_FALSE || v->type == CZ_SPLICE || v->type == CZ_TABLE;
}

static bool is_applicable(const cz_val *v) {
    return v->type == CZ_SUBR || v->type == CZ_FSUBR || v->type == CZ_FUNCTION
        || v->type == CZ_MACRO || v->type == CZ_FIX;
}

/* growable value array */
typedef struct { cz_val **items; size_t n, cap; } varr;
static void varr_push(varr *a, cz_val *v) {
    if (a->n >= a->cap) {
        a->cap = a->cap ? a->cap * 2 : 8;
        a->items = realloc(a->items, a->cap * sizeof(cz_val *));
        if (!a->items) abort();
    }
    a->items[a->n++] = v;
}

/* ---- eval ---- */

static cz_result eval_seq_elements(cz_ctx *c, cz_val **items, size_t n, varr *out);

cz_result cz_eval(cz_ctx *c, cz_val *v) {
    switch (v->type) {
    case CZ_ATOM: case CZ_FIX: case CZ_STRING: case CZ_CHAR:
    case CZ_FALSE: case CZ_FUNCTION: case CZ_MACRO:
    case CZ_SUBR: case CZ_FSUBR: case CZ_SPLICE: case CZ_TABLE:
        return ok(v);

    case CZ_LIST: case CZ_VECTOR: {
        varr out = { 0 };
        cz_result r = eval_seq_elements(c, v->seq.items, v->seq.count, &out);
        if (r.flow != CZ_F_NORMAL) { free(out.items); return r; }
        cz_val *result = new_list_of(c, v->type, out.items, out.n);
        free(out.items);
        return ok(result);
    }

    case CZ_FORM: {
        if (v->seq.count == 0) return ok(c->false_obj);
        cz_val *head = v->seq.items[0];
        cz_val *target;
        if (head->type == CZ_ATOM) {
            target = get_global(c, head);
            if (!target) target = get_local(c, head);
            if (!target)
                return ERR(c, "calling unassigned atom: %s", head->atom.name);
        } else {
            cz_result r = cz_eval(c, head);
            if (r.flow != CZ_F_NORMAL) return r;
            target = r.val;
        }
        if (!is_applicable(target))
            return ERR(c, "not an applicable type");
        return cz_apply(c, target, v->seq.items + 1, v->seq.count - 1, true);
    }

    case CZ_SEGMENT:
        return ERR(c, "segment evaluated outside structure");

    case CZ_ADECL:
        return cz_eval(c, v->adecl.value);   /* decl checking deferred */

    case CZ_READEVAL:
        return cz_eval(c, v->seg.inner);

    case CZ_READEVAL2: {
        cz_result r = cz_eval(c, v->seg.inner);
        if (r.flow != CZ_F_NORMAL) return r;
        return ok(empty_seq(c, CZ_SPLICE));
    }

    case CZ_CHTYPE: {
        /* #TYPE literal: the value is taken literally, converted */
        const char *tn = v->chtype.type_atom->atom.name;
        cz_val *inner = v->chtype.value;
        if (strcmp(tn, "FALSE") == 0 && inner->type == CZ_LIST)
            return ok(cz_new_seq(c, CZ_FALSE, inner->seq.items, inner->seq.count));
        if (strcmp(tn, "SPLICE") == 0 && inner->type == CZ_LIST)
            return ok(cz_new_seq(c, CZ_SPLICE, inner->seq.items, inner->seq.count));
        if (strcmp(tn, "FUNCTION") == 0 && inner->type == CZ_LIST && inner->seq.count >= 2) {
            cz_val *f = cz_alloc(c->arena, sizeof(*f));
            memset(f, 0, sizeof(*f));
            f->type = CZ_FUNCTION;
            f->func.spec = inner->seq.items[0];
            f->func.body = inner->seq.items + 1;
            f->func.body_count = inner->seq.count - 1;
            f->func.name = "anonymous";
            return ok(f);
        }
        if (strcmp(tn, "DECL") == 0)
            return ok(v);   /* decls pass through untouched until the checker lands */
        if (strcmp(tn, "BYTE") == 0 && inner->type == CZ_FIX)
            return ok(v);   /* #BYTE n stays wrapped; tables honor it at emit */
        return ERR(c, "CHTYPE to %s not supported yet", tn);
    }
    }
    return ERR(c, "unhandled type in eval");
}

/* evaluate a run of elements with segment splicing (upstream EvalSequence) */
static cz_result eval_seq_elements(cz_ctx *c, cz_val **items, size_t n, varr *out) {
    for (size_t i = 0; i < n; i++) {
        cz_val *item = items[i];
        if (item->type == CZ_SEGMENT) {
            cz_result r = cz_eval(c, item->seg.inner);
            if (r.flow != CZ_F_NORMAL) return r;
            if (r.val->type == CZ_STRING) {
                for (size_t j = 0; j < r.val->str.len; j++)
                    varr_push(out, cz_new_char(c, (unsigned char)r.val->str.text[j]));
                continue;
            }
            if (!is_seq(r.val))
                return ERR(c, "segment value is not a structure");
            for (size_t j = 0; j < r.val->seq.count; j++)
                varr_push(out, r.val->seq.items[j]);
        } else {
            cz_result r = cz_eval(c, item);
            if (r.flow != CZ_F_NORMAL) return r;
            if (r.val->type == CZ_SPLICE) {
                for (size_t j = 0; j < r.val->seq.count; j++)
                    varr_push(out, r.val->seq.items[j]);
            } else {
                varr_push(out, r.val);
            }
        }
    }
    return ok(NULL);
}

/* ---- function application ---- */

typedef enum { AS_REQUIRED, AS_OPTIONAL, AS_AUX, AS_ARGS, AS_TUPLE } as_mode;

static cz_result apply_function(cz_ctx *c, cz_val *fn, cz_val **args, size_t n, bool eval_args) {
    frame fr = { .parent = c->env, .bindings = NULL };
    c->env = &fr;
    cz_result result = ok(c->false_obj);

    cz_val *spec = fn->func.spec;
    as_mode mode = AS_REQUIRED;
    size_t argi = 0;
    bool failed = false;

    for (size_t i = 0; i < spec->seq.count && !failed; i++) {
        cz_val *item = spec->seq.items[i];

        if (item->type == CZ_STRING) {
            const char *s = item->str.text;
            if (strcmp(s, "OPT") == 0 || strcmp(s, "OPTIONAL") == 0) mode = AS_OPTIONAL;
            else if (strcmp(s, "AUX") == 0 || strcmp(s, "EXTRA") == 0) mode = AS_AUX;
            else if (strcmp(s, "ARGS") == 0) mode = AS_ARGS;
            else if (strcmp(s, "TUPLE") == 0) mode = AS_TUPLE;
            else if (strcmp(s, "NAME") == 0 || strcmp(s, "ACT") == 0 || strcmp(s, "BIND") == 0) {
                /* activations: bind the next atom to FALSE for now */
                if (i + 1 < spec->seq.count && spec->seq.items[i + 1]->type == CZ_ATOM) {
                    bind_here(c, spec->seq.items[i + 1], c->false_obj);
                    i++;
                }
            } else {
                result = ERR(c, "unrecognized argspec string \"%s\"", s);
                failed = true;
            }
            continue;
        }

        if (mode == AS_ARGS || mode == AS_TUPLE) {
            if (item->type != CZ_ATOM) {
                result = ERR(c, "expected atom after \"ARGS\"/\"TUPLE\"");
                failed = true;
                break;
            }
            if (mode == AS_ARGS) {
                bind_here(c, item, new_list_of(c, CZ_LIST, args + argi, n - argi));
            } else {
                varr out = { 0 };
                cz_result r = eval_seq_elements(c, args + argi, n - argi, &out);
                if (r.flow != CZ_F_NORMAL) { free(out.items); result = r; failed = true; break; }
                bind_here(c, item, new_list_of(c, CZ_LIST, out.items, out.n));
                free(out.items);
            }
            argi = n;
            continue;
        }

        /* unwrap adecls in specs (X:FIX) - decl checking deferred */
        cz_val *nameish = item->type == CZ_ADECL ? item->adecl.value : item;
        bool quoted = false;
        cz_val *defaultv = NULL;
        cz_val *atom = NULL;

        if (nameish->type == CZ_FORM && nameish->seq.count == 2
            && nameish->seq.items[0]->type == CZ_ATOM
            && strcmp(nameish->seq.items[0]->atom.name, "QUOTE") == 0) {
            quoted = true;
            atom = nameish->seq.items[1];
        } else if (nameish->type == CZ_ATOM) {
            atom = nameish;
        } else if (nameish->type == CZ_LIST && nameish->seq.count >= 1) {
            /* (name default) in OPT/AUX */
            cz_val *inner = nameish->seq.items[0];
            if (inner->type == CZ_ADECL) inner = inner->adecl.value;
            if (inner->type == CZ_FORM && inner->seq.count == 2
                && inner->seq.items[0]->type == CZ_ATOM
                && strcmp(inner->seq.items[0]->atom.name, "QUOTE") == 0) {
                quoted = true;
                atom = inner->seq.items[1];
            } else {
                atom = inner;
            }
            if (nameish->seq.count >= 2) defaultv = nameish->seq.items[1];
        }
        if (!atom || atom->type != CZ_ATOM) {
            result = ERR(c, "bad argspec item");
            failed = true;
            break;
        }

        if (mode == AS_AUX) {
            /* no default -> bound but unassigned (ASSIGNED? is false) */
            cz_val *value = NULL;
            if (defaultv) {
                cz_result r = cz_eval(c, defaultv);
                if (r.flow != CZ_F_NORMAL) { result = r; failed = true; break; }
                value = r.val;
            }
            bind_here(c, atom, value);
            continue;
        }

        if (argi < n) {
            cz_val *raw = args[argi++];
            cz_val *value = raw;
            if (eval_args && !quoted) {
                cz_result r = cz_eval(c, raw);
                if (r.flow != CZ_F_NORMAL) { result = r; failed = true; break; }
                value = r.val;
            }
            bind_here(c, atom, value);
        } else if (mode == AS_OPTIONAL) {
            /* no default -> bound but unassigned (ASSIGNED? is false) */
            cz_val *value = NULL;
            if (defaultv) {
                cz_result r = cz_eval(c, defaultv);
                if (r.flow != CZ_F_NORMAL) { result = r; failed = true; break; }
                value = r.val;
            }
            bind_here(c, atom, value);
        } else {
            result = ERR(c, "too few arguments to %s", fn->func.name);
            failed = true;
            break;
        }
    }

    if (!failed && argi < n) {
        result = ERR(c, "too many arguments to %s", fn->func.name);
        failed = true;
    }

    if (!failed) {
        for (size_t i = 0; i < fn->func.body_count; i++) {
            /* leading #DECL is documentation to us, skip it */
            if (fn->func.body[i]->type == CZ_CHTYPE
                && strcmp(fn->func.body[i]->chtype.type_atom->atom.name, "DECL") == 0)
                continue;
            result = cz_eval(c, fn->func.body[i]);
            if (result.flow != CZ_F_NORMAL) break;
        }
    }

    c->env = fr.parent;
    return result;
}

cz_result cz_apply(cz_ctx *c, cz_val *target, cz_val **args, size_t n, bool eval_args) {
    switch (target->type) {
    case CZ_SUBR: {
        varr out = { 0 };
        if (eval_args) {
            cz_result r = eval_seq_elements(c, args, n, &out);
            if (r.flow != CZ_F_NORMAL) { free(out.items); return r; }
        } else {
            for (size_t i = 0; i < n; i++) varr_push(&out, args[i]);
        }
        cz_result r = ((cz_subr_fn)target->subr.fn)(c, out.items, out.n);
        free(out.items);
        return r;
    }
    case CZ_FSUBR:
        return ((cz_subr_fn)target->subr.fn)(c, args, n);
    case CZ_FUNCTION:
        return apply_function(c, target, args, n, eval_args);
    case CZ_MACRO: {
        /* expand with raw args, then evaluate the expansion (upstream ZilEvalMacro) */
        cz_result r = cz_apply(c, target->seg.inner, args, n, false);
        if (r.flow != CZ_F_NORMAL) return r;
        return cz_eval(c, r.val);
    }
    case CZ_FIX: {
        /* <2 structure> is NTH */
        varr out = { 0 };
        if (eval_args) {
            cz_result er = eval_seq_elements(c, args, n, &out);
            if (er.flow != CZ_F_NORMAL) { free(out.items); return er; }
        } else {
            for (size_t i = 0; i < n; i++) varr_push(&out, args[i]);
        }
        cz_result r;
        if (out.n != 1 || !is_seq(out.items[0])) {
            r = ERR(c, "FIX application needs one structure argument");
        } else {
            int32_t idx = target->fix.value;
            cz_val *s = out.items[0];
            if (idx < 1 || (size_t)idx > s->seq.count)
                r = ERR(c, "index %d out of range", idx);
            else
                r = ok(s->seq.items[idx - 1]);
        }
        free(out.items);
        return r;
    }
    default:
        return ERR(c, "not an applicable type");
    }
}

/* ================= SUBRs ================= */

#define REQUIRE_COUNT(name, cond) \
    do { if (!(cond)) return ERR(c, "wrong number of args to %s", name); } while (0)
#define REQUIRE(name, cond, what) \
    do { if (!(cond)) return ERR(c, "%s: expected %s", name, what); } while (0)

/* ---- arithmetic (upstream: Subrs.Math.cs / ArithmeticTests) ---- */

static cz_result do_arith(cz_ctx *c, cz_val **args, size_t n, char op) {
    for (size_t i = 0; i < n; i++)
        if (args[i]->type != CZ_FIX) return ERR(c, "non-FIX in arithmetic");
    int64_t acc;
    switch (op) {
    case '+':
        acc = 0;
        for (size_t i = 0; i < n; i++) acc += args[i]->fix.value;
        break;
    case '-':
        if (n == 0) acc = 0;
        else if (n == 1) acc = -(int64_t)args[0]->fix.value;
        else {
            acc = args[0]->fix.value;
            for (size_t i = 1; i < n; i++) acc -= args[i]->fix.value;
        }
        break;
    case '*':
        acc = 1;
        for (size_t i = 0; i < n; i++) acc *= args[i]->fix.value;
        break;
    case '/':
        if (n == 0) acc = 1;
        else if (n == 1) {
            if (args[0]->fix.value == 0) return ERR(c, "division by zero");
            acc = 1 / args[0]->fix.value;
        } else {
            acc = args[0]->fix.value;
            for (size_t i = 1; i < n; i++) {
                if (args[i]->fix.value == 0) return ERR(c, "division by zero");
                acc /= args[i]->fix.value;
            }
        }
        break;
    default: return ERR(c, "bad op");
    }
    return ok(cz_new_fix(c, (int32_t)acc));
}

static cz_result s_add(cz_ctx *c, cz_val **a, size_t n) { return do_arith(c, a, n, '+'); }
static cz_result s_sub(cz_ctx *c, cz_val **a, size_t n) { return do_arith(c, a, n, '-'); }
static cz_result s_mul(cz_ctx *c, cz_val **a, size_t n) { return do_arith(c, a, n, '*'); }
static cz_result s_div(cz_ctx *c, cz_val **a, size_t n) { return do_arith(c, a, n, '/'); }

static cz_result s_mod(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("MOD", n == 2);
    REQUIRE("MOD", a[0]->type == CZ_FIX && a[1]->type == CZ_FIX, "FIXes");
    if (a[1]->fix.value == 0) return ERR(c, "division by zero");
    return ok(cz_new_fix(c, a[0]->fix.value % a[1]->fix.value));
}

static cz_result s_lsh(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("LSH", n == 2);
    REQUIRE("LSH", a[0]->type == CZ_FIX && a[1]->type == CZ_FIX, "FIXes");
    int32_t sh = a[1]->fix.value;
    uint32_t v = (uint32_t)a[0]->fix.value;
    if (sh >= 32 || sh <= -32) return ok(cz_new_fix(c, 0));
    return ok(cz_new_fix(c, sh >= 0 ? (int32_t)(v << sh) : (int32_t)(v >> -sh)));
}

static cz_result s_min(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("MIN", n >= 1);
    int32_t best = 0;
    for (size_t i = 0; i < n; i++) {
        REQUIRE("MIN", a[i]->type == CZ_FIX, "FIXes");
        if (i == 0 || a[i]->fix.value < best) best = a[i]->fix.value;
    }
    return ok(cz_new_fix(c, best));
}

static cz_result s_max(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("MAX", n >= 1);
    int32_t best = 0;
    for (size_t i = 0; i < n; i++) {
        REQUIRE("MAX", a[i]->type == CZ_FIX, "FIXes");
        if (i == 0 || a[i]->fix.value > best) best = a[i]->fix.value;
    }
    return ok(cz_new_fix(c, best));
}

static cz_result s_abs(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("ABS", n == 1);
    REQUIRE("ABS", a[0]->type == CZ_FIX, "FIX");
    int32_t v = a[0]->fix.value;
    return ok(cz_new_fix(c, v < 0 ? -v : v));
}

/* ---- predicates ---- */

static bool struct_equal(const cz_val *x, const cz_val *y) {
    if (x == y) return true;
    if (x->type != y->type) return false;
    switch (x->type) {
    case CZ_FIX: return x->fix.value == y->fix.value;
    case CZ_STRING: return x->str.len == y->str.len && memcmp(x->str.text, y->str.text, x->str.len) == 0;
    case CZ_CHAR: return x->chr.ch == y->chr.ch;
    case CZ_ATOM: return false; /* pointer-equal already checked */
    case CZ_LIST: case CZ_FORM: case CZ_VECTOR: case CZ_FALSE: case CZ_SPLICE:
        if (x->seq.count != y->seq.count) return false;
        for (size_t i = 0; i < x->seq.count; i++)
            if (!struct_equal(x->seq.items[i], y->seq.items[i])) return false;
        return true;
    case CZ_SEGMENT: return struct_equal(x->seg.inner, y->seg.inner);
    case CZ_ADECL:
        return struct_equal(x->adecl.value, y->adecl.value) && struct_equal(x->adecl.decl, y->adecl.decl);
    default: return false;
    }
}

static bool exact_equal(const cz_val *x, const cz_val *y) {
    if (x == y) return true;
    if (x->type != y->type) return false;
    switch (x->type) {
    case CZ_FIX: return x->fix.value == y->fix.value;
    case CZ_CHAR: return x->chr.ch == y->chr.ch;
    default: return false;  /* strings/structures compare by identity for ==? */
    }
}

static cz_val *boolify(cz_ctx *c, bool b) {
    return b ? cz_intern(c, "T", 1) : c->false_obj;
}

static cz_result s_eeq(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("==?", n == 2);
    return ok(boolify(c, exact_equal(a[0], a[1])));
}
static cz_result s_neeq(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("N==?", n == 2);
    return ok(boolify(c, !exact_equal(a[0], a[1])));
}
static cz_result s_seq_eq(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("=?", n == 2);
    return ok(boolify(c, struct_equal(a[0], a[1])));
}
static cz_result s_seq_neq(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("N=?", n == 2);
    return ok(boolify(c, !struct_equal(a[0], a[1])));
}

static cz_result cmp2(cz_ctx *c, cz_val **a, size_t n, const char *name, int want, bool eq_ok) {
    REQUIRE_COUNT(name, n == 2);
    REQUIRE(name, a[0]->type == CZ_FIX && a[1]->type == CZ_FIX, "FIXes");
    int32_t x = a[0]->fix.value, y = a[1]->fix.value;
    int cmpv = x < y ? -1 : x > y ? 1 : 0;
    return ok(boolify(c, cmpv == want || (eq_ok && cmpv == 0)));
}
static cz_result s_g(cz_ctx *c, cz_val **a, size_t n) { return cmp2(c, a, n, "G?", 1, false); }
static cz_result s_l(cz_ctx *c, cz_val **a, size_t n) { return cmp2(c, a, n, "L?", -1, false); }
static cz_result s_geq(cz_ctx *c, cz_val **a, size_t n) { return cmp2(c, a, n, "G=?", 1, true); }
static cz_result s_leq(cz_ctx *c, cz_val **a, size_t n) { return cmp2(c, a, n, "L=?", -1, true); }

static cz_result s_zerop(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("0?", n == 1);
    return ok(boolify(c, a[0]->type == CZ_FIX && a[0]->fix.value == 0));
}
static cz_result s_onep(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("1?", n == 1);
    return ok(boolify(c, a[0]->type == CZ_FIX && a[0]->fix.value == 1));
}
static cz_result s_not(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("NOT", n == 1);
    return ok(boolify(c, !cz_is_true(a[0])));
}

static cz_result s_type(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("TYPE", n == 1);
    const char *name;
    switch (a[0]->type) {
    case CZ_ATOM: name = "ATOM"; break;
    case CZ_FIX: name = "FIX"; break;
    case CZ_STRING: name = "STRING"; break;
    case CZ_CHAR: name = "CHARACTER"; break;
    case CZ_LIST: name = "LIST"; break;
    case CZ_FORM: name = "FORM"; break;
    case CZ_VECTOR: name = "VECTOR"; break;
    case CZ_FALSE: name = "FALSE"; break;
    case CZ_FUNCTION: name = "FUNCTION"; break;
    case CZ_MACRO: name = "MACRO"; break;
    case CZ_SUBR: name = "SUBR"; break;
    case CZ_FSUBR: name = "FSUBR"; break;
    case CZ_SEGMENT: name = "SEGMENT"; break;
    case CZ_ADECL: name = "ADECL"; break;
    case CZ_SPLICE: name = "SPLICE"; break;
    case CZ_TABLE: name = "TABLE"; break;
    default: name = "UNKNOWN"; break;
    }
    return ok(cz_intern(c, name, strlen(name)));
}

static cz_result s_typep(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("TYPE?", n >= 2);
    cz_result t = s_type(c, a, 1);
    for (size_t i = 1; i < n; i++) {
        REQUIRE("TYPE?", a[i]->type == CZ_ATOM, "type atoms");
        if (a[i] == t.val) return ok(a[i]);
    }
    return ok(c->false_obj);
}

/* ---- values ---- */

static cz_result s_setg(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("SETG", n == 2);
    REQUIRE("SETG", a[0]->type == CZ_ATOM, "an atom");
    set_global(c, a[0], a[1]);
    return ok(a[1]);
}
static cz_result s_set(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("SET", n == 2);
    REQUIRE("SET", a[0]->type == CZ_ATOM, "an atom");
    set_local(c, a[0], a[1]);
    return ok(a[1]);
}
static cz_result s_gval(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("GVAL", n == 1);
    REQUIRE("GVAL", a[0]->type == CZ_ATOM, "an atom");
    cz_val *v = get_global(c, a[0]);
    if (!v) return ERR(c, "atom has no global value: %s", a[0]->atom.name);
    return ok(v);
}
static cz_result s_lval(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("LVAL", n == 1);
    REQUIRE("LVAL", a[0]->type == CZ_ATOM, "an atom");
    cz_val *v = get_local(c, a[0]);
    if (!v) return ERR(c, "atom has no local value: %s", a[0]->atom.name);
    return ok(v);
}
static cz_result s_value(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("VALUE", n == 1);
    REQUIRE("VALUE", a[0]->type == CZ_ATOM, "an atom");
    cz_val *v = get_local(c, a[0]);
    if (!v) v = get_global(c, a[0]);
    if (!v) return ERR(c, "atom has no value: %s", a[0]->atom.name);
    return ok(v);
}
static cz_result s_gassigned(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("GASSIGNED?", n == 1);
    REQUIRE("GASSIGNED?", a[0]->type == CZ_ATOM, "an atom");
    return ok(boolify(c, get_global(c, a[0]) != NULL));
}
static cz_result s_assigned(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("ASSIGNED?", n == 1);
    REQUIRE("ASSIGNED?", a[0]->type == CZ_ATOM, "an atom");
    return ok(boolify(c, get_local(c, a[0]) != NULL));
}
static cz_result s_unassign(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("UNASSIGN", n == 1);
    REQUIRE("UNASSIGN", a[0]->type == CZ_ATOM, "an atom");
    unassign_local(c, a[0]);
    return ok(a[0]);
}
static cz_result s_gunassign(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("GUNASSIGN", n == 1);
    REQUIRE("GUNASSIGN", a[0]->type == CZ_ATOM, "an atom");
    uint32_t h = cz_hash_ptr(a[0]) % GLOBAL_BUCKETS;
    binding *b = find_binding(c->globals[h], a[0]);
    if (b) b->value = NULL;
    return ok(a[0]);
}

/* ---- quote / eval / apply ---- */

static cz_result f_quote(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("QUOTE", n == 1);
    return ok(a[0]);
}
static cz_result s_eval(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("EVAL", n == 1 || n == 2);
    if (n == 2) return ERR(c, "EVAL: environments not supported");
    return cz_eval(c, a[0]);
}
static cz_result s_expand(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("EXPAND", n == 1);
    return ok(a[0]);  /* argument was already evaluated once */
}
static cz_result s_id(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("ID", n == 1);
    return ok(a[0]);
}
static cz_result s_apply(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("APPLY", n >= 1);
    if (!is_applicable(a[0])) return ERR(c, "APPLY: not applicable");
    return cz_apply(c, a[0], a + 1, n - 1, false);
}

/* ---- flow control ---- */

static cz_result f_cond(cz_ctx *c, cz_val **a, size_t n) {
    cz_result result = ok(c->false_obj);
    for (size_t i = 0; i < n; i++) {
        if (a[i]->type != CZ_LIST || a[i]->seq.count == 0)
            return ERR(c, "COND: clauses must be non-empty lists");
        result = cz_eval(c, a[i]->seq.items[0]);
        if (result.flow != CZ_F_NORMAL) return result;
        if (!cz_is_true(result.val)) continue;
        for (size_t j = 1; j < a[i]->seq.count; j++) {
            result = cz_eval(c, a[i]->seq.items[j]);
            if (result.flow != CZ_F_NORMAL) return result;
        }
        break;
    }
    return result;
}

static cz_result f_and(cz_ctx *c, cz_val **a, size_t n) {
    cz_result r = ok(cz_intern(c, "T", 1));
    for (size_t i = 0; i < n; i++) {
        r = cz_eval(c, a[i]);
        if (r.flow != CZ_F_NORMAL || !cz_is_true(r.val)) return r;
    }
    return r;
}
static cz_result f_or(cz_ctx *c, cz_val **a, size_t n) {
    cz_result r = ok(c->false_obj);
    for (size_t i = 0; i < n; i++) {
        r = cz_eval(c, a[i]);
        if (r.flow != CZ_F_NORMAL || cz_is_true(r.val)) return r;
    }
    return r;
}

static cz_result run_block(cz_ctx *c, cz_val **a, size_t n, bool repeat) {
    REQUIRE_COUNT(repeat ? "REPEAT" : "PROG", n >= 2);
    /* optional activation atom before the binding list */
    size_t i = 0;
    if (a[i]->type == CZ_ATOM) i++;
    if (i >= n || a[i]->type != CZ_LIST)
        return ERR(c, "PROG/REPEAT: expected binding list");
    cz_val *bindings = a[i++];
    if (i >= n) return ERR(c, "PROG/REPEAT: missing body");

    frame fr = { .parent = c->env, .bindings = NULL };
    c->env = &fr;
    cz_result result = ok(c->false_obj);
    bool done = false;

    /* bindings: atom, (atom init), adecl-wrapped variants */
    for (size_t b = 0; b < bindings->seq.count && !done; b++) {
        cz_val *item = bindings->seq.items[b];
        if (item->type == CZ_ADECL) item = item->adecl.value;
        if (item->type == CZ_ATOM) {
            bind_here(c, item, NULL);
        } else if (item->type == CZ_LIST && item->seq.count == 2) {
            cz_val *atom = item->seq.items[0];
            if (atom->type == CZ_ADECL) atom = atom->adecl.value;
            if (atom->type != CZ_ATOM) { result = ERR(c, "bad PROG binding"); done = true; break; }
            cz_result r = cz_eval(c, item->seq.items[1]);
            if (r.flow != CZ_F_NORMAL) { result = r; done = true; break; }
            bind_here(c, atom, r.val);
        } else {
            result = ERR(c, "bad PROG binding");
            done = true;
        }
    }

    while (!done) {
        bool again = false;
        for (size_t j = i; j < n; j++) {
            if (a[j]->type == CZ_CHTYPE
                && strcmp(a[j]->chtype.type_atom->atom.name, "DECL") == 0)
                continue;
            result = cz_eval(c, a[j]);
            if (result.flow == CZ_F_RETURN) {
                result = ok(result.val);
                done = true;
                break;
            }
            if (result.flow == CZ_F_AGAIN) { again = true; break; }
            if (result.flow != CZ_F_NORMAL) { done = true; break; }
        }
        if (done) break;
        if (again) continue;
        if (!repeat) break;   /* PROG runs once; REPEAT loops */
    }

    c->env = fr.parent;
    return result;
}

static cz_result f_prog(cz_ctx *c, cz_val **a, size_t n) { return run_block(c, a, n, false); }
static cz_result f_repeat(cz_ctx *c, cz_val **a, size_t n) { return run_block(c, a, n, true); }
static cz_result f_bind(cz_ctx *c, cz_val **a, size_t n) { return run_block(c, a, n, false); }

static cz_result s_return(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("RETURN", n <= 1);
    return (cz_result){ CZ_F_RETURN, n == 1 ? a[0] : cz_intern(c, "T", 1) };
}
static cz_result s_again(cz_ctx *c, cz_val **a, size_t n) {
    (void)a;
    REQUIRE_COUNT("AGAIN", n == 0);
    return (cz_result){ CZ_F_AGAIN, NULL };
}

/* ---- definitions ---- */

static cz_result make_function(cz_ctx *c, const char *name, cz_val **a, size_t n, cz_val **out) {
    if (n < 1 || a[0]->type != CZ_LIST) return ERR(c, "%s: expected argspec list", name);
    /* a body consisting only of a #DECL doesn't count as a body */
    size_t real_body = 0;
    for (size_t i = 1; i < n; i++)
        if (!(a[i]->type == CZ_CHTYPE
              && strcmp(a[i]->chtype.type_atom->atom.name, "DECL") == 0))
            real_body++;
    if (real_body == 0) return ERR(c, "%s: missing body", name);

    cz_val *f = cz_alloc(c->arena, sizeof(*f));
    memset(f, 0, sizeof(*f));
    f->type = CZ_FUNCTION;
    f->func.spec = a[0];
    f->func.body = cz_alloc(c->arena, (n - 1) * sizeof(cz_val *));
    memcpy(f->func.body, a + 1, (n - 1) * sizeof(cz_val *));
    f->func.body_count = n - 1;
    f->func.name = name;
    *out = f;
    return ok(f);
}

static cz_result define_common(cz_ctx *c, cz_val **a, size_t n, bool macro) {
    const char *what = macro ? "DEFMAC" : "DEFINE";
    REQUIRE_COUNT(what, n >= 3);
    REQUIRE(what, a[0]->type == CZ_ATOM, "a name atom");
    if (a[1]->type != CZ_LIST)
        return ERR(c, "%s: expected argspec list (activation atoms unsupported)", what);

    cz_val *existing = get_global(c, a[0]);
    if (existing && (existing->type == CZ_FUNCTION || existing->type == CZ_MACRO)) {
        cz_val *redefine = get_local(c, cz_intern(c, "REDEFINE", 8));
        if (!redefine || !cz_is_true(redefine))
            return ERR(c, "%s: already defined: %s (SET REDEFINE T to allow)", what, a[0]->atom.name);
    }

    cz_val *fn;
    cz_result r = make_function(c, a[0]->atom.name, a + 1, n - 1, &fn);
    if (r.flow != CZ_F_NORMAL) return r;
    if (macro) {
        cz_val *m = cz_new_wrap(c, CZ_MACRO, fn);
        set_global(c, a[0], m);
    } else {
        set_global(c, a[0], fn);
    }
    return ok(a[0]);
}

static cz_result f_define(cz_ctx *c, cz_val **a, size_t n) { return define_common(c, a, n, false); }
static cz_result f_defmac(cz_ctx *c, cz_val **a, size_t n) { return define_common(c, a, n, true); }
static cz_result f_function(cz_ctx *c, cz_val **a, size_t n) {
    cz_val *fn;
    return make_function(c, "anonymous", a, n, &fn);
}

/* ---- structures ---- */

static cz_result s_list(cz_ctx *c, cz_val **a, size_t n) { return ok(new_list_of(c, CZ_LIST, a, n)); }
static cz_result s_vector(cz_ctx *c, cz_val **a, size_t n) { return ok(new_list_of(c, CZ_VECTOR, a, n)); }
static cz_result s_form(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("FORM", n >= 1);
    return ok(new_list_of(c, CZ_FORM, a, n));
}
static cz_result s_cons(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("CONS", n == 2);
    REQUIRE("CONS", a[1]->type == CZ_LIST, "a list");
    varr out = { 0 };
    varr_push(&out, a[0]);
    for (size_t i = 0; i < a[1]->seq.count; i++) varr_push(&out, a[1]->seq.items[i]);
    cz_val *v = new_list_of(c, CZ_LIST, out.items, out.n);
    free(out.items);
    return ok(v);
}

static cz_result s_length(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("LENGTH", n == 1);
    if (a[0]->type == CZ_STRING) return ok(cz_new_fix(c, (int32_t)a[0]->str.len));
    REQUIRE("LENGTH", is_seq(a[0]), "a structure");
    return ok(cz_new_fix(c, (int32_t)a[0]->seq.count));
}
static cz_result s_lengthp(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("LENGTH?", n == 2);
    REQUIRE("LENGTH?", a[1]->type == CZ_FIX, "a FIX limit");
    size_t len;
    if (a[0]->type == CZ_STRING) len = a[0]->str.len;
    else { REQUIRE("LENGTH?", is_seq(a[0]), "a structure"); len = a[0]->seq.count; }
    return len <= (size_t)a[1]->fix.value
        ? ok(cz_new_fix(c, (int32_t)len))
        : ok(c->false_obj);
}
static cz_result s_emptyp(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("EMPTY?", n == 1);
    if (a[0]->type == CZ_STRING) return ok(boolify(c, a[0]->str.len == 0));
    REQUIRE("EMPTY?", is_seq(a[0]), "a structure");
    return ok(boolify(c, a[0]->seq.count == 0));
}

static cz_result s_nth(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("NTH", n == 1 || n == 2);
    int32_t idx = n == 2 ? (a[1]->type == CZ_FIX ? a[1]->fix.value : -1) : 1;
    if (idx < 1) return ERR(c, "NTH: bad index");
    if (a[0]->type == CZ_STRING) {
        if ((size_t)idx > a[0]->str.len) return ERR(c, "NTH: index out of range");
        return ok(cz_new_char(c, (unsigned char)a[0]->str.text[idx - 1]));
    }
    REQUIRE("NTH", is_seq(a[0]), "a structure");
    if ((size_t)idx > a[0]->seq.count) return ERR(c, "NTH: index out of range");
    return ok(a[0]->seq.items[idx - 1]);
}

static cz_result s_rest(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("REST", n == 1 || n == 2);
    int32_t k = n == 2 ? (a[1]->type == CZ_FIX ? a[1]->fix.value : -1) : 1;
    if (k < 0) return ERR(c, "REST: bad count");
    if (a[0]->type == CZ_STRING) {
        if ((size_t)k > a[0]->str.len) return ERR(c, "REST: past end");
        return ok(cz_new_string(c, a[0]->str.text + k, a[0]->str.len - k));
    }
    REQUIRE("REST", is_seq(a[0]), "a structure");
    if ((size_t)k > a[0]->seq.count) return ERR(c, "REST: past end");
    if (a[0]->type == CZ_VECTOR || a[0]->type == CZ_TABLE)
        return ok(new_list_of(c, CZ_VECTOR, a[0]->seq.items + k, a[0]->seq.count - k));
    /* LIST primtype: REST shares structure with the original so PUTREST
     * through the view extends the whole chain (MDL cons semantics) */
    cz_val *v = cz_alloc(c->arena, sizeof(*v));
    memset(v, 0, sizeof(*v));
    v->type = CZ_LIST;
    v->seq.owner = a[0]->seq.owner ? a[0]->seq.owner : a[0];
    v->seq.off = a[0]->seq.off + (size_t)k;
    v->seq.items = v->seq.owner->seq.items + v->seq.off;
    v->seq.count = a[0]->seq.count - (size_t)k;
    return ok(v);
}

static cz_result s_put(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("PUT", n == 3);
    REQUIRE("PUT", is_seq(a[0]), "a structure");
    REQUIRE("PUT", a[1]->type == CZ_FIX, "a FIX index");
    int32_t idx = a[1]->fix.value;
    if (idx < 1 || (size_t)idx > a[0]->seq.count) return ERR(c, "PUT: index out of range");
    a[0]->seq.items[idx - 1] = a[2];
    return ok(a[0]);
}

static cz_result s_putrest(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("PUTREST", n == 2);
    REQUIRE("PUTREST", a[0]->type == CZ_LIST || a[0]->type == CZ_FORM || a[0]->type == CZ_FALSE, "a list");
    REQUIRE("PUTREST", a[1]->type == CZ_LIST || a[1]->type == CZ_FORM || a[1]->type == CZ_FALSE, "a list");
    if (a[0]->seq.count == 0) return ERR(c, "PUTREST: empty list");

    /* grow the OWNER so every live view of the chain sees the new tail.
     * The old array stays behind in the arena: views taken before this
     * call keep the detached old tail, exactly like MDL cons cells. */
    cz_val *owner = a[0]->seq.owner ? a[0]->seq.owner : a[0];
    size_t base = a[0]->seq.off;             /* x's head within the owner */
    size_t newcount = base + 1 + a[1]->seq.count;
    cz_val **arr = cz_alloc(c->arena, newcount ? newcount * sizeof(cz_val *) : 1);
    memcpy(arr, owner->seq.items, (base + 1) * sizeof(cz_val *));
    for (size_t i = 0; i < a[1]->seq.count; i++)
        arr[base + 1 + i] = a[1]->seq.items[i];
    owner->seq.items = arr;
    owner->seq.count = newcount;
    /* refresh the alias PUTREST was called through */
    a[0]->seq.items = owner->seq.items + base;
    a[0]->seq.count = newcount - base;
    return ok(a[0]);
}

static cz_result s_memq(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("MEMQ", n == 2);
    REQUIRE("MEMQ", is_seq(a[1]), "a structure");
    for (size_t i = 0; i < a[1]->seq.count; i++)
        if (exact_equal(a[0], a[1]->seq.items[i]) || a[0] == a[1]->seq.items[i]) {
            cz_type t = a[1]->type == CZ_VECTOR ? CZ_VECTOR : CZ_LIST;
            return ok(new_list_of(c, t, a[1]->seq.items + i, a[1]->seq.count - i));
        }
    return ok(c->false_obj);
}
static cz_result s_member(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("MEMBER", n == 2);
    REQUIRE("MEMBER", is_seq(a[1]), "a structure");
    for (size_t i = 0; i < a[1]->seq.count; i++)
        if (struct_equal(a[0], a[1]->seq.items[i])) {
            cz_type t = a[1]->type == CZ_VECTOR ? CZ_VECTOR : CZ_LIST;
            return ok(new_list_of(c, t, a[1]->seq.items + i, a[1]->seq.count - i));
        }
    return ok(c->false_obj);
}

/* ---- strings and atoms ---- */

static cz_result s_spname(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("SPNAME", n == 1);
    REQUIRE("SPNAME", a[0]->type == CZ_ATOM, "an atom");
    return ok(cz_new_string(c, a[0]->atom.name, strlen(a[0]->atom.name)));
}

static cz_result s_string(cz_ctx *c, cz_val **a, size_t n) {
    size_t cap = 64, len = 0;
    char *buf = malloc(cap);
    if (!buf) abort();
    for (size_t i = 0; i < n; i++) {
        const char *piece;
        char chbuf[1];
        size_t plen;
        if (a[i]->type == CZ_STRING) { piece = a[i]->str.text; plen = a[i]->str.len; }
        else if (a[i]->type == CZ_CHAR) { chbuf[0] = (char)a[i]->chr.ch; piece = chbuf; plen = 1; }
        else { free(buf); return ERR(c, "STRING: expected strings/characters"); }
        if (len + plen + 1 > cap) {
            while (cap < len + plen + 1) cap *= 2;
            buf = realloc(buf, cap);
            if (!buf) abort();
        }
        memcpy(buf + len, piece, plen);
        len += plen;
    }
    cz_val *v = cz_new_string(c, buf, len);
    free(buf);
    return ok(v);
}

static cz_result s_parse(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("PARSE", n == 1);
    REQUIRE("PARSE", a[0]->type == CZ_STRING, "a string");
    cz_parse_result pr = cz_parse(c, a[0]->str.text, a[0]->str.len);
    if (!pr.ok) return ERR(c, "PARSE: %s", pr.error);
    if (pr.count == 0) return ERR(c, "PARSE: empty");
    return ok(pr.items[0]);
}

static cz_result s_chtype(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("CHTYPE", n == 2);
    REQUIRE("CHTYPE", a[1]->type == CZ_ATOM, "a type atom");
    const char *tn = a[1]->atom.name;
    cz_val *v = a[0];
    cz_type want;
    if (strcmp(tn, "LIST") == 0) want = CZ_LIST;
    else if (strcmp(tn, "FORM") == 0) want = CZ_FORM;
    else if (strcmp(tn, "VECTOR") == 0) want = CZ_VECTOR;
    else if (strcmp(tn, "FALSE") == 0) want = CZ_FALSE;
    else if (strcmp(tn, "SPLICE") == 0) want = CZ_SPLICE;
    else if (strcmp(tn, "SEGMENT") == 0) {
        if (v->type != CZ_FORM) return ERR(c, "CHTYPE SEGMENT needs a FORM");
        return ok(cz_new_wrap(c, CZ_SEGMENT, v));
    }
    else return ERR(c, "CHTYPE to %s not supported", tn);
    if (!is_seq(v) && !(v->type == CZ_SEGMENT && want == CZ_FORM))
        return ERR(c, "CHTYPE: value has wrong primtype");
    if (v->type == CZ_SEGMENT) return ok(v->seg.inner);
    return ok(cz_new_seq(c, want, v->seq.items, v->seq.count));
}

/* ---- MAPF / MAPR ---- */

static cz_result do_map(cz_ctx *c, cz_val **a, size_t n, bool rests) {
    const char *name = rests ? "MAPR" : "MAPF";
    REQUIRE_COUNT(name, n >= 2);
    cz_val *finalf = a[0];
    cz_val *loopf = a[1];
    size_t nstructs = n - 2;
    cz_val **structs = a + 2;
    for (size_t i = 0; i < nstructs; i++)
        REQUIRE(name, is_seq(structs[i]) || structs[i]->type == CZ_STRING, "structures");

    varr collected = { 0 };
    size_t pos = 0;
    cz_result final_result;
    bool stopped = false;

    for (;;) {
        /* out of elements? (with no structs, loop until MAPSTOP/MAPLEAVE) */
        if (nstructs > 0) {
            bool exhausted = false;
            for (size_t i = 0; i < nstructs; i++) {
                size_t len = structs[i]->type == CZ_STRING ? structs[i]->str.len : structs[i]->seq.count;
                if (pos >= len) { exhausted = true; break; }
            }
            if (exhausted) break;
        }

        cz_val *callargs[8];
        size_t ncall = nstructs > 8 ? 8 : nstructs;
        for (size_t i = 0; i < ncall; i++) {
            if (structs[i]->type == CZ_STRING) {
                callargs[i] = rests
                    ? cz_new_string(c, structs[i]->str.text + pos, structs[i]->str.len - pos)
                    : cz_new_char(c, (unsigned char)structs[i]->str.text[pos]);
            } else {
                callargs[i] = rests
                    ? new_list_of(c, CZ_LIST, structs[i]->seq.items + pos, structs[i]->seq.count - pos)
                    : structs[i]->seq.items[pos];
            }
        }
        pos++;

        cz_result r = cz_apply(c, loopf, callargs, ncall, false);
        if (r.flow == CZ_F_MAPRET || r.flow == CZ_F_MAPSTOP) {
            for (size_t i = 0; i < r.val->seq.count; i++)
                varr_push(&collected, r.val->seq.items[i]);
            if (r.flow == CZ_F_MAPSTOP) { stopped = true; break; }
        } else if (r.flow != CZ_F_NORMAL) {
            free(collected.items);
            return r;
        } else {
            varr_push(&collected, r.val);
        }
    }
    (void)stopped;

    if (finalf->type == CZ_FALSE) {
        final_result = collected.n
            ? ok(collected.items[collected.n - 1])
            : ok(c->false_obj);
    } else {
        final_result = cz_apply(c, finalf, collected.items, collected.n, false);
    }
    free(collected.items);
    return final_result;
}

static cz_result s_mapf(cz_ctx *c, cz_val **a, size_t n) { return do_map(c, a, n, false); }
static cz_result s_mapr(cz_ctx *c, cz_val **a, size_t n) { return do_map(c, a, n, true); }

static cz_result s_mapret(cz_ctx *c, cz_val **a, size_t n) {
    return (cz_result){ CZ_F_MAPRET, new_list_of(c, CZ_SPLICE, a, n) };
}
static cz_result s_mapstop(cz_ctx *c, cz_val **a, size_t n) {
    return (cz_result){ CZ_F_MAPSTOP, new_list_of(c, CZ_SPLICE, a, n) };
}

/* ---- output ---- */

static cz_result s_princ(cz_ctx *c, cz_val **a, size_t n) {
    REQUIRE_COUNT("PRINC", n == 1);
    if (a[0]->type == CZ_STRING) {
        out_emit(c, a[0]->str.text, a[0]->str.len);
    } else if (a[0]->type == CZ_CHAR) {
        char ch = (char)a[0]->chr.ch;
        out_emit(c, &ch, 1);
    } else {
        char *buf = NULL; size_t len = 0, cap = 0;
        cz_print(a[0], &buf, &len, &cap);
        out_emit(c, buf, len);
        free(buf);
    }
    return ok(a[0]);
}
static cz_result s_crlf(cz_ctx *c, cz_val **a, size_t n) {
    (void)a; (void)n;
    out_emit(c, "\n", 1);
    return ok(cz_intern(c, "T", 1));
}

/* ---- no-ops the trilogy sources use at read time ---- */

static cz_result f_gdecl(cz_ctx *c, cz_val **a, size_t n) {
    (void)a; (void)n;
    return ok(cz_intern(c, "T", 1));
}

/* ---- internals shared with zmodel.c ---- */

void cz_setg(cz_ctx *c, cz_val *atom, cz_val *value) { set_global(c, atom, value); }
cz_val *cz_getg(cz_ctx *c, cz_val *atom) { return get_global(c, atom); }

/* ---- registration ---- */

static void reg(cz_ctx *c, const char *name, cz_subr_fn fn, bool fsubr) {
    cz_val *v = cz_alloc(c->arena, sizeof(*v));
    memset(v, 0, sizeof(*v));
    v->type = fsubr ? CZ_FSUBR : CZ_SUBR;
    v->subr.fn = (void *)fn;
    v->subr.name = name;
    set_global(c, cz_intern(c, name, strlen(name)), v);
}

void cz_def_subr(cz_ctx *c, const char *name, cz_subr_fn fn, bool fsubr) {
    reg(c, name, fn, fsubr);
}

void cz_eval_init(cz_ctx *c) {
    /* canonical FALSE */
    cz_val *f = cz_alloc(c->arena, sizeof(*f));
    memset(f, 0, sizeof(*f));
    f->type = CZ_FALSE;
    c->false_obj = f;

    reg(c, "+", s_add, false);       reg(c, "-", s_sub, false);
    reg(c, "*", s_mul, false);       reg(c, "/", s_div, false);
    reg(c, "MOD", s_mod, false);     reg(c, "LSH", s_lsh, false);
    reg(c, "MIN", s_min, false);     reg(c, "MAX", s_max, false);
    reg(c, "ABS", s_abs, false);

    reg(c, "==?", s_eeq, false);     reg(c, "N==?", s_neeq, false);
    reg(c, "=?", s_seq_eq, false);   reg(c, "N=?", s_seq_neq, false);
    reg(c, "G?", s_g, false);        reg(c, "L?", s_l, false);
    reg(c, "G=?", s_geq, false);     reg(c, "L=?", s_leq, false);
    reg(c, "0?", s_zerop, false);    reg(c, "1?", s_onep, false);
    reg(c, "NOT", s_not, false);
    reg(c, "TYPE", s_type, false);   reg(c, "TYPE?", s_typep, false);

    reg(c, "SETG", s_setg, false);   reg(c, "SET", s_set, false);
    reg(c, "GVAL", s_gval, false);   reg(c, "LVAL", s_lval, false);
    reg(c, "VALUE", s_value, false);
    reg(c, "GASSIGNED?", s_gassigned, false);
    reg(c, "ASSIGNED?", s_assigned, false);
    reg(c, "UNASSIGN", s_unassign, false);
    reg(c, "GUNASSIGN", s_gunassign, false);

    reg(c, "QUOTE", f_quote, true);
    reg(c, "ID", s_id, false);
    reg(c, "EVAL", s_eval, false);
    reg(c, "EXPAND", s_expand, false);
    reg(c, "APPLY", s_apply, false);

    reg(c, "COND", f_cond, true);
    reg(c, "AND", f_and, true);      reg(c, "OR", f_or, true);
    reg(c, "PROG", f_prog, true);    reg(c, "REPEAT", f_repeat, true);
    reg(c, "BIND", f_bind, true);
    reg(c, "RETURN", s_return, false);
    reg(c, "AGAIN", s_again, false);

    reg(c, "DEFINE", f_define, true);
    reg(c, "DEFMAC", f_defmac, true);
    reg(c, "FUNCTION", f_function, true);

    reg(c, "LIST", s_list, false);   reg(c, "VECTOR", s_vector, false);
    reg(c, "FORM", s_form, false);   reg(c, "CONS", s_cons, false);
    reg(c, "LENGTH", s_length, false);
    reg(c, "LENGTH?", s_lengthp, false);
    reg(c, "EMPTY?", s_emptyp, false);
    reg(c, "NTH", s_nth, false);     reg(c, "REST", s_rest, false);
    reg(c, "PUT", s_put, false);     reg(c, "PUTREST", s_putrest, false);
    reg(c, "MEMQ", s_memq, false);   reg(c, "MEMBER", s_member, false);

    reg(c, "SPNAME", s_spname, false);
    reg(c, "STRING", s_string, false);
    reg(c, "PARSE", s_parse, false);
    reg(c, "CHTYPE", s_chtype, false);

    reg(c, "MAPF", s_mapf, false);   reg(c, "MAPR", s_mapr, false);
    reg(c, "MAPRET", s_mapret, false);
    reg(c, "MAPSTOP", s_mapstop, false);

    reg(c, "PRINC", s_princ, false);
    reg(c, "CRLF", s_crlf, false);

    reg(c, "GDECL", f_gdecl, true);
}
