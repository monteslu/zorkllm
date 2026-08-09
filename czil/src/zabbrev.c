/* czil - C port of ZILF (Copyright 2010-2023 Tara McGrew).
 * GPL-3.0-or-later; see czil/LICENSE.
 *
 * Abbreviation selection: a deterministic greedy pass over the corpus of
 * every string the compiler encodes. One counting sweep finds candidate
 * substrings; candidates are ranked by z-chars saved and accepted while
 * their real (non-overlapping, unclaimed) savings stay positive.
 */
#include <stdlib.h>
#include <string.h>
#include "zmodel.h"

/* internals shared with ztext.c */
void zt_abbrev_install(const char *text, size_t len);
size_t zt_corpus_count(void);
const char *zt_corpus_get(size_t i);

#define MINLEN 2
#define MAXLEN 30
#define MAXCAND 20000

typedef struct {
    const char *ptr;
    uint16_t len;
    uint32_t count;
    int32_t score;
} cand;

static uint32_t hash_sub(const char *s, size_t len) {
    uint32_t h = 2166136261u;
    for (size_t i = 0; i < len; i++) {
        h ^= (unsigned char)s[i];
        h *= 16777619u;
    }
    return h;
}

/* z-chars saved per replaced occurrence (an abbreviation reference is 2) */
static int32_t per_occurrence(size_t zc) { return (int32_t)zc - 2; }

/* z-chars the table copy itself costs (padded to full words) */
static int32_t storage_cost(size_t zc) { return (int32_t)((zc + 2) / 3) * 3; }

static int cand_cmp(const void *a, const void *b) {
    const cand *x = a, *y = b;
    if (x->score != y->score) return y->score - x->score;
    if (x->len != y->len) return (int)y->len - (int)x->len;
    return memcmp(x->ptr, y->ptr, x->len < y->len ? x->len : y->len);
}

size_t zt_abbrev_select(void) {
    size_t ncorpus = zt_corpus_count();
    if (ncorpus == 0) return 0;

    /* counting sweep: every substring of length 2..20 */
    size_t nslots = 1;
    size_t total = 0;
    for (size_t i = 0; i < ncorpus; i++) total += strlen(zt_corpus_get(i));
    while (nslots < total * (MAXLEN - MINLEN + 1) * 2 && nslots < (1u << 22)) nslots <<= 1;
    typedef struct { const char *ptr; uint32_t len, count; } slot;
    slot *slots = calloc(nslots, sizeof(slot));
    if (!slots) abort();

    for (size_t i = 0; i < ncorpus; i++) {
        const char *s = zt_corpus_get(i);
        size_t slen = strlen(s);
        for (size_t off = 0; off < slen; off++) {
            for (size_t len = MINLEN; len <= MAXLEN && off + len <= slen; len++) {
                uint32_t h = hash_sub(s + off, len) & (nslots - 1);
                for (;;) {
                    if (!slots[h].ptr) {
                        slots[h].ptr = s + off;
                        slots[h].len = (uint32_t)len;
                        slots[h].count = 1;
                        break;
                    }
                    if (slots[h].len == len && memcmp(slots[h].ptr, s + off, len) == 0) {
                        slots[h].count++;
                        break;
                    }
                    h = (h + 1) & (nslots - 1);
                }
            }
        }
    }

    /* rank the plausible ones */
    cand *cands = malloc(MAXCAND * sizeof(cand));
    if (!cands) abort();
    size_t ncand = 0;
    for (size_t i = 0; i < nslots; i++) {
        if (!slots[i].ptr || slots[i].count < 2) continue;
        size_t zc = zt_zchar_cost(slots[i].ptr, slots[i].len);
        int32_t per = per_occurrence(zc);
        if (per <= 0) continue;
        int32_t score = (int32_t)slots[i].count * per - storage_cost(zc);
        if (score <= 0) continue;
        cand c = { slots[i].ptr, (uint16_t)slots[i].len, slots[i].count, score };
        if (ncand < MAXCAND) {
            cands[ncand++] = c;
        } else {
            /* replace the current worst if this one beats it */
            size_t worst = 0;
            for (size_t k = 1; k < MAXCAND; k++)
                if (cands[k].score < cands[worst].score) worst = k;
            if (c.score > cands[worst].score) cands[worst] = c;
        }
    }
    qsort(cands, ncand, sizeof(cand), cand_cmp);

    /* greedy accept with claim tracking */
    uint8_t **claimed = malloc(ncorpus * sizeof(uint8_t *));
    if (!claimed) abort();
    for (size_t i = 0; i < ncorpus; i++)
        claimed[i] = calloc(strlen(zt_corpus_get(i)) + 1, 1);

    size_t chosen = 0;
    while (chosen < 96 && ncand > 0) {
        /* lazy greedy: refresh the stale top candidate's score against the
         * current claim state until it genuinely leads, then accept it */
        const char *sub;
        size_t len, zc;
        int32_t per;
        for (;;) {
            if (ncand == 0) goto done;
            cand *top = &cands[0];
            sub = top->ptr;
            len = top->len;
            zc = zt_zchar_cost(sub, len);
            per = per_occurrence(zc);
            uint32_t occ = 0;
            for (size_t i = 0; i < ncorpus; i++) {
                const char *s = zt_corpus_get(i);
                size_t slen = strlen(s);
                for (size_t off = 0; off + len <= slen; ) {
                    if (!claimed[i][off] && memcmp(s + off, sub, len) == 0) {
                        bool clean = true;
                        for (size_t k = 0; k < len; k++)
                            if (claimed[i][off + k]) { clean = false; break; }
                        if (clean) { occ++; off += len; continue; }
                    }
                    off++;
                }
            }
            int32_t fresh = (int32_t)occ * per - storage_cost(zc);
            if (fresh <= 0) {
                /* dead candidate: drop it */
                memmove(cands, cands + 1, (ncand - 1) * sizeof(cand));
                ncand--;
                continue;
            }
            if (top->score != fresh) {
                /* re-place it by its fresh score and try again */
                top->score = fresh;
                size_t pos = 1;
                while (pos < ncand && cands[pos].score > fresh) pos++;
                cand saved = cands[0];
                memmove(cands, cands + 1, (pos - 1) * sizeof(cand));
                cands[pos - 1] = saved;
                if (pos == 1) break;   /* still the leader with fresh score */
                continue;
            }
            break;
        }
        /* accept the leader: drop it from the list */
        memmove(cands, cands + 1, (ncand - 1) * sizeof(cand));
        ncand--;

        /* claim the spans and accept */
        for (size_t i = 0; i < ncorpus; i++) {
            const char *s = zt_corpus_get(i);
            size_t slen = strlen(s);
            for (size_t off = 0; off + len <= slen; ) {
                if (!claimed[i][off] && memcmp(s + off, sub, len) == 0) {
                    bool clean = true;
                    for (size_t k = 0; k < len; k++)
                        if (claimed[i][off + k]) { clean = false; break; }
                    if (clean) {
                        memset(claimed[i] + off, 1, len);
                        off += len;
                        continue;
                    }
                }
                off++;
            }
        }
        char *copy = malloc(len + 1);
        if (!copy) abort();
        memcpy(copy, sub, len);
        copy[len] = '\0';
        zt_abbrev_install(copy, len);
        chosen++;
    }

done:
    for (size_t i = 0; i < ncorpus; i++) free(claimed[i]);
    free(claimed);
    free(cands);
    free(slots);
    return chosen;
}
