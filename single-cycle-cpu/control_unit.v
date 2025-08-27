`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/12 18:05:04
// Design Name: 
// Module Name: control_unit
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

module control_unit(
    input reset_n,
    input [3:0] opcode,
    input [5:0] func_code,
    
    output reg RegDst,
    output reg Jump,
    output reg [3:0] ALUOperation,
    output reg ALUSrc,
    output reg RegWrite,
    output reg isWWD
    );
    
    initial begin
        RegDst <= 1'b0;
        Jump <= 1'b0;
        ALUSrc <= 1'b0;
        RegWrite <= 1'b0;
        isWWD <= 1'b0;
    end
    
    always @ (negedge reset_n) begin
        RegDst <= 1'b0;
        Jump <= 1'b0;
        ALUSrc <= 1'b0;
        RegWrite <= 1'b0;
        isWWD <= 1'b0;
    end
    
    always @ (*) begin
        RegDst <= 1'b0;
        Jump <= 1'b0;
        ALUSrc <= 1'b0;
        RegWrite <= 1'b0;
        isWWD <= 1'b0;
        case (opcode)
            `OPCODE_RTYPE: begin
                RegDst <= 1'b1;
                case (func_code)
                    `FUNC_ADD: begin
                        ALUOperation <= `ALU_ADD;
                        RegWrite <= 1'b1;
                    end
                    `FUNC_WWD: begin
                        isWWD <= 1'b1;
                    end
                endcase
            end
            `OPCODE_ADI: begin
                ALUSrc <= 1'b1;
                ALUOperation <= `ALU_ADD;
                RegWrite <= 1'b1;
            end
            `OPCODE_LHI: begin
                ALUSrc <= 1'b1;
                ALUOperation <= `ALU_LHI;
                RegWrite <= 1'b1;
            end
            `OPCODE_JMP: begin
                Jump <= 1'b1;
            end
        endcase
    end
    
endmodule
