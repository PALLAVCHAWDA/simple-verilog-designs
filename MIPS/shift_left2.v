// ============================================================
// Shift Module Design Code (Figure 64 — Page 101)
// ============================================================

module shift_left2(SHIFT_IN, SHIFT_OUT);

input [31:0] SHIFT_IN;
output [31:0] SHIFT_OUT;

assign SHIFT_OUT = {SHIFT_IN[29:0], 2'b00};

endmodule
