---
layout: default
title: Micro-architecture | RISCV Multi Cycle
---

This page details the implementation of the core and it's 
micro-architecture.

----

# Top Level Signals

These are the signals which must be connected in order to use and implement
the core. 

Direction | Width  | Name        | Description
----------|--------|-------------|--------------------------------------------
input     |        | `clk`       | System level clock.
input     |        | `resetn`    | Asynchronous active low reset.
output    | [31:0] | `mem_addr`  | Memory address lines
input     | [31:0] | `mem_rdata` | Memory read data
output    | [31:0] | `mem_wdata` | Memory write data
output    |        | `mem_c_en`  | Memory chip enable
output    |        | `mem_w_en`  | Memory write enable
output    | [ 3:0] | `mem_b_en`  | Memory byte enable
input     |        | `mem_error` | Memory error indicator
input     |        | `mem_stall  | Memory stall indicator

# Module Hierarchy

- `rvm_core`
  - `rvm_adder`
  - `rvm_shifter`
  - `rvm_bitwise`
  - `rvm_gprs`
  - `rvm_control`
  - `rvm_fdu`
    - `rv32ui_decoder`
  - `rvm_scu`

# Major Blocks

These are the main components of the core. Each is implement in a different
file and stitched together according to the hierarchy above.

## `rvm_core`

Top level module for the whole core. Contains instances of the control logic
and functional units, as well as the PRA.

## `rvm_adder`

Performs additional and comparison operations. Single cycle.

## `rvm_shifter`

Performs arithmetic and logical shift operations using a single cycle barrel
shifter.

## `rvm_bitwise`

Performs logical bitwise operations: and, or & xor.

## `rvm_gprs`

Contains the 31 general purpose architectural registers and the zero register.
Has two read only ports and a single write port.

## `rvm_control`

This contains the main control and routing logic for the core. It implements a
finite state machine (FSM) which is generated automatically from a YAML
description of the semantics of each instruction.

The YAML file is found in `bin/fsm-spec.yaml`. It also defines the various
interfaces to the functional units.

## `rvm_fdu`

The fetch and decode unit responsible for buffering fetched instruction words.
It contains the decoder as a sub module.

## `rv32ui_decoder`

Responsible for taking a single 32 bit instruction word and decoding it into a
unique control code for the FSM and extracting it's operands.

## `rvm_scu`

Implements the privilege resource architecture for the core. Only the machine
mode is supported and only the relevant registers are implemented.

# FSM State Diagram

The diagram below is generated from the same YAML specification as the
`rvm_control` module. It shows the various control states of the core and the
transition conditions between them.

[FSM Control Diagram](../assets/fsm.svg)
