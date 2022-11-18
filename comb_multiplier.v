module CombMultiplier8 (
    input [7:0] lop,
    input [7:0] rop,

    output [15:0] oval
);

assign oval = lop * rop;

endmodule;