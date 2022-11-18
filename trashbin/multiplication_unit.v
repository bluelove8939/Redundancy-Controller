module MultiplicationUnit #(
    parameter WORD_WIDTH = 8,  // bitwidth of each operand
    parameter REST_WIDTH = 7   // bitwidth of multiplication result
) (
    input clk,
    input reset_n,
    input enable,

    input [WORD_WIDTH-1:0] left_op,
    input [WORD_WIDTH-1:0] right_op,

    output valid,
    output overflow,

    output [REST_WIDTH-1:0] result
);

localparam [1:0] MUL_IDLE   = 2'd0;  // idle state
localparam [1:0] MUL_SHIFT  = 2'd1;  // shifting
localparam [1:0] MUL_ADD    = 2'd2;  // adding
localparam [1:0] MUL_OUTPUT = 2'd3;  // output state

reg [1:0] mode;

reg [WORD_WIDTH*2-1:0] left_op_reg;
reg [WORD_WIDTH-1:0]   right_op_reg;

reg valid_in_reg;
reg valid_out_reg;

reg [WORD_WIDTH-1:0] counter;

reg [WORD_WIDTH*2-1:0] result_reg;

assign valid    = valid_out_reg;
assign overflow = (result_reg[WORD_WIDTH*2-1:REST_WIDTH]) ? 1'b1 : 1'b0;
assign result   = result_reg[REST_WIDTH-1:0];

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        left_op_reg <= 0;
        right_op_reg <= 0;

        valid_in_reg <= 0;
        valid_out_reg <= 0;
        counter <= 0;

        result_reg <= 0;
    end

    else if (mode == MUL_IDLE) begin
        if (enable) begin
            left_op_reg[WORD_WIDTH-1:0] <= left_op;
            right_op_reg <= right_op;
            valid_in_reg <= 1;
        end
    end

    else if (mode == MUL_SHIFT) begin
        left_op_reg[2*WORD_WIDTH-1:0] <= {left_op_reg[2*WORD_WIDTH-2:0], 1'b0};
        right_op_reg[WORD_WIDTH-1:0]  <= {1'b0, right_op_reg[WORD_WIDTH-1:1]};
    end

    else if (mode == MUL_ADD) begin
        if (right_op_reg[0]) begin
            result_reg <= result_reg + left_op_reg;
        end

        counter <= counter + 1;
    end

    else if (mode == MUL_OUTPUT) begin
        if (!enable) begin
            valid_out_reg <= 0;
        end
    end
end

// State transition
wire [1:0] next, next_idle, next_shift, next_add, next_output;

assign next_idle     = valid_in_reg            ? MUL_SHIFT    : MUL_IDLE;
assign next_shift    =                           MUL_ADD;
assign next_add      = (counter == WORD_WIDTH) ? MUL_OUTPUT   : MUL_SHIFT;
assign next_output   = !valid_out_reg          ? MUL_IDLE     : MUL_OUTPUT;

assign next = (mode == MUL_IDLE)     ? next_idle     :
              (mode == MUL_SHIFT)    ? next_shift    : 
              (mode == MUL_ADD)      ? next_add      :
              (mode == MUL_OUTPUT)   ? next_output   :
                                       MUL_IDLE;

always @(posedge clk or negedge reset_n) begin : MUL_STATE_TRANS
    if (!reset_n) begin
        mode <= MUL_IDLE;
    end else begin
        mode <= next;
    end
end
    
endmodule