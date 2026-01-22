ENTRY(_start)
PHDRS { 
  text PT_LOAD; 
  data PT_LOAD;
  bss  PT_LOAD;
}
MEMORY {
  rom(rx)    : ORIGIN = 0x20000000, LENGTH = 0x1000
  ram(rwx)   : ORIGIN = 0x0f000000, LENGTH = 0x2000
  flash(rwx) : ORIGIN = 0x30000000, LENGTH = 0x10000000
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
  } > ram AT>flash : data
  _data_loadaddr = LOADADDR(.data);

  edata = .;
  _data = .;

  .bss : {
	_bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
  _bss_end = .;
  } > ram : bss

  _heap_start = ALIGN(4);
  . = ORIGIN(ram) + LENGTH(ram);
  _stack_pointer = .;
  
  end = .;
  _end = .;
}
