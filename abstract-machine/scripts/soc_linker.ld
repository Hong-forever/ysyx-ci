ENTRY(_start)
PHDRS { 
  fsbl PT_LOAD;
  ssbl PT_LOAD;
  text PT_LOAD;
  data PT_LOAD;
}

MEMORY {
  mrom(rx)   : ORIGIN = 0x20000000, LENGTH = 0x1000
  flash(rx)  : ORIGIN = 0x30000000, LENGTH = 0x10000000
  sram(rwx)  : ORIGIN = 0x0f000000, LENGTH = 0x2000
  psram(rwx) : ORIGIN = 0x80000000, LENGTH = 0x400000
  sdram(rwx) : ORIGIN = 0xa0000000, LENGTH = 0x8000000
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
    _etext = .;
  } > sdram AT>flash : text

  _text_loadaddr = LOADADDR(.text);

  .data.extra : {

    _sdata = ALIGN(4);

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
  } > sdram AT>flash : data

  .data : {
    *(.data*)
    *(.sdata*)
    _edata = ALIGN(4);
  } > sdram AT>flash : data

  _data_loadaddr = LOADADDR(.data);
  
  .bss.extra (NOLOAD): {

	  _sbss = ALIGN(4);
    
    . = ALIGN(8);
    __am_apps_bss_start = .;
    *(__am_apps.bss*)
    *(__am_apps.sbss*)
    *(__am_apps.scommon*)
    __am_apps_bss_end = .;
    . = ALIGN(8);
  } > sdram

  .bss (NOLOAD) : {
    *(.bss*)
    *(.sbss*)
    *(.scommon)
    *(COMMON)
	  _ebss = ALIGN(4);
  } > sdram

  .heap (NOLOAD) : {
    _heap_start = ALIGN(4);
    . = ORIGIN(sdram) + LENGTH(sdram);
    _heap_end = ALIGN(4);
  } > sdram

  .stack (NOLOAD) : {
    . = ALIGN(4);
    . = _essbl;
    _stack_end = .;
    _stack_top = .;
    . = ORIGIN(sram) + LENGTH(sram);
    _stack_start = .;
    _stack_pointer = .;
  } > sram
}
