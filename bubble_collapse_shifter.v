module BCShifter128 #(  // Bubble-Collapsing Shifter
    parameter WORD_WIDTH    = 8,
    parameter DIST_WIDTH    = 7,
    parameter MAX_LIFM_RSIZ = 3
) (
    input [1023:0] psum,
    input [127:0]  mask,

    input [128*WORD_WIDTH-1:0]               lifm_line,
    input [128*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_line,

    output [128*WORD_WIDTH-1:0]               lifm_comp,
    output [128*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_comp
);

genvar line_idx;  // line index iterator

// Generate array connected with input and output ports
wire [WORD_WIDTH-1:0]               lifm_line_arr [0:127];
wire [DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_line_arr   [0:127];

reg [WORD_WIDTH-1:0]               lifm_comp_arr [0:127];
reg [DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_comp_arr   [0:127];

generate
    for (line_idx = 0; line_idx < 128; line_idx = line_idx+1) begin
        assign lifm_line_arr[line_idx] = lifm_line[WORD_WIDTH*line_idx+:WORD_WIDTH];
        assign mt_line_arr[line_idx] = mt_line[DIST_WIDTH*MAX_LIFM_RSIZ*line_idx+:DIST_WIDTH*MAX_LIFM_RSIZ];
    end
endgenerate

// Shifter 1
wire [WORD_WIDTH-1:0] i_vec_lifm_l1;
wire [WORD_WIDTH-1:0] o_vec_lifm_l1;
wire [DIST_WIDTH*MAX_LIFM_RSIZ-1:0] i_vec_mt_l1;
wire [DIST_WIDTH*MAX_LIFM_RSIZ-1:0] o_vec_mt_l1;
wire stride_l0;
assign i_vec_lifm_l0 = {lifm_line_arr[1], WORD_WIDTH'b0};
assign i_vec_mt_l0 = {mt_line_arr[1], WORD_WIDTH'b0};
assign stride_l0 = psum_arr[1][0];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm (
    .i_vec(i_vec_lifm_l1), .stride(stride_l1), .o_vec(o_vec_lifm_l1)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(line_idx+1), .NUMEL_LOG($clog2(line_idx+1))
) vs_mt (
    .i_vec(i_vec_mt_l1), .stride(stride_l1), .o_vec(o_vec_mt_l1)
);

// Shifter 2
wire [2*WORD_WIDTH-1:0] i_vec_lifm_l2;
wire [2*WORD_WIDTH-1:0] o_vec_lifm_l2;
wire [2*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] i_vec_mt_l2;
wire [2*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] o_vec_mt_l2;
wire stride_l0;
assign i_vec_lifm_l0 = {lifm_line_arr[1], WORD_WIDTH'b0};
assign i_vec_mt_l0 = {mt_line_arr[1], WORD_WIDTH'b0};
assign stride_l0 = psum_arr[1][0];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm (
    .i_vec(i_vec_lifm_l1), .stride(stride_l1), .o_vec(o_vec_lifm_l1)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(line_idx+1), .NUMEL_LOG($clog2(line_idx+1))
) vs_mt (
    .i_vec(i_vec_mt_l1), .stride(stride_l1), .o_vec(o_vec_mt_l1)
);
    
endmodule


module VShifter #(
    parameter WORD_WIDTH = 8,
    parameter NUMEL      = 128,
    parameter NUMEL_LOG  = 7
) (
    input [WORD_WIDTH*NUMEL-1:0] i_vec,
    input [NUMEL_LOG-1:0]        stride,

    output [WORD_WIDTH*NUMEL-1:0] o_vec
);

assign o_vec = i_vec >> (stride * WORD_WIDTH);
    
endmodule