/* czil - C port of ZILF (Copyright 2010-2023 Tara McGrew).
 * GPL-3.0-or-later; see czil/LICENSE.
 *
 * Port of Zilf/Language/Parsing/Parser.cs + CharBuffer.cs.
 *
 * Upstream's trick is kept: a '!' prefix adds 128 to the following
 * character, so "banged" tokens travel through the parser as c+128
 * (e.g. !> is '>'+128). Characters are ints here; EOF is -1.
 *
 * Deviations (documented in ../README.md): %-macros and #type CHTYPEs
 * parse into deferred nodes instead of evaluating (no evaluator yet);
 * one global oblist; {} templates are an error.
 */
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <setjmp.h>
#include "czil.h"

#define BANG 128
#define B(c) ((c) + BANG)

typedef struct {
    cz_ctx *ctx;
    const char *src;
    size_t len, pos;
    int line;
    int pushback[16];
    int nback;
    int cur;              /* current character (last returned) */
    jmp_buf fail;
    char error[256];
    int error_line;
    /* top-level accumulator lives here so it survives longjmp intact */
    cz_val **top_items;
    size_t top_count, top_cap;
} reader;

/* ---- output of one parse step (upstream: ParserOutput) ---- */

typedef enum { PO_OBJECT, PO_COMMENT, PO_TERMINATOR, PO_EOF, PO_EMPTY } po_type;

typedef struct {
    po_type type;
    cz_val *obj;
} po;

static po po_obj(cz_val *v) { return (po){ PO_OBJECT, v }; }
static po po_comment(cz_val *v) { return (po){ PO_COMMENT, v }; }
static const po PO_TERM = { PO_TERMINATOR, NULL };
static const po PO_END = { PO_EOF, NULL };
static const po PO_SKIP = { PO_EMPTY, NULL };

_Noreturn static void fail(reader *r, const char *fmt, const char *arg) {
    snprintf(r->error, sizeof r->error, fmt, arg ? arg : "");
    r->error_line = r->line;
    longjmp(r->fail, 1);
}

/* ---- char buffer (upstream: CharBuffer) ---- */

static bool move_next(reader *r) {
    if (r->nback > 0) {
        r->cur = r->pushback[--r->nback];
        return true;
    }
    if (r->pos >= r->len) { r->cur = -1; return false; }
    r->cur = (unsigned char)r->src[r->pos++];
    if (r->cur == '\n') r->line++;
    return true;
}

static void push_back(reader *r, int c) {
    if (r->nback >= (int)(sizeof r->pushback / sizeof r->pushback[0])) abort();
    r->pushback[r->nback++] = c;
}

/* upstream CharBuffer.UnreadCurrent: current char returns to the head of
 * the queue AND stays queued behind the restored one */
static void unread_current(reader *r, int restored) {
    push_back(r, r->cur);
    push_back(r, restored);
    move_next(r); /* restored becomes current again */
}

/* ---- char classes (upstream: CharExtensions) ---- */

static bool is_terminator(int c) {
    switch (c & ~BANG) {
    case ')': case ']': case '}': case '>': case ':': return true;
    default: return false;
    }
}

static bool is_ws(int c) {
    return c == ' ' || c == '\t' || c == '\r' || c == '\f' || c == '\n';
}

static bool is_non_atom_char(int c) {
    if (is_ws(c & ~BANG)) return true;
    switch (c & ~BANG) {
    case '<': case '>': case '(': case ')': case '{': case '}':
    case '[': case ']': case ':': case ';': case '"': case '\'':
    case ',': case '%': case '#': return true;
    default: return false;
    }
}

/* ---- whitespace (upstream: SkipWhitespace, incl. bang-whitespace) ---- */

static bool skip_ws(reader *r) {
    for (;;) {
        if (!move_next(r)) return false;
        int c = r->cur;
        if (is_ws(c)) continue;
        if (c == '!') {
            if (!move_next(r)) fail(r, "expected character after '!', found EOF", NULL);
            if (is_ws(r->cur)) continue;      /* !<ws> is whitespace */
            unread_current(r, '!');           /* '!' current again, next queued */
            return true;
        }
        return true;
    }
}

/* ---- forward decls ---- */

static po parse_one(reader *r);
static po parse_one_nonadecl(reader *r);

