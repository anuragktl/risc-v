# riscv-sv
RISC-V rv32i implementation 

# Dependencies
- RISC-V gcc tools
- Xilinx Vivado 2018.3 or later

Set the RISCV variable in the environment to the location of riscv gcc tools

# Run instructions
```bash
cd c/counter
make

Testbench is in tb. Set top module as riscv_top.sv

It has been tested on Arty S7 development board running at 150MHz.
```