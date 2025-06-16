`timescale 1ns / 1ps
`define a0  16'sd16384  // 1.0
`define a1  -16'sd25575 // -1.5610
`define a2  16'sd10509  // 0.6414
`define b0  16'sd13117  // 0.8006
`define b1  -16'sd26234 // -1.6012
`define b2  16'sd13117  // 0.8006
module preprocessing(
    input clk,
    input rst,
    input start,
    input logic signed [15:0] x [0:2],
    output logic signed [15:0] y
);

    function logic signed [15:0] muls(input logic signed [15:0] a, input logic signed [15:0] b);
        logic signed [31:0] result;
        result = a * b + 16384; // rounding
        result = result >>> 15;
        if (result > 32767) result = 32767;
        else if (result < -32768) result = -32768;
        return result[15:0];
    endfunction

    // Stage 1: compute products
    logic signed [15:0] acc_0, acc_1, acc_2, acc_3, acc_4;
    logic signed [15:0] acc_sum;

    // Delay buffers
    logic signed [15:0] y_buff, y_buff_2;

    // Stage control
    logic [1:0] state;

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            y <= 0;
            y_buff <= 0;
            y_buff_2 <= 0;
            acc_sum <= 0;
            state <= 0;
        end
        else begin
            case (state)
                2'b00: begin
                    if (start) begin
                        acc_0 <= muls(`b0, x[0]);
                        acc_1 <= muls(`b1, x[1]);
                        acc_2 <= muls(`b2, x[2]);
                        acc_3 <= muls(`a1, y_buff);
                        acc_4 <= muls(`a2, y_buff_2);
                        state <= 1;
                    end
                end
                2'b01: begin
                    acc_sum <= acc_0 + acc_1 + acc_2 + acc_3 + acc_4;
                    state <= 2;
                end
                2'b10: begin
                    y <= acc_sum >>> 2;
                    y_buff <= y;
                    y_buff_2 <= y_buff;
                    state <= 0;
                end
            endcase
        end
    end

endmodule
