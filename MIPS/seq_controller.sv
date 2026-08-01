// ============================================================
// Sequence Controller Design Code (Figures 31–40 — Pages 68–77)
// ============================================================

module Seq_Controller(clk, rst, Opcode, Funct, Rd, OF_OUT, BF_OUT,
                      ALU_OP, Reg_Dest, REG_WS,
                      MUX1_SEL, MUX2_SEL, MUX3_SEL, MUX4_SEL, MUX5_SEL,
                      MUX6_SEL, MUX7_SEL, MUX8_SEL, MUX9_SEL, MUX10_SEL,
                      RAM_WE, RAM_RE, PC_LOAD, IR_LOAD, ALU_REG_LOAD,
                      EPC_EN, CAUSE_SEL, CAUSE_EN, Present_State);

input clk, rst, OF_OUT, BF_OUT, MUX1_SEL;
input [5:0] Opcode, Funct;
input [4:0] Rd;
output reg [2:0] ALU_OP;
output reg [1:0] Reg_Dest, MUX2_SEL, MUX3_SEL, MUX5_SEL, MUX8_SEL, MUX10_SEL;
output reg REG_WS, MUX4_SEL, MUX6_SEL, MUX7_SEL, MUX9_SEL;
output reg RAM_WE, RAM_RE, PC_LOAD, IR_LOAD, ALU_REG_LOAD;
output reg EPC_EN, CAUSE_SEL, CAUSE_EN;
output reg [3:0] Present_State;

reg [3:0] Next_State;

// State register
always @ (posedge clk or posedge rst)
begin
    if (rst)
        Present_State <= 4'd0;
    else
        Present_State <= Next_State;
end

