module LFPrefixAdder32 (  // Ladner-Fischer adder
    input [31:0] mask,

    output [191:0] psum
);

// Stage 1
wire [1:0] st1 [0:31];

PAdd #(.WORD_WIDTH(1)) st1_pa0(.a(mask[0]), .b(mask[1]), .y(st1[1]));
PAdd #(.WORD_WIDTH(1)) st1_pa1(.a(mask[2]), .b(mask[3]), .y(st1[3]));
PAdd #(.WORD_WIDTH(1)) st1_pa2(.a(mask[4]), .b(mask[5]), .y(st1[5]));
PAdd #(.WORD_WIDTH(1)) st1_pa3(.a(mask[6]), .b(mask[7]), .y(st1[7]));
PAdd #(.WORD_WIDTH(1)) st1_pa4(.a(mask[8]), .b(mask[9]), .y(st1[9]));
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
wire [2:0] st2 [0:31];

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

assign st2[0] = {1'b0, st1[0]};
assign st2[1] = {1'b0, st1[1]};
assign st2[4] = {1'b0, st1[4]};
assign st2[5] = {1'b0, st1[5]};
assign st2[8] = {1'b0, st1[8]};
assign st2[9] = {1'b0, st1[9]};
assign st2[12] = {1'b0, st1[12]};
assign st2[13] = {1'b0, st1[13]};
assign st2[16] = {1'b0, st1[16]};
assign st2[17] = {1'b0, st1[17]};
assign st2[20] = {1'b0, st1[20]};
assign st2[21] = {1'b0, st1[21]};
assign st2[24] = {1'b0, st1[24]};
assign st2[25] = {1'b0, st1[25]};
assign st2[28] = {1'b0, st1[28]};
assign st2[29] = {1'b0, st1[29]};

// Stage 3
wire [3:0] st3 [0:31];

PAdd #(.WORD_WIDTH(3)) st3_pa0(.a(st2[3]), .b(st2[4]),  .y(st3[4]));
PAdd #(.WORD_WIDTH(3)) st3_pa1(.a(st2[3]), .b(st2[5]),  .y(st3[5]));
PAdd #(.WORD_WIDTH(3)) st3_pa2(.a(st2[3]), .b(st2[6]),  .y(st3[6]));
PAdd #(.WORD_WIDTH(3)) st3_pa3(.a(st2[3]), .b(st2[7]),  .y(st3[7]));
PAdd #(.WORD_WIDTH(3)) st3_pa4(.a(st2[11]), .b(st2[12]), .y(st3[12]));
PAdd #(.WORD_WIDTH(3)) st3_pa5(.a(st2[11]), .b(st2[13]), .y(st3[13]));
PAdd #(.WORD_WIDTH(3)) st3_pa6(.a(st2[11]), .b(st2[14]), .y(st3[14]));
PAdd #(.WORD_WIDTH(3)) st3_pa7(.a(st2[11]), .b(st2[15]), .y(st3[15]));
PAdd #(.WORD_WIDTH(3)) st3_pa8(.a(st2[19]), .b(st2[20]), .y(st3[20]));
PAdd #(.WORD_WIDTH(3)) st3_pa9(.a(st2[19]), .b(st2[21]), .y(st3[21]));
PAdd #(.WORD_WIDTH(3)) st3_pa10(.a(st2[19]), .b(st2[22]), .y(st3[22]));
PAdd #(.WORD_WIDTH(3)) st3_pa11(.a(st2[19]), .b(st2[23]), .y(st3[23]));
PAdd #(.WORD_WIDTH(3)) st3_pa12(.a(st2[27]), .b(st2[28]), .y(st3[28]));
PAdd #(.WORD_WIDTH(3)) st3_pa13(.a(st2[27]), .b(st2[29]), .y(st3[29]));
PAdd #(.WORD_WIDTH(3)) st3_pa14(.a(st2[27]), .b(st2[30]), .y(st3[30]));
PAdd #(.WORD_WIDTH(3)) st3_pa15(.a(st2[27]), .b(st2[31]), .y(st3[31]));

assign st3[0] = {1'b0, st2[0]};
assign st3[1] = {1'b0, st2[1]};
assign st3[2] = {1'b0, st2[2]};
assign st3[3] = {1'b0, st2[3]};
assign st3[8] = {1'b0, st2[8]};
assign st3[9] = {1'b0, st2[9]};
assign st3[10] = {1'b0, st2[10]};
assign st3[11] = {1'b0, st2[11]};
assign st3[16] = {1'b0, st2[16]};
assign st3[17] = {1'b0, st2[17]};
assign st3[18] = {1'b0, st2[18]};
assign st3[19] = {1'b0, st2[19]};
assign st3[24] = {1'b0, st2[24]};
assign st3[25] = {1'b0, st2[25]};
assign st3[26] = {1'b0, st2[26]};
assign st3[27] = {1'b0, st2[27]};

// Stage 4
wire [4:0] st4 [0:31];

PAdd #(.WORD_WIDTH(4)) st4_pa0(.a(st3[7]), .b(st3[8]),  .y(st4[8]));
PAdd #(.WORD_WIDTH(4)) st4_pa1(.a(st3[7]), .b(st3[9]),  .y(st4[9]));
PAdd #(.WORD_WIDTH(4)) st4_pa2(.a(st3[7]), .b(st3[10]), .y(st4[10]));
PAdd #(.WORD_WIDTH(4)) st4_pa3(.a(st3[7]), .b(st3[11]), .y(st4[11]));
PAdd #(.WORD_WIDTH(4)) st4_pa4(.a(st3[7]), .b(st3[12]), .y(st4[12]));
PAdd #(.WORD_WIDTH(4)) st4_pa5(.a(st3[7]), .b(st3[13]), .y(st4[13]));
PAdd #(.WORD_WIDTH(4)) st4_pa6(.a(st3[7]), .b(st3[14]), .y(st4[14]));
PAdd #(.WORD_WIDTH(4)) st4_pa7(.a(st3[7]), .b(st3[15]), .y(st4[15]));
PAdd #(.WORD_WIDTH(4)) st4_pa8(.a(st3[23]), .b(st3[24]), .y(st4[24]));
PAdd #(.WORD_WIDTH(4)) st4_pa9(.a(st3[23]), .b(st3[25]), .y(st4[25]));
PAdd #(.WORD_WIDTH(4)) st4_pa10(.a(st3[23]), .b(st3[26]), .y(st4[26]));
PAdd #(.WORD_WIDTH(4)) st4_pa11(.a(st3[23]), .b(st3[27]), .y(st4[27]));
PAdd #(.WORD_WIDTH(4)) st4_pa12(.a(st3[23]), .b(st3[28]), .y(st4[28]));
PAdd #(.WORD_WIDTH(4)) st4_pa13(.a(st3[23]), .b(st3[29]), .y(st4[29]));
PAdd #(.WORD_WIDTH(4)) st4_pa14(.a(st3[23]), .b(st3[30]), .y(st4[30]));
PAdd #(.WORD_WIDTH(4)) st4_pa15(.a(st3[23]), .b(st3[31]), .y(st4[31]));

assign st4[0] = {1'b0, st3[0]};
assign st4[1] = {1'b0, st3[1]};
assign st4[2] = {1'b0, st3[2]};
assign st4[3] = {1'b0, st3[3]};
assign st4[4] = {1'b0, st3[4]};
assign st4[5] = {1'b0, st3[5]};
assign st4[6] = {1'b0, st3[6]};
assign st4[7] = {1'b0, st3[7]};
assign st4[16] = {1'b0, st3[16]};
assign st4[17] = {1'b0, st3[17]};
assign st4[18] = {1'b0, st3[18]};
assign st4[19] = {1'b0, st3[19]};
assign st4[20] = {1'b0, st3[20]};
assign st4[21] = {1'b0, st3[21]};
assign st4[22] = {1'b0, st3[22]};
assign st4[23] = {1'b0, st3[23]};

// Stage 5
wire [5:0] st5 [0:31];

PAdd #(.WORD_WIDTH(5)) st5_pa0(.a(st4[15]), .b(st4[16]), .y(st5[16]));
PAdd #(.WORD_WIDTH(5)) st5_pa1(.a(st4[15]), .b(st4[17]), .y(st5[17]));
PAdd #(.WORD_WIDTH(5)) st5_pa2(.a(st4[15]), .b(st4[18]), .y(st5[18]));
PAdd #(.WORD_WIDTH(5)) st5_pa3(.a(st4[15]), .b(st4[19]), .y(st5[19]));
PAdd #(.WORD_WIDTH(5)) st5_pa4(.a(st4[15]), .b(st4[20]), .y(st5[20]));
PAdd #(.WORD_WIDTH(5)) st5_pa5(.a(st4[15]), .b(st4[21]), .y(st5[21]));
PAdd #(.WORD_WIDTH(5)) st5_pa6(.a(st4[15]), .b(st4[22]), .y(st5[22]));
PAdd #(.WORD_WIDTH(5)) st5_pa7(.a(st4[15]), .b(st4[23]), .y(st5[23]));
PAdd #(.WORD_WIDTH(5)) st5_pa8(.a(st4[15]), .b(st4[24]), .y(st5[24]));
PAdd #(.WORD_WIDTH(5)) st5_pa9(.a(st4[15]), .b(st4[25]), .y(st5[25]));
PAdd #(.WORD_WIDTH(5)) st5_pa10(.a(st4[15]), .b(st4[26]), .y(st5[26]));
PAdd #(.WORD_WIDTH(5)) st5_pa11(.a(st4[15]), .b(st4[27]), .y(st5[27]));
PAdd #(.WORD_WIDTH(5)) st5_pa12(.a(st4[15]), .b(st4[28]), .y(st5[28]));
PAdd #(.WORD_WIDTH(5)) st5_pa13(.a(st4[15]), .b(st4[29]), .y(st5[29]));
PAdd #(.WORD_WIDTH(5)) st5_pa14(.a(st4[15]), .b(st4[30]), .y(st5[30]));
PAdd #(.WORD_WIDTH(5)) st5_pa15(.a(st4[15]), .b(st4[31]), .y(st5[31]));

assign st5[0] = {1'b0, st4[0]};
assign st5[1] = {1'b0, st4[1]};
assign st5[2] = {1'b0, st4[2]};
assign st5[3] = {1'b0, st4[3]};
assign st5[4] = {1'b0, st4[4]};
assign st5[5] = {1'b0, st4[5]};
assign st5[6] = {1'b0, st4[6]};
assign st5[7] = {1'b0, st4[7]};
assign st5[8] = {1'b0, st4[8]};
assign st5[9] = {1'b0, st4[9]};
assign st5[10] = {1'b0, st4[10]};
assign st5[11] = {1'b0, st4[11]};
assign st5[12] = {1'b0, st4[12]};
assign st5[13] = {1'b0, st4[13]};
assign st5[14] = {1'b0, st4[14]};
assign st5[15] = {1'b0, st4[15]};

genvar line_idx;

generate
    for (line_idx = 0; line_idx < 32; line_idx = line_idx+1) begin
        assign psum[line_idx*6+:6] = st5[line_idx];
    end
endgenerate

endmodule


module FullAdder (
    input a,
    input b,
    input Cin,

    output s,
    output Cout
);

assign s = a ^ b ^ Cin;
assign Cout = (a & b) | (a & Cin) | (b & Cin);

endmodule


module PAdd #(
    parameter WORD_WIDTH = 1
) (
    input [WORD_WIDTH-1:0] a,
    input [WORD_WIDTH-1:0] b,

    output [WORD_WIDTH:0] y
);

wire [WORD_WIDTH:0] carry;

assign carry[0] = 1'b0;
assign y[WORD_WIDTH] = carry[WORD_WIDTH];

genvar witer;

generate
    for (witer = 0; witer < WORD_WIDTH; witer = witer+1) begin
        FullAdder fadd(.a(a[witer]), .b(b[witer]), .Cin(carry[witer]), .s(y[witer]), .Cout(carry[witer+1]));
    end
endgenerate
    
endmodule