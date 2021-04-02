 module control_gen(
	clk, 
	rst_n,
	ins,
	mfc,
	PC_sel,
	PC_en,
	INC_sel,
	IR_en,
	imm,
    RF_wr,
    B_sel, 
    ALU_op,
    Y_sel,
    Mem_rd,
    Mem_wr,
    MA_sel);

input logic clk, rst_n,mfc;
input logic [31:0] ins;
output logic [31:0] imm;
output logic [4:0] ALU_op;
output logic PC_sel, PC_en, INC_sel, IR_en, RF_wr, B_sel, Mem_rd, Mem_wr, MA_sel;
output logic [1:0] Y_sel;
 
logic wmfc;

//-----------------------------------
// Instruction Categories definition
// ----------------------------------
localparam  R = 3'b000;
localparam  I = 3'b001;
localparam  L = 3'b010;
localparam JR =	3'b011;
localparam  S = 3'b100;
localparam SB = 3'b101;
localparam  U = 3'b110;
localparam UJ = 3'b111; 

//----------------------------------
// States for control state machine
// ---------------------------------
 reg [4:0] state;
`define RESET   'b00000
`define FETCH   'b00001
`define DECODE  'b00010
`define COMPUTE 'b00100
`define MEM     'b01000
`define WB      'b10000     

wire Count_en;
wire [6:0] opcode;
wire [2:0] funct3;
wire [6:0] funct7;
wire [11:0] imm12; 
reg [2:0] Ins_t;
//------------------------------
//separating instruction fields
//------------------------------
assign opcode = ins[6:0];
assign funct3 = ins[14:12];
assign funct7 = ins[31:26];
assign imm12  = ins[21:20];    

//--------------------------------------
//this will be used to stall the machine 
//e.g., waiting for mem
//--------------------------------------
assign Count_en = (wmfc == 0 || mfc==1); 

//-------------------------------------
// Determining instruction types
// Reference H&P Figure 2.18
// last 2 bits are always 1 for base ISA
// Can reduce the comparator size
// ------------------------------------
always @(*) begin
	case (opcode)
		7'b0110011: Ins_t = R;  // register
		7'b0000011: Ins_t = L; //load
		7'b0010011: Ins_t = I; //arithmetic
		7'b1100111: Ins_t = JR; //jalr
		7'b0100011: Ins_t = S; // store instructions
		7'b1100111: Ins_t = SB; // branch ins
		7'b0110111: Ins_t = U; //lui, auipc
		7'b1101111: Ins_t = UJ; //jal
		default:    Ins_t = R;
	endcase
end

//-----------------------------------
// state machine for generating control signals
// state transitions
// ----------------------------------
always_ff @(posedge clk or negedge rst_n) begin
	if (rst_n == 0)
		state <= #(`cq) `RESET;
	else if (Count_en) begin
		case (state)
			`RESET:    state <= #(`cq) `FETCH;
			`FETCH:    state <= #(`cq) `DECODE;
			`DECODE:   state <= #(`cq) `COMPUTE;
			`COMPUTE:  state <= #(`cq) `MEM;
			`MEM:      state <= #(`cq) `WB;
			`WB:       state <= #(`cq) `FETCH;
			default:   state <= #(`cq) `FETCH;
		endcase
	end
