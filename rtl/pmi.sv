module pmi(
	input logic clk,
	input logic rst_n,
	input logic [31:0] data_in,
	input logic [31:0] address,
	input logic mem_rd,
	input logic mem_wr,
	output wire [31:0] data,
	output logic mfc);



// address map
// Instruction       : 0x0000_0000 to 0x0000_FFFF
// Memory Mapped CSRS: 0x0001_0000 to 0x0001_FFFF
// Reserved          : 0x0002_0000 to 0x0002_FFFF
// RAM, ROM, MMIO    : 0x0003_0000 to 0xDFFF_FFFF

//------------------------------------------------
// defining an instruction memory 
// worsize = 32
// address bits = 16 (64k X 4 bytes of memory)
// delays: write data hold = 1 time unit
// delays: rd to op delay  = 1 time unit
// -------------------------------------------



logic ins_rd;
logic data_access;

assign ins_rd = (mem_rd && address <= 32'h0000ffff)? 1'b1:1'b0;
assign data_access = (mem_rd || mem_wr) && (address >= 32'h00030000);

assign #(`cd) mfc = ins_rd || (data_access); 

/*ram #(32, 26, 2, 2) imem(
	  .data(data),
	  .address(address[27:2]),
	  .read(ins_rd),
	  .write(1'b0)
  ); 

 */
ram_byte_addr fmem(
	.data_in(data_in),
	.address(address),
	.read(mem_rd),
	.write(mem_wr),
	.data_out(data)
);
  endmodule

