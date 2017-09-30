
VVP=vvp
VVP_FLAGS=-l work/sim.log

VCC=iverilog
VCC_TARGET=vvp
VCC_OUTPUT=$(RVM_HOME)/work/sim.bin
VCC_SCRIPT=$(RVM_HOME)/sim/icarus/manifest-iverilog.cmd
VCC_RAND_SCRIPT=$(RVM_HOME)/sim/icarus/manifest-iverilog-crt.cmd
VCC_FLAGS=-v -g2005 -t $(VCC_TARGET) -o $(VCC_OUTPUT)

COVGROUPS=$(RVM_HOME)/verif/coverage/coverpoints.json

ISA_TESTS=$(RVM_HOME)/verif/riscv-tests/build/hex
TEST=rv32ui-p-sh
TEST_HEX=$(ISA_TESTS)/$(TEST).hex
HALT_ADDR=0x80000608
PASS_ADDR=0x80000590
FAIL_ADDR=0x80000580
TIMEOUT=10000

TEST_LEN=3900 # How log a CRT test shouldbe.

WAVE_FILE=waves.vcd

.PHONY: docs

all: build

# Force a re-build of the RTL source simulation.
build: control-fsm
	$(MAKE) -B $(VCC_OUTPUT)

verilate: control-fsm
	$(MAKE) -C $(RVM_HOME)/sim/verilator all

$(VCC_OUTPUT) : $(VCC_SCRIPT)
	$(VCC) $(VCC_FLAGS) -c $(VCC_SCRIPT)

run-test: $(VCC_OUTPUT)
	echo "Running simulator hex file: $(TEST_HEX)"
	$(VVP) $(VVP_FLAGS) $(VCC_OUTPUT) +IMEM=$(TEST_HEX) \
        +HALT_ADDR=$(HALT_ADDR) +MAX_CYCLE_COUNT=$(TIMEOUT) \
        +PASS_ADDR=$(PASS_ADDR) +FAIL_ADDR=$(FAIL_ADDR)

control-fsm:
	./bin/fsmgen.py -o ./work/fsm.v \
                    -d ./work/fsm.dot \
                       ./bin/fsm-spec.yaml

control-fsm-diagram: control-fsm
	dot -Tsvg -O ./work/fsm.dot

view-waves:
	gtkwave -l $(RVM_HOME)/work/sim.log \
	        -O $(RVM_HOME)/work/gtkwave.log \
            $(RVM_HOME)/work/$(WAVE_FILE) \
            $(RVM_HOME)/sim/waves.gtkw &

regress-isa: build
	python2.7 $(RVM_HOME)/bin/regression.py $(RVM_HOME)/sim/regression-list-isa-tests.txt


coverage:
	python3 $(RVM_HOME)/bin/coverage.py --covergroups $(COVGROUPS) ./work/*.vcd
	
clean:
	rm -rf $(RVM_HOME)/work/*
	$(MAKE) -C $(RVM_HOME)/sim/verilator clean
