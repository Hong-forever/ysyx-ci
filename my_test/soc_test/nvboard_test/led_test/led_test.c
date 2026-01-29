#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#define LED_ADDR 0x10002000

int main(const char *args) {

    volatile uint16_t *p = (volatile uint16_t *)LED_ADDR;

    for(int i = 0; i < 10000; i++) {
        *p = 1 << i;
        for (volatile int j = 0; j < 1000000; j++);
    }
    

    return 0;
}
