`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/26 17:26:27
// Design Name: 
// Module Name: branch_predictor
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


module branch_predictor(
        input clk,
        input reset_n,
        input bubble,
        
        input call_bp,
        
        output predicted_taken
    );
    
    localparam STRONGLY_NOT_TAKEN = 2'b00;
    localparam WEAKLY_NOT_TAKEN   = 2'b01;
    localparam WEAKLY_TAKEN       = 2'b10;
    localparam STRONGLY_TAKEN     = 2'b11;

    reg [1:0] current_state;
    reg [1:0] predicted_state;
    reg [1:0] recovered_state;
    
    assign predicted_taken = (current_state == STRONGLY_NOT_TAKEN || current_state == WEAKLY_NOT_TAKEN) ? 0 : 1;

    initial begin
        current_state <= STRONGLY_TAKEN;
        predicted_state <= STRONGLY_TAKEN;
        recovered_state <= STRONGLY_TAKEN;
    end
    
    always @ (*) begin
        case (current_state)
            STRONGLY_NOT_TAKEN: begin
                predicted_state <= STRONGLY_NOT_TAKEN;
                recovered_state <= WEAKLY_NOT_TAKEN;
            end
            WEAKLY_NOT_TAKEN: begin
                predicted_state <= STRONGLY_NOT_TAKEN;
                recovered_state <= WEAKLY_TAKEN;
            end
            WEAKLY_TAKEN: begin
                predicted_state <= STRONGLY_TAKEN;
                recovered_state <= WEAKLY_NOT_TAKEN;
            end
            STRONGLY_TAKEN: begin
                predicted_state <= STRONGLY_TAKEN;
                recovered_state <= WEAKLY_TAKEN;
            end
        endcase
    end

    always @ (negedge reset_n, posedge clk) begin
        if (!reset_n) begin
            current_state <= STRONGLY_TAKEN;
        end
        else if (call_bp || bubble) begin
            if (call_bp) begin
                current_state <= predicted_state;
            end
            else begin      // bubble
                current_state <= recovered_state;
            end
            case (current_state)
                STRONGLY_NOT_TAKEN: begin
                    predicted_state <= STRONGLY_NOT_TAKEN;
                    recovered_state <= WEAKLY_NOT_TAKEN;
                end
                WEAKLY_NOT_TAKEN: begin
                    predicted_state <= STRONGLY_NOT_TAKEN;
                    recovered_state <= WEAKLY_TAKEN;
                end
                WEAKLY_TAKEN: begin
                    predicted_state <= STRONGLY_TAKEN;
                    recovered_state <= WEAKLY_NOT_TAKEN;
                end
                STRONGLY_TAKEN: begin
                    predicted_state <= STRONGLY_TAKEN;
                    recovered_state <= WEAKLY_TAKEN;
                end
            endcase
        end
    end
    
endmodule
