import ofdm_pkg::*;
module cyclic_prefix(
    input logic clk,
    input logic rst_n,
    input combined_word_t ecrip_frame,
    input valid,
    output cp_frame_t cp_frame,
    output logic ready
);
    localparam CYCLIC_LENGTH = CYCLIC_PREFIX * FIXED_PR_IFFT_SUM ;
    logic ready_next, ready_q;
    cp_frame_t cp_frame_next, cp_frame_q;
    logic signed [CYCLIC_LENGTH-1:0] cyclic_part;

    
    always_ff @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            cp_frame_q <= '0;
            ready_q <= '0;
        end
        else begin
            cp_frame_q <= cp_frame_next;
            ready_q <= ready_q;
        end
    end

    always_comb begin
        if(valid)begin
            cyclic_part = ecrip_frame[(IFFT_BINS *FIXED_PR_IFFT_SUM -1):((IFFT_BINS-CYCLIC_PREFIX)*FIXED_PR_IFFT_SUM)];
            cp_frame_next = {ecrip_frame,cyclic_part};
            ready_next = 1'b1;
        end
        else begin
            cp_frame_next = '0;
            ready_next = '0;
        end
    end

    assign cp_frame = cp_frame_q;
    assign ready = ready_q;
endmodule