// ============================================================
// State Register Design Code (Figure 70 — Page 107)
// ============================================================

module StateReg(CLK, RST_n, Next_State, Present_State);

input CLK, RST_n;
input [2:0] Next_State;
output reg [2:0] Present_State;

always @ (posedge CLK or posedge RST_n)
begin
    if (RST_n)
        Present_State <= 3'b000;
    else
        Present_State <= Next_State;
end

endmodule
