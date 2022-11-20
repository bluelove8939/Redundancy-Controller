
`include "distance_calculator.v"
`include "muxes.v"


module RedundancyController #(
    parameter WORD_WIDTH = 8,    // bitwidth of a word (fixed to 8bit)
    parameter DIST_WIDTH = 4,    // bitwidth of distances
    parameter MAX_R_SIZE = 4,    // size of each row of lifm and mapping table
    parameter MAX_C_SIZE = 16,   // size of each column of lifm and mapping table
    parameter MPTE_WIDTH = DIST_WIDTH * MAX_R_SIZE  // width of mapping table entry
) (
    input clk,      // global clock signal (positive-edge triggered)
    input reset_n,  // global asynchronous reset signal (negative triggered)

    input [WORD_WIDTH-1:0] idx,  // index of weight value (lowered filter)
    input [WORD_WIDTH-1:0] ow,   // shapes: output width (OW)
    input [WORD_WIDTH-1:0] fw,   // shapes: filter(kernel) width (FW)
    input [WORD_WIDTH-1:0] st,   // shapes: stride amount (S)

    input [MAX_R_SIZE*WORD_WIDTH-1:0] lifm_line,  // un-processed lifm column

    output [MAX_R_SIZE*WORD_WIDTH-1:0] lifm_comp,  // vector of compressed lifm
    output [MAX_R_SIZE*MPTE_WIDTH-1:0] mpte_comp   // vector mapping table entries
);

// Buffers
reg [WORD_WIDTH-1:0] idx1, idx2;
reg [WORD_WIDTH*MAX_C_SIZE-1:0] lifm_buff [0:1];
reg [MPTE_WIDTH*MAX_C_SIZE-1:0] mpte_buff [0:1];
reg [WORD_WIDTH*MAX_C_SIZE-1:0] lifm_comp_reg;
reg [MPTE_WIDTH*MAX_C_SIZE-1:0] mpte_comp_reg;

assign lifm_comp = lifm_comp_reg;
assign mpte_comp = mpte_comp_reg;

// Instantiation of distance calculator
wire valid;
wire [DIST_WIDTH-1:0] dr;

DistanceCalculator #(
    .WORD_WIDTH(WORD_WIDTH), .DIST_WIDTH(DIST_WIDTH), .MAX_C_SIZE(MAX_C_SIZE)
) dist_calc (
    .idx1(idx1), .idx2(idx2), 
    .ow(ow), .fw(fw), .st(st),
    .valid(valid), .dr(dr)
);

// Generating MPTE Stage 1: Status flags
wire [MAX_C_SIZE-1:0] oor_flag,       // out of range flag
                      red_flag_prev,  // redundancy flag for previous column (0)
                      red_flag_curr;  // redundancy flag for current column (1)
wire [DIST_WIDTH-1:0] cpd_index  [0:MAX_C_SIZE-1],  // copy index
                      rev_index  [0:MAX_C_SIZE-1];  // reversed copy index
wire [WORD_WIDTH-1:0] red_values [0:MAX_C_SIZE-1];  // redundant values 


assign oor_flag[0]      = (valid && (dr <= 0)) ? 1'b1 : 1'b0;
assign red_flag_prev[0] = (lifm_buff[0][WORD_WIDTH*1-1:WORD_WIDTH*0] == red_values[0])   ? 1'b1 : 1'b0;
assign red_flag_curr[0] = (lifm_buff[1][WORD_WIDTH*1-1:WORD_WIDTH*0] == lifm_buff[0][WORD_WIDTH*rev_index[0]+:WORD_WIDTH]) ? 1'b1 : 1'b0;
assign cpd_index[0] = (0 <= dr) ? (0 - dr) : 0;
assign rev_index[0] = (0 < (MAX_C_SIZE - dr)) ? (0 + dr) : 0;

assign red_values[0] = lifm_buff[0][WORD_WIDTH*16-1:WORD_WIDTH*15];

assign oor_flag[1]      = (valid && (dr <= 1)) ? 1'b1 : 1'b0;
assign red_flag_prev[1] = (lifm_buff[0][WORD_WIDTH*2-1:WORD_WIDTH*1] == red_values[1])   ? 1'b1 : 1'b0;
assign red_flag_curr[1] = (lifm_buff[1][WORD_WIDTH*2-1:WORD_WIDTH*1] == lifm_buff[0][WORD_WIDTH*rev_index[1]+:WORD_WIDTH]) ? 1'b1 : 1'b0;
assign cpd_index[1] = (1 <= dr) ? (1 - dr) : 0;
assign rev_index[1] = (1 < (MAX_C_SIZE - dr)) ? (1 + dr) : 0;

assign red_values[1] = lifm_buff[0][WORD_WIDTH*16-1:WORD_WIDTH*15];

assign oor_flag[2]      = (valid && (dr <= 2)) ? 1'b1 : 1'b0;
assign red_flag_prev[2] = (lifm_buff[0][WORD_WIDTH*3-1:WORD_WIDTH*2] == red_values[2])   ? 1'b1 : 1'b0;
assign red_flag_curr[2] = (lifm_buff[1][WORD_WIDTH*3-1:WORD_WIDTH*2] == lifm_buff[0][WORD_WIDTH*rev_index[2]+:WORD_WIDTH]) ? 1'b1 : 1'b0;
assign cpd_index[2] = (2 <= dr) ? (2 - dr) : 0;
assign rev_index[2] = (2 < (MAX_C_SIZE - dr)) ? (2 + dr) : 0;

MUX2to1 #(
    .WORD_WIDTH(WORD_WIDTH)
) mux_unit_redundant_2to1_lv2 (
    .in_w0(lifm_buff[0][WORD_WIDTH*15-1:WORD_WIDTH*14]), .in_w1(lifm_buff[0][WORD_WIDTH*16-1:WORD_WIDTH*15]),
    .sel(cpd_index[2][0]),
    .out_w(red_values[2])
);

assign oor_flag[3]      = (valid && (dr <= 3)) ? 1'b1 : 1'b0;
assign red_flag_prev[3] = (lifm_buff[0][WORD_WIDTH*4-1:WORD_WIDTH*3] == red_values[3])   ? 1'b1 : 1'b0;
assign red_flag_curr[3] = (lifm_buff[1][WORD_WIDTH*4-1:WORD_WIDTH*3] == lifm_buff[0][WORD_WIDTH*rev_index[3]+:WORD_WIDTH]) ? 1'b1 : 1'b0;
assign cpd_index[3] = (3 <= dr) ? (3 - dr) : 0;
assign rev_index[3] = (3 < (MAX_C_SIZE - dr)) ? (3 + dr) : 0;

MUX4to1 #(
    .WORD_WIDTH(WORD_WIDTH)
) mux_unit_redundant_4to1_lv3 (
    .in_w0(lifm_buff[0][WORD_WIDTH*13-1:WORD_WIDTH*12]), .in_w1(lifm_buff[0][WORD_WIDTH*14-1:WORD_WIDTH*13]), 
    .in_w2(lifm_buff[0][WORD_WIDTH*15-1:WORD_WIDTH*14]), .in_w3(lifm_buff[0][WORD_WIDTH*16-1:WORD_WIDTH*15]),

    .sel(cpd_index[3][1:0]),

    .out_w(red_values[3])
);

assign oor_flag[4]      = (valid && (dr <= 4)) ? 1'b1 : 1'b0;
assign red_flag_prev[4] = (lifm_buff[0][WORD_WIDTH*5-1:WORD_WIDTH*4] == red_values[4])   ? 1'b1 : 1'b0;
assign red_flag_curr[4] = (lifm_buff[1][WORD_WIDTH*5-1:WORD_WIDTH*4] == lifm_buff[0][WORD_WIDTH*rev_index[4]+:WORD_WIDTH]) ? 1'b1 : 1'b0;
assign cpd_index[4] = (4 <= dr) ? (4 - dr) : 0;
assign rev_index[4] = (4 < (MAX_C_SIZE - dr)) ? (4 + dr) : 0;

