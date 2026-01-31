#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#define BASE 0xa7000000
#define SIZE 0x800

#define p_period 0x100

#define PUT(i, period, op, bit) \
    do { \
        if(i % period == 0) printf("%s: 0x%x-0x%x ", op, i * bit / 8 * period, (i + 1) * bit / 8 * period - 1); \
    } while (0)

#define TEST(bit, val_max, type) \
    do { \
        printf("Testing %d-bit memory...\n", bit); \
        volatile type *p = (volatile type *)BASE; \
        for (uint32_t i = 0; &p[i] < (volatile type *)(BASE + SIZE); i++) { \
            p[i] = i % val_max; \
            PUT(i, p_period, "write", bit); \
        } \
        printf("\n"); \
        for(uint32_t i = 0; &p[i] < (volatile type *)(BASE + SIZE); i++) { \
            if(p[i] != i % val_max) { \
                putstr("error\n"); \
                return 1; \
            } \
            PUT(i, p_period, "read", bit); \
        } \
        printf("\n\n"); \
    } while (0)

int main(const char *args) {

    putstr("mem test start!\n\n");

    TEST(64, 987656789, uint64_t);
    TEST(32, 1234321, uint32_t);
    TEST(16, 65536, uint16_t);
    TEST(8,  256,  uint8_t );

    putstr("mem test pass!\n\n");
    return 0;
}
