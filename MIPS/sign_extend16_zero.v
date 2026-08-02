module sign_extend16_zero(BYTE_IN, OUT);
input [15:0] BYTE_IN;
output [31:0] OUT;
reg [31:0] OUT;
always @ (BYTE_IN) begin
    OUT = {{16{1'b0}}, BYTE_IN};
end

endmodule