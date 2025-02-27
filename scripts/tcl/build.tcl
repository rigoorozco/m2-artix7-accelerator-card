#
# Typical usage: vivado -mode batch -source build.tcl -tclargs ${BUILD_STEP}
#

if { $argc != 1 } {
    puts "Invalid argument count. Please try again."
} else {
    set BUILD_STEP [expr [lindex $argv 0]]
}

# Store working directories
set curr_directory [pwd]
set build_directory [pwd]/build
set proj_directory ${build_directory}/temp_project

# Create build directory
file mkdir ${build_directory}

# Set default variables. Will be overriden by project_config.tcl
set hdl_sources {}
set partition_definitions {}

# Source project configurations
source ${curr_directory}/project_config.tcl

# Create the project and directory structure
create_project -force ${proj_name} ${proj_directory} -part ${part_name}

# Source block design tcl scripts
foreach bd ${block_designs} {
    source ${curr_directory}/${bd}
}

# Make a wrapper for block design and make top
make_wrapper -top \
-files [get_files ${proj_directory}/${proj_name}.srcs/sources_1/bd/${design_name}/${design_name}.bd]
add_files -norecurse ${proj_directory}/${proj_name}.gen/sources_1/bd/${design_name}/hdl/${design_name}_wrapper.v
set_property top ${proj_name}_wrapper [current_fileset]

# Add hdl sources to the project
add_files -quiet ${hdl_sources}

# Add pin constraints to the project
foreach constr ${constraints} {
    add_files -fileset constrs_1 ${curr_directory}/${constr}
}

# Now import/copy the files into the project
import_files -force

# Update to set top and file compile order
update_compile_order -fileset sources_1

if { ${BUILD_STEP} > 0 } {
    # Launch Synthesis
    launch_runs synth_1 -jobs 2
    wait_on_run synth_1
    open_run synth_1 -name synth_1

    # Make output directory
    file mkdir ${build_directory}/static

    # Generate a timing and power reports and write to disk
    # Can create custom reports as required
    report_timing_summary -delay_type max -report_unconstrained -check_timing_verbose \
    -max_paths 10 -input_pins -file ${build_directory}/static/syn_timing.rpt
    report_power -file ${build_directory}/static/syn_power.rpt

    set num_partitions [llength ${partition_definitions}]
    for {set p 0} {${p} < ${num_partitions}} {incr p} {
        # Setup partition definitions
        set partition_def [lindex ${partition_definitions} ${p}]
        create_pr_configuration -name config_${p} -partitions ${partition_def}
        set_property PR_CONFIGURATION config_${p} [get_runs impl_1]

        # Make output directory
        file mkdir ${build_directory}/reconfigurable

        # Write synth checkpoints while we're here
        set module [lindex [split ${partition_def} ":"] 0]
        set inst [lindex [split ${partition_def} ":"] 1]
        write_checkpoint -force -cell ${module} ${build_directory}/reconfigurable/${inst}_synth.dcp
    }

    if { ${BUILD_STEP} > 1 } {
        # Launch Implementation
        launch_runs impl_1 -to_step write_bitstream -jobs 2
        wait_on_run impl_1

        # Generate a timing and power reports and write to disk
        # comment out the open_run for batch mode
        open_run impl_1
        report_timing_summary -delay_type min_max -report_unconstrained \
        -check_timing_verbose -max_paths 10 -input_pins -file ${build_directory}/static/imp_timing.rpt
        report_power -file ${build_directory}/static/imp_power.rpt

        # Copy routed checkpoint(s) to build directory
        foreach dcp [glob ${proj_directory}/${proj_name}.runs/impl_1/*_routed.dcp] {
            file copy -force ${dcp} ${build_directory}/static/
        }

        # Copy bistream(s) to build directory
        foreach bit [glob ${proj_directory}/${proj_name}.runs/impl_1/*.bit] {
            file copy -force ${bit} ${build_directory}/static/
        }
    }
}
