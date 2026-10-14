import ofdm_pkg::*;
module ecrip(
    input logic clk,
    input logic rst_n,
    input o_frame_t real_frame,
    input o_frame_t imaj_frame,
    input logic valid,
    output comb_frame_t combined_frame,
    output logic ready
);

    localparam int INPUT_ADDR_BITS = $clog2(IFFT_OUTPUT_WIDTH);
    localparam int OUTPUT_ADDR_BITS = $clog2(ECRIP_WIDTH);
    comb_frame_t temp;


    always_comb begin
        temp = '0;
        for(n=0;n<IFFT_BINS;n++)begin : COMBINATION
                temp[(n*FIXED_PR_IFFT) +: ECRIP_WIDTH] = real_frame[(n*FIXED_PR_IFFT) +: FIXED_PR_IFFT] + imaj_frame[(n*FIXED_PR_IFFT) +: FIXED_PR_IFFT];
        end
    end

    always_ff @( posedge clk or negedge rst_n ) begin
        if(~rst_n)begin
            combined_frame <= '0;
            ready <= '0;
        end
        else begin
            if(valid)begin
                combined_frame <= temp;
                ready <= 1'b1;
            end
            else begin
                combined_frame <= '0;
                ready <= '0;
            end
        end
    end

endmodule