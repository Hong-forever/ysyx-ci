#include <klibtest.h>

void memmove_test() {
    int l, r;
    uint8_t data_r[NR];
    for(l=0; l<NR; l++) {
        for(r=l+1; r<=NR; r++) {
            reset();
            uint8_t val = (l+r)/2;
            memset(data_r+l, val, r-l);
            memmove(data+l, data_r+l, r-l);
            check_seq(0, l, 1);
            check_eq(l, r, val);
            check_seq(r, NR, r+1);
        }
    }
}
