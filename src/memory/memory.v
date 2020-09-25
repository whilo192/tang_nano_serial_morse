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

module memory (clk_24, rst, ascii_out, read_index, write_index, rx, rx_in);
    input clk_24;
    input rst;
    input rx;

    input [10:0] read_index;
    input [7:0] rx_in;

    output reg [10:0] write_index = 0;
    output wire [6:0] ascii_out;

    wire [31:0] d_out;
    reg [31:0] d_in = 0;
    reg [31:0] ascii_buf = 0;

    reg oce = 0;
    reg ce = 1;
    reg wre = 0;

    assign ascii_out = ascii_buf[6:0];

    reg [10:0] addr = 0;

    wire gw_gnd;
    assign gw_gnd = 1'b0;

    //Each clock cycle handle some form of request
    always @(posedge clk_24)
    begin
        //If we've recieved data then write it
        if (rx)
        begin
            addr <= write_index;
            write_index <= write_index + 1;
            d_in <= {24'b0, rx_in};
            wre <= 1;
        end
        else
        begin
            //Otherwise, always keep the index memory value up to date
            addr <= read_index;
            ascii_buf <= d_out;
            wre <= 0;
        end

        if (rst)
        begin
            write_index <= 11'b0;
            d_in <= 31'b0;
            ascii_buf <= 31'b0;
            addr <= 11'b0;
        end
    end

    SP sp_inst_0 (
        .DO(d_out),
        .CLK(clk_24),
        .OCE(oce),
        .CE(ce),
        .RESET(rst),
        .WRE(wre),
        .BLKSEL({gw_gnd,gw_gnd,gw_gnd}),
        .AD({addr,gw_gnd,gw_gnd,gw_gnd}),
        .DI(d_in)
    );

    defparam sp_inst_0.READ_MODE = 1'b0;
    defparam sp_inst_0.WRITE_MODE = 2'b00;
    defparam sp_inst_0.BIT_WIDTH = 8;
    defparam sp_inst_0.BLK_SEL = 3'b000;
    defparam sp_inst_0.RESET_MODE = "SYNC";

endmodule
