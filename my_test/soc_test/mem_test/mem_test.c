#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#define BASE 0xa0000000
#define SIZE 0x200

#define p_period 0x100

#define PUT(i, period, op, bit) \
    do { \
        if(i % period == 0) printf("(%s): 0x%x-0x%x ", op, i * (bit / 8), (i + period) * (bit / 8) - 1); \
    } while (0)

#define TEST(bit, val_max, type) \
    do { \
        printf("Testing %d-bit access:\n", bit); \
        volatile type *p = (volatile type *)BASE; \
        for (uint32_t i = 0; &p[i] < (volatile type *)(BASE + SIZE); i++) { \
            p[i] = (type)(i + val_max); \
            PUT(i, p_period, "w", bit); \
        } \
        printf("\n"); \
        for(uint32_t i = 0; &p[i] < (volatile type *)(BASE + SIZE); i++) { \
            if(p[i] != (type)(i + val_max)) { \
                putstr("error\n"); \
                return 1; \
            } \
            PUT(i, p_period, "r", bit); \
        } \
        printf("\n\n"); \
    } while (0)

int main(const char *args) {

    putstr("\nmem test start!\n");
    printf("Testing memory range: 0x%x - 0x%x\n\n", BASE, BASE + SIZE - 1);

    // TEST(64, 9876789, uint64_t);
    // TEST(32, 124321,  uint32_t);
    // TEST(16, 656,     uint16_t);
    TEST(8,  26,      uint8_t );

    putstr("mem test pass!\n\n");
    return 0;
}
