.section entry, "ax"
.globl _start
.type _start, @function

_start:
  mv s0, zero

  la a0, _text_loadaddr
  la a1, _stext
  la a2, _etext

.text_copy_loop:
  beq a1, a2, .text_copy_done
  lw t0, 0(a0)
  sw t0, 0(a1)
  addi a0, a0, 4
  addi a1, a1, 4
  j .text_copy_loop

.text_copy_done:
  la t0, _start2 
  jr t0

.size _start, . - _start

.section text_entry, "ax"
.globl _start2
.type _start2, @function

_start2:

  la a0, _data_loadaddr
  la a1, _sdata
  la a2, _edata

.data_copy_loop:
  beq a1, a2, .data_copy_done
  lw t0, 0(a0)
  sw t0, 0(a1)
  addi a0, a0, 4
  addi a1, a1, 4
  j .data_copy_loop

.data_copy_done:
  la a0, _sbss
  la a1, _ebss

.bss_zero_loop:
  beq a0, a1, .bss_zero_done
  sw zero, 0(a0)
  addi a0, a0, 4
  j .bss_zero_loop

.bss_zero_done:

  la sp, _stack_pointer
  call _trm_init

.size _start2, . - _start2