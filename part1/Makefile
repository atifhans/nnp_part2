all: sim synth

simp1:
	vlib work
	vlog /usr/local/synopsys/syn/dw/sim_ver/DW02_mult*.v
	vlog +acc mac.sv
	vlog +acc memory.sv
	vlog +acc defines_pkg.sv
	vlog +acc mvm3_part1.sv
	vlog +acc mvm3_part1_simple_tb.sv
	vsim check_timing -c -do "run -all"

simp2:
	vlib work
	vlog /usr/local/synopsys/syn/dw/sim_ver/DW02_mult*.v
	vlog +acc mac.sv
	vlog +acc memory.sv
	vlog +acc defines_pkg.sv
	vlog +acc mvm3_part1.sv
	vlog +acc mvm3_part1_tb2.sv
	vsim check_timing -c -do "run -all"

sim:
	vlib work
	vlog /usr/local/synopsys/syn/dw/sim_ver/DW02_mult*.v
	vlog +acc mac.sv
	vlog +acc memory.sv
	vlog +acc defines_pkg.sv
	vlog +acc mvm3_part1.sv
	vlog +acc mvm3_part1_tb.sv
	vsim tb_part1_mvm -c -do "coverage save -onexit mac_cover.ucdb;run -all" -coverage -voptargs="+cover=bcfst"

sim_gui:
	vsim tb_part1_mvm &

cov_gui:
	vsim tb_part1_mvm -do "coverage save -onexit mac_cover.ucdb;" -coverage -voptargs="+cover=bcfst"
	
cov:
	vcover report -all mac_cover.ucdb

synth:
	dc_shell -f runsynth.tcl | tee output.txt

clean:
	rm -rf *.log *.txt *.svf *.wlf transcript output.txt gates.v work work_synth

clean_db:
	rm -rf alib-52 *.ucdb
