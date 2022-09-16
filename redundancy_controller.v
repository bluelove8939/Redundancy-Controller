/*
 *  Module Name: RedundancyController
 *
 *  Description
 *    This module generates dense IFM(Input Feature Map) and MT(Mapping Table) from given 
 *    LIFM(Lowered IFM)
 */

module RedundancyController #(
    parameter WORD_WIDTH = 8,       // bitwidth of quantized activation element
    parameter CDIST_WIDTH = 8,      // bitwidth of column distance values (d, dr, dv, dh)
    parameter RDIST_WIDTH = 8,      // bitwidth of row distance values (lr, oc)
    parameter MAX_LIFM_RSIZ = 3,    // maximum row size of LIFM
    parameter STEP_RANGE = 128      // step range (LIFM column window size, MTE size)
) (
    input clk,       // positive edge triggered clock signal
    input reset_n,   // asynchronous negative triggered reset
    input enable_in, // input enable signal

    input [WORD_WIDTH-1:0] ke_width;  // kernel width (FW)
    input [WORD_WIDTH-1:0] of_width;  // output feature map width (OW)
    input [WORD_WIDTH-1:0] stride;    // stride of convolution windows (S)
    
    input [WORD_WIDTH-1:0]            kidx;         // index of each kernel element
    input [WORD_WIDTH*STEP_RANGE-1:0] lifm_column,  // each column of LIFM

    output valid,  // 1 if output is valid

    output [WORD_WIDTH*STEP_RANGE-1:0] olifm_column,  // each column of output dense LIFM
    output [STEP_RANGE*STEP_RANGE-1:0] mt_column      // each column of mapping table
);


/*
 *  Local Parameters
 */

// FSM states
localparam                  RC_MODE_WIDTH = 3;                 // bitwidth of FSM state register
localparam [MODE_WIDTH-1:0] RC_IDLE       = RC_MODE_WIDTH'd0;  // idle state
localparam [MODE_WIDTH-1:0] RC_INPUT      = RC_MODE_WIDTH'd1;  // input mode
localparam [MODE_WIDTH-1:0] RC_DIST_CALC  = RC_MODE_WIDTH'd2;  // distance calculation mode
localparam [MODE_WIDTH-1:0] RC_REDC_CALC  = RC_MODE_WIDTH'd3;  // redundancy calculation mode
localparam [MODE_WIDTH-1:0] RC_DIFM_CALC  = RC_MODE_WIDTH'd4;  // dense IFM calculation mode
localparam [MODE_WIDTH-1:0] RC_OUTPUT     = RC_MODE_WIDTH'd5;  // output mode


/*
 *  Registers and Buffers
 */

reg valid_reg;  // output valid signal

reg [RC_MODE_WIDTH-1:0] mode;  // FSM state register

reg [WORD_WIDTH-1:0] rsiz_cnt;  // counter for row size of LIFM
reg [WORD_WIDTH-1:0] cursor_a;  // cursor_a and cursor_b are used to check redundancy
reg [WORD_WIDTH-1:0] cursor_b;  // cursor_b is for src column and cursor_b is for dest column

reg [0:MAX_LIFM_RSIZ-1] [WORD_WIDTH-1:0]            kidx_buffer;  // buffer for index of each redundant kernel element
reg [0:MAX_LIFM_RSIZ-1] [WORD_WIDTH*STEP_RANGE-1:0] lifm_buffer;  // buffer for lowered input feature map
reg [0:MAX_LIFM_RSIZ-1] [STEP_RANGE*STEP_RANGE-1:0] mt_buffer;    // buffer for mapping table
reg [0:MAX_LIFM_RSIZ-1] [2*STEP_RANGE-1:0]          st_buffer;    // buffer for state table (entry size is 2bits)

assign valid        = valid_reg;
assign olifm_column = lifm_buffer[MAX_LIFM_RSIZ-1];
assign mt_column    = mt_buffer[MAX_LIFM_RSIZ-1];


