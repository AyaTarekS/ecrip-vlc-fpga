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

    comb_frame_t combined_frame_q;
    comb_frame_t combined_frame_next;
    comb_frame_t temp;
    logic ready_next, ready_q;


    genvar n;
    generate;
        for(n=0;n<IFFT_BINS;n++)begin : COMBINATION
            adder frame_adder (.real_word(real_frame[(n*FIXED_PR_IFFT) +: FIXED_PR_IFFT]),.imaj_word(imaj_frame[(n*FIXED_PR_IFFT) +: FIXED_PR_IFFT]),.combined_word(temp[(n*ECRIP_WIDTH) +: ECRIP_WIDTH]));   
        end  
    endgenerate 

    //current state logic 
    always_ff @( posedge clk or negedge rst_n ) begin
        if(~rst_n)begin
            combined_frame_q <= '0;
            ready_q <= '0;
        end
        else begin
            combined_frame_q <= combined_frame_next;
            ready_q <= '0;
        end
    end

    //next state logic 
    always_comb begin
        combined_frame_next = '0;
        if(valid)begin
            combined_frame_next = temp;
            ready_next <= 1'b1;
        end
        else begin
            combined_frame_next <= '0;
            ready_next <= '0;
        end
    end

    assign combined_frame = combined_frame_q;
    assign ready = ready_q;

endmodule