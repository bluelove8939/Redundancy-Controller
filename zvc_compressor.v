`include "prefix_adder.v"

module ZVCompressor #(
    parameter WORD_WIDTH    = 8,
    parameter LINE_SIZE     = 32,
    parameter DIST_WIDTH    = 7,
    parameter MAX_LIFM_RSIZ = 3    // maximum row size of LIFM
) (
    input clk,
    input reset_n,
    
    input [LINE_SIZE*WORD_WIDTH-1:0]               lifm_line,
    input [LINE_SIZE*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_line,

    output [LINE_SIZE*WORD_WIDTH-1:0]               lifm_comp,
    output [LINE_SIZE*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_comp
);

genvar line_idx;  // line index iterator

// Generate array connected with input and output ports
wire [WORD_WIDTH-1:0]               lifm_line_arr [0:LINE_SIZE-1];
wire [DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_line_arr   [0:LINE_SIZE-1];

reg [WORD_WIDTH-1:0]               lifm_comp_arr [0:LINE_SIZE-1];
reg [DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_comp_arr   [0:LINE_SIZE-1];

generate
    for (line_idx = 0; line_idx < LINE_SIZE; line_idx = line_idx+1) begin
        assign lifm_line_arr[line_idx] = lifm_line[WORD_WIDTH*line_idx+:WORD_WIDTH];
        assign mt_line_arr[line_idx] = mt_line[DIST_WIDTH*MAX_LIFM_RSIZ*line_idx+:DIST_WIDTH*MAX_LIFM_RSIZ];
    end
endgenerate

// Pipeline1: Generate zero mask and bubble index with prefix adder
wire [LINE_SIZE-1:0] mask;
wire [LINE_SIZE*LINE_SIZE-1:0] psum;
wire [LINE_SIZE-1:0] psum_arr [0:LINE_SIZE-1];

reg [WORD_WIDTH-1:0]               lifm_pipe1 [0:LINE_SIZE-1];  // pipeline registers: LOWERED IFM
reg [DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_pipe1   [0:LINE_SIZE-1];  // pipeline registers: MAPPING TABLE
reg [LINE_SIZE-1:0]                psum_pipe1 [0:LINE_SIZE-1];  // pipeline registers: PREFIX SUM

LFPrefixAdder32 padder(.mask(mask), .psum(psum));

generate
    for (line_idx = 0; line_idx < LINE_SIZE; line_idx = line_idx+1) begin
        assign mask[line_idx] = (mt_line_arr[line_idx] != 0);
        assign psum_arr[line_idx] = psum[LINE_SIZE*line_idx+:LINE_SIZE];
    end
endgenerate

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        for (integer lidx = 0; lidx < LINE_SIZE; lidx = lidx+1) begin
            lifm_pipe1[lidx] <= 0;
            mt_pipe1[lidx] <= 0;
            psum_pipe1[lidx] <= 0;
        end
    end

    else begin
        for (integer lidx = 0; lidx < LINE_SIZE; lidx = lidx+1) begin
            lifm_pipe1[lidx] <= lifm_line_arr[lidx];
            mt_pipe1[lidx] <= mt_line_arr[lidx];
            psum_pipe1[lidx] <= psum_arr[lidx];
        end
    end
end

// Pipeline2: Bubble-collapsing Shifter

    
endmodule


