module mux2(A, B, SEL, OUT);
input [31:0] A, B;
input SEL;
output reg [31:0] OUT;

always @ (A, B, SEL)
begin
    case(SEL)
        1'b0: OUT = A;
        1'b1: OUT = B;
        default: OUT = 32'hx;
    endcase
end

endmodule