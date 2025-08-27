`timescale 1ns / 1ps

module cache(
    input clk,
    input reset_n,
    
    input       readC,
    input       writeC,
    output      readyC,
    
    input [15:0] address,
    inout [15:0] data_dp,   // bus for datapath
    inout [63:0] data_mem,  // bus for memory
    
    output reg readM,
    output reg writeM,
    input       readyM
    );
    
    reg  [11:0] tag_bank  [3:0];
    reg         valid     [3:0];
    reg  [63:0] data_bank [3:0];
    
    reg         dirty     [3:0];     // dirty bit for each line
    
    wire [11:0] tag;
    wire [1:0]  index;
    wire [1:0]  bo;                  // block offset
    
    wire        hit;
    reg         c_valid;
    
    reg  [15:0] num_hit;
    reg  [15:0] num_access;
    
    assign tag   = address[15:4];
    assign index = address[3:2];
    assign bo    = address[1:0];
    
    assign hit   = (tag == tag_bank[index]) && valid[index];
    assign readyC   = hit | c_valid;

    assign data_dp  = readyC ? data_bank[index][(bo * 16) +: 16] : 16'bz;
    assign data_mem = writeM ? data_bank[index] : 64'bz;
    
    always @ (negedge reset_n, posedge clk) begin
        if (!reset_n) begin
            tag_bank[0]  <= 0;
            tag_bank[1]  <= 0;
            tag_bank[2]  <= 0;
            tag_bank[3]  <= 0;
            valid[0]     <= 0;
            valid[1]     <= 0;
            valid[2]     <= 0;
            valid[3]     <= 0;
            data_bank[0] <= 0;
            data_bank[1] <= 0;
            data_bank[2] <= 0;
            data_bank[3] <= 0;
            dirty[0]     <= 0;
            dirty[1]     <= 0;
            dirty[2]     <= 0;
            dirty[3]     <= 0;
            readM        <= 0;
            writeM       <= 0;
            c_valid      <= 0;
            num_hit      <= 0;
            num_access   <= 0;
        end
        else begin
            if (readC) begin
                if (!hit) begin
                    if (dirty[index]) begin
                        if (writeM) begin
                            if (readyM) begin
                                dirty[index] <= 0;
                                writeM <= 0;
                            end
                        end
                        else writeM <= 1;
                    end
                    else if (readM) begin
                        if (readyM) begin
                            tag_bank[index]  <= tag;
                            valid[index]     <= 1;
                            data_bank[index] <= data_mem;
                            readM <= 0;
                        end
                    end
                    else readM <= 1;
                end
                else num_hit <= num_hit + 1;
            end
            if (writeC) begin
                if (!hit) begin
                    if (dirty[index]) begin
                        if (writeM) begin
                            if (readyM) begin
                                data_bank[index][(bo * 16) +: 16] <= data_dp;
                                writeM <= 0;
                            end
                        end
                        else writeM <= 1;
                    end
                end
                else begin
                    num_hit <= num_hit + 1;
                    if (data_bank[index][(bo * 16) +: 16] != data_dp) begin
                        data_bank[index][(bo * 16) +: 16] <= data_dp;
                        dirty[index] <= 1;
                    end
                end
            end
            if (readyM) c_valid <= 1;
            else c_valid <= 0;
        end
    end
endmodule
