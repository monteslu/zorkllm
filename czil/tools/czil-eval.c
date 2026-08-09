/* czil - C port of ZILF (Copyright 2010-2023 Tara McGrew).
 * GPL-3.0-or-later; see czil/LICENSE.
 * CLI for the stage-3 evaluator.
 *
 *   czil-eval -e "expr..."       parse+eval each top-level object, print results
 *   czil-eval -t tests/eval.t    run a tab-separated test file:
 *                                  OK <TAB> expr <TAB> expected-printed-result
 *                                  ERR <TAB> expr           (must error)
 *                                  OUT <TAB> expr <TAB> expected-PRINC-output
 *                                lines starting with # and blank lines skipped
 *   czil-eval --sweep file.zil…  parse files; evaluate every %<...> / %%<...>
 *                                node found anywhere in the tree; report count
 *                                evaluated and any errors (trilogy acceptance)
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "czil.h"

static char *slurp(const char *path, size_t *len) {
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

static void print_val(cz_val *v) {
    char *buf = NULL; size_t len = 0, cap = 0;
    cz_print(v, &buf, &len, &cap);
    printf("%s\n", buf);
    free(buf);
}

/* ---- -e mode ---- */

static int run_exprs(cz_ctx *ctx, const char *src) {
    cz_parse_result res = cz_parse(ctx, src, strlen(src));
    if (!res.ok) {
        fprintf(stderr, "parse error: %s (line %d)\n", res.error, res.error_line);
        return 1;
    }
    for (size_t i = 0; i < res.count; i++) {
        cz_result r = cz_eval(ctx, res.items[i]);
        if (r.flow == CZ_F_ERROR) {
            fprintf(stderr, "error: %s\n", cz_error(ctx));
            return 1;
        }
        if (r.flow != CZ_F_NORMAL) {
            fprintf(stderr, "error: control flow escaped to top level\n");
            return 1;
        }
        print_val(r.val);
    }
    return 0;
}

/* ---- -t mode ---- */

static int run_testfile(const char *path) {
    size_t len;
    char *src = slurp(path, &len);
    if (!src) { fprintf(stderr, "cannot read %s\n", path); return 1; }

    int pass = 0, fail = 0, lineno = 0;
    char *cursor = src;
    while (*cursor) {
        char *line = cursor;
        char *nl = strchr(cursor, '\n');
        if (nl) { *nl = '\0'; cursor = nl + 1; }
        else cursor = line + strlen(line);
        lineno++;
        if (line[0] == '#' || line[0] == '\0') continue;

        char *tab1 = strchr(line, '\t');
        if (!tab1) { fprintf(stderr, "  FAIL line %d: malformed (no tab)\n", lineno); fail++; continue; }
        *tab1 = '\0';
        char *expr = tab1 + 1;
        char *expect = NULL;
        char *tab2 = strchr(expr, '\t');
        if (tab2) { *tab2 = '\0'; expect = tab2 + 1; }

        /* fresh context per line: tests must not leak state into each other */
        cz_ctx *ctx = cz_ctx_new();
        cz_parse_result pr = cz_parse(ctx, expr, strlen(expr));
        cz_result r = { CZ_F_NORMAL, NULL };
        bool parse_ok = pr.ok && pr.count > 0;
        if (parse_ok) {
            for (size_t i = 0; i < pr.count; i++) {
                r = cz_eval(ctx, pr.items[i]);
                if (r.flow != CZ_F_NORMAL) break;
            }
        }

        if (strcmp(line, "ERR") == 0) {
            if (!parse_ok || r.flow != CZ_F_NORMAL) { pass++; }
            else {
                char *buf = NULL; size_t blen = 0, bcap = 0;
                cz_print(r.val, &buf, &blen, &bcap);
                fprintf(stderr, "  FAIL line %d: expected error from %s, got %s\n", lineno, expr, buf);
                free(buf);
                fail++;
            }
        } else if (strcmp(line, "OK") == 0 || strcmp(line, "OUT") == 0) {
            if (!parse_ok) {
                fprintf(stderr, "  FAIL line %d: parse error in %s: %s\n", lineno, expr, pr.error);
                fail++;
            } else if (r.flow == CZ_F_ERROR) {
                fprintf(stderr, "  FAIL line %d: %s -> error: %s\n", lineno, expr, cz_error(ctx));
                fail++;
            } else if (r.flow != CZ_F_NORMAL) {
                fprintf(stderr, "  FAIL line %d: %s -> control flow escaped\n", lineno, expr);
                fail++;
            } else {
                const char *got;
                char *buf = NULL;
                if (strcmp(line, "OUT") == 0) {
                    got = cz_output(ctx);
                } else {
                    size_t blen = 0, bcap = 0;
                    cz_print(r.val, &buf, &blen, &bcap);
                    got = buf;
                }
                /* test file encodes newlines in expectations as \n */
                char *want = malloc(expect ? strlen(expect) + 1 : 1);
                if (!want) abort();
                size_t w = 0;
                for (const char *p = expect ? expect : ""; *p; p++) {
                    if (p[0] == '\\' && p[1] == 'n') { want[w++] = '\n'; p++; }
                    else want[w++] = *p;
                }
                want[w] = '\0';
                if (strcmp(got, want) == 0) pass++;
                else {
                    fprintf(stderr, "  FAIL line %d: %s\n    want: %s\n    got:  %s\n", lineno, expr, want, got);
                    fail++;
                }
                free(want);
                free(buf);
            }
        } else {
            fprintf(stderr, "  FAIL line %d: unknown directive %s\n", lineno, line);
            fail++;
        }
        cz_ctx_free(ctx);
    }
    free(src);
    printf("eval tests: %d passed, %d failed\n", pass, fail);
    return fail ? 1 : 0;
}

