import ofdm_pkg::*;
module ecrip_tb;
    logic clk , rst_n;
    i_frame_t real_frame;
    i_frame_t imaj_frame;
    logic valid;
    comb_frame_t combined_frame;
    logic ready;

    i_word_t real_queue [IFFT_BINS];
    i_word_t imaj_queue [IFFT_BINS];
    comb_frame_t combined_queue [$];
    combined_word_t golden_word;
    comb_frame_t golden_data;
    int correct_data, error_data;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    ecrip ecrip_design (.clk(clk),.rst_n(rst_n),.real_frame(real_frame),.imaj_frame(imaj_frame),.valid(valid),.combined_frame(combined_frame),.ready(ready));

    task generate_data();
        for(int i=0;i<1;i++)begin
            for(int k=0;k<IFFT_BINS;k++)begin
                real_queue[k]=$random();
                imaj_queue[k]=$random();
                golden_word = golden_model(real_queue[k],imaj_queue[k]);
                combined_queue[k] = golden_word;
            end
            for (int j=0;j<IFFT_BINS;j++)begin
                real_frame={{real_queue[j]},real_frame[IFFT_OUTPUT_WIDTH-1:FIXED_PR_IFFT]};
                imaj_frame={{imaj_queue[j]},imaj_frame[IFFT_OUTPUT_WIDTH-1:FIXED_PR_IFFT]};
                golden_data={{golden_word[j]},golden_data[ECRIP_WIDTH-1:FIXED_PR_IFFT_SUM]};
            end
            @(posedge clk);
            valid = 1'b1;
            @(posedge clk);
            if(ready)
                combined_queue.push_back(combined_frame);
            else
                combined_queue.push_back('0);
            valid = 1'b0;
        end
    endtask

    function combined_word_t golden_model(input i_word_t real_word, input i_word_t imaj_word);
        combined_word_t golden_word = real_word + imaj_word;
        return(golden_word);
    endfunction
    task combare_data();
        comb_frame_t module_out;
        for(int i = 0; i<1 ; i++)begin
            module_out = combined_queue[i];
            if(golden_data===module_out)
                correct_data ++;
            else begin
                error_data ++;
                $$display("The data corrupted in %0b and the correct data is %0b",module_out,golden_data);

            end
        end
        $display("the output of the system -> correct items: %0d", correct_data);
        $display("the output of the system -> error items  : %0d", error_data);




    endtask

endmodule