/*
 *  Module Name: DistCalc
 *
 *  Description
 *    This module calculates horizontal/vertical distance of duplicated kernel element
 *    with given indices.
 */

 `include "division_unit.v"
 `include "multiplication_unit.v"

module DistCalc #(
    parameter WORD_WIDTH = 8,  // default wordwidth is 1Byte
    parameter DIST_WIDTH = 7   // default maximum distance is 127 (7bits)
) (
    input clk,        // positive edge triggered clock signal
    input reset_n,    // asynchronous negative triggered reset signal
    input enable_in,  // input enable signal (dh)

    input [WORD_WIDTH-1:0] ke_width,  // kernel width (FW)
    input [WORD_WIDTH-1:0] of_width,  // output feature map width (OW)
    input [WORD_WIDTH-1:0] stride,    // stride of convolution windows (S)
    
    input [WORD_WIDTH-1:0] idx1,  // lowered index1
    input [WORD_WIDTH-1:0] idx2,  // lowered index2

    output valid,      // output valid signal
    output exception,  // exception signal
    
    output [WORD_WIDTH-1:0] dist  // redundant LIFM element distance (dr)
);

// FSM states
localparam [2:0] DC_IDLE        = 3'd0;  // IDLE state
localparam [2:0] DC_IN          = 3'd1;  // input state
localparam [2:0] DC_FW_DIV      = 3'd3;  // division with filter width
localparam [2:0] DC_ST_DIV_INIT = 3'd2;  // division with stride initialization
localparam [2:0] DC_ST_DIV      = 3'd4;  // division with stride width
localparam [2:0] DC_COORD_CALC  = 3'd5;  // vertical/horizontal distance calculation
localparam [2:0] DC_DIST_CALC   = 3'd6;  // distance calculation
localparam [2:0] DC_OUT         = 3'd7;  // output state

reg [2:0] mode;  // state register


// Registers
reg valid_in_reg;    // input valid signal register
reg valid_out_reg;   // output valid signal register

reg overflow_reg;    // overflow exception register
reg st_except_reg;   // stride exeption register

reg [DIST_WIDTH-1:0] dist_reg;   // redundant LIFM element distance register (dr)
reg [DIST_WIDTH-1:0] vdist_reg;  // vertical distance register (dv)
reg [DIST_WIDTH-1:0] hdist_reg;  // horizontal distance register (dh)

assign valid = valid_out_reg;
assign exception = overflow_reg & st_except_reg;
assign dist = dist_reg;


// Instanciation of division modules
reg enable_div;  // enable signal of divisor unit

reg [WORD_WIDTH-1:0] div_left_op1;   // left operand buffer1
reg [WORD_WIDTH-1:0] div_left_op2;   // left operand buffer2
reg [WORD_WIDTH-1:0] div_right_op1;  // right operand buffer1
reg [WORD_WIDTH-1:0] div_right_op2;  // right operand buffer2

wire valid_div1;  // division valid register1
wire valid_div2;  // division valid register2

wire [WORD_WIDTH-1:0] div_mod1;   // modulus buffer1
wire [WORD_WIDTH-1:0] div_mod2;   // modulus buffer2
wire [WORD_WIDTH-1:0] div_quot1;  // quotient buffer1
wire [WORD_WIDTH-1:0] div_quot2;  // quotient buffer2

DivisionUnit #(
    .WORD_WIDTH(WORD_WIDTH)
) div1 (
    .clk(clk), .reset_n(reset_n), .enable(enable_div),
    .left_op(div_left_op1), .right_op(div_right_op1),
    .valid(valid_div1), .quot(div_quot1), .mod(div_mod1)
);

DivisionUnit #(
    .WORD_WIDTH(WORD_WIDTH)
) div2 (
    .clk(clk), .reset_n(reset_n), .enable(enable_div),
    .left_op(div_left_op2), .right_op(div_right_op2),
    .valid(valid_div2), .quot(div_quot2), .mod(div_mod2)
);


// Instanciation of multiplication modules
reg enable_mul;

wire valid_mul;
wire overflow_mul;
wire [DIST_WIDTH-1:0] mul_result;

