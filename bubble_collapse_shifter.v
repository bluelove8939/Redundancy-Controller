module BCShifter32 #(  // Bubble-Collapsing Shifter
    parameter WORD_WIDTH    = 8,
    parameter DIST_WIDTH    = 7,
    parameter MAX_LIFM_RSIZ = 3
) (
    input [1023:0] psum,
    input [31:0]   mask,

    input [32*WORD_WIDTH-1:0]               lifm_line,
    input [32*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_line,

    output [32*WORD_WIDTH-1:0]               lifm_comp,
    output [23*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_comp
);

genvar line_idx;  // line index iterator

// Generate array connected with input and output ports
wire [WORD_WIDTH-1:0]               lifm_line_arr [0:31];
wire [DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_line_arr   [0:31];

reg [WORD_WIDTH-1:0]               lifm_comp_arr [0:31];
reg [DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_comp_arr   [0:31];

generate
    for (line_idx = 0; line_idx < 32; line_idx = line_idx+1) begin
        assign lifm_line_arr[line_idx] = lifm_line[WORD_WIDTH*line_idx+:WORD_WIDTH];
        assign mt_line_arr[line_idx] = mt_line[DIST_WIDTH*MAX_LIFM_RSIZ*line_idx+:DIST_WIDTH*MAX_LIFM_RSIZ];
    end
endgenerate


    
endmodule