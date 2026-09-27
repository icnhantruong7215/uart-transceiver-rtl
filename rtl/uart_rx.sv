//=====================================================================
// Project      : UART Transceiver
// Module       : uart_rx
// File         : uart_rx.sv
// Description  : UART receiver module.
//                Receives serial UART data and converts it into
//                8-bit parallel data using configurable baud rate
//                and system clock frequency.
//
// Features:
//   - Configurable baud rate
//   - Configurable system clock frequency
//   - 8-bit data reception
//   - Start-bit validation
//   - Stop-bit validation
//   - LSB-first reception
//   - Valid receive status signal
//
// Author       : Truong Thanh Nhan
// Language     : SystemVerilog
//=====================================================================

module uart_rx #(
    parameter int BAUD_RATE = 9600,
    parameter int CLK_FREQ  = 50_000_000
)(
    input  logic       clk,
    input  logic       reset,
    input  logic       rx,

    output logic [7:0] data_rx,
    output logic       valid_rx
);

    localparam int BAUD_DIV = CLK_FREQ / BAUD_RATE;

    typedef enum logic [1:0] {
        IDLE,
        START,
        DATA,
        DONE
    } state_t;

    state_t state;

    logic [31:0] baud_counter;
    logic [2:0]  bit_counter;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state        <= IDLE;
            baud_counter <= 32'd0;
            bit_counter  <= 3'd0;
            data_rx      <= 8'd0;
            valid_rx     <= 1'b0;
        end
        else begin
            valid_rx <= 1'b0;

            case (state)
                IDLE: begin
                    baud_counter <= 32'd0;
                    bit_counter  <= 3'd0;

                    if (rx == 1'b0) begin
                        state <= START;
                    end
                end

                START: begin
                    if (baud_counter == (BAUD_DIV / 2) - 1) begin
                        baud_counter <= 32'd0;

                        if (rx == 1'b0) begin
                            state <= DATA;
                        end
                        else begin
                            state <= IDLE;
                        end
                    end
                    else begin
                        baud_counter <= baud_counter + 1'b1;
                    end
                end

                DATA: begin
                    if (baud_counter == BAUD_DIV - 1) begin
                        baud_counter          <= 32'd0;
                        data_rx[bit_counter]  <= rx;

                        if (bit_counter == 3'd7) begin
                            bit_counter <= 3'd0;
                            state       <= DONE;
                        end
                        else begin
                            bit_counter <= bit_counter + 1'b1;
                        end
                    end
                    else begin
                        baud_counter <= baud_counter + 1'b1;
                    end
                end

                DONE: begin
                    if (baud_counter == BAUD_DIV - 1) begin
                        baud_counter <= 32'd0;

                        if (rx == 1'b1) begin
                            valid_rx <= 1'b1;
                        end

                        state <= IDLE;
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