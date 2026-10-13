onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /bit_to_symbol_tb/bit_to_symbol_1/clk
add wave -noupdate /bit_to_symbol_tb/bit_to_symbol_1/rst_n
add wave -noupdate -expand -group input_Data -color {Violet Red} /bit_to_symbol_tb/bit_to_symbol_1/bit_in
add wave -noupdate -expand -group input_Data -color {Violet Red} /bit_to_symbol_tb/bit_to_symbol_1/valid_bit
add wave -noupdate /bit_to_symbol_tb/bit_to_symbol_1/count
add wave -noupdate -expand -group {output Data} -color {Sky Blue} /bit_to_symbol_tb/bit_to_symbol_1/symbol_out
add wave -noupdate -expand -group {output Data} -color {Sky Blue} /bit_to_symbol_tb/bit_to_symbol_1/ready
add wave -noupdate -expand -group {output Data} /bit_to_symbol_tb/data_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {95 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 301
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {166 ns}
