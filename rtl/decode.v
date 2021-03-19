module decode(
	clk,
	rst_n,
	RF_write,
	ins,
	A,
	B,
	C);
input clk, rst_n, RF_write;
input [31:0] ins;
input [31:0] C;
output [31:0] A, B;
reg [31:0] A, B;


wire [31:0] A_w, B_w;
wire [4:0] rs1, rs2, rd;
wire [6:0] opcode;
wire [2:0] funct3;
wire [6:0] funct7;

wire [31:0] C;



assign rd     = ins[11:7];
assign rs1    = ins[19:15];
assign rs2    = ins[25:20];

regFile RF(
	 .Ad_A(rs1),
	 .Ad_B(rs2),
	 .Ad_C(rd),
	 .clk(clk),
	 .RD(),
	 .rst_n(rst_n),
	 .RF_write(RF_write),
	 .A(A_w),
	 .B(B_w),
	 .C(C)); 

 always @(posedge clk) begin
	 if (rst_n==0)begin
		 A <=#(`cq) 0; 
		 B <=#(`cq) 0;
	 end
	 else begin 
		 A <=#(`cq) A_w;
		 B <=#(`cq) B_w;
	 end
 end
endmodule
