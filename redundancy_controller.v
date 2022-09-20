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
localparam [3:0] RC_IDLE       = 4'd0,  // idle mode
                 RC_INPUT      = 4'd1,  // input mode
                 RC_DIST_CALC  = 4'd2,  // distance calculation mode

reg [3:0] mode;  // FSM state register


// Registers and buffers
reg valid_reg;  // output valid signal

reg [RSIZ_WIDTH-1:0] rsiz_cnt;  // counter for row size of LIFM

reg [MAX_LIFM_RSIZ*WORD_WIDTH-1:0]            kidx_buffer;    // buffer for index of each redundant kernel element
reg [MAX_LIFM_RSIZ*STEP_RANGE*WORD_WIDTH-1:0] lifm_buffer;    // buffer for lowered input feature map
reg [MAX_LIFM_RSIZ*STEP_RANGE*WORD_WIDTH-1:0] mt_buffer;      // buffer for mapping table
reg [MAX_LIFM_RSIZ*STEP_RANGE*2-1:0]          st_buffer;      // buffer for state table (entry size is 2bits)

assign valid        = valid_reg;
assign olifm_column = lifm_buffer[(MAX_LIFM_RSIZ-1)*STEP_RANGE*WORD_WIDTH +: STEP_RANGE*WORD_WIDTH];
assign mt_column    = mt_buffer[(MAX_LIFM_RSIZ-1)*STEP_RANGE*STEP_RANGE +: STEP_RANGE*STEP_RANGE];


// // Iterators
// reg [ITER_WIDTH-1:0] src_it, dest_it;      // source/destination iterator
// reg [WORD_WIDTH-1:0] src_elem, dest_elem;  // source/destination element
// reg [1:0]            src_st_elem;          // state table element

// wire [ITER_WIDTH-STEP_SHIFT-1:0] src_row_idx, dest_row_idx;
// wire [STEP_SHIFT-1:0]            src_col_idx, dest_col_idx;
// wire                             valid_dest;
// wire                             redc_occured;

// assign src_row_idx  = src_it[ITER_WIDTH-1:STEP_SHIFT+1];    // row index of source
// assign src_col_idx  = src_it[STEP_SHIFT:0];                 // column index of source
// assign dest_row_idx = dest_it[ITER_WIDTH-1:STEP_SHIFT+1];   // row index of destination
// assign dest_col_idx = dest_it[STEP_SHIFT:0];                // column index of destination

// assign valid_dest = ((src_row_idx == MAX_LIFM_RSIZ-1)  || 
//                      (dest_col_idx >= STEP_RANGE)      || 
//                      (src_row_idx == dest_row_idx)) ? 1'b0 : 1'b1;  // valid destination condition

// assign redc_occured = (src_elem == dest_elem) ? 1'b1 : 1'b0;  // redundancy occurance condition


// // Mapping table entry generator
// reg [STEP_RANGE-1:0] src_mt_mask;
// reg [STEP_RANGE-1:0] dest_mt_mask;


// // Chain rule detection
// reg ch_continue;
// reg [ITER_WIDTH-1:0] ch_it;       // chain iterator


// Free list
reg [FL_RANGE*WORD_WIDTH-1:0] fl_row_buffer;  // buffer for free list rows
reg [FL_RANGE*WORD_WIDTH-1:0] fl_col_buffer;  // buffer for free list columns


// Inatanciation of distance calculation unit
reg dc_unit_enable;
wire [MAX_LIFM_RSIZ-1:0]            dc_unit_valid_vec;
wire [MAX_LIFM_RSIZ-1:0]            dc_unit_exception_vec;
wire [MAX_LIFM_RSIZ*DIST_WIDTH-1:0] dist_vec;

assign dc_unit_valid_vec[MAX_LIFM_RSIZ-1] = 0;
assign dc_unit_exception_vec[MAX_LIFM_RSIZ-1] = 0;
assign dist_vec[MAX_LIFM_RSIZ*DIST_WIDTH-1:(MAX_LIFM_RSIZ-1)*DIST_WIDTH] = 0;

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
assign next_input     = (rsiz_cnt >= rsiz) || (!enable_in)               ? RC_DIST_CALC  : RC_INPUT;
assign next_dist_calc = (&dc_unit_valid_vec)                             ? RC_REDC_DETC  : RC_DIST_CALC;

assign next = (mode == RC_IDLE)      ? next_idle      :
              (mode == RC_INPUT)     ? next_input     :
              (mode == RC_DIST_CALC) ? next_dist_calc :
                                       RC_IDLE;

always @(posedge clk or negedge reset_n) begin : RC_STATE_TRANS
    if (!reset_n) begin
        mode <= RC_IDLE;
    end else begin
        mode <= next;
    end
end
    
endmodule  // End of RedundancyController