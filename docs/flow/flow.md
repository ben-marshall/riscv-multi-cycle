---
layout: default
title: Flow | RISCV Single Cycle
---

Describes the build, simulation and synthesis tool flows.

----

# Tools Used

It is assumed that you have a unix-like enironment with the following tools
installed already. The workspace scripts assume a bourne-shell (`sh`/`bash`)
compatible environment.

- Icarus Verilog Simulator
- Yosys Open Sythesis Tool
- Python2.7
- Python3.5
- GTKWave

Further, the `bitstring` python package is also used.

# Workspace Setup

First, set the `RISCV` environment variable to the root of your riscv-tools
installation.

To prepare the workspace for building and simulating the core, move to the
top of the project directory tree and run:

```sh
$> source ./bin/source.me.sh
```

This will setup the `RVM_HOME` environment variable, which is used by the
various makefiles and build scripts. It will also copy the compiled 
`riscv-isa-test` suite into `./verif/isa-tests` folder.

# RTL

This section deals with how to build a simulation from the RTL source files.
These files are found in `rtl/main/` for the "core" synthesisable files, and
`rtl/test/` for the testbench infrastructure and peripheral models.

## RTL Build

Icarus verilog is used to build a simulation executable. Run the following
command to build the default self-checking test environment:

```sh
$> make build
```

This uses the `sim/manifest-iverilog.cmd` script to load the appropriate
testbench and RTL files.
This will put a `sim.bin` file in the `work/` directory.

## RTL Simulation

Running the simulation is done with the `vvp` tool, which is part of the
Icarus toolset.

```sh
$> make run-test
```

Will run the default isa test (`addi`) and dump the results into `work/sim.log`
and write a VCD wave database of the simulation to `work/waves.vcd`

There are several arguments (plusargs, in verilog terminology) which can be
passed to the simulation to configure the pass/fail conditions and which test
file to run.

- `TEST_HEX` - The `.hex` file which is loaded into the simulator memories
  at the start of the test. These contain the programs to run.
- `TIMEOUT` - An integer which will cause the simuation to fail out after this
   many cycles of activity.
- `HALT_ADDR` - Stop the simulation if we hit this address. Used to catch
   runaway program counters.
- `PASS_ADDR` - Stop the simulation when the PC hits this address and report 
    pass.
- `FAIL_ADDR` - Stop the simulation when the PC hits this address and report 
    fail.

For example:

```sh
$> make TEST_HEX=./my-custom-test.hex HALT_ADDR=0x00000500 run-test
```

Will run a specified hex file and stop when the PC hits address `0x00000500`.

After simulation, run `make view-waves` to load the `work/waves.vcd` file
into GTKWave for analysis. There is a script file in `sim/wave-view.gtkw` which
will load common sets of signals into the window view to make debugging easier.

## RTL Synthesis

Synthesis is the process of translating RTL code into a netlist of actual
gates which can be implemented in a circuit.

Yosys is used as the synthesis tool to build gate-level models of the
core. All synthesis related work is performed in the `./synth/` directory.
The following commands will create a synthesised netlist version of the core:

```sh
$> cd $RVM_HOME/synth
$> make netlist
```

This will produce a logfile, and the `core-synth.v` file. This is the
synthesised netlist. No particular technology library is used, but yosys
will support this if you have one available.

The command script yosys uses to build the core is `./synth/yosys.cmd`. An
explanation of the steps it takes can be found in `./synth/README.md`.

# Verification

This core is *not* verified. I make no claims as to its fitness for purpose.

That said, I have tried to build enough confidence in the implementation
such that it is something I can build on in other projects. This takes a
three step approach:

- Self checking directed tests. These are part of the `riscv-tests`
repository and contain lots of self-checking tests for each instruction.
Any RISCV implementation must be able to run these tests.
- Random testing. I have built a small random-testing flow. It is not
complete yet, but it allows random sequences of arithmetic instructions to
be run and the final processor state to be checked against the SPIKE ISA
simulator.
- Functional Coverage. Again, I have built a simple tool to allow specification
of coverage points and crosscoverage and data extraction from VCD files.

## ISA Tests

`$> make regress`

## Random Testing

`$> make run-random-tests`

## Functional Coverage

`$> make coverage`




