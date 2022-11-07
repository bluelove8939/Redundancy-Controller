`include "prefix_sum.v"
`include "bubble_collapse_shifter.v"

module ZVCompressor128 #(
    parameter WORD_WIDTH    = 8,
    parameter DIST_WIDTH    = 7,
    parameter MAX_LIFM_RSIZ = 4    // maximum row size of LIFM
) (
    input clk,
    input reset_n,
    
    input [128*WORD_WIDTH-1:0]               lifm_line,
    input [128*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_line,

    output [128*WORD_WIDTH-1:0]               lifm_comp,
    output [128*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_comp
);

// Pipeline1: Generate zero mask and bubble index with prefix adder
wire [127:0] mask;
wire [1023:0] psum;

reg [128*WORD_WIDTH-1:0]               lifm_pipe1;  // pipeline registers: LOWERED IFM
reg [128*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_pipe1;    // pipeline registers: MAPPING TABLE

reg [127:0]  mask_pipe1;  // pipeline regesters: MASK
reg [1023:0] psum_pipe1;  // pipeline registers: PREFIX SUM

LFPrefixSum128 padder(.mask(mask), .psum(psum));

genvar line_idx;
generate
    for (line_idx = 0; line_idx < 128; line_idx = line_idx+1) begin: MASK_GEN
        assign mask[line_idx] = (mt_line[DIST_WIDTH*MAX_LIFM_RSIZ*line_idx+:DIST_WIDTH*MAX_LIFM_RSIZ] == 0);
    end
endgenerate

// Pipeline2: Bubble-collapsing Shifter
wire [128*WORD_WIDTH-1:0]               lifm_comp_wo;
wire [128*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_comp_wo;

reg [128*WORD_WIDTH-1:0]               lifm_pipe2;  // pipeline registers: LOWERED IFM
reg [128*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_pipe2;    // pipeline registers: MAPPING TABLE

BCShifter128 #(
    .WORD_WIDTH(WORD_WIDTH), .PSUM_WIDTH(128), .DIST_WIDTH(DIST_WIDTH), .MAX_LIFM_RSIZ(MAX_LIFM_RSIZ)
) bc_shift(
    .mask(mask_pipe1), .psum(psum_pipe1), .lifm_line(lifm_pipe1), .mt_line(mt_pipe1),
    .lifm_comp(lifm_comp_wo), .mt_comp(mt_comp_wo)
);

// Synchronize with clock
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        lifm_pipe1 <= 0;
        mt_pipe1 <= 0;
        mask_pipe1 <= 0;
        psum_pipe1 <= 0;
        
        lifm_pipe2 <= 0;
        mt_pipe2 <= 0;
    end

    else begin
        // Pipeline 1
        lifm_pipe1 <= lifm_line;
        mt_pipe1 <= mt_line;
        mask_pipe1 <= mask;
        psum_pipe1 <= psum;
        
        // Pipeline 2
        lifm_pipe2 <= lifm_comp_wo;
        mt_pipe2 <= mt_comp_wo;
    end
end

assign lifm_comp = lifm_pipe2;
assign mt_comp = mt_pipe2;
    
endmodule