MultiplicationUnit #(
    .WORD_WIDTH(WORD_WIDTH),
    .REST_WIDTH(DIST_WIDTH)
) mul (
    .clk(clk), .reset_n(reset_n), .enable(enable_mul),
    .left_op(ke_width), .right_op({1'b0, vdist_reg}),
    .valid(valid_mul), .overflow(overflow_mul), .result(mul_result)
);


// Main operations
always @(posedge clk or negedge reset_n) begin : DC_MAIN_OP
    // Reset registers and buffers
    if (!reset_n) begin
        valid_in_reg <= 0;
        valid_out_reg <= 0;
        overflow_reg <= 0;
        st_except_reg <= 0;

        vdist_reg <= 0;
        hdist_reg <= 0;
        dist_reg <= 0;

        enable_div <= 0;

        div_left_op1 <= 0;
        div_left_op2 <= 0;
        div_right_op1 <= 0;
        div_right_op2 <= 0;

        enable_mul <= 0;
    end
    
    // IDLE state
    else if (mode == DC_IDLE) begin
        valid_in_reg <= 0;
        valid_out_reg <= 0;
        overflow_reg <= 0;
        st_except_reg <= 0;

        vdist_reg <= 0;
        hdist_reg <= 0;
        dist_reg <= 0;

        enable_div <= 0;

        div_left_op1 <= 0;
        div_left_op2 <= 0;
        div_right_op1 <= 0;
        div_right_op2 <= 0;

        enable_mul <= 0;
    end

    // Input mode operation (initialization of FW division op)
    else if (mode == DC_IN) begin
        div_left_op1 <= idx1;
        div_left_op2 <= idx2;
        div_right_op1 <= ke_width;
        div_right_op2 <= ke_width;
        valid_in_reg <= 1;
    end

    else if (mode == DC_FW_DIV) begin
        enable_div <= 1;
        valid_in_reg <= 0;
    end

    else if (mode == DC_COORD_CALC) begin
        vdist_reg <= div_quot2 - div_quot1;
        hdist_reg <= div_mod2 - div_mod1;
        div_left_op1 <= div_quot1;
        div_left_op2 <= div_quot2;
    end

    else if (mode == DC_ST_DIV_INIT) begin
        enable_div <= 0;
        div_right_op1 <= stride;
        div_right_op2 <= stride;
        valid_in_reg <= 1;
    end

    else if (mode == DC_ST_DIV) begin
        enable_div <= 1;
        valid_in_reg <= 0;
    end

    else if (mode == DC_DIST_CALC) begin
        enable_mul <= 1;
    end

    else if (mode == DC_OUT) begin
        st_except_reg <= (div_mod1 == 0 && div_mod2 == 0) ? 1'b0 : 1'b1;
        overflow_reg <= overflow_mul;
        dist_reg <= mul_result + hdist_reg;
        valid_out_reg <= 1;
    end
end

// State transition
wire [2:0] next, next_idle, next_in, next_fw_div, next_coord_calc, next_st_div_init, next_st_div, next_dist_calc, next_out;

assign next_idle        = enable_in                ? DC_IN          : DC_IDLE;
assign next_in          = valid_in_reg             ? DC_FW_DIV      : DC_IN;
assign next_fw_div      = valid_div1 && valid_div2 ? DC_COORD_CALC  : DC_FW_DIV;
assign next_coord_calc  =                            DC_ST_DIV_INIT;
assign next_st_div_init = valid_in_reg             ? DC_ST_DIV      : DC_ST_DIV_INIT;
assign next_st_div      = valid_div1 && valid_div2 ? DC_DIST_CALC   : DC_ST_DIV;
assign next_dist_calc   = valid_mul                ? DC_OUT         : DC_DIST_CALC;
assign next_out         = !enable_in               ? DC_IDLE        : DC_OUT;

assign next = (mode == DC_IDLE)        ? next_idle        :
              (mode == DC_IN)          ? next_in          :
              (mode == DC_FW_DIV)      ? next_fw_div      : 
              (mode == DC_COORD_CALC)  ? next_coord_calc  :
              (mode == DC_ST_DIV_INIT) ? next_st_div_init :
              (mode == DC_ST_DIV)      ? next_st_div      :
              (mode == DC_DIST_CALC)   ? next_dist_calc   :
              (mode == DC_OUT)         ? next_out         :
                                         DC_IDLE;

always @(posedge clk or negedge reset_n) begin : DC_STATE_TRANS
    if (!reset_n) begin
        mode <= DC_IDLE;
    end else begin
        mode <= next;
    end
end
    
endmodule  // End of DistCalc