MUX4to1 #(
    .WORD_WIDTH(WORD_WIDTH)
) mux_unit_redundant_4to1_lv4 (
    .in_w0(lifm_buff[0][WORD_WIDTH*13-1:WORD_WIDTH*12]), .in_w1(lifm_buff[0][WORD_WIDTH*14-1:WORD_WIDTH*13]), 
    .in_w2(lifm_buff[0][WORD_WIDTH*15-1:WORD_WIDTH*14]), .in_w3(lifm_buff[0][WORD_WIDTH*16-1:WORD_WIDTH*15]),

    .sel(cpd_index[4][1:0]),

    .out_w(red_values[4])
);

assign oor_flag[5]      = (valid && (dr <= 5)) ? 1'b1 : 1'b0;
assign red_flag_prev[5] = (lifm_buff[0][WORD_WIDTH*6-1:WORD_WIDTH*5] == red_values[5])   ? 1'b1 : 1'b0;
assign red_flag_curr[5] = (lifm_buff[1][WORD_WIDTH*6-1:WORD_WIDTH*5] == lifm_buff[0][WORD_WIDTH*rev_index[5]+:WORD_WIDTH]) ? 1'b1 : 1'b0;
assign cpd_index[5] = (5 <= dr) ? (5 - dr) : 0;
assign rev_index[5] = (5 < (MAX_C_SIZE - dr)) ? (5 + dr) : 0;

MUX8to1 #(
    .WORD_WIDTH(WORD_WIDTH)
) mux_unit_redundant_8to1_lv5 (
    .in_w0(lifm_buff[0][WORD_WIDTH*9-1:WORD_WIDTH*8]), .in_w1(lifm_buff[0][WORD_WIDTH*10-1:WORD_WIDTH*9]), 
    .in_w2(lifm_buff[0][WORD_WIDTH*11-1:WORD_WIDTH*10]), .in_w3(lifm_buff[0][WORD_WIDTH*12-1:WORD_WIDTH*11]), 
    .in_w4(lifm_buff[0][WORD_WIDTH*13-1:WORD_WIDTH*12]), .in_w5(lifm_buff[0][WORD_WIDTH*14-1:WORD_WIDTH*13]), 
    .in_w6(lifm_buff[0][WORD_WIDTH*15-1:WORD_WIDTH*14]), .in_w7(lifm_buff[0][WORD_WIDTH*16-1:WORD_WIDTH*15]),

    .sel(cpd_index[5][2:0]),

    .out_w(red_values[5])
);

assign oor_flag[6]      = (valid && (dr <= 6)) ? 1'b1 : 1'b0;
assign red_flag_prev[6] = (lifm_buff[0][WORD_WIDTH*7-1:WORD_WIDTH*6] == red_values[6])   ? 1'b1 : 1'b0;
assign red_flag_curr[6] = (lifm_buff[1][WORD_WIDTH*7-1:WORD_WIDTH*6] == lifm_buff[0][WORD_WIDTH*rev_index[6]+:WORD_WIDTH]) ? 1'b1 : 1'b0;
assign cpd_index[6] = (6 <= dr) ? (6 - dr) : 0;
assign rev_index[6] = (6 < (MAX_C_SIZE - dr)) ? (6 + dr) : 0;

MUX8to1 #(
    .WORD_WIDTH(WORD_WIDTH)
) mux_unit_redundant_8to1_lv6 (
    .in_w0(lifm_buff[0][WORD_WIDTH*9-1:WORD_WIDTH*8]), .in_w1(lifm_buff[0][WORD_WIDTH*10-1:WORD_WIDTH*9]), 
    .in_w2(lifm_buff[0][WORD_WIDTH*11-1:WORD_WIDTH*10]), .in_w3(lifm_buff[0][WORD_WIDTH*12-1:WORD_WIDTH*11]), 
    .in_w4(lifm_buff[0][WORD_WIDTH*13-1:WORD_WIDTH*12]), .in_w5(lifm_buff[0][WORD_WIDTH*14-1:WORD_WIDTH*13]), 
    .in_w6(lifm_buff[0][WORD_WIDTH*15-1:WORD_WIDTH*14]), .in_w7(lifm_buff[0][WORD_WIDTH*16-1:WORD_WIDTH*15]),

    .sel(cpd_index[6][2:0]),

    .out_w(red_values[6])
);

assign oor_flag[7]      = (valid && (dr <= 7)) ? 1'b1 : 1'b0;
assign red_flag_prev[7] = (lifm_buff[0][WORD_WIDTH*8-1:WORD_WIDTH*7] == red_values[7])   ? 1'b1 : 1'b0;
assign red_flag_curr[7] = (lifm_buff[1][WORD_WIDTH*8-1:WORD_WIDTH*7] == lifm_buff[0][WORD_WIDTH*rev_index[7]+:WORD_WIDTH]) ? 1'b1 : 1'b0;
assign cpd_index[7] = (7 <= dr) ? (7 - dr) : 0;
assign rev_index[7] = (7 < (MAX_C_SIZE - dr)) ? (7 + dr) : 0;

MUX8to1 #(
    .WORD_WIDTH(WORD_WIDTH)
) mux_unit_redundant_8to1_lv7 (
    .in_w0(lifm_buff[0][WORD_WIDTH*9-1:WORD_WIDTH*8]), .in_w1(lifm_buff[0][WORD_WIDTH*10-1:WORD_WIDTH*9]), 
    .in_w2(lifm_buff[0][WORD_WIDTH*11-1:WORD_WIDTH*10]), .in_w3(lifm_buff[0][WORD_WIDTH*12-1:WORD_WIDTH*11]), 
    .in_w4(lifm_buff[0][WORD_WIDTH*13-1:WORD_WIDTH*12]), .in_w5(lifm_buff[0][WORD_WIDTH*14-1:WORD_WIDTH*13]), 
    .in_w6(lifm_buff[0][WORD_WIDTH*15-1:WORD_WIDTH*14]), .in_w7(lifm_buff[0][WORD_WIDTH*16-1:WORD_WIDTH*15]),

    .sel(cpd_index[7][2:0]),

    .out_w(red_values[7])
);

assign oor_flag[8]      = (valid && (dr <= 8)) ? 1'b1 : 1'b0;
assign red_flag_prev[8] = (lifm_buff[0][WORD_WIDTH*9-1:WORD_WIDTH*8] == red_values[8])   ? 1'b1 : 1'b0;
assign red_flag_curr[8] = (lifm_buff[1][WORD_WIDTH*9-1:WORD_WIDTH*8] == lifm_buff[0][WORD_WIDTH*rev_index[8]+:WORD_WIDTH]) ? 1'b1 : 1'b0;
assign cpd_index[8] = (8 <= dr) ? (8 - dr) : 0;
assign rev_index[8] = (8 < (MAX_C_SIZE - dr)) ? (8 + dr) : 0;

MUX8to1 #(
    .WORD_WIDTH(WORD_WIDTH)
) mux_unit_redundant_8to1_lv8 (
    .in_w0(lifm_buff[0][WORD_WIDTH*9-1:WORD_WIDTH*8]), .in_w1(lifm_buff[0][WORD_WIDTH*10-1:WORD_WIDTH*9]), 
    .in_w2(lifm_buff[0][WORD_WIDTH*11-1:WORD_WIDTH*10]), .in_w3(lifm_buff[0][WORD_WIDTH*12-1:WORD_WIDTH*11]), 
    .in_w4(lifm_buff[0][WORD_WIDTH*13-1:WORD_WIDTH*12]), .in_w5(lifm_buff[0][WORD_WIDTH*14-1:WORD_WIDTH*13]), 
    .in_w6(lifm_buff[0][WORD_WIDTH*15-1:WORD_WIDTH*14]), .in_w7(lifm_buff[0][WORD_WIDTH*16-1:WORD_WIDTH*15]),

    .sel(cpd_index[8][2:0]),

    .out_w(red_values[8])
);

assign oor_flag[9]      = (valid && (dr <= 9)) ? 1'b1 : 1'b0;
assign red_flag_prev[9] = (lifm_buff[0][WORD_WIDTH*10-1:WORD_WIDTH*9] == red_values[9])   ? 1'b1 : 1'b0;
assign red_flag_curr[9] = (lifm_buff[1][WORD_WIDTH*10-1:WORD_WIDTH*9] == lifm_buff[0][WORD_WIDTH*rev_index[9]+:WORD_WIDTH]) ? 1'b1 : 1'b0;
assign cpd_index[9] = (9 <= dr) ? (9 - dr) : 0;
assign rev_index[9] = (9 < (MAX_C_SIZE - dr)) ? (9 + dr) : 0;

