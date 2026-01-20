ENTRY(_start)
PHDRS { 
  text PT_LOAD; 
  data PT_LOAD;
}
MEMORY {
  rom(rx)  : ORIGIN = 0x20000000, LENGTH = 0x1000
  ram(rwx) : ORIGIN = 0x0f000000, LENGTH = 0x2000
}

SECTIONS {
  /* _rom_start and _entry_offset are defined in LDFLAGS */
  . = _rom_start + _entry_offset;
  .text : {
    *(entry)
    *(.text*)
  } > rom AT> rom : text
  etext = .;
  _etext = .;
  .rodata : {
    *(.rodata*)
  } > rom AT> rom
  .data : {
    _data_start = .;
    *(.data*)
	  
    edata = .;
    _data = .;

    _bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
    _bss_end = .;
  } > ram AT>rom : data

  _data_loadaddr = LOADADDR(.data);

  _heap_start = ALIGN(4); 
  _stack_top = ORIGIN(ram) + LENGTH(ram);
  . = _stack_top;
  _stack_pointer = .;
  end = .;
  _end = .;
}
