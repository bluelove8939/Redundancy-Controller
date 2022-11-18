
module CombDivider16 (
    input [15:0] lop,
    input [15:0] rop,

    output [15:0] quot,
    output [15:0] mod
);

// Stage 0
wire [15:0] interm_st0;
wire [15:0] mod_st0;
wire [15:0] lop_st0;
wire [15:0] quot_st0;

assign interm_st0 = { 14'b0, lop[15] };
assign lop_st0 = { lop[14:0], 1'b0 };
assign mod_st0 = interm_st0 >= rop ? (interm_st0 - rop) : interm_st0;
assign quot_st0 = {14'b0, interm_st0 >= rop ? 1'b1 : 1'b0};

// Stage 1
wire [15:0] interm_st1;
wire [15:0] mod_st1;
wire [15:0] lop_st1;
wire [15:0] quot_st1;

assign interm_st1 = { mod_st0[14:0], lop_st0[15] };
assign lop_st1 = { lop_st0[14:0], 1'b0 };
assign mod_st1 = interm_st1 >= rop ? (interm_st1 - rop) : interm_st1;
assign quot_st1 = {quot_st0[14:0], interm_st1 >= rop ? 1'b1 : 1'b0};

// Stage 2
wire [15:0] interm_st2;
wire [15:0] mod_st2;
wire [15:0] lop_st2;
wire [15:0] quot_st2;

assign interm_st2 = { mod_st1[14:0], lop_st1[15] };
assign lop_st2 = { lop_st1[14:0], 1'b0 };
assign mod_st2 = interm_st2 >= rop ? (interm_st2 - rop) : interm_st2;
assign quot_st2 = {quot_st1[14:0], interm_st2 >= rop ? 1'b1 : 1'b0};

// Stage 3
wire [15:0] interm_st3;
wire [15:0] mod_st3;
wire [15:0] lop_st3;
wire [15:0] quot_st3;

assign interm_st3 = { mod_st2[14:0], lop_st2[15] };
assign lop_st3 = { lop_st2[14:0], 1'b0 };
assign mod_st3 = interm_st3 >= rop ? (interm_st3 - rop) : interm_st3;
assign quot_st3 = {quot_st2[14:0], interm_st3 >= rop ? 1'b1 : 1'b0};

// Stage 4
wire [15:0] interm_st4;
wire [15:0] mod_st4;
wire [15:0] lop_st4;
wire [15:0] quot_st4;

assign interm_st4 = { mod_st3[14:0], lop_st3[15] };
assign lop_st4 = { lop_st3[14:0], 1'b0 };
assign mod_st4 = interm_st4 >= rop ? (interm_st4 - rop) : interm_st4;
assign quot_st4 = {quot_st3[14:0], interm_st4 >= rop ? 1'b1 : 1'b0};

// Stage 5
wire [15:0] interm_st5;
wire [15:0] mod_st5;
wire [15:0] lop_st5;
wire [15:0] quot_st5;

assign interm_st5 = { mod_st4[14:0], lop_st4[15] };
assign lop_st5 = { lop_st4[14:0], 1'b0 };
assign mod_st5 = interm_st5 >= rop ? (interm_st5 - rop) : interm_st5;
assign quot_st5 = {quot_st4[14:0], interm_st5 >= rop ? 1'b1 : 1'b0};

// Stage 6
wire [15:0] interm_st6;
wire [15:0] mod_st6;
wire [15:0] lop_st6;
wire [15:0] quot_st6;

assign interm_st6 = { mod_st5[14:0], lop_st5[15] };
assign lop_st6 = { lop_st5[14:0], 1'b0 };
assign mod_st6 = interm_st6 >= rop ? (interm_st6 - rop) : interm_st6;
assign quot_st6 = {quot_st5[14:0], interm_st6 >= rop ? 1'b1 : 1'b0};

// Stage 7
wire [15:0] interm_st7;
wire [15:0] mod_st7;
wire [15:0] lop_st7;
wire [15:0] quot_st7;

assign interm_st7 = { mod_st6[14:0], lop_st6[15] };
assign lop_st7 = { lop_st6[14:0], 1'b0 };
assign mod_st7 = interm_st7 >= rop ? (interm_st7 - rop) : interm_st7;
assign quot_st7 = {quot_st6[14:0], interm_st7 >= rop ? 1'b1 : 1'b0};

// Stage 8
wire [15:0] interm_st8;
wire [15:0] mod_st8;
wire [15:0] lop_st8;
wire [15:0] quot_st8;

assign interm_st8 = { mod_st7[14:0], lop_st7[15] };
assign lop_st8 = { lop_st7[14:0], 1'b0 };
assign mod_st8 = interm_st8 >= rop ? (interm_st8 - rop) : interm_st8;
assign quot_st8 = {quot_st7[14:0], interm_st8 >= rop ? 1'b1 : 1'b0};

// Stage 9
wire [15:0] interm_st9;
wire [15:0] mod_st9;
wire [15:0] lop_st9;
wire [15:0] quot_st9;

assign interm_st9 = { mod_st8[14:0], lop_st8[15] };
assign lop_st9 = { lop_st8[14:0], 1'b0 };
assign mod_st9 = interm_st9 >= rop ? (interm_st9 - rop) : interm_st9;
assign quot_st9 = {quot_st8[14:0], interm_st9 >= rop ? 1'b1 : 1'b0};

// Stage 10
wire [15:0] interm_st10;
wire [15:0] mod_st10;
wire [15:0] lop_st10;
wire [15:0] quot_st10;

assign interm_st10 = { mod_st9[14:0], lop_st9[15] };
assign lop_st10 = { lop_st9[14:0], 1'b0 };
assign mod_st10 = interm_st10 >= rop ? (interm_st10 - rop) : interm_st10;
assign quot_st10 = {quot_st9[14:0], interm_st10 >= rop ? 1'b1 : 1'b0};

// Stage 11
wire [15:0] interm_st11;
wire [15:0] mod_st11;
wire [15:0] lop_st11;
wire [15:0] quot_st11;

assign interm_st11 = { mod_st10[14:0], lop_st10[15] };
assign lop_st11 = { lop_st10[14:0], 1'b0 };
assign mod_st11 = interm_st11 >= rop ? (interm_st11 - rop) : interm_st11;
assign quot_st11 = {quot_st10[14:0], interm_st11 >= rop ? 1'b1 : 1'b0};

// Stage 12
wire [15:0] interm_st12;
wire [15:0] mod_st12;
wire [15:0] lop_st12;
wire [15:0] quot_st12;

assign interm_st12 = { mod_st11[14:0], lop_st11[15] };
assign lop_st12 = { lop_st11[14:0], 1'b0 };
assign mod_st12 = interm_st12 >= rop ? (interm_st12 - rop) : interm_st12;
assign quot_st12 = {quot_st11[14:0], interm_st12 >= rop ? 1'b1 : 1'b0};

// Stage 13
wire [15:0] interm_st13;
wire [15:0] mod_st13;
wire [15:0] lop_st13;
wire [15:0] quot_st13;

assign interm_st13 = { mod_st12[14:0], lop_st12[15] };
assign lop_st13 = { lop_st12[14:0], 1'b0 };
assign mod_st13 = interm_st13 >= rop ? (interm_st13 - rop) : interm_st13;
assign quot_st13 = {quot_st12[14:0], interm_st13 >= rop ? 1'b1 : 1'b0};

// Stage 14
wire [15:0] interm_st14;
wire [15:0] mod_st14;
wire [15:0] lop_st14;
wire [15:0] quot_st14;

assign interm_st14 = { mod_st13[14:0], lop_st13[15] };
assign lop_st14 = { lop_st13[14:0], 1'b0 };
assign mod_st14 = interm_st14 >= rop ? (interm_st14 - rop) : interm_st14;
assign quot_st14 = {quot_st13[14:0], interm_st14 >= rop ? 1'b1 : 1'b0};

// Stage 15
wire [15:0] interm_st15;
wire [15:0] mod_st15;
wire [15:0] lop_st15;
wire [15:0] quot_st15;

assign interm_st15 = { mod_st14[14:0], lop_st14[15] };
assign lop_st15 = { lop_st14[14:0], 1'b0 };
assign mod_st15 = interm_st15 >= rop ? (interm_st15 - rop) : interm_st15;
assign quot_st15 = {quot_st14[14:0], interm_st15 >= rop ? 1'b1 : 1'b0};

assign quot = quot_st15;
assign mod = mod_st15;

endmodule