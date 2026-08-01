// ============================================================
// RISC Processor Top-Level Design Code (Figures 73, 74 — Pages 111, 112)
// ============================================================

module RISC_Processor(clk, rst);

input clk, rst;

// Internal wires
wire [31:0] PC_OUT, IR_OUT, ALU_OUT_wire, ALU_REG_OUT;
wire [31:0] Reg1, Reg2, MUX1_OUT, MUX2_OUT, MUX3_OUT, MUX4_OUT;
wire [31:0] MUX5_OUT, MUX6_OUT, MUX10_OUT;
wire [31:0] RAM_OUT, Sign_Ext_Out, Zero_Ext_B_Out;
wire [31:0] Sign_Ext_B_Out, Zero_Ext_H_Out, Concat_Out, Shift_Out;
wire [31:0] EPC_OUT, Cause_OUT;
wire [4:0]  Write_Addr;
wire [3:0]  ALU_CTRL, Present_State;
wire [2:0]  ALU_OP;
wire [1:0]  Reg_Dest, MUX2_SEL, MUX3_SEL, MUX10_SEL;
wire [2:0]  MUX5_SEL;
wire        OF_OUT, NF_OUT, ZF_OUT, BF_OUT;
wire        REG_WS, MUX1_SEL, MUX4_SEL, MUX6_SEL, MUX7_SEL, MUX9_SEL;
wire        RAM_WE, RAM_RE, PC_LOAD, IR_LOAD, ALU_REG_LOAD;
wire        EPC_EN, CAUSE_SEL, CAUSE_EN;

PC u_PC(.clk(clk), .rst(rst), .PC_LOAD(PC_LOAD), .PC_IN(MUX10_OUT), .PC_OUT(PC_OUT));
Scalable_Reg #(32) u_IR(.clk(clk), .rst(rst), .EN(IR_LOAD), .D(RAM_OUT), .Q(IR_OUT));
RAM u_RAM(.clk(clk), .RAM_RE(RAM_RE), .RAM_WE(RAM_WE), .Addr(MUX6_OUT), .Data_in(MUX4_OUT), .Data_out(RAM_OUT));
Reg_File u_Reg_File(.clk(clk), .rst(rst), .REG_WS(REG_WS), .Read_Addr1(IR_OUT[25:21]), .Read_Addr2(IR_OUT[20:16]), .Write_Addr(Write_Addr), .Write_Data(MUX5_OUT), .Reg1(Reg1), .Reg2(Reg2));
ALU_Control u_ALU_CTRL(.ALU_OP(ALU_OP), .Funct(IR_OUT[5:0]), .ALU_CTRL(ALU_CTRL));
ALU u_ALU(.ALU_CTRL(ALU_CTRL), .A(MUX1_OUT), .B(MUX2_OUT), .Shamt(IR_OUT[10:6]), .ALU_OUT(ALU_OUT_wire), .OF_OUT(OF_OUT), .NF_OUT(NF_OUT), .ZF_OUT(ZF_OUT), .BF_OUT(BF_OUT));
Scalable_Reg #(32) u_ALU_REG(.clk(clk), .rst(rst), .EN(ALU_REG_LOAD), .D(ALU_OUT_wire), .Q(ALU_REG_OUT));
Scalable_Reg #(32) u_EPC(.clk(clk), .rst(rst), .EN(EPC_EN), .D(PC_OUT), .Q(EPC_OUT));
Scalable_Reg #(1) u_CAUSE(.clk(clk), .rst(rst), .EN(CAUSE_EN), .D(CAUSE_SEL), .Q(Cause_OUT[0]));
Seq_Controller u_Seq_Ctrl(.clk(clk), .rst(rst), .Opcode(IR_OUT[31:26]), .Funct(IR_OUT[5:0]), .Rd(IR_OUT[15:11]), .OF_OUT(ZF_OUT), .BF_OUT(BF_OUT), .ALU_OP(ALU_OP), .Reg_Dest(Reg_Dest), .REG_WS(REG_WS), .MUX1_SEL(MUX1_SEL), .MUX2_SEL(MUX2_SEL), .MUX3_SEL(MUX3_SEL), .MUX4_SEL(MUX4_SEL), .MUX5_SEL(MUX5_SEL), .MUX6_SEL(MUX6_SEL), .MUX7_SEL(MUX7_SEL), .MUX8_SEL(MUX8_SEL), .MUX9_SEL(MUX9_SEL), .MUX10_SEL(MUX10_SEL), .RAM_WE(RAM_WE), .RAM_RE(RAM_RE), .PC_LOAD(PC_LOAD), .IR_LOAD(IR_LOAD), .ALU_REG_LOAD(ALU_REG_LOAD), .EPC_EN(EPC_EN), .CAUSE_SEL(CAUSE_SEL), .CAUSE_EN(CAUSE_EN), .Present_State(Present_State));
Sign_Extend u_Sign_Ext(.In(IR_OUT[15:0]), .Sign_Out(Sign_Ext_Out));
Shift u_Shift(.In(Sign_Ext_Out), .Shift_Out(Shift_Out));
Concat u_Concat(.IR(IR_OUT), .PC(PC_OUT), .Concat_Out(Concat_Out));
Zero_Extend_Byte u_ZEB(.In(RAM_OUT[7:0]), .Zero_Out(Zero_Ext_B_Out));
Sign_Extend_Byte u_SEB(.In(RAM_OUT[7:0]), .Sign_Out(Sign_Ext_B_Out));
Zero_Extend_Half u_ZEH(.In(RAM_OUT[15:0]), .Zero_Out(Zero_Ext_H_Out));

assign Write_Addr = (Reg_Dest == 2'b00) ? IR_OUT[20:16] :
                    (Reg_Dest == 2'b01) ? IR_OUT[15:11] :
                    (Reg_Dest == 2'b10) ? IR_OUT[15:11] : 5'd31;

Mux2x1 u_MUX1(.In0(Reg1), .In1(PC_OUT), .Sel(MUX1_SEL), .Out(MUX1_OUT));
Mux4x1 u_MUX2(.In0(Reg2), .In1(32'd1), .In2(Sign_Ext_Out), .In3(32'b0), .Sel(MUX2_SEL), .Out(MUX2_OUT));
Mux4x1 u_MUX3(.In0(Sign_Ext_B_Out), .In1(Zero_Ext_B_Out), .In2({{16{RAM_OUT[15]}}, RAM_OUT[15:0]}), .In3(RAM_OUT), .Sel(MUX3_SEL), .Out(MUX3_OUT));
Mux4x1 u_MUX4(.In0(Reg2), .In1({24'b0, Reg2[7:0]}), .In2({16'b0, Reg2[15:0]}), .In3(32'b0), .Sel({MUX9_SEL, MUX4_SEL}), .Out(MUX4_OUT));
Mux8x1 u_MUX5(.In0(ALU_REG_OUT), .In1(MUX3_OUT), .In2(32'b0), .In3(EPC_OUT), .In4(Cause_OUT), .In5(PC_OUT), .In6(32'b0), .In7(32'b0), .Sel(MUX5_SEL), .Out(MUX5_OUT));
Mux2x1 u_MUX6(.In0(PC_OUT), .In1(ALU_REG_OUT), .Sel(MUX6_SEL), .Out(MUX6_OUT));
Mux4x1 u_MUX10(.In0(ALU_OUT_wire), .In1(ALU_REG_OUT), .In2(Concat_Out), .In3(Reg1), .Sel(MUX10_SEL), .Out(MUX10_OUT));

endmodule
