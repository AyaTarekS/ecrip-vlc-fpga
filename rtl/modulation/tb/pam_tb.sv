import ofdm_pkg::*;
module pam_tb ();
    logic clk, rst_n;
    logic [MODULATION_BITS-1:0] bits_in;
    logic valid;
    typedef struct{
        symbol_t pam_symbol;
        logic ready;
    } data_t;

    
    data_t data;
    data_t queue[$];
    int correct_data, error_data;



    logic [MODULATION_BITS-1:0] arr [16] ='{
       3'b101,3'b111,3'b000,3'b010,
       3'b110,3'b011,3'b001,3'b100,
       3'b000,3'b111,3'b101,3'b010,
       3'b110,3'b011,3'b001,3'b100
    };


    initial begin
        clk = 0;
        forever #5 clk =~ clk;
    end

    pam pam_design (.clk(clk), .rst_n(rst_n), .bits_in(bits_in), .valid(valid), .pam_symbol(data.pam_symbol), .ready(data.ready));

    initial begin
        assert_reset();
        @(posedge clk);
        generate_data();
        @(posedge clk);
        compare_data();
        $finish;
    end


    task assert_reset();
        rst_n = 1'b0;
        repeat(2) @(posedge clk);
        rst_n = 1'b1;
        @(posedge clk);
    endtask

    task generate_data();
        for(int i = 0; i<16 ; i++)begin
            @(posedge clk);
            bits_in =  arr[i];
            valid = 1'b1;
            @(posedge clk);
            if(data.ready)
                queue.push_back(data.pam_symbol , data.ready);
            else 
                queue.push_back('0,'0);
        end  
    endtask
    task golden_model(input logic [MODULATION_BITS-1:0] in, output symbol_t golden_symbol);
        case(in)
            3'd0: golden_data = -4'sd7;
            3'd1: golden_data = -4'sd5;
            3'd3: golden_data = -4'sd3;
            3'd2: golden_data = -4'sd1;
            3'd6: golden_data = 4'sd1;
            3'd7: golden_data = 4'sd3;
            3'd5: golden_data = 4'sd5;
            3'd4: golden_data = 4'sd7;
    endtask
    task compare_data ();
        symbol_t golden_data;
        symbol_t data_out;
        for(int i = 0; i < queue.size() ; i++)begin
            golden_model(arr[i], golden_data);
            if(golden_data===queue[i].pam_symbol && queue[i].ready == 1'b1)
                correct_data++;
            else begin
                error_data++;
                $display("the data corrupted %0d in index %0d with ready flag %0b", queue[i].pam_symbol ,  i , queue[i].ready);
            end
        end
        $display("the output of the system -> correct items: %0d", correct_data);
        $display("the output of the system -> error items  : %0d", error_data);
       
    endtask
endmodule