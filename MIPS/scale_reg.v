module scale_reg#(parameter REG_SIZE = 32)(DATA, CLK, OUT);
    input CLK;
    input [REG_SIZE-1:0] DATA;
    output reg [REG_SIZE-1:0] OUT;

    always @ (posedge CLK)
    begin
        OUT <= DATA;
    end
endmodule