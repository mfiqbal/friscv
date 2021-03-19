module alu(inA, inB, alu_out, ALU_op);
input logic [31:0] inA, inB;
output logic [31:0] alu_out;
input logic [4:0] ALU_op;
always_comb begin
	case(ALU_op)
		5'b00000: alu_out = inA + inB;
		5'b00001: alu_out = inA - inB;
		5'b00010: alu_out = inA | inB;
		5'b00011: alu_out = inA ^ inB;
		5'b00100: alu_out = inA & inB;
		5'b00101: alu_out = inA << inB;
		5'b00110: alu_out = inA >> inB;
		5'b00111: alu_out = inA >>> inB; //shift right arithmetic
		5'b01000: alu_out = inB; // lui
		default: alu_out = 0;
	endcase
end

endmodule
