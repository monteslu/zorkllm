/* czil - C port of ZILF (Copyright 2010-2023 Tara McGrew).
 * GPL-3.0-or-later; see czil/LICENSE.
 *
 * WASM reactor entry with a deliberately tiny ABI. The host owns all I/O:
 *
 *   import  host.read_file(pathPtr, pathLen, destPtr, destCap) -> i32
 *     destCap == 0: return the file's size (or -1 if unreadable).
 *     otherwise:    copy up to destCap bytes into destPtr, return count.
 *
 *   export  czil_compile(rootPathPtr, release, serialPtr, includePtr) -> i32
 *     0 on success; nonzero leaves a message at czil_error().
 *   export  czil_output()      -> pointer to the story bytes
 *   export  czil_output_len()  -> story byte count
 *   export  czil_error()       -> NUL-terminated error string
 *   export  malloc / free      -> for staging path strings
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "zmodel.h"

__attribute__((import_module("host"), import_name("read_file")))
extern int host_read_file(const char *path, int path_len, char *dest, int dest_cap);

static char wasm_err[1024];

static char *wasm_reader(const char *path, size_t *len) {
    int plen = (int)strlen(path);
    int size = host_read_file(path, plen, NULL, 0);
    if (size < 0) return NULL;
    char *buf = malloc((size_t)size + 1);
    if (!buf) return NULL;
    int got = host_read_file(path, plen, buf, size);
    if (got != size) { free(buf); return NULL; }
    buf[size] = '\0';
    *len = (size_t)size;
    return buf;
}

__attribute__((export_name("czil_compile")))
int czil_compile(const char *root, int release, const char *serial,
                 const char *include_dir, int zversion) {
    zm_set_file_reader(wasm_reader);
    wasm_err[0] = '\0';

    cz_ctx *ctx = cz_ctx_new();
    zm_game *g = zm_new();
    zm_install(ctx, g);
    if (zversion) { g->zversion = zversion; g->version_locked = 1; }

    const char *slash = strrchr(root, '/');
    if (slash) {
        size_t n = (size_t)(slash - root);
        if (n >= sizeof(g->base_dir)) n = sizeof(g->base_dir) - 1;
        memcpy(g->base_dir, root, n);
        g->base_dir[n] = '\0';
    } else {
        strcpy(g->base_dir, ".");
    }
    if (include_dir && include_dir[0]) {
        const char *p = include_dir;
        while (*p && g->include_count < 4) {
            const char *colon = strchr(p, ':');
            size_t n = colon ? (size_t)(colon - p) : strlen(p);
            if (n >= sizeof g->include_dirs[0]) n = sizeof g->include_dirs[0] - 1;
            memcpy(g->include_dirs[g->include_count], p, n);
            g->include_dirs[g->include_count][n] = '\0';
            g->include_count++;
            p = colon ? colon + 1 : p + n;
        }
    }

    if (!zm_load_file(ctx, g, root) || !zm_finalize(ctx, g)) {
        snprintf(wasm_err, sizeof wasm_err, "%s", g->err);
        return 1;
    }
    zc_options opt = { release, serial && serial[0] ? serial : "000000", 0 };
    zt_abbrev_reset();
    zt_abbrev_collect(true);
    if (!zc_compile(ctx, g, &opt, NULL, wasm_err, sizeof wasm_err))
        return 2;
    zt_abbrev_collect(false);
    zt_abbrev_select();
    if (!zc_compile(ctx, g, &opt, NULL, wasm_err, sizeof wasm_err))
        return 2;
    return 0;
}

__attribute__((export_name("czil_output")))
const unsigned char *czil_output(void) {
    size_t len;
    return zc_output_bytes(&len);
}

__attribute__((export_name("czil_output_len")))
int czil_output_len(void) {
    size_t len;
    zc_output_bytes(&len);
    return (int)len;
}

__attribute__((export_name("czil_error")))
const char *czil_error_text(void) {
    return wasm_err;
}
