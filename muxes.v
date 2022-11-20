
module MUX2to1 #(
    parameter WORD_WIDTH = 8
) (
    input [WORD_WIDTH-1:0] in_w0, in_w1,
    input [0:0] sel,

    output [WORD_WIDTH-1:0] out_w
);

reg [WORD_WIDTH-1:0] out_r;
assign out_w = out_r;

always @(in_w0 or in_w1 or sel) begin
    case (sel)
        1'd0: out_r <= in_w0;
        1'd1: out_r <= in_w1;
        default: out_r <= in_w1;
    endcase
end

endmodule


module MUX4to1 #(
    parameter WORD_WIDTH = 8
) (
    input [WORD_WIDTH-1:0] in_w0, in_w1, in_w2, in_w3,
    input [1:0] sel,

    output [WORD_WIDTH-1:0] out_w
);

reg [WORD_WIDTH-1:0] out_r;
assign out_w = out_r;

always @(in_w0 or in_w1 or in_w2 or in_w3 or sel) begin
    case (sel)
        2'd0: out_r <= in_w0;
        2'd1: out_r <= in_w1;
        2'd2: out_r <= in_w2;
        2'd3: out_r <= in_w3;
        default: out_r <= in_w3;
    endcase
end

endmodule


module MUX8to1 #(
    parameter WORD_WIDTH = 8
) (
    input [WORD_WIDTH-1:0] in_w0, in_w1, in_w2, in_w3, in_w4, in_w5, in_w6, in_w7,
    input [2:0] sel,

    output [WORD_WIDTH-1:0] out_w
);

reg [WORD_WIDTH-1:0] out_r;
assign out_w = out_r;

always @(in_w0 or in_w1 or in_w2 or in_w3 or in_w4 or in_w5 or in_w6 or in_w7 or sel) begin
    case (sel)
        3'd0: out_r <= in_w0;
        3'd1: out_r <= in_w1;
        3'd2: out_r <= in_w2;
        3'd3: out_r <= in_w3;
        3'd4: out_r <= in_w4;
        3'd5: out_r <= in_w5;
        3'd6: out_r <= in_w6;
        3'd7: out_r <= in_w7;
        default: out_r <= in_w7;
    endcase
end

endmodule


module MUX16to1 #(
    parameter WORD_WIDTH = 8
) (
    input [WORD_WIDTH-1:0] in_w0, in_w1, in_w2, in_w3, in_w4, in_w5, in_w6, in_w7, in_w8, in_w9, in_w10, in_w11, in_w12, in_w13, in_w14, in_w15,
    input [3:0] sel,

    output [WORD_WIDTH-1:0] out_w
);

reg [WORD_WIDTH-1:0] out_r;
assign out_w = out_r;

always @(in_w0 or in_w1 or in_w2 or in_w3 or in_w4 or in_w5 or in_w6 or in_w7 or in_w8 or in_w9 or in_w10 or in_w11 or in_w12 or in_w13 or in_w14 or in_w15 or sel) begin
    case (sel)
        4'd0: out_r <= in_w0;
        4'd1: out_r <= in_w1;
        4'd2: out_r <= in_w2;
        4'd3: out_r <= in_w3;
        4'd4: out_r <= in_w4;
        4'd5: out_r <= in_w5;
        4'd6: out_r <= in_w6;
        4'd7: out_r <= in_w7;
        4'd8: out_r <= in_w8;
        4'd9: out_r <= in_w9;
        4'd10: out_r <= in_w10;
        4'd11: out_r <= in_w11;
        4'd12: out_r <= in_w12;
        4'd13: out_r <= in_w13;
        4'd14: out_r <= in_w14;
        4'd15: out_r <= in_w15;
        default: out_r <= in_w15;
    endcase
end

endmodule


module MUX32to1 #(
    parameter WORD_WIDTH = 8
) (
    input [WORD_WIDTH-1:0] in_w0, in_w1, in_w2, in_w3, in_w4, in_w5, in_w6, in_w7, in_w8, in_w9, in_w10, in_w11, in_w12, in_w13, in_w14, in_w15, in_w16, in_w17, in_w18, in_w19, in_w20, in_w21, in_w22, in_w23, in_w24, in_w25, in_w26, in_w27, in_w28, in_w29, in_w30, in_w31,
    input [4:0] sel,

    output [WORD_WIDTH-1:0] out_w
);

reg [WORD_WIDTH-1:0] out_r;
assign out_w = out_r;

always @(in_w0 or in_w1 or in_w2 or in_w3 or in_w4 or in_w5 or in_w6 or in_w7 or in_w8 or in_w9 or in_w10 or in_w11 or in_w12 or in_w13 or in_w14 or in_w15 or in_w16 or in_w17 or in_w18 or in_w19 or in_w20 or in_w21 or in_w22 or in_w23 or in_w24 or in_w25 or in_w26 or in_w27 or in_w28 or in_w29 or in_w30 or in_w31 or sel) begin
    case (sel)
        5'd0: out_r <= in_w0;
        5'd1: out_r <= in_w1;
        5'd2: out_r <= in_w2;
        5'd3: out_r <= in_w3;
        5'd4: out_r <= in_w4;
        5'd5: out_r <= in_w5;
        5'd6: out_r <= in_w6;
        5'd7: out_r <= in_w7;
        5'd8: out_r <= in_w8;
        5'd9: out_r <= in_w9;
        5'd10: out_r <= in_w10;
        5'd11: out_r <= in_w11;
        5'd12: out_r <= in_w12;
        5'd13: out_r <= in_w13;
        5'd14: out_r <= in_w14;
        5'd15: out_r <= in_w15;
        5'd16: out_r <= in_w16;
        5'd17: out_r <= in_w17;
        5'd18: out_r <= in_w18;
        5'd19: out_r <= in_w19;
        5'd20: out_r <= in_w20;
        5'd21: out_r <= in_w21;
        5'd22: out_r <= in_w22;
        5'd23: out_r <= in_w23;
        5'd24: out_r <= in_w24;
        5'd25: out_r <= in_w25;
        5'd26: out_r <= in_w26;
        5'd27: out_r <= in_w27;
        5'd28: out_r <= in_w28;
        5'd29: out_r <= in_w29;
        5'd30: out_r <= in_w30;
        5'd31: out_r <= in_w31;
        default: out_r <= in_w31;
    endcase
