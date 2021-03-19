 module muxMto1 (Z, SEL, D);

 parameter N = 8;  // number of bits wide
 parameter M = 4;  // number of inputs
 parameter S = 2;  // number of sel lines

 parameter W = M * N;
 `define DTOTAL W-1:0
 `define DWIDTH N-1:0
 `define SELW   S-1:0
 `define WORDS  M-1:0

 /* Verilog does not provide an easy way to parameterize 
 * the number of inputs, this model takes all inputs as
 * one long vector */

 input [`DTOTAL] D;
 input [`SELW] SEL;
 output [`DWIDTH] Z;

 reg[`DWIDTH] tmp, Z;
 integer i;

 always @(SEL or D) begin
	 for (i = 0; i < N; i = i + 1)
		 tmp[i] = D[N*SEL + i];
	 Z = tmp;
 end

 endmodule

