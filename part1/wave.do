onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix decimal /tb_part2_mac/a
add wave -noupdate -radix decimal /tb_part2_mac/b
add wave -noupdate -radix decimal /tb_part2_mac/clk
add wave -noupdate -radix decimal /tb_part2_mac/f
add wave -noupdate -radix decimal -childformat {{{/tb_part2_mac/idx[31]} -radix decimal} {{/tb_part2_mac/idx[30]} -radix decimal} {{/tb_part2_mac/idx[29]} -radix decimal} {{/tb_part2_mac/idx[28]} -radix decimal} {{/tb_part2_mac/idx[27]} -radix decimal} {{/tb_part2_mac/idx[26]} -radix decimal} {{/tb_part2_mac/idx[25]} -radix decimal} {{/tb_part2_mac/idx[24]} -radix decimal} {{/tb_part2_mac/idx[23]} -radix decimal} {{/tb_part2_mac/idx[22]} -radix decimal} {{/tb_part2_mac/idx[21]} -radix decimal} {{/tb_part2_mac/idx[20]} -radix decimal} {{/tb_part2_mac/idx[19]} -radix decimal} {{/tb_part2_mac/idx[18]} -radix decimal} {{/tb_part2_mac/idx[17]} -radix decimal} {{/tb_part2_mac/idx[16]} -radix decimal} {{/tb_part2_mac/idx[15]} -radix decimal} {{/tb_part2_mac/idx[14]} -radix decimal} {{/tb_part2_mac/idx[13]} -radix decimal} {{/tb_part2_mac/idx[12]} -radix decimal} {{/tb_part2_mac/idx[11]} -radix decimal} {{/tb_part2_mac/idx[10]} -radix decimal} {{/tb_part2_mac/idx[9]} -radix decimal} {{/tb_part2_mac/idx[8]} -radix decimal} {{/tb_part2_mac/idx[7]} -radix decimal} {{/tb_part2_mac/idx[6]} -radix decimal} {{/tb_part2_mac/idx[5]} -radix decimal} {{/tb_part2_mac/idx[4]} -radix decimal} {{/tb_part2_mac/idx[3]} -radix decimal} {{/tb_part2_mac/idx[2]} -radix decimal} {{/tb_part2_mac/idx[1]} -radix decimal} {{/tb_part2_mac/idx[0]} -radix decimal}} -subitemconfig {{/tb_part2_mac/idx[31]} {-height 16 -radix decimal} {/tb_part2_mac/idx[30]} {-height 16 -radix decimal} {/tb_part2_mac/idx[29]} {-height 16 -radix decimal} {/tb_part2_mac/idx[28]} {-height 16 -radix decimal} {/tb_part2_mac/idx[27]} {-height 16 -radix decimal} {/tb_part2_mac/idx[26]} {-height 16 -radix decimal} {/tb_part2_mac/idx[25]} {-height 16 -radix decimal} {/tb_part2_mac/idx[24]} {-height 16 -radix decimal} {/tb_part2_mac/idx[23]} {-height 16 -radix decimal} {/tb_part2_mac/idx[22]} {-height 16 -radix decimal} {/tb_part2_mac/idx[21]} {-height 16 -radix decimal} {/tb_part2_mac/idx[20]} {-height 16 -radix decimal} {/tb_part2_mac/idx[19]} {-height 16 -radix decimal} {/tb_part2_mac/idx[18]} {-height 16 -radix decimal} {/tb_part2_mac/idx[17]} {-height 16 -radix decimal} {/tb_part2_mac/idx[16]} {-height 16 -radix decimal} {/tb_part2_mac/idx[15]} {-height 16 -radix decimal} {/tb_part2_mac/idx[14]} {-height 16 -radix decimal} {/tb_part2_mac/idx[13]} {-height 16 -radix decimal} {/tb_part2_mac/idx[12]} {-height 16 -radix decimal} {/tb_part2_mac/idx[11]} {-height 16 -radix decimal} {/tb_part2_mac/idx[10]} {-height 16 -radix decimal} {/tb_part2_mac/idx[9]} {-height 16 -radix decimal} {/tb_part2_mac/idx[8]} {-height 16 -radix decimal} {/tb_part2_mac/idx[7]} {-height 16 -radix decimal} {/tb_part2_mac/idx[6]} {-height 16 -radix decimal} {/tb_part2_mac/idx[5]} {-height 16 -radix decimal} {/tb_part2_mac/idx[4]} {-height 16 -radix decimal} {/tb_part2_mac/idx[3]} {-height 16 -radix decimal} {/tb_part2_mac/idx[2]} {-height 16 -radix decimal} {/tb_part2_mac/idx[1]} {-height 16 -radix decimal} {/tb_part2_mac/idx[0]} {-height 16 -radix decimal}} /tb_part2_mac/idx
add wave -noupdate -radix decimal /tb_part2_mac/mac_m
add wave -noupdate -radix decimal /tb_part2_mac/overflow
add wave -noupdate -radix decimal /tb_part2_mac/reset
add wave -noupdate -radix decimal /tb_part2_mac/valid_in
add wave -noupdate -radix decimal /tb_part2_mac/valid_out
add wave -noupdate -radix decimal /tb_part2_mac/dut/a
add wave -noupdate -radix decimal /tb_part2_mac/dut/a_int
add wave -noupdate -radix decimal /tb_part2_mac/dut/b
add wave -noupdate -radix decimal /tb_part2_mac/dut/b_int
add wave -noupdate -radix decimal /tb_part2_mac/dut/c_int
add wave -noupdate -radix decimal /tb_part2_mac/dut/clk
add wave -noupdate -radix decimal /tb_part2_mac/dut/d_int
add wave -noupdate -radix decimal /tb_part2_mac/dut/enable_f
add wave -noupdate -radix decimal /tb_part2_mac/dut/f
add wave -noupdate -radix decimal /tb_part2_mac/dut/overflow
add wave -noupdate -radix decimal /tb_part2_mac/dut/overflow_int
add wave -noupdate -radix decimal /tb_part2_mac/dut/reset
add wave -noupdate -radix decimal /tb_part2_mac/dut/valid_in
add wave -noupdate -radix decimal /tb_part2_mac/dut/valid_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 ns} {37 ns}
