ENTRY(_start)
PHDRS { 
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
  rom(rx)    : ORIGIN = 0x30000000, LENGTH = 0x10000000
  ram(rwx)   : ORIGIN = 0x80000000, LENGTH = 0x400000
}

SECTIONS {
  .text : {
    _rom_start = .;
    *(entry)
    *(.text*)
  } > rom AT>rom : text

  etext = .;
  _etext = .;

  .rodata : {
    *(.rodata*)
    _rom_end = .;
  } > rom AT>rom


  .data : {
    _ram_start = .;
    _data_start = .;
    *(.data*)
  } > ram AT>rom : data
  _data_loadaddr = LOADADDR(.data);

  edata = .;
  _data = .;

  .bss (NOLOAD) : {
	  _bss_start = ALIGN(4);
    *(.bss*)
    *(.sbss*)
    *(.scommon)
    *(COMMON)
    . = ALIGN(4);
    _bss_end = .;
  } > ram

  _heap_start = ALIGN(4);

  . = ORIGIN(ram) + LENGTH(ram);

  _heap_end = .;
  _ram_end = .;
  _stack_pointer = .;
  
  end = .;
  _end = .;
}
