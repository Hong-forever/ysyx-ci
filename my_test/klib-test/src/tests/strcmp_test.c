#include <klibtest.h>

int strcmp_reference(const char *s1, const char *s2);
void strcmp_test() {
    const char *test_cases[] = {
        "apple", "apple",     // 相等
        "apple", "banana",    // 小于
        "banana", "apple",    // 大于  
        "app", "apple",       // 前缀
        "apple", "app",       // 后缀
        "", "",               // 空字符串
        "a", "",              // 与非空比较
        "", "a",              // 与非空比较
        NULL
    };
    
    for (int i = 0; test_cases[i] != NULL; i += 2) {
        const char *s1 = test_cases[i];
        const char *s2 = test_cases[i + 1];
        
        int result = strcmp(s1, s2);
        
        // 验证符号正确性（具体值不重要，符号重要）
        if (strcmp_reference(s1, s2) == 0) {
            assert(result == 0);
        } else if (strcmp_reference(s1, s2) < 0) {
            assert(result < 0);
        } else {
            assert(result > 0);
        }
    }
}

// 参考实现（用于比较）
int strcmp_reference(const char *s1, const char *s2) {
    while (*s1 && *s1 == *s2) {
        s1++;
        s2++;
    }
    return *(unsigned char *)s1 - *(unsigned char *)s2;
}
