module comb(NF, ZF, BLTZ, BGTZ, BLEZ, BNE, BEQ, PC_EN, OUT);
    output OUT;
    input NF, ZF, BLTZ, BGTZ, BLEZ, BNE, BEQ, PC_EN;

    reg OUT;

    always @ (NF, ZF, BLTZ, BGTZ, BLEZ, BNE, BEQ, PC_EN)
    begin
        OUT = (NF & BLTZ) | (BGTZ & ~(NF | ZF)) | (BLEZ & (NF | ZF)) | (BNE & ~ZF) | (BEQ & ZF) | PC_EN;
    end

endmodule