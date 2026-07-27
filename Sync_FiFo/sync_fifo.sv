module sync_fifo #(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 16
)(
    input wire clk,
    input wire rst_n,
    input wire wr_en,
    input wire rd_en,
    input wire [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out,
    output reg full,
    output reg empty
);

    reg [DATA_WIDTH-1:0] fifo_mem [0:FIFO_DEPTH-1];
    reg [$clog2(FIFO_DEPTH):0] wr_ptr;
    reg [$clog2(FIFO_DEPTH):0] rd_ptr;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            data_out <= 0;
        end else begin

            if (wr_en && !full) begin
                fifo_mem[wr_ptr[$clog2(FIFO_DEPTH)-1:0]] <= data_in;
                wr_ptr <= (wr_ptr + 1);
            end

            if (rd_en && !empty) begin
                data_out <= fifo_mem[rd_ptr[$clog2(FIFO_DEPTH)-1:0]];
                rd_ptr <= (rd_ptr + 1);
            end

        end
    end

    always@(*) begin
        full = ((wr_ptr[$clog2(FIFO_DEPTH)] != rd_ptr[$clog2(FIFO_DEPTH)]) && (wr_ptr[$clog2(FIFO_DEPTH)-1:0] == rd_ptr[$clog2(FIFO_DEPTH)-1:0]));
        empty = (wr_ptr == rd_ptr);
    end

endmodule