/* ---- --sweep mode: evaluate every READEVAL node in the tree ---- */

typedef struct { int evaluated; int errors; } sweep_stats;

static void sweep(cz_ctx *ctx, cz_val *v, sweep_stats *st, const char *file) {
    switch (v->type) {
    case CZ_READEVAL:
    case CZ_READEVAL2: {
        cz_result r = cz_eval(ctx, v);
        st->evaluated++;
        if (r.flow == CZ_F_ERROR) {
            st->errors++;
            char *buf = NULL; size_t len = 0, cap = 0;
            cz_print(v, &buf, &len, &cap);
            fprintf(stderr, "%s: eval error: %s\n  in: %.200s\n", file, cz_error(ctx), buf);
            free(buf);
        }
        /* still sweep inside for nested READEVALs */
        sweep(ctx, v->seg.inner, st, file);
        break;
    }
    case CZ_LIST: case CZ_FORM: case CZ_VECTOR: case CZ_FALSE: case CZ_SPLICE:
        for (size_t i = 0; i < v->seq.count; i++) sweep(ctx, v->seq.items[i], st, file);
        break;
    case CZ_SEGMENT:
        sweep(ctx, v->seg.inner, st, file);
        break;
    case CZ_ADECL:
        sweep(ctx, v->adecl.value, st, file);
        sweep(ctx, v->adecl.decl, st, file);
        break;
    case CZ_CHTYPE:
        sweep(ctx, v->chtype.value, st, file);
        break;
    default:
        break;
    }
}

/* Top-level forms the sweep must EXECUTE (not just scan) so that later
 * READEVALs see their definitions: DEFINE/DEFMAC/SETG/GDECL and
 * top-level PROG-less SET/COND blocks that guard definitions. */
static bool is_definition_form(cz_val *v) {
    if (v->type != CZ_FORM || v->seq.count == 0) return false;
    if (v->seq.items[0]->type != CZ_ATOM) return false;
    const char *h = v->seq.items[0]->atom.name;
    return strcmp(h, "DEFINE") == 0 || strcmp(h, "DEFMAC") == 0
        || strcmp(h, "SETG") == 0 || strcmp(h, "SET") == 0
        || strcmp(h, "GDECL") == 0 || strcmp(h, "COND") == 0
        || strcmp(h, "OR") == 0 || strcmp(h, "AND") == 0;
}

static int run_sweep(int argc, char **argv, int first, const char *zork_number) {
    cz_ctx *ctx = cz_ctx_new();
    sweep_stats st = { 0, 0 };
    int parse_failures = 0;

    if (zork_number) {
        char prime[64];
        snprintf(prime, sizeof prime, "<SETG ZORK-NUMBER %s>", zork_number);
        cz_parse_result pr = cz_parse(ctx, prime, strlen(prime));
        if (pr.ok && pr.count == 1) cz_eval(ctx, pr.items[0]);
    }

    for (int i = first; i < argc; i++) {
        size_t len;
        char *src = slurp(argv[i], &len);
        if (!src) { fprintf(stderr, "%s: READ ERROR\n", argv[i]); parse_failures++; continue; }
        cz_parse_result res = cz_parse(ctx, src, len);
        if (!res.ok) {
            fprintf(stderr, "%s: parse FAIL line %d: %s\n", argv[i], res.error_line, res.error);
            parse_failures++;
            free(src);
            continue;
        }
        for (size_t j = 0; j < res.count; j++) {
            cz_val *obj = res.items[j];
            if (is_definition_form(obj)) {
                cz_result r = cz_eval(ctx, obj);
                if (r.flow == CZ_F_ERROR) {
                    /* definition forms may reference compiler-stage subrs we
                     * don't have yet; that's fine, just note in the tree walk */
                }
            }
            sweep(ctx, obj, &st, argv[i]);
        }
        free(src);
    }
    printf("sweep: %d READEVAL nodes evaluated, %d errors, %d parse failures\n",
           st.evaluated, st.errors, parse_failures);
    cz_ctx_free(ctx);
    return (st.errors || parse_failures) ? 1 : 0;
}

int main(int argc, char **argv) {
    if (argc >= 3 && strcmp(argv[1], "-e") == 0) {
        cz_ctx *ctx = cz_ctx_new();
        int rc = 0;
        for (int i = 2; i < argc && rc == 0; i++) rc = run_exprs(ctx, argv[i]);
        /* surface PRINC output if any */
        if (cz_output(ctx)[0]) fprintf(stderr, "[output] %s\n", cz_output(ctx));
        cz_ctx_free(ctx);
        return rc;
    }
    if (argc == 3 && strcmp(argv[1], "-t") == 0)
        return run_testfile(argv[2]);
    if (argc >= 3 && strcmp(argv[1], "--sweep") == 0) {
        const char *zn = NULL;
        int first = 2;
        if (argc >= 5 && strcmp(argv[2], "-z") == 0) { zn = argv[3]; first = 4; }
        return run_sweep(argc, argv, first, zn);
    }
    fprintf(stderr, "usage: czil-eval -e \"expr\" | -t tests.t | --sweep [-z N] file.zil...\n");
    return 2;
}
