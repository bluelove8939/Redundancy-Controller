`include "comb_divider.v"
`include "comb_multiplier.v"

module DistanceCalculator #(
    parameter WORD_WIDTH    = 8,
    parameter PSUM_WIDTH    = 7,
    parameter DIST_WIDTH    = 7,
    parameter MAX_LIFM_RSIZ = 4
) (
    input [WORD_WIDTH-1:0] idx1,  // smaller index of redundant operand pair
    input [WORD_WIDTH-1:0] idx2,  // larger index of redundant operand pair

    input [WORD_WIDTH-1:0] ld,  // lowered distance
    input [WORD_WIDTH-1:0] ow,  // output width
    input [WORD_WIDTH-1:0] fw,  // filter(kernel) width
    input [WORD_WIDTH-1:0] st,  // stride amount

    output valid,  // indicates whether the value is valid

    output [DIST_WIDTH-1:0] dr,
);

// Stage: Calculating dv = (i2 % FW) - (i1 % FW)
    
endmodule