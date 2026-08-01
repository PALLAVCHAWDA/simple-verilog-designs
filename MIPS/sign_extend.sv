// ============================================================
// Sign Extend Module Design Code (Figure 67 — Page 104)
// ============================================================

module Sign_Extend(In, Sign_Out);

input [15:0] In;
output [31:0] Sign_Out;

assign Sign_Out = {{16{In[15]}}, In};

endmodule

module Zero_Extend_Byte(In, Zero_Out);

input [7:0] In;
output [31:0] Zero_Out;

assign Zero_Out = {24'b0, In};

endmodule

module Sign_Extend_Byte(In, Sign_Out);

input [7:0] In;
output [31:0] Sign_Out;

assign Sign_Out = {{24{In[7]}}, In};

endmodule

module Zero_Extend_Half(In, Zero_Out);

input [15:0] In;
output [31:0] Zero_Out;

assign Zero_Out = {16'b0, In};

endmodule
