// ============================================================
// ALU Design Code
// ============================================================

module alu(A, B, ALU_CTRL, SHAMT, ALU_OUT, NF_OUT, ZF_OUT, OF_OUT, BF_OUT);

input [3:0] ALU_CTRL;
input [31:0] A, B;
input [4:0] SHAMT;
output reg [31:0] ALU_OUT;
output reg OF_OUT, NF_OUT, ZF_OUT, BF_OUT;

localparam 
    AND = 4'b0000,
    OR  = 4'b0001,
    ADD = 4'b0010,
    XOR = 4'b0011,
    NOR = 4'b0100,
    SLTU = 4'b0101,
    SUB = 4'b0110,
    SLT = 4'b0111,
    SLL = 4'b1000,
    SLL_VAR = 4'b1001,
    SRL = 4'b1010,
    SRL_VAR = 4'b1011,
    SRA = 4'b1100,
    SRA_VAR = 4'b1101;

reg [31:0] B_Temp;
always @ (ALU_CTRL, A, B, SHAMT)
begin
    OF_OUT = 0;
    NF_OUT = 0;
    ZF_OUT = 0;
    BF_OUT = 0;

    case(ALU_CTRL)
        AND: // AND
        begin
            ALU_OUT = A & B;
        end
        OR: // OR
        begin
            ALU_OUT = A | B;
        end
        ADD: // ADD
        begin
            ALU_OUT = A + B;
            if ((A[31] && B[31]) && !ALU_OUT[31]) // Overflow condition for addition
                OF_OUT = 1;
            else if ((!A[31] && !B[31]) && ALU_OUT[31]) // Overflow condition for addition
                OF_OUT = 1;
        end
        XOR: // XOR
        begin
            ALU_OUT = A ^ B;
        end
        NOR: // NOR
        begin
            ALU_OUT = ~(A | B);
        end
        SLTU: // SLTU (set less than unsigned)
        begin
            if (A < B)
                ALU_OUT = 32'b1;
            else
                ALU_OUT = 32'b0;
        end
        SUB: // SUB
        begin
            B_Temp = ~B + 1; // Two's complement of B
            ALU_OUT = A + B_Temp;
            if ((A[31] && B_Temp[31]) && !ALU_OUT[31]) // Overflow condition for subtraction
                OF_OUT = 1;
            else if ((!A[31] && !B_Temp[31]) && ALU_OUT[31]) // Overflow condition for subtraction
                OF_OUT = 1;
        end
        SLT: // SLT (set less than signed)
        begin
            if ($signed(A) < $signed(B))
                ALU_OUT = 32'b1;
            else
                ALU_OUT = 32'b0;
        end
        SLL: // SLL (shift left logical)
        begin
            ALU_OUT = B << SHAMT;
        end
        SLL_VAR: // SLLV (shift left logical variable)
        begin
            ALU_OUT = B << A;
        end
        SRL: // SRL (shift right logical)
        begin
            ALU_OUT = B >> SHAMT;
        end
        SRL_VAR: // SRLV (shift right logical variable)
        begin
            ALU_OUT = B >> A;
        end
        SRA: // SRA (shift right arithmetic)
        begin
            ALU_OUT = B >>> SHAMT;
        end
        SRA_VAR: // SRAV (shift right arithmetic variable)
        begin
            ALU_OUT = B >>> A;
        end
        default:
        begin
            ALU_OUT = 0;
            BF_OUT = 1;
        end
    endcase

    NF_OUT = ALU_OUT[31];
    ZF_OUT = (ALU_OUT == 0) ? 1 : 0;
end

endmodule