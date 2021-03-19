 module ins_ad_gen(
     input clk,
	 input rst_n,
	 input PC_sel,
	 input PC_en,
	 input INC_sel,
	 input [31:0] ra,
	 input [31:0] branch_offset,
	 output [31:0] ret_ad,
     output [31:0] ins_ad);

 reg [31:0] PC;
 reg [31:0] PC_temp;

 wire [31:0] muxPC_out;
 wire [31:0] muxInc_out;
 wire [31:0] add_out;


 assign ret_ad = PC_temp;
 assign ins_ad = PC;

 assign muxPC_out = PC_sel ? add_out[31:0]:ra[31:0];
 assign muxInc_out = INC_sel? branch_offset[31:0]:32'd4;  
 assign add_out = muxInc_out + PC;
 
 
 
 
 always@(posedge clk) begin
	 if (rst_n == 0)begin
		 PC <=#(`cq) 0;
	 end
	 else if (PC_en) begin
		 PC <=#(`cq) muxPC_out;
	 end
 end

always @(posedge clk)
	PC_temp <=#(`cq) PC;
 
 
 endmodule
