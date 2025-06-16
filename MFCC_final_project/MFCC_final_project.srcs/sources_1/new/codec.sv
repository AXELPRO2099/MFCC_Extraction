`timescale 1ns / 1ps
module codec(
input logic [23:0] data_in,
output logic [15:0] data_out,
input clk, rst
);

//define two random integers
byte rand_1, rand_2;
//The sum of 2 random numbers is stored in tpdf_noise with overflow bit
logic signed [8:0] tpdf_noise;
logic signed [24:0] dithered_data;
//create a linear feedback shift register to generate random noise
byte lfsr_1 = 8'hA5, lfsr_2 = 8'hA5;
logic signed [15:0] temp_data;

always_ff @(posedge clk) begin
    if (rst) begin
        lfsr_1 <= 8'hA5;
        lfsr_2 <= 8'hA5;
    end
    else begin
        lfsr_1 <= {lfsr_1[6:0], lfsr_1[7] ^ lfsr_1[5] ^ lfsr_1[4] ^ lfsr_1[3]};
        lfsr_2 <= {lfsr_2[6:0], lfsr_2[7] ^ lfsr_2[5] ^ lfsr_2[4] ^ lfsr_2[3]};
    end
end
assign rand_1 = lfsr_1;
assign rand_2 = lfsr_2;

always_ff @(posedge clk) begin
    if (rst) begin
        temp_data <= 16'sd0;
    end else begin
        // Convert unsigned LFSR outputs to signed range [-128, +127]
        tpdf_noise <= signed'({1'b0, rand_1}) - 9'd128 
                    + signed'({1'b0, rand_2}) - 9'd128;  

        // Apply dithering noise before truncation
        dithered_data <= data_in + tpdf_noise;  
        temp_data   <= dithered_data[23:8];  // Convert to 16-bit
    end
end
assign data_out = temp_data;
endmodule