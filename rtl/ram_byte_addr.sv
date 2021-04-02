 module ram_byte_addr(
	 input logic [31:0] data_in, 
	 input logic [31:0] address, 
	 input logic read, 
	 input logic write,
     
	 output logic [31:0] data_out
     );
 // model for a byte addressable memory
 
 parameter MEM_SZ = (1 << 25); // 32 MBytes 


 //internal storage
 reg[7:0] mem [0: MEM_SZ -1];
 
 /* simple behavior of a static RAM
    write occurs when write is 1.
	To act more like a ralistic SRAM, if data changes while write is asserted
	the data in memory is changed
*/
 wire [31:0] adr = address & (MEM_SZ-1);

 wire [31:0] data_out = { mem[{adr[31:2],2'd3}],
	                      mem[{adr[31:2],2'd2}],
						  mem[{adr[31:2],2'd1}],
						  mem[{adr[31:2],2'd0}]};
 
 always_comb
	 if (write)begin
	    mem[{adr[31:2],2'd3}] = data_in[31:24];
	    mem[{adr[31:2],2'd2}] = data_in[23:16];
	    mem[{adr[31:2],2'd1}] = data_in[15:08];
	    mem[{adr[31:2],2'd0}] = data_in[07:00];
	  end

 

 /*convenience task for displaying the contents of the memory
 * during interactive debug.
 */

 task dump;
	 input [31:0] low, high;
	 integer i;
	 begin
		 for (i = low; i <= high; i = i+1)
			 $display ("mem [%h] = %h", i, mem[i]);
		     
		 $stop;
	 end
 endtask
 endmodule
	

