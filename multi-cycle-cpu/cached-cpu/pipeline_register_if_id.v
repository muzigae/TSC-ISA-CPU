`timescale 1ns / 1ps

`include "opcodes.v"
`include "mux_selectors.v"
`include "control_selectors.v"
`include "constants.v"

module pipeline_register_if_id(
    input clk,
    input reset_n,
    input stall,
    input stall_pc,
    input stall_mem,
    input bubble,
    
    input [15:0] pc_in,
    input [15:0] instruction_in,
    
    output reg [15:0] pc_out,
    output reg [15:0] instruction_out
    );
    
    initial begin
        pc_out <= 0;
        instruction_out <= `INVALID_INSTRUCTION;
    end
    
    always @ (negedge reset_n, posedge clk) begin
        if (!reset_n | stall_pc | bubble) begin
            pc_out <= 0;
            instruction_out <= `INVALID_INSTRUCTION;
        end
        else if (!stall & !stall_mem) begin
            pc_out <= pc_in;
            instruction_out <= instruction_in;
            /*
            if (i_readM) begin
                pc_out <= 0;
                instruction_out <= `INVALID_INSTRUCTION;
            end
            else begin
                pc_out <= pc_in;
                instruction_out <= instruction_in;
            end*/
        end
    end
    
endmodule
