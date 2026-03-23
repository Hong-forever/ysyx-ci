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

#include <utils.h>
#include <device/map.h>
#include <fcntl.h>
#include <unistd.h>
#include <assert.h>
#include <errno.h>

/* http://en.wikibooks.org/wiki/Serial_Programming/8250_UART_Programming */
// NOTE: this is compatible to 16550

#define CH_OFFSET 0

static uint8_t *serial_base = NULL;


static void serial_putc(char ch) {
  MUXDEF(CONFIG_TARGET_AM, putch(ch), putc(ch, stderr));
}

static void serial_io_handler(uint32_t offset, int len, bool is_write) {
  assert(len == 1);
  switch (offset) {
    /* We bind the serial port with the host stderr in NEMU. */
    case CH_OFFSET:
      if (is_write) serial_putc(serial_base[0]);
      else {
        int ret = fgetc(stdin);
        if (ret == EOF) ret = -1;
        serial_base[0] = ret;
      }
      break;
    // default: panic("do not support offset = %d", offset);
  }
}

void init_serial() {
  serial_base = new_space(8);

  int ret = fcntl(STDIN_FILENO, F_GETFL);
  assert(ret != -1);
  int flag = ret | O_NONBLOCK;
  ret = fcntl(STDIN_FILENO, F_SETFL, flag);
  assert(ret != -1);

#ifdef CONFIG_HAS_PORT_IO
  add_pio_map ("serial", CONFIG_SERIAL_PORT, serial_base, 8, serial_io_handler);
#else
  add_mmio_map("serial", CONFIG_SERIAL_MMIO, serial_base, 8, serial_io_handler);
#endif

}
