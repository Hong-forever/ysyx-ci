#ifndef __COMMON_H__
#define __COMMON_H__

#include <Vtop.h>
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

#define PMEM_LEFT  ((paddr_t)CONFIG_MBASE)
#define PMEM_RIGHT ((paddr_t)CONFIG_MBASE + CONFIG_MSIZE - 1)
#define RESET_VECTOR (PMEM_LEFT + CONFIG_PC_RESET_OFFSET)

static inline bool in_pmem(paddr_t addr) {
    return (addr - CONFIG_MBASE) < (CONFIG_MSIZE << 2);
}

static inline word_t host_read(uint8_t *addr) {
    return *(word_t *)addr;
}

static inline void host_write(uint8_t *addr, word_t wdata, uint32_t mask) {
    switch (mask)
    {
        case 1: *(uint8_t  *)addr = wdata; break;
        case 2: *(uint16_t *)addr = wdata; break;
        case 4: *(uint32_t *)addr = wdata; break;
        default: printf("Error write!\n"); assert(0); break;
    }
}


#endif