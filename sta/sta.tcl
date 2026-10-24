# Run from the repository root: sta -exit sta/sta.tcl
# First run at T = 10 ns: CLOCK_PERIOD=10.0 sta -exit sta/sta.tcl
# Second run at T = T_min = 2.60 ns (default): sta -exit sta/sta.tcl

if {![info exists ::env(PDK_ROOT)]} {
    error "PDK_ROOT is unset. Run OpenSTA inside the EDA container."
}
set lib "$::env(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
if {![file readable $lib]} {
    error "Cannot read SKY130 timing library: $lib"
}

set period 2.60
if {[info exists ::env(CLOCK_PERIOD)]} {
    set period $::env(CLOCK_PERIOD)
} elseif {[info exists ::env(STA_PERIOD)]} {
    set period $::env(STA_PERIOD)
} elseif {[info exists ::env(T)]} {
    set period $::env(T)
}
if {![string is double -strict $period] || $period <= 0} {
    error "Clock period must be a positive number in ns."
}

# 1. Read the cell timing library
read_liberty $lib

# 2. Read and link the netlist
read_verilog synth/mult_array_netlist.v
link_design mult_array

# 3. Define the clock with period T in ns
create_clock -name clk -period $period [get_ports clk]

# 4. Input arrival time
set_input_delay 1.0 -clock clk [delete_from_list [all_inputs] [get_ports clk]]

# 5. Output required time
set_output_delay 1.0 -clock clk [all_outputs]

# 6. Print the worst setup slack
puts "Timing analysis: clock period = $period ns"
report_worst_slack -max

# 7. Save the critical path report
report_checks -path_delay max -digits 3 > sta/mult_array_timing.rpt

exit
