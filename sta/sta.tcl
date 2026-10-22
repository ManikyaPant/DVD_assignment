# Run from the repository root: sta -exit sta/sta.tcl
# To check a different period: CLOCK_PERIOD=6.00 sta -exit sta/sta.tcl

if {![info exists ::env(PDK_ROOT)]} {
    error "PDK_ROOT is unset. Run OpenSTA inside the EDA container."
}
set lib "$::env(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
if {![file readable $lib]} {
    error "Cannot read SKY130 timing library: $lib"
}

set period 10.0
if {[info exists ::env(CLOCK_PERIOD)]} {
    set period $::env(CLOCK_PERIOD)
}
if {![string is double -strict $period] || $period <= 0} {
    error "CLOCK_PERIOD must be a positive number in ns."
}

read_liberty $lib
read_verilog synth/mult_array_netlist.v
link_design mult_array

create_clock -name clk -period $period [get_ports clk]
set_input_delay 1.0 -clock clk [delete_from_list [all_inputs] [get_ports clk]]
set_output_delay 1.0 -clock clk [all_outputs]

puts "Timing analysis: clock period = $period ns"
report_worst_slack -max
report_checks -path_delay max -digits 3 > sta/mult_array_timing.rpt

exit
