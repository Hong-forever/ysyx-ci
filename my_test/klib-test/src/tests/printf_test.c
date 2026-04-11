#include <klibtest.h>
#include <limits.h>
#include <stdint.h>

int int_test_cases[] = {
    0, 1, -1, 2, -2, 10, -10, 123, -123,
    INT_MAX / 17, INT_MIN / 17, 
    INT_MAX, INT_MIN, INT_MIN + 1,
    INT_MAX - 1
};

unsigned uint_test_cases[] = {
    0, 1, 2, 10, 100, 123, 1000,
    UINT_MAX / 17, UINT_MAX / 2,
    UINT_MAX, UINT_MAX - 1
};

char *str_test_cases[] = {
    "", "a", "hello", "world", 
    "test string", "with spaces",
    "special\tchars\n", NULL
};

char char_test_cases[] = {
    'A', 'a', '0', ' ', '\t', '\n', '!', '@'
};

void printf_test() {
    for(int i=0; i<sizeof(int_test_cases)/sizeof(int_test_cases[0]); i++) {
        printf("%d ", int_test_cases[i]);
    }
    printf("\n");

    for(int i=0; i<sizeof(uint_test_cases)/sizeof(uint_test_cases[0]); i++) {
        printf("%u ", uint_test_cases[i]);
    }
    printf("\n");
    
    for(int i=0; str_test_cases[i] != NULL; i++) {
        printf("%s ", str_test_cases[i]);
    }
    printf("\n");

    for(int i=0; i<sizeof(char_test_cases)/sizeof(char_test_cases[0]); i++) {
        printf("%c ", char_test_cases[i]);
    }
    printf("\n");
    
}
