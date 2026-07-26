// Simple 8-bit ALU
module alu (
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire [2:0] op,
    output reg  [7:0] result,
    output wire       carry_out,
    output wire       zero
);

    assign carry_out = (op == 3'b000) ? (a + b > 8'hFF) : 1'b0;
    assign zero      = (result == 8'h00);

    always @(*) begin
        case (op)
            3'b000: result = a + b;          // ADD
            3'b001: result = a - b;          // SUB
            3'b010: result = a & b;          // AND
            3'b011: result = a | b;          // OR
            3'b100: result = a ^ b;          // XOR
            3'b101: result = ~a;             // NOT A
            3'b110: result = (a < b) ? 8'h01 : 8'h00; // Compare less than
            default: result = 8'h00;         // NOP / unsupported
        endcase
    end

endmodule
