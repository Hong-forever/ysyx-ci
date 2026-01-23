#include <am.h>
#include <klib.h>
#include <klib-macros.h>

int main(const char *args) {

    volatile uint32_t *p = (volatile uint32_t *)0x80000000;

    for(int i = 0; i < 100; i++) {
        p[i] = i * 2 + 1;
    }
    for(int i = 0; i < 100; i++) {
        uint32_t val = p[i];
        printf("Testing: %d\r", i);
        if(val != (i * 2 + 1)) {
            printf("PSRAM TEST FAILED at addr 0x%08x: expected 0x%08x, got 0x%08x\n", 
                   0x80000000 + i * 4, i * 2 + 1, val);
            return -1;
        }
    }


    return 0;
}
