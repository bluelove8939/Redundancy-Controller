import os

from utils.verilog_generator import VerilogGenerator


dirname = os.curdir
filename = 'prefix_sum'

vgen = VerilogGenerator(dirname=dirname, filename=filename)

# Parameter
PSUM_WIDTH = 8

# Header
vgen.register_line(code='''
`include "nodeadder.v"

module LFPrefixSum128 (  // Ladner-Fischer
    input [127:0] mask,

    output [1023:0] psum
);''')

# Generate shifters
for stage in range(1, 8, 1):
    vgen.register_line(code=f"""
// Stage {stage}
wire [{stage}:0] st{stage} [0:127];\n""")

    prev_wire = f'st{stage-1}' if stage != 1 else 'mask'

    for st_iter in range(128):
        if ((st_iter // (2 ** (stage-1))) % 2 != 0):
            vgen.register_line(code=f"NodeAdder #(.WORD_WIDTH({stage})) st{stage}_pa{st_iter} (.a({prev_wire}[{st_iter - 1 - (st_iter % (2 ** (stage-1)))}]), .b({prev_wire}[{st_iter}]), .y(st{stage}[{st_iter}]));")
        else:
            vgen.register_line(code=f"assign st{stage}[{st_iter}]  = {{1'b0, {prev_wire}[{st_iter}]}};")
    
    vgen.register_line(code='\n')

# Generate output signal
vgen.register_line(code='// Output link')
for out_iter in range(128):
    vgen.register_line(code=f"assign psum[{out_iter*8+7}:{out_iter*8}] = st7[{out_iter}];")

vgen.register_line(code='\nendmodule')


if __name__ == '__main__':
    vgen.compile(remove_tmpfile=True)
    vgen.print_result()