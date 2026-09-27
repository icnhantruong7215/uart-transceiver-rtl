//=====================================================================
// Project      : UART Transceiver
// Module       : uart_tx
// File         : uart_tx.sv
// Description  : UART transmitter module.
//                Transmits 8-bit parallel data serially using
//                configurable baud rate and system clock frequency.
//
// Features:
//   - Configurable baud rate
//   - Configurable system clock frequency
//   - 8-bit data transmission
//   - 1 start bit
//   - 1 stop bit
//   - LSB-first transmission
//   - Busy and done status signals
//
// Author       : Truong Thanh Nhan
// Language     : SystemVerilog
//=====================================================================

module uart_tx #(
    parameter int BAUD_RATE = 9600,
    parameter int CLK_FREQ  = 50_000_000
)(
    input  logic       clk,
    input  logic       reset,
    input  logic       start_tx,
    input  logic [7:0] data_tx,

    output logic       tx,
    output logic       busy_tx,
    output logic       done_tx
);

    localparam int BAUD_DIV = CLK_FREQ / BAUD_RATE;

    typedef enum logic [1:0] {
        IDLE,
        START,
        DATA,
        STOP
    } state_t;

    state_t state;

    logic [31:0] baud_counter;
    logic [2:0]  bit_counter;
    logic [7:0]  tx_data_reg;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state        <= IDLE;
            baud_counter <= 32'd0;
            bit_counter  <= 3'd0;
            tx_data_reg  <= 8'd0;
            tx            <= 1'b1;
            busy_tx       <= 1'b0;
            done_tx       <= 1'b0;
        end
        else begin
            done_tx <= 1'b0;

            case (state)
                IDLE: begin
                    tx           <= 1'b1;
                    busy_tx      <= 1'b0;
                    baud_counter <= 32'd0;
                    bit_counter  <= 3'd0;

                    if (start_tx) begin
                        tx_data_reg <= data_tx;
                        busy_tx     <= 1'b1;
                        state       <= START;
                    end
                end

                START: begin
                    tx      <= 1'b0;
                    busy_tx <= 1'b1;

                    if (baud_counter == BAUD_DIV - 1) begin
                        baud_counter <= 32'd0;
                        state        <= DATA;
                    end
                    else begin
                        baud_counter <= baud_counter + 1'b1;
                    end
                end

                DATA: begin
                    tx      <= tx_data_reg[bit_counter];
                    busy_tx <= 1'b1;

                    if (baud_counter == BAUD_DIV - 1) begin
                        baud_counter <= 32'd0;

                        if (bit_counter == 3'd7) begin
                            bit_counter <= 3'd0;
                            state       <= STOP;
                        end
                        else begin
                            bit_counter <= bit_counter + 1'b1;
                        end
                    end
                    else begin
                        baud_counter <= baud_counter + 1'b1;
                    end
                end

                STOP: begin
                    tx      <= 1'b1;
                    busy_tx <= 1'b1;

                    if (baud_counter == BAUD_DIV - 1) begin
                        baud_counter <= 32'd0;
                        busy_tx      <= 1'b0;
                        done_tx      <= 1'b1;
                        state        <= IDLE;
                    end
                    else begin
                        baud_counter <= baud_counter + 1'b1;
                    end
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule