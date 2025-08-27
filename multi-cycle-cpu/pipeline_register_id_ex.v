`timescale 1ns / 1ps

`include "opcodes.v"
`include "mux_selectors.v"
`include "control_selectors.v"
`include "constants.v"

module pipeline_register_id_ex(
    input clk,
    input reset_n,
    input stall,
    input bubble,
    
    input [15:0] pc_in,
    
    input [15:0] read_data1_in,
    input [15:0] read_data2_in,
    
    input [15:0] sign_extend_imm_in,       // immediate
    
    input [1:0] rt_in,
    input [1:0] rd_in,
    
    input [`SIG_SIZE-1:0] control_signal_in,
    
    output reg [15:0] pc_out,
    
    output reg [15:0] read_data1_out,
    output reg [15:0] read_data2_out,
    
    output reg [15:0] sign_extend_imm_out, // immediate
    
    output reg [1:0] rt_out,
    output reg [1:0] rd_out,
    
    output reg [`SIG_SIZE-1:0] control_signal_out
    );
    
    reg ignore_control_signal;      // ignore control signal after bubble
    
    initial begin
        pc_out <= 0;
        read_data1_out <= 0;
        read_data2_out <= 0;
        sign_extend_imm_out <= 0;
        rt_out <= 0;
        rd_out <= 0;
        control_signal_out <= 0;
        ignore_control_signal <= 0;
    end
    
    always @ (negedge reset_n, posedge clk) begin
        if (!reset_n | stall | bubble) begin
            pc_out <= 0;
            read_data1_out <= 0;
            read_data2_out <= 0;
            sign_extend_imm_out <= 0;
            rt_out <= 0;
            rd_out <= 0;
            control_signal_out <= 0;
            if (bubble) begin
                ignore_control_signal <= 1;
            end
            else begin
                ignore_control_signal <= 0;
            end
        end
        else if (ignore_control_signal) begin
            pc_out <= 0;
            read_data1_out <= 0;
            read_data2_out <= 0;
            sign_extend_imm_out <= 0;
            rt_out <= 0;
            rd_out <= 0;
            control_signal_out <= 0;
            ignore_control_signal <= 0;
        end
        else begin
            pc_out <= pc_in;
            read_data1_out <= read_data1_in;
            read_data2_out <= read_data2_in;
            sign_extend_imm_out <= sign_extend_imm_in;
            rt_out <= rt_in;
            rd_out <= rd_in;
            control_signal_out <= control_signal_in;
        end
    end
    
endmodule