MUX16to1 #(
    .WORD_WIDTH(WORD_WIDTH)
) mux_unit_redundant_16to1_lv9 (
    .in_w0(lifm_buff[0][WORD_WIDTH*1-1:WORD_WIDTH*0]), .in_w1(lifm_buff[0][WORD_WIDTH*2-1:WORD_WIDTH*1]), 
    .in_w2(lifm_buff[0][WORD_WIDTH*3-1:WORD_WIDTH*2]), .in_w3(lifm_buff[0][WORD_WIDTH*4-1:WORD_WIDTH*3]), 
    .in_w4(lifm_buff[0][WORD_WIDTH*5-1:WORD_WIDTH*4]), .in_w5(lifm_buff[0][WORD_WIDTH*6-1:WORD_WIDTH*5]), 
    .in_w6(lifm_buff[0][WORD_WIDTH*7-1:WORD_WIDTH*6]), .in_w7(lifm_buff[0][WORD_WIDTH*8-1:WORD_WIDTH*7]), 
    .in_w8(lifm_buff[0][WORD_WIDTH*9-1:WORD_WIDTH*8]), .in_w9(lifm_buff[0][WORD_WIDTH*10-1:WORD_WIDTH*9]), 
    .in_w10(lifm_buff[0][WORD_WIDTH*11-1:WORD_WIDTH*10]), .in_w11(lifm_buff[0][WORD_WIDTH*12-1:WORD_WIDTH*11]), 
    .in_w12(lifm_buff[0][WORD_WIDTH*13-1:WORD_WIDTH*12]), .in_w13(lifm_buff[0][WORD_WIDTH*14-1:WORD_WIDTH*13]), 
    .in_w14(lifm_buff[0][WORD_WIDTH*15-1:WORD_WIDTH*14]), .in_w15(lifm_buff[0][WORD_WIDTH*16-1:WORD_WIDTH*15]),

    .sel(cpd_index[9][3:0]),

    .out_w(red_values[9])
);

assign oor_flag[10]      = (valid && (dr <= 10)) ? 1'b1 : 1'b0;
assign red_flag_prev[10] = (lifm_buff[0][WORD_WIDTH*11-1:WORD_WIDTH*10] == red_values[10])   ? 1'b1 : 1'b0;
assign red_flag_curr[10] = (lifm_buff[1][WORD_WIDTH*11-1:WORD_WIDTH*10] == lifm_buff[0][WORD_WIDTH*rev_index[10]+:WORD_WIDTH]) ? 1'b1 : 1'b0;
assign cpd_index[10] = (10 <= dr) ? (10 - dr) : 0;
assign rev_index[10] = (10 < (MAX_C_SIZE - dr)) ? (10 + dr) : 0;

MUX16to1 #(
    .WORD_WIDTH(WORD_WIDTH)
) mux_unit_redundant_16to1_lv10 (
    .in_w0(lifm_buff[0][WORD_WIDTH*1-1:WORD_WIDTH*0]), .in_w1(lifm_buff[0][WORD_WIDTH*2-1:WORD_WIDTH*1]), 
    .in_w2(lifm_buff[0][WORD_WIDTH*3-1:WORD_WIDTH*2]), .in_w3(lifm_buff[0][WORD_WIDTH*4-1:WORD_WIDTH*3]), 
    .in_w4(lifm_buff[0][WORD_WIDTH*5-1:WORD_WIDTH*4]), .in_w5(lifm_buff[0][WORD_WIDTH*6-1:WORD_WIDTH*5]), 
    .in_w6(lifm_buff[0][WORD_WIDTH*7-1:WORD_WIDTH*6]), .in_w7(lifm_buff[0][WORD_WIDTH*8-1:WORD_WIDTH*7]), 
    .in_w8(lifm_buff[0][WORD_WIDTH*9-1:WORD_WIDTH*8]), .in_w9(lifm_buff[0][WORD_WIDTH*10-1:WORD_WIDTH*9]), 
    .in_w10(lifm_buff[0][WORD_WIDTH*11-1:WORD_WIDTH*10]), .in_w11(lifm_buff[0][WORD_WIDTH*12-1:WORD_WIDTH*11]), 
    .in_w12(lifm_buff[0][WORD_WIDTH*13-1:WORD_WIDTH*12]), .in_w13(lifm_buff[0][WORD_WIDTH*14-1:WORD_WIDTH*13]), 
    .in_w14(lifm_buff[0][WORD_WIDTH*15-1:WORD_WIDTH*14]), .in_w15(lifm_buff[0][WORD_WIDTH*16-1:WORD_WIDTH*15]),

    .sel(cpd_index[10][3:0]),

    .out_w(red_values[10])
);

assign oor_flag[11]      = (valid && (dr <= 11)) ? 1'b1 : 1'b0;
assign red_flag_prev[11] = (lifm_buff[0][WORD_WIDTH*12-1:WORD_WIDTH*11] == red_values[11])   ? 1'b1 : 1'b0;
assign red_flag_curr[11] = (lifm_buff[1][WORD_WIDTH*12-1:WORD_WIDTH*11] == lifm_buff[0][WORD_WIDTH*rev_index[11]+:WORD_WIDTH]) ? 1'b1 : 1'b0;
assign cpd_index[11] = (11 <= dr) ? (11 - dr) : 0;
assign rev_index[11] = (11 < (MAX_C_SIZE - dr)) ? (11 + dr) : 0;

MUX16to1 #(
    .WORD_WIDTH(WORD_WIDTH)
) mux_unit_redundant_16to1_lv11 (
    .in_w0(lifm_buff[0][WORD_WIDTH*1-1:WORD_WIDTH*0]), .in_w1(lifm_buff[0][WORD_WIDTH*2-1:WORD_WIDTH*1]), 
    .in_w2(lifm_buff[0][WORD_WIDTH*3-1:WORD_WIDTH*2]), .in_w3(lifm_buff[0][WORD_WIDTH*4-1:WORD_WIDTH*3]), 
    .in_w4(lifm_buff[0][WORD_WIDTH*5-1:WORD_WIDTH*4]), .in_w5(lifm_buff[0][WORD_WIDTH*6-1:WORD_WIDTH*5]), 
    .in_w6(lifm_buff[0][WORD_WIDTH*7-1:WORD_WIDTH*6]), .in_w7(lifm_buff[0][WORD_WIDTH*8-1:WORD_WIDTH*7]), 
    .in_w8(lifm_buff[0][WORD_WIDTH*9-1:WORD_WIDTH*8]), .in_w9(lifm_buff[0][WORD_WIDTH*10-1:WORD_WIDTH*9]), 
    .in_w10(lifm_buff[0][WORD_WIDTH*11-1:WORD_WIDTH*10]), .in_w11(lifm_buff[0][WORD_WIDTH*12-1:WORD_WIDTH*11]), 
    .in_w12(lifm_buff[0][WORD_WIDTH*13-1:WORD_WIDTH*12]), .in_w13(lifm_buff[0][WORD_WIDTH*14-1:WORD_WIDTH*13]), 
    .in_w14(lifm_buff[0][WORD_WIDTH*15-1:WORD_WIDTH*14]), .in_w15(lifm_buff[0][WORD_WIDTH*16-1:WORD_WIDTH*15]),

    .sel(cpd_index[11][3:0]),

    .out_w(red_values[11])
);

assign oor_flag[12]      = (valid && (dr <= 12)) ? 1'b1 : 1'b0;
assign red_flag_prev[12] = (lifm_buff[0][WORD_WIDTH*13-1:WORD_WIDTH*12] == red_values[12])   ? 1'b1 : 1'b0;
assign red_flag_curr[12] = (lifm_buff[1][WORD_WIDTH*13-1:WORD_WIDTH*12] == lifm_buff[0][WORD_WIDTH*rev_index[12]+:WORD_WIDTH]) ? 1'b1 : 1'b0;
assign cpd_index[12] = (12 <= dr) ? (12 - dr) : 0;
assign rev_index[12] = (12 < (MAX_C_SIZE - dr)) ? (12 + dr) : 0;

