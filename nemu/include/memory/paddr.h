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

#ifndef __MEMORY_PADDR_H__
#define __MEMORY_PADDR_H__

#include <common.h>

#define PMEM_LEFT_ROM  ((paddr_t)CONFIG_ROM_BASE)
#define PMEM_RIGHT_ROM ((paddr_t)CONFIG_ROM_BASE + CONFIG_ROM_SIZE - 1)

#define PMEM_LEFT_RAM  ((paddr_t)CONFIG_RAM_BASE)
#define PMEM_RIGHT_RAM ((paddr_t)CONFIG_RAM_BASE + CONFIG_RAM_SIZE - 1)

#define PMEM_LEFT_FLASH  ((paddr_t)CONFIG_FLASH_BASE)
#define PMEM_RIGHT_FLASH ((paddr_t)CONFIG_FLASH_BASE + CONFIG_FLASH_SIZE - 1)

#define RESET_VECTOR (PMEM_LEFT_FLASH + CONFIG_PC_RESET_OFFSET)

/* convert the guest physical address in the guest program to host virtual address in NEMU */
uint8_t* guest_to_host(paddr_t paddr);
/* convert the host virtual address in NEMU to guest physical address in the guest program */
paddr_t host_to_guest(uint8_t *haddr);

static inline bool in_rom(paddr_t addr) {
  return addr >= PMEM_LEFT_ROM && addr <= PMEM_RIGHT_ROM;
}

static inline bool in_ram(paddr_t addr) {
  return addr >= PMEM_LEFT_RAM && addr <= PMEM_RIGHT_RAM;
}

static inline bool in_flash(paddr_t addr) {
  return addr >= PMEM_LEFT_FLASH && addr <= PMEM_RIGHT_FLASH;
}

static inline bool in_pmem(paddr_t addr) {
  return in_ram(addr) || in_flash(addr) || in_rom(addr);
}

word_t paddr_read(paddr_t addr, int len);
void paddr_write(paddr_t addr, int len, word_t data);

#endif
