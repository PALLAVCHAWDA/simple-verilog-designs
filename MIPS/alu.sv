// ============================================================
// ALU Design Code (Figure 9, 10, 11 — Pages 45, 46, 47)
// ============================================================

module ALU(ALU_CTRL, A, B, Shamt, ALU_OUT, OF_OUT, NF_OUT, ZF_OUT, BF_OUT);

input [3:0] ALU_CTRL;
input [31:0] A, B;
input [4:0] Shamt;
output reg [31:0] ALU_OUT;
output reg OF_OUT, NF_OUT, ZF_OUT, BF_OUT;

wire [31:0] adder_out;
wire c_out;

adder add1(.A(A), .B(B), .Cin(ALU_CTRL[0]), .Sum(adder_out), .C_out(c_out));

always @ (ALU_CTRL, A, B, Shamt, adder_out, c_out)
begin
    OF_OUT = 0;
    NF_OUT = 0;
    ZF_OUT = 0;
    BF_OUT = 0;

    case(ALU_CTRL)
        4'b0000: // AND
        begin
            ALU_OUT = A & B;
        end
        4'b0001: // OR
        begin
            ALU_OUT = A | B;
        end
        4'b0010: // ADD
        begin
            ALU_OUT = adder_out;
            OF_OUT = (A[31] ~^ B[31]) & (A[31] ^ adder_out[31]);
        end
        4'b0011: // SUB
        begin
            ALU_OUT = adder_out;
            OF_OUT = (A[31] ^ B[31]) & (A[31] ^ adder_out[31]);
        end
        4'b0100: // SLT (set less than signed)
        begin
            ALU_OUT = $signed(A) < $signed(B) ? 32'b1 : 32'b0;
        end
        4'b0101: // SLTU (set less than unsigned)
        begin
            ALU_OUT = A < B ? 32'b1 : 32'b0;
        end
        4'b0110: // NOR
        begin
            ALU_OUT = ~(A | B);
        end
        4'b0111: // XOR
        begin
            ALU_OUT = A ^ B;
        end
        4'b1000: // SLL (shift left logical)
        begin
            ALU_OUT = B << Shamt;
        end
        4'b1001: // SRL (shift right logical)
        begin
            ALU_OUT = B >> Shamt;
        end
        4'b1010: // SRA (shift right arithmetic)
        begin
            ALU_OUT = $signed(B) >>> Shamt;
        end
        4'b1011: // SLLV (shift left logical variable)
        begin
            ALU_OUT = B << A[4:0];
        end
        4'b1100: // SRLV (shift right logical variable)
        begin
            ALU_OUT = B >> A[4:0];
        end
        4'b1101: // SRAV (shift right arithmetic variable)
        begin
            ALU_OUT = $signed(B) >>> A[4:0];
        end
        4'b1110: // LUI (load upper immediate)
        begin
            ALU_OUT = {B[15:0], 16'b0};
        end
        4'b1111: // Bad Instruction
        begin
            ALU_OUT = 0;
            BF_OUT = 1;
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

// ============================================================
// ALU Controller Design Code (Figure 18 — Page 54)
// ============================================================

module ALU_Control(ALU_OP, Funct, ALU_CTRL);

input [2:0] ALU_OP;
input [5:0] Funct;
output reg [3:0] ALU_CTRL;

always @ (ALU_OP, Funct)
begin
    case(ALU_OP)
        3'b000: ALU_CTRL = 4'b0010; // ADD (lw, sw, addi)
        3'b001: ALU_CTRL = 4'b0011; // SUB (beq, bne, sub)
        3'b010: // R-type
        begin
            case(Funct)
                6'b100000: ALU_CTRL = 4'b0010; // add
                6'b100001: ALU_CTRL = 4'b0010; // addu
                6'b100010: ALU_CTRL = 4'b0011; // sub
                6'b100011: ALU_CTRL = 4'b0011; // subu
                6'b100100: ALU_CTRL = 4'b0000; // and
                6'b100101: ALU_CTRL = 4'b0001; // or
                6'b100110: ALU_CTRL = 4'b0111; // xor
                6'b100111: ALU_CTRL = 4'b0110; // nor
                6'b101010: ALU_CTRL = 4'b0100; // slt
                6'b101011: ALU_CTRL = 4'b0101; // sltu
                6'b000000: ALU_CTRL = 4'b1000; // sll
                6'b000010: ALU_CTRL = 4'b1001; // srl
                6'b000011: ALU_CTRL = 4'b1010; // sra
                6'b000100: ALU_CTRL = 4'b1011; // sllv
                6'b000110: ALU_CTRL = 4'b1100; // srlv
                6'b000111: ALU_CTRL = 4'b1101; // srav
                6'b001000: ALU_CTRL = 4'b0010; // jr
                6'b001001: ALU_CTRL = 4'b0010; // jalr
                default:   ALU_CTRL = 4'b1111; // bad instruction
            endcase
        end
        3'b011: ALU_CTRL = 4'b0000; // AND (andi)
        3'b100: ALU_CTRL = 4'b0001; // OR  (ori)
        3'b101: ALU_CTRL = 4'b0111; // XOR (xori)
        3'b110: ALU_CTRL = 4'b0100; // SLT (slti)
        3'b111: ALU_CTRL = 4'b1110; // LUI (lui)
        default: ALU_CTRL = 4'b1111; // bad instruction
    endcase
end

endmodule
