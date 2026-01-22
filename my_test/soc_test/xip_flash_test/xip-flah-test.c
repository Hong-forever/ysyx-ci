#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#define SIZE 16 

int main(const char *args) {

    // volatile uint32_t *p = (volatile uint32_t *)0x30000000;
    // for (int i = 0; i < SIZE / 4; i++) {
    //     printf("Data at address 0x%08x: 0x%08x\n", (uint32_t)(0x30000000 + i * 4), p[i]);
    // }

    // test jump to flash
    asm volatile("li t0, %0; jalr zero, t0, 0" : : "i"(0x30000000));
    return 0;
}
