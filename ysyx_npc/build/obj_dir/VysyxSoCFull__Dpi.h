// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Prototypes for DPI import and export functions.
//
// Verilator includes this file in all generated .cpp files that use DPI functions.
// Manually include this file where DPI .c import functions are declared to ensure
// the C functions match the expectations of the DPI imports.

#ifndef VERILATED_VYSYXSOCFULL__DPI_H_
#define VERILATED_VYSYXSOCFULL__DPI_H_  // guard

#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif


    // DPI IMPORTS
    // DPI import at /home/hhh/Desktop/ysyx/ysyx-workbench/npc/vsrc/wbu.v:152:34
    extern void cpu_value(int diff_skip, int valid, int inst, int inst_addr, int pc, int gpr0, int gpr1, int gpr2, int gpr3, int gpr4, int gpr5, int gpr6, int gpr7, int gpr8, int gpr9, int gpr10, int gpr11, int gpr12, int gpr13, int gpr14, int gpr15, int gpr16, int gpr17, int gpr18, int gpr19, int gpr20, int gpr21, int gpr22, int gpr23, int gpr24, int gpr25, int gpr26, int gpr27, int gpr28, int gpr29, int gpr30, int gpr31, int mepc, int mtvec, int mstatus, int mcause, int mcyclel, int mcycleh, int mvendorid, int marchid);
    // DPI import at /home/hhh/Desktop/ysyx/ysyx-workbench/ysyxSoC/perip/flash/flash.v:84:30
    extern void flash_read(int addr, int* data);
    // DPI import at /home/hhh/Desktop/ysyx/ysyx-workbench/npc/vsrc/exec.v:264:34
    extern void ftrace_exec(int pc, int dnpc, int rs1, int rd, int imm, int op);
    // DPI import at /home/hhh/Desktop/ysyx/ysyx-workbench/ysyxSoC/build/ysyxSoCFull.v:5402:30
    extern void mrom_read(int raddr, int* rdata);
    // DPI import at /home/hhh/Desktop/ysyx/ysyx-workbench/npc/vsrc/wbu.v:150:34
    extern void trap(int reg_data, int halt_pc);

#ifdef __cplusplus
}
#endif

#endif  // guard
