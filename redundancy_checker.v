module RedundancyChecker #(
    parameter WORD_WIDTH    = 8,
    parameter RSIZ_WIDTH    = 2,
    parameter ITER_WIDTH    = 9,  // 7bits for column, 2bits for row
    parameter MAX_LIFM_RSIZ = 3,
    parameter STEP_RANGE    = 128,
    parameter DIST_WIDTH    = 7,
    parameter OFFSET        = 0
) (
    input clk,
    input reset_n,
    input idle_state,  // reset into idle state
    input enable_in,   // 

    input [RSIZ_WIDTH-1:0] rsiz,  // LIFM row size

    input [MAX_LIFM_RSIZ-1:0]            dist_except,  // distance exception
    input [MAX_LIFM_RSIZ*DIST_WIDTH-1:0] dist_buffer,  // distance vector

    input [MAX_LIFM_RSIZ*STEP_RANGE*WORD_WIDTH-1:0] lifm_buffer,  // LIFM buffer
    input [MAX_LIFM_RSIZ*STEP_RANGE*STEP_RANGE-1:0] mt_buffer,    // mapping table buffer
    input [MAX_LIFM_RSIZ*STEP_RANGE*2-1:0]          st_buffer,    // state table buffer

    output valid,

    output [STEP_RANGE-1:0] n_src_mt,
    output [STEP_RANGE-1:0] n_dest_mt
    output [1:0]            n_src_st,
    output [1:0]            n_dest_st   
);

// FSM states
localparam [3:0] RCH_IDLE   = 4'd0,  // idle state
                 RCH_READ   = 4'd1,  // read state
                 RCH_CHECK  = 4'd2,  // checking state
                 RCH_INC_IT = 4'd3;  // increase iterator

reg [3:0] mode;

// Registers and iterators
reg [WORD_WIDTH-1:0] src, dest;        // LIFM elements
reg [STEP_RANGE-1:0] src_mt, dest_mt;  // mapping table entries
reg [1:0]            src_st, dest_st;  // state table entries
reg [ITER_WIDTH-1:0] src_it, dest_it;  // iterators

reg                  valid_reg;                    // indicates whether there's valid output
reg [STEP_RANGE-1:0] n_src_mt_reg, n_dest_mt_reg;  // new mapping table entry output
reg [1:0]            n_src_st_reg, n_dest_st_reg;  // new state table entry output

assign valid     = valid_reg;
assign n_src_mt  = n_src_mt_reg;
assign n_dest_mt = n_dest_mt_reg;
assign n_src_st  = n_src_st_reg;
assign n_dest_st = n_dest_st_reg;

// Destination valid signal (combinational)
wire [MAX_LIFM_RSIZ-1:0] dest_valid;
reg  [MAX_LIFM_RSIZ-1:0] dest_valid_vec;

genvar dest_valid_gvar;
generate
    for (dest_valid_gvar = 0; dest_valid_gvar < MAX_LIFM_RSIZ; dest_valid_gvar = dest_valid_gvar + 1) begin
        assign dest_valid[dest_valid_gvar] = (!dist_except[dest_valid_gvar]) && 
                                             (dist_buffer[DIST_WIDTH*(dest_valid_gvar+1)-1:DIST_WIDTH*dest_valid_gvar] <= OFFSET) &&
                                             (src_it[ITER_WIDTH-1:STEP_SHIFT+1] < MAX_LIFM_RSIZ-1);
    end
endgenerate

// Main operations
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        src <= 0;
        dest <= 0;

        src_mt <= 0;
        dest_mt <= 0;

        src_st <= 0;
        dest_st <= 0;

        src_it <= 0;
        dest_it <= 0;
    end

    else if (mode == RCH_IDLE) begin
        src_it[ITER_WIDTH-1:STEP_SHIFT+1] <= 0;
        src_it[STEP_SHIFT-1:0]            <= OFFSET;

        dest_it[ITER_WIDTH-1:DIST_WIDTH] <= dest_valid[0] ? 1                                 : 0;
        dest_it[DIST_WIDTH-1:0]          <= dest_valid[0] ? OFFSET - dist_vec[DIST_WIDTH-1:0] : 0;

        dest_valid_vec <= dest_valid;
    end

    else if (mode == RCH_READ) begin
        src    <= lifm_buffer[WORD_WIDTH*src_it +: WORD_WIDTH];
        src_st <= st_buffer[2*src_it +: 2];
        src_mt <= mt_buffer[STEP_RANGE*src_it +: STEP_RANGE];

        dest    <= dest_valid_vec[0] ? lifm_buffer[WORD_WIDTH*dest_it +: WORD_WIDTH] : 0;
        dest_mt <= dest_valid_vec[0] ? mt_buffer[STEP_RANGE*dest_it +: STEP_RANGE]   : 0;
        dest_st <= dest_valid_vec[0] ? st_buffer[2*dest_it +: 2]                     : 0;
    end

    else if (mode == RCH_CHECK) begin
        n_src_st_reg <= (dest_valid_vec[0] && (src == dest)) ? 2'b10 : dest_valid_vec[0] ? 2'b00 : 2'b01;
    end

    else if (mode == RCH_INC_IT) begin
        
    end
end
    
endmodule