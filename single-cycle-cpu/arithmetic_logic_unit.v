`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/13 04:15:54
// Design Name: 
// Module Name: arithmetic_logic_unit
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

`include "opcodes.v"

module arithmetic_logic_unit(
    input [15:0] input1,
    input [15:0] input2,
    input Cin,
    input [3:0] OP,
    output reg [15:0] result,
    output reg Cout
    // output reg bcond     // Not used yet.
    );
    
    reg [16:0] temp;
    
    always @ (*) begin
        result = 0;
        Cout = 0;
        case (OP)
            `ALU_ADD: begin
                temp = input1 + input2 + Cin;
                result = temp[15:0];
                Cout = temp[16];
            end
            `ALU_SUB: begin
                temp = input1 - (input2 + Cin);
                result = temp[15:0];
                Cout = temp[16];
            end
            `ALU_LHI: begin
                result = { input2[7:0], input1[7:0] };
            end
            /*  rarely used code
            `ALU_ID: begin
                result = input1;
            end
            */
            `ALU_NAND: begin
                result = ~(input1 & input2);
            end
            `ALU_NOR: begin
                result = ~(input1 | input2);
            end
            `ALU_XNOR: begin
                result = ~(input1 ^ input2);
            end
            `ALU_NOT: begin
                result = ~input1;
            end
            `ALU_AND: begin
                result = input1 & input2;
            end
            `ALU_OR: begin
                result = input1 | input2;
            end
            `ALU_XOR: begin
                result = input1 ^ input2;
            end
            `ALU_LRS: begin
                result = input1 >> 1;
            end
            `ALU_ARS: begin
                result = input1 >> 1;
                result[15] = input1[15];
            end
            `ALU_RR: begin
                result = input1 >> 1;
                result[15] = input1[0];
            end
            `ALU_LLS: begin
                result = input1 << 1;
            end
            `ALU_ALS: begin
                result = input1 <<< 1;
            end
            `ALU_RL: begin
                result = input1 << 1;
                result[0] = input1[15];
            end
        endcase
    end
    
endmodule
