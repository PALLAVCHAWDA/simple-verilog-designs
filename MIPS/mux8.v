// ============================================================
// Multiplexor Design Code (Figure 44 — Page 81)
// ============================================================

module mux8(A,B,C,D,E,F,G,H,SEL,OUT);

input [31:0] A, B, C, D, E, F, G, H;
input [2:0] SEL;
output reg [31:0] OUT;

always @ (A, B, C, D, E, F, G, H, SEL)
begin
    case(SEL)
        3'b000: OUT = A;
        3'b001: OUT = B;
        3'b010: OUT = C;
        3'b011: OUT = D;
        3'b100: OUT = E;
        3'b101: OUT = F;
        3'b110: OUT = G;
        3'b111: OUT = H;
        default: OUT = 32'hx;
    endcase
end

endmodule
