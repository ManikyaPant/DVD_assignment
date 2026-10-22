# Part B: Logic synthesis

Results from `synth/mult_array_stat.rpt` and `report/part_b_gls.log`,
using the SKY130 `sky130_fd_sc_hd` typical-corner library.

| Metric | Value |
| --- | --- |
| Total number of cells | 67 |
| Number of flip-flops | 16 |
| Total cell area | 746.966400 um^2 |
| Flip-flop area | 400.384000 um^2 |
| Flip-flop area (% of total) | 53.60% |
| Most-used cell type | `sky130_fd_sc_hd__dfrtp_1`: 16 |
| Second most-used cell type | `sky130_fd_sc_hd__nand2_1`: 12 |
| Third most-used cell type | `sky130_fd_sc_hd__xnor2_1`: 7 |
| Netlist simulation | PASS: 256 vectors checked, 0 errors |

The combinational logic uses 67 - 16 = 51 cells. Synthesis maps the
full-adder logic into library gates and optimizes shared and constant logic,
so each full adder does not correspond to one standard cell.
The 16 flip-flops occupy 53.60% of the area because this small multiplier
registers both its eight input bits and its eight output bits.

## Reproduce

Run from the multiplier project directory inside the EDA container with
`PDK_ROOT` set:

```bash
set -o pipefail
yosys -c synth/synth.tcl 2>&1 | tee report/part_b_synthesis.log
CELLS="$PDK_ROOT/sky130A/libs.ref/sky130_fd_sc_hd/verilog"
iverilog -g2012 -DFUNCTIONAL '-DUNIT_DELAY=#1' -o gls \
  tb/tb_mult.v "$CELLS/primitives.v" "$CELLS/sky130_fd_sc_hd.v" \
  synth/mult_array_netlist.v
vvp gls 2>&1 | tee report/part_b_gls.log
```

These numbers and the PASS line describe the saved run; simulation was not
rerun while preparing this commit.
