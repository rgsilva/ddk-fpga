onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label clk_i /clk_counter_wb_tb/ci/clk_i
add wave -noupdate -label clk_in /clk_counter_wb_tb/ci/clk_counteri/clk_in
add wave -noupdate -label rst /clk_counter_wb_tb/ci/clk_counteri/rst
add wave -noupdate -label counter_rst /clk_counter_wb_tb/ci/clk_counter_rst
add wave -noupdate -label state /clk_counter_wb_tb/ci/clk_counteri/state
add wave -noupdate -label count -radix unsigned /clk_counter_wb_tb/ci/clk_counteri/count
add wave -noupdate -label ch_start /clk_counter_wb_tb/ci/ch_start
add wave -noupdate -label ch_stop /clk_counter_wb_tb/ci/ch_stop
add wave -noupdate -label edge_start /clk_counter_wb_tb/ci/start
add wave -noupdate -label edge_stop /clk_counter_wb_tb/ci/stop
add wave -noupdate /clk_counter_wb_tb/tb_ch_in
add wave -noupdate /clk_counter_wb_tb/ci/force_rst
add wave -noupdate /clk_counter_wb_tb/ci/clk_counter_rst
add wave -noupdate /clk_counter_wb_tb/read_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1589694 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 196
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1959792 ps}
