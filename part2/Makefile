all: sim synth

sim:
	vlib work
	vlog /usr/local/synopsys/syn/dw/sim_ver/DW02_mult*.v
	vlog +acc mac.sv
	vlog +acc memory.sv
	vlog +acc defines_pkg.sv
	vlog +acc mvm3_part2.sv
	vlog +acc mvm3_part2_tb.sv
	vsim tb_part2_mvm -c -do "run -all"

synth:
	dc_shell -f runsynth.tcl | tee output.txt

clean:
	rm -rf *.log *.txt *.svf *.wlf transcript output.txt gates.v work work_synth
