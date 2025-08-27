`include "opcodes.v"

module arithmetic_logic_unit(
    input [15:0] input1,
    input [15:0] input2,
    input Cin,
    input [3:0] OP,
    output reg [15:0] result,
    output reg Cout
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
            `ALU_ID: begin
                result = input1;
            end
            `ALU_EQ: begin
                result = input1 == input2;
            end
            `ALU_NE: begin
                result = input1 != input2;
            end
            `ALU_GZ: begin
                result = (input1[15] == 0 && input1 != 0);
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
            `ALU_TCP: begin
                result = ~input1 + 1;
            end
            `ALU_ARS: begin
                result = input1 >> 1;
                result[15] = input1[15];
            end
            `ALU_LHI: begin
                result = { input2[7:0], 8'b0 };
            end
            `ALU_LZ: begin
                result = input1[15] == 1;
            end
            `ALU_ALS: begin
                result = input1 <<< 1;
            end
            `ALU_ORI: begin
                result = input1 | { 8'b0, input2[7:0] };
            end
        endcase
    end
    
endmodule
