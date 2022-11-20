import os
import math

from utils.verilog_generator import VerilogGenerator


# Parameter
WORD_WIDTH = 8

dirname = os.curdir
filename = f'muxes'

vgen = VerilogGenerator(dirname=dirname, filename=filename)


for sel_width in range(1, 7, 1):
    col_siz = 2 ** sel_width

    vgen.register_line(code=f'''
module MUX{col_siz}to1 #(
    parameter WORD_WIDTH = 8
) (
    input [WORD_WIDTH-1:0] {', '.join([f'in_w{i}' for i in range(col_siz)])},
    input [{sel_width-1}:0] sel,

    output [WORD_WIDTH-1:0] out_w
);

reg [WORD_WIDTH-1:0] out_r;
assign out_w = out_r;

always @({' or '.join([f'in_w{i}' for i in range(col_siz)])} or sel) begin
    case (sel)''')

    for cidx in range(col_siz):
        vgen.register_line(code=f'''        {sel_width}'d{cidx}: out_r <= in_w{cidx};''')

    vgen.register_line(code=f'''        default: out_r <= in_w{cidx};
    endcase
end

endmodule
''')

if __name__ == '__main__':
    vgen.compile(save_log=False, remove_output=True)
    vgen.print_result()