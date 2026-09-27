//=====================================================================
// Project      : UART Transceiver
// Module       : uart_top
// File         : uart_top.sv
// Description  : Top-level UART transceiver module.
//                Integrates UART transmitter, receiver, and RX input
//                synchronizer.
//
// Features:
//   - UART transmitter integration
//   - UART receiver integration
//   - Two-flip-flop RX input synchronizer
//   - Configurable baud rate
//   - Configurable system clock frequency
//   - Independent TX and RX data paths
//
// Author       : Truong Thanh Nhan
// Language     : SystemVerilog
//=====================================================================

module uart_top #(
    parameter int BAUD_RATE = 9600,
    parameter int CLK_FREQ  = 50_000_000
)(
    input  logic       clk,
    input  logic       reset,

    input  logic       start_tx,
    input  logic [7:0] data_tx,

    input  logic       rx,

    output logic       tx,
    output logic       busy_tx,
    output logic       done_tx,

    output logic [7:0] data_rx,
    output logic       valid_rx
);

    logic rx_sync;

    sync_2ff u_sync_2ff (
        .clk      (clk),
        .reset    (reset),
        .async_in (rx),
        .sync_out (rx_sync)
    );

    uart_tx #(
        .BAUD_RATE (BAUD_RATE),
        .CLK_FREQ  (CLK_FREQ)
    ) u_uart_tx (
        .clk       (clk),
        .reset     (reset),
        .start_tx  (start_tx),
        .data_tx   (data_tx),
        .tx        (tx),
        .busy_tx   (busy_tx),
        .done_tx   (done_tx)
    );

    uart_rx #(
        .BAUD_RATE (BAUD_RATE),
        .CLK_FREQ  (CLK_FREQ)
    ) u_uart_rx (
        .clk       (clk),
        .reset     (reset),
        .rx        (rx_sync),
        .data_rx   (data_rx),
        .valid_rx  (valid_rx)
    );

endmodule