/* parse the next real object after a prefix (upstream: ParsePrefixed) */
static cz_val *parse_prefixed_obj(reader *r, const char *what) {
    for (;;) {
        po p = parse_one_nonadecl(r);
        switch (p.type) {
        case PO_COMMENT:
        case PO_EMPTY: continue;
        case PO_OBJECT: return p.obj;
        case PO_EOF: fail(r, "expected object after '%s', found EOF", what);
        case PO_TERMINATOR:
            move_next(r);
            fail(r, "expected object after '%s', found terminator", what);
        }
    }
}

/* ---- atoms and numbers (upstream: ParseCurrentAtomOrNumber) ---- */

static cz_val *parse_atom_or_number(reader *r) {
    char buf[512];
    size_t n = 0;
    bool run = true, backslash = false;
    int digits = 0, octal_digits = 0;

    do {
        int c = r->cur;
        if (is_non_atom_char(c)) {
            push_back(r, c);
            run = false;
        } else if (c == '\\') {
            backslash = true;
            if (!move_next(r)) fail(r, "expected character after '\\', found EOF", NULL);
            if (n < sizeof buf - 1) buf[n++] = (char)r->cur;
        } else if (c == '!') {
            /* keep "!-" (oblist separator), otherwise drop the bang */
            if (!move_next(r)) fail(r, "expected character after '!', found EOF", NULL);
            if (r->cur == '-') {
                if (n < sizeof buf - 2) { buf[n++] = '!'; buf[n++] = '-'; }
            } else {
                push_back(r, r->cur);
            }
        } else {
            if (n < sizeof buf - 1) buf[n++] = (char)c;
            if (c >= '0' && c <= '9') {
                digits++;
                if (c < '8') octal_digits++;
            }
        }
    } while (run && move_next(r));

    if (n == 0) fail(r, "empty atom", NULL);
    buf[n] = '\0';

    if (!backslash) {
        /* decimal FIX: all digits, or sign + all digits */
        if (digits > 0 &&
            ((size_t)digits == n ||
             ((size_t)digits == n - 1 && (buf[0] == '-' || buf[0] == '+')))) {
            return cz_new_fix(r->ctx, (int32_t)strtol(buf, NULL, 10));
        }
        /* octal *777* */
        if (n > 2 && (size_t)octal_digits == n - 2 && buf[0] == '*' && buf[n - 1] == '*') {
            buf[n - 1] = '\0';
            return cz_new_fix(r->ctx, (int32_t)strtol(buf + 1, NULL, 8));
        }
    }
    return cz_intern(r->ctx, buf, n);
}

/* ---- strings (upstream: ParseCurrentString) ---- */

static cz_val *parse_string(reader *r) {
    size_t cap = 128, n = 0;
    char *buf = malloc(cap);
    if (!buf) abort();
    while (move_next(r)) {
        int c = r->cur;
        if (c == '"') {
            cz_val *v = cz_new_string(r->ctx, buf, n);
            free(buf);
            return v;
        }
        if (c == '\\') {
            if (!move_next(r)) { free(buf); fail(r, "expected character after '\\' in string, found EOF", NULL); }
            c = r->cur;
        }
        if (n + 1 >= cap) { cap *= 2; buf = realloc(buf, cap); if (!buf) abort(); }
        buf[n++] = (char)c;
    }
    free(buf);
    fail(r, "unterminated string", NULL);
    return NULL;
}

/* ---- structures (upstream: ParseCurrentStructure) ---- */

static cz_val *parse_structure(reader *r, int ket1, int ket2, cz_type type) {
    size_t cap = 16, n = 0;
    cz_val **items = malloc(cap * sizeof(cz_val *));
    if (!items) abort();

    for (;;) {
        po p = parse_one(r);
        switch (p.type) {
        case PO_COMMENT:
        case PO_EMPTY:
            break;
        case PO_EOF:
            free(items);
            fail(r, "unterminated structure (expected closing bracket)", NULL);
            break;
        case PO_OBJECT:
            if (n >= cap) { cap *= 2; items = realloc(items, cap * sizeof(cz_val *)); if (!items) abort(); }
            items[n++] = p.obj;
            break;
        case PO_TERMINATOR: {
            move_next(r);
            int c = r->cur;
            if (c != ket1 && c != ket2) {
                free(items);
                fail(r, "mismatched terminator in structure", NULL);
            }
            cz_val *v = cz_new_seq(r->ctx, type, items, n);
            free(items);
            return v;
        }
        }
    }
}

