module DivisionUnit #(
    parameter WORD_WIDTH = 8
) (
    input clk,
    input reset_n,
    input enable,

    input [WORD_WIDTH-1:0] left_op,
    input [WORD_WIDTH-1:0] right_op,

    output valid,

    output [WORD_WIDTH-1:0] quot,
    output [WORD_WIDTH-1:0] mod
);

localparam [1:0] DIV_IDLE     = 2'd0;  // idle state
localparam [1:0] DIV_SHIFT    = 2'd1;  // shifting operands
localparam [1:0] DIV_MOD_CALC = 2'd2;  // modulus calculation
localparam [1:0] DIV_OUTPUT   = 2'd3;  // output state

reg [1:0] mode;

reg [WORD_WIDTH-1:0] left_op_reg;
reg [WORD_WIDTH-1:0] right_op_reg;

reg valid_in_reg;
reg valid_out_reg;

reg [WORD_WIDTH-1:0] counter;

reg [WORD_WIDTH-1:0] quot_reg;
reg [WORD_WIDTH-1:0] mod_reg;

assign valid = valid_out_reg;
assign quot = quot_reg;
assign mod = mod_reg;

// always @(*) begin
//     $display("mode = %d", mode);
// end

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        left_op_reg <= 0;
        right_op_reg <= 0;

        valid_in_reg <= 0;
        valid_out_reg <= 0;
        counter <= 0;

        quot_reg <= 0;
        mod_reg <= 0;
        mode <= DIV_IDLE;
    end

    else if (mode == DIV_IDLE) begin
        if (enable) begin
            left_op_reg <= left_op;
            right_op_reg <= right_op;
            valid_in_reg <= 1;
        end
    end

    else if (mode == DIV_SHIFT) begin
        {mod_reg[WORD_WIDTH-1:0], left_op_reg[WORD_WIDTH-1:0]} <= {mod_reg[WORD_WIDTH-2:0], left_op_reg[WORD_WIDTH-1:0], 1'b0};
        quot_reg[WORD_WIDTH-1:0] <= {quot_reg[WORD_WIDTH-2:0], 1'b0};
    end

    else if (mode == DIV_MOD_CALC) begin
        if (mod_reg >= right_op_reg) begin
            mod_reg <= mod_reg - right_op_reg;
            counter <= counter + 1;
        end
    end

    else if (mode == DIV_OUTPUT) begin
        if (!enable) begin
            valid_out_reg <= 0;
        end
    end
end

// State transition
wire [1:0] next, next_idle, next_shift, next_mod_calc, next_output;

assign next_idle     = valid_in_reg            ? DIV_SHIFT    : DIV_IDLE;
assign next_shift    =                           DIV_MOD_CALC;
assign next_mod_calc = (counter == WORD_WIDTH) ? DIV_OUTPUT   : DIV_SHIFT;
assign next_output   = !valid_out_reg          ? DIV_IDLE     : DIV_OUTPUT;

assign next = (mode == DIV_IDLE)     ? next_idle     :
              (mode == DIV_SHIFT)    ? next_shift    : 
              (mode == DIV_MOD_CALC) ? next_mod_calc :
              (mode == DIV_OUTPUT)   ? next_output   :
                                       DIV_IDLE;

always @(posedge clk or negedge reset_n) begin : DIV_STATE_TRANS
    if (!reset_n) begin
        mode <= DIV_IDLE;
    end else begin
        mode <= next;
    end
end
    
endmodule