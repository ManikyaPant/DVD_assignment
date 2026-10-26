# 4-bit Unsigned Array Multiplier: RTL to GDSII (SKY130)

- **Name**: Manikya Pant
- **Roll number**: `2023112024`
- **Name**: Aryan Agrawal
- **Roll number**: `2023102050`
- **Technology**: SkyWater SKY130 (`sky130A`), standard-cell library `sky130_fd_sc_hd`

---

## Repository Architecture

This repository follows the exact file architecture specified in Section 5 of the assignment guide:

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
|   |-- config.json
|   |-- metrics.json
|   `-- mult_array.gds
`-- report/
    |-- report.pdf
    `-- figures/
        |-- partA_block_diagram.png
        |-- partA_waveform.png
        |-- partD_layout_die.png
        `-- partD_layout_zoom.png
```

---

## Exact Commands Run (In Order)

### 0. Environment Setup and Tool Check (Section 4)

Start the IIC-OSIC-TOOLS container with the repository mounted at `/foss/designs/mult4_2023112024` and `sky130A` selected:

```bash
docker run --rm -it \
  -e USER_ID="$(id -u)" -e GROUP_ID="$(id -g)" \
  -e PDK=sky130A -e PDK_ROOT=/foss/pdks -e STD_CELL_LIBRARY=sky130_fd_sc_hd \
  -v "$PWD":/foss/designs/mult4_2023112024 \
  -w /foss/designs/mult4_2023112024 \
  docker.io/hpretl/iic-osic-tools:latest --skip bash -l
```

Inside the container, verify the tools and PDK environment:

```bash
iverilog -V | head -1
yosys -V
sta -version
librelane --version
echo $PDK_ROOT $PDK
```

---

### 1. Part A — RTL Design and Verification (Section 6)

```bash
# Task 4: Compile and run exhaustive self-checking RTL simulation (256 vectors)
iverilog -g2012 -o sim tb/tb_mult.v rtl/full_adder.v rtl/mult_array.v
vvp sim
# -> PASS: 256 vectors checked, 0 errors

# Task 5: View waveform for roll number 2023112024 (last digit 4 -> A = 9, B = 7, P = 63)
gtkwave mult.vcd

# Task 6: Error-injection test (temporarily change sum to a ^ b in rtl/full_adder.v)
sed -i 's/assign sum  = a \^ b \^ cin;/assign sum  = a ^ b;/' rtl/full_adder.v
iverilog -g2012 -o sim tb/tb_mult.v rtl/full_adder.v rtl/mult_array.v
vvp sim
# -> FAIL: 256 vectors checked, 95 errors

# Restore rtl/full_adder.v and confirm PASS again
sed -i 's/assign sum  = a \^ b;/assign sum  = a ^ b ^ cin;/' rtl/full_adder.v
iverilog -g2012 -o sim tb/tb_mult.v rtl/full_adder.v rtl/mult_array.v
vvp sim
# -> PASS: 256 vectors checked, 0 errors
```

---

### 2. Part B — Logic Synthesis with Yosys (Section 7)

```bash
# Task 1 & 2: Synthesize RTL to SKY130 standard cells (writes netlist and area/cell report)
yosys -c synth/synth.tcl

# Task 3: Gate-level simulation of the synthesized netlist with the same testbench
CELLS="$PDK_ROOT/sky130A/libs.ref/sky130_fd_sc_hd/verilog"
iverilog -g2012 -DFUNCTIONAL -DUNIT_DELAY=#1 -o gls \
  tb/tb_mult.v "$CELLS/primitives.v" "$CELLS/sky130_fd_sc_hd.v" \
  synth/mult_array_netlist.v
