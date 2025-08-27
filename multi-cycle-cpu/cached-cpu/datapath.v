`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/24 17:38:23
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
`include "mux_selectors.v"
`include "control_selectors.v"
`include "constants.v"

module datapath #(
    parameter WORD_SIZE = 16
)(
    input clk,
    input reset_n,
    
    output reg i_readM, 
    output reg i_writeM, 
    output [`WORD_SIZE-1:0] i_address, 
    inout  [`WORD_SIZE-1:0] i_data,
    input  i_readyM,

    output reg d_readM, 
    output reg d_writeM, 
    output [`WORD_SIZE-1:0] d_address, 
    inout  [`WORD_SIZE-1:0] d_data,
    input  d_readyM,
        
    output reg [`WORD_SIZE-1:0] num_inst, 
    output reg [WORD_SIZE-1:0] output_port,
    output reg is_halted,

    input  [`SIG_SIZE-1:0] control_signal,
        
    output [3:0] opcode,
    output [5:0] func_code
    );
    
    // Declare registers & wires
    reg [15:0]  next_num_inst;
    
    // Hazard
    wire [5:0]  hazard_signal_if;   // hazard type for data forwarding in IF stage
    wire [5:0]  hazard_signal_id;   // hazard type for data forwarding in ID stage
    reg  [5:0]  hazard_signal_ex;   // hazard type for data forwarding in EX stage
    wire        stall;              // hazard stall
    wire        stall_pc;           // stall for calculating PC
    wire        bubble;
    wire [15:0] pc_recovered;
    
    wire        is_jump_rs;
    wire [15:0] reg_dst_id_ex;
    wire        ex_load;
    
    // Forwarding path
    wire [1:0]  jump_addr_forwarding_in;
    wire [15:0] jump_addr_forwarding_out;
    
    wire [15:0] wb_forwarding;
    
    // IF Stage
    wire [15:0] pc_cand;
    wire [15:0] pc_out;
    wire [15:0] pc_plus_one;
    
    wire [15:0] jump_predicted;
    wire        jump;
    wire [15:0] jump_target;
    
    // ID Stage
    wire [15:0] pc_if_id_in;
    wire [15:0] pc_if_id_out;
    
    wire [15:0] instruction_if_id_in;
    wire [15:0] instruction_if_id_out;
    
    wire [1:0]  rs;
    wire [1:0]  rt;
    wire [1:0]  rd;
    wire [7:0]  immediate;
    
    wire [15:0] read_data1;
    wire [15:0] read_data2;
    wire [1:0]  write_addr;
    wire [15:0] write_data;
    
    // EX Stage
    wire [15:0] pc_id_ex_in;
    wire [15:0] pc_id_ex_out;
    wire [`SIG_SIZE-1:0] control_signal_id_ex_in;
    wire [`SIG_SIZE-1:0] control_signal_id_ex_out;
    
    wire [15:0] read_data1_id_ex_in;
    wire [15:0] read_data1_id_ex_out;
    wire [15:0] read_data2_id_ex_in;
    wire [15:0] read_data2_id_ex_out;
    
    wire [15:0] sign_extend_imm_id_ex_in;
    wire [15:0] sign_extend_imm_id_ex_out;
    
    wire [1:0]  rt_id_ex_in;
    wire [1:0]  rt_id_ex_out;
    wire [1:0]  rd_id_ex_in;
    wire [1:0]  rd_id_ex_out;
    
    wire [15:0] alu_input1;
    wire [15:0] alu_input2;
    wire [15:0] alu_result;
    
    wire [15:0] write_data_ex;      // data forwarding
    
    // MEM Stage
    wire [15:0] pc_ex_mem_in;
    wire [15:0] pc_ex_mem_out;
    wire [`SIG_SIZE-1:0] control_signal_ex_mem_in;
    wire [`SIG_SIZE-1:0] control_signal_ex_mem_out;
    
    wire        branch_cond_ex_mem_in;
    wire        branch_cond_ex_mem_out;
    wire [15:0] alu_result_ex_mem_in;
    wire [15:0] alu_result_ex_mem_out;
    wire [15:0] read_data2_ex_mem_in;
    wire [15:0] read_data2_ex_mem_out;
    wire [15:0] reg_dst_ex_mem_in;
    wire [15:0] reg_dst_ex_mem_out;
    
    wire [15:0] write_data_mem;     // data forwarding
    reg  [15:0] d_address_reg;      // Store data during memory latency
    reg  [15:0] d_data_reg;         // Store data during memory latency
    reg  d_valid;
    
    // WB Stage
    wire [15:0] pc_mem_wb_in;
    wire [15:0] pc_mem_wb_out;
    wire [`SIG_SIZE-1:0] control_signal_mem_wb_in;
    wire [`SIG_SIZE-1:0] control_signal_mem_wb_out;
    
    wire [15:0] mem_data_mem_wb_in;
    wire [15:0] mem_data_mem_wb_out;
    wire [15:0] alu_resullt_mem_wb_in;
    wire [15:0] alu_resullt_mem_wb_out;
    wire [15:0] reg_dst_mem_wb_in;
    wire [15:0] reg_dst_mem_wb_out;
    
    // Import modules
    assign is_jump_rs = instruction_if_id_in[15:12] == `OPCODE_RTYPE && 
                        (instruction_if_id_in[5:0] == `FUNC_JPR || instruction_if_id_in[5:0] == `FUNC_JRL);
    assign reg_dst_id_ex = 
        (control_signal_id_ex_in[`SIG_REG_DST] == `REG_RT) ? rt :
        (control_signal_id_ex_in[`SIG_REG_DST] == `REG_RD) ? rd : 2'd2;   // Register Destination MUX
    assign ex_load = control_signal_id_ex_out[`SIG_MEM_TO_REG];
    hazard_detector HD (
        .rs_if(instruction_if_id_in[11:10]),
        .is_jump_rs(is_jump_rs),
    
        .rs_id(rs),
        .rt_id(rt_id_ex_in),
        .use_rs(control_signal_id_ex_in[`SIG_USE_RS]),
        .use_rt(control_signal_id_ex_in[`SIG_USE_RT]),
    
        .dest_id(reg_dst_id_ex),
        .dest_ex(reg_dst_ex_mem_in),
        .dest_mem(reg_dst_ex_mem_out),
        .dest_wb(reg_dst_mem_wb_out),
        
        .reg_write_id(control_signal_id_ex_in[`SIG_REG_WRITE]),
        .reg_write_ex(control_signal_id_ex_out[`SIG_REG_WRITE]), 
        .reg_write_mem(control_signal_ex_mem_out[`SIG_REG_WRITE]),
        .reg_write_wb(control_signal_mem_wb_out[`SIG_REG_WRITE]),
        
        .ex_load(ex_load),
    
        .hazard_signal_if(hazard_signal_if),
        .hazard_signal_id(hazard_signal_id),
        .stall_pc(stall_pc),
        .stall(stall)
    );
    
    arithmetic_logic_unit ALU_BRANCH (
        .input1(pc_plus_one),
        .input2({ { 8{instruction_if_id_in[7]}}, instruction_if_id_in[7:0] }),
        .Cin(0),
        .OP(`ALU_ADD),
        .result(jump_predicted)
    );
    
    //assign jump_addr_forwarding_in = pc_hazard ? rs : instruction_if_id_in[11:10];   // stall for calculating PC or fetch PC from register early
    assign jump_addr_forwarding_in = instruction_if_id_in[11:10];
    assign jump = (instruction_if_id_in[15:12] == `OPCODE_RTYPE && 
                  (instruction_if_id_in[5:0] == `FUNC_JPR || instruction_if_id_in[5:0] == `FUNC_JRL))
                  || instruction_if_id_in[15:12] == `OPCODE_JMP
                  || instruction_if_id_in[15:12] == `OPCODE_JAL
                  || instruction_if_id_in[15:12] == `OPCODE_BNE
                  || instruction_if_id_in[15:12] == `OPCODE_BEQ
                  || instruction_if_id_in[15:12] == `OPCODE_BGZ
                  || instruction_if_id_in[15:12] == `OPCODE_BLZ;
    assign jump_target = 
           (instruction_if_id_in[15:12] == `OPCODE_RTYPE && 
           (instruction_if_id_in[5:0] == `FUNC_JPR || instruction_if_id_in[5:0] == `FUNC_JRL)) ? 
               hazard_signal_if[`HAZARD_EX_RS]  ? write_data_ex          :
               hazard_signal_if[`HAZARD_MEM_RS] ? write_data_mem         :
               hazard_signal_if[`HAZARD_WB_RS]  ? write_data             : jump_addr_forwarding_out :
           (instruction_if_id_in[15:12] == `OPCODE_JMP || instruction_if_id_in[15:12] == `OPCODE_JAL) ? { pc_plus_one[15:12], instruction_if_id_in[11:0] }
           : jump_predicted;

    program_counter PC (
        .clk(clk),
        .reset_n(reset_n),
        .stall(stall),
        .stall_pc(stall_pc | !i_readyM),
        .stall_mem(d_readM | d_writeM),
        .bubble(bubble),
        
        .pc_recovered(pc_recovered),
        
        .jump(jump),
        .jump_target(jump_target),
        
        .pc_out(pc_out),
        .pc_plus_one(pc_plus_one)
    );
    assign i_address = pc_out;
    
    assign pc_if_id_in = pc_plus_one;
    assign instruction_if_id_in = i_data;
    pipeline_register_if_id PR_IF_ID (
        .clk(clk),
        .reset_n(reset_n),
        .stall(stall),
        .stall_pc(stall_pc | (i_readM & !i_readyM)),
        .stall_mem(d_readM | d_writeM),
        .bubble(bubble),
    
        .pc_in(pc_if_id_in),
        .instruction_in(instruction_if_id_in),
    
        .pc_out(pc_if_id_out),
        .instruction_out(instruction_if_id_out)
    );
    
    assign opcode    = instruction_if_id_out[15:12];
    assign rs        = instruction_if_id_out[11:10];
    assign rt        = instruction_if_id_out[9:8];
    assign rd        = instruction_if_id_out[7:6];
    assign func_code = instruction_if_id_out[5:0];
    assign immediate = instruction_if_id_out[7:0];
    register_file RF (
        .write(control_signal_mem_wb_out[`SIG_REG_WRITE]),
        .clk(clk),
        .reset_n(reset_n),
        
        .read_addr1(rs),
        .read_addr2(rt),
        .jump_addr_forwarding_in(jump_addr_forwarding_in),
    
        .write_addr(write_addr),
        .write_data(write_data),
    
        .read_data1(read_data1),
        .read_data2(read_data2),
        .jump_addr_forwarding_out(jump_addr_forwarding_out),
        .wb_forwarding(wb_forwarding)
    );
    
    assign pc_id_ex_in = pc_if_id_out;
    assign control_signal_id_ex_in = control_signal;
    assign read_data1_id_ex_in = read_data1;
    assign read_data2_id_ex_in = read_data2;
    assign sign_extend_imm_id_ex_in = { { 8{immediate[7]}}, immediate };
    assign rt_id_ex_in = rt;
    assign rd_id_ex_in = rd;
    pipeline_register_id_ex PR_ID_EX (
        .clk(clk),
        .reset_n(reset_n),
        .stall(stall),
        .stall_mem(d_readM | d_writeM),
        .bubble(bubble),
        
        .pc_in(pc_id_ex_in),
        
        .read_data1_in(read_data1_id_ex_in),
        .read_data2_in(read_data2_id_ex_in),
        
        .sign_extend_imm_in(sign_extend_imm_id_ex_in),
        
        .rt_in(rt_id_ex_in),
        .rd_in(rd_id_ex_in),
        
        .control_signal_in(control_signal_id_ex_in),
        
        .pc_out(pc_id_ex_out),
        
        .read_data1_out(read_data1_id_ex_out),
        .read_data2_out(read_data2_id_ex_out),
        
        .sign_extend_imm_out(sign_extend_imm_id_ex_out),
        
        .rt_out(rt_id_ex_out),
        .rd_out(rd_id_ex_out),
        
        .control_signal_out(control_signal_id_ex_out)
    );
    
    // Data forwarding for alu input
    assign alu_input1 = hazard_signal_ex[`HAZARD_EX_RS]  ? write_data_mem         :
                        hazard_signal_ex[`HAZARD_MEM_RS] ? write_data             :
                        hazard_signal_ex[`HAZARD_WB_RS]  ? wb_forwarding          :
                        read_data1_id_ex_out;
    assign alu_input2 = (control_signal_id_ex_out[`SIG_ALU_SRC] == `ALU_IMM) ? sign_extend_imm_id_ex_out :
                        hazard_signal_ex[`HAZARD_EX_RT]  ? write_data_mem         :
                        hazard_signal_ex[`HAZARD_MEM_RT] ? write_data             :
                        hazard_signal_ex[`HAZARD_WB_RT]  ? wb_forwarding          :
                        read_data2_id_ex_out;
    assign read_data2_ex_mem_in = 
                        hazard_signal_ex[`HAZARD_EX_RT]  ? write_data_mem         :
                        hazard_signal_ex[`HAZARD_MEM_RT] ? write_data             :
                        hazard_signal_ex[`HAZARD_WB_RT]  ? wb_forwarding          :
                        read_data2_id_ex_out;
    
    arithmetic_logic_unit ALU (
        .input1(alu_input1),
        .input2(alu_input2),
        .Cin(0),
        .OP(control_signal_id_ex_out[`SIG_ALU_OP]),
        .result(alu_result)
    );
    assign write_data_ex =
            control_signal_id_ex_out[`SIG_REG_DST] == `REG_RET ? pc_id_ex_out :
            alu_result_ex_mem_in;
    
    assign pc_ex_mem_in = pc_id_ex_out;
    assign control_signal_ex_mem_in = control_signal_id_ex_out;
    assign branch_cond_ex_mem_in = alu_result;                      // ALU also operates EQ, GZ, ...
    assign alu_result_ex_mem_in = alu_result;
    assign reg_dst_ex_mem_in = 
            (control_signal_id_ex_out[`SIG_REG_DST] == `REG_RT) ? rt_id_ex_out :
            (control_signal_id_ex_out[`SIG_REG_DST] == `REG_RD) ? rd_id_ex_out : 2'd2;   // Register Destination MUX
    pipeline_register_ex_mem PR_EX_MEM (
        .clk(clk),
        .reset_n(reset_n),
        .stall_mem(d_readM | d_writeM),
        .bubble(bubble),
        
        .pc_in(pc_ex_mem_in),
        
        .branch_cond_in(branch_cond_ex_mem_in),
        .alu_result_in(alu_result_ex_mem_in),
        
        .read_data2_in(read_data2_ex_mem_in),
        
        .reg_dst_in(reg_dst_ex_mem_in),
        
        .control_signal_in(control_signal_ex_mem_in),
        
        .pc_out(pc_ex_mem_out),
        
        .branch_cond_out(branch_cond_ex_mem_out),
        .alu_result_out(alu_result_ex_mem_out),
        
        .read_data2_out(read_data2_ex_mem_out),
        
        .reg_dst_out(reg_dst_ex_mem_out),
        
        .control_signal_out(control_signal_ex_mem_out)
    );
    assign bubble = (control_signal_ex_mem_out[`SIG_PC_SRC] == `PC_BRANCH) && !branch_cond_ex_mem_out;       // branch taken but failed
    assign pc_recovered = pc_ex_mem_out;
    assign write_data_mem =
            control_signal_ex_mem_out[`SIG_MEM_TO_REG] ? mem_data_mem_wb_in : 
            control_signal_ex_mem_out[`SIG_REG_DST] == `REG_RET ? pc_ex_mem_out :
            alu_result_ex_mem_out;
    
    // Access data memory
    assign d_address = alu_result_ex_mem_out;
    assign d_data = control_signal_ex_mem_out[`SIG_MEM_WRITE] ? read_data2_ex_mem_out : `WORD_SIZE'bz;
    //assign d_address = d_address_reg;
    //assign d_data = d_valid ? d_data_reg : `WORD_SIZE'bz;
    
    assign pc_mem_wb_in = pc_ex_mem_out;
    assign control_signal_mem_wb_in = control_signal_ex_mem_out;
    assign mem_data_mem_wb_in = d_data;
    assign alu_resullt_mem_wb_in = alu_result_ex_mem_out;
    assign reg_dst_mem_wb_in = reg_dst_ex_mem_out;
    pipeline_register_mem_wb PR_MEM_WB (
        .clk(clk),
        .reset_n(reset_n),
        .stall_mem(d_readM | d_writeM),
        
        .pc_in(pc_mem_wb_in),
        
        .mem_data_in(mem_data_mem_wb_in),
        .alu_result_in(alu_resullt_mem_wb_in),
        
        .reg_dst_in(reg_dst_mem_wb_in),
        
        .control_signal_in(control_signal_mem_wb_in),
        
        .pc_out(pc_mem_wb_out),
        
        .mem_data_out(mem_data_mem_wb_out),
        .alu_result_out(alu_resullt_mem_wb_out),
        
        .reg_dst_out(reg_dst_mem_wb_out),
        
        .control_signal_out(control_signal_mem_wb_out)
    );
    assign write_addr = 
            control_signal_mem_wb_out[`SIG_REG_DST] == `REG_RET ? 2'd2 : reg_dst_mem_wb_out;
    assign write_data = 
            control_signal_mem_wb_out[`SIG_MEM_TO_REG] ? mem_data_mem_wb_out : 
            control_signal_mem_wb_out[`SIG_REG_DST] == `REG_RET ? pc_mem_wb_out :
            alu_resullt_mem_wb_out;

    initial begin
        i_readM <= 0;
        i_writeM <= 0;
        d_readM <= 0;
        d_writeM <= 0;
        d_address_reg <= 0;
        d_data_reg <= 0;
        d_valid <= 0;
        num_inst <= 0;
        next_num_inst <= 0;
        output_port <= 0;
        hazard_signal_ex <= 0;
        is_halted <= 0;
    end
    
    always @ (negedge reset_n, posedge clk) begin
        if (!reset_n) begin
            i_readM <= 0;
            i_writeM <= 0;
            d_readM <= 0;
            d_writeM <= 0;
            d_address_reg <= 0;
            d_data_reg <= 0;
            d_valid <= 0;
            num_inst <= 0;
            next_num_inst <= 0;
            output_port <= 0;
            hazard_signal_ex <= 0;
            is_halted <= 0;
        end
        else begin
            //i_readM <= 1;
            num_inst <= next_num_inst;
            hazard_signal_ex <= hazard_signal_id;
            
            // Access instruction memory
            if (stall_pc | stall | d_readM | d_writeM) i_readM <= 1;
            else if (i_readM) begin
                if (i_readyM) i_readM <= 0;
            end
            else i_readM <= 1;
            
            // Access data memory
            if (control_signal_ex_mem_in[`SIG_MEM_READ]) begin
                d_readM <= 1;
            end
            else if (d_readM) begin
                /*
                d_readM <= 0;
                d_address_reg <= alu_result_ex_mem_out;
                d_data_reg <= read_data2_ex_mem_out;*/
                if (d_readyM) d_readM <= 0;
            end
            if (control_signal_ex_mem_in[`SIG_MEM_WRITE]) begin
                d_writeM <= 1;
            end
            else if (d_writeM) begin
                /*
                d_writeM <= 0;
                d_address_reg <= alu_result_ex_mem_out;
                d_data_reg <= read_data2_ex_mem_out;*/
                if (d_readyM) begin
                    d_writeM <= 0;
                    d_valid <= 1;
                end
            end
            else d_valid <= 0;
            
            // Special signal
            if (control_signal_mem_wb_out[`SIG_WWD]) begin
                output_port <= write_data;
            end
            if (control_signal_mem_wb_out[`SIG_HLT]) begin
                is_halted <= 1;
            end
        end
    end
    
    always @ (*) begin
        next_num_inst = num_inst;
        if (control_signal_mem_wb_out) begin
            next_num_inst = next_num_inst + 1;
        end
    end
    
endmodule
