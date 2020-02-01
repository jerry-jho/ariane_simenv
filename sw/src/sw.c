#include <sw.h>

int main(int argc,char ** argv);

int crtmain() {
    int r = main(0,NULL);
    out64(0x0,r);
    return 0;
}