module control_gen(
	clk, 
	rst_n,
	ins,
	PC_sel,
	PC_en,
	INC_sel,
	IR_en,
	Extend,
    RF_wr);

input clk, rst_n;
input [31:0] ins;
output [1:0] Extend;
output PC_sel, PC_en, INC_sel, IR_en, RF_wr;
reg PC_sel, PC_en, INC_sel, IR_en;
reg[1:0] Extend;

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
//separating instruction fields
assign opcode = ins[6:0];
assign funct3 = ins[14:12];
assign funct7 = ins[31:26];
assign imm12  = ins[21:20];
//---------------------------------------
//Control word definition
// order of bits in the control word
// [INC_sel, PC_Sel, PC_en, IR_en,
// MA_sel, Mem_rd, Mem_wr, WMFC, Extend[1:0], B_Sel
// Y_Sel[1:0], RF_Wr, C_sel[1:0]
// ------------------------------------------------
reg [15:0] control_word;
assign INC_sel = control_word[15];
assign PC_sel  = control_word[14];
assign PC_en   = control_word[13];
assign IR_en   = control_word[12];
assign MA_sel  = control_word[11];
assign Mem_rd  = control_word[10];
assign Mem_wr  = control_word[9];
assign wmfc    = control_word[8];
assign Extend  = control_word[7:6];
assign B_sel   = control_word[5];
assign Y_sel   = control_word[4:3];
assign RF_wr   = control_word[2];
assign C_sel   = control_word[1:0];


assign Count_en = 1;

//-----------------------------------
// Modeling Counter of Figure 5.21
// ----------------------------------
always @(posedge clk or negedge rst_n) begin
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

//-------------------------------
// Generation of Control Signals
// -----------------------------

always @(state) begin
	case (state) 
		`RESET: 
			control_word = 16'b0100110100000000; 
		`FETCH: // Fetch is same for all types of instructions   
			control_word = 16'b0111110100000000; 
		// To Do
		`DECODE:  begin
				control_word = 16'b0100110100000000;

			end
		`COMPUTE: begin
            if (opcode == 7'b0110011)
				control_word = 16'b0100110100000000;
			else
				control_word = 16'b0100110100100000;

			end 
		`MEM:     control_word = 16'b0100110100000000;
		//RF_write = 1 if ALU, LOAD, or CALL inst
		//RF_write is bit 2 
		// C_sel is also of interest in this stage
		// C_sel is bits [1:0]
		`WB:      control_word = 16'b0100110100000100; 
		default:  control_word = 16'b0100110100000000; 
	endcase
end

endmodule
