#include "common.h"
#include "utils.h"
#include "isa.h"

extern uint64_t g_nr_guest_inst;
extern uint64_t g_cycle;

enum Inst_Type {
    IT_ALU_ALU = 0x01,
    IT_LS      = 0x02,
    IT_BR      = 0x04,
    IT_CSR     = 0x08,
    IT_FENCE_I = 0x10
};

typedef struct {
    uint32_t pc;
    uint8_t type;
} Inst_buf;

typedef struct {
    word_t inst_nr;
} Inst_log;

Inst_buf inst_buffer[5];
Inst_log alu_inst_log, ls_inst_log, br_inst_log, csr_inst_log, fence_i_inst_log;
uint64_t ifu_inst, dec_inst, exec_inst, wb_inst, ls_data_nr;
uint64_t act_dec_inst, act_ex_inst, act_wb_inst;

uint64_t ls_delay_total;
uint64_t icache_miss, icache_miss_penal;

static inline uint64_t rdtime() {
    return g_cycle;
}

extern "C" void ifetch_inst_get_nr_cal(uint32_t pc) {
    inst_buffer[ifu_inst % 5].pc = pc;
    ifu_inst++;
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



extern "C" void decoder_inst_type_cal(uint32_t pc, uint32_t inst, int inst_type) {
    static uint8_t flag = 0;
    if (pc != 0 && inst != 0) {
        flag = 1;
        inst_buffer[dec_inst % 5].type = inst_type;
        act_dec_inst++;
    }
    if(flag) dec_inst++;
    // printf("Decoder Cal: inst_type=0x%x, total %lu\n", inst_type, dec_inst);
}

extern "C" void exec_inst_cal(uint32_t pc, uint32_t inst) {
    static uint8_t flag = 0;
    if (pc != 0 && inst != 0) {
        flag = 1;
        act_ex_inst++;
    }
    if(flag) exec_inst++;
}

extern "C" void ls_data_cal() {
    ls_data_nr++;
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

extern "C" void wb_inst_cycle_cal(uint32_t pc, uint32_t inst) {
    static uint8_t flag = 0;
    if(pc != 0 && inst != 0 ) {
        printf("WB Cal: PC=0x%08x, inst=0x%08x\n", pc, inst);
        flag = 1;
        act_wb_inst++;
        if(pc != inst_buffer[wb_inst % 5].pc) {
            printf("Error: PC mismatch in WB stage! Expected 0x%08x, got 0x%08x\n", inst_buffer[wb_inst % 5].pc, pc);
            assert(0);
        }

        switch (inst_buffer[wb_inst % 5].type) {
            case IT_ALU_ALU: alu_inst_log.inst_nr++; break;
            case IT_LS:      ls_inst_log.inst_nr++;  break;
            case IT_BR:      br_inst_log.inst_nr++;  break;
            case IT_CSR:     csr_inst_log.inst_nr++; break;
            case IT_FENCE_I: fence_i_inst_log.inst_nr++; break;
            default: break;
        }
    }
    if(flag) wb_inst++;
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
    printf("\n===== Instruction Count =====\n");
    printf("IFU  Inst: %lu\n", ifu_inst);
    printf("Dec  Inst: %lu\n", act_dec_inst);
    printf("Exec Inst: %lu\n", act_ex_inst);
    printf("WB   Inst: %lu\n", act_wb_inst);
    printf("L/S  Data: %lu\n", ls_data_nr);


    printf("\n===== Proportion =====\n");
    printf("ALU Inst(alu): %u(%.2f%%)\n", alu_inst_log.inst_nr, (double)alu_inst_log.inst_nr / (double)g_nr_guest_inst * 100);
    printf("L/S Inst     : %u(%.2f%%)\n", ls_inst_log.inst_nr,  (double)ls_inst_log.inst_nr  / (double)g_nr_guest_inst * 100);
    printf("Branch Inst  : %u(%.2f%%)\n", br_inst_log.inst_nr,  (double)br_inst_log.inst_nr  / (double)g_nr_guest_inst * 100);
    printf("CSR Inst     : %u(%.2f%%)\n", csr_inst_log.inst_nr, (double)csr_inst_log.inst_nr / (double)g_nr_guest_inst * 100);
    printf("FENCE Inst   : %u(%.2f%%)\n", fence_i_inst_log.inst_nr, (double)fence_i_inst_log.inst_nr / (double)g_nr_guest_inst * 100);

    double miss_per = (double)icache_miss / (double)(g_nr_guest_inst);
    double hit_per = (double)1 - miss_per;
    double miss_penalty = (double)icache_miss_penal / (double)icache_miss;
    double iamat = miss_penalty * miss_per + 2 * hit_per;
    printf("\n===== MEM Average Delay =====\n");
    printf("Inst Delay   : %.2f\n", iamat);
    printf("L/S Delay    : %.2f\n", ls_inst_log.inst_nr  ? (double)ls_delay_total / (double)ls_inst_log.inst_nr : 0);

    printf("\n===== IAMAT =====\n");
    printf("IAMAT        : %.2f\n", iamat);
    printf("IHIT         : %.2f%%\n", hit_per * 100);
    printf("MISSPENALTY  : %.2f cycles\n", miss_penalty);

    printf("\n===== DAMAT =====\n");
    printf("L/S Delay    : %.2f\n", ls_inst_log.inst_nr  ? (double)ls_delay_total / (double)ls_inst_log.inst_nr : 0);

    printf("\n==================================\n");
}
