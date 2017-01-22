#!/usr/bin/python3

"""
A script for piping arbitrary commands into stdin of other programs.
"""

import io
import os
import sys
import shlex
import logging
import argparse
import subprocess

def parseArgs():
    """
    Parse all command line arguments to the program.
    """
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cmd", "-c",help="The command to run which will have data piped to its stdin.", default = "echo")
    parser.add_argument("--stdin", "-i", help="A file whos content will be piped to stdin of the command being run.")
    parser.add_argument("--stdout", "-o", help="The commands stdout will be piped to this file.")
    parser.add_argument("--stderr", "-e", help="The commands stderr will be piped here.")
    parser.add_argument("--timeout","-t",help="Time in seconds before the program in question in killed. Default is no timeout", default=0, type=int)

    args = parser.parse_args()

    if(args.timeout == 0):
        args.timeout=None
    return args
    
def automate(command, stdin_file, stdout_file, stderr_file, timeout=None):
    """
    Run the supplied command, piping IO to the supplied files. Files are
    passed as paths.
    """
    cmd = shlex.split(command)
    f_stdin  = open(stdin_file,"r")
    f_stdout = open(stdout_file,"w")
    f_stderr = open(stderr_file,"w")
    
    proc = subprocess.run(cmd,
                          stdin    = f_stdin,
                          stdout   = f_stdout,
                          stderr   = f_stderr,
                          timeout  = timeout)
    f_stderr.flush()
    f_stdout.flush()

def main():
    """
    Main function for the program.
    """
    args    = parseArgs()
    automate(args.cmd,args.stdin, args.stdout,args.stderr,timeout=args.timeout)

if(__name__=="__main__"):
    main()
