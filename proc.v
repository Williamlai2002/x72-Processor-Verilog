// Instantiating module
module proc(SW, KEY, LEDR, HEX5, bus_out);
		
		input [8:0] SW; // COnnects SW[8:0] to the bus input of the processor
		input [1:0] KEY;
		output [9:0] LEDR; // Connects to the bottom 10 bits of the bus output of the processor.
		
		
		wire reset = ~KEY[0]; // Connects ~KEY[0] to the reset input of the processor, to use as synchronous reset.
		wire clock = ~KEY[1]; // Connect ~KEY[1] to the clock input of the processor.
		assign enable = 1'b1;
		
		output wire [15:0] bus_out;
		wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7;
		wire [3:0] tick_output;
		
		output [6:0] HEX5;
		
		// Connect 1’b1 to the enable input of the tick_FSM
		
		tick_FSM insttick(.rst(reset), .clk(clock), .enable(enable), .tick(tick_output));
		
		// Instantiate simple proc
		simple_proc instproc(.clk(clock), .rst(reset), .din(SW), .bus(bus_out), .R0(R0), .R1(R1), .R2(R2), .R3(R3), .R4(R4), .R5(R5), .R6(R6), .R7(R7));

		assign LEDR = bus_out[9:0];
		
		// Display tick_FSM output
		bcd bcd_inst(.in(tick_output), .HEX(HEX5));
		



endmodule 


