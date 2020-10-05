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

module audio(clk_24, rst, vol, speaker);
    //Default frequency of 500Hz
    parameter FREQ = 500;
    
    //24MHz clock
    input clk_24;

    //Reset
    input rst;

    //Whether to play audio or not
    input vol;

    //The speaker output
    output speaker;

    //The clock feequency reduced to FREQ
    reg down_freq = 0;

    //A counter for frequency conversion
    reg [23:0] count = 0;

    //Output 1KHz or nothing
    assign speaker = vol ? down_freq : 0;

    always @(posedge clk_24)
    begin
        //Increment here to avoid resetting issues when nonblocking
        count <= count + 1;
        //Simple clock divider - 50% duty cycle, square wave - sound wonderful...
        //Uses multiplication - FREQ must divide half the input clock frequency (24MHz)
        if (FREQ * count == 12_000_000)
        begin
            count <= 0;
            down_freq <= ~down_freq;
        end

        if (rst)
        begin
            count <= 0;
            down_freq <= 0;
        end
    end
endmodule
