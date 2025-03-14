#
# Typical usage: vivado -mode batch -source partial_impl.tcl
#

# Store current directory
set current_directory [pwd]
set build_directory [pwd]/build/partial
set proj_directory ${build_directory}/temp_project

# Source project configurations
source ${current_directory}/project_config.tcl

# Generate static region checkpoint with black box
open_checkpoint ${build_directory}/../full/${proj_name}_wrapper_routed.dcp
update_design -cell ${partition_cell} -black_box
lock_design -level routing
write_checkpoint -force ${build_directory}/${proj_name}_black_box_routed.dcp

# Swap black box for DFX partition
open_checkpoint ${build_directory}/${proj_name}_black_box_routed.dcp
read_checkpoint -cell ${partition_cell} ${build_directory}/${partition_inst}_synth.dcp

# Build design
opt_design
place_design
route_design

# Write config checkpoint and verify
write_checkpoint -force ${build_directory}/config_${partition_inst}_routed.dcp
pr_verify ${build_directory}/../full/${proj_name}_wrapper_routed.dcp \
    ${build_directory}/config_${partition_inst}_routed.dcp

# Remove CFG MEM settings
reset_property BITSTREAM.GENERAL.COMPRESS [current_design]
reset_property BITSTREAM.CONFIG.CONFIGRATE [current_design]
reset_property BITSTREAM.CONFIG.SPI_BUSWIDTH [current_design]
reset_property BITSTREAM.CONFIG.SPI_FALL_EDGE [current_design]

# Save partial bitstream
write_bitstream -force -cell ${partition_cell} ${build_directory}/${proj_name}_pblock_rm_partial.bit

# Format partial bitstream for ICAP:
#
# The user guide says SMAPx32 and disablebitswap are only needed for PCAP or MCAP but
# but it's probably needed here since we aren't running on an ARM or the MicroBlaze.
#
write_cfgmem -force -format BIN -interface SMAPx32 -disablebitswap \
    -loadbit "up 0x0 ${build_directory}/${proj_name}_pblock_rm_partial.bit" \
    -file "${build_directory}/${proj_name}_pblock_rm_partial_icap.bin"

# Delete no longer needed bitstream
file delete ${build_directory}/${proj_name}_pblock_rm_partial.bit

# We're finished
close_project
