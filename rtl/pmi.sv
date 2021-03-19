module pmi(
	input logic clk,
	input logic rst_n,
	input logic [31:0] in_data,
	input logic [31:0] address,
	input logic mem_rd,
	input logic mem_wr,
	output wire [31:0] data,
	output logic mfc);



// address map
// Instruction       : 0x0000_0000 to 0x0000_FFFF
// Memory Mapped CSRS: 0x0001_0000 to 0x0001_FFFF
// Reserved          : 0x0002_0000 to 0x0FFF_FFFF
// RAM, ROM, MMIO    : 0x1000_0000 to 0xDFFF_FFFF

//------------------------------------------------
// defining an instruction memory 
// worsize = 32
// address bits = 16 (64k X 4 bytes of memory)
// delays: write data hold = 1 time unit
// delays: rd to op delay  = 1 time unit
// -------------------------------------------



logic [2:0 ] state;
localparam idle = 3'b000;
localparam imem_rd = 3'b001;
logic ins_rd;
assign ins_rd = (mem_rd && address <= 32'h0000ffff)? 1'b1:1'b0;
assign #(`cd) mfc = ins_rd;
/*always_ff @(posedge clk) begin
	if (rst_n == 0) state <= idle;
	else begin
		case (state)
			idle   : if (mem_rd && address <= 32'h0000ffff) state <= #(`cq) imem_rd;
			imem_rd: state <= #(`cq) idle;
		default: state <= #(`cq) idle;
	endcase
end
  end
  //output logic
  always_comb begin
	  if (state == imem_rd) mfc = 1; else mfc = 0;
  end
  */
  ram #(32, 16, 2, 2) imem(
	  .data(data),
	  .address(address[17:2]),
	  .read(ins_rd),
	  .write(1'b0)
  ); 


  endmodule

