#
# Typical usage: vivado -mode batch -source build_partitions.tcl
#

# Store current directory
set current_directory [pwd]

# Source project configurations
source ${current_directory}/project_config.tcl

# Create partial directory
file mkdir ${current_directory}/partial

# Generate a bitstream for each partition
set num_partitions [llength ${partition_definitions}]
for {set p 0} {${p} < ${num_partitions}} {incr p} {
    # Extract partition information
    set partition_def [lindex ${partition_definitions} ${p}]
    set module [lindex [split ${partition_def} ":"] 0]
    set inst [lindex [split ${partition_def} ":"] 1]

    # Generate static region checkpoint with black box
    open_checkpoint ${current_directory}/build/${proj_name}_wrapper_routed.dcp
    update_design -cell ${module} -black_box
    lock_design -level routing
    write_checkpoint -force ${current_directory}/partial/static_routed.dcp

    # Swap black box for DFX partition
    open_checkpoint ${current_directory}/partial/static_routed.dcp
    read_checkpoint -cell ${module} ${current_directory}/build/${inst}_synth.dcp

    # Build design
    opt_design
    place_design
    route_design

    # Write config checkpoint and verify
    write_checkpoint -force ${current_directory}/partial/config_${inst}_routed.dcp
    pr_verify ${current_directory}/build/${proj_name}_wrapper_routed.dcp \
    ${current_directory}/partial/config_${inst}_routed.dcp

    # Save bitstream and close
    write_bitstream -force ${current_directory}/partial/${proj_name}
    close_project
}
