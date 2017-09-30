
VERILATE=$(RVM_VERILATOR_BIN)
VL_TOP=rvm_core_axi4

VERILOG_RTL_CTR=$(RVM_HOME)/work/fsm.v
VERILOG_RTL_SRC=$(VERILOG_RTL_CTR) $(shell find $(RVM_HOME)/rtl/main -name '*.v')
VERILOG_TST_SRC=$(shell find $(RVM_HOME)/rtl/test -name '*.v')
VERILOG_INCLUDE=$(RVM_HOME)/rtl/main

OBJ_DIR=$(RVM_HOME)/work/obj_dir

C_SRC=$(RVM_HOME)/sim/verilator/verilator_main.cpp \
      $(RVM_HOME)/sim/verilator/verilator_sim.cpp \
      $(RVM_HOME)/sim/verilator/axi_memory.cpp

SIM=$(OBJ_DIR)/V$(VL_TOP)

VERILATE_FLAGS= -Wno-fatal \
                --exe $(C_SRC) \
                --top-module $(VL_TOP) \
                --Mdir $(OBJ_DIR) \
                --trace


all: $(SIM)

$(SIM) : $(VERILOG_RTL_SRC) $(VERILOG_TST_SRC)
	$(VERILATE) $(VERILATE_FLAGS) \
        --cc $(VERILOG_RTL_SRC) \
        -I$(VERILOG_INCLUDE)
	$(MAKE) -j -C $(OBJ_DIR) -f V$(VL_TOP).mk V$(VL_TOP) \
	    VERILATOR_ROOT=$(RVM_VERILATOR_ROOT)

clean:
	rm -rf $(OBJ_DIR)
