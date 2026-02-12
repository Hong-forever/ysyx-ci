#include "memory.h"
#include "utils.h"
#include "device.h"

static uint8_t *pmem = NULL;
static uint32_t rtc_value[2] = {0};

uint8_t* guest_to_host(paddr_t paddr) {
    if(in_mrom(paddr))  
        return pmem + paddr - CONFIG_MROM_BASE;
    else if(in_flash(paddr))  
        return pmem + paddr - CONFIG_FLASH_BASE + CONFIG_MROM_SIZE;
    else if(in_psram(paddr))  
        return pmem + paddr - CONFIG_PSRAM_BASE + CONFIG_MROM_SIZE + CONFIG_FLASH_SIZE;
    else if(in_sdram(paddr))  
        return pmem + paddr - CONFIG_SDRAM_BASE + CONFIG_MROM_SIZE + CONFIG_FLASH_SIZE + CONFIG_PSRAM_SIZE;
    else return NULL;
}
paddr_t host_to_guest(uint8_t *haddr) { 
    if((haddr-pmem) < CONFIG_MROM_SIZE) 
        return haddr - pmem + CONFIG_MROM_BASE;
    else if((haddr-pmem) < (CONFIG_MROM_SIZE + CONFIG_FLASH_SIZE)) 
        return haddr - pmem - CONFIG_MROM_SIZE + CONFIG_FLASH_BASE;
    else if((haddr-pmem) < (CONFIG_MROM_SIZE + CONFIG_FLASH_SIZE + CONFIG_PSRAM_SIZE)) 
        return haddr - pmem - CONFIG_MROM_SIZE - CONFIG_FLASH_SIZE + CONFIG_PSRAM_BASE;
    else if((haddr-pmem) < (CONFIG_MROM_SIZE + CONFIG_FLASH_SIZE + CONFIG_PSRAM_SIZE + CONFIG_SDRAM_SIZE)) 
        return haddr - pmem - CONFIG_MROM_SIZE - CONFIG_FLASH_SIZE - CONFIG_PSRAM_SIZE + CONFIG_SDRAM_BASE;
    else 
        return 0;
}

static void out_of_bound(paddr_t addr, bool is_write) {
    PRINTF_RED("%s address = 0x%08x is out of bound of mrom [0x%08x, 0x%08x], flash [0x%08x, 0x%08x], psram [0x%08x, 0x%08x]\n", is_write?"Write":"Read", addr, PMEM_LEFT_MROM, PMEM_RIGHT_MROM, PMEM_LEFT_FLASH, PMEM_RIGHT_FLASH, PMEM_LEFT_PSRAM, PMEM_RIGHT_PSRAM);
    assert(0);
}

void init_mem() {
    pmem = (uint8_t *)malloc(CONFIG_MROM_SIZE + CONFIG_FLASH_SIZE + CONFIG_PSRAM_SIZE + CONFIG_SDRAM_SIZE);
    assert(pmem);
    IFDEF(CONFIG_MEM_RANDOM, memset(pmem, rand(), (CONFIG_MROM_SIZE + CONFIG_FLASH_SIZE + CONFIG_PSRAM_SIZE + CONFIG_SDRAM_SIZE) * sizeof(uint8_t)));
    PRINTF_BLUE("physical memory area mrom [0x%08x, 0x%08x], sram(No trace) [0x%08x, 0x%08x], flash [0x%08x, 0x%08x], psram [0x%08x, 0x%08x], sdram [0x%08x, 0x%08x]\n", 
                    PMEM_LEFT_MROM, PMEM_RIGHT_MROM, PMEM_LEFT_SRAM, PMEM_RIGHT_SRAM, PMEM_LEFT_FLASH, PMEM_RIGHT_FLASH, PMEM_LEFT_PSRAM, PMEM_RIGHT_PSRAM, PMEM_LEFT_SDRAM, PMEM_RIGHT_SDRAM);
}

IFDEF(MTRACE,
void mtrace_read(paddr_t addr, uint32_t data)
{
    if (addr >= CONFIG_MTRACE_BASE && addr < CONFIG_MTRACE_BASE + CONFIG_MTRACE_SIZE) {
        PRINTF_BLUE("[Mtrace] Read addr: 0x%08x data: 0x%08x\n", addr, data);
    }
}

void mtrace_write(paddr_t addr, uint32_t data, uint32_t len)
{
    if (addr >= CONFIG_MTRACE_BASE && addr < CONFIG_MTRACE_BASE + CONFIG_MTRACE_SIZE) {
        PRINTF_BLUE("[Mtrace] Wrtie addr: 0x%08x data: 0x%08x len: %x\n", addr, data, len);
    }
}
);

