`timescale 1ns/1ns
`define WORD_SIZE 16    // data and address word size

`include "opcodes.v"
`include "constants.v"

module cpu(
        input Clk, 
        input Reset_N, 

	// Instruction memory interface
        output i_readM, 
        output i_writeM, 
        output [`WORD_SIZE-1:0] i_address, 
        inout [`WORD_SIZE-1:0] i_data, 

	// Data memory interface
        output d_readM, 
        output d_writeM, 
        output [`WORD_SIZE-1:0] d_address, 
        inout [`WORD_SIZE-1:0] d_data, 

        output [`WORD_SIZE-1:0] num_inst, 
        output [`WORD_SIZE-1:0] output_port, 
        output is_halted
);

	// TODO : Implement your pipelined CPU!
	
	// Datapath <-> Control Unit
    wire [3:0] opcode;
    wire [5:0] func_code;
    wire [`SIG_SIZE-1:0] control_signal;
    
    control_unit Control (
        .clk(Clk),
        .reset_n(Reset_N),
        
        .opcode(opcode),
        .func_code(func_code),
        
        .control_signal(control_signal)
        ); 
        
    datapath #(.WORD_SIZE (`WORD_SIZE)) 
        DP (
        .clk(Clk),
        .reset_n(Reset_N),
        
        .i_readM(i_readM),
        .i_writeM(i_writeM),
        .i_address(i_address),
        .i_data(i_data),
        
        .d_readM(d_readM),
        .d_writeM(d_writeM),
        .d_address(d_address),
        .d_data(d_data),
        
        .num_inst(num_inst),
        .output_port(output_port),
        .is_halted(is_halted),
        
        .control_signal(control_signal),
        
        .opcode(opcode),
        .func_code (func_code)
        );

endmodule
