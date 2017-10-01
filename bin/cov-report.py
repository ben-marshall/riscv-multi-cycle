#!/usr/bin/python3

"""
Post processes the line and toggle coverage reports from verilator into
something which is easier to read and review.
"""

import os
import re
import sys
import yaml
import argparse

import jinja2


class AnnotatedFile(object):
    """
    Describes a single annotated file.
    """

    def __init__(self, in_file):
        """
        Create a new annotated source file represetnation
        """

        self.lines = []
        self.splitlines = []
        self.filename = os.path.basename(in_file.name)

        self.lines = [l.replace("\t","    ") for l in in_file.readlines()]

        matcher = re.compile(" [0-9].*")

        # Very crudely parse the annotated source file into a list of
        # tuples. First item of tuple is None, or integer for number of
        # times the line is hit. The second item is the line itself.
        for line in self.lines:

            check = matcher.match(line)

            if(line[0]=="%"):
                spl = line.partition(" ")
                self.splitlines.append((0,spl[2][:-1]))

            elif(check):
                
                spl = line[1:].partition(" ")
                self.splitlines.append((int(spl[0][1:]),spl[2][:-1]))

            else:
                self.splitlines.append(("",line[:-1]))

    def getscore(self):
        """
        Return the number of covered lines as a percentage.
        """
        num_hits = 0.0
        num_miss = 0.0

        for line in self.splitlines:
            if(line[0] == 0):
                num_miss += 1.0
            if(line[0] != None):
                num_hits += 1.0

        total = num_hits + num_miss
        return (num_hits / total) * 100.0


    def writeout(self, to_file):
        """
        Write out the annotated file with a rendered jinja template to
        the specified file path.
        """
        ld  = jinja2.FileSystemLoader(
            os.path.expandvars("$RVM_HOME/verif/coverage"))
        env = jinja2.Environment(loader = ld)

        template = env.get_template("report-template.html")
        
        result = template.render(lines = self.splitlines,
                                 filename= self.filename)
        
        with open(to_file, "w") as fh:
            fh.write(result)


def parseargs():
    """
    Parses and returns all command line arguments to the program.
    """
    
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("-o","--output", type=str,
        help="output directory path.",
        default="./work/cov-rpt")
    parser.add_argument("-i","--input", nargs='+',
        type=argparse.FileType('r'),
        help="List of input files", default=[])

    args = parser.parse_args()
    return args


def writeOverview(scores, path):
    """
    Writes an overview of the coverage scores for each file.
    """
    ld  = jinja2.FileSystemLoader(
        os.path.expandvars("$RVM_HOME/verif/coverage"))
    env = jinja2.Environment(loader = ld)

    template = env.get_template("overview-template.html")
    
    result = template.render(scores = scores)
    
    with open(path, "w") as fh:
        fh.write(result)


def main():
    """
    Main entry point for using the script
    """
    args = parseargs()

    scores = []

    for inputfile in args.input:
        
        print("Parsing    %s" % inputfile.name)
        af = AnnotatedFile(inputfile)
        name = os.path.basename(inputfile.name)+".html"
        outputfile = os.path.join(args.output,name)
        print("Writing to %s" % outputfile)

        af.writeout(outputfile)
        scores.append((af.filename,af.getscore()))

    writeOverview(scores,os.path.join(args.output,"overview.html"))
    
    sys.exit(0)


if(__name__=="__main__"):
    main()
