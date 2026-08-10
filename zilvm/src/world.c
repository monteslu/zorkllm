/* zilvm stage 2: lift czil's compiler-shaped model into a runtime model.
 * See world.h for why the API shape is the point. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "world.h"

static const char *atom_name(const cz_val *v) {
    return (v && v->type == CZ_ATOM) ? v->atom.name : NULL;
}

static const char *string_of(const cz_val *v) {
    return (v && v->type == CZ_STRING) ? v->str.text : NULL;
}

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

static bool is_direction(const zm_game *g, const cz_val *head) {
    const char *name = atom_name(head);
    if (!name) return false;
    for (size_t i = 0; i < g->direction_count; i++) {
        const char *d = atom_name(g->directions[i]);
        if (d && strcmp(d, name) == 0) return true;
    }
    return false;
}

/*
 * Read one exit clause. ZIL writes these five ways, and the meaning is in
 * the keywords - which is exactly what compilation throws away, leaving a
 * property whose byte length you have to interpret:
 *
 *   (NORTH TO KITCHEN)
 *   (NORTH TO KITCHEN IF DOOR IS OPEN ELSE "The door is closed.")
 *   (NORTH TO KITCHEN IF FLAG-SET)
 *   (NORTH PER SOME-ROUTINE)
 *   (NORTH SORRY "You can't go that way.")
 */
static void read_exit(const zm_prop *p, zw_exit *out) {
    memset(out, 0, sizeof *out);
    out->direction = atom_name(p->head);
    out->kind = ZW_EXIT_TO;

    for (size_t i = 0; i < p->count; i++) {
        const char *kw = atom_name(p->body[i]);
        if (kw && strcmp(kw, "TO") == 0 && i + 1 < p->count) {
            out->dest = atom_name(p->body[++i]);
        } else if (kw && strcmp(kw, "PER") == 0 && i + 1 < p->count) {
            out->kind = ZW_EXIT_PER;
            out->routine = atom_name(p->body[++i]);
        } else if (kw && strcmp(kw, "SORRY") == 0 && i + 1 < p->count) {
            out->kind = ZW_EXIT_SORRY;
            out->message = string_of(p->body[++i]);
        } else if (kw && strcmp(kw, "IF") == 0 && i + 1 < p->count) {
            out->kind = ZW_EXIT_IF;
            out->condition = atom_name(p->body[++i]);
        } else if (kw && strcmp(kw, "ELSE") == 0 && i + 1 < p->count) {
            out->message = string_of(p->body[++i]);
        } else if (kw && (strcmp(kw, "IS") == 0 || strcmp(kw, "OPEN") == 0)) {
            /* door-state sugar; the condition atom already carries it */
        } else if (!out->dest && atom_name(p->body[i])) {
            /* bare room atom: `(NORTH KITCHEN IF ...)` */
            out->dest = atom_name(p->body[i]);
        } else if (!out->message && string_of(p->body[i])) {
            out->message = string_of(p->body[i]);
            if (out->kind == ZW_EXIT_TO && !out->dest) out->kind = ZW_EXIT_SORRY;
        }
    }
}

/** Collect the atoms of a named clause (FLAGS, SYNONYM, ADJECTIVE). */
static size_t collect(const zm_object *o, const char *clause,
                      const char ***out, cz_val ***scratch) {
    size_t total = 0;
    for (size_t p = 0; p < o->prop_count; p++) {
        const char *head = atom_name(o->props[p].head);
        if (head && strcmp(head, clause) == 0) total += o->props[p].count;
    }
    if (!total) { *out = NULL; return 0; }
    const char **names = calloc(total, sizeof *names);
    size_t n = 0;
    for (size_t p = 0; p < o->prop_count; p++) {
        const char *head = atom_name(o->props[p].head);
        if (!head || strcmp(head, clause) != 0) continue;
        for (size_t i = 0; i < o->props[p].count; i++) {
            const char *a = atom_name(o->props[p].body[i]);
            if (a) names[n++] = a;
        }
    }
    (void)scratch;
    *out = names;
    return n;
}

/** First value of a single-valued clause, as an atom or string. */
static const cz_val *clause_value(const zm_object *o, const char *clause) {
    for (size_t p = 0; p < o->prop_count; p++) {
        const char *head = atom_name(o->props[p].head);
        if (head && strcmp(head, clause) == 0 && o->props[p].count > 0) {
            return o->props[p].body[0];
        }
    }
    return NULL;
}

