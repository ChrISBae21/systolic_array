`timescale 1ns / 1ps
module systolic_array_4x4 #(
    parameter DATA_WIDTH = 16
)(
    input  wire                        clk,
    input  wire                        reset,

    input  wire [DATA_WIDTH-1:0]       a_in_row [0:3],
    input  wire [DATA_WIDTH-1:0]       b_in_col [0:3],
    input  wire                        valid_in,

    output wire [2*DATA_WIDTH-1:0]     c_out [0:3][0:3],
    output wire                        valid_out
);

wire [DATA_WIDTH-1:0] a_wire [0:3][0:3];
wire [DATA_WIDTH-1:0] b_wire [0:3][0:3];
wire valid_wire [0:3][0:3];

genvar i, j;
generate
    for (i = 0; i < 4; i = i + 1) begin
        for (j = 0; j < 4; j = j + 1) begin

            // Declare once per PE instance
            wire [DATA_WIDTH-1:0] a_in;
            wire [DATA_WIDTH-1:0] b_in;
            wire                  v_in;

            // first corner PE
            if ((i == 0) && (j == 0)) begin
                assign a_in = a_in_row[0];
                assign b_in = b_in_col[0];
                assign v_in = valid_in;
            end
            
            // first row, cols get input down (outer top boundary)
            else if (i == 0) begin
                assign a_in = a_wire[0][j-1];
                assign b_in = b_in_col[j];
                assign v_in = valid_wire[0][j-1];
            end
            
            // first col, rows get input right (outer left boundary)
            else if (j == 0) begin
                assign a_in = a_in_row[i];
                assign b_in = b_wire[i-1][0];
                assign v_in = valid_wire[i-1][0];
            end
            
            // middle PEs
            else begin
                assign a_in = a_wire[i][j-1];
                assign b_in = b_wire[i-1][j];
                assign v_in = valid_wire[i][j-1]; // propagate from left
            end

            pe #(.DATA_WIDTH(DATA_WIDTH)) u_pe (
                .clk       (clk),
                .reset     (reset),
                .a_in      (a_in),
                .b_in      (b_in),
                .valid_in  (v_in),
                .valid_out (valid_wire[i][j]),
                .a_out     (a_wire[i][j]),
                .b_out     (b_wire[i][j]),
                .c_out     (c_out[i][j])
            );

        end
    end
endgenerate

assign valid_out = valid_wire[3][3];

endmodule