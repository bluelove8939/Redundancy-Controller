`include "distance_calculator.v"


module RedundancyController #(
    parameter WORD_WIDTH = 8,    // bitwidth of a word (fixed to 8bit)
    parameter DIST_WIDTH = 7,    // bitwidth of distances
    parameter MAX_R_SIZE = 4,    // size of each row of lifm and mapping table
    parameter MAX_C_SIZE = 128,  // size of each column of lifm and mapping table
    parameter MPTE_WIDTH = DIST_WIDTH * MAX_R_SIZE  // width of mapping table entry
) (
    input clk,      // global clock signal (positive-edge triggered)
    input reset_n,  // global asynchronous reset signal (negative triggered)

    input [WORD_WIDTH-1:0] idx,  // index of weight value (lowered filter)
    input [WORD_WIDTH-1:0] ow,   // shapes: output width (OW)
    input [WORD_WIDTH-1:0] fw,   // shapes: filter(kernel) width (FW)
    input [WORD_WIDTH-1:0] st,   // shapes: stride amount (S)

    input [MAX_R_SIZE*WORD_WIDTH-1:0] lifm_line,  // un-processed lifm column

    output [MAX_R_SIZE*WORD_WIDTH-1:0] lifm_comp,  // vector of compressed lifm
    output [MAX_R_SIZE*MPTE_WIDTH-1:0] mpte_comp   // vector mapping table entries
);

// Buffers
reg [WORD_WIDTH-1:0] idx1, idx2;
reg [WORD_WIDTH*MAX_C_SIZE-1:0] lifm_buff [0:1];
reg [MPTE_WIDTH*MAX_C_SIZE-1:0] mpte_buff [0:1];

// Instantiation of distance calculator
wire valid;
wire [DIST_WIDTH-1:0] dr;

DistanceCalculator #(
    .WORD_WIDTH(WORD_WIDTH), .DIST_WIDTH(DIST_WIDTH), .MAX_C_SIZE(MAX_C_SIZE)
) dist_calc (
    .idx1(idx1), .idx2(idx2), 
    .ow(ow), .fw(fw), .st(st),
    .valid(valid), .dr(dr)
);

// Generating MPTE
reg [MPTE_WIDTH*MAX_C_SIZE-1:0] mpte_udpate [0:1];

always @(dr) begin
    case (dr)
        1: begin
            
        end
        default: 
    endcase
end

always @(*) begin
    for (integer citer = 0; citer < MAX_C_SIZE; citer = citer+1) begin
        if (valid && (dr <= citer)) begin
            if (lifm_buff[0][citer] == lifm_buff[1][citer - dr]) begin
                
            end
        end
    end
end

// Shifting LIFM and MPTE
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        idx1 <= 0;
        idx2 <= 0;
        lifm_buff[0] <= 0;
        lifm_buff[1] <= 0;
        mpte_buff[0] <= 0;
        mpte_buff[1] <= 0;
    end 
    
    else begin
        {idx2, idx1} <= {idx, idx2};
        {lifm_buff[1], lifm_buff[0]} <= {lifm_line, lifm_buff[1]};
        {mpte_buff[1], mpte_buff[0]} <= {mpte_line, mpte_buff[1]};
    end
end

endmodule