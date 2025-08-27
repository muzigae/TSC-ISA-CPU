`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/24 17:39:16
// Design Name: 
// Module Name: program_counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module program_counter(
        input clk,
        input reset_n,
        input stall,
        input stall_pc,
        input bubble,
        input [15:0] pc_recovered,
        
        input jump,
        input [15:0] jump_target,
        
        output reg [15:0] pc_out,
        output [15:0] pc_plus_one
    );
    
    reg [15:0] next_pc;
    
    assign pc_plus_one = pc_out + 1;
    
    initial begin
        pc_out <= -1;
    end
    
    always @ (negedge reset_n, posedge clk) begin
        if (!reset_n) begin
            pc_out <= -1;
        end
        else if (bubble) begin
            pc_out <= pc_recovered;
        end
        else if (!stall_pc && !stall) begin
            if (jump) begin
                pc_out <= jump_target;
            end
            else begin
                pc_out <= pc_plus_one;
            end
        end
    end
    
endmodule
