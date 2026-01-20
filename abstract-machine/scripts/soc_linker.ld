ENTRY(_start)
PHDRS { 
  text PT_LOAD; 
  data PT_LOAD;
  bss  PT_LOAD;
}
MEMORY {
  pmem(rx)  : ORIGIN = 0x20000000, LENGTH = 0x1000
  sram(rwx) : ORIGIN = 0x0f000000, LENGTH = 0x2000
}

SECTIONS {
  /* _pmem_start and _entry_offset are defined in LDFLAGS */
  . = _pmem_start + _entry_offset;
  .text : {
    *(entry)
    *(.text*)
  } > pmem AT> pmem : text
  etext = .;
  _etext = .;
  .rodata : {
    *(.rodata*)
  } > pmem AT> pmem
  .data : {
    _data_start = .;
    *(.data*)
  } > sram AT>pmem : data
  _data_loadaddr = LOADADDR(.data);
  edata = .;
  _data = .;
  .bss : {
	_bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
  _bss_end = .;
  } > sram : bss
  _stack_top = ORIGIN(sram);
  . = _stack_top + LENGTH(sram);
  _stack_pointer = .;
  end = .;
  _end = .;
  _heap_start = ALIGN(0x1000);
}
