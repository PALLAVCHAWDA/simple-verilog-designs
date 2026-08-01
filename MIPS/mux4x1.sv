// ============================================================
// Multiplexor Design Code (Figure 44 — Page 81)
// ============================================================

module Mux4x1(In0, In1, In2, In3, Sel, Out);

input [31:0] In0, In1, In2, In3;
input [1:0] Sel;
output reg [31:0] Out;

always @ (In0, In1, In2, In3, Sel)
begin
    case(Sel)
        2'b00: Out = In0;
        2'b01: Out = In1;
        2'b10: Out = In2;
        2'b11: Out = In3;
    endcase
end

endmodule
