module tb_sync_fifo;
    parameter DATA_WIDTH = 8;
    parameter FIFO_DEPTH = 16;

    reg clk;
    reg rst_n;
    reg wr_en;
    reg rd_en;
    reg [DATA_WIDTH-1:0] data_in;
    wire [DATA_WIDTH-1:0] data_out;
    wire full;
    wire empty;
    integer i;

    // Instantiate the sync_fifo
    sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    initial begin
        $dumpfile("tb_sync_fifo.vcd");
        $dumpvars(0, tb_sync_fifo);
        $monitor("time=%0t wr_en=%b rd_en=%b data_in=%02h data_out=%02h full=%b empty=%b", 
                 $time, wr_en, rd_en, data_in, data_out, full, empty);

        // Reset the FIFO
        rst_n = 0;
        wr_en = 0;
        rd_en = 0;
        data_in = 0;
        #20 rst_n = 1;

        // Write data to the FIFO
        for (i = 0; i < FIFO_DEPTH; i = i + 1) begin
            @(posedge clk);
            wr_en = 1;
            data_in = $random % 256; // Random data
            @(posedge clk);
            wr_en = 0;
            @(posedge clk);
            if (full) $display("FIFO is full at time %t", $time);
        end

        // Read data from the FIFO
        for (i = 0; i < FIFO_DEPTH; i = i + 1) begin
            @(posedge clk);
            rd_en = 1;
            @(posedge clk);
            rd_en = 0;
            @(posedge clk);
            if (empty) $display("FIFO is empty at time %t", $time);
            else $display("Read data: %0h at time %t", data_out, $time);
        end

        @(posedge clk);
        wr_en = 1;
        data_in = 8'hAA; // Write a specific value
        @(posedge clk);
        rd_en = 1;
        data_in = 8'hBB; // Clear data_in
        @(posedge clk);
        wr_en = 0;
        rd_en = 0;
        @(posedge clk);
        @(posedge clk);
        $display("Test complete.");
        $finish;
    end
endmodule