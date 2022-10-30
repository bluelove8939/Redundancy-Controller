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


module LFPrefixAdder32 (  // Ladner-Fischer adder
    input [31:0] mask,

    output [1023:0] psum
);

// Stage 1
wire [1:0] st1_ps0, st1_ps1, st1_ps2, st1_ps3, st1_ps4, st1_ps5, 
           st1_ps6, st1_ps7, st1_ps8, st1_ps9, st1_ps10, st1_ps11, 
           st1_ps12, st1_ps13, st1_ps14, st1_ps15;

PAdd st1_pa0(a.(mask[0]),  .b(mask[1]),  st1_ps0);
PAdd st1_pa0(a.(mask[2]),  .b(mask[3]),  st1_ps1);
PAdd st1_pa0(a.(mask[4]),  .b(mask[5]),  st1_ps2);
PAdd st1_pa0(a.(mask[6]),  .b(mask[7]),  st1_ps3);
PAdd st1_pa0(a.(mask[8]),  .b(mask[9]),  st1_ps4);
PAdd st1_pa0(a.(mask[10]), .b(mask[11]), st1_ps5);
PAdd st1_pa0(a.(mask[12]), .b(mask[13]), st1_ps6);
PAdd st1_pa0(a.(mask[14]), .b(mask[15]), st1_ps7);
PAdd st1_pa0(a.(mask[16]), .b(mask[17]), st1_ps8);
PAdd st1_pa0(a.(mask[18]), .b(mask[19]), st1_ps9);
PAdd st1_pa0(a.(mask[20]), .b(mask[21]), st1_ps10);
PAdd st1_pa0(a.(mask[22]), .b(mask[23]), st1_ps11);
PAdd st1_pa0(a.(mask[24]), .b(mask[25]), st1_ps12);
PAdd st1_pa0(a.(mask[26]), .b(mask[27]), st1_ps13);
PAdd st1_pa0(a.(mask[28]), .b(mask[29]), st1_ps14);
PAdd st1_pa0(a.(mask[30]), .b(mask[31]), st1_ps15);

// Stage 2
wire [1:0] st1_ps0,  st1_ps1,  st1_ps2,  st1_ps3, st1_ps4,  st1_ps5, 
           st1_ps6,  st1_ps7,  st1_ps8,  st1_ps9, st1_ps10, st1_ps11, 
           st1_ps12, st1_ps13, st1_ps14, st1_ps15;

PAdd st1_pa0(a.(mask[0]), .b(mask[1]), st1_ps0);
PAdd st1_pa0(a.(mask[2]), .b(mask[3]), st1_ps1);
PAdd st1_pa0(a.(mask[4]), .b(mask[5]), st1_ps2);
PAdd st1_pa0(a.(mask[6]), .b(mask[7]), st1_ps3);
PAdd st1_pa0(a.(mask[8]), .b(mask[9]), st1_ps4);
PAdd st1_pa0(a.(mask[10]), .b(mask[11]), st1_ps5);
PAdd st1_pa0(a.(mask[12]), .b(mask[13]), st1_ps6);
PAdd st1_pa0(a.(mask[14]), .b(mask[15]), st1_ps7);
PAdd st1_pa0(a.(mask[16]), .b(mask[17]), st1_ps8);
PAdd st1_pa0(a.(mask[18]), .b(mask[19]), st1_ps9);
PAdd st1_pa0(a.(mask[20]), .b(mask[21]), st1_ps10;
PAdd st1_pa0(a.(mask[22]), .b(mask[23]), st1_ps11);
PAdd st1_pa0(a.(mask[24]), .b(mask[25]), st1_ps12);
PAdd st1_pa0(a.(mask[26]), .b(mask[27]), st1_ps13);
PAdd st1_pa0(a.(mask[28]), .b(mask[29]), st1_ps14);
PAdd st1_pa0(a.(mask[30]), .b(mask[31]), st1_ps15);

endmodule


module PAdd #(
    parameter WORD_WIDTH = 1
) (
    input [WORD_WIDTH-1:0] a,
    input [WORD_WIDTH-1:0] b,

    output [2*WORD_WIDTH-1:0] y
);

assign y = a + b;
    
endmodule