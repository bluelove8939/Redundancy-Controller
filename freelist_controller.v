module FreeListController #(
    parameter WORD_WIDTH = 8,
    parameter ITER_WIDTH = 9,
    parameter DIST_WIDTH = 7,
    parameter STEP_RANGE = 128
) (
    input clk,
    input reset_n,

    input [STEP_RANGE-1:0]            enable_in,
    input [STEP_RANGE*ITER_WIDTH-1:0] it_in,

    output valid,

    output [STEP_RANGE-1:0] full,    // indicates whether this controller is full
    output [ITER_WIDTH-1:0] src_it,  // 
    output [WORD_WIDTH-1:0] src
);

reg [STEP_RANGE-1:0] full_reg;
reg [ITER_WIDTH-1:0] src_it_reg;
reg [WORD_WIDTH-1:0] src_reg;

assign full = full_reg;
assign src_it = src_it_reg;
assign src = src_reg;



always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        full_reg <= 0;
        src_it_reg <= 0;
        src_reg <= 0;
    end
end
    
endmodule


module LeadingOneDetector #(
    parameter OUT_WIDTH = 8
) (
    input  [OUT_WIDTH-1:0] in_w,
    output [OUT_WIDTH-1:0] out_w
);

assign out_w[0] = in_w[0];

genvar w_it;

generate
    for (w_it = 1; w_it < OUT_WIDTH; w_it = w_it + 1) begin
        assign out_w[w_it] <= ~|in_w[w_it-1:0] & in_w[w_it];
    end
endgenerate

endmodule