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
);''')


for stage in range(7):
    csize = 2 ** stage
    vgen.register_line(f'''

// Stage{stage}
wire [128*WORD_WIDTH-1:0] lifm_st{stage}_wi;  // stage input for LIFM
wire [128*WORD_WIDTH-1:0] lifm_st{stage}_wo;  // stage output of LIFM
wire [128*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_st{stage}_wi;  // stage input for MT
wire [128*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_st{stage}_wo;  // stage output of MT

assign lifm_st{stage}_wi = {'lifm_line' if stage == 0 else f'lifm_st{stage-1}_wo'};
assign mt_st{stage}_wi = {'mt_line' if stage == 0 else f'mt_st{stage-1}_wo'};''')

    for cidx in range(0, 128, csize):
        if (cidx // csize) % 2 == 1:
            sidx = cidx//csize//2

            # csize: size of a chunk (2^stage)
            # cidx:  index of shifter input chunk (first element of a chunk)
            # sidx:  index of barrel shifter
            #
            # shifter input chunk: arr[WIDTH*{cidx+csize}-1:WIDTH*{cidx}]
            # shifter prev  chunk: arr[WIDTH*{cidx}-1:WIDTH*{cidx-csize}]
            # shifter pprev chunk: arr[WIDTH*{cidx-csize}-1:WIDTH*{cidx-(2*csize)}]
            #
            # stride: psum[PSUM_WIDTH*{cidx}-1:PSUM_WIDTH*{cidx-1}] - psum[PSUM_WIDTH*{cidx-csize}-1:PSUM_WIDTH*{cidx-csize-1}]

            vgen.register_line(f'''
// Stage{stage} Index{sidx}
wire [WORD_WIDTH*{csize}*2-1:0] i_lifm_st{stage}_idx{sidx};
wire [WORD_WIDTH*{csize}*2-1:0] o_lifm_st{stage}_idx{sidx};
wire [DIST_WIDTH*MAX_LIFM_RSIZ*{csize}*2-1:0] i_mt_st{stage}_idx{sidx};
wire [DIST_WIDTH*MAX_LIFM_RSIZ*{csize}*2-1:0] o_mt_st{stage}_idx{sidx};
wire [{math.ceil(math.log2(csize*2))}-1:0] i_dist_st{stage}_idx{sidx};

assign i_lifm_st{stage}_idx{sidx} = {{ lifm_st{stage}_wi[WORD_WIDTH*{cidx+csize}-1:WORD_WIDTH*{cidx}], {{ WORD_WIDTH*{csize}{{1'b0}} }} }};
assign i_mt_st{stage}_idx{sidx}   = {{ mt_st{stage}_wi[DIST_WIDTH*MAX_LIFM_RSIZ*{cidx+csize}-1:DIST_WIDTH*MAX_LIFM_RSIZ*{cidx}], {{ DIST_WIDTH*MAX_LIFM_RSIZ*{csize}{{1'b0}} }} }};
assign i_dist_st{stage}_idx{sidx} = { f"psum[PSUM_WIDTH*{cidx}-1:PSUM_WIDTH*{cidx-1}]" if sidx == 0 else f"psum[PSUM_WIDTH*{cidx}-1:PSUM_WIDTH*{cidx-1}] - psum[PSUM_WIDTH*{cidx-csize}-1:PSUM_WIDTH*{cidx-csize-1}]" };

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL({csize*2}), .NUMEL_LOG({math.ceil(math.log2(csize*2))})
) vs_lifm_st{stage}_idx{sidx} (
    .i_vec(i_lifm_st{stage}_idx{sidx}), .stride(i_dist_st{stage}_idx{sidx}), .o_vec(o_lifm_st{stage}_idx{sidx})
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL({csize*2}), .NUMEL_LOG({math.ceil(math.log2(csize*2))})
) vs_mt_st{stage}_idx{sidx} (
    .i_vec(i_mt_st{stage}_idx{sidx}), .stride(i_dist_st{stage}_idx{sidx}), .o_vec(o_mt_st{stage}_idx{sidx})
);

assign lifm_st{stage}_wo[WORD_WIDTH*{cidx+csize}-1:WORD_WIDTH*{cidx}] = o_lifm_st{stage}_idx{sidx}[WORD_WIDTH*{2*csize}-1:WORD_WIDTH*{csize}];
assign lifm_st{stage}_wo[WORD_WIDTH*{cidx}-1:WORD_WIDTH*{cidx-csize}] = o_lifm_st{stage}_idx{sidx}[WORD_WIDTH*{csize}-1:0] | lifm_st{stage}_wi[WORD_WIDTH*{cidx}-1:WORD_WIDTH*{cidx-csize}];
assign mt_st{stage}_wo[DIST_WIDTH*MAX_LIFM_RSIZ*{cidx+csize}-1:DIST_WIDTH*MAX_LIFM_RSIZ*{cidx}] = o_mt_st{stage}_idx{sidx}[DIST_WIDTH*MAX_LIFM_RSIZ*{2*csize}-1:DIST_WIDTH*MAX_LIFM_RSIZ*{csize}];
assign mt_st{stage}_wo[DIST_WIDTH*MAX_LIFM_RSIZ*{cidx}-1:DIST_WIDTH*MAX_LIFM_RSIZ*{cidx-csize}] = o_mt_st{stage}_idx{sidx}[DIST_WIDTH*MAX_LIFM_RSIZ*{csize}-1:0] | mt_st{stage}_wi[DIST_WIDTH*MAX_LIFM_RSIZ*{cidx}-1:DIST_WIDTH*MAX_LIFM_RSIZ*{cidx-csize}];
''')
            

vgen.register_line(code=f'''
assign lifm_comp = lifm_st6_wo;
assign mt_comp = mt_st6_wo;''')


# Tail
vgen.register_line(code='''
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