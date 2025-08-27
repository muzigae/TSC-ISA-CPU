// IF Stage
`define SIG_PC_SRC      1:0     // 4-MUX: PC + 1 | (J-type) Jump address | branch address | $rs (JPR or JRL)

// ID Stage
`define SIG_WWD         2       // special R-type instruction
`define SIG_HLT         3
`define SIG_REG_WRITE   4       // store in RF (WB)

// EX Stage
`define SIG_REG_DST     6:5     // 4-MUX: $rs (JRL) | $rt | $rd | $2 (JAL, JRL)

`define SIG_ALU_SRC     7       // 2-MUX: readData2 | (I-type) sign-extend immediate

`define SIG_ALU_OP      11:8    // ALU opcode

// MEM Stage
`define SIG_MEM_READ    12      // for LW
`define SIG_MEM_WRITE   13      // for SW

// WB Stage
`define SIG_MEM_TO_REG  14      // for LW
`define SIG_USE_RS      15
`define SIG_USE_RT      16

// Hazard signal
`define HAZARD_EX_RS    0
`define HAZARD_MEM_RS   1
`define HAZARD_WB_RS    2
`define HAZARD_EX_RT    3
`define HAZARD_MEM_RT   4
`define HAZARD_WB_RT    5