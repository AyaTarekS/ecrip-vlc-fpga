import ofdm_pkg::*;
module dc_gain(
    input logic clk,
    input logic rst_n,
    input cp_frame_t cp_in,
    input logic valid,
    output cp_frame_t dc_gain_frame,
    output logic ready
    );
    logic ready_q, ready_next;
    cp_frame_t dc_gain_frame_q, dc_gain_frame_next;
    cp_frame_t temp;

    genvar n;
    generate
        for (n = 0; n < IFFT_BINS; n = n + 1) begin : adding_block
            adder #(.INPUT_WIDTH(FIXED_PR_IFFT_SUM),.OUTPUT_WIDTH(FIXED_PR_IFFT_SUM))gain(.a(cp_in[(n*FIXED_PR_IFFT_SUM) +: FIXED_PR_IFFT_SUM]),.b(DC_VALUE),.sum(temp));
        end
    endgenerate
    

    always_ff @(posedge clk or negedge rst_n)begin
      if(!rst_n)begin
        dc_gain_frame_q <= '0;
        ready_q <= '0;
      end
      else begin
        dc_gain_frame_q <= dc_gain_frame_next;
        ready_q <= ready_next;
      end  
    end

    always_comb begin
        if(valid)begin
            dc_gain_frame_next = temp;
            ready_next = 1'b1;
        end
        else begin
            dc_gain_frame_next = '0;
            ready_next = 1'b0;
        end
    end

    assign ready = ready_q;
    assign dc_gain_frame = dc_gain_frame_q;
    
endmodule