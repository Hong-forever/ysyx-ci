ENTRY(_start)
PHDRS { 
  fsbl PT_LOAD;
  ssbl PT_LOAD;
  text PT_LOAD;
  data PT_LOAD;
}

MEMORY {
  mrom(rx)   : ORIGIN = 0x20000000, LENGTH = 0x1000
  flash(rx)  : ORIGIN = 0x30000000, LENGTH = 0x10000000
  sram(rwx)  : ORIGIN = 0x0f000000, LENGTH = 0x2000
  psram(rwx) : ORIGIN = 0x80000000, LENGTH = 0x400000
  sdram(rwx) : ORIGIN = 0xa0000000, LENGTH = 0x8000000
}

SECTIONS {
  .fsbl : {
    _sfsbl = ALIGN(4);
    *(fsbl_entry)
    _efsbl = ALIGN(4);
  } > flash AT>flash : fsbl

  .ssbl : {
    _sssbl = ALIGN(4);
    *(ssbl_entry)
    _essbl = ALIGN(4);
  } > sram AT>flash : ssbl

  _ssbl_loadaddr = LOADADDR(.ssbl);
  
  .text : {
    _sload = ALIGN(4);
    *(text_entry)
    *(.text*)
    *(.rodata*)
    *(.srodata*)
  } > psram AT>flash : text

  _start_loadaddr = LOADADDR(.text);

  .data : {
    *(.data*)
    *(.sdata*)
    _eload = ALIGN(4);
  } > psram AT>flash : data


  .bss (NOLOAD) : {
    *(.bss*)
    *(.sbss*)
    *(.scommon)
    *(COMMON)
	  _ezero = ALIGN(4);
  } > psram

  .heap (NOLOAD) : {
    _heap_start = ALIGN(4);
    . = ORIGIN(psram) + LENGTH(psram);
    _heap_end = ALIGN(4);
  } > psram

  .stack (NOLOAD) : {
    . = _essbl;
    _stack_end = .;
    _stack_top = .;
    . = ORIGIN(sram) + LENGTH(sram);
    _stack_start = .;
    _stack_pointer = .;
  } > sram
}