vvp gls
# -> PASS: 256 vectors checked, 0 errors
```

- **Synthesis summary**: `67` total cells (`16` `sky130_fd_sc_hd__dfrtp_1` flip-flops + `51` logic cells), total area `746.966 µm²`, flip-flop area `400.384 µm²` (`53.60%`).

---

### 3. Part C — Static Timing Analysis with OpenSTA (Section 8)

```bash
# Task 1 (Step 1): Run OpenSTA at T = 10.0 ns to find worst setup slack (WNS)
CLOCK_PERIOD=10.0 sta -exit sta/sta.tcl
# -> worst slack max 7.40 (+7.396 ns in report)
# -> T_min = 10.000 - 7.396 = 2.604 ns (2.60 ns rounded to 0.01 ns)
# -> F_max = 1000 / 2.604 = 384.02 MHz

# Task 1 (Step 2): Re-run OpenSTA at T = T_min = 2.60 ns (default in sta/sta.tcl)
sta -exit sta/sta.tcl
# -> worst slack max -0.00 (-0.004 ns in sta/mult_array_timing.rpt, close to 0)
```

- **Critical path**: `_106_` (`b_reg[0]`) $\rightarrow$ `8` combinational cells (`1` partial-product AND + `7` full-adder cells across `7` full-adder stages) $\rightarrow$ `_100_` (`p[6]`).

---

### 4. Part D — Physical Design: RTL to GDSII with LibreLane (Section 9)

Initial clock period: $1.2 \times T_{\min} = 1.2 \times 2.604 = 3.125\text{ ns}$, rounded up to the next $0.5\text{ ns} = \mathbf{3.5\text{ ns}}$. Following Task 1, `CLOCK_PERIOD` in `pnr/config.json` was increased by $0.5\text{ ns}$ after each setup timing failure in the slow corner (`max_ss_100C_1v60`) until the flow completed with `0` DRC errors, `0` LVS errors, and setup slack $\ge 0$:

```bash
cd pnr
librelane config.json
cd ..

# Copy final metrics and GDSII from the passing 7.0 ns run into pnr/
cp pnr/runs/RUN_*/final/metrics.json      pnr/metrics.json
cp pnr/runs/RUN_*/final/gds/mult_array.gds pnr/mult_array.gds

# View layout in KLayout
klayout pnr/mult_array.gds
```

#### Record of All LibreLane Attempts

| Attempt | `CLOCK_PERIOD` (ns) | Worst Setup Slack (`max_ss`, ns) | Typical Setup Slack (`nom_tt`, ns) | Hold Slack (ns) | DRC | LVS | Outcome |
|---:|---:|---:|---:|---:|---:|---:|---|
| 1 | 3.5 | -3.034 | +0.340 | +0.114 | 0 | 0 | FAIL (setup, `ss` corner) |
| 2 | 4.0 | -2.535 | +0.839 | +0.113 | 0 | 0 | FAIL (setup, `ss` corner) |
| 3 | 4.5 | -2.035 | +1.339 | +0.113 | 0 | 0 | FAIL (setup, `ss` corner) |
| 4 | 5.0 | -1.535 | +1.839 | +0.113 | 0 | 0 | FAIL (setup, `ss` corner) |
| 5 | 5.5 | -1.035 | +2.339 | +0.113 | 0 | 0 | FAIL (setup, `ss` corner) |
| 6 | 6.0 | -0.535 | +2.839 | +0.113 | 0 | 0 | FAIL (setup, `ss` corner) |
| 7 | 6.5 | -0.035 | +3.339 | +0.113 | 0 | 0 | FAIL (setup, `ss` corner) |
| **8** | **7.0** | **+0.465** | **+3.839** | **+0.113** | **0** | **0** | **PASS (final)** |

- **Final physical-design summary**: `CLOCK_PERIOD = 7.0 ns`, worst setup slack `+0.465 ns`, post-route $F_{\max} = 1000 / (7.0 - 0.4646) = \mathbf{153.01\text{ MHz}}$ (`316.34 MHz` nominal), core area `16,900.00 µm²`, wirelength `2,328 µm`, `1,883` total cells (`319` active instances), `0` DRC errors, `0` LVS errors.
