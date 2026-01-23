#include <am.h>
#include <klib.h>
#include <klib-macros.h>

int main(const char *args) {

    volatile uint8_t *p = (volatile uint8_t *)0x80000000;

    p[0] = 0x12;
    p[1] = 0x34;

    if(p[0] != 0x12) {
        putstr("psram_test failed at addr 0x80000000\n");
        return -1;
    }
    if(p[1] != 0x34) {
        putstr("psram_test failed at addr 0x80000001\n");
        return -1;
    }

    return 0;
}
