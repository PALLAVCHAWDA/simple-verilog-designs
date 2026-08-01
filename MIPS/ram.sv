// ============================================================
// RAM Design Code (Figure 51 — Page 88)
// ============================================================

module RAM(clk, RAM_RE, RAM_WE, Addr, Data_in, Data_out);

input clk, RAM_RE, RAM_WE;
input [31:0] Addr, Data_in;
output reg [31:0] Data_out;

reg [31:0] mem [0:1023];

initial
begin
    $readmemh("program.mem", mem);
end

always @ (posedge clk)
begin
    if (RAM_WE)
        mem[Addr] <= Data_in;
end

always @ (RAM_RE, Addr, mem[Addr])
begin
    if (RAM_RE)
        Data_out = mem[Addr];
    else
        Data_out = 32'bz;
end

endmodule
