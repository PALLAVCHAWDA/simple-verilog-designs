// ============================================================
// Adder Module
// ============================================================

module adder(A, B, Cin, Sum, C_out);

input [31:0] A, B;
input Cin;
output reg [31:0] Sum;
output reg C_out;

always @(*)
begin
    {C_out, Sum} = A + B + Cin;
end

endmodule
