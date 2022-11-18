module RedundancyController #(
    parameter WORD_WIDTH = 8,    // bitwidth of a word (fixed to 8bit)
    parameter DIST_WIDTH = 7,    // bitwidth of distances
    parameter MAX_R_SIZE = 4,    // size of each row of lifm and mapping table
    parameter MAX_C_SIZE = 128,  // size of each column of lifm and mapping table
    parameter MPTE_WIDTH = DIST_WIDTH * MAX_R_SIZE  // width of mapping table entry
) (
    input clk,      // global clock signal (positive-edge triggered)
    input reset_n,  // global asynchronous reset signal (negative triggered)

    input [WORD_WIDTH-1:0] idx,  // index of weight value (lowered filter)

    input [MAX_R_SIZE*WORD_WIDTH-1:0] lifm_line,  // un-processed lifm column

    output [MAX_R_SIZE*WORD_WIDTH-1:0] lifm_comp,  // vector of compressed lifm
    output [MAX_R_SIZE*MPTE_WIDTH-1:0] mt_comp     // vector mapping table entries
);



endmodule