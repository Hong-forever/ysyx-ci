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
    
    uint32_t entry;
    int count = 0;
    
    while (fread(&entry, sizeof(uint32_t), 1, fp) == 1) {
        cachesim_access(cache, entry, 0);
        count++;
        
        if (count % 1000000 == 0) {
            printf("Processed %d million accesses...\n", count / 1000000);
        }
    }
    
    fclose(fp);
    return count;
}
