`include "comb_divider.v"
`include "comb_divider16.v"
`include "comb_multiplier.v"

module DistanceCalculator #(
    parameter WORD_WIDTH = 8,
    parameter DIST_WIDTH = 7,
    parameter MAX_C_SIZE = 128
) (
    input [WORD_WIDTH-1:0] idx1,  // indices: smaller index of redundant weight pair
    input [WORD_WIDTH-1:0] idx2,  // indices: larger index of redundant weight pair

    input [WORD_WIDTH-1:0] ow,  // shapes: output width (OW)
    input [WORD_WIDTH-1:0] fw,  // shapes: filter(kernel) width (FW)
    input [WORD_WIDTH-1:0] st,  // shapes: stride amount (S)

    output [MAX_C_SIZE-1:0] except,  // indicates whether the distance value is exception
    output [DIST_WIDTH-1:0] dr       // distance of redundant output pixel
);

// Calculating dv and dh
wire [WORD_WIDTH-1:0] d,    // lowered filter distance
                      do1,  // quotient of smaller index with FW
                      do2,  // quotient of larger index with FW
                      mo1,  // modulus of smaller index with FW
                      mo2,  // modulus of larger index with FW
                      dv,   // vertical distance within filter matrix
                      dh;   // horizontal distance within filter matrix

assign d = idx2 - idx1;  // d = idx2 - idx1
assign dv = do2 - do1;   // dv = do2 - do1 = (idx2 // FW) - (idx1 // FW)
assign dh = mo2 - mo1;   // dh = mo2 - mo1 = (idx2 % FW) - (idx1 % FW)

CombDivider8 cdiv_do_1 (.lop(idx1), .rop(fw), .quot(do1), .mod(mo1));  // do1 = idx1 // FW
CombDivider8 cdiv_do_2 (.lop(idx2), .rop(fw), .quot(do2), .mod(mo2));  // do2 = idx2 // FW

// Calculating dr
wire [WORD_WIDTH-1:0]   wd;      // difference of OW and FW
wire [2*WORD_WIDTH-1:0] st_exp;  // stride expanded as 16bits
wire [2*WORD_WIDTH-1:0] dr_mul,  // oval = (OW - FW) * dv
                        dr_nst,  // dr without considering stride -> dr_nst = (OW - FW) * dv + d
                        dr_raw,  // dr with 16bits (detect overflow)
                        dr_mod;  // dr modulus (detect stride exception)

assign wd = ow - fw;         // wd = OW - FW
assign dr_nst = dr_mul + d;  // dr_nst = dr_mul + d = (OW - FW) * dv + d
assign st_exp = {8'b0, st};  // zero padding to MSB

CombMultiplier8 cmul_dr (.lop(wd), .rop(dv), .oval(dr_mul));                        // dr_mul = wd * dv = (OW - FW) * dv
CombDivider16   cdiv_dr (.lop(dr_nst), .rop(st_exp), .quot(dr_raw), .mod(dr_mod));  // dr = dr_nst / S = ((OW - FW) * dv + d) / S

// Overflow and Exception
wire                  overflow,         // overflow exception
                      stride_except;    // stride exception

wire [MAX_C_SIZE-1:0] cidx_max_except,  // column index out of range exception (maximum bound)
                      cidx_min_except;  // column indes out of range exception (minimum bound)

wire [WORD_WIDTH-1:0] dv_mod_st,   // dv % S  -> stride exception
                      dh_mod_st,   // dh % S  -> stride exception
                      dh_quot_st;  // dh // S -> out of range exception

wire [WORD_WIDTH-1:0] oc_arr [0:MAX_C_SIZE-1];

CombDivider8WoQuot cdiv_se_dv (.lop(dv), .rop(st), .mod(dv_mod_st));                     // dv / FW
CombDivider8       cdiv_se_dh (.lop(dh), .rop(st), .quot(dh_quot_st), .mod(dh_mod_st));  // dh / FW

assign overflow = (dr_raw[2*WORD_WIDTH-1:DIST_WIDTH] != 0);  // overflow exception: dr is larger than distance width 
assign stride_except = ({dv_mod_st, dh_mod_st} != 0);        // stride exception:   dv % S != 0 or dh % S != 0

genvar citer;
generate
    for (citer = 0; citer < MAX_C_SIZE; citer = citer+1) begin
        CombDivider8WoQuot cdiv_oi_except (.lop(citer[WORD_WIDTH-1:0]), .rop(ow), .mod(oc_arr[citer]));
        assign cidx_max_except[citer] = (oc_arr[citer] < dh_quot_st);
        assign cidx_min_except[citer] = (oc_arr[citer] - dh_quot_st >= ow);
    end
endgenerate 

// Output assignment
assign except = {MAX_C_SIZE{overflow | stride_except}} | cidx_max_except | cidx_min_except;  // check if there exists overflow or stride exception
assign dr     = dr_raw[DIST_WIDTH-1:0];                                                      // distance of redundant output pixels (within flatten output image)

endmodule