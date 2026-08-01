// ============================================================
// Shift Module Design Code (Figure 64 — Page 101)
// ============================================================

module Shift(In, Shift_Out);

input [31:0] In;
output [31:0] Shift_Out;

assign Shift_Out = {In[29:0], 2'b00};

endmodule
