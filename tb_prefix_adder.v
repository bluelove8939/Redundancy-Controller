`include "prefix_adder.v"


module prefix_sum_tb;

parameter  CLOCK_PS = 10000;
parameter  HCLOCK_PS = 5000;

integer clk_counter;


// Instantiation of processing element
reg clk;
reg reset_n;
reg mode;

reg [31:0] mask;
wire [191:0] psum;
wire [5:0] psum_arr [0:31];

genvar iter;

generate 
    for(iter = 0; iter < 32; iter=iter+1) begin
        assign psum_arr[iter] = psum[iter*6+:6];
    end
endgenerate

LFPrefixAdder32 lf_adder(.mask(mask), .psum(psum));

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
    $dumpfile("tb_prefix_adder.vcd");
    $dumpvars(-1, clk);
    for (integer i = 0; i < 32; i=i+1) begin
        $dumpvars(-1, psum_arr[i]);
    end

    $monitor("clk: %3d  psum: %b\n", clk_counter, psum);
    
    reset_n = 1;
    # HCLOCK_PS
    reset_n = 0;
    # HCLOCK_PS
    reset_n = 1;

    // mask = 32'b00001000000010000010000000010011;
    mask = 32'b11111111111111111111111111111111;
    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS

    $finish;
end

    
endmodule