
# RTL

Contains all of the RTL source code for the core and the testbench.

---

## main/

Contains the actual core as synthesisable RTL.

## axi4master/

A bridge for connecting the *very* basic SRAM interface of the core to an
AXI4 Bus master.

## test/

Contains non-synthesisable testbench environment stuff.

## sys/

Contains the system control module. This is responsible for managing the
loading of a memory image via UART, dumping memory contents via UART, and
starting / stopping the core.
