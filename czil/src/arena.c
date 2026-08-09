/* czil - C port of ZILF (Copyright 2010-2023 Tara McGrew).
 * GPL-3.0-or-later; see czil/LICENSE. */
#include <stdlib.h>
#include <string.h>
#include "czil.h"

#define CHUNK_SIZE (256 * 1024)

typedef struct chunk {
    struct chunk *next;
    size_t used;
    size_t size;
    unsigned char data[];
} chunk;

struct cz_arena {
    chunk *head;
};

static chunk *chunk_new(size_t min) {
    size_t size = min > CHUNK_SIZE ? min : CHUNK_SIZE;
    chunk *ch = malloc(sizeof(chunk) + size);
    if (!ch) abort();
    ch->next = NULL;
    ch->used = 0;
    ch->size = size;
    return ch;
}

cz_arena *cz_arena_new(void) {
    cz_arena *a = malloc(sizeof(*a));
    if (!a) abort();
    a->head = chunk_new(0);
    return a;
}

void *cz_alloc(cz_arena *a, size_t size) {
    size = (size + 15) & ~(size_t)15;
    if (a->head->used + size > a->head->size) {
        chunk *ch = chunk_new(size);
        ch->next = a->head;
        a->head = ch;
    }
    void *p = a->head->data + a->head->used;
    a->head->used += size;
    return p;
}

char *cz_strdup(cz_arena *a, const char *s, size_t len) {
    char *p = cz_alloc(a, len + 1);
    memcpy(p, s, len);
    p[len] = '\0';
    return p;
}

void cz_arena_free(cz_arena *a) {
    chunk *ch = a->head;
    while (ch) {
        chunk *next = ch->next;
        free(ch);
        ch = next;
    }
    free(a);
}
