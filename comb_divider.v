module CombDivider8 (
    input [7:0] lop,
    input [7:0] rop,

    output [7:0] quot,
    output [7:0] mod
);

// Stage 0
wire [7:0] interm_st0;
wire [7:0] mod_st0;
wire [7:0] lop_st0;
wire [7:0] quot_st0;

assign interm_st0 = { 6'b0, lop[7] };
assign lop_st0 = { lop[6:0], 1'b0 };
assign mod_st0 = interm_st0 >= rop ? (interm_st0 - rop) : interm_st0;
assign quot_st0 = {6'b0, interm_st0 >= rop ? 1'b1 : 1'b0};

// Stage 1
wire [7:0] interm_st1;
wire [7:0] mod_st1;
wire [7:0] lop_st1;
wire [7:0] quot_st1;

assign interm_st1 = { mod_st0[6:0], lop_st0[7] };
assign lop_st1 = { lop_st0[6:0], 1'b0 };
assign mod_st1 = interm_st1 >= rop ? (interm_st1 - rop) : interm_st1;
assign quot_st1 = {quot_st0[6:0], interm_st1 >= rop ? 1'b1 : 1'b0};

// Stage 2
wire [7:0] interm_st2;
wire [7:0] mod_st2;
wire [7:0] lop_st2;
wire [7:0] quot_st2;

assign interm_st2 = { mod_st1[6:0], lop_st1[7] };
assign lop_st2 = { lop_st1[6:0], 1'b0 };
assign mod_st2 = interm_st2 >= rop ? (interm_st2 - rop) : interm_st2;
assign quot_st2 = {quot_st1[6:0], interm_st2 >= rop ? 1'b1 : 1'b0};

// Stage 3
wire [7:0] interm_st3;
wire [7:0] mod_st3;
wire [7:0] lop_st3;
wire [7:0] quot_st3;

assign interm_st3 = { mod_st2[6:0], lop_st2[7] };
assign lop_st3 = { lop_st2[6:0], 1'b0 };
assign mod_st3 = interm_st3 >= rop ? (interm_st3 - rop) : interm_st3;
assign quot_st3 = {quot_st2[6:0], interm_st3 >= rop ? 1'b1 : 1'b0};

// Stage 4
wire [7:0] interm_st4;
wire [7:0] mod_st4;
wire [7:0] lop_st4;
wire [7:0] quot_st4;

assign interm_st4 = { mod_st3[6:0], lop_st3[7] };
assign lop_st4 = { lop_st3[6:0], 1'b0 };
assign mod_st4 = interm_st4 >= rop ? (interm_st4 - rop) : interm_st4;
assign quot_st4 = {quot_st3[6:0], interm_st4 >= rop ? 1'b1 : 1'b0};

// Stage 5
wire [7:0] interm_st5;
wire [7:0] mod_st5;
wire [7:0] lop_st5;
wire [7:0] quot_st5;

assign interm_st5 = { mod_st4[6:0], lop_st4[7] };
assign lop_st5 = { lop_st4[6:0], 1'b0 };
assign mod_st5 = interm_st5 >= rop ? (interm_st5 - rop) : interm_st5;
assign quot_st5 = {quot_st4[6:0], interm_st5 >= rop ? 1'b1 : 1'b0};

// Stage 6
wire [7:0] interm_st6;
wire [7:0] mod_st6;
wire [7:0] lop_st6;
wire [7:0] quot_st6;

assign interm_st6 = { mod_st5[6:0], lop_st5[7] };
assign lop_st6 = { lop_st5[6:0], 1'b0 };
assign mod_st6 = interm_st6 >= rop ? (interm_st6 - rop) : interm_st6;
assign quot_st6 = {quot_st5[6:0], interm_st6 >= rop ? 1'b1 : 1'b0};

// Stage 7
wire [7:0] interm_st7;
wire [7:0] mod_st7;
wire [7:0] lop_st7;
wire [7:0] quot_st7;

assign interm_st7 = { mod_st6[6:0], lop_st6[7] };
assign lop_st7 = { lop_st6[6:0], 1'b0 };
assign mod_st7 = interm_st7 >= rop ? (interm_st7 - rop) : interm_st7;
assign quot_st7 = {quot_st6[6:0], interm_st7 >= rop ? 1'b1 : 1'b0};

assign quot = quot_st7;
assign mod = mod_st7;

endmodule;


module CombDivider8_wo_mod (
    input [7:0] lop,
    input [7:0] rop,

    output [7:0] quot
);

// Stage 0
wire [7:0] interm_st0;
wire [7:0] mod_st0;
wire [7:0] lop_st0;
wire [7:0] quot_st0;

assign interm_st0 = { 6'b0, lop[7] };
assign lop_st0 = { lop[6:0], 1'b0 };
assign mod_st0 = interm_st0 >= rop ? (interm_st0 - rop) : interm_st0;
assign quot_st0 = {6'b0, interm_st0 >= rop ? 1'b1 : 1'b0};

// Stage 1
wire [7:0] interm_st1;
wire [7:0] mod_st1;
wire [7:0] lop_st1;
wire [7:0] quot_st1;

assign interm_st1 = { mod_st0[6:0], lop_st0[7] };
assign lop_st1 = { lop_st0[6:0], 1'b0 };
assign mod_st1 = interm_st1 >= rop ? (interm_st1 - rop) : interm_st1;
assign quot_st1 = {quot_st0[6:0], interm_st1 >= rop ? 1'b1 : 1'b0};

// Stage 2
wire [7:0] interm_st2;
wire [7:0] mod_st2;
wire [7:0] lop_st2;
wire [7:0] quot_st2;

assign interm_st2 = { mod_st1[6:0], lop_st1[7] };
assign lop_st2 = { lop_st1[6:0], 1'b0 };
assign mod_st2 = interm_st2 >= rop ? (interm_st2 - rop) : interm_st2;
assign quot_st2 = {quot_st1[6:0], interm_st2 >= rop ? 1'b1 : 1'b0};

// Stage 3
wire [7:0] interm_st3;
wire [7:0] mod_st3;
wire [7:0] lop_st3;
wire [7:0] quot_st3;

assign interm_st3 = { mod_st2[6:0], lop_st2[7] };
assign lop_st3 = { lop_st2[6:0], 1'b0 };
assign mod_st3 = interm_st3 >= rop ? (interm_st3 - rop) : interm_st3;
assign quot_st3 = {quot_st2[6:0], interm_st3 >= rop ? 1'b1 : 1'b0};

// Stage 4
wire [7:0] interm_st4;
wire [7:0] mod_st4;
wire [7:0] lop_st4;
wire [7:0] quot_st4;

assign interm_st4 = { mod_st3[6:0], lop_st3[7] };
assign lop_st4 = { lop_st3[6:0], 1'b0 };
assign mod_st4 = interm_st4 >= rop ? (interm_st4 - rop) : interm_st4;
assign quot_st4 = {quot_st3[6:0], interm_st4 >= rop ? 1'b1 : 1'b0};

// Stage 5
wire [7:0] interm_st5;
wire [7:0] mod_st5;
wire [7:0] lop_st5;
wire [7:0] quot_st5;

assign interm_st5 = { mod_st4[6:0], lop_st4[7] };
assign lop_st5 = { lop_st4[6:0], 1'b0 };
assign mod_st5 = interm_st5 >= rop ? (interm_st5 - rop) : interm_st5;
assign quot_st5 = {quot_st4[6:0], interm_st5 >= rop ? 1'b1 : 1'b0};

// Stage 6
wire [7:0] interm_st6;
wire [7:0] mod_st6;
wire [7:0] lop_st6;
wire [7:0] quot_st6;

assign interm_st6 = { mod_st5[6:0], lop_st5[7] };
assign lop_st6 = { lop_st5[6:0], 1'b0 };
assign mod_st6 = interm_st6 >= rop ? (interm_st6 - rop) : interm_st6;
assign quot_st6 = {quot_st5[6:0], interm_st6 >= rop ? 1'b1 : 1'b0};

// Stage 7
wire [7:0] interm_st7;
wire [7:0] lop_st7;
wire [7:0] quot_st7;

assign interm_st7 = { mod_st6[6:0], lop_st6[7] };
assign lop_st7 = { lop_st6[6:0], 1'b0 };
assign quot_st7 = {quot_st6[6:0], interm_st7 >= rop ? 1'b1 : 1'b0};

assign quot = quot_st7;

endmodule;