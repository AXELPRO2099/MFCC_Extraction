`timescale 1ns / 1ps
module top(
input wire [23:0] data_in,
input clk, rst, start,
output logic [15:0] spectrogram_val [0:25],
output logic done
);


//state machine
typedef enum logic [3:0] {
IDLE,
FFT1,
FFT2,
POWER,
MEL_bank,
DONE
}states_t;

states_t state;

reg codec_start;
//reg [1:0] count;
reg preprocessing_start, preprocessing_done;
reg fft_1_start, fft_1_done;
reg fft_2_start, fft_2_done;
reg mel_start, mel_done;

logic signed [23:0] d_in;
reg [8:0] address;
logic [15:0] power_val [0:255];
reg power_done;
reg power_start;
logic signed [15:0] power_real_in [0:255];
logic signed [15:0] power_img_in [0:255];
logic signed [15:0] codec_out;
logic signed [15:0] preprocessing_in [0:2];
logic signed [15:0] preprocessing_out;
logic signed [15:0] fft1_in [0:255];
logic signed [15:0] fft1_real_out [0:255];
logic signed [15:0] fft1_img_out [0:255];
logic signed [15:0] fft2_real_in [0:255];
logic signed [15:0] fft2_img_in [0:255];
logic signed [15:0] fft2_real_out [0:255];
logic signed [15:0] fft2_img_out [0:255];
logic signed [15:0] mel_in [0:111];
logic signed [15:0] mel_out [0:25];
logic signed [15:0] buffer [0:255];




always_comb begin
    //preprocessing_in[0] = codec_out;
    for(int i=0; i<256; i++)begin
        fft1_in[i] = buffer[i];
        fft2_real_in[i] = fft1_real_out[i];
        fft2_img_in[i] = fft1_img_out[i];
        power_real_in[i] = fft2_real_out[i];
        power_img_in[i] = fft2_img_out[i];
         
    end
    for(int i=0; i<110; i++) begin
        mel_in[i] = power_val[i];
    end
end
always_ff @(posedge clk)begin
    preprocessing_in[0] <= codec_out;
    preprocessing_in[1] <= preprocessing_in[0];
    preprocessing_in[2] <= preprocessing_in[1];
end
always_ff @(posedge clk) begin
    if(rst) begin
        state <= IDLE;
        done <= 0;
        address <= 0;
        codec_start <= 0;
        preprocessing_start <= 0;
        fft_1_start <= 0;
        fft_2_start <= 0;
        mel_start <= 0;
        power_start <= 0;
        preprocessing_done <= 0;
        fft_1_done <= 0;
        fft_2_done <= 0;
        mel_done <= 0;
        power_done <= 0;
    end
    else begin
        if(start) begin
            d_in <= data_in;
            case(state)
            IDLE: begin
                if(start) begin
                    if(address < 256) begin
                        buffer[address] <= preprocessing_out;
                        address <= address + 1;
                    end
                    else begin
                        preprocessing_done <= 1;
                        state <= FFT1;
                    end
                end
                else begin
                    state <= state;
                end
            end
            FFT1: begin
                fft_1_start <= 1;
                state <= fft_1_done? FFT2 : FFT1;
            end
            FFT2: begin
                fft_2_start <= 1;
                state <= fft_2_done? POWER : FFT2;
            end
            POWER: begin
                power_start <= 1;
                state <= power_done? MEL_bank : POWER;
            end
            MEL_bank: begin
                mel_start <= 1;
                state <= mel_done? DONE : MEL_bank;
            end
            DONE: begin
                for(int i=0; i<26; i++) begin
                    spectrogram_val[i] <= mel_out[i];
                end
                done <= 1;
            end
            endcase
        end       
    end
    
end
codec inst1 (
            .clk(clk),
            .rst(rst),
            .data_in(d_in),
            .data_out(codec_out)
            );
preprocessing inst2 (
                    .clk(clk),
                    .rst(rst),
                    .x(preprocessing_in),
                    .y(preprocessing_out)
                    );
fft_1 inst3 (
            .clk(clk),
            .rst(rst),
            .start(fft_1_start),
            .done(fft_1_done),
            .x(fft1_in),
            .data_real(fft1_real_out),
            .data_img(fft1_img_out)
            );
fft_2 inst4 (
            .clk(clk),
            .rst(rst),
            .start(fft_2_start),
            .done(fft_2_done),
            .x_real(fft2_real_in),
            .x_img(fft2_img_in),
            .data_real(fft2_real_out),
            .data_img(fft2_img_out)
            );
            
power inst5(
            .clk(clk),
            .start(power_start),
            .d_real_in(power_real_in),
            .d_img_in(power_img_in),
            .done(power_done),
            .d_out(power_val)
            ); 
            
mel_filter_bank inst6 (
            .clk(clk),
            .rst(rst),
            .start(mel_start),
            .done(mel_done),
            .data_in(mel_in),
            .mel_sptg(mel_out)
            );
endmodule