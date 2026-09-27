//=====================================================================
// Project      : UART Transceiver
// Module       : tb_uart_rx
// File         : tb_uart_rx.sv
// Description  : Testbench for UART receiver.
//                Generates UART frames and verifies received data.
//
// Test Cases:
//   - Reset behavior
//   - Receive multiple UART frames
//   - 8-bit LSB-first data reception
//   - RX valid status
//
// Author       : Truong Thanh Nhan
// Language     : SystemVerilog
//=====================================================================

`timescale 1ns/1ps

module tb_uart_rx;

    localparam int CLK_FREQ   = 10_000_000;
    localparam int BAUD_RATE  = 1_000_000;
    localparam int CLK_PERIOD = 100;
    localparam int BAUD_DIV   = CLK_FREQ / BAUD_RATE;
    localparam int BIT_TIME   = CLK_PERIOD * BAUD_DIV;

    logic       clk;
    logic       reset;
    logic       rx;

    logic [7:0] data_rx;
    logic       valid_rx;

    logic [7:0] expected_data;
    integer     i;

    uart_rx #(
        .BAUD_RATE (BAUD_RATE),
        .CLK_FREQ  (CLK_FREQ)
    ) dut (
        .clk      (clk),
        .reset    (reset),
        .rx       (rx),
        .data_rx  (data_rx),
        .valid_rx (valid_rx)
    );

    always #(CLK_PERIOD / 2) clk = ~clk;

    initial begin
        $dumpfile("sim/tb_uart_rx.vcd");
        $dumpvars(0, tb_uart_rx);
    end

    initial begin
        $monitor(
            "time=%0t reset=%b rx=%b data_rx=%h valid_rx=%b",
            $time,
            reset,
            rx,
            data_rx,
            valid_rx
        );
    end

    initial begin
        clk           = 1'b0;
        reset         = 1'b1;
        rx            = 1'b1;
        expected_data = 8'h00;

        repeat (5) @(posedge clk);
        reset = 1'b0;

        repeat (2) @(posedge clk);

        //=============================================================
        // Test 1: Receive 0x55
        //=============================================================
        expected_data = 8'h55;

        // Start bit
        rx = 1'b0;
        #(BIT_TIME);

        // Data bits - LSB first
        for (i = 0; i < 8; i = i + 1) begin
            rx = expected_data[i];
            #(BIT_TIME);
        end

        // Stop bit
        rx = 1'b1;

        wait(valid_rx == 1'b1);

        if (data_rx !== expected_data)
            $error(
                "TEST 1 FAILED: expected=%h actual=%h",
                expected_data,
                data_rx
            );
        else
            $display(
                "TEST 1 PASSED: RX=0x%h",
                data_rx
            );

        wait(valid_rx == 1'b0);

        repeat (5) @(posedge clk);

        //=============================================================
        // Test 2: Receive 0xA5
        //=============================================================
        expected_data = 8'hA5;

        // Start bit
        rx = 1'b0;
        #(BIT_TIME);

        // Data bits - LSB first
        for (i = 0; i < 8; i = i + 1) begin
            rx = expected_data[i];
            #(BIT_TIME);
        end

        // Stop bit
        rx = 1'b1;

        wait(valid_rx == 1'b1);

        if (data_rx !== expected_data)
            $error(
                "TEST 2 FAILED: expected=%h actual=%h",
                expected_data,
                data_rx
            );
        else
            $display(
                "TEST 2 PASSED: RX=0x%h",
                data_rx
            );

        wait(valid_rx == 1'b0);

        repeat (5) @(posedge clk);

        //=============================================================
        // Test 3: Receive 0x3C
        //=============================================================
        expected_data = 8'h3C;

        // Start bit
        rx = 1'b0;
        #(BIT_TIME);

        // Data bits - LSB first
        for (i = 0; i < 8; i = i + 1) begin
            rx = expected_data[i];
            #(BIT_TIME);
        end

        // Stop bit
        rx = 1'b1;

        wait(valid_rx == 1'b1);

        if (data_rx !== expected_data)
            $error(
                "TEST 3 FAILED: expected=%h actual=%h",
                expected_data,
                data_rx
            );
        else
            $display(
                "TEST 3 PASSED: RX=0x%h",
                data_rx
            );

        wait(valid_rx == 1'b0);

        repeat (10) @(posedge clk);

        $display("UART RX TEST COMPLETED");

        $finish;
    end

endmodule
