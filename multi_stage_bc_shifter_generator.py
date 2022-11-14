import os
import math

from utils.verilog_generator import VerilogGenerator


dirname = os.curdir
filename = 'multi_stage_bc_shifter'

vgen = VerilogGenerator(dirname=dirname, filename=filename)

# Parameter
PSUM_WIDTH = 7

# Header
vgen.register_line(code='''module MSBCShifter128 #(  // Bubble-Collapsing Shifter
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

''')


for stage in range(7):
    csize = 2 ** stage
    vgen.register_line(f'''
// Stage{stage}
wire [128*WORD_WIDTH-1:0] lifm_st{stage}_wi;  // stage input for LIFM
wire [128*WORD_WIDTH-1:0] lifm_st{stage}_wo;  // stage output of LIFM
wire [128*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_st{stage}_wi;  // stage input for MT
wire [128*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_st{stage}_wo;  // stage output of MT
wire [PSUM_WIDTH-1:0] dist_st{stage}_wi;  // stage input for distance

assign lifm_st{stage}_wi = {'lifm_line' if stage == 0 else f'lifm_st{stage-1}_wo'}

''')

    for cidx in range(0, 128, csize):
        if (cidx / csize) % 2 == 1:
            vgen.register_line(f'''
// Stage{stage}  Index{cidx//csize}
wire [WORD_WIDTH*{csize}-1:0]               i_lifm_st{stage}_idx{cidx//csize};
wire [DIST_WIDTH*MAX_LIFM_RSIZ*{csize}-1:0] i_mt_st{stage}_idx{cidx//csize};
wire [WORD_WIDTH*{csize}-1:0]               o_lifm_st{stage}_idx{cidx//csize};
wire [DIST_WIDTH*MAX_LIFM_RSIZ*{csize}-1:0] o_mt_st{stage}_idx{cidx//csize};

wire [PSUM_WIDTH-1:0] i_dist_st{stage}_idx{cidx//csize} [PSUM_WIDTH*{cidx+1}-1:PSUM_WIDTH*{cidx}];
wire [PSUM_WIDTH-1:0] o_dist_st{stage}_idx{cidx//csize} [PSUM_WIDTH*{cidx+1}-1:PSUM_WIDTH*{cidx}];

assign i_lifm_st{stage}_idx{cidx//csize} = lifm_st{stage}_wi;
assign i_mt_st{stage}_idx{cidx//csize}   = mt_st{stage}_wi;
assign i_dist_st{stage}_idx{cidx//csize} = {f'o_dist_st{stage}_idx{(cidx//csize)*2+1}'};

ShifterStageLIFM #(
    .WORD_WIDTH(WORD_WIDTH), .PSUM_WIDTH(PSUM_WIDTH), .NUMEL({csize}), .NUMEL_LOG({math.ceil(math.log2(csize*2))}), .MAX_DIST({2 ** stage})
) ssu_lifm_st{stage}_idx{cidx} (
    .i_vec(i_lifm_st{stage}_idx{cidx//csize}), .i_dist(i_dist_st{stage}_idx{cidx//csize}), .o_vec(o_mt_st{stage}_idx{cidx//csize})
)
''')


# Tail
vgen.register_line(code='''
endmodule


module ShifterStageLIFM #(
    parameter WORD_WIDTH = 8,
    parameter PSUM_WIDTH = 7,
    parameter NUMEL      = 128,
    parameter NUMEL_LOG  = 7,
    parameter MAX_DIST   = 1
) (
    input [WORD_WIDTH*NUMEL-1:0] i_vec,
    input [PSUM_WIDTH-1:0]       i_dist,  // input distance

    output [WORD_WIDTH*NUMEL*2-1:0] o_vec,
);

wire [PSUM_WIDTH-1:0] stride;
assign stride = i_dist >= MAX_DIST ? MAX_DIST : i_dist;

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(NUMEL*2), .NUMEL_LOG(NUMEL_LOG)
) vs_unit (
    .i_vec({{i_vec, {{NUMEL{{1'b0}}}}}}), .stride(stride[NUMEL_LOG-1:0]), .o_vec(o_vec)
);
    
endmodule


module ShifterStageMT #(
    parameter WORD_WIDTH = 8,
    parameter PSUM_WIDTH = 7,
    parameter NUMEL      = 128,
    parameter NUMEL_LOG  = 7,
    parameter MAX_DIST   = 1
) (
    input [WORD_WIDTH*NUMEL-1:0] i_vec,
    input [PSUM_WIDTH-1:0]       i_dist,  // input distance

    output [WORD_WIDTH*NUMEL*2-1:0] o_vec,
    output [PSUM_WIDTH-1:0]         o_dist  // remaining distance
);

wire [PSUM_WIDTH-1:0] stride;
assign stride = i_dist >= MAX_DIST ? MAX_DIST : i_dist;
assign o_dist = i_dist - stride;

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL(NUMEL*2), .NUMEL_LOG(NUMEL_LOG)
) vs_unit (
    .i_vec({{i_vec, {{NUMEL{{1'b0}}}}}}), .stride(stride[NUMEL_LOG-1:0]), .o_vec(o_vec)
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
    
endmodule''')


if __name__ == '__main__':
    vgen.compile(save_log=False, remove_output=True)
    vgen.print_result()