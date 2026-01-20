#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#define SIZE 64

int main(const char *args) {
    uint8_t *p = (uint8_t *)malloc(SIZE);
    for (int i = 0; i < SIZE; i++) {
        p[i] = i;
    }
    for (int i = 0; i < SIZE; i++) {
        if (p[i] != i) {
            return 1;
        }
    }
    uint16_t *q = (uint16_t *)malloc(SIZE);
    for (int i = 0; i < SIZE / 2; i++) {
        q[i] = i * 2;
    }
    for (int i = 0; i < SIZE / 2; i++) {
        if (q[i] != i * 2) {
            return 1;
        }
    }
    uint32_t *r = (uint32_t *)malloc(SIZE);
    for (int i = 0; i < SIZE / 4; i++) {
        r[i] = i * 3;
    }
    for (int i = 0; i < SIZE / 4; i++) {
        if (r[i] != i * 3) {
            return 1;
        }
    }
    uint64_t *s = (uint64_t *)malloc(SIZE);
    for (int i = 0; i < SIZE / 8; i++) {
        s[i] = i * 4;
    }
    for (int i = 0; i < SIZE / 8; i++) {
        if (s[i] != i * 4) {
            return 1;
        }
    }
    return 0;
}
