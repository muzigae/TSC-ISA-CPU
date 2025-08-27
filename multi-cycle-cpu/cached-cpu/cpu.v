`timescale 1ns/1ns
`define WORD_SIZE 16    // data and address word size
`define LINE_SIZE 64

`include "opcodes.v"
`include "constants.v"

module cpu(
        input Clk,
        input Reset_N,

	// Instruction memory interface
        output i_readM,
        output i_writeM,
        output [`WORD_SIZE-1:0] i_address,
        inout  [`LINE_SIZE-1:0] i_data,
        input  i_valid,

	// Data memory interface
        output d_readM,
        output d_writeM,
        output [`WORD_SIZE-1:0] d_address,
        inout  [`LINE_SIZE-1:0] d_data,
        input  d_valid,

        output [`WORD_SIZE-1:0] num_inst,
        output [`WORD_SIZE-1:0] output_port,
        output is_halted
);

	// TODO : Implement your pipelined CPU!
	
	// Datapath <-> Control Unit
    wire [3:0] opcode;
    wire [5:0] func_code;
    wire [`SIG_SIZE-1:0] control_signal;
    
    // Datapath <-> Cache
    wire i_readyC;
    wire i_readC;
    wire i_writeC;
    wire [`WORD_SIZE-1:0] i_data_dp;
    
    wire d_readyC;
    wire d_readC;
    wire d_writeC;
    wire [`WORD_SIZE-1:0] d_data_dp;
    
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
        
        .i_readM(i_readC),
        .i_writeM(i_writeC),
        .i_address(i_address),
        .i_data(i_data_dp),
        .i_readyM(i_readyC),
        
        .d_readM(d_readC),
        .d_writeM(d_writeC),
        .d_address(d_address),
        .d_data(d_data_dp),
        .d_readyM(d_readyC),
        
        .num_inst(num_inst),
        .output_port(output_port),
        .is_halted(is_halted),
        
        .control_signal(control_signal),
        
        .opcode(opcode),
        .func_code (func_code)
        );
    
    cache IC (  // instruction cache
        .clk(Clk),
        .reset_n(Reset_N),
        
        .readC(i_readC),
        .writeC(i_writeC),
        .readyC(i_readyC),
        
        .address(i_address),
        .data_dp(i_data_dp),
        .data_mem(i_data),
        
        .readM(i_readM),
        .writeM(i_writeM),
        .readyM(i_valid)
        );
        
    cache DC (  // data cache
        .clk(Clk),
        .reset_n(Reset_N),
        
        .readC(d_readC),
        .writeC(d_writeC),
        .readyC(d_readyC),
        
        .address(d_address),
        .data_dp(d_data_dp),
        .data_mem(d_data),
        
        .readM(d_readM),
        .writeM(d_writeM),
        .readyM(d_valid)
        );
endmodule
