`include "fulladder.v"

module NodeAdder #(
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