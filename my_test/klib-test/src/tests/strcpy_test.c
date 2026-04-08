#include <klibtest.h>

void strcpy_test() {
    char *dest, *src;
    
    // 测试各种长度的字符串
    const char *test_strings[] = {
        "", "a", "hello", "longer test string", NULL
    };
    
    for (int i = 0; test_strings[i] != NULL; i++) {
        reset_str_data();
        
        src = str_data + 10;  // 源字符串位置
        dest = str_data + 30; // 目标位置
        
        // 设置源字符串
        strcpy(src, test_strings[i]);
        
        // 执行测试
        char *result = strcpy(dest, src);
        
        // 验证结果
        assert(result == dest);  // 返回值正确
        check_str_eq(dest, test_strings[i], STR_SIZE);
        check_str_eq(src, test_strings[i], STR_SIZE);  // 源字符串不应改变
        assert(dest[strlen(test_strings[i])] == '\0'); // 终止符正确
    }
}
