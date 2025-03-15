#
# Typical usage: vivado -mode batch -source full.tcl -tclargs ${BUILD_STEP}
#

if { $argc != 2 } {
    puts "Invalid argument count. Please try again."
} else {
    set BUILD_STEP [expr [lindex $argv 0]]
    set NUM_PROC [expr [lindex $argv 1]]
}

# Store working directories
set current_directory [pwd]
set build_directory [pwd]/build/full
set proj_directory ${build_directory}/temp_project

# Create build directory
file mkdir ${build_directory}

# Set default variables. Will be overridden by project_config.tcl
set hdl_sources {}
set partition_bdc 0

# Source project configurations
source ${current_directory}/project_config.tcl

# Create the project and directory structure
create_project -force ${proj_name} ${proj_directory} -part ${part_name}

# Source DFX block design container if defined
if {${partition_bdc} != 0} {
    source ${current_directory}/${partition_bdc}
}

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

# Source block design tcl script
source ${current_directory}/${block_design}

# Make a wrapper for block design and make top
make_wrapper -top \
    -files [get_files ${proj_directory}/${proj_name}.srcs/sources_1/bd/${design_name}/${design_name}.bd]
add_files -norecurse ${proj_directory}/${proj_name}.gen/sources_1/bd/${design_name}/hdl/${design_name}_wrapper.v
set_property top ${design_name}_wrapper [current_fileset]

# Update to set top and file compile order
update_compile_order -fileset sources_1

# Add pin constraints to the project
foreach constr ${constraints} {
    add_files -fileset constrs_1 ${current_directory}/${constr}

    # Add specific settings for early constraints file
    if {[string match  "*_early.xdc" "${constr}"]} {
        set_property PROCESSING_ORDER EARLY [get_files -all ${current_directory}/${constr}]
    }
}

# Now import/copy the files into the project
import_files -force

if { ${BUILD_STEP} > 0 } {
    # Launch Synthesis
    launch_runs synth_1 -jobs ${NUM_PROC}
    wait_on_run synth_1
    open_run synth_1 -name synth_1

    # Setup partition definition (if any)
    if {${partition_bdc} != 0 } {
        create_pr_configuration -name config_def -partitions ${partition_cell}:${partition_inst}
        set_property PR_CONFIGURATION config_def [get_runs impl_1]
    }

    if { ${BUILD_STEP} > 1 } {
        # Generate a timing and power reports and write to disk
        # Can create custom reports as required
        report_timing_summary -delay_type max -report_unconstrained -check_timing_verbose \
            -max_paths 10 -input_pins -file ${build_directory}/syn_timing.rpt
        report_power -file ${build_directory}/syn_power.rpt

        # Move PCIe IP constraint file back so ours gets applied first
        set_property PROCESSING_ORDER NORMAL [get_files -all ${proj_directory}/${proj_name}.gen/sources_1/bd/${design_name}/ip/${design_name}_xdma_0_0/ip_0/source/${design_name}_xdma_0_0_pcie2_ip-PCIE_X0Y0.xdc]

        # Launch Implementation
        launch_runs impl_1 -jobs ${NUM_PROC}
        wait_on_run impl_1

        # Generate a timing and power reports and write to disk
        # comment out the open_run for batch mode
        open_run impl_1
        report_timing_summary -delay_type min_max -report_unconstrained \
            -check_timing_verbose -max_paths 10 -input_pins -file ${build_directory}/imp_timing.rpt
        report_power -file ${build_directory}/imp_power.rpt

        # Copy routed checkpoint to build directory
        file copy -force [glob ${proj_directory}/${proj_name}.runs/impl_1/*_wrapper_routed.dcp] ${build_directory}/

        # Save full bitstream
        write_bitstream -force -bin_file -no_binary_bitfile -no_partial_bitfile ${build_directory}/${proj_name}

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

        # Delete no longer needed partial bitstream
        file delete ${build_directory}/${proj_name}_pblock_rm_partial.bit

        # We're finished
        close_project
    }
}
