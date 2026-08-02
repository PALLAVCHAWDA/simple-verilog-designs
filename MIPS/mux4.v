module mux4(A, B, C, D, SEL, OUT);
    input [31:0] A, B, C, D;
    input [1:0] SEL;
    output reg [31:0] OUT;
    always @ (A, B, C, D, SEL)
    begin
        case(SEL)
            2'b00: OUT = A;
            2'b01: OUT = B;
            2'b10: OUT = C;
            2'b11: OUT = D;
            default: OUT = 32'hx;
        endcase
    end
endmodule