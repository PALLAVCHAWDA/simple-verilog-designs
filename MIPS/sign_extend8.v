module sign_extend8(BYTE_IN, OUT);
input [7:0] BYTE_IN;
output [31:0] OUT;
reg [31:0] OUT;
always @ (BYTE_IN) begin
    OUT = {{24{BYTE_IN[7]}}, BYTE_IN};
end
endmodule