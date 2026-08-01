// ============================================================
// Register File Design Code (Figure 56 — Page 93)
// ============================================================

module Reg_File(clk, rst, REG_WS, Read_Addr1, Read_Addr2, Write_Addr,
                Write_Data, Reg1, Reg2);

input clk, rst, REG_WS;
input [4:0] Read_Addr1, Read_Addr2, Write_Addr;
input [31:0] Write_Data;
output [31:0] Reg1, Reg2;

reg [31:0] registers [0:31];
integer i;

initial
begin
    for (i = 0; i < 32; i = i + 1)
        registers[i] = 32'b0;
end

always @ (posedge clk or posedge rst)
begin
    if (rst)
    begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] <= 32'b0;
    end
    else if (REG_WS && Write_Addr != 5'b0)
        registers[Write_Addr] <= Write_Data;
end

assign Reg1 = registers[Read_Addr1];
assign Reg2 = registers[Read_Addr2];

endmodule
