
VERILATE=/opt/verilator/verilator-3.912/verilator_bin

VERILOG_RTL_CTR=$(RVM_HOME)/work/fsm.v
VERILOG_RTL_SRC=$(VERILOG_RTL_CTR) $(shell find $(RVM_HOME)/rtl/main -name '*.v')
VERILOG_TST_SRC=$(shell find $(RVM_HOME)/rtl/test -name '*.v')
VERILOG_INCLUDE=$(RVM_HOME)/rtl/main

SIM=$(RVM_HOME)/work/vl_sim.bin

all: $(SIM)


$(SIM) : $(VERILOG_RTL_SRC) $(VERILOG_TST_SRC)
	$(VERILATE) -Wall --cc $(VERILOG_RTL_SRC) -I$(VERILOG_INCLUDE)