static word_t pmem_read(paddr_t raddr)
{
    word_t ret = host_read(guest_to_host(raddr));
    IFDEF(MTRACE, mtrace_read(raddr, ret));
    return ret;
}

static void pmem_write(paddr_t waddr, word_t wdata, uint32_t len)
{
    // printf("waddr: 0x%08x\nwdata: 0x%08x\nmask:0x%x\n", waddr, wdata, len);
    host_write(guest_to_host(waddr), wdata, len);
    IFDEF(MTRACE, mtrace_write(waddr, wdata, len));
}

word_t paddr_read(paddr_t addr) {
    if (likely(in_pmem(addr))) {
        // printf("paddr_data: 0x%08x\n", pmem_read(addr));
        return pmem_read(addr&~0x3);
    } else {
        out_of_bound(addr, false);
        return 0;
    }
}

void paddr_write(paddr_t addr, word_t data, int len) {
    if (in_psram(addr) || in_sdram(addr)) {
        pmem_write(addr, data, len);
    } else if (in_flash(addr) || in_mrom(addr)) {
        PRINTF_RED("Cannot write to mrom or flash address 0x%08x\n", addr);
        assert(0);
    } else {
        out_of_bound(addr, true);
    }
}

extern "C" void mrom_read(int32_t addr, int32_t *data) 
{
    // printf("mrom_read addr: 0x%08x\n", addr);
    *data = paddr_read(addr);
}

extern "C" void flash_read(int32_t addr, int32_t *data) {
    // printf("flash_read addr: 0x%08x\n", addr);
    //spi
    *data = paddr_read(addr + CONFIG_FLASH_BASE);
    // printf("flash_read addr: 0x%08x, data: 0x%08x\n", addr, *data);
}

extern "C" void psram_read(int32_t addr, int32_t *data) {
    //spi
    *data = paddr_read(addr + CONFIG_PSRAM_BASE);
    // printf("psram_read addr: 0x%08x, data: 0x%08x\n", addr, *data);
}

extern "C" void psram_write(int32_t addr, int32_t data, int32_t len) {
    // printf("psram_write addr: 0x%08x data: 0x%08x len: %d\n", addr, data, len);
    if(len == 1) {
        paddr_write(addr + CONFIG_PSRAM_BASE, data, 1);
    }
    if(len == 2) {
        paddr_write(addr + CONFIG_PSRAM_BASE, data, 2);
    }
    if(len == 4) {
        paddr_write(addr + CONFIG_PSRAM_BASE, data, 4);
    }
}

extern "C" void sdram_read(int32_t addr, int32_t *data, int32_t num) {

    uint32_t read_data = paddr_read(addr + CONFIG_SDRAM_BASE + CONFIG_SDRAM_SIZE / 2 * (num >> 1));
    
    *data = num & 0x1 ? read_data >> 16 : 
                        read_data & 0xffff;

    // printf("sdram_read addr: 0x%08x, data: 0x%04x, num: %d\n", addr, *data, num);
}

extern "C" void sdram_write(int32_t addr, int32_t data, int32_t mask, int32_t num) {
    // printf("sdram_write addr: 0x%08x data: 0x%04x mask: %02x, num: %d\n", addr, data, ~mask&0x3, num);
    switch ((~mask) & 0x3)
    {
        case 0:
            break;
        case 1:
            paddr_write(addr + CONFIG_SDRAM_BASE + CONFIG_SDRAM_SIZE / 2 * (num >> 1) + ((num&0x1) ? 2 : 0), data, 1);
            break;
        case 2:
            paddr_write(addr + CONFIG_SDRAM_BASE + CONFIG_SDRAM_SIZE / 2 * (num >> 1) + 1 + ((num&0x1) ? 2 : 0), data >> 8, 1);
            break;
        case 3:
            paddr_write(addr + CONFIG_SDRAM_BASE + CONFIG_SDRAM_SIZE / 2 * (num >> 1) + ((num&0x1) ? 2 : 0), data, 2);
            break;
        default:
            break;
    }
}