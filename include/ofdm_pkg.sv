package ofdm_pkg;
    parameter int MODULATION_BITS = 3;
    parameter int SYMBOL_WIDTH = 4; //signed bits
    parameter int IFFT_BINS = 
    parameter int FRAME = SYMBOL_WIDTH * IFFT_BINS;
    parameter int CYCLIC_PREFIX = 8;
    typedef logic [SYMBOL_WIDTH-1:0] symbol_t;
endpackage