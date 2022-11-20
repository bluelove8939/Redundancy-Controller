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
        data_out_r = data_out_w;
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

assign data_out[0]    = s_o;
assign data_out[8:1]  = e_o;
assign data_out[31:9] = m_o;

wire [22:0] m_diff;
assign m_diff = (m_i2 > m_i1) ? (m_i2 - m_i1) : (m_i1 - m_i2);

always @(data_in1 or data_in2) begin
    for ()
end
    
endmodule


module BarrelShifter (
    input [22:0]  data_in,
    input [4:0]   shift_amt,
    output [22:0] data_out,
);

assign data_out = (data_in << shift_amt);

endmodule


module INTAdder #(
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