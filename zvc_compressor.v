`include "prefix_adder.v"

module ZVCompressor #(
    parameter WORD_WIDTH    = 8,
    parameter LINE_SIZE     = 128,
    parameter DIST_WIDTH    = 7,
    parameter MAX_LIFM_RSIZ = 4    // maximum row size of LIFM
) (
    input clk,
    input reset_n,
    
    input [LINE_SIZE*WORD_WIDTH-1:0]               lifm_line,
    input [LINE_SIZE*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_line,

    output [LINE_SIZE*WORD_WIDTH-1:0]               lifm_comp,
    output [LINE_SIZE*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_comp
);

// Pipeline1: Generate zero mask and bubble index with prefix adder
wire [127:0] mask;
wire [1023:0] psum;

reg [LINE_SIZE*WORD_WIDTH-1:0]               lifm_pipe1;  // pipeline registers: LOWERED IFM
reg [LINE_SIZE*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_pipe1;    // pipeline registers: MAPPING TABLE

reg [1023:0] psum_pipe1;  // pipeline registers: PREFIX SUM

LFPrefixSum128 padder(.mask(mask), .psum(psum));

genvar line_idx;
generate
    for (line_idx = 0; line_idx < LINE_SIZE; line_idx = line_idx+1) begin
        assign mask[line_idx] = (mt_line[DIST_WIDTH*MAX_LIFM_RSIZ*line_idx+:DIST_WIDTH*MAX_LIFM_RSIZ] != 0);
    end
endgenerate

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        lifm_pipe1 <= 0;
        mt_pipe1 <= 0;
        psum_pipe1 <= 0;
    end

    else begin
        lifm_pipe1 <= lifm_line;
        mt_pipe1 <= mt_line;
        psum_pipe1 <= psum;
    end
end

// Pipeline2: Bubble-collapsing Shifter
reg [LINE_SIZE*WORD_WIDTH-1:0]               lifm_pipe2;  // pipeline registers: LOWERED IFM
reg [LINE_SIZE*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_pipe2;    // pipeline registers: MAPPING TABLE

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        lifm_pipe2 <= 0;
        mt_pipe2 <= 0;
    end

    else begin
        lifm_pipe2 <= lifm_pipe1;
        mt_pipe2 <= mt_pipe1;
    end
end

assign lifm_comp = lifm_pipe2;
assign mt_comp = mt_pipe2;
    
endmodule

// module LFPrefixSum128 (  // Ladner-Fischer
//     input [127:0] mask,

//     output [1023:0] psum
// );

// // Stage 1
// wire [1:0] st1 [0:127];

// genvar st1_iter;
// generate
//     for (st1_iter = 0; st1_iter < 128; st1_iter = st1_iter+1) begin: ST1_ITER
//         if (st1_iter % 2 != 0) begin: ST1_SUMS
//             NodeAdder #(.WORD_WIDTH(1)) st1_pa(.a(mask[st1_iter-1]), .b(mask[st1_iter]), .y(st1[st1_iter]));
//         end else begin: ST1_WIRES
//             assign st1[st1_iter]  = {1'b0, mask[st1_iter]};
//         end
//     end
// endgenerate

// // Stage 2
// wire [2:0] st2 [0:127];

// genvar st2_iter;
// generate
//     for (st2_iter = 0; st2_iter < 128; st2_iter = st2_iter+1) begin: ST2_ITER
//         if ((st2_iter / 2) % 2 != 0) begin: ST2_SUMS
//             NodeAdder #(.WORD_WIDTH(2)) st2_pa(.a(st1[st2_iter - 1 - (st2_iter % 2)]), .b(st1[st2_iter]), .y(st2[st2_iter]));
//         end else begin: ST2_WIRES
//             assign st2[st2_iter]  = {1'b0, st1[st2_iter]};
//         end
//     end
// endgenerate

// // Stage 3
// wire [3:0] st3 [0:127];

// genvar st3_iter;
// generate
//     for (st3_iter = 0; st3_iter < 128; st3_iter = st3_iter+1) begin: ST3_ITER
//         if ((st3_iter / 4) % 2 != 0) begin: ST3_SUMS
//             NodeAdder #(.WORD_WIDTH(3)) st3_pa(.a(st2[st3_iter - 1 - (st3_iter % 4)]), .b(st2[st3_iter]), .y(st3[st3_iter]));
//         end else begin: ST3_WIRES
//             assign st3[st3_iter]  = {1'b0, st2[st3_iter]};
//         end
//     end
// endgenerate

// // Stage 4
// wire [4:0] st4 [0:127];

// genvar st4_iter;
// generate
//     for (st4_iter = 0; st4_iter < 128; st4_iter = st4_iter+1) begin: ST4_ITER
//         if ((st4_iter / 8) % 2 != 0) begin: ST4_SUMS
//             NodeAdder #(.WORD_WIDTH(4)) st4_pa(.a(st3[st4_iter - 1 - (st4_iter % 8)]), .b(st3[st4_iter]), .y(st4[st4_iter]));
//         end else begin: ST4_WIRES
//             assign st4[st4_iter]  = {1'b0, st3[st4_iter]};
//         end
//     end
// endgenerate

// // Stage 5
// wire [5:0] st5 [0:127];

// genvar st5_iter;
// generate
//     for (st5_iter = 0; st5_iter < 128; st5_iter = st5_iter+1) begin: ST5_ITER
//         if ((st5_iter / 16) % 2 != 0) begin: ST5_SUMS
//             NodeAdder #(.WORD_WIDTH(5)) st5_pa(.a(st4[st5_iter - 1 - (st5_iter % 16)]), .b(st4[st5_iter]), .y(st5[st5_iter]));
//         end else begin: ST5_WIRES
//             assign st5[st5_iter]  = {1'b0, st4[st5_iter]};
//         end
//     end
// endgenerate

// // Stage 6
// wire [6:0] st6 [0:127];

// genvar st6_iter;
// generate
//     for (st6_iter = 0; st6_iter < 128; st6_iter = st6_iter+1) begin: ST6_ITER
//         if ((st6_iter / 32) % 2 != 0) begin: ST6_SUMS
//             NodeAdder #(.WORD_WIDTH(6)) st6_pa(.a(st5[st6_iter - 1 - (st6_iter % 32)]), .b(st5[st6_iter]), .y(st6[st6_iter]));
//         end else begin: ST6_WIRES
//             assign st6[st6_iter]  = {1'b0, st5[st6_iter]};
//         end
//     end
// endgenerate

// // Stage 7
// wire [7:0] st7 [0:127];

// genvar st7_iter;
// generate
//     for (st7_iter = 0; st7_iter < 128; st7_iter = st7_iter+1) begin: ST7_ITER
//         if ((st7_iter / 64) % 2 != 0) begin: ST7_SUMS
//             NodeAdder #(.WORD_WIDTH(7)) st7_pa(.a(st6[st7_iter - 1 - (st7_iter % 64)]), .b(st6[st7_iter]), .y(st7[st7_iter]));
//         end else begin: ST7_WIRES
//             assign st7[st7_iter]  = {1'b0, st6[st7_iter]};
//         end
//     end
// endgenerate

// // Output link
// genvar out_iter;
// generate
//     for (out_iter = 0; out_iter < 128; out_iter = out_iter+1) begin: OUT_ASSIGN
//         assign psum[out_iter*8+:8] = st7[out_iter];
//     end
// endgenerate

// endmodule

// module NodeAdder #(
//     parameter WORD_WIDTH = 1
// ) (
//     input [WORD_WIDTH-1:0] a,
//     input [WORD_WIDTH-1:0] b,

//     output [WORD_WIDTH:0] y
// );

// wire [WORD_WIDTH:0] carry;

// assign carry[0] = 1'b0;
// assign y[WORD_WIDTH] = carry[WORD_WIDTH];

// genvar witer;

// generate
//     for (witer = 0; witer < WORD_WIDTH; witer = witer+1) begin: FADDERS
//         FullAdder fadd(.a(a[witer]), .b(b[witer]), .Cin(carry[witer]), .s(y[witer]), .Cout(carry[witer+1]));
//     end
// endgenerate
    
// endmodule

// module FullAdder (
//     input a,
//     input b,
//     input Cin,

//     output s,
//     output Cout
// );

// assign s = a ^ b ^ Cin;
// assign Cout = (a & b) | (a & Cin) | (b & Cin);

// endmodule