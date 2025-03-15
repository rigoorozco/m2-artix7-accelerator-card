#
# Typical usage: vivado -mode batch -source partial_synth.tcl
#

if { $argc != 2 } {
    puts "Invalid argument count. Please try again."
} else {
    set DFX_BDC_TCL [lindex $argv 0]
    set NUM_PROC [expr [lindex $argv 1]]
}

# Store working directories
set current_directory [pwd]
set build_directory [pwd]/build/partial
set proj_directory ${build_directory}/temp_project

# Create build directory
file mkdir ${build_directory}

# Set default variables. Will be overridden by project_config.tcl
set hdl_sources {}

# Source project configurations
source ${current_directory}/project_config.tcl

# Create the project and directory structure
create_project -force ${proj_name} ${proj_directory} -part ${part_name}

# Get path to all HDL sources
set hdl_paths {}
foreach source ${hdl_sources} {
    lappend hdl_paths ${current_directory}/${source}
}

# Add hdl sources to the project
if {[llength ${hdl_paths}] != 0} {
    add_files ${hdl_paths}
}

# Update file compile order
update_compile_order -fileset sources_1

# Source DFX block design container
source ${current_directory}/${DFX_BDC_TCL}

# Make a wrapper for block design and make top
make_wrapper -top \
    -files [get_files ${proj_directory}/${proj_name}.srcs/sources_1/bd/${design_name}/${design_name}.bd]
add_files -norecurse ${proj_directory}/${proj_name}.gen/sources_1/bd/${design_name}/hdl/${design_name}_wrapper.v
set_property top ${design_name}_wrapper [current_fileset]

# Update file compile order
update_compile_order -fileset sources_1

# Now import/copy the files into the project
import_files -force

# Set as out of context
set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-mode out_of_context} -objects [get_runs synth_1]

# Launch Synthesis
launch_runs synth_1 -jobs ${NUM_PROC}
wait_on_run synth_1
open_run synth_1 -name synth_1

# Write synth checkpoints
write_checkpoint -force ${build_directory}/${partition_inst}_synth.dcp

# We're finished
close_project
