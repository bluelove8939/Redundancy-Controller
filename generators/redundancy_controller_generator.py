import os

from utils.verilog_generator import VerilogGenerator


# Parameter
MAX_C_SIZE = 16

dirname = os.curdir
filename = f'redundancy_controller'

vgen = VerilogGenerator(dirname=dirname, filename=filename)

vgen.register_line(code=f'''
`include "distance_calculator.v"
`include "muxes.v"


module RedundancyController #(
    parameter WORD_WIDTH = 8,    // bitwidth of a word (fixed to 8bit)
    parameter DIST_WIDTH = 4,    // bitwidth of distances
    parameter MAX_R_SIZE = 4,    // size of each row of lifm and mapping table
    parameter MAX_C_SIZE = 16,   // size of each column of lifm and mapping table
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
reg [WORD_WIDTH*MAX_C_SIZE-1:0] lifm_comp_reg;
reg [MPTE_WIDTH*MAX_C_SIZE-1:0] mpte_comp_reg;

assign lifm_comp = lifm_comp_reg;
assign mpte_comp = mpte_comp_reg;

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

### Stage 1: Status flags
vgen.register_line(code=f'''
// Generating MPTE Stage 1: Status flags
wire [MAX_C_SIZE-1:0] oor_flag,       // out of range flag
                      red_flag_prev,  // redundancy flag for previous column (0)
                      red_flag_curr;  // redundancy flag for current column (1)
wire [DIST_WIDTH-1:0] cpd_index  [0:MAX_C_SIZE-1],  // copy index
                      rev_index  [0:MAX_C_SIZE-1];  // reversed copy index
wire [WORD_WIDTH-1:0] red_values [0:MAX_C_SIZE-1];  // redundant values 
''')

for citer in range(MAX_C_SIZE):
    vgen.register_line(code=f'''
assign oor_flag[{citer}]      = (valid && (dr <= {citer})) ? 1'b1 : 1'b0;
assign red_flag_prev[{citer}] = (lifm_buff[0][WORD_WIDTH*{citer+1}-1:WORD_WIDTH*{citer}] == red_values[{citer}])   ? 1'b1 : 1'b0;
assign red_flag_curr[{citer}] = (lifm_buff[1][WORD_WIDTH*{citer+1}-1:WORD_WIDTH*{citer}] == lifm_buff[0][WORD_WIDTH*rev_index[{citer}]+:WORD_WIDTH]) ? 1'b1 : 1'b0;
assign cpd_index[{citer}] = ({citer} <= dr) ? ({citer} - dr) : 0;
assign rev_index[{citer}] = ({citer} < (MAX_C_SIZE - dr)) ? ({citer} + dr) : 0;''')

    if citer > 8:
        vgen.register_line(code=f'''
MUX16to1 #(
    .WORD_WIDTH(WORD_WIDTH)
) mux_unit_redundant_16to1_lv{citer} (
    .in_w0(lifm_buff[0][WORD_WIDTH*1-1:WORD_WIDTH*0]), .in_w1(lifm_buff[0][WORD_WIDTH*2-1:WORD_WIDTH*1]), 
    .in_w2(lifm_buff[0][WORD_WIDTH*3-1:WORD_WIDTH*2]), .in_w3(lifm_buff[0][WORD_WIDTH*4-1:WORD_WIDTH*3]), 
    .in_w4(lifm_buff[0][WORD_WIDTH*5-1:WORD_WIDTH*4]), .in_w5(lifm_buff[0][WORD_WIDTH*6-1:WORD_WIDTH*5]), 
    .in_w6(lifm_buff[0][WORD_WIDTH*7-1:WORD_WIDTH*6]), .in_w7(lifm_buff[0][WORD_WIDTH*8-1:WORD_WIDTH*7]), 
    .in_w8(lifm_buff[0][WORD_WIDTH*9-1:WORD_WIDTH*8]), .in_w9(lifm_buff[0][WORD_WIDTH*10-1:WORD_WIDTH*9]), 
    .in_w10(lifm_buff[0][WORD_WIDTH*11-1:WORD_WIDTH*10]), .in_w11(lifm_buff[0][WORD_WIDTH*12-1:WORD_WIDTH*11]), 
    .in_w12(lifm_buff[0][WORD_WIDTH*13-1:WORD_WIDTH*12]), .in_w13(lifm_buff[0][WORD_WIDTH*14-1:WORD_WIDTH*13]), 
    .in_w14(lifm_buff[0][WORD_WIDTH*15-1:WORD_WIDTH*14]), .in_w15(lifm_buff[0][WORD_WIDTH*16-1:WORD_WIDTH*15]),

    .sel(cpd_index[{citer}][3:0]),

    .out_w(red_values[{citer}])
);''')
    elif citer > 4:
        vgen.register_line(code=f'''
