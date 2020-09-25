/*
Tang Nano Projects
Copyright (C) 2020  Louis Whitburn

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA. 
*/

module morse(clk_24, rst, ascii_in, out, len);
    input clk_24;
    input rst;
    input [6:0] ascii_in;

    output reg [4:0] out = 5'b0;
    output reg [2:0] len = 3'b0;

    reg [7:0] letters [0:25];
    reg [7:0] numbers [0:9];

    //0 short, 1 long
    //Read from right to left (little endian)
    initial begin
        numbers[0] = {5'b11111, 3'd5}; //0
        numbers[1] = {5'b11110, 3'd5}; //1
        numbers[2] = {5'b11100, 3'd5}; //2
        numbers[3] = {5'b11000, 3'd5}; //3
        numbers[4] = {5'b10000, 3'd5}; //4
        numbers[5] = {5'b00000, 3'd5}; //5
        numbers[6] = {5'b00001, 3'd5}; //6
        numbers[7] = {5'b00011, 3'd5}; //7
        numbers[8] = {5'b00111, 3'd5}; //8
        numbers[9] = {5'b01111, 3'd5}; //9

        //Underscore to tell where the morse end
        //The length parameter encodes this in the Verilog
        letters[0] = {5'b000_10, 3'd2}; //A
        letters[1] = {5'b0_0001, 3'd4}; //B
        letters[2] = {5'b0_0101, 3'd4}; //C
        letters[3] = {5'b00_001, 3'd3}; //D
        letters[4] = {5'b0000_0, 3'd1}; //E
        letters[5] = {5'b0_0100, 3'd4}; //F
        letters[6] = {5'b00_011, 3'd3}; //G
        letters[7] = {5'b0_0000, 3'd4}; //H
        letters[8] = {5'b000_00, 3'd2}; //I
        letters[9] = {5'b0_1110, 3'd4}; //J
        letters[10] = {5'b00_101, 3'd3}; //K
        letters[11] = {5'b0_0010, 3'd4}; //L
        letters[12] = {5'b000_11, 3'd2}; //M
        letters[13] = {5'b000_01, 3'd2}; //N
        letters[14] = {5'b00_111, 3'd3}; //O
        letters[15] = {5'b0_0110, 3'd4}; //P
        letters[16] = {5'b0_1011, 3'd4}; //Q
        letters[17] = {5'b00_010, 3'd3}; //R
        letters[18] = {5'b00_000, 3'd3}; //S
        letters[19] = {5'b0000_1, 3'd1}; //T
        letters[20] = {5'b00_100, 3'd3}; //U
        letters[21] = {5'b0_1000, 3'd4}; //V
        letters[22] = {5'b00_110, 3'd3}; //W
        letters[23] = {5'b0_1001, 3'd4}; //X
        letters[24] = {5'b0_1101, 3'd4}; //Y
        letters[25] = {5'b0_0011, 3'd4}; //Z
    end

    always @(posedge clk_24)
    begin
        if (rst)
        begin
            out <= 5'b0;
            len <= 5'b0;
        end
        else if (ascii_in == 32) //Space
        begin
            out <= 5'b0;
            len <= 3'd1; //space is 2 lots of 3 unit waits, plus a 1 unit wait is a 7 unit wait
        end
        else if (ascii_in < 48) //Less than numbers
        begin
            out <= 5'b0;
            len <= 3'b0;
        end
        else if (ascii_in < 58) //Numbers
        begin
            {out, len} = numbers[ascii_in - 48]; 
        end
        else if (ascii_in < 65) //Less than uppercase
        begin
            out <= 5'b0;
            len <= 3'b0;
        end
        else if (ascii_in < 91) //Uppercase
        begin
            {out, len} = letters[ascii_in - 65]; 
        end
        else if (ascii_in < 97) //Less than lowercase
        begin
            out <= 5'b0;
            len <= 3'b0;
        end
        else if (ascii_in < 123) //Lowercase
        begin
            {out, len} = letters[ascii_in - 97]; 
        end
        else //The rest
        begin
            out <= 5'b0;
            len <= 3'b0;
        end
    end
endmodule
