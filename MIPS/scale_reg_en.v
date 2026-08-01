// ============================================================
// Scalable Register Design Code (Figure 61 — Page 98)
// ============================================================

module scale_reg_en(DATA, EN, CLK, OUT);

parameter REG_SIZE = 32;

input CLK,EN;
input [REG_SIZE-1:0] DATA;
output reg [REG_SIZE-1:0] OUT;

always @ (posedge CLK)
begin
    if (EN)
        OUT <= DATA;
end

endmodule
