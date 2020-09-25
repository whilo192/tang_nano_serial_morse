#!/usr/bin/env python3

import serial
import sys
import time

def main(chars, count, timeout, port):
    chars_len = len(chars)

    start_index = 0

    #Open our serial port
    ser = serial.Serial(port=port, baudrate=9600, timeout=timeout)
       
    #Loop until we're out of characters
    while start_index < chars_len:
        #Calculate how many to write - at most count, but this may be less if we're near the end of the character buffer
        to_write = min(chars_len - start_index, count)

        write_str = "".join(chars[start_index:(start_index + to_write)])

        for i, char in enumerate(write_str):
            print("w: ", char, " -> ", start_index + i)
            ser.write(char.encode("ascii"))
            #time.sleep(0.05) #20 per second seems to work

        #Read the characters, with a 6s timeout
        for i in range(to_write):
            s_read = ser.read().decode("ascii")
            print("r: ", s_read, " -> ", start_index + i)

        #Increment count. If we wrote less then count start_index will now be set equal to chars_len and the loop will terminate
        start_index += to_write

    ser.close()

if __name__ == "__main__":
    #Longest is 5 dashes (3 long with 1 space is 20 units), with a 0.1s unit this is ~2s, so use 3
    TIMEOUT = 6

    #Tends to be ttyUSB1
    SER_PORT_BASE = "/dev/ttyUSB"

    main(input(), int(sys.argv[1]), TIMEOUT, SER_PORT_BASE + str(sys.argv[2]))
