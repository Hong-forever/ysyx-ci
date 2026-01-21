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
  . = ORIGIN(rom);
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
  } > ram AT>rom : data
  _data_loadaddr = LOADADDR(.data);

  edata = .;
  _data = .;

  .bss : {
	_bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
  _bss_end = .;
  }

  _heap_start = ALIGN(4);
  . = ORIGIN(ram) + LENGTH(ram);
  _stack_pointer = .;
  
  end = .;
  _end = .;
}
