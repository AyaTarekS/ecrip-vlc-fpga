package ofdm_pkg;
    parameter int MODULATION_BITS = 3;
    parameter int SYMBOL_WIDTH = 4; //signed bits
    parameter int IFFT_BINS = 64;
    parameter int IFFT_INPUT_WIDTH = SYMBOL_WIDTH * IFFT_BINS;
    parameter int CYCLIC_PREFIX = 8;
    parameter int FIXED_PR_IFFT = 16; // FIXED POINT REPRESENTATION
    parameter int IFFT_OUTPUT_WIDTH = IFFT_BINS * FIXED_PR_IFFT;  
    parameter int ECRIP_WIDTH = (FIXED_PR_IFFT +1) * IFFT_BINS;


    typedef logic signed [SYMBOL_WIDTH-1:0] symbol_t;
    typedef logic signed [IFFT_INPUT_WIDTH-1:0] i_frame_t;
    typedef logic signed [IFFT_OUTPUT_WIDTH-1:0] o_frame_t;
    typedef logic signed [ECRIP_WIDTH-1:0] comb_frame_t; 
endpackage