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
  flash(rx)  : ORIGIN = 0x30000000, LENGTH = 0x10000000
  psram(rwx) : ORIGIN = 0x80000000, LENGTH = 0x20000000
  */
  rom(rx)    : ORIGIN = 0x30000000, LENGTH = 0x10000000
  ram(rwx)   : ORIGIN = 0x80000000, LENGTH = 0x20000000
}

SECTIONS {
  . = ORIGIN(rom);
  .text : {
    *(entry)
    *(.text*)
  } > rom AT>rom : text

  etext = .;
  _etext = .;

  .rodata : {
    *(.rodata*)
  } > rom AT>rom

  .data : {
    _data_start = .;
    *(.data*)
  } > ram AT>rom : data
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
  } > ram : bss

  _heap_start = ALIGN(4);
  . = ORIGIN(ram) + LENGTH(ram);
  _stack_pointer = .;
  
  end = .;
  _end = .;
}
