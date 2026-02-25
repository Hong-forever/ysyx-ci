#include "common.h"
#include "utils.h"
#include "isa.h"

extern uint64_t g_nr_guest_inst;
extern uint64_t g_cycle;


uint64_t alu_inst_nr, ls_inst_nr, br_inst_nr, csr_inst_nr, fence_i_inst_nr, jal_inst_nr, jalr_inst_nr;

uint64_t ls_delay_total;
uint64_t icache_miss, icache_miss_penal;

uint64_t ex_br_inst_nr, ex_jalr_inst_nr;
uint64_t ex_jal_inst_nr = -1;  // 由于流水线原因，ebreak指令后面会多一条jal指令，导致ex_jal_inst_nr比jal_inst_nr多1，所以初始化为-1
uint64_t ex_taken_br_nr;

uint64_t ex_taken_final_br_nr, ex_taken_final_jalr_nr;
uint64_t ex_taken_final_jal_nr = -1;  // 由于流水线原因，ebreak指令后面会多一条jal指令，导致ex_taken_final_jal_nr比ex_jal_inst_nr多1，所以初始化为-1

static inline uint64_t rdtime() {
    return g_cycle;
}

extern "C" void iamat_cal(int begin_flag, int end_flag) {
    static uint64_t delay_begin, delay_end;
    if(begin_flag) {
        delay_begin = rdtime();
    }
    if(end_flag) {
        delay_end = rdtime();
        icache_miss_penal += delay_end - delay_begin;
        icache_miss ++;
    }
}

extern "C" void ls_delay_cal(int begin_flag, int end_flag) {
    static uint64_t delay_begin, delay_end;
    if(begin_flag) {
        delay_begin = rdtime();
    }
    if(end_flag) {
        delay_end = rdtime();
        ls_delay_total += (delay_end - delay_begin + 1);
    }
}

extern "C" void jump_br_cal(uint32_t inst, uint32_t pc, uint32_t target, bool is_taken, bool is_taken_final) {
    if((inst & 0x7f) == 0x6f || (inst & 0x7f) == 0x67) { // JAL or JALR
        if((inst & 0x7f) == 0x6f) {
            ex_jal_inst_nr++;
            if(is_taken_final) {
                ex_taken_final_jal_nr++;
            }
        } else {
            ex_jalr_inst_nr++;
        }
        assert(is_taken);
    } else if((inst & 0x7f) == 0x63) { // Branch
        ex_br_inst_nr++;
        if(is_taken_final) {
            ex_taken_final_br_nr++;
        }
        if(is_taken) {
            ex_taken_br_nr++;
        }
    }

    if((inst & 0x7f) == 0x63 || (inst & 0x7f) == 0x6f) { // Branch or JAL
        static FILE *log_fp = NULL;
        if (!log_fp) {
            log_fp = fopen("/tmp/npc_branch_log.bin", "wb");
            if (!log_fp) {
                perror("Failed to open log file");
            }
        }

        if (log_fp) {
            uint64_t log_entry = ((uint64_t)inst) | ((uint64_t)pc << 32);
            uint64_t log_entry2 = ((uint64_t)is_taken | (uint64_t)is_taken_final << 1);
            fwrite(&log_entry, sizeof(uint64_t), 1, log_fp);
            fwrite(&log_entry2, sizeof(uint64_t), 1, log_fp);
        }    
    }
}

extern "C" void wb_inst_cycle_cal(uint32_t pc, uint32_t inst) {

        switch (inst & 0x7f) {
            case 0x13: 
            case 0x17: 
            case 0x33: 
            case 0x37: alu_inst_nr++;  break;
            case 0x63: br_inst_nr++;  break;
            case 0x67: jalr_inst_nr++; break;
            case 0x6f: jal_inst_nr++; break;
            case 0x03: 
            case 0x23: ls_inst_nr++;  break;
            case 0x73: csr_inst_nr++; break;
            case 0x0f: fence_i_inst_nr++; break;
            default: break;
        }
}

void perf_cal() {

    printf("\n===== Performance Calulation =====\n");
    printf("Total Cycle: %lu\n", g_cycle);
    printf("Total Inst : %lu\n", g_nr_guest_inst);
    if (g_cycle != 0) {
        printf("IPC        : %.2f\n", (double)g_nr_guest_inst / (double)g_cycle);
    } else {
        printf("IPC        : INF\n");
    }

    printf("\n===== Proportion =====\n");
    printf("ALU Inst(alu): %lu(%.2f%%)\n", alu_inst_nr, (double)alu_inst_nr / (double)g_nr_guest_inst * 100);
    printf("L/S Inst     : %lu(%.2f%%)\n", ls_inst_nr,  (double)ls_inst_nr  / (double)g_nr_guest_inst * 100);
    printf("Branch Inst  : %lu(%.2f%%)\n", br_inst_nr,  (double)br_inst_nr  / (double)g_nr_guest_inst * 100);
    printf("JAL Inst     : %lu(%.2f%%)\n", jal_inst_nr,  (double)jal_inst_nr  / (double)g_nr_guest_inst * 100);
    printf("JALR Inst    : %lu(%.2f%%)\n", jalr_inst_nr,  (double)jalr_inst_nr  / (double)g_nr_guest_inst * 100);
    printf("CSR Inst     : %lu(%.2f%%)\n", csr_inst_nr, (double)csr_inst_nr / (double)g_nr_guest_inst * 100);
    printf("FENCE Inst   : %lu(%.2f%%)\n", fence_i_inst_nr, (double)fence_i_inst_nr / (double)g_nr_guest_inst * 100);

    double miss_per = (double)icache_miss / (double)(g_nr_guest_inst);
    double hit_per = (double)1 - miss_per;
    double miss_penalty = (double)icache_miss_penal / (double)icache_miss;
    double iamat = miss_penalty * miss_per + 2 * hit_per;
    printf("\n===== MEM Average Delay =====\n");
    printf("Inst Delay   : %.2f\n", iamat);
    printf("L/S Delay    : %.2f\n", ls_inst_nr  ? (double)ls_delay_total / (double)ls_inst_nr : 0);

    printf("\n===== IAMAT =====\n");
    printf("IAMAT        : %.2f\n", iamat);
    printf("IHIT         : %.2f%%\n", hit_per * 100);
    printf("MISSPENALTY  : %.2f cycles\n", miss_penalty);

    printf("\n===== BR/JAL =====\n");
    printf("TAKEN BR     : %lu(%.2f%%)\n", ex_taken_br_nr, (double)ex_taken_br_nr / (double)ex_br_inst_nr * 100);
    printf("TAKEN JAL    : %lu(%d%%)\n", jal_inst_nr, 100);
    printf("FINAL BR T   : %lu(HIT: %.2f%%)\n", ex_taken_final_br_nr, 100 - (double)ex_taken_final_br_nr / (double)ex_br_inst_nr * 100);
    printf("FINAL JAL T  : %lu(HIT: %.2f%%)\n", ex_taken_final_jal_nr, 100 - (double)ex_taken_final_jal_nr / (double)ex_jal_inst_nr * 100);
    printf("Accuracy     : %.2f%%\n", 100 - (ex_taken_final_br_nr + ex_taken_final_jal_nr) / (double)(ex_br_inst_nr + ex_jal_inst_nr) * 100);

    printf("\n==================================\n");
}
