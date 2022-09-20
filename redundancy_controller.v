`include "distance_calculator.v"

/*
 *  Module Name: RedundancyController
 *
 *  Description
 *    This module generates dense IFM(Input Feature Map) and MT(Mapping Table) from given 
 *    LIFM(Lowered IFM)
 */

module RedundancyController #(
    parameter WORD_WIDTH = 8,       // bitwidth of quantized activation element
    parameter DIST_WIDTH = 7,       // bitwidth of distance values (d, dr, dv, dh) (default 7bits, maximum 127)
    parameter RSIZ_WIDTH = 2,       // bitwidth of rowsize buffer (default 2bits, maximum 3, minimum 2)
    parameter MAX_LIFM_RSIZ = 3,    // maximum row size of LIFM
    parameter STEP_RANGE = 128,     // step range (LIFM column window size, MTE size)
    parameter FL_RANGE = 128        // free list range (column size of list of free slot)
) (
    input clk,       // positive edge triggered clock signal
    input reset_n,   // asynchronous negative triggered reset
    input enable_in, // input enable signal

    input [WORD_WIDTH-1:0] ke_width,  // kernel width (FW)
    input [WORD_WIDTH-1:0] of_width,  // output feature map width (OW)
    input [WORD_WIDTH-1:0] stride,    // stride of convolution windows (S)

    input [RSIZ_WIDTH-1:0] rsiz,  // row size of LIFM partition
    
    input [WORD_WIDTH-1:0]            kidx,         // index of each kernel element
    input [WORD_WIDTH*STEP_RANGE-1:0] lifm_column,  // each column of LIFM

    output valid,  // 1 if output is valid

    output [WORD_WIDTH*STEP_RANGE-1:0] olifm_column,  // each column of output dense LIFM
    output [STEP_RANGE*STEP_RANGE-1:0] mt_column      // each column of mapping table
);


// FSM states
localparam [3:0] RC_IDLE       = 4'd0,  // idle state
                 RC_INPUT      = 4'd1,  // input mode
                 RC_DIST_CALC  = 4'd2,  // distance calculation mode
                 RC_IT_INIT    = 4'd3,  // making mapping table for redundancy calculation
                 RC_REDC_DETC  = 4'd4,  // shifting for redundancy calculation
                 RC_ROW_IT_UD  = 4'd5,  // making mapping table for redundancy calculation
                 RC_COL_IT_UD  = 4'd6,  // iterator setup
                 RC_EX_INIT    = 4'd7,  // initialization stage for exchanging 
                 RC_EXCHANGE   = 4'd8,  // dense IFM calculation mode (compression)
                 RC_OUTPUT     = 4'd9;  // output mode

reg [3:0] mode;  // FSM state register


// Registers and buffers
reg valid_reg;  // output valid signal

reg [WORD_WIDTH-1:0] rsiz_cnt;  // counter for row size of LIFM

reg [MAX_LIFM_RSIZ*WORD_WIDTH-1:0]            kidx_buffer;    // buffer for index of each redundant kernel element
reg [MAX_LIFM_RSIZ*STEP_RANGE*WORD_WIDTH-1:0] lifm_buffer;    // buffer for lowered input feature map
reg [MAX_LIFM_RSIZ*STEP_RANGE*WORD_WIDTH-1:0] mt_buffer;      // buffer for mapping table
reg [MAX_LIFM_RSIZ*STEP_RANGE*2-1:0]          st_buffer;      // buffer for state table (entry size is 2bits)

assign valid        = valid_reg;
assign olifm_column = lifm_buffer[(MAX_LIFM_RSIZ-1)*STEP_RANGE*WORD_WIDTH +: STEP_RANGE*WORD_WIDTH];
assign mt_column    = mt_buffer[(MAX_LIFM_RSIZ-1)*STEP_RANGE*STEP_RANGE +: STEP_RANGE*STEP_RANGE];


// Inatanciation of distance calculation unit
reg dc_unit_enable;
wire [MAX_LIFM_RSIZ-2:0]                dc_unit_valid_vec;
wire [MAX_LIFM_RSIZ-2:0]                dc_unit_exception_vec;
wire [(MAX_LIFM_RSIZ-1)*DIST_WIDTH-1:0] dist_vec;

genvar dist_gvar;

generate
    for (dist_gvar = 0; dist_gvar < MAX_LIFM_RSIZ-1; dist_gvar = dist_gvar + 1) begin
        DistCalc #(.WORD_WIDTH(WORD_WIDTH)) dc_unit (
            .clk(clk),
            .reset_n(reset_n),
            .enable_in(dc_unit_enable),

            .ke_width(ke_width),
            .of_width(of_width),
            .stride(stride),

            .idx1(kidx_buffer[WORD_WIDTH*dist_gvar +: WORD_WIDTH]),
            .idx2(kidx_buffer[WORD_WIDTH*(dist_gvar+1) +: WORD_WIDTH]),

            .valid(dc_unit_valid_vec[dist_gvar]),
            .exception(dc_unit_exception_vec[dist_gvar]),

            .dist(dist_vec[DIST_WIDTH*dist_gvar +: DIST_WIDTH])
        );
    end
endgenerate


// Main operation
always @(posedge clk or negedge reset_n) begin : RC_MAIN_OP
    // Reset registers and buffers
    if (!reset_n) begin
        valid_reg <= 0;

        rsiz_cnt <= 0;

        kidx_buffer <= 0;
        lifm_buffer <= 0;
        mt_buffer <= 0;
        st_buffer <= 0;

        dc_unit_enable <= 0;
    end

    // IDLE mode operation
    else if (mode == RC_IDLE) begin
        valid_reg <= 0;

        rsiz_cnt <= 0;

        kidx_buffer <= 0;
        lifm_buffer <= 0;
        mt_buffer <= 0;
        st_buffer <= 0;

        dc_unit_enable <= 0;
    end

    // Input mode operation
    else if (mode == RC_INPUT) begin
        rsiz_cnt <= rsiz_cnt + 1;  // increase row size

        kidx_buffer <= {kidx_buffer[(MAX_LIFM_RSIZ-1)*WORD_WIDTH-1:0],            kidx};         // shift kernel idx buffer
        lifm_buffer <= {lifm_buffer[(MAX_LIFM_RSIZ-1)*STEP_RANGE*WORD_WIDTH-1:0], lifm_column};  // shift LIFM buffer
    end

    // Distance calculation mode operation
    else if (mode == RC_DIST_CALC) begin
        dc_unit_enable <= 1;
    end

    
end


// State Transition
wire [3:0] next, next_idle, next_input, next_dist_calc, next_redc_detc, next_row_it_ud, next_col_it_ud;

assign next_idle      = enable_in                                        ? RC_INPUT      : RC_IDLE;
assign next_input     = (rsiz_cnt >= rsiz)                               ? RC_DIST_CALC  : RC_INPUT;
assign next_dist_calc = (&dc_unit_valid_vec)                             ? RC_REDC_DETC  : RC_DIST_CALC;
// assign next_redc_detc =                                                    RC_ROW_IT_UD;
// assign next_row_it_ud =                                                    RC_COL_IT_UD;
// assign next_col_it_ud = (s_row_it == rsiz-1 && s_col_it == STEP_RANGE-1) ? RC_EXCHANGE   : RC_REDC_DETC;

assign next = (mode == RC_IDLE)      ? next_idle      :
              (mode == RC_INPUT)     ? next_input     :
              (mode == RC_DIST_CALC) ? next_dist_calc :
            //   (mode == RC_REDC_DETC) ? next_redc_detc :
            //   (mode == RC_ROW_IT_UD) ? next_row_it_ud :
            //   (mode == RC_COL_IT_UD) ? next_col_it_ud :
                                       RC_IDLE;

always @(posedge clk or negedge reset_n) begin : RC_STATE_TRANS
    if (!reset_n) begin
        mode <= RC_IDLE;
    end else begin
        mode <= next;
    end
end
    
endmodule  // End of RedundancyController