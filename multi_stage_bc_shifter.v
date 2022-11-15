module MSBCShifter128 #(  // Bubble-Collapsing Shifter
    parameter WORD_WIDTH    = 8,
    parameter PSUM_WIDTH    = 7,
    parameter DIST_WIDTH    = 7,
    parameter MAX_LIFM_RSIZ = 4
) (
    input [128*PSUM_WIDTH-1:0] psum,

    input [128*WORD_WIDTH-1:0]               lifm_line,
    input [128*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_line,

    output [128*WORD_WIDTH-1:0]               lifm_comp,
    output [128*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_comp
);


// Stage0
wire [128*WORD_WIDTH-1:0] lifm_st0_wi;  // stage input for LIFM
wire [128*WORD_WIDTH-1:0] lifm_st0_wo;  // stage output of LIFM
wire [128*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_st0_wi;  // stage input for MT
wire [128*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_st0_wo;  // stage output of MT

assign lifm_st0_wi = lifm_line;
assign mt_st0_wi = mt_line;

// Stage0 Index0
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx0;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx0;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx0;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx0;
wire [1-1:0] i_dist_st0_idx0;

assign i_lifm_st0_idx0 = { lifm_st0_wi[WORD_WIDTH*2-1:WORD_WIDTH*1], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx0   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx0 = psum[PSUM_WIDTH*1-1:PSUM_WIDTH*0];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx0 (
    .i_vec(i_lifm_st0_idx0), .stride(i_dist_st0_idx0), .o_vec(o_lifm_st0_idx0)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx0 (
    .i_vec(i_mt_st0_idx0), .stride(i_dist_st0_idx0), .o_vec(o_mt_st0_idx0)
);

assign lifm_st0_wo[WORD_WIDTH*2-1:WORD_WIDTH*1] = o_lifm_st0_idx0[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*1-1:WORD_WIDTH*0] = o_lifm_st0_idx0[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*1-1:WORD_WIDTH*0];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1] = o_mt_st0_idx0[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:DIST_WIDTH*MAX_LIFM_RSIZ*0] = o_mt_st0_idx0[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:DIST_WIDTH*MAX_LIFM_RSIZ*0];


// Stage0 Index1
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx1;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx1;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx1;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx1;
wire [1-1:0] i_dist_st0_idx1;

assign i_lifm_st0_idx1 = { lifm_st0_wi[WORD_WIDTH*4-1:WORD_WIDTH*3], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx1   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*3], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx1 = psum[PSUM_WIDTH*3-1:PSUM_WIDTH*2] - psum[PSUM_WIDTH*2-1:PSUM_WIDTH*1];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx1 (
    .i_vec(i_lifm_st0_idx1), .stride(i_dist_st0_idx1), .o_vec(o_lifm_st0_idx1)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx1 (
    .i_vec(i_mt_st0_idx1), .stride(i_dist_st0_idx1), .o_vec(o_mt_st0_idx1)
);

assign lifm_st0_wo[WORD_WIDTH*4-1:WORD_WIDTH*3] = o_lifm_st0_idx1[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*3-1:WORD_WIDTH*2] = o_lifm_st0_idx1[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*3-1:WORD_WIDTH*2];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*3] = o_mt_st0_idx1[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*3-1:DIST_WIDTH*MAX_LIFM_RSIZ*2] = o_mt_st0_idx1[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*3-1:DIST_WIDTH*MAX_LIFM_RSIZ*2];


// Stage0 Index2
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx2;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx2;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx2;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx2;
wire [1-1:0] i_dist_st0_idx2;

assign i_lifm_st0_idx2 = { lifm_st0_wi[WORD_WIDTH*6-1:WORD_WIDTH*5], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx2   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*6-1:DIST_WIDTH*MAX_LIFM_RSIZ*5], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx2 = psum[PSUM_WIDTH*5-1:PSUM_WIDTH*4] - psum[PSUM_WIDTH*4-1:PSUM_WIDTH*3];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx2 (
    .i_vec(i_lifm_st0_idx2), .stride(i_dist_st0_idx2), .o_vec(o_lifm_st0_idx2)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx2 (
    .i_vec(i_mt_st0_idx2), .stride(i_dist_st0_idx2), .o_vec(o_mt_st0_idx2)
);

assign lifm_st0_wo[WORD_WIDTH*6-1:WORD_WIDTH*5] = o_lifm_st0_idx2[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*5-1:WORD_WIDTH*4] = o_lifm_st0_idx2[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*5-1:WORD_WIDTH*4];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*6-1:DIST_WIDTH*MAX_LIFM_RSIZ*5] = o_mt_st0_idx2[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*5-1:DIST_WIDTH*MAX_LIFM_RSIZ*4] = o_mt_st0_idx2[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*5-1:DIST_WIDTH*MAX_LIFM_RSIZ*4];


// Stage0 Index3
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx3;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx3;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx3;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx3;
wire [1-1:0] i_dist_st0_idx3;

assign i_lifm_st0_idx3 = { lifm_st0_wi[WORD_WIDTH*8-1:WORD_WIDTH*7], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx3   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*8-1:DIST_WIDTH*MAX_LIFM_RSIZ*7], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx3 = psum[PSUM_WIDTH*7-1:PSUM_WIDTH*6] - psum[PSUM_WIDTH*6-1:PSUM_WIDTH*5];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx3 (
    .i_vec(i_lifm_st0_idx3), .stride(i_dist_st0_idx3), .o_vec(o_lifm_st0_idx3)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx3 (
    .i_vec(i_mt_st0_idx3), .stride(i_dist_st0_idx3), .o_vec(o_mt_st0_idx3)
);

assign lifm_st0_wo[WORD_WIDTH*8-1:WORD_WIDTH*7] = o_lifm_st0_idx3[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*7-1:WORD_WIDTH*6] = o_lifm_st0_idx3[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*7-1:WORD_WIDTH*6];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*8-1:DIST_WIDTH*MAX_LIFM_RSIZ*7] = o_mt_st0_idx3[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*7-1:DIST_WIDTH*MAX_LIFM_RSIZ*6] = o_mt_st0_idx3[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*7-1:DIST_WIDTH*MAX_LIFM_RSIZ*6];


// Stage0 Index4
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx4;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx4;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx4;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx4;
wire [1-1:0] i_dist_st0_idx4;

assign i_lifm_st0_idx4 = { lifm_st0_wi[WORD_WIDTH*10-1:WORD_WIDTH*9], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx4   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*10-1:DIST_WIDTH*MAX_LIFM_RSIZ*9], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx4 = psum[PSUM_WIDTH*9-1:PSUM_WIDTH*8] - psum[PSUM_WIDTH*8-1:PSUM_WIDTH*7];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx4 (
    .i_vec(i_lifm_st0_idx4), .stride(i_dist_st0_idx4), .o_vec(o_lifm_st0_idx4)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx4 (
    .i_vec(i_mt_st0_idx4), .stride(i_dist_st0_idx4), .o_vec(o_mt_st0_idx4)
);

assign lifm_st0_wo[WORD_WIDTH*10-1:WORD_WIDTH*9] = o_lifm_st0_idx4[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*9-1:WORD_WIDTH*8] = o_lifm_st0_idx4[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*9-1:WORD_WIDTH*8];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*10-1:DIST_WIDTH*MAX_LIFM_RSIZ*9] = o_mt_st0_idx4[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*9-1:DIST_WIDTH*MAX_LIFM_RSIZ*8] = o_mt_st0_idx4[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*9-1:DIST_WIDTH*MAX_LIFM_RSIZ*8];


// Stage0 Index5
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx5;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx5;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx5;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx5;
wire [1-1:0] i_dist_st0_idx5;

assign i_lifm_st0_idx5 = { lifm_st0_wi[WORD_WIDTH*12-1:WORD_WIDTH*11], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx5   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*12-1:DIST_WIDTH*MAX_LIFM_RSIZ*11], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx5 = psum[PSUM_WIDTH*11-1:PSUM_WIDTH*10] - psum[PSUM_WIDTH*10-1:PSUM_WIDTH*9];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx5 (
    .i_vec(i_lifm_st0_idx5), .stride(i_dist_st0_idx5), .o_vec(o_lifm_st0_idx5)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx5 (
    .i_vec(i_mt_st0_idx5), .stride(i_dist_st0_idx5), .o_vec(o_mt_st0_idx5)
);

assign lifm_st0_wo[WORD_WIDTH*12-1:WORD_WIDTH*11] = o_lifm_st0_idx5[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*11-1:WORD_WIDTH*10] = o_lifm_st0_idx5[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*11-1:WORD_WIDTH*10];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*12-1:DIST_WIDTH*MAX_LIFM_RSIZ*11] = o_mt_st0_idx5[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*11-1:DIST_WIDTH*MAX_LIFM_RSIZ*10] = o_mt_st0_idx5[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*11-1:DIST_WIDTH*MAX_LIFM_RSIZ*10];


// Stage0 Index6
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx6;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx6;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx6;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx6;
wire [1-1:0] i_dist_st0_idx6;

assign i_lifm_st0_idx6 = { lifm_st0_wi[WORD_WIDTH*14-1:WORD_WIDTH*13], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx6   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*14-1:DIST_WIDTH*MAX_LIFM_RSIZ*13], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx6 = psum[PSUM_WIDTH*13-1:PSUM_WIDTH*12] - psum[PSUM_WIDTH*12-1:PSUM_WIDTH*11];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx6 (
    .i_vec(i_lifm_st0_idx6), .stride(i_dist_st0_idx6), .o_vec(o_lifm_st0_idx6)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx6 (
    .i_vec(i_mt_st0_idx6), .stride(i_dist_st0_idx6), .o_vec(o_mt_st0_idx6)
);

assign lifm_st0_wo[WORD_WIDTH*14-1:WORD_WIDTH*13] = o_lifm_st0_idx6[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*13-1:WORD_WIDTH*12] = o_lifm_st0_idx6[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*13-1:WORD_WIDTH*12];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*14-1:DIST_WIDTH*MAX_LIFM_RSIZ*13] = o_mt_st0_idx6[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*13-1:DIST_WIDTH*MAX_LIFM_RSIZ*12] = o_mt_st0_idx6[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*13-1:DIST_WIDTH*MAX_LIFM_RSIZ*12];


// Stage0 Index7
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx7;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx7;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx7;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx7;
wire [1-1:0] i_dist_st0_idx7;

assign i_lifm_st0_idx7 = { lifm_st0_wi[WORD_WIDTH*16-1:WORD_WIDTH*15], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx7   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*16-1:DIST_WIDTH*MAX_LIFM_RSIZ*15], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx7 = psum[PSUM_WIDTH*15-1:PSUM_WIDTH*14] - psum[PSUM_WIDTH*14-1:PSUM_WIDTH*13];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx7 (
    .i_vec(i_lifm_st0_idx7), .stride(i_dist_st0_idx7), .o_vec(o_lifm_st0_idx7)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx7 (
    .i_vec(i_mt_st0_idx7), .stride(i_dist_st0_idx7), .o_vec(o_mt_st0_idx7)
);

assign lifm_st0_wo[WORD_WIDTH*16-1:WORD_WIDTH*15] = o_lifm_st0_idx7[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*15-1:WORD_WIDTH*14] = o_lifm_st0_idx7[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*15-1:WORD_WIDTH*14];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*16-1:DIST_WIDTH*MAX_LIFM_RSIZ*15] = o_mt_st0_idx7[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*15-1:DIST_WIDTH*MAX_LIFM_RSIZ*14] = o_mt_st0_idx7[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*15-1:DIST_WIDTH*MAX_LIFM_RSIZ*14];


// Stage0 Index8
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx8;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx8;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx8;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx8;
wire [1-1:0] i_dist_st0_idx8;

assign i_lifm_st0_idx8 = { lifm_st0_wi[WORD_WIDTH*18-1:WORD_WIDTH*17], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx8   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*18-1:DIST_WIDTH*MAX_LIFM_RSIZ*17], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx8 = psum[PSUM_WIDTH*17-1:PSUM_WIDTH*16] - psum[PSUM_WIDTH*16-1:PSUM_WIDTH*15];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx8 (
    .i_vec(i_lifm_st0_idx8), .stride(i_dist_st0_idx8), .o_vec(o_lifm_st0_idx8)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx8 (
    .i_vec(i_mt_st0_idx8), .stride(i_dist_st0_idx8), .o_vec(o_mt_st0_idx8)
);

assign lifm_st0_wo[WORD_WIDTH*18-1:WORD_WIDTH*17] = o_lifm_st0_idx8[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*17-1:WORD_WIDTH*16] = o_lifm_st0_idx8[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*17-1:WORD_WIDTH*16];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*18-1:DIST_WIDTH*MAX_LIFM_RSIZ*17] = o_mt_st0_idx8[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*17-1:DIST_WIDTH*MAX_LIFM_RSIZ*16] = o_mt_st0_idx8[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*17-1:DIST_WIDTH*MAX_LIFM_RSIZ*16];


// Stage0 Index9
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx9;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx9;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx9;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx9;
wire [1-1:0] i_dist_st0_idx9;

assign i_lifm_st0_idx9 = { lifm_st0_wi[WORD_WIDTH*20-1:WORD_WIDTH*19], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx9   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*20-1:DIST_WIDTH*MAX_LIFM_RSIZ*19], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx9 = psum[PSUM_WIDTH*19-1:PSUM_WIDTH*18] - psum[PSUM_WIDTH*18-1:PSUM_WIDTH*17];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx9 (
    .i_vec(i_lifm_st0_idx9), .stride(i_dist_st0_idx9), .o_vec(o_lifm_st0_idx9)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx9 (
    .i_vec(i_mt_st0_idx9), .stride(i_dist_st0_idx9), .o_vec(o_mt_st0_idx9)
);

assign lifm_st0_wo[WORD_WIDTH*20-1:WORD_WIDTH*19] = o_lifm_st0_idx9[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*19-1:WORD_WIDTH*18] = o_lifm_st0_idx9[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*19-1:WORD_WIDTH*18];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*20-1:DIST_WIDTH*MAX_LIFM_RSIZ*19] = o_mt_st0_idx9[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*19-1:DIST_WIDTH*MAX_LIFM_RSIZ*18] = o_mt_st0_idx9[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*19-1:DIST_WIDTH*MAX_LIFM_RSIZ*18];


// Stage0 Index10
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx10;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx10;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx10;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx10;
wire [1-1:0] i_dist_st0_idx10;

assign i_lifm_st0_idx10 = { lifm_st0_wi[WORD_WIDTH*22-1:WORD_WIDTH*21], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx10   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*22-1:DIST_WIDTH*MAX_LIFM_RSIZ*21], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx10 = psum[PSUM_WIDTH*21-1:PSUM_WIDTH*20] - psum[PSUM_WIDTH*20-1:PSUM_WIDTH*19];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx10 (
    .i_vec(i_lifm_st0_idx10), .stride(i_dist_st0_idx10), .o_vec(o_lifm_st0_idx10)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx10 (
    .i_vec(i_mt_st0_idx10), .stride(i_dist_st0_idx10), .o_vec(o_mt_st0_idx10)
);

assign lifm_st0_wo[WORD_WIDTH*22-1:WORD_WIDTH*21] = o_lifm_st0_idx10[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*21-1:WORD_WIDTH*20] = o_lifm_st0_idx10[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*21-1:WORD_WIDTH*20];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*22-1:DIST_WIDTH*MAX_LIFM_RSIZ*21] = o_mt_st0_idx10[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*21-1:DIST_WIDTH*MAX_LIFM_RSIZ*20] = o_mt_st0_idx10[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*21-1:DIST_WIDTH*MAX_LIFM_RSIZ*20];


// Stage0 Index11
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx11;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx11;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx11;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx11;
wire [1-1:0] i_dist_st0_idx11;

assign i_lifm_st0_idx11 = { lifm_st0_wi[WORD_WIDTH*24-1:WORD_WIDTH*23], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx11   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*24-1:DIST_WIDTH*MAX_LIFM_RSIZ*23], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx11 = psum[PSUM_WIDTH*23-1:PSUM_WIDTH*22] - psum[PSUM_WIDTH*22-1:PSUM_WIDTH*21];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx11 (
    .i_vec(i_lifm_st0_idx11), .stride(i_dist_st0_idx11), .o_vec(o_lifm_st0_idx11)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx11 (
    .i_vec(i_mt_st0_idx11), .stride(i_dist_st0_idx11), .o_vec(o_mt_st0_idx11)
);

assign lifm_st0_wo[WORD_WIDTH*24-1:WORD_WIDTH*23] = o_lifm_st0_idx11[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*23-1:WORD_WIDTH*22] = o_lifm_st0_idx11[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*23-1:WORD_WIDTH*22];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*24-1:DIST_WIDTH*MAX_LIFM_RSIZ*23] = o_mt_st0_idx11[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*23-1:DIST_WIDTH*MAX_LIFM_RSIZ*22] = o_mt_st0_idx11[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*23-1:DIST_WIDTH*MAX_LIFM_RSIZ*22];


// Stage0 Index12
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx12;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx12;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx12;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx12;
wire [1-1:0] i_dist_st0_idx12;

assign i_lifm_st0_idx12 = { lifm_st0_wi[WORD_WIDTH*26-1:WORD_WIDTH*25], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx12   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*26-1:DIST_WIDTH*MAX_LIFM_RSIZ*25], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx12 = psum[PSUM_WIDTH*25-1:PSUM_WIDTH*24] - psum[PSUM_WIDTH*24-1:PSUM_WIDTH*23];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx12 (
    .i_vec(i_lifm_st0_idx12), .stride(i_dist_st0_idx12), .o_vec(o_lifm_st0_idx12)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx12 (
    .i_vec(i_mt_st0_idx12), .stride(i_dist_st0_idx12), .o_vec(o_mt_st0_idx12)
);

assign lifm_st0_wo[WORD_WIDTH*26-1:WORD_WIDTH*25] = o_lifm_st0_idx12[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*25-1:WORD_WIDTH*24] = o_lifm_st0_idx12[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*25-1:WORD_WIDTH*24];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*26-1:DIST_WIDTH*MAX_LIFM_RSIZ*25] = o_mt_st0_idx12[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*25-1:DIST_WIDTH*MAX_LIFM_RSIZ*24] = o_mt_st0_idx12[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*25-1:DIST_WIDTH*MAX_LIFM_RSIZ*24];


// Stage0 Index13
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx13;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx13;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx13;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx13;
wire [1-1:0] i_dist_st0_idx13;

assign i_lifm_st0_idx13 = { lifm_st0_wi[WORD_WIDTH*28-1:WORD_WIDTH*27], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx13   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*28-1:DIST_WIDTH*MAX_LIFM_RSIZ*27], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx13 = psum[PSUM_WIDTH*27-1:PSUM_WIDTH*26] - psum[PSUM_WIDTH*26-1:PSUM_WIDTH*25];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx13 (
    .i_vec(i_lifm_st0_idx13), .stride(i_dist_st0_idx13), .o_vec(o_lifm_st0_idx13)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx13 (
    .i_vec(i_mt_st0_idx13), .stride(i_dist_st0_idx13), .o_vec(o_mt_st0_idx13)
);

assign lifm_st0_wo[WORD_WIDTH*28-1:WORD_WIDTH*27] = o_lifm_st0_idx13[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*27-1:WORD_WIDTH*26] = o_lifm_st0_idx13[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*27-1:WORD_WIDTH*26];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*28-1:DIST_WIDTH*MAX_LIFM_RSIZ*27] = o_mt_st0_idx13[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*27-1:DIST_WIDTH*MAX_LIFM_RSIZ*26] = o_mt_st0_idx13[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*27-1:DIST_WIDTH*MAX_LIFM_RSIZ*26];


// Stage0 Index14
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx14;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx14;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx14;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx14;
wire [1-1:0] i_dist_st0_idx14;

assign i_lifm_st0_idx14 = { lifm_st0_wi[WORD_WIDTH*30-1:WORD_WIDTH*29], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx14   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*30-1:DIST_WIDTH*MAX_LIFM_RSIZ*29], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx14 = psum[PSUM_WIDTH*29-1:PSUM_WIDTH*28] - psum[PSUM_WIDTH*28-1:PSUM_WIDTH*27];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx14 (
    .i_vec(i_lifm_st0_idx14), .stride(i_dist_st0_idx14), .o_vec(o_lifm_st0_idx14)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx14 (
    .i_vec(i_mt_st0_idx14), .stride(i_dist_st0_idx14), .o_vec(o_mt_st0_idx14)
);

assign lifm_st0_wo[WORD_WIDTH*30-1:WORD_WIDTH*29] = o_lifm_st0_idx14[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*29-1:WORD_WIDTH*28] = o_lifm_st0_idx14[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*29-1:WORD_WIDTH*28];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*30-1:DIST_WIDTH*MAX_LIFM_RSIZ*29] = o_mt_st0_idx14[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*29-1:DIST_WIDTH*MAX_LIFM_RSIZ*28] = o_mt_st0_idx14[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*29-1:DIST_WIDTH*MAX_LIFM_RSIZ*28];


// Stage0 Index15
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx15;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx15;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx15;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx15;
wire [1-1:0] i_dist_st0_idx15;

assign i_lifm_st0_idx15 = { lifm_st0_wi[WORD_WIDTH*32-1:WORD_WIDTH*31], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx15   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*32-1:DIST_WIDTH*MAX_LIFM_RSIZ*31], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx15 = psum[PSUM_WIDTH*31-1:PSUM_WIDTH*30] - psum[PSUM_WIDTH*30-1:PSUM_WIDTH*29];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx15 (
    .i_vec(i_lifm_st0_idx15), .stride(i_dist_st0_idx15), .o_vec(o_lifm_st0_idx15)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx15 (
    .i_vec(i_mt_st0_idx15), .stride(i_dist_st0_idx15), .o_vec(o_mt_st0_idx15)
);

assign lifm_st0_wo[WORD_WIDTH*32-1:WORD_WIDTH*31] = o_lifm_st0_idx15[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*31-1:WORD_WIDTH*30] = o_lifm_st0_idx15[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*31-1:WORD_WIDTH*30];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*32-1:DIST_WIDTH*MAX_LIFM_RSIZ*31] = o_mt_st0_idx15[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*31-1:DIST_WIDTH*MAX_LIFM_RSIZ*30] = o_mt_st0_idx15[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*31-1:DIST_WIDTH*MAX_LIFM_RSIZ*30];


// Stage0 Index16
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx16;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx16;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx16;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx16;
wire [1-1:0] i_dist_st0_idx16;

assign i_lifm_st0_idx16 = { lifm_st0_wi[WORD_WIDTH*34-1:WORD_WIDTH*33], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx16   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*34-1:DIST_WIDTH*MAX_LIFM_RSIZ*33], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx16 = psum[PSUM_WIDTH*33-1:PSUM_WIDTH*32] - psum[PSUM_WIDTH*32-1:PSUM_WIDTH*31];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx16 (
    .i_vec(i_lifm_st0_idx16), .stride(i_dist_st0_idx16), .o_vec(o_lifm_st0_idx16)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx16 (
    .i_vec(i_mt_st0_idx16), .stride(i_dist_st0_idx16), .o_vec(o_mt_st0_idx16)
);

assign lifm_st0_wo[WORD_WIDTH*34-1:WORD_WIDTH*33] = o_lifm_st0_idx16[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*33-1:WORD_WIDTH*32] = o_lifm_st0_idx16[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*33-1:WORD_WIDTH*32];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*34-1:DIST_WIDTH*MAX_LIFM_RSIZ*33] = o_mt_st0_idx16[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*33-1:DIST_WIDTH*MAX_LIFM_RSIZ*32] = o_mt_st0_idx16[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*33-1:DIST_WIDTH*MAX_LIFM_RSIZ*32];


// Stage0 Index17
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx17;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx17;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx17;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx17;
wire [1-1:0] i_dist_st0_idx17;

assign i_lifm_st0_idx17 = { lifm_st0_wi[WORD_WIDTH*36-1:WORD_WIDTH*35], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx17   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*36-1:DIST_WIDTH*MAX_LIFM_RSIZ*35], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx17 = psum[PSUM_WIDTH*35-1:PSUM_WIDTH*34] - psum[PSUM_WIDTH*34-1:PSUM_WIDTH*33];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx17 (
    .i_vec(i_lifm_st0_idx17), .stride(i_dist_st0_idx17), .o_vec(o_lifm_st0_idx17)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx17 (
    .i_vec(i_mt_st0_idx17), .stride(i_dist_st0_idx17), .o_vec(o_mt_st0_idx17)
);

assign lifm_st0_wo[WORD_WIDTH*36-1:WORD_WIDTH*35] = o_lifm_st0_idx17[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*35-1:WORD_WIDTH*34] = o_lifm_st0_idx17[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*35-1:WORD_WIDTH*34];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*36-1:DIST_WIDTH*MAX_LIFM_RSIZ*35] = o_mt_st0_idx17[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*35-1:DIST_WIDTH*MAX_LIFM_RSIZ*34] = o_mt_st0_idx17[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*35-1:DIST_WIDTH*MAX_LIFM_RSIZ*34];


// Stage0 Index18
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx18;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx18;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx18;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx18;
wire [1-1:0] i_dist_st0_idx18;

assign i_lifm_st0_idx18 = { lifm_st0_wi[WORD_WIDTH*38-1:WORD_WIDTH*37], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx18   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*38-1:DIST_WIDTH*MAX_LIFM_RSIZ*37], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx18 = psum[PSUM_WIDTH*37-1:PSUM_WIDTH*36] - psum[PSUM_WIDTH*36-1:PSUM_WIDTH*35];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx18 (
    .i_vec(i_lifm_st0_idx18), .stride(i_dist_st0_idx18), .o_vec(o_lifm_st0_idx18)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx18 (
    .i_vec(i_mt_st0_idx18), .stride(i_dist_st0_idx18), .o_vec(o_mt_st0_idx18)
);

assign lifm_st0_wo[WORD_WIDTH*38-1:WORD_WIDTH*37] = o_lifm_st0_idx18[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*37-1:WORD_WIDTH*36] = o_lifm_st0_idx18[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*37-1:WORD_WIDTH*36];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*38-1:DIST_WIDTH*MAX_LIFM_RSIZ*37] = o_mt_st0_idx18[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*37-1:DIST_WIDTH*MAX_LIFM_RSIZ*36] = o_mt_st0_idx18[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*37-1:DIST_WIDTH*MAX_LIFM_RSIZ*36];


// Stage0 Index19
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx19;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx19;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx19;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx19;
wire [1-1:0] i_dist_st0_idx19;

assign i_lifm_st0_idx19 = { lifm_st0_wi[WORD_WIDTH*40-1:WORD_WIDTH*39], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx19   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*40-1:DIST_WIDTH*MAX_LIFM_RSIZ*39], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx19 = psum[PSUM_WIDTH*39-1:PSUM_WIDTH*38] - psum[PSUM_WIDTH*38-1:PSUM_WIDTH*37];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx19 (
    .i_vec(i_lifm_st0_idx19), .stride(i_dist_st0_idx19), .o_vec(o_lifm_st0_idx19)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx19 (
    .i_vec(i_mt_st0_idx19), .stride(i_dist_st0_idx19), .o_vec(o_mt_st0_idx19)
);

assign lifm_st0_wo[WORD_WIDTH*40-1:WORD_WIDTH*39] = o_lifm_st0_idx19[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*39-1:WORD_WIDTH*38] = o_lifm_st0_idx19[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*39-1:WORD_WIDTH*38];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*40-1:DIST_WIDTH*MAX_LIFM_RSIZ*39] = o_mt_st0_idx19[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*39-1:DIST_WIDTH*MAX_LIFM_RSIZ*38] = o_mt_st0_idx19[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*39-1:DIST_WIDTH*MAX_LIFM_RSIZ*38];


// Stage0 Index20
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx20;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx20;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx20;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx20;
wire [1-1:0] i_dist_st0_idx20;

assign i_lifm_st0_idx20 = { lifm_st0_wi[WORD_WIDTH*42-1:WORD_WIDTH*41], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx20   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*42-1:DIST_WIDTH*MAX_LIFM_RSIZ*41], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx20 = psum[PSUM_WIDTH*41-1:PSUM_WIDTH*40] - psum[PSUM_WIDTH*40-1:PSUM_WIDTH*39];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx20 (
    .i_vec(i_lifm_st0_idx20), .stride(i_dist_st0_idx20), .o_vec(o_lifm_st0_idx20)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx20 (
    .i_vec(i_mt_st0_idx20), .stride(i_dist_st0_idx20), .o_vec(o_mt_st0_idx20)
);

assign lifm_st0_wo[WORD_WIDTH*42-1:WORD_WIDTH*41] = o_lifm_st0_idx20[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*41-1:WORD_WIDTH*40] = o_lifm_st0_idx20[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*41-1:WORD_WIDTH*40];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*42-1:DIST_WIDTH*MAX_LIFM_RSIZ*41] = o_mt_st0_idx20[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*41-1:DIST_WIDTH*MAX_LIFM_RSIZ*40] = o_mt_st0_idx20[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*41-1:DIST_WIDTH*MAX_LIFM_RSIZ*40];


// Stage0 Index21
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx21;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx21;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx21;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx21;
wire [1-1:0] i_dist_st0_idx21;

assign i_lifm_st0_idx21 = { lifm_st0_wi[WORD_WIDTH*44-1:WORD_WIDTH*43], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx21   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*44-1:DIST_WIDTH*MAX_LIFM_RSIZ*43], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx21 = psum[PSUM_WIDTH*43-1:PSUM_WIDTH*42] - psum[PSUM_WIDTH*42-1:PSUM_WIDTH*41];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx21 (
    .i_vec(i_lifm_st0_idx21), .stride(i_dist_st0_idx21), .o_vec(o_lifm_st0_idx21)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx21 (
    .i_vec(i_mt_st0_idx21), .stride(i_dist_st0_idx21), .o_vec(o_mt_st0_idx21)
);

assign lifm_st0_wo[WORD_WIDTH*44-1:WORD_WIDTH*43] = o_lifm_st0_idx21[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*43-1:WORD_WIDTH*42] = o_lifm_st0_idx21[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*43-1:WORD_WIDTH*42];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*44-1:DIST_WIDTH*MAX_LIFM_RSIZ*43] = o_mt_st0_idx21[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*43-1:DIST_WIDTH*MAX_LIFM_RSIZ*42] = o_mt_st0_idx21[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*43-1:DIST_WIDTH*MAX_LIFM_RSIZ*42];


// Stage0 Index22
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx22;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx22;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx22;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx22;
wire [1-1:0] i_dist_st0_idx22;

assign i_lifm_st0_idx22 = { lifm_st0_wi[WORD_WIDTH*46-1:WORD_WIDTH*45], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx22   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*46-1:DIST_WIDTH*MAX_LIFM_RSIZ*45], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx22 = psum[PSUM_WIDTH*45-1:PSUM_WIDTH*44] - psum[PSUM_WIDTH*44-1:PSUM_WIDTH*43];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx22 (
    .i_vec(i_lifm_st0_idx22), .stride(i_dist_st0_idx22), .o_vec(o_lifm_st0_idx22)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx22 (
    .i_vec(i_mt_st0_idx22), .stride(i_dist_st0_idx22), .o_vec(o_mt_st0_idx22)
);

assign lifm_st0_wo[WORD_WIDTH*46-1:WORD_WIDTH*45] = o_lifm_st0_idx22[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*45-1:WORD_WIDTH*44] = o_lifm_st0_idx22[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*45-1:WORD_WIDTH*44];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*46-1:DIST_WIDTH*MAX_LIFM_RSIZ*45] = o_mt_st0_idx22[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*45-1:DIST_WIDTH*MAX_LIFM_RSIZ*44] = o_mt_st0_idx22[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*45-1:DIST_WIDTH*MAX_LIFM_RSIZ*44];


// Stage0 Index23
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx23;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx23;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx23;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx23;
wire [1-1:0] i_dist_st0_idx23;

assign i_lifm_st0_idx23 = { lifm_st0_wi[WORD_WIDTH*48-1:WORD_WIDTH*47], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx23   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*48-1:DIST_WIDTH*MAX_LIFM_RSIZ*47], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx23 = psum[PSUM_WIDTH*47-1:PSUM_WIDTH*46] - psum[PSUM_WIDTH*46-1:PSUM_WIDTH*45];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx23 (
    .i_vec(i_lifm_st0_idx23), .stride(i_dist_st0_idx23), .o_vec(o_lifm_st0_idx23)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx23 (
    .i_vec(i_mt_st0_idx23), .stride(i_dist_st0_idx23), .o_vec(o_mt_st0_idx23)
);

assign lifm_st0_wo[WORD_WIDTH*48-1:WORD_WIDTH*47] = o_lifm_st0_idx23[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*47-1:WORD_WIDTH*46] = o_lifm_st0_idx23[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*47-1:WORD_WIDTH*46];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*48-1:DIST_WIDTH*MAX_LIFM_RSIZ*47] = o_mt_st0_idx23[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*47-1:DIST_WIDTH*MAX_LIFM_RSIZ*46] = o_mt_st0_idx23[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*47-1:DIST_WIDTH*MAX_LIFM_RSIZ*46];


// Stage0 Index24
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx24;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx24;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx24;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx24;
wire [1-1:0] i_dist_st0_idx24;

assign i_lifm_st0_idx24 = { lifm_st0_wi[WORD_WIDTH*50-1:WORD_WIDTH*49], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx24   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*50-1:DIST_WIDTH*MAX_LIFM_RSIZ*49], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx24 = psum[PSUM_WIDTH*49-1:PSUM_WIDTH*48] - psum[PSUM_WIDTH*48-1:PSUM_WIDTH*47];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx24 (
    .i_vec(i_lifm_st0_idx24), .stride(i_dist_st0_idx24), .o_vec(o_lifm_st0_idx24)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx24 (
    .i_vec(i_mt_st0_idx24), .stride(i_dist_st0_idx24), .o_vec(o_mt_st0_idx24)
);

assign lifm_st0_wo[WORD_WIDTH*50-1:WORD_WIDTH*49] = o_lifm_st0_idx24[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*49-1:WORD_WIDTH*48] = o_lifm_st0_idx24[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*49-1:WORD_WIDTH*48];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*50-1:DIST_WIDTH*MAX_LIFM_RSIZ*49] = o_mt_st0_idx24[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*49-1:DIST_WIDTH*MAX_LIFM_RSIZ*48] = o_mt_st0_idx24[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*49-1:DIST_WIDTH*MAX_LIFM_RSIZ*48];


// Stage0 Index25
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx25;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx25;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx25;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx25;
wire [1-1:0] i_dist_st0_idx25;

assign i_lifm_st0_idx25 = { lifm_st0_wi[WORD_WIDTH*52-1:WORD_WIDTH*51], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx25   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*52-1:DIST_WIDTH*MAX_LIFM_RSIZ*51], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx25 = psum[PSUM_WIDTH*51-1:PSUM_WIDTH*50] - psum[PSUM_WIDTH*50-1:PSUM_WIDTH*49];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx25 (
    .i_vec(i_lifm_st0_idx25), .stride(i_dist_st0_idx25), .o_vec(o_lifm_st0_idx25)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx25 (
    .i_vec(i_mt_st0_idx25), .stride(i_dist_st0_idx25), .o_vec(o_mt_st0_idx25)
);

assign lifm_st0_wo[WORD_WIDTH*52-1:WORD_WIDTH*51] = o_lifm_st0_idx25[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*51-1:WORD_WIDTH*50] = o_lifm_st0_idx25[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*51-1:WORD_WIDTH*50];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*52-1:DIST_WIDTH*MAX_LIFM_RSIZ*51] = o_mt_st0_idx25[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*51-1:DIST_WIDTH*MAX_LIFM_RSIZ*50] = o_mt_st0_idx25[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*51-1:DIST_WIDTH*MAX_LIFM_RSIZ*50];


// Stage0 Index26
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx26;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx26;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx26;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx26;
wire [1-1:0] i_dist_st0_idx26;

assign i_lifm_st0_idx26 = { lifm_st0_wi[WORD_WIDTH*54-1:WORD_WIDTH*53], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx26   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*54-1:DIST_WIDTH*MAX_LIFM_RSIZ*53], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx26 = psum[PSUM_WIDTH*53-1:PSUM_WIDTH*52] - psum[PSUM_WIDTH*52-1:PSUM_WIDTH*51];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx26 (
    .i_vec(i_lifm_st0_idx26), .stride(i_dist_st0_idx26), .o_vec(o_lifm_st0_idx26)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx26 (
    .i_vec(i_mt_st0_idx26), .stride(i_dist_st0_idx26), .o_vec(o_mt_st0_idx26)
);

assign lifm_st0_wo[WORD_WIDTH*54-1:WORD_WIDTH*53] = o_lifm_st0_idx26[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*53-1:WORD_WIDTH*52] = o_lifm_st0_idx26[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*53-1:WORD_WIDTH*52];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*54-1:DIST_WIDTH*MAX_LIFM_RSIZ*53] = o_mt_st0_idx26[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*53-1:DIST_WIDTH*MAX_LIFM_RSIZ*52] = o_mt_st0_idx26[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*53-1:DIST_WIDTH*MAX_LIFM_RSIZ*52];


// Stage0 Index27
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx27;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx27;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx27;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx27;
wire [1-1:0] i_dist_st0_idx27;

assign i_lifm_st0_idx27 = { lifm_st0_wi[WORD_WIDTH*56-1:WORD_WIDTH*55], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx27   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*56-1:DIST_WIDTH*MAX_LIFM_RSIZ*55], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx27 = psum[PSUM_WIDTH*55-1:PSUM_WIDTH*54] - psum[PSUM_WIDTH*54-1:PSUM_WIDTH*53];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx27 (
    .i_vec(i_lifm_st0_idx27), .stride(i_dist_st0_idx27), .o_vec(o_lifm_st0_idx27)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx27 (
    .i_vec(i_mt_st0_idx27), .stride(i_dist_st0_idx27), .o_vec(o_mt_st0_idx27)
);

assign lifm_st0_wo[WORD_WIDTH*56-1:WORD_WIDTH*55] = o_lifm_st0_idx27[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*55-1:WORD_WIDTH*54] = o_lifm_st0_idx27[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*55-1:WORD_WIDTH*54];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*56-1:DIST_WIDTH*MAX_LIFM_RSIZ*55] = o_mt_st0_idx27[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*55-1:DIST_WIDTH*MAX_LIFM_RSIZ*54] = o_mt_st0_idx27[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*55-1:DIST_WIDTH*MAX_LIFM_RSIZ*54];


// Stage0 Index28
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx28;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx28;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx28;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx28;
wire [1-1:0] i_dist_st0_idx28;

assign i_lifm_st0_idx28 = { lifm_st0_wi[WORD_WIDTH*58-1:WORD_WIDTH*57], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx28   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*58-1:DIST_WIDTH*MAX_LIFM_RSIZ*57], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx28 = psum[PSUM_WIDTH*57-1:PSUM_WIDTH*56] - psum[PSUM_WIDTH*56-1:PSUM_WIDTH*55];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx28 (
    .i_vec(i_lifm_st0_idx28), .stride(i_dist_st0_idx28), .o_vec(o_lifm_st0_idx28)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx28 (
    .i_vec(i_mt_st0_idx28), .stride(i_dist_st0_idx28), .o_vec(o_mt_st0_idx28)
);

assign lifm_st0_wo[WORD_WIDTH*58-1:WORD_WIDTH*57] = o_lifm_st0_idx28[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*57-1:WORD_WIDTH*56] = o_lifm_st0_idx28[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*57-1:WORD_WIDTH*56];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*58-1:DIST_WIDTH*MAX_LIFM_RSIZ*57] = o_mt_st0_idx28[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*57-1:DIST_WIDTH*MAX_LIFM_RSIZ*56] = o_mt_st0_idx28[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*57-1:DIST_WIDTH*MAX_LIFM_RSIZ*56];


// Stage0 Index29
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx29;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx29;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx29;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx29;
wire [1-1:0] i_dist_st0_idx29;

assign i_lifm_st0_idx29 = { lifm_st0_wi[WORD_WIDTH*60-1:WORD_WIDTH*59], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx29   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*60-1:DIST_WIDTH*MAX_LIFM_RSIZ*59], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx29 = psum[PSUM_WIDTH*59-1:PSUM_WIDTH*58] - psum[PSUM_WIDTH*58-1:PSUM_WIDTH*57];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx29 (
    .i_vec(i_lifm_st0_idx29), .stride(i_dist_st0_idx29), .o_vec(o_lifm_st0_idx29)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx29 (
    .i_vec(i_mt_st0_idx29), .stride(i_dist_st0_idx29), .o_vec(o_mt_st0_idx29)
);

assign lifm_st0_wo[WORD_WIDTH*60-1:WORD_WIDTH*59] = o_lifm_st0_idx29[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*59-1:WORD_WIDTH*58] = o_lifm_st0_idx29[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*59-1:WORD_WIDTH*58];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*60-1:DIST_WIDTH*MAX_LIFM_RSIZ*59] = o_mt_st0_idx29[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*59-1:DIST_WIDTH*MAX_LIFM_RSIZ*58] = o_mt_st0_idx29[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*59-1:DIST_WIDTH*MAX_LIFM_RSIZ*58];


// Stage0 Index30
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx30;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx30;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx30;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx30;
wire [1-1:0] i_dist_st0_idx30;

assign i_lifm_st0_idx30 = { lifm_st0_wi[WORD_WIDTH*62-1:WORD_WIDTH*61], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx30   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*62-1:DIST_WIDTH*MAX_LIFM_RSIZ*61], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx30 = psum[PSUM_WIDTH*61-1:PSUM_WIDTH*60] - psum[PSUM_WIDTH*60-1:PSUM_WIDTH*59];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx30 (
    .i_vec(i_lifm_st0_idx30), .stride(i_dist_st0_idx30), .o_vec(o_lifm_st0_idx30)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx30 (
    .i_vec(i_mt_st0_idx30), .stride(i_dist_st0_idx30), .o_vec(o_mt_st0_idx30)
);

assign lifm_st0_wo[WORD_WIDTH*62-1:WORD_WIDTH*61] = o_lifm_st0_idx30[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*61-1:WORD_WIDTH*60] = o_lifm_st0_idx30[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*61-1:WORD_WIDTH*60];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*62-1:DIST_WIDTH*MAX_LIFM_RSIZ*61] = o_mt_st0_idx30[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*61-1:DIST_WIDTH*MAX_LIFM_RSIZ*60] = o_mt_st0_idx30[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*61-1:DIST_WIDTH*MAX_LIFM_RSIZ*60];


// Stage0 Index31
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx31;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx31;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx31;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx31;
wire [1-1:0] i_dist_st0_idx31;

assign i_lifm_st0_idx31 = { lifm_st0_wi[WORD_WIDTH*64-1:WORD_WIDTH*63], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx31   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*64-1:DIST_WIDTH*MAX_LIFM_RSIZ*63], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx31 = psum[PSUM_WIDTH*63-1:PSUM_WIDTH*62] - psum[PSUM_WIDTH*62-1:PSUM_WIDTH*61];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx31 (
    .i_vec(i_lifm_st0_idx31), .stride(i_dist_st0_idx31), .o_vec(o_lifm_st0_idx31)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx31 (
    .i_vec(i_mt_st0_idx31), .stride(i_dist_st0_idx31), .o_vec(o_mt_st0_idx31)
);

assign lifm_st0_wo[WORD_WIDTH*64-1:WORD_WIDTH*63] = o_lifm_st0_idx31[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*63-1:WORD_WIDTH*62] = o_lifm_st0_idx31[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*63-1:WORD_WIDTH*62];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*64-1:DIST_WIDTH*MAX_LIFM_RSIZ*63] = o_mt_st0_idx31[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*63-1:DIST_WIDTH*MAX_LIFM_RSIZ*62] = o_mt_st0_idx31[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*63-1:DIST_WIDTH*MAX_LIFM_RSIZ*62];


// Stage0 Index32
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx32;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx32;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx32;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx32;
wire [1-1:0] i_dist_st0_idx32;

assign i_lifm_st0_idx32 = { lifm_st0_wi[WORD_WIDTH*66-1:WORD_WIDTH*65], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx32   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*66-1:DIST_WIDTH*MAX_LIFM_RSIZ*65], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx32 = psum[PSUM_WIDTH*65-1:PSUM_WIDTH*64] - psum[PSUM_WIDTH*64-1:PSUM_WIDTH*63];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx32 (
    .i_vec(i_lifm_st0_idx32), .stride(i_dist_st0_idx32), .o_vec(o_lifm_st0_idx32)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx32 (
    .i_vec(i_mt_st0_idx32), .stride(i_dist_st0_idx32), .o_vec(o_mt_st0_idx32)
);

assign lifm_st0_wo[WORD_WIDTH*66-1:WORD_WIDTH*65] = o_lifm_st0_idx32[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*65-1:WORD_WIDTH*64] = o_lifm_st0_idx32[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*65-1:WORD_WIDTH*64];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*66-1:DIST_WIDTH*MAX_LIFM_RSIZ*65] = o_mt_st0_idx32[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*65-1:DIST_WIDTH*MAX_LIFM_RSIZ*64] = o_mt_st0_idx32[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*65-1:DIST_WIDTH*MAX_LIFM_RSIZ*64];


// Stage0 Index33
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx33;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx33;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx33;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx33;
wire [1-1:0] i_dist_st0_idx33;

assign i_lifm_st0_idx33 = { lifm_st0_wi[WORD_WIDTH*68-1:WORD_WIDTH*67], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx33   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*68-1:DIST_WIDTH*MAX_LIFM_RSIZ*67], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx33 = psum[PSUM_WIDTH*67-1:PSUM_WIDTH*66] - psum[PSUM_WIDTH*66-1:PSUM_WIDTH*65];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx33 (
    .i_vec(i_lifm_st0_idx33), .stride(i_dist_st0_idx33), .o_vec(o_lifm_st0_idx33)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx33 (
    .i_vec(i_mt_st0_idx33), .stride(i_dist_st0_idx33), .o_vec(o_mt_st0_idx33)
);

assign lifm_st0_wo[WORD_WIDTH*68-1:WORD_WIDTH*67] = o_lifm_st0_idx33[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*67-1:WORD_WIDTH*66] = o_lifm_st0_idx33[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*67-1:WORD_WIDTH*66];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*68-1:DIST_WIDTH*MAX_LIFM_RSIZ*67] = o_mt_st0_idx33[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*67-1:DIST_WIDTH*MAX_LIFM_RSIZ*66] = o_mt_st0_idx33[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*67-1:DIST_WIDTH*MAX_LIFM_RSIZ*66];


// Stage0 Index34
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx34;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx34;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx34;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx34;
wire [1-1:0] i_dist_st0_idx34;

assign i_lifm_st0_idx34 = { lifm_st0_wi[WORD_WIDTH*70-1:WORD_WIDTH*69], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx34   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*70-1:DIST_WIDTH*MAX_LIFM_RSIZ*69], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx34 = psum[PSUM_WIDTH*69-1:PSUM_WIDTH*68] - psum[PSUM_WIDTH*68-1:PSUM_WIDTH*67];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx34 (
    .i_vec(i_lifm_st0_idx34), .stride(i_dist_st0_idx34), .o_vec(o_lifm_st0_idx34)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx34 (
    .i_vec(i_mt_st0_idx34), .stride(i_dist_st0_idx34), .o_vec(o_mt_st0_idx34)
);

assign lifm_st0_wo[WORD_WIDTH*70-1:WORD_WIDTH*69] = o_lifm_st0_idx34[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*69-1:WORD_WIDTH*68] = o_lifm_st0_idx34[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*69-1:WORD_WIDTH*68];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*70-1:DIST_WIDTH*MAX_LIFM_RSIZ*69] = o_mt_st0_idx34[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*69-1:DIST_WIDTH*MAX_LIFM_RSIZ*68] = o_mt_st0_idx34[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*69-1:DIST_WIDTH*MAX_LIFM_RSIZ*68];


// Stage0 Index35
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx35;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx35;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx35;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx35;
wire [1-1:0] i_dist_st0_idx35;

assign i_lifm_st0_idx35 = { lifm_st0_wi[WORD_WIDTH*72-1:WORD_WIDTH*71], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx35   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*72-1:DIST_WIDTH*MAX_LIFM_RSIZ*71], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx35 = psum[PSUM_WIDTH*71-1:PSUM_WIDTH*70] - psum[PSUM_WIDTH*70-1:PSUM_WIDTH*69];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx35 (
    .i_vec(i_lifm_st0_idx35), .stride(i_dist_st0_idx35), .o_vec(o_lifm_st0_idx35)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx35 (
    .i_vec(i_mt_st0_idx35), .stride(i_dist_st0_idx35), .o_vec(o_mt_st0_idx35)
);

assign lifm_st0_wo[WORD_WIDTH*72-1:WORD_WIDTH*71] = o_lifm_st0_idx35[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*71-1:WORD_WIDTH*70] = o_lifm_st0_idx35[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*71-1:WORD_WIDTH*70];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*72-1:DIST_WIDTH*MAX_LIFM_RSIZ*71] = o_mt_st0_idx35[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*71-1:DIST_WIDTH*MAX_LIFM_RSIZ*70] = o_mt_st0_idx35[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*71-1:DIST_WIDTH*MAX_LIFM_RSIZ*70];


// Stage0 Index36
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx36;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx36;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx36;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx36;
wire [1-1:0] i_dist_st0_idx36;

assign i_lifm_st0_idx36 = { lifm_st0_wi[WORD_WIDTH*74-1:WORD_WIDTH*73], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx36   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*74-1:DIST_WIDTH*MAX_LIFM_RSIZ*73], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx36 = psum[PSUM_WIDTH*73-1:PSUM_WIDTH*72] - psum[PSUM_WIDTH*72-1:PSUM_WIDTH*71];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx36 (
    .i_vec(i_lifm_st0_idx36), .stride(i_dist_st0_idx36), .o_vec(o_lifm_st0_idx36)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx36 (
    .i_vec(i_mt_st0_idx36), .stride(i_dist_st0_idx36), .o_vec(o_mt_st0_idx36)
);

assign lifm_st0_wo[WORD_WIDTH*74-1:WORD_WIDTH*73] = o_lifm_st0_idx36[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*73-1:WORD_WIDTH*72] = o_lifm_st0_idx36[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*73-1:WORD_WIDTH*72];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*74-1:DIST_WIDTH*MAX_LIFM_RSIZ*73] = o_mt_st0_idx36[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*73-1:DIST_WIDTH*MAX_LIFM_RSIZ*72] = o_mt_st0_idx36[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*73-1:DIST_WIDTH*MAX_LIFM_RSIZ*72];


// Stage0 Index37
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx37;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx37;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx37;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx37;
wire [1-1:0] i_dist_st0_idx37;

assign i_lifm_st0_idx37 = { lifm_st0_wi[WORD_WIDTH*76-1:WORD_WIDTH*75], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx37   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*76-1:DIST_WIDTH*MAX_LIFM_RSIZ*75], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx37 = psum[PSUM_WIDTH*75-1:PSUM_WIDTH*74] - psum[PSUM_WIDTH*74-1:PSUM_WIDTH*73];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx37 (
    .i_vec(i_lifm_st0_idx37), .stride(i_dist_st0_idx37), .o_vec(o_lifm_st0_idx37)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx37 (
    .i_vec(i_mt_st0_idx37), .stride(i_dist_st0_idx37), .o_vec(o_mt_st0_idx37)
);

assign lifm_st0_wo[WORD_WIDTH*76-1:WORD_WIDTH*75] = o_lifm_st0_idx37[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*75-1:WORD_WIDTH*74] = o_lifm_st0_idx37[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*75-1:WORD_WIDTH*74];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*76-1:DIST_WIDTH*MAX_LIFM_RSIZ*75] = o_mt_st0_idx37[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*75-1:DIST_WIDTH*MAX_LIFM_RSIZ*74] = o_mt_st0_idx37[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*75-1:DIST_WIDTH*MAX_LIFM_RSIZ*74];


// Stage0 Index38
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx38;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx38;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx38;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx38;
wire [1-1:0] i_dist_st0_idx38;

assign i_lifm_st0_idx38 = { lifm_st0_wi[WORD_WIDTH*78-1:WORD_WIDTH*77], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx38   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*78-1:DIST_WIDTH*MAX_LIFM_RSIZ*77], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx38 = psum[PSUM_WIDTH*77-1:PSUM_WIDTH*76] - psum[PSUM_WIDTH*76-1:PSUM_WIDTH*75];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx38 (
    .i_vec(i_lifm_st0_idx38), .stride(i_dist_st0_idx38), .o_vec(o_lifm_st0_idx38)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx38 (
    .i_vec(i_mt_st0_idx38), .stride(i_dist_st0_idx38), .o_vec(o_mt_st0_idx38)
);

assign lifm_st0_wo[WORD_WIDTH*78-1:WORD_WIDTH*77] = o_lifm_st0_idx38[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*77-1:WORD_WIDTH*76] = o_lifm_st0_idx38[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*77-1:WORD_WIDTH*76];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*78-1:DIST_WIDTH*MAX_LIFM_RSIZ*77] = o_mt_st0_idx38[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*77-1:DIST_WIDTH*MAX_LIFM_RSIZ*76] = o_mt_st0_idx38[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*77-1:DIST_WIDTH*MAX_LIFM_RSIZ*76];


// Stage0 Index39
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx39;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx39;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx39;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx39;
wire [1-1:0] i_dist_st0_idx39;

assign i_lifm_st0_idx39 = { lifm_st0_wi[WORD_WIDTH*80-1:WORD_WIDTH*79], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx39   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*80-1:DIST_WIDTH*MAX_LIFM_RSIZ*79], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx39 = psum[PSUM_WIDTH*79-1:PSUM_WIDTH*78] - psum[PSUM_WIDTH*78-1:PSUM_WIDTH*77];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx39 (
    .i_vec(i_lifm_st0_idx39), .stride(i_dist_st0_idx39), .o_vec(o_lifm_st0_idx39)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx39 (
    .i_vec(i_mt_st0_idx39), .stride(i_dist_st0_idx39), .o_vec(o_mt_st0_idx39)
);

assign lifm_st0_wo[WORD_WIDTH*80-1:WORD_WIDTH*79] = o_lifm_st0_idx39[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*79-1:WORD_WIDTH*78] = o_lifm_st0_idx39[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*79-1:WORD_WIDTH*78];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*80-1:DIST_WIDTH*MAX_LIFM_RSIZ*79] = o_mt_st0_idx39[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*79-1:DIST_WIDTH*MAX_LIFM_RSIZ*78] = o_mt_st0_idx39[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*79-1:DIST_WIDTH*MAX_LIFM_RSIZ*78];


// Stage0 Index40
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx40;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx40;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx40;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx40;
wire [1-1:0] i_dist_st0_idx40;

assign i_lifm_st0_idx40 = { lifm_st0_wi[WORD_WIDTH*82-1:WORD_WIDTH*81], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx40   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*82-1:DIST_WIDTH*MAX_LIFM_RSIZ*81], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx40 = psum[PSUM_WIDTH*81-1:PSUM_WIDTH*80] - psum[PSUM_WIDTH*80-1:PSUM_WIDTH*79];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx40 (
    .i_vec(i_lifm_st0_idx40), .stride(i_dist_st0_idx40), .o_vec(o_lifm_st0_idx40)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx40 (
    .i_vec(i_mt_st0_idx40), .stride(i_dist_st0_idx40), .o_vec(o_mt_st0_idx40)
);

assign lifm_st0_wo[WORD_WIDTH*82-1:WORD_WIDTH*81] = o_lifm_st0_idx40[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*81-1:WORD_WIDTH*80] = o_lifm_st0_idx40[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*81-1:WORD_WIDTH*80];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*82-1:DIST_WIDTH*MAX_LIFM_RSIZ*81] = o_mt_st0_idx40[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*81-1:DIST_WIDTH*MAX_LIFM_RSIZ*80] = o_mt_st0_idx40[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*81-1:DIST_WIDTH*MAX_LIFM_RSIZ*80];


// Stage0 Index41
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx41;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx41;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx41;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx41;
wire [1-1:0] i_dist_st0_idx41;

assign i_lifm_st0_idx41 = { lifm_st0_wi[WORD_WIDTH*84-1:WORD_WIDTH*83], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx41   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*84-1:DIST_WIDTH*MAX_LIFM_RSIZ*83], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx41 = psum[PSUM_WIDTH*83-1:PSUM_WIDTH*82] - psum[PSUM_WIDTH*82-1:PSUM_WIDTH*81];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx41 (
    .i_vec(i_lifm_st0_idx41), .stride(i_dist_st0_idx41), .o_vec(o_lifm_st0_idx41)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx41 (
    .i_vec(i_mt_st0_idx41), .stride(i_dist_st0_idx41), .o_vec(o_mt_st0_idx41)
);

assign lifm_st0_wo[WORD_WIDTH*84-1:WORD_WIDTH*83] = o_lifm_st0_idx41[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*83-1:WORD_WIDTH*82] = o_lifm_st0_idx41[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*83-1:WORD_WIDTH*82];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*84-1:DIST_WIDTH*MAX_LIFM_RSIZ*83] = o_mt_st0_idx41[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*83-1:DIST_WIDTH*MAX_LIFM_RSIZ*82] = o_mt_st0_idx41[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*83-1:DIST_WIDTH*MAX_LIFM_RSIZ*82];


// Stage0 Index42
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx42;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx42;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx42;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx42;
wire [1-1:0] i_dist_st0_idx42;

assign i_lifm_st0_idx42 = { lifm_st0_wi[WORD_WIDTH*86-1:WORD_WIDTH*85], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx42   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*86-1:DIST_WIDTH*MAX_LIFM_RSIZ*85], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx42 = psum[PSUM_WIDTH*85-1:PSUM_WIDTH*84] - psum[PSUM_WIDTH*84-1:PSUM_WIDTH*83];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx42 (
    .i_vec(i_lifm_st0_idx42), .stride(i_dist_st0_idx42), .o_vec(o_lifm_st0_idx42)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx42 (
    .i_vec(i_mt_st0_idx42), .stride(i_dist_st0_idx42), .o_vec(o_mt_st0_idx42)
);

assign lifm_st0_wo[WORD_WIDTH*86-1:WORD_WIDTH*85] = o_lifm_st0_idx42[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*85-1:WORD_WIDTH*84] = o_lifm_st0_idx42[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*85-1:WORD_WIDTH*84];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*86-1:DIST_WIDTH*MAX_LIFM_RSIZ*85] = o_mt_st0_idx42[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*85-1:DIST_WIDTH*MAX_LIFM_RSIZ*84] = o_mt_st0_idx42[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*85-1:DIST_WIDTH*MAX_LIFM_RSIZ*84];


// Stage0 Index43
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx43;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx43;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx43;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx43;
wire [1-1:0] i_dist_st0_idx43;

assign i_lifm_st0_idx43 = { lifm_st0_wi[WORD_WIDTH*88-1:WORD_WIDTH*87], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx43   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*88-1:DIST_WIDTH*MAX_LIFM_RSIZ*87], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx43 = psum[PSUM_WIDTH*87-1:PSUM_WIDTH*86] - psum[PSUM_WIDTH*86-1:PSUM_WIDTH*85];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx43 (
    .i_vec(i_lifm_st0_idx43), .stride(i_dist_st0_idx43), .o_vec(o_lifm_st0_idx43)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx43 (
    .i_vec(i_mt_st0_idx43), .stride(i_dist_st0_idx43), .o_vec(o_mt_st0_idx43)
);

assign lifm_st0_wo[WORD_WIDTH*88-1:WORD_WIDTH*87] = o_lifm_st0_idx43[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*87-1:WORD_WIDTH*86] = o_lifm_st0_idx43[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*87-1:WORD_WIDTH*86];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*88-1:DIST_WIDTH*MAX_LIFM_RSIZ*87] = o_mt_st0_idx43[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*87-1:DIST_WIDTH*MAX_LIFM_RSIZ*86] = o_mt_st0_idx43[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*87-1:DIST_WIDTH*MAX_LIFM_RSIZ*86];


// Stage0 Index44
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx44;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx44;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx44;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx44;
wire [1-1:0] i_dist_st0_idx44;

assign i_lifm_st0_idx44 = { lifm_st0_wi[WORD_WIDTH*90-1:WORD_WIDTH*89], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx44   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*90-1:DIST_WIDTH*MAX_LIFM_RSIZ*89], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx44 = psum[PSUM_WIDTH*89-1:PSUM_WIDTH*88] - psum[PSUM_WIDTH*88-1:PSUM_WIDTH*87];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx44 (
    .i_vec(i_lifm_st0_idx44), .stride(i_dist_st0_idx44), .o_vec(o_lifm_st0_idx44)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx44 (
    .i_vec(i_mt_st0_idx44), .stride(i_dist_st0_idx44), .o_vec(o_mt_st0_idx44)
);

assign lifm_st0_wo[WORD_WIDTH*90-1:WORD_WIDTH*89] = o_lifm_st0_idx44[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*89-1:WORD_WIDTH*88] = o_lifm_st0_idx44[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*89-1:WORD_WIDTH*88];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*90-1:DIST_WIDTH*MAX_LIFM_RSIZ*89] = o_mt_st0_idx44[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*89-1:DIST_WIDTH*MAX_LIFM_RSIZ*88] = o_mt_st0_idx44[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*89-1:DIST_WIDTH*MAX_LIFM_RSIZ*88];


// Stage0 Index45
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx45;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx45;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx45;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx45;
wire [1-1:0] i_dist_st0_idx45;

assign i_lifm_st0_idx45 = { lifm_st0_wi[WORD_WIDTH*92-1:WORD_WIDTH*91], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx45   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*92-1:DIST_WIDTH*MAX_LIFM_RSIZ*91], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx45 = psum[PSUM_WIDTH*91-1:PSUM_WIDTH*90] - psum[PSUM_WIDTH*90-1:PSUM_WIDTH*89];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx45 (
    .i_vec(i_lifm_st0_idx45), .stride(i_dist_st0_idx45), .o_vec(o_lifm_st0_idx45)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx45 (
    .i_vec(i_mt_st0_idx45), .stride(i_dist_st0_idx45), .o_vec(o_mt_st0_idx45)
);

assign lifm_st0_wo[WORD_WIDTH*92-1:WORD_WIDTH*91] = o_lifm_st0_idx45[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*91-1:WORD_WIDTH*90] = o_lifm_st0_idx45[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*91-1:WORD_WIDTH*90];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*92-1:DIST_WIDTH*MAX_LIFM_RSIZ*91] = o_mt_st0_idx45[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*91-1:DIST_WIDTH*MAX_LIFM_RSIZ*90] = o_mt_st0_idx45[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*91-1:DIST_WIDTH*MAX_LIFM_RSIZ*90];


// Stage0 Index46
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx46;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx46;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx46;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx46;
wire [1-1:0] i_dist_st0_idx46;

assign i_lifm_st0_idx46 = { lifm_st0_wi[WORD_WIDTH*94-1:WORD_WIDTH*93], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx46   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*94-1:DIST_WIDTH*MAX_LIFM_RSIZ*93], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx46 = psum[PSUM_WIDTH*93-1:PSUM_WIDTH*92] - psum[PSUM_WIDTH*92-1:PSUM_WIDTH*91];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx46 (
    .i_vec(i_lifm_st0_idx46), .stride(i_dist_st0_idx46), .o_vec(o_lifm_st0_idx46)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx46 (
    .i_vec(i_mt_st0_idx46), .stride(i_dist_st0_idx46), .o_vec(o_mt_st0_idx46)
);

assign lifm_st0_wo[WORD_WIDTH*94-1:WORD_WIDTH*93] = o_lifm_st0_idx46[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*93-1:WORD_WIDTH*92] = o_lifm_st0_idx46[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*93-1:WORD_WIDTH*92];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*94-1:DIST_WIDTH*MAX_LIFM_RSIZ*93] = o_mt_st0_idx46[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*93-1:DIST_WIDTH*MAX_LIFM_RSIZ*92] = o_mt_st0_idx46[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*93-1:DIST_WIDTH*MAX_LIFM_RSIZ*92];


// Stage0 Index47
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx47;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx47;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx47;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx47;
wire [1-1:0] i_dist_st0_idx47;

assign i_lifm_st0_idx47 = { lifm_st0_wi[WORD_WIDTH*96-1:WORD_WIDTH*95], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx47   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*96-1:DIST_WIDTH*MAX_LIFM_RSIZ*95], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx47 = psum[PSUM_WIDTH*95-1:PSUM_WIDTH*94] - psum[PSUM_WIDTH*94-1:PSUM_WIDTH*93];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx47 (
    .i_vec(i_lifm_st0_idx47), .stride(i_dist_st0_idx47), .o_vec(o_lifm_st0_idx47)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx47 (
    .i_vec(i_mt_st0_idx47), .stride(i_dist_st0_idx47), .o_vec(o_mt_st0_idx47)
);

assign lifm_st0_wo[WORD_WIDTH*96-1:WORD_WIDTH*95] = o_lifm_st0_idx47[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*95-1:WORD_WIDTH*94] = o_lifm_st0_idx47[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*95-1:WORD_WIDTH*94];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*96-1:DIST_WIDTH*MAX_LIFM_RSIZ*95] = o_mt_st0_idx47[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*95-1:DIST_WIDTH*MAX_LIFM_RSIZ*94] = o_mt_st0_idx47[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*95-1:DIST_WIDTH*MAX_LIFM_RSIZ*94];


// Stage0 Index48
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx48;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx48;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx48;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx48;
wire [1-1:0] i_dist_st0_idx48;

assign i_lifm_st0_idx48 = { lifm_st0_wi[WORD_WIDTH*98-1:WORD_WIDTH*97], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx48   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*98-1:DIST_WIDTH*MAX_LIFM_RSIZ*97], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx48 = psum[PSUM_WIDTH*97-1:PSUM_WIDTH*96] - psum[PSUM_WIDTH*96-1:PSUM_WIDTH*95];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx48 (
    .i_vec(i_lifm_st0_idx48), .stride(i_dist_st0_idx48), .o_vec(o_lifm_st0_idx48)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx48 (
    .i_vec(i_mt_st0_idx48), .stride(i_dist_st0_idx48), .o_vec(o_mt_st0_idx48)
);

assign lifm_st0_wo[WORD_WIDTH*98-1:WORD_WIDTH*97] = o_lifm_st0_idx48[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*97-1:WORD_WIDTH*96] = o_lifm_st0_idx48[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*97-1:WORD_WIDTH*96];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*98-1:DIST_WIDTH*MAX_LIFM_RSIZ*97] = o_mt_st0_idx48[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*97-1:DIST_WIDTH*MAX_LIFM_RSIZ*96] = o_mt_st0_idx48[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*97-1:DIST_WIDTH*MAX_LIFM_RSIZ*96];


// Stage0 Index49
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx49;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx49;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx49;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx49;
wire [1-1:0] i_dist_st0_idx49;

assign i_lifm_st0_idx49 = { lifm_st0_wi[WORD_WIDTH*100-1:WORD_WIDTH*99], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx49   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*100-1:DIST_WIDTH*MAX_LIFM_RSIZ*99], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx49 = psum[PSUM_WIDTH*99-1:PSUM_WIDTH*98] - psum[PSUM_WIDTH*98-1:PSUM_WIDTH*97];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx49 (
    .i_vec(i_lifm_st0_idx49), .stride(i_dist_st0_idx49), .o_vec(o_lifm_st0_idx49)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx49 (
    .i_vec(i_mt_st0_idx49), .stride(i_dist_st0_idx49), .o_vec(o_mt_st0_idx49)
);

assign lifm_st0_wo[WORD_WIDTH*100-1:WORD_WIDTH*99] = o_lifm_st0_idx49[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*99-1:WORD_WIDTH*98] = o_lifm_st0_idx49[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*99-1:WORD_WIDTH*98];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*100-1:DIST_WIDTH*MAX_LIFM_RSIZ*99] = o_mt_st0_idx49[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*99-1:DIST_WIDTH*MAX_LIFM_RSIZ*98] = o_mt_st0_idx49[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*99-1:DIST_WIDTH*MAX_LIFM_RSIZ*98];


// Stage0 Index50
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx50;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx50;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx50;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx50;
wire [1-1:0] i_dist_st0_idx50;

assign i_lifm_st0_idx50 = { lifm_st0_wi[WORD_WIDTH*102-1:WORD_WIDTH*101], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx50   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*102-1:DIST_WIDTH*MAX_LIFM_RSIZ*101], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx50 = psum[PSUM_WIDTH*101-1:PSUM_WIDTH*100] - psum[PSUM_WIDTH*100-1:PSUM_WIDTH*99];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx50 (
    .i_vec(i_lifm_st0_idx50), .stride(i_dist_st0_idx50), .o_vec(o_lifm_st0_idx50)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx50 (
    .i_vec(i_mt_st0_idx50), .stride(i_dist_st0_idx50), .o_vec(o_mt_st0_idx50)
);

assign lifm_st0_wo[WORD_WIDTH*102-1:WORD_WIDTH*101] = o_lifm_st0_idx50[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*101-1:WORD_WIDTH*100] = o_lifm_st0_idx50[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*101-1:WORD_WIDTH*100];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*102-1:DIST_WIDTH*MAX_LIFM_RSIZ*101] = o_mt_st0_idx50[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*101-1:DIST_WIDTH*MAX_LIFM_RSIZ*100] = o_mt_st0_idx50[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*101-1:DIST_WIDTH*MAX_LIFM_RSIZ*100];


// Stage0 Index51
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx51;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx51;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx51;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx51;
wire [1-1:0] i_dist_st0_idx51;

assign i_lifm_st0_idx51 = { lifm_st0_wi[WORD_WIDTH*104-1:WORD_WIDTH*103], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx51   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*104-1:DIST_WIDTH*MAX_LIFM_RSIZ*103], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx51 = psum[PSUM_WIDTH*103-1:PSUM_WIDTH*102] - psum[PSUM_WIDTH*102-1:PSUM_WIDTH*101];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx51 (
    .i_vec(i_lifm_st0_idx51), .stride(i_dist_st0_idx51), .o_vec(o_lifm_st0_idx51)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx51 (
    .i_vec(i_mt_st0_idx51), .stride(i_dist_st0_idx51), .o_vec(o_mt_st0_idx51)
);

assign lifm_st0_wo[WORD_WIDTH*104-1:WORD_WIDTH*103] = o_lifm_st0_idx51[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*103-1:WORD_WIDTH*102] = o_lifm_st0_idx51[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*103-1:WORD_WIDTH*102];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*104-1:DIST_WIDTH*MAX_LIFM_RSIZ*103] = o_mt_st0_idx51[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*103-1:DIST_WIDTH*MAX_LIFM_RSIZ*102] = o_mt_st0_idx51[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*103-1:DIST_WIDTH*MAX_LIFM_RSIZ*102];


// Stage0 Index52
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx52;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx52;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx52;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx52;
wire [1-1:0] i_dist_st0_idx52;

assign i_lifm_st0_idx52 = { lifm_st0_wi[WORD_WIDTH*106-1:WORD_WIDTH*105], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx52   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*106-1:DIST_WIDTH*MAX_LIFM_RSIZ*105], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx52 = psum[PSUM_WIDTH*105-1:PSUM_WIDTH*104] - psum[PSUM_WIDTH*104-1:PSUM_WIDTH*103];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx52 (
    .i_vec(i_lifm_st0_idx52), .stride(i_dist_st0_idx52), .o_vec(o_lifm_st0_idx52)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx52 (
    .i_vec(i_mt_st0_idx52), .stride(i_dist_st0_idx52), .o_vec(o_mt_st0_idx52)
);

assign lifm_st0_wo[WORD_WIDTH*106-1:WORD_WIDTH*105] = o_lifm_st0_idx52[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*105-1:WORD_WIDTH*104] = o_lifm_st0_idx52[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*105-1:WORD_WIDTH*104];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*106-1:DIST_WIDTH*MAX_LIFM_RSIZ*105] = o_mt_st0_idx52[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*105-1:DIST_WIDTH*MAX_LIFM_RSIZ*104] = o_mt_st0_idx52[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*105-1:DIST_WIDTH*MAX_LIFM_RSIZ*104];


// Stage0 Index53
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx53;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx53;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx53;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx53;
wire [1-1:0] i_dist_st0_idx53;

assign i_lifm_st0_idx53 = { lifm_st0_wi[WORD_WIDTH*108-1:WORD_WIDTH*107], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx53   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*108-1:DIST_WIDTH*MAX_LIFM_RSIZ*107], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx53 = psum[PSUM_WIDTH*107-1:PSUM_WIDTH*106] - psum[PSUM_WIDTH*106-1:PSUM_WIDTH*105];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx53 (
    .i_vec(i_lifm_st0_idx53), .stride(i_dist_st0_idx53), .o_vec(o_lifm_st0_idx53)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx53 (
    .i_vec(i_mt_st0_idx53), .stride(i_dist_st0_idx53), .o_vec(o_mt_st0_idx53)
);

assign lifm_st0_wo[WORD_WIDTH*108-1:WORD_WIDTH*107] = o_lifm_st0_idx53[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*107-1:WORD_WIDTH*106] = o_lifm_st0_idx53[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*107-1:WORD_WIDTH*106];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*108-1:DIST_WIDTH*MAX_LIFM_RSIZ*107] = o_mt_st0_idx53[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*107-1:DIST_WIDTH*MAX_LIFM_RSIZ*106] = o_mt_st0_idx53[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*107-1:DIST_WIDTH*MAX_LIFM_RSIZ*106];


// Stage0 Index54
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx54;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx54;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx54;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx54;
wire [1-1:0] i_dist_st0_idx54;

assign i_lifm_st0_idx54 = { lifm_st0_wi[WORD_WIDTH*110-1:WORD_WIDTH*109], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx54   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*110-1:DIST_WIDTH*MAX_LIFM_RSIZ*109], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx54 = psum[PSUM_WIDTH*109-1:PSUM_WIDTH*108] - psum[PSUM_WIDTH*108-1:PSUM_WIDTH*107];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx54 (
    .i_vec(i_lifm_st0_idx54), .stride(i_dist_st0_idx54), .o_vec(o_lifm_st0_idx54)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx54 (
    .i_vec(i_mt_st0_idx54), .stride(i_dist_st0_idx54), .o_vec(o_mt_st0_idx54)
);

assign lifm_st0_wo[WORD_WIDTH*110-1:WORD_WIDTH*109] = o_lifm_st0_idx54[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*109-1:WORD_WIDTH*108] = o_lifm_st0_idx54[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*109-1:WORD_WIDTH*108];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*110-1:DIST_WIDTH*MAX_LIFM_RSIZ*109] = o_mt_st0_idx54[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*109-1:DIST_WIDTH*MAX_LIFM_RSIZ*108] = o_mt_st0_idx54[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*109-1:DIST_WIDTH*MAX_LIFM_RSIZ*108];


// Stage0 Index55
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx55;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx55;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx55;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx55;
wire [1-1:0] i_dist_st0_idx55;

assign i_lifm_st0_idx55 = { lifm_st0_wi[WORD_WIDTH*112-1:WORD_WIDTH*111], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx55   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*112-1:DIST_WIDTH*MAX_LIFM_RSIZ*111], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx55 = psum[PSUM_WIDTH*111-1:PSUM_WIDTH*110] - psum[PSUM_WIDTH*110-1:PSUM_WIDTH*109];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx55 (
    .i_vec(i_lifm_st0_idx55), .stride(i_dist_st0_idx55), .o_vec(o_lifm_st0_idx55)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx55 (
    .i_vec(i_mt_st0_idx55), .stride(i_dist_st0_idx55), .o_vec(o_mt_st0_idx55)
);

assign lifm_st0_wo[WORD_WIDTH*112-1:WORD_WIDTH*111] = o_lifm_st0_idx55[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*111-1:WORD_WIDTH*110] = o_lifm_st0_idx55[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*111-1:WORD_WIDTH*110];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*112-1:DIST_WIDTH*MAX_LIFM_RSIZ*111] = o_mt_st0_idx55[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*111-1:DIST_WIDTH*MAX_LIFM_RSIZ*110] = o_mt_st0_idx55[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*111-1:DIST_WIDTH*MAX_LIFM_RSIZ*110];


// Stage0 Index56
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx56;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx56;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx56;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx56;
wire [1-1:0] i_dist_st0_idx56;

assign i_lifm_st0_idx56 = { lifm_st0_wi[WORD_WIDTH*114-1:WORD_WIDTH*113], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx56   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*114-1:DIST_WIDTH*MAX_LIFM_RSIZ*113], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx56 = psum[PSUM_WIDTH*113-1:PSUM_WIDTH*112] - psum[PSUM_WIDTH*112-1:PSUM_WIDTH*111];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx56 (
    .i_vec(i_lifm_st0_idx56), .stride(i_dist_st0_idx56), .o_vec(o_lifm_st0_idx56)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx56 (
    .i_vec(i_mt_st0_idx56), .stride(i_dist_st0_idx56), .o_vec(o_mt_st0_idx56)
);

assign lifm_st0_wo[WORD_WIDTH*114-1:WORD_WIDTH*113] = o_lifm_st0_idx56[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*113-1:WORD_WIDTH*112] = o_lifm_st0_idx56[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*113-1:WORD_WIDTH*112];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*114-1:DIST_WIDTH*MAX_LIFM_RSIZ*113] = o_mt_st0_idx56[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*113-1:DIST_WIDTH*MAX_LIFM_RSIZ*112] = o_mt_st0_idx56[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*113-1:DIST_WIDTH*MAX_LIFM_RSIZ*112];


// Stage0 Index57
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx57;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx57;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx57;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx57;
wire [1-1:0] i_dist_st0_idx57;

assign i_lifm_st0_idx57 = { lifm_st0_wi[WORD_WIDTH*116-1:WORD_WIDTH*115], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx57   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*116-1:DIST_WIDTH*MAX_LIFM_RSIZ*115], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx57 = psum[PSUM_WIDTH*115-1:PSUM_WIDTH*114] - psum[PSUM_WIDTH*114-1:PSUM_WIDTH*113];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx57 (
    .i_vec(i_lifm_st0_idx57), .stride(i_dist_st0_idx57), .o_vec(o_lifm_st0_idx57)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx57 (
    .i_vec(i_mt_st0_idx57), .stride(i_dist_st0_idx57), .o_vec(o_mt_st0_idx57)
);

assign lifm_st0_wo[WORD_WIDTH*116-1:WORD_WIDTH*115] = o_lifm_st0_idx57[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*115-1:WORD_WIDTH*114] = o_lifm_st0_idx57[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*115-1:WORD_WIDTH*114];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*116-1:DIST_WIDTH*MAX_LIFM_RSIZ*115] = o_mt_st0_idx57[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*115-1:DIST_WIDTH*MAX_LIFM_RSIZ*114] = o_mt_st0_idx57[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*115-1:DIST_WIDTH*MAX_LIFM_RSIZ*114];


// Stage0 Index58
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx58;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx58;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx58;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx58;
wire [1-1:0] i_dist_st0_idx58;

assign i_lifm_st0_idx58 = { lifm_st0_wi[WORD_WIDTH*118-1:WORD_WIDTH*117], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx58   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*118-1:DIST_WIDTH*MAX_LIFM_RSIZ*117], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx58 = psum[PSUM_WIDTH*117-1:PSUM_WIDTH*116] - psum[PSUM_WIDTH*116-1:PSUM_WIDTH*115];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx58 (
    .i_vec(i_lifm_st0_idx58), .stride(i_dist_st0_idx58), .o_vec(o_lifm_st0_idx58)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx58 (
    .i_vec(i_mt_st0_idx58), .stride(i_dist_st0_idx58), .o_vec(o_mt_st0_idx58)
);

assign lifm_st0_wo[WORD_WIDTH*118-1:WORD_WIDTH*117] = o_lifm_st0_idx58[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*117-1:WORD_WIDTH*116] = o_lifm_st0_idx58[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*117-1:WORD_WIDTH*116];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*118-1:DIST_WIDTH*MAX_LIFM_RSIZ*117] = o_mt_st0_idx58[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*117-1:DIST_WIDTH*MAX_LIFM_RSIZ*116] = o_mt_st0_idx58[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*117-1:DIST_WIDTH*MAX_LIFM_RSIZ*116];


// Stage0 Index59
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx59;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx59;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx59;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx59;
wire [1-1:0] i_dist_st0_idx59;

assign i_lifm_st0_idx59 = { lifm_st0_wi[WORD_WIDTH*120-1:WORD_WIDTH*119], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx59   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*120-1:DIST_WIDTH*MAX_LIFM_RSIZ*119], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx59 = psum[PSUM_WIDTH*119-1:PSUM_WIDTH*118] - psum[PSUM_WIDTH*118-1:PSUM_WIDTH*117];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx59 (
    .i_vec(i_lifm_st0_idx59), .stride(i_dist_st0_idx59), .o_vec(o_lifm_st0_idx59)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx59 (
    .i_vec(i_mt_st0_idx59), .stride(i_dist_st0_idx59), .o_vec(o_mt_st0_idx59)
);

assign lifm_st0_wo[WORD_WIDTH*120-1:WORD_WIDTH*119] = o_lifm_st0_idx59[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*119-1:WORD_WIDTH*118] = o_lifm_st0_idx59[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*119-1:WORD_WIDTH*118];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*120-1:DIST_WIDTH*MAX_LIFM_RSIZ*119] = o_mt_st0_idx59[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*119-1:DIST_WIDTH*MAX_LIFM_RSIZ*118] = o_mt_st0_idx59[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*119-1:DIST_WIDTH*MAX_LIFM_RSIZ*118];


// Stage0 Index60
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx60;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx60;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx60;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx60;
wire [1-1:0] i_dist_st0_idx60;

assign i_lifm_st0_idx60 = { lifm_st0_wi[WORD_WIDTH*122-1:WORD_WIDTH*121], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx60   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*122-1:DIST_WIDTH*MAX_LIFM_RSIZ*121], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx60 = psum[PSUM_WIDTH*121-1:PSUM_WIDTH*120] - psum[PSUM_WIDTH*120-1:PSUM_WIDTH*119];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx60 (
    .i_vec(i_lifm_st0_idx60), .stride(i_dist_st0_idx60), .o_vec(o_lifm_st0_idx60)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx60 (
    .i_vec(i_mt_st0_idx60), .stride(i_dist_st0_idx60), .o_vec(o_mt_st0_idx60)
);

assign lifm_st0_wo[WORD_WIDTH*122-1:WORD_WIDTH*121] = o_lifm_st0_idx60[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*121-1:WORD_WIDTH*120] = o_lifm_st0_idx60[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*121-1:WORD_WIDTH*120];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*122-1:DIST_WIDTH*MAX_LIFM_RSIZ*121] = o_mt_st0_idx60[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*121-1:DIST_WIDTH*MAX_LIFM_RSIZ*120] = o_mt_st0_idx60[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*121-1:DIST_WIDTH*MAX_LIFM_RSIZ*120];


// Stage0 Index61
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx61;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx61;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx61;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx61;
wire [1-1:0] i_dist_st0_idx61;

assign i_lifm_st0_idx61 = { lifm_st0_wi[WORD_WIDTH*124-1:WORD_WIDTH*123], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx61   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*124-1:DIST_WIDTH*MAX_LIFM_RSIZ*123], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx61 = psum[PSUM_WIDTH*123-1:PSUM_WIDTH*122] - psum[PSUM_WIDTH*122-1:PSUM_WIDTH*121];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx61 (
    .i_vec(i_lifm_st0_idx61), .stride(i_dist_st0_idx61), .o_vec(o_lifm_st0_idx61)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx61 (
    .i_vec(i_mt_st0_idx61), .stride(i_dist_st0_idx61), .o_vec(o_mt_st0_idx61)
);

assign lifm_st0_wo[WORD_WIDTH*124-1:WORD_WIDTH*123] = o_lifm_st0_idx61[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*123-1:WORD_WIDTH*122] = o_lifm_st0_idx61[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*123-1:WORD_WIDTH*122];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*124-1:DIST_WIDTH*MAX_LIFM_RSIZ*123] = o_mt_st0_idx61[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*123-1:DIST_WIDTH*MAX_LIFM_RSIZ*122] = o_mt_st0_idx61[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*123-1:DIST_WIDTH*MAX_LIFM_RSIZ*122];


// Stage0 Index62
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx62;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx62;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx62;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx62;
wire [1-1:0] i_dist_st0_idx62;

assign i_lifm_st0_idx62 = { lifm_st0_wi[WORD_WIDTH*126-1:WORD_WIDTH*125], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx62   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*126-1:DIST_WIDTH*MAX_LIFM_RSIZ*125], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx62 = psum[PSUM_WIDTH*125-1:PSUM_WIDTH*124] - psum[PSUM_WIDTH*124-1:PSUM_WIDTH*123];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx62 (
    .i_vec(i_lifm_st0_idx62), .stride(i_dist_st0_idx62), .o_vec(o_lifm_st0_idx62)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx62 (
    .i_vec(i_mt_st0_idx62), .stride(i_dist_st0_idx62), .o_vec(o_mt_st0_idx62)
);

assign lifm_st0_wo[WORD_WIDTH*126-1:WORD_WIDTH*125] = o_lifm_st0_idx62[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*125-1:WORD_WIDTH*124] = o_lifm_st0_idx62[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*125-1:WORD_WIDTH*124];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*126-1:DIST_WIDTH*MAX_LIFM_RSIZ*125] = o_mt_st0_idx62[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*125-1:DIST_WIDTH*MAX_LIFM_RSIZ*124] = o_mt_st0_idx62[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*125-1:DIST_WIDTH*MAX_LIFM_RSIZ*124];


// Stage0 Index63
wire [WORD_WIDTH*1*2-1:0] i_lifm_st0_idx63;
wire [WORD_WIDTH*1*2-1:0] o_lifm_st0_idx63;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] i_mt_st0_idx63;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*1*2-1:0] o_mt_st0_idx63;
wire [1-1:0] i_dist_st0_idx63;

assign i_lifm_st0_idx63 = { lifm_st0_wi[WORD_WIDTH*128-1:WORD_WIDTH*127], { WORD_WIDTH*1{1'b0} } };
assign i_mt_st0_idx63   = { mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*128-1:DIST_WIDTH*MAX_LIFM_RSIZ*127], { DIST_WIDTH*MAX_LIFM_RSIZ*1{1'b0} } };
assign i_dist_st0_idx63 = psum[PSUM_WIDTH*127-1:PSUM_WIDTH*126] - psum[PSUM_WIDTH*126-1:PSUM_WIDTH*125];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(2), .NUMEL_LOG(1)
) vs_lifm_st0_idx63 (
    .i_vec(i_lifm_st0_idx63), .stride(i_dist_st0_idx63), .o_vec(o_lifm_st0_idx63)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(2), .NUMEL_LOG(1)
) vs_mt_st0_idx63 (
    .i_vec(i_mt_st0_idx63), .stride(i_dist_st0_idx63), .o_vec(o_mt_st0_idx63)
);

assign lifm_st0_wo[WORD_WIDTH*128-1:WORD_WIDTH*127] = o_lifm_st0_idx63[WORD_WIDTH*2-1:WORD_WIDTH*1];
assign lifm_st0_wo[WORD_WIDTH*127-1:WORD_WIDTH*126] = o_lifm_st0_idx63[WORD_WIDTH*1-1:0] | lifm_st0_wi[WORD_WIDTH*127-1:WORD_WIDTH*126];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*128-1:DIST_WIDTH*MAX_LIFM_RSIZ*127] = o_mt_st0_idx63[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*1];
assign mt_st0_wo[DIST_WIDTH*MAX_LIFM_RSIZ*127-1:DIST_WIDTH*MAX_LIFM_RSIZ*126] = o_mt_st0_idx63[DIST_WIDTH*MAX_LIFM_RSIZ*1-1:0] | mt_st0_wi[DIST_WIDTH*MAX_LIFM_RSIZ*127-1:DIST_WIDTH*MAX_LIFM_RSIZ*126];



// Stage1
wire [128*WORD_WIDTH-1:0] lifm_st1_wi;  // stage input for LIFM
wire [128*WORD_WIDTH-1:0] lifm_st1_wo;  // stage output of LIFM
wire [128*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_st1_wi;  // stage input for MT
wire [128*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_st1_wo;  // stage output of MT

assign lifm_st1_wi = lifm_st0_wo;
assign mt_st1_wi = mt_st0_wo;

// Stage1 Index0
wire [WORD_WIDTH*2*2-1:0] i_lifm_st1_idx0;
wire [WORD_WIDTH*2*2-1:0] o_lifm_st1_idx0;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] i_mt_st1_idx0;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] o_mt_st1_idx0;
wire [2-1:0] i_dist_st1_idx0;

assign i_lifm_st1_idx0 = { lifm_st1_wi[WORD_WIDTH*4-1:WORD_WIDTH*2], { WORD_WIDTH*2{1'b0} } };
assign i_mt_st1_idx0   = { mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2], { DIST_WIDTH*MAX_LIFM_RSIZ*2{1'b0} } };
assign i_dist_st1_idx0 = psum[PSUM_WIDTH*2-1:PSUM_WIDTH*1];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(4), .NUMEL_LOG(2)
) vs_lifm_st1_idx0 (
    .i_vec(i_lifm_st1_idx0), .stride(i_dist_st1_idx0), .o_vec(o_lifm_st1_idx0)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(4), .NUMEL_LOG(2)
) vs_mt_st1_idx0 (
    .i_vec(i_mt_st1_idx0), .stride(i_dist_st1_idx0), .o_vec(o_mt_st1_idx0)
);

assign lifm_st1_wo[WORD_WIDTH*4-1:WORD_WIDTH*2] = o_lifm_st1_idx0[WORD_WIDTH*4-1:WORD_WIDTH*2];
assign lifm_st1_wo[WORD_WIDTH*2-1:WORD_WIDTH*0] = o_lifm_st1_idx0[WORD_WIDTH*2-1:0] | lifm_st1_wi[WORD_WIDTH*2-1:WORD_WIDTH*0];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2] = o_mt_st1_idx0[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*0] = o_mt_st1_idx0[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:0] | mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:DIST_WIDTH*MAX_LIFM_RSIZ*0];


// Stage1 Index1
wire [WORD_WIDTH*2*2-1:0] i_lifm_st1_idx1;
wire [WORD_WIDTH*2*2-1:0] o_lifm_st1_idx1;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] i_mt_st1_idx1;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] o_mt_st1_idx1;
wire [2-1:0] i_dist_st1_idx1;

assign i_lifm_st1_idx1 = { lifm_st1_wi[WORD_WIDTH*8-1:WORD_WIDTH*6], { WORD_WIDTH*2{1'b0} } };
assign i_mt_st1_idx1   = { mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*8-1:DIST_WIDTH*MAX_LIFM_RSIZ*6], { DIST_WIDTH*MAX_LIFM_RSIZ*2{1'b0} } };
assign i_dist_st1_idx1 = psum[PSUM_WIDTH*6-1:PSUM_WIDTH*5] - psum[PSUM_WIDTH*4-1:PSUM_WIDTH*3];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(4), .NUMEL_LOG(2)
) vs_lifm_st1_idx1 (
    .i_vec(i_lifm_st1_idx1), .stride(i_dist_st1_idx1), .o_vec(o_lifm_st1_idx1)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(4), .NUMEL_LOG(2)
) vs_mt_st1_idx1 (
    .i_vec(i_mt_st1_idx1), .stride(i_dist_st1_idx1), .o_vec(o_mt_st1_idx1)
);

assign lifm_st1_wo[WORD_WIDTH*8-1:WORD_WIDTH*6] = o_lifm_st1_idx1[WORD_WIDTH*4-1:WORD_WIDTH*2];
assign lifm_st1_wo[WORD_WIDTH*6-1:WORD_WIDTH*4] = o_lifm_st1_idx1[WORD_WIDTH*2-1:0] | lifm_st1_wi[WORD_WIDTH*6-1:WORD_WIDTH*4];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*8-1:DIST_WIDTH*MAX_LIFM_RSIZ*6] = o_mt_st1_idx1[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*6-1:DIST_WIDTH*MAX_LIFM_RSIZ*4] = o_mt_st1_idx1[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:0] | mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*6-1:DIST_WIDTH*MAX_LIFM_RSIZ*4];


// Stage1 Index2
wire [WORD_WIDTH*2*2-1:0] i_lifm_st1_idx2;
wire [WORD_WIDTH*2*2-1:0] o_lifm_st1_idx2;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] i_mt_st1_idx2;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] o_mt_st1_idx2;
wire [2-1:0] i_dist_st1_idx2;

assign i_lifm_st1_idx2 = { lifm_st1_wi[WORD_WIDTH*12-1:WORD_WIDTH*10], { WORD_WIDTH*2{1'b0} } };
assign i_mt_st1_idx2   = { mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*12-1:DIST_WIDTH*MAX_LIFM_RSIZ*10], { DIST_WIDTH*MAX_LIFM_RSIZ*2{1'b0} } };
assign i_dist_st1_idx2 = psum[PSUM_WIDTH*10-1:PSUM_WIDTH*9] - psum[PSUM_WIDTH*8-1:PSUM_WIDTH*7];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(4), .NUMEL_LOG(2)
) vs_lifm_st1_idx2 (
    .i_vec(i_lifm_st1_idx2), .stride(i_dist_st1_idx2), .o_vec(o_lifm_st1_idx2)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(4), .NUMEL_LOG(2)
) vs_mt_st1_idx2 (
    .i_vec(i_mt_st1_idx2), .stride(i_dist_st1_idx2), .o_vec(o_mt_st1_idx2)
);

assign lifm_st1_wo[WORD_WIDTH*12-1:WORD_WIDTH*10] = o_lifm_st1_idx2[WORD_WIDTH*4-1:WORD_WIDTH*2];
assign lifm_st1_wo[WORD_WIDTH*10-1:WORD_WIDTH*8] = o_lifm_st1_idx2[WORD_WIDTH*2-1:0] | lifm_st1_wi[WORD_WIDTH*10-1:WORD_WIDTH*8];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*12-1:DIST_WIDTH*MAX_LIFM_RSIZ*10] = o_mt_st1_idx2[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*10-1:DIST_WIDTH*MAX_LIFM_RSIZ*8] = o_mt_st1_idx2[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:0] | mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*10-1:DIST_WIDTH*MAX_LIFM_RSIZ*8];


// Stage1 Index3
wire [WORD_WIDTH*2*2-1:0] i_lifm_st1_idx3;
wire [WORD_WIDTH*2*2-1:0] o_lifm_st1_idx3;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] i_mt_st1_idx3;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] o_mt_st1_idx3;
wire [2-1:0] i_dist_st1_idx3;

assign i_lifm_st1_idx3 = { lifm_st1_wi[WORD_WIDTH*16-1:WORD_WIDTH*14], { WORD_WIDTH*2{1'b0} } };
assign i_mt_st1_idx3   = { mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*16-1:DIST_WIDTH*MAX_LIFM_RSIZ*14], { DIST_WIDTH*MAX_LIFM_RSIZ*2{1'b0} } };
assign i_dist_st1_idx3 = psum[PSUM_WIDTH*14-1:PSUM_WIDTH*13] - psum[PSUM_WIDTH*12-1:PSUM_WIDTH*11];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(4), .NUMEL_LOG(2)
) vs_lifm_st1_idx3 (
    .i_vec(i_lifm_st1_idx3), .stride(i_dist_st1_idx3), .o_vec(o_lifm_st1_idx3)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(4), .NUMEL_LOG(2)
) vs_mt_st1_idx3 (
    .i_vec(i_mt_st1_idx3), .stride(i_dist_st1_idx3), .o_vec(o_mt_st1_idx3)
);

assign lifm_st1_wo[WORD_WIDTH*16-1:WORD_WIDTH*14] = o_lifm_st1_idx3[WORD_WIDTH*4-1:WORD_WIDTH*2];
assign lifm_st1_wo[WORD_WIDTH*14-1:WORD_WIDTH*12] = o_lifm_st1_idx3[WORD_WIDTH*2-1:0] | lifm_st1_wi[WORD_WIDTH*14-1:WORD_WIDTH*12];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*16-1:DIST_WIDTH*MAX_LIFM_RSIZ*14] = o_mt_st1_idx3[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*14-1:DIST_WIDTH*MAX_LIFM_RSIZ*12] = o_mt_st1_idx3[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:0] | mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*14-1:DIST_WIDTH*MAX_LIFM_RSIZ*12];


// Stage1 Index4
wire [WORD_WIDTH*2*2-1:0] i_lifm_st1_idx4;
wire [WORD_WIDTH*2*2-1:0] o_lifm_st1_idx4;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] i_mt_st1_idx4;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] o_mt_st1_idx4;
wire [2-1:0] i_dist_st1_idx4;

assign i_lifm_st1_idx4 = { lifm_st1_wi[WORD_WIDTH*20-1:WORD_WIDTH*18], { WORD_WIDTH*2{1'b0} } };
assign i_mt_st1_idx4   = { mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*20-1:DIST_WIDTH*MAX_LIFM_RSIZ*18], { DIST_WIDTH*MAX_LIFM_RSIZ*2{1'b0} } };
assign i_dist_st1_idx4 = psum[PSUM_WIDTH*18-1:PSUM_WIDTH*17] - psum[PSUM_WIDTH*16-1:PSUM_WIDTH*15];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(4), .NUMEL_LOG(2)
) vs_lifm_st1_idx4 (
    .i_vec(i_lifm_st1_idx4), .stride(i_dist_st1_idx4), .o_vec(o_lifm_st1_idx4)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(4), .NUMEL_LOG(2)
) vs_mt_st1_idx4 (
    .i_vec(i_mt_st1_idx4), .stride(i_dist_st1_idx4), .o_vec(o_mt_st1_idx4)
);

assign lifm_st1_wo[WORD_WIDTH*20-1:WORD_WIDTH*18] = o_lifm_st1_idx4[WORD_WIDTH*4-1:WORD_WIDTH*2];
assign lifm_st1_wo[WORD_WIDTH*18-1:WORD_WIDTH*16] = o_lifm_st1_idx4[WORD_WIDTH*2-1:0] | lifm_st1_wi[WORD_WIDTH*18-1:WORD_WIDTH*16];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*20-1:DIST_WIDTH*MAX_LIFM_RSIZ*18] = o_mt_st1_idx4[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*18-1:DIST_WIDTH*MAX_LIFM_RSIZ*16] = o_mt_st1_idx4[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:0] | mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*18-1:DIST_WIDTH*MAX_LIFM_RSIZ*16];


// Stage1 Index5
wire [WORD_WIDTH*2*2-1:0] i_lifm_st1_idx5;
wire [WORD_WIDTH*2*2-1:0] o_lifm_st1_idx5;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] i_mt_st1_idx5;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] o_mt_st1_idx5;
wire [2-1:0] i_dist_st1_idx5;

assign i_lifm_st1_idx5 = { lifm_st1_wi[WORD_WIDTH*24-1:WORD_WIDTH*22], { WORD_WIDTH*2{1'b0} } };
assign i_mt_st1_idx5   = { mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*24-1:DIST_WIDTH*MAX_LIFM_RSIZ*22], { DIST_WIDTH*MAX_LIFM_RSIZ*2{1'b0} } };
assign i_dist_st1_idx5 = psum[PSUM_WIDTH*22-1:PSUM_WIDTH*21] - psum[PSUM_WIDTH*20-1:PSUM_WIDTH*19];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(4), .NUMEL_LOG(2)
) vs_lifm_st1_idx5 (
    .i_vec(i_lifm_st1_idx5), .stride(i_dist_st1_idx5), .o_vec(o_lifm_st1_idx5)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(4), .NUMEL_LOG(2)
) vs_mt_st1_idx5 (
    .i_vec(i_mt_st1_idx5), .stride(i_dist_st1_idx5), .o_vec(o_mt_st1_idx5)
);

assign lifm_st1_wo[WORD_WIDTH*24-1:WORD_WIDTH*22] = o_lifm_st1_idx5[WORD_WIDTH*4-1:WORD_WIDTH*2];
assign lifm_st1_wo[WORD_WIDTH*22-1:WORD_WIDTH*20] = o_lifm_st1_idx5[WORD_WIDTH*2-1:0] | lifm_st1_wi[WORD_WIDTH*22-1:WORD_WIDTH*20];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*24-1:DIST_WIDTH*MAX_LIFM_RSIZ*22] = o_mt_st1_idx5[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*22-1:DIST_WIDTH*MAX_LIFM_RSIZ*20] = o_mt_st1_idx5[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:0] | mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*22-1:DIST_WIDTH*MAX_LIFM_RSIZ*20];


// Stage1 Index6
wire [WORD_WIDTH*2*2-1:0] i_lifm_st1_idx6;
wire [WORD_WIDTH*2*2-1:0] o_lifm_st1_idx6;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] i_mt_st1_idx6;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] o_mt_st1_idx6;
wire [2-1:0] i_dist_st1_idx6;

assign i_lifm_st1_idx6 = { lifm_st1_wi[WORD_WIDTH*28-1:WORD_WIDTH*26], { WORD_WIDTH*2{1'b0} } };
assign i_mt_st1_idx6   = { mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*28-1:DIST_WIDTH*MAX_LIFM_RSIZ*26], { DIST_WIDTH*MAX_LIFM_RSIZ*2{1'b0} } };
assign i_dist_st1_idx6 = psum[PSUM_WIDTH*26-1:PSUM_WIDTH*25] - psum[PSUM_WIDTH*24-1:PSUM_WIDTH*23];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(4), .NUMEL_LOG(2)
) vs_lifm_st1_idx6 (
    .i_vec(i_lifm_st1_idx6), .stride(i_dist_st1_idx6), .o_vec(o_lifm_st1_idx6)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(4), .NUMEL_LOG(2)
) vs_mt_st1_idx6 (
    .i_vec(i_mt_st1_idx6), .stride(i_dist_st1_idx6), .o_vec(o_mt_st1_idx6)
);

assign lifm_st1_wo[WORD_WIDTH*28-1:WORD_WIDTH*26] = o_lifm_st1_idx6[WORD_WIDTH*4-1:WORD_WIDTH*2];
assign lifm_st1_wo[WORD_WIDTH*26-1:WORD_WIDTH*24] = o_lifm_st1_idx6[WORD_WIDTH*2-1:0] | lifm_st1_wi[WORD_WIDTH*26-1:WORD_WIDTH*24];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*28-1:DIST_WIDTH*MAX_LIFM_RSIZ*26] = o_mt_st1_idx6[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*26-1:DIST_WIDTH*MAX_LIFM_RSIZ*24] = o_mt_st1_idx6[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:0] | mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*26-1:DIST_WIDTH*MAX_LIFM_RSIZ*24];


// Stage1 Index7
wire [WORD_WIDTH*2*2-1:0] i_lifm_st1_idx7;
wire [WORD_WIDTH*2*2-1:0] o_lifm_st1_idx7;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] i_mt_st1_idx7;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] o_mt_st1_idx7;
wire [2-1:0] i_dist_st1_idx7;

assign i_lifm_st1_idx7 = { lifm_st1_wi[WORD_WIDTH*32-1:WORD_WIDTH*30], { WORD_WIDTH*2{1'b0} } };
assign i_mt_st1_idx7   = { mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*32-1:DIST_WIDTH*MAX_LIFM_RSIZ*30], { DIST_WIDTH*MAX_LIFM_RSIZ*2{1'b0} } };
assign i_dist_st1_idx7 = psum[PSUM_WIDTH*30-1:PSUM_WIDTH*29] - psum[PSUM_WIDTH*28-1:PSUM_WIDTH*27];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(4), .NUMEL_LOG(2)
) vs_lifm_st1_idx7 (
    .i_vec(i_lifm_st1_idx7), .stride(i_dist_st1_idx7), .o_vec(o_lifm_st1_idx7)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(4), .NUMEL_LOG(2)
) vs_mt_st1_idx7 (
    .i_vec(i_mt_st1_idx7), .stride(i_dist_st1_idx7), .o_vec(o_mt_st1_idx7)
);

assign lifm_st1_wo[WORD_WIDTH*32-1:WORD_WIDTH*30] = o_lifm_st1_idx7[WORD_WIDTH*4-1:WORD_WIDTH*2];
assign lifm_st1_wo[WORD_WIDTH*30-1:WORD_WIDTH*28] = o_lifm_st1_idx7[WORD_WIDTH*2-1:0] | lifm_st1_wi[WORD_WIDTH*30-1:WORD_WIDTH*28];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*32-1:DIST_WIDTH*MAX_LIFM_RSIZ*30] = o_mt_st1_idx7[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*30-1:DIST_WIDTH*MAX_LIFM_RSIZ*28] = o_mt_st1_idx7[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:0] | mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*30-1:DIST_WIDTH*MAX_LIFM_RSIZ*28];


// Stage1 Index8
wire [WORD_WIDTH*2*2-1:0] i_lifm_st1_idx8;
wire [WORD_WIDTH*2*2-1:0] o_lifm_st1_idx8;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] i_mt_st1_idx8;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] o_mt_st1_idx8;
wire [2-1:0] i_dist_st1_idx8;

assign i_lifm_st1_idx8 = { lifm_st1_wi[WORD_WIDTH*36-1:WORD_WIDTH*34], { WORD_WIDTH*2{1'b0} } };
assign i_mt_st1_idx8   = { mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*36-1:DIST_WIDTH*MAX_LIFM_RSIZ*34], { DIST_WIDTH*MAX_LIFM_RSIZ*2{1'b0} } };
assign i_dist_st1_idx8 = psum[PSUM_WIDTH*34-1:PSUM_WIDTH*33] - psum[PSUM_WIDTH*32-1:PSUM_WIDTH*31];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(4), .NUMEL_LOG(2)
) vs_lifm_st1_idx8 (
    .i_vec(i_lifm_st1_idx8), .stride(i_dist_st1_idx8), .o_vec(o_lifm_st1_idx8)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(4), .NUMEL_LOG(2)
) vs_mt_st1_idx8 (
    .i_vec(i_mt_st1_idx8), .stride(i_dist_st1_idx8), .o_vec(o_mt_st1_idx8)
);

assign lifm_st1_wo[WORD_WIDTH*36-1:WORD_WIDTH*34] = o_lifm_st1_idx8[WORD_WIDTH*4-1:WORD_WIDTH*2];
assign lifm_st1_wo[WORD_WIDTH*34-1:WORD_WIDTH*32] = o_lifm_st1_idx8[WORD_WIDTH*2-1:0] | lifm_st1_wi[WORD_WIDTH*34-1:WORD_WIDTH*32];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*36-1:DIST_WIDTH*MAX_LIFM_RSIZ*34] = o_mt_st1_idx8[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*34-1:DIST_WIDTH*MAX_LIFM_RSIZ*32] = o_mt_st1_idx8[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:0] | mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*34-1:DIST_WIDTH*MAX_LIFM_RSIZ*32];


// Stage1 Index9
wire [WORD_WIDTH*2*2-1:0] i_lifm_st1_idx9;
wire [WORD_WIDTH*2*2-1:0] o_lifm_st1_idx9;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] i_mt_st1_idx9;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] o_mt_st1_idx9;
wire [2-1:0] i_dist_st1_idx9;

assign i_lifm_st1_idx9 = { lifm_st1_wi[WORD_WIDTH*40-1:WORD_WIDTH*38], { WORD_WIDTH*2{1'b0} } };
assign i_mt_st1_idx9   = { mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*40-1:DIST_WIDTH*MAX_LIFM_RSIZ*38], { DIST_WIDTH*MAX_LIFM_RSIZ*2{1'b0} } };
assign i_dist_st1_idx9 = psum[PSUM_WIDTH*38-1:PSUM_WIDTH*37] - psum[PSUM_WIDTH*36-1:PSUM_WIDTH*35];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(4), .NUMEL_LOG(2)
) vs_lifm_st1_idx9 (
    .i_vec(i_lifm_st1_idx9), .stride(i_dist_st1_idx9), .o_vec(o_lifm_st1_idx9)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(4), .NUMEL_LOG(2)
) vs_mt_st1_idx9 (
    .i_vec(i_mt_st1_idx9), .stride(i_dist_st1_idx9), .o_vec(o_mt_st1_idx9)
);

assign lifm_st1_wo[WORD_WIDTH*40-1:WORD_WIDTH*38] = o_lifm_st1_idx9[WORD_WIDTH*4-1:WORD_WIDTH*2];
assign lifm_st1_wo[WORD_WIDTH*38-1:WORD_WIDTH*36] = o_lifm_st1_idx9[WORD_WIDTH*2-1:0] | lifm_st1_wi[WORD_WIDTH*38-1:WORD_WIDTH*36];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*40-1:DIST_WIDTH*MAX_LIFM_RSIZ*38] = o_mt_st1_idx9[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*38-1:DIST_WIDTH*MAX_LIFM_RSIZ*36] = o_mt_st1_idx9[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:0] | mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*38-1:DIST_WIDTH*MAX_LIFM_RSIZ*36];


// Stage1 Index10
wire [WORD_WIDTH*2*2-1:0] i_lifm_st1_idx10;
wire [WORD_WIDTH*2*2-1:0] o_lifm_st1_idx10;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] i_mt_st1_idx10;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] o_mt_st1_idx10;
wire [2-1:0] i_dist_st1_idx10;

assign i_lifm_st1_idx10 = { lifm_st1_wi[WORD_WIDTH*44-1:WORD_WIDTH*42], { WORD_WIDTH*2{1'b0} } };
assign i_mt_st1_idx10   = { mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*44-1:DIST_WIDTH*MAX_LIFM_RSIZ*42], { DIST_WIDTH*MAX_LIFM_RSIZ*2{1'b0} } };
assign i_dist_st1_idx10 = psum[PSUM_WIDTH*42-1:PSUM_WIDTH*41] - psum[PSUM_WIDTH*40-1:PSUM_WIDTH*39];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(4), .NUMEL_LOG(2)
) vs_lifm_st1_idx10 (
    .i_vec(i_lifm_st1_idx10), .stride(i_dist_st1_idx10), .o_vec(o_lifm_st1_idx10)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(4), .NUMEL_LOG(2)
) vs_mt_st1_idx10 (
    .i_vec(i_mt_st1_idx10), .stride(i_dist_st1_idx10), .o_vec(o_mt_st1_idx10)
);

assign lifm_st1_wo[WORD_WIDTH*44-1:WORD_WIDTH*42] = o_lifm_st1_idx10[WORD_WIDTH*4-1:WORD_WIDTH*2];
assign lifm_st1_wo[WORD_WIDTH*42-1:WORD_WIDTH*40] = o_lifm_st1_idx10[WORD_WIDTH*2-1:0] | lifm_st1_wi[WORD_WIDTH*42-1:WORD_WIDTH*40];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*44-1:DIST_WIDTH*MAX_LIFM_RSIZ*42] = o_mt_st1_idx10[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*42-1:DIST_WIDTH*MAX_LIFM_RSIZ*40] = o_mt_st1_idx10[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:0] | mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*42-1:DIST_WIDTH*MAX_LIFM_RSIZ*40];


// Stage1 Index11
wire [WORD_WIDTH*2*2-1:0] i_lifm_st1_idx11;
wire [WORD_WIDTH*2*2-1:0] o_lifm_st1_idx11;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] i_mt_st1_idx11;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] o_mt_st1_idx11;
wire [2-1:0] i_dist_st1_idx11;

assign i_lifm_st1_idx11 = { lifm_st1_wi[WORD_WIDTH*48-1:WORD_WIDTH*46], { WORD_WIDTH*2{1'b0} } };
assign i_mt_st1_idx11   = { mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*48-1:DIST_WIDTH*MAX_LIFM_RSIZ*46], { DIST_WIDTH*MAX_LIFM_RSIZ*2{1'b0} } };
assign i_dist_st1_idx11 = psum[PSUM_WIDTH*46-1:PSUM_WIDTH*45] - psum[PSUM_WIDTH*44-1:PSUM_WIDTH*43];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(4), .NUMEL_LOG(2)
) vs_lifm_st1_idx11 (
    .i_vec(i_lifm_st1_idx11), .stride(i_dist_st1_idx11), .o_vec(o_lifm_st1_idx11)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(4), .NUMEL_LOG(2)
) vs_mt_st1_idx11 (
    .i_vec(i_mt_st1_idx11), .stride(i_dist_st1_idx11), .o_vec(o_mt_st1_idx11)
);

assign lifm_st1_wo[WORD_WIDTH*48-1:WORD_WIDTH*46] = o_lifm_st1_idx11[WORD_WIDTH*4-1:WORD_WIDTH*2];
assign lifm_st1_wo[WORD_WIDTH*46-1:WORD_WIDTH*44] = o_lifm_st1_idx11[WORD_WIDTH*2-1:0] | lifm_st1_wi[WORD_WIDTH*46-1:WORD_WIDTH*44];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*48-1:DIST_WIDTH*MAX_LIFM_RSIZ*46] = o_mt_st1_idx11[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*46-1:DIST_WIDTH*MAX_LIFM_RSIZ*44] = o_mt_st1_idx11[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:0] | mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*46-1:DIST_WIDTH*MAX_LIFM_RSIZ*44];


// Stage1 Index12
wire [WORD_WIDTH*2*2-1:0] i_lifm_st1_idx12;
wire [WORD_WIDTH*2*2-1:0] o_lifm_st1_idx12;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] i_mt_st1_idx12;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] o_mt_st1_idx12;
wire [2-1:0] i_dist_st1_idx12;

assign i_lifm_st1_idx12 = { lifm_st1_wi[WORD_WIDTH*52-1:WORD_WIDTH*50], { WORD_WIDTH*2{1'b0} } };
assign i_mt_st1_idx12   = { mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*52-1:DIST_WIDTH*MAX_LIFM_RSIZ*50], { DIST_WIDTH*MAX_LIFM_RSIZ*2{1'b0} } };
assign i_dist_st1_idx12 = psum[PSUM_WIDTH*50-1:PSUM_WIDTH*49] - psum[PSUM_WIDTH*48-1:PSUM_WIDTH*47];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(4), .NUMEL_LOG(2)
) vs_lifm_st1_idx12 (
    .i_vec(i_lifm_st1_idx12), .stride(i_dist_st1_idx12), .o_vec(o_lifm_st1_idx12)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(4), .NUMEL_LOG(2)
) vs_mt_st1_idx12 (
    .i_vec(i_mt_st1_idx12), .stride(i_dist_st1_idx12), .o_vec(o_mt_st1_idx12)
);

assign lifm_st1_wo[WORD_WIDTH*52-1:WORD_WIDTH*50] = o_lifm_st1_idx12[WORD_WIDTH*4-1:WORD_WIDTH*2];
assign lifm_st1_wo[WORD_WIDTH*50-1:WORD_WIDTH*48] = o_lifm_st1_idx12[WORD_WIDTH*2-1:0] | lifm_st1_wi[WORD_WIDTH*50-1:WORD_WIDTH*48];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*52-1:DIST_WIDTH*MAX_LIFM_RSIZ*50] = o_mt_st1_idx12[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*50-1:DIST_WIDTH*MAX_LIFM_RSIZ*48] = o_mt_st1_idx12[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:0] | mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*50-1:DIST_WIDTH*MAX_LIFM_RSIZ*48];


// Stage1 Index13
wire [WORD_WIDTH*2*2-1:0] i_lifm_st1_idx13;
wire [WORD_WIDTH*2*2-1:0] o_lifm_st1_idx13;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] i_mt_st1_idx13;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] o_mt_st1_idx13;
wire [2-1:0] i_dist_st1_idx13;

assign i_lifm_st1_idx13 = { lifm_st1_wi[WORD_WIDTH*56-1:WORD_WIDTH*54], { WORD_WIDTH*2{1'b0} } };
assign i_mt_st1_idx13   = { mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*56-1:DIST_WIDTH*MAX_LIFM_RSIZ*54], { DIST_WIDTH*MAX_LIFM_RSIZ*2{1'b0} } };
assign i_dist_st1_idx13 = psum[PSUM_WIDTH*54-1:PSUM_WIDTH*53] - psum[PSUM_WIDTH*52-1:PSUM_WIDTH*51];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(4), .NUMEL_LOG(2)
) vs_lifm_st1_idx13 (
    .i_vec(i_lifm_st1_idx13), .stride(i_dist_st1_idx13), .o_vec(o_lifm_st1_idx13)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(4), .NUMEL_LOG(2)
) vs_mt_st1_idx13 (
    .i_vec(i_mt_st1_idx13), .stride(i_dist_st1_idx13), .o_vec(o_mt_st1_idx13)
);

assign lifm_st1_wo[WORD_WIDTH*56-1:WORD_WIDTH*54] = o_lifm_st1_idx13[WORD_WIDTH*4-1:WORD_WIDTH*2];
assign lifm_st1_wo[WORD_WIDTH*54-1:WORD_WIDTH*52] = o_lifm_st1_idx13[WORD_WIDTH*2-1:0] | lifm_st1_wi[WORD_WIDTH*54-1:WORD_WIDTH*52];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*56-1:DIST_WIDTH*MAX_LIFM_RSIZ*54] = o_mt_st1_idx13[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*54-1:DIST_WIDTH*MAX_LIFM_RSIZ*52] = o_mt_st1_idx13[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:0] | mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*54-1:DIST_WIDTH*MAX_LIFM_RSIZ*52];


// Stage1 Index14
wire [WORD_WIDTH*2*2-1:0] i_lifm_st1_idx14;
wire [WORD_WIDTH*2*2-1:0] o_lifm_st1_idx14;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] i_mt_st1_idx14;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] o_mt_st1_idx14;
wire [2-1:0] i_dist_st1_idx14;

assign i_lifm_st1_idx14 = { lifm_st1_wi[WORD_WIDTH*60-1:WORD_WIDTH*58], { WORD_WIDTH*2{1'b0} } };
assign i_mt_st1_idx14   = { mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*60-1:DIST_WIDTH*MAX_LIFM_RSIZ*58], { DIST_WIDTH*MAX_LIFM_RSIZ*2{1'b0} } };
assign i_dist_st1_idx14 = psum[PSUM_WIDTH*58-1:PSUM_WIDTH*57] - psum[PSUM_WIDTH*56-1:PSUM_WIDTH*55];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(4), .NUMEL_LOG(2)
) vs_lifm_st1_idx14 (
    .i_vec(i_lifm_st1_idx14), .stride(i_dist_st1_idx14), .o_vec(o_lifm_st1_idx14)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(4), .NUMEL_LOG(2)
) vs_mt_st1_idx14 (
    .i_vec(i_mt_st1_idx14), .stride(i_dist_st1_idx14), .o_vec(o_mt_st1_idx14)
);

assign lifm_st1_wo[WORD_WIDTH*60-1:WORD_WIDTH*58] = o_lifm_st1_idx14[WORD_WIDTH*4-1:WORD_WIDTH*2];
assign lifm_st1_wo[WORD_WIDTH*58-1:WORD_WIDTH*56] = o_lifm_st1_idx14[WORD_WIDTH*2-1:0] | lifm_st1_wi[WORD_WIDTH*58-1:WORD_WIDTH*56];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*60-1:DIST_WIDTH*MAX_LIFM_RSIZ*58] = o_mt_st1_idx14[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*58-1:DIST_WIDTH*MAX_LIFM_RSIZ*56] = o_mt_st1_idx14[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:0] | mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*58-1:DIST_WIDTH*MAX_LIFM_RSIZ*56];


// Stage1 Index15
wire [WORD_WIDTH*2*2-1:0] i_lifm_st1_idx15;
wire [WORD_WIDTH*2*2-1:0] o_lifm_st1_idx15;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] i_mt_st1_idx15;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] o_mt_st1_idx15;
wire [2-1:0] i_dist_st1_idx15;

assign i_lifm_st1_idx15 = { lifm_st1_wi[WORD_WIDTH*64-1:WORD_WIDTH*62], { WORD_WIDTH*2{1'b0} } };
assign i_mt_st1_idx15   = { mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*64-1:DIST_WIDTH*MAX_LIFM_RSIZ*62], { DIST_WIDTH*MAX_LIFM_RSIZ*2{1'b0} } };
assign i_dist_st1_idx15 = psum[PSUM_WIDTH*62-1:PSUM_WIDTH*61] - psum[PSUM_WIDTH*60-1:PSUM_WIDTH*59];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(4), .NUMEL_LOG(2)
) vs_lifm_st1_idx15 (
    .i_vec(i_lifm_st1_idx15), .stride(i_dist_st1_idx15), .o_vec(o_lifm_st1_idx15)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(4), .NUMEL_LOG(2)
) vs_mt_st1_idx15 (
    .i_vec(i_mt_st1_idx15), .stride(i_dist_st1_idx15), .o_vec(o_mt_st1_idx15)
);

assign lifm_st1_wo[WORD_WIDTH*64-1:WORD_WIDTH*62] = o_lifm_st1_idx15[WORD_WIDTH*4-1:WORD_WIDTH*2];
assign lifm_st1_wo[WORD_WIDTH*62-1:WORD_WIDTH*60] = o_lifm_st1_idx15[WORD_WIDTH*2-1:0] | lifm_st1_wi[WORD_WIDTH*62-1:WORD_WIDTH*60];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*64-1:DIST_WIDTH*MAX_LIFM_RSIZ*62] = o_mt_st1_idx15[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*62-1:DIST_WIDTH*MAX_LIFM_RSIZ*60] = o_mt_st1_idx15[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:0] | mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*62-1:DIST_WIDTH*MAX_LIFM_RSIZ*60];


// Stage1 Index16
wire [WORD_WIDTH*2*2-1:0] i_lifm_st1_idx16;
wire [WORD_WIDTH*2*2-1:0] o_lifm_st1_idx16;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] i_mt_st1_idx16;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] o_mt_st1_idx16;
wire [2-1:0] i_dist_st1_idx16;

assign i_lifm_st1_idx16 = { lifm_st1_wi[WORD_WIDTH*68-1:WORD_WIDTH*66], { WORD_WIDTH*2{1'b0} } };
assign i_mt_st1_idx16   = { mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*68-1:DIST_WIDTH*MAX_LIFM_RSIZ*66], { DIST_WIDTH*MAX_LIFM_RSIZ*2{1'b0} } };
assign i_dist_st1_idx16 = psum[PSUM_WIDTH*66-1:PSUM_WIDTH*65] - psum[PSUM_WIDTH*64-1:PSUM_WIDTH*63];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(4), .NUMEL_LOG(2)
) vs_lifm_st1_idx16 (
    .i_vec(i_lifm_st1_idx16), .stride(i_dist_st1_idx16), .o_vec(o_lifm_st1_idx16)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(4), .NUMEL_LOG(2)
) vs_mt_st1_idx16 (
    .i_vec(i_mt_st1_idx16), .stride(i_dist_st1_idx16), .o_vec(o_mt_st1_idx16)
);

assign lifm_st1_wo[WORD_WIDTH*68-1:WORD_WIDTH*66] = o_lifm_st1_idx16[WORD_WIDTH*4-1:WORD_WIDTH*2];
assign lifm_st1_wo[WORD_WIDTH*66-1:WORD_WIDTH*64] = o_lifm_st1_idx16[WORD_WIDTH*2-1:0] | lifm_st1_wi[WORD_WIDTH*66-1:WORD_WIDTH*64];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*68-1:DIST_WIDTH*MAX_LIFM_RSIZ*66] = o_mt_st1_idx16[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*66-1:DIST_WIDTH*MAX_LIFM_RSIZ*64] = o_mt_st1_idx16[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:0] | mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*66-1:DIST_WIDTH*MAX_LIFM_RSIZ*64];


// Stage1 Index17
wire [WORD_WIDTH*2*2-1:0] i_lifm_st1_idx17;
wire [WORD_WIDTH*2*2-1:0] o_lifm_st1_idx17;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] i_mt_st1_idx17;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] o_mt_st1_idx17;
wire [2-1:0] i_dist_st1_idx17;

assign i_lifm_st1_idx17 = { lifm_st1_wi[WORD_WIDTH*72-1:WORD_WIDTH*70], { WORD_WIDTH*2{1'b0} } };
assign i_mt_st1_idx17   = { mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*72-1:DIST_WIDTH*MAX_LIFM_RSIZ*70], { DIST_WIDTH*MAX_LIFM_RSIZ*2{1'b0} } };
assign i_dist_st1_idx17 = psum[PSUM_WIDTH*70-1:PSUM_WIDTH*69] - psum[PSUM_WIDTH*68-1:PSUM_WIDTH*67];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(4), .NUMEL_LOG(2)
) vs_lifm_st1_idx17 (
    .i_vec(i_lifm_st1_idx17), .stride(i_dist_st1_idx17), .o_vec(o_lifm_st1_idx17)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(4), .NUMEL_LOG(2)
) vs_mt_st1_idx17 (
    .i_vec(i_mt_st1_idx17), .stride(i_dist_st1_idx17), .o_vec(o_mt_st1_idx17)
);

assign lifm_st1_wo[WORD_WIDTH*72-1:WORD_WIDTH*70] = o_lifm_st1_idx17[WORD_WIDTH*4-1:WORD_WIDTH*2];
assign lifm_st1_wo[WORD_WIDTH*70-1:WORD_WIDTH*68] = o_lifm_st1_idx17[WORD_WIDTH*2-1:0] | lifm_st1_wi[WORD_WIDTH*70-1:WORD_WIDTH*68];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*72-1:DIST_WIDTH*MAX_LIFM_RSIZ*70] = o_mt_st1_idx17[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*70-1:DIST_WIDTH*MAX_LIFM_RSIZ*68] = o_mt_st1_idx17[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:0] | mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*70-1:DIST_WIDTH*MAX_LIFM_RSIZ*68];


// Stage1 Index18
wire [WORD_WIDTH*2*2-1:0] i_lifm_st1_idx18;
wire [WORD_WIDTH*2*2-1:0] o_lifm_st1_idx18;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] i_mt_st1_idx18;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] o_mt_st1_idx18;
wire [2-1:0] i_dist_st1_idx18;

assign i_lifm_st1_idx18 = { lifm_st1_wi[WORD_WIDTH*76-1:WORD_WIDTH*74], { WORD_WIDTH*2{1'b0} } };
assign i_mt_st1_idx18   = { mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*76-1:DIST_WIDTH*MAX_LIFM_RSIZ*74], { DIST_WIDTH*MAX_LIFM_RSIZ*2{1'b0} } };
assign i_dist_st1_idx18 = psum[PSUM_WIDTH*74-1:PSUM_WIDTH*73] - psum[PSUM_WIDTH*72-1:PSUM_WIDTH*71];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(4), .NUMEL_LOG(2)
) vs_lifm_st1_idx18 (
    .i_vec(i_lifm_st1_idx18), .stride(i_dist_st1_idx18), .o_vec(o_lifm_st1_idx18)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(4), .NUMEL_LOG(2)
) vs_mt_st1_idx18 (
    .i_vec(i_mt_st1_idx18), .stride(i_dist_st1_idx18), .o_vec(o_mt_st1_idx18)
);

assign lifm_st1_wo[WORD_WIDTH*76-1:WORD_WIDTH*74] = o_lifm_st1_idx18[WORD_WIDTH*4-1:WORD_WIDTH*2];
assign lifm_st1_wo[WORD_WIDTH*74-1:WORD_WIDTH*72] = o_lifm_st1_idx18[WORD_WIDTH*2-1:0] | lifm_st1_wi[WORD_WIDTH*74-1:WORD_WIDTH*72];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*76-1:DIST_WIDTH*MAX_LIFM_RSIZ*74] = o_mt_st1_idx18[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*74-1:DIST_WIDTH*MAX_LIFM_RSIZ*72] = o_mt_st1_idx18[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:0] | mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*74-1:DIST_WIDTH*MAX_LIFM_RSIZ*72];


// Stage1 Index19
wire [WORD_WIDTH*2*2-1:0] i_lifm_st1_idx19;
wire [WORD_WIDTH*2*2-1:0] o_lifm_st1_idx19;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] i_mt_st1_idx19;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] o_mt_st1_idx19;
wire [2-1:0] i_dist_st1_idx19;

assign i_lifm_st1_idx19 = { lifm_st1_wi[WORD_WIDTH*80-1:WORD_WIDTH*78], { WORD_WIDTH*2{1'b0} } };
assign i_mt_st1_idx19   = { mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*80-1:DIST_WIDTH*MAX_LIFM_RSIZ*78], { DIST_WIDTH*MAX_LIFM_RSIZ*2{1'b0} } };
assign i_dist_st1_idx19 = psum[PSUM_WIDTH*78-1:PSUM_WIDTH*77] - psum[PSUM_WIDTH*76-1:PSUM_WIDTH*75];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(4), .NUMEL_LOG(2)
) vs_lifm_st1_idx19 (
    .i_vec(i_lifm_st1_idx19), .stride(i_dist_st1_idx19), .o_vec(o_lifm_st1_idx19)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(4), .NUMEL_LOG(2)
) vs_mt_st1_idx19 (
    .i_vec(i_mt_st1_idx19), .stride(i_dist_st1_idx19), .o_vec(o_mt_st1_idx19)
);

assign lifm_st1_wo[WORD_WIDTH*80-1:WORD_WIDTH*78] = o_lifm_st1_idx19[WORD_WIDTH*4-1:WORD_WIDTH*2];
assign lifm_st1_wo[WORD_WIDTH*78-1:WORD_WIDTH*76] = o_lifm_st1_idx19[WORD_WIDTH*2-1:0] | lifm_st1_wi[WORD_WIDTH*78-1:WORD_WIDTH*76];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*80-1:DIST_WIDTH*MAX_LIFM_RSIZ*78] = o_mt_st1_idx19[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*78-1:DIST_WIDTH*MAX_LIFM_RSIZ*76] = o_mt_st1_idx19[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:0] | mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*78-1:DIST_WIDTH*MAX_LIFM_RSIZ*76];


// Stage1 Index20
wire [WORD_WIDTH*2*2-1:0] i_lifm_st1_idx20;
wire [WORD_WIDTH*2*2-1:0] o_lifm_st1_idx20;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] i_mt_st1_idx20;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] o_mt_st1_idx20;
wire [2-1:0] i_dist_st1_idx20;

assign i_lifm_st1_idx20 = { lifm_st1_wi[WORD_WIDTH*84-1:WORD_WIDTH*82], { WORD_WIDTH*2{1'b0} } };
assign i_mt_st1_idx20   = { mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*84-1:DIST_WIDTH*MAX_LIFM_RSIZ*82], { DIST_WIDTH*MAX_LIFM_RSIZ*2{1'b0} } };
assign i_dist_st1_idx20 = psum[PSUM_WIDTH*82-1:PSUM_WIDTH*81] - psum[PSUM_WIDTH*80-1:PSUM_WIDTH*79];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(4), .NUMEL_LOG(2)
) vs_lifm_st1_idx20 (
    .i_vec(i_lifm_st1_idx20), .stride(i_dist_st1_idx20), .o_vec(o_lifm_st1_idx20)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(4), .NUMEL_LOG(2)
) vs_mt_st1_idx20 (
    .i_vec(i_mt_st1_idx20), .stride(i_dist_st1_idx20), .o_vec(o_mt_st1_idx20)
);

assign lifm_st1_wo[WORD_WIDTH*84-1:WORD_WIDTH*82] = o_lifm_st1_idx20[WORD_WIDTH*4-1:WORD_WIDTH*2];
assign lifm_st1_wo[WORD_WIDTH*82-1:WORD_WIDTH*80] = o_lifm_st1_idx20[WORD_WIDTH*2-1:0] | lifm_st1_wi[WORD_WIDTH*82-1:WORD_WIDTH*80];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*84-1:DIST_WIDTH*MAX_LIFM_RSIZ*82] = o_mt_st1_idx20[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*82-1:DIST_WIDTH*MAX_LIFM_RSIZ*80] = o_mt_st1_idx20[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:0] | mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*82-1:DIST_WIDTH*MAX_LIFM_RSIZ*80];


// Stage1 Index21
wire [WORD_WIDTH*2*2-1:0] i_lifm_st1_idx21;
wire [WORD_WIDTH*2*2-1:0] o_lifm_st1_idx21;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] i_mt_st1_idx21;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] o_mt_st1_idx21;
wire [2-1:0] i_dist_st1_idx21;

assign i_lifm_st1_idx21 = { lifm_st1_wi[WORD_WIDTH*88-1:WORD_WIDTH*86], { WORD_WIDTH*2{1'b0} } };
assign i_mt_st1_idx21   = { mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*88-1:DIST_WIDTH*MAX_LIFM_RSIZ*86], { DIST_WIDTH*MAX_LIFM_RSIZ*2{1'b0} } };
assign i_dist_st1_idx21 = psum[PSUM_WIDTH*86-1:PSUM_WIDTH*85] - psum[PSUM_WIDTH*84-1:PSUM_WIDTH*83];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(4), .NUMEL_LOG(2)
) vs_lifm_st1_idx21 (
    .i_vec(i_lifm_st1_idx21), .stride(i_dist_st1_idx21), .o_vec(o_lifm_st1_idx21)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(4), .NUMEL_LOG(2)
) vs_mt_st1_idx21 (
    .i_vec(i_mt_st1_idx21), .stride(i_dist_st1_idx21), .o_vec(o_mt_st1_idx21)
);

assign lifm_st1_wo[WORD_WIDTH*88-1:WORD_WIDTH*86] = o_lifm_st1_idx21[WORD_WIDTH*4-1:WORD_WIDTH*2];
assign lifm_st1_wo[WORD_WIDTH*86-1:WORD_WIDTH*84] = o_lifm_st1_idx21[WORD_WIDTH*2-1:0] | lifm_st1_wi[WORD_WIDTH*86-1:WORD_WIDTH*84];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*88-1:DIST_WIDTH*MAX_LIFM_RSIZ*86] = o_mt_st1_idx21[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*86-1:DIST_WIDTH*MAX_LIFM_RSIZ*84] = o_mt_st1_idx21[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:0] | mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*86-1:DIST_WIDTH*MAX_LIFM_RSIZ*84];


// Stage1 Index22
wire [WORD_WIDTH*2*2-1:0] i_lifm_st1_idx22;
wire [WORD_WIDTH*2*2-1:0] o_lifm_st1_idx22;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] i_mt_st1_idx22;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] o_mt_st1_idx22;
wire [2-1:0] i_dist_st1_idx22;

assign i_lifm_st1_idx22 = { lifm_st1_wi[WORD_WIDTH*92-1:WORD_WIDTH*90], { WORD_WIDTH*2{1'b0} } };
assign i_mt_st1_idx22   = { mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*92-1:DIST_WIDTH*MAX_LIFM_RSIZ*90], { DIST_WIDTH*MAX_LIFM_RSIZ*2{1'b0} } };
assign i_dist_st1_idx22 = psum[PSUM_WIDTH*90-1:PSUM_WIDTH*89] - psum[PSUM_WIDTH*88-1:PSUM_WIDTH*87];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(4), .NUMEL_LOG(2)
) vs_lifm_st1_idx22 (
    .i_vec(i_lifm_st1_idx22), .stride(i_dist_st1_idx22), .o_vec(o_lifm_st1_idx22)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(4), .NUMEL_LOG(2)
) vs_mt_st1_idx22 (
    .i_vec(i_mt_st1_idx22), .stride(i_dist_st1_idx22), .o_vec(o_mt_st1_idx22)
);

assign lifm_st1_wo[WORD_WIDTH*92-1:WORD_WIDTH*90] = o_lifm_st1_idx22[WORD_WIDTH*4-1:WORD_WIDTH*2];
assign lifm_st1_wo[WORD_WIDTH*90-1:WORD_WIDTH*88] = o_lifm_st1_idx22[WORD_WIDTH*2-1:0] | lifm_st1_wi[WORD_WIDTH*90-1:WORD_WIDTH*88];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*92-1:DIST_WIDTH*MAX_LIFM_RSIZ*90] = o_mt_st1_idx22[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*90-1:DIST_WIDTH*MAX_LIFM_RSIZ*88] = o_mt_st1_idx22[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:0] | mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*90-1:DIST_WIDTH*MAX_LIFM_RSIZ*88];


// Stage1 Index23
wire [WORD_WIDTH*2*2-1:0] i_lifm_st1_idx23;
wire [WORD_WIDTH*2*2-1:0] o_lifm_st1_idx23;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] i_mt_st1_idx23;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] o_mt_st1_idx23;
wire [2-1:0] i_dist_st1_idx23;

assign i_lifm_st1_idx23 = { lifm_st1_wi[WORD_WIDTH*96-1:WORD_WIDTH*94], { WORD_WIDTH*2{1'b0} } };
assign i_mt_st1_idx23   = { mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*96-1:DIST_WIDTH*MAX_LIFM_RSIZ*94], { DIST_WIDTH*MAX_LIFM_RSIZ*2{1'b0} } };
assign i_dist_st1_idx23 = psum[PSUM_WIDTH*94-1:PSUM_WIDTH*93] - psum[PSUM_WIDTH*92-1:PSUM_WIDTH*91];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(4), .NUMEL_LOG(2)
) vs_lifm_st1_idx23 (
    .i_vec(i_lifm_st1_idx23), .stride(i_dist_st1_idx23), .o_vec(o_lifm_st1_idx23)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(4), .NUMEL_LOG(2)
) vs_mt_st1_idx23 (
    .i_vec(i_mt_st1_idx23), .stride(i_dist_st1_idx23), .o_vec(o_mt_st1_idx23)
);

assign lifm_st1_wo[WORD_WIDTH*96-1:WORD_WIDTH*94] = o_lifm_st1_idx23[WORD_WIDTH*4-1:WORD_WIDTH*2];
assign lifm_st1_wo[WORD_WIDTH*94-1:WORD_WIDTH*92] = o_lifm_st1_idx23[WORD_WIDTH*2-1:0] | lifm_st1_wi[WORD_WIDTH*94-1:WORD_WIDTH*92];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*96-1:DIST_WIDTH*MAX_LIFM_RSIZ*94] = o_mt_st1_idx23[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*94-1:DIST_WIDTH*MAX_LIFM_RSIZ*92] = o_mt_st1_idx23[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:0] | mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*94-1:DIST_WIDTH*MAX_LIFM_RSIZ*92];


// Stage1 Index24
wire [WORD_WIDTH*2*2-1:0] i_lifm_st1_idx24;
wire [WORD_WIDTH*2*2-1:0] o_lifm_st1_idx24;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] i_mt_st1_idx24;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] o_mt_st1_idx24;
wire [2-1:0] i_dist_st1_idx24;

assign i_lifm_st1_idx24 = { lifm_st1_wi[WORD_WIDTH*100-1:WORD_WIDTH*98], { WORD_WIDTH*2{1'b0} } };
assign i_mt_st1_idx24   = { mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*100-1:DIST_WIDTH*MAX_LIFM_RSIZ*98], { DIST_WIDTH*MAX_LIFM_RSIZ*2{1'b0} } };
assign i_dist_st1_idx24 = psum[PSUM_WIDTH*98-1:PSUM_WIDTH*97] - psum[PSUM_WIDTH*96-1:PSUM_WIDTH*95];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(4), .NUMEL_LOG(2)
) vs_lifm_st1_idx24 (
    .i_vec(i_lifm_st1_idx24), .stride(i_dist_st1_idx24), .o_vec(o_lifm_st1_idx24)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(4), .NUMEL_LOG(2)
) vs_mt_st1_idx24 (
    .i_vec(i_mt_st1_idx24), .stride(i_dist_st1_idx24), .o_vec(o_mt_st1_idx24)
);

assign lifm_st1_wo[WORD_WIDTH*100-1:WORD_WIDTH*98] = o_lifm_st1_idx24[WORD_WIDTH*4-1:WORD_WIDTH*2];
assign lifm_st1_wo[WORD_WIDTH*98-1:WORD_WIDTH*96] = o_lifm_st1_idx24[WORD_WIDTH*2-1:0] | lifm_st1_wi[WORD_WIDTH*98-1:WORD_WIDTH*96];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*100-1:DIST_WIDTH*MAX_LIFM_RSIZ*98] = o_mt_st1_idx24[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*98-1:DIST_WIDTH*MAX_LIFM_RSIZ*96] = o_mt_st1_idx24[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:0] | mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*98-1:DIST_WIDTH*MAX_LIFM_RSIZ*96];


// Stage1 Index25
wire [WORD_WIDTH*2*2-1:0] i_lifm_st1_idx25;
wire [WORD_WIDTH*2*2-1:0] o_lifm_st1_idx25;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] i_mt_st1_idx25;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] o_mt_st1_idx25;
wire [2-1:0] i_dist_st1_idx25;

assign i_lifm_st1_idx25 = { lifm_st1_wi[WORD_WIDTH*104-1:WORD_WIDTH*102], { WORD_WIDTH*2{1'b0} } };
assign i_mt_st1_idx25   = { mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*104-1:DIST_WIDTH*MAX_LIFM_RSIZ*102], { DIST_WIDTH*MAX_LIFM_RSIZ*2{1'b0} } };
assign i_dist_st1_idx25 = psum[PSUM_WIDTH*102-1:PSUM_WIDTH*101] - psum[PSUM_WIDTH*100-1:PSUM_WIDTH*99];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(4), .NUMEL_LOG(2)
) vs_lifm_st1_idx25 (
    .i_vec(i_lifm_st1_idx25), .stride(i_dist_st1_idx25), .o_vec(o_lifm_st1_idx25)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(4), .NUMEL_LOG(2)
) vs_mt_st1_idx25 (
    .i_vec(i_mt_st1_idx25), .stride(i_dist_st1_idx25), .o_vec(o_mt_st1_idx25)
);

assign lifm_st1_wo[WORD_WIDTH*104-1:WORD_WIDTH*102] = o_lifm_st1_idx25[WORD_WIDTH*4-1:WORD_WIDTH*2];
assign lifm_st1_wo[WORD_WIDTH*102-1:WORD_WIDTH*100] = o_lifm_st1_idx25[WORD_WIDTH*2-1:0] | lifm_st1_wi[WORD_WIDTH*102-1:WORD_WIDTH*100];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*104-1:DIST_WIDTH*MAX_LIFM_RSIZ*102] = o_mt_st1_idx25[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*102-1:DIST_WIDTH*MAX_LIFM_RSIZ*100] = o_mt_st1_idx25[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:0] | mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*102-1:DIST_WIDTH*MAX_LIFM_RSIZ*100];


// Stage1 Index26
wire [WORD_WIDTH*2*2-1:0] i_lifm_st1_idx26;
wire [WORD_WIDTH*2*2-1:0] o_lifm_st1_idx26;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] i_mt_st1_idx26;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] o_mt_st1_idx26;
wire [2-1:0] i_dist_st1_idx26;

assign i_lifm_st1_idx26 = { lifm_st1_wi[WORD_WIDTH*108-1:WORD_WIDTH*106], { WORD_WIDTH*2{1'b0} } };
assign i_mt_st1_idx26   = { mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*108-1:DIST_WIDTH*MAX_LIFM_RSIZ*106], { DIST_WIDTH*MAX_LIFM_RSIZ*2{1'b0} } };
assign i_dist_st1_idx26 = psum[PSUM_WIDTH*106-1:PSUM_WIDTH*105] - psum[PSUM_WIDTH*104-1:PSUM_WIDTH*103];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(4), .NUMEL_LOG(2)
) vs_lifm_st1_idx26 (
    .i_vec(i_lifm_st1_idx26), .stride(i_dist_st1_idx26), .o_vec(o_lifm_st1_idx26)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(4), .NUMEL_LOG(2)
) vs_mt_st1_idx26 (
    .i_vec(i_mt_st1_idx26), .stride(i_dist_st1_idx26), .o_vec(o_mt_st1_idx26)
);

assign lifm_st1_wo[WORD_WIDTH*108-1:WORD_WIDTH*106] = o_lifm_st1_idx26[WORD_WIDTH*4-1:WORD_WIDTH*2];
assign lifm_st1_wo[WORD_WIDTH*106-1:WORD_WIDTH*104] = o_lifm_st1_idx26[WORD_WIDTH*2-1:0] | lifm_st1_wi[WORD_WIDTH*106-1:WORD_WIDTH*104];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*108-1:DIST_WIDTH*MAX_LIFM_RSIZ*106] = o_mt_st1_idx26[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*106-1:DIST_WIDTH*MAX_LIFM_RSIZ*104] = o_mt_st1_idx26[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:0] | mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*106-1:DIST_WIDTH*MAX_LIFM_RSIZ*104];


// Stage1 Index27
wire [WORD_WIDTH*2*2-1:0] i_lifm_st1_idx27;
wire [WORD_WIDTH*2*2-1:0] o_lifm_st1_idx27;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] i_mt_st1_idx27;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] o_mt_st1_idx27;
wire [2-1:0] i_dist_st1_idx27;

assign i_lifm_st1_idx27 = { lifm_st1_wi[WORD_WIDTH*112-1:WORD_WIDTH*110], { WORD_WIDTH*2{1'b0} } };
assign i_mt_st1_idx27   = { mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*112-1:DIST_WIDTH*MAX_LIFM_RSIZ*110], { DIST_WIDTH*MAX_LIFM_RSIZ*2{1'b0} } };
assign i_dist_st1_idx27 = psum[PSUM_WIDTH*110-1:PSUM_WIDTH*109] - psum[PSUM_WIDTH*108-1:PSUM_WIDTH*107];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(4), .NUMEL_LOG(2)
) vs_lifm_st1_idx27 (
    .i_vec(i_lifm_st1_idx27), .stride(i_dist_st1_idx27), .o_vec(o_lifm_st1_idx27)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(4), .NUMEL_LOG(2)
) vs_mt_st1_idx27 (
    .i_vec(i_mt_st1_idx27), .stride(i_dist_st1_idx27), .o_vec(o_mt_st1_idx27)
);

assign lifm_st1_wo[WORD_WIDTH*112-1:WORD_WIDTH*110] = o_lifm_st1_idx27[WORD_WIDTH*4-1:WORD_WIDTH*2];
assign lifm_st1_wo[WORD_WIDTH*110-1:WORD_WIDTH*108] = o_lifm_st1_idx27[WORD_WIDTH*2-1:0] | lifm_st1_wi[WORD_WIDTH*110-1:WORD_WIDTH*108];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*112-1:DIST_WIDTH*MAX_LIFM_RSIZ*110] = o_mt_st1_idx27[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*110-1:DIST_WIDTH*MAX_LIFM_RSIZ*108] = o_mt_st1_idx27[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:0] | mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*110-1:DIST_WIDTH*MAX_LIFM_RSIZ*108];


// Stage1 Index28
wire [WORD_WIDTH*2*2-1:0] i_lifm_st1_idx28;
wire [WORD_WIDTH*2*2-1:0] o_lifm_st1_idx28;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] i_mt_st1_idx28;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] o_mt_st1_idx28;
wire [2-1:0] i_dist_st1_idx28;

assign i_lifm_st1_idx28 = { lifm_st1_wi[WORD_WIDTH*116-1:WORD_WIDTH*114], { WORD_WIDTH*2{1'b0} } };
assign i_mt_st1_idx28   = { mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*116-1:DIST_WIDTH*MAX_LIFM_RSIZ*114], { DIST_WIDTH*MAX_LIFM_RSIZ*2{1'b0} } };
assign i_dist_st1_idx28 = psum[PSUM_WIDTH*114-1:PSUM_WIDTH*113] - psum[PSUM_WIDTH*112-1:PSUM_WIDTH*111];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(4), .NUMEL_LOG(2)
) vs_lifm_st1_idx28 (
    .i_vec(i_lifm_st1_idx28), .stride(i_dist_st1_idx28), .o_vec(o_lifm_st1_idx28)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(4), .NUMEL_LOG(2)
) vs_mt_st1_idx28 (
    .i_vec(i_mt_st1_idx28), .stride(i_dist_st1_idx28), .o_vec(o_mt_st1_idx28)
);

assign lifm_st1_wo[WORD_WIDTH*116-1:WORD_WIDTH*114] = o_lifm_st1_idx28[WORD_WIDTH*4-1:WORD_WIDTH*2];
assign lifm_st1_wo[WORD_WIDTH*114-1:WORD_WIDTH*112] = o_lifm_st1_idx28[WORD_WIDTH*2-1:0] | lifm_st1_wi[WORD_WIDTH*114-1:WORD_WIDTH*112];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*116-1:DIST_WIDTH*MAX_LIFM_RSIZ*114] = o_mt_st1_idx28[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*114-1:DIST_WIDTH*MAX_LIFM_RSIZ*112] = o_mt_st1_idx28[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:0] | mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*114-1:DIST_WIDTH*MAX_LIFM_RSIZ*112];


// Stage1 Index29
wire [WORD_WIDTH*2*2-1:0] i_lifm_st1_idx29;
wire [WORD_WIDTH*2*2-1:0] o_lifm_st1_idx29;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] i_mt_st1_idx29;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] o_mt_st1_idx29;
wire [2-1:0] i_dist_st1_idx29;

assign i_lifm_st1_idx29 = { lifm_st1_wi[WORD_WIDTH*120-1:WORD_WIDTH*118], { WORD_WIDTH*2{1'b0} } };
assign i_mt_st1_idx29   = { mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*120-1:DIST_WIDTH*MAX_LIFM_RSIZ*118], { DIST_WIDTH*MAX_LIFM_RSIZ*2{1'b0} } };
assign i_dist_st1_idx29 = psum[PSUM_WIDTH*118-1:PSUM_WIDTH*117] - psum[PSUM_WIDTH*116-1:PSUM_WIDTH*115];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(4), .NUMEL_LOG(2)
) vs_lifm_st1_idx29 (
    .i_vec(i_lifm_st1_idx29), .stride(i_dist_st1_idx29), .o_vec(o_lifm_st1_idx29)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(4), .NUMEL_LOG(2)
) vs_mt_st1_idx29 (
    .i_vec(i_mt_st1_idx29), .stride(i_dist_st1_idx29), .o_vec(o_mt_st1_idx29)
);

assign lifm_st1_wo[WORD_WIDTH*120-1:WORD_WIDTH*118] = o_lifm_st1_idx29[WORD_WIDTH*4-1:WORD_WIDTH*2];
assign lifm_st1_wo[WORD_WIDTH*118-1:WORD_WIDTH*116] = o_lifm_st1_idx29[WORD_WIDTH*2-1:0] | lifm_st1_wi[WORD_WIDTH*118-1:WORD_WIDTH*116];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*120-1:DIST_WIDTH*MAX_LIFM_RSIZ*118] = o_mt_st1_idx29[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*118-1:DIST_WIDTH*MAX_LIFM_RSIZ*116] = o_mt_st1_idx29[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:0] | mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*118-1:DIST_WIDTH*MAX_LIFM_RSIZ*116];


// Stage1 Index30
wire [WORD_WIDTH*2*2-1:0] i_lifm_st1_idx30;
wire [WORD_WIDTH*2*2-1:0] o_lifm_st1_idx30;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] i_mt_st1_idx30;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] o_mt_st1_idx30;
wire [2-1:0] i_dist_st1_idx30;

assign i_lifm_st1_idx30 = { lifm_st1_wi[WORD_WIDTH*124-1:WORD_WIDTH*122], { WORD_WIDTH*2{1'b0} } };
assign i_mt_st1_idx30   = { mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*124-1:DIST_WIDTH*MAX_LIFM_RSIZ*122], { DIST_WIDTH*MAX_LIFM_RSIZ*2{1'b0} } };
assign i_dist_st1_idx30 = psum[PSUM_WIDTH*122-1:PSUM_WIDTH*121] - psum[PSUM_WIDTH*120-1:PSUM_WIDTH*119];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(4), .NUMEL_LOG(2)
) vs_lifm_st1_idx30 (
    .i_vec(i_lifm_st1_idx30), .stride(i_dist_st1_idx30), .o_vec(o_lifm_st1_idx30)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(4), .NUMEL_LOG(2)
) vs_mt_st1_idx30 (
    .i_vec(i_mt_st1_idx30), .stride(i_dist_st1_idx30), .o_vec(o_mt_st1_idx30)
);

assign lifm_st1_wo[WORD_WIDTH*124-1:WORD_WIDTH*122] = o_lifm_st1_idx30[WORD_WIDTH*4-1:WORD_WIDTH*2];
assign lifm_st1_wo[WORD_WIDTH*122-1:WORD_WIDTH*120] = o_lifm_st1_idx30[WORD_WIDTH*2-1:0] | lifm_st1_wi[WORD_WIDTH*122-1:WORD_WIDTH*120];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*124-1:DIST_WIDTH*MAX_LIFM_RSIZ*122] = o_mt_st1_idx30[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*122-1:DIST_WIDTH*MAX_LIFM_RSIZ*120] = o_mt_st1_idx30[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:0] | mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*122-1:DIST_WIDTH*MAX_LIFM_RSIZ*120];


// Stage1 Index31
wire [WORD_WIDTH*2*2-1:0] i_lifm_st1_idx31;
wire [WORD_WIDTH*2*2-1:0] o_lifm_st1_idx31;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] i_mt_st1_idx31;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*2*2-1:0] o_mt_st1_idx31;
wire [2-1:0] i_dist_st1_idx31;

assign i_lifm_st1_idx31 = { lifm_st1_wi[WORD_WIDTH*128-1:WORD_WIDTH*126], { WORD_WIDTH*2{1'b0} } };
assign i_mt_st1_idx31   = { mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*128-1:DIST_WIDTH*MAX_LIFM_RSIZ*126], { DIST_WIDTH*MAX_LIFM_RSIZ*2{1'b0} } };
assign i_dist_st1_idx31 = psum[PSUM_WIDTH*126-1:PSUM_WIDTH*125] - psum[PSUM_WIDTH*124-1:PSUM_WIDTH*123];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(4), .NUMEL_LOG(2)
) vs_lifm_st1_idx31 (
    .i_vec(i_lifm_st1_idx31), .stride(i_dist_st1_idx31), .o_vec(o_lifm_st1_idx31)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(4), .NUMEL_LOG(2)
) vs_mt_st1_idx31 (
    .i_vec(i_mt_st1_idx31), .stride(i_dist_st1_idx31), .o_vec(o_mt_st1_idx31)
);

assign lifm_st1_wo[WORD_WIDTH*128-1:WORD_WIDTH*126] = o_lifm_st1_idx31[WORD_WIDTH*4-1:WORD_WIDTH*2];
assign lifm_st1_wo[WORD_WIDTH*126-1:WORD_WIDTH*124] = o_lifm_st1_idx31[WORD_WIDTH*2-1:0] | lifm_st1_wi[WORD_WIDTH*126-1:WORD_WIDTH*124];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*128-1:DIST_WIDTH*MAX_LIFM_RSIZ*126] = o_mt_st1_idx31[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*2];
assign mt_st1_wo[DIST_WIDTH*MAX_LIFM_RSIZ*126-1:DIST_WIDTH*MAX_LIFM_RSIZ*124] = o_mt_st1_idx31[DIST_WIDTH*MAX_LIFM_RSIZ*2-1:0] | mt_st1_wi[DIST_WIDTH*MAX_LIFM_RSIZ*126-1:DIST_WIDTH*MAX_LIFM_RSIZ*124];



// Stage2
wire [128*WORD_WIDTH-1:0] lifm_st2_wi;  // stage input for LIFM
wire [128*WORD_WIDTH-1:0] lifm_st2_wo;  // stage output of LIFM
wire [128*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_st2_wi;  // stage input for MT
wire [128*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_st2_wo;  // stage output of MT

assign lifm_st2_wi = lifm_st1_wo;
assign mt_st2_wi = mt_st1_wo;

// Stage2 Index0
wire [WORD_WIDTH*4*2-1:0] i_lifm_st2_idx0;
wire [WORD_WIDTH*4*2-1:0] o_lifm_st2_idx0;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*4*2-1:0] i_mt_st2_idx0;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*4*2-1:0] o_mt_st2_idx0;
wire [3-1:0] i_dist_st2_idx0;

assign i_lifm_st2_idx0 = { lifm_st2_wi[WORD_WIDTH*8-1:WORD_WIDTH*4], { WORD_WIDTH*4{1'b0} } };
assign i_mt_st2_idx0   = { mt_st2_wi[DIST_WIDTH*MAX_LIFM_RSIZ*8-1:DIST_WIDTH*MAX_LIFM_RSIZ*4], { DIST_WIDTH*MAX_LIFM_RSIZ*4{1'b0} } };
assign i_dist_st2_idx0 = psum[PSUM_WIDTH*4-1:PSUM_WIDTH*3];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(8), .NUMEL_LOG(3)
) vs_lifm_st2_idx0 (
    .i_vec(i_lifm_st2_idx0), .stride(i_dist_st2_idx0), .o_vec(o_lifm_st2_idx0)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(8), .NUMEL_LOG(3)
) vs_mt_st2_idx0 (
    .i_vec(i_mt_st2_idx0), .stride(i_dist_st2_idx0), .o_vec(o_mt_st2_idx0)
);

assign lifm_st2_wo[WORD_WIDTH*8-1:WORD_WIDTH*4] = o_lifm_st2_idx0[WORD_WIDTH*8-1:WORD_WIDTH*4];
assign lifm_st2_wo[WORD_WIDTH*4-1:WORD_WIDTH*0] = o_lifm_st2_idx0[WORD_WIDTH*4-1:0] | lifm_st2_wi[WORD_WIDTH*4-1:WORD_WIDTH*0];
assign mt_st2_wo[DIST_WIDTH*MAX_LIFM_RSIZ*8-1:DIST_WIDTH*MAX_LIFM_RSIZ*4] = o_mt_st2_idx0[DIST_WIDTH*MAX_LIFM_RSIZ*8-1:DIST_WIDTH*MAX_LIFM_RSIZ*4];
assign mt_st2_wo[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*0] = o_mt_st2_idx0[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:0] | mt_st2_wi[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:DIST_WIDTH*MAX_LIFM_RSIZ*0];


// Stage2 Index1
wire [WORD_WIDTH*4*2-1:0] i_lifm_st2_idx1;
wire [WORD_WIDTH*4*2-1:0] o_lifm_st2_idx1;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*4*2-1:0] i_mt_st2_idx1;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*4*2-1:0] o_mt_st2_idx1;
wire [3-1:0] i_dist_st2_idx1;

assign i_lifm_st2_idx1 = { lifm_st2_wi[WORD_WIDTH*16-1:WORD_WIDTH*12], { WORD_WIDTH*4{1'b0} } };
assign i_mt_st2_idx1   = { mt_st2_wi[DIST_WIDTH*MAX_LIFM_RSIZ*16-1:DIST_WIDTH*MAX_LIFM_RSIZ*12], { DIST_WIDTH*MAX_LIFM_RSIZ*4{1'b0} } };
assign i_dist_st2_idx1 = psum[PSUM_WIDTH*12-1:PSUM_WIDTH*11] - psum[PSUM_WIDTH*8-1:PSUM_WIDTH*7];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(8), .NUMEL_LOG(3)
) vs_lifm_st2_idx1 (
    .i_vec(i_lifm_st2_idx1), .stride(i_dist_st2_idx1), .o_vec(o_lifm_st2_idx1)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(8), .NUMEL_LOG(3)
) vs_mt_st2_idx1 (
    .i_vec(i_mt_st2_idx1), .stride(i_dist_st2_idx1), .o_vec(o_mt_st2_idx1)
);

assign lifm_st2_wo[WORD_WIDTH*16-1:WORD_WIDTH*12] = o_lifm_st2_idx1[WORD_WIDTH*8-1:WORD_WIDTH*4];
assign lifm_st2_wo[WORD_WIDTH*12-1:WORD_WIDTH*8] = o_lifm_st2_idx1[WORD_WIDTH*4-1:0] | lifm_st2_wi[WORD_WIDTH*12-1:WORD_WIDTH*8];
assign mt_st2_wo[DIST_WIDTH*MAX_LIFM_RSIZ*16-1:DIST_WIDTH*MAX_LIFM_RSIZ*12] = o_mt_st2_idx1[DIST_WIDTH*MAX_LIFM_RSIZ*8-1:DIST_WIDTH*MAX_LIFM_RSIZ*4];
assign mt_st2_wo[DIST_WIDTH*MAX_LIFM_RSIZ*12-1:DIST_WIDTH*MAX_LIFM_RSIZ*8] = o_mt_st2_idx1[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:0] | mt_st2_wi[DIST_WIDTH*MAX_LIFM_RSIZ*12-1:DIST_WIDTH*MAX_LIFM_RSIZ*8];


// Stage2 Index2
wire [WORD_WIDTH*4*2-1:0] i_lifm_st2_idx2;
wire [WORD_WIDTH*4*2-1:0] o_lifm_st2_idx2;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*4*2-1:0] i_mt_st2_idx2;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*4*2-1:0] o_mt_st2_idx2;
wire [3-1:0] i_dist_st2_idx2;

assign i_lifm_st2_idx2 = { lifm_st2_wi[WORD_WIDTH*24-1:WORD_WIDTH*20], { WORD_WIDTH*4{1'b0} } };
assign i_mt_st2_idx2   = { mt_st2_wi[DIST_WIDTH*MAX_LIFM_RSIZ*24-1:DIST_WIDTH*MAX_LIFM_RSIZ*20], { DIST_WIDTH*MAX_LIFM_RSIZ*4{1'b0} } };
assign i_dist_st2_idx2 = psum[PSUM_WIDTH*20-1:PSUM_WIDTH*19] - psum[PSUM_WIDTH*16-1:PSUM_WIDTH*15];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(8), .NUMEL_LOG(3)
) vs_lifm_st2_idx2 (
    .i_vec(i_lifm_st2_idx2), .stride(i_dist_st2_idx2), .o_vec(o_lifm_st2_idx2)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(8), .NUMEL_LOG(3)
) vs_mt_st2_idx2 (
    .i_vec(i_mt_st2_idx2), .stride(i_dist_st2_idx2), .o_vec(o_mt_st2_idx2)
);

assign lifm_st2_wo[WORD_WIDTH*24-1:WORD_WIDTH*20] = o_lifm_st2_idx2[WORD_WIDTH*8-1:WORD_WIDTH*4];
assign lifm_st2_wo[WORD_WIDTH*20-1:WORD_WIDTH*16] = o_lifm_st2_idx2[WORD_WIDTH*4-1:0] | lifm_st2_wi[WORD_WIDTH*20-1:WORD_WIDTH*16];
assign mt_st2_wo[DIST_WIDTH*MAX_LIFM_RSIZ*24-1:DIST_WIDTH*MAX_LIFM_RSIZ*20] = o_mt_st2_idx2[DIST_WIDTH*MAX_LIFM_RSIZ*8-1:DIST_WIDTH*MAX_LIFM_RSIZ*4];
assign mt_st2_wo[DIST_WIDTH*MAX_LIFM_RSIZ*20-1:DIST_WIDTH*MAX_LIFM_RSIZ*16] = o_mt_st2_idx2[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:0] | mt_st2_wi[DIST_WIDTH*MAX_LIFM_RSIZ*20-1:DIST_WIDTH*MAX_LIFM_RSIZ*16];


// Stage2 Index3
wire [WORD_WIDTH*4*2-1:0] i_lifm_st2_idx3;
wire [WORD_WIDTH*4*2-1:0] o_lifm_st2_idx3;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*4*2-1:0] i_mt_st2_idx3;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*4*2-1:0] o_mt_st2_idx3;
wire [3-1:0] i_dist_st2_idx3;

assign i_lifm_st2_idx3 = { lifm_st2_wi[WORD_WIDTH*32-1:WORD_WIDTH*28], { WORD_WIDTH*4{1'b0} } };
assign i_mt_st2_idx3   = { mt_st2_wi[DIST_WIDTH*MAX_LIFM_RSIZ*32-1:DIST_WIDTH*MAX_LIFM_RSIZ*28], { DIST_WIDTH*MAX_LIFM_RSIZ*4{1'b0} } };
assign i_dist_st2_idx3 = psum[PSUM_WIDTH*28-1:PSUM_WIDTH*27] - psum[PSUM_WIDTH*24-1:PSUM_WIDTH*23];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(8), .NUMEL_LOG(3)
) vs_lifm_st2_idx3 (
    .i_vec(i_lifm_st2_idx3), .stride(i_dist_st2_idx3), .o_vec(o_lifm_st2_idx3)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(8), .NUMEL_LOG(3)
) vs_mt_st2_idx3 (
    .i_vec(i_mt_st2_idx3), .stride(i_dist_st2_idx3), .o_vec(o_mt_st2_idx3)
);

assign lifm_st2_wo[WORD_WIDTH*32-1:WORD_WIDTH*28] = o_lifm_st2_idx3[WORD_WIDTH*8-1:WORD_WIDTH*4];
assign lifm_st2_wo[WORD_WIDTH*28-1:WORD_WIDTH*24] = o_lifm_st2_idx3[WORD_WIDTH*4-1:0] | lifm_st2_wi[WORD_WIDTH*28-1:WORD_WIDTH*24];
assign mt_st2_wo[DIST_WIDTH*MAX_LIFM_RSIZ*32-1:DIST_WIDTH*MAX_LIFM_RSIZ*28] = o_mt_st2_idx3[DIST_WIDTH*MAX_LIFM_RSIZ*8-1:DIST_WIDTH*MAX_LIFM_RSIZ*4];
assign mt_st2_wo[DIST_WIDTH*MAX_LIFM_RSIZ*28-1:DIST_WIDTH*MAX_LIFM_RSIZ*24] = o_mt_st2_idx3[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:0] | mt_st2_wi[DIST_WIDTH*MAX_LIFM_RSIZ*28-1:DIST_WIDTH*MAX_LIFM_RSIZ*24];


// Stage2 Index4
wire [WORD_WIDTH*4*2-1:0] i_lifm_st2_idx4;
wire [WORD_WIDTH*4*2-1:0] o_lifm_st2_idx4;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*4*2-1:0] i_mt_st2_idx4;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*4*2-1:0] o_mt_st2_idx4;
wire [3-1:0] i_dist_st2_idx4;

assign i_lifm_st2_idx4 = { lifm_st2_wi[WORD_WIDTH*40-1:WORD_WIDTH*36], { WORD_WIDTH*4{1'b0} } };
assign i_mt_st2_idx4   = { mt_st2_wi[DIST_WIDTH*MAX_LIFM_RSIZ*40-1:DIST_WIDTH*MAX_LIFM_RSIZ*36], { DIST_WIDTH*MAX_LIFM_RSIZ*4{1'b0} } };
assign i_dist_st2_idx4 = psum[PSUM_WIDTH*36-1:PSUM_WIDTH*35] - psum[PSUM_WIDTH*32-1:PSUM_WIDTH*31];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(8), .NUMEL_LOG(3)
) vs_lifm_st2_idx4 (
    .i_vec(i_lifm_st2_idx4), .stride(i_dist_st2_idx4), .o_vec(o_lifm_st2_idx4)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(8), .NUMEL_LOG(3)
) vs_mt_st2_idx4 (
    .i_vec(i_mt_st2_idx4), .stride(i_dist_st2_idx4), .o_vec(o_mt_st2_idx4)
);

assign lifm_st2_wo[WORD_WIDTH*40-1:WORD_WIDTH*36] = o_lifm_st2_idx4[WORD_WIDTH*8-1:WORD_WIDTH*4];
assign lifm_st2_wo[WORD_WIDTH*36-1:WORD_WIDTH*32] = o_lifm_st2_idx4[WORD_WIDTH*4-1:0] | lifm_st2_wi[WORD_WIDTH*36-1:WORD_WIDTH*32];
assign mt_st2_wo[DIST_WIDTH*MAX_LIFM_RSIZ*40-1:DIST_WIDTH*MAX_LIFM_RSIZ*36] = o_mt_st2_idx4[DIST_WIDTH*MAX_LIFM_RSIZ*8-1:DIST_WIDTH*MAX_LIFM_RSIZ*4];
assign mt_st2_wo[DIST_WIDTH*MAX_LIFM_RSIZ*36-1:DIST_WIDTH*MAX_LIFM_RSIZ*32] = o_mt_st2_idx4[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:0] | mt_st2_wi[DIST_WIDTH*MAX_LIFM_RSIZ*36-1:DIST_WIDTH*MAX_LIFM_RSIZ*32];


// Stage2 Index5
wire [WORD_WIDTH*4*2-1:0] i_lifm_st2_idx5;
wire [WORD_WIDTH*4*2-1:0] o_lifm_st2_idx5;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*4*2-1:0] i_mt_st2_idx5;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*4*2-1:0] o_mt_st2_idx5;
wire [3-1:0] i_dist_st2_idx5;

assign i_lifm_st2_idx5 = { lifm_st2_wi[WORD_WIDTH*48-1:WORD_WIDTH*44], { WORD_WIDTH*4{1'b0} } };
assign i_mt_st2_idx5   = { mt_st2_wi[DIST_WIDTH*MAX_LIFM_RSIZ*48-1:DIST_WIDTH*MAX_LIFM_RSIZ*44], { DIST_WIDTH*MAX_LIFM_RSIZ*4{1'b0} } };
assign i_dist_st2_idx5 = psum[PSUM_WIDTH*44-1:PSUM_WIDTH*43] - psum[PSUM_WIDTH*40-1:PSUM_WIDTH*39];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(8), .NUMEL_LOG(3)
) vs_lifm_st2_idx5 (
    .i_vec(i_lifm_st2_idx5), .stride(i_dist_st2_idx5), .o_vec(o_lifm_st2_idx5)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(8), .NUMEL_LOG(3)
) vs_mt_st2_idx5 (
    .i_vec(i_mt_st2_idx5), .stride(i_dist_st2_idx5), .o_vec(o_mt_st2_idx5)
);

assign lifm_st2_wo[WORD_WIDTH*48-1:WORD_WIDTH*44] = o_lifm_st2_idx5[WORD_WIDTH*8-1:WORD_WIDTH*4];
assign lifm_st2_wo[WORD_WIDTH*44-1:WORD_WIDTH*40] = o_lifm_st2_idx5[WORD_WIDTH*4-1:0] | lifm_st2_wi[WORD_WIDTH*44-1:WORD_WIDTH*40];
assign mt_st2_wo[DIST_WIDTH*MAX_LIFM_RSIZ*48-1:DIST_WIDTH*MAX_LIFM_RSIZ*44] = o_mt_st2_idx5[DIST_WIDTH*MAX_LIFM_RSIZ*8-1:DIST_WIDTH*MAX_LIFM_RSIZ*4];
assign mt_st2_wo[DIST_WIDTH*MAX_LIFM_RSIZ*44-1:DIST_WIDTH*MAX_LIFM_RSIZ*40] = o_mt_st2_idx5[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:0] | mt_st2_wi[DIST_WIDTH*MAX_LIFM_RSIZ*44-1:DIST_WIDTH*MAX_LIFM_RSIZ*40];


// Stage2 Index6
wire [WORD_WIDTH*4*2-1:0] i_lifm_st2_idx6;
wire [WORD_WIDTH*4*2-1:0] o_lifm_st2_idx6;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*4*2-1:0] i_mt_st2_idx6;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*4*2-1:0] o_mt_st2_idx6;
wire [3-1:0] i_dist_st2_idx6;

assign i_lifm_st2_idx6 = { lifm_st2_wi[WORD_WIDTH*56-1:WORD_WIDTH*52], { WORD_WIDTH*4{1'b0} } };
assign i_mt_st2_idx6   = { mt_st2_wi[DIST_WIDTH*MAX_LIFM_RSIZ*56-1:DIST_WIDTH*MAX_LIFM_RSIZ*52], { DIST_WIDTH*MAX_LIFM_RSIZ*4{1'b0} } };
assign i_dist_st2_idx6 = psum[PSUM_WIDTH*52-1:PSUM_WIDTH*51] - psum[PSUM_WIDTH*48-1:PSUM_WIDTH*47];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(8), .NUMEL_LOG(3)
) vs_lifm_st2_idx6 (
    .i_vec(i_lifm_st2_idx6), .stride(i_dist_st2_idx6), .o_vec(o_lifm_st2_idx6)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(8), .NUMEL_LOG(3)
) vs_mt_st2_idx6 (
    .i_vec(i_mt_st2_idx6), .stride(i_dist_st2_idx6), .o_vec(o_mt_st2_idx6)
);

assign lifm_st2_wo[WORD_WIDTH*56-1:WORD_WIDTH*52] = o_lifm_st2_idx6[WORD_WIDTH*8-1:WORD_WIDTH*4];
assign lifm_st2_wo[WORD_WIDTH*52-1:WORD_WIDTH*48] = o_lifm_st2_idx6[WORD_WIDTH*4-1:0] | lifm_st2_wi[WORD_WIDTH*52-1:WORD_WIDTH*48];
assign mt_st2_wo[DIST_WIDTH*MAX_LIFM_RSIZ*56-1:DIST_WIDTH*MAX_LIFM_RSIZ*52] = o_mt_st2_idx6[DIST_WIDTH*MAX_LIFM_RSIZ*8-1:DIST_WIDTH*MAX_LIFM_RSIZ*4];
assign mt_st2_wo[DIST_WIDTH*MAX_LIFM_RSIZ*52-1:DIST_WIDTH*MAX_LIFM_RSIZ*48] = o_mt_st2_idx6[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:0] | mt_st2_wi[DIST_WIDTH*MAX_LIFM_RSIZ*52-1:DIST_WIDTH*MAX_LIFM_RSIZ*48];


// Stage2 Index7
wire [WORD_WIDTH*4*2-1:0] i_lifm_st2_idx7;
wire [WORD_WIDTH*4*2-1:0] o_lifm_st2_idx7;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*4*2-1:0] i_mt_st2_idx7;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*4*2-1:0] o_mt_st2_idx7;
wire [3-1:0] i_dist_st2_idx7;

assign i_lifm_st2_idx7 = { lifm_st2_wi[WORD_WIDTH*64-1:WORD_WIDTH*60], { WORD_WIDTH*4{1'b0} } };
assign i_mt_st2_idx7   = { mt_st2_wi[DIST_WIDTH*MAX_LIFM_RSIZ*64-1:DIST_WIDTH*MAX_LIFM_RSIZ*60], { DIST_WIDTH*MAX_LIFM_RSIZ*4{1'b0} } };
assign i_dist_st2_idx7 = psum[PSUM_WIDTH*60-1:PSUM_WIDTH*59] - psum[PSUM_WIDTH*56-1:PSUM_WIDTH*55];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(8), .NUMEL_LOG(3)
) vs_lifm_st2_idx7 (
    .i_vec(i_lifm_st2_idx7), .stride(i_dist_st2_idx7), .o_vec(o_lifm_st2_idx7)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(8), .NUMEL_LOG(3)
) vs_mt_st2_idx7 (
    .i_vec(i_mt_st2_idx7), .stride(i_dist_st2_idx7), .o_vec(o_mt_st2_idx7)
);

assign lifm_st2_wo[WORD_WIDTH*64-1:WORD_WIDTH*60] = o_lifm_st2_idx7[WORD_WIDTH*8-1:WORD_WIDTH*4];
assign lifm_st2_wo[WORD_WIDTH*60-1:WORD_WIDTH*56] = o_lifm_st2_idx7[WORD_WIDTH*4-1:0] | lifm_st2_wi[WORD_WIDTH*60-1:WORD_WIDTH*56];
assign mt_st2_wo[DIST_WIDTH*MAX_LIFM_RSIZ*64-1:DIST_WIDTH*MAX_LIFM_RSIZ*60] = o_mt_st2_idx7[DIST_WIDTH*MAX_LIFM_RSIZ*8-1:DIST_WIDTH*MAX_LIFM_RSIZ*4];
assign mt_st2_wo[DIST_WIDTH*MAX_LIFM_RSIZ*60-1:DIST_WIDTH*MAX_LIFM_RSIZ*56] = o_mt_st2_idx7[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:0] | mt_st2_wi[DIST_WIDTH*MAX_LIFM_RSIZ*60-1:DIST_WIDTH*MAX_LIFM_RSIZ*56];


// Stage2 Index8
wire [WORD_WIDTH*4*2-1:0] i_lifm_st2_idx8;
wire [WORD_WIDTH*4*2-1:0] o_lifm_st2_idx8;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*4*2-1:0] i_mt_st2_idx8;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*4*2-1:0] o_mt_st2_idx8;
wire [3-1:0] i_dist_st2_idx8;

assign i_lifm_st2_idx8 = { lifm_st2_wi[WORD_WIDTH*72-1:WORD_WIDTH*68], { WORD_WIDTH*4{1'b0} } };
assign i_mt_st2_idx8   = { mt_st2_wi[DIST_WIDTH*MAX_LIFM_RSIZ*72-1:DIST_WIDTH*MAX_LIFM_RSIZ*68], { DIST_WIDTH*MAX_LIFM_RSIZ*4{1'b0} } };
assign i_dist_st2_idx8 = psum[PSUM_WIDTH*68-1:PSUM_WIDTH*67] - psum[PSUM_WIDTH*64-1:PSUM_WIDTH*63];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(8), .NUMEL_LOG(3)
) vs_lifm_st2_idx8 (
    .i_vec(i_lifm_st2_idx8), .stride(i_dist_st2_idx8), .o_vec(o_lifm_st2_idx8)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(8), .NUMEL_LOG(3)
) vs_mt_st2_idx8 (
    .i_vec(i_mt_st2_idx8), .stride(i_dist_st2_idx8), .o_vec(o_mt_st2_idx8)
);

assign lifm_st2_wo[WORD_WIDTH*72-1:WORD_WIDTH*68] = o_lifm_st2_idx8[WORD_WIDTH*8-1:WORD_WIDTH*4];
assign lifm_st2_wo[WORD_WIDTH*68-1:WORD_WIDTH*64] = o_lifm_st2_idx8[WORD_WIDTH*4-1:0] | lifm_st2_wi[WORD_WIDTH*68-1:WORD_WIDTH*64];
assign mt_st2_wo[DIST_WIDTH*MAX_LIFM_RSIZ*72-1:DIST_WIDTH*MAX_LIFM_RSIZ*68] = o_mt_st2_idx8[DIST_WIDTH*MAX_LIFM_RSIZ*8-1:DIST_WIDTH*MAX_LIFM_RSIZ*4];
assign mt_st2_wo[DIST_WIDTH*MAX_LIFM_RSIZ*68-1:DIST_WIDTH*MAX_LIFM_RSIZ*64] = o_mt_st2_idx8[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:0] | mt_st2_wi[DIST_WIDTH*MAX_LIFM_RSIZ*68-1:DIST_WIDTH*MAX_LIFM_RSIZ*64];


// Stage2 Index9
wire [WORD_WIDTH*4*2-1:0] i_lifm_st2_idx9;
wire [WORD_WIDTH*4*2-1:0] o_lifm_st2_idx9;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*4*2-1:0] i_mt_st2_idx9;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*4*2-1:0] o_mt_st2_idx9;
wire [3-1:0] i_dist_st2_idx9;

assign i_lifm_st2_idx9 = { lifm_st2_wi[WORD_WIDTH*80-1:WORD_WIDTH*76], { WORD_WIDTH*4{1'b0} } };
assign i_mt_st2_idx9   = { mt_st2_wi[DIST_WIDTH*MAX_LIFM_RSIZ*80-1:DIST_WIDTH*MAX_LIFM_RSIZ*76], { DIST_WIDTH*MAX_LIFM_RSIZ*4{1'b0} } };
assign i_dist_st2_idx9 = psum[PSUM_WIDTH*76-1:PSUM_WIDTH*75] - psum[PSUM_WIDTH*72-1:PSUM_WIDTH*71];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(8), .NUMEL_LOG(3)
) vs_lifm_st2_idx9 (
    .i_vec(i_lifm_st2_idx9), .stride(i_dist_st2_idx9), .o_vec(o_lifm_st2_idx9)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(8), .NUMEL_LOG(3)
) vs_mt_st2_idx9 (
    .i_vec(i_mt_st2_idx9), .stride(i_dist_st2_idx9), .o_vec(o_mt_st2_idx9)
);

assign lifm_st2_wo[WORD_WIDTH*80-1:WORD_WIDTH*76] = o_lifm_st2_idx9[WORD_WIDTH*8-1:WORD_WIDTH*4];
assign lifm_st2_wo[WORD_WIDTH*76-1:WORD_WIDTH*72] = o_lifm_st2_idx9[WORD_WIDTH*4-1:0] | lifm_st2_wi[WORD_WIDTH*76-1:WORD_WIDTH*72];
assign mt_st2_wo[DIST_WIDTH*MAX_LIFM_RSIZ*80-1:DIST_WIDTH*MAX_LIFM_RSIZ*76] = o_mt_st2_idx9[DIST_WIDTH*MAX_LIFM_RSIZ*8-1:DIST_WIDTH*MAX_LIFM_RSIZ*4];
assign mt_st2_wo[DIST_WIDTH*MAX_LIFM_RSIZ*76-1:DIST_WIDTH*MAX_LIFM_RSIZ*72] = o_mt_st2_idx9[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:0] | mt_st2_wi[DIST_WIDTH*MAX_LIFM_RSIZ*76-1:DIST_WIDTH*MAX_LIFM_RSIZ*72];


// Stage2 Index10
wire [WORD_WIDTH*4*2-1:0] i_lifm_st2_idx10;
wire [WORD_WIDTH*4*2-1:0] o_lifm_st2_idx10;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*4*2-1:0] i_mt_st2_idx10;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*4*2-1:0] o_mt_st2_idx10;
wire [3-1:0] i_dist_st2_idx10;

assign i_lifm_st2_idx10 = { lifm_st2_wi[WORD_WIDTH*88-1:WORD_WIDTH*84], { WORD_WIDTH*4{1'b0} } };
assign i_mt_st2_idx10   = { mt_st2_wi[DIST_WIDTH*MAX_LIFM_RSIZ*88-1:DIST_WIDTH*MAX_LIFM_RSIZ*84], { DIST_WIDTH*MAX_LIFM_RSIZ*4{1'b0} } };
assign i_dist_st2_idx10 = psum[PSUM_WIDTH*84-1:PSUM_WIDTH*83] - psum[PSUM_WIDTH*80-1:PSUM_WIDTH*79];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(8), .NUMEL_LOG(3)
) vs_lifm_st2_idx10 (
    .i_vec(i_lifm_st2_idx10), .stride(i_dist_st2_idx10), .o_vec(o_lifm_st2_idx10)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(8), .NUMEL_LOG(3)
) vs_mt_st2_idx10 (
    .i_vec(i_mt_st2_idx10), .stride(i_dist_st2_idx10), .o_vec(o_mt_st2_idx10)
);

assign lifm_st2_wo[WORD_WIDTH*88-1:WORD_WIDTH*84] = o_lifm_st2_idx10[WORD_WIDTH*8-1:WORD_WIDTH*4];
assign lifm_st2_wo[WORD_WIDTH*84-1:WORD_WIDTH*80] = o_lifm_st2_idx10[WORD_WIDTH*4-1:0] | lifm_st2_wi[WORD_WIDTH*84-1:WORD_WIDTH*80];
assign mt_st2_wo[DIST_WIDTH*MAX_LIFM_RSIZ*88-1:DIST_WIDTH*MAX_LIFM_RSIZ*84] = o_mt_st2_idx10[DIST_WIDTH*MAX_LIFM_RSIZ*8-1:DIST_WIDTH*MAX_LIFM_RSIZ*4];
assign mt_st2_wo[DIST_WIDTH*MAX_LIFM_RSIZ*84-1:DIST_WIDTH*MAX_LIFM_RSIZ*80] = o_mt_st2_idx10[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:0] | mt_st2_wi[DIST_WIDTH*MAX_LIFM_RSIZ*84-1:DIST_WIDTH*MAX_LIFM_RSIZ*80];


// Stage2 Index11
wire [WORD_WIDTH*4*2-1:0] i_lifm_st2_idx11;
wire [WORD_WIDTH*4*2-1:0] o_lifm_st2_idx11;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*4*2-1:0] i_mt_st2_idx11;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*4*2-1:0] o_mt_st2_idx11;
wire [3-1:0] i_dist_st2_idx11;

assign i_lifm_st2_idx11 = { lifm_st2_wi[WORD_WIDTH*96-1:WORD_WIDTH*92], { WORD_WIDTH*4{1'b0} } };
assign i_mt_st2_idx11   = { mt_st2_wi[DIST_WIDTH*MAX_LIFM_RSIZ*96-1:DIST_WIDTH*MAX_LIFM_RSIZ*92], { DIST_WIDTH*MAX_LIFM_RSIZ*4{1'b0} } };
assign i_dist_st2_idx11 = psum[PSUM_WIDTH*92-1:PSUM_WIDTH*91] - psum[PSUM_WIDTH*88-1:PSUM_WIDTH*87];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(8), .NUMEL_LOG(3)
) vs_lifm_st2_idx11 (
    .i_vec(i_lifm_st2_idx11), .stride(i_dist_st2_idx11), .o_vec(o_lifm_st2_idx11)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(8), .NUMEL_LOG(3)
) vs_mt_st2_idx11 (
    .i_vec(i_mt_st2_idx11), .stride(i_dist_st2_idx11), .o_vec(o_mt_st2_idx11)
);

assign lifm_st2_wo[WORD_WIDTH*96-1:WORD_WIDTH*92] = o_lifm_st2_idx11[WORD_WIDTH*8-1:WORD_WIDTH*4];
assign lifm_st2_wo[WORD_WIDTH*92-1:WORD_WIDTH*88] = o_lifm_st2_idx11[WORD_WIDTH*4-1:0] | lifm_st2_wi[WORD_WIDTH*92-1:WORD_WIDTH*88];
assign mt_st2_wo[DIST_WIDTH*MAX_LIFM_RSIZ*96-1:DIST_WIDTH*MAX_LIFM_RSIZ*92] = o_mt_st2_idx11[DIST_WIDTH*MAX_LIFM_RSIZ*8-1:DIST_WIDTH*MAX_LIFM_RSIZ*4];
assign mt_st2_wo[DIST_WIDTH*MAX_LIFM_RSIZ*92-1:DIST_WIDTH*MAX_LIFM_RSIZ*88] = o_mt_st2_idx11[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:0] | mt_st2_wi[DIST_WIDTH*MAX_LIFM_RSIZ*92-1:DIST_WIDTH*MAX_LIFM_RSIZ*88];


// Stage2 Index12
wire [WORD_WIDTH*4*2-1:0] i_lifm_st2_idx12;
wire [WORD_WIDTH*4*2-1:0] o_lifm_st2_idx12;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*4*2-1:0] i_mt_st2_idx12;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*4*2-1:0] o_mt_st2_idx12;
wire [3-1:0] i_dist_st2_idx12;

assign i_lifm_st2_idx12 = { lifm_st2_wi[WORD_WIDTH*104-1:WORD_WIDTH*100], { WORD_WIDTH*4{1'b0} } };
assign i_mt_st2_idx12   = { mt_st2_wi[DIST_WIDTH*MAX_LIFM_RSIZ*104-1:DIST_WIDTH*MAX_LIFM_RSIZ*100], { DIST_WIDTH*MAX_LIFM_RSIZ*4{1'b0} } };
assign i_dist_st2_idx12 = psum[PSUM_WIDTH*100-1:PSUM_WIDTH*99] - psum[PSUM_WIDTH*96-1:PSUM_WIDTH*95];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(8), .NUMEL_LOG(3)
) vs_lifm_st2_idx12 (
    .i_vec(i_lifm_st2_idx12), .stride(i_dist_st2_idx12), .o_vec(o_lifm_st2_idx12)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(8), .NUMEL_LOG(3)
) vs_mt_st2_idx12 (
    .i_vec(i_mt_st2_idx12), .stride(i_dist_st2_idx12), .o_vec(o_mt_st2_idx12)
);

assign lifm_st2_wo[WORD_WIDTH*104-1:WORD_WIDTH*100] = o_lifm_st2_idx12[WORD_WIDTH*8-1:WORD_WIDTH*4];
assign lifm_st2_wo[WORD_WIDTH*100-1:WORD_WIDTH*96] = o_lifm_st2_idx12[WORD_WIDTH*4-1:0] | lifm_st2_wi[WORD_WIDTH*100-1:WORD_WIDTH*96];
assign mt_st2_wo[DIST_WIDTH*MAX_LIFM_RSIZ*104-1:DIST_WIDTH*MAX_LIFM_RSIZ*100] = o_mt_st2_idx12[DIST_WIDTH*MAX_LIFM_RSIZ*8-1:DIST_WIDTH*MAX_LIFM_RSIZ*4];
assign mt_st2_wo[DIST_WIDTH*MAX_LIFM_RSIZ*100-1:DIST_WIDTH*MAX_LIFM_RSIZ*96] = o_mt_st2_idx12[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:0] | mt_st2_wi[DIST_WIDTH*MAX_LIFM_RSIZ*100-1:DIST_WIDTH*MAX_LIFM_RSIZ*96];


// Stage2 Index13
wire [WORD_WIDTH*4*2-1:0] i_lifm_st2_idx13;
wire [WORD_WIDTH*4*2-1:0] o_lifm_st2_idx13;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*4*2-1:0] i_mt_st2_idx13;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*4*2-1:0] o_mt_st2_idx13;
wire [3-1:0] i_dist_st2_idx13;

assign i_lifm_st2_idx13 = { lifm_st2_wi[WORD_WIDTH*112-1:WORD_WIDTH*108], { WORD_WIDTH*4{1'b0} } };
assign i_mt_st2_idx13   = { mt_st2_wi[DIST_WIDTH*MAX_LIFM_RSIZ*112-1:DIST_WIDTH*MAX_LIFM_RSIZ*108], { DIST_WIDTH*MAX_LIFM_RSIZ*4{1'b0} } };
assign i_dist_st2_idx13 = psum[PSUM_WIDTH*108-1:PSUM_WIDTH*107] - psum[PSUM_WIDTH*104-1:PSUM_WIDTH*103];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(8), .NUMEL_LOG(3)
) vs_lifm_st2_idx13 (
    .i_vec(i_lifm_st2_idx13), .stride(i_dist_st2_idx13), .o_vec(o_lifm_st2_idx13)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(8), .NUMEL_LOG(3)
) vs_mt_st2_idx13 (
    .i_vec(i_mt_st2_idx13), .stride(i_dist_st2_idx13), .o_vec(o_mt_st2_idx13)
);

assign lifm_st2_wo[WORD_WIDTH*112-1:WORD_WIDTH*108] = o_lifm_st2_idx13[WORD_WIDTH*8-1:WORD_WIDTH*4];
assign lifm_st2_wo[WORD_WIDTH*108-1:WORD_WIDTH*104] = o_lifm_st2_idx13[WORD_WIDTH*4-1:0] | lifm_st2_wi[WORD_WIDTH*108-1:WORD_WIDTH*104];
assign mt_st2_wo[DIST_WIDTH*MAX_LIFM_RSIZ*112-1:DIST_WIDTH*MAX_LIFM_RSIZ*108] = o_mt_st2_idx13[DIST_WIDTH*MAX_LIFM_RSIZ*8-1:DIST_WIDTH*MAX_LIFM_RSIZ*4];
assign mt_st2_wo[DIST_WIDTH*MAX_LIFM_RSIZ*108-1:DIST_WIDTH*MAX_LIFM_RSIZ*104] = o_mt_st2_idx13[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:0] | mt_st2_wi[DIST_WIDTH*MAX_LIFM_RSIZ*108-1:DIST_WIDTH*MAX_LIFM_RSIZ*104];


// Stage2 Index14
wire [WORD_WIDTH*4*2-1:0] i_lifm_st2_idx14;
wire [WORD_WIDTH*4*2-1:0] o_lifm_st2_idx14;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*4*2-1:0] i_mt_st2_idx14;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*4*2-1:0] o_mt_st2_idx14;
wire [3-1:0] i_dist_st2_idx14;

assign i_lifm_st2_idx14 = { lifm_st2_wi[WORD_WIDTH*120-1:WORD_WIDTH*116], { WORD_WIDTH*4{1'b0} } };
assign i_mt_st2_idx14   = { mt_st2_wi[DIST_WIDTH*MAX_LIFM_RSIZ*120-1:DIST_WIDTH*MAX_LIFM_RSIZ*116], { DIST_WIDTH*MAX_LIFM_RSIZ*4{1'b0} } };
assign i_dist_st2_idx14 = psum[PSUM_WIDTH*116-1:PSUM_WIDTH*115] - psum[PSUM_WIDTH*112-1:PSUM_WIDTH*111];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(8), .NUMEL_LOG(3)
) vs_lifm_st2_idx14 (
    .i_vec(i_lifm_st2_idx14), .stride(i_dist_st2_idx14), .o_vec(o_lifm_st2_idx14)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(8), .NUMEL_LOG(3)
) vs_mt_st2_idx14 (
    .i_vec(i_mt_st2_idx14), .stride(i_dist_st2_idx14), .o_vec(o_mt_st2_idx14)
);

assign lifm_st2_wo[WORD_WIDTH*120-1:WORD_WIDTH*116] = o_lifm_st2_idx14[WORD_WIDTH*8-1:WORD_WIDTH*4];
assign lifm_st2_wo[WORD_WIDTH*116-1:WORD_WIDTH*112] = o_lifm_st2_idx14[WORD_WIDTH*4-1:0] | lifm_st2_wi[WORD_WIDTH*116-1:WORD_WIDTH*112];
assign mt_st2_wo[DIST_WIDTH*MAX_LIFM_RSIZ*120-1:DIST_WIDTH*MAX_LIFM_RSIZ*116] = o_mt_st2_idx14[DIST_WIDTH*MAX_LIFM_RSIZ*8-1:DIST_WIDTH*MAX_LIFM_RSIZ*4];
assign mt_st2_wo[DIST_WIDTH*MAX_LIFM_RSIZ*116-1:DIST_WIDTH*MAX_LIFM_RSIZ*112] = o_mt_st2_idx14[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:0] | mt_st2_wi[DIST_WIDTH*MAX_LIFM_RSIZ*116-1:DIST_WIDTH*MAX_LIFM_RSIZ*112];


// Stage2 Index15
wire [WORD_WIDTH*4*2-1:0] i_lifm_st2_idx15;
wire [WORD_WIDTH*4*2-1:0] o_lifm_st2_idx15;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*4*2-1:0] i_mt_st2_idx15;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*4*2-1:0] o_mt_st2_idx15;
wire [3-1:0] i_dist_st2_idx15;

assign i_lifm_st2_idx15 = { lifm_st2_wi[WORD_WIDTH*128-1:WORD_WIDTH*124], { WORD_WIDTH*4{1'b0} } };
assign i_mt_st2_idx15   = { mt_st2_wi[DIST_WIDTH*MAX_LIFM_RSIZ*128-1:DIST_WIDTH*MAX_LIFM_RSIZ*124], { DIST_WIDTH*MAX_LIFM_RSIZ*4{1'b0} } };
assign i_dist_st2_idx15 = psum[PSUM_WIDTH*124-1:PSUM_WIDTH*123] - psum[PSUM_WIDTH*120-1:PSUM_WIDTH*119];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(8), .NUMEL_LOG(3)
) vs_lifm_st2_idx15 (
    .i_vec(i_lifm_st2_idx15), .stride(i_dist_st2_idx15), .o_vec(o_lifm_st2_idx15)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(8), .NUMEL_LOG(3)
) vs_mt_st2_idx15 (
    .i_vec(i_mt_st2_idx15), .stride(i_dist_st2_idx15), .o_vec(o_mt_st2_idx15)
);

assign lifm_st2_wo[WORD_WIDTH*128-1:WORD_WIDTH*124] = o_lifm_st2_idx15[WORD_WIDTH*8-1:WORD_WIDTH*4];
assign lifm_st2_wo[WORD_WIDTH*124-1:WORD_WIDTH*120] = o_lifm_st2_idx15[WORD_WIDTH*4-1:0] | lifm_st2_wi[WORD_WIDTH*124-1:WORD_WIDTH*120];
assign mt_st2_wo[DIST_WIDTH*MAX_LIFM_RSIZ*128-1:DIST_WIDTH*MAX_LIFM_RSIZ*124] = o_mt_st2_idx15[DIST_WIDTH*MAX_LIFM_RSIZ*8-1:DIST_WIDTH*MAX_LIFM_RSIZ*4];
assign mt_st2_wo[DIST_WIDTH*MAX_LIFM_RSIZ*124-1:DIST_WIDTH*MAX_LIFM_RSIZ*120] = o_mt_st2_idx15[DIST_WIDTH*MAX_LIFM_RSIZ*4-1:0] | mt_st2_wi[DIST_WIDTH*MAX_LIFM_RSIZ*124-1:DIST_WIDTH*MAX_LIFM_RSIZ*120];



// Stage3
wire [128*WORD_WIDTH-1:0] lifm_st3_wi;  // stage input for LIFM
wire [128*WORD_WIDTH-1:0] lifm_st3_wo;  // stage output of LIFM
wire [128*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_st3_wi;  // stage input for MT
wire [128*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_st3_wo;  // stage output of MT

assign lifm_st3_wi = lifm_st2_wo;
assign mt_st3_wi = mt_st2_wo;

// Stage3 Index0
wire [WORD_WIDTH*8*2-1:0] i_lifm_st3_idx0;
wire [WORD_WIDTH*8*2-1:0] o_lifm_st3_idx0;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*8*2-1:0] i_mt_st3_idx0;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*8*2-1:0] o_mt_st3_idx0;
wire [4-1:0] i_dist_st3_idx0;

assign i_lifm_st3_idx0 = { lifm_st3_wi[WORD_WIDTH*16-1:WORD_WIDTH*8], { WORD_WIDTH*8{1'b0} } };
assign i_mt_st3_idx0   = { mt_st3_wi[DIST_WIDTH*MAX_LIFM_RSIZ*16-1:DIST_WIDTH*MAX_LIFM_RSIZ*8], { DIST_WIDTH*MAX_LIFM_RSIZ*8{1'b0} } };
assign i_dist_st3_idx0 = psum[PSUM_WIDTH*8-1:PSUM_WIDTH*7];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(16), .NUMEL_LOG(4)
) vs_lifm_st3_idx0 (
    .i_vec(i_lifm_st3_idx0), .stride(i_dist_st3_idx0), .o_vec(o_lifm_st3_idx0)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(16), .NUMEL_LOG(4)
) vs_mt_st3_idx0 (
    .i_vec(i_mt_st3_idx0), .stride(i_dist_st3_idx0), .o_vec(o_mt_st3_idx0)
);

assign lifm_st3_wo[WORD_WIDTH*16-1:WORD_WIDTH*8] = o_lifm_st3_idx0[WORD_WIDTH*16-1:WORD_WIDTH*8];
assign lifm_st3_wo[WORD_WIDTH*8-1:WORD_WIDTH*0] = o_lifm_st3_idx0[WORD_WIDTH*8-1:0] | lifm_st3_wi[WORD_WIDTH*8-1:WORD_WIDTH*0];
assign mt_st3_wo[DIST_WIDTH*MAX_LIFM_RSIZ*16-1:DIST_WIDTH*MAX_LIFM_RSIZ*8] = o_mt_st3_idx0[DIST_WIDTH*MAX_LIFM_RSIZ*16-1:DIST_WIDTH*MAX_LIFM_RSIZ*8];
assign mt_st3_wo[DIST_WIDTH*MAX_LIFM_RSIZ*8-1:DIST_WIDTH*MAX_LIFM_RSIZ*0] = o_mt_st3_idx0[DIST_WIDTH*MAX_LIFM_RSIZ*8-1:0] | mt_st3_wi[DIST_WIDTH*MAX_LIFM_RSIZ*8-1:DIST_WIDTH*MAX_LIFM_RSIZ*0];


// Stage3 Index1
wire [WORD_WIDTH*8*2-1:0] i_lifm_st3_idx1;
wire [WORD_WIDTH*8*2-1:0] o_lifm_st3_idx1;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*8*2-1:0] i_mt_st3_idx1;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*8*2-1:0] o_mt_st3_idx1;
wire [4-1:0] i_dist_st3_idx1;

assign i_lifm_st3_idx1 = { lifm_st3_wi[WORD_WIDTH*32-1:WORD_WIDTH*24], { WORD_WIDTH*8{1'b0} } };
assign i_mt_st3_idx1   = { mt_st3_wi[DIST_WIDTH*MAX_LIFM_RSIZ*32-1:DIST_WIDTH*MAX_LIFM_RSIZ*24], { DIST_WIDTH*MAX_LIFM_RSIZ*8{1'b0} } };
assign i_dist_st3_idx1 = psum[PSUM_WIDTH*24-1:PSUM_WIDTH*23] - psum[PSUM_WIDTH*16-1:PSUM_WIDTH*15];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(16), .NUMEL_LOG(4)
) vs_lifm_st3_idx1 (
    .i_vec(i_lifm_st3_idx1), .stride(i_dist_st3_idx1), .o_vec(o_lifm_st3_idx1)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(16), .NUMEL_LOG(4)
) vs_mt_st3_idx1 (
    .i_vec(i_mt_st3_idx1), .stride(i_dist_st3_idx1), .o_vec(o_mt_st3_idx1)
);

assign lifm_st3_wo[WORD_WIDTH*32-1:WORD_WIDTH*24] = o_lifm_st3_idx1[WORD_WIDTH*16-1:WORD_WIDTH*8];
assign lifm_st3_wo[WORD_WIDTH*24-1:WORD_WIDTH*16] = o_lifm_st3_idx1[WORD_WIDTH*8-1:0] | lifm_st3_wi[WORD_WIDTH*24-1:WORD_WIDTH*16];
assign mt_st3_wo[DIST_WIDTH*MAX_LIFM_RSIZ*32-1:DIST_WIDTH*MAX_LIFM_RSIZ*24] = o_mt_st3_idx1[DIST_WIDTH*MAX_LIFM_RSIZ*16-1:DIST_WIDTH*MAX_LIFM_RSIZ*8];
assign mt_st3_wo[DIST_WIDTH*MAX_LIFM_RSIZ*24-1:DIST_WIDTH*MAX_LIFM_RSIZ*16] = o_mt_st3_idx1[DIST_WIDTH*MAX_LIFM_RSIZ*8-1:0] | mt_st3_wi[DIST_WIDTH*MAX_LIFM_RSIZ*24-1:DIST_WIDTH*MAX_LIFM_RSIZ*16];


// Stage3 Index2
wire [WORD_WIDTH*8*2-1:0] i_lifm_st3_idx2;
wire [WORD_WIDTH*8*2-1:0] o_lifm_st3_idx2;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*8*2-1:0] i_mt_st3_idx2;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*8*2-1:0] o_mt_st3_idx2;
wire [4-1:0] i_dist_st3_idx2;

assign i_lifm_st3_idx2 = { lifm_st3_wi[WORD_WIDTH*48-1:WORD_WIDTH*40], { WORD_WIDTH*8{1'b0} } };
assign i_mt_st3_idx2   = { mt_st3_wi[DIST_WIDTH*MAX_LIFM_RSIZ*48-1:DIST_WIDTH*MAX_LIFM_RSIZ*40], { DIST_WIDTH*MAX_LIFM_RSIZ*8{1'b0} } };
assign i_dist_st3_idx2 = psum[PSUM_WIDTH*40-1:PSUM_WIDTH*39] - psum[PSUM_WIDTH*32-1:PSUM_WIDTH*31];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(16), .NUMEL_LOG(4)
) vs_lifm_st3_idx2 (
    .i_vec(i_lifm_st3_idx2), .stride(i_dist_st3_idx2), .o_vec(o_lifm_st3_idx2)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(16), .NUMEL_LOG(4)
) vs_mt_st3_idx2 (
    .i_vec(i_mt_st3_idx2), .stride(i_dist_st3_idx2), .o_vec(o_mt_st3_idx2)
);

assign lifm_st3_wo[WORD_WIDTH*48-1:WORD_WIDTH*40] = o_lifm_st3_idx2[WORD_WIDTH*16-1:WORD_WIDTH*8];
assign lifm_st3_wo[WORD_WIDTH*40-1:WORD_WIDTH*32] = o_lifm_st3_idx2[WORD_WIDTH*8-1:0] | lifm_st3_wi[WORD_WIDTH*40-1:WORD_WIDTH*32];
assign mt_st3_wo[DIST_WIDTH*MAX_LIFM_RSIZ*48-1:DIST_WIDTH*MAX_LIFM_RSIZ*40] = o_mt_st3_idx2[DIST_WIDTH*MAX_LIFM_RSIZ*16-1:DIST_WIDTH*MAX_LIFM_RSIZ*8];
assign mt_st3_wo[DIST_WIDTH*MAX_LIFM_RSIZ*40-1:DIST_WIDTH*MAX_LIFM_RSIZ*32] = o_mt_st3_idx2[DIST_WIDTH*MAX_LIFM_RSIZ*8-1:0] | mt_st3_wi[DIST_WIDTH*MAX_LIFM_RSIZ*40-1:DIST_WIDTH*MAX_LIFM_RSIZ*32];


// Stage3 Index3
wire [WORD_WIDTH*8*2-1:0] i_lifm_st3_idx3;
wire [WORD_WIDTH*8*2-1:0] o_lifm_st3_idx3;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*8*2-1:0] i_mt_st3_idx3;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*8*2-1:0] o_mt_st3_idx3;
wire [4-1:0] i_dist_st3_idx3;

assign i_lifm_st3_idx3 = { lifm_st3_wi[WORD_WIDTH*64-1:WORD_WIDTH*56], { WORD_WIDTH*8{1'b0} } };
assign i_mt_st3_idx3   = { mt_st3_wi[DIST_WIDTH*MAX_LIFM_RSIZ*64-1:DIST_WIDTH*MAX_LIFM_RSIZ*56], { DIST_WIDTH*MAX_LIFM_RSIZ*8{1'b0} } };
assign i_dist_st3_idx3 = psum[PSUM_WIDTH*56-1:PSUM_WIDTH*55] - psum[PSUM_WIDTH*48-1:PSUM_WIDTH*47];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(16), .NUMEL_LOG(4)
) vs_lifm_st3_idx3 (
    .i_vec(i_lifm_st3_idx3), .stride(i_dist_st3_idx3), .o_vec(o_lifm_st3_idx3)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(16), .NUMEL_LOG(4)
) vs_mt_st3_idx3 (
    .i_vec(i_mt_st3_idx3), .stride(i_dist_st3_idx3), .o_vec(o_mt_st3_idx3)
);

assign lifm_st3_wo[WORD_WIDTH*64-1:WORD_WIDTH*56] = o_lifm_st3_idx3[WORD_WIDTH*16-1:WORD_WIDTH*8];
assign lifm_st3_wo[WORD_WIDTH*56-1:WORD_WIDTH*48] = o_lifm_st3_idx3[WORD_WIDTH*8-1:0] | lifm_st3_wi[WORD_WIDTH*56-1:WORD_WIDTH*48];
assign mt_st3_wo[DIST_WIDTH*MAX_LIFM_RSIZ*64-1:DIST_WIDTH*MAX_LIFM_RSIZ*56] = o_mt_st3_idx3[DIST_WIDTH*MAX_LIFM_RSIZ*16-1:DIST_WIDTH*MAX_LIFM_RSIZ*8];
assign mt_st3_wo[DIST_WIDTH*MAX_LIFM_RSIZ*56-1:DIST_WIDTH*MAX_LIFM_RSIZ*48] = o_mt_st3_idx3[DIST_WIDTH*MAX_LIFM_RSIZ*8-1:0] | mt_st3_wi[DIST_WIDTH*MAX_LIFM_RSIZ*56-1:DIST_WIDTH*MAX_LIFM_RSIZ*48];


// Stage3 Index4
wire [WORD_WIDTH*8*2-1:0] i_lifm_st3_idx4;
wire [WORD_WIDTH*8*2-1:0] o_lifm_st3_idx4;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*8*2-1:0] i_mt_st3_idx4;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*8*2-1:0] o_mt_st3_idx4;
wire [4-1:0] i_dist_st3_idx4;

assign i_lifm_st3_idx4 = { lifm_st3_wi[WORD_WIDTH*80-1:WORD_WIDTH*72], { WORD_WIDTH*8{1'b0} } };
assign i_mt_st3_idx4   = { mt_st3_wi[DIST_WIDTH*MAX_LIFM_RSIZ*80-1:DIST_WIDTH*MAX_LIFM_RSIZ*72], { DIST_WIDTH*MAX_LIFM_RSIZ*8{1'b0} } };
assign i_dist_st3_idx4 = psum[PSUM_WIDTH*72-1:PSUM_WIDTH*71] - psum[PSUM_WIDTH*64-1:PSUM_WIDTH*63];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(16), .NUMEL_LOG(4)
) vs_lifm_st3_idx4 (
    .i_vec(i_lifm_st3_idx4), .stride(i_dist_st3_idx4), .o_vec(o_lifm_st3_idx4)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(16), .NUMEL_LOG(4)
) vs_mt_st3_idx4 (
    .i_vec(i_mt_st3_idx4), .stride(i_dist_st3_idx4), .o_vec(o_mt_st3_idx4)
);

assign lifm_st3_wo[WORD_WIDTH*80-1:WORD_WIDTH*72] = o_lifm_st3_idx4[WORD_WIDTH*16-1:WORD_WIDTH*8];
assign lifm_st3_wo[WORD_WIDTH*72-1:WORD_WIDTH*64] = o_lifm_st3_idx4[WORD_WIDTH*8-1:0] | lifm_st3_wi[WORD_WIDTH*72-1:WORD_WIDTH*64];
assign mt_st3_wo[DIST_WIDTH*MAX_LIFM_RSIZ*80-1:DIST_WIDTH*MAX_LIFM_RSIZ*72] = o_mt_st3_idx4[DIST_WIDTH*MAX_LIFM_RSIZ*16-1:DIST_WIDTH*MAX_LIFM_RSIZ*8];
assign mt_st3_wo[DIST_WIDTH*MAX_LIFM_RSIZ*72-1:DIST_WIDTH*MAX_LIFM_RSIZ*64] = o_mt_st3_idx4[DIST_WIDTH*MAX_LIFM_RSIZ*8-1:0] | mt_st3_wi[DIST_WIDTH*MAX_LIFM_RSIZ*72-1:DIST_WIDTH*MAX_LIFM_RSIZ*64];


// Stage3 Index5
wire [WORD_WIDTH*8*2-1:0] i_lifm_st3_idx5;
wire [WORD_WIDTH*8*2-1:0] o_lifm_st3_idx5;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*8*2-1:0] i_mt_st3_idx5;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*8*2-1:0] o_mt_st3_idx5;
wire [4-1:0] i_dist_st3_idx5;

assign i_lifm_st3_idx5 = { lifm_st3_wi[WORD_WIDTH*96-1:WORD_WIDTH*88], { WORD_WIDTH*8{1'b0} } };
assign i_mt_st3_idx5   = { mt_st3_wi[DIST_WIDTH*MAX_LIFM_RSIZ*96-1:DIST_WIDTH*MAX_LIFM_RSIZ*88], { DIST_WIDTH*MAX_LIFM_RSIZ*8{1'b0} } };
assign i_dist_st3_idx5 = psum[PSUM_WIDTH*88-1:PSUM_WIDTH*87] - psum[PSUM_WIDTH*80-1:PSUM_WIDTH*79];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(16), .NUMEL_LOG(4)
) vs_lifm_st3_idx5 (
    .i_vec(i_lifm_st3_idx5), .stride(i_dist_st3_idx5), .o_vec(o_lifm_st3_idx5)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(16), .NUMEL_LOG(4)
) vs_mt_st3_idx5 (
    .i_vec(i_mt_st3_idx5), .stride(i_dist_st3_idx5), .o_vec(o_mt_st3_idx5)
);

assign lifm_st3_wo[WORD_WIDTH*96-1:WORD_WIDTH*88] = o_lifm_st3_idx5[WORD_WIDTH*16-1:WORD_WIDTH*8];
assign lifm_st3_wo[WORD_WIDTH*88-1:WORD_WIDTH*80] = o_lifm_st3_idx5[WORD_WIDTH*8-1:0] | lifm_st3_wi[WORD_WIDTH*88-1:WORD_WIDTH*80];
assign mt_st3_wo[DIST_WIDTH*MAX_LIFM_RSIZ*96-1:DIST_WIDTH*MAX_LIFM_RSIZ*88] = o_mt_st3_idx5[DIST_WIDTH*MAX_LIFM_RSIZ*16-1:DIST_WIDTH*MAX_LIFM_RSIZ*8];
assign mt_st3_wo[DIST_WIDTH*MAX_LIFM_RSIZ*88-1:DIST_WIDTH*MAX_LIFM_RSIZ*80] = o_mt_st3_idx5[DIST_WIDTH*MAX_LIFM_RSIZ*8-1:0] | mt_st3_wi[DIST_WIDTH*MAX_LIFM_RSIZ*88-1:DIST_WIDTH*MAX_LIFM_RSIZ*80];


// Stage3 Index6
wire [WORD_WIDTH*8*2-1:0] i_lifm_st3_idx6;
wire [WORD_WIDTH*8*2-1:0] o_lifm_st3_idx6;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*8*2-1:0] i_mt_st3_idx6;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*8*2-1:0] o_mt_st3_idx6;
wire [4-1:0] i_dist_st3_idx6;

assign i_lifm_st3_idx6 = { lifm_st3_wi[WORD_WIDTH*112-1:WORD_WIDTH*104], { WORD_WIDTH*8{1'b0} } };
assign i_mt_st3_idx6   = { mt_st3_wi[DIST_WIDTH*MAX_LIFM_RSIZ*112-1:DIST_WIDTH*MAX_LIFM_RSIZ*104], { DIST_WIDTH*MAX_LIFM_RSIZ*8{1'b0} } };
assign i_dist_st3_idx6 = psum[PSUM_WIDTH*104-1:PSUM_WIDTH*103] - psum[PSUM_WIDTH*96-1:PSUM_WIDTH*95];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(16), .NUMEL_LOG(4)
) vs_lifm_st3_idx6 (
    .i_vec(i_lifm_st3_idx6), .stride(i_dist_st3_idx6), .o_vec(o_lifm_st3_idx6)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(16), .NUMEL_LOG(4)
) vs_mt_st3_idx6 (
    .i_vec(i_mt_st3_idx6), .stride(i_dist_st3_idx6), .o_vec(o_mt_st3_idx6)
);

assign lifm_st3_wo[WORD_WIDTH*112-1:WORD_WIDTH*104] = o_lifm_st3_idx6[WORD_WIDTH*16-1:WORD_WIDTH*8];
assign lifm_st3_wo[WORD_WIDTH*104-1:WORD_WIDTH*96] = o_lifm_st3_idx6[WORD_WIDTH*8-1:0] | lifm_st3_wi[WORD_WIDTH*104-1:WORD_WIDTH*96];
assign mt_st3_wo[DIST_WIDTH*MAX_LIFM_RSIZ*112-1:DIST_WIDTH*MAX_LIFM_RSIZ*104] = o_mt_st3_idx6[DIST_WIDTH*MAX_LIFM_RSIZ*16-1:DIST_WIDTH*MAX_LIFM_RSIZ*8];
assign mt_st3_wo[DIST_WIDTH*MAX_LIFM_RSIZ*104-1:DIST_WIDTH*MAX_LIFM_RSIZ*96] = o_mt_st3_idx6[DIST_WIDTH*MAX_LIFM_RSIZ*8-1:0] | mt_st3_wi[DIST_WIDTH*MAX_LIFM_RSIZ*104-1:DIST_WIDTH*MAX_LIFM_RSIZ*96];


// Stage3 Index7
wire [WORD_WIDTH*8*2-1:0] i_lifm_st3_idx7;
wire [WORD_WIDTH*8*2-1:0] o_lifm_st3_idx7;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*8*2-1:0] i_mt_st3_idx7;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*8*2-1:0] o_mt_st3_idx7;
wire [4-1:0] i_dist_st3_idx7;

assign i_lifm_st3_idx7 = { lifm_st3_wi[WORD_WIDTH*128-1:WORD_WIDTH*120], { WORD_WIDTH*8{1'b0} } };
assign i_mt_st3_idx7   = { mt_st3_wi[DIST_WIDTH*MAX_LIFM_RSIZ*128-1:DIST_WIDTH*MAX_LIFM_RSIZ*120], { DIST_WIDTH*MAX_LIFM_RSIZ*8{1'b0} } };
assign i_dist_st3_idx7 = psum[PSUM_WIDTH*120-1:PSUM_WIDTH*119] - psum[PSUM_WIDTH*112-1:PSUM_WIDTH*111];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(16), .NUMEL_LOG(4)
) vs_lifm_st3_idx7 (
    .i_vec(i_lifm_st3_idx7), .stride(i_dist_st3_idx7), .o_vec(o_lifm_st3_idx7)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(16), .NUMEL_LOG(4)
) vs_mt_st3_idx7 (
    .i_vec(i_mt_st3_idx7), .stride(i_dist_st3_idx7), .o_vec(o_mt_st3_idx7)
);

assign lifm_st3_wo[WORD_WIDTH*128-1:WORD_WIDTH*120] = o_lifm_st3_idx7[WORD_WIDTH*16-1:WORD_WIDTH*8];
assign lifm_st3_wo[WORD_WIDTH*120-1:WORD_WIDTH*112] = o_lifm_st3_idx7[WORD_WIDTH*8-1:0] | lifm_st3_wi[WORD_WIDTH*120-1:WORD_WIDTH*112];
assign mt_st3_wo[DIST_WIDTH*MAX_LIFM_RSIZ*128-1:DIST_WIDTH*MAX_LIFM_RSIZ*120] = o_mt_st3_idx7[DIST_WIDTH*MAX_LIFM_RSIZ*16-1:DIST_WIDTH*MAX_LIFM_RSIZ*8];
assign mt_st3_wo[DIST_WIDTH*MAX_LIFM_RSIZ*120-1:DIST_WIDTH*MAX_LIFM_RSIZ*112] = o_mt_st3_idx7[DIST_WIDTH*MAX_LIFM_RSIZ*8-1:0] | mt_st3_wi[DIST_WIDTH*MAX_LIFM_RSIZ*120-1:DIST_WIDTH*MAX_LIFM_RSIZ*112];



// Stage4
wire [128*WORD_WIDTH-1:0] lifm_st4_wi;  // stage input for LIFM
wire [128*WORD_WIDTH-1:0] lifm_st4_wo;  // stage output of LIFM
wire [128*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_st4_wi;  // stage input for MT
wire [128*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_st4_wo;  // stage output of MT

assign lifm_st4_wi = lifm_st3_wo;
assign mt_st4_wi = mt_st3_wo;

// Stage4 Index0
wire [WORD_WIDTH*16*2-1:0] i_lifm_st4_idx0;
wire [WORD_WIDTH*16*2-1:0] o_lifm_st4_idx0;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*16*2-1:0] i_mt_st4_idx0;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*16*2-1:0] o_mt_st4_idx0;
wire [5-1:0] i_dist_st4_idx0;

assign i_lifm_st4_idx0 = { lifm_st4_wi[WORD_WIDTH*32-1:WORD_WIDTH*16], { WORD_WIDTH*16{1'b0} } };
assign i_mt_st4_idx0   = { mt_st4_wi[DIST_WIDTH*MAX_LIFM_RSIZ*32-1:DIST_WIDTH*MAX_LIFM_RSIZ*16], { DIST_WIDTH*MAX_LIFM_RSIZ*16{1'b0} } };
assign i_dist_st4_idx0 = psum[PSUM_WIDTH*16-1:PSUM_WIDTH*15];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(32), .NUMEL_LOG(5)
) vs_lifm_st4_idx0 (
    .i_vec(i_lifm_st4_idx0), .stride(i_dist_st4_idx0), .o_vec(o_lifm_st4_idx0)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(32), .NUMEL_LOG(5)
) vs_mt_st4_idx0 (
    .i_vec(i_mt_st4_idx0), .stride(i_dist_st4_idx0), .o_vec(o_mt_st4_idx0)
);

assign lifm_st4_wo[WORD_WIDTH*32-1:WORD_WIDTH*16] = o_lifm_st4_idx0[WORD_WIDTH*32-1:WORD_WIDTH*16];
assign lifm_st4_wo[WORD_WIDTH*16-1:WORD_WIDTH*0] = o_lifm_st4_idx0[WORD_WIDTH*16-1:0] | lifm_st4_wi[WORD_WIDTH*16-1:WORD_WIDTH*0];
assign mt_st4_wo[DIST_WIDTH*MAX_LIFM_RSIZ*32-1:DIST_WIDTH*MAX_LIFM_RSIZ*16] = o_mt_st4_idx0[DIST_WIDTH*MAX_LIFM_RSIZ*32-1:DIST_WIDTH*MAX_LIFM_RSIZ*16];
assign mt_st4_wo[DIST_WIDTH*MAX_LIFM_RSIZ*16-1:DIST_WIDTH*MAX_LIFM_RSIZ*0] = o_mt_st4_idx0[DIST_WIDTH*MAX_LIFM_RSIZ*16-1:0] | mt_st4_wi[DIST_WIDTH*MAX_LIFM_RSIZ*16-1:DIST_WIDTH*MAX_LIFM_RSIZ*0];


// Stage4 Index1
wire [WORD_WIDTH*16*2-1:0] i_lifm_st4_idx1;
wire [WORD_WIDTH*16*2-1:0] o_lifm_st4_idx1;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*16*2-1:0] i_mt_st4_idx1;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*16*2-1:0] o_mt_st4_idx1;
wire [5-1:0] i_dist_st4_idx1;

assign i_lifm_st4_idx1 = { lifm_st4_wi[WORD_WIDTH*64-1:WORD_WIDTH*48], { WORD_WIDTH*16{1'b0} } };
assign i_mt_st4_idx1   = { mt_st4_wi[DIST_WIDTH*MAX_LIFM_RSIZ*64-1:DIST_WIDTH*MAX_LIFM_RSIZ*48], { DIST_WIDTH*MAX_LIFM_RSIZ*16{1'b0} } };
assign i_dist_st4_idx1 = psum[PSUM_WIDTH*48-1:PSUM_WIDTH*47] - psum[PSUM_WIDTH*32-1:PSUM_WIDTH*31];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(32), .NUMEL_LOG(5)
) vs_lifm_st4_idx1 (
    .i_vec(i_lifm_st4_idx1), .stride(i_dist_st4_idx1), .o_vec(o_lifm_st4_idx1)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(32), .NUMEL_LOG(5)
) vs_mt_st4_idx1 (
    .i_vec(i_mt_st4_idx1), .stride(i_dist_st4_idx1), .o_vec(o_mt_st4_idx1)
);

assign lifm_st4_wo[WORD_WIDTH*64-1:WORD_WIDTH*48] = o_lifm_st4_idx1[WORD_WIDTH*32-1:WORD_WIDTH*16];
assign lifm_st4_wo[WORD_WIDTH*48-1:WORD_WIDTH*32] = o_lifm_st4_idx1[WORD_WIDTH*16-1:0] | lifm_st4_wi[WORD_WIDTH*48-1:WORD_WIDTH*32];
assign mt_st4_wo[DIST_WIDTH*MAX_LIFM_RSIZ*64-1:DIST_WIDTH*MAX_LIFM_RSIZ*48] = o_mt_st4_idx1[DIST_WIDTH*MAX_LIFM_RSIZ*32-1:DIST_WIDTH*MAX_LIFM_RSIZ*16];
assign mt_st4_wo[DIST_WIDTH*MAX_LIFM_RSIZ*48-1:DIST_WIDTH*MAX_LIFM_RSIZ*32] = o_mt_st4_idx1[DIST_WIDTH*MAX_LIFM_RSIZ*16-1:0] | mt_st4_wi[DIST_WIDTH*MAX_LIFM_RSIZ*48-1:DIST_WIDTH*MAX_LIFM_RSIZ*32];


// Stage4 Index2
wire [WORD_WIDTH*16*2-1:0] i_lifm_st4_idx2;
wire [WORD_WIDTH*16*2-1:0] o_lifm_st4_idx2;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*16*2-1:0] i_mt_st4_idx2;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*16*2-1:0] o_mt_st4_idx2;
wire [5-1:0] i_dist_st4_idx2;

assign i_lifm_st4_idx2 = { lifm_st4_wi[WORD_WIDTH*96-1:WORD_WIDTH*80], { WORD_WIDTH*16{1'b0} } };
assign i_mt_st4_idx2   = { mt_st4_wi[DIST_WIDTH*MAX_LIFM_RSIZ*96-1:DIST_WIDTH*MAX_LIFM_RSIZ*80], { DIST_WIDTH*MAX_LIFM_RSIZ*16{1'b0} } };
assign i_dist_st4_idx2 = psum[PSUM_WIDTH*80-1:PSUM_WIDTH*79] - psum[PSUM_WIDTH*64-1:PSUM_WIDTH*63];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(32), .NUMEL_LOG(5)
) vs_lifm_st4_idx2 (
    .i_vec(i_lifm_st4_idx2), .stride(i_dist_st4_idx2), .o_vec(o_lifm_st4_idx2)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(32), .NUMEL_LOG(5)
) vs_mt_st4_idx2 (
    .i_vec(i_mt_st4_idx2), .stride(i_dist_st4_idx2), .o_vec(o_mt_st4_idx2)
);

assign lifm_st4_wo[WORD_WIDTH*96-1:WORD_WIDTH*80] = o_lifm_st4_idx2[WORD_WIDTH*32-1:WORD_WIDTH*16];
assign lifm_st4_wo[WORD_WIDTH*80-1:WORD_WIDTH*64] = o_lifm_st4_idx2[WORD_WIDTH*16-1:0] | lifm_st4_wi[WORD_WIDTH*80-1:WORD_WIDTH*64];
assign mt_st4_wo[DIST_WIDTH*MAX_LIFM_RSIZ*96-1:DIST_WIDTH*MAX_LIFM_RSIZ*80] = o_mt_st4_idx2[DIST_WIDTH*MAX_LIFM_RSIZ*32-1:DIST_WIDTH*MAX_LIFM_RSIZ*16];
assign mt_st4_wo[DIST_WIDTH*MAX_LIFM_RSIZ*80-1:DIST_WIDTH*MAX_LIFM_RSIZ*64] = o_mt_st4_idx2[DIST_WIDTH*MAX_LIFM_RSIZ*16-1:0] | mt_st4_wi[DIST_WIDTH*MAX_LIFM_RSIZ*80-1:DIST_WIDTH*MAX_LIFM_RSIZ*64];


// Stage4 Index3
wire [WORD_WIDTH*16*2-1:0] i_lifm_st4_idx3;
wire [WORD_WIDTH*16*2-1:0] o_lifm_st4_idx3;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*16*2-1:0] i_mt_st4_idx3;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*16*2-1:0] o_mt_st4_idx3;
wire [5-1:0] i_dist_st4_idx3;

assign i_lifm_st4_idx3 = { lifm_st4_wi[WORD_WIDTH*128-1:WORD_WIDTH*112], { WORD_WIDTH*16{1'b0} } };
assign i_mt_st4_idx3   = { mt_st4_wi[DIST_WIDTH*MAX_LIFM_RSIZ*128-1:DIST_WIDTH*MAX_LIFM_RSIZ*112], { DIST_WIDTH*MAX_LIFM_RSIZ*16{1'b0} } };
assign i_dist_st4_idx3 = psum[PSUM_WIDTH*112-1:PSUM_WIDTH*111] - psum[PSUM_WIDTH*96-1:PSUM_WIDTH*95];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(32), .NUMEL_LOG(5)
) vs_lifm_st4_idx3 (
    .i_vec(i_lifm_st4_idx3), .stride(i_dist_st4_idx3), .o_vec(o_lifm_st4_idx3)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(32), .NUMEL_LOG(5)
) vs_mt_st4_idx3 (
    .i_vec(i_mt_st4_idx3), .stride(i_dist_st4_idx3), .o_vec(o_mt_st4_idx3)
);

assign lifm_st4_wo[WORD_WIDTH*128-1:WORD_WIDTH*112] = o_lifm_st4_idx3[WORD_WIDTH*32-1:WORD_WIDTH*16];
assign lifm_st4_wo[WORD_WIDTH*112-1:WORD_WIDTH*96] = o_lifm_st4_idx3[WORD_WIDTH*16-1:0] | lifm_st4_wi[WORD_WIDTH*112-1:WORD_WIDTH*96];
assign mt_st4_wo[DIST_WIDTH*MAX_LIFM_RSIZ*128-1:DIST_WIDTH*MAX_LIFM_RSIZ*112] = o_mt_st4_idx3[DIST_WIDTH*MAX_LIFM_RSIZ*32-1:DIST_WIDTH*MAX_LIFM_RSIZ*16];
assign mt_st4_wo[DIST_WIDTH*MAX_LIFM_RSIZ*112-1:DIST_WIDTH*MAX_LIFM_RSIZ*96] = o_mt_st4_idx3[DIST_WIDTH*MAX_LIFM_RSIZ*16-1:0] | mt_st4_wi[DIST_WIDTH*MAX_LIFM_RSIZ*112-1:DIST_WIDTH*MAX_LIFM_RSIZ*96];



// Stage5
wire [128*WORD_WIDTH-1:0] lifm_st5_wi;  // stage input for LIFM
wire [128*WORD_WIDTH-1:0] lifm_st5_wo;  // stage output of LIFM
wire [128*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_st5_wi;  // stage input for MT
wire [128*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_st5_wo;  // stage output of MT

assign lifm_st5_wi = lifm_st4_wo;
assign mt_st5_wi = mt_st4_wo;

// Stage5 Index0
wire [WORD_WIDTH*32*2-1:0] i_lifm_st5_idx0;
wire [WORD_WIDTH*32*2-1:0] o_lifm_st5_idx0;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*32*2-1:0] i_mt_st5_idx0;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*32*2-1:0] o_mt_st5_idx0;
wire [6-1:0] i_dist_st5_idx0;

assign i_lifm_st5_idx0 = { lifm_st5_wi[WORD_WIDTH*64-1:WORD_WIDTH*32], { WORD_WIDTH*32{1'b0} } };
assign i_mt_st5_idx0   = { mt_st5_wi[DIST_WIDTH*MAX_LIFM_RSIZ*64-1:DIST_WIDTH*MAX_LIFM_RSIZ*32], { DIST_WIDTH*MAX_LIFM_RSIZ*32{1'b0} } };
assign i_dist_st5_idx0 = psum[PSUM_WIDTH*32-1:PSUM_WIDTH*31];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(64), .NUMEL_LOG(6)
) vs_lifm_st5_idx0 (
    .i_vec(i_lifm_st5_idx0), .stride(i_dist_st5_idx0), .o_vec(o_lifm_st5_idx0)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(64), .NUMEL_LOG(6)
) vs_mt_st5_idx0 (
    .i_vec(i_mt_st5_idx0), .stride(i_dist_st5_idx0), .o_vec(o_mt_st5_idx0)
);

assign lifm_st5_wo[WORD_WIDTH*64-1:WORD_WIDTH*32] = o_lifm_st5_idx0[WORD_WIDTH*64-1:WORD_WIDTH*32];
assign lifm_st5_wo[WORD_WIDTH*32-1:WORD_WIDTH*0] = o_lifm_st5_idx0[WORD_WIDTH*32-1:0] | lifm_st5_wi[WORD_WIDTH*32-1:WORD_WIDTH*0];
assign mt_st5_wo[DIST_WIDTH*MAX_LIFM_RSIZ*64-1:DIST_WIDTH*MAX_LIFM_RSIZ*32] = o_mt_st5_idx0[DIST_WIDTH*MAX_LIFM_RSIZ*64-1:DIST_WIDTH*MAX_LIFM_RSIZ*32];
assign mt_st5_wo[DIST_WIDTH*MAX_LIFM_RSIZ*32-1:DIST_WIDTH*MAX_LIFM_RSIZ*0] = o_mt_st5_idx0[DIST_WIDTH*MAX_LIFM_RSIZ*32-1:0] | mt_st5_wi[DIST_WIDTH*MAX_LIFM_RSIZ*32-1:DIST_WIDTH*MAX_LIFM_RSIZ*0];


// Stage5 Index1
wire [WORD_WIDTH*32*2-1:0] i_lifm_st5_idx1;
wire [WORD_WIDTH*32*2-1:0] o_lifm_st5_idx1;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*32*2-1:0] i_mt_st5_idx1;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*32*2-1:0] o_mt_st5_idx1;
wire [6-1:0] i_dist_st5_idx1;

assign i_lifm_st5_idx1 = { lifm_st5_wi[WORD_WIDTH*128-1:WORD_WIDTH*96], { WORD_WIDTH*32{1'b0} } };
assign i_mt_st5_idx1   = { mt_st5_wi[DIST_WIDTH*MAX_LIFM_RSIZ*128-1:DIST_WIDTH*MAX_LIFM_RSIZ*96], { DIST_WIDTH*MAX_LIFM_RSIZ*32{1'b0} } };
assign i_dist_st5_idx1 = psum[PSUM_WIDTH*96-1:PSUM_WIDTH*95] - psum[PSUM_WIDTH*64-1:PSUM_WIDTH*63];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(64), .NUMEL_LOG(6)
) vs_lifm_st5_idx1 (
    .i_vec(i_lifm_st5_idx1), .stride(i_dist_st5_idx1), .o_vec(o_lifm_st5_idx1)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(64), .NUMEL_LOG(6)
) vs_mt_st5_idx1 (
    .i_vec(i_mt_st5_idx1), .stride(i_dist_st5_idx1), .o_vec(o_mt_st5_idx1)
);

assign lifm_st5_wo[WORD_WIDTH*128-1:WORD_WIDTH*96] = o_lifm_st5_idx1[WORD_WIDTH*64-1:WORD_WIDTH*32];
assign lifm_st5_wo[WORD_WIDTH*96-1:WORD_WIDTH*64] = o_lifm_st5_idx1[WORD_WIDTH*32-1:0] | lifm_st5_wi[WORD_WIDTH*96-1:WORD_WIDTH*64];
assign mt_st5_wo[DIST_WIDTH*MAX_LIFM_RSIZ*128-1:DIST_WIDTH*MAX_LIFM_RSIZ*96] = o_mt_st5_idx1[DIST_WIDTH*MAX_LIFM_RSIZ*64-1:DIST_WIDTH*MAX_LIFM_RSIZ*32];
assign mt_st5_wo[DIST_WIDTH*MAX_LIFM_RSIZ*96-1:DIST_WIDTH*MAX_LIFM_RSIZ*64] = o_mt_st5_idx1[DIST_WIDTH*MAX_LIFM_RSIZ*32-1:0] | mt_st5_wi[DIST_WIDTH*MAX_LIFM_RSIZ*96-1:DIST_WIDTH*MAX_LIFM_RSIZ*64];



// Stage6
wire [128*WORD_WIDTH-1:0] lifm_st6_wi;  // stage input for LIFM
wire [128*WORD_WIDTH-1:0] lifm_st6_wo;  // stage output of LIFM
wire [128*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_st6_wi;  // stage input for MT
wire [128*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_st6_wo;  // stage output of MT

assign lifm_st6_wi = lifm_st5_wo;
assign mt_st6_wi = mt_st5_wo;

// Stage6 Index0
wire [WORD_WIDTH*64*2-1:0] i_lifm_st6_idx0;
wire [WORD_WIDTH*64*2-1:0] o_lifm_st6_idx0;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*64*2-1:0] i_mt_st6_idx0;
wire [DIST_WIDTH*MAX_LIFM_RSIZ*64*2-1:0] o_mt_st6_idx0;
wire [7-1:0] i_dist_st6_idx0;

assign i_lifm_st6_idx0 = { lifm_st6_wi[WORD_WIDTH*128-1:WORD_WIDTH*64], { WORD_WIDTH*64{1'b0} } };
assign i_mt_st6_idx0   = { mt_st6_wi[DIST_WIDTH*MAX_LIFM_RSIZ*128-1:DIST_WIDTH*MAX_LIFM_RSIZ*64], { DIST_WIDTH*MAX_LIFM_RSIZ*64{1'b0} } };
assign i_dist_st6_idx0 = psum[PSUM_WIDTH*64-1:PSUM_WIDTH*63];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(128), .NUMEL_LOG(7)
) vs_lifm_st6_idx0 (
    .i_vec(i_lifm_st6_idx0), .stride(i_dist_st6_idx0), .o_vec(o_lifm_st6_idx0)
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL(128), .NUMEL_LOG(7)
) vs_mt_st6_idx0 (
    .i_vec(i_mt_st6_idx0), .stride(i_dist_st6_idx0), .o_vec(o_mt_st6_idx0)
);

assign lifm_st6_wo[WORD_WIDTH*128-1:WORD_WIDTH*64] = o_lifm_st6_idx0[WORD_WIDTH*128-1:WORD_WIDTH*64];
assign lifm_st6_wo[WORD_WIDTH*64-1:WORD_WIDTH*0] = o_lifm_st6_idx0[WORD_WIDTH*64-1:0] | lifm_st6_wi[WORD_WIDTH*64-1:WORD_WIDTH*0];
assign mt_st6_wo[DIST_WIDTH*MAX_LIFM_RSIZ*128-1:DIST_WIDTH*MAX_LIFM_RSIZ*64] = o_mt_st6_idx0[DIST_WIDTH*MAX_LIFM_RSIZ*128-1:DIST_WIDTH*MAX_LIFM_RSIZ*64];
assign mt_st6_wo[DIST_WIDTH*MAX_LIFM_RSIZ*64-1:DIST_WIDTH*MAX_LIFM_RSIZ*0] = o_mt_st6_idx0[DIST_WIDTH*MAX_LIFM_RSIZ*64-1:0] | mt_st6_wi[DIST_WIDTH*MAX_LIFM_RSIZ*64-1:DIST_WIDTH*MAX_LIFM_RSIZ*0];


assign lifm_comp = lifm_st6_wo;
assign mt_comp = mt_st6_wo;

endmodule


module VShifter #(
    parameter WORD_WIDTH = 8,
    parameter NUMEL      = 128,
    parameter NUMEL_LOG  = 7
) (
    input [WORD_WIDTH*NUMEL-1:0] i_vec,
    input [NUMEL_LOG-1:0]        stride,

    output [WORD_WIDTH*NUMEL-1:0] o_vec
);

wire [NUMEL-1:0] i_bp [0:WORD_WIDTH];  // input bitplanes
wire [NUMEL-1:0] o_bp [0:WORD_WIDTH];  // output bitplanes

genvar bp_iter;  // bitplane iterator
genvar el_iter;  // element iterator
generate
    for (bp_iter = 0; bp_iter < WORD_WIDTH; bp_iter = bp_iter+1) begin
        for (el_iter = 0; el_iter < NUMEL; el_iter = el_iter+1) begin
            assign i_bp[bp_iter][el_iter] = i_vec[el_iter*WORD_WIDTH+bp_iter];
            assign o_vec[el_iter*WORD_WIDTH+bp_iter] = o_bp[bp_iter][el_iter];
        end

        assign o_bp[bp_iter] = i_bp[bp_iter] >> stride;
    end
endgenerate

// assign o_vec = i_vec >> (stride * WORD_WIDTH);
    
endmodule