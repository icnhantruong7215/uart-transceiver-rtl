//=====================================================================
// Project      : UART Transceiver
// Module       : tb_uart_top
// File         : tb_uart_top.sv
// Description  : Loopback testbench for UART transceiver.
//                Connects TX output to RX input through the
//                top-level RX synchronizer and verifies that
//                transmitted data is correctly received.
//
// Test Cases:
//   - Reset behavior
//   - TX to RX loopback
//   - Multiple data patterns
//   - TX done status
//   - RX valid status
//
// Author       : Truong Thanh Nhan
// Language     : SystemVerilog
//=====================================================================

`timescale 1ns/1ps

module tb_uart_top;

    localparam int CLK_FREQ   = 10_000_000;
    localparam int BAUD_RATE  = 1_000_000;
    localparam int CLK_PERIOD = 100;

    logic       clk;
    logic       reset;

    logic       start_tx;
    logic [7:0] data_tx;

    logic       tx;
    logic       rx;

    logic       busy_tx;
    logic       done_tx;

    logic [7:0] data_rx;
    logic       valid_rx;

    logic [7:0] expected_data;

    assign rx = tx;

    uart_top #(
        .BAUD_RATE (BAUD_RATE),
        .CLK_FREQ  (CLK_FREQ)
    ) dut (
        .clk       (clk),
        .reset     (reset),

        .start_tx  (start_tx),
        .data_tx   (data_tx),

        .rx        (rx),

        .tx        (tx),
        .busy_tx   (busy_tx),
        .done_tx   (done_tx),

        .data_rx   (data_rx),
        .valid_rx  (valid_rx)
    );

    always #(CLK_PERIOD / 2) clk = ~clk;

    initial begin
        $dumpfile("sim/tb_uart_top.vcd");
        $dumpvars(0, tb_uart_top);
    end

    initial begin
        $monitor(
            "time=%0t reset=%b start=%b data_tx=%h tx=%b rx=%b busy=%b done=%b data_rx=%h valid=%b",
            $time,
            reset,
            start_tx,
            data_tx,
            tx,
            rx,
            busy_tx,
            done_tx,
            data_rx,
            valid_rx
        );
    end

    initial begin
        clk           = 1'b0;
        reset         = 1'b1;
        start_tx      = 1'b0;
        data_tx       = 8'h00;
        expected_data = 8'h00;

        repeat (5) @(posedge clk);
        reset = 1'b0;

        repeat (2) @(posedge clk);

        //=============================================================
        // Test 1: Loopback 0x55
        //=============================================================
        expected_data = 8'h55;
        data_tx       = expected_data;

        @(posedge clk);
        start_tx = 1'b1;

        @(posedge clk);
        start_tx = 1'b0;

        wait(valid_rx == 1'b1);

        if (data_rx !== expected_data)
            $error(
                "TEST 1 FAILED: expected=%h actual=%h",
                expected_data,
                data_rx
            );
        else
            $display(
                "TEST 1 PASSED: TX=0x%h RX=0x%h",
                expected_data,
                data_rx
            );

        wait(done_tx == 1'b1);

        repeat (5) @(posedge clk);

        //=============================================================
        // Test 2: Loopback 0xA5
        //=============================================================
        expected_data = 8'hA5;
        data_tx       = expected_data;

        @(posedge clk);
        start_tx = 1'b1;

        @(posedge clk);
        start_tx = 1'b0;

        wait(valid_rx == 1'b1);

        if (data_rx !== expected_data)
            $error(
                "TEST 2 FAILED: expected=%h actual=%h",
                expected_data,
                data_rx
            );
        else
            $display(
                "TEST 2 PASSED: TX=0x%h RX=0x%h",
                expected_data,
                data_rx
            );

        wait(done_tx == 1'b1);

        repeat (5) @(posedge clk);

        //=============================================================
        // Test 3: Loopback 0x3C
        //=============================================================
        expected_data = 8'h3C;
        data_tx       = expected_data;

        @(posedge clk);
        start_tx = 1'b1;

        @(posedge clk);
        start_tx = 1'b0;

        wait(valid_rx == 1'b1);

        if (data_rx !== expected_data)
            $error(
                "TEST 3 FAILED: expected=%h actual=%h",
                expected_data,
                data_rx
            );
        else
            $display(
                "TEST 3 PASSED: TX=0x%h RX=0x%h",
                expected_data,
                data_rx
            );

        wait(done_tx == 1'b1);

        repeat (10) @(posedge clk);

        $display("UART LOOPBACK TEST COMPLETED");

        $finish;
    end

endmodule