MUX16to1 #(
    .WORD_WIDTH(WORD_WIDTH)
) mux_unit_redundant_16to1_lv12 (
    .in_w0(lifm_buff[0][WORD_WIDTH*1-1:WORD_WIDTH*0]), .in_w1(lifm_buff[0][WORD_WIDTH*2-1:WORD_WIDTH*1]), 
    .in_w2(lifm_buff[0][WORD_WIDTH*3-1:WORD_WIDTH*2]), .in_w3(lifm_buff[0][WORD_WIDTH*4-1:WORD_WIDTH*3]), 
    .in_w4(lifm_buff[0][WORD_WIDTH*5-1:WORD_WIDTH*4]), .in_w5(lifm_buff[0][WORD_WIDTH*6-1:WORD_WIDTH*5]), 
    .in_w6(lifm_buff[0][WORD_WIDTH*7-1:WORD_WIDTH*6]), .in_w7(lifm_buff[0][WORD_WIDTH*8-1:WORD_WIDTH*7]), 
    .in_w8(lifm_buff[0][WORD_WIDTH*9-1:WORD_WIDTH*8]), .in_w9(lifm_buff[0][WORD_WIDTH*10-1:WORD_WIDTH*9]), 
    .in_w10(lifm_buff[0][WORD_WIDTH*11-1:WORD_WIDTH*10]), .in_w11(lifm_buff[0][WORD_WIDTH*12-1:WORD_WIDTH*11]), 
    .in_w12(lifm_buff[0][WORD_WIDTH*13-1:WORD_WIDTH*12]), .in_w13(lifm_buff[0][WORD_WIDTH*14-1:WORD_WIDTH*13]), 
    .in_w14(lifm_buff[0][WORD_WIDTH*15-1:WORD_WIDTH*14]), .in_w15(lifm_buff[0][WORD_WIDTH*16-1:WORD_WIDTH*15]),

    .sel(cpd_index[12][3:0]),

    .out_w(red_values[12])
);

assign oor_flag[13]      = (valid && (dr <= 13)) ? 1'b1 : 1'b0;
assign red_flag_prev[13] = (lifm_buff[0][WORD_WIDTH*14-1:WORD_WIDTH*13] == red_values[13])   ? 1'b1 : 1'b0;
assign red_flag_curr[13] = (lifm_buff[1][WORD_WIDTH*14-1:WORD_WIDTH*13] == lifm_buff[0][WORD_WIDTH*rev_index[13]+:WORD_WIDTH]) ? 1'b1 : 1'b0;
assign cpd_index[13] = (13 <= dr) ? (13 - dr) : 0;
assign rev_index[13] = (13 < (MAX_C_SIZE - dr)) ? (13 + dr) : 0;

MUX16to1 #(
    .WORD_WIDTH(WORD_WIDTH)
) mux_unit_redundant_16to1_lv13 (
    .in_w0(lifm_buff[0][WORD_WIDTH*1-1:WORD_WIDTH*0]), .in_w1(lifm_buff[0][WORD_WIDTH*2-1:WORD_WIDTH*1]), 
    .in_w2(lifm_buff[0][WORD_WIDTH*3-1:WORD_WIDTH*2]), .in_w3(lifm_buff[0][WORD_WIDTH*4-1:WORD_WIDTH*3]), 
    .in_w4(lifm_buff[0][WORD_WIDTH*5-1:WORD_WIDTH*4]), .in_w5(lifm_buff[0][WORD_WIDTH*6-1:WORD_WIDTH*5]), 
    .in_w6(lifm_buff[0][WORD_WIDTH*7-1:WORD_WIDTH*6]), .in_w7(lifm_buff[0][WORD_WIDTH*8-1:WORD_WIDTH*7]), 
    .in_w8(lifm_buff[0][WORD_WIDTH*9-1:WORD_WIDTH*8]), .in_w9(lifm_buff[0][WORD_WIDTH*10-1:WORD_WIDTH*9]), 
    .in_w10(lifm_buff[0][WORD_WIDTH*11-1:WORD_WIDTH*10]), .in_w11(lifm_buff[0][WORD_WIDTH*12-1:WORD_WIDTH*11]), 
    .in_w12(lifm_buff[0][WORD_WIDTH*13-1:WORD_WIDTH*12]), .in_w13(lifm_buff[0][WORD_WIDTH*14-1:WORD_WIDTH*13]), 
    .in_w14(lifm_buff[0][WORD_WIDTH*15-1:WORD_WIDTH*14]), .in_w15(lifm_buff[0][WORD_WIDTH*16-1:WORD_WIDTH*15]),

    .sel(cpd_index[13][3:0]),

    .out_w(red_values[13])
);

assign oor_flag[14]      = (valid && (dr <= 14)) ? 1'b1 : 1'b0;
assign red_flag_prev[14] = (lifm_buff[0][WORD_WIDTH*15-1:WORD_WIDTH*14] == red_values[14])   ? 1'b1 : 1'b0;
assign red_flag_curr[14] = (lifm_buff[1][WORD_WIDTH*15-1:WORD_WIDTH*14] == lifm_buff[0][WORD_WIDTH*rev_index[14]+:WORD_WIDTH]) ? 1'b1 : 1'b0;
assign cpd_index[14] = (14 <= dr) ? (14 - dr) : 0;
assign rev_index[14] = (14 < (MAX_C_SIZE - dr)) ? (14 + dr) : 0;

MUX16to1 #(
    .WORD_WIDTH(WORD_WIDTH)
) mux_unit_redundant_16to1_lv14 (
    .in_w0(lifm_buff[0][WORD_WIDTH*1-1:WORD_WIDTH*0]), .in_w1(lifm_buff[0][WORD_WIDTH*2-1:WORD_WIDTH*1]), 
    .in_w2(lifm_buff[0][WORD_WIDTH*3-1:WORD_WIDTH*2]), .in_w3(lifm_buff[0][WORD_WIDTH*4-1:WORD_WIDTH*3]), 
    .in_w4(lifm_buff[0][WORD_WIDTH*5-1:WORD_WIDTH*4]), .in_w5(lifm_buff[0][WORD_WIDTH*6-1:WORD_WIDTH*5]), 
    .in_w6(lifm_buff[0][WORD_WIDTH*7-1:WORD_WIDTH*6]), .in_w7(lifm_buff[0][WORD_WIDTH*8-1:WORD_WIDTH*7]), 
    .in_w8(lifm_buff[0][WORD_WIDTH*9-1:WORD_WIDTH*8]), .in_w9(lifm_buff[0][WORD_WIDTH*10-1:WORD_WIDTH*9]), 
    .in_w10(lifm_buff[0][WORD_WIDTH*11-1:WORD_WIDTH*10]), .in_w11(lifm_buff[0][WORD_WIDTH*12-1:WORD_WIDTH*11]), 
    .in_w12(lifm_buff[0][WORD_WIDTH*13-1:WORD_WIDTH*12]), .in_w13(lifm_buff[0][WORD_WIDTH*14-1:WORD_WIDTH*13]), 
    .in_w14(lifm_buff[0][WORD_WIDTH*15-1:WORD_WIDTH*14]), .in_w15(lifm_buff[0][WORD_WIDTH*16-1:WORD_WIDTH*15]),

    .sel(cpd_index[14][3:0]),

    .out_w(red_values[14])
);

assign oor_flag[15]      = (valid && (dr <= 15)) ? 1'b1 : 1'b0;
assign red_flag_prev[15] = (lifm_buff[0][WORD_WIDTH*16-1:WORD_WIDTH*15] == red_values[15])   ? 1'b1 : 1'b0;
assign red_flag_curr[15] = (lifm_buff[1][WORD_WIDTH*16-1:WORD_WIDTH*15] == lifm_buff[0][WORD_WIDTH*rev_index[15]+:WORD_WIDTH]) ? 1'b1 : 1'b0;
assign cpd_index[15] = (15 <= dr) ? (15 - dr) : 0;
assign rev_index[15] = (15 < (MAX_C_SIZE - dr)) ? (15 + dr) : 0;

