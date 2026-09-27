# UART Transceiver (SystemVerilog)
Configurable UART TX/RX transceiver written in SystemVerilog, with a loopback testbench for verification.

## Features
- Configurable baud rate and system clock frequency (via `BAUD_RATE` and `CLK_FREQ` parameters)
- 8-bit parallel data, 1 start bit, 1 stop bit, LSB-first
- Independent TX and RX datapaths with `busy`/`done`/`valid` status signals
- 2-flip-flop synchronizer on the RX input to guard against metastability
- Self-checking loopback testbenches (TX → RX) for each module and for the full top level

## Repository structure
```
uart-transceiver-rtl/
├── rtl/
│   ├── uart_top.sv     # Top-level: integrates TX, RX, and RX synchronizer
│   ├── uart_tx.sv       # UART transmitter (FSM: IDLE -> START -> DATA -> STOP)
│   ├── uart_rx.sv       # UART receiver (FSM: IDLE -> START -> DATA -> DONE)
│   └── sync_2ff.sv      # 2-FF synchronizer for the async RX input
├── tb/
│   ├── tb_uart_top.sv   # Loopback testbench for the full transceiver
│   ├── tb_uart_tx.sv    # Standalone testbench for uart_tx
│   └── tb_uart_rx.sv    # Standalone testbench for uart_rx
├── sim/                 # Compiled simulations and waveform dumps (.vcd)
└── docs/                # Waveform screenshots (uart_top, uart_tx, uart_rx)
```

## Module: `uart_top`
Top-level module wiring the transmitter, receiver, and input synchronizer together.

| Parameter    | Default      | Description                  |
|--------------|--------------|-------------------------------|
| `BAUD_RATE`  | `9600`       | Target UART baud rate         |
| `CLK_FREQ`   | `50_000_000` | System clock frequency (Hz)   |

| Port        | Direction | Width | Description                          |
|-------------|-----------|-------|---------------------------------------|
| `clk`       | input     | 1     | System clock                          |
| `reset`     | input     | 1     | Active-high reset                     |
| `start_tx`  | input     | 1     | Pulse high to start a transmission    |
| `data_tx`   | input     | 8     | Byte to transmit                      |
| `rx`        | input     | 1     | Serial data input                     |
| `tx`        | output    | 1     | Serial data output                    |
| `busy_tx`   | output    | 1     | High while a transmission is in progress |
| `done_tx`   | output    | 1     | Single-cycle pulse when TX completes  |
| `data_rx`   | output    | 8     | Last byte received                    |
| `valid_rx`  | output    | 1     | Single-cycle pulse when a valid byte is received |
`uart_tx` and `uart_rx` can also be instantiated on their own; they share the same `BAUD_RATE`/`CLK_FREQ` parameters and the corresponding subset of the ports above.
## Getting started

### Requirements
- [Icarus Verilog](http://iverilog.icarus.com/) (`iverilog` / `vvp`)
- [GTKWave](http://gtkwave.sourceforge.net/) (optional, to view `.vcd` waveforms)

### Running the loopback simulation
```bash
# From the repository root
iverilog -g2012 -o sim/uart_top_sim rtl/uart_top.sv rtl/uart_tx.sv rtl/uart_rx.sv rtl/sync_2ff.sv tb/tb_uart_top.sv
vvp sim/uart_top_sim
```

This drives three data patterns (`0x55`, `0xA5`, `0x3C`) through the TX output looped back into RX, and checks that the received byte matches what was sent, printing `TEST n PASSED`/`FAILED` for each.

To inspect the waveform:

```bash
gtkwave sim/tb_uart_top.vcd
```

### Running the standalone TX / RX testbenches
```bash
iverilog -g2012 -o sim/uart_tx_sim rtl/uart_tx.sv tb/tb_uart_tx.sv
vvp sim/uart_tx_sim

iverilog -g2012 -o sim/uart_rx_sim rtl/uart_rx.sv tb/tb_uart_rx.sv
vvp sim/uart_rx_sim
```

## Waveforms
Example simulation waveforms (captured in GTKWave) are available in [`docs/`](docs):

- `uart_top.jpg` — full TX → RX loopback
- `uart_tx.jpg` — transmitter FSM
- `uart_rx.jpg` — receiver FSM

## Author
Truong Thanh Nhan
