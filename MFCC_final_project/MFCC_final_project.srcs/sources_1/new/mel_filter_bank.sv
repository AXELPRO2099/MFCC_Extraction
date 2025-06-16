`timescale 1ns / 1ps
module mel_filter_bank(
input wire signed [15:0] data_in [0:111],
input clk, rst, start,
output reg done,
output logic signed [15:0] mel_sptg [0:25]
);

//This module consists of the mel filter bank of 26 triangular filters.

logic signed [15:0] bin_coeff [0:16] ='{
16'h1249, //1/7                     0 
16'h2492, //2/7                     1 
16'h36db, //3/7                     2
16'h4925, //4/7                     3
16'h5b6e, //5/7                     4
16'h6db7, //6/7                     5 
16'h1555, //1/6                     6
16'h2aab, //2/6        1/3          7
16'h4000, //3/6        0.5          8
16'h5555, //4/6        2/3          9
16'h6aab, //5/6                    10
16'h199a, //1/5        0.2         11
16'h3333, //2/5        0.4         12
16'h4ccd, //3/5        0.6         13
16'h6666, //4/5        0.8         14  
16'h2000, //0.25                   15
16'h6000 //0.75                    16
};


typedef enum logic [1:0]{
IDLE,
BUSY,
DONE
}states_t;

states_t state;

logic signed [27:0] mel_bin [0:25];

always_ff @(posedge clk) begin
    if(rst) begin
        state <= IDLE;
        done <= 0;
        for(int i=0; i<26; i++) begin
            mel_bin[i] <= 0;
        end
    end
    else if(start) begin
        state <= BUSY;        
    end
    else begin
        if(state == BUSY) begin
            
            mel_bin[0]  = ((data_in[13] + data_in[14]   * bin_coeff[8]) + 12'sd2048) >>> 12;
            mel_bin[1]  = ((data_in[14] * bin_coeff[8]  + data_in[15]  + data_in[16]    * bin_coeff[8])   + 12'd2048) >>> 12;
            mel_bin[2]  = ((data_in[16] * bin_coeff[8]  + data_in[17]  + data_in[18]    * bin_coeff[8])   + 12'd2048) >>> 12;
            mel_bin[3]  = ((data_in[18] * bin_coeff[8]  + data_in[19]  + data_in[20]      * bin_coeff[8])   + 12'd2048) >>> 12;
            mel_bin[4]  = ((data_in[20] * bin_coeff[8]  + data_in[21]  + data_in[22]    * bin_coeff[9]    + data_in[23]     * bin_coeff[7]) + 12'd2048) >>> 12;
            mel_bin[5]  = ((data_in[22] * bin_coeff[7]  + data_in[23]  * bin_coeff[9]    + data_in[24]     + data_in[25]     * bin_coeff[8]) + 12'd2048) >>> 12;
            mel_bin[6]  = ((data_in[25] * bin_coeff[8]  + data_in[26]  + data_in[27]    * bin_coeff[9]    + data_in[28]     * bin_coeff[7]) + 12'd2048) >>> 12;
            mel_bin[7]  = ((data_in[27] * bin_coeff[7]  + data_in[28]  * bin_coeff[9]    + data_in[29]     + data_in[30]     * bin_coeff[8]) + 12'd2048) >>> 12;
            mel_bin[8]  = ((data_in[30] * bin_coeff[8]  + data_in[31]  + data_in[32]    * bin_coeff[9]    + data_in[33]     * bin_coeff[7]) + 12'd2048) >>> 12;
            mel_bin[9]  = ((data_in[32] * bin_coeff[9]  + data_in[33]  * bin_coeff[7]    + data_in[34]     + data_in[35]     * bin_coeff[9] + data_in[36] * bin_coeff[7]) + 12'd2048) >>> 12;
            mel_bin[10] = ((data_in[35] * bin_coeff[7]  + data_in[36]  * bin_coeff[9]    + data_in[37]     + data_in[38]     * bin_coeff[16] + data_in[39] * bin_coeff[8] + data_in[40] * bin_coeff[15]) + 12'd2048) >>> 12;
            mel_bin[11] = ((data_in[38] * bin_coeff[15] + data_in[39]  * bin_coeff[8]    + data_in[40]     * bin_coeff[16]   + data_in[41] + data_in[42] * bin_coeff[9] + data_in[43] * bin_coeff[7]) + 12'd2048) >>> 12;
            mel_bin[12] = ((data_in[42] * bin_coeff[7]  + data_in[43]  * bin_coeff[9]    + data_in[44]     + data_in[45]     * bin_coeff[9] + data_in[46] * bin_coeff[7]) + 12'd2048) >>> 12;
            mel_bin[13] = ((data_in[45] * bin_coeff[7]  + data_in[46]  * bin_coeff[9]    + data_in[47]     + data_in[48]     * bin_coeff[16] + data_in[49] * bin_coeff[8] + data_in[50] * bin_coeff[15]) + 12'd2048) >>> 12;
            mel_bin[14] = ((data_in[48] * bin_coeff[15] + data_in[49]  * bin_coeff[8]   + data_in[50]     * bin_coeff[16]   + data_in[51] + data_in[52] * bin_coeff[16] + data_in[53] * bin_coeff[8] + data_in[54] * bin_coeff[15]) + 12'd2048) >>> 12;
            mel_bin[15] = ((data_in[52] * bin_coeff[15] + data_in[53]  * bin_coeff[8]   + data_in[54]     * bin_coeff[16]   + data_in[55] + data_in[56] * bin_coeff[16] + data_in[57] * bin_coeff[8] + data_in[58] * bin_coeff[15]) + 12'd2048) >>> 12;
            mel_bin[16] = ((data_in[56] * bin_coeff[15] + data_in[57]  * bin_coeff[8]   + data_in[58]     * bin_coeff[16]   + data_in[59] + data_in[60] * bin_coeff[14] + data_in[61] * bin_coeff[13] + data_in[62] * bin_coeff[12] + data_in[63] * bin_coeff[11]) + 12'd2048) >>> 12;
            mel_bin[17] = ((data_in[60] * bin_coeff[11] + data_in[61]  * bin_coeff[12]  + data_in[62]     * bin_coeff[13]   + data_in[63] * bin_coeff[14] + data_in[64] + data_in[65] * bin_coeff[16] + data_in[66] * bin_coeff[8] + data_in[67] * bin_coeff[15]) + 12'd2048) >>> 12;
            mel_bin[18] = ((data_in[65] * bin_coeff[15] + data_in[66]  * bin_coeff[8]   + data_in[67]     * bin_coeff[16]   + data_in[68] + data_in[69] * bin_coeff[14] + data_in[70] * bin_coeff[13] + data_in[71] * bin_coeff[12] + data_in[72] * bin_coeff[11]) + 12'sd2048) >>> 12;
            mel_bin[19] = ((data_in[69] * bin_coeff[11] + data_in[70]  * bin_coeff[12]  + data_in[71]     * bin_coeff[13]   + data_in[72] * bin_coeff[14] + data_in[73] + data_in[74] * bin_coeff[14] + data_in[75] * bin_coeff[13] + data_in[76] * bin_coeff[12] + data_in[77] * bin_coeff[11]) + 12'd2048) >>> 12;
            mel_bin[20] = ((data_in[74] * bin_coeff[11] + data_in[75]  * bin_coeff[12]  + data_in[76]     * bin_coeff[13]   + data_in[77] * bin_coeff[14] + data_in[78] + data_in[79] * bin_coeff[10] + data_in[80] * bin_coeff[9] + data_in[81] * bin_coeff[8] + data_in[82] * bin_coeff[7] + data_in[83] * bin_coeff[6]) + 12'd2048) >>> 12;
            mel_bin[21] = ((data_in[79] * bin_coeff[6]  + data_in[80]  * bin_coeff[7]   + data_in[81]     * bin_coeff[8]    + data_in[82] * bin_coeff[9] + data_in[83] * bin_coeff[10] + data_in[84] + data_in[85] * bin_coeff[14] + data_in[86] * bin_coeff[13] + data_in[87] * bin_coeff[12] + data_in[88] * bin_coeff[11]) + 12'd2048) >>> 12;
            mel_bin[22] = ((data_in[85] * bin_coeff[11] + data_in[86]  * bin_coeff[12]  + data_in[87]     * bin_coeff[13]   + data_in[88] * bin_coeff[14] + data_in[89] + data_in[90] * bin_coeff[10] + data_in[91] * bin_coeff[9] + data_in[92] * bin_coeff[8] + data_in[93] * bin_coeff[7] + data_in[94] * bin_coeff[6]) + 12'd2048) >>> 12;
            mel_bin[23] = ((data_in[90] * bin_coeff[6]  + data_in[91]  * bin_coeff[7]   + data_in[92]     * bin_coeff[8]    + data_in[93] * bin_coeff[9] + data_in[94] * bin_coeff[10] + data_in[95] + data_in[96] * bin_coeff[5] + data_in[97] * bin_coeff[4] + data_in[98] * bin_coeff[3] + data_in[99] * bin_coeff[2] + data_in[100] * bin_coeff[1] + data_in[101] * bin_coeff[0]) + 12'd2048) >>> 12;
            mel_bin[24] = ((data_in[96] * bin_coeff[0]  + data_in[97]  * bin_coeff[1]   + data_in[98]     * bin_coeff[2]    + data_in[99] * bin_coeff[3] + data_in[100] * bin_coeff[4] + data_in[101] * bin_coeff[5] + data_in[102] + data_in[103] * bin_coeff[5] + data_in[104] * bin_coeff[4] + data_in[105] * bin_coeff[3] + data_in[106] * bin_coeff[2] + data_in[107] * bin_coeff[1] + data_in[108] * bin_coeff[0]) + 12'd2048) >>> 12;
            mel_bin[25] = ((data_in[103] * bin_coeff[0] + data_in[104] * bin_coeff[1]   + data_in[105]    * bin_coeff[2]    + data_in[106] * bin_coeff[3] + data_in[107] * bin_coeff[4] + data_in[108] * bin_coeff[5] + data_in[109]) + 12'd2048) >>> 12;
            state <= DONE;
        end
        else if(state == DONE) begin
            done <= 1;
            state <= state;
        end
        else begin
            done <= done;
            //state <= state;
        end
    end
end
always_comb begin
    if(done) begin
        for (int i=0; i<26; i++) begin
            mel_sptg[i] <= mel_bin[i];
        end
    end
end
endmodule

