#!/usr/bin/python3

"""
A Visualiser for the actions of ISA instructions.
"""

import os
import sys
import json

def main():
    """
    Main function for the script.
    """

    inputfile = sys.argv[1]
    ISA = None

    with open(inputfile,"r") as fh:
        ISA = json.load(fh)
    
    for instr in ISA:
        print(instr)

        for action in ISA[instr]["actions"]:
            for target in action:
                split = action[target].split(" ")
                lhs,op,rhs =split[0:3]
                print("\t%s <- '%s' %s '%s'" % (target,lhs,op,rhs))

if(__name__ == "__main__"):
    main()
