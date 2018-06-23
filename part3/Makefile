all: sim synth

sim:
	vlib work
	vlog /usr/local/synopsys/syn/dw/sim_ver/DW02_mult*.v
	vlog +acc defines_pkg.sv
	vlog +acc mac.sv
	vlog +acc memory.sv
	vlog +acc mvma4_part3.sv
	vlog +acc mvma4_part3_tb.sv
	vsim tb_part3_mvm -c -do "coverage save -onexit mac_cover.ucdb;run -all" -coverage -voptargs="+cover=bcfst"

sim_gui:
	vsim tb_part3_mvm &

cov_gui:
	vsim tb_part3_mvm -do "coverage save -onexit mac_cover.ucdb;" -coverage -voptargs="+cover=bcfst"
	
cov:
	vcover report -all mac_cover.ucdb

synth:
	dc_shell -f runsynth.tcl | tee output.txt

clean:
	rm -rf *.log *.txt *.svf *.wlf transcript output.txt gates.v work work_synth

clean_db:
	rm -rf alib-52 *.ucdb
