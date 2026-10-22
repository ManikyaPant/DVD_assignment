`timescale 1ns/1ps

module tb_mult;
    reg clk;
    reg rst_n;
    reg [3:0] a;
    reg [3:0] b;
    wire [7:0] p;

    integer a_value;
    integer b_value;
    integer vectors_checked;
    integer errors;
    reg [7:0] expected;

    mult_array dut (
        .clk(clk),
        .rst_n(rst_n),
        .a(a),
        .b(b),
        .p(p)
    );

    // A 10 ns clock period.
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Save testbench and DUT signals for waveform viewing.
    initial begin
        $dumpfile("mult.vcd");
        $dumpvars(0, tb_mult);
    end

    initial begin
        rst_n = 1'b0;
        a = 4'b0;
        b = 4'b0;
        vectors_checked = 0;
        errors = 0;
        expected = 8'b0;

        // Hold reset through two rising edges; release away from an edge.
        repeat (2) @(posedge clk);
        @(negedge clk);
        rst_n = 1'b1;

        for (a_value = 0; a_value < 16; a_value = a_value + 1) begin
            for (b_value = 0; b_value < 16; b_value = b_value + 1) begin
                // Drive on a falling edge to avoid racing the DUT registers.
                @(negedge clk);
                a = a_value;
                b = b_value;
                expected = a_value * b_value;

                // First edge captures inputs; second captures their product.
                repeat (2) @(posedge clk);
                // Sample after the SKY130 models' 1 ns UNIT_DELAY as well
                // as the RTL's nonblocking register updates.
                #2;
                vectors_checked = vectors_checked + 1;

                // Case inequality also catches unknown or undriven outputs.
                if (p !== expected) begin
                    errors = errors + 1;
                    $display("Mismatch: a=%0d b=%0d expected=%0d got=%0d",
                             a_value, b_value, expected, p);
                end
            end
        end

        if (errors == 0)
            $display("PASS: %0d vectors checked, 0 errors", vectors_checked);
        else
            $display("FAIL: %0d vectors checked, %0d errors",
                     vectors_checked, errors);

        $finish;
    end
endmodule
