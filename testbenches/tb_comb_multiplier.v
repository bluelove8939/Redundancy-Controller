`include "comb_multiplier.v"


module comb_multiplier_tb;

parameter  CLOCK_PS = 10000;
parameter  HCLOCK_PS = 5000;

reg clk;
integer clk_counter;


// Instantiation of processing element
reg [7:0] lop;
reg [7:0] rop;
wire [31:0] oval;

CombMultiplier8 cm_unit (.lop(lop), .rop(rop), .oval(oval));

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
    $dumpfile("tb_comb_multiplier.vcd");
    $dumpvars(-1, clk);
    $dumpvars(-1, lop);
    $dumpvars(-1, rop);
    $dumpvars(-1, oval);

    $monitor("clk: %3d  lop: %d  rop: %d  oval: %d", clk_counter, lop, rop, oval);
    
    // reset_n = 1;
    // # HCLOCK_PS
    // reset_n = 0;
    // # HCLOCK_PS
    // reset_n = 1;

    lop = 5;
    rop = 3;

    # CLOCK_PS
    # CLOCK_PS

    lop = 45;
    rop = 13;

    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS

    lop = 20;
    rop = 5;

    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS

    $finish;
end

    
endmodule