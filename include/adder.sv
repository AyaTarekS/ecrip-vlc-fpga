import ofdm_pkg::*;
module adder#(
    parameter int INPUT_WIDTH = FIXED_PR_IFFT,
    parameter int OUTPUT_WIDTH = FIXED_PR_IFFT_SUM)(
    input logic signed [INPUT_WIDTH-1:0] a,
    input logic signed [INPUT_WIDTH-1:0] b,
    output logic signed [OUTPUT_WIDTH-1:0] sum
);

assign sum = a + b;

endmodule

