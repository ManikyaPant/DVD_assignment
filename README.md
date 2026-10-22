# 4-bit Array Multiplier: RTL to GDSII

Name: Manikya Pant

Roll number: 2023112024

## Repository layout

Clone this repository as `mult4_2023112024`. Run all design commands from
its root; the directory names and required filenames follow Section 5 of
the assignment.

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
|-- sta/
|   |-- sta.tcl
|   `-- mult_array_timing.rpt
|-- pnr/
|   `-- config.json
`-- report/
    |-- part_b_results.md
    `-- part_c_results.md
```

Final submission files still pending: `pnr/metrics.json`,
`pnr/mult_array.gds`, and `report/report.pdf`. The results notes and saved
logs are supporting evidence for the final report. Physical-design runs,
simulation executables, and waveforms are excluded from Git.

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

## Simulation, synthesis, and timing commands

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

# Part C: typical-corner timing at 10 ns, then near the minimum period.
sta -exit sta/sta.tcl 2>&1 | tee report/part_c_10ns.log
cp sta/mult_array_timing.rpt report/part_c_10ns_timing.rpt
CLOCK_PERIOD=2.60 sta -exit sta/sta.tcl 2>&1 | tee report/part_c_tmin.log
```

## Part D: physical design

Initial configured clock period: 3.5 ns, calculated by rounding
1.2 × 2.604 ns up to the next 0.5 ns. Die size: 150 × 150 µm.

Run inside the container:

```bash
cd /foss/designs/mult4_2023112024/pnr
set -o pipefail
python3 -m librelane config.json 2>&1 | tee "../report/part_d_$(date +%Y%m%d_%H%M%S).log"
```

Record each actual run below with its run directory, clock period, completion
status, setup slack, DRC errors, and LVS errors. No Part D run has completed successfully yet. If setup slack is negative, increase CLOCK_PERIOD by 0.5 ns and rerun.
Copy the successful run's final metrics and GDS into pnr/ for submission.
The runs/ directory is excluded by the workspace .gitignore.


### Failed attempts inspected

| Run directory | Period | PDK actually selected | Outcome |
|---|---|---|---|
| RUN_2026-10-10_13-34-41 | 3.5 ns | ihp-sg13g2 | Failed at OpenROAD.STAPrePNR with a scene error |
| RUN_2026-10-11_20-46-00 | 3.5 ns | ihp-sg13g2 | Failed at OpenROAD.STAPrePNR with a scene error |

The configuration now explicitly selects sky130A and sky130_fd_sc_hd.
The previous runs used the container default PDK, not the assignment technology.
DRC, LVS, routing, and final GDS have not completed in those runs.
Whether the scene error also occurs with SKY130 remains to be checked.


| Additional run | Period | PDK selected | Outcome |
|---|---|---|---|
| RUN_2026-10-11_20-49-59 | 3.5 ns | sky130A / sky130_fd_sc_hd | Failed at OpenROAD.STAPrePNR with the same scene error |

The explicit SKY130 selection is verified in the resolved run configuration.
The scene error persists across PDKs and needs tool/script compatibility diagnosis.


### Timing attempt after scene compatibility repair

RUN_2026-10-11_20-58-08 used SKY130 at 3.5 ns and reached final views.
DRC and LVS passed, but the flow failed final setup checks in
max_ss_100C_1v60, min_ss_100C_1v60, and nom_ss_100C_1v60.
The next configured period is 4.0 ns, increasing by 0.5 ns as required.
This next attempt has not yet been verified.


RUN_2026-10-11_21-04-05: 4.0 ns, SKY130, final DRC/LVS/hold checks passed.
Final setup slack: -1.550177 ns; slow corners failed.
Next configured attempt: 4.5 ns, following the required 0.5 ns increment.


RUN_2026-10-11_21-08-57: 4.5 ns, SKY130, final DRC/LVS checks had zero errors.
Worst hold slack: +0.138522 ns. Worst setup slack: -1.050177 ns.
Slow-corner setup checks still failed. Next configured attempt: 5.0 ns.


Clock period increased from the configured 5.0 ns to 5.5 ns at the user's
request. No saved 5.0 ns run was found; the latest verified attempt remains
4.5 ns with -1.050177 ns setup slack. The 5.5 ns run is pending.


RUN_2026-10-11_21-19-25: 5.5 ns, SKY130, final DRC/LVS checks had zero errors.
Worst hold slack: +0.139540 ns. Worst setup slack: -0.080239 ns.
Slow-corner setup checks still failed. Next configured attempt: 6.0 ns.
