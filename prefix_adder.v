// module ZVCompressor #(
//     parameter WORD_WIDTH    = 8,
//     parameter LINE_SIZE     = 32,
//     parameter DIST_WIDTH    = 7,
//     parameter MAX_LIFM_RSIZ = 3    // maximum row size of LIFM
// ) (
//     input clk,
//     input reset_n,
    
//     input [LINE_SIZE*WORD_WIDTH-1:0]               lifm_line,
//     input [LINE_SIZE*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_line,

//     output [LINE_SIZE*WORD_WIDTH-1:0]               lifm_comp,
//     output [LINE_SIZE*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_comp
// );

// genvar line_idx;  // line index iterator

// // Generate array connected with input and output ports
// wire [WORD_WIDTH-1:0]               lifm_line_arr [0:LINE_SIZE-1];
// wire [DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_line_arr   [0:LINE_SIZE-1];

// reg [WORD_WIDTH-1:0]               lifm_comp_arr [0:LINE_SIZE-1];
// reg [DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_comp_arr   [0:LINE_SIZE-1];

// generate
//     for (line_idx = 0; line_idx < LINE_SIZE; line_idx = line_idx+1) begin
//         assign lifm_comp_arr[line_idx] = lifm_comp[WORD_WIDTH*line_idx-1:WORD_WIDTH*(line_idx-1)];
//         assign mt_line[DIST_WIDTH*MAX_LIFM_RSIZ*line_idx-1:DIST_WIDTH*MAX_LIFM_RSIZ*(line_idx-1)] = mt_comp_arr[line_idx];
//     end
// endgenerate

// // Pipeline: Generate zero bitmask and bubble index with prefix adder
// wire [LINE_SIZE-1:0] bitmask;

// reg [WORD_WIDTH-1:0]               lifm_pipe_a [0:LINE_SIZE-1];  // pipeline registers: LIFM
// reg [DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_pipe_a   [0:LINE_SIZE-1];  // pipeline registers: MT

// generate
//     for (line_idx = 0; line_idx < LINE_SIZE; line_idx = line_idx+1) begin
//         assign bitmask[line_idx] = (mt_line_arr[line_idx] != 0);
//     end
// endgenerate
    
// endmodule


module LFPrefixAdder32 (  // Ladner-Fischer adder
    input [31:0] mask,

    output [1023:0] psum
);

// Stage 1
wire [1:0] st1 [0:31];

PAdd #(.WORD_WIDTH(1)) st1_pa0(.a(mask[0]), .b(mask[1]),  .y(st1[1]));
PAdd #(.WORD_WIDTH(1)) st1_pa1(.a(mask[2]), .b(mask[3]),  .y(st1[3]));
PAdd #(.WORD_WIDTH(1)) st1_pa2(.a(mask[4]), .b(mask[5]),  .y(st1[5]));
PAdd #(.WORD_WIDTH(1)) st1_pa3(.a(mask[6]), .b(mask[7]),  .y(st1[7]));
PAdd #(.WORD_WIDTH(1)) st1_pa4(.a(mask[8]), .b(mask[9]),  .y(st1[9]));
PAdd #(.WORD_WIDTH(1)) st1_pa5(.a(mask[10]), .b(mask[11]), .y(st1[11]));
PAdd #(.WORD_WIDTH(1)) st1_pa6(.a(mask[12]), .b(mask[13]), .y(st1[13]));
PAdd #(.WORD_WIDTH(1)) st1_pa7(.a(mask[14]), .b(mask[15]), .y(st1[15]));
PAdd #(.WORD_WIDTH(1)) st1_pa8(.a(mask[16]), .b(mask[17]), .y(st1[17]));
PAdd #(.WORD_WIDTH(1)) st1_pa9(.a(mask[18]), .b(mask[19]), .y(st1[19]));
PAdd #(.WORD_WIDTH(1)) st1_pa10(.a(mask[20]), .b(mask[21]), .y(st1[21]));
PAdd #(.WORD_WIDTH(1)) st1_pa11(.a(mask[22]), .b(mask[23]), .y(st1[23]));
PAdd #(.WORD_WIDTH(1)) st1_pa12(.a(mask[24]), .b(mask[25]), .y(st1[25]));
PAdd #(.WORD_WIDTH(1)) st1_pa13(.a(mask[26]), .b(mask[27]), .y(st1[27]));
PAdd #(.WORD_WIDTH(1)) st1_pa14(.a(mask[28]), .b(mask[29]), .y(st1[29]));
PAdd #(.WORD_WIDTH(1)) st1_pa15(.a(mask[30]), .b(mask[31]), .y(st1[31]));

