// ============================================================
// Program Counter Design Code (Figure 48 — Page 85)
// ============================================================

module PC(clk, rst, PC_LOAD, PC_IN, PC_OUT);

input clk, rst, PC_LOAD;
input [31:0] PC_IN;
output reg [31:0] PC_OUT;

always @ (posedge clk or posedge rst)
begin
    if (rst)
        PC_OUT <= 32'b0;
    else if (PC_LOAD)
        PC_OUT <= PC_IN;
end

endmodule
