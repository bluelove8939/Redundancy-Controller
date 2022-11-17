`include "division_unit.v"


module division_unit_tb;

parameter CLOCK_PS   = 10000;
parameter HCLOCK_PS  = 5000;
parameter WORD_WIDTH = 8;

integer clk_counter;


// Instantiation of processing element
reg clk;
reg reset_n;
reg enable;

reg [WORD_WIDTH-1:0] left_op;
reg [WORD_WIDTH-1:0] right_op;

wire valid;

wire [WORD_WIDTH-1:0] quot;
wire [WORD_WIDTH-1:0] mod;

DivisionUnit #(
    .WORD_WIDTH(WORD_WIDTH)
) div_unit(
    .clk(clk), .reset_n(reset_n), .enable(enable),
    .left_op(left_op), .right_op(right_op),
    .valid(valid), .quot(quot), .mod(mod)
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
initial begin
    $dumpfile("tb_division_unit.vcd");
    $dumpvars(-1, clk);
    $dumpvars(-1, left_op);
    $dumpvars(-1, right_op);
    $dumpvars(-1, quot);
    $dumpvars(-1, mod);
    $dumpvars(-1, valid);

    $monitor("clk: %3d  left: %d  right: %d  quot: %d  mod: %d  valid: %b", clk_counter, left_op, right_op, quot, mod, valid);

    reset_n = 1;
    # HCLOCK_PS
    reset_n = 0;
    # HCLOCK_PS
    reset_n = 1;
    enable = 1;

    left_op = 5;
    right_op = 3;

    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;

    left_op = 7;
    right_op = 2;

    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;
    # CLOCK_PS;

    $finish;
end

    
endmodule