//=====================================================================
// Project      : UART Transceiver
// Module       : sync_2ff
// File         : sync_2ff.sv
// Description  : Two-flip-flop synchronizer for asynchronous input.
//                Reduces the probability of metastability propagating
//                into the destination clock domain.
//
// Author       : Truong Thanh Nhan
// Language     : SystemVerilog
//=====================================================================

module sync_2ff (
    input  logic clk,
    input  logic reset,
    input  logic async_in,

    output logic sync_out
);

    logic sync_ff1;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            sync_ff1 <= 1'b1;
            sync_out <= 1'b1;
        end
        else begin
            sync_ff1 <= async_in;
            sync_out <= sync_ff1;
        end
    end

endmodule