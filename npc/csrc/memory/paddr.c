#include "common.h"
#include "utils.h"
#include "device.h"

static uint8_t* pmem = NULL;
static uint32_t rtc_value[2] = {0};



uint8_t *guest_to_host(paddr_t paddr) {
    return pmem + paddr - CONFIG_MBASE;
}

paddr_t host_to_guest(uint8_t *haddr) {
    return haddr - pmem + CONFIG_MBASE;
}

static void out_of_bound(paddr_t addr, bool is_write) {
    PRINTF_RED("%s address = 0x%08x is out of bound of pmem [0x%08x, 0x%08x] with the size of 0x%08x\n", is_write?"Write":"Read", addr, PMEM_LEFT, PMEM_RIGHT, CONFIG_MSIZE);
    // assert(0);
}

void init_mem() {
    pmem = (uint8_t *)malloc(CONFIG_MSIZE);
    assert(pmem);
    IFDEF(CONFIG_MEM_RANDOM, memset(pmem, rand(), CONFIG_MSIZE));
    PRINTF_BLUE("physical memory area [0x%08x, 0x%08x]\n", PMEM_LEFT, PMEM_RIGHT);
}

IFDEF(CONFIG_MTRACE,
void mtrace_read(paddr_t addr, uint32_t data)
{
    if (addr >= CONFIG_MTRACE_BASE && addr < CONFIG_MTRACE_BASE + CONFIG_MTRACE_SIZE) {
        PRINTF_BLUE("[Mtrace] Read addr: 0x%08x data: 0x%08x\n", addr, data);
    }
}

void mtrace_write(paddr_t addr, uint32_t data, uint32_t len)
{
    if (addr >= CONFIG_MTRACE_BASE && addr < CONFIG_MTRACE_BASE + CONFIG_MTRACE_SIZE) {
        PRINTF_BLUE("[Mtrace] Wrtie addr: 0x%08x data: 0x%08x len: 0x%08x\n", addr, data, len);
    }
}
);

static word_t pmem_read(paddr_t raddr)
{
    word_t ret = host_read(guest_to_host(raddr&~0x3));
    IFDEF(CONFIG_MTRACE, mtrace_read(raddr, ret));
    return ret;
}

static void pmem_write(paddr_t waddr, word_t wdata, uint32_t wmask)
{
    // printf("waddr: 0x%08x\nwdata: 0x%08x\nmask:0x%08x\n", waddr, wdata, tra_mask(wmask));
    uint32_t len = 0;
    switch(wmask)
    {
        case 0x1 : case 0x2 : case 0x4 : case 0x8 :
            len = 1; break;
        case 0x3 : case 0xc :
            len = 2; break;
        case 0xf :
            len = 4; break;
        default:
            break;
    }
    word_t data = wdata >> (waddr&0x3)*8;
    host_write(guest_to_host(waddr), data, len);
    // if(waddr == 0x80295bd5) printf("data: 0x%x addr: 0x%x\n", data, waddr);
    IFDEF(CONFIG_MTRACE, mtrace_write(waddr, data, len));
}

extern "C" word_t paddr_read(paddr_t raddr) {
    if (in_pmem(raddr)) {
        // printf("paddr_read addr: 0x%08x\n", raddr);
        return pmem_read(raddr);
    } 
    else {
        if ((raddr & ~0x7u) == RTC_MMIO) {
            if (raddr & 0x4) {
                uint64_t us = get_time();
                if (rtc_value[0] == 0 && rtc_value[1] == 0) {
                    rtc_value[0] = boot_time & 0xffffffff;
                    rtc_value[1] = (boot_time >> 32) & 0xffffffff;
                    return rtc_value[1];
                } else {
                    rtc_value[0] = us & 0xffffffff;
                    rtc_value[1] = (us >> 32) & 0xffffffff;
                    return rtc_value[1];
                }
            } else {
                return rtc_value[0];
            }
        }

        out_of_bound(raddr, false);
        return 0;
    }
}

extern "C" void paddr_write(paddr_t waddr, word_t wdata, uint32_t wmask) {
    if (in_pmem(waddr)) {
        pmem_write(waddr, wdata, wmask);
    }
    else {
        if ((waddr & ~0x3u) == SERIAL_MMIO) {
            // memory-mapped serial port write
            assert(wmask == 0x1);
            putc((char)(wdata & 0xff), stderr);
        } else {
            out_of_bound(waddr, true);
        }
    }
}
