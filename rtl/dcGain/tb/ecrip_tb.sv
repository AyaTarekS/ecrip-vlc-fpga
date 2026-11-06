import ofdm_pkg::*;
module ecrip_tb;
    logic clk , rst_n;
    o_frame_t real_frame;
    o_frame_t imaj_frame;
    logic valid;
    comb_frame_t combined_frame;
    logic ready;

    i_word_t real_queue [IFFT_BINS];
    i_word_t imaj_queue [IFFT_BINS];
    comb_frame_t combined_queue [$];
    comb_frame_t golden_queue[$];
    combined_word_t golden_word;
    comb_frame_t golden_data;
    int correct_data, error_data;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    ecrip ecrip_design (.clk(clk),.rst_n(rst_n),.real_frame(real_frame),.imaj_frame(imaj_frame),.valid(valid),.combined_frame(combined_frame),.ready(ready));

    initial begin
        assert_reset();
        @(posedge clk);
        generate_data();
        repeat(2) @(posedge clk);
        compare_data();
        $finish();
    end

    task assert_reset();
        rst_n = 1'b0;
        repeat(2) @(posedge clk);
        rst_n = 1'b1;
        @(posedge clk);
    endtask
    task generate_data();
        real_frame = '0;
        imaj_frame = '0;
        golden_data = '0;
        for(int i=0;i<16;i++)begin
            for(int k=0;k<IFFT_BINS;k++)begin
                real_queue[k]=$random();
                imaj_queue[k]=$random();
                // golden_word = golden_model(real_queue[k],imaj_queue[k]);
                // combined_queue[k] = golden_word;
            end
            for (int j=0;j<IFFT_BINS;j++)begin
                real_frame[(j*FIXED_PR_IFFT) +: FIXED_PR_IFFT] = real_queue[j];
                imaj_frame[(j*FIXED_PR_IFFT) +: FIXED_PR_IFFT] = imaj_queue[j];
                golden_data[(j*FIXED_PR_IFFT_SUM) +: FIXED_PR_IFFT_SUM] = golden_model(real_queue[j], imaj_queue[j]);
            end
            golden_queue.push_back(golden_data);
            @(posedge clk);
            valid = 1'b1;
            repeat(2) @(posedge clk);
            if(ready)
                combined_queue.push_back(combined_frame);
            else
                combined_queue.push_back('0);
            @(posedge clk);
            valid = 1'b0;
        end
    endtask

    function automatic combined_word_t golden_model(input i_word_t real_word, input i_word_t imaj_word);
        combined_word_t golden_word = real_word + imaj_word;
        return(golden_word);
    endfunction


    task compare_data();

        for(int i = 0; i<16 ; i++)begin

            if(golden_queue[i]===combined_queue[i])
                correct_data ++;
            else begin
                error_data ++;
                // $display("the real data is %0b:", real_frame);
                // $display("the imaginary data is %0b:", imaj_frame);
                $display("The data corrupted in %0b and the correct data is %0b",combined_queue[i],golden_queue[i]);

            end
        end
        $display("the output of the system -> correct items: %0d", correct_data);
        $display("the output of the system -> error items  : %0d", error_data);




    endtask

endmodule