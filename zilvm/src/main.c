/* zilvm CLI: load a game from ZIL source and answer questions about it.
 * The queries here are the ones the app must answer to brief an LLM. */
#include <stdio.h>
#include <string.h>
#include "world.h"

int main(int argc, char **argv) {
    const char *main_file = NULL, *incs[4]; size_t nincs = 0;
    const char *query = NULL, *arg = NULL;
    bool json = false;

    for (int i = 1; i < argc; i++) {
        if (!strcmp(argv[i], "-I") && i + 1 < argc) { if (nincs < 4) incs[nincs++] = argv[++i]; else i++; }
        else if (!strcmp(argv[i], "--json")) json = true;
        else if (!strcmp(argv[i], "--room") && i + 1 < argc) { query = "room"; arg = argv[++i]; }
        else if (!strcmp(argv[i], "--summary")) query = "summary";
        else main_file = argv[i];
    }
    if (!main_file) { fprintf(stderr, "usage: zilvm [-I dir]... [--json|--summary|--room NAME] <main.zil>\n"); return 2; }

    char err[1024];
    zw_world *w = zw_load(main_file, incs, nincs, err, sizeof err);
    if (!w) { fprintf(stderr, "%s\n", err); return 1; }

    if (json) { zw_write_json(w, stdout); zw_free(w); return 0; }

    if (query && !strcmp(query, "room")) {
        const zw_object *o = zw_find(w, arg);
        if (!o) o = zw_find_by_desc(w, arg);
        if (!o) { fprintf(stderr, "no such object: %s\n", arg); zw_free(w); return 1; }
        printf("%s (%s)\n", o->name, o->desc ? o->desc : "no desc");
        if (o->action) printf("  action  %s\n", o->action);
        for (size_t e = 0; e < o->exit_count; e++) {
            const zw_exit *x = &o->exits[e];
            printf("  exit    %-6s", x->direction);
            switch (x->kind) {
            case ZW_EXIT_TO: printf(" -> %s\n", x->dest); break;
            case ZW_EXIT_PER: printf(" -> computed by %s\n", x->routine); break;
            case ZW_EXIT_IF: printf(" -> %s if %s\n", x->dest, x->condition); break;
            case ZW_EXIT_SORRY: printf(" blocked: %s\n", x->message ? x->message : ""); break;
            }
        }
        zw_free(w); return 0;
    }

    size_t rooms = 0, with_exits = 0, exits = 0;
    for (size_t i = 0; i < w->object_count; i++) {
        if (w->objects[i].is_room) rooms++;
        if (w->objects[i].exit_count) { with_exits++; exits += w->objects[i].exit_count; }
    }
    printf("%s\n  version %d | objects %zu (%zu rooms) | exits %zu across %zu rooms | vocab %zu\n",
           main_file, w->zversion, w->object_count, rooms, exits, with_exits, w->word_count);
    printf("  directions:");
    for (size_t i = 0; i < w->direction_count; i++) printf(" %s", w->directions[i]);
    printf("\n");
    zw_free(w);
    return 0;
}
