 module ins_fetch(
	 input clk,
	 input rst_n,
	 input PC_sel,
	 input PC_en,
	 input INC_sel,
	 input IR_en,
	 input [31:0] ra,
	 input [31:0] ins_mem,
	 input [31:0] branch_offset,
	 output [31:0] ins_ad,
	 output [31:0] ins,
     output [31:0] ret_ad);

 reg [31:0] IR;

 assign ins = IR;
 
 ins_ad_gen iag (
     .clk(clk),
	 .rst_n(rst_n),
	 .PC_sel(PC_sel),
	 .PC_en(PC_en),
	 .INC_sel(INC_sel),
	 .ra(ra),
	 .branch_offset(branch_offset),
	 .ins_ad(ins_ad),
	 .ret_ad(ret_ad)
 );  
 
 
 
 always @(posedge clk)
	 if (rst_n == 0)
		 IR <=#(`cq) 0;
	 else if (IR_en)
   		IR <=#(`cq) ins_mem;
 
 
 
 
 
 endmodule