module simple_proc(clk, rst, din, bus, R0, R1, R2, R3, R4, R5, R6, R7);

    // Note: The skeleton you are provided with includes output ports to output the values of the internal registers R0 - R7, for the purpose of test benching. When instantiating the processor to program your DE10-lite, you can leave these ports unused.

    // Declare inputs and outputs:
	 
	 
	 // Declare Inputs and Outputs

    input clk;                // Clock signal
    input rst;                // Synchronous reset signal
    input [8:0] din;          // 9-bit data input (DIN)
    output [15:0] bus;        // 16-bit data bus output (for observation)
    output [15:0] R0, R1, R2, R3, R4, R5, R6, R7; // Outputs for internal registers


    // Internal Wires and Registers

    wire [15:0] Bus;          // Internal data bus
    wire [15:0] sign_ext;   // Sign-extended DIN
    wire [8:0] IR_output;         // Output of Instruction Register (IR)
    wire [15:0] G;         // Output of Register G
    wire [15:0] A;         // Output of Register A
    wire [15:0] ALU_output;   // Result from ALU
    wire [3:0] tick;          // Tick counter from tick_FSM

    // Control signals
    reg [3:0] bus_control;    // Controls the multiplexer selection
    reg [7:0] Rin;            // Write enable signals for registers R0 - R7
    reg ir_in, r_A, r_G;       // Write enable signals for IR, A, G
    reg [2:0] ALUop;          // ALU operation code
	 
	 
	  wire [15:0] R [7:0];  // Array to hold the values of R0, R1, ..., R7
	  
	  wire [2:0] opcode = IR_output[8:6];
	  wire [2:0] rx = IR_output[5:3];
     wire [2:0] ry = IR_output[2:0];


    // Instantiate registers:
    generate
    genvar i;
    for (i = 0; i < 8; i = i + 1) begin : reg_gen
        register_n reg_inst (
            .data_in(Bus),
            .r_in(Rin[i]),
            .clk(clk),
            .rst(rst),
            .Q(R[i])  // Connect the output to R[i], where i corresponds to R0, R1, ..., R7
        );
    end
	endgenerate
	 
	 
	 // instantiate Registers A and G
	 register_n regA(.data_in(bus), .r_in(r_A), .clk(clk), .Q(A), .rst(rst)); // Reg A
	 register_n regG(.data_in(ALU_output), .r_in(r_G), .clk(clk), .Q(G), .rst(rst)); // Reg G
	 
	 // Instatinaite IR register:
	 register_n regIR(.data_in(din), .r_in(ir_in), .clk(clk), .Q(IR_output), .rst(rst));
	 
    // Instantiate Multiplexer:
	 
	 // Input of multiplexer is Din sign extended to 16 bits, R0-R7, Register G
	 sign_extend ext(.in(din), .ext(sign_ext)); 
	 multiplexer multi(.SignExtDin(sign_ext), .R0(R0), .R1(R1), .R2(R2), .R3(R3), .R4(R4), .R5(R5), .R6(R6), .R7(R7), .G(G), .sel(bus_control), .Bus(bus));
	 
    
    
    // Instantiate ALU:
	 
	 // Inputs register A and Bus
	 // ALUop chooses which ALU intruction to choose 
	 ALU aluinst(.input_a(A), .input_b(bus), .alu_op(ALUop), .result(ALU_output));
    
    
    // Instantiate tick counter:
    tick_FSM tickinst(.rst(rst), .clk(clk), .enable(1'b1), .tick(tick));
    
    // Define control unit:
	 // Inputs for the control unit are current instruction, as well as the tick FSM output

	
    always @(posedge clk or posedge rst) begin
				
	 
	         if (rst) begin
            // Reset all control signals
            bus_control <= 4'b0000;
            ALUop <= 3'b111;
            Rin <= 8'b00000000;
            ir_in <= 1'b0;
            r_A <= 1'b0;
            r_G <= 1'b0;
				end else begin
            // Default values for control signals (turned off)
            bus_control <= 4'b0000;
            ALUop <= 3'b111;
            Rin <= 8'b00000000;
            ir_in <= 1'b0;
            r_A <= 1'b0;
            r_G <= 1'b0;
				
				
				
        // Turn on specific control signals based on current tick:
        case (tick)
            4'b0001: /* Tick 1 */
                begin
					     // Tick 1: Read DIN into the IR Register so that the control unit can decode and process the information.
						  ir_in <= 1'b1;
						
                 end
            
            4'b0010:/* Tick 2 */
                begin
						  case(opcode)
						  3'b111: begin // movi Rx, Immi
                                bus_control <= 4'd9; // Select SignExtDin onto Bus
                                Rin[rx] <= 1'b1; // Write to Rx
                            end
                            3'b001, 3'b011: begin // add Rx, Ry or sub Rx, Ry
                                bus_control <= rx; // Select Rx
										  r_A <= 1'b1; // Store the value in register A
                            end
                            3'b010: begin // addi Rx, Immi
                                bus_control <= rx; // Select Rx onto Bus
                                r_A <= 1'b1; // Load into Register A
                            end
                            default: begin
                                // Do nothing for unsupported opcodes
                            end
						  endcase
                end
            
             4'b0100/* Tick 3 */:
                begin
					 case (opcode) // Decode opcode
                            3'b001: begin // add Rx, Ry
                                bus_control <= ry; // Select Ry onto Bus
                                ALUop <= 3'b001; // Set ALU operation to addition
                                r_G <= 1'b1; // Load ALU result into Register G
                            end
                            3'b011: begin // sub Rx, Ry
                                bus_control <=ry; // Select Ry onto Bus
                                ALUop <= 3'b010; // Set ALU operation to subtraction
                                r_G <= 1'b1; // Load ALU result into Register G
                            end
                            3'b010: begin // addi Rx, Immi
                                bus_control <= 4'd9; // Select SignExtDin onto Bus
                                ALUop <= 3'b001; // Set ALU operation to addition
                                r_G <= 1'b1; // Load ALU result into Register G
                            end
                            default: begin
                                // Do nothing for unsupported opcodes
                            end
                        endcase
                end
            
					 
					  4'b1000: // Tick 4
                    begin
                        case (opcode) // Decode opcode
                            3'b001, 3'b010, 3'b011: begin // add, addi, sub
                                bus_control <= 4'd8; // Select G onto Bus
                                Rin[rx] <= 1'b1; // Write back to Rx
                            end
                            default: begin
                                // Do nothing for unsupported opcodes
                            end
                        endcase
                    end

                default: begin
                    // Do nothing in default case
                end

        endcase

		end
	 end
endmodule