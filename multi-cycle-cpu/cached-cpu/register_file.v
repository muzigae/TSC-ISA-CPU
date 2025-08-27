`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/24 17:41:17
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
    
    input [1:0] read_addr1,                 // Read register 1
    input [1:0] read_addr2,                 // Read register 2
    input [1:0] jump_addr_forwarding_in,    // for JPR, JRL
    
    input [1:0] write_addr,                 // Write register
    input [15:0] write_data,                // Write data
    
    output [15:0] read_data1,               // Read data 1
    output [15:0] read_data2,               // Read data 2
    output [15:0] jump_addr_forwarding_out, // for JPR, JRL
    output reg [15:0] wb_forwarding        // for wb forwarding
    );
    
    reg [15:0] memory [3:0];
    
    assign read_data1 = memory[read_addr1];
    assign read_data2 = memory[read_addr2];
    assign jump_addr_forwarding_out = memory[jump_addr_forwarding_in];
    
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
                memory[write_addr] <= write_data;
                wb_forwarding      <= write_data;
                //$display("write addr:",write_addr," data:",write_data);
            end
        end
    end
    
endmodule
