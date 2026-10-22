# Part C: Static Timing Analysis

SKY130 sky130_fd_sc_hd, typical corner tt_025C_1v80; pre-layout timing
with ideal clock and no extracted interconnect parasitics.

| Metric | Value |
|---|---|
| Worst setup slack at 10 ns | +7.396 ns |
| Calculated minimum period | 2.604 ns (10 - 7.396) |
| Maximum frequency from calculated period | approximately 384.02 MHz |
| Rounded period tested | 2.60 ns |
| Setup slack at rounded period | -0.004 ns |
| Critical path start | _106_/Q, b_reg[0] |
| Critical path end | _100_/D, output register p[6] |
| Combinational cells on critical path | 8 |
| Cells including launch and capture flip-flops | 10 |
| Latency at calculated minimum period | 5.208 ns |
| Throughput at calculated minimum period | approximately 384.02 million results/s |

The rounded 2.60 ns period has a small setup violation of about 4 ps,
consistent with the assignment requirement to confirm slack near zero.
It is not a strictly timing-clean period. 2.61 ns would provide a small
positive margin under the same analysis conditions; it has not been tested.

## Critical path in order

| Instance | Cell type | Role |
|---|---|---|
| _106_ | sky130_fd_sc_hd__dfrtp_1 | Launch register, b_reg[0] |
| _043_ | sky130_fd_sc_hd__and2_0 | Partial-product AND |
| _056_ | sky130_fd_sc_hd__or3_1 | Combinational addition logic |
| _058_ | sky130_fd_sc_hd__a32oi_1 | Combinational addition logic |
| _072_ | sky130_fd_sc_hd__o21ba_1 | Combinational addition logic |
| _073_ | sky130_fd_sc_hd__xnor2_1 | Combinational addition logic |
| _082_ | sky130_fd_sc_hd__maj3_1 | Combinational addition logic |
| _084_ | sky130_fd_sc_hd__maj3_1 | Combinational addition logic |
| _086_ | sky130_fd_sc_hd__xnor3_1 | Combinational addition logic |
| _100_ | sky130_fd_sc_hd__dfrtp_1 | Capture register, p[6] |

The path traverses one partial-product AND and seven mapped cells in the
optimized addition network. These seven standard cells are not seven full
adders. Flattening and ABC optimization can combine logic across full-adder
boundaries, so an exact count of original full-adder stages cannot be inferred
from this timing report alone. The PDF estimate of about 2N = 8 full-adder
delays describes the original architecture, rather than the mapped cell count.

The report also lists a reset recovery path with +1.828 ns slack at 2.60 ns;
the register-to-register setup path is the limiting path.

## Commands run

```bash
sta sta/sta.tcl 2>&1 | tee report/part_c_10ns.log
CLOCK_PERIOD=2.60 sta sta/sta.tcl 2>&1 | tee report/part_c_tmin.log
```

## Evidence

- report/part_c_10ns.log
- report/part_c_10ns_timing.rpt
- report/part_c_tmin.log
- sta/mult_array_timing.rpt

These notes should be incorporated into the final report PDF.
