/*
 *  Module Name: DistCalc
 *
 *  Description
 *    This module calculates horizontal/vertical distance of duplicated kernel element
 *    with given indices.
 */

module DistCalc #(
    parameter WORD_WIDTH = 8,  // default wordwidth is 1Byte
    parameter DIST_WIDTH = 7   // default maximum distance is 127 (7bits)
) (
    input clk,        // positive edge triggered clock signal
    input reset_n,    // asynchronous negative triggered reset signal
    input enable_in,  // input enable signal (dh)

    input [WORD_WIDTH-1:0] ke_width;  // kernel width (FW)
    input [WORD_WIDTH-1:0] of_width;  // output feature map width (OW)
    input [WORD_WIDTH-1:0] stride;    // stride of convolution windows (S)
    
    input [WORD_WIDTH-1:0] idx1,  // lowered index1
    input [WORD_WIDTH-1:0] idx2,  // lowered index2

    output valid,     // output valid signal
    output overflow,  // distance overflow signal
    
    output [WORD_WIDTH-1:0] dist  // redundant LIFM element distance (dr)
);

// FSM states
localparam                  DC_MODE_WIDTH  = 2;                 // bitwidth of FSM state register
localparam [MODE_WIDTH-1:0] DC_IDLE        = DC_MODE_WIDTH'd0;  // IDLE state
localparam [MODE_WIDTH-1:0] DC_IN          = DC_MODE_WIDTH'd1;  // input state
localparam [MODE_WIDTH-1:0] DC_DIV         = DC_MODE_WIDTH'd2;  // division calculation state
localparam [MODE_WIDTH-1:0] DC_COORD_CALC  = DC_MODE_WIDTH'd3;  // vertical/horizontal distance calculation
localparam [MODE_WIDTH-1:0] DC_STIDE_EXCP  = DC_MODE_WIDTH'd3;  // stride exception checking
localparam [MODE_WIDTH-1:0] DC_DIST_CALC   = DC_MODE_WIDTH'd4;  // distance calculation
localparam [MODE_WIDTH-1:0] DC_OUT         = DC_MODE_WIDTH'd5;  // output state


reg [DC_MODE_WIDTH-1:0] mode;  // FSM state register

// Registers
reg valid_in_reg;    // input valid signal register
reg valid_idx1_div;  // idx1 division valid signal register
reg valid_idx2_div;  // idx2 division valid signal register
reg valid_out_reg;   // output valid signal register
reg overflow_reg;

reg [WORD_WIDTH-1:0] mod1;   // -> i1 % FW   dv % S
reg [WORD_WIDTH-1:0] mod2;   // -> i2 % FW   dh % S
reg [WORD_WIDTH-1:0] quot1;  // -> i1 // FW
reg [WORD_WIDTH-1:0] quot2;  // -> i2 // FW

reg [WORD_WIDTH-1:0] dist_reg;   // redundant LIFM element distance register (dr)
reg [WORD_WIDTH-1:0] vdist_reg;  // vertical distance register (dv)
reg [WORD_WIDTH-1:0] hdist_reg;  // horizontal distance register (dh)

assign valid = valid_out_reg;
assign overflow_reg = overflow;
assign dist = dist_reg;

// Main synchronous operation
always @(posedge clk or negedge reset_n) begin : DC_MAIN_OP
    // Reset registers and buffers
    if (!reset_n) begin
        valid_in_reg <= 0;
        valid_idx1_div <= 0;
        valid_idx2_div <= 0;
        valid_out_reg <= 0;

        mod1 <= 0;
        mod2 <= 0;
        quot1 <= 0;
        quot2 <= 0;

        vdist_reg <= 0;
        hdist_reg <= 0;
    end
    
    // IDLE state
    else if (mode == DC_IDLE) begin
        valid_in_reg <= 0;
        valid_idx1_div <= 0;
        valid_idx2_div <= 0;
        valid_out_reg <= 0;

        mod1 <= 0;
        mod2 <= 0;
        quot1 <= 0;
        quot2 <= 0;

        vdist_reg <= 0;
        hdist_reg <= 0;
    end

    // Input mode operation
    else if (mode == DC_IN) begin
        mod1 <= idx1;
        mod2 <= idx2;
        valid_in_reg <= 1;
    end

    // Division calculation mode operation
    else if (mode == DC_DIV) begin
        if (mod1 >= ke_width) begin
            mod1  <= mod1 - ke_width;
            quot1 <= quot1 + 1;
        end else begin
            valid_idx1_div <= 1;
        end

        if (mod2 >= ke_width) begin
            mod2  <= mod2 - ke_width;
            quot2 <= quot2 + 1;
        end else begin
            valid_idx2_div <= 1;
        end
    end

    // Coordinate calculation mode operation
    else if (mode == DC_COORD_CALC) begin
        if (!valid_out_reg) begin
            hdist_reg <= mod2 - mod1;
            vdist_reg <= quot2 - quot1;
            valid_out_reg <= 1;
        end
    end
end

// State transition
always @(enable_in, valid_in_reg, valid_idx1_div, valid_idx2_div, valid_out_reg, reset_n) begin : DC_STATE_TRANS
    if (mode == DC_IDLE) begin
        if (enable_in) begin
            mode <= DC_IN;
        end
    end

    else if (mode == DC_IN) begin
        if (valid_in_reg) begin
            mode <= DC_DIV;
        end
    end

    else if (mode == DC_DIV) begin
        if (valid_idx1_div & valid_idx2_div) begin
            mode <= DC_OUT;
        end
    end

    else if (mode == DC_OUT) begin
        if (!reset_n) begin
            mode <= DC_IDLE;
        end
    end

    else begin
        if (enable_in) begin
            mode <= DC_IN;
        end
    end
end
    
endmodule  // End of DistCalc