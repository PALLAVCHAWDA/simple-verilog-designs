// =============================================================================
// Testbench: RISC Processor (risc_top)
// -----------------------------------------------------------------------------
// Purpose:
//   Drives CLK/RST_n, preloads instruction & register memories, and logs
//   internal processor signals every clock edge for waveform / log analysis.
//
// Data files:
//   RAM_Data.txt      - instruction memory image (loaded via $readmemh)
//   RegFile_Data.txt  - register file initial values (loaded via $readmemh)
//
// Program under test (see RAM_Data.txt for full annotated listing):
//   Instructions span address 0x000 through 0x07A and exercise nearly every
//   opcode in the ISA (ADD, SUB, loads/stores of all widths, branches taken
//   and not-taken, shifts, set-on-less-than variants, JAL/JALR, etc).
//
// KNOWN DATA ISSUE:
//   RAM_Data.txt @042 (SLTiu, Set case) contains the value "2EBS8001".
//   'S' is not a valid hex digit -- this will corrupt $readmemh parsing
//   for that word (and silently shift/misread subsequent words depending
//   on the simulator's leniency). Fix the source file before relying on
//   results from that instruction onward.
// =============================================================================

`timescale 1ns / 1ns

module tb_RISC_Processor();

    // -------------------------------------------------------------------
    // DUT interface signals
    // -------------------------------------------------------------------
    reg CLK;
    reg RST_n;

    // -------------------------------------------------------------------
    // DUT instantiation
    // -------------------------------------------------------------------
    risc_top UUT (
        .CLK   (CLK),
        .RST_n (RST_n)
    );

    // -------------------------------------------------------------------
    // Clock generation: 50 ns period (matches original #25 half-period)
    // -------------------------------------------------------------------
    initial CLK = 1'b0;
    always #25 CLK = ~CLK;

    // -------------------------------------------------------------------
    // Memory initialization
    // -------------------------------------------------------------------
    initial begin
        $readmemh("RAM_Data.txt", UUT.MEM1.mem);        // instruction memory
        $readmemh("RegFile_Data.txt", UUT.MEM2.mem);    // register file
    end

    // -------------------------------------------------------------------
    // Waveform dump
    // -------------------------------------------------------------------
    initial begin
        $dumpfile("risc_wave.vcd");
        $dumpvars(0, tb_RISC_Processor);
    end

    // -------------------------------------------------------------------
    // Signal trace: one line per event, labeled and grouped by pipeline
    // stage for easier reading than one giant $monitor line.
    // -------------------------------------------------------------------
    initial begin
        $display("Testbench for RISC Processor");

        // Fixed-width column header. Every field below uses a decimal-style
        // width specifier (%Nd) -- including single-bit signals -- because
        // %b field widths do not align consistently with %s header widths
        // across simulators. Keep header widths and $monitor widths
        // identical, column for column, or the table will drift.
        $display("---------------------------------------------------------------------------------------------------------------------------------------------------------------------");
        $display("%8s | %3s %5s %5s | %10s | %8s %8s %2s %2s %10s | %10s | %2s %2s %10s %5s | %10s %10s %10s %1s %1s %1s %1s | %6s %8s",
                  "time", "CLK", "RST_n", "STATE", "PC",
                  "RAMaddr", "RAMwd", "WS", "OE", "RAMrd",
                  "IR",
                  "WS", "OE", "REGwd", "REGad",
                  "ALU_A", "ALU_B", "ALU_OUT", "N", "Z", "O", "B",
                  "EPC_EN", "CAUSE_EN");
        $display("---------------------------------------------------------------------------------------------------------------------------------------------------------------------");

        $monitor(
            "%8d | %3d %5d %5d | %10d | %8d %8d %2d %2d %10d | %10d | %2d %2d %10d %5d | %10d %10d %10d %1d %1d %1d %1d | %6d %8d",
            $time, CLK, RST_n, UUT.CTL.STATE,
            UUT.PCR.Dout,
            UUT.MUX1.OUT, UUT.MUX2.OUT, UUT.CTL.MEM_WS, UUT.CTL.MEM_OE, UUT.MEM1.DataOut,
            UUT.MIR.OUT,
            UUT.CTL.REG_WS, UUT.CTL.REG_OE, UUT.MUX5.OUT, UUT.MUX4.OUT,
            UUT.REG1.OUT, UUT.REG2.OUT, UUT.ALU.ALU_OUT,
            UUT.ALU.NF_OUT, UUT.ALU.ZF_OUT, UUT.ALU.OF_OUT, UUT.ALU.BF_OUT,
            UUT.CTL.EPC_EN, UUT.CTL.CAUSE_EN
        );
    end

    // -------------------------------------------------------------------
    // Reset sequence and simulation control
    // -------------------------------------------------------------------
    initial begin
        $display("Simulation Started");

        RST_n = 1'b1;
        #5   RST_n = 1'b0;   // assert reset (active-low)
        #30  RST_n = 1'b1;   // release reset, processor begins fetch/execute

        // Program spans instruction addresses 0x000-0x07A; 15000 ns gives
        // ample margin for every instruction (including branches/jumps)
        // to retire before the simulation ends.
        #15000 begin
            $display("Simulation Finished");
            $finish;
        end
    end

endmodule