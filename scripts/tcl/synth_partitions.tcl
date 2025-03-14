#
# Typical usage: vivado -mode batch -source synth_partitions.tcl
#

if { $argc != 1 } {
    puts "Invalid argument count. Please try again."
} else {
    set NUM_PROC [expr [lindex $argv 0]]
}

# Store current directory
set current_directory [pwd]
set build_directory [pwd]/build

# Source project configurations
source ${current_directory}/project_config.tcl

# Override proj_name
set partition_num 0

# Generate a bitstream for each partition
foreach bd ${block_designs} {
    if { [string match "*_bdc.tcl" "${bd}"] } {
        # Set project name
        set proj_name "dfx_partition_${partition_num}"
        incr partition_num

        # Set project directory
        set proj_directory ${build_directory}/${proj_name}

        # Create the project and directory structure
        create_project -force ${proj_name} ${proj_directory} -part ${part_name}

        # Source block design container
        source ${current_directory}/${bd}

        # Make a wrapper for block design and make top
        make_wrapper -top \
            -files [get_files ${proj_directory}/${proj_name}.srcs/sources_1/bd/${design_name}/${design_name}.bd]
        add_files -norecurse ${proj_directory}/${proj_name}.gen/sources_1/bd/${design_name}/hdl/${design_name}_wrapper.v
        set_property top ${proj_name}_wrapper [current_fileset]

        # Now import/copy the files into the project
        import_files -force

        # Update to set top and file compile order
        update_compile_order -fileset sources_1

        # Set as out of context
        set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-mode out_of_context} -objects [get_runs synth_1]

        # Launch Synthesis
        launch_runs synth_1 -jobs ${NUM_PROC}
        wait_on_run synth_1
        open_run synth_1 -name synth_1

        # Write synth checkpoints
        write_checkpoint -force ${build_directory}/reconfigurable/${design_name}_inst_0_synth.dcp

        # We're finished
        close_project
    }
}
