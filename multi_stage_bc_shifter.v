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



endmodule


module ShifterStage #(
    parameter WORD_WIDTH = 8,
    parameter PSUM_WIDTH = 7,
    parameter NUMEL      = 128,
    parameter NUMEL_LOG  = 7,
    parameter MAX_DIST   = 1
) (
    input [WORD_WIDTH*NUMEL-1:0] i_vec,
    input [PSUM_WIDTH-1:0]       i_dist,  // input distance

    output [WORD_WIDTH*NUMEL-1:0] o_vec,
    output [PSUM_WIDTH-1:0]       o_dist  // remaining distance
);

wire [PSUM_WIDTH-1:0] stride;
assign stride = i_dist >= MAX_DIST ? MAX_DIST : i_dist;

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(NUMEL), .NUMEL_LOG(NUMEL_LOG)
) vs_unit (
    .i_vec(i_vec), .stride(stride[NUMEL_LOG-1:0]), .o_vec(o_vec)
);
    
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