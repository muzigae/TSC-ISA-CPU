`timescale 1ns / 1ps

`include "opcodes.v"
`include "mux_selectors.v"
`include "control_selectors.v"
`include "constants.v"

module pipeline_register_mem_wb(
    input clk,
    input reset_n,
    input stall_mem,
    
    input [15:0] pc_in,
    
    input [15:0] mem_data_in,
    input [15:0] alu_result_in,
    
    input [1:0] reg_dst_in,
    
    input [`SIG_SIZE-1:0] control_signal_in,
    
    output reg [15:0] pc_out,
    
    output reg [15:0] mem_data_out,
    output reg [15:0] alu_result_out,
    
    output reg [1:0] reg_dst_out,
    
    output reg [`SIG_SIZE-1:0] control_signal_out
    );
    
    initial begin
        pc_out <= 0;
        mem_data_out <= 0;
        alu_result_out <= 0;
        reg_dst_out <= 0;
        control_signal_out <= 0;
    end
    
    always @ (negedge reset_n, posedge clk) begin
        if (!reset_n | stall_mem) begin
            pc_out <= 0;
            mem_data_out <= 0;
            alu_result_out <= 0;
            reg_dst_out <= 0;
            control_signal_out <= 0;
        end
        else begin
            pc_out <= pc_in;
            mem_data_out <= mem_data_in;
            alu_result_out <= alu_result_in;
            reg_dst_out <= reg_dst_in;
            control_signal_out <= control_signal_in;
        end
    end
    
endmodule
