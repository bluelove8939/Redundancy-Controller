`include "comb_divider16.v"


module comb_divider_tb;

parameter  CLOCK_PS = 10000;
parameter  HCLOCK_PS = 5000;
parameter  WORD_WIDTH = 16;

reg clk;
integer clk_counter;


// Instantiation of processing element
reg [WORD_WIDTH-1:0] lop;
reg [WORD_WIDTH-1:0] rop;
wire [WORD_WIDTH-1:0] quot;
wire [WORD_WIDTH-1:0] mod;

CombDivider16 cd_unit (.lop(lop), .rop(rop), .quot(quot), .mod(mod));

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
    $dumpfile("tb_comb_divider.vcd");
    $dumpvars(-1, clk);
    $dumpvars(-1, lop);
    $dumpvars(-1, rop);
    $dumpvars(-1, quot);
    $dumpvars(-1, mod);

    $monitor("clk: %3d  lop: %d  rop: %d  quot: %d  mod: %d", clk_counter, lop, rop, quot, mod);
    
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