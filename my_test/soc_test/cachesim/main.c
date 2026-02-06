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
    uint32_t size_kb;
    uint32_t ways;
    uint32_t block_size;
    char replace_policy[10];
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
        {"icache", no_argument, 0, 'i'},
        {0, 0, 0, 0}
    };
    
    // 默认值
    strcpy(args->trace_file, "trace.txt");
    strcpy(args->cache_type, "unified");
    args->size_kb = 32;
    args->ways = 4;
    args->block_size = 64;
    strcpy(args->replace_policy, "lru");
    args->icache_only = false;
    
    int opt;
    while ((opt = getopt_long(argc, argv, "t:y:s:w:b:p:ivh", 
                              long_options, NULL)) != -1) {
        switch (opt) {
            case 't':
                strncpy(args->trace_file, optarg, sizeof(args->trace_file)-1);
                break;
            case 'y':
                strncpy(args->cache_type, optarg, sizeof(args->cache_type)-1);
                break;
            case 's':
                args->size_kb = atoi(optarg);
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
            case 'i':
                args->icache_only = true;
                break;
            case 'h':
            default:
                printf("Usage: %s [options]\n", argv[0]);
                printf("Options:\n");
                printf("  -t, --trace FILE        Trace file (default: trace.txt)\n");
                printf("  -y, --type TYPE         Cache type: icache/dcache/unified\n");
                printf("  -s, --size KB           Cache size in KB (default: 32)\n");
                printf("  -w, --ways N            Associativity (default: 4)\n");
                printf("  -b, --block BYTES       Block size in bytes (default: 64)\n");
                printf("  -p, --policy POLICY     Replacement policy: lru/fifo/random (default: lru)\n");
                printf("  -i, --icache            I-cache only mode (simplified)\n");
                printf("  -h, --help              Show this help\n");
                return 1;
        }
    }
    
    return 0;
}

// 批量评估多个配置
void batch_evaluation(const char *trace_file) {
    printf("Starting batch evaluation...\n");
    
    // 测试参数组合
    uint32_t sizes[] = {4, 8, 16, 32, 64};
    uint32_t ways[] = {1, 2, 4, 8};
    uint32_t blocks[] = {32, 64, 128};
    const char *policies[] = {"lru", "fifo", "random"};
    
    int total_tests = sizeof(sizes) / sizeof(sizes[0]) *
                     sizeof(ways) / sizeof(ways[0]) *
                     sizeof(blocks) / sizeof(blocks[0]) *
                     sizeof(policies) / sizeof(policies[0]);
    
    printf("Total test configurations: %d\n", total_tests);
    
    int test_num = 0;
    for (uint32_t s = 0; s < sizeof(sizes)/sizeof(sizes[0]); s++) {
        for (uint32_t w = 0; w < sizeof(ways)/sizeof(ways[0]); w++) {
            for (uint32_t b = 0; b < sizeof(blocks)/sizeof(blocks[0]); b++) {
                for (uint32_t p = 0; p < sizeof(policies)/sizeof(policies[0]); p++) {
                    test_num++;
                    printf("\n[Test %d/%d] ", test_num, total_tests);
                    
                    // 检查配置是否有效
                    if (sizes[s] * 1024 < ways[w] * blocks[b]) {
                        printf("Skipping invalid config: Size=%dKB, Ways=%d, Block=%dB\n",
                               sizes[s], ways[w], blocks[b]);
                        continue;
                    }
                    
                    // 创建配置
                    CacheConfig config = {
                        .size_kb = sizes[s],
                        .ways = ways[w],
                        .block_size = blocks[b],
                        .is_icache = true,
                    };
                    strcpy(config.replace_policy, policies[p]);
                    
                    // 创建并运行cache模拟器
                    CacheSim *cache = cachesim_create(&config);
                    if (!cache) {
                        fprintf(stderr, "Failed to create cache simulator\n");
                        continue;
                    }
                    
                    // 处理trace（简化：这里直接使用一些随机访问）
                    // 实际应该从文件读取
                    srand(time(NULL));
                    uint64_t base_addr = 0x80000000;
                    for (int i = 0; i < 100000; i++) {
                        uint64_t addr = base_addr + (rand() % 0x10000) * 4;
                        cachesim_access(cache, addr, false);
                    }
                    
                    // 输出结果
                    printf("Config: Size=%dKB, Ways=%d, Block=%dB, Policy=%s\n",
                           sizes[s], ways[w], blocks[b], policies[p]);
                    printf("Miss rate: %.4f%%\n", 
                           100.0 * cache->miss_count / cache->access_count);
                    
                    cachesim_destroy(cache);
                }
            }
        }
    }
}

int main(int argc, char *argv[]) {
    // 解析命令行参数
    CmdArgs args;
    if (parse_args(argc, argv, &args) != 0) {
        return 1;
    }
    
    // 如果是批处理模式
    if (strcmp(args.trace_file, "batch") == 0) {
        batch_evaluation("default_trace.bin");
        return 0;
    }
    
    // 设置随机种子
    srand(time(NULL));
    
    // 创建cache配置
    CacheConfig config;
    config.size_kb = args.size_kb;
    config.ways = args.ways;
    config.block_size = args.block_size;
    config.is_icache = args.icache_only || strcmp(args.cache_type, "icache") == 0;
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
    printf("  Size: %u KB\n", config.size_kb);
    printf("  Ways: %u\n", config.ways);
    printf("  Block: %u bytes\n", config.block_size);
    printf("  Policy: %s\n", config.replace_policy);
    
    // 处理trace文件
    int access_count = 0;
    if (strstr(args.trace_file, ".bz2") != NULL) {
        access_count = process_compressed_trace(args.trace_file, cache);
    } else if (strstr(args.trace_file, ".bin") != NULL) {
        access_count = process_binary_trace(args.trace_file, cache);
    } else {
        access_count = process_text_trace(args.trace_file, cache);
    }
    
    printf("\nTrace processing completed\n");
    printf("Total accesses processed: %d\n", access_count);
    
    // 打印统计信息
    cachesim_print_stats(cache);
    
    // 估算TMT
    double clock_freq = 100e6;  // 100 MHz
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