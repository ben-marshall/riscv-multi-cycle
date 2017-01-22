
CC=riscv32-unknown-elf-gcc
CC_FLAGS=-static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles
CC_INCLUDE=-I $(RISCV)/riscv-tests/env/p/ -I $(RISCV)/riscv-tests/isa/macros/scalar/

OBJDUMP=riscv32-unknown-elf-objdump

SRC=crt.S
EXE=crt.out
HEX=crt.hex
DIS=crt.dis

INSTR_DB=$(RVM_HOME)/verif/specs/instructions.json

SIM_WRAPPER=$(RVM_HOME)/bin/automator.py
SIM_CMD="$(RISCV)/riscv-isa-sim/build/spike -d --isa RV32I $(RVM_HOME)/verif/random-tests/$(EXE)"

VEC_LEN=10

all: $(EXE) $(HEX) $(DIS)

clean:
	rm -rf ./*.out ./*.hex ./*dis ./*.S ./*.in ./*.log

$(SRC) : 
	$(RVM_HOME)/bin/tvgen.py -n $(VEC_LEN) -o $@ --json $(INSTR_DB)

%.hex : %.out
	elf2hex 8 16384 $< > $@
	$(RVM_HOME)/bin/hexmem-refactor.py $@ 4

%.dis : %.out
	$(OBJDUMP) -D $< > $@

%.out : %.S
	$(CC) $(CC_FLAGS) $(CC_INCLUDE) -T$(RISCV)/riscv-tests/env/p/link.ld -o $@ $<

simulate: $(EXE)
	echo "run $(VEC_LEN)" > spike.in
	echo "reg 0" >> spike.in
	echo "q" >> spike.in
	$(SIM_WRAPPER) --cmd $(SIM_CMD) \
                   --stdin spike.in \
                   --stdout spike-out.log \
                   --stderr spike-err.log \
                   --timeout 5
