<div align="center">
  <h1>➡️ 8-bit SIPO Shift Register</h1>
  <p><strong>Structural sequential RTL with functional and timing-check simulation scenarios</strong></p>
  <p>
    <img src="https://img.shields.io/badge/HDL-SystemVerilog-F97316?style=for-the-badge" alt="SystemVerilog" />
    <img src="https://img.shields.io/badge/Design-Sequential-8B5CF6?style=for-the-badge" alt="Sequential design" />
    <img src="https://img.shields.io/badge/Timing-Specify%20Checks-EC4899?style=for-the-badge" alt="Specify timing checks" />
    <img src="https://img.shields.io/badge/Verification-2%20Scenarios-22C55E?style=for-the-badge" alt="Two verification scenarios" />
  </p>
</div>

---

An 8-bit SIPO shift register built structurally from eight D flip-flops. The flip-flop model includes a `specify` block for clock-to-Q delay and setup, hold, recovery and removal checks.

## Design status

| Item | Status |
|---|---|
| Structural RTL | Implemented |
| Functional/timing-safe testbench | Implemented |
| Intentional timing-violation testbench | Implemented |
| Synthesis/STA reports | Not included |

## Specification

| Property | Value |
|---|---|
| Top module | `sipo8bit` |
| Storage | 8 D flip-flops |
| Shift event | Rising edge of `clk` |
| Reset | Asynchronous active low (`rstn`) |
| Serial entry point | `parallel_out[0]` |
| Shift direction | Toward `parallel_out[7]` |

At every rising edge while reset is inactive:

```text
q[0] <= serial_in
q[1] <= q[0]
...
q[7] <= q[6]
```

After eight accepted clock edges, the first transmitted bit reaches `parallel_out[7]` and the most recent bit is at `parallel_out[0]`.

### Interface

| Port | Direction | Width | Description |
|---|---|---:|---|
| `clk` | Input | 1 | Shift clock |
| `rstn` | Input | 1 | Asynchronous active-low reset |
| `serial_in` | Input | 1 | Serial data bit |
| `parallel_out` | Output | 8 | Current contents of all stages |

## Timing model

`flipflopD.sv` declares these simulation timing values:

| Check/path | Value |
|---|---:|
| Clock-to-Q rise/fall | 1.5 ns |
| Reset-to-Q | 1.0 ns |
| Setup | 2.0 ns |
| Hold | 1.0 ns |
| Recovery | 2.0 ns |
| Removal | 1.0 ns |

The `specify` block is for timing-aware simulation. Synthesis tools normally ignore it, and some simulators require timing checks to be explicitly enabled.

## Repository structure

```text
.
├── rtl/
│   ├── flipflopD.sv
│   └── sipo_8_bit.sv
└── tb/
    ├── sipo_8_bit_non_violation.sv
    └── sipo_8_bit_violation.sv
```

## Verification

### Non-violation regression

The self-checking testbench applies serial data on the falling edge, waits for the following rising edge plus clock-to-Q delay and compares against a reference shift register. It checks initial reset, safe reset release, eight shifted bits, asynchronous reset during operation and shifting after reset.

The transmitted sequence `1 0 1 1 0 0 1 0` is expected to produce `8'b1011_0010`.

### Violation test

The second testbench intentionally changes data/reset inside the declared timing windows. A timing-capable simulator should report:

1. setup violation on the first stage;
2. hold violation on the first stage;
3. recovery violations on reset release;
4. removal violations on reset release.

### Questa/ModelSim example

```tcl
vlib work
vlog -sv rtl/flipflopD.sv rtl/sipo_8_bit.sv
vlog -sv tb/sipo_8_bit_non_violation.sv tb/sipo_8_bit_violation.sv
vsim -c -t 1ps work.sipo8bit_tb_no_violation -do "run -all; quit -f"
vsim -c -t 1ps work.sipo8bit_tb_violation -do "run -all; quit -f"
```

## Limitations

- There is no shift enable; the register shifts on every rising edge outside reset.
- There is no `valid` or word-complete indication.
- Timing values are educational model values, not extracted delays from a characterized cell library.
