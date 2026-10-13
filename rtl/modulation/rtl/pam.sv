import ofdm_pkg::*;
module pam(
    input logic clk,
    input logic rst_n,
    input [MODULATION_BITS-1:0] bits_in,
    input logic valid,
    output symbol_t pam_symbol,
    output logic ready
);

    always_ff @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            pam_symbol <= '0;
            ready <= '0;
        end
        else begin
            if(valid)begin
                case (bits_in) // Gray encoding
                    3'b000:  pam_symbol <= -4'sd7;
                    3'b001:  pam_symbol <= -4'sd5;
                    3'b011:  pam_symbol <= -4'sd3;
                    3'b010:  pam_symbol <= -4'sd1;
                    3'b110:  pam_symbol <= 4'sd1;
                    3'b111:  pam_symbol <= 4'sd3;
                    3'b101:  pam_symbol <= 4'sd5;
                    3'b100:  pam_symbol <= 4'sd7;
                    default: pam_symbol <= '0;
                endcase
                ready <= 1'b1;
            end
        end
    end

endmodule