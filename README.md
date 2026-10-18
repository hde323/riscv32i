#	RISCV32I CPU 

## description
this project  is a system verilog implementation of the riscv32i multi cycle cpu core. 
the core functionalities of the cpu where implemented it supports all the base instructions of riscv32i instruction set. note that for the purpose of this project the system and fence instructions where not implemented and where considered as nops. 

## notes
- the project was written with synthesis deck for the gowin nano tang 20k fpga but the  source code it self can be compiled for other fpga boards.
- in the source code the cpu clock is linked to the physical 27mhz clock of the fpga board.
- the program that is loaded to the cpu is in src/const/program.hex 
- the cpu was tested on verilator duo to technical problems wwith synthesis deck simulations.
- the cpu does not have any exception handler as of the moment.
