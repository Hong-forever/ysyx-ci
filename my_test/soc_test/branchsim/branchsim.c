#include "branchsim.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include <assert.h>

uint32_t total_accesses = 0;
uint32_t correct_br_pred= 0;
uint32_t correct_jal_pred = 0;
uint32_t mis_br_pred = 0;
uint32_t mis_jal_pred = 0;

uint32_t br_inst_nr = 0;
uint32_t jal_inst_nr = 0;
uint32_t jalr_inst_nr = 0;
uint32_t taken_br_nr = 0;

#define BTB_SIZE 4

bool btb_valid[BTB_SIZE];
uint32_t btb[BTB_SIZE];

// 核心访问函数
bool branchsim_access(uint32_t inst, uint32_t pc, uint32_t target, bool is_taken) {
    
    if (inst == 0) return false;

    if((inst & 0x7f) == 0x63 || (inst & 0x7f) == 0x6f) { // Branch or JAL
        bool pred_taken = false;
        if((inst & 0x7f) == 0x63) {
            br_inst_nr++;
            pred_taken = (inst >> 31) == 1 && btb_valid[(pc>>2) % BTB_SIZE];
            if(is_taken) {
                taken_br_nr++;
            }
        } else {
            jal_inst_nr++;
            pred_taken = true; // JAL always taken
            assert(is_taken);
        }
        uint32_t predicted_target = btb[(pc>>2) % BTB_SIZE];

        bool is_correct = (pred_taken && predicted_target == target) || (!pred_taken && !is_taken);

        if(pc == 0xa0000264 && is_taken == false && is_correct == false) {
            printf("Debug: PC=0x%08x, Inst=0x%08x, Target=0x%08x, Taken=%d, PredTaken=%d, PredTarget=0x%08x, Correct=%d\n", 
                    pc, inst, target, is_taken, pred_taken, predicted_target, is_correct);
        }

    
        if (is_correct) {
            if((inst & 0x7f) == 0x63) {
                correct_br_pred++;
            } else if((inst & 0x7f) == 0x6f) {
                correct_jal_pred++;
            }
        } else {
            if((inst & 0x7f) == 0x63) {
                mis_br_pred++;
            } else if((inst & 0x7f) == 0x6f) {
                mis_jal_pred++;
            }
            btb_valid[(pc>>2) % BTB_SIZE] = true;
            btb[(pc>>2) % BTB_SIZE] = target;
        }

        bool is_taken_final = !is_correct;
        static FILE *log_fp = NULL;
        if(pc == 0xa0000264 && is_taken == false) {
            if (!log_fp) {
                log_fp = fopen("/tmp/branchsim_log.bin", "wb");
                if (!log_fp) {
                    perror("Failed to open log file");
                }
            }

            if (log_fp) {
                uint64_t log_entry = ((uint64_t)inst) | ((uint64_t)pc << 32);
                uint64_t log_entry2 =  ((uint64_t)is_taken | ((uint64_t)is_taken_final << 4) | ((uint64_t)predicted_target << 32));
                fwrite(&log_entry, sizeof(uint64_t), 1, log_fp);
                fwrite(&log_entry2, sizeof(uint64_t), 1, log_fp);
            }
        }

    } else if ((inst & 0x7f) == 0x67) { // JALR
        jalr_inst_nr++;
        assert(is_taken);
    } else {
        assert(0 && "Not a branch or jump instruction");
    }

    total_accesses++;

    return true;
    
}


// 打印统计信息
void branchsim_print_stats() {
    
    printf("\n========== Branch Simulator Statistics ==========\n");
    printf("pred_taken:\n");
    printf("  Total BR accesses: %u\n", br_inst_nr);
    printf("  Total JAL accesses: %u\n", jal_inst_nr);
    printf("  Correct BR predictions: %u(%.2f%%)\n", correct_br_pred, 
           br_inst_nr > 0 ? 100.0 * correct_br_pred / br_inst_nr : 0);
    printf("  Correct JAL predictions: %u(%.2f%%)\n", correct_jal_pred, 
           jal_inst_nr > 0 ? 100.0 * correct_jal_pred / jal_inst_nr : 0);
    printf("  Mispredicted BR: %u\n", mis_br_pred);
    printf("  Mispredicted JAL: %u\n", mis_jal_pred);
    printf("  Accuracy: %.2f%%\n", 
           (br_inst_nr + jal_inst_nr) > 0 ? 100.0 * (correct_br_pred + correct_jal_pred) / (br_inst_nr + jal_inst_nr) : 0);
    
    printf("\nBranch/Jump Breakdown:\n");
    printf("  Branch instructions: %u\n", br_inst_nr);
    printf("  JAL instructions: %u\n", jal_inst_nr );
    printf("  JALR instructions: %u\n", jalr_inst_nr);
    printf("  Taken branches: %u\n", taken_br_nr);
    printf("  Taken branch rate: %.2f%%\n", 
           br_inst_nr > 0 ? 100.0 * taken_br_nr / br_inst_nr : 0);
    
    printf("================================================\n");
}