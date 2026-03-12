#include <klibtest.h>

void (*entry)() = NULL;

static const char *tests[256] = {
    ['0'] = "strcpy test",
    ['1'] = "strcat test",
    ['2'] = "memset test",
    ['3'] = "memmove test",
    ['4'] = "memcpy test",
    ['5'] = "strcmp test",
    ['6'] = "strlen test",
    ['7'] = "printf test",

};

uint8_t data[NR];
char str_data[STR_SIZE * 3];  // 更大的缓冲区来处理重叠情况
char str_cmp[STR_SIZE];       // 用于比较的参考字符串


int main(const char *args) {
    switch(args[0]) {
        CASE('0', strcpy_test);
        CASE('1', strcat_test);
        CASE('2', memset_test);
        CASE('3', memmove_test);
        CASE('4', memcpy_test);
        CASE('5', strcmp_test);
        CASE('6', strlen_test);
        CASE('7', printf_test, IOE);

        default:  
        IOE;
        printf("Usage: make run mainargs=*\n");
        for(int ch=0; ch<256; ch++) {
            if(tests[ch]) {
                printf("  %c: %s\n", ch, tests[ch]);
            }
        }

    }

    return 0;
}

void reset() {
    int i;
    for(i=0; i<NR; i++) {
        data[i] = i+1;
    }
}

void reset_str_data() {
    for (int i = 0; i < STR_SIZE * 3; i++) {
        str_data[i] = 'A' + (i % 26);  // 循环填充A-Z
    }
    str_data[STR_SIZE - 1] = '\0';
    str_data[STR_SIZE * 2 - 1] = '\0';
}

void check_seq(int l, int r, int val) {
    int i;
    for(i=l; i<r; i++) {
        assert(data[i] == val + i - l);
    }
}

void check_eq(int l, int r, int val) {
    int i;
    for(i=l; i<r; i++) {
        assert(data[i] == val);
    }
}

void check_str_eq(const char *actual, const char *expected, int max_len) {
    for(int i=0; i<max_len; i++) {
        if(expected[i] == '\0') {
            assert(actual[i] == '\0');
            return;
        }
        assert(actual[i] == expected[i]);
    }
}

void check_str_len(const char *str, int expected_len) {
    int len = 0;
    while(str[len] != '\0') {
        len++;
        assert(len < NR);
    }
    assert(len == expected_len);
}

void check_rg_unchanged(int start, int end, char expected_char) {
    for(int i=start; i<end; i++) {
        assert(str_data[i] == expected_char);
    }
}