end

endmodule


module MUX64to1 #(
    parameter WORD_WIDTH = 8
) (
    input [WORD_WIDTH-1:0] in_w0, in_w1, in_w2, in_w3, in_w4, in_w5, in_w6, in_w7, in_w8, in_w9, in_w10, in_w11, in_w12, in_w13, in_w14, in_w15, in_w16, in_w17, in_w18, in_w19, in_w20, in_w21, in_w22, in_w23, in_w24, in_w25, in_w26, in_w27, in_w28, in_w29, in_w30, in_w31, in_w32, in_w33, in_w34, in_w35, in_w36, in_w37, in_w38, in_w39, in_w40, in_w41, in_w42, in_w43, in_w44, in_w45, in_w46, in_w47, in_w48, in_w49, in_w50, in_w51, in_w52, in_w53, in_w54, in_w55, in_w56, in_w57, in_w58, in_w59, in_w60, in_w61, in_w62, in_w63,
    input [5:0] sel,

    output [WORD_WIDTH-1:0] out_w
);

reg [WORD_WIDTH-1:0] out_r;
assign out_w = out_r;

always @(in_w0 or in_w1 or in_w2 or in_w3 or in_w4 or in_w5 or in_w6 or in_w7 or in_w8 or in_w9 or in_w10 or in_w11 or in_w12 or in_w13 or in_w14 or in_w15 or in_w16 or in_w17 or in_w18 or in_w19 or in_w20 or in_w21 or in_w22 or in_w23 or in_w24 or in_w25 or in_w26 or in_w27 or in_w28 or in_w29 or in_w30 or in_w31 or in_w32 or in_w33 or in_w34 or in_w35 or in_w36 or in_w37 or in_w38 or in_w39 or in_w40 or in_w41 or in_w42 or in_w43 or in_w44 or in_w45 or in_w46 or in_w47 or in_w48 or in_w49 or in_w50 or in_w51 or in_w52 or in_w53 or in_w54 or in_w55 or in_w56 or in_w57 or in_w58 or in_w59 or in_w60 or in_w61 or in_w62 or in_w63 or sel) begin
    case (sel)
        6'd0: out_r <= in_w0;
        6'd1: out_r <= in_w1;
        6'd2: out_r <= in_w2;
        6'd3: out_r <= in_w3;
        6'd4: out_r <= in_w4;
        6'd5: out_r <= in_w5;
        6'd6: out_r <= in_w6;
        6'd7: out_r <= in_w7;
        6'd8: out_r <= in_w8;
        6'd9: out_r <= in_w9;
        6'd10: out_r <= in_w10;
        6'd11: out_r <= in_w11;
        6'd12: out_r <= in_w12;
        6'd13: out_r <= in_w13;
        6'd14: out_r <= in_w14;
        6'd15: out_r <= in_w15;
        6'd16: out_r <= in_w16;
        6'd17: out_r <= in_w17;
        6'd18: out_r <= in_w18;
        6'd19: out_r <= in_w19;
        6'd20: out_r <= in_w20;
        6'd21: out_r <= in_w21;
        6'd22: out_r <= in_w22;
        6'd23: out_r <= in_w23;
        6'd24: out_r <= in_w24;
        6'd25: out_r <= in_w25;
        6'd26: out_r <= in_w26;
        6'd27: out_r <= in_w27;
        6'd28: out_r <= in_w28;
        6'd29: out_r <= in_w29;
        6'd30: out_r <= in_w30;
        6'd31: out_r <= in_w31;
        6'd32: out_r <= in_w32;
        6'd33: out_r <= in_w33;
        6'd34: out_r <= in_w34;
        6'd35: out_r <= in_w35;
        6'd36: out_r <= in_w36;
        6'd37: out_r <= in_w37;
        6'd38: out_r <= in_w38;
        6'd39: out_r <= in_w39;
        6'd40: out_r <= in_w40;
        6'd41: out_r <= in_w41;
        6'd42: out_r <= in_w42;
        6'd43: out_r <= in_w43;
        6'd44: out_r <= in_w44;
        6'd45: out_r <= in_w45;
        6'd46: out_r <= in_w46;
        6'd47: out_r <= in_w47;
        6'd48: out_r <= in_w48;
        6'd49: out_r <= in_w49;
        6'd50: out_r <= in_w50;
        6'd51: out_r <= in_w51;
        6'd52: out_r <= in_w52;
        6'd53: out_r <= in_w53;
        6'd54: out_r <= in_w54;
        6'd55: out_r <= in_w55;
        6'd56: out_r <= in_w56;
        6'd57: out_r <= in_w57;
        6'd58: out_r <= in_w58;
        6'd59: out_r <= in_w59;
        6'd60: out_r <= in_w60;
        6'd61: out_r <= in_w61;
        6'd62: out_r <= in_w62;
        6'd63: out_r <= in_w63;
        default: out_r <= in_w63;
    endcase
end

endmodule
