import ofdm_pkg::*;
module adder(
    input i_word_t real_word,
    input i_word_t imaj_word,
    output combined_word_t combined_word
);

assign combined_word = real_word + imaj_word;

endmodule

