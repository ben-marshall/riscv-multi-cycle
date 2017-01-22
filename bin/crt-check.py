#!/usr/bin/python3

"""
A script for comparing the output of the random test flows from the
CSIM and RTL sim.
"""

import io
import os
import sys
import shlex
import logging
import argparse
import subprocess

RED   = "\033[1;31m"  
BLUE  = "\033[1;34m"
CYAN  = "\033[1;36m"
GREEN = "\033[0;32m"
RESET = "\033[0;0m"
BOLD    = "\033[;1m"
REVERSE = "\033[;7m"

def red(s):
    return RED+s+RESET

def green(s):
    return GREEN+s+RESET

def parseArgs():
    """
    Parse all command line arguments to the program.
    """
    parser = argparse.ArgumentParser(description=__doc__)

    parser.add_argument("--rtl-log", help="The log of the RTL simulation")
    parser.add_argument("--sim-log", help="The log of the C simulator.")

    args = parser.parse_args()
    return args

def getRegistersFromRTL(rtl_log):
    """
    Parse the RTL simulation log and return a dictionary of register
    addresses to values.
    """
    tr = {}

    with open(rtl_log,"r") as fh:
        for line in fh.readlines():
            if (line.startswith(" GPR:")):
                l = line.rstrip(" \n").lstrip(" GPR: ")
                s = l.split(":")
                addr = int(s[0].rstrip(" \t").lstrip())
                val  = s[1].lstrip().rstrip()
                tr[addr]=val
    return tr

def getRegistersFromSim(sim_log):
    """
    Parse the CSIM simulation log and return a dictionary of register
    addresses to values.
    """
    tr = {}
    with open(sim_log,"r") as fh:
        lines = fh.readlines()[-9:-1]
        i = 0
        for l in lines:
            l = l.rstrip(" \n").lstrip(" :").replace("zero:","zero :")
            v  = [a for a in l.split(" ") if a != ""]
            tr[i] = "0x"+v[2][-8:]
            i += 1
            tr[i] = "0x"+v[5][-8:]
            i += 1
            tr[i] = "0x"+v[8][-8:]
            i += 1
            tr[i] = "0x"+v[11][-8:]
            i += 1
    return tr

def main():
    """
    main function for the program.
    """
    
    args = parseArgs()

    print("Checking Constrained random test results:")
    print(" RTL Log: %s" % args.rtl_log)
    print(" SIM Log: %s" % args.sim_log)

    rtl = getRegistersFromRTL(args.rtl_log)
    sim = getRegistersFromSim(args.sim_log)
    difs = 0
    for i in range(0, 32):
        if(rtl[i] == sim[i]):
            print("REG %d\t RTL: %s  SIM: %s" % (i,green(rtl[i]),green(sim[i])))
        else:
            print("REG %d\t RTL: %s  SIM: %s" % (i,red(rtl[i]),green(sim[i])))
            difs += 1

    if(difs>0):
        print("Mismatches detected. Test Failed.")
    else:
        print("No Mismatches. Test Passed.")

    sys.exit(difs)


if(__name__ == "__main__"):
    main()
