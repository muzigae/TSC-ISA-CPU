`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/13 16:22:07
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
        
        input jump,
        input [11:0] targetAddr,
        output [15:0] nextAddr
    );
    
    reg [15:0] PC;
    wire [15:0] nextPC;
    reg isRunning;      // ���α׷� ������ ���۵Ǿ����� Ȯ��: nextPC�� ó�� ����ȭ�� �� �ʱⰪ 0�� �Ѱ��ֱ� ����
    assign nextPC = isRunning ? (jump ? { PC[15:12], targetAddr } : PC + 1) : 0;
    assign nextAddr = PC;
    
    initial begin
        PC <= 0;
        isRunning <= 0;
    end
    
    always @ (negedge reset_n, posedge clk) begin
        if (!reset_n) begin
            PC <= 0;
            isRunning <= 0;
        end
        else begin
            PC <= nextPC;
            isRunning <= 1;
        end
    end
    
endmodule
