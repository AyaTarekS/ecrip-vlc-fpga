package ofdm_pkg;
    parameter int MODULATION_BITS = 3;
    parameter int SYMBOL_WIDTH = 4; //signed bits
    parameter int IFFT_BINS = 64;
    parameter int CYCLIC_PREFIX = 8;
    parameter int FIXED_PR_IFFT = 16; // FIXED POINT REPRESENTATION


    parameter int IFFT_INPUT_WIDTH = SYMBOL_WIDTH * IFFT_BINS;

    parameter int IFFT_OUTPUT_WIDTH = IFFT_BINS * FIXED_PR_IFFT;
    parameter int FIXED_PR_IFFT_SUM= FIXED_PR_IFFT +1;
     
    parameter int ECRIP_WIDTH = FIXED_PR_IFFT_SUM * IFFT_BINS;
    parameter int CYCLIC_PREFIX_WIDTH = (CYCLIC_PREFIX + IFFT_BINS)*FIXED_PR_IFFT_SUM;

    parameter [FIXED_PR_IFFT_SUM-1] DC_VALUE = 17'h2E36; 


    typedef logic signed [SYMBOL_WIDTH-1:0] symbol_t;
    typedef logic signed [IFFT_INPUT_WIDTH-1:0] i_frame_t;
    typedef logic signed [IFFT_OUTPUT_WIDTH-1:0] o_frame_t;
    typedef logic signed [FIXED_PR_IFFT-1:0] i_word_t;
    typedef logic signed [FIXED_PR_IFFT_SUM-1:0] combined_word_t;
    typedef logic signed [ECRIP_WIDTH-1:0] comb_frame_t; 
    typedef logic signed [CYCLIC_PREFIX_WIDTH-1:0] cp_frame_t;
    
endpackage