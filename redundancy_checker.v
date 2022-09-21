module RedundancyChecker #(
    parameter WORD_WIDTH    = 8,
    parameter RSIZ_WIDTH    = 2,
    parameter ITER_WIDTH    = 9,  // 7bits for column, 2bits for row
    parameter MAX_LIFM_RSIZ = 3,
    parameter STEP_RANGE    = 128,
    parameter DIST_WIDTH    = 7,
    parameter OFFSET        = 0
) (
    input clk,         // clock signal
    input reset_n,     // asynchronous negative active reset
    input set_idle,    // set module as idle state
    input enable_rd,   // read enable signal
    input enable_wt,   // write enable signal
    input enable_fl,   // enable flushing out free list entries

    input [RSIZ_WIDTH-1:0] rsiz,  // LIFM row size

    input [MAX_LIFM_RSIZ-1:0]            dist_except,  // distance exception
    input [MAX_LIFM_RSIZ*DIST_WIDTH-1:0] dist_buffer,  // distance vector

    input [MAX_LIFM_RSIZ*STEP_RANGE*WORD_WIDTH-1:0] lifm_buffer,  // LIFM buffer
    input [MAX_LIFM_RSIZ*STEP_RANGE*STEP_RANGE-1:0] mt_buffer,    // mapping table buffer
    input [MAX_LIFM_RSIZ*STEP_RANGE*2-1:0]          st_buffer,    // state table buffer

    output valid,     // output valid signal (1 iff output value needs to be written to appropriate position)
    output valid_fl,  // free list entry valid signal
    output done,      // finished checking redundancy

    output [ITER_WIDTH-1:0] n_ch_it,    // new chain position iterator
    output [ITER_WIDTH-1:0] n_src_it,   // new source position iterator
    output [ITER_WIDTH-1:0] n_dest_it,  // new destination position iterator

    output [STEP_RANGE-1:0] n_src_mt,   // new source mapping table entry (with chain iterator)
    output [1:0]            n_src_st,   // new source state table entry (with source iterator)
    output [1:0]            n_dest_st   // new destination state table entry (with destination iterator)
);

// FSM states
localparam [3:0] RCH_IDLE    = 4'd0,   // idle state
                 RCH_READ    = 4'd1,   // read table entries
                 RCH_CHECK   = 4'd2,   // checking redundancy
                 RCH_CH_IT   = 4'd3,   // chain iterator select
                 RCH_CH_RD   = 4'd4,
                 RCH_CHAIN   = 4'd4,   // chain detection stage
                 RCH_WRITE   = 4'd5,   // write new table entries
                 RCH_INC_IT  = 4'd6,   // increase iterator
                 RCH_CH_DONE = 4'd8,
                 RCH_EDIT_INIT    = 4'd9,   // edit with fl
                 RCH_EDIT_IT = 4'd10;  // edit iteration

reg [3:0] mode;

// Registers and iterators
reg [WORD_WIDTH-1:0] src, dest;        // LIFM elements
reg [STEP_RANGE-1:0] src_mt, dest_mt;  // mapping table entries
reg [1:0]            src_st, dest_st;  // state table entries

reg valid_reg;  // indicates whether there's valid output
reg done_reg;

reg [ITER_WIDTH-1:0] src_it, dest_it, ch_it;  // iterators

reg [STEP_RANGE-1:0] n_src_mt_reg;                 // new mapping table entry output
reg [1:0]            n_src_st_reg, n_dest_st_reg;  // new state table entry output

reg [STEP_RANGE-1:0] ch_mt_reg;  // chain source mapping table entry
reg [1:0]            ch_st_reg;  // chain source state table entry

assign valid = valid_reg;
assign done  = done_reg;

assign n_ch_it   = ch_it;
assign n_src_it  = src_it;
assign n_dest_it = dest_it;

assign n_src_mt  = n_src_mt_reg;
assign n_src_st  = n_src_st_reg;
assign n_dest_st = n_dest_st_reg;

// Destination valid signal (combinational)
wire [MAX_LIFM_RSIZ-1:0] dest_valid;      // distination valid signal (combinational)
reg  [MAX_LIFM_RSIZ-1:0] dest_valid_vec;  // destination valid register (sequential)

