# 4-bit Array Multiplier: RTL to GDSII

Name: Manikya Pant

Roll number: 2023112024

## Repository layout

Clone this repository as `mult4_2023112024`. Run all design commands from
its root. This revision publishes Parts A and B only, using the directory
names and required filenames from Section 5 of the assignment.

```text
mult4_2023112024/
|-- README.md
|-- rtl/
|   |-- full_adder.v
|   `-- mult_array.v
|-- tb/
|   `-- tb_mult.v
|-- synth/
|   |-- synth.tcl
|   |-- mult_array_netlist.v
|   `-- mult_array_stat.rpt
`-- report/
    |-- part_a_pass.log
    |-- part_a_fail.log
    |-- part_b_results.md
    |-- part_b_synthesis.log
    `-- part_b_gls.log
```

The results notes and saved logs are supporting evidence for the final
report. Simulation executables and waveforms are excluded from Git.

## Working directory

Host checkout in this workspace: `/home/ubuntu-user/sem7/dvd`.
Container project directory: `/foss/designs/mult4_2023112024`.

Mount the repository root at that container directory. An existing container
that mounted only the former `designs/` directory must be recreated with the
new bind mount. For a command-line session, run from the repository root:

```bash
docker run --rm -it \
  --mount "type=bind,source=$PWD,target=/foss/designs/mult4_2023112024" \
  docker.io/hpretl/iic-osic-tools:latest bash -l
```

## Simulation and synthesis commands

The saved logs record runs made before the repository was reorganized.
Their design-relative paths remain valid. To reproduce those steps with
the new layout, run inside the EDA container with `PDK_ROOT` set:

```bash
cd /foss/designs/mult4_2023112024
set -o pipefail

# Part A: RTL verification.
iverilog -g2012 -o sim tb/tb_mult.v rtl/full_adder.v rtl/mult_array.v
vvp sim 2>&1 | tee report/part_a_pass.log

# Part B: synthesis and gate-level verification.
yosys -c synth/synth.tcl 2>&1 | tee report/part_b_synthesis.log
CELLS="$PDK_ROOT/sky130A/libs.ref/sky130_fd_sc_hd/verilog"
iverilog -g2012 -DFUNCTIONAL '-DUNIT_DELAY=#1' -o gls \
  tb/tb_mult.v "$CELLS/primitives.v" "$CELLS/sky130_fd_sc_hd.v" \
  synth/mult_array_netlist.v
vvp gls 2>&1 | tee report/part_b_gls.log
```
