/*
 * zilvm stage 2: the queryable world model.
 *
 * czil's zm_game is a compiler's view - every clause kept raw, in source
 * order, waiting to be numbered. This is the runtime's view: rooms,
 * objects, exits and vocabulary resolved into things you can ask
 * questions about, with every name intact.
 *
 * The API is the product, not a side effect. The app holds the world and
 * briefs the model per question, so "what is in this room", "which ways
 * lead out of here", "what does this verb do" have to be cheap lookups.
 * Recovering those from a compiled story file cost four wrong attempts in
 * one session; here they are fields.
 */
#ifndef ZILVM_WORLD_H
#define ZILVM_WORLD_H

#include <stdbool.h>
#include <stddef.h>
#include "czil.h"
#include "zmodel.h"

/* How a room's exit behaves, kept as meaning rather than byte layout. */
typedef enum {
    ZW_EXIT_TO,       /* unconditional: goes to `dest` */
    ZW_EXIT_SORRY,    /* refuses, printing `message` */
    ZW_EXIT_IF,       /* `dest` if `condition` is true, else `message` */
    ZW_EXIT_PER,      /* destination computed by routine `routine` */
} zw_exit_kind;

typedef struct {
    const char *direction;   /* "NORTH" - the name, never a property number */
    zw_exit_kind kind;
    const char *dest;        /* destination room, or NULL */
    const char *condition;   /* global or door object gating it, or NULL */
    const char *routine;     /* PER routine name, or NULL */
    const char *message;     /* refusal text, or NULL */
} zw_exit;

typedef struct {
    const char *name;        /* the ZIL atom: "LIVING-ROOM" */
    const char *desc;        /* DESC string: "Living Room" */
    const char *ldesc;       /* long description, or NULL */
    const char *action;      /* ACTION routine name, or NULL */
    const char *parent;      /* containing object/room name, or NULL */
    bool is_room;
    zw_exit *exits;          /* only for rooms */
    size_t exit_count;
    const char **flags;      /* FLAGS atoms, by name */
    size_t flag_count;
    const char **synonyms;   /* nouns the parser accepts */
    size_t synonym_count;
    const char **adjectives;
    size_t adjective_count;
} zw_object;

typedef struct {
    const char *word;
    unsigned pos;            /* ZM_POS_* bits */
} zw_word;

typedef struct zw_world {
    int zversion;
    const char **directions; /* declaration order fixes exit semantics */
    size_t direction_count;
    zw_object *objects;
    size_t object_count;
    zw_word *words;
    size_t word_count;
    zm_game *game;           /* the underlying model, for anything not lifted */
    cz_ctx *ctx;
} zw_world;

/* Load a game from its main .zil file. Returns NULL on error, with the
 * message in `err`. Include dirs resolve INSERT-FILE, as czil's CLI does. */
zw_world *zw_load(const char *main_file, const char **include_dirs,
                  size_t include_count, char *err, size_t err_size);
void zw_free(zw_world *w);

/* Lookups the LLM layer needs. All O(n) over a few hundred objects, which
 * is nothing next to a model call. */
const zw_object *zw_find(const zw_world *w, const char *name);
const zw_object *zw_find_by_desc(const zw_world *w, const char *desc);

/* Write the world as JSON, so a JS host can hold the same structure the
 * C runtime does without a second parser. */
void zw_write_json(const zw_world *w, FILE *out);

#endif
