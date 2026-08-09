/* czil - C port of ZILF (Copyright 2010-2023 Tara McGrew).
 * GPL-3.0-or-later; see czil/LICENSE.
 * CLI: parse .zil files (or -e "expr") and summarize or dump. */
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

int main(int argc, char **argv) {
    bool dump = false;
    const char *expr = NULL;
    int first = 1;
    for (; first < argc; first++) {
        if (strcmp(argv[first], "-d") == 0) dump = true;
        else if (strcmp(argv[first], "-e") == 0 && first + 1 < argc) { expr = argv[++first]; }
        else break;
    }

    cz_ctx *ctx = cz_ctx_new();
    int failures = 0;

    if (expr) {
        cz_parse_result res = cz_parse(ctx, expr, strlen(expr));
        if (!res.ok) {
            fprintf(stderr, "error: %s (line %d)\n", res.error, res.error_line);
            return 1;
        }
        for (size_t i = 0; i < res.count; i++) {
            char *buf = NULL; size_t len = 0, cap = 0;
            cz_print(res.items[i], &buf, &len, &cap);
            printf("%s\n", buf);
            free(buf);
        }
        cz_ctx_free(ctx);
        return 0;
    }

    for (int i = first; i < argc; i++) {
        size_t len;
        char *src = slurp(argv[i], &len);
        if (!src) { printf("%-24s READ ERROR\n", argv[i]); failures++; continue; }
        cz_parse_result res = cz_parse(ctx, src, len);
        if (res.ok) {
            printf("%-40s ok  %4zu top-level objects\n", argv[i], res.count);
            if (dump) {
                for (size_t j = 0; j < res.count; j++) {
                    char *buf = NULL; size_t blen = 0, bcap = 0;
                    cz_print(res.items[j], &buf, &blen, &bcap);
                    printf("%s\n", buf);
                    free(buf);
                }
            }
        } else {
            printf("%-40s FAIL line %d: %s\n", argv[i], res.error_line, res.error);
            failures++;
        }
        free(src);
    }
    cz_ctx_free(ctx);
    return failures ? 1 : 0;
}
