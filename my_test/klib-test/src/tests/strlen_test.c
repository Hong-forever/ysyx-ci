#include <klibtest.h>

struct test_case {
    const char *str;
    int length;
};

void strlen_test() {
    struct test_case test_cases[] = {
        {"", 0},
        {"a", 1},
        {"ab", 2},
        {"hello", 5},
        {"long string here", 16},
        {NULL, 0}  // 结束标记
    };

    for (int i = 0; test_cases[i].str != NULL; i++) {
        assert(strlen(test_cases[i].str) == test_cases[i].length);
    }
}
