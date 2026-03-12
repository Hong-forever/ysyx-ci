#include "branchsim.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <getopt.h>

// 命令行参数
typedef struct {
    char trace_file[256];
} CmdArgs;

// 解析命令行参数
int parse_args(int argc, char *argv[], CmdArgs *args) {
    static struct option long_options[] = {
        {"trace", required_argument, 0, 't'},
        {0, 0, 0, 0}
    };
    
    // 默认值
    strcpy(args->trace_file, "trace.txt");
    int opt;
    while ((opt = getopt_long(argc, argv, "t:h",
                              long_options, NULL)) != -1) {
        switch (opt) {
            case 't':
                strncpy(args->trace_file, optarg, sizeof(args->trace_file)-1);
                break;
            case 'h':
            default:
                printf("Usage: %s [options]\n", argv[0]);
                printf("Options:\n");
                printf("  -t, --trace FILE        Trace file (default: trace.txt)\n");
                printf("  -h, --help              Show this help\n");
                return 1;
        }
    }
    
    return 0;
}

int main(int argc, char *argv[]) {
    // 解析命令行参数
    CmdArgs args;
    if (parse_args(argc, argv, &args) != 0) {
        return 1;
    }
    
    // 设置随机种子
    srand(time(NULL));

    // 处理trace文件
    int access_count = 0;
    if (strstr(args.trace_file, ".bin") != NULL) {
        access_count = process_binary_trace(args.trace_file);
    } else {
        return 1;
    }
    
    printf("\nTrace processing completed\n");
    printf("Total accesses processed: %d\n", access_count);
    
    // 打印统计信息
    branchsim_print_stats();

    return 0;
}