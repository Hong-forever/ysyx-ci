.section entry, "ax"
.globl _start
.type _start, @function

_start:
  mv s0, zero

  la a0, _data_loadaddr
  la a1, _data_start
  la a2, _bss_start

.data_copy_loop:
  beq a1, a2, .data_copy_done
  lw t0, 0(a0)
  sw t0, 0(a1)
  addi a0, a0, 4
  addi a1, a1, 4
  j .data_copy_loop

.data_copy_done:

  la sp, _stack_pointer
  call _trm_init

.size _start, . - _start
