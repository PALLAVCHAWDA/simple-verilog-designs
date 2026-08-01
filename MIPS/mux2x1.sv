// ============================================================
// Multiplexor Design Code (Figure 44 — Page 81)
// ============================================================

module Mux2x1(In0, In1, Sel, Out);

input [31:0] In0, In1;
input Sel;
output [31:0] Out;

assign Out = Sel ? In1 : In0;

endmodule
