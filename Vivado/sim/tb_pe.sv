`timescale 1ns / 1ps

module tb_pe;

parameter DATA_WIDTH = 16;

reg clk;
reg reset;
reg valid_in;

reg  [DATA_WIDTH-1:0] a_in;
reg  [DATA_WIDTH-1:0] b_in;

wire valid_out;
wire [DATA_WIDTH-1:0] a_out;
wire [DATA_WIDTH-1:0] b_out;
wire [2*DATA_WIDTH-1:0] c_out;

integer expected;

// Instantiate the PE
pe #(DATA_WIDTH) uut (
    .clk(clk),
    .reset(reset),
    .a_in(a_in),
    .b_in(b_in),
    .valid_in(valid_in),
    .valid_out(valid_out),
    .a_out(a_out),
    .b_out(b_out),
    .c_out(c_out)
);


// Clock generation
always #5 clk = ~clk;


// Test procedure
initial begin

    clk = 0;
    reset = 1;
    valid_in = 0;
    a_in = 0;
    b_in = 0;
    expected = 0;

    // Reset
    #10;
    reset = 0;

    // ---- Test inputs ----
    // Pair 1
    @(posedge clk);
    a_in = 2;
    b_in = 3;
    valid_in = 1;
    expected = expected + (2*3);

    // Pair 2
    @(posedge clk);
    a_in = 4;
    b_in = 5;
    expected = expected + (4*5);

    // Pair 3
    @(posedge clk);
    a_in = 1;
    b_in = 7;
    expected = expected + (1*7);

    // Stop sending data
    @(posedge clk);
    valid_in = 0;


    // Display result
    $display("Expected Sum = %d", expected);
    $display("Hardware c_out = %d", c_out);

    if (c_out == expected)
        $display("TEST PASSED");
    else
        $display("TEST FAILED");
    // Wait one cycle
//    @(posedge clk);

    reset = 1;
    expected = 0;
    a_in = 0;
    b_in = 0;

    $finish;

end

endmodule