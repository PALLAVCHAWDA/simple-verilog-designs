module REG_FILE(Reg1_data, Reg2_data, Reg1, Reg2, Write_Reg, Write_Data, OE, WS);

    output [31:0] Reg1_data, Reg2_data;
    input [4:0] Reg1, Reg2, Write_Reg;
    input [31:0] Write_Data;
    input OE, WS;

    reg [31:0] mem[0:31];
    reg [31:0] Reg1_data, Reg2_data;

    always @ (Reg1 or Reg2 or OE) begin
        if (OE) begin
            Reg1_data = mem[Reg1];
            Reg2_data = mem[Reg2];
        end
        else begin
            Reg1_data = Reg1_data;
            Reg2_data = Reg2_data;
        end
    end

    always @(posedge WS) begin
        mem[Write_Reg] = Write_Data;
    end 

endmodule