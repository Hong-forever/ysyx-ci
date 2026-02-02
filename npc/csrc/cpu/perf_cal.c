#include "common.h"
#include "utils.h"
#include "isa.h"

extern uint64_t g_nr_guest_inst;

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

uint64_t ls_delay_total, delay_begin, delay_end;

uint64_t total_cycle;
extern "C" void per_cyc_get(int mcycleh, int mcyclel) {
    total_cycle = ((uint64_t)mcycleh << 32) | (uint64_t)mcyclel;
}

static inline uint64_t rdtime() {
    return total_cycle;
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

extern "C" void ls_delay_cal(int begin_flag, int end_flag) {
    if(begin_flag) {
        delay_begin = rdtime();
    }
    if(end_flag) {
        delay_end = rdtime();
        ls_delay_total += (delay_end - delay_begin + 1);
    }
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
            // printf("WB Cal: pc=0x%x, type=%s, cycle=%lu\n", pc, inst_buffer[i].type == IT_ALU_ONE ? "ALU_ONE" : 
            //                                                     inst_buffer[i].type == IT_ALU_MUL ? "ALU_MUL" :
            //                                                     inst_buffer[i].type == IT_ALU_DIV ? "ALU_DIV" :
            //                                                     inst_buffer[i].type == IT_LS      ? "LS"      :
            //                                                     inst_buffer[i].type == IT_BR      ? "BR"      :
            //                                                     inst_buffer[i].type == IT_CSR     ? "CSR"     : "UNKNOWN",
            //                                                 cycle);
            break;
        }
    }
}

void perf_cal() {


    printf("\n===== Performance Calulation =====\n");
    printf("Total Cycle: %lu\n", total_cycle);
    printf("Total Inst : %lu\n", g_nr_guest_inst);
    if (total_cycle != 0) {
        printf("IPC        : %.2f\n", (double)g_nr_guest_inst / (double)total_cycle);
    } else {
        printf("IPC        : INF\n");
    }
    printf("\n===== Instruction Count =====\n");
    printf("IFU  Inst: %lu\n", ifu_inst);
    printf("Dec  Inst: %lu\n", dec_inst);
    printf("Exec Inst: %lu\n", exec_inst);
    printf("L/S  Data: %lu\n", ls_data_nr);


    printf("\n===== Proportion =====\n");
    printf("ALU Inst(one): %u(%.2f%%)\n", one_inst_log.inst_nr, (double)one_inst_log.inst_nr / (double)g_nr_guest_inst * 100);
    printf("ALU Inst(mul): %u(%.2f%%)\n", mul_inst_log.inst_nr, (double)mul_inst_log.inst_nr / (double)g_nr_guest_inst * 100);
    printf("ALU Inst(div): %u(%.2f%%)\n", div_inst_log.inst_nr, (double)div_inst_log.inst_nr / (double)g_nr_guest_inst * 100);
    printf("L/S Inst     : %u(%.2f%%)\n", ls_inst_log.inst_nr,  (double)ls_inst_log.inst_nr  / (double)g_nr_guest_inst * 100);
    printf("Branch Inst  : %u(%.2f%%)\n", br_inst_log.inst_nr,  (double)br_inst_log.inst_nr  / (double)g_nr_guest_inst * 100);
    printf("CSR Inst     : %u(%.2f%%)\n", csr_inst_log.inst_nr, (double)csr_inst_log.inst_nr / (double)g_nr_guest_inst * 100);

    printf("\n===== Inst Exe Average Cycle =====\n");
    printf("ALU Inst(one): %.2f\n", one_inst_log.inst_nr ? (double)one_inst_log.cycle / (double)one_inst_log.inst_nr : 0);
    printf("ALU Inst(mul): %.2f\n", mul_inst_log.inst_nr ? (double)mul_inst_log.cycle / (double)mul_inst_log.inst_nr : 0);
    printf("ALU Inst(div): %.2f\n", div_inst_log.inst_nr ? (double)div_inst_log.cycle / (double)div_inst_log.inst_nr : 0);
    printf("L/S Inst     : %.2f\n", ls_inst_log.inst_nr  ? (double)ls_inst_log.cycle  / (double)ls_inst_log.inst_nr  : 0);
    printf("Branch Inst  : %.2f\n", br_inst_log.inst_nr  ? (double)br_inst_log.cycle  / (double)br_inst_log.inst_nr  : 0);
    printf("CSR Inst     : %.2f\n", csr_inst_log.inst_nr ? (double)csr_inst_log.cycle / (double)csr_inst_log.inst_nr : 0);

    printf("\n===== L/S Average Delay =====\n");
    printf("L/S Delay    : %.2f\n", ls_inst_log.inst_nr  ? (double)ls_delay_total / (double)ls_inst_log.inst_nr : 0);

    printf("\n==================================\n");


}
