ENTRY(_start)
PHDRS { 
  fsbl PT_LOAD;
  ssbl PT_LOAD;
  text PT_LOAD;
  data PT_LOAD;
  data.extra PT_LOAD;
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
  .fsbl : {
    _sfsbl = .;
    *(fsbl_entry)
    _efsbl = .;
  } > flash AT>flash : fsbl

  .ssbl : {
    _sssbl = .;
    *(ssbl_entry)
    _essbl = .;
  } > sram AT>flash : ssbl

  _ssbl_loadaddr = LOADADDR(.ssbl);
  
  .text : {
    _stext = ALIGN(4);
    *(text_entry)
    *(.text*)
    *(.rodata*)
    *(.srodata*)
    _etext = ALIGN(4);
  } > psram AT>flash : text

  _text_loadaddr = LOADADDR(.text);

  .data.extra : {
    /* section information for finsh shell */
    __fsymtab_start = .;
    KEEP(*(FSymTab))
    __fsymtab_end = .;
    . = ALIGN(8);
    __vsymtab_start = .;
    KEEP(*(VSymTab))
    __vsymtab_end = .;
    . = ALIGN(8);

    /* section information for initial. */
    . = ALIGN(8);
    __rt_init_start = .;
    KEEP(*(SORT(.rti_fn*)))
    __rt_init_end = .;
    . = ALIGN(8);

    __rt_utest_tc_tab_start = .;
    KEEP(*(UtestTcTab))
    __rt_utest_tc_tab_end = .;

    . = ALIGN(8);
    __am_apps_data_start = .;
    *(__am_apps.data*)
    *(__am_apps.sdata*)
    __am_apps_data_end = .;
    . = ALIGN(8);
  } > psram AT> flash

  .data : {
    _sdata = ALIGN(4);
    *(.data*)
    *(.sdata*)
    _edata = ALIGN(4);
  } > psram AT>flash : data

  _data_loadaddr = LOADADDR(.text) + SIZEOF(.text);

  .bss.extra (NOLOAD): {
    . = ALIGN(8);
    __am_apps_bss_start = .;
    *(__am_apps.bss*)
    *(__am_apps.sbss*)
    *(__am_apps.scommon*)
    __am_apps_bss_end = .;
    . = ALIGN(8);
  } > psram

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
    . = _essbl;
    _stack_start = ALIGN(4);
    . = ORIGIN(sram) + LENGTH(sram);
    . = ALIGN(4);
    _stack_end = .;
    _stack_pointer = .;
  } > sram
}
