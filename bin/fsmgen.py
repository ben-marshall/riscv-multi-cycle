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
        self.range     = (range[0],range[1])
        self.readable  = readable
        self.writable  = writable

        self.values    = []
        self.state_conditions = set([])

    def __len__(self):
        return 1+(self.range[0]-self.range[1])

    def value_in(self, state):
        """
        Return the value this signal should take in a given state or None
        if no value is prescribed.
        """
        for v in values:
            if(v.value_in(state) != None):
                return v.value
        return None

    def add_state_assignment(self, assignment):
        """
        Adds a new assignment to this signal such that when the FSM is in
        the given state, it will take a certain value.
        """
        assert(type(assignment) == AssignOnState)
        
        if(not assignment.state in self.state_conditions):
            self.values.append(assignment)
            self.state_conditions.add(assignment.state)
        else:
            print("[ERROR] The state %s already prescribes a value for the signal %s." % (assignment.state.name(),self.name))

    def verilog_name(self):
        """
        Return a verilog safe version of the interface signal name.
        """
        return self.name.replace(".","_").replace("-","_");

    def get_range(self):
        """
        Returns the signal range in the form "x:y"
        """
        return "%d:%d" % self.range
    
    def direction(self):
        """
        Depending on the combination of readable/writable, returns
        "input" or "output" or "inout"
        Returns None if neither are set.
        """
        if(self.readable and self.writable):
            return "inout"
        elif(self.readable and not self.writable):
            return "input"
        elif(not self.readable and self.writable):
            return "output"
        else:
            return None

class AssignOnCondition(object):
    """
    A class for representing the value a particular signal should take
    when an arbitrary condition is met.
    """

    def __init__(self, condition, value):
        """
        Given a condition, take this value.
        """
        self.condition = condition
        self.value = value


class AssignOnState(object):
    """
    A class for representing the value a particular signal should take
    when the FSM is in a particular state.
    """

    def __init__(self, state, value):
        """
        Given a state, take this value.
        """
        self.state = state
        self.value = value

    def value_in(self,state):
        """
        Returns None if the state argument doesn't match the class's
        own state or value if it does.
        """
        if(state.name() == self.state.name()):
            return self.value
        else:
            return None


class State(object):
    """
    Describes a single state in the FSM
    """

    __uid__ = 0
    __ids__ = set([])

    def __init__(self, name = None, enc = None):
        """
        Creates a blank interface.
        """
        self.state_name = name
        self.uid = State.__uid__ + 1
        while(self.uid in State.__ids__):
            self.uid += 1
            State.__uid__ = self.uid + 1
        State.__ids__.add(self.uid)

        self.next_state = None
        self.wait = None
        self.enc = enc

    def get_encoding(self):
        if(self.enc==None):
            return self.uid
        else:
            return self.enc

    def verilog_name(self):
        """
        Return a verilog safe version of the interface signal name.
        """
        n = self.name()
        return ("%s" % n.replace(".","_").replace("-","_"));
    
    def name(self):
        """
        Return a verilog friendly name for the state.
        """
        return self.state_name

    def next_state_expression(self):
        """
        Return verilog code representing the next state expression for
        the FSM, given it is in this state.
        """
        if(type(self.next_state) == State):
            return self.next_state.verilog_name()
        else:
            return "0"


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

        self.state_var_name     = "ctrl_state"
        self.state_var_width    = 6
        self.default_next_state = "0"

    def add_state(self, state):
        """
        Add a new state to the FSM
        """
        self.states[state.name()] = state

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
                                 interfaces=self.interfaces,
                                 state_var = self.state_var_name,
                                 state_var_w = self.state_var_width,
                                 default_next_state = self.default_next_state)
        
        with open(output_path, "w") as fh:
            fh.write(result)
    
    def to_dot(self, output_path):
        """
        Renders the FSM as a graphviz dot file.
        """
        ld  = jinja2.FileSystemLoader(os.path.expandvars("$RVM_HOME/bin"))
        env = jinja2.Environment(loader = ld)

        template = env.get_template("fsm-graph.dot")
        
        result = template.render(states = self.states, 
                                 interfaces=self.interfaces,
                                 state_var = self.state_var_name,
                                 state_var_w = self.state_var_width,
                                 default_next_state = self.default_next_state)
        
        with open(output_path, "w") as fh:
            fh.write(result)
    

    def __check_states__(self):
        """
        Performs a simple coherencey check on the various state and next
        state encodings.
        """
        for stateName in self.states:
            state = self.states[stateName]

            if(type(state.next_state) == str):
                if(not state.next_state in self.states):
                    print("[ERROR] next state '%s' of state '%s' doesn't exist." % (state.name(), state.next_state))
                else:
                    state.next_state = self.states[state.next_state]


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
                enc = None
                if("encoding" in state):
                    enc = state["encoding"]
                ta = State(name=state["name"], enc=enc)
                
                if("wait" in state):
                    ta.wait = state["wait"]

                if(type(state["next"]) == str):
                    ta.next_state = state["next"]
                    ta.single_next_state = True
                else:
                    ta.single_next_state = False
                    ta.next_state = []
                    for n in state["next"]:
                        cond = AssignOnCondition(n["if"],n["then"])
                        ta.next_state.append(cond)


                if("set" in state):
                    for interface in state["set"]:
                        for i_name in interface:
                            for signal in interface[i_name]:
                                for s_name in signal:
                                    v = signal[s_name]
                                    t = AssignOnState(ta,v)
                                    i = tr.interfaces[i_name]
                                    i.signals[s_name].add_state_assignment(t)


                tr.add_state(ta)
        
        tr.__check_states__()
        return tr


def parseargs():
    """
    Parses and returns all command line arguments to the program.
    """
    
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("-o","--output", type=str,
        help="Output verilog path.",
        default="./fsm.v")
    parser.add_argument("-d","--diagram", type=str,
        help="Path to output a graphviz .dot file.",
        default=None)
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

    if(args.diagram != None):
        fsm.to_dot(args.diagram)
    
    sys.exit(0)


if(__name__=="__main__"):
    main()

