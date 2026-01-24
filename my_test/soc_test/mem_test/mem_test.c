#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#define SIZE 1024 * 1024 * 4

int main(const char *args) {
    uint8_t *p = (uint8_t *)malloc(SIZE);
    for (int i = 0; i < SIZE; i++) {
        p[i] = i % 256;
        putstr("8 ");
    }
    for (int i = 0; i < SIZE; i++) {
        if (p[i] != i % 256) {
            putstr("error\n");
            return 1;
        }
        putstr("\b\b");
    }
    uint16_t *q = (uint16_t *)malloc(SIZE);
    for (int i = 0; i < SIZE / 2; i++) {
        q[i] = i % 65536;
        putstr("16 ");
    }
    for (int i = 0; i < SIZE / 2; i++) {
        if (q[i] != i % 65536) {
            putstr("error\n");
            return 1;
        }
        putstr("\b\b\b");
    }
    uint32_t *r = (uint32_t *)malloc(SIZE);
    for (int i = 0; i < SIZE / 4; i++) {
        r[i] = i;
        putstr("32 ");
    }
    for (int i = 0; i < SIZE / 4; i++) {
        if (r[i] != i) {
            putstr("error\n");
            return 1;
        }
        putstr("\b\b\b");
    }
    uint64_t *s = (uint64_t *)malloc(SIZE);
    for (int i = 0; i < SIZE / 8; i++) {
        s[i] = i;
        putstr("64 ");
    }
    for (int i = 0; i < SIZE / 8; i++) {
        if (s[i] != i) {
            putstr("error\n");
            return 1;
        }
        putstr("\b\b\b");
    }
    putstr("mem test pass!\n");
    return 0;
}