end  
// always @ (state)
always_comb begin
	//INC_sel
	if (state == `COMPUTE) INC_sel = 1; else INC_sel = 0; //need to fix for branch instruction
	// PC_sel
	if (state == `FETCH)   PC_sel =  1; else PC_sel = 0; // need to fix this for branch
    //PC_en
	if (state == `FETCH)   PC_en = 1; else PC_en = 0;
	//IR_en
	if (state == `FETCH)   IR_en = 1; else IR_en = 0;
	//RF_write
	if (state == `WB && (Ins_t == R || Ins_t == I || Ins_t == UJ || Ins_t == L || Ins_t ==JR || Ins_t==U ) ) RF_wr = 1; else RF_wr = 0;
	//B_sel mux B select
	//if (state == `COMPUTE && (Ins_t == I || Ins_t == L || Ins_t == JR)) B_sel = 1; else B_sel = 0;
	if ((Ins_t == I || Ins_t == L || Ins_t == JR)|| Ins_t ==U ) B_sel = 1; else B_sel = 0;
	// Y_sel
    if (Ins_t == I || Ins_t == R || Ins_t==U) Y_sel = 2'b00;
	else if (Ins_t == L) Y_sel = 2'b01;
	else if (Ins_t == JR) Y_sel = 2'b10;
	else Y_sel = 2'b11;
	// Mem_rd, Mem_wr
    if (state == `FETCH || (state== `MEM && Ins_t==L)) Mem_rd = 1; else Mem_rd = 0;
	if (state == `MEM && Ins_t==S) Mem_wr = 1; else Mem_wr = 0;
    // wmfc
    if (state == `FETCH || (state == `MEM && Ins_t == L) || (state == `MEM && Ins_t == S)) wmfc = 1; else wmfc = 0;
	//MA_sel : selects whether the address sent to memory comes from PC or RX
    if (state == `MEM && (Ins_t ==L || Ins_t == S)) MA_sel = 0; else MA_sel = 1;
//
end

//--------------------------------
//Generating the 32 bit immediate
//--------------------------------
always @ (*) begin
case (Ins_t)
	I: imm  = { {20{ins[31]}}, ins[31:20]};
	S: imm  = { {20{ins[31]}}, ins[31:25] ,ins[11:7]};
	SB: imm = { {19{ins[31]}}, ins[31], ins[7], ins[30:25], ins[11:8] ,1'b0 };
    U : imm = (ins[31:12] << 12);
    UJ: imm = { {11{ins[31]}},ins[31], ins[19:12], ins[20], ins[30:21], 1'b0};
	default: imm = 32'd0;
endcase
end



//--------------------------
// Generating ALU Operation
//  reference slides from cornell
//--------------------------
logic is_ld;
logic is_st;
logic is_alu_add;

assign is_ld = (opcode == 7'b0000011);
assign is_st = (opcode == 7'b0100011);

// R-type arithmetic & Logic instructions
assign is_alu_sub     = (Ins_t == R && funct3 == 3'b000 && funct7 == 7'b0100000);
assign is_alu_add     = (Ins_t == R && funct3 == 3'b000 && funct7 == 7'b0000000);
assign is_alu_or      = (Ins_t == R && funct3 == 3'b110 && funct7 == 7'b0000000);
assign is_alu_xor     = (Ins_t == R && funct3 == 3'b100 && funct7 == 7'b0000000);
assign is_alu_and     = (Ins_t == R && funct3 == 3'b111 && funct7 == 7'b0000000);
// R-type shift instructions
assign is_alu_sll     = (Ins_t == R && funct3 == 3'b001 && funct7 == 7'b0000000);
assign is_alu_srl     = (Ins_t == R && funct3 == 3'b101 && funct7 == 7'b0000000);
assign is_alu_sra     = (Ins_t == R && funct3 == 3'b101 && funct7 == 7'b0100000);
// Immediate Arithmetic & Logic
assign is_alu_addi    = ( Ins_t == I && funct3 == 3'b000);
assign is_alu_andi    = ( Ins_t == I && funct3 == 3'b111);
assign is_alu_ori     = ( Ins_t == I && funct3 == 3'b110);
assign is_alu_xori    = ( Ins_t == I && funct3 == 3'b100);
// U-type instruction
assign is_alu_lui = (opcode == 7'b0110111);

always_comb
 begin
	 if (is_ld || is_st || is_alu_add || is_alu_addi) ALU_op = 5'd0;
	 else if (is_alu_sub)                ALU_op = 5'd1;
	 else if (is_alu_or  || is_alu_ori)  ALU_op = 5'd2;
	 else if (is_alu_xor || is_alu_xori) ALU_op = 5'd3;
	 else if (is_alu_and || is_alu_andi) ALU_op = 5'd4;
	 else if (is_alu_sll)                ALU_op = 5'd5;
	 else if (is_alu_srl)                ALU_op = 5'd6;
	 else if (is_alu_sra)                ALU_op = 5'd7;
	 else if (is_alu_lui)                ALU_op = 5'd8;
	 else ALU_op = 5'd1;
 end

endmodule













