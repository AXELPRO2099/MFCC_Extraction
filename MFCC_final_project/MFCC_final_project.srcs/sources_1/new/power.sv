`timescale 1ns / 1ps
module power(
input clk, rst, start, 
input logic signed [15:0] d_real_in [0:255],
input logic signed [15:0] d_img_in [0:255],
output logic [15:0] d_out [0:255],
output reg done
);

logic signed [15:0] buff_a [0:255];
logic signed [15:0] buff_b [0:255]; 


always_ff @(posedge clk) begin
    if(rst) begin
        done <= 0;
    end
    else begin
        if(start)begin
            for(int i=0; i<256; i++) begin
                buff_a[i] <= ((d_real_in[i] * d_real_in[i]) + 16'sd32768) >> 16;
                buff_b[i] <= ((d_img_in[i] * d_img_in[i]) + 16'sd32768) >> 16;
                d_out[i] <= (buff_a[i] + buff_b[i]) >> 2;
            end
            done <= 1;
        end
        else begin
            done <= done;
        end
    end
end


endmodule
