`timescale 1ns/1ps
module tb_systolic_array_4x4;

parameter DATA_WIDTH = 16;

reg clk, reset;
reg valid_in;

reg  [DATA_WIDTH-1:0] a_in_row [0:3];
reg  [DATA_WIDTH-1:0] b_in_col [0:3];

wire [2*DATA_WIDTH-1:0] c_out [0:3][0:3];
wire valid_out;

integer i,j,k,t;

// DUT
systolic_array_4x4 #(DATA_WIDTH) dut (
    .clk(clk),
    .reset(reset),
    .a_in_row(a_in_row),
    .b_in_col(b_in_col),
    .valid_in(valid_in),
    .c_out(c_out),
    .valid_out(valid_out)
);

// clock
always #5 clk = ~clk;

// matrices
reg [DATA_WIDTH-1:0] A [0:3][0:3];
reg [DATA_WIDTH-1:0] B [0:3][0:3];

initial begin
    clk = 0;
    reset = 1;
    valid_in = 0;

    // init A
    A[0][0]=1;  A[0][1]=2;  A[0][2]=3;  A[0][3]=4;
    A[1][0]=5;  A[1][1]=6;  A[1][2]=7;  A[1][3]=8;
    A[2][0]=9;  A[2][1]=10; A[2][2]=11; A[2][3]=12;
    A[3][0]=13; A[3][1]=14; A[3][2]=15; A[3][3]=16;

    // init B = Identity matrix
    for (i=0;i<4;i=i+1)
      for (j=0;j<4;j=j+1)
        B[i][j] = (i==j) ? 1 : 0;

    // clear inputs
    for (i=0;i<4;i=i+1) begin
        a_in_row[i] = 0;
        b_in_col[i] = 0;
    end

    // release reset
    #20;
    @(posedge clk);
    reset = 0;

    // Run skewed injection for t = 0..9 (3N-3 for N=4)
    for (t = 0; t <= 9; t = t + 1) begin
        // defaults each cycle
        for (i=0;i<4;i=i+1) begin
            a_in_row[i] = 0;
            b_in_col[i] = 0;
        end
        valid_in = 0;

        // drive A: A[i][k] at time t = i + k
        for (i=0;i<4;i=i+1) begin
            for (k=0;k<4;k=k+1) begin
                if (t == (i + k)) begin
                    a_in_row[i] = A[i][k];
                    valid_in = 1;
                end
            end
        end

        // drive B: B[k][j] at time t = j + k
        for (j=0;j<4;j=j+1) begin
            for (k=0;k<4;k=k+1) begin
                if (t == (j + k)) begin
                    b_in_col[j] = B[k][j];
                    valid_in = 1;
                end
            end
        end

        @(posedge clk);
    end

    // stop
    valid_in = 0;
    for (i=0;i<4;i=i+1) begin
        a_in_row[i] = 0;
        b_in_col[i] = 0;
    end

    // wait a couple cycles, then print
    repeat(2) @(posedge clk);

    $display("Result Matrix C:");
    for (i=0;i<4;i=i+1) begin
        for (j=0;j<4;j=j+1)
            $write("%0d ", c_out[i][j]);
        $display("");
    end

    $finish;
end

endmodule