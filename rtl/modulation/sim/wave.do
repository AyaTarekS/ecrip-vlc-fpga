onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /pam_tb/pam_design/clk
add wave -noupdate /pam_tb/pam_design/rst_n
add wave -noupdate -expand -group inputData -color {Sky Blue} -radix decimal /pam_tb/pam_design/bits_in
add wave -noupdate -expand -group inputData -color {Sky Blue} /pam_tb/pam_design/valid
add wave -noupdate -expand -group outputData -color {Medium Violet Red} -radix decimal /pam_tb/pam_design/pam_symbol
add wave -noupdate -expand -group outputData -color {Medium Violet Red} /pam_tb/pam_design/ready
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 346
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
WaveRestoreZoom {0 ns} {839 ns}
