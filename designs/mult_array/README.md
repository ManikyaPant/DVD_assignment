# 4-bit Array Multiplier: RTL to GDSII

## Team

- Member 1: TODO name and roll number
- Member 2: TODO name and roll number

## Working directory

Host: `/home/ubuntu-user/sem7/dvd/designs/mult_array`
Container: `/foss/designs/mult_array`

## Command log

Record the exact commands you run for each assignment step, in order.

## Files

RTL, simulation, synthesis, and timing-analysis source files are implemented.
The physical-design configuration is prepared; final physical-design artifacts
and the completed report PDF are pending.

## Part D: physical design

Initial configured clock period: 3.5 ns, calculated by rounding
1.2 × 2.604 ns up to the next 0.5 ns. Die size: 150 × 150 µm.

Run inside the container:

```bash
cd /foss/designs/mult_array/pnr
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
