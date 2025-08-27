`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/13 04:29:54
// Design Name: 
// Module Name: register_file
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


module register_file(
    input write,
    input clk,
    input reset_n,
    
    input [1:0] readAddr1,      // Read register 1
    input [1:0] readAddr2,      // Read register 2
    
    input [1:0] writeAddr,      // Write register
    input [15:0] writeData,     // Write data
    
    output [15:0] readData1,    // Read data 1
    output [15:0] readData2     // Read data 2
    );
    
    reg [15:0] memory [3:0];
    
    assign readData1 = memory[readAddr1];
    assign readData2 = memory[readAddr2];
    
    initial begin
        memory[0] <= 16'h0000;
        memory[1] <= 16'h0000;
        memory[2] <= 16'h0000;
        memory[3] <= 16'h0000;
    end
    
    always @ (negedge reset_n, posedge clk) begin
        if (!reset_n) begin
            memory[0] <= 16'h0000;
            memory[1] <= 16'h0000;
            memory[2] <= 16'h0000;
            memory[3] <= 16'h0000;
        end
        else begin
            if (write) begin
                // $display("writeAddr:",writeAddr," writeData:",writeData);    // debug
                memory[writeAddr] <= writeData;
            end
        end
    end
    
endmodule
