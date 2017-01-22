
CC=riscv32-unknown-elf-gcc
CC_FLAGS=-static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles
CC_INCLUDE=-I $(RISCV)/riscv-tests/env/p/ -I $(RISCV)/riscv-tests/isa/macros/scalar/

OBJDUMP=riscv32-unknown-elf-objdump


all: rv32ui-p-sltu.hex \
     rv32ui-p-sltu.dis \
     rv32ui-p-csrwi.hex \
     rv32ui-p-csrwi.dis \
     rv32ui-p-csrsi.hex \
     rv32ui-p-csrsi.dis \
     rv32ui-p-csrci.hex \
     rv32ui-p-csrci.dis \
     rv32ui-p-timer.hex \
     rv32ui-p-timer.dis

clean:
	rm -rf ./*.out ./*.hex ./*dis


%.hex : %.out
	elf2hex 8 16384 $< > $@
	$(RVM_HOME)/bin/hexmem-refactor.py $@ 4

%.dis : %.out
	$(OBJDUMP) -D $< > $@

%.out : %.S
	$(CC) $(CC_FLAGS) $(CC_INCLUDE) -T$(RISCV)/riscv-tests/env/p/link.ld -o $@ $<

