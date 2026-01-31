#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#define BASE 0xa0000000
#define SIZE 0x8000000

int main(const char *args) {

    putstr("mem test start!\n");

    volatile uint8_t *p8 = (volatile uint8_t *)BASE;
    for (int i = 0; &p8[i] < (volatile uint8_t *)(BASE + SIZE); i++) {
        p8[i] = i % 256;
        if(i % 1000 == 0) printf("%x(%d) ", i/1000, 8);
    }
    for(int i = 0; &p8[i] < (volatile uint8_t *)(BASE + SIZE); i++) {
        if(p8[i] != i % 256) {
            putstr("error\n");
            return 1;
        }
    }

    volatile uint16_t *p16 = (volatile uint16_t *)BASE;
    for (int i = 0; &p16[i] < (volatile uint16_t *)(BASE + SIZE); i++) {
        p16[i] = i % 65536;
        if(i % 1000 == 0) printf("%x(%d) ", i/1000, 16);
    }
    for(int i = 0; &p16[i] < (volatile uint16_t *)(BASE + SIZE); i++) {
        if(p16[i] != i % 65536) {
            putstr("error\n");
            return 1;
        }
    }

    volatile uint32_t *p32 = (volatile uint32_t *)BASE;
    for (int i = 0; &p32[i] < (volatile uint32_t *)(BASE + SIZE); i++) {
        p32[i] = i;
        if(i % 1000 == 0) printf("%x(%d) ", i/1000, 32);
    }
    for(int i = 0; &p32[i] < (volatile uint32_t *)(BASE + SIZE); i++) {
        if(p32[i] != i) {
            putstr("error\n");
            return 1;
        }
    }

    volatile uint64_t *p64 = (volatile uint64_t *)BASE;
    for (int i = 0; &p64[i] < (volatile uint64_t *)(BASE + SIZE); i++) {
        p64[i] = i;
        if(i % 1000 == 0) printf("%x(%d) ", i/1000, 64);
    }
    for(int i = 0; &p64[i] < (volatile uint64_t *)(BASE + SIZE); i++) {
        if(p64[i] != i) {
            putstr("error\n");
            return 1;
        }
    }

    putstr("mem test pass!\n");
    return 0;
}
