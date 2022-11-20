module LeadingOneDetector4 (
    input  [3:0] mask,
    output [1:0] out_w
);

reg [1:0] out_w_reg;
assign out_w = out_w_reg;

always @(mask) begin
    case (mask)
        4'd0:  out_w_reg <= 0;  // 0000 
        4'd1:  out_w_reg <= 0;  // 0001
        4'd2:  out_w_reg <= 1;  // 0010
        4'd3:  out_w_reg <= 1;  // 0011
        4'd4:  out_w_reg <= 2;  // 0100
        4'd5:  out_w_reg <= 2;  // 0101
        4'd6:  out_w_reg <= 2;  // 0110
        4'd7:  out_w_reg <= 2;  // 0111
        4'd8:  out_w_reg <= 3;  // 1000
        4'd9:  out_w_reg <= 3;  // 1001
        4'd10: out_w_reg <= 3;  // 1010
        4'd11: out_w_reg <= 3;  // 1011
        4'd12: out_w_reg <= 3;  // 1100
        4'd13: out_w_reg <= 3;  // 1101
        4'd14: out_w_reg <= 3;  // 1110
        4'd15: out_w_reg <= 3;  // 1111
        default: out_w_reg <= 0;
    endcase
end
    
endmodule