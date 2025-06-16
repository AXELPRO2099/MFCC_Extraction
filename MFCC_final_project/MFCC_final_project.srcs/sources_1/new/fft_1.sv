`timescale 1ns / 1ps
module fft_1(
input wire signed [15:0] x [0:255],
input clk, rst, start,
output reg signed [15:0] data_real [0:255],
output reg signed [15:0] data_img [0:255],
output reg done
);


reg [6:0] group;

logic [1:0] state;

always_ff @(posedge clk) begin
    if(rst) begin
        group <= 0;
        done <= 0;
        state <= 0;
    end
    else if (start) begin
        group <= 0;
        done <= 0;
        state <= 1;
    end
    else begin
        if (state == 1) begin
            if(group < 64) begin
                data_real[group*4] <= x[group*4+0] + x[group*4+1] + x[group*4+2] + x[group*4+3];
                data_real[group*4+1] <= x[group*4+0] - x[group*4+2];
                data_real[group*4+2] <= x[group*4+0] - x[group*4+1] + x[group*4+2] - x[group*4+3];
                data_real[group*4+3] <= x[group*4+0] - x[group*4+2];
                
                
                data_img[group*4] <= 0;  
                data_img[group*4+1] <= x[group*4+3] -  x[group*4+1];
                data_img[group*4+2] <= 0;
                data_img[group*4+3] <= x[group*4+1] - x[group*4+3];
                group <= group + 1;
            end
            else state <= 2;
        end
        else if(state == 2) begin
            done <= 1;
        end
        else group <= 0;
    end
end

endmodule