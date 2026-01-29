#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#define LED_ADDR 0x10002000

int main(const char *args) {

    volatile uint16_t *p = (volatile uint16_t *)LED_ADDR;
    *p = 0xAAAA;

    while(1);
    

    return 0;
}
