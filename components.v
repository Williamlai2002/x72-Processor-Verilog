module sign_extend(in, ext); 
	/* 
	 * This module sign extends the 9-bit Din to a 16-bit output.
	 */
	// Declare inputs and outputs
	input [8:0] in;
	output reg [15:0] ext;
	
	// Implement logic
	
	// The input will be a twos complement
   // output is a sign extended 
	
	always @ (in) begin
		// If input is positive the MSB of In will be 0
		if(in[8] == 0) begin 
			ext[15:9] = 7'b0000000;
			ext[8:0] = in[8:0];
		end
		
		// If input is negative the MSB of the In will be 1
		else if (in[8] == 1) begin
			ext[15:9] = 7'b1111111;
			ext[8:0] = in[8:0];
		end
	end
endmodule



module tick_FSM(rst, clk, enable, tick);  
	/* 
	 * This module implements a tick FSM that will be used to
	 * control the actions of the control unit
	 */

	// Declare inputs and outputs
	input [0:0] rst;
	input [0:0] clk;
	input [0:0] enable;
	output reg [3:0] tick; // Output reg that represents the current tick.
	reg [3:0] next_state; 
	
    // Implement FSM
	 
	 // When enable is on, cycle through 4 ticks that is based on clk. 
	 // The outputted Tick is a 4 bit value to the control unit that performs tasks every tick depending on Opcode.
	 // The MSB of 'tick' represents tick4 and when it is high we choose an instruction from tick4 instructions based on current opcode
	 
	 // State our 4 possible tick states
	 parameter tick1 = 4'b0001;
	 parameter tick2 = 4'b0010;
	 parameter tick3 = 4'b0100;
	 parameter tick4 = 4'b1000;
	 
	 always @(posedge clk) begin
	 
		 if (rst) begin 
			tick <= tick1; // Reset current state back to tick1
		 end
		 else if (enable) begin
			tick <= next_state;
		 end
	 end
	 // If clk and enable is high cycle through our 4 ticks, setting our current tick to tick1....tick4
	 always @(*) begin
		case(tick)
		
			tick1: 
				next_state =tick2;
			tick2: 
				next_state =tick3;
			tick3:
				next_state =tick4;
			tick4:
				next_state =tick1;
				
			default:
				next_state =tick1;
			
		endcase
	 end

	 
endmodule

module multiplexer(SignExtDin, R0, R1, R2, R3, R4, R5, R6, R7, G, sel, Bus);
	/* 
	 * This module takes 10 inputs and places the correct input onto the bus.
	 */
	// Declare inputs and outputs
	input [15:0] SignExtDin, R0, R1, R2, R3, R4, R5, R6, R7, G;
   input [3:0] sel;
   output reg [15:0] Bus;
	
	// Implement logic
	always @(*) begin
    case (sel)
        4'b0000: Bus = R0;
        4'b0001: Bus = R1;
        4'b0010: Bus = R2;
        4'b0011: Bus = R3;
        4'b0100: Bus = R4;
        4'b0101: Bus = R5;
        4'b0110: Bus = R6;
        4'b0111: Bus = R7;
        4'b1000: Bus = G;
        4'b1001: Bus = SignExtDin;
        default: Bus = 16'b0; // Default to 0 if sel is invalid
    endcase
	 end
endmodule


module ALU (input_a, input_b, alu_op, result); 
	/* 
	 * This module implements the arithmetic logic unit of the processor.
	 */
	// Declare inputs and outputs
	input [15:0] input_a;
	input [15:0] input_b;
	input [2:0] alu_op;
	output reg [15:0] result;
	
	// Implement ALU Logic:
	always @ (*) begin
	
		case(alu_op)
			
			3'b000:
					result = input_a * input_b;
			3'b001:
					result = input_a + input_b;
			3'b010:
					result = input_a - input_b;
			3'b011:
					if (input_a >=0) begin
						// Shift left when input_a is positive
						result = input_b <<< input_a;
					end
					else begin
						// Shift right when the input_a is negative
						result = input_b >>> (-input_a);
					end
			default: result = 16'b0; // Default to 0 if sel is invalid
		endcase
	end
endmodule


module register_n #(parameter n = 8)(data_in,r_in,rst,clk,Q);
	/*

	Function: Creates an n-bit register

	Input:
		n = parameter for the width of the data
		data_in = data to be stored
		r_in = enables the register to store data
		rst = Resets value to 0
		clk = clock
		
	Output:
		Q= output
	*/
	
	//IO
	input [n-1:0] data_in;
	input r_in, rst,clk;
	output reg [n-1:0] Q;
	
	always @(posedge clk) begin
		if (rst) begin
		Q <= {n{1'b0}}; // format for creating n-bit output is from stackoverflow
		end
		else if (r_in) begin
		Q <= data_in;
		end
	end

endmodule 

