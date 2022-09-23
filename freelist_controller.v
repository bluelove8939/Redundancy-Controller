module FreeListController #(
    parameter WORD_WIDTH = 8,
    parameter ITER_WIDTH = 9,
    parameter DIST_WIDTH = 7,
    parameter STEP_RANGE = 128,
    parameter FL_SIZE    = 128,
    parameter PTR_WIDTH  = 7
) (
    input clk,        // clock signal
    input reset_n,    // asynchronous negative active reset
    input set_idle,   // set module as idle state
    input enable_in,  // module enable signal (module goes to IDLE state if enable signal is False)
    input write_fin,  // indicates whether current writing process is finished by redundancy controller

    input [STEP_RANGE-1:0]            fl_enable_ch,  // free list entry enable signal
    input [STEP_RANGE*ITER_WIDTH-1:0] fl_it_in,      // free list entry input

    input [STEP_RANGE-1:0]            nr_enable_ch,  // no-redundancy element enable signal
    input [STEP_RANGE*ITER_WIDTH-1:0] nr_it_in,      // no-redundancy element input

    output available,  // indicates whether the controller module is busy

    output nxt_exchange,  // go onto next exchange (writing finished)
    output valid,         // indicates whether the exchange is valid

    output [ITER_WIDTH-1:0] e_src_it,  // source index for exchange
    output [ITER_WIDTH-1:0] e_dest_it  // destination index for exchange
);


// FSM states
localparam [3:0] FLC_IDLE     = 4'd0,
                 FLC_RDY      = 4'd1,
                 FLC_ENABLE   = 4'd2,
                 FLC_FL_SET   = 4'd3,
                 FLC_FL_NXT   = 4'd4,
                 FLC_WRITE = 4'd5,

reg [3:0] mode;


// Registers and buffers
reg [ITER_WIDTH-1:0] fl_it_buffer [0:STEP_RANGE-1];
reg [STEP_RANGE-1:0] fl_current_enables;
reg [ITER_WIDTH-1:0] fl_buffer [0:FL_SIZE-1];
reg fl_buff_empty_flag;

reg  [PTR_WIDTH-1:0] fl_w_ptr, fl_r_ptr;
wire [PTR_WIDTH-1:0] fl_w_ptr_nxt, fl_r_ptr_nxt;
assign fl_w_ptr_nxt = (fl_w_ptr == (FL_SIZE-1)) ? 0 : fl_w_ptr + 1;
assign fl_r_ptr_nxt = (fl_r_ptr == (FL_SIZE-1)) ? 0 : fl_r_ptr + 1;

wire fl_buff_full;
assign fl_buff_full = (!fl_buff_empty_flag) && (fl_w_ptr != fl_r_ptr);

reg [STEP_RANGE*ITER_WIDTH-1:0] nr_it_buffer;
reg [STEP_RANGE-1:0] nr_current_enables;

reg available_reg;
reg valid_reg;
assign available = available_reg;
assign valid = valid_reg;

reg [ITER_WIDTH-1:0] src_it_reg;
reg [ITER_WIDTH-1:0] dest_it_reg;
reg [1:0]            dest_st_reg;

reg [STEP_RANGE*ITER_WIDTH-1:0] fl_it_in_reg;
reg [STEP_RANGE*ITER_WIDTH-1:0] nr_it_in_reg;

reg [ITER_WIDTH-1:0] e_src_it_reg, e_dest_it_reg;


// Checker enable signal generator
wire [STEP_RANGE-1:0] fl_enable_out_w, nr_enable_out_w;

LeadingOneDetector #(
    .OUT_WIDTH(STEP_RANGE)
) fl_lod_unit (
    .in_w(fl_current_enables),
    .out_w(fl_enable_out_w)
);

LeadingOneDetector #(
    .OUT_WIDTH(STEP_RANGE)
) nr_lod_unit (
    .in_w(nr_current_enables),
    .out_w(nr_enable_out_w)
);


// Value extractor
wire fl_it_valid, nr_it_valid;
wire [ITER_WIDTH-1:0] fl_it_target, nr_it_target;

ValueExtractor #(
    .ELEM_NUM(STEP_RANGE),
    .ELEM_SIZ(ITER_WIDTH)
) fl_ve_unit (
    .in_w(fl_it_buffer),
    .ctrl(fl_enable_out_w),
    .valid(fl_it_valid)
    .out_w(fl_it_target)
);

ValueExtractor #(
    .ELEM_NUM(STEP_RANGE),
    .ELEM_SIZ(ITER_WIDTH)
) nr_ve_unit (
    .in_w(nr_it_buffer),
    .ctrl(nr_enable_out_w),
    .valid(nr_it_valid)
    .out_w(nr_it_target)
);


