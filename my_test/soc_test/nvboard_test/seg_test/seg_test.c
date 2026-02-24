#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#define LED_ADDR 0x10002000
#define SW_ADDR  0x10002004
#define SEG_ADDR 0x10002008


int main(const char *args) {

    volatile uint16_t *led = (volatile uint16_t *)LED_ADDR;
    // volatile uint16_t *sw = (volatile uint16_t *)SW_ADDR;
    // volatile uint32_t *seg = (volatile uint32_t *)SEG_ADDR;

    // while(*sw != 0x1234);

    // *seg = 0x25110270;

    int i = 0;
    while(1) {
        *led = 1 << i;
        i++;
        if(i >= 16) i = 0;
        putstr("LED changed\n");
        // for (volatile int j = 0; j < 1000; j++); 
        // while((*sw) != (1 << i));
    }
    

    return 0;
}
