`timescale 1ns / 1ps
module fft_2(
input wire signed [15:0] x_real [0:255],
input wire signed [15:0] x_img [0:255],
input clk, rst, start,
output reg signed [15:0] data_real [0:255],
output reg signed [15:0] data_img [0:255],
output reg done
);

/*
We make 16 groups of 16 samples each
Each group has 4 butterflies
7 unique twiddle factors per group
W=exp(-2j*pi*butterfly_number/16
*/

logic signed [15:0] W_real [0:8] = '{
16'sd30274, 
16'sd23170,
16'sd12540,
16'sd23170,
16'sd0,
-16'sd23170,
16'sd12540,
-16'sd23170,
-16'sd30274
};
logic signed [15:0] W_img [0:8] = '{
-16'sd12540,
-16'sd23170, 
-16'sd30274,
-16'sd23170,
-16'sd32768,
-16'sd23170,
-16'sd30274,
-16'sd23170, 
16'sd12540
};


logic signed [32:0] xcr [0:15];
logic signed [32:0] xci [0:15];


typedef enum logic [2:0] {
IDLE,
LOAD,
BUSY,
DONE
}states_t;

states_t state;
logic [4:0] group;
logic [8:0] idx;

always_ff @(posedge clk) begin
    if(rst) begin
        idx <= 0;
        group <= 0;
        done <= 0;
        state <= IDLE;
    end
    else if(start) begin
        idx <= 0;
        group <= 0;
        done <= 0;
        state <= LOAD;
    end
    else begin
        if (group < 16) begin
            idx = group * 16;
            if(state == LOAD) begin
                
                //Butterfly 0
                xcr[0] <= x_real[idx];
                xcr[1] <= x_real[idx+4];
                xcr[2] <= x_real[idx+8];
                xcr[3] <= x_real[idx+12];
                
                xci[0] <= x_img[idx];
                xci[1] <= x_img[idx+4];
                xci[2] <= x_img[idx+8];
                xci[3] <= x_img[idx+12];
                
                //Butterfly 1
                xcr[4] <= x_real[idx+1];
                xcr[5] <= x_real[idx+5] * W_real[0] - x_img[idx+5] * W_img[0];
                xcr[6] <= x_real[idx+9] * W_real[1] - x_img[idx+9] * W_img[1];
                xcr[7] <= x_real[idx+13] * W_real[2] - x_img[idx+13] * W_img[2];
                
                xci[4] <= x_img[idx+1];
                xci[5] <= x_real[idx+5] * W_img[0] + x_img[idx+5] * W_real[0];
                xci[6] <= x_real[idx+9] * W_img[1] + x_img[idx+9] * W_real[1];
                xci[7] <= x_real[idx+13] * W_img[2] + x_img[idx+13] * W_real[2];
                
                //Butterfly 2
                xcr[8]  <= x_real[idx+2];
                xcr[9]  <= x_real[idx+6] * W_real[3] - x_img[idx+6] * W_img[3];
                xcr[10] <= x_real[idx+10] * W_real[4] - x_img[idx+10] * W_img[4];
                xcr[11] <= x_real[idx+14] * W_real[5] - x_img[idx+14] * W_img[5];
                
                xci[8]  <= x_img[idx+2];
                xci[9]  <= x_real[idx+6] * W_img[3] + x_img[idx+6] * W_real[3];
                xci[10] <= x_real[idx+10] * W_img[4] + x_img[idx+10] * W_real[4];
                xci[11] <= x_real[idx+14] * W_img[5] + x_img[idx+14] * W_real[5];
                
                //Butterfly 3
                xcr[12]  <= x_real[idx+3];
                xcr[13]  <= x_real[idx+7] * W_real[6] - x_img[idx+7] * W_img[6];
                xcr[14] <= x_real[idx+11] * W_real[7] - x_img[idx+11] * W_img[7];
                xcr[15] <= x_real[idx+15] * W_real[8] - x_img[idx+15] * W_img[8];
                
                xci[12]  <= x_img[idx+3];
                xci[13]  <= x_real[idx+7] * W_img[6] + x_img[idx+7] * W_real[6];
                xci[14] <= x_real[idx+11] * W_img[7] + x_img[idx+11] * W_real[7];
                xci[15] <= x_real[idx+15] * W_img[8] + x_img[idx+15] * W_real[8];
                
                state <= BUSY;
            end
            else if (state == BUSY) begin
            
                //Butterfly 0
                data_real[idx]      <= (xcr[0] + xcr[1] + xcr[2] + xcr[3] + 19'd524287) >>> 20;
                data_real[idx + 4]  <= (xcr[0] + xci[1] - xcr[2] - xci[3] + 19'd524287) >>> 20;
                data_real[idx + 8]  <= (xcr[0] - xcr[1] + xcr[2] - xcr[3] + 19'd524287) >>> 20;
                data_real[idx + 12] <= (xcr[0] - xci[1] - xcr[2] + xcr[3] + 19'd524287) >>> 20;
                
                data_img[idx]      <= (xci[0] + xci[1] + xci[2] + xci[3] + 19'd524287) >>> 20;
                data_img[idx + 4]  <= (xci[0] - xcr[1] + xci[2] + xcr[3] + 19'd524287) >>> 20;
                data_img[idx + 8]  <= (xci[0] - xci[1] + xci[2] - xci[3] + 19'd524287) >>> 20;
                data_img[idx + 12] <= (xci[0] + xcr[1] + xci[2] - xcr[3] + 19'd524287) >>> 20;
                
                //Butterfly 1
                data_real[idx + 1]  <= (xcr[4] + xcr[5] + xcr[6] + xcr[7] + 19'd524287) >>> 20;
                data_real[idx + 5]  <= (xcr[4] + xci[5] - xcr[6] - xci[7] + 19'd524287) >>> 20;
                data_real[idx + 9]  <= (xcr[4] - xcr[5] + xcr[6] - xcr[7] + 19'd524287) >>> 20;
                data_real[idx + 13] <= (xcr[4] - xci[5] - xcr[6] + xcr[7] + 19'd524287) >>> 20;
                
                data_img[idx + 1]   <= (xci[4] + xci[5] + xci[6] + xci[7] + 19'd524287) >>> 20;
                data_img[idx + 5]   <= (xci[4] - xcr[5] + xci[6] + xcr[7] + 19'd524287) >>> 20;
                data_img[idx + 9]   <= (xci[4] - xci[5] + xci[6] - xci[7] + 19'd524287) >>> 20;
                data_img[idx + 13]  <= (xci[4] + xcr[5] + xci[6] - xcr[7] + 19'd524287) >>> 20;
                
                //Butterfly 2
                data_real[idx + 2]  <= (xcr[8] + xcr[9] + xcr[10] + xcr[11] + 19'd524287) >>> 20;
                data_real[idx + 6]  <= (xcr[8] + xci[9] - xcr[10] - xci[11] + 19'd524287) >>> 20;
                data_real[idx + 10] <= (xcr[8] - xcr[9] + xcr[10] - xcr[11] + 19'd524287) >>> 20;
                data_real[idx + 14] <= (xcr[8] - xci[9] - xcr[10] + xcr[11] + 19'd524287) >>> 20;
                
                data_img[idx + 2]  <= (xci[8] + xci[9] + xci[10] + xci[11] + 19'd524287) >>> 20;
                data_img[idx + 6]  <= (xci[8] - xcr[9] + xci[10] + xcr[11] + 19'd524287) >>> 20;
                data_img[idx + 10] <= (xci[8] - xci[9] + xci[10] - xci[11] + 19'd524287) >>> 20;
                data_img[idx + 14] <= (xci[8] + xcr[9] + xci[10] - xcr[11] + 19'd524287) >>> 20;
                
                
                //Butterfly 3
                data_real[idx + 3]  <= (xcr[12] + xcr[13] + xcr[14] + xcr[15] + 19'd524287) >>> 20;
                data_real[idx + 7]  <= (xcr[12] + xci[13] - xcr[14] - xci[15] + 19'd524287) >>> 20;
                data_real[idx + 11] <= (xcr[12] - xcr[13] + xcr[14] - xcr[15] + 19'd524287) >>> 20;
                data_real[idx + 15] <= (xcr[12] - xci[13] - xcr[14] + xcr[15] + 19'd524287) >>> 20;
                
                data_img[idx + 3]  <= (xci[12] + xci[13] + xci[14] + xci[15] + 19'd524287) >>> 20;
                data_img[idx + 7]  <= (xci[12] - xcr[13] + xci[14] + xcr[15] + 19'd524287) >>> 20;
                data_img[idx + 11] <= (xci[12] - xci[13] + xci[14] - xci[15] + 19'd524287) >>> 20;
                data_img[idx + 15] <= (xci[12] + xcr[13] + xci[14] - xcr[15] + 19'd524287) >>> 20;
                
                state <= (group < 16)? LOAD : DONE;
                group <= group + 1;
            end
            else if (state == DONE) begin
                done <= 1;
                state <= DONE;
            end
            else begin
                state <= state;
                idx <= idx;
                group <= group;
                done <= done;
            end
        end
    end
end

endmodule

