`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/24 22:42:50
// Design Name: 
// Module Name: hazard_detector
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

module hazard_detector (
    input [1:0] rs_if,           // rs field from IF stage for JPR, JRL
    input is_jump_rs,            // signal indicating JPR or JRL

    input [1:0] rs_id,           // rs field from ID stage
    input [1:0] rt_id,           // rt field from ID stage
    input use_rs,                // signal indicating rs is used
    input use_rt,                // signal indicating rt is used
    
    input [1:0] dest_id,         // destination register in ID stage
    input [1:0] dest_ex,         // destination register in EX stage
    input [1:0] dest_mem,        // destination register in MEM stage 
    input [1:0] dest_wb,         // destination register in WB stage
    
    input reg_write_id,          // register write enable in ID
    input reg_write_ex,          // register write enable in EX
    input reg_write_mem,         // register write enable in MEM
    input reg_write_wb,          // register write enable in WB
    
    input ex_load,               // EX stage is load
    
    output [5:0] hazard_signal_if,
    output [5:0] hazard_signal_id,
    output stall_pc,                // stall only IF-ID
    output stall                    // stall signal output
);

    // Detect data hazards for rs in IF
    wire rs_ex_hazard_if  = (rs_if == dest_ex)  && is_jump_rs && reg_write_ex;
    wire rs_mem_hazard_if = (rs_if == dest_mem) && is_jump_rs && reg_write_mem;
    wire rs_wb_hazard_if  = (rs_if == dest_wb)  && is_jump_rs && reg_write_wb;

    // Detect data hazards for rs
    wire rs_ex_hazard_id  = (rs_id == dest_ex)  && use_rs && reg_write_ex;
    wire rs_mem_hazard_id = (rs_id == dest_mem) && use_rs && reg_write_mem;
    wire rs_wb_hazard_id  = (rs_id == dest_wb)  && use_rs && reg_write_wb;
    
    // Detect data hazards for rt
    wire rt_ex_hazard_id  = (rt_id == dest_ex)  && use_rt && reg_write_ex;
    wire rt_mem_hazard_id = (rt_id == dest_mem) && use_rt && reg_write_mem;
    wire rt_wb_hazard_id  = (rt_id == dest_wb)  && use_rt && reg_write_wb;
    
    assign hazard_signal_if = { rs_wb_hazard_if, rs_mem_hazard_if, rs_ex_hazard_if };
    assign hazard_signal_id = { rt_wb_hazard_id, rt_mem_hazard_id, rt_ex_hazard_id, rs_wb_hazard_id, rs_mem_hazard_id, rs_ex_hazard_id };
    
    // Generate stall signal
    assign stall_pc = is_jump_rs && (((rs_if == dest_id) && reg_write_id) ||
                                     ((rs_if == dest_ex) && ex_load));
    assign stall    = (rs_ex_hazard_id || rt_ex_hazard_id) && ex_load;

endmodule
