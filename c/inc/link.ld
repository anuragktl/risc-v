OUTPUT_ARCH( "riscv" )

START_LOC = 0x0000;
IMEM_LEN = 0x6400;
DMEM_LEN = 0x1800;

MEMORY {
       imem (R)     : ORIGIN = START_LOC     , LENGTH = IMEM_LEN
       dmem (RW)    : ORIGIN = IMEM_LEN      , LENGTH = DMEM_LEN
}

SECTIONS {
  . = 0x0000;
  .crt_section :
  {
    . = ALIGN(4);
    *crt.o(.text*);
    *(.init.text*);
    *(.text*);
  } > imem

  __imem_size = SIZEOF(.crt_section);

  .var_space :
  {
    . = ALIGN(4);
    *(.sdata .sdata.*);
    *(.data .data.*);
    *(.sbss*)
  } > dmem

  .will_zero :
  {
    . = ALIGN(4);
    __bss_vma_start = .;

    *(.bss*)
    *(COMMON)

    . = ALIGN(4);
    __bss_vma_end = .;
  } > dmem

  . = ALIGN(4);
  __dedicated_mem_end = .;


  __sp_start = ORIGIN(dmem) + LENGTH(dmem) - 4 ;
  __stack_size = __sp_start - __dedicated_mem_end;


}
