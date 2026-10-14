vlib work
vlog -f compile.f  +cover -covercells
vsim -voptargs=+acc work.ecrip_tb -cover 
do wave.do
run -all
#quit -sim