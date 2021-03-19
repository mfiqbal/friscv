 module control_gen(
	clk, 
	rst_n,
	ins,
	PC_sel,
	PC_en,
	INC_sel,
	IR_en,
	Extend,
    RF_wr,
    B_sel);

input clk, rst_n;
input [31:0] ins;
output [1:0] Extend;
output PC_sel, PC_en, INC_sel, IR_en, RF_wr, B_sel;
reg PC_sel, PC_en, INC_sel, IR_en, B_sel;
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


assign Count_en = 1; // this will be used to stall the machine e.g., waiting for mem

 //-----------------------------------
// Modeling Counter of Figure 5.21
// state transitions
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

//-------------------------------------------
// Generation of control signals
// -----------------------------------------
always @ (state) begin
	//INC_sel
	if (state == `COMPUTE) INC_sel = 1 else INC_sel = 0; //need to fix for branch instruction
	// PC_sel
	if (state == `FETCH)   PC_sel =  1 else PC_sel = 0; // need to fix this for branch
    //PC_en
	if (state == `FETCH)   PC_en = 1 else PC_en = 0;
	//IR_en
	if (state == `FETCH)   IR_en = 1 else IR_en = 0;
	// Extend
	if (state == `DECODE) Extend = 2'b00; else Extend = 2'b01; // temp
	//RF_write
	if (state == `WB && opcode[4:0] == 5'b10011) RF_wr = 1; else RF_wr = 0; // need to be fixed
	//B_sel mux B select
	if (state == `COMPUTE && `OPCODE ==  7'b0110011) B_sel = 0; else B_sel = 1;


end














