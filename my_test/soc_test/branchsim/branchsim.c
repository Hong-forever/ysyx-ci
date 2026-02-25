#include "branchsim.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include <assert.h>

uint32_t total_accesses = 0;
uint32_t correct_predictions = 0;
uint32_t mispredictions = 0;

uint32_t br_inst_nr = 0;
uint32_t jump_inst_nr = 0;
uint32_t taken_br_nr = 0;
uint32_t taken_jump_nr = 0;

bool btb_valid[4];
uint32_t btb[4];

// 核心访问函数
bool branchsim_access(uint32_t inst, uint32_t pc, uint32_t target, bool br_taken) {
    // 参数检查
    if (inst == 0) return false;

    if((inst & 0x7f) == 0x63) { // Branch
        br_inst_nr++;
        bool prediction = (inst >> 31) == 1 && btb_valid[(pc>>2) % 4];
        uint32_t predicted_target = btb[(pc>>2) % 4];

        bool is_correct = (prediction && br_taken && predicted_target == target) || (!prediction && !br_taken);

        bool is_taken_final = !is_correct;
    
        if (is_correct) {
            correct_predictions++;
        } else {
            mispredictions++;
        }

        if(br_taken) {
            btb_valid[(pc>>2) % 4] = true;
            btb[(pc>>2) % 4] = target;
            taken_br_nr++;
        }

        static FILE *log_fp = NULL;
        if (!log_fp) {
            log_fp = fopen("/tmp/branchsim_log.bin", "wb");
            if (!log_fp) {
                perror("Failed to open log file");
            }
        }

        if (log_fp) {
            uint64_t log_entry = ((uint64_t)inst) | ((uint64_t)pc << 32);
            uint64_t log_entry2 =  ((uint64_t)br_taken | (uint64_t)is_taken_final << 1);
            fwrite(&log_entry, sizeof(uint64_t), 1, log_fp);
            fwrite(&log_entry2, sizeof(uint64_t), 1, log_fp);
        }

    } else if ((inst & 0x7f) == 0x6f || (inst & 0x7f) == 0x67) { // JAL or JALR
        jump_inst_nr++;
        if(br_taken) {
            taken_jump_nr++;
        }
        assert(br_taken);
    } else {
        assert(0 && "Not a branch or jump instruction");
    }

    total_accesses++;

    return true;
    
}


// 打印统计信息
void branchsim_print_stats() {
    
    printf("\n========== Branch Simulator Statistics ==========\n");
    printf("Configuration:\n");
    printf("  Total BR accesses: %u\n", br_inst_nr);
    printf("  Correct predictions: %u\n", correct_predictions);
    printf("  Mispredictions: %u\n", mispredictions);
    printf("  Accuracy: %.2f%%\n", 
           br_inst_nr > 0 ? 100.0 * correct_predictions / br_inst_nr : 0);
    
    printf("\nBranch/Jump Breakdown:\n");
    printf("  Branch instructions: %u\n", br_inst_nr);
    printf("  Jump instructions: %u\n", jump_inst_nr);
    printf("  Taken branches: %u\n", taken_br_nr);
    printf("  Taken jumps: %u\n", taken_jump_nr);
    printf("  Taken branch rate: %.2f%%\n", 
           br_inst_nr > 0 ? 100.0 * taken_br_nr / br_inst_nr : 0);
    printf("  Taken jump rate: %.2f%%\n", 
           jump_inst_nr > 0 ? 100.0 * taken_jump_nr / jump_inst_nr : 0);
    
    printf("================================================\n");
}