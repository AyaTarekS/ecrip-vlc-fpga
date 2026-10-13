import ofdm_pkg::*;
module bit_to_symbol_tb();
    bit clk; bit rst_n;
    logic bit_in;
    logic valid_bit;
    int correct_data, error_data;


    typedef struct {
        logic [MODULATION_BITS-1:0] symbol_out;
        logic ready;
        logic [1:0] count;
        int index;     
    } data_t;

    data_t data_out;
    data_t queue[$];
    logic [MODULATION_BITS-1:0] arr [16] ='{
       3'b101,3'b111,3'b000,3'b010,
       3'b110,3'b011,3'b001,3'b100,
       3'b000,3'b111,3'b101,3'b010,
       3'b110,3'b011,3'b001,3'b100
    };
    
    //clk generation
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    //module instantiation 
    bit_to_symbol bit_to_symbol_1(.clk(clk),.rst_n(rst_n),
    .bit_in(bit_in),.valid_bit(valid_bit),.symbol_out(data_out.symbol_out),
    .ready(data_out.ready));

    initial begin
        assert_reset();
        @(posedge clk);
        generate_data();
        @(posedge clk);
        compare_data();
        $finish();

    end



    task assert_reset();
        rst_n = 1'b0;
        repeat(3) @(posedge clk);
        rst_n = 1;
        @(posedge clk);
    endtask
    task generate_data();
        //16 case
        data_out.count = '0;
        data_out.index = '0;
        for(int i = 0; i < 16 ; i++)begin
            for(int j = 0 ; j < 3 ;  j++)begin
                @(posedge clk);
                valid_bit = 1'b1;
                bit_in = arr[i][j];
                data_out.count = j;
                data_out.index = i;
                @(posedge clk);
                valid_bit = 1'b0;

            end
            @(posedge clk);
            if(data_out.ready)begin
                queue.push_back(data_out);
            end
            else queue.push_back('{'0,'0,'0,'0});
            @(posedge clk);
        end
    endtask
    task compare_data();
        data_t golden_data;
        data_t data;
        for(int k = 0; k < queue.size() ; k++)begin
            golden_data.symbol_out = arr[k];
            data = queue[k];
            if(golden_data.symbol_out === data.symbol_out && data.count == 2'd2 && data.ready == 1'b1)
                correct_data++;
            else begin
                error_data++;
                $display("the error in index : %0d, the data output is :%0b, the count is :%0b and the ready is: %0b",k, data.symbol_out, data.count, data.ready);
            end
        end
        $display("the output of the system -> correct items: %0d", correct_data);
        $display("the output of the system -> error items  : %0d", error_data);

    endtask
endmodule