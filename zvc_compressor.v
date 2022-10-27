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
        assign lifm_comp_arr[line_idx] = lifm_comp[WORD_WIDTH*line_idx-1:WORD_WIDTH*(line_idx-1)];
        assign mt_line[DIST_WIDTH*MAX_LIFM_RSIZ*line_idx-1:DIST_WIDTH*MAX_LIFM_RSIZ*(line_idx-1)] = mt_comp_arr[line_idx];
    end
endgenerate

// Pipeline: Generate zero bitmask and bubble index with prefix adder
wire [LINE_SIZE-1:0] bitmask;

reg [WORD_WIDTH-1:0]               lifm_pipe_a [0:LINE_SIZE-1];  // pipeline registers: LIFM
reg [DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_pipe_a   [0:LINE_SIZE-1];  // pipeline registers: MT

generate
    for (line_idx = 0; line_idx < LINE_SIZE; line_idx = line_idx+1) begin
        assign bitmask[line_idx] = (mt_line_arr[line_idx] != 0);
    end
endgenerate
    
endmodule


module PrefixAdder #(
    parameter WORD_WIDTH = 1
) (
    ports
);
    
endmodule