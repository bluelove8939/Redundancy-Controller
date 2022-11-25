`include "muxes.v"
`include "leading_one_detector.v"

module RowCompressor #(
    parameter WORD_WIDTH = 8,
    parameter MAX_R_SIZE = 4,
    parameter R_DIST_WIDTH = 2
) (
    input clk,
    input reset_n,
    input enable_in,
    input enable_out,

    input [WORD_WIDTH*MAX_R_SIZE-1:0] data_in,

    output [WORD_WIDTH-1:0] data_out
);

reg [WORD_WIDTH*MAX_R_SIZE-1:0] data_in_buff;

// Zero mask generation
wire [MAX_R_SIZE-1:0] mask;

genvar riter_gvar;
generate
    for (riter_gvar = 0; riter_gvar < MAX_R_SIZE; riter_gvar = riter_gvar+1) begin
        assign mask[riter_gvar] = (data_in_buff[WORD_WIDTH*riter_gvar+:WORD_WIDTH] == 0) ? 1'b0 : 1'b1;
    end
endgenerate

// LeadingOneDetector
wire [1:0] sel;

LeadingOneDetector4 lod4_unit (.mask(mask), .out_w(sel));

// MUX
wire [WORD_WIDTH-1:0] out_w;

MUX4to1 #(
    .WORD_WIDTH(WORD_WIDTH)
) mux_unit (
    .in_w0(data_in[WORD_WIDTH-1:0]), .in_w1(data_in[WORD_WIDTH*2-1:WORD_WIDTH]),
    .in_w2(data_in[WORD_WIDTH*3-1:WORD_WIDTH*2]), .in_w3(data_in[WORD_WIDTH*4-1:WORD_WIDTH*3]),

    .sel(sel),

    .out_w(out_w)
);

// Output assignment
reg data_out_reg;
assign data_out = data_out_reg;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        data_out_reg <= 0;
        data_in_buff <= 0;
    end else begin
        if (enable_out) begin
            data_out_reg <= out_w;
        end
        if (enable_in) begin
            data_in_buff <= data_in;
        end
    end
end
    
endmodule