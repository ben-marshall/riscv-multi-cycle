
LOGFILE=$(RVM_HOME)/synth/synthesis.log
OUTFILE=$(RVM_HOME)/synth/core-synth.v
SCRIPT=$(RVM_HOME)/synth/yosys.cmd

all: netlist

netlist:
	yosys -l $(LOGFILE) -o $(OUTFILE) -s $(SCRIPT)
