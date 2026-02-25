#include "cachesim.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

uint32_t total_accesses = 0;
uint32_t correct_predictions = 0;
uint32_t mispredictions = 0;

// 核心访问函数
bool branchsim_access(uint32_t inst, bool br_taken) {
    // 参数检查
    if (inst == 0) return false;

    bool prediction = (inst & 0x7f) == 0x63 && (inst >> 31) == 1;
    total_accesses++;
    
    if (prediction == br_taken) {
        correct_predictions++;
    } else {
        mispredictions++;
    }

    return true;
    
}


// 打印统计信息
void branchsim_print_stats() {
    
    printf("\n========== Branch Simulator Statistics ==========\n");
    printf("Configuration:\n");
    printf("  Total accesses: %u\n", total_accesses);
    printf("  Correct predictions: %u\n", correct_predictions);
    printf("  Mispredictions: %u\n", mispredictions);
    printf("  Accuracy: %.2f%%\n", 
           total_accesses > 0 ? 100.0 * correct_predictions / total_accesses : 0);
    
    printf("================================================\n");
}