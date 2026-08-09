/* czil - C port of ZILF (Copyright 2010-2023 Tara McGrew).
 * GPL-3.0-or-later; see czil/LICENSE.
 *
 * Stage-4 driver: build the Z-model from a game's root .zil file
 * (INSERT-FILE pulls in the rest).
 *
 *   czil-build root.zil              stats summary
 *   czil-build --vocab root.zil      dictionary words (v3-encoded then
 *                                    decoded, so truncation matches the
 *                                    real dictionary), one per line
 *   czil-build --words root.zil      raw word + part-of-speech flags
 *   czil-build --objects root.zil    object names in definition order
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
    const char *mode = "--stats";
    int argi = 1;
    if (argc >= 2 && argv[1][0] == '-') { mode = argv[1]; argi = 2; }
    if (argi >= argc) {
        fprintf(stderr, "usage: czil-build [--stats|--vocab|--words|--objects] root.zil\n");
        return 2;
    }
    const char *root = argv[argi];

    cz_ctx *ctx = cz_ctx_new();
    zm_game *g = zm_new();
    zm_install(ctx, g);
    set_base_dir(g, root);

    if (!zm_load_file(ctx, g, root)) {
        fprintf(stderr, "load failed: %s\n", g->err);
        return 1;
    }
    if (!zm_finalize(ctx, g)) {
        fprintf(stderr, "finalize failed: %s\n", g->err);
        return 1;
    }

    if (strcmp(mode, "--vocab") == 0) {
        for (size_t i = 0; i < g->word_count; i++) {
            uint8_t enc[4];
            char dec[32];
            zt_encode_word(g->words[i].text, enc);
            zt_decode_word(enc, dec, sizeof dec);
            printf("%s\n", dec);
        }
    } else if (strcmp(mode, "--words") == 0) {
        for (size_t i = 0; i < g->word_count; i++) {
            zm_word *w = &g->words[i];
            printf("%-16s%s%s%s%s%s%s\n", w->text,
                   w->pos & ZM_POS_NOUN ? " noun" : "",
                   w->pos & ZM_POS_ADJ ? " adj" : "",
                   w->pos & ZM_POS_VERB ? " verb" : "",
                   w->pos & ZM_POS_PREP ? " prep" : "",
                   w->pos & ZM_POS_DIR ? " dir" : "",
                   w->pos & ZM_POS_BUZZ ? " buzz" : "");
        }
    } else if (strcmp(mode, "--objects") == 0) {
        for (size_t i = 0; i < g->object_count; i++)
            printf("%s%s\n", g->objects[i].name->atom.name,
                   g->objects[i].is_room ? " (room)" : "");
    } else if (strcmp(mode, "--heads") == 0) {
        /* survey: distinct FORM heads reachable in routine bodies after
         * expanding game macros; drives the stage-5 builtin worklist */
        zm_survey_heads(ctx, g);
    } else if (strcmp(mode, "--descs") == 0) {
        for (size_t i = 0; i < g->object_count; i++)
            printf("%s\n", g->objects[i].desc ? g->objects[i].desc : "");
    } else {
        size_t rooms = 0;
        for (size_t i = 0; i < g->object_count; i++)
            if (g->objects[i].is_room) rooms++;
        printf("zversion:   %d\n", g->zversion);
        if (g->sname) printf("sname:      %s\n", g->sname);
        printf("objects:    %zu (%zu rooms)\n", g->object_count, rooms);
        printf("routines:   %zu\n", g->routine_count);
        printf("globals:    %zu\n", g->global_count);
        printf("constants:  %zu\n", g->constant_count);
        printf("syntaxes:   %zu\n", g->syntax_count);
        printf("directions: %zu\n", g->direction_count);
        printf("properties: %zu\n", g->propname_count);
        printf("flags:      %zu\n", g->flag_count);
        printf("tables:     %zu\n", g->table_count);
        printf("buzzwords:  %zu\n", g->buzz_count);
        printf("synonyms:   %zu\n", g->synonym_count);
        printf("propdefs:   %zu\n", g->propdef_count);
        printf("vocabulary: %zu words\n", g->word_count);
    }

    zm_free(g);
    cz_ctx_free(ctx);
    return 0;
}
