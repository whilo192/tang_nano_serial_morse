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

module top(clk_24, rst_n, led, audio_out, uart_rx, uart_tx, write_index);
    //The uart receive port
    input uart_rx;
    
    //The reset line
    input rst_n;

    //The LED output on the Tang Nano
    output [0:2] led;

    //The 1khz audio output port
    output audio_out;
    
    //Debug output - write_index
    //These don't really do anything but they're good to have for debugging
    output [10:0] write_index;

    //Another debug (sort of) output - the serial transmit port
    //I use this to transmit the recieved ASCII value back so that any error can be noticed
    output uart_tx;

    //The 24MHz clock
    input clk_24;
    
    //The morse value and length decoded from an ascii value
    wire [4:0] morse_value;
    wire [2:0] morse_len;

    //How far through the diven value we are
    reg [2:0] morse_index = 0;

    //Whether to output high or low, and how long to output it for
    reg out_val = 0;
    reg[1:0] repeat_time = 0;

    //The ascii value from memory
    //This is 7 bits!
    wire [6:0] ascii;

    //The index into the memory. Can store 64 characters at a time
    reg [10:0] read_index = 0;

    //Count of clock cycles 
    reg [23:0] count = 0;

    //LED output is inverted!
    //Just blink the LED at the same time as the morse (audio) output
    assign led = {~out_val, ~is_rx, ~is_tx};
    
    //Don't reset the UART
    reg gnd = 0;

    //Whether to transmit, and the value to transmit
    reg do_tx;
    reg [7:0] to_tx;

    //Whether we have recieved, and what we have recieved
    wire recieved;
    wire [7:0] rx_serial;

    //wire is_rx;
    wire is_tx;

    //Setup for the UART module
    reg [30:0] setup = {7'b1000000, 24'd2500};

    //UART modules
    rxuart r1(clk_24, ~rst_n, setup, uart_rx, recieved, rx_serial, is_rx);
    txuart t1(clk_24, ~rst_n, setup, gnd, do_tx, to_tx, 1'b0, uart_tx, is_tx);

    // Basic Morse Code
    // - A dot is 1 unit
    // - A dash is 3 units
    // - There is one unit between a dot/dash and another dot/dash in the same letter
    // - There are 3 units between letters
    // - There are 7 letters between words. I implement this by having a space take one unit
    //   two 3-unit gaps between the letters, and a one unit space makes 7

    localparam CLK_UNITS = 2_400_000; //0.1s per unit

    //What position we have data up to
    wire [10:0] write_index;

    //Reads / writes morse ascii values to memory
    memory mem1(clk_24, ~rst_n, ascii, read_index, write_index, recieved, rx_serial);

    //Decodes ASCII values into morse code
    //Morse code has variable length so we need to work out that as well
    morse m1(clk_24, ~rst_n, ascii, morse_value, morse_len);

    //Speaker driver - outputs a (default of) 1KHz signal when out_val is high
    audio a1(clk_24, ~rst_n, out_val, audio_out);

    always @(posedge clk_24)
    begin
        if (~rst_n)
        begin
            count <= 0;
            to_tx <= 0;
            do_tx <= 8'b0;
            morse_index <= 0;
            out_val <= 0;
            repeat_time <= 0;
            read_index <= 0;
        end
        //Frequency divider - 24MHz to 4Hz
        if (count == CLK_UNITS)
        begin
            //Reset the clock cycle count
            count <= 0;

            //If we have waited the required amount of units, and we have data to read
            //We use != as opposed to < since the memory is circular. This means we can safely write up to 64 (ish) values at one
            if (repeat_time == 0 && write_index != read_index)
            begin
                //If we have finished out latter
                if (morse_index == morse_len)
                begin
                    //Reset, and move to the next work
                    morse_index <= 0;
                    read_index <= read_index + 1;
                    repeat_time <= 3; //next letter - so delay of 3
                    out_val <= 0;
                end
                else
                begin
                    //If it was high it now goes low (finished our letter).
                    if (out_val)
                    begin
                        out_val <= 0;
                        repeat_time <= 1; //next part of same letter - so delay of 1
                    end
                    else //not sounding
                    begin
                        //If this is the first part of a letter then write back to serial
                        if (morse_index == 0)
                        begin
                            do_tx <= 1;
                            to_tx <= ascii;
                        end
                        //Chose our repeat time - 1 is a dash, 0 is a dot
                        repeat_time <= morse_value[morse_index] ? 3 : 1; //dot or dash

                        //Move to the next part of the letter
                        morse_index <= morse_index + 1;

                        //If a space then don't actually sound anything
                        out_val <= (ascii == 32 ? 0 : 1);
                    end
                end
            end
            else
            begin
                //Wait...
                repeat_time <= repeat_time - 1;
            end
        end
        else
        begin
            //Increment clock cycles - and make sure to stop any transmission
            do_tx <= 0;
            count <= count + 1;
        end
    end
endmodule