zw_world *zw_load(const char *main_file, const char **include_dirs,
                  size_t include_count, char *err, size_t err_size) {
    cz_ctx *c = cz_ctx_new();
    cz_eval_init(c);
    zm_game *g = zm_new();
    for (size_t i = 0; i < include_count && i < 4; i++) {
        snprintf(g->include_dirs[g->include_count++], sizeof g->include_dirs[0],
                 "%s", include_dirs[i]);
    }
    set_base_dir(g, main_file);
    zm_install(c, g);

    if (!zm_load_file(c, g, main_file) || !zm_finalize(c, g)) {
        snprintf(err, err_size, "%s", g->err);
        zm_free(g);
        cz_ctx_free(c);
        return NULL;
    }

    zw_world *w = calloc(1, sizeof *w);
    w->game = g;
    w->ctx = c;
    w->zversion = g->zversion;

    w->direction_count = g->direction_count;
    w->directions = calloc(g->direction_count ? g->direction_count : 1, sizeof *w->directions);
    for (size_t i = 0; i < g->direction_count; i++) {
        w->directions[i] = atom_name(g->directions[i]);
    }

    w->object_count = g->object_count;
    w->objects = calloc(g->object_count ? g->object_count : 1, sizeof *w->objects);
    for (size_t i = 0; i < g->object_count; i++) {
        const zm_object *src = &g->objects[i];
        zw_object *dst = &w->objects[i];
        dst->name = atom_name(src->name);
        dst->desc = src->desc;
        dst->is_room = src->is_room;
        dst->parent = atom_name(src->parent);
        dst->ldesc = string_of(clause_value(src, "LDESC"));
        dst->action = atom_name(clause_value(src, "ACTION"));

        size_t exits = 0;
        for (size_t p = 0; p < src->prop_count; p++) {
            if (is_direction(g, src->props[p].head)) exits++;
        }
        if (exits) {
            dst->exits = calloc(exits, sizeof *dst->exits);
            for (size_t p = 0; p < src->prop_count; p++) {
                if (!is_direction(g, src->props[p].head)) continue;
                read_exit(&src->props[p], &dst->exits[dst->exit_count++]);
            }
        }
        dst->flag_count = collect(src, "FLAGS", &dst->flags, NULL);
        dst->synonym_count = collect(src, "SYNONYM", &dst->synonyms, NULL);
        dst->adjective_count = collect(src, "ADJECTIVE", &dst->adjectives, NULL);
    }

    w->word_count = g->word_count;
    w->words = calloc(g->word_count ? g->word_count : 1, sizeof *w->words);
    for (size_t i = 0; i < g->word_count; i++) {
        w->words[i].word = g->words[i].text;
        w->words[i].pos = (unsigned)g->words[i].pos;
    }
    return w;
}

void zw_free(zw_world *w) {
    if (!w) return;
    for (size_t i = 0; i < w->object_count; i++) {
        free(w->objects[i].exits);
        free((void *)w->objects[i].flags);
        free((void *)w->objects[i].synonyms);
        free((void *)w->objects[i].adjectives);
    }
    free(w->objects);
    free((void *)w->directions);
    free(w->words);
    zm_free(w->game);
    cz_ctx_free(w->ctx);
    free(w);
}

const zw_object *zw_find(const zw_world *w, const char *name) {
    for (size_t i = 0; i < w->object_count; i++) {
        if (w->objects[i].name && strcmp(w->objects[i].name, name) == 0) return &w->objects[i];
    }
    return NULL;
}

const zw_object *zw_find_by_desc(const zw_world *w, const char *desc) {
    for (size_t i = 0; i < w->object_count; i++) {
        if (w->objects[i].desc && strcmp(w->objects[i].desc, desc) == 0) return &w->objects[i];
    }
    return NULL;
}

static void json_string(FILE *out, const char *s) {
    if (!s) { fputs("null", out); return; }
    fputc('"', out);
    for (const unsigned char *p = (const unsigned char *)s; *p; p++) {
        switch (*p) {
        case '"':  fputs("\\\"", out); break;
        case '\\': fputs("\\\\", out); break;
        case '\n': fputs("\\n", out); break;
        case '\r': fputs("\\r", out); break;
        case '\t': fputs("\\t", out); break;
        default:
            if (*p < 0x20) fprintf(out, "\\u%04x", *p);
            else fputc(*p, out);
        }
    }
    fputc('"', out);
}

static void json_names(FILE *out, const char **names, size_t count) {
    fputc('[', out);
    for (size_t i = 0; i < count; i++) {
        if (i) fputc(',', out);
        json_string(out, names[i]);
    }
    fputc(']', out);
}

static const char *kind_name(zw_exit_kind k) {
    switch (k) {
    case ZW_EXIT_TO: return "to";
    case ZW_EXIT_SORRY: return "sorry";
    case ZW_EXIT_IF: return "conditional";
    case ZW_EXIT_PER: return "routine";
    }
    return "?";
}

void zw_write_json(const zw_world *w, FILE *out) {
    fprintf(out, "{\n  \"version\": %d,\n  \"directions\": ", w->zversion);
    json_names(out, w->directions, w->direction_count);
    fputs(",\n  \"objects\": [\n", out);
    for (size_t i = 0; i < w->object_count; i++) {
        const zw_object *o = &w->objects[i];
        if (i) fputs(",\n", out);
        fputs("    {\"name\": ", out);
        json_string(out, o->name);
        fputs(", \"desc\": ", out);
        json_string(out, o->desc);
        fprintf(out, ", \"room\": %s", o->is_room ? "true" : "false");
        if (o->parent) { fputs(", \"parent\": ", out); json_string(out, o->parent); }
        if (o->action) { fputs(", \"action\": ", out); json_string(out, o->action); }
        if (o->ldesc)  { fputs(", \"ldesc\": ", out);  json_string(out, o->ldesc); }
        if (o->synonym_count) { fputs(", \"synonyms\": ", out); json_names(out, o->synonyms, o->synonym_count); }
        if (o->adjective_count) { fputs(", \"adjectives\": ", out); json_names(out, o->adjectives, o->adjective_count); }
        if (o->flag_count) { fputs(", \"flags\": ", out); json_names(out, o->flags, o->flag_count); }
        if (o->exit_count) {
            fputs(", \"exits\": [", out);
            for (size_t e = 0; e < o->exit_count; e++) {
                const zw_exit *x = &o->exits[e];
                if (e) fputc(',', out);
                fputs("{\"dir\": ", out); json_string(out, x->direction);
                fprintf(out, ", \"kind\": \"%s\"", kind_name(x->kind));
                if (x->dest) { fputs(", \"to\": ", out); json_string(out, x->dest); }
                if (x->condition) { fputs(", \"if\": ", out); json_string(out, x->condition); }
                if (x->routine) { fputs(", \"per\": ", out); json_string(out, x->routine); }
                if (x->message) { fputs(", \"else\": ", out); json_string(out, x->message); }
                fputc('}', out);
            }
            fputc(']', out);
        }
        fputc('}', out);
    }
    fputs("\n  ]\n}\n", out);
}
