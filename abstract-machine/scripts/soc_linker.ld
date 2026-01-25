ENTRY(_start)
PHDRS { 
  boot PT_LOAD;
  text PT_LOAD;
  data PT_LOAD;
}
MEMORY {
  /* 
  mrom(rx)   : ORIGIN = 0x20000000, LENGTH = 0x1000
  sram(rwx)  : ORIGIN = 0x0f000000, LENGTH = 0x2000
  flash(rx)  : ORIGIN = 0x30000000, LENGTH = 0x10000000
  psram(rwx) : ORIGIN = 0x80000000, LENGTH = 0x400000
  */
  flash(rx)  : ORIGIN = 0x30000000, LENGTH = 0x10000000
  psram(rwx) : ORIGIN = 0x80000000, LENGTH = 0x400000
  sram(rwx)  : ORIGIN = 0x0f000000, LENGTH = 0x2000
}

SECTIONS {
  .boot : {
    _sboot = .;
    *(entry)
    *(.boot*)
    _eboot = .;
  } > flash AT>flash : boot
  
  .text : {
    _stext = ALIGN(4);
    *(text_entry)
    *(.text*)
    *(.rodata*)
    *(.srodata*)
    _etext = ALIGN(4);
  } > psram AT>flash : text

  _text_loadaddr = LOADADDR(.text);

  .data : {
    _sdata = ALIGN(4);
    *(.data*)
    *(.sdata*)
    _edata = ALIGN(4);
  } > psram AT>flash : data

  _data_loadaddr = LOADADDR(.data);
  
  .bss (NOLOAD) : {
	  _sbss = ALIGN(4);
    *(.bss*)
    *(.sbss*)
    *(.scommon)
    *(COMMON)
	  _ebss = ALIGN(4);
  } > psram

  .heap (NOLOAD) : {
    _heap_start = ALIGN(4);
    . = ORIGIN(psram) + LENGTH(psram);
    _heap_end = ALIGN(4);
  } > psram


  .stack (NOLOAD) : {
    . = ORIGIN(sram);
    _stack_start = ALIGN(4);
    . = ORIGIN(sram) + LENGTH(sram);
    . = ALIGN(4);
    _stack_end = .;
    _stack_pointer = .;
  } > sram
  
}
