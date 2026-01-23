ENTRY(_start)
PHDRS { 
  text PT_LOAD; 
  data PT_LOAD;
  bss  PT_LOAD;
}
MEMORY {
  /* 
  mrom(rx)   : ORIGIN = 0x20000000, LENGTH = 0x1000
  sram(rwx)  : ORIGIN = 0x0f000000, LENGTH = 0x2000
  */
  flash(rx)  : ORIGIN = 0x30000000, LENGTH = 0x10000000
  psram(rwx) : ORIGIN = 0x80000000, LENGTH = 0x20000000
}

SECTIONS {
  . = ORIGIN(flash);
  .text : {
    *(entry)
    *(.text*)
  } > flash AT>flash : text

  etext = .;
  _etext = .;

  .rodata : {
    *(.rodata*)
  } > flash AT>flash

  .data : {
    _data_start = .;
    *(.data*)
  } > psram AT>flash : data
  _data_loadaddr = LOADADDR(.data);

  edata = .;
  _data = .;

  .bss (NOLOAD): {
	_bss_start = ALIGN(4);
    *(.bss*)
    *(.sbss*)
    *(.scommon)
    *(COMMOM)
  _bss_end = ALIGN(4);
  } > psram : bss

  _heap_start = ALIGN(4);
  . = ORIGIN(psram) + LENGTH(psram);
  _stack_pointer = .;
  
  end = .;
  _end = .;
}
