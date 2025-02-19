#
# Typical usage: vivado -mode batch -source build.tcl -tclargs ${BUILD_STEP}
#

if { $argc != 1 } {
    puts "Invalid argument count. Please try again."
} else {
    set BUILD_STEP [expr [lindex $argv 0]]
}

set current_directory [pwd]

# Set default variables. Will be overriden by project_config.tcl
set hdl_sources {}
set partition_definitions {}

# Source project configurations
source ${current_directory}/project_config.tcl

# Create the project and directory structure
create_project -force ${proj_name} ${current_directory}/temp_project -part ${part_name}

# Source block design tcl scripts
foreach bd ${block_designs} {
    source ${current_directory}/${bd}
}

# Make a wrapper for block design and make top
make_wrapper -top \
-files [get_files ${current_directory}/temp_project/${proj_name}.srcs/sources_1/bd/${design_name}/${design_name}.bd]
add_files -norecurse ${current_directory}/temp_project/${proj_name}.gen/sources_1/bd/${design_name}/hdl/${design_name}_wrapper.v
set_property top ${proj_name}_wrapper [current_fileset]

# Add hdl sources to the project
add_files -quiet ${hdl_sources}

# Add pin constraints to the project
foreach constr ${constraints} {
    add_files -fileset constrs_1 ${current_directory}/${constr}
}

# Now import/copy the files into the project
import_files -force

# Update to set top and file compile order
update_compile_order -fileset sources_1

if { ${BUILD_STEP} > 0 } {
    # Launch Synthesis
    launch_runs synth_1 -jobs 8
    wait_on_run synth_1
    open_run synth_1 -name synth_1

    # Create build directory
    file mkdir ${current_directory}/build

    set num_partitions [llength ${partition_definitions}]
    for {set p 0} {${p} < ${num_partitions}} {incr p} {
        # Setup partition definitions
        set partition_def [lindex ${partition_definitions} ${p}]
        create_pr_configuration -name config_${p} -partitions ${partition_def}
        set_property PR_CONFIGURATION config_${p} [get_runs impl_1]

        # Write synth checkpoints while we're here
        set module [lindex [split ${partition_def} ":"] 0]
        set inst [lindex [split ${partition_def} ":"] 1]
        write_checkpoint -force -cell ${module} ${current_directory}/build/${inst}_synth.dcp
    }

    if { ${BUILD_STEP} > 1 } {
        # Generate a timing and power reports and write to disk
        # Can create custom reports as required
        report_timing_summary -delay_type max -report_unconstrained -check_timing_verbose \
        -max_paths 10 -input_pins -file ${current_directory}/build/syn_timing.rpt
        report_power -file ${current_directory}/build/syn_power.rpt

        # Launch Implementation
        launch_runs impl_1 -to_step write_bitstream
        wait_on_run impl_1

        # Generate a timing and power reports and write to disk
        # comment out the open_run for batch mode
        open_run impl_1
        report_timing_summary -delay_type min_max -report_unconstrained \
        -check_timing_verbose -max_paths 10 -input_pins -file ${current_directory}/build/imp_timing.rpt
        report_power -file ${current_directory}/build/imp_power.rpt

        # Copy routed checkpoint(s) to build directory
        foreach dcp [glob ${current_directory}/temp_project/${proj_name}.runs/impl_1/*_routed.dcp] {
            file copy -force ${dcp} ${current_directory}/build/
        }

        # Copy bistream(s) to build directory
        foreach bit [glob ${current_directory}/temp_project/${proj_name}.runs/impl_1/*.bit] {
            file copy -force ${bit} ${current_directory}/build/
        }
    }
}