// Main operation
integer i;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        for (i = 0; i < STEP_RANGE; i = i + 1) begin
            fl_buffer[i] <= 0;
        end

        fl_current_enables <= 0;
        fl_buffer <= 0;
        fl_buff_empty_flag <= 0

        nr_it_buffer <= 0;
        nr_current_enables <= 0;
        nr_buffer <= 0;

        valid_reg <= 0;
        available_reg <= 0;

        src_it_reg <= 0;
        dest_it_reg <= 0;
        dest_st_reg <= 0;

        fl_it_in_reg <= 0;
        nr_it_in_reg <= 0;

        e_src_it_reg <= 0;
        e_dest_it_reg <= 0;
    end

    else if (mode == FLC_IDLE) begin
        for (integer i = 0; i < STEP_RANGE; i = i + 1) begin
            fl_buffer[i] <= 0;
        end

        fl_current_enables <= 0;
        fl_buffer <= 0;
        fl_buff_empty_flag <= 0;

        nr_it_buffer <= 0;
        nr_current_enables <= 0;
        nr_buffer <= 0;

        valid_reg <= 0;
        available_reg <= 0;

        src_it_reg <= 0;
        dest_it_reg <= 0;
        dest_st_reg <= 0;

        fl_it_in_reg <= 0;
        nr_it_in_reg <= 0;

        e_src_it_reg <= 0;
        e_dest_it_reg <= 0;
    end

    else if (mode == FLC_RDY) begin
        available_reg <= 1;
        fl_buff_empty_flag <= 1;
    end

    else if (mode == FLC_ENABLE) begin
        available_reg <= 0;

        fl_it_buffer <= fl_it_in;
        nr_it_buffer <= nr_it_in;

        fl_current_enables <= fl_enable_ch;
        nr_current_enables <= nr_enable_ch;

        fl_it_in_reg <= fl_it_in;
        nr_it_in_reg <= nr_it_in;
    end

    else if (mode == FLC_FL_SET) begin
        if (fl_it_valid) begin
            fl_buffer[fl_w_ptr] <= fl_it_target;
            fl_w_ptr <= fl_w_ptr_nxt;
        end

        if (nr_it_valid) begin
            if (fl_buffer[fl_r_ptr][ITER_WIDTH-1:DIST_WIDTH] < nr_it_target[ITER_WIDTH-1:DIST_WIDTH]) begin
                e_src_it_reg <= fl_buffer[fl_r_ptr];
                e_dest_it_reg <= nr_it_target;
                fl_r_ptr <= fl_r_ptr + 1;
                valid <= 1;
            end else begin
                valid <= 0;
            end
        end
    end

    else if (mode == FLC_WRITE) begin
        if (write_fin) begin
            valid <= 0;
        end
    end
end


// State trainsition
wire [3:0] next, next_idle, next_rdy, next_enable, next_fl_set, next_write;

assign next_idle   =                              FLC_RDY;
assign next_rdy    = enable_in                  ? FLC_ENABLE : FLC_RDY;
assign next_enable = !enable_in                 ? FLC_FL_SET;
assign next_fl_set = valid                      ? FLC_WRITE  :
                     fl_it_valid || nr_it_valid ? FLC_FL_SET : FLC_RDY;
assign next_write  = write_fin                  ? FLC_FL_SET : FLC_WRITE;

assign next = (mode == FLC_IDLE)   ? next_idle   :
              (mode == FLC_ENABLE) ? next_enable :
              (mode == FLC_FL_SET) ? next_fl_set :
              (mode == FLC_WRITE)  ? next_write  :
                                     FLC_IDLE;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        mode <= FLC_IDLE;
    end else begin
        mode <= next;
    end
end
    
endmodule


module LeadingOneDetector #(
    parameter OUT_WIDTH = 128
) (
    input  [OUT_WIDTH-1:0] in_w,
    output [OUT_WIDTH-1:0] out_w
);

assign out_w[0] = in_w[0];

genvar w_it;

generate
    for (w_it = 1; w_it < OUT_WIDTH; w_it = w_it + 1) begin
        assign out_w[w_it] <= (~|in_w[w_it-1:0]) & in_w[w_it];
    end
endgenerate

endmodule


module ValueExtractor #(
    parameter ELEM_NUM = 128,
    parameter ELEM_SIZ = 9
) (
    input  [ELEM_NUM*ELEM_SIZ-1:0] in_w,
    input  [ELEM_NUM-1:0]          ctrl,

    output valid,

    output [ELEM_SIZ-1:0]          out_w
);

reg [ELEM_SIZ-1:0] out_w_reg;

assign valid = |ctrl;
assign out_w = out_w_reg;

always @(in_w, out_w, ctrl) begin
    for (integer i = 0; i < ELEM_NUM; i = i+1) begin
        out_w_reg = ctrl[i] ? in_w : 0;
    end
end

endmodule