module farm_tb;

import farm_pkg::*;
reg clk, rst_n;
reg[1:0] Extend;
reg [31:0] ra, imem_data;

wire [31:0] ins, ret_ad;
wire [31:0] imem_ad;
  
                                                
   farm_top DUT(
	 .clk(clk),
	 .rst_n(rst_n),
	 .ins(ins),
     .ret_ad(ret_ad));         
 
 initial begin
      clk = 0;
      forever begin
         #10;
         clk = ~clk;
      end
   end  
 
 task reset_alu();
	 rst_n = 1'b0;
	 @(posedge clk);
	 @(posedge clk);

	 rst_n = 1'b1;
 endtask: reset_alu

 task init_imem();
	 $readmemh("../tb/hex/program.hex", DUT.farm_pmi.imem.mem);
	 //DUT.imem.dump(0,7);
 endtask



 initial begin
	 $dumpfile("test.vcd");
	 $dumpvars;
 end

 initial begin: tester
	 reset_alu();
	 init_imem();
	 // Test 1: PC_sel = 0 --> ra will be selected
	 // at first clock edge PC will get the value of ra
	 // at the next clock edge PC_temp should get ra
	 // This should be the output ret_ad at the second clock edge
	 

	 #550 DUT.farm_dec.RF.dump(0,10); 
	 
	 $finish;
 end: tester
 initial begin
	 $monitor("t=%3d State = %h PC=%h ins=%h ",$time,DUT.cg.state,DUT.farm_fetch.iag.PC, DUT.farm_fetch.IR );
 end
endmodule
