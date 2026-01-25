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
  rom(rx)    : ORIGIN = 0x30000000, LENGTH = 0x10000000
  ram(rwx)   : ORIGIN = 0x80000000, LENGTH = 0x400000
  sram(rwx)  : ORIGIN = 0x0f000000, LENGTH = 0x2000
}

SECTIONS {
  .boot : {
    _boot_start = .;
    *(entry)
    *(.boot*)
  } > rom AT>rom : boot
  
  .text : {
    _rom_start = .;
    _text_start = .;
    *(text_entry)
    *(.text*)
  } > ram AT>rom : text

  _text_loadaddr = LOADADDR(.text);

  etext = .;
  _etext = .;

  .rodata : {
    . = ALIGN(4);
    *(.rodata*)
    *(.srodata*)
    . = ALIGN(4);
    _rom_end = .;
    _text_end = .;
  } > ram AT>rom


  .data : {
    _ram_start = .;
    _data_start = .;
    *(.data*)
    *(.sdata*)
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
	  _bss_end = ALIGN(4);
  } > ram

  _heap_start = ALIGN(4);

  . = ORIGIN(ram) + LENGTH(ram);

  _heap_end = .;
  _ram_end = .;

  . = ORIGIN(sram) + LENGTH(sram);
  _stack_pointer = .;
  
  end = .;
  _end = .;
}
