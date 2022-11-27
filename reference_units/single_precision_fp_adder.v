`include "muxes.v"

module SinglePrecisionFPAdderWrapper (
    input clk, reset_n,
    input [31:0] data_in1, data_in2,
    output [31:0] data_out
);

reg [31:0] data_out_r;
assign data_out = data_out_r;

wire [31:0] data_out_w;

SinglePrecisionFPAdder fp_adder_unit (
    .data_in1(data_in1), .data_in2(data_in2),
    .data_out(data_out_w)
);

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        data_out_r <= 0;
    end else begin
        data_out_r <= data_out_w;
    end
end

endmodule


module SinglePrecisionFPAdder (
    input [31:0] data_in1, data_in2,
    output [31:0] data_out
);

wire        s_i1, s_i2, s_o;
wire [7:0]  e_i1, e_i2, e_o;
wire [22:0] m_i1, m_i2, m_o;

assign s_i1 = data_in1[0];
assign e_i1 = data_in1[8:1];
assign m_i1 = data_in1[31:9];

assign s_i2 = data_in2[0];
assign e_i2 = data_in2[8:1];
assign m_i2 = data_in2[31:9];

assign data_out[0]    = s_o;
assign data_out[8:1]  = e_o;
assign data_out[31:9] = m_o;

// Exponent difference unit
wire       e_borw;  // compares the size of exponent
wire [7:0] e_diff;  // absolute difference of exponent

Subtractor exp_diff_unit (
    .lop(e_i1), .rop(e_i2),
    .borrow(e_borw), .dout(e_diff)
);

// Shift selection
wire [23:0] m_s;   // mantissa not shifted
wire [23:0] m_c1;  // criterion mantissa

assign m_s[23] = 1'b1;
assign m_c1[23] = 1'b1;

MUX2to1 #(.WORD_WIDTH(23)) s_mux_unit (
    .in_w0(m_i2), .in_w1(m_i1),
    .sel(e_borw), .out_w(m_s[22:0])
);

MUX2to1 #(.WORD_WIDTH(23)) c_mux_unit (
    .in_w0(m_i1), .in_w1(m_i2),
    .sel(e_borw), .out_w(m_c1[22:0])
);

// Mantissa Shifter
wire [4:0]  shift_amt;  // shift amount (absolute difference b/w two exponents)
wire [23:0] m_c2;       // shifted mantissa

assign shift_amt = e_diff[4:0];

BarrelShifter mantissa_shifter (
    .data_in(m_s), .shift_amt(shift_amt), .data_out(m_c2)
);

// Mantissa Adder
wire [24:0] add_res;  // result of mantissa addition
wire [23:0] m_a;      // added mantissa
wire        carry;    // carry

assign m_a   = add_res[23:0];
assign carry = add_res[24];

Adder #(.WORD_WIDTH(24)) mantissa_adder (
    .a(m_c1), .b(m_c2), .y(add_res)
);

// Exponent Selector
wire [7:0] e_sel;

MUX2to1 #(.WORD_WIDTH(8)) e_mux_unit (
    .in_w0(e_i1), .in_w1(e_i2),
    .sel(e_borw), .out_w(e_sel)
);

// Exponent Final
wire [7:0] cond_add, e_fin;
wire [8:0] cond_add_res;

assign cond_add = {7'd0, carry};
assign e_fin = cond_add_res[7:0];

Adder #(.WORD_WIDTH(8)) conditional_adder (
    .a(e_sel), .b(cond_add), .y(cond_add_res)
);

// Mantissa Final
wire [4:0]  cond_shift;
wire [23:0] cond_shift_res;
wire [22:0] m_fin;

assign cond_shift = {4'd0, carry};
assign m_fin = cond_shift_res[22:0];

BarrelShifter conditional_shifter (
    .data_in(m_a), .shift_amt(cond_shift), .data_out(cond_shift_res)
);

// Output assignment
assign s_o = 1'b0;
assign e_o = e_fin;
assign m_o = m_fin;
    
endmodule


module BarrelShifter (
    input [23:0]  data_in,
    input [4:0]   shift_amt,
    output [23:0] data_out
);

assign data_out = (data_in << shift_amt);

endmodule


module Subtractor (
    input [7:0] lop, rop,

    output borrow,
    output [7:0] dout
);

assign borrow = (lop > rop) ? 1'b0 : 1'b1;
assign dout = (lop > rop) ? (lop - rop) : (rop - lop);
    
endmodule


module Adder #(
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
    for (witer = 0; witer < WORD_WIDTH; witer = witer+1) begin: FADDERS
        FullAdder fadd(.a(a[witer]), .b(b[witer]), .Cin(carry[witer]), .s(y[witer]), .Cout(carry[witer+1]));
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