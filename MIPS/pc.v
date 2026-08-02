// ============================================================
// Program Counter Design Code (Figure 48 — Page 85)
// ============================================================

module pc(Dout, RST_n, CLK, Din, LD);

input CLK, RST_n, LD;
input [31:0] Din;
output reg [31:0] Dout;

always @ (posedge CLK or negedge RST_n)
begin
    if (!RST_n)
        Dout <= 32'b0;
    else if (LD)
        Dout <= Din;
end

endmodule
