import os

from utils.verilog_generator import VerilogGenerator


# Parameter
WORD_WIDTH = 16

dirname = os.curdir
filename = f'comb_divider{WORD_WIDTH}'

vgen = VerilogGenerator(dirname=dirname, filename=filename)

# Header
vgen.register_line(code=f'''
module CombDivider{WORD_WIDTH} (
    input [{WORD_WIDTH-1}:0] lop,
    input [{WORD_WIDTH-1}:0] rop,

    output [{WORD_WIDTH-1}:0] quot,
    output [{WORD_WIDTH-1}:0] mod
);''')

for stage in range(WORD_WIDTH):
    vgen.register_line(code=f'''
// Stage {stage}
wire [{WORD_WIDTH-1}:0] interm_st{stage};
wire [{WORD_WIDTH-1}:0] mod_st{stage};
wire [{WORD_WIDTH-1}:0] lop_st{stage};
wire [{WORD_WIDTH-1}:0] quot_st{stage};

assign interm_st{stage} = {f"{{ mod_st{stage-1}[{WORD_WIDTH-2}:0], lop_st{stage-1}[{WORD_WIDTH-1}] }}" if stage != 0 else f"{{ {WORD_WIDTH-2}'b0, lop[{WORD_WIDTH-1}] }}"};
assign lop_st{stage} = {f"{{ lop_st{stage-1}[{WORD_WIDTH-2}:0], 1'b0 }}" if stage != 0 else f"{{ lop[{WORD_WIDTH-2}:0], 1'b0 }}"};
assign mod_st{stage} = interm_st{stage} >= rop ? (interm_st{stage} - rop) : interm_st{stage};
assign quot_st{stage} = {{{f"quot_st{stage-1}[{WORD_WIDTH-2}:0]" if stage != 0 else f"{WORD_WIDTH-2}'b0"}, interm_st{stage} >= rop ? 1'b1 : 1'b0}};''')

# Tail
vgen.register_line(code=f'''
assign quot = quot_st{WORD_WIDTH-1};
assign mod = mod_st{WORD_WIDTH-1};

endmodule;''')


if __name__ == '__main__':
    vgen.compile(save_log=False, remove_output=True)
    vgen.print_result()