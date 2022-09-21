`include "distance_calculator.v"
`include "redundancy_checker.v"

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
                 RC_REDC_DETC  = 4'd3,
                 RC_REDC_EDIT  = 4'd4,  // edit mapping/state table entry
                 RC_REDC_ITER  = 4'd5;

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


// Instanciation of checker array
reg checker_enable;
reg checker_set_idle;
reg checker_enable_rd;
reg checker_enable_wt;

wire [STEP_RANGE-1:0] checker_valid_vec;

wire [ITER_WIDTH-1:0] checker_ch_it   [0:STEP_RANGE-1],
                      checker_src_it  [0:STEP_RANGE-1],
                      checker_dest_it [0:STEP_RANGE-1];

wire [STEP_RANGE-1:0] checker_src_mt  [0:STEP_RANGE-1];
wire [1:0]            checker_src_st  [0:STEP_RANGE-1];
wire [1:0]            checker_dest_st [0:STEP_RANGE-1];

wire                  checker_enable_fl_vec [0:STEP_RANGE];
wire                  checker_valid_fl_vec  [0:STEP_RANGE];

reg checker_enable_fl;
wire checker_valid_fl;

assign checker_enable_fl_vec[0] = checker_enable_fl;
assign checker_valid_fl = checker_valid_fl_vec[STEP_RANGE-1]

genvar checker_gvar;

generate
    for (checker_gvar = 0; checker_gvar < STEP_RANGE; checker_gvar = checker_gvar + 1) begin
        RedundancyChecker #(
            .WORD_WIDTH(WORD_WIDTH), .RSIZ_WIDTH(RSIZ_WIDTH), .ITER_WIDTH(ITER_WIDTH), .MAX_LIFM_RSIZ(MAX_LIFM_RSIZ),
            .STEP_RANGE(STEP_RANGE), .DIST_WIDTH(DIST_WIDTH), .OFFSET(checker_gvar)
        ) checker_unit (
            .clk(clk), .reset_n(reset_n), .set_idle(checker_set_idle),
            .enable_rd(checker_enable_rd), .enable_wt(checker_enable_wt), 
            .enable_fl(checker_enable_fl_vec[checker_gvar]),

            .rsiz(rsiz), .dist_except(dc_unit_exception_vec), .dist_buffer(dist_vec),
            .lifm_buffer(lifm_buffer), .mt_buffer(mt_buffer), .st_buffer(st_buffer),
            
            .valid(checker_valid_vec[checker_gvar]), .valid_fl(checker_valid_fl_vec[checker_gvar]),

            .n_ch_it(checker_ch_it[checker_gvar]),
            .n_src_it(checker_src_it[checker_gvar]),
            .n_dest_it(checker_dest_it[checker_gvar]),

            .n_src_mt(checker_src_mt[checker_gvar]),
            .n_src_st(checker_src_st[checker_gvar]),
            .n_dest_st(checker_dest_st[checker_gvar])
        );

        assign 
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

    else if (mode == RC_REDC_DETC) begin
        checker_enable_rd <= 1;
        checker_enable_wt <= 1;
    end

    else if (mode == RC_REDC_EDIT) begin
        for (integer sr_idx = 0; sr_idx < STEP_RANGE; sr_idx = sr_idx + 1) begin
            mt_buffer[STEP_RANGE*checker_ch_it[ITER_WIDTH*sr_idx +: ITER_WIDTH] +: STEP_RANGE]  <= checker_src_mt[STEP_RANGE*sr_idx +: STEP_RANGE];
            st_buffer[2*checker_src_it[ITER_WIDTH*sr_idx +: ITER_WIDTH] +: 2]  <= checker_src_st[2*sr_idx +: 2];
            st_buffer[2*checker_dest_it[ITER_WIDTH*sr_idx +: ITER_WIDTH] +: 2] <= checker_dest_st[2*sr_idx +: 2];
        end
    end

    else if (mode == RC_REDC_ITER) begin
        checker_enable_wt <= 0;
    end
end


// State Transition
wire [3:0] next, next_idle, next_input, next_dist_calc, next_redc_detc, next_redc_edit, next_redc_iter;

assign next_idle      = enable_in                           ? RC_INPUT     : RC_IDLE;
assign next_input     = (rsiz_cnt >= rsiz) || (!enable_in)  ? RC_DIST_CALC : RC_INPUT;
assign next_dist_calc = (&dc_unit_valid_vec)                ? RC_REDC_DETC : RC_DIST_CALC;
assign next_redc_detc = (&checker_valid_vec)                ? RC_REDC_EDIT : RC_REDC_DETC;
assign next_redc_edit =                                       RC_REDC_ITER;
assign next_redc_iter =                                       RC_REDC_DETC;

assign next = (mode == RC_IDLE)      ? next_idle      :
              (mode == RC_INPUT)     ? next_input     :
              (mode == RC_DIST_CALC) ? next_dist_calc :
              (mode == RC_REDC_DETC) ? next_redc_detc :
                                       RC_IDLE;

always @(posedge clk or negedge reset_n) begin : RC_STATE_TRANS
    if (!reset_n) begin
        mode <= RC_IDLE;
    end else begin
        mode <= next;
    end
end
    
endmodule  // End of RedundancyController