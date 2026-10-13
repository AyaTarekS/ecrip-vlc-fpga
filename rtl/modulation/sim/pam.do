vlib work
vlog -f compile.f  +cover -covercells
vsim -voptargs=+acc work.pam_tb -cover 
#do wave.do
run -all
#quit -sim