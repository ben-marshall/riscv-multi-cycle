---
layout: default
title: Architecture | RISCV Multi Cycle
---

This page details all ISA specific information which the core implements.

----

# ISA Documentation

This documentation is supplied by the [RISC-V Foundation](https://riscv.org/).
The most recent coppies can be found [here](https://riscv.org/specifications/).

- RISCV ISA Specification [PDF](../arch/riscv-spec-v2.2.pdf)]
- RISCV Privileged Resource Architecture [PDF](../arch/riscv-privileged-v1.10.pdf)

A concise description of all RV32UI instructions can be found 
[here](actions.html). Quirks in the current version of the RISCV toolchain
can also make it difficult to work out exactly which register an instruction
is addressing when viewing dissassembly. A mapping table to make debugging
easier is listed [here](registers.html).

# Implementation Notes

This is an implementation of the RISCV RV32UI architecture. It implements
only the minimum required amount of logic in the privilidged resource
architecture in order to run programs.

## Fence Instructions

The `fence` and `fencei` instruction are implemented as NOP instructions. This
is because there are no caches supported.

## Memory Alignment

The core uses byte addressed memory. Interfaces to memory are word addressed,
where one word is four bytes.

`LOAD` and `STORE` instructions can access words, half-words and bytes.

Support for accessing words and half-words which span a word boundary is not
present. Access to halfwords which are misaligned within a word, but which do
not straddle a word boundary are supported.

