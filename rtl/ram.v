 module ram(data, address, read, write);
 
 parameter width = 32; //default word size
 parameter abits = 8 ; //default number of address bits
 parameter twdh = 1; // write data hold
 parameter trd  = 1; // rd to output delay

 input [abits-1:0] address;
 inout [width-1:0] data;

 input read, write;

 //internal storage
 reg[width-1:0] mem [0: (1<<abits) -1];

 /* simple behavior of a static RAM
    write occurs when write is 1.
	To act more like a ralistic SRAM, if data changes while write is asserted
	the data in memory is changed
*/
 always @(write or data)
	 if (write)
		 #twdh mem[address] = data;

 assign #trd data = read ? mem[address] : 'bz;

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
	

