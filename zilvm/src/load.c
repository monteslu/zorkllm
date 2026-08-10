/*
 * zilvm stage 1: load a game from ZIL source, keeping the names.
 *
 * This links czil's front end (reader, evaluator, Z-model) and stops
 * exactly where the compiler would begin numbering things. The point is
 * what survives: `<DIRECTIONS NORTH EAST WEST SOUTH ...>` stays a list of
 * named atoms instead of becoming property numbers 31, 30, 29, 28, and a
 * room's ACTION stays a routine name instead of an address.
 *
 * Every question that cost time reading a compiled story file - which
 * property is north, what does this room's action routine do, is this
 * M-LOOK override replacing the LDESC - is a field lookup here.
 *
 * Build (from the repo root):
 *   make -C czil libczilfront.a
 *   cc -std=c11 -Iczil/include zilvm/src/load.c czil/libczilfront.a -o zilvm/zilvm-load
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "czil.h"
#include "zmodel.h"

/* INSERT-FILE resolves relative to the main file's directory; the
 * loader must set that, exactly as czil's own CLI does. */
static void set_base_dir(zm_game *g, const char *root) {
    const char *slash = strrchr(root, '/');
    if (slash) {
        size_t n = (size_t)(slash - root);
        if (n >= sizeof g->base_dir) n = sizeof g->base_dir - 1;
        memcpy(g->base_dir, root, n);
        g->base_dir[n] = '\0';
    } else {
        snprintf(g->base_dir, sizeof g->base_dir, ".");
    }
}

static const char *atom_name(const cz_val *v) {
    return (v && v->type == CZ_ATOM) ? v->atom.name : NULL;
}

/* A property whose head is a declared direction is an exit. The compiler
 * turns these into numbered properties and forgets which was which; here
 * the head keeps its name. */
static bool is_direction(const zm_game *g, const cz_val *head) {
    const char *name = atom_name(head);
    if (!name) return false;
    for (size_t i = 0; i < g->direction_count; i++) {
        const char *d = atom_name(g->directions[i]);
        if (d && strcmp(d, name) == 0) return true;
    }
    return false;
}

int main(int argc, char **argv) {
    const char *main_file = NULL;
    const char *includes[4];
    size_t include_count = 0;
    bool list_rooms = false;

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-I") == 0 && i + 1 < argc) {
            if (include_count < 4) includes[include_count++] = argv[++i];
            else i++;
        } else if (strcmp(argv[i], "--rooms") == 0) {
            list_rooms = true;
        } else {
            main_file = argv[i];
        }
    }
    if (!main_file) {
        fprintf(stderr, "usage: zilvm-load [-I dir]... [--rooms] <main.zil>\n");
        return 2;
    }

    cz_ctx *c = cz_ctx_new();
    cz_eval_init(c);
    zm_game *g = zm_new();
    for (size_t i = 0; i < include_count; i++) {
        snprintf(g->include_dirs[g->include_count++], sizeof g->include_dirs[0],
                 "%s", includes[i]);
    }
    set_base_dir(g, main_file);
    zm_install(c, g);

    if (!zm_load_file(c, g, main_file)) {
        fprintf(stderr, "load failed: %s\n", g->err);
        return 1;
    }
    if (!zm_finalize(c, g)) {
        fprintf(stderr, "finalize failed: %s\n", g->err);
        return 1;
    }

    printf("%s\n", main_file);
    printf("  version    %d\n", g->zversion);
    printf("  objects    %zu\n", g->object_count);
    printf("  routines   %zu\n", g->routine_count);
    printf("  syntaxes   %zu\n", g->syntax_count);
    printf("  globals    %zu\n", g->global_count);
    printf("  vocabulary %zu\n", g->word_count);

    /* The metadata the compiler discards, printed to prove it is here. */
    printf("  directions ");
    for (size_t i = 0; i < g->direction_count; i++) {
        const char *d = atom_name(g->directions[i]);
        printf("%s%s", i ? " " : "", d ? d : "?");
    }
    printf("\n");

    if (list_rooms) {
        size_t rooms = 0;
        for (size_t i = 0; i < g->object_count; i++) {
            zm_object *o = &g->objects[i];
            bool has_exit = false;
            for (size_t p = 0; p < o->prop_count; p++) {
                if (is_direction(g, o->props[p].head)) { has_exit = true; break; }
            }
            if (!has_exit) continue;
            rooms++;
            printf("  room %-24s exits:", atom_name(o->name) ? atom_name(o->name) : "?");
            for (size_t p = 0; p < o->prop_count; p++) {
                if (!is_direction(g, o->props[p].head)) continue;
                printf(" %s", atom_name(o->props[p].head));
            }
            printf("\n");
        }
        printf("  rooms with exits: %zu\n", rooms);
    }

    zm_free(g);
    cz_ctx_free(c);
    return 0;
}
