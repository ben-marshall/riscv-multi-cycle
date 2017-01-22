
# Synthesis

This directory contains the very simple synthesis infrastructure for the core.

The flow uses [YOSYS](http://www.clifford.at/yosys/) to perform RTL to
gate level netlist translation. The command script to direct YOSYS is in
this folder called yosys.cmd.

The general steps followed by the script are:

- Reading in the design
- Elaborating the design hierarchy. This also sets `rvs_core` to the top level
  module.
- Checking for basic problems like logic loops.
- Converting process blocks into netlists.
- Flattening the design into a single module.
- Optimising the flattened design.
- Mapping the design to gates.
- Performing a final optimisation pass.
- Writing the design to verilog.
