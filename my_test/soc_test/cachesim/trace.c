#include "cachesim.h"
#include <stdio.h>
#include <stdlib.h>
#include <zlib.h>
#include <string.h>


// 读取二进制格式trace
int process_binary_trace(const char *filename, CacheSim *cache) {
    FILE *fp = fopen(filename, "rb");
    if (!fp) {
        fprintf(stderr, "Error opening binary trace file: %s\n", filename);
        return -1;
    }
    
    uint64_t entry;
    int count = 0;
    
    while (fread(&entry, sizeof(uint64_t), 1, fp) == 1) {
        bool is_write = (entry >> 32) != 0;
        // if(entry < 0x0f000000 || entry >= 0x10000000) {
            cachesim_access(cache, (uint32_t)entry, is_write);
            count++;
        // }
        if (count % 1000000 == 0) {
            printf("Processed %d million accesses...\n", count / 1000000);
        }
    }
    
    fclose(fp);
    return count;
}
