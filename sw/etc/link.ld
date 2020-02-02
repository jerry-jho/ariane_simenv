 OUTPUT_ARCH( "riscv" )
 ENTRY( _start )
 SECTIONS
 {
     . = 0x1000;
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