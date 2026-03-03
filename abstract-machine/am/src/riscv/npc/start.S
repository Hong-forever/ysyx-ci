.section entry, "ax"
.globl _start
.type _start, @function

_start:
  mv s0, zero
  la sp, _stack_pointer

  la a0, sbss
  la a1, ebss

.zero_loop:
  beq a0, a1, .zero_done
  sw zero, 0(a0)
  addi a0, a0, 4
  j .zero_loop

.zero_done:
  call _trm_init

.size _start, . - _start
