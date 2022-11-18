`include "distance_calculator.v"


module distance_calculator_tb;

parameter CLOCK_PS   = 10000;
parameter HCLOCK_PS  = 5000;

parameter WORD_WIDTH = 8;
parameter DIST_WIDTH = 7;
parameter MAX_C_SIZE = 128;

reg clk;
integer clk_counter;
integer dr_orig;


// Instantiation of processing element
reg [WORD_WIDTH-1:0] idx1, idx2, ow, fw, st;
wire [MAX_C_SIZE-1:0] except;
wire [DIST_WIDTH-1:0] dr;

DistanceCalculator #(
    .WORD_WIDTH(WORD_WIDTH), .DIST_WIDTH(DIST_WIDTH)
) distcalc (
    .idx1(idx1), .idx2(idx2),
    .ow(ow), .fw(fw), .st(st),
    .except(except), .dr(dr)
);


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


// PE test
initial begin : PE_TEST
    $dumpfile("tb_distance_calculator.vcd");
    $dumpvars(-1, clk);
    $dumpvars(-1, ow);
    $dumpvars(-1, fw);
    $dumpvars(-1, st);
    $dumpvars(-1, idx1);
    $dumpvars(-1, idx2);
    $dumpvars(-1, dr);
    $dumpvars(-1, except);

    $monitor("clk: %3d  OW: %d  FW: %2d  S: %2d  idx1: %2d  idx2: %2d -> dr: %2d  orig: %2d\n- except: %b", 
             clk_counter, ow, fw, st, idx1, idx2, dr, dr_orig, except);

    // reset_n = 1;
    // # HCLOCK_PS
    // reset_n = 0;
    // # HCLOCK_PS
    // reset_n = 1;

    ow = 20;
    fw = 3;
    st = 1;
    idx1 = 0;
    idx2 = 4;
    dr_orig = ((ow - fw) * ((idx2 / fw) - (idx1 / fw)) + (idx2 - idx1)) / st;
    $display("--------------------------------------------------------------");

    # CLOCK_PS
    # CLOCK_PS

    ow = 42;
    fw = 5;
    st = 2;
    idx1 = 0;
    idx2 = 12;
    dr_orig = ((ow - fw) * ((idx2 / fw) - (idx1 / fw)) + (idx2 - idx1)) / st;
    $display("--------------------------------------------------------------");

    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS

    ow = 20;
    fw = 5;
    st = 5;
    idx1 = 0;
    idx2 = 4;
    dr_orig = ((ow - fw) * ((idx2 / fw) - (idx1 / fw)) + (idx2 - idx1)) / st;
    $display("--------------------------------------------------------------");

    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS

    $finish;
end

    
endmodule