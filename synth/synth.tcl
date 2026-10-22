# Run from the project directory: yosys -c synth/synth.tcl

# Locate the SKY130 typical-corner timing library.
if {![info exists ::env(PDK_ROOT)]} {
    error "PDK_ROOT is unset. Run this script inside the EDA container."
}
set lib "$::env(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
if {![file readable $lib]} {
    error "Cannot read SKY130 timing library: $lib"
}

# Read RTL and flatten the full-adder instances into the top-level design.
yosys read_verilog rtl/full_adder.v rtl/mult_array.v
yosys synth -top mult_array -flatten

# Map registers and combinational logic to SKY130 standard cells.
yosys dfflibmap -liberty $lib
yosys abc -liberty $lib

# Clean the netlist and save the area report and gate-level Verilog.
yosys opt_clean -purge
yosys tee -o synth/mult_array_stat.rpt stat -liberty $lib
yosys write_verilog -noattr synth/mult_array_netlist.v
