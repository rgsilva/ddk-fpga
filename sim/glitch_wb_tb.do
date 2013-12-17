onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -label tb_clk /glitch_wb_tb/tb_clk
add wave -noupdate -label tb_rst /glitch_wb_tb/tb_rst

add wave -noupdate -divider

add wave -noupdate -label tb_stb_o /glitch_wb_tb/tb_stb_o
add wave -noupdate -label tb_we_o_str -radix ascii /glitch_wb_tb/tb_we_o_str
add wave -noupdate -label tb_adr_o_str -radix ascii /glitch_wb_tb/tb_adr_o_str
add wave -noupdate -label tb_dat_o -radix hexadecimal /glitch_wb_tb/tb_dat_o
add wave -noupdate -label tb_dat_i -radix hexadecimal /glitch_wb_tb/tb_dat_i

add wave -noupdate -divider

add wave -noupdate -label width -radix hexadecimal /glitch_wb_tb/gi/glitchi/glitch_width
add wave -noupdate -label width_cnt -radix hexadecimal /glitch_wb_tb/gi/glitchi/width_cnt
add wave -noupdate -label delay -radix hexadecimal /glitch_wb_tb/gi/glitchi/glitch_delay
add wave -noupdate -label delay_cnt -radix hexadecimal /glitch_wb_tb/gi/glitchi/delay_cnt
add wave -noupdate -label tb_state_str -radix ascii /glitch_wb_tb/tb_state_str

add wave -noupdate -divider

add wave -noupdate -label ready /glitch_wb_tb/gi/ready
add wave -noupdate -label core_en /glitch_wb_tb/gi/glitchi/glitch_corei/en
add wave -noupdate -label tb_clk_in /glitch_wb_tb/tb_clk_in
add wave -noupdate -label tb_clk_gl /glitch_wb_tb/tb_clk_gl
add wave -noupdate -label tb_mode_str -radix ascii /glitch_wb_tb/tb_mode_str
add wave -noupdate -label tb_clk_out /glitch_wb_tb/tb_clk_out

add wave -noupdate -divider

add wave -noupdate -label full /glitch_wb_tb/gi/fifoi/FULL
add wave -noupdate -label empty /glitch_wb_tb/gi/fifoi/EMPTY
add wave -noupdate -label reset /glitch_wb_tb/gi/fifoi/RESET

TreeUpdate [SetDefaultTree]
