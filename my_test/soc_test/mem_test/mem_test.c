#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#define SIZE 1024 * 1024 * 4

extern Area heap;

int main(const char *args) {
    uint8_t *p8 = (uint8_t *)heap.start;

    for (int i = 0; &p8[i] < (uint8_t *)heap.end; p8++, i++) {
        p8[i] = i % 256;
        if(p8[i] != i % 256) {
            putstr("error\n");
            return 1;
        }
    }

    putstr("8 ");

    uint16_t *p16 = (uint16_t *)heap.start;

    for (int i = 0; &p16[i] < (uint16_t *)heap.end; p16++, i++) {
        p16[i] = i % 65536;
        if(p16[i] != i % 65536) {
            putstr("error\n");
            return 1;
        }
    }

    putstr("16 ");

    uint32_t *p32 = (uint32_t *)heap.start;
    for (int i = 0; &p32[i] < (uint32_t *)heap.end; p32++, i++) {
        p32[i] = i;
        if(p32[i] != i) {
            putstr("error\n");
            return 1;
        }
    }

    putstr("32 ");

    uint64_t *p64 = (uint64_t *)heap.start;
    for (int i = 0; &p64[i] < (uint64_t *)heap.end; p64++, i++) {
        p64[i] = i;
        if(p64[i] != i) {
            putstr("error\n");
            return 1;
        }
    }

    putstr("64 ");

    putstr("mem test pass!\n");
    return 0;
}