/*
 *  Distance Calculation Unit
 */

reg dc_unit_enable;
wire [0:MAX_LIFM_RSIZ-2]                  dc_unit_valid_vec;
wire [0:MAX_LIFM_RSIZ-2] [WORD_WIDTH-1:0] hdist_vec;
wire [0:MAX_LIFM_RSIZ-2] [WORD_WIDTH-1:0] vdist_vec;

genvar dist_it;

generate
    for (dist_it = 0; dist_it < MAX_LIFM_RSIZ-1; dist_it = dist_it + 1) begin
        DistCalc #(.WORD_WIDTH(WORD_WIDTH)) dc_unit (
            .clk(clk),
            .reset_n(reset_n),
            .enable_in(dc_unit_enable);

            .ke_width(ke_width),

            .idx1(kidx_buffer[dist_it]),
            .idx2(kidx_buffer[dist_it+1]),

            .valid(dc_unit_valid_vec[dist_it]),

            .vdist(vdist_vec[dist_it]),
            .hdist(hdist_vec[dist_it])
        );
    end
endgenerate


/*
 *  Main Operation
 */

always @(posedge clk or negedge reset_n) begin : RC_MAIN_OP
    // Reset registers and buffers
    if (!reset_n) begin
        valid_reg <= 0;

        rsiz_cnt <= 0;
        cursor_a <= 0;
        cursor_b <= 0;

        kidx_buffer <= 0;
        lifm_buffer <= 0;
        mt_buffer <= 0;
        st_buffer <= 0;

        dc_unit_enable <= 0;
    end

    // IDLE mode operation
    else if (mode == RC_IDLE) begin : RC_IDLE_MODE_OP
        valid_reg <= 0;

        rsiz_cnt <= 0;
        cursor_a <= 0;
        cursor_b <= 0;

        kidx_buffer <= 0;
        lifm_buffer <= 0;
        mt_buffer <= 0;
        st_buffer <= 0;

        dc_unit_enable <= 0;
    end

    // Input mode operation
    else if (mode == RC_INPUT) begin : RC_INPUT_MODE_OP
        rsiz_cnt <= rsiz_cnt + 1;  // increase row size

        kidx_buffer[0:MAX_LIFM_RSIZ-1] <= {kidx,        kidx_buffer[0:MAX_LIFM_RSIZ-2]};  // shift kernel idx buffer
        lifm_buffer[0:MAX_LIFM_RSIZ-1] <= {lifm_column, lifm_buffer[0:MAX_LIFM_RSIZ-2]};  // shift LIFM buffer
    end

    // Distance calculation mode operation
    else if (mode == RC_DIST_CALC) begin
        dc_unit_enable <= 1;
    end
end


/*
 *  State Transition
 */

always @(enable_in, rsiz_cnt, reset_n) begin : RC_STATE_TRANS
    if (mode == RC_IDLE) begin
        if (enable_in) begin
            mode <= RC_INPUT;
        end
    end

    else if (mode == RC_INPUT) begin
        if (rsiz_cnt >= MAX_LIFM_RSIZ) begin
            mode <= RC_DIST_CALC;
        end
    end

    else if (mode == RC_OUTPUT) begin
        if (!reset_n) begin
            mode <= RC_IDLE;
        end
    end
end
    
endmodule  // End of RedundancyController


/*
 *  Module Name: DistCalc
 *
 *  Description
 *    This module calculates horizontal/vertical distance of duplicated kernel element
 *    with given indices.
 */

module DistCalc #(
    parameter WORD_WIDTH = 8
) (
    input clk,        // positive edge triggered clock signal
    input reset_n,    // asynchronous negative triggered reset signal
    input enable_in,  // input enable signal (dh)

    input [WORD_WIDTH-1:0] ke_width;  // kernel width (FW)
    
    input [WORD_WIDTH-1:0] idx1,  // lowered index1
    input [WORD_WIDTH-1:0] idx2,  // lowered index2

    output valid,  // output valid signal
    
    output [WORD_WIDTH-1:0] vdist   // vertical distance    (i2 // FW) - (i1 // FW)
    output [WORD_WIDTH-1:0] hdist,  // horizontal distance  (i2 %  FW) - (i1 %  FW)
);

