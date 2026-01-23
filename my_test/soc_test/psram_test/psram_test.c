#include <am.h>
#include <klib.h>
#include <klib-macros.h>

int main(const char *args) {

    volatile uint32_t *p = (volatile uint32_t *)0x80000000;

    p[0] = 0x12345678;

    if(p[0] != 0x12345678) {
        putstr("psram_test failed at addr 0x80000000\n");
        return -1;
    }

    return 0;
}
