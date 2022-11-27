module INT16AdderWrapper (
    input clk,
    input reset_n,
    input [15:0] a, b,

    output cout,
    output [15:0] y
);

wire cout_w;
wire [15:0] y_w;
wire [16:0] out_combined;

assign {cout_w, y_w} = out_combined;

NodeAdder #(.WORD_WIDTH(16)) nadd (
    .a(a), .b(b), .y(out_combined)
);

reg cout_r;
reg [15:0] y_r;

assign cout = cout_w;
assign y = y_r;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        cout_r <= 0;
        y_r <= 0;
    end else begin
        cout_r <= cout_w;
        y_r <= y_w;
    end
end
    
endmodule


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