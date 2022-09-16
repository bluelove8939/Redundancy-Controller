module RedundancyController #(
    parameter WORD_WIDTH = 8,       // bitwidth of quantized activation element
    parameter CDIST_WIDTH = 8,      // bitwidth of column distance values (d, dr, dv, dh)
    parameter RDIST_WIDTH = 8,      // bitwidth of row distance values (lr, oc)
    parameter MAX_LIFM_RSIZ = 3,    // maximum row size of LIFM
    parameter STEP_RANGE = 128      // step range (LIFM column window size, MTE size)
) (
    input clk,       // positive edge triggered clock signal
    input reset_n,   // asynchronous negative triggered reset
    input enable_in, // input enable signal

    input [WORD_WIDTH*STEP_RANGE-1:0] lifm_column,  // each column of LIFM

    output valid,  // 1 if output is valid

    output [WORD_WIDTH*STEP_RANGE-1:0] olifm_column,  // each column of output dense LIFM
    output [STEP_RANGE*STEP_RANGE-1:0] mt_column      // each column of mapping table
);

integer lidx_it;  // LIFM row index iterator


/*
 *  Registers and Buffers
 */

reg [WORD_WIDTH-1:0] rsiz_cnt;  // counter for row size of LIFM 
reg [WORD_WIDTH-1:0] cursor_a;  // cursor_a and cursor_b are used to check redundancy
reg [WORD_WIDTH-1:0] cursor_b;  // cursor_a is for src column and cursor_b is for dest column

reg [WORD_WIDTH*STEP_RANGE-1:0] lifm_buffer [0:MAX_LIFM_RSIZ-1];  // buffer for lowered input feature map
reg [STEP_RANGE*STEP_RANGE-1:0] mt_buffer   [0:MAX_LIFM_RSIZ-1];  // buffer for mapping table
reg [2*STEP_RANGE-1:0]          st_buffer   [0:MAX_LIFM_RSIZ-1];  // buffer for state table


/*
 *  Main Operation
 */

always @(posedge clk or negedge reset_n) begin
    if (reset_n == 1'b0) begin
        rsiz_cnt <= 0;
        cursor_a <= 0;
        cursor_b <= 0;
        
        for (lidx_it = 0; lidx_it < MAX_LIFM_RSIZ; lidx_it = lidx_it + 1) begin
            lifm_buffer[lidx_it] <= 0;
            mt_buffer[lidx_it] <= 0;
            st_buffer[lidx_it] <= 0;
        end
    end else begin
        
    end
end
    
endmodule