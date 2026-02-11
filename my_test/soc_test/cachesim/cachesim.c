#include "cachesim.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

static uint32_t get_offset_bits(uint32_t block_size) {
    return (uint32_t)log2(block_size);
}

static uint32_t get_index_bits(uint32_t sets) {
    return (uint32_t)log2(sets);
}

// 创建cache模拟器
CacheSim* cachesim_create(CacheConfig *config) {
    CacheSim *cache = (CacheSim*)malloc(sizeof(CacheSim));
    if (!cache) return NULL;
    
    // 复制配置
    cache->config = *config;
    
    // 计算组数
    uint32_t total_bytes = config->size_byte;
    uint32_t block_bytes = config->block_size;
    uint32_t lines_per_set = config->ways;
    uint32_t total_lines = total_bytes / block_bytes;
    cache->config.sets = total_lines / lines_per_set;
    
    // 分配cache行
    size_t lines_size = sizeof(CacheLine) * cache->config.sets * lines_per_set;
    cache->lines = (CacheLine*)malloc(lines_size);
    if (!cache->lines) {
        free(cache);
        return NULL;
    }
    
    // 初始化cache行
    for (uint32_t i = 0; i < cache->config.sets * lines_per_set; i++) {
        cache->lines[i].tag = 0;
        cache->lines[i].valid = false;
        cache->lines[i].dirty = false;
        cache->lines[i].lru_counter = 0;
        cache->lines[i].fifo_counter = 0;
    }
    
    // 初始化统计
    cachesim_reset_stats(cache);
    cache->counter = 0;
    
    return cache;
}

// 销毁cache模拟器
void cachesim_destroy(CacheSim *cache) {
    if (!cache) return;
    
    // 释放数据
    if (cache->lines) {
        free(cache->lines);
    }
    free(cache);
}

// 重置统计
void cachesim_reset_stats(CacheSim *cache) {
    cache->access_count = 0;
    cache->read_count = 0;
    cache->write_count = 0;
    cache->hit_count = 0;
    cache->miss_count = 0;
    cache->read_hit = 0;
    cache->read_miss = 0;
    cache->counter = 0;
}

// 从地址中提取tag、index、offset
static void extract_address(uint32_t addr, CacheSim *cache, 
                           uint32_t *tag, uint32_t *index, uint32_t *offset) {
    uint32_t offset_bits = get_offset_bits(cache->config.block_size);
    uint32_t index_bits = get_index_bits(cache->config.sets);
    // uint32_t tag_bits = 32 - index_bits - offset_bits;
    
    *offset = addr & ((1 << offset_bits) - 1);
    *index = (addr >> offset_bits) & ((1 << index_bits) - 1);
    *tag = addr >> (offset_bits + index_bits);
}

// 查找cache行
static CacheLine* find_line(CacheSim *cache, uint32_t index, uint32_t tag) {
    CacheLine *set = &cache->lines[index * cache->config.ways];
    
    for (uint32_t i = 0; i < cache->config.ways; i++) {
        if (set[i].valid && set[i].tag == tag) {
            return &set[i];
        }
    }
    
    return NULL;
}

// 查找替换牺牲行
static CacheLine* find_victim(CacheSim *cache, uint32_t index) {
    CacheLine *set = &cache->lines[index * cache->config.ways];
    CacheLine *victim = &set[0];
    
    // 查找无效行
    for (uint32_t i = 0; i < cache->config.ways; i++) {
        if (!set[i].valid) {
            return &set[i];
        }
    }
    
    // 所有行都有效，使用替换策略
    if (strcmp(cache->config.replace_policy, "lru") == 0) {
        // LRU策略：找最小的lru_counter
        for (uint32_t i = 1; i < cache->config.ways; i++) {
            if (set[i].lru_counter < victim->lru_counter) {
                victim = &set[i];
            }
        }
    } else if (strcmp(cache->config.replace_policy, "fifo") == 0) {
        // FIFO策略：找最小的fifo_counter
        for (uint32_t i = 1; i < cache->config.ways; i++) {
            if (set[i].fifo_counter < victim->fifo_counter) {
                victim = &set[i];
            }
        }
    } else {
        // Random策略
        victim = &set[rand() % cache->config.ways];
    }
    
    return victim;
}

