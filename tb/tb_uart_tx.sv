//=====================================================================
// Project      : UART Transceiver
// Module       : tb_uart_tx
// File         : tb_uart_tx.sv
// Description  : Testbench for UART transmitter.
//
// Author       : Truong Thanh Nhan
// Language     : SystemVerilog
//=====================================================================

`timescale 1ns/1ps

module tb_uart_tx;

    localparam int CLK_FREQ   = 10_000_000;
    localparam int BAUD_RATE  = 1_000_000;
    localparam int CLK_PERIOD = 100;
    localparam int BAUD_DIV   = CLK_FREQ / BAUD_RATE;

    logic       clk;
    logic       reset;
    logic       start_tx;
    logic [7:0] data_tx;

    logic       tx;
    logic       busy_tx;
    logic       done_tx;

    logic [7:0] expected_data;
    integer     i;

    uart_tx #(
        .BAUD_RATE (BAUD_RATE),
        .CLK_FREQ  (CLK_FREQ)
    ) dut (
        .clk       (clk),
        .reset     (reset),
        .start_tx  (start_tx),
        .data_tx   (data_tx),
        .tx        (tx),
        .busy_tx   (busy_tx),
        .done_tx   (done_tx)
    );

    always #(CLK_PERIOD / 2) clk = ~clk;

    initial begin
        $dumpfile("sim/tb_uart_tx.vcd");
        $dumpvars(0, tb_uart_tx);
    end

    initial begin
        $monitor(
            "time=%0t reset=%b start=%b data=%h tx=%b busy=%b done=%b",
            $time, reset, start_tx, data_tx, tx, busy_tx, done_tx
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

        // Test 1: 0x55
        expected_data = 8'h55;
        data_tx       = expected_data;

        @(posedge clk);
        start_tx = 1'b1;

        @(posedge clk);
        start_tx = 1'b0;

        wait(tx == 1'b0);

        #(CLK_PERIOD * BAUD_DIV / 2);

        if (tx !== 1'b0)
            $error("START bit error");

        #(CLK_PERIOD * BAUD_DIV);

        for (i = 0; i < 8; i = i + 1) begin
            if (tx !== expected_data[i])
                $error(
                    "DATA bit %0d error: expected=%0b actual=%0b",
                    i, expected_data[i], tx
                );

            #(CLK_PERIOD * BAUD_DIV);
        end

        if (tx !== 1'b1)
            $error("STOP bit error");

        wait(done_tx);

        $display("PASS: Sent 0x%h", expected_data);

        repeat (5) @(posedge clk);

        // Test 2: 0xA5
        expected_data = 8'hA5;
        data_tx       = expected_data;

        @(posedge clk);
        start_tx = 1'b1;

        @(posedge clk);
        start_tx = 1'b0;

        wait(tx == 1'b0);

        #(CLK_PERIOD * BAUD_DIV / 2);
        #(CLK_PERIOD * BAUD_DIV);

        for (i = 0; i < 8; i = i + 1) begin
            if (tx !== expected_data[i])
                $error(
                    "DATA bit %0d error: expected=%0b actual=%0b",
                    i, expected_data[i], tx
                );

            #(CLK_PERIOD * BAUD_DIV);
        end

        if (tx !== 1'b1)
            $error("STOP bit error");

        wait(done_tx);

        $display("PASS: Sent 0x%h", expected_data);

        repeat (5) @(posedge clk);

        // Test 3: 0x3C
        expected_data = 8'h3C;
        data_tx       = expected_data;

        @(posedge clk);
        start_tx = 1'b1;

        @(posedge clk);
        start_tx = 1'b0;

        wait(tx == 1'b0);

        #(CLK_PERIOD * BAUD_DIV / 2);
        #(CLK_PERIOD * BAUD_DIV);

        for (i = 0; i < 8; i = i + 1) begin
            if (tx !== expected_data[i])
                $error(
                    "DATA bit %0d error: expected=%0b actual=%0b",
                    i, expected_data[i], tx
                );

            #(CLK_PERIOD * BAUD_DIV);
        end

        if (tx !== 1'b1)
            $error("STOP bit error");

        wait(done_tx);

        $display("PASS: Sent 0x%h", expected_data);

        repeat (5) @(posedge clk);

        $display("UART TX TEST COMPLETED");

        $finish;
    end

endmodule