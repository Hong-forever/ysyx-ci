#include "cachesim.h"
#include <stdio.h>
#include <stdlib.h>
#include <zlib.h>
#include <string.h>

// 简单的trace条目结构
typedef struct {
    uint64_t pc;
    uint8_t is_write;  // 0=读, 1=写
    uint8_t length;    // 连续访问长度
} TraceEntry;

// 读取文本格式trace
int process_text_trace(const char *filename, CacheSim *cache) {
    FILE *fp = fopen(filename, "r");
    if (!fp) {
        fprintf(stderr, "Error opening trace file: %s\n", filename);
        return -1;
    }
    
    char line[256];
    uint64_t pc;
    char type;
    int count = 0;
    
    while (fgets(line, sizeof(line), fp)) {
        if (sscanf(line, "%c %lx", &type, &pc) == 2) {
            bool is_write = (type == 'W' || type == 'w');
            
            // 处理访问
            cachesim_access(cache, pc, is_write);
            count++;
            
            if (count % 1000000 == 0) {
                printf("Processed %d million accesses...\n", count / 1000000);
            }
        }
    }
    
    fclose(fp);
    return count;
}

// 读取二进制格式trace
int process_binary_trace(const char *filename, CacheSim *cache) {
    FILE *fp = fopen(filename, "rb");
    if (!fp) {
        fprintf(stderr, "Error opening binary trace file: %s\n", filename);
        return -1;
    }
    
    TraceEntry entry;
    int count = 0;
    
    while (fread(&entry, sizeof(TraceEntry), 1, fp) == 1) {
        for (int i = 0; i < entry.length; i++) {
            cachesim_access(cache, entry.pc + i * 4, entry.is_write);
            count++;
        }
        
        if (count % 1000000 == 0) {
            printf("Processed %d million accesses...\n", count / 1000000);
        }
    }
    
    fclose(fp);
    return count;
}

// 压缩trace处理（使用bz2）
int process_compressed_trace(const char *filename, CacheSim *cache) {
    char command[512];
    sprintf(command, "bzcat %s", filename);
    
    FILE *fp = popen(command, "r");
    if (!fp) {
        fprintf(stderr, "Error opening compressed trace: %s\n", filename);
        return -1;
    }
    
    char line[256];
    uint64_t pc;
    char type;
    int count = 0;
    
    while (fgets(line, sizeof(line), fp)) {
        if (sscanf(line, "%c %lx", &type, &pc) == 2) {
            bool is_write = (type == 'W' || type == 'w');
            cachesim_access(cache, pc, is_write);
            count++;
        }
    }
    
    pclose(fp);
    return count;
}