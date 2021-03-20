# friscv
Verilog for multi-cycle implementation of RV32IM.
This is a non-pipelined machine where each instruction takes 5 cycles to complete.
One cycle for each stage: fetch, decode, compute, memory access & writeback.
The microarchitecture is adopted from the book Computer Architecture and Embedded Systems by Hamacher et al.
The focus of the code is on clarity for instructional purposes and not on generating the most optimized code. 
