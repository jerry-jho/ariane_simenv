#include <sw.h>

int main(int argc,char ** argv) {
    out64(0x1000,0x3);
    out64(0x40000000,0xABCD);
    out32(0x21000000,0x2233);
    out32(0x21000004,0x1234);
    return 0x3456;
}