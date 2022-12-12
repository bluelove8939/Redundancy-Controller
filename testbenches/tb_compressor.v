`include "compressor.v"


module compressor_tb;

parameter CLOCK_PS   = 10000;
parameter HCLOCK_PS  = 5000;

parameter WORD_WIDTH = 8;
parameter MAX_R_SIZE = 4;
parameter R_DIST_WIDTH = 2;

reg clk;
integer clk_counter;


// Instantiation of processing element
// reg reset_n, enable_in, enable_out;
wire [WORD_WIDTH*MAX_R_SIZE-1:0] data_in;
wire [WORD_WIDTH-1:0] data_out;

RowCompressor #(
    .WORD_WIDTH(WORD_WIDTH), .MAX_R_SIZE(MAX_R_SIZE), .R_DIST_WIDTH(R_DIST_WIDTH)
) rc_unit (
    // .clk(clk), .reset_n(reset_n), .enable_in(enable_in), .enable_out(enable_out),
    .data_in(data_in), .data_out(data_out)
);

reg [WORD_WIDTH-1:0] data_in_arr [0:MAX_R_SIZE-1];

genvar arr_iter;
generate
    for (arr_iter = 0; arr_iter < MAX_R_SIZE; arr_iter = arr_iter+1) begin
        assign data_in[WORD_WIDTH*(arr_iter+1)-1:WORD_WIDTH*arr_iter] = data_in_arr[arr_iter];
    end
endgenerate

// Clock signal generation
initial begin : CLOCK_GENERATOR
    clk = 1'b0;
    clk_counter = 0;
    forever
        # HCLOCK_PS clk = ~clk;
end

always @(posedge clk) begin
    clk_counter = clk_counter + 1;
end

integer i;

// Test
initial begin : RC_TEST
    $dumpfile("tb_compressor.vcd");
    // $dumpvars(-1, clk);
    // $dumpvars(-1, reset_n);
    // $dumpvars(-1, enable_in);
    // $dumpvars(-1, enable_out);
    $dumpvars(-1, data_out);
    for (i = 0; i < MAX_R_SIZE; i = i+1) begin
        $dumpvars(-1, data_in_arr[i]);
    end


    // $monitor("clk: %3d  OW: %d  FW: %2d  S: %2d  idx1: %2d  idx2: %2d -> dr: %2d  orig: %2d  valid: %b", 
    //          clk_counter, ow, fw, st, idx1, idx2, dr, dr_orig, valid);

    // reset_n = 1;
    // # HCLOCK_PS
    // reset_n = 0;
    // # HCLOCK_PS
    // reset_n = 1;

    data_in_arr[0] = 0;
    data_in_arr[1] = 1;
    data_in_arr[2] = 0;
    data_in_arr[3] = 2;

    # CLOCK_PS

    data_in_arr[0] = 0;
    data_in_arr[1] = 0;
    data_in_arr[2] = 3;
    data_in_arr[3] = 4;

    # CLOCK_PS

    data_in_arr[0] = 5;
    data_in_arr[1] = 6;
    data_in_arr[2] = 0;
    data_in_arr[3] = 7;

    # CLOCK_PS

    data_in_arr[0] = 0;
    data_in_arr[1] = 0;
    data_in_arr[2] = 8;
    data_in_arr[3] = 0;

    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS

    $finish;
end

    
endmodule