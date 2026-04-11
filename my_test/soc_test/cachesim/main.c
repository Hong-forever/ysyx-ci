#include "cachesim.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <getopt.h>

// 命令行参数
typedef struct {
    char trace_file[256];
    char cache_type[10];
    uint32_t size_byte;
    uint32_t ways;
    uint32_t block_size;
    char replace_policy[10];
    bool write_back;
    bool write_allocate;
    bool icache_only;

} CmdArgs;

// 解析命令行参数
int parse_args(int argc, char *argv[], CmdArgs *args) {
    static struct option long_options[] = {
        {"trace", required_argument, 0, 't'},
        {"type", required_argument, 0, 'y'},
        {"size", required_argument, 0, 's'},
        {"ways", required_argument, 0, 'w'},
        {"block", required_argument, 0, 'b'},
        {"policy", required_argument, 0, 'p'},
        {"write-back", no_argument, 0, 'B'},
        {"write-through", no_argument, 0, 'T'},
        {"write-allocate", no_argument, 0, 'a'},
        {"no-write-allocate", no_argument, 0, 'A'},
        {"icache", no_argument, 0, 'i'},
        {0, 0, 0, 0}
    };
    
    // 默认值
    strcpy(args->trace_file, "trace.txt");
    strcpy(args->cache_type, "unified");
    args->size_byte = 32;
    args->ways = 4;
    args->block_size = 64;
    strcpy(args->replace_policy, "lru");
    args->icache_only = false;
    
    int opt;
    while ((opt = getopt_long(argc, argv, "t:y:s:w:b:p:BTaAih",
                              long_options, NULL)) != -1) {
        switch (opt) {
            case 't':
                strncpy(args->trace_file, optarg, sizeof(args->trace_file)-1);
                break;
            case 'y':
                strncpy(args->cache_type, optarg, sizeof(args->cache_type)-1);
                break;
            case 's':
                args->size_byte = atoi(optarg);
                break;
            case 'w':
                args->ways = atoi(optarg);
                break;
            case 'b':
                args->block_size = atoi(optarg);
                break;
            case 'p':
                strncpy(args->replace_policy, optarg, sizeof(args->replace_policy)-1);
                break;
            case 'B':
                args->write_back = true;
                break;
            case 'T':
                args->write_back = false;
                break;
            case 'a':
                args->write_allocate = true;
                break;
            case 'A':
                args->write_allocate = false;
                break;
            case 'i':
                args->icache_only = true;
                break;
            case 'h':
            default:
                printf("Usage: %s [options]\n", argv[0]);
                printf("Options:\n");
                printf("  -t, --trace FILE        Trace file (default: trace.txt)\n");
                printf("  -y, --type TYPE         Cache type: icache/dcache/unified\n");
                printf("  -s, --size KB           Cache size in B (default: 32)\n");
                printf("  -w, --ways N            Associativity (default: 4)\n");
                printf("  -b, --block BYTES       Block size in bytes (default: 64)\n");
                printf("  -p, --policy POLICY     Replacement policy: lru/fifo/random (default: lru)\n");
                printf("  -B, --write-back        Use write-back policy (default)\n");
                printf("  -T, --write-through     Use write-through policy\n");
                printf("  -a, --write-allocate    Use write-allocate (default)\n");
                printf("  -A, --no-write-allocate Use no-write-allocate\n");
                printf("  -i, --icache            I-cache only mode (simplified)\n");
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
    
    // 创建cache配置
    CacheConfig config;
    config.size_byte = args.size_byte;
    config.ways = args.ways;
    config.block_size = args.block_size;
    config.is_icache = args.icache_only || strcmp(args.cache_type, "icache") == 0;
    config.write_back = args.write_back && !config.is_icache;
    config.write_allocate = args.write_allocate && !config.is_icache;
    strcpy(config.replace_policy, args.replace_policy);
    
    // 创建cache模拟器
    CacheSim *cache = cachesim_create(&config);
    if (!cache) {
        fprintf(stderr, "Failed to create cache simulator\n");
        return 1;
    }
    
    printf("Cache Simulator Started\n");
    printf("Configuration:\n");
    printf("  Type: %s\n", config.is_icache ? "Instruction Cache" : "Data Cache");
    printf("  Size: %u B\n", config.size_byte);
    printf("  Ways: %u\n", config.ways);
    printf("  Block: %u bytes\n", config.block_size);
    printf("  Policy: %s\n", config.replace_policy);
    printf("  Write: %s\n", config.write_back ? "Write-Back" : "Write-Through");
    printf("  Write allocate: %s\n", config.write_allocate ? "Yes" : "No");
    // 处理trace文件
    int access_count = 0;
    if (strstr(args.trace_file, ".bin") != NULL) {
        access_count = process_binary_trace(args.trace_file, cache);
    } else {
        return 1;
    }
    
    printf("\nTrace processing completed\n");
    printf("Total accesses processed: %d\n", access_count);
    
    // 打印统计信息
    cachesim_print_stats(cache);
    
    // 估算TMT
    double clock_freq = 1000e6;  // 1000 MHz
    double tmt = cachesim_estimate_tmt(cache, clock_freq);
    printf("\nPerformance Estimation (assuming %.0f MHz clock):\n", clock_freq / 1e6);
    printf("  Total Miss Time (TMT): %.6f seconds\n", tmt);
    printf("  Average memory access time: %.2f cycles\n",
           (double)cache->access_count * (1.0 + 
           (double)cache->miss_count / cache->access_count * 
           cachesim_calculate_miss_penalty(config.block_size, true)));
    
    // 清理
    cachesim_destroy(cache);
    
    return 0;
}