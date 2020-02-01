 OUTPUT_ARCH( "riscv" )
 ENTRY( _start )
 SECTIONS
 {
     . = 0x100A0;
     .init :
     {
     *(.init)
     }     
     .text :
     {
     *(.text)
     }
     .data :
     {
     *(.data)
     }
     _end = .;
 }