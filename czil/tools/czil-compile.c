/* czil - C port of ZILF (Copyright 2010-2023 Tara McGrew).
 * GPL-3.0-or-later; see czil/LICENSE.
 *
 * Stage-5 driver: compile a game to a .z3 story file.
 *   czil-compile root.zil -o out.z3 [-r release] [-s serial]
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "zmodel.h"

static void set_base_dir(zm_game *g, const char *root) {
    const char *slash = strrchr(root, '/');
    if (slash) {
        size_t n = (size_t)(slash - root);
        if (n >= sizeof(g->base_dir)) n = sizeof(g->base_dir) - 1;
        memcpy(g->base_dir, root, n);
        g->base_dir[n] = '\0';
    } else {
        strcpy(g->base_dir, ".");
    }
}

int main(int argc, char **argv) {
    const char *root = NULL, *out = NULL, *serial = NULL;
    const char *includes[4];
    size_t ninc = 0;
    int release = 1;
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-o") == 0 && i + 1 < argc) out = argv[++i];
        else if (strcmp(argv[i], "-r") == 0 && i + 1 < argc) release = atoi(argv[++i]);
        else if (strcmp(argv[i], "-s") == 0 && i + 1 < argc) serial = argv[++i];
        else if (strcmp(argv[i], "-I") == 0 && i + 1 < argc && ninc < 4) includes[ninc++] = argv[++i];
        else root = argv[i];
    }
    if (!root || !out) {
        fprintf(stderr, "usage: czil-compile root.zil -o out.z3 [-r release] [-s serial] [-I dir]...\n");
        return 2;
    }

    cz_ctx *ctx = cz_ctx_new();
    zm_game *g = zm_new();
    zm_install(ctx, g);
    set_base_dir(g, root);
    for (size_t i = 0; i < ninc; i++) {
        snprintf(g->include_dirs[g->include_count], sizeof g->include_dirs[0], "%s", includes[i]);
        g->include_count++;
    }

    if (!zm_load_file(ctx, g, root)) {
        fprintf(stderr, "load failed: %s\n", g->err);
        return 1;
    }
    if (!zm_finalize(ctx, g)) {
        fprintf(stderr, "finalize failed: %s\n", g->err);
        return 1;
    }

    zc_options opt = { release, serial };
    char err[512];
    if (!zc_compile(ctx, g, &opt, out, err, sizeof err)) {
        fprintf(stderr, "compile failed: %s\n", err);
        return 1;
    }
    FILE *f = fopen(out, "rb");
    fseek(f, 0, SEEK_END);
    long size = ftell(f);
    fclose(f);
    printf("%s: %ld bytes\n", out, size);
    return 0;
}
