#!/usr/bin/python3

"""
A simple post simulation coverage script.
"""

import os
import sys
import json
import logging
import argparse

import bitstring

import pyvcd

RED   = "\033[1;31m"  
GREEN = "\033[0;32m"
RESET = "\033[0;0m"

class Coverbin(object):
    """
    A single coverage bin
    """

    def __init__(self, highval, lowval, coverpoint):
        """
        Create a new coverage bin for storing counts.
        """
        self.__count__ = 0
        self.percent_covered = 0.0
        self.high = int(highval)
        self.low  = int(lowval)
        self.parentPoint = coverpoint
        self.hitAtTimes = set([])
    
    def __str__(self):
        if(self.high == self.low):
            return "%s == %d" % (self.parentPoint.name,self.high)
        else:
            return "%d <= %s <= %d" % (self.low, 
                self.parentPoint.name,self.high)
    
    def toDict(self, withStats = True):
        """
        Return a dictionary representation of the coverbin
        """
        tr = {}
        if(self.high == self.low):
            tr["value"] = self.high
        else:
            tr["high"] = self.high
            tr["low"] = self.low
        if(withStats):
            tr["hits"] = self.__count__
            tr["cov"] = self.percent_covered
        return tr
        
    def getHitTimes(self):
        return self.hitAtTimes

    def matches(self,value):
        """
        Return true if the supplied value is in the range of the bin.
        """
        valueint = int(value, base=2)
        if(valueint >= self.low and valueint <= self.high):
            return True
        else:
            return False

    def getHits(self):
        return self.__count__

    def addHit(self, timeRange):
        self.__count__ += 1
        self.percent_covered = 1.0
        self.hitAtTimes.add(timeRange)
    
    def addHits(self, timeRanges):
        self.__count__ += len(timeRanges)
        self.percent_covered = 1.0
        self.hitAtTimes = self.hitAtTimes.union(set(timeRanges))


class Coverpoint(object):
    """
    Describes a single coverage point.
    """

    def __init__(self, name,
                       signal,
                       width):
        """
        Create a new coverage point.
        """
        self.bins   = []
        self.name   = name
        self.signal = signal
        self.width  = width

    def toDict(self):
        """
        Return a dictonary representation of the coverpoint.
        """
        tr = {}
        tr["name"]  = self.name
        tr["width"] = self.width
        tr["signal"]= self.signal
        tr["bins"]  = [b.toDict() for b in self.bins]
        return tr

    def addBin(self, coverbin):
        """
        Add a new coverage bin to the coverpoint
        """
        self.bins.append(coverbin)
        

class Covergroup(object):
    """
    Contains a set of coverage points.
    """

    def __init__(self, name):
        """
        Create a new covergroup.
        """
        self.name   = name
        self.points = []        # The coverage points in the group.

    def toDict(self):
        """
        Return a dictionary representation of the covergroup.
        """
        tr = {}
        tr["name"] = self.name
        tr["points"] = [p.toDict() for p in self.points]
        return tr

    def addPoint(self, point):
        """
        Add a new coverpoint of the group.
        """
        self.points.append(point)

class CrosscoveragePoint(object):
    """
    Contains details on a single crosscoverage point.
    """

    def __init__(self, name, sets,bins):
        """
        Initialise the empty list of crosscoverage points.
        """
        self.name    = name
        self.binList = bins
        self.sets    = sets
        self.hits    = 0

    def toDict(self):
        """
        Return a dictionary representation fo the crosscovea points.
        """
        tr = {}
        tr["name"] = self.name
        tr["sets"] = self.sets
        tr["hits"] = self.hits
        return tr

    def evaluateCrossCoveragePoint(self):
        """
        Evaluate a single cross coverage bin list.
        """
        hitTimes = set([])
        for rng in self.binList[0].getHitTimes():
            for i in range(rng[0],rng[1]):
                hitTimes.add(i)

        for b in self.binList[1:]:
            hits = set([])
            for rng in self.binList[0].getHitTimes():
                for i in range(rng[0],rng[1]):
                    hits.add(i)
            hitTimes = hitTimes.union(hits)

        self.hits = len(hitTimes)

