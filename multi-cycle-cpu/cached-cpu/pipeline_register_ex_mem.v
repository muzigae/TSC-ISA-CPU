`timescale 1ns / 1ps

`include "opcodes.v"
`include "mux_selectors.v"
`include "control_selectors.v"
`include "constants.v"

module pipeline_register_ex_mem(
    input clk,
    input reset_n,
    input bubble,
    input stall_mem,
    
    input [15:0] pc_in,
    
    input branch_cond_in,
    input [15:0] alu_result_in,         // write address when MEM_WRITE
    
    input [15:0] read_data2_in,
    
    input [1:0] reg_dst_in,
    
    input [`SIG_SIZE-1:0] control_signal_in,
    
    output reg [15:0] pc_out,
    
    output reg branch_cond_out,
    output reg [15:0] alu_result_out,
    
    output reg [15:0] read_data2_out,
    
    output reg [1:0] reg_dst_out,
    
    output reg [`SIG_SIZE-1:0] control_signal_out
    );
    
    initial begin
        pc_out <= 0;
        branch_cond_out <= 0;
        alu_result_out <= 0;
        read_data2_out <= 0;
        reg_dst_out <= 0;
        control_signal_out <= 0;
    end
    
    always @ (negedge reset_n, posedge clk) begin
        if (!reset_n | bubble) begin
            pc_out <= 0;
            branch_cond_out <= 0;
            alu_result_out <= 0;
            read_data2_out <= 0;
            reg_dst_out <= 0;
            control_signal_out <= 0;
        end
        else if (!stall_mem) begin
            pc_out <= pc_in;
            branch_cond_out <= branch_cond_in;
            alu_result_out <= alu_result_in;
            read_data2_out <= read_data2_in;
            reg_dst_out <= reg_dst_in;
            control_signal_out <= control_signal_in;
        end
    end
    
endmodule
