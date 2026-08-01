// ============================================================
// Concatenate Module Design Code (Figure 28 — Page 64)
// ============================================================

module Concat(IR, PC, Concat_Out);

input [31:0] IR, PC;
output [31:0] Concat_Out;

assign Concat_Out = {PC[31:28], IR[25:0], 2'b00};

endmodule
