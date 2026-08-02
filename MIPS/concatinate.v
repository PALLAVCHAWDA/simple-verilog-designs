// ============================================================
// Concatenate Module 
// ============================================================

module concatinate(CIN26, CIN4, OUT);
    
input [25:0] CIN26;
input [3:0] CIN4;
output [31:0] OUT;

reg [31:0] OUT;

always @ (CIN26 or CIN4) begin
    OUT = {CIN4, CIN26, 2'b00};
end
// assign OUT = {CIN4, CIN26, 2'b00};

endmodule