MUX8to1 #(
    .WORD_WIDTH(WORD_WIDTH)
) mux_unit_redundant_8to1_lv{citer} (
    .in_w0(lifm_buff[0][WORD_WIDTH*9-1:WORD_WIDTH*8]), .in_w1(lifm_buff[0][WORD_WIDTH*10-1:WORD_WIDTH*9]), 
    .in_w2(lifm_buff[0][WORD_WIDTH*11-1:WORD_WIDTH*10]), .in_w3(lifm_buff[0][WORD_WIDTH*12-1:WORD_WIDTH*11]), 
    .in_w4(lifm_buff[0][WORD_WIDTH*13-1:WORD_WIDTH*12]), .in_w5(lifm_buff[0][WORD_WIDTH*14-1:WORD_WIDTH*13]), 
    .in_w6(lifm_buff[0][WORD_WIDTH*15-1:WORD_WIDTH*14]), .in_w7(lifm_buff[0][WORD_WIDTH*16-1:WORD_WIDTH*15]),

    .sel(cpd_index[{citer}][2:0]),

    .out_w(red_values[{citer}])
);''')

    elif citer > 2:
        vgen.register_line(code=f'''
MUX4to1 #(
    .WORD_WIDTH(WORD_WIDTH)
) mux_unit_redundant_4to1_lv{citer} (
    .in_w0(lifm_buff[0][WORD_WIDTH*13-1:WORD_WIDTH*12]), .in_w1(lifm_buff[0][WORD_WIDTH*14-1:WORD_WIDTH*13]), 
    .in_w2(lifm_buff[0][WORD_WIDTH*15-1:WORD_WIDTH*14]), .in_w3(lifm_buff[0][WORD_WIDTH*16-1:WORD_WIDTH*15]),

    .sel(cpd_index[{citer}][1:0]),

    .out_w(red_values[{citer}])
);''')

    elif citer > 1:
        vgen.register_line(code=f'''
MUX2to1 #(
    .WORD_WIDTH(WORD_WIDTH)
) mux_unit_redundant_2to1_lv{citer} (
    .in_w0(lifm_buff[0][WORD_WIDTH*15-1:WORD_WIDTH*14]), .in_w1(lifm_buff[0][WORD_WIDTH*16-1:WORD_WIDTH*15]),
    .sel(cpd_index[{citer}][0]),
    .out_w(red_values[{citer}])
);''')

    else:
        vgen.register_line(code=f'''
assign red_values[{citer}] = lifm_buff[0][WORD_WIDTH*16-1:WORD_WIDTH*15];''')


### Stage 2: Routing copied MPTE with MUXes left shift one bit of copied MPTE
vgen.register_line(code=f'''
// Generating MPTE Stage 2: Routing copied MPTE with MUXes left shift one bit of copied MPTE
wire [MPTE_WIDTH-1:0] mpte_copied_curr  [0:MAX_C_SIZE-1],  // copied column
                      mpte_shifted_curr [0:MAX_C_SIZE-1];  // shifted column
''')

for citer in range(MAX_C_SIZE):
    if citer > 8:
        vgen.register_line(code=f'''
MUX16to1 #(
    .WORD_WIDTH(MPTE_WIDTH)
) mux_unit_copy_16to1_lv{citer} (
    .in_w0(mpte_buff[0][MPTE_WIDTH*1-1:MPTE_WIDTH*0]), .in_w1(mpte_buff[0][MPTE_WIDTH*2-1:MPTE_WIDTH*1]), 
    .in_w2(mpte_buff[0][MPTE_WIDTH*3-1:MPTE_WIDTH*2]), .in_w3(mpte_buff[0][MPTE_WIDTH*4-1:MPTE_WIDTH*3]), 
    .in_w4(mpte_buff[0][MPTE_WIDTH*5-1:MPTE_WIDTH*4]), .in_w5(mpte_buff[0][MPTE_WIDTH*6-1:MPTE_WIDTH*5]), 
    .in_w6(mpte_buff[0][MPTE_WIDTH*7-1:MPTE_WIDTH*6]), .in_w7(mpte_buff[0][MPTE_WIDTH*8-1:MPTE_WIDTH*7]), 
    .in_w8(mpte_buff[0][MPTE_WIDTH*9-1:MPTE_WIDTH*8]), .in_w9(mpte_buff[0][MPTE_WIDTH*10-1:MPTE_WIDTH*9]), 
    .in_w10(mpte_buff[0][MPTE_WIDTH*11-1:MPTE_WIDTH*10]), .in_w11(mpte_buff[0][MPTE_WIDTH*12-1:MPTE_WIDTH*11]), 
    .in_w12(mpte_buff[0][MPTE_WIDTH*13-1:MPTE_WIDTH*12]), .in_w13(mpte_buff[0][MPTE_WIDTH*14-1:MPTE_WIDTH*13]), 
    .in_w14(mpte_buff[0][MPTE_WIDTH*15-1:MPTE_WIDTH*14]), .in_w15(mpte_buff[0][MPTE_WIDTH*16-1:MPTE_WIDTH*15]),

    .sel(cpd_index[{citer}][3:0]),

    .out_w(mpte_copied_curr[{citer}])
);''')
    elif citer > 4:
        vgen.register_line(code=f'''
