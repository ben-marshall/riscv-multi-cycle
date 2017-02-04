---
layout: default
title: Micro-architecture | RISCV Multi Cycle
---

This page details the implementation of the core and it's 
micro-architecture.

----

# Micro-architecture overview

- The core will be a multi-cycle implementation optimised for area.
- All logic blocks will be implemented so as to maximise resource sharing.

The main interfaces and data paths within the core have three main identifying
prefixes:
- `F_` - Functional block
- `S_` - Data Source
- `D_` - Data Destination
These make it easy to look at a signal and identify what it's purpose is.

The mappings of instructions onto sequences of datapath mappins are
described on the [Instruction Actions](execution-listing.html) page.

## Functional Blocks

These are blocks which implement atomic functions which are comined to create
the required data path for a particular instruction.

- `F_ADD` - Adder/Subtracter
- `F_SHF` - Logical/Arithmetic Shifter
- `F_BIT` - Bitwise (and/or/xor)

## Data Sources

These are places which the functional blocks will need to source their
operands from.

- `S_GPRA` GPR Port A
- `S_GPRB` GPR Port B
- `S_IMM` Instruction Immediate
- `S_CONST` Hard coded constant
- `S_PC` Program Counter
- `S_CSR` CSR Register
- `S_MEMR` Memory Read Data

## Data Destinations

These are places where the results of functional blocks will need to be
written to.

- `D_PC` - Program Counter
- `D_GPRC` - GPR Port C
- `D_CSR` - CSR Register
- `D_MEMW` - Memory write data
- `D_MEMA` - Memory write address
