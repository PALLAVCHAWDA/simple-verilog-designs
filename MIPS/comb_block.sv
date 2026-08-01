// ============================================================
// Combinational Block Design Code (Figure 23 — Page 59)
// ============================================================

module Comb_Block(Opcode, Funct, Rd, ALU_OP, Reg_Dest, REG_WS,
                  MUX1_SEL, MUX2_SEL, MUX3_SEL, MUX4_SEL, MUX5_SEL,
                  MUX6_SEL, MUX7_SEL, MUX8_SEL, MUX9_SEL, MUX10_SEL,
                  RAM_WE, RAM_RE, PC_LOAD, IR_LOAD, ALU_REG_LOAD,
                  EPC_EN, CAUSE_SEL, CAUSE_EN, State);

input [5:0] Opcode, Funct;
input [4:0] Rd;
input [3:0] State;
output reg [2:0] ALU_OP;
output reg [1:0] Reg_Dest, MUX2_SEL, MUX3_SEL, MUX5_SEL, MUX8_SEL, MUX10_SEL;
output reg REG_WS, MUX1_SEL, MUX4_SEL, MUX6_SEL, MUX7_SEL, MUX9_SEL;
output reg RAM_WE, RAM_RE, PC_LOAD, IR_LOAD, ALU_REG_LOAD, EPC_EN, CAUSE_SEL, CAUSE_EN;

always @ (Opcode, Funct, Rd, State)
begin
    // Default output values
    ALU_OP       = 3'b000;
    Reg_Dest     = 2'b00;
    REG_WS       = 0;
    MUX1_SEL     = 0;
    MUX2_SEL     = 2'b00;
    MUX3_SEL     = 2'b00;
    MUX4_SEL     = 0;
    MUX5_SEL     = 2'b00;
    MUX6_SEL     = 0;
    MUX7_SEL     = 0;
    MUX8_SEL     = 2'b00;
    MUX9_SEL     = 0;
    MUX10_SEL    = 2'b00;
    RAM_WE       = 0;
    RAM_RE       = 0;
    PC_LOAD      = 0;
    IR_LOAD      = 0;
    ALU_REG_LOAD = 0;
    EPC_EN       = 0;
    CAUSE_SEL    = 0;
    CAUSE_EN     = 0;

    case(State)
        4'd0: // Fetch
        begin
            IR_LOAD   = 1;
            RAM_RE    = 1;
            PC_LOAD   = 1;
            MUX10_SEL = 2'b00;
            ALU_OP    = 3'b000;
            MUX1_SEL  = 1;
            MUX2_SEL  = 2'b00;
        end
        4'd1: // Decode
        begin
            ALU_OP    = 3'b000;
            MUX1_SEL  = 1;
            MUX2_SEL  = 2'b01;
        end
    endcase
end

endmodule