MUX16to1 #(
    .WORD_WIDTH(WORD_WIDTH)
) mux_unit_redundant_16to1_lv15 (
    .in_w0(lifm_buff[0][WORD_WIDTH*1-1:WORD_WIDTH*0]), .in_w1(lifm_buff[0][WORD_WIDTH*2-1:WORD_WIDTH*1]), 
    .in_w2(lifm_buff[0][WORD_WIDTH*3-1:WORD_WIDTH*2]), .in_w3(lifm_buff[0][WORD_WIDTH*4-1:WORD_WIDTH*3]), 
    .in_w4(lifm_buff[0][WORD_WIDTH*5-1:WORD_WIDTH*4]), .in_w5(lifm_buff[0][WORD_WIDTH*6-1:WORD_WIDTH*5]), 
    .in_w6(lifm_buff[0][WORD_WIDTH*7-1:WORD_WIDTH*6]), .in_w7(lifm_buff[0][WORD_WIDTH*8-1:WORD_WIDTH*7]), 
    .in_w8(lifm_buff[0][WORD_WIDTH*9-1:WORD_WIDTH*8]), .in_w9(lifm_buff[0][WORD_WIDTH*10-1:WORD_WIDTH*9]), 
    .in_w10(lifm_buff[0][WORD_WIDTH*11-1:WORD_WIDTH*10]), .in_w11(lifm_buff[0][WORD_WIDTH*12-1:WORD_WIDTH*11]), 
    .in_w12(lifm_buff[0][WORD_WIDTH*13-1:WORD_WIDTH*12]), .in_w13(lifm_buff[0][WORD_WIDTH*14-1:WORD_WIDTH*13]), 
    .in_w14(lifm_buff[0][WORD_WIDTH*15-1:WORD_WIDTH*14]), .in_w15(lifm_buff[0][WORD_WIDTH*16-1:WORD_WIDTH*15]),

    .sel(cpd_index[15][3:0]),

    .out_w(red_values[15])
);

// Generating MPTE Stage 2: Routing copied MPTE with MUXes left shift one bit of copied MPTE
wire [MPTE_WIDTH-1:0] mpte_copied_curr  [0:MAX_C_SIZE-1],  // copied column
                      mpte_shifted_curr [0:MAX_C_SIZE-1];  // shifted column


assign mpte_copied_curr[0] = mpte_buff[0][MPTE_WIDTH*16-1:MPTE_WIDTH*15];

assign mpte_copied_curr[1] = mpte_buff[0][MPTE_WIDTH*16-1:MPTE_WIDTH*15];

MUX2to1 #(
    .WORD_WIDTH(MPTE_WIDTH)
) mux_unit_copy_2to1_lv2 (
    .in_w0(mpte_buff[0][MPTE_WIDTH*15-1:MPTE_WIDTH*14]), .in_w1(mpte_buff[0][MPTE_WIDTH*16-1:MPTE_WIDTH*15]),
    .sel(cpd_index[2][0]),
    .out_w(mpte_copied_curr[2])
);

MUX4to1 #(
    .WORD_WIDTH(MPTE_WIDTH)
) mux_unit_copy_4to1_lv3 (
    .in_w0(mpte_buff[0][MPTE_WIDTH*13-1:MPTE_WIDTH*12]), .in_w1(mpte_buff[0][MPTE_WIDTH*14-1:MPTE_WIDTH*13]), 
    .in_w2(mpte_buff[0][MPTE_WIDTH*15-1:MPTE_WIDTH*14]), .in_w3(mpte_buff[0][MPTE_WIDTH*16-1:MPTE_WIDTH*15]),

    .sel(cpd_index[3][1:0]),

    .out_w(mpte_copied_curr[3])
);

MUX4to1 #(
    .WORD_WIDTH(MPTE_WIDTH)
) mux_unit_copy_4to1_lv4 (
    .in_w0(mpte_buff[0][MPTE_WIDTH*13-1:MPTE_WIDTH*12]), .in_w1(mpte_buff[0][MPTE_WIDTH*14-1:MPTE_WIDTH*13]), 
    .in_w2(mpte_buff[0][MPTE_WIDTH*15-1:MPTE_WIDTH*14]), .in_w3(mpte_buff[0][MPTE_WIDTH*16-1:MPTE_WIDTH*15]),

    .sel(cpd_index[4][1:0]),

    .out_w(mpte_copied_curr[4])
);

MUX8to1 #(
    .WORD_WIDTH(MPTE_WIDTH)
) mux_unit_copy_8to1_lv5 (
    .in_w0(mpte_buff[0][MPTE_WIDTH*9-1:MPTE_WIDTH*8]), .in_w1(mpte_buff[0][MPTE_WIDTH*10-1:MPTE_WIDTH*9]), 
    .in_w2(mpte_buff[0][MPTE_WIDTH*11-1:MPTE_WIDTH*10]), .in_w3(mpte_buff[0][MPTE_WIDTH*12-1:MPTE_WIDTH*11]), 
    .in_w4(mpte_buff[0][MPTE_WIDTH*13-1:MPTE_WIDTH*12]), .in_w5(mpte_buff[0][MPTE_WIDTH*14-1:MPTE_WIDTH*13]), 
    .in_w6(mpte_buff[0][MPTE_WIDTH*15-1:MPTE_WIDTH*14]), .in_w7(mpte_buff[0][MPTE_WIDTH*16-1:MPTE_WIDTH*15]),

    .sel(cpd_index[5][2:0]),

    .out_w(mpte_copied_curr[5])
);

MUX8to1 #(
    .WORD_WIDTH(MPTE_WIDTH)
) mux_unit_copy_8to1_lv6 (
    .in_w0(mpte_buff[0][MPTE_WIDTH*9-1:MPTE_WIDTH*8]), .in_w1(mpte_buff[0][MPTE_WIDTH*10-1:MPTE_WIDTH*9]), 
    .in_w2(mpte_buff[0][MPTE_WIDTH*11-1:MPTE_WIDTH*10]), .in_w3(mpte_buff[0][MPTE_WIDTH*12-1:MPTE_WIDTH*11]), 
    .in_w4(mpte_buff[0][MPTE_WIDTH*13-1:MPTE_WIDTH*12]), .in_w5(mpte_buff[0][MPTE_WIDTH*14-1:MPTE_WIDTH*13]), 
    .in_w6(mpte_buff[0][MPTE_WIDTH*15-1:MPTE_WIDTH*14]), .in_w7(mpte_buff[0][MPTE_WIDTH*16-1:MPTE_WIDTH*15]),

    .sel(cpd_index[6][2:0]),

    .out_w(mpte_copied_curr[6])
);

MUX8to1 #(
    .WORD_WIDTH(MPTE_WIDTH)
) mux_unit_copy_8to1_lv7 (
    .in_w0(mpte_buff[0][MPTE_WIDTH*9-1:MPTE_WIDTH*8]), .in_w1(mpte_buff[0][MPTE_WIDTH*10-1:MPTE_WIDTH*9]), 
    .in_w2(mpte_buff[0][MPTE_WIDTH*11-1:MPTE_WIDTH*10]), .in_w3(mpte_buff[0][MPTE_WIDTH*12-1:MPTE_WIDTH*11]), 
    .in_w4(mpte_buff[0][MPTE_WIDTH*13-1:MPTE_WIDTH*12]), .in_w5(mpte_buff[0][MPTE_WIDTH*14-1:MPTE_WIDTH*13]), 
    .in_w6(mpte_buff[0][MPTE_WIDTH*15-1:MPTE_WIDTH*14]), .in_w7(mpte_buff[0][MPTE_WIDTH*16-1:MPTE_WIDTH*15]),

    .sel(cpd_index[7][2:0]),

    .out_w(mpte_copied_curr[7])
);

MUX8to1 #(
    .WORD_WIDTH(MPTE_WIDTH)
) mux_unit_copy_8to1_lv8 (
    .in_w0(mpte_buff[0][MPTE_WIDTH*9-1:MPTE_WIDTH*8]), .in_w1(mpte_buff[0][MPTE_WIDTH*10-1:MPTE_WIDTH*9]), 
    .in_w2(mpte_buff[0][MPTE_WIDTH*11-1:MPTE_WIDTH*10]), .in_w3(mpte_buff[0][MPTE_WIDTH*12-1:MPTE_WIDTH*11]), 
    .in_w4(mpte_buff[0][MPTE_WIDTH*13-1:MPTE_WIDTH*12]), .in_w5(mpte_buff[0][MPTE_WIDTH*14-1:MPTE_WIDTH*13]), 
    .in_w6(mpte_buff[0][MPTE_WIDTH*15-1:MPTE_WIDTH*14]), .in_w7(mpte_buff[0][MPTE_WIDTH*16-1:MPTE_WIDTH*15]),

    .sel(cpd_index[8][2:0]),

    .out_w(mpte_copied_curr[8])
);

