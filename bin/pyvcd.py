#!/usr/bin/python3

import os
import sys
import bitstring

class VCDScope(object):
    """
    Describes the scope of a signal in a VCD file.
    """

    def __init__(self, name, parentScope = None):
        """
        Instance a new scope with an optional parent.
        """
        self.name       = name
        self.parent     = parentScope
        self.children   = []    # Contains child scope objects.
        self.vars       = []    # Contains names of variables in this scope.

        self.__str__ = self.fullName

    def fullName(self):
        """
        Returns the full name of the scope.
        """
        tr = [self.name]
        s = self.parent
        while(s != None):
            tr.insert(0,s.name)
            s = s.parent
        return "/".join(tr)

    def allSignals(self):
        """
        Return the full names of all signals in the scope as a list.
        """
        return [self.fullName() + "/" + s for s in self.vars]

    def addChild(self, scope):
        """
        Add a child scope to this scope.
        """
        self.children.append(scope)

    def addSignal(self, name, alias, width):
        """
        Add a new signal to the scope.
        """
        self.vars.append(name)


class VCDValues(object):
    """
    Key value storage for relating the sets of signals, aliases and
    values.
    """

    def __init__(self):
        """
        Instance a new VCDValues class.
        """
        self.__time__       = 0
        self.times          = []

        self.by_alias       = {}
        self.by_time        = {}
        self.alias_widths   = {}

    def addAlias(self, alias,width):
        """
        Add a new alias to the values database
        """
        self.by_alias[alias]    = {}
        self.alias_widths[alias]= width

    def addTime(self, time):
        """
        Add a new time value to the values database.
        """
        self.by_time[time] = {}
        if(not time in self.times):
            self.times.append(time)
    
    def addValue(self, time, alias, value):
        """
        Add a new value for a signal at a given time and scope.
        """
        v = value
        if(value.startswith("b")):
            v = value[1:]
        while(len(v) < self.alias_widths[alias]):
            v = "0"+v
        self.by_time [time][alias] = v
        self.by_alias[alias][time] = v

class VCDFile(object):
    """
    A simple python class for reading Value Change Dump (VCD) Files.
    """

    def __init__(self, vcd_file_path):
        """
        Open a new VCD file for analysis.
        """
        self.file_path = vcd_file_path
        self.values    = VCDValues()
        self.top       = None
        self.names_to_aliases = {}
        self.__parse__()

    def getSignalAlias(self, signalName):
        """
        Given a fully qualified signal name, return it's alias or None
        if the signal does not exist in the VCD.
        """
        if(signalName in self.names_to_aliases):
            return self.names_to_aliases[signalName]
        else:
            return None

    def getTimesWhenSignalIs(self, alias, value):
        """
        Return a list of time ranges (expressed as tuples) which
        define when the given alias has a particular value.
        """
        tr = []
        vt = self.getValuesByTimeForAlias(alias)
        prev_time = 0
        prev_val  = None

        times = sorted(vt.keys())
        
        for i in range(0, len(times)-1):
            time = times[i]
            if(vt[time] == value):
                tr.append((time, times[i+1]))

        return tr

    def getValuesByTimeForAlias(self,alias):
        """
        For a given signal alias, return a dictionary of its values
        keyed by times.
        """
        return self.values.by_alias[alias]
        
    def getValuesForAlias(self,alias):
        """
        For a given signal alias, return a dictionary of its values only
        without timestamps.
        """
        return self.values.by_alias[alias].values()

    def __parse__(self):
        """
        Parse the VCD file path in self.file_path
        """

        with open(self.file_path,"r") as fh:
            
            current_scope   = None
            current_time    = 0
            parse_vars      = False
            
            self.values.addTime(current_time)

            for line in fh.readlines():
                l = line.rstrip(" \n").strip(" ")
                
                if(parse_vars):
                    if(l.startswith("#")):
                        current_time = int(l[1:])
                        self.values.addTime(current_time)
                    elif(l != "$end"):
                        alias = l[1:]
                        value = l[0]
                        s = l.split(" ")
                        if(len(s) == 2):
                            alias = s[1]
                            value = s[0]
                        self.values.addValue(current_time, 
                                             alias,
                                             value)

                elif(l.startswith("$scope ")):
                    sname = l.split(" ")[2]
                    new_scope = VCDScope(sname,parentScope = current_scope)
                    if(current_scope != None):
                        current_scope.addChild(new_scope)
                    else:
                        self.top = new_scope
                    current_scope = new_scope

                elif(l.startswith("$var")):
                    s = l.split(" ")
                    self.values.addAlias(s[3], int(s[2]))
                    current_scope.addSignal(s[4],s[3],int(s[2]))
                    fullname = current_scope.fullName()+"/"+s[4]
                    self.names_to_aliases[fullname] = s[3]

                elif(l.startswith("$upscope")):
                    current_scope = current_scope.parent

                elif(l.startswith("$dumpvars")):
                    parse_vars = True

                else:
                    pass

def main():
    vcd = VCDFile(sys.argv[1])
    print(vcd)

if(__name__=="__main__"):
    main()

