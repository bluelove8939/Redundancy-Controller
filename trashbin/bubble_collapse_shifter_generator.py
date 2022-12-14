import os
import math

from utils.verilog_generator import VerilogGenerator


dirname = os.curdir
filename = 'bubble_collapse_shifter'

vgen = VerilogGenerator(dirname=dirname, filename=filename)

# Parameter
PSUM_WIDTH = 7

# Header
vgen.register_line(code='''module BCShifter128 #(  // Bubble-Collapsing Shifter
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

// Generate array connected with input and output ports
wire [WORD_WIDTH-1:0]               lifm_line_arr [0:127];
wire [DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_line_arr   [0:127];

wire [WORD_WIDTH-1:0]               lifm_comp_arr [0:127];
wire [DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_comp_arr   [0:127];

genvar line_idx;
generate
    for (line_idx = 0; line_idx < 128; line_idx = line_idx+1) begin
        assign lifm_line_arr[line_idx] = lifm_line[WORD_WIDTH*line_idx+:WORD_WIDTH];
        assign mt_line_arr[line_idx] = mt_line[DIST_WIDTH*MAX_LIFM_RSIZ*line_idx+:DIST_WIDTH*MAX_LIFM_RSIZ];
        assign lifm_comp[WORD_WIDTH*line_idx+:WORD_WIDTH] = lifm_comp_arr[line_idx];
        assign mt_comp[DIST_WIDTH*MAX_LIFM_RSIZ*line_idx+:DIST_WIDTH*MAX_LIFM_RSIZ] = mt_comp_arr[line_idx];
    end
endgenerate

wire [WORD_WIDTH-1:0] o_lifm_l1;
wire [DIST_WIDTH*MAX_LIFM_RSIZ-1:0] o_mt_l1;

assign o_lifm_l1 = lifm_line[WORD_WIDTH-1:0];
assign o_mt_l1 = mt_line[DIST_WIDTH*MAX_LIFM_RSIZ-1:0];
''')

# Generate shifters
for numel in range(2, 129, 1):
    vgen.register_line(code=f"""
// Shifter {numel}
wire [{numel}*WORD_WIDTH-1:0] i_lifm_l{numel};
wire [{numel}*WORD_WIDTH-1:0] o_lifm_l{numel};
wire [{numel}*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] i_mt_l{numel};
wire [{numel}*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] o_mt_l{numel};
wire [{math.ceil(math.log2(numel))-1}:0] stride_l{numel};

assign i_lifm_l{numel} = {{lifm_line_arr[{numel-1}], {{{numel-1}*WORD_WIDTH{{1'b0}}}}}};
assign i_mt_l{numel} = {{mt_line_arr[{numel-1}], {{{numel-1}*DIST_WIDTH*MAX_LIFM_RSIZ{{1'b0}}}}}};
assign stride_l{numel} = psum[{(numel-1)*PSUM_WIDTH+math.ceil(math.log2(numel))-1}:{(numel-1)*PSUM_WIDTH}];

VShifter #(
    .WORD_WIDTH(WORD_WIDTH), .NUMEL({numel}), .NUMEL_LOG({math.ceil(math.log2(numel))})
) vs_lifm_{numel} (
    .i_vec(i_lifm_l{numel}), .stride(stride_l{numel}), .o_vec(o_lifm_l{numel})
);

VShifter #(
    .WORD_WIDTH(DIST_WIDTH*MAX_LIFM_RSIZ), .NUMEL({numel}), .NUMEL_LOG({math.ceil(math.log2(numel))})
) vs_mt_{numel} (
    .i_vec(i_mt_l{numel}), .stride(stride_l{numel}), .o_vec(o_mt_l{numel})
);""")

# Generate output signal
for idx in range(128):
    vgen.register_line(code=f"""
assign lifm_comp_arr[{idx}] = {' | '.join([f'o_lifm_l{numel}[{idx}*WORD_WIDTH+:WORD_WIDTH]' for numel in range(max(idx+1, 1), 129, 1)])};
assign mt_comp_arr[{idx}]   = {' | '.join([f'o_mt_l{numel}[{idx}*DIST_WIDTH*MAX_LIFM_RSIZ+:DIST_WIDTH*MAX_LIFM_RSIZ]' for numel in range(max(idx+1, 1), 129, 1)])};""")

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