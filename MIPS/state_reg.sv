// ============================================================
// State Register Design Code (Figure 70 — Page 107)
// ============================================================

module State_Reg(clk, rst, Next_State, Present_State);

input clk, rst;
input [3:0] Next_State;
output reg [3:0] Present_State;

always @ (posedge clk or posedge rst)
begin
    if (rst)
        Present_State <= 4'd0;
    else
        Present_State <= Next_State;
end

endmodule