genvar dest_valid_gvar;
generate
    for (dest_valid_gvar = 0; dest_valid_gvar < MAX_LIFM_RSIZ; dest_valid_gvar = dest_valid_gvar + 1) begin
        assign dest_valid[dest_valid_gvar] = (!dist_except[dest_valid_gvar]) && 
                                             (dist_buffer[DIST_WIDTH*(dest_valid_gvar+1)-1:DIST_WIDTH*dest_valid_gvar] <= OFFSET) &&
                                             (src_it[ITER_WIDTH-1:STEP_SHIFT+1] < MAX_LIFM_RSIZ-1);
    end
endgenerate

// Redundancy/chain detection logicfl_counter
wire redc_oc;
wire chain_oc;

assign redc_oc  = (dest_valid_vec[0] && (src == dest));
assign chain_oc = (redc_oc && (src_st == 2'b01) && (src_it[ITER_WIDTH-1:DIST_WIDTH] > 0));

// Free list buffer logic
reg [MAX_LIFM_RSIZ*ITER_WIDTH-1:0] fl_buffer;
reg [MAX_LIFM_RSIZ-1:0]            fl_mask;
reg [WORD_WIDTH-1:0]               fl_counter;

// Main operations
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        src <= 0;
        dest <= 0;
        src_mt <= 0;
        dest_mt <= 0;
        src_st <= 0;
        dest_st <= 0;

        valid_reg <= 0;
        done_reg <= 0;

        src_it <= 0;
        dest_it <= 0;
        ch_it <= 0;

        n_src_mt_reg <= 0;
        n_src_st_reg <= 0;
        n_dest_st_reg <= 0;

        ch_mt_reg <= 0;
        ch_st_reg <= 0;

        dest_valid_vec <= 0;

        fl_buffer <= 0;
        fl_mask <= 0;
    end

    else if (mode == RCH_IDLE) begin
        src_it[ITER_WIDTH-1:DIST_WIDTH] <= 0;
        src_it[DIST_WIDTH-1:0]          <= OFFSET;

        dest_it[ITER_WIDTH-1:DIST_WIDTH] <= dest_valid[0] ? 1                                 : 0;
        dest_it[DIST_WIDTH-1:0]          <= dest_valid[0] ? OFFSET - dist_vec[DIST_WIDTH-1:0] : 0;

        dest_valid_vec <= dest_valid;
    end

    else if (mode == RCH_READ) begin
        ch_it <= src_it;

        src    <= lifm_buffer[WORD_WIDTH*src_it +: WORD_WIDTH];
        src_st <= st_buffer[2*src_it +: 2];
        src_mt <= mt_buffer[STEP_RANGE*src_it +: STEP_RANGE];

        dest    <= dest_valid_vec[0] ? lifm_buffer[WORD_WIDTH*dest_it +: WORD_WIDTH] : 0;
        dest_mt <= dest_valid_vec[0] ? mt_buffer[STEP_RANGE*dest_it +: STEP_RANGE]   : 0;
        dest_st <= dest_valid_vec[0] ? st_buffer[2*dest_it +: 2]                     : 0;
    end

    else if (mode == RCH_CHECK) begin
        if (redc_oc) begin
            n_src_st_reg  <= (src_st == 2'b00) ? 2'b10 :
                             (src_st == 2'b01) ? 2'b01 : 2'b00;
            n_dest_st_reg <= 2'b01;
            n_src_mt_reg  <= (1 << OFFSET) | (1 << dest_it[DIST_WIDTH-1:0]);

            fl_buffer <= {fl_buffer[(MAX_LIFM_RSIZ-1)*ITER_WIDTH-1:0], dest_it};
            fl_mask   <= {fl_mask[MAX_LIFM_RSIZ-2:0], 1'b1};
        end 
        
        else begin
            n_src_st_reg  <= 0;
            n_dest_st_reg <= 0;
            n_src_mt_reg  <= (1 << OFFSET);

            fl_buffer <= {fl_buffer[(MAX_LIFM_RSIZ-1)*ITER_WIDTH-1:0], 0};
            fl_mask     <= {fl_mask[MAX_LIFM_RSIZ-2:0], 1'b0};
        end

        dest_valid_vec <= {dest_valid_vec[0], dest_valid_vec[MAX_LIFM_RSIZ-1:1]};
    end

    else if (mode == RCH_CH_IT) begin
        ch_it <= ch_it - STEP_RANGE + dist_vec[DIST_WIDTH*ch_it[ITER_WIDTH-1:DIST_WIDTH] +: DIST_WIDTH];
    end

    else if (mode == RCH_CH_RD) begin
        ch_mt_reg <= mt_buffer[STEP_RANGE*ch_it +: STEP_RANGE];
        ch_st_reg <= st_buffer[2*ch_it +: 2];
    end

    else if (mode == RCH_CHAIN) begin
        n_src_mt_reg <= ch_mt_reg | n_src_mt_reg;
    end

    else if (mode == RCH_WRITE) begin
        if (enable_wt) begin
            valid_reg <= 1'b1;
        end
    end

    else if (mode == RCH_INC_IT) begin
        valid_reg <= 1'b0;

        src_it[ITER_WIDTH-1:DIST_WIDTH]  <= src_it[ITER_WIDTH-1:DIST_WIDTH] + 1;

        dest_it[ITER_WIDTH-1:DIST_WIDTH] <= dest_valid[0] ? dest_it[ITER_WIDTH-1:DIST_WIDTH] + 1 : 0;
        dest_it[DIST_WIDTH-1:0]          <= dest_valid[0] ? OFFSET - dist_vec[DIST_WIDTH*src_it[ITER_WIDTH-1:DIST_WIDTH] +: DIST_WIDTH] : 0;
    end

    else if (mode == RCH_CH_DONE) begin
        done_reg <= 1'b1;
    end

    else if (mode == RCH_EDIT_INIT) begin
        done_reg <= 1'b0;

        if (fl_mask[MAX_LIFM_RSIZ-1]) begin
            src_it     <= fl_buffer[MAX_LIFM_RSIZ*ITER_WIDTH-1:(MAX_LIFM_RSIZ-1)*ITER_WIDTH];
            fl_counter <= 0;
        end else begin
            
        end
    end

    else if (mode == RCH_EDIT_RDY) begin
        dest_it[ITER_WIDTH-1:DIST_WIDTH] <= fl_buffer[MAX_LIFM_RSIZ*ITER_WIDTH-1:(MAX_LIFM_RSIZ-1)*ITER_WIDTH+DIST_WIDTH] + 1;
        dest_it[DIST_WIDTH-1:0]          <= 0;
    end
end

// State transition
wire [3:0] next, next_idle, next_read, next_check, next_ch_it, next_ch_rd, next_chain, next_write, next_inc_it;

assign next_idle   = enable_rd                                                       ? RCH_READ   : RCH_IDLE;
assign next_read   =                                                                   RCH_CHECK;
assign next_check  = chain_oc                                                        ? RCH_CH_IT  : RCH_WRITE;
assign next_ch_it  =                                                                   RCH_CH_RD;
assign next_ch_rd  =                                                                   RCH_CHAIN;
assign next_chain  = ((ch_it[ITER_WIDTH-1:DIST_WIDTH] == 0) || (ch_st_reg == 2'b10)) ? RCH_WRITE  : RCH_CH_IT;
assign next_write  = (valid_reg & !enable_wt)                                        ? RCH_INC_IT : RCH_WRITE;
assign next_inc_it = src_it[ITER_WIDTH-1:DIST_WIDTH] == MAX_LIFM_RSIZ                ? RCH_CHECK  : RCH_CH_DONE;

assign next = (set_idle)            ? RCH_IDLE     :
              (mode == RCH_IDLE)    ? next_idle    :
              (mode == RCH_READ)    ? next_read    :
              (mode == RCH_CHECK)   ? next_check   :
              (mode == RCH_CH_IT)   ? next_ch_it   :
              (mode == RCH_CH_RD)   ? next_ch_rd   :
              (mode == RCH_CHAIN)   ? next_chain   :
              (mode == RCH_WRITE)   ? next_write   : RCH_IDLE;

always @(posedge clk or negedge reset_n) begin : RCH_STATE_TRANS
    if (!reset_n) begin
        mode <= RCH_IDLE;
    end else begin
        mode <= next;
    end
end
    
endmodule