class Coverage(object):
    """
    Functions and structures for evaluating coverage databases over
    VCD files.
    """

    def __init__(self, coverfile=None):
        """
        Create a new coverage database.
        """

        if(coverfile != None):
            result = self.__parse_json_covergroups__(coverfile)
            self.crosscoverage  = result[0]
            self.covergroups    = result[1]

    def toDict(self):
        """
        Return a dictionary representaiton of the coverage database.
        """
        tr = {}
        tr["covergroups"]   = [g.toDict() for g in self.covergroups]
        tr["crosscoverage"] = [g.toDict() for g in self.crosscoverage]
        return tr

    def writeJSON(self, path):
        """
        Write the result of self.toDict to the supplied file path.
        """
        with open(path, "w") as fh:
            json.dump(self.toDict(),fh,indent=1)

    def getBinsFromGroups(setspec, groups):
        """
        Given a list of strings corresponding to groups, points and bins,
        return the set of bins matching that spec from the supplied set of
        coverage groups.
        """
        tr      = []
        sets    =setspec.split(".")
        for group in groups:
            if((len(sets) < 1 or group.name != sets[0]) and sets[0]!="*"):
                continue
            for point in group.points:
                if((len(sets) < 2 or point.name != sets[1]) and sets[1]!="*"):
                    continue
                for covbin in point.bins:
                    tr.append(covbin)
        return tr

    def __parse_json_covergroups__(self,path):
        """
        Load and return a list of goverage groups from the supplied json
        description.
        """
        tr = []
        crossCov = []

        with open(path,"r") as fh:
            db = json.load(fh)

            groups = db["covergroups"]

            for groupname in groups:

                db_group = groups[groupname]
                group = Covergroup(groupname)

                for pointname in db_group:
                    db_point = db_group[pointname]
                    signal = db_point["signal"]
                    width  = db_point["width"]

                    point = Coverpoint(pointname,signal, width)

                    if("bins" in db_point):
                        for covbin in db_point["bins"]:
                            if("value" in covbin):
                                val = covbin["value"]
                                cb = Coverbin(val,val, point)
                                point.addBin(cb)
                            else:
                                pass # we don't support ranges yet.
                    else:
                        for i in range(0, (2**width)-1):
                            cb = Coverbin(i, i, point)
                            point.addBin(cb)

                    group.addPoint(point)

                tr.append(group)

            crossgroups = db["crosscoverage"]

            for group in crossgroups:
                name = group["name"]
                sets = group["sets"]

                binListA = Coverage.getBinsFromGroups(sets[0], tr)
                binListB = Coverage.getBinsFromGroups(sets[1], tr)

                for i in binListA:
                    for j in binListB:
                        bins = [i,j]
                        pname = "%s and %s" % (i.parentPoint.name,
                            j.parentPoint.name)
                        crossCov.append(CrosscoveragePoint(pname,sets,bins))

        return (crossCov,tr)
    
    def evaluate_coverage_bin(signal, covbin, vcd):
        """
        Given a signal, coverage bin and vcd file, evaluate the coverage bin.
        """
        alias = vcd.getSignalAlias(signal)
        if(alias == None):
            print("coverage - error - Signal not found: %s" % signal)
            return None

        valuesByTime = vcd.getValuesByTimeForAlias(alias)
        times = sorted(list(valuesByTime.keys()))

        for i in range(0,len(times)-1):
            time  = times[i]
            value = valuesByTime[time]
            if(covbin.matches(value)):
                timesWhen = vcd.getTimesWhenSignalIs(alias, value)
                covbin.addHits(timesWhen)


    def evaluate_coverage(groups, vcd):
        """
        Evaluate the supplied coverage groups over the supplied VCD file
        """
        for group in groups:
            #print("coverage - evaluating covergroup: %s" % group.name)

            for point in group.points:
                #print("coverage - evaluating coverpoint: %s" % point.name)
                signal = point.signal

                for covbin in point.bins:
                    Coverage.evaluate_coverage_bin(signal, covbin, vcd)

    def report_coverage(self):
        """
        Uses Jinja2 to render a HTML report for the coverage.
        """
        t_path = os.path.expandvars("$RVM_HOME/verif/coverage")
        output = os.path.expandvars("$RVM_HOME/verif/coverage/report.html")

        try:
            from jinja2 import Environment, FileSystemLoader
            env = Environment(loader=FileSystemLoader(t_path))

            template = env.get_template("report-template.html")

            with open(output,"w") as fh:
                rendered = template.render(cdb = self.toDict())
                fh.write(rendered)

        except Exception as e:
            logging.error("Could not render coverage report.")
            logging.error(str(e))

def parse_arguments():
    """
    Get all of the command line arguments for the script.
    """
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--covergroups", type=str,
        help="A JSON file specifiying the coverage groups to evaluate.")
    parser.add_argument("vcd_files", nargs="+", help="The VCD files to analyse.")

    args = parser.parse_args()
    return args


def main():
    """
    Main function for the coverage script.
    """
    args = parse_arguments()
    logging.basicConfig(level=logging.INFO)
        
    logging.info("Loading coverage groups: %s " % args.covergroups)
    cdb = Coverage(coverfile = args.covergroups)

    for vcd_path in args.vcd_files:
        logging.info("Loading VCD file: %s" % vcd_path)
        vcd = pyvcd.VCDFile(vcd_path)
        Coverage.evaluate_coverage(cdb.covergroups, vcd)
    
    logging.info("Evaluating cross coverage...")
    for i in cdb.crosscoverage:
        i.evaluateCrossCoveragePoint()

    report_path = "./work/cov.json"
    logging.info("Reporting results to %s" % report_path)
    cdb.writeJSON(report_path)
    cdb.report_coverage()


if(__name__ == "__main__"):
    main()
