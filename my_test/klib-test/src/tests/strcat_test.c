#include <klibtest.h>

void strcat_test() {
    reset_str_data();

    char *dest = str_data;
    char *src = str_data + 20;

    // 设置初始字符串
    strcpy(dest, "Hello ");
    strcpy(src, "World!");

    // 执行连接
    char *result = strcat(dest, src);

    // 验证
    assert(result == dest);
    check_str_eq(dest, "Hello World!", STR_SIZE);
    check_str_eq(src, "World!", STR_SIZE);  // 源不变
}