// 处理cache缺失
static void handle_miss(CacheSim *cache, uint32_t index, uint32_t tag, 
                       bool is_write, CacheLine *line) {
    
    // 加载新行
    line->tag = tag;
    line->valid = true;
    
    // 更新计数器
    line->lru_counter = cache->counter;
    if (strcmp(cache->config.replace_policy, "fifo") == 0 && !line->valid) {
        line->fifo_counter = cache->counter;
    }
}

// 核心访问函数
bool cachesim_access(CacheSim *cache, uint32_t addr, bool is_write) {
    // 参数检查
    if (!cache || addr == 0) return false;
    
    // 提取地址各部分
    uint32_t tag;
    uint32_t index, offset;
    extract_address(addr, cache, &tag, &index, &offset);
    
    // 更新全局计数器
    cache->counter++;
    
    // 更新统计
    cache->access_count++;
    if (is_write) {
        cache->write_count++;
    } else {
        cache->read_count++;
    }
    
    // 查找是否命中
    CacheLine *line = find_line(cache, index, tag);
    
    if (line != NULL) {
        // 命中
        cache->hit_count++;
        if (is_write) {
        } else {
            cache->read_hit++;
        }
        
        // 更新LRU计数器
        line->lru_counter = cache->counter;
        
        return true;
    } else {
        // 缺失
        cache->miss_count++;
        if (is_write) {
        } else {
            cache->read_miss++;
        }
        
        // 查找替换行
        CacheLine *victim = find_victim(cache, index);
        
        // 处理缺失
        handle_miss(cache, index, tag, is_write, victim);
        
        return false;
    }
}

uint64_t cachesim_calculate_miss_penalty(uint32_t block_size, bool is_dram) {
    
    return 20;
}

// 估算总缺失时间（TMT）
double cachesim_estimate_tmt(CacheSim *cache, double clock_freq) {
    if (cache->access_count == 0) return 0.0;
    
    double miss_rate = (double)cache->miss_count / cache->access_count;
    uint64_t miss_penalty = cachesim_calculate_miss_penalty(
        cache->config.block_size, true);  // 假设DRAM
    
    double total_cycles = cache->access_count * (1 - miss_rate) * 1  // 命中周期
                        + cache->miss_count * miss_penalty;          // 缺失周期
    
    return total_cycles / clock_freq;  // 秒
}

// 打印统计信息
void cachesim_print_stats(CacheSim *cache) {
    if (!cache) return;
    
    printf("\n========== Cache Simulator Statistics ==========\n");
    printf("Configuration:\n");
    printf("  Size:           %u B\n", cache->config.size_byte);
    printf("  Associativity:  %u-way\n", cache->config.ways);
    printf("  Block size:     %u bytes\n", cache->config.block_size);
    printf("  Sets:           %u\n", cache->config.sets);
    printf("  Type:           %s\n", cache->config.is_icache ? "I-Cache" : "D-Cache");
    printf("  Replace policy: %s\n", cache->config.replace_policy);
    
    printf("\nAccess Statistics:\n");
    printf("  Total accesses: %lu\n", cache->access_count);
    printf("  Read accesses:  %lu (%.2f%%)\n", 
           cache->read_count, 
           cache->access_count > 0 ? 100.0 * cache->read_count / cache->access_count : 0);
    printf("  Write accesses: %lu (%.2f%%)\n", 
           cache->write_count,
           cache->access_count > 0 ? 100.0 * cache->write_count / cache->access_count : 0);
    
    printf("\nPerformance Statistics:\n");
    printf("  Total hits:     %lu\n", cache->hit_count);
    printf("  Total misses:   %lu\n", cache->miss_count);
    printf("  Hit rate:       %.2f%%\n", 
           cache->access_count > 0 ? 100.0 * cache->hit_count / cache->access_count : 0);
    printf("  Miss rate:      %.2f%%\n", 
           cache->access_count > 0 ? 100.0 * cache->miss_count / cache->access_count : 0);
    
    if (cache->read_count > 0) {
        printf("  Read hit rate:  %.2f%%\n", 
               100.0 * cache->read_hit / cache->read_count);
    }
   
    
    printf("================================================\n");
}