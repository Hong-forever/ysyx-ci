#include "branchsim.h"
#include <stdio.h>
#include <stdlib.h>
#include <zlib.h>
#include <string.h>


// 读取二进制格式trace
int process_binary_trace(const char *filename) {
    FILE *fp = fopen(filename, "rb");
    if (!fp) {
        fprintf(stderr, "Error opening binary trace file: %s\n", filename);
        return -1;
    }
    
    uint64_t entry, entry2;
    int count = 0;

    // 127:96 - Branch taken (1) or not taken (0)
    // 95:64 - Target address
    // 63:32 - PC
    // 31:0 - Instruction (32-bit)
    
    // inst, addr, target, br_taken
    while (fread(&entry, sizeof(uint64_t), 1, fp) == 1 && fread(&entry2, sizeof(uint64_t), 1, fp) == 1) {
        bool is_taken = (entry2 >> 32) & 0x1;  // 取第32位作为分支结果 
            branchsim_access((uint32_t)entry, (uint32_t)(entry >> 32), (uint32_t)(entry2 & 0xFFFFFFFF), is_taken);
            count++;
        if (count % 1000000 == 0) {
            printf("Processed %d million accesses...\n", count / 1000000);
        }
    }
    
    fclose(fp);
    return count;
}
