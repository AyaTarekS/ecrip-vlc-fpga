import ofdm_pkg::*;
module bit_to_symbol(
    input logic clk,
    input logic rst_n,
    input logic bit_in,
    input logic valid_bit,
    output symbol_t symbol_out,
    output logic ready
);
    localparam MAX_BIT = MODULATION_BITS -1;
    localparam COUNT_BITS = $clog2(MODULATION_BITS+1);

    reg [COUNT_BITS-1:0] count = '0;
    always_ff @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            symbol_out <= '0;
            count <= '0;
            ready <= '0;
        end
        else begin 
            if(valid_bit)begin
                count <= count + 1;
                symbol_out <= {bit_in, symbol_out[MAX_BIT:1]};
                ready <= (count == 2'd3)? 1'b1:1'b0;
            end
        end
    end
endmodule
