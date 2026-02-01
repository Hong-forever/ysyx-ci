#include "common.h"
#include "utils.h"
#include "isa.h"

extern uint64_t g_nr_guest_inst;

#define TOTAL_CYCLE       ((uint64_t)(extra_cpu.mcycleh) << 32 | (uint64_t)extra_cpu.mcyclel)
#define TOTAL_INST_VALID  (g_nr_guest_inst)

enum Inst_Type {
    IT_ALU_ONE = 0x01,
    IT_ALU_MUL = 0x02,
    IT_ALU_DIV = 0x04,
    IT_LS      = 0x08,
    IT_BR      = 0x10,
    IT_CSR     = 0x20
};

typedef struct {
    word_t pc;
    uint8_t type;
    uint64_t begin;
} Inst_buf;

typedef struct {
    word_t inst_nr;
    uint64_t cycle;
} Inst_log;

Inst_buf inst_buffer[5];
Inst_log one_inst_log, mul_inst_log, div_inst_log, ls_inst_log, br_inst_log, csr_inst_log;
uint64_t ifu_inst, dec_inst, exec_inst, ls_data_nr;

static inline uint64_t rdtime() {
    return TOTAL_CYCLE;
}

extern "C" void ifetch_inst_get_nr_cal(int inst, int pc) {
    inst_buffer[ifu_inst%5].pc = pc;
    inst_buffer[ifu_inst%5].begin = rdtime();
    ifu_inst++;
}

extern "C" void decoder_inst_type_cal(int inst_type, int pc) {
    for(int i = 0; i < 5; i++) {
        if (inst_buffer[i].pc == pc) {
            inst_buffer[i].type = inst_type;
            break;
        }
    }
    dec_inst++;
    // printf("Decoder Cal: inst_type=0x%x, total %lu\n", inst_type, dec_inst);
}

extern "C" void exec_inst_cal() {
    exec_inst++;
}

extern "C" void ls_data_cal() {
    ls_data_nr++;
}

extern "C" void wb_inst_cycle_cal(int pc) {
    uint64_t end = rdtime();
    for(int i = 0; i < 5; i++) {
        if (inst_buffer[i].pc == pc) {
            uint64_t cycle = end - inst_buffer[i].begin + 1;
            switch (inst_buffer[i].type) {
                case IT_ALU_ONE: one_inst_log.inst_nr++; one_inst_log.cycle += cycle; break;
                case IT_ALU_MUL: mul_inst_log.inst_nr++; mul_inst_log.cycle += cycle; break;
                case IT_ALU_DIV: div_inst_log.inst_nr++; div_inst_log.cycle += cycle; break;
                case IT_LS:      ls_inst_log.inst_nr++;  ls_inst_log.cycle  += cycle; break;
                case IT_BR:      br_inst_log.inst_nr++;  br_inst_log.cycle  += cycle; break;
                case IT_CSR:     csr_inst_log.inst_nr++; csr_inst_log.cycle += cycle; break;
                default:                                                              break;
            }
            break;
        }
    }
}

void perf_cal() {
    uint64_t total_cycle = TOTAL_CYCLE;
    uint64_t total_inst_valid = TOTAL_INST_VALID;

    printf("===== Performance Calulation =====\n");
    printf("Total Cycle: %lu\n", total_cycle);
    printf("Total Valid Inst: %lu\n", total_inst_valid);
    if (total_cycle != 0) {
        printf("IPC: %.2f\n", (double)total_inst_valid / (double)total_cycle);
    } else {
        printf("IPC: INF\n");
    }
    printf("\nIFU Inst: %lu\n", ifu_inst);
    printf("Decoder Inst: %lu\n", dec_inst);
    printf("Exec   Inst: %lu\n", exec_inst);
    printf("Load/Store Data: %lu\n", ls_data_nr);

    printf("\nInstruction Type Breakdown:\n");
    printf("ALU Inst(one):   %u(%.2f%%)\n", one_inst_log.inst_nr, (double)one_inst_log.inst_nr / (double)total_inst_valid * 100);
    printf("ALU Inst(mul):   %u(%.2f%%)\n", mul_inst_log.inst_nr, (double)mul_inst_log.inst_nr / (double)total_inst_valid * 100);
    printf("ALU Inst(div):   %u(%.2f%%)\n", div_inst_log.inst_nr, (double)div_inst_log.inst_nr / (double)total_inst_valid * 100);
    printf("Load/Store Inst: %u(%.2f%%)\n", ls_inst_log.inst_nr, (double)ls_inst_log.inst_nr / (double)total_inst_valid * 100);
    printf("Branch Inst:     %u(%.2f%%)\n", br_inst_log.inst_nr, (double)br_inst_log.inst_nr / (double)total_inst_valid * 100);
    printf("CSR Inst:        %u(%.2f%%)\n", csr_inst_log.inst_nr, (double)csr_inst_log.inst_nr / (double)total_inst_valid * 100);
    printf("==================================\n");
}
