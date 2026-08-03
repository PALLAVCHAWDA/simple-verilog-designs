module risc_top(CLK, RST_n);
//Port delcaration
    input CLK, RST_n;

//Internal port declaration

wire OF_OUT, BF_OUT, NF_OUT, ZF_OUT, PC_EN, IorD, MEM_OE, MEM_WS, IR_EN, REG_OE, REG_WS, SIGNEXT_SEL, ALU_SEL1, EPC_EN, CAUSE_SEL, CAUSE_EN, PCWrite_BEQ, PCWrite_BNE, PCWrite_BGTZ, PCWrite_BLTZ, PCWrite_BLEZ, PC_LOAD;
wire [2:0] present_state, next_state, PC_SEL, REG_DATA_SEL, ALU_SEL2, ALU_OP, MEMtoREG;
wire [1:0] MEM_DATA_SEL, Reg_Dest;
wire [31:0] Inst, PC_OUT, PC_SEL_WIRE, ALU_REG_OUT, Addr, DATA, WriteData, Reg2_Out, EB1_Out, EW1_Out, EBZ1_Out, EB2_Out, EWZ1_Out, EW2_Out, DATA_WIRE, EPC_OUT,CAUSE_OUT, Reg_Write_Data, Reg1_Data, Reg2_Data, EW3_Out, EWZ2_Out, Immediate_Out, Immediate_SL, Reg1_Out, ALU_OPR1, ALU_OPR2, ALU_OUT, CAUSE_DATA,CAT_OUT;
wire [4:0] Dest_Addr;
wire [3:0] ALU_CONTROL;
wire [5:0] STATE;
reg [31:0] NC = 32'b0; //No Connect. Used to fill unused inputs of MUXes

// The netlist
// initial $display("RISC Processor module instantiated");
// $display("RISC Processor module instantiated");
control CTL(Inst[31:26], present_state[2:0], OF_OUT, BF_OUT, Inst[5:0], Inst[15:11], next_state[2:0], PC_EN, PC_SEL[2:0], IorD, MEM_DATA_SEL[1:0], MEM_OE, MEM_WS,REG_DATA_SEL[2:0], IR_EN, Reg_Dest[1:0], MEMtoREG[2:0], REG_OE, REG_WS, SIGNEXT_SEL, ALU_SEL1, ALU_SEL2[2:0], ALU_OP[2:0], EPC_EN, CAUSE_SEL, CAUSE_EN, PCWrite_BEQ, PCWrite_BNE, PCWrite_BGTZ, PCWrite_BLTZ, PCWrite_BLEZ, STATE); //Sequence Controller

StateReg SRG(CLK, RST_n, next_state[2:0], present_state[2:0]); //Phase Generator

comb CMB(NF_OUT, ZF_OUT, PCWrite_BLTZ, PCWrite_BGTZ, PCWrite_BLEZ, PCWrite_BNE, PCWrite_BEQ, PC_EN, PC_LOAD); //Combinational Block

pc PCR(PC_OUT[31:0], RST_n, CLK, PC_SEL_WIRE[31:0], PC_LOAD); //Program Counter

mux2 MUX1(PC_OUT[31:0], ALU_REG_OUT[31:0], IorD, Addr[31:0]); //Mux 1. Selects RAM address source.

RAM MEM1(DATA[31:0], Addr[7:0], WriteData[31:0], MEM_OE, MEM_WS); //RAM module. Most segnificant 26 bits of Addr not used to conserve resources.

mux4 MUX2(Reg2_Out[31:0], EB1_Out[31:0], EW1_Out[31:0], NC[31:0], MEM_DATA_SEL[1:0], WriteData[31:0]); //Mux2. Input D is a No Connect (NC). Selects RAM data source.

sign_extend8 EB1(Reg2_Out[7:0], EB1_Out[31:0]); //Sign Extend Byte. Input listed first.

sign_extend16 EW1(Reg2_Out[15:0], EW1_Out[31:0]); //Sign Extend Half Word. Input listed first.

sign_extend8_zero EBZ1(DATA[7:0], EBZ1_Out[31:0]); //Sign Extend Unsigned Byte. Input listed first.

sign_extend8 EB2(DATA[7:0], EB2_Out[31:0]); //Sign Extend Byte. Input listed first.

sign_extend16_zero EWZ1(DATA[15:0], EWZ1_Out[31:0]); //Sign Extend Unsigned Half Word. Input listed first.

