#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#define LED_ADDR 0x10002000

int main(const char *args) {

    volatile uint16_t *p = (volatile uint16_t *)LED_ADDR;

    int i = 0;
    while(1) {
        *p = 1 << i;
        i++;
        if(i >= 16) i = 0;
        for (volatile int j = 0; j < 1000; j++);
    }
    

    return 0;
}
