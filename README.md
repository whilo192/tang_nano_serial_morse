# Resources

For this project I used the following:
 
 - [A GPL UART Module](https://opencores.org/projects/wbuart32) from <https://opencores.org>.
 - A Japanese language website that explained *exactly* [how to get the serial port on the FPGA working](https://qiita.com/ciniml/items/05ac7fd2515ceed3f88d).
 
# Instructions
 
To get the serial port working on your Tang Nano you should follow the instructions in the website above.
You will most likely require some form of translation to view that web-page.
The CH552T re-flashing seems to be required.
 
To synthesise this project you should ensure that GowinSynthesis, *not* Synplify Pro is selected in `Project -> Configuration` under `Synthesize`.
Synplify Pro seems to be convinced that most of the modules aren't needed and removes them.

Finally, make sure `Use SSPI as regular IO` and `Use MSPI as regular IO` to ensure that the debug outputs work.

For flashing ensure [openFPGALoader](https://github.com/trabucayre/openFPGALoader) is installed, and then run `./load.sh <tty number> serial_morse` from the root directory of this repository. `tty number` is the number et the end of the `tty` name, e.g. `1` for `/dev/ttyUSB1`.

To send characters via serial, make sure `screen` is installed (it is usually called `screen` in your package manager) and run `screen /dev/ttyUSB1 9600`. Typed characters are not echoed until the FPGA has started to output it as Morse code. This is intentional, to help detect decoding / transmission errors. To exit `screen` type `CTRL + A`, `CRTL + \`, then `y` to confirm.

You can also send characters from a file (or `stdin`) by using the `test_buffer.py` script. For example, run `./test_buffer.py <count> <tty number> < test_input.txt`, where count if the maximum amount of bytes to write at a time before reading. This should be set less than 64 to prevent filling the module's ring buffer. This requires `pyserial`, which can be installed via `pip3 install pyserial`. `pip` / `pip3` can be installed via your package manager e.g. via `sudo apt install python3-pip`, or your equivalent.

Any questions can be sent to [louis@whitburn.nz](mailto:louis@whitburn.nz).
