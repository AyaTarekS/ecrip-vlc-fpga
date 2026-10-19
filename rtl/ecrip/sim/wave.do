onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ecrip_tb/ecrip_design/clk
add wave -noupdate /ecrip_tb/ecrip_design/rst_n
add wave -noupdate -expand -group inputData -color {Medium Violet Red} -radix hexadecimal /ecrip_tb/ecrip_design/real_frame
add wave -noupdate -expand -group inputData -color {Medium Violet Red} -radix hexadecimal /ecrip_tb/ecrip_design/imaj_frame
add wave -noupdate -expand -group inputData -color {Medium Violet Red} /ecrip_tb/ecrip_design/valid
add wave -noupdate /ecrip_tb/ecrip_design/temp
add wave -noupdate -expand -group outputData -color {Sky Blue} /ecrip_tb/ecrip_design/combined_frame
add wave -noupdate -expand -group outputData -color {Sky Blue} /ecrip_tb/ecrip_design/ready
add wave -noupdate -expand -group currentState -color {Medium Aquamarine} /ecrip_tb/ecrip_design/combined_frame_q
add wave -noupdate -expand -group currentState -color {Medium Aquamarine} /ecrip_tb/ecrip_design/ready_q
add wave -noupdate -expand -group nextStateLogic -color {Medium Orchid} /ecrip_tb/ecrip_design/combined_frame_next
add wave -noupdate -expand -group nextStateLogic -color {Medium Orchid} /ecrip_tb/ecrip_design/ready_next
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 341
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
WaveRestoreZoom {0 ns} {843 ns}
