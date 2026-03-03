ENTRY(_start)
PHDRS { text PT_LOAD; data PT_LOAD; }

SECTIONS {
  /* _pmem_start and _entry_offset are defined in LDFLAGS */
  . = _pmem_start + _entry_offset;
  .text : {
    *(entry)
    *(.text*)
    *(.rodata*)
    . = ALIGN(8);
    etext = .;
    _etext = .;
  } : text

  .data : {
    sdata = ALIGN(4);
    *(.data*)
    *(.sdata*)
    . = ALIGN(4);
    edata = .;
    _edata = .;
  } : data

  .bss (NOLOAD) : {
	  _bss_start = .;
    _sbss = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
    _ebss = ALIGN(4);
  }

  _stack_top = ALIGN(0x1000);
  . = _stack_top + 0x8000;
  _stack_pointer = .;
  end = .;
  _end = .;
  _heap_start = ALIGN(0x1000);
}
