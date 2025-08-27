// Stage Definition
`define IF  3'd0
`define ID  3'd1
`define EX  3'd2
`define MEM 3'd3
`define WB  3'd4

// Register Destination parameter
`define REG_RS  2'd1    // $rs
`define REG_RT  2'd0    // $rt  (default)
`define REG_RD  2'd2    // $rd  (R-type)
`define REG_RET 2'd3    // $2   (for return)

// ALU Source B parameter
`define ALU_REG 2'd0    // read data2 from RF
`define ALU_IMM 2'd1    // immediate

// PC Source parameter
`define PC_INT     2'd0 // ALU result
`define PC_JUMP    2'd1 // ALU out
`define PC_BRANCH  2'd2 // jump address
`define PC_RS      2'd3 // $rs