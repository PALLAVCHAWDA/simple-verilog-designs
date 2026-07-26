`timescale 1ns/1ps

module tb_alu;
    reg [7:0] a;
    reg [7:0] b;
    reg [2:0] op;
    wire [7:0] result;
    wire carry_out;
    wire zero;

    // Instantiate the ALU
    alu uut (
        .a(a),
        .b(b),
        .op(op),
        .result(result),
        .carry_out(carry_out),
        .zero(zero)
    );

    initial begin
        $dumpfile("tb_alu.vcd");
        $dumpvars(0, tb_alu);

        $display("Time   op  a      b      result  carry zero");
        $display("------------------------------------------------");

        a = 8'h10; b = 8'h20; op = 3'b000; // ADD
        #10 $display("%4dns  %b  %h  %h  %h      %b     %b", $time, op, a, b, result, carry_out, zero);

        a = 8'h50; b = 8'h30; op = 3'b001; // SUB
        #10 $display("%4dns  %b  %h  %h  %h      %b     %b", $time, op, a, b, result, carry_out, zero);

        a = 8'hF0; b = 8'h20; op = 3'b000; // ADD with carry
        #10 $display("%4dns  %b  %h  %h  %h      %b     %b", $time, op, a, b, result, carry_out, zero);

        a = 8'hAA; b = 8'h55; op = 3'b010; // AND
        #10 $display("%4dns  %b  %h  %h  %h      %b     %b", $time, op, a, b, result, carry_out, zero);

        a = 8'hAA; b = 8'h55; op = 3'b011; // OR
        #10 $display("%4dns  %b  %h  %h  %h      %b     %b", $time, op, a, b, result, carry_out, zero);

        a = 8'hFF; b = 8'h0F; op = 3'b100; // XOR
        #10 $display("%4dns  %b  %h  %h  %h      %b     %b", $time, op, a, b, result, carry_out, zero);

        a = 8'h0F; b = 8'hF0; op = 3'b101; // NOT A
        #10 $display("%4dns  %b  %h  %h  %h      %b     %b", $time, op, a, b, result, carry_out, zero);

        a = 8'h05; b = 8'h0A; op = 3'b110; // Compare less than
        #10 $display("%4dns  %b  %h  %h  %h      %b     %b", $time, op, a, b, result, carry_out, zero);

        a = 8'h0A; b = 8'h05; op = 3'b110; // Compare less than false
        #10 $display("%4dns  %b  %h  %h  %h      %b     %b", $time, op, a, b, result, carry_out, zero);

        $display("Test complete.");
        $finish;
    end
endmodule
