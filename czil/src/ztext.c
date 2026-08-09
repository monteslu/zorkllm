/* czil - C port of ZILF (Copyright 2010-2023 Tara McGrew).
 * GPL-3.0-or-later; see czil/LICENSE.
 *
 * v3 dictionary-word Z-text codec: 6 z-chars packed into 4 bytes.
 * Alphabets per the Z-machine standard (v3):
 *   A0 a-z, A1 A-Z, A2 [esc]\n0123456789.,!?_#'"/\-:()
 * Z-chars 4/5 are single-shifts in dictionary words; 6 in A2 escapes to a
 * 10-bit ZSCII literal.
 */
#include <stdlib.h>
#include <string.h>
#include "zmodel.h"

static const char A2[] = "\x00\n0123456789.,!?_#'\"/\\-:()";  /* index 0 = escape slot */

/* returns z-chars (with shifts) for one ascii char into zc[], count returned */
static size_t char_to_zchars(char ch, uint8_t zc[4]) {
    if (ch >= 'A' && ch <= 'Z') ch = (char)(ch + 32);   /* dict words are lowercased */
    if (ch >= 'a' && ch <= 'z') {
        zc[0] = (uint8_t)(ch - 'a' + 6);
        return 1;
    }
    for (size_t i = 1; i < sizeof(A2) - 1; i++) {
        if (A2[i] == ch) {
            zc[0] = 5;
            zc[1] = (uint8_t)(i + 6);
            return 2;
        }
    }
    /* 10-bit ZSCII escape */
    zc[0] = 5;
    zc[1] = 6;
    zc[2] = (uint8_t)(((unsigned char)ch >> 5) & 0x1f);
    zc[3] = (uint8_t)((unsigned char)ch & 0x1f);
    return 4;
}

void zt_encode_word(const char *text, uint8_t out[4]) {
    uint8_t zc[6];
    size_t n = 0;
    for (const char *p = text; *p && n < 6; p++) {
        uint8_t tmp[4];
        size_t k = char_to_zchars(*p, tmp);
        for (size_t i = 0; i < k && n < 6; i++) zc[n++] = tmp[i];
    }
    while (n < 6) zc[n++] = 5;   /* pad */
    uint16_t w1 = (uint16_t)((zc[0] << 10) | (zc[1] << 5) | zc[2]);
    uint16_t w2 = (uint16_t)((zc[3] << 10) | (zc[4] << 5) | zc[5]);
    w2 |= 0x8000;                /* end-of-string marker */
    out[0] = (uint8_t)(w1 >> 8);
    out[1] = (uint8_t)(w1 & 0xff);
    out[2] = (uint8_t)(w2 >> 8);
    out[3] = (uint8_t)(w2 & 0xff);
}

/* Encode an arbitrary-length string as v3 z-text (no abbreviations):
 * collect all z-chars, pad to a multiple of 3 with 5s, pack 3 per word,
 * set the end bit on the last word. Words go to the callback in order. */
size_t zt_encode_string(const char *text, size_t len,
                        void (*emit_word)(void *ud, uint16_t w), void *ud) {
    uint8_t *zc = malloc(len * 4 + 3);
    if (!zc) abort();
    size_t n = 0;
    for (size_t i = 0; i < len; i++) {
        char ch = text[i];
        if (ch == ' ') zc[n++] = 0;
        else if (ch == '\n') { zc[n++] = 5; zc[n++] = 7; }
        else if (ch >= 'a' && ch <= 'z') zc[n++] = (uint8_t)(ch - 'a' + 6);
        else if (ch >= 'A' && ch <= 'Z') { zc[n++] = 4; zc[n++] = (uint8_t)(ch - 'A' + 6); }
        else {
            bool found = false;
            for (size_t j = 2; j < sizeof(A2) - 1; j++) {
                if (A2[j] == ch) { zc[n++] = 5; zc[n++] = (uint8_t)(j + 6); found = true; break; }
            }
            if (!found) {
                zc[n++] = 5; zc[n++] = 6;
                zc[n++] = (uint8_t)(((unsigned char)ch >> 5) & 0x1f);
                zc[n++] = (uint8_t)((unsigned char)ch & 0x1f);
            }
        }
    }
    if (n == 0) zc[n++] = 5;      /* empty string still needs one word */
    while (n % 3) zc[n++] = 5;
    size_t words = n / 3;
    for (size_t i = 0; i < words; i++) {
        uint16_t w = (uint16_t)((zc[i * 3] << 10) | (zc[i * 3 + 1] << 5) | zc[i * 3 + 2]);
        if (i == words - 1) w |= 0x8000;
        emit_word(ud, w);
    }
    free(zc);
    return words;
}

size_t zt_decode_word(const uint8_t in[4], char *out, size_t cap) {
    uint16_t w1 = (uint16_t)((in[0] << 8) | in[1]);
    uint16_t w2 = (uint16_t)((in[2] << 8) | in[3]);
    uint8_t zc[6] = {
        (uint8_t)((w1 >> 10) & 0x1f), (uint8_t)((w1 >> 5) & 0x1f), (uint8_t)(w1 & 0x1f),
        (uint8_t)((w2 >> 10) & 0x1f), (uint8_t)((w2 >> 5) & 0x1f), (uint8_t)(w2 & 0x1f),
    };
    size_t len = 0;
    int shift = 0;   /* 0 = A0, 1 = A1, 2 = A2 (single-shot) */
    for (size_t i = 0; i < 6; i++) {
        uint8_t z = zc[i];
        if (z == 0) {
            if (len + 1 < cap) out[len++] = ' ';
            shift = 0;
        } else if (z <= 3) {
            /* abbreviation: never valid inside a dictionary word */
            shift = 0;
        } else if (z == 4) {
            shift = 1;
        } else if (z == 5) {
            shift = 2;
        } else if (shift == 2 && z == 6) {
            /* 10-bit ZSCII literal from the next two z-chars */
            if (i + 2 < 6) {
                int code = (zc[i + 1] << 5) | zc[i + 2];
                if (len + 1 < cap) out[len++] = (char)code;
                i += 2;
            } else {
                i = 6;
            }
            shift = 0;
        } else {
            char ch;
            if (shift == 0) ch = (char)('a' + z - 6);
            else if (shift == 1) ch = (char)('A' + z - 6);
            else ch = A2[z - 6] ? A2[z - 6] : '?';
            if (len + 1 < cap) out[len++] = ch;
            shift = 0;
        }
    }
    if (cap) out[len < cap ? len : cap - 1] = '\0';
    return len;
}
