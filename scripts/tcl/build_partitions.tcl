#
# Typical usage: vivado -mode batch -source build_partitions.tcl
#

# Store current directory
set current_directory [pwd]
set build_directory [pwd]/build

# Source project configurations
source ${current_directory}/project_config.tcl

# Generate a bitstream for each partition
set num_partitions [llength ${partition_definitions}]
for {set p 0} {${p} < ${num_partitions}} {incr p} {
    # Extract partition information
    set partition_def [lindex ${partition_definitions} ${p}]
    set module [lindex [split ${partition_def} ":"] 0]
    set inst [lindex [split ${partition_def} ":"] 1]

    # Generate static region checkpoint with black box
    open_checkpoint ${build_directory}/static/${proj_name}_wrapper_routed.dcp
    update_design -cell ${module} -black_box
    lock_design -level routing
    write_checkpoint -force ${build_directory}/reconfigurable/static_routed.dcp

    # Swap black box for DFX partition
    open_checkpoint ${build_directory}/reconfigurable/static_routed.dcp
    read_checkpoint -cell ${module} ${build_directory}/reconfigurable/${inst}_synth.dcp

    # Build design
    opt_design
    place_design
    route_design

    # Write config checkpoint and verify
    write_checkpoint -force ${build_directory}/reconfigurable/config_${inst}_routed.dcp
    pr_verify ${build_directory}/static/${proj_name}_wrapper_routed.dcp \
    ${build_directory}/reconfigurable/config_${inst}_routed.dcp

    # Save bitstream and close
    write_bitstream -bin_file -force ${build_directory}/reconfigurable/${proj_name}
    close_project
}
