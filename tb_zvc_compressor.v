`include "zvc_compressor.v"


module ZVCompresor_tb;

parameter  CLOCK_PS = 10000;
parameter  HCLOCK_PS = 5000;

parameter WORD_WIDTH    = 8;
parameter LINE_SIZE     = 128;
parameter DIST_WIDTH    = 7;
parameter MAX_LIFM_RSIZ = 4;

integer clk_counter;


// Instantiation of compressor
reg clk;
reg reset_n;

reg [LINE_SIZE*WORD_WIDTH-1:0]               lifm_line;
reg [LINE_SIZE*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_line;

wire [LINE_SIZE*WORD_WIDTH-1:0]               lifm_comp;
wire [LINE_SIZE*DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_comp;

wire [WORD_WIDTH-1:0]               lifm_comp_arr [0:LINE_SIZE-1];
wire [DIST_WIDTH*MAX_LIFM_RSIZ-1:0] mt_comp_arr   [0:LINE_SIZE-1];

ZVCompressor #(.WORD_WIDTH(WORD_WIDTH), .LINE_SIZE(LINE_SIZE), .DIST_WIDTH(DIST_WIDTH), .MAX_LIFM_RSIZ(MAX_LIFM_RSIZ)
) zvc_compr (
    .clk(clk), .reset_n(reset_n),
    .lifm_line(lifm_line), .mt_line(mt_line),
    .lifm_comp(lifm_comp), .mt_comp(mt_comp)
);

genvar line_iter;
generate
    for (line_iter = 0; line_iter < LINE_SIZE; line_iter = line_iter+1) begin
        assign lifm_comp_arr[line_iter] = lifm_comp[line_iter*WORD_WIDTH+:WORD_WIDTH];
        assign mt_comp_arr[line_iter] = mt_comp[line_iter*DIST_WIDTH*MAX_LIFM_RSIZ+:DIST_WIDTH*MAX_LIFM_RSIZ];
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

// PE test
initial begin : COMPR_TEST
    $dumpfile("tb_zvc_compressor.vcd");
    $dumpvars(-1, clk);
    for (integer i = 0; i < LINE_SIZE; i=i+1) begin
        $dumpvars(-1, lifm_comp_arr[i]);
    end

    $monitor("clk: %3d  lifm_comp: %b\n", clk_counter, lifm_comp);
    
    reset_n = 1;
    # HCLOCK_PS
    reset_n = 0;
    # HCLOCK_PS
    reset_n = 1;

    lifm_line[3*WORD_WIDTH+:WORD_WIDTH]  = 13;
    lifm_line[8*WORD_WIDTH+:WORD_WIDTH]  = 47;
    lifm_line[15*WORD_WIDTH+:WORD_WIDTH] = 22;

    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS
    # CLOCK_PS

    $finish;
end

    
endmodule