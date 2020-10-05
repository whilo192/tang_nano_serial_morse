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

    output reg [6:0] out = 6'b0;
    output reg [2:0] len = 3'b0;

    reg [9:0] letters [0:25];
    reg [9:0] numbers [0:9];
    reg [9:0] punctuation [0:19];

    reg [4:0] punc_index;

    //0 short, 1 long
    //Read from right to left (little endian)
    initial begin
        numbers[0] = {6'b00_11111, 3'd5}; //0
        numbers[1] = {6'b00_11110, 3'd5}; //1
        numbers[2] = {6'b00_11100, 3'd5}; //2
        numbers[3] = {6'b00_11000, 3'd5}; //3
        numbers[4] = {6'b00_10000, 3'd5}; //4
        numbers[5] = {6'b00_00000, 3'd5}; //5
        numbers[6] = {6'b00_00001, 3'd5}; //6
        numbers[7] = {6'b00_00011, 3'd5}; //7
        numbers[8] = {6'b00_00111, 3'd5}; //8
        numbers[9] = {6'b00_01111, 3'd5}; //9

        //Underscore to tell where the morse end
        //The length parameter encodes this in the Verilog
        letters[0] = {7'b00000_10, 3'd2}; //A
        letters[1] = {7'b000_0001, 3'd4}; //B
        letters[2] = {7'b000_0101, 3'd4}; //C
        letters[3] = {7'b0000_001, 3'd3}; //D
        letters[4] = {7'b000000_0, 3'd1}; //E
        letters[5] = {7'b000_0100, 3'd4}; //F
        letters[6] = {7'b0000_011, 3'd3}; //G
        letters[7] = {7'b000_0000, 3'd4}; //H
        letters[8] = {7'b00000_00, 3'd2}; //I
        letters[9] = {7'b000_1110, 3'd4}; //J
        letters[10] = {7'b0000_101, 3'd3}; //K
        letters[11] = {7'b000_0010, 3'd4}; //L
        letters[12] = {7'b00000_11, 3'd2}; //M
        letters[13] = {7'b00000_01, 3'd2}; //N
        letters[14] = {7'b0000_111, 3'd3}; //O
        letters[15] = {7'b000_0110, 3'd4}; //P
        letters[16] = {7'b000_1011, 3'd4}; //Q
        letters[17] = {7'b0000_010, 3'd3}; //R
        letters[18] = {7'b0000_000, 3'd3}; //S
        letters[19] = {7'b000000_1, 3'd1}; //T
        letters[20] = {7'b0000_100, 3'd3}; //U
        letters[21] = {7'b000_1000, 3'd4}; //V
        letters[22] = {7'b0000_110, 3'd3}; //W
        letters[23] = {7'b000_1001, 3'd4}; //X
        letters[24] = {7'b000_1101, 3'd4}; //Y
        letters[25] = {7'b000_0011, 3'd4}; //Z

        punctuation[0] = {7'b0_110101, 3'd6}; //! 33
        punctuation[1] = {7'b0_010010, 3'd6}; //" 34
        punctuation[2] = {7'b 1001000, 3'd7}; //$ 36
        punctuation[3] = {7'b00_00010, 3'd5}; //& 38
        punctuation[4] = {7'b0_011110, 3'd6}; //' 39
        punctuation[5] = {7'b00_01101, 3'd5}; //( 40
        punctuation[6] = {7'b0_101101, 3'd6}; //) 41
        punctuation[7] = {7'b00_01010, 3'd5}; //+ 43
        punctuation[8] = {7'b0_110011, 3'd6}; //, 44
        punctuation[9] = {7'b0_100001, 3'd6}; //- 45
        punctuation[10] = {7'b0_101010, 3'd6}; //. 46
        punctuation[11] = {7'b00_01001, 3'd5}; /// 47
        punctuation[12] = {7'b0_000111, 3'd6}; //: 58
        punctuation[13] = {7'b0_010101, 3'd6}; //; 59
        punctuation[14] = {7'b00_10001, 3'd5}; //= 61
        punctuation[15] = {7'b0_001100, 3'd6}; //? 63
        punctuation[16] = {7'b0_010110, 3'd6}; //@ 64
        punctuation[17] = {7'b0_101100, 3'd6}; //_ 95

        punctuation[18] = {7'b0, 3'd1}; // space is 2 lots of 3 unit waits, plus a 1 unit wait is a 7 unit wait
        punctuation[19] = {7'b0, 3'd0}; //empty
    end

    always @(posedge clk_24)
    begin
        if (rst)
        begin
            {out, len} = punctuation[19];
        end
        else if (ascii_in >= 48 && ascii_in < 58) //Numbers
        begin
            {out, len} = numbers[ascii_in - 48]; 
        end
        else if (ascii_in >= 65 && ascii_in < 91) //Uppercase
        begin
            {out, len} = letters[ascii_in - 65]; 
        end
        else if (ascii_in >= 97 && ascii_in < 123) //Lowercase
        begin
            {out, len} = letters[ascii_in - 97]; 
        end
        else //Punctuation and invalid code points
        begin
            case (ascii_in)
                7'd33      : punc_index = 5'd0;
                7'd34      : punc_index = 5'd1;
                7'd36      : punc_index = 5'd2;
                7'd38      : punc_index = 5'd3;
                7'd39      : punc_index = 5'd4;
                7'd40      : punc_index = 5'd5;
                7'd41      : punc_index = 5'd6;
                7'd43      : punc_index = 5'd7;
                7'd44      : punc_index = 5'd8;
                7'd45      : punc_index = 5'd9;
                7'd46      : punc_index = 5'd10;
                7'd47      : punc_index = 5'd11;
                7'd58      : punc_index = 5'd12;
                7'd59      : punc_index = 5'd13;
                7'd61      : punc_index = 5'd14;
                7'd63      : punc_index = 5'd15;
                7'd64      : punc_index = 5'd16;
                7'd95      : punc_index = 5'd17;
                7'd32      : punc_index = 5'd18;
                default    : punc_index = 5'd19;
            endcase

            {out, len} = punctuation[punc_index];
        end
    end
endmodule