MUX16to1 #(
    .WORD_WIDTH(MPTE_WIDTH)
) mux_unit_copy_16to1_lv9 (
    .in_w0(mpte_buff[0][MPTE_WIDTH*1-1:MPTE_WIDTH*0]), .in_w1(mpte_buff[0][MPTE_WIDTH*2-1:MPTE_WIDTH*1]), 
    .in_w2(mpte_buff[0][MPTE_WIDTH*3-1:MPTE_WIDTH*2]), .in_w3(mpte_buff[0][MPTE_WIDTH*4-1:MPTE_WIDTH*3]), 
    .in_w4(mpte_buff[0][MPTE_WIDTH*5-1:MPTE_WIDTH*4]), .in_w5(mpte_buff[0][MPTE_WIDTH*6-1:MPTE_WIDTH*5]), 
    .in_w6(mpte_buff[0][MPTE_WIDTH*7-1:MPTE_WIDTH*6]), .in_w7(mpte_buff[0][MPTE_WIDTH*8-1:MPTE_WIDTH*7]), 
    .in_w8(mpte_buff[0][MPTE_WIDTH*9-1:MPTE_WIDTH*8]), .in_w9(mpte_buff[0][MPTE_WIDTH*10-1:MPTE_WIDTH*9]), 
    .in_w10(mpte_buff[0][MPTE_WIDTH*11-1:MPTE_WIDTH*10]), .in_w11(mpte_buff[0][MPTE_WIDTH*12-1:MPTE_WIDTH*11]), 
    .in_w12(mpte_buff[0][MPTE_WIDTH*13-1:MPTE_WIDTH*12]), .in_w13(mpte_buff[0][MPTE_WIDTH*14-1:MPTE_WIDTH*13]), 
    .in_w14(mpte_buff[0][MPTE_WIDTH*15-1:MPTE_WIDTH*14]), .in_w15(mpte_buff[0][MPTE_WIDTH*16-1:MPTE_WIDTH*15]),

    .sel(cpd_index[9][3:0]),

    .out_w(mpte_copied_curr[9])
);

MUX16to1 #(
    .WORD_WIDTH(MPTE_WIDTH)
) mux_unit_copy_16to1_lv10 (
    .in_w0(mpte_buff[0][MPTE_WIDTH*1-1:MPTE_WIDTH*0]), .in_w1(mpte_buff[0][MPTE_WIDTH*2-1:MPTE_WIDTH*1]), 
    .in_w2(mpte_buff[0][MPTE_WIDTH*3-1:MPTE_WIDTH*2]), .in_w3(mpte_buff[0][MPTE_WIDTH*4-1:MPTE_WIDTH*3]), 
    .in_w4(mpte_buff[0][MPTE_WIDTH*5-1:MPTE_WIDTH*4]), .in_w5(mpte_buff[0][MPTE_WIDTH*6-1:MPTE_WIDTH*5]), 
    .in_w6(mpte_buff[0][MPTE_WIDTH*7-1:MPTE_WIDTH*6]), .in_w7(mpte_buff[0][MPTE_WIDTH*8-1:MPTE_WIDTH*7]), 
    .in_w8(mpte_buff[0][MPTE_WIDTH*9-1:MPTE_WIDTH*8]), .in_w9(mpte_buff[0][MPTE_WIDTH*10-1:MPTE_WIDTH*9]), 
    .in_w10(mpte_buff[0][MPTE_WIDTH*11-1:MPTE_WIDTH*10]), .in_w11(mpte_buff[0][MPTE_WIDTH*12-1:MPTE_WIDTH*11]), 
    .in_w12(mpte_buff[0][MPTE_WIDTH*13-1:MPTE_WIDTH*12]), .in_w13(mpte_buff[0][MPTE_WIDTH*14-1:MPTE_WIDTH*13]), 
    .in_w14(mpte_buff[0][MPTE_WIDTH*15-1:MPTE_WIDTH*14]), .in_w15(mpte_buff[0][MPTE_WIDTH*16-1:MPTE_WIDTH*15]),

    .sel(cpd_index[10][3:0]),

    .out_w(mpte_copied_curr[10])
);

MUX16to1 #(
    .WORD_WIDTH(MPTE_WIDTH)
) mux_unit_copy_16to1_lv11 (
    .in_w0(mpte_buff[0][MPTE_WIDTH*1-1:MPTE_WIDTH*0]), .in_w1(mpte_buff[0][MPTE_WIDTH*2-1:MPTE_WIDTH*1]), 
    .in_w2(mpte_buff[0][MPTE_WIDTH*3-1:MPTE_WIDTH*2]), .in_w3(mpte_buff[0][MPTE_WIDTH*4-1:MPTE_WIDTH*3]), 
    .in_w4(mpte_buff[0][MPTE_WIDTH*5-1:MPTE_WIDTH*4]), .in_w5(mpte_buff[0][MPTE_WIDTH*6-1:MPTE_WIDTH*5]), 
    .in_w6(mpte_buff[0][MPTE_WIDTH*7-1:MPTE_WIDTH*6]), .in_w7(mpte_buff[0][MPTE_WIDTH*8-1:MPTE_WIDTH*7]), 
    .in_w8(mpte_buff[0][MPTE_WIDTH*9-1:MPTE_WIDTH*8]), .in_w9(mpte_buff[0][MPTE_WIDTH*10-1:MPTE_WIDTH*9]), 
    .in_w10(mpte_buff[0][MPTE_WIDTH*11-1:MPTE_WIDTH*10]), .in_w11(mpte_buff[0][MPTE_WIDTH*12-1:MPTE_WIDTH*11]), 
    .in_w12(mpte_buff[0][MPTE_WIDTH*13-1:MPTE_WIDTH*12]), .in_w13(mpte_buff[0][MPTE_WIDTH*14-1:MPTE_WIDTH*13]), 
    .in_w14(mpte_buff[0][MPTE_WIDTH*15-1:MPTE_WIDTH*14]), .in_w15(mpte_buff[0][MPTE_WIDTH*16-1:MPTE_WIDTH*15]),

    .sel(cpd_index[11][3:0]),

    .out_w(mpte_copied_curr[11])
);

MUX16to1 #(
    .WORD_WIDTH(MPTE_WIDTH)
) mux_unit_copy_16to1_lv12 (
    .in_w0(mpte_buff[0][MPTE_WIDTH*1-1:MPTE_WIDTH*0]), .in_w1(mpte_buff[0][MPTE_WIDTH*2-1:MPTE_WIDTH*1]), 
    .in_w2(mpte_buff[0][MPTE_WIDTH*3-1:MPTE_WIDTH*2]), .in_w3(mpte_buff[0][MPTE_WIDTH*4-1:MPTE_WIDTH*3]), 
    .in_w4(mpte_buff[0][MPTE_WIDTH*5-1:MPTE_WIDTH*4]), .in_w5(mpte_buff[0][MPTE_WIDTH*6-1:MPTE_WIDTH*5]), 
    .in_w6(mpte_buff[0][MPTE_WIDTH*7-1:MPTE_WIDTH*6]), .in_w7(mpte_buff[0][MPTE_WIDTH*8-1:MPTE_WIDTH*7]), 
    .in_w8(mpte_buff[0][MPTE_WIDTH*9-1:MPTE_WIDTH*8]), .in_w9(mpte_buff[0][MPTE_WIDTH*10-1:MPTE_WIDTH*9]), 
    .in_w10(mpte_buff[0][MPTE_WIDTH*11-1:MPTE_WIDTH*10]), .in_w11(mpte_buff[0][MPTE_WIDTH*12-1:MPTE_WIDTH*11]), 
    .in_w12(mpte_buff[0][MPTE_WIDTH*13-1:MPTE_WIDTH*12]), .in_w13(mpte_buff[0][MPTE_WIDTH*14-1:MPTE_WIDTH*13]), 
    .in_w14(mpte_buff[0][MPTE_WIDTH*15-1:MPTE_WIDTH*14]), .in_w15(mpte_buff[0][MPTE_WIDTH*16-1:MPTE_WIDTH*15]),

    .sel(cpd_index[12][3:0]),

    .out_w(mpte_copied_curr[12])
);

