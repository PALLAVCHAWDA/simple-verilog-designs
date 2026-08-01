// ============================================================
// RAM Design Code (Figure 51 — Page 88)
// ============================================================

module RAM(DataOut, Addr, WriteData, OE, WS);

output [31:0] DataOut;
input [31:0] WriteData;
input [7:0] Addr;
input OE, WS;

reg [31:0] mem [0:255];
reg [31:0] DataOut;

always @ (Addr, OE) begin
    if (OE)
        DataOut = mem[Addr];
    else
        DataOut = DataOut;
end

always @ (posedge WS) begin
    mem[Addr] = WriteData;
end

endmodule
