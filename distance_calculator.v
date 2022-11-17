`include "comb_divider.v"
`include "comb_multiplier.v"

module DistanceCalculator #(
    parameter WORD_WIDTH    = 8,
    parameter PSUM_WIDTH    = 7,
    parameter DIST_WIDTH    = 7,
    parameter MAX_LIFM_RSIZ = 4
) (
    input [WORD_WIDTH-1:0] idx1,
    input [WORD_WIDTH-1:0] idx2,

    input [WORD_WIDTH-1:0] ow,  // output width
    input [WORD_WIDTH-1:0] kw,  // kernel width
    input [WORD_WIDTH-1:0] st,  // stride amount

    output []
);
    
endmodule