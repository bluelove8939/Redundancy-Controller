`include "nodeadder.v"

module LFPrefixSum128 (  // Ladner-Fischer
    input [127:0] mask,

    output [1023:0] psum
);

// Stage 1
wire [1:0] st1 [0:127];

genvar st1_iter;
generate
    for (st1_iter = 0; st1_iter < 128; st1_iter = st1_iter+1) begin: ST1_ITER
        if (st1_iter % 2 != 0) begin: ST1_SUMS
            NodeAdder #(.WORD_WIDTH(1)) st1_pa(.a(mask[st1_iter-1]), .b(mask[st1_iter]), .y(st1[st1_iter]));
        end else begin: ST1_WIRES
            assign st1[st1_iter]  = {1'b0, mask[st1_iter]};
        end
    end
endgenerate

// Stage 2
wire [2:0] st2 [0:127];

genvar st2_iter;
generate
    for (st2_iter = 0; st2_iter < 128; st2_iter = st2_iter+1) begin: ST2_ITER
        if ((st2_iter / 2) % 2 != 0) begin: ST2_SUMS
            NodeAdder #(.WORD_WIDTH(2)) st2_pa(.a(st1[st2_iter - 1 - (st2_iter % 2)]), .b(st1[st2_iter]), .y(st2[st2_iter]));
        end else begin: ST2_WIRES
            assign st2[st2_iter]  = {1'b0, st1[st2_iter]};
        end
    end
endgenerate

// Stage 3
wire [3:0] st3 [0:127];

genvar st3_iter;
generate
    for (st3_iter = 0; st3_iter < 128; st3_iter = st3_iter+1) begin: ST3_ITER
        if ((st3_iter / 4) % 2 != 0) begin: ST3_SUMS
            NodeAdder #(.WORD_WIDTH(3)) st3_pa(.a(st2[st3_iter - 1 - (st3_iter % 4)]), .b(st2[st3_iter]), .y(st3[st3_iter]));
        end else begin: ST3_WIRES
            assign st3[st3_iter]  = {1'b0, st2[st3_iter]};
        end
    end
endgenerate

// Stage 4
wire [4:0] st4 [0:127];

genvar st4_iter;
generate
    for (st4_iter = 0; st4_iter < 128; st4_iter = st4_iter+1) begin: ST4_ITER
        if ((st4_iter / 8) % 2 != 0) begin: ST4_SUMS
            NodeAdder #(.WORD_WIDTH(4)) st4_pa(.a(st3[st4_iter - 1 - (st4_iter % 8)]), .b(st3[st4_iter]), .y(st4[st4_iter]));
        end else begin: ST4_WIRES
            assign st4[st4_iter]  = {1'b0, st3[st4_iter]};
        end
    end
endgenerate

// Stage 5
wire [5:0] st5 [0:127];

genvar st5_iter;
generate
    for (st5_iter = 0; st5_iter < 128; st5_iter = st5_iter+1) begin: ST5_ITER
        if ((st5_iter / 16) % 2 != 0) begin: ST5_SUMS
            NodeAdder #(.WORD_WIDTH(5)) st5_pa(.a(st4[st5_iter - 1 - (st5_iter % 16)]), .b(st4[st5_iter]), .y(st5[st5_iter]));
        end else begin: ST5_WIRES
            assign st5[st5_iter]  = {1'b0, st4[st5_iter]};
        end
    end
endgenerate

// Stage 6
wire [6:0] st6 [0:127];

genvar st6_iter;
generate
    for (st6_iter = 0; st6_iter < 128; st6_iter = st6_iter+1) begin: ST6_ITER
        if ((st6_iter / 32) % 2 != 0) begin: ST6_SUMS
            NodeAdder #(.WORD_WIDTH(6)) st6_pa(.a(st5[st6_iter - 1 - (st6_iter % 32)]), .b(st5[st6_iter]), .y(st6[st6_iter]));
        end else begin: ST6_WIRES
            assign st6[st6_iter]  = {1'b0, st5[st6_iter]};
        end
    end
endgenerate

// Stage 7
wire [7:0] st7 [0:127];

genvar st7_iter;
generate
    for (st7_iter = 0; st7_iter < 128; st7_iter = st7_iter+1) begin: ST7_ITER
        if ((st7_iter / 64) % 2 != 0) begin: ST7_SUMS
            NodeAdder #(.WORD_WIDTH(7)) st7_pa(.a(st6[st7_iter - 1 - (st7_iter % 64)]), .b(st6[st7_iter]), .y(st7[st7_iter]));
        end else begin: ST7_WIRES
            assign st7[st7_iter]  = {1'b0, st6[st7_iter]};
        end
    end
endgenerate

// Output link
genvar out_iter;
generate
    for (out_iter = 0; out_iter < 128; out_iter = out_iter+1) begin: OUT_ASSIGN
        assign psum[out_iter*8+:8] = st7[out_iter];
    end
endgenerate

endmodule