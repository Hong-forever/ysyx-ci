#include "common.h"
#include "utils.h"
#include "device.h"

static uint8_t pmem[CONFIG_MSIZE] = {0};
static uint32_t rtc_value[2] = {0};

static inline bool in_pmem(paddr_t addr) {
  return (addr - CONFIG_MBASE) < CONFIG_MSIZE;
}

uint8_t* guest_to_host(paddr_t paddr) {
    return pmem + (paddr - CONFIG_MBASE);
}

paddr_t host_to_guest(uint8_t *haddr) {
    return (haddr - pmem) + CONFIG_MBASE;
}

static void out_of_bound(paddr_t addr, bool is_write) {
    PRINTF_RED("%s address = 0x%08x is out of bound of pmem [0x%08x, 0x%08x] with the size of 0x%08x\n", is_write?"Write":"Read", addr, PMEM_LEFT, PMEM_RIGHT, CONFIG_MSIZE);
    // assert(0);
}

static word_t host_read(uint8_t *addr) {
    return *(word_t *)addr;
}

static void host_write(uint8_t *addr, word_t wdata, uint32_t wmask) {
    if(wmask & 0x1)      addr[0] = wdata & 0xff;
    if(wmask & 0x2)      addr[1] = (wdata >> 8) & 0xff;
    if(wmask & 0x4)      addr[2] = (wdata >> 16) & 0xff;
    if(wmask & 0x8)      addr[3] = (wdata >> 24) & 0xff;
}

void init_mem() {
    IFDEF(CONFIG_MEM_RANDOM, memset(pmem, rand(), CONFIG_MSIZE * sizeof(uint8_t)));
    PRINTF_BLUE("physical memory area [0x%08x, 0x%08x]\n", PMEM_LEFT, PMEM_RIGHT);
}

IFDEF(MTRACE,
void mtrace_read(paddr_t addr, uint32_t data)
{
    if (addr >= CONFIG_MTRACE_BASE && addr < CONFIG_MTRACE_BASE + CONFIG_MTRACE_SIZE) {
        PRINTF_BLUE("[Mtrace] Read addr: 0x%08x data: 0x%08x\n", addr, data);
    }
}

void mtrace_write(paddr_t addr, uint32_t data, uint32_t mask)
{
    if (addr >= CONFIG_MTRACE_BASE && addr < CONFIG_MTRACE_BASE + CONFIG_MTRACE_SIZE) {
        PRINTF_BLUE("[Mtrace] Wrtie addr: 0x%08x data: 0x%08x mask: 0x%04x\n", addr, data, mask);
    }
}
);

static word_t pmem_read(paddr_t raddr)
{
    // printf("data: 0x%x addr: 0x%x\n", (uint32_t)pmem[raddr], raddr);
    word_t ret = host_read(guest_to_host(raddr));
    IFDEF(MTRACE, mtrace_read(raddr, ret));
    return ret;
}

static void pmem_write(paddr_t waddr, word_t wdata, uint32_t wmask)
{
    // printf("waddr: 0x%08x\nwdata: 0x%08x\nmask:0x%08x\n", waddr, wdata, tra_mask(wmask));
    host_write(guest_to_host(waddr), wdata, wmask);
    IFDEF(MTRACE, mtrace_write(waddr, wdata, wmask));
}

// static word_t flash_mem[CONFIG_MSIZE] = {0x100007b7, 0x04100713, 0x00e78023, 0x00100073, 0x0000006f}; // dummy flash memory
// static word_t flash_mem[CONFIG_MSIZE] = {0x12345678, 0x13579135, 0x24682468, 0x87654321}; // dummy flash memory

extern "C" void flash_read(int32_t addr, int32_t *data) {
    // printf("flash_read addr: 0x%08x\n", addr);
    *data = pmem_read(addr + CONFIG_MBASE);
}
extern "C" void mrom_read(int32_t addr, int32_t *data) 
{
    // printf("mrom_read addr: 0x%08x\n", addr);
    *data = pmem_read(addr);
}

static uint8_t psram[2000] = {0};

extern "C" void psram_read(int32_t addr, int32_t *data) {
    *data = psram[addr];
    // printf("psram_read addr: 0x%08x, data: 0x%02x\n", addr, *data);
}

extern "C" void psram_write(int32_t addr, int32_t data, int32_t len) {
    // printf("psram_write addr: 0x%08x data: 0x%08x len: %d\n", addr, data, len);
    if(len == 1) {
        psram[addr] = data;
        // printf("psram[%x] = 0x%02x\n", addr, psram[addr]);
    }
    if(len == 2) {
        psram[addr] = data;
        psram[addr+1] = data >> 8;
        // printf("psram[%x] = 0x%02x\n", addr, psram[addr]);
        // printf("psram[%x] = 0x%02x\n", addr+1, psram[addr+1]);
    }
    if(len == 4) {
        psram[addr] = data;
        psram[addr+1] = data >> 8;
        psram[addr+2] = data >> 16;
        psram[addr+3] = data >> 24;
        // printf("psram[%x] = 0x%02x\n", addr, psram[addr]);
        // printf("psram[%x] = 0x%02x\n", addr+1, psram[addr+1]);
        // printf("psram[%x] = 0x%02x\n", addr+2, psram[addr+2]);
        // printf("psram[%x] = 0x%02x\n", addr+3, psram[addr+3]);
    }

}