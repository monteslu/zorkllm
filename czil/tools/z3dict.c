/* czil - C port of ZILF (Copyright 2010-2023 Tara McGrew).
 * GPL-3.0-or-later; see czil/LICENSE.
 *
 * Oracle-side extractor for the stage-4 differ: read a shipped v3 story
 * file and print model facts czil-build can be compared against.
 *
 *   z3dict file.z3            dictionary words, one per line (file order)
 *   z3dict file.z3 objects    object short names, one per line (object order)
 *   z3dict file.z3 counts     object count
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "zmodel.h"

static const uint8_t *M;
static size_t MSIZE;

static uint16_t rw(size_t addr) {
    if (addr + 1 >= MSIZE) return 0;
    return (uint16_t)((M[addr] << 8) | M[addr + 1]);
}

/* full v3 z-string decode including abbreviations */
static void decode_string(size_t addr, char *out, size_t cap, int allow_abbrev);

static void decode_abbrev(int z, int next, char *out, size_t cap) {
    size_t table = rw(0x18);
    size_t idx = (size_t)(32 * (z - 1) + next);
    size_t str_addr = (size_t)rw(table + idx * 2) * 2;
    decode_string(str_addr, out, cap, 0);
}

static const char A2T[] = "\x00\n0123456789.,!?_#'\"/\\-:()";

/* unpack the z-chars of a string, then walk them linearly; shifts,
 * abbreviations, and 10-bit literals never straddle anything that way */
static void decode_string(size_t addr, char *out, size_t cap, int allow_abbrev) {
    uint8_t zc[1024];
    size_t n = 0;
    for (;;) {
        uint16_t w = rw(addr);
        addr += 2;
        if (n + 3 <= sizeof zc) {
            zc[n++] = (uint8_t)((w >> 10) & 0x1f);
            zc[n++] = (uint8_t)((w >> 5) & 0x1f);
            zc[n++] = (uint8_t)(w & 0x1f);
        }
        if (w & 0x8000) break;
    }
    size_t len = strlen(out);
    int shift = 0;
    for (size_t i = 0; i < n; i++) {
        uint8_t z = zc[i];
        if (z == 0) {
            if (len + 1 < cap) out[len++] = ' ';
            shift = 0;
        } else if (z <= 3) {
            if (allow_abbrev && i + 1 < n) {
                out[len] = '\0';
                decode_abbrev(z, zc[++i], out, cap);
                len = strlen(out);
            }
            shift = 0;
        } else if (z == 4) {
            shift = 1;
        } else if (z == 5) {
            shift = 2;
        } else if (shift == 2 && z == 6) {
            if (i + 2 < n) {
                if (len + 1 < cap) out[len++] = (char)((zc[i + 1] << 5) | zc[i + 2]);
                i += 2;
            }
            shift = 0;
        } else {
            char ch;
            if (shift == 0) ch = (char)('a' + z - 6);
            else if (shift == 1) ch = (char)('A' + z - 6);
            else ch = A2T[z - 6] ? A2T[z - 6] : '?';
            if (len + 1 < cap) out[len++] = ch;
            shift = 0;
        }
    }
    out[len < cap ? len : cap - 1] = '\0';
}

static size_t object_count(size_t objtab) {
    /* objects run until the lowest property table address */
    size_t first = objtab + 62;            /* skip 31 default words */
    size_t min_props = MSIZE;
    size_t count = 0;
    size_t p = first;
    while (p + 9 <= min_props) {
        size_t props = (size_t)rw(p + 7);
        if (props > 0 && props < min_props && props > first) min_props = props;
        p += 9;
        count++;
        if (first + count * 9 >= min_props) break;
    }
    return count;
}

int main(int argc, char **argv) {
    if (argc < 2 || argc > 3) {
        fprintf(stderr, "usage: z3dict file.z3 [dict|objects|counts]\n");
        return 2;
    }
    const char *mode = argc == 3 ? argv[2] : "dict";

    FILE *f = fopen(argv[1], "rb");
    if (!f) { fprintf(stderr, "cannot open %s\n", argv[1]); return 1; }
    fseek(f, 0, SEEK_END);
    long size = ftell(f);
    fseek(f, 0, SEEK_SET);
    uint8_t *m = malloc(size);
    if (!m || fread(m, 1, size, f) != (size_t)size) { fprintf(stderr, "read error\n"); return 1; }
    fclose(f);
    M = m;
    MSIZE = (size_t)size;

    if (size < 64 || m[0] != 3) {
        fprintf(stderr, "%s: not a v3 story file\n", argv[1]);
        return 1;
    }

    if (strcmp(mode, "dict") == 0) {
        size_t dict = rw(0x08);
        size_t p = dict;
        uint8_t nseps = m[p++];
        p += nseps;
        uint8_t entry_len = m[p++];
        size_t count = rw(p);
        p += 2;
        if (entry_len < 4 || p + count * entry_len > (size_t)size) {
            fprintf(stderr, "bad dictionary layout\n");
            return 1;
        }
        for (size_t i = 0; i < count; i++) {
            char word[32];
            zt_decode_word(m + p + i * entry_len, word, sizeof word);
            printf("%s\n", word);
        }
    } else if (strcmp(mode, "dictdata") == 0) {
        size_t dict = rw(0x08);
        size_t p = dict;
        uint8_t nseps = m[p++];
        p += nseps;
        uint8_t entry_len = m[p++];
        size_t count = rw(p);
        p += 2;
        for (size_t i = 0; i < count; i++) {
            char word[32];
            zt_decode_word(m + p + i * entry_len, word, sizeof word);
            printf("%-8s", word);
            for (int k = 4; k < entry_len; k++)
                printf(" %02x", m[p + i * entry_len + k]);
            printf("\n");
        }
    } else if (strcmp(mode, "objects") == 0 || strcmp(mode, "counts") == 0) {
        size_t objtab = rw(0x0a);
        size_t count = object_count(objtab);
        if (strcmp(mode, "counts") == 0) {
            printf("%zu\n", count);
        } else {
            for (size_t i = 0; i < count; i++) {
                size_t entry = objtab + 62 + i * 9;
                size_t props = rw(entry + 7);
                uint8_t textlen = m[props];
                char name[256] = "";
                if (textlen > 0) decode_string(props + 1, name, sizeof name, 1);
                printf("%s\n", name);
            }
        }
    } else {
        fprintf(stderr, "unknown mode %s\n", mode);
        return 2;
    }
    free(m);
    return 0;
}
