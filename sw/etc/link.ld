 OUTPUT_ARCH( "riscv" )
 ENTRY( _start )
 SECTIONS
 {
     . = 0x40000200;
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