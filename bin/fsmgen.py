#!/usr/bin/python3

"""
Responsible for reading in a description of the core control FSM and
generating synthesisable Verilog code which implements it.
"""

import os
import sys
import yaml
import argparse

import jinja2

class Interface(object):
    """
    Describes a single interface which the FSM controls. An
    interface comprises a group of signals.
    """

    def __init__(self, name=None,description=None):
        """
        Creates a blank interface.
        """
        self.name           = name
        self.description    = description
        self.signals        = {}
    
    def add_signal(self, signal):
        """
        Add a new signal to the interface.
        """
        self.signals[signal.name] = signal


class InterfaceSignal(object):
    """
    Describes a single signal within an interface.
    """

    def __init__(self, interface, name=None, range=[0,0], readable=True,
        writable=False):
        """
        Creates a blank signal attatched to the supplied interface.
        """
        self.interface = interface
        self.name      = name
        self.range     = (range[1],range[0])
        self.readable  = True
        self.writable  = False

class State(object):
    """
    Describes a single state in the FSM
    """

    __uid__ = 0

    def __init__(self, name = None):
        """
        Creates a blank interface.
        """
        self.name = name
        self.uid = self.__uid__
        self.__uid__ += 1

        self.next = None
        self.wait = None


class FSM(object):
    """
    Describes a single FSM in terms of its states, transitions, inputs
    and outputs.
    """

    def __init__(self):
        """
        Create a new empty FSM.
        """
        self.states         = {}
        self.interfaces     = {}
        self.initial_state  = None

    def add_state(self, state):
        """
        Add a new state to the FSM
        """
        self.states[state.name] = state

    def add_interface(self, interface):
        """
        Add a new IO interface to the FSM
        """
        self.interfaces[interface.name] = interface

    def to_verilog(self, output_path):
        """
        Renders the FSM as verilog into the supplied output path.
        """
        ld  = jinja2.FileSystemLoader(os.path.expandvars("$RVM_HOME/bin"))
        env = jinja2.Environment(loader = ld)

        template = env.get_template("fsm-template.v")
        
        result = template.render(states = self.states, 
                                 interfaces=self.interfaces)
        
        with open(output_path, "w") as fh:
            fh.write(result)

    def fromYAML(filepath):
        """
        Load an FSM description from a YAML file.
        """
        tr = FSM()
        
        # Load the YAML description for parsing.
        with open(filepath,"r") as fh:
            desc = yaml.load(fh)

            interfaces = desc["interfaces"]
            states     = desc["states"]

            for interface in interfaces:
                ta = Interface(name=interface["name"])

                if(not "signals" in interface):
                    print("Warning: Interface '%s' has no signals defined."%ta.name)
                    continue
                
                for signal in interface["signals"]:
                    s = InterfaceSignal(ta,
                        name = signal["name"],
                        range= signal["range"] if "range" in signal else [0,0],
                        readable = "r" in signal["access"],
                        writable = "w" in signal["access"])
                    ta.add_signal(s)

                tr.add_interface(ta)

            for state in states:
                ta = State(name=state["name"])
                
                ta.wait = state["wait"]
                ta.next = state["next"]

                tr.add_state(ta)
    
        return tr


def parseargs():
    """
    Parses and returns all command line arguments to the program.
    """
    
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("-o","--output", type=str,
        help="Output verilog path.",
        default="./fsm.v")
    parser.add_argument("fsm", type=str,
        help="The YAML file which describes the FSM interfaces and states",
        default="./fsm-spec.yaml")

    args = parser.parse_args()
    return args

def main():
    """
    Main entry point for using the script
    """
    args = parseargs()

    fsm = FSM.fromYAML(args.fsm)
    fsm.to_verilog(args.output)
    
    sys.exit(0)


if(__name__=="__main__"):
    main()

