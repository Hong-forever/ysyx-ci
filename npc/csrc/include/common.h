#ifndef __COMMON_H__
#define __COMMON_H__

#include <VysyxSoCFull.h>
#include "macro.h"
#include <verilated.h>

#ifdef WAVE_ENABLE
    #if WAVE_FORMAT == 1
        #include "verilated_vcd_c.h"
    #else
        #include "verilated_fst_c.h"
    #endif
#endif

#include "autoconf.h"

typedef uint32_t paddr_t;
typedef uint32_t vaddr_t;
typedef uint32_t word_t;

#ifdef SOC
#define RESET_VECTOR (CONFIG_FLASH_BASE + CONFIG_PC_RESET_OFFSET)
#else
#define RESET_VECTOR (CONFIG_SDRAM_BASE + CONFIG_PC_RESET_OFFSET)
#endif

#endif