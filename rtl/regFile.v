 module regFile(
	 Ad_A,
	 Ad_B, 
	 Ad_C,
	 clk,
	 RD,
	 rst_n,
	 RF_write,
	 A,
	 B,
	 C);

 input [4:0] Ad_A, Ad_B, Ad_C;
 output [31:0] A, B;
 input [31:0] C;
 input clk, RD, rst_n, RF_write;
 integer i;
 reg [31:0] regFile [0:31];

 //---------------------------
 // Register Write operation
 // disallow write into register r0
 //---------------------------
 always @(posedge clk or negedge rst_n) begin
	 if (rst_n == 0)begin
		 for(i = 0; i < 32; i++)
			 regFile[i] <=#(`cq) 32'h0;
	 end
	 else begin
		 if (RF_write == 1 && Ad_C != 0)
			 regFile[Ad_C] <=#(`cq) C; 
	 end
 end

 //---------------------------
 // Register Read Operation
 // -------------------------- 
assign A = regFile[Ad_A];
assign B = regFile[Ad_B];

//convenience task for displaying contents
// of regfile for debug
task dump;
	input [4:0] low, high;
	integer i;
	begin
		for (i = low; i<= high; i = i + 1)
			$display ("X[%d] = %h", i, regFile[i]);
	end
endtask
 
endmodule

