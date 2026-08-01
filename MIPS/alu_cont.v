module alu_cont(FUNCT, ALU_CTRL, OUT);
    output [3:0] OUT;
    input [5:0] FUNCT;
    input [3:0] ALU_CTRL;

    reg [3:0] OUT;
    always @ (FUNCT, ALU_CTRL) begin
            case(ALU_CTRL)
            3'b000: OUT = 4'b0010; // ADD
            3'b001: OUT = 4'b0110; // SUB
            3'b010: 
            begin
                case(FUNCT)
                    6'b001001: OUT = 4'b0010; // ADD
                    6'b100000: OUT = 4'b0010; // ADD
                    6'b100001: OUT = 4'b0010; // ADD
                    6'b100010: OUT = 4'b0110; // SUB
                    6'b100011: OUT = 4'b0110; // SUB
                    6'b100100: OUT = 4'b0000; // AND
                    6'b100101: OUT = 4'b0001; // OR
                    6'b100110: OUT = 4'b0011; // XOR
                    6'b100111: OUT = 4'b0100; // NOR
                    6'b000000: OUT = 4'b1000; // SLL
                    6'b000100: OUT = 4'b1001; // SLLV
                    6'b000010: OUT = 4'b1010; // SRL
                    6'b000110: OUT = 4'b1011; // SRLV
                    6'b000011: OUT = 4'b1100; // SRA
                    6'b000111: OUT = 4'b1101; // SRAV
                    6'b101001: OUT = 4'b0101; // SLTU
                    6'b101010: OUT = 4'b0111; // SLT
                    default:   OUT = 4'bxxxx; // Undefined operation
                endcase
            3'b011: OUT = 4'b0111; // SLT
            3'b100: OUT = 4'b0000; // AND
            3'b101: OUT = 4'b0001; // OR
            3'b110: OUT = 4'b0011; // XOR
            default: OUT = 4'bxxxx; // Undefined operation
            end
            endcase
    end

endmodule