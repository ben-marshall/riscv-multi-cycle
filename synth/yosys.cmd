
#
# Load the design

read_verilog -I ../rtl/main ../rtl/main/rv32ui_decoder.v
read_verilog -I ../rtl/main ../rtl/main/rvm_adder.v
read_verilog -I ../rtl/main ../rtl/main/rvm_bitwise.v
read_verilog -I ../rtl/main ../rtl/main/rvm_constants.v
read_verilog -I ../rtl/main ../rtl/main/rvm_core.v
read_verilog -I ../rtl/main ../rtl/main/rvm_fdu.v
read_verilog -I ../rtl/main ../rtl/main/rvm_gprs.v
read_verilog -I ../rtl/main ../rtl/main/rvm_pcu.v
read_verilog -I ../rtl/main ../rtl/main/rvm_scu.v
read_verilog -I ../rtl/main ../rtl/main/rvm_shift.v
read_verilog -I ../rtl/main ../work/fsm.v

#
# Elaborate the design hierarchy using rvs_core as the top module.
hierarchy -check -top rvm_core

#
# Make sure there are no problems
check -assert

#
# Convert processes to netlists
proc

#
# Flatten the design into a single module.
flatten

#
# Optimisation pass
opt

#
# Map to gats
techmap

#
# Final optmisation pass
opt

#
# Write the design out to file.
write_verilog core-synth.v

#
# Print some statistics
stat
