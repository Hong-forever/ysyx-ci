#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#define LED_ADDR 0x10002000
#define SW_ADDR  0x10002004

int main(const char *args) {

    volatile uint16_t *led = (volatile uint16_t *)LED_ADDR;
    volatile uint16_t *sw = (volatile uint16_t *)SW_ADDR;

    int i = 0;
    while(1) {
        *led = 1 << i;
        i++;
        if(i >= 16) i = 0;
        for (volatile int j = 0; j < 1000; j++);
        while((*sw) != i);
    }
    

    return 0;
}
