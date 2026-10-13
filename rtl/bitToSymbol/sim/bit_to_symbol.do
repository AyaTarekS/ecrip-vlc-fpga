vlib work
vlog -f compile.f  +cover -covercells
vsim -voptargs=+acc work.bit_to_symbol_tb -cover 
do wave.do
run -all
#quit -sim