// FSM states
localparam                  DC_MODE_WIDTH  = 2;                 // bitwidth of FSM state register
localparam [MODE_WIDTH-1:0] DC_IDLE        = DC_MODE_WIDTH'd0;  // IDLE state
localparam [MODE_WIDTH-1:0] DC_IN          = DC_MODE_WIDTH'd1;  // input state
localparam [MODE_WIDTH-1:0] DC_DIV         = DC_MODE_WIDTH'd2;  // division calculation state
localparam [MODE_WIDTH-1:0] DC_OUT         = DC_MODE_WIDTH'd3;  // output state

reg [DC_MODE_WIDTH-1:0] mode;  // FSM state register

// Registers
reg valid_in_reg;    // input valid signal register
reg valid_idx1_div;  // idx1 division valid signal register
reg valid_idx2_div;  // idx2 division valid signal register
reg valid_out_reg;   // output valid signal register

reg [WORD_WIDTH-1:0] idx1_mod;   // -> i1 % FW
reg [WORD_WIDTH-1:0] idx2_mod;   // -> i2 % FW
reg [WORD_WIDTH-1:0] idx1_quot;  // -> i1 // FW
reg [WORD_WIDTH-1:0] idx2_quot;  // -> i2 // FW

reg [WORD_WIDTH-1:0] vdist_reg;  // vertical distance register
reg [WORD_WIDTH-1:0] hdist_reg;  // horizontal distance register

assign valid = valid_out_reg;
assign vdist = vdist_reg;
assign hdist = hdist_reg;

// Main synchronous operation
always @(posedge clk or negedge reset_n) begin : DC_MAIN_OP
    // Reset registers and buffers
    if (!reset_n) begin
        valid_in_reg <= 0;
        valid_idx1_div <= 0;
        valid_idx2_div <= 0;
        valid_out_reg <= 0;

        idx1_mod <= 0;
        idx2_mod <= 0;
        idx1_quot <= 0;
        idx2_quot <= 0;

        vdist_reg <= 0;
        hdist_reg <= 0;
    end
    
    // IDLE state
    else if (mode == DC_IDLE) begin
        valid_in_reg <= 0;
        valid_idx1_div <= 0;
        valid_idx2_div <= 0;
        valid_out_reg <= 0;

        idx1_mod <= 0;
        idx2_mod <= 0;
        idx1_quot <= 0;
        idx2_quot <= 0;

        vdist_reg <= 0;
        hdist_reg <= 0;
    end

    // Input mode operation
    else if (mode == DC_IN) begin
        idx1_mod <= idx1;
        idx2_mod <= idx2;
        valid_in_reg <= 1;
    end

    // Division calculation mode operation
    else if (mode == DC_DIV) begin
        if (idx1_mod >= ke_width) begin
            idx1_mod  <= idx1_mod - ke_width;
            idx1_quot <= idx1_quot + 1;
        end else begin
            valid_idx1_div <= 1;
        end

        if (idx2_mod >= ke_width) begin
            idx2_mod  <= idx2_mod - ke_width;
            idx2_quot <= idx2_quot + 1;
        end else begin
            valid_idx2_div <= 1;
        end
    end

    // Output mode operation
    else if (mode == DC_OUT) begin
        if (!valid_out_reg) begin
            hdist_reg <= idx2_mod - idx1_mod;
            vdist_reg <= idx2_quot - idx1_quot;
            valid_out_reg <= 1;
        end
    end
end

// State transition
always @(enable_in, valid_in_reg, valid_out_reg, reset_n) begin : DC_STATE_TRANS
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
end
    
endmodule  // End of DistCalc