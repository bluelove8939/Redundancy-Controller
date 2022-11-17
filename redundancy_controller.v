module RedundancyController #(
    parameter WORD_WIDTH    = 8,
    parameter PSUM_WIDTH    = 7,
    parameter DIST_WIDTH    = 7,
    parameter MAX_LIFM_RSIZ = 4
) (
    input clk,
    input reset_n,

    input [DIST_WIDTH-1:0]     dist,
    input [128*WORD_WIDTH-1:0] lifm_line,

    output [128*WORD_WIDTH-1:0]               lifm_comp,
    output [128*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_comp
);



endmodule