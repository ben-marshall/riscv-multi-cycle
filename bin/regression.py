#!python2.7

"""
A simple script for running regressions using the directed selfchecking
tests.
"""

import os
import sys
import csv
import shutil
import subprocess

RED   = "\033[1;31m"  
BLUE  = "\033[1;34m"
CYAN  = "\033[1;36m"
GREEN = "\033[0;32m"
RESET = "\033[0;0m"
BOLD    = "\033[;1m"
REVERSE = "\033[;7m"

class RegressionTest(object):
    """
    A simple holder to describe a single regression test.
    """

    def __init__(self, hex_file, 
                       pass_addr, 
                       dis_file=None,
                       fail_addr=None,
                       halt_addr=None):
        """
        Instance a new regression test.
        """
        self.hex_file    = os.path.expandvars(hex_file) 
        self.dis_file    = os.path.expandvars(dis_file) 
        self.pass_addr   = pass_addr
        self.fail_addr   = fail_addr
        self.halt_addr   = halt_addr

        self.result      = None
        self.result_str  = "      "
        self.__infer_pass_fail_addr__()


    def __infer_pass_fail_addr__(self):
        """
        Try and automatically work out the pass/fail address from the
        dissassembly.
        """
        if(os.path.isfile(self.dis_file)):
            with open(self.dis_file,"r") as fh:
                for line in fh.readlines():
                    if " <pass>:" in line:
                        self.pass_addr = line.split(" ")[0]
                    elif " <fail>:" in line:
                        self.fail_addr = line.split(" ")[0]


    def __str__(self):
        return "%s | %s | %s | %s | %s" % (self.result_str,
            self.pass_addr,
            self.fail_addr,
            self.halt_addr,
            self.hex_file)

    def passed(self,output):
        self.result="PASSED"
        self.result_str=GREEN+"PASSED"+RESET

    def failed(self,output):
        self.result="FAILED"
        self.result_str=RED  +"FAILED"+RESET

    def errored(self,exception):
        self.result="ERROR "
        self.result_str=RED+"ERROR "+RESET
                                                                

def load_db(file_path):
    """
    Load and return the CSV database
    """

    tr = []

    with open(file_path,"r") as fh:
        reader = csv.DictReader(fh,delimiter=",")

        for row in reader:
            hex_file    = row["hex" ].rstrip("\n ").lstrip(" ")
            dis_file    = row["dis" ].rstrip("\n ").lstrip(" ")
            pass_addr   = row["pass"].rstrip("\n ").lstrip(" ")
            fail_addr   = row["fail"].rstrip("\n ").lstrip(" ")
            halt_addr   = row["halt"].rstrip("\n ").lstrip(" ")
            tr.append(RegressionTest(hex_file, pass_addr,
                                     dis_file  = dis_file,
                                     halt_addr = halt_addr,
                                     fail_addr = fail_addr))

    return tr

def run_regressions(to_run):
    """
    Takes a list of RegressionTest objects and runs them in order.
    """

    print("RESULT | PASS       | FAIL       | HALT       | TEST")
    print("-------|------------|------------|------------|--------------------")
    i = 0
    for test in to_run:

        cmd = ["make", "run-vl",
                "TEST_HEX=%s"   % test.hex_file,
                "HALT_ADDR=%s"  % test.halt_addr,
                "PASS_ADDR=%s"  % test.pass_addr,
                "FAIL_ADDR=%s"  % test.fail_addr]
        try:
            output = subprocess.check_output(cmd)

            if("TEST PASS" in output):
                test.passed(output)
            elif("TEST FAIL" in output):
                test.failed(output)
            else:
                test.failed(output)
            vcd_name = os.path.basename(test.hex_file).split(".")[0]+".vcd"
            shutil.copyfile("./work/waves.vcd", "./work/%s" % vcd_name)
        
        except subprocess.CalledProcessError as e:
            test.errored(e)

        i += 1
        print(str(test))

def main():
    """
    Main function for the program
    """

    rdb = load_db(sys.argv[1])
    
    run_regressions(rdb)


if(__name__ == "__main__"):
    main()
