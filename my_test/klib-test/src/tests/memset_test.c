#include <klibtest.h>

//statememt?
void memset_test() {
    int l, r;
    for(l=0; l<NR; l++) {
        for(r=l+1; r<=NR; r++) {
            reset();
            uint8_t val = (l+r)/2;
            memset(data+l, val, r-l);
            check_seq(0, l, 1);
            check_eq(l, r, val);
            check_seq(r, NR, r+1);
        }
    }
}
