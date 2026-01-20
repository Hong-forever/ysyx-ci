/***************************************************************************************
* Copyright (c) 2014-2024 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <memory/host.h>
#include <memory/paddr.h>
#include <device/mmio.h>
#include <isa.h>

#if   defined(CONFIG_PMEM_MALLOC)
static uint8_t *pmem = NULL;
#else // CONFIG_PMEM_GARRAY
static uint8_t pmem[CONFIG_ROM_SIZE + CONFIG_RAM_SIZE] PG_ALIGN = {};
#endif

uint8_t* guest_to_host(paddr_t paddr) {
  if(in_rom(paddr))  return pmem + paddr - CONFIG_ROM_BASE;
  else if(in_ram(paddr))  return pmem + paddr - CONFIG_RAM_BASE + CONFIG_ROM_SIZE;
  else return NULL;
}
paddr_t host_to_guest(uint8_t *haddr) { 
  if(haddr-pmem < CONFIG_ROM_SIZE) return haddr - pmem + CONFIG_ROM_BASE;
  else return haddr - pmem - CONFIG_ROM_SIZE + CONFIG_RAM_BASE;
}

static word_t pmem_read(paddr_t addr, int len) {
  word_t ret = host_read(guest_to_host(addr), len);
  return ret;
}


static void pmem_write(paddr_t addr, int len, word_t data) {
  host_write(guest_to_host(addr), len, data);
}

static void out_of_bound(paddr_t addr) {
  panic("address = " FMT_PADDR " is out of bound of rom [" FMT_PADDR ", " FMT_PADDR "] or ram [" FMT_PADDR ", " FMT_PADDR "] at pc = " FMT_WORD,
      addr, PMEM_LEFT_ROM, PMEM_RIGHT_ROM, PMEM_LEFT_RAM, PMEM_RIGHT_RAM, cpu.pc);
}

void init_mem() {
#if   defined(CONFIG_PMEM_MALLOC)
  pmem = malloc(CONFIG_ROM_SIZE + CONFIG_RAM_SIZE);
  assert(pmem);
#endif
  IFDEF(CONFIG_MEM_RANDOM, memset(pmem, rand(), CONFIG_ROM_SIZE + CONFIG_RAM_SIZE));
  Log("physical memory area [" FMT_PADDR ", " FMT_PADDR "], [" FMT_PADDR ", " FMT_PADDR "]",
      PMEM_LEFT_ROM, PMEM_RIGHT_ROM, PMEM_LEFT_RAM, PMEM_RIGHT_RAM);
}

#ifdef CONFIG_MTRACE

#define MTRACE_BASE 0x80000140
#define MTRACE_SIZE 3

static void mtrace(paddr_t addr, word_t data, int op) {
    if(addr > MTRACE_BASE && addr < MTRACE_BASE+4*MTRACE_SIZE) printf("MTRACE===>>>  addr(0x%08x): data(0x%08x) op(%s)\n", addr, data, op==0? "read" : op==1? "sb  " : op==2? "sh  " : "sw  ");
}

#endif

word_t paddr_read(paddr_t addr, int len) {
    if (likely(in_pmem(addr))) {
        word_t read_data = pmem_read(addr, len);
        IFDEF(CONFIG_MTRACE, mtrace(addr, read_data, 0));
        return read_data;
    }
  IFDEF(CONFIG_DEVICE, word_t mmio_data = mmio_read(addr, len); IFDEF(CONFIG_MTRACE, mtrace(addr, mmio_data, 0)); return mmio_data);
  out_of_bound(addr);
  return 0;
}

void paddr_write(paddr_t addr, int len, word_t data) {
  if (likely(in_pmem(addr))) {
      if(in_rom(addr)) {
        panic("can not write to rom address " FMT_PADDR " at pc = " FMT_WORD, addr, cpu.pc);
      }
      pmem_write(addr, len, data); 
      IFDEF(CONFIG_MTRACE, mtrace(addr, len==1? data&0x000000ff : len==2? data&0x0000ffff : data&0xffffffff, len));
      return; 
  }
  IFDEF(CONFIG_DEVICE, mmio_write(addr, len, data); IFDEF(CONFIG_MTRACE, mtrace(addr, len==1? data&0x000000ff : len==2? data&0x0000ffff : data&0xffffffff, len)); return);
  out_of_bound(addr);
}
