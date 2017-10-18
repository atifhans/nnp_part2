all: sim synth

simp:
	vlib work
	vlog /usr/local/synopsys/syn/dw/sim_ver/DW02_mult*.v
	vlog +acc part3_mac.sv
	vlog +acc memory.sv
	vlog +acc defines_pkg.sv
	vlog +acc mvm3_part1.sv
	vlog +acc mvm3_part1_simple_tb.sv
	vsim check_timing -c -do "run -all"

sim:
	vlib work
	vlog /usr/local/synopsys/syn/dw/sim_ver/DW02_mult*.v
	vlog +acc part3_mac.sv
	vlog +acc memory.sv
	vlog +acc defines_pkg.sv
	vlog +acc mvm3_part1.sv
	vlog +acc mvm3_part1_tb.sv
	vsim tb_part1_mvm -c -do "run -all"

synth:
	dc_shell -f runsynth.tcl | tee output.txt

clean:
	rm -rf *.log *.txt *.svf *.wlf transcript output.txt gates.v work work_synth
