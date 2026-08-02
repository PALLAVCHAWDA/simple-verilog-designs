`timescale 1 ns / 1 ns          //Timescale definition
`include "risc_top.v"        //Include the RISC Processor module
`include "RAM_Data.txt"          //Include the RAM data file
`include "RegFile_Data.txt"      //Include the Register File data file
module tb_RISC_Processor();

    //port declarations
    reg CLK, RST_n;

    risc_top UUT(CLK, RST_n);       //cpu instantiation
    initial $display("Testbench for RISC Processor");
    initial
    //parameters output to the simulation log file
    $monitor ("%d CLK = %b RST = %b PC_out = %d RAM_Addr = %d RAM_Data = %d RAM_WS = %b RAM_OE = %b RAM_out = %b IR_out = %b REG_WS = %b REG_OE = %b RegData = %d RegAddr= %d A_Reg = %d ALU_OPR2 = %d ALU_OUT = %d NF = %b ZF = %b OF = %b BF = %b EPC_EN = %d CAUSE_EN = %b STATE = %d", $time, CLK, RST_n, UUT.PCR.Dout, UUT.MUX1.OUT, UUT.MUX2.OUT, UUT.CTL.MEM_WS, UUT.CTL.MEM_OE, UUT.MEM1.DataOut, UUT.MIR.OUT, UUT.CTL.REG_WS, UUT.CTL.REG_OE, UUT.MUX5.OUT, UUT.MUX4.OUT, UUT.REG1.OUT, UUT.REG2.OUT, UUT.MUX7.OUT, UUT.MUX8.OUT, UUT.ALU.ALU_OUT, UUT.ALU.NF_OUT, UUT.ALU.ZF_OUT, UUT.ALU.OF_OUT, UUT.ALU.BF_OUT, UUT.CTL.EPC_EN, UUT.CTL.CAUSE_EN, UUT.CTL.STATE);

    initial CLK = 1'b0;
    always begin
        $write("\n");   //new line used for clarity
        #25 CLK = ~CLK; //clock generator
    end

    initial begin
        $readmemh("RAM_Data.txt", UUT.MEM1.mem);    //initialize RAM with data from RAM_Data.txt
    end

    initial begin
        $readmemh("RegFile_Data.txt", UUT.MEM2.mem);    //initialize Register File with data from RegFile_Data.txt
    end

    initial begin
        $dumpfile("risc_wave.vcd");
        $dumpvars(0, tb_risc);      // dump all signals in tb_risc hierarchy
    end

    initial begin
            // $vcdpluson;         //Enable graphical viewer
            $display("Simulation Started");
             RST_n = 1'b1;
        #5   RST_n = 1'b0;

        #30  RST_n = 1'b1;

        #15000  $finish;        //give enough time for the processor to execute all instructions before terminating simulation
    end
endmodule