sign_extend16 EW2(DATA[15:0], EW2_Out[31:0]); //Sign Extend Half Word. Input listed first.

mux8 MUX3(DATA[31:0], EBZ1_Out[31:0], EB2_Out[31:0], EWZ1_Out[31:0], EW2_Out[31:0], NC[31:0], NC[31:0], NC[31:0], REG_DATA_SEL[2:0], DATA_WIRE[31:0]); //Mux 3 Selects
//MIR data source.

scale_reg_en #(32)MIR(DATA_WIRE[31:0], IR_EN, CLK, Inst[31:0]); //Memory Instruction Register

mux4 MUX4(Inst[20:16], Inst[15:11], 5'b11111, NC[31:0], Reg_Dest[1:0], Dest_Addr[4:0]); //Mux4. Only 5 I/O bits used. Selects Register File address source.

mux8 MUX5(ALU_OUT[31:0], Inst[31:0], EPC_OUT[31:0], CAUSE_OUT[31:0], DATA_WIRE[31:0], PC_OUT[31:0], NC[31:0], NC[31:0], MEMtoREG[2:0], Reg_Write_Data[31:0]); //Mux5.
//Selects Register File data source.

REG_FILE MEM2(Reg1_Data[31:0], Reg2_Data[31:0], Inst[25:21], Inst[20:16], Dest_Addr[4:0], Reg_Write_Data[31:0], REG_OE, REG_WS); //Register File

sign_extend16 EW3(Inst[15:0], EW3_Out[31:0]); //Sign Extend Half Word. Input listed first.

sign_extend16_zero EWZ2(Inst[15:0], EWZ2_Out[31:0]); //Sign Extend Unsigned Half Word. Input listed first.

mux2 MUX6(EW3_Out[31:0], EWZ2_Out[31:0], SIGNEXT_SEL, Immediate_Out[31:0]); //Mux 6. Selects Immediate value to be used by the ALU.

shift_left2 SLL1(Immediate_Out[31:0], Immediate_SL[31:0]); //Shift Immediate value left by two bits. Input listed first.

scale_reg #(32)REG1(Reg1_Data[31:0], CLK, Reg1_Out[31:0]); //ALU Reg1. Input listed first.

scale_reg #(32)REG2(Reg2_Data[31:0], CLK, Reg2_Out[31:0]); //ALU Reg2. Input listed first.

mux2 MUX7(PC_OUT[31:0], Reg1_Out[31:0], ALU_SEL1, ALU_OPR1[31:0]); //Mux 7. Selects ALU Operand1 source.

mux8 MUX8(Reg2_Out[31:0], 32'b1, Immediate_Out[31:0], Immediate_SL[31:0], 32'b0, NC[31:0], NC[31:0], NC[31:0], ALU_SEL2[2:0], ALU_OPR2[31:0]); //Mux 3 Selects MIR data
//source.

alu_cont CONT(Inst[5:0], ALU_OP[2:0], ALU_CONTROL[3:0]); //ALU controller. Inputs listed first.

alu ALU(ALU_OPR1[31:0], ALU_OPR2[31:0], ALU_CONTROL[3:0], Inst[10:6], ALU_OUT[31:0], NF_OUT, ZF_OUT, OF_OUT, BF_OUT); //ALU. Inputs listed first.

scale_reg #(32)REGA(ALU_OUT[31:0], CLK, ALU_REG_OUT[31:0]); //ALU Register. Inputs listed first.

mux2 MUX9(32'b0, 32'b1, CAUSE_SEL, CAUSE_DATA[31:0]); //Mux 9. Determines content of Cause register.

scale_reg_en #(32)REGC(CAUSE_DATA[31:0], CAUSE_EN, CLK, CAUSE_OUT[31:0]); //Cause Register. Inputs listed first.

scale_reg_en #(32)REGE(PC_OUT[31:0], EPC_EN, CLK, EPC_OUT[31:0]); //EPC Register. Inputs listed first.

concatinate CAT(Inst[25:0], PC_OUT[31:28], CAT_OUT[31:0]); //concatinate to calculate PC address for Jump function

mux8 MUX10(ALU_OUT[31:0], ALU_REG_OUT[31:0], CAT_OUT[31:0], Reg1_Out[31:0], 32'b0, NC[31:0], NC[31:0], NC[31:0], PC_SEL[2:0], PC_SEL_WIRE[31:0]); //Mux 10. Selects PC
//value.

endmodule