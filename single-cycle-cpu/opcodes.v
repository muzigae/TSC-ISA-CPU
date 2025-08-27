`define FUNC_ADD 6'd0
`define FUNC_SUB 6'd1
`define FUNC_AND 6'd2
`define FUNC_ORR 6'd3
`define FUNC_NOT 6'd4
`define FUNC_TCP 6'd5
`define FUNC_SHL 6'd6
`define FUNC_SHR 6'd7
`define FUNC_RWD 6'd27      // custom RWD code
`define FUNC_WWD 6'd28      // custom WWD code

`define OPCODE_RTYPE 4'd15  // custom R-format instruction code
`define OPCODE_ADI 4'd4
`define OPCODE_ORI 4'd5
`define OPCODE_LHI 4'd6
`define OPCODE_LWD 4'd7
`define OPCODE_SWD 4'd8
`define OPCODE_BNE 4'd0
`define OPCODE_BEQ 4'd1
`define OPCODE_BGZ 4'd2
`define OPCODE_BLZ 4'd3
`define OPCODE_JMP 4'd9
`define OPCODE_JAL 4'd10

// ALU OPCODE
// Arithmetic
`define	ALU_ADD	    4'b0000
`define	ALU_SUB	    4'b0001
// Bitwise Boolean operation
`define ALU_LHI     4'B0011 // custom LHI code
//`define	ALU_ID	    4'b0010    // rarely used code
`define	ALU_NAND	4'b0011
`define	ALU_NOR	    4'b0100
`define	ALU_XNOR	4'b0101
`define	ALU_NOT	    4'b0110
`define	ALU_AND	    4'b0111
`define	ALU_OR	    4'b1000
`define	ALU_XOR	    4'b1001
// Shifting
`define	ALU_LRS	    4'b1010
`define	ALU_ARS	    4'b1011
`define	ALU_RR	    4'b1100
`define	ALU_LLS	    4'b1101
`define	ALU_ALS	    4'b1110
`define	ALU_RL	    4'b1111