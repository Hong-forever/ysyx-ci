#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#define BASE 0xa0000000
#define SIZE 0x8000

#define p_period 100

#define PUT(i, period, bit, op) \
    do { \
        if(i % period == 0) printf("%s: %d(%d bit) ", op, i, bit); \
    } while (0)

#define TEST(bit, val_max, type) \
    do { \
        volatile type *p = (volatile type *)BASE; \
        for (uint64_t i = 0; &p[i] < (volatile type *)(BASE + SIZE); i++) { \
            p[i] = i % val_max; \
            PUT(i, p_period, bit, "write"); \
        } \
        printf("\n"); \
        for(uint64_t i = 0; &p[i] < (volatile type *)(BASE + SIZE); i++) { \
            if(p[i] != i % val_max) { \
                putstr("error\n"); \
                return 1; \
            } \
            PUT(i, p_period, bit, "read"); \
        } \
        printf("\n"); \
    } while (0)

int main(const char *args) {

    putstr("mem test start!\n");

    TEST(8,  256,  uint8_t );
    TEST(16, 65536, uint16_t);
    TEST(32, 1234321, uint32_t);
    TEST(64, 987656789, uint64_t);

    putstr("mem test pass!\n");
    return 0;
}
