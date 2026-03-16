# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Direct Sampling SDR (Software Defined Radio) implemented in Verilog for Intel MAX 10 FPGA (10M08DAF484C8GES). The project implements a digital receiver/transmitter using direct mixing architecture with NCO-based quadrature signal generation.

## Build Commands

This project uses Intel Quartus Prime Lite Edition v22.1.

```bash
# Open project in Quartus GUI
quartus direct_sampling_sdr.qpf

# Command-line compilation
quartus_sh --flow compile direct_sampling_sdr

# Run Questa simulation
quartus_sim direct_sampling_sdr

# View timing analysis
quartus_sta direct_sampling_sdr
```

**Output files:**
- Bitstream: `output_files/direct_sampling_sdr.sof`
- Programmer file: `output_files/direct_sampling_sdr.pof`
- Reports: `output_files/*.rpt` (sta, fit, map)

## Architecture

### Signal Flow (Receiver Path)

```
wav_in[14-bit] → NCO Mixer → I/Q[14-bit] → CIC(÷256) → FIR(÷10) → i2s
                     ↑
              frequency[27-bit]
```

### Key Modules

| Module | Purpose |
|--------|---------|
| `direct_sampling_sdr.v` | Top-level, direct mixing receiver |
| `nco.v` | LUT-based NCO with 27-bit phase accumulator, sin/cos quadrature output |
| `cic_decimator.v` | 4-stage CIC, 256x decimation |
| `fir_decimator.v` | 256-tap FIR, 10x decimation, configurable coefficients |
| `cic_interpolator.v` | 4-stage CIC, 256x interpolation (TX path) |
| `fir_interpolator.v` | 256-tap FIR, polyphase interpolation (TX path) |
| `timing_generator.v` | Clock dividers: ÷256 (CIC), ÷2560 (FIR/audio) |
| `i2s_interface.v` | I2S transceiver (16-bit stereo, 48kHz) |
| `i2s_timing_generator.v` | I2S clocks: 1.536MHz bit clock, 48kHz frame |
| `spi_interface.v` | SPI command receiver |
| `control_registers.v` | Command interpreter with state machine |

### Clock Domain

- Master clock: 122.88 MHz (8.1ns period constraint in `.sdc`)
- CIC strobe: 480 kHz (÷256)
- Audio/FIR strobe: 48 kHz (÷2560)
- I2S bit clock: 1.536 MHz (÷80)

### Control Commands (via SPI)

Commands defined in `control_registers.v`:
- `0x00-0x03`: FIR coefficient loading (TX/RX, I/Q)
- `0x04`: RX gain set
- `0x05`: Reset
- `0x06`: Set NCO frequency (27-bit, 4-byte sequence)

## Development Notes

- NCO uses trigonometric addition formula with pipelined intermediate results (commit 48b06cf addressed timing)
- FIR memories require registered outputs for timing closure
- Block RAM address generation needs register stage before access
- Code comments are in Japanese

## Simulation

Testbench: `simulation/questa/direct_sampling_sdr.vt`
Simulation script: `simulation/questa/direct_sampling_sdr_run_msim_rtl_verilog.do`

## Target Hardware

BeMicro MAX 10 FPGA Evaluation Kit
