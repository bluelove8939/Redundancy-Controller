`include "comb_divider.v"
`include "comb_divider16.v"
`include "comb_multiplier.v"

module DistanceCalculator #(
    parameter WORD_WIDTH = 8,
    parameter DIST_WIDTH = 7
) (
    input [WORD_WIDTH-1:0] idx1,  // indices: smaller index of redundant weight pair
    input [WORD_WIDTH-1:0] idx2,  // indices: larger index of redundant weight pair

    input [WORD_WIDTH-1:0] ow,  // shapes: output width (OW)
    input [WORD_WIDTH-1:0] fw,  // shapes: filter(kernel) width (FW)
    input [WORD_WIDTH-1:0] st,  // shapes: stride amount (S)

    output valid,  // indicates whether the value is valid (including stride exception)

    output [DIST_WIDTH-1:0] dr
);

// Calculating dv
wire [WORD_WIDTH-1:0] d,    // lowered filter distance
                      do1,  // quotient of smaller index with FW
                      do2,  // quotient of larger index with FW
                      dv;   // vertical distance within filter matrix

assign d = idx2 - idx1;  // d = idx2 - idx1
assign dv = do2 - do1;   // dv = do2 - do1 = (idx2 // FW) - (idx1 // FW)

CombDivider8_wo_mod cdiv_wo_mod_1 (.lop(idx1), .rop(fw), .quot(do1));  // do1 = idx1 // FW
CombDivider8_wo_mod cdiv_wo_mod_2 (.lop(idx2), .rop(fw), .quot(do2));  // do2 = idx2 // FW

// Calculating dr
wire [WORD_WIDTH-1:0]   wd;      // difference of OW and FW
wire [2*WORD_WIDTH-1:0] st_exp;  // stride expanded as 16bits
wire [2*WORD_WIDTH-1:0] dr_mul,  // oval = (OW - FW) * dv
                        dr_nst,  // dr without considering stride -> dr_nst = (OW - FW) * dv + d
                        dr_raw,  // dr with 16bits (detect overflow)
                        dr_mod;  // dr modulus (detect stride exception)

assign wd = ow - fw;         // wd = OW - FW
assign dr_nst = dr_mul + d;  // dr_nst = dr_mul + d = (OW - FW) * dv + d
assign st_exp = {8'b0, st};

CombMultiplier8 cmul_dr (.lop(wd), .rop(dv), .oval(dr_mul));                    // dr_mul = wd * dv = (OW - FW) * dv
CombDivider16   cdiv_dr (.lop(dr_nst), .rop(st_exp), .quot(dr_raw), .mod(dr_mod));  // dr = dr_nst / S = ((OW - FW) * dv + d) / S

// Output assignment
assign valid = ~(|{dr_raw[2*WORD_WIDTH-1:DIST_WIDTH], dr_mod});
assign dr    = dr_raw[DIST_WIDTH-1:0];

endmodule