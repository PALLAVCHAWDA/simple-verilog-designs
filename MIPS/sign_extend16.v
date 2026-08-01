// ============================================================
// Sign Extend Module Design Code (Figure 67 — Page 104)
// ============================================================

module sign_extend16(BYTE_IN, OUT);

input [15:0] BYTE_IN;
output [31:0] OUT;

assign OUT = {{16{BYTE_IN[15]}}, BYTE_IN};

endmodule