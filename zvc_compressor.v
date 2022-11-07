`include "prefix_adder.v"
`include "bubble_collapse_shifter.v"

module ZVCompressor #(
    parameter WORD_WIDTH    = 8,
    parameter LINE_SIZE     = 128,
    parameter DIST_WIDTH    = 7,
    parameter MAX_LIFM_RSIZ = 4    // maximum row size of LIFM
) (
    input clk,
    input reset_n,
    
    input [LINE_SIZE*WORD_WIDTH-1:0]               lifm_line,
    input [LINE_SIZE*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_line,

    output [LINE_SIZE*WORD_WIDTH-1:0]               lifm_comp,
    output [LINE_SIZE*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_comp
);

// Pipeline1: Generate zero mask and bubble index with prefix adder
wire [127:0] mask;
wire [1023:0] psum;

reg [LINE_SIZE*WORD_WIDTH-1:0]               lifm_pipe1;  // pipeline registers: LOWERED IFM
reg [LINE_SIZE*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_pipe1;    // pipeline registers: MAPPING TABLE

reg [1023:0] psum_pipe1;  // pipeline registers: PREFIX SUM

LFPrefixSum128 padder(.mask(mask), .psum(psum));

genvar line_idx;
generate
    for (line_idx = 0; line_idx < LINE_SIZE; line_idx = line_idx+1) begin
        assign mask[line_idx] = (mt_line[DIST_WIDTH*MAX_LIFM_RSIZ*line_idx+:DIST_WIDTH*MAX_LIFM_RSIZ] != 0);
    end
endgenerate

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        lifm_pipe1 <= 0;
        mt_pipe1 <= 0;
        psum_pipe1 <= 0;
    end

    else begin
        lifm_pipe1 <= lifm_line;
        mt_pipe1 <= mt_line;
        psum_pipe1 <= psum;
    end
end

// Pipeline2: Bubble-collapsing Shifter
wire [LINE_SIZE*WORD_WIDTH-1:0]               lifm_comp;
wire [LINE_SIZE*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_comp;

reg [LINE_SIZE*WORD_WIDTH-1:0]               lifm_pipe2;  // pipeline registers: LOWERED IFM
reg [LINE_SIZE*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_pipe2;    // pipeline registers: MAPPING TABLE

BCShifter128 #(.WORD_WIDTH(WORD_WIDTH), .PSUM_WIDTH(128), .DIST_WIDTH(DIST_WIDTH), .MAX_LIFM_RSIZ(MAX_LIFM_RSIZ)
) bc_shift(
    .mask(mask), .psum(psum), .lifm_line(lifm_pipe1), .mt_line(mt_pipe1),
    .lifm_comp(lifm_comp), .mt_comp(mt_comp)
);

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        lifm_pipe2 <= 0;
        mt_pipe2 <= 0;
    end

    else begin
        lifm_pipe2 <= lifm_comp;
        mt_pipe2 <= mt_comp;
    end
end

assign lifm_comp = lifm_pipe2;
assign mt_comp = mt_pipe2;
    
endmodule