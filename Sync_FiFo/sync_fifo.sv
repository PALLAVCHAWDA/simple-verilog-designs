// -----------------------------------------------------------------------------
// Synchronous FIFO
// - Single clock domain
// - Registered read data (1-cycle latency from read_en to valid read_data)
// - Parameterizable data width and depth (depth must be power of 2)
// -----------------------------------------------------------------------------

module sync_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 16,                  // must be power of 2
    parameter ADDR_WIDTH = $clog2(DEPTH)
)(
    input  wire                   clk,
    input  wire                   rst_n,        // active-low synchronous reset

    // Write interface
    input  wire                   wr_en,
    input  wire [DATA_WIDTH-1:0]  wr_data,
    output wire                   full,

    // Read interface
    input  wire                   rd_en,
    output reg  [DATA_WIDTH-1:0]  rd_data,
    output wire                   empty
);

    // Memory array
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Pointers: one extra MSB bit to distinguish full vs empty
    reg [ADDR_WIDTH:0] wr_ptr;
    reg [ADDR_WIDTH:0] rd_ptr;

    wire [ADDR_WIDTH-1:0] wr_addr = wr_ptr[ADDR_WIDTH-1:0];
    wire [ADDR_WIDTH-1:0] rd_addr = rd_ptr[ADDR_WIDTH-1:0];

    // Full:  pointers equal except MSB differs (wrapped around)
    // Empty: pointers exactly equal
    assign full  = (wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]) &&
                   (wr_addr == rd_addr);
    assign empty = (wr_ptr == rd_ptr);

    wire wr_valid = wr_en & ~full;
    wire rd_valid = rd_en & ~empty;

    // Write logic
    always @(posedge clk) begin
        if (!rst_n) begin
            wr_ptr <= 0;
        end else if (wr_valid) begin
            mem[wr_addr] <= wr_data;
            wr_ptr       <= wr_ptr + 1'b1;
        end
    end

    // Read logic (registered output -> 1 cycle latency)
    always @(posedge clk) begin
        if (!rst_n) begin
            rd_ptr  <= 0;
            rd_data <= {DATA_WIDTH{1'b0}};
        end else if (rd_valid) begin
            rd_data <= mem[rd_addr];
            rd_ptr  <= rd_ptr + 1'b1;
        end
    end

endmodule