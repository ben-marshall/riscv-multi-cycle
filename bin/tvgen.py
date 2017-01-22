#!/usr/bin/python3

"""
A program for generating random test vectors for the core.

The program will write out a random sequence of instructions as assembly
using a stated seed value. This is then compiled and a hex file generated.
from this hexfile, a test vector is created which describes what every
pin of the core should be at each cycle.
"""

import os
import sys
import json
import random
import logging
import argparse

import bitstring

class RandomVariable(object):
    """
    Represents the interface to a single random variable used by the program.
    """

    def __init__(self):
        """
        Instance a new random variable.
        """
        pass

    def sample(self):   
        """
        Return a new sample of the random variable. For the base class,
        this will just be a random integer X where 0 <= X <= 1000 as a
        BitArray
        """
        return bitstring.BitArray(uint=random.randint(0,1000),length=32)
    
    def strsample(self):
        """
        Return the string formatted version of the sample.
        """
        return str(self.sample().uint)

class Register(RandomVariable):
    """
    Represents a single register value as a random variable.
    """

    def __init__(self):
        """
        Instance a new register random variable.
        """
        self.__choices__ = ["zero","ra"  ,"sp"  ,"gp"  ,"tp"  ,
        "t0"  ,"t1"  ,"t2"  ,"s0"  ,"s1"  ,"a0"  ,"a1"  ,"a2"  ,"a3"  ,
        "a4"  ,"a5"  ,"a6"  ,"a7"  ,"s2"  ,"s3"  ,"s4"  ,"s5"  ,"s6"  ,
        "s7"  ,"s8"  ,"s9"  ,"s10" ,"s11" ,"t3"  ,"t4"  ,"t5"  ,"t6"  ]


    def sample(self):
        """
        Returns an 5 bit BitArray representing a single register between 0 and
        31
        """
        return random.choice(self.__choices__)
   
    def strsample(self):
        """
        Return the string formatted version of the sample.
        """
        return str(self.sample())

class Immediate(RandomVariable):
    """
    Represents a single immediate value as a random variable.
    """
    
    def __init__(self, size):
        """
        An immediate random variable of <size> bits long.
        """
        self.size = size
        self.minimum = 0
    
    def sample(self):
        """
        Return a <size> bit long integer.
        """
        v = random.getrandbits(self.size)
        if(v <= self.minimum):
            v = self.minimum + 1
        return bitstring.BitArray(uint=v,
                                    length=self.size)
    

class Instruction(RandomVariable):
    """
    Represents a single instruction ready to be sampled with randomised
    arguments.
    """
    
    def __init__(self, memonic, arguments, memArgFormat=False):
        """
        Create a new instruction with the supplied memonic and list of
        arguments.
        """
        self.__memonic__    = memonic
        self.__arguments__  = arguments
        self.memArgFormat = memArgFormat

    def getMemonic(self):
        return self.__memonic__

    def addArgument(self,arg):
        """
        Add a new argument to the end of the list of internal arguments.
        """
        self.__arguments__.append(arg)

    def sample(self):
        """
        Return a STRING representing a random sample of the instruction with
        all of its arguments.
        """
        tr = self.__memonic__
        arg_choices = []
        for i in range(0,len(self.__arguments__)):
            arg_choices.append(self.__arguments__[i].strsample())
        
        if(self.memArgFormat):
            tr = tr + " " + arg_choices[0] + ",%s(%s)" % (arg_choices[2],arg_choices[1])
        else:
            tr = tr + " " + ",".join(arg_choices)
        return tr

class ISA(object):
    """
    A collection of instructions.
    """

    def __init__(self):
        """
        Create a new empty ISA.
        """
        self.instructions = []

    def getMemonics(self):
        """
        Return a list of instruction memonics from the ISA.
        """
        return [i.getMemonic() for i in self.instructions]

    def __argFromJson__(self, argjson):
        """
        Translate the supplied json and return either an Immediate or
        Register class.
        """
        tr =  None
        name = argjson["name"]

        if(argjson["type"] == "register"):
            tr = Register()
        elif(argjson["type"] == "immediate"):
            tr = Immediate(argjson["length"])
            if("min" in argjson):
                tr.minimum = argjson["min"]
        else:
            logging.error("Unknown argument type: %s" % argjson["type"])
        return tr

    def fromJSON(self, json_path):
        """
        Load the set of instructions from a JSON file.
        """
        with open(json_path,"r") as fh:
            data = json.load(fh)
            for instr in data["instructions"]:
                memonic   = instr["memonic"]
                args      = instr["arguments"]

                memFmt = False
                if("mem-arg-format" in instr and instr["mem-arg-format"]==1):
                    memFmt=True

                arguments = [self.__argFromJson__(a) for a in args]
                I         = Instruction(memonic,arguments,memArgFormat=memFmt)
                self.instructions.append(I)

    def generate(self, N, outputfile = "a.asm"):
        """
        Generate a random sequence of instructions N elements long.
        """
        
        with open(outputfile,"w") as fh:
            fh.write("_start:\n")
            for i in range(0,N):
                instr = random.choice(self.instructions)
                fh.write("   "+instr.sample() + "\n")
            fh.write("_end: j _end\n")


def parseArgs():
    """
    Parse and return command line arguments to the program.
    """

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--json", type=str,
        help="The JSON file which describes the instructions in the ISA.", 
        default="./verif/specs/instructions.json")
    parser.add_argument("-o", type=str,help="output file name", default="a.S")
    parser.add_argument("-n",type=int,default=100,
        help="The number of instructions to generate.")

    args = parser.parse_args()
    return args

def main():
    """
    Main function for the script
    """
    
    args = parseArgs()

    isa = ISA()
    isa.fromJSON(args.json)
    
    isa.generate(args.n, outputfile=args.o)

if(__name__ == "__main__"):
    main()
        