assign st1[0]  = {1'b0, mask[0]};
assign st1[2]  = {1'b0, mask[2]};
assign st1[4]  = {1'b0, mask[4]};
assign st1[6]  = {1'b0, mask[6]};
assign st1[8]  = {1'b0, mask[8]};
assign st1[10] = {1'b0, mask[10]};
assign st1[12] = {1'b0, mask[12]};
assign st1[14] = {1'b0, mask[14]};
assign st1[16] = {1'b0, mask[16]};
assign st1[18] = {1'b0, mask[18]};
assign st1[20] = {1'b0, mask[20]};
assign st1[22] = {1'b0, mask[22]};
assign st1[24] = {1'b0, mask[24]};
assign st1[26] = {1'b0, mask[26]};
assign st1[28] = {1'b0, mask[28]};
assign st1[30] = {1'b0, mask[30]};

// Stage 2
wire [3:0] st2 [0:31];

PAdd #(.WORD_WIDTH(2)) st2_pa0(.a(st1[1]), .b(st1[2]),  .y(st2[2]));
PAdd #(.WORD_WIDTH(2)) st2_pa1(.a(st1[1]), .b(st1[3]),  .y(st2[3]));
PAdd #(.WORD_WIDTH(2)) st2_pa2(.a(st1[5]), .b(st1[6]),  .y(st2[6]));
PAdd #(.WORD_WIDTH(2)) st2_pa3(.a(st1[5]), .b(st1[7]),  .y(st2[7]));
PAdd #(.WORD_WIDTH(2)) st2_pa4(.a(st1[9]), .b(st1[10]), .y(st2[10]));
PAdd #(.WORD_WIDTH(2)) st2_pa5(.a(st1[9]), .b(st1[11]), .y(st2[11]));
PAdd #(.WORD_WIDTH(2)) st2_pa6(.a(st1[13]), .b(st1[14]), .y(st2[14]));
PAdd #(.WORD_WIDTH(2)) st2_pa7(.a(st1[13]), .b(st1[15]), .y(st2[15]));
PAdd #(.WORD_WIDTH(2)) st2_pa8(.a(st1[17]), .b(st1[18]), .y(st2[18]));
PAdd #(.WORD_WIDTH(2)) st2_pa9(.a(st1[17]), .b(st1[19]), .y(st2[19]));
PAdd #(.WORD_WIDTH(2)) st2_pa10(.a(st1[21]), .b(st1[22]), .y(st2[22]));
PAdd #(.WORD_WIDTH(2)) st2_pa11(.a(st1[21]), .b(st1[23]), .y(st2[23]));
PAdd #(.WORD_WIDTH(2)) st2_pa12(.a(st1[25]), .b(st1[26]), .y(st2[26]));
PAdd #(.WORD_WIDTH(2)) st2_pa13(.a(st1[25]), .b(st1[27]), .y(st2[27]));
PAdd #(.WORD_WIDTH(2)) st2_pa14(.a(st1[29]), .b(st1[30]), .y(st2[30]));
PAdd #(.WORD_WIDTH(2)) st2_pa15(.a(st1[29]), .b(st1[31]), .y(st2[31]));

assign st2[0] = {2'b0, st1[0]};
assign st2[1] = {2'b0, st1[1]};
assign st2[4] = {2'b0, st1[4]};
assign st2[5] = {2'b0, st1[5]};
assign st2[8] = {2'b0, st1[8]};
assign st2[9] = {2'b0, st1[9]};
assign st2[12] = {2'b0, st1[12]};
assign st2[13] = {2'b0, st1[13]};
assign st2[16] = {2'b0, st1[16]};
assign st2[17] = {2'b0, st1[17]};
assign st2[20] = {2'b0, st1[20]};
assign st2[21] = {2'b0, st1[21]};
assign st2[24] = {2'b0, st1[24]};
assign st2[25] = {2'b0, st1[25]};
assign st2[28] = {2'b0, st1[28]};
assign st2[29] = {2'b0, st1[29]};

// Stage 3
wire [7:0] st3 [0:31];

PAdd #(.WORD_WIDTH(4)) st3_pa0(.a(st2[3]), .b(st2[4]),  .y(st3[4]));
PAdd #(.WORD_WIDTH(4)) st3_pa1(.a(st2[3]), .b(st2[5]),  .y(st3[5]));
PAdd #(.WORD_WIDTH(4)) st3_pa2(.a(st2[3]), .b(st2[6]),  .y(st3[6]));
PAdd #(.WORD_WIDTH(4)) st3_pa3(.a(st2[3]), .b(st2[7]),  .y(st3[7]));
PAdd #(.WORD_WIDTH(4)) st3_pa4(.a(st2[11]), .b(st2[12]), .y(st3[12]));
PAdd #(.WORD_WIDTH(4)) st3_pa5(.a(st2[11]), .b(st2[13]), .y(st3[13]));
PAdd #(.WORD_WIDTH(4)) st3_pa6(.a(st2[11]), .b(st2[14]), .y(st3[14]));
PAdd #(.WORD_WIDTH(4)) st3_pa7(.a(st2[11]), .b(st2[15]), .y(st3[15]));
PAdd #(.WORD_WIDTH(4)) st3_pa8(.a(st2[19]), .b(st2[20]), .y(st3[20]));
PAdd #(.WORD_WIDTH(4)) st3_pa9(.a(st2[19]), .b(st2[21]), .y(st3[21]));
PAdd #(.WORD_WIDTH(4)) st3_pa10(.a(st2[19]), .b(st2[22]), .y(st3[22]));
PAdd #(.WORD_WIDTH(4)) st3_pa11(.a(st2[19]), .b(st2[23]), .y(st3[23]));
PAdd #(.WORD_WIDTH(4)) st3_pa12(.a(st2[27]), .b(st2[28]), .y(st3[28]));
PAdd #(.WORD_WIDTH(4)) st3_pa13(.a(st2[27]), .b(st2[29]), .y(st3[29]));
PAdd #(.WORD_WIDTH(4)) st3_pa14(.a(st2[27]), .b(st2[30]), .y(st3[30]));
PAdd #(.WORD_WIDTH(4)) st3_pa15(.a(st2[27]), .b(st2[31]), .y(st3[31]));

assign st3[0] = {4'b0, st2[0]};
assign st3[1] = {4'b0, st2[1]};
assign st3[2] = {4'b0, st2[2]};
assign st3[3] = {4'b0, st2[3]};
assign st3[8] = {4'b0, st2[8]};
assign st3[9] = {4'b0, st2[9]};
assign st3[10] = {4'b0, st2[10]};
assign st3[11] = {4'b0, st2[11]};
assign st3[16] = {4'b0, st2[16]};
assign st3[17] = {4'b0, st2[17]};
assign st3[18] = {4'b0, st2[18]};
assign st3[19] = {4'b0, st2[19]};
assign st3[24] = {4'b0, st2[24]};
assign st3[25] = {4'b0, st2[25]};
assign st3[26] = {4'b0, st2[26]};
assign st3[27] = {4'b0, st2[27]};

// Stage 4
wire [15:0] st4 [0:31];

PAdd #(.WORD_WIDTH(8)) st4_pa0(.a(st3[7]), .b(st3[8]),  .y(st4[8]));
PAdd #(.WORD_WIDTH(8)) st4_pa1(.a(st3[7]), .b(st3[9]),  .y(st4[9]));
PAdd #(.WORD_WIDTH(8)) st4_pa2(.a(st3[7]), .b(st3[10]), .y(st4[10]));
PAdd #(.WORD_WIDTH(8)) st4_pa3(.a(st3[7]), .b(st3[11]), .y(st4[11]));
PAdd #(.WORD_WIDTH(8)) st4_pa4(.a(st3[7]), .b(st3[12]), .y(st4[12]));
PAdd #(.WORD_WIDTH(8)) st4_pa5(.a(st3[7]), .b(st3[13]), .y(st4[13]));
PAdd #(.WORD_WIDTH(8)) st4_pa6(.a(st3[7]), .b(st3[14]), .y(st4[14]));
PAdd #(.WORD_WIDTH(8)) st4_pa7(.a(st3[7]), .b(st3[15]), .y(st4[15]));
PAdd #(.WORD_WIDTH(8)) st4_pa8(.a(st3[23]), .b(st3[24]), .y(st4[24]));
PAdd #(.WORD_WIDTH(8)) st4_pa9(.a(st3[23]), .b(st3[25]), .y(st4[25]));
PAdd #(.WORD_WIDTH(8)) st4_pa10(.a(st3[23]), .b(st3[26]), .y(st4[26]));
PAdd #(.WORD_WIDTH(8)) st4_pa11(.a(st3[23]), .b(st3[27]), .y(st4[27]));
PAdd #(.WORD_WIDTH(8)) st4_pa12(.a(st3[23]), .b(st3[28]), .y(st4[28]));
PAdd #(.WORD_WIDTH(8)) st4_pa13(.a(st3[23]), .b(st3[29]), .y(st4[29]));
PAdd #(.WORD_WIDTH(8)) st4_pa14(.a(st3[23]), .b(st3[30]), .y(st4[30]));
PAdd #(.WORD_WIDTH(8)) st4_pa15(.a(st3[23]), .b(st3[31]), .y(st4[31]));

assign st4[0] = {8'b0, st3[0]};
assign st4[1] = {8'b0, st3[1]};
assign st4[2] = {8'b0, st3[2]};
assign st4[3] = {8'b0, st3[3]};
assign st4[4] = {8'b0, st3[4]};
assign st4[5] = {8'b0, st3[5]};
assign st4[6] = {8'b0, st3[6]};
assign st4[7] = {8'b0, st3[7]};
assign st4[16] = {8'b0, st3[16]};
assign st4[17] = {8'b0, st3[17]};
assign st4[18] = {8'b0, st3[18]};
assign st4[19] = {8'b0, st3[19]};
assign st4[20] = {8'b0, st3[20]};
assign st4[21] = {8'b0, st3[21]};
assign st4[22] = {8'b0, st3[22]};
assign st4[23] = {8'b0, st3[23]};

// Stage 5
wire [31:0] st5 [0:31];

PAdd #(.WORD_WIDTH(16)) st5_pa0(.a(st4[15]), .b(st4[16]), .y(st5[16]));
PAdd #(.WORD_WIDTH(16)) st5_pa1(.a(st4[15]), .b(st4[17]), .y(st5[17]));
PAdd #(.WORD_WIDTH(16)) st5_pa2(.a(st4[15]), .b(st4[18]), .y(st5[18]));
PAdd #(.WORD_WIDTH(16)) st5_pa3(.a(st4[15]), .b(st4[19]), .y(st5[19]));
PAdd #(.WORD_WIDTH(16)) st5_pa4(.a(st4[15]), .b(st4[20]), .y(st5[20]));
PAdd #(.WORD_WIDTH(16)) st5_pa5(.a(st4[15]), .b(st4[21]), .y(st5[21]));
PAdd #(.WORD_WIDTH(16)) st5_pa6(.a(st4[15]), .b(st4[22]), .y(st5[22]));
PAdd #(.WORD_WIDTH(16)) st5_pa7(.a(st4[15]), .b(st4[23]), .y(st5[23]));
PAdd #(.WORD_WIDTH(16)) st5_pa8(.a(st4[15]), .b(st4[24]), .y(st5[24]));
PAdd #(.WORD_WIDTH(16)) st5_pa9(.a(st4[15]), .b(st4[25]), .y(st5[25]));
PAdd #(.WORD_WIDTH(16)) st5_pa10(.a(st4[15]), .b(st4[26]), .y(st5[26]));
PAdd #(.WORD_WIDTH(16)) st5_pa11(.a(st4[15]), .b(st4[27]), .y(st5[27]));
PAdd #(.WORD_WIDTH(16)) st5_pa12(.a(st4[15]), .b(st4[28]), .y(st5[28]));
PAdd #(.WORD_WIDTH(16)) st5_pa13(.a(st4[15]), .b(st4[29]), .y(st5[29]));
PAdd #(.WORD_WIDTH(16)) st5_pa14(.a(st4[15]), .b(st4[30]), .y(st5[30]));
PAdd #(.WORD_WIDTH(16)) st5_pa15(.a(st4[15]), .b(st4[31]), .y(st5[31]));

assign st5[0] = {16'b0, st4[0]};
assign st5[1] = {16'b0, st4[1]};
assign st5[2] = {16'b0, st4[2]};
assign st5[3] = {16'b0, st4[3]};
assign st5[4] = {16'b0, st4[4]};
assign st5[5] = {16'b0, st4[5]};
assign st5[6] = {16'b0, st4[6]};
assign st5[7] = {16'b0, st4[7]};
assign st5[8] = {16'b0, st4[8]};
assign st5[9] = {16'b0, st4[9]};
assign st5[10] = {16'b0, st4[10]};
assign st5[11] = {16'b0, st4[11]};
assign st5[12] = {16'b0, st4[12]};
assign st5[13] = {16'b0, st4[13]};
assign st5[14] = {16'b0, st4[14]};
assign st5[15] = {16'b0, st4[15]};

assign psum[0+:32] = st5[0];
assign psum[32+:32] = st5[1];
assign psum[64+:32] = st5[2];
assign psum[96+:32] = st5[3];
assign psum[128+:32] = st5[4];
assign psum[160+:32] = st5[5];
assign psum[192+:32] = st5[6];
assign psum[224+:32] = st5[7];
assign psum[256+:32] = st5[8];
assign psum[288+:32] = st5[9];
assign psum[320+:32] = st5[10];
assign psum[352+:32] = st5[11];
assign psum[384+:32] = st5[12];
assign psum[416+:32] = st5[13];
assign psum[448+:32] = st5[14];
assign psum[480+:32] = st5[15];
assign psum[512+:32] = st5[16];
assign psum[544+:32] = st5[17];
assign psum[576+:32] = st5[18];
assign psum[608+:32] = st5[19];
assign psum[640+:32] = st5[20];
assign psum[672+:32] = st5[21];
assign psum[704+:32] = st5[22];
assign psum[736+:32] = st5[23];
assign psum[768+:32] = st5[24];
assign psum[800+:32] = st5[25];
assign psum[832+:32] = st5[26];
assign psum[864+:32] = st5[27];
assign psum[896+:32] = st5[28];
assign psum[928+:32] = st5[29];
assign psum[960+:32] = st5[30];
assign psum[992+:32] = st5[31];

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