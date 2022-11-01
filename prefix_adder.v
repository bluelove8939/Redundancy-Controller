`include "nodeadder.v"

module LFPrefixSum128 (  // Ladner-Fischer
    input [127:0] mask,

    output [1024:0] psum
);

genvar line_idx;

// Stage 1
wire [1:0] st1 [0:127];

generate
    for (line_idx = 0; line_idx < 128; line_idx = line_idx+1) begin
        if (line_idx % 2 != 0) begin
            NodeAdder #(.WORD_WIDTH(1)) st1_pa(.a(mask[line_idx-1]), .b(mask[line_idx]), .y(st1[line_idx]));
        end else begin
            assign st1[line_idx]  = {1'b0, mask[line_idx]};
        end
    end
endgenerate

// Stage 2
wire [2:0] st2 [0:127];

generate
    for (line_idx = 0; line_idx < 128; line_idx = line_idx+1) begin
        if ((line_idx / 2) % 2 != 0) begin
            NodeAdder #(.WORD_WIDTH(2)) st2_pa(.a(st1[line_idx - 1 - (line_idx % 2)]), .b(st1[line_idx]), .y(st2[line_idx]));
        end else begin
            assign st2[line_idx]  = {1'b0, st1[line_idx]};
        end
    end
endgenerate

// Stage 3
wire [3:0] st3 [0:127];

generate
    for (line_idx = 0; line_idx < 128; line_idx = line_idx+1) begin
        if ((line_idx / 4) % 2 != 0) begin
            NodeAdder #(.WORD_WIDTH(3)) st3_pa(.a(st2[line_idx - 1 - (line_idx % 4)]), .b(st2[line_idx]), .y(st3[line_idx]));
        end else begin
            assign st3[line_idx]  = {1'b0, st2[line_idx]};
        end
    end
endgenerate

// Stage 4
wire [4:0] st4 [0:127];

generate
    for (line_idx = 0; line_idx < 128; line_idx = line_idx+1) begin
        if ((line_idx / 8) % 2 != 0) begin
            NodeAdder #(.WORD_WIDTH(4)) st4_pa(.a(st3[line_idx - 1 - (line_idx % 8)]), .b(st3[line_idx]), .y(st4[line_idx]));
        end else begin
            assign st4[line_idx]  = {1'b0, st3[line_idx]};
        end
    end
endgenerate

// Stage 5
wire [5:0] st5 [0:127];

generate
    for (line_idx = 0; line_idx < 128; line_idx = line_idx+1) begin
        if ((line_idx / 16) % 2 != 0) begin
            NodeAdder #(.WORD_WIDTH(5)) st5_pa(.a(st4[line_idx - 1 - (line_idx % 16)]), .b(st4[line_idx]), .y(st5[line_idx]));
        end else begin
            assign st5[line_idx]  = {1'b0, st4[line_idx]};
        end
    end
endgenerate

// Stage 6
wire [6:0] st6 [0:127];

generate
    for (line_idx = 0; line_idx < 128; line_idx = line_idx+1) begin
        if ((line_idx / 32) % 2 != 0) begin
            NodeAdder #(.WORD_WIDTH(6)) st6_pa(.a(st5[line_idx - 1 - (line_idx % 32)]), .b(st5[line_idx]), .y(st6[line_idx]));
        end else begin
            assign st6[line_idx]  = {1'b0, st5[line_idx]};
        end
    end
endgenerate

// Stage 7
wire [7:0] st7 [0:127];

generate
    for (line_idx = 0; line_idx < 128; line_idx = line_idx+1) begin
        if ((line_idx / 64) % 2 != 0) begin
            NodeAdder #(.WORD_WIDTH(7)) st7_pa(.a(st6[line_idx - 1 - (line_idx % 64)]), .b(st6[line_idx]), .y(st7[line_idx]));
        end else begin
            assign st7[line_idx]  = {1'b0, st6[line_idx]};
        end
    end
endgenerate

// Output link
generate
    for (line_idx = 0; line_idx < 128; line_idx = line_idx+1) begin
        assign psum[line_idx*8+:8] = st7[line_idx];
    end
endgenerate

endmodule