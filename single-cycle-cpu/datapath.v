`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/12 18:05:38
// Design Name: 
// Module Name: datapath
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

module datapath #(
    parameter WORD_SIZE = 16
)(
    input clk,
    input reset_n,
    input inputReady,
    input [WORD_SIZE-1:0] data,
    output reg readM,
    output [WORD_SIZE-1:0] address,
    output reg [WORD_SIZE-1:0] num_inst,
    output reg [WORD_SIZE-1:0] output_port,
        
    input RegDst,
    input RegWrite,
    input ALUSrc,
    input [3:0] ALUOp,    
    input Jump,
    input isWWD,
        
    output [3:0] opcode,
    output [5:0] func_code
    );
   
    // Instruction decode
    reg [WORD_SIZE-1:0] instruction;
    assign opcode = instruction[15:12];
    assign func_code = instruction[5:0];
    
    // Import modules
    wire [WORD_SIZE-1:0] nextAddr;
    program_counter PC (
        .clk(clk),
        .reset_n(reset_n),
    
        .jump(Jump),
        .targetAddr(instruction[11:0]),
        .nextAddr(nextAddr)
    );
    assign address = nextAddr;      // Branch doesn't exist yet.
    
    wire [1:0] writeRegister;
    wire [WORD_SIZE-1:0] readData1;
    wire [WORD_SIZE-1:0] readData2;
    assign writeRegister = RegDst ? instruction[7:6] : instruction[9:8];    // RegDst MUX
    wire [WORD_SIZE-1:0] writeData;
    register_file RF (
        .write(RegWrite),
        .clk(clk),
        .reset_n(reset_n),
        
        .readAddr1(instruction[11:10]),
        .readAddr2(instruction[9:8]),
    
        .writeAddr(writeRegister),
        .writeData(writeData),
    
        .readData1(readData1),
        .readData2(readData2)
    );
    
    // ALU Module
    wire [WORD_SIZE-1:0] aluResult;
    wire [WORD_SIZE-1:0] aluInput2;
    assign aluInput2 = ALUSrc ? { {8{instruction[7]}}, instruction[7:0] } : readData2;     // ALUSrc MUX
    assign writeData = aluResult;
    arithmetic_logic_unit ALU (
        .input1(readData1),
        .input2(aluInput2),
        .Cin(1'b0),
        .OP(ALUOp),
        .result(aluResult)
    );
    
    initial begin
        readM <= 0;
        num_inst <= 0;
        output_port <= 0;
        instruction <= 0;
    end
    
    always @ (posedge inputReady) begin
        instruction <= data;
        readM <= 0;
    end
    
    // num_inst 매번 넣은 이유: 유효하지 않은 명령어가 들어올 수도 있어서
    always @ (negedge readM) begin
        case (opcode)
            `OPCODE_RTYPE: begin
                case (func_code)
                    `FUNC_ADD: begin
                        num_inst <= num_inst + 1;
                    end
                    `FUNC_WWD: begin
                        output_port <= readData1;
                        num_inst <= num_inst + 1;
                    end
                endcase
            end
            `OPCODE_ADI: begin
                num_inst <= num_inst + 1;
            end
            `OPCODE_LHI: begin
                // $display("writeAddr:",writeRegister," write:",{ instruction[7:0], readData2[7:0] }," rt:",instruction[9:8]); // debug
                num_inst <= num_inst + 1;
            end
            `OPCODE_JMP: begin
                num_inst <= num_inst + 1;
            end
        endcase
    end
    
    always @ (negedge reset_n, posedge clk) begin
        if (!reset_n) begin
            readM <= 0;
            num_inst <= 0;
            output_port <= 0;
            instruction <= 0;
        end
        else begin
            readM <= 1;
        end
    end
    
endmodule