/* ---- hash-prefixed literals: #2 #16 #TYPE (upstream: '#' case) ---- */

static cz_val *parse_radix_number(reader *r, int radix) {
    if (!skip_ws(r)) fail(r, "expected number after '#radix', found EOF", NULL);
    char buf[64];
    size_t n = 0;
    bool run = true;
    do {
        int c = r->cur;
        bool ok = (radix == 2) ? (c == '0' || c == '1')
                               : ((c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F'));
        if (ok) {
            if (n < sizeof buf - 1) buf[n++] = (char)c;
        } else if (is_terminator(c) || is_ws(c)) {
            push_back(r, c);
            run = false;
        } else {
            fail(r, "bad digit in #radix number", NULL);
        }
    } while (run && move_next(r));
    buf[n] = '\0';
    return cz_new_fix(r->ctx, (int32_t)strtol(buf, NULL, radix));
}

/* ---- the core (upstream: ParseOneNonAdecl) ---- */

static po parse_one_nonadecl(reader *r) {
    if (!skip_ws(r)) return PO_END;

    int c = r->cur;

    /* '!' adds 128 to the next character */
    if (c == '!') {
        if (!move_next(r)) fail(r, "expected character after '!', found EOF", NULL);
        c = r->cur;
        if (c == '!') fail(r, "expected character after '!', found another '!'", NULL);
        if (c < BANG) c += BANG;
    }

    switch (c) {
    case '(':
        return po_obj(parse_structure(r, ')', B(')'), CZ_LIST));
    case '<':
        return po_obj(parse_structure(r, '>', B('>'), CZ_FORM));
    case '[':
        return po_obj(parse_structure(r, ']', B(']'), CZ_VECTOR));
    case B('('):   /* !(foo!) == (foo) */
        return po_obj(parse_structure(r, ')', B(')'), CZ_LIST));
    case B('<'):   /* !<foo!> is a segment */
        return po_obj(cz_new_wrap(r->ctx, CZ_SEGMENT,
                                  parse_structure(r, '>', B('>'), CZ_FORM)));
    case B('['):   /* ![foo!] is a uvector, aliased to vector */
        return po_obj(parse_structure(r, ']', B(']'), CZ_VECTOR));

    case B('.'): case B(','): case B('\''): {
        /* !.X == !<LVAL X> etc: re-queue the unbanged prefix, parse, wrap */
        push_back(r, c - BANG);
        po p = parse_one_nonadecl(r);
        if (p.type != PO_OBJECT) fail(r, "expected object after banged prefix", NULL);
        return po_obj(cz_new_wrap(r->ctx, CZ_SEGMENT, p.obj));
    }

    case '{': case B('{'):
        fail(r, "'{}' template substitution is not supported in czil (stage 3)", NULL);
        break;

    case '.': {
        cz_val *inner = parse_prefixed_obj(r, ".");
        cz_val *items[2] = { cz_intern(r->ctx, "LVAL", 4), inner };
        return po_obj(cz_new_seq(r->ctx, CZ_FORM, items, 2));
    }
    case ',': {
        cz_val *inner = parse_prefixed_obj(r, ",");
        cz_val *items[2] = { cz_intern(r->ctx, "GVAL", 4), inner };
        return po_obj(cz_new_seq(r->ctx, CZ_FORM, items, 2));
    }
    case '\'': {
        cz_val *inner = parse_prefixed_obj(r, "'");
        cz_val *items[2] = { cz_intern(r->ctx, "QUOTE", 5), inner };
        return po_obj(cz_new_seq(r->ctx, CZ_FORM, items, 2));
    }

    case '%': case B('%'): {
        /* %X read-time eval; %%X eval-and-drop. Deferred: no evaluator yet. */
        bool drop = false;
        if (move_next(r)) {
            if (r->cur == '%' || r->cur == B('%')) drop = true;
            else push_back(r, r->cur);
        }
        cz_val *inner = parse_prefixed_obj(r, "%");
        return po_obj(cz_new_wrap(r->ctx, drop ? CZ_READEVAL2 : CZ_READEVAL, inner));
    }

    case '#': case B('#'): {
        cz_val *indicator = parse_prefixed_obj(r, "#");
        if (indicator->type == CZ_FIX && indicator->fix.value == 2)
            return po_obj(parse_radix_number(r, 2));
        if (indicator->type == CZ_FIX && indicator->fix.value == 16)
            return po_obj(parse_radix_number(r, 16));
        if (indicator->type == CZ_ATOM) {
            cz_val *value = parse_prefixed_obj(r, "#type");
            return po_obj(cz_new_chtype(r->ctx, indicator, value));
        }
        fail(r, "expected atom, 2, or 16 after '#'", NULL);
        break;
    }

    case ';': case B(';'): {
        if (move_next(r)) {
            if (r->cur == ';' || r->cur == B(';')) {
                /* ;; line comment */
                size_t cap = 64, n = 0;
                char *buf = malloc(cap);
                if (!buf) abort();
                while (move_next(r)) {
                    if (r->cur == '\r' || r->cur == '\n') break;
                    if (n + 1 >= cap) { cap *= 2; buf = realloc(buf, cap); if (!buf) abort(); }
                    buf[n++] = (char)r->cur;
                }
                cz_val *v = cz_new_string(r->ctx, buf, n);
                free(buf);
                return po_comment(v);
            }
            push_back(r, r->cur);
        }
        cz_val *inner = parse_prefixed_obj(r, ";");
        return po_comment(inner);
    }

    case '"':
        return po_obj(parse_string(r));

    case B('\\'): case B('"'):
        /* !\x and !"x are character literals */
        if (!move_next(r)) fail(r, "expected character after '!\\', found EOF", NULL);
        return po_obj(cz_new_char(r->ctx, r->cur));

    default:
        if (is_terminator(c)) {
            push_back(r, c);
            return PO_TERM;
        }
        if (is_non_atom_char(c)) fail(r, "expected atom, found non-atom character", NULL);
        return po_obj(parse_atom_or_number(r));
    }
    return PO_SKIP; /* unreachable */
}

/* ---- adecl wrapper (upstream: ParseOne) ---- */

static po parse_one(reader *r) {
    po p = parse_one_nonadecl(r);
    if (p.type != PO_OBJECT && p.type != PO_COMMENT) return p;

    /* look ahead for ':' (adecl) */
    if (!skip_ws(r)) return p;
    int c = r->cur;
    if (c != ':' && c != B(':')) {
        push_back(r, c);
        return p;
    }

    po p2;
    do {
        p2 = parse_one_nonadecl(r);
    } while (p2.type == PO_COMMENT || p2.type == PO_EMPTY);

    if (p2.type == PO_EOF) fail(r, "expected object after ':', found EOF", NULL);
    if (p2.type == PO_TERMINATOR) {
        move_next(r);
        fail(r, "expected object after ':', found terminator", NULL);
    }
    cz_val *adecl = cz_new_adecl(r->ctx, p.obj, p2.obj);
    return p.type == PO_COMMENT ? po_comment(adecl) : po_obj(adecl);
}

/* ---- entry point ---- */

cz_parse_result cz_parse(cz_ctx *c, const char *src, size_t len) {
    cz_parse_result result = { 0 };
    reader r = { 0 };
    r.ctx = c;
    r.src = src;
    r.len = len;
    r.line = 1;
    r.top_cap = 64;
    r.top_items = malloc(r.top_cap * sizeof(cz_val *));
    if (!r.top_items) abort();

    if (setjmp(r.fail)) {
        free(r.top_items);
        result.ok = false;
        snprintf(result.error, sizeof result.error, "%s", r.error);
        result.error_line = r.error_line;
        return result;
    }

    for (;;) {
        po p = parse_one(&r);
        if (p.type == PO_EOF) break;
        if (p.type == PO_TERMINATOR) {
            move_next(&r);
            fail(&r, "stray terminator at top level", NULL);
        }
        if (p.type == PO_OBJECT) {
            if (r.top_count >= r.top_cap) {
                r.top_cap *= 2;
                r.top_items = realloc(r.top_items, r.top_cap * sizeof(cz_val *));
                if (!r.top_items) abort();
            }
            r.top_items[r.top_count++] = p.obj;
        }
        /* comments and empty splices are dropped at top level */
    }

    cz_val **arr = cz_alloc(cz_ctx_arena(c), r.top_count * sizeof(cz_val *));
    memcpy(arr, r.top_items, r.top_count * sizeof(cz_val *));
    result.count = r.top_count;
    free(r.top_items);

    result.ok = true;
    result.items = arr;
    return result;
}
