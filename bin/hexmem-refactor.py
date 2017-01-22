#!/usr/bin/python

"""
A script for re-organising verilog hex memory files

usage: ./hexmem-refactor.py <hex file> <mem word width>

Where <mem word width> is in bytes.
"""

import os
import sys

def main():
    """
    Main function for the program.
    """
    input_file      = sys.argv[1]
    target_width    = int(sys.argv[2]) * 2

    to_write = ""
        
    print("Processing: %s" % input_file)

    with open(input_file,"r") as fh:
        for line in fh.readlines():
            slices = line[:-1]
            
            endian_buf = []

            while(len(slices) > 0):
                k = slices[0:target_width]
                endian_buf.insert(0,k+"\n")
                slices = slices[target_width:]

            for b in endian_buf:
                to_write += b

    with open(input_file,"w") as fh:
        fh.write(to_write)

if(__name__=="__main__"):
    main()
