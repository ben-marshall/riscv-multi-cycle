
VERILATE=/opt/verilator/verilator-3.912/verilator_bin


VERILOG_RTL_CTR=$(RVM_HOME)/work/fsm.v
VERILOG_RTL_SRC=$(VERILOG_RTL_CTR) $(shell find $(RVM_HOME)/rtl/main -name '*.v')
VERILOG_TST_SRC=$(shell find $(RVM_HOME)/rtl/test -name '*.v')
VERILOG_INCLUDE=$(RVM_HOME)/rtl/main

C_SRC=$(RVM_HOME)/sim/verilator/verilator_main.cpp

SIM=$(RVM_HOME)/work/vl_sim.bin

VERILATE_FLAGS= -Wno-fatal \
                --exe $(C_SRC) \
                --top-module rvm_core_axi4


all: $(SIM)

$(SIM) : $(VERILOG_RTL_SRC) $(VERILOG_TST_SRC)
	$(VERILATE) $(VERILATE_FLAGS) \
        --cc $(VERILOG_RTL_SRC) \
        -I$(VERILOG_INCLUDE)
	$(MAKE) -j -C obj_dir -f Vrvm_core_axi4.mk Vrvm_core_axi4 \
	    VERILATOR_ROOT=$(RVM_VERILATOR_ROOT)

clean:
	rm -rf obj_dir
