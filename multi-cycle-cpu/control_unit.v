`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/24 17:37:09
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
`include "mux_selectors.v"
`include "control_selectors.v"
`include "constants.v"

module control_unit(
    input clk,
    input reset_n,
    
    input [3:0] opcode,
    input [5:0] func_code,
    
    output reg [`SIG_SIZE-1:0] control_signal
    );
    
    reg [`SIG_SIZE-1:0] next_control_signal;

    initial begin
        control_signal <= 0;
    end
    
    always @ (negedge reset_n, posedge clk) begin
        if (!reset_n) begin
            control_signal <= 0;
        end
    end
    
    always @ (*) begin
        control_signal = 0;
        case (opcode)
            `OPCODE_RTYPE: begin
                control_signal[`SIG_REG_DST] = `REG_RD;
                control_signal[`SIG_USE_RS] = 1;
                case (func_code)
                    `FUNC_WWD: begin
                        control_signal[`SIG_WWD] = 1;
                        control_signal[`SIG_ALU_OP] = `ALU_ID;
                    end
                    `FUNC_JPR: begin
                        control_signal[`SIG_PC_SRC] = `PC_RS;
                    end
                    `FUNC_JRL: begin
                        control_signal[`SIG_PC_SRC] = `PC_RS;
                        control_signal[`SIG_REG_WRITE] = 1;
                        control_signal[`SIG_REG_DST] = `REG_RET;
                    end
                    `FUNC_HLT: begin
                        control_signal[`SIG_HLT] = 1;
                        control_signal[`SIG_USE_RS] = 0;
                    end
                    `FUNC_ADD: begin
                        control_signal[`SIG_REG_WRITE] = 1;
                        control_signal[`SIG_ALU_OP] = `ALU_ADD;
                        control_signal[`SIG_USE_RT] = 1;
                    end
                    `FUNC_SUB: begin
                        control_signal[`SIG_REG_WRITE] = 1;
                        control_signal[`SIG_ALU_OP] = `ALU_SUB;
                        control_signal[`SIG_USE_RT] = 1;
                    end
                    `FUNC_AND: begin
                        control_signal[`SIG_REG_WRITE] = 1;
                        control_signal[`SIG_ALU_OP] = `ALU_AND;
                        control_signal[`SIG_USE_RT] = 1;
                    end
                    `FUNC_ORR: begin
                        control_signal[`SIG_REG_WRITE] = 1;
                        control_signal[`SIG_ALU_OP] = `ALU_OR;
                        control_signal[`SIG_USE_RT] = 1;
                    end
                    `FUNC_NOT: begin
                        control_signal[`SIG_REG_WRITE] = 1;
                        control_signal[`SIG_ALU_OP] = `ALU_NOT;
                    end
                    `FUNC_TCP: begin
                        control_signal[`SIG_REG_WRITE] = 1;
                        control_signal[`SIG_ALU_OP] = `ALU_TCP;
                    end
                    `FUNC_SHL: begin
                        control_signal[`SIG_REG_WRITE] = 1;
                        control_signal[`SIG_ALU_OP] = `ALU_ALS;
                    end
                    `FUNC_SHR: begin
                        control_signal[`SIG_REG_WRITE] = 1;
                        control_signal[`SIG_ALU_OP] = `ALU_ARS;
                    end
                endcase
            end
            `OPCODE_ADI: begin
                control_signal[`SIG_REG_WRITE] = 1;
                control_signal[`SIG_ALU_SRC] = `ALU_IMM;
                control_signal[`SIG_ALU_OP] = `ALU_ADD;
                control_signal[`SIG_USE_RS] = 1;
                control_signal[`SIG_USE_RT] = 1;
            end
            `OPCODE_ORI: begin
                control_signal[`SIG_REG_WRITE] = 1;
                control_signal[`SIG_ALU_SRC] = `ALU_IMM;
                control_signal[`SIG_ALU_OP] = `ALU_ORI;
                control_signal[`SIG_USE_RS] = 1;
                control_signal[`SIG_USE_RT] = 1;
            end
            `OPCODE_LHI: begin
                control_signal[`SIG_REG_WRITE] = 1;
                control_signal[`SIG_ALU_SRC] = `ALU_IMM;
                control_signal[`SIG_ALU_OP] = `ALU_LHI;
                control_signal[`SIG_USE_RT] = 1;
            end
            `OPCODE_LWD: begin
                control_signal[`SIG_REG_WRITE] = 1;
                control_signal[`SIG_ALU_SRC] = `ALU_IMM;
                control_signal[`SIG_ALU_OP] = `ALU_ADD;
                control_signal[`SIG_MEM_READ] = 1;
                control_signal[`SIG_MEM_TO_REG] = 1;
                control_signal[`SIG_USE_RS] = 1;
                control_signal[`SIG_USE_RT] = 1;
            end
            `OPCODE_SWD: begin
                control_signal[`SIG_ALU_SRC] = `ALU_IMM;
                control_signal[`SIG_ALU_OP] = `ALU_ADD;
                control_signal[`SIG_MEM_WRITE] = 1;
                control_signal[`SIG_USE_RS] = 1;
                control_signal[`SIG_USE_RT] = 1;
            end
            `OPCODE_BNE: begin
                control_signal[`SIG_PC_SRC] = `PC_BRANCH;
                control_signal[`SIG_ALU_OP] = `ALU_NE;
                control_signal[`SIG_USE_RS] = 1;
                control_signal[`SIG_USE_RT] = 1;
            end
            `OPCODE_BEQ: begin
                control_signal[`SIG_PC_SRC] = `PC_BRANCH;
                control_signal[`SIG_ALU_OP] = `ALU_EQ;
                control_signal[`SIG_USE_RS] = 1;
                control_signal[`SIG_USE_RT] = 1;
            end
            `OPCODE_BGZ: begin
                control_signal[`SIG_PC_SRC] = `PC_BRANCH;
                control_signal[`SIG_ALU_OP] = `ALU_GZ;
                control_signal[`SIG_USE_RS] = 1;
            end
            `OPCODE_BLZ: begin
                control_signal[`SIG_PC_SRC] = `PC_BRANCH;
                control_signal[`SIG_ALU_OP] = `ALU_LZ;
                control_signal[`SIG_USE_RS] = 1;
            end
            `OPCODE_JMP: begin
                control_signal[`SIG_PC_SRC] = `PC_JUMP;
            end
            `OPCODE_JAL: begin
                control_signal[`SIG_PC_SRC] = `PC_JUMP;
                control_signal[`SIG_REG_WRITE] = 1;
                control_signal[`SIG_REG_DST] = `REG_RET;
            end
        endcase
    end
    
endmodule
