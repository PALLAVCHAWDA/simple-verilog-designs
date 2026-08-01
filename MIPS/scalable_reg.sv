// ============================================================
// Scalable Register Design Code (Figure 61 — Page 98)
// ============================================================

module Scalable_Reg(clk, rst, EN, D, Q);

parameter WIDTH = 32;

input clk, rst, EN;
input [WIDTH-1:0] D;
output reg [WIDTH-1:0] Q;

always @ (posedge clk or posedge rst)
begin
    if (rst)
        Q <= {WIDTH{1'b0}};
    else if (EN)
        Q <= D;
end

endmodule
