#include "common.h"
#include "utils.h"
#include "isa.h"

extern uint64_t g_nr_guest_inst;

#define TOTAL_CYCLE       ((uint64_t)(extra_cpu.mcycleh) << 32 | (uint64_t)extra_cpu.mcyclel)
#define TOTAL_INST_VALID  (g_nr_guest_inst)

uint64_t ifu_inst = 0;
uint64_t dec_inst = 0;

uint32_t alu_inst_one = 0;
uint32_t alu_inst_mul = 0;
uint32_t alu_inst_div = 0;
uint32_t ls_inst = 0;
uint32_t br_inst = 0;
uint32_t csr_inst_num = 0;

extern "C" void ifetch_inst_get_nr_cal(int valid) {
    ifu_inst += valid & 0x1;
}

extern "C" void decoder_inst_type_cal(int inst_type, int inst_valid) {
    switch (inst_type) {
        case 0x01: alu_inst_one++; break;
        case 0x02: alu_inst_mul++; break;
        case 0x04: alu_inst_div++; break;
        case 0x08: ls_inst++; break;
        case 0x10: br_inst++; break;
        case 0x20: csr_inst_num++; break;
        default: break;
    }
    dec_inst += inst_valid & 0x1;
    printf("Decoder Cal: inst_type=0x%x, inst_valid=%d, total %lu\n", inst_type, inst_valid, dec_inst);
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
    printf("\nIFU Inst: %lu, Decoded Inst: %lu\n", ifu_inst, dec_inst);
    if (dec_inst != 0) {
        printf("Decode Efficiency: %.2f%%\n", (double)dec_inst / (double)ifu_inst * 100.0);
    } else {
        printf("Decode Efficiency: 0.00%%\n");
    }
    printf("ALU Inst(one):   %u\n", alu_inst_one);
    printf("ALU Inst(mul):   %u\n", alu_inst_mul);
    printf("ALU Inst(div):   %u\n", alu_inst_div);
    printf("Load/Store Inst: %u\n", ls_inst);
    printf("Branch Inst:     %u\n", br_inst);
    printf("CSR Inst:        %u\n", csr_inst_num);
    printf("==================================\n");
}
