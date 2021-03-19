 module compute(clk, rst_n, ra, rb, imm, ALU_op, B_sel, rz, rm);
 
 input clk, rst_n;
 input [31:0] ra, rb, imm;
 input [4:0] ALU_op;
 input B_sel;

 output [31:0] rz, rm;
 reg [31:0] rz, rm;
 wire [31:0] muxB_out;
 wire [31:0] alu_out;

 //muxMto1 #(32, 2, 1) muxB(.D({rb,imm}), .SEL(B_sel), .Z(muxB_out));
 assign muxB_out = B_sel? imm: rb;
alu farm_alu (
	.inA(ra), 
	.inB(muxB_out),
	.alu_out(alu_out), 
	.ALU_op(ALU_op)
); 
 
 
 
 always_ff @(posedge clk) begin
	 if (rst_n == 0)begin
		 rz = 32'd0;
		 rm = 32'd0;
	 end
	 else begin
		 rz <= #(`cq) alu_out;
		 rm <= #(`cq) rb;
	 end
 end

 endmodule
