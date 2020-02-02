RISCV_PREFIX=$(RISCV)/bin/riscv64-unknown-elf-
SDK_ROOT=$(ARIANE_SIMENV_ROOT)/sw

ARCH_IMC=-march=rv64imc -Wa,-march=rv64imc -mabi=lp64 

GCC=$(RISCV_PREFIX)gcc
LINK=$(RISCV_PREFIX)link
OBJDUMP=$(RISCV_PREFIX)objdump
OBJCOPY=$(RISCV_PREFIX)objcopy

FCOLOR=-fdiagnostics-color=always

INCLUDES=-I. -I$(SDK_ROOT)/include -I$(SDK_ROOT)/riscv_tests

CFLAGS= -g \
        -Wextra -Wall \
        -Wno-unused-parameter \
        -Wno-unused-variable \
        -Wno-unused-function \
        $(FCOLOR) $(DEFINES)
        

        
ifeq (,$(wildcard app.c))
	APP=*.S
	STARTUP=
	MAINSRC=
	LIBSRC=$(SDK_ROOT)/riscv_tests/test_lib.c
	LD_SCRIPT=$(SDK_ROOT)/riscv_tests/link.ld
else
	APP=app.c
	STARTUP=$(SDK_ROOT)/src/start.S -nostdlib -nostartfiles
	LD_SCRIPT=$(SDK_ROOT)/etc/link.ld
	MAINSRC=$(SDK_ROOT)/src/sw.c
endif

MEM64=python3 $(SDK_ROOT)/bin/process_mem.py
OUT=app.m64
TEMPMEM=app.mem
BASE=0x0
firmware:
	$(GCC) $(INCLUDES) $(CFLAGS) $(ARCH_IMC) $(APP) $(STARTUP) $(MAINSRC) -T$(LD_SCRIPT) -o app.elf
	$(OBJDUMP) -dx --source app.elf > app.lst
	$(OBJCOPY) -O verilog app.elf app.mem
	$(MEM64) app.mem 64 $(BASE) > app.m64
    
elf2m64:
	$(OBJCOPY) -O verilog $(APP) $(TEMPMEM)
	$(MEM64) $(TEMPMEM) 64 $(BASE) > $(OUT)	
	


