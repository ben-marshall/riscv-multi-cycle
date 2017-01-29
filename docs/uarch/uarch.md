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

Main logic blocks:

- Control FSM
- PC
- ALU
 - Adder
 - Shifter
- Memory interface
- Instruction decode
- General Purpose Registers
- Priviliged resource architecture (PRA) registers.

# Execution Loop

- Instruction Fetch
- Instruction Decode
 - Execute
 - Memory Access
- Writeback
