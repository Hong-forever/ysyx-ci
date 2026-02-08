#include "common.h"
#include "utils.h"
#include "isa.h"

extern uint64_t g_nr_guest_inst;

enum Inst_Type {
    IT_ALU_ALU = 0x01,
    IT_LS      = 0x02,
    IT_BR      = 0x04,
    IT_CSR     = 0x08
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
Inst_log alu_inst_log, ls_inst_log, br_inst_log, csr_inst_log;
uint64_t ifu_inst, dec_inst, exec_inst, ls_data_nr;

uint64_t if_delay_total, ls_delay_total;

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

extern "C" void ifetch_delay_cal(int begin_flag, int end_flag) {
    static uint64_t delay_begin, delay_end;
    if(begin_flag) {
        delay_begin = rdtime();
        // printf("IF Delay Begin: %lu\n", delay_begin);
    }
    if(end_flag) {
        delay_end = rdtime();
        if_delay_total += (delay_end - delay_begin + 1);
        // printf("IF Delay End: %lu, Total IF Delay: %lu\n", delay_end, if_delay_total);
    }
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
    static uint64_t delay_begin, delay_end;
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
                case IT_ALU_ALU: alu_inst_log.inst_nr++; alu_inst_log.cycle += cycle; break;
                case IT_LS:      ls_inst_log.inst_nr++;  ls_inst_log.cycle  += cycle; break;
                case IT_BR:      br_inst_log.inst_nr++;  br_inst_log.cycle  += cycle; break;
                case IT_CSR:     csr_inst_log.inst_nr++; csr_inst_log.cycle += cycle; break;
                default:                                                              break;
            }
            // printf("WB Cal: pc=0x%x, type=%s, cycle=%lu\n", pc, inst_buffer[i].type == IT_ALU_ALU ? "ALU_ALU" : 
            //                                                     inst_buffer[i].type == IT_LS      ? "LS"      :
            //                                                     inst_buffer[i].type == IT_BR      ? "BR"      :
            //                                                     inst_buffer[i].type == IT_CSR     ? "CSR"     : "UNKNOWN",
            //                                                 cycle);
            break;
        }
    }
}
void perf_reset() {
    ifu_inst = 0;
    dec_inst = 0;
    exec_inst = 0;
    ls_data_nr = 0;
    total_cycle = 0;
    if_delay_total = 0;
    ls_delay_total = 0;
    memset(inst_buffer, 0, sizeof(inst_buffer));
    memset(&alu_inst_log, 0, sizeof(alu_inst_log));
    memset(&ls_inst_log, 0, sizeof(ls_inst_log));
    memset(&br_inst_log, 0, sizeof(br_inst_log));
    memset(&csr_inst_log, 0, sizeof(csr_inst_log));
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
    printf("ALU Inst(alu): %u(%.2f%%)\n", alu_inst_log.inst_nr, (double)alu_inst_log.inst_nr / (double)g_nr_guest_inst * 100);
    printf("L/S Inst     : %u(%.2f%%)\n", ls_inst_log.inst_nr,  (double)ls_inst_log.inst_nr  / (double)g_nr_guest_inst * 100);
    printf("Branch Inst  : %u(%.2f%%)\n", br_inst_log.inst_nr,  (double)br_inst_log.inst_nr  / (double)g_nr_guest_inst * 100);
    printf("CSR Inst     : %u(%.2f%%)\n", csr_inst_log.inst_nr, (double)csr_inst_log.inst_nr / (double)g_nr_guest_inst * 100);

    printf("\n===== Inst Exe Average Cycle =====\n");
    printf("ALU Inst(alu): %.2f\n", alu_inst_log.inst_nr ? (double)alu_inst_log.cycle / (double)alu_inst_log.inst_nr : 0);
    printf("L/S Inst     : %.2f\n", ls_inst_log.inst_nr  ? (double)ls_inst_log.cycle  / (double)ls_inst_log.inst_nr  : 0);
    printf("Branch Inst  : %.2f\n", br_inst_log.inst_nr  ? (double)br_inst_log.cycle  / (double)br_inst_log.inst_nr  : 0);
    printf("CSR Inst     : %.2f\n", csr_inst_log.inst_nr ? (double)csr_inst_log.cycle / (double)csr_inst_log.inst_nr : 0);

    printf("\n===== MEM Average Delay =====\n");
    printf("Inst Delay   : %.2f\n", (double)if_delay_total / (double)g_nr_guest_inst);
    printf("L/S Delay    : %.2f\n", ls_inst_log.inst_nr  ? (double)ls_delay_total / (double)ls_inst_log.inst_nr : 0);

    printf("\n==================================\n");


}
