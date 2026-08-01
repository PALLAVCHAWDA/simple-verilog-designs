`timescale 1ns / 1ps
module tb_RISC_Processor();
    reg clk;
    reg rst;

    RISC_Processor uut(
        .clk(clk),
        .rst(rst)
    );

    inital clk = 0;
    always #5 clk = ~clk;

    initial begin
        $display("Starting Testbench for RISC Processor");
        rst = 1;
        #10;
        rst = 0;
        #1000;
        $finish;
    end
endmodule