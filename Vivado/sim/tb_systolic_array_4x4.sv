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

systolic_array_4x4 #(DATA_WIDTH) dut (
    .clk(clk),
    .reset(reset),
    .a_in_row(a_in_row),
    .b_in_col(b_in_col),
    .valid_in(valid_in),
    .c_out(c_out),
    .valid_out(valid_out)
);

// create a fake clock
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

    B[0][0]=1;  B[0][1]=2;  B[0][2]=3;  B[0][3]=4;
    B[1][0]=5;  B[1][1]=6;  B[1][2]=7;  B[1][3]=8;
    B[2][0]=9;  B[2][1]=10; B[2][2]=11; B[2][3]=12;
    B[3][0]=13; B[3][1]=14; B[3][2]=15; B[3][3]=16;

    // clear inputs
    for (i=0;i<4;i=i+1) begin
        a_in_row[i] = 0;
        b_in_col[i] = 0;
    end

    // release reset
    #20;
    @(posedge clk);
    reset = 0;

    // "Skew" timing for each element so that it's diagonal
    for (t = 0; t <= 9; t = t + 1) begin
        // reset inputs every cycle (inserting don't cares)
        for (i=0;i<4;i=i+1) begin
            a_in_row[i] = 0;
            b_in_col[i] = 0;
        end
        valid_in = 0;

        // at time t = i + k drive:
        // A: A[i][k] (row)
        // B: B[k][i] (col)
        for (i=0;i<4;i=i+1) begin
            for (k=0;k<4;k=k+1) begin
                if (t == (i + k)) begin
                    a_in_row[i] = A[i][k];
                    b_in_col[i] = B[k][i];
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

    repeat(2) @(posedge clk);

    $display("Matrix A:");
    for (i=0;i<4;i=i+1) begin
        for (j=0;j<4;j=j+1)
            $write("%0d ", A[i][j]);
        $display("");
    end
    
    $display("Matrix B:");
    for (i=0;i<4;i=i+1) begin
        for (j=0;j<4;j=j+1)
            $write("%0d ", B[i][j]);
        $display("");
    end

    $display("Result Matrix C:");
    for (i=0;i<4;i=i+1) begin
        for (j=0;j<4;j=j+1)
            $write("%0d ", c_out[i][j]);
        $display("");
    end

    $finish;
end

endmodule
