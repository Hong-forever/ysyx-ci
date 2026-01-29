#include <am.h>
#include <klib.h>
#include <klib-macros.h>

int main(const char *args) {

    volatile uint16_t *p = (volatile uint16_t *)0x10002000;

    *p = 0xAAAA;

    while(1);
    

    return 0;
}
