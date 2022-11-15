module MultiplierTest (
    input clk,
    input reset_n,
    input [7:0] a,
    input [7:0] b,

    output [15:0] y
);

reg [15:0] y_o;

assign y = y_o;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        y_o <= 0;
    end else begin
        y_o <= a * b;
    end
end
    
endmodule


module Multiplier32Test (
    input clk,
    input reset_n,
    input [31:0] a,
    input [31:0] b,

    output [63:0] y
);

reg [63:0] y_o;

assign y = y_o;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        y_o <= 0;
    end else begin
        y_o <= a * b;
    end
end
    
endmodule