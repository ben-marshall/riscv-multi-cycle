
#
# Load the design

read_verilog -I ../rtl/ ../rtl/main/rv32ui_decoder.v
read_verilog -I ../rtl/ ../rtl/main/rvs_fdu.v
read_verilog -I ../rtl/ ../rtl/main/rvs_gprs.v
read_verilog -I ../rtl/ ../rtl/main/rvs_alu.v
read_verilog -I ../rtl/ ../rtl/main/rvs_lsu.v
read_verilog -I ../rtl/ ../rtl/main/rvs_pcu.v
read_verilog -I ../rtl/ ../rtl/main/rvs_scu.v
read_verilog -I ../rtl/ ../rtl/main/rvs_core.v

#
# Elaborate the design hierarchy using rvs_core as the top module.
hierarchy -check -top rvs_core

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
