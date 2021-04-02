
module farm_top(
	input clk,
	input rst_n,
	output [31:0] ins,
	output [31:0] ret_ad);

wire [31:0] imem_data;
logic [31:0] imem_ad;
logic [31:0] imm; 
logic [4:0] ALU_op; //output of cotrol generator
logic [31:0] ra, rb; //output of decode 
logic [31:0] rz, rm; //output of compute
logic [31:0] ry;     //output of memAccess
logic [1:0] y_sel;
wire [31:0] mem_ad;
wire MA_sel;

//------------------------------------------------------------
// Instruction Fetch
// Output: Instruction to be executed
// Output: Return Address in case of a call instruction
// input: control signals PC_sel, PC_en, INC_Sel, IR_en, Extend
// ------------------------------------------------------------
ins_fetch farm_fetch(
.clk(clk),
.rst_n(rst_n),
.PC_sel(PC_sel),
.PC_en(PC_en),
.INC_sel(INC_sel),
.IR_en(IR_en),
.ra(ra),
.ins_mem(imem_data),
.branch_offset(imm),
.ins_ad(imem_ad),
.ins(ins),
.ret_ad(ret_ad));

//--------------------------------------------------------------
//processor memory interface
// A simple interface to talk to the memory (cache, SRAM)
// asserts mfc for one cycle after memory operation is complete
//-------------------------------------------------------------
assign mem_ad = MA_sel ? imem_ad : rz;  
pmi farm_pmi(
	 .clk(clk),
	 .rst_n(rst_n),
	 .data_in(rm),
	 .address(mem_ad),
	 .mem_rd(Mem_rd),
	 .mem_wr(Mem_wr),
	 .data(imem_data),
	 .mfc(mfc));     

//------------------------------------
 // Instruction memory
 // Modeling separate instruction memory at the moment
 // Will move to multiported combined (ins + data) memory for pipelined version
 // this memory is being initialized in the testbench with test code
 // ---------------------------------------------------
 /*ram #(32, 16, 2, 2) imem(
 .data(imem_data),
 .address(imem_ad[17:2]),
 .read(1'b1),
 .write(1'b0)
 );*/

 //----------------------------
 // Control signal generator
 // going for hardlogicd control 
 // ----------------------------
 control_gen cg(
 .clk   (clk),
 .rst_n (rst_n),
 .ins   (ins),
 .mfc   (mfc),
 .PC_sel(PC_sel),
 .PC_en (PC_en),
 .INC_sel(INC_sel),
 .IR_en (IR_en),
 .imm(imm),
 .RF_wr(RF_write),
 .B_sel(B_sel),
 .ALU_op(ALU_op),
 .Y_sel(y_sel),
 .Mem_rd(Mem_rd),
 .Mem_wr(Mem_wr),
 .MA_sel(MA_sel)
 );

 //---------------------------------
 // Instruction Decode
 // Decode for RV is simple.
 // In this stage we'll be reading from register file
 // ---------------------------------------------
 decode farm_dec(
 .clk(clk),
 .rst_n(rst_n),
 .RF_write(RF_write),
 .ins(ins),
 .A(ra),
 .B(rb),
 .C(rz));

//---------------------------------------
// Compute stage
// perform the alu operation based on instruction
// --------------------------------------------
compute farm_compute(
.clk(clk),
.rst_n(rst_n),
.ra(ra),
.rb(rb),
.imm(imm),
.ALU_op(ALU_op),
.B_sel(B_sel),
.rz(rz),
.rm(rm)
);

//---------------------------------------------
// Mem Access stage
// For Load ins read memory
// for store write to memory
// for branch forward ret_ad to wb stage
// alu ins forward alu result to wb
// ---------------------------------------------
memAccess farm_ma(
.clk (clk),
.rst_n (rst_n),
.rz (rz),
.rm (rm),
.Y_sel(y_sel), // should come from control gen
.mem_data(),  // need to define a PMI
.ret_ad(ret_ad),
.mem_adr(),
.ry(ry)
);



endmodule
