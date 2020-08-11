RISCV_COMPILER=$(RISCV)/bin/riscv64-unknown-elf-gcc
RISCV_OBJCOPY=$(RISCV)/bin/riscv64-unknown-elf-objcopy
RISCV_OBJDUMP=$(RISCV)/bin/riscv64-unknown-elf-objdump
# RISCV_COMPILER=$(RISCV)/bin/riscv64-unknown-linux-gnu-gcc
# RISCV_OBJCOPY=$(RISCV)/bin/riscv64-unknown-linux-gnu-objcopy
# RISCV_OBJDUMP=$(RISCV)/bin/riscv64-unknown-linux-gnu-objdump
LD=../inc/link.ld
START=../inc/start.S


default: all

all: compile genmemfiles

compile:
	rm -rf build
	mkdir build
	$(RISCV_COMPILER) -g -march=rv32i -mabi=ilp32 -nostdlib -T $(LD) $(START) ./src/main.c -o build/counter.o -Wl,-Map,build/counter.map,--print-memory-usage
# 	$(RISCV_COMPILER) -g -march=rv32i -mabi=ilp32 -nostdlib -T $(LD) $(START) ./src/main.c -o build/counter.o -Wl,-Map,build/counter.map,--print-memory-usage

genmemfiles:
	$(RISCV_OBJCOPY) -O ihex build/counter.o build/counter.hex
	$(RISCV_OBJCOPY) -O binary build/counter.o build/counter.bin
	$(RISCV_OBJDUMP) -S -d build/counter.o > build/counter.asm
	$(RISCV_OBJDUMP) -t build/counter.o > build/counter_symbols.txt
	../../scripts/word_to_byte_mem.py build/counter.bin build/counter_


