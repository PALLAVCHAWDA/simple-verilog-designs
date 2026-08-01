`timescale 1ns / 1ps
module tb_sync_fifo;
    parameter DATA_WIDTH = 8;
    parameter FIFO_DEPTH = 16;

    reg clk;
    reg rst_n;
    reg wr_en;
    reg rd_en;
    reg [DATA_WIDTH-1:0] wr_data;
    wire [DATA_WIDTH-1:0] rd_data;
    wire full;
    wire empty;
    integer i;

    // Instantiate the sync_fifo
    sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(FIFO_DEPTH)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .full(full),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .empty(empty)
    );

    // Clock generation
    initial begin
        clk = 0;
        // forever #5 clk = ~clk; // 100MHz clock
    end

    always #5 clk = ~clk; // 100MHz clock

        // Debug: trace internal FIFO signals every clock edge (hierarchical reference)
    always @(posedge clk) begin
        #1; // wait for nonblocking assignments to settle
        $display("DBG t=%0t rd_en=%b empty=%b rd_valid=%b rd_ptr=%0d wr_ptr=%0d rd_addr=%0d rd_data=%0h",
                $time, rd_en, empty, uut.rd_valid, uut.rd_ptr, uut.wr_ptr, uut.rd_addr, uut.rd_data);
    end
    initial begin
        $dumpfile("tb_sync_fifo.vcd");
        $dumpvars(0, tb_sync_fifo);
        // $monitor("time=%0t wr_en=%b rd_en=%b wr_data=%02h rd_data=%02h full=%b empty=%b",
                //  $time, wr_en, rd_en, wr_data, rd_data, full, empty);

        // Reset the FIFO
        rst_n = 0;
        wr_en = 0;
        rd_en = 0;
        wr_data = 0;
        #20 rst_n = 1;

        // ---------------------------------------------------------------
        // Write data to the FIFO
        // Fix: set wr_data BEFORE the clock edge that samples it, so the
        // value written into memory on this edge is the one we intended.
        // ---------------------------------------------------------------
        wr_en = 1;
        for (i = 0; i < FIFO_DEPTH; i = i + 1) begin
            wr_data = $random % 256; // set data first
            @(posedge clk);          // this edge writes wr_data into mem
            if (full) $display("FIFO is full at time %t", $time);
        end
        wr_en = 0;

        // ---------------------------------------------------------------
        // Read data from the FIFO
        // Fix: add #1 after @(posedge clk) so the DUT's nonblocking
        // assignment (rd_data <= mem[rd_addr]) has settled before we
        // sample rd_data. Without this, we read the PREVIOUS rd_data.
        rd_en = 1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        rd_en = 0;
        // ---------------------------------------------------------------
        // Simultaneous write + read check
        // ---------------------------------------------------------------
        wr_data = 8'hAA;
        wr_en   = 1;
        @(posedge clk);

        wr_data = 8'hBB;
        rd_en   = 1;
        @(posedge clk);
        #1;
        // $display("Simultaneous R/W -> Read data: %0h at time %t", rd_data, $time);

        wr_en = 0;
        rd_en = 0;
        @(posedge clk);
        @(posedge clk);

        $display("Test complete.");
        $finish;
    end
endmodule