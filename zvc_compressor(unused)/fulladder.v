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