// ============================================================
// Concatenate Module 
// ============================================================

module concatinate(CIN26, CIN4, OUT);
    
input [25:0] CIN26;
input [3:0] CIN4;
output [31:0] OUT;

reg [31:0] OUT;

assign OUT = {CIN4, CIN26, 2'b00};

endmodule