// Next state & output logic
always @ (Present_State, Opcode, Funct, Rd, OF_OUT, BF_OUT)
begin
    // Default outputs
    ALU_OP       = 3'b000;
    Reg_Dest     = 2'b00;
    REG_WS       = 0;
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
    Next_State   = 4'd0;

    case(Present_State)
        4'd0: // Fetch
        begin
            IR_LOAD    = 1;
            RAM_RE     = 1;
            PC_LOAD    = 1;
            MUX10_SEL  = 2'b00;
            ALU_OP     = 3'b000;
            MUX2_SEL   = 2'b00;
            Next_State = 4'd1;
        end

        4'd1: // Decode
        begin
            ALU_OP     = 3'b000;
            MUX2_SEL   = 2'b01;
            Next_State = 4'd2;
        end

        4'd2: // Execute
        begin
            ALU_REG_LOAD = 1;

            case(Opcode)
                6'b000000: // R-type
                begin
                    ALU_OP = 3'b010;
                    MUX2_SEL = 2'b00;

                    case(Funct)
                        6'b001000: // jr
                        begin
                            PC_LOAD    = 1;
                            MUX10_SEL  = 2'b11;
                            Next_State = 4'd0;
                        end
                        6'b001001: // jalr
                        begin
                            PC_LOAD    = 1;
                            MUX10_SEL  = 2'b11;
                            REG_WS     = 1;
                            Reg_Dest   = 2'b10;
                            MUX5_SEL   = 2'b101; // PC to reg
                            Next_State = 4'd0;
                        end
                        default:
                        begin
                            Next_State = 4'd5;
                        end
                    endcase
                end

                6'b100011, // lw
                6'b100000, // lb
                6'b100100, // lbu
                6'b100001, // lh
                6'b100101: // lhu
                begin
                    ALU_OP     = 3'b000;
                    MUX2_SEL   = 2'b10;
                    Next_State = 4'd3;
                end

                6'b101011, // sw
                6'b101000, // sb
                6'b101001: // sh
                begin
                    ALU_OP     = 3'b000;
                    MUX2_SEL   = 2'b10;
                    Next_State = 4'd4;
                end

                6'b000100: // beq
                begin
                    ALU_OP   = 3'b001;
                    MUX2_SEL = 2'b00;
                    if (OF_OUT == 0) // ZF used via OF naming here
                    begin
                        PC_LOAD    = 1;
                        MUX10_SEL  = 2'b01;
                    end
                    Next_State = 4'd0;
                end

                6'b000101: // bne
                begin
                    ALU_OP   = 3'b001;
                    MUX2_SEL = 2'b00;
                    if (OF_OUT == 1)
                    begin
                        PC_LOAD    = 1;
                        MUX10_SEL  = 2'b01;
                    end
                    Next_State = 4'd0;
                end

                6'b000110: // blez
                begin
                    ALU_OP   = 3'b001;
                    MUX2_SEL = 2'b00;
                    Next_State = 4'd0;
                end

                6'b000111: // bgtz
                begin
                    ALU_OP   = 3'b001;
                    MUX2_SEL = 2'b00;
                    Next_State = 4'd0;
                end

                6'b000001: // bltz (via Rd field)
                begin
                    ALU_OP   = 3'b001;
                    MUX2_SEL = 2'b00;
                    Next_State = 4'd0;
                end

                6'b001000: // addi
                begin
                    ALU_OP     = 3'b000;
                    MUX2_SEL   = 2'b10;
                    Next_State = 4'd5;
                end

                6'b001001: // addiu
                begin
                    ALU_OP     = 3'b000;
                    MUX2_SEL   = 2'b10;
                    Next_State = 4'd5;
                end

                6'b001100: // andi
                begin
                    ALU_OP     = 3'b011;
                    MUX2_SEL   = 2'b10;
                    Next_State = 4'd5;
                end

                6'b001101: // ori
                begin
                    ALU_OP     = 3'b100;
                    MUX2_SEL   = 2'b10;
                    Next_State = 4'd5;
                end

                6'b001110: // xori
                begin
                    ALU_OP     = 3'b101;
                    MUX2_SEL   = 2'b10;
                    Next_State = 4'd5;
                end

                6'b001010: // slti
                begin
                    ALU_OP     = 3'b110;
                    MUX2_SEL   = 2'b10;
                    Next_State = 4'd5;
                end

                6'b001111: // lui
                begin
                    ALU_OP     = 3'b111;
                    MUX2_SEL   = 2'b10;
                    Next_State = 4'd5;
                end

                6'b000010: // j
                begin
                    PC_LOAD    = 1;
                    MUX10_SEL  = 2'b10;
                    Next_State = 4'd0;
                end

                6'b000011: // jal
                begin
                    PC_LOAD    = 1;
                    MUX10_SEL  = 2'b10;
                    REG_WS     = 1;
                    Reg_Dest   = 2'b11;
                    MUX5_SEL   = 2'b101;
                    Next_State = 4'd0;
                end

                6'b010000: // mfc0
                begin
                    REG_WS     = 1;
                    Reg_Dest   = 2'b00;
                    MUX5_SEL   = 2'b11;
                    Next_State = 4'd0;
                end

                default: // bad instruction
                begin
                    EPC_EN     = 1;
                    CAUSE_EN   = 1;
                    CAUSE_SEL  = 0;
                    PC_LOAD    = 1;
                    MUX10_SEL  = 2'b00; // vector at 0x0000
                    Next_State = 4'd0;
                end
            endcase
        end

        4'd3: // Memory Read
        begin
            RAM_RE     = 1;
            Next_State = 4'd5;
        end

        4'd4: // Memory Write
        begin
            RAM_WE     = 1;
            MUX4_SEL   = 1;
            Next_State = 4'd0;
        end

        4'd5: // Write Back
        begin
            REG_WS = 1;

            case(Opcode)
                6'b000000: // R-type
                begin
                    Reg_Dest = 2'b01;
                    MUX5_SEL = 2'b00;
                end
                6'b100011: // lw
                begin
                    Reg_Dest = 2'b00;
                    MUX5_SEL = 2'b01;
                    MUX3_SEL = 2'b11;
                end
                6'b100000: // lb (sign extend byte)
                begin
                    Reg_Dest = 2'b00;
                    MUX5_SEL = 2'b01;
                    MUX3_SEL = 2'b00;
                end
                6'b100100: // lbu (zero extend byte)
                begin
                    Reg_Dest = 2'b00;
                    MUX5_SEL = 2'b01;
                    MUX3_SEL = 2'b01;
                end
                6'b100001: // lh (sign extend half)
                begin
                    Reg_Dest = 2'b00;
                    MUX5_SEL = 2'b01;
                    MUX3_SEL = 2'b10;
                end
                6'b100101: // lhu (zero extend half)
                begin
                    Reg_Dest = 2'b00;
                    MUX5_SEL = 2'b01;
                    MUX3_SEL = 2'b11;
                end
                default: // I-type ALU ops
                begin
                    Reg_Dest = 2'b00;
                    MUX5_SEL = 2'b00;
                end
            endcase

            Next_State = 4'd0;
        end

        default:
        begin
            Next_State = 4'd0;
        end
    endcase
end

endmodule
