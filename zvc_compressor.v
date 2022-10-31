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

// Pipeline1: Generate zero mask and bubble index with prefix adder
wire [31:0] mask;
wire [191:0] psum;

reg [LINE_SIZE*WORD_WIDTH-1:0]               lifm_pipe1;  // pipeline registers: LOWERED IFM
reg [LINE_SIZE*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_pipe1;    // pipeline registers: MAPPING TABLE

reg [191:0] psum_pipe1;  // pipeline registers: PREFIX SUM

LFPrefixAdder32 padder(.mask(mask), .psum(psum));

generate
    for (line_idx = 0; line_idx < LINE_SIZE; line_idx = line_idx+1) begin
        assign mask[line_idx] = (mt_line_arr[line_idx] != 0);
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

    
endmodule