MUX8to1 #(
    .WORD_WIDTH(MPTE_WIDTH)
) mux_unit_copy_8to1_lv{citer} (
    .in_w0(mpte_buff[0][MPTE_WIDTH*9-1:MPTE_WIDTH*8]), .in_w1(mpte_buff[0][MPTE_WIDTH*10-1:MPTE_WIDTH*9]), 
    .in_w2(mpte_buff[0][MPTE_WIDTH*11-1:MPTE_WIDTH*10]), .in_w3(mpte_buff[0][MPTE_WIDTH*12-1:MPTE_WIDTH*11]), 
    .in_w4(mpte_buff[0][MPTE_WIDTH*13-1:MPTE_WIDTH*12]), .in_w5(mpte_buff[0][MPTE_WIDTH*14-1:MPTE_WIDTH*13]), 
    .in_w6(mpte_buff[0][MPTE_WIDTH*15-1:MPTE_WIDTH*14]), .in_w7(mpte_buff[0][MPTE_WIDTH*16-1:MPTE_WIDTH*15]),

    .sel(cpd_index[{citer}][2:0]),

    .out_w(mpte_copied_curr[{citer}])
);''')

    elif citer > 2:
        vgen.register_line(code=f'''
MUX4to1 #(
    .WORD_WIDTH(MPTE_WIDTH)
) mux_unit_copy_4to1_lv{citer} (
    .in_w0(mpte_buff[0][MPTE_WIDTH*13-1:MPTE_WIDTH*12]), .in_w1(mpte_buff[0][MPTE_WIDTH*14-1:MPTE_WIDTH*13]), 
    .in_w2(mpte_buff[0][MPTE_WIDTH*15-1:MPTE_WIDTH*14]), .in_w3(mpte_buff[0][MPTE_WIDTH*16-1:MPTE_WIDTH*15]),

    .sel(cpd_index[{citer}][1:0]),

    .out_w(mpte_copied_curr[{citer}])
);''')

    elif citer > 1:
        vgen.register_line(code=f'''
MUX2to1 #(
    .WORD_WIDTH(MPTE_WIDTH)
) mux_unit_copy_2to1_lv{citer} (
    .in_w0(mpte_buff[0][MPTE_WIDTH*15-1:MPTE_WIDTH*14]), .in_w1(mpte_buff[0][MPTE_WIDTH*16-1:MPTE_WIDTH*15]),
    .sel(cpd_index[{citer}][0]),
    .out_w(mpte_copied_curr[{citer}])
);''')

    else:
        vgen.register_line(code=f'''
assign mpte_copied_curr[{citer}] = mpte_buff[0][MPTE_WIDTH*16-1:MPTE_WIDTH*15];''')


### Stage 3: Set updated values of MPTE
vgen.register_line(code=f'''
// Generating MPTE Stage 3: Set updated values of MPTE
wire [MPTE_WIDTH*MAX_C_SIZE-1:0] mpte_updated [0:1];''')

for citer in range(MAX_C_SIZE):
    vgen.register_line(code=f'''
assign mpte_updated[0][MPTE_WIDTH*{citer+1}-1:MPTE_WIDTH*{citer}] = red_flag_prev[{citer}] ? 0 : {{ mpte_buff[0][MPTE_WIDTH*{citer+1}-DIST_WIDTH-1:MPTE_WIDTH*{citer}], 7'd{citer} }};
assign mpte_updated[1][MPTE_WIDTH*{citer+1}-1:MPTE_WIDTH*{citer}] = red_flag_curr[{citer}] ? {{ mpte_copied_curr[{citer}][MPTE_WIDTH-1:DIST_WIDTH], 7'd{citer} }} : mpte_buff[1][MPTE_WIDTH*{citer+1}-1:MPTE_WIDTH*{citer}];''')

vgen.register_line(code=f'''

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        idx1 <= 0;
        idx2 <= 0;
        lifm_buff[0] <= 0;
        lifm_buff[1] <= 0;
        mpte_buff[0] <= 0;
        mpte_buff[1] <= 0;
    end 

    // Shift mapping table and lifm buffer at falling edge of the clock
    else begin
        {{ idx2, idx1 }} <= {{ idx, idx2 }};
        {{ lifm_buff[1], lifm_buff[0], lifm_comp_reg }} <= {{ lifm_line, lifm_buff[1], lifm_buff[0] }};
        {{ mpte_buff[1], mpte_buff[0], mpte_comp_reg }} <= {{ {{ MPTE_WIDTH*MAX_C_SIZE{{ 1'b0 }} }}, mpte_updated[1], mpte_updated[0] }};
    end 
end

endmodule''')

if __name__ == '__main__':
    vgen.compile(save_log=False, remove_output=True)
    vgen.print_result()