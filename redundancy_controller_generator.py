import os

from utils.verilog_generator import VerilogGenerator


dirname = os.curdir
filename = f'redundancy_controller'

vgen = VerilogGenerator(dirname=dirname, filename=filename)

# Header
vgen.register_line(code=f'''
`include "distance_calculator.v"


module RedundancyController #(
    parameter WORD_WIDTH = 8,    // bitwidth of a word (fixed to 8bit)
    parameter DIST_WIDTH = 7,    // bitwidth of distances
    parameter MAX_R_SIZE = 4,    // size of each row of lifm and mapping table
    parameter MAX_C_SIZE = 128,  // size of each column of lifm and mapping table
    parameter MPTE_WIDTH = DIST_WIDTH * MAX_R_SIZE  // width of mapping table entry
) (
    input clk,      // global clock signal (positive-edge triggered)
    input reset_n,  // global asynchronous reset signal (negative triggered)

    input [WORD_WIDTH-1:0] idx,  // index of weight value (lowered filter)
    input [WORD_WIDTH-1:0] ow,   // shapes: output width (OW)
    input [WORD_WIDTH-1:0] fw,   // shapes: filter(kernel) width (FW)
    input [WORD_WIDTH-1:0] st,   // shapes: stride amount (S)

    input [MAX_R_SIZE*WORD_WIDTH-1:0] lifm_line,  // un-processed lifm column

    output [MAX_R_SIZE*WORD_WIDTH-1:0] lifm_comp,  // vector of compressed lifm
    output [MAX_R_SIZE*MPTE_WIDTH-1:0] mpte_comp   // vector mapping table entries
);

// Buffers
reg [WORD_WIDTH-1:0] idx1, idx2;
reg [WORD_WIDTH*MAX_C_SIZE-1:0] lifm_buff [0:1];
reg [MPTE_WIDTH*MAX_C_SIZE-1:0] mpte_buff [0:1];

// Instantiation of distance calculator
wire valid;
wire [DIST_WIDTH-1:0] dr;

DistanceCalculator #(
    .WORD_WIDTH(WORD_WIDTH), .DIST_WIDTH(DIST_WIDTH), .MAX_C_SIZE(MAX_C_SIZE)
) dist_calc (
    .idx1(idx1), .idx2(idx2), 
    .ow(ow), .fw(fw), .st(st),
    .valid(valid), .dr(dr)
);''')


# Logic for Mapping Table Generation
vgen.register_line(code=f'''
// MPTE generation logic
wire [MPTE_WIDTH*MAX_C_SIZE-1:0] mpte_update [0:1];

always @(*) begin''')

for idx in range(128):
    vgen.register_line(code=f'''
    if (valid && (dr <= {idx}))
        mpte_update[1][MPTE_WIDTH*({idx+1}-dr)-1:MPTE_WIDTH*({idx}-dr)]
        mpte_update[0][MPTE_WIDTH*{idx+1}-1:MPTE_WIDTH*{idx}] = {{ MPTE_WIDTH{{ 1'b0 }} }};
    end else begin

    end''')

vgen.register_line(code=f'''
end''')

# Tail
vgen.register_line(code=f'''
// Shifting LIFM and MPTE
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        idx1 <= 0;
        idx2 <= 0;
        lifm_buff[0] <= 0;
        lifm_buff[1] <= 0;
        mpte_buff[0] <= 0;
        mpte_buff[1] <= 0;
    end 
    
    else begin
        {{idx2, idx1}} <= {{idx, idx2}};
        {{lifm_buff[1], lifm_buff[0]}} <= {{lifm_line, lifm_buff[1]}};
        {{mpte_buff[1], mpte_buff[0]}} <= {{mpte_line, mpte_buff[1]}};
    end
end

endmodule''')


if __name__ == '__main__':
    vgen.compile(save_log=False, remove_output=True)
    vgen.print_result()