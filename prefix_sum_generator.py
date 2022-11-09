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
    input clk,
    input reset_n,
    input [127:0] mask,

    output [1023:0] psum
);

reg [1023:0] psum_reg;
wire [1023:0] psum_wire;

assign psum = psum_reg;

''')

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
    vgen.register_line(code=f"assign psum_wire[{out_iter*8+7}:{out_iter*8}] = st7[{out_iter}];")

vgen.register_line(code='''

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        psum_reg <= 0;
    end else begin
        psum_reg <= psum_wire;
    end
end

endmodule''')


if __name__ == '__main__':
    vgen.compile(save_log=False, remove_output=True)
    vgen.print_result()