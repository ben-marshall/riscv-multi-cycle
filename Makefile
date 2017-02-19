
VVP=vvp
VVP_FLAGS=-l work/sim.log

VCC=iverilog
VCC_TARGET=vvp
VCC_OUTPUT=$(RVM_HOME)/work/sim.bin
VCC_SCRIPT=$(RVM_HOME)/sim/manifest-iverilog.cmd
VCC_RAND_SCRIPT=$(RVM_HOME)/sim/manifest-iverilog-crt.cmd
VCC_FLAGS=-v -g2005 -t $(VCC_TARGET) -o $(VCC_OUTPUT)

COVGROUPS=$(RVM_HOME)/verif/coverage/coverpoints.json

TEST_HEX=$(RVM_HOME)/verif/riscv-tests/hex/rv32ui-p-sh.hex
HALT_ADDR=0x8000074c
PASS_ADDR=0x80000548
FAIL_ADDR=0x80000534
TIMEOUT=10000

TEST_LEN=3900 # How log a CRT test shouldbe.

WAVE_FILE=waves.vcd

.PHONY: docs

all: build docs

docs:
	$(MAKE) -C $(RVM_HOME)/docs all

# Force a re-build of the RTL source simulation.
build: control-fsm
	$(MAKE) -B $(VCC_OUTPUT)

$(VCC_OUTPUT) : $(VCC_SCRIPT)
	$(VCC) $(VCC_FLAGS) -c $(VCC_SCRIPT)

run-test: $(VCC_OUTPUT)
	echo "Running simulator hex file: $(TEST_HEX)"
	$(VVP) $(VVP_FLAGS) $(VCC_OUTPUT) +IMEM=$(TEST_HEX) \
        +HALT_ADDR=$(HALT_ADDR) +MAX_CYCLE_COUNT=$(TIMEOUT) \
        +PASS_ADDR=$(PASS_ADDR) +FAIL_ADDR=$(FAIL_ADDR)

control-fsm:
	./bin/fsmgen.py -o ./work/fsm.v ./bin/fsm-spec.yaml

view-waves:
	gtkwave -l $(RVM_HOME)/work/sim.log \
	        -O $(RVM_HOME)/work/gtkwave.log \
            $(RVM_HOME)/work/$(WAVE_FILE) \
            $(RVM_HOME)/sim/waves.gtkw &

directed-tests:
	$(MAKE) -C $(RVM_HOME)/verif/directed-tests all

build-random-tests:
	$(MAKE) -B $(VCC_OUTPUT) VCC_SCRIPT=$(VCC_RAND_SCRIPT)
	$(MAKE) -B -C $(RVM_HOME)/verif/random-tests VEC_LEN=$(TEST_LEN) all

regress-random: TEST_HEX=./verif/random-tests/crt.hex
regress-random: build-random-tests
	$(VVP) $(VVP_FLAGS) $(VCC_OUTPUT) +IMEM=$(TEST_HEX) +DMEM=$(TEST_HEX) \
        +HALT_ADDR=$(HALT_ADDR) +MAX_CYCLE_COUNT=$(TEST_LEN) 
	$(MAKE) -C $(RVM_HOME)/verif/random-tests VEC_LEN=$(TEST_LEN) simulate 
	./bin/crt-check.py --rtl-log ./work/sim.log --sim-log ./verif/random-tests/spike-err.log
	mv ./work/waves.vcd ./work/crt.vcd
	

regress-isa: build
	python2.7 $(RVM_HOME)/bin/regression.py $(RVM_HOME)/sim/regression-list-isa-tests.txt

regress-directed: directed-tests build
	python2.7 $(RVM_HOME)/bin/regression.py $(RVM_HOME)/sim/regression-list-directed-tests.txt


coverage: regress-isa regress-directed regress-random
	python3 $(RVM_HOME)/bin/coverage.py --covergroups $(COVGROUPS) ./work/*.vcd
	
clean:
	rm -rf $(RVM_HOME)/work/*
	$(MAKE) -C $(RVM_HOME)/verif/directed-tests clean
	$(MAKE) -C $(RVM_HOME)/verif/random-tests clean
