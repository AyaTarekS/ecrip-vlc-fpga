vlib work
vlog -f compile.f  +cover -covercells
vsim -voptargs=+acc work.cyclic_prefix_tb -cover 
#do wave.do
run -all
#quit -sim