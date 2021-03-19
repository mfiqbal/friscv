module memAccess(
	input logic clk,
	input logic rst_n,
	input logic [31:0] rz,
	input logic [31:0] rm,
	input logic [1:0] Y_sel,
	input logic [31:0] mem_data,
	input logic [31:0] ret_ad,
	output logic [31:0] mem_adr,
	output logic[31:0] ry
);

logic [31:0] muxY_out;

assign mem_adr = rm;

muxMto1 #(32, 4, 2) muxY(.D ({32'd0 ,ret_ad, mem_data, rz}),
	                     .SEL(Y_sel),
						 .Z(muxY_out));


always_ff @(posedge clk) begin
	if (rst_n == 0) ry <= #(`cq) 0;
	else            ry <= #(`cq) muxY_out;
end

endmodule