MUX16to1 #(
    .WORD_WIDTH(MPTE_WIDTH)
) mux_unit_copy_16to1_lv13 (
    .in_w0(mpte_buff[0][MPTE_WIDTH*1-1:MPTE_WIDTH*0]), .in_w1(mpte_buff[0][MPTE_WIDTH*2-1:MPTE_WIDTH*1]), 
    .in_w2(mpte_buff[0][MPTE_WIDTH*3-1:MPTE_WIDTH*2]), .in_w3(mpte_buff[0][MPTE_WIDTH*4-1:MPTE_WIDTH*3]), 
    .in_w4(mpte_buff[0][MPTE_WIDTH*5-1:MPTE_WIDTH*4]), .in_w5(mpte_buff[0][MPTE_WIDTH*6-1:MPTE_WIDTH*5]), 
    .in_w6(mpte_buff[0][MPTE_WIDTH*7-1:MPTE_WIDTH*6]), .in_w7(mpte_buff[0][MPTE_WIDTH*8-1:MPTE_WIDTH*7]), 
    .in_w8(mpte_buff[0][MPTE_WIDTH*9-1:MPTE_WIDTH*8]), .in_w9(mpte_buff[0][MPTE_WIDTH*10-1:MPTE_WIDTH*9]), 
    .in_w10(mpte_buff[0][MPTE_WIDTH*11-1:MPTE_WIDTH*10]), .in_w11(mpte_buff[0][MPTE_WIDTH*12-1:MPTE_WIDTH*11]), 
    .in_w12(mpte_buff[0][MPTE_WIDTH*13-1:MPTE_WIDTH*12]), .in_w13(mpte_buff[0][MPTE_WIDTH*14-1:MPTE_WIDTH*13]), 
    .in_w14(mpte_buff[0][MPTE_WIDTH*15-1:MPTE_WIDTH*14]), .in_w15(mpte_buff[0][MPTE_WIDTH*16-1:MPTE_WIDTH*15]),

    .sel(cpd_index[13][3:0]),

    .out_w(mpte_copied_curr[13])
);

MUX16to1 #(
    .WORD_WIDTH(MPTE_WIDTH)
) mux_unit_copy_16to1_lv14 (
    .in_w0(mpte_buff[0][MPTE_WIDTH*1-1:MPTE_WIDTH*0]), .in_w1(mpte_buff[0][MPTE_WIDTH*2-1:MPTE_WIDTH*1]), 
    .in_w2(mpte_buff[0][MPTE_WIDTH*3-1:MPTE_WIDTH*2]), .in_w3(mpte_buff[0][MPTE_WIDTH*4-1:MPTE_WIDTH*3]), 
    .in_w4(mpte_buff[0][MPTE_WIDTH*5-1:MPTE_WIDTH*4]), .in_w5(mpte_buff[0][MPTE_WIDTH*6-1:MPTE_WIDTH*5]), 
    .in_w6(mpte_buff[0][MPTE_WIDTH*7-1:MPTE_WIDTH*6]), .in_w7(mpte_buff[0][MPTE_WIDTH*8-1:MPTE_WIDTH*7]), 
    .in_w8(mpte_buff[0][MPTE_WIDTH*9-1:MPTE_WIDTH*8]), .in_w9(mpte_buff[0][MPTE_WIDTH*10-1:MPTE_WIDTH*9]), 
    .in_w10(mpte_buff[0][MPTE_WIDTH*11-1:MPTE_WIDTH*10]), .in_w11(mpte_buff[0][MPTE_WIDTH*12-1:MPTE_WIDTH*11]), 
    .in_w12(mpte_buff[0][MPTE_WIDTH*13-1:MPTE_WIDTH*12]), .in_w13(mpte_buff[0][MPTE_WIDTH*14-1:MPTE_WIDTH*13]), 
    .in_w14(mpte_buff[0][MPTE_WIDTH*15-1:MPTE_WIDTH*14]), .in_w15(mpte_buff[0][MPTE_WIDTH*16-1:MPTE_WIDTH*15]),

    .sel(cpd_index[14][3:0]),

    .out_w(mpte_copied_curr[14])
);

MUX16to1 #(
    .WORD_WIDTH(MPTE_WIDTH)
) mux_unit_copy_16to1_lv15 (
    .in_w0(mpte_buff[0][MPTE_WIDTH*1-1:MPTE_WIDTH*0]), .in_w1(mpte_buff[0][MPTE_WIDTH*2-1:MPTE_WIDTH*1]), 
    .in_w2(mpte_buff[0][MPTE_WIDTH*3-1:MPTE_WIDTH*2]), .in_w3(mpte_buff[0][MPTE_WIDTH*4-1:MPTE_WIDTH*3]), 
    .in_w4(mpte_buff[0][MPTE_WIDTH*5-1:MPTE_WIDTH*4]), .in_w5(mpte_buff[0][MPTE_WIDTH*6-1:MPTE_WIDTH*5]), 
    .in_w6(mpte_buff[0][MPTE_WIDTH*7-1:MPTE_WIDTH*6]), .in_w7(mpte_buff[0][MPTE_WIDTH*8-1:MPTE_WIDTH*7]), 
    .in_w8(mpte_buff[0][MPTE_WIDTH*9-1:MPTE_WIDTH*8]), .in_w9(mpte_buff[0][MPTE_WIDTH*10-1:MPTE_WIDTH*9]), 
    .in_w10(mpte_buff[0][MPTE_WIDTH*11-1:MPTE_WIDTH*10]), .in_w11(mpte_buff[0][MPTE_WIDTH*12-1:MPTE_WIDTH*11]), 
    .in_w12(mpte_buff[0][MPTE_WIDTH*13-1:MPTE_WIDTH*12]), .in_w13(mpte_buff[0][MPTE_WIDTH*14-1:MPTE_WIDTH*13]), 
    .in_w14(mpte_buff[0][MPTE_WIDTH*15-1:MPTE_WIDTH*14]), .in_w15(mpte_buff[0][MPTE_WIDTH*16-1:MPTE_WIDTH*15]),

    .sel(cpd_index[15][3:0]),

    .out_w(mpte_copied_curr[15])
);

// Generating MPTE Stage 3: Set updated values of MPTE
wire [MPTE_WIDTH*MAX_C_SIZE-1:0] mpte_updated [0:1];

