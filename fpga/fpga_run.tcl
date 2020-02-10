set project ariane
set top ariane_single_core
set part $::env(XILINX_PART)


create_project $project . -force -part $part
source flist_vivado.tcl
read_xdc ${project}.xdc
eval "synth_design -top $top -part $part -mode out_of_context $SYN_OPTIONS"
write_checkpoint -force ${project}.post_synth.dcp
write_edif -force ${project}.edf
report_timing_summary -file ${project}.post_synth.timing_summary.rpt
report_utilization -file ${project}.post_synth.util.rpt
write_verilog -mode funcsim -include_xilinx_libs -include_unisim -force ${project}.post_synth.sim.v