assign mpte_updated[0][MPTE_WIDTH*1-1:MPTE_WIDTH*0] = red_flag_prev[0] ? 0 : { mpte_buff[0][MPTE_WIDTH*1-DIST_WIDTH-1:MPTE_WIDTH*0], 7'd0 };
assign mpte_updated[1][MPTE_WIDTH*1-1:MPTE_WIDTH*0] = red_flag_curr[0] ? { mpte_copied_curr[0][MPTE_WIDTH-1:DIST_WIDTH], 7'd0 } : mpte_buff[1][MPTE_WIDTH*1-1:MPTE_WIDTH*0];

assign mpte_updated[0][MPTE_WIDTH*2-1:MPTE_WIDTH*1] = red_flag_prev[1] ? 0 : { mpte_buff[0][MPTE_WIDTH*2-DIST_WIDTH-1:MPTE_WIDTH*1], 7'd1 };
assign mpte_updated[1][MPTE_WIDTH*2-1:MPTE_WIDTH*1] = red_flag_curr[1] ? { mpte_copied_curr[1][MPTE_WIDTH-1:DIST_WIDTH], 7'd1 } : mpte_buff[1][MPTE_WIDTH*2-1:MPTE_WIDTH*1];

assign mpte_updated[0][MPTE_WIDTH*3-1:MPTE_WIDTH*2] = red_flag_prev[2] ? 0 : { mpte_buff[0][MPTE_WIDTH*3-DIST_WIDTH-1:MPTE_WIDTH*2], 7'd2 };
assign mpte_updated[1][MPTE_WIDTH*3-1:MPTE_WIDTH*2] = red_flag_curr[2] ? { mpte_copied_curr[2][MPTE_WIDTH-1:DIST_WIDTH], 7'd2 } : mpte_buff[1][MPTE_WIDTH*3-1:MPTE_WIDTH*2];

assign mpte_updated[0][MPTE_WIDTH*4-1:MPTE_WIDTH*3] = red_flag_prev[3] ? 0 : { mpte_buff[0][MPTE_WIDTH*4-DIST_WIDTH-1:MPTE_WIDTH*3], 7'd3 };
assign mpte_updated[1][MPTE_WIDTH*4-1:MPTE_WIDTH*3] = red_flag_curr[3] ? { mpte_copied_curr[3][MPTE_WIDTH-1:DIST_WIDTH], 7'd3 } : mpte_buff[1][MPTE_WIDTH*4-1:MPTE_WIDTH*3];

assign mpte_updated[0][MPTE_WIDTH*5-1:MPTE_WIDTH*4] = red_flag_prev[4] ? 0 : { mpte_buff[0][MPTE_WIDTH*5-DIST_WIDTH-1:MPTE_WIDTH*4], 7'd4 };
assign mpte_updated[1][MPTE_WIDTH*5-1:MPTE_WIDTH*4] = red_flag_curr[4] ? { mpte_copied_curr[4][MPTE_WIDTH-1:DIST_WIDTH], 7'd4 } : mpte_buff[1][MPTE_WIDTH*5-1:MPTE_WIDTH*4];

assign mpte_updated[0][MPTE_WIDTH*6-1:MPTE_WIDTH*5] = red_flag_prev[5] ? 0 : { mpte_buff[0][MPTE_WIDTH*6-DIST_WIDTH-1:MPTE_WIDTH*5], 7'd5 };
assign mpte_updated[1][MPTE_WIDTH*6-1:MPTE_WIDTH*5] = red_flag_curr[5] ? { mpte_copied_curr[5][MPTE_WIDTH-1:DIST_WIDTH], 7'd5 } : mpte_buff[1][MPTE_WIDTH*6-1:MPTE_WIDTH*5];

assign mpte_updated[0][MPTE_WIDTH*7-1:MPTE_WIDTH*6] = red_flag_prev[6] ? 0 : { mpte_buff[0][MPTE_WIDTH*7-DIST_WIDTH-1:MPTE_WIDTH*6], 7'd6 };
assign mpte_updated[1][MPTE_WIDTH*7-1:MPTE_WIDTH*6] = red_flag_curr[6] ? { mpte_copied_curr[6][MPTE_WIDTH-1:DIST_WIDTH], 7'd6 } : mpte_buff[1][MPTE_WIDTH*7-1:MPTE_WIDTH*6];

assign mpte_updated[0][MPTE_WIDTH*8-1:MPTE_WIDTH*7] = red_flag_prev[7] ? 0 : { mpte_buff[0][MPTE_WIDTH*8-DIST_WIDTH-1:MPTE_WIDTH*7], 7'd7 };
assign mpte_updated[1][MPTE_WIDTH*8-1:MPTE_WIDTH*7] = red_flag_curr[7] ? { mpte_copied_curr[7][MPTE_WIDTH-1:DIST_WIDTH], 7'd7 } : mpte_buff[1][MPTE_WIDTH*8-1:MPTE_WIDTH*7];

assign mpte_updated[0][MPTE_WIDTH*9-1:MPTE_WIDTH*8] = red_flag_prev[8] ? 0 : { mpte_buff[0][MPTE_WIDTH*9-DIST_WIDTH-1:MPTE_WIDTH*8], 7'd8 };
assign mpte_updated[1][MPTE_WIDTH*9-1:MPTE_WIDTH*8] = red_flag_curr[8] ? { mpte_copied_curr[8][MPTE_WIDTH-1:DIST_WIDTH], 7'd8 } : mpte_buff[1][MPTE_WIDTH*9-1:MPTE_WIDTH*8];

assign mpte_updated[0][MPTE_WIDTH*10-1:MPTE_WIDTH*9] = red_flag_prev[9] ? 0 : { mpte_buff[0][MPTE_WIDTH*10-DIST_WIDTH-1:MPTE_WIDTH*9], 7'd9 };
assign mpte_updated[1][MPTE_WIDTH*10-1:MPTE_WIDTH*9] = red_flag_curr[9] ? { mpte_copied_curr[9][MPTE_WIDTH-1:DIST_WIDTH], 7'd9 } : mpte_buff[1][MPTE_WIDTH*10-1:MPTE_WIDTH*9];

assign mpte_updated[0][MPTE_WIDTH*11-1:MPTE_WIDTH*10] = red_flag_prev[10] ? 0 : { mpte_buff[0][MPTE_WIDTH*11-DIST_WIDTH-1:MPTE_WIDTH*10], 7'd10 };
assign mpte_updated[1][MPTE_WIDTH*11-1:MPTE_WIDTH*10] = red_flag_curr[10] ? { mpte_copied_curr[10][MPTE_WIDTH-1:DIST_WIDTH], 7'd10 } : mpte_buff[1][MPTE_WIDTH*11-1:MPTE_WIDTH*10];

assign mpte_updated[0][MPTE_WIDTH*12-1:MPTE_WIDTH*11] = red_flag_prev[11] ? 0 : { mpte_buff[0][MPTE_WIDTH*12-DIST_WIDTH-1:MPTE_WIDTH*11], 7'd11 };
assign mpte_updated[1][MPTE_WIDTH*12-1:MPTE_WIDTH*11] = red_flag_curr[11] ? { mpte_copied_curr[11][MPTE_WIDTH-1:DIST_WIDTH], 7'd11 } : mpte_buff[1][MPTE_WIDTH*12-1:MPTE_WIDTH*11];

assign mpte_updated[0][MPTE_WIDTH*13-1:MPTE_WIDTH*12] = red_flag_prev[12] ? 0 : { mpte_buff[0][MPTE_WIDTH*13-DIST_WIDTH-1:MPTE_WIDTH*12], 7'd12 };
assign mpte_updated[1][MPTE_WIDTH*13-1:MPTE_WIDTH*12] = red_flag_curr[12] ? { mpte_copied_curr[12][MPTE_WIDTH-1:DIST_WIDTH], 7'd12 } : mpte_buff[1][MPTE_WIDTH*13-1:MPTE_WIDTH*12];

assign mpte_updated[0][MPTE_WIDTH*14-1:MPTE_WIDTH*13] = red_flag_prev[13] ? 0 : { mpte_buff[0][MPTE_WIDTH*14-DIST_WIDTH-1:MPTE_WIDTH*13], 7'd13 };
assign mpte_updated[1][MPTE_WIDTH*14-1:MPTE_WIDTH*13] = red_flag_curr[13] ? { mpte_copied_curr[13][MPTE_WIDTH-1:DIST_WIDTH], 7'd13 } : mpte_buff[1][MPTE_WIDTH*14-1:MPTE_WIDTH*13];

assign mpte_updated[0][MPTE_WIDTH*15-1:MPTE_WIDTH*14] = red_flag_prev[14] ? 0 : { mpte_buff[0][MPTE_WIDTH*15-DIST_WIDTH-1:MPTE_WIDTH*14], 7'd14 };
assign mpte_updated[1][MPTE_WIDTH*15-1:MPTE_WIDTH*14] = red_flag_curr[14] ? { mpte_copied_curr[14][MPTE_WIDTH-1:DIST_WIDTH], 7'd14 } : mpte_buff[1][MPTE_WIDTH*15-1:MPTE_WIDTH*14];

assign mpte_updated[0][MPTE_WIDTH*16-1:MPTE_WIDTH*15] = red_flag_prev[15] ? 0 : { mpte_buff[0][MPTE_WIDTH*16-DIST_WIDTH-1:MPTE_WIDTH*15], 7'd15 };
assign mpte_updated[1][MPTE_WIDTH*16-1:MPTE_WIDTH*15] = red_flag_curr[15] ? { mpte_copied_curr[15][MPTE_WIDTH-1:DIST_WIDTH], 7'd15 } : mpte_buff[1][MPTE_WIDTH*16-1:MPTE_WIDTH*15];


always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        idx1 <= 0;
        idx2 <= 0;
        lifm_buff[0] <= 0;
        lifm_buff[1] <= 0;
        mpte_buff[0] <= 0;
        mpte_buff[1] <= 0;
    end 

    // Shift mapping table and lifm buffer at falling edge of the clock
    else begin
        { idx2, idx1 } <= { idx, idx2 };
        { lifm_buff[1], lifm_buff[0], lifm_comp_reg } <= { lifm_line, lifm_buff[1], lifm_buff[0] };
        { mpte_buff[1], mpte_buff[0], mpte_comp_reg } <= { { MPTE_WIDTH*MAX_C_SIZE{ 1'b0 } }, mpte_updated[1], mpte_updated[0] };
    end 
end

endmodule