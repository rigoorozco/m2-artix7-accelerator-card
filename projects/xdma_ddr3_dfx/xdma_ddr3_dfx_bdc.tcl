
################################################################
# This is a generated script based on design: dfx_partition
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2024.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   if { [string compare $scripts_vivado_version $current_vivado_version] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2042 -severity "ERROR" " This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Sourcing the script failed since it was created with a future version of Vivado."}

   } else {
     catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   }

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source dfx_partition_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7a200tfbg484-2
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name dfx_partition

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:axi_datamover:5.1\
xilinx.com:ip:axi_gpio:2.0\
xilinx.com:ip:smartconnect:1.0\
xilinx.com:ip:axi_bram_ctrl:4.1\
xilinx.com:ip:blk_mem_gen:8.4\
xilinx.com:ip:axi_register_slice:2.1\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set rp_M_AXI [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 rp_M_AXI ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {64} \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.FREQ_HZ {125000000} \
   CONFIG.HAS_REGION {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI4} \
   ] $rp_M_AXI

  set rp_S_AXI [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 rp_S_AXI ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {31} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ {125000000} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4LITE} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $rp_S_AXI


  # Create ports
  set rp_clk [ create_bd_port -dir I -type clk -freq_hz 125000000 rp_clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {rp_M_AXI:rp_S_AXI} \
   CONFIG.ASSOCIATED_RESET {rp_resetn} \
 ] $rp_clk
  set rp_resetn [ create_bd_port -dir I rp_resetn ]

  # Create instance: axi_datamover_0, and set properties
  set axi_datamover_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_datamover:5.1 axi_datamover_0 ]
  set_property -dict [list \
    CONFIG.c_dummy {1} \
    CONFIG.c_enable_s2mm {0} \
    CONFIG.c_m_axis_mm2s_tdata_width {32} \
  ] $axi_datamover_0


  # Create instance: axi_datamover_1, and set properties
  set axi_datamover_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_datamover:5.1 axi_datamover_1 ]
  set_property -dict [list \
    CONFIG.c_dummy {1} \
    CONFIG.c_enable_mm2s {0} \
    CONFIG.c_enable_s2mm {1} \
    CONFIG.c_include_s2mm {Full} \
    CONFIG.c_include_s2mm_stsfifo {true} \
    CONFIG.c_m_axi_s2mm_awid {1} \
    CONFIG.c_m_axi_s2mm_data_width {64} \
    CONFIG.c_s2mm_addr_pipe_depth {3} \
    CONFIG.c_s_axis_s2mm_tdata_width {32} \
  ] $axi_datamover_1


  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0 ]

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
  set_property CONFIG.NUM_MI {2} $axi_interconnect_0


  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0 ]

  # Create instance: axi_bram_ctrl_0, and set properties
  set axi_bram_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_0 ]
  set_property CONFIG.DATA_WIDTH {64} $axi_bram_ctrl_0


  # Create instance: axi_bram_ctrl_0_bram, and set properties
  set axi_bram_ctrl_0_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 axi_bram_ctrl_0_bram ]
  set_property -dict [list \
    CONFIG.EN_SAFETY_CKT {false} \
    CONFIG.Enable_B {Use_ENB_Pin} \
    CONFIG.Memory_Type {True_Dual_Port_RAM} \
    CONFIG.Port_B_Clock {100} \
    CONFIG.Port_B_Enable_Rate {100} \
    CONFIG.Port_B_Write_Rate {50} \
    CONFIG.Use_RSTB_Pin {true} \
  ] $axi_bram_ctrl_0_bram


  # Create instance: axi_register_slice_0, and set properties
  set axi_register_slice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 axi_register_slice_0 ]
  set_property -dict [list \
    CONFIG.ADDR_WIDTH {64} \
    CONFIG.ARUSER_WIDTH {4} \
    CONFIG.AWUSER_WIDTH {4} \
    CONFIG.BUSER_WIDTH {0} \
    CONFIG.DATA_WIDTH {128} \
    CONFIG.HAS_BURST {1} \
    CONFIG.HAS_CACHE {1} \
    CONFIG.HAS_LOCK {1} \
    CONFIG.HAS_PROT {1} \
    CONFIG.HAS_QOS {1} \
    CONFIG.HAS_REGION {1} \
    CONFIG.HAS_WSTRB {1} \
    CONFIG.ID_WIDTH {0} \
    CONFIG.MAX_BURST_LENGTH {1} \
    CONFIG.NUM_READ_OUTSTANDING {1} \
    CONFIG.NUM_READ_THREADS {0} \
    CONFIG.NUM_WRITE_OUTSTANDING {1} \
    CONFIG.NUM_WRITE_THREADS {0} \
    CONFIG.PROTOCOL {AXI4} \
    CONFIG.READ_WRITE_MODE {READ_WRITE} \
    CONFIG.RUSER_BITS_PER_BYTE {0} \
    CONFIG.RUSER_WIDTH {0} \
    CONFIG.SUPPORTS_NARROW_BURST {1} \
    CONFIG.WUSER_BITS_PER_BYTE {0} \
    CONFIG.WUSER_WIDTH {0} \
  ] $axi_register_slice_0


  # Create instance: axi_register_slice_1, and set properties
  set axi_register_slice_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 axi_register_slice_1 ]
  set_property -dict [list \
    CONFIG.ADDR_WIDTH {32} \
    CONFIG.DATA_WIDTH {32} \
    CONFIG.HAS_BRESP {1} \
    CONFIG.HAS_BURST {1} \
    CONFIG.HAS_CACHE {1} \
    CONFIG.HAS_LOCK {1} \
    CONFIG.HAS_PROT {1} \
    CONFIG.HAS_QOS {1} \
    CONFIG.HAS_REGION {1} \
    CONFIG.HAS_RRESP {1} \
    CONFIG.HAS_WSTRB {1} \
    CONFIG.MAX_BURST_LENGTH {1} \
    CONFIG.NUM_READ_OUTSTANDING {1} \
    CONFIG.NUM_READ_THREADS {0} \
    CONFIG.NUM_WRITE_OUTSTANDING {1} \
    CONFIG.NUM_WRITE_THREADS {0} \
    CONFIG.PROTOCOL {AXI4LITE} \
    CONFIG.READ_WRITE_MODE {READ_WRITE} \
    CONFIG.REG_AR {1} \
    CONFIG.REG_AW {1} \
    CONFIG.REG_B {1} \
    CONFIG.REG_R {1} \
    CONFIG.REG_W {1} \
    CONFIG.RUSER_BITS_PER_BYTE {0} \
    CONFIG.SUPPORTS_NARROW_BURST {0} \
    CONFIG.WUSER_BITS_PER_BYTE {0} \
  ] $axi_register_slice_1


  # Create interface connections
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_0_bram/BRAM_PORTA] [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTB [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTB] [get_bd_intf_pins axi_bram_ctrl_0_bram/BRAM_PORTB]
  connect_bd_intf_net -intf_net axi_datamover_0_M_AXI_MM2S [get_bd_intf_pins axi_datamover_0/M_AXI_MM2S] [get_bd_intf_pins smartconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net axi_datamover_1_M_AXI_S2MM [get_bd_intf_pins axi_datamover_1/M_AXI_S2MM] [get_bd_intf_pins smartconnect_0/S01_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins axi_gpio_0/S_AXI] [get_bd_intf_pins axi_interconnect_0/M00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M01_AXI [get_bd_intf_pins axi_bram_ctrl_0/S_AXI] [get_bd_intf_pins axi_interconnect_0/M01_AXI]
  connect_bd_intf_net -intf_net axi_register_slice_0_M_AXI [get_bd_intf_ports rp_M_AXI] [get_bd_intf_pins axi_register_slice_0/M_AXI]
  connect_bd_intf_net -intf_net axi_register_slice_1_M_AXI [get_bd_intf_pins axi_register_slice_1/M_AXI] [get_bd_intf_pins axi_interconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net rp_S_AXI_1 [get_bd_intf_ports rp_S_AXI] [get_bd_intf_pins axi_register_slice_1/S_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins axi_register_slice_0/S_AXI] [get_bd_intf_pins smartconnect_0/M00_AXI]

  # Create port connections
  connect_bd_net -net rp_clk_1  [get_bd_ports rp_clk] \
  [get_bd_pins axi_datamover_0/m_axi_mm2s_aclk] \
  [get_bd_pins axi_datamover_0/m_axis_mm2s_cmdsts_aclk] \
  [get_bd_pins axi_datamover_1/m_axi_s2mm_aclk] \
  [get_bd_pins axi_datamover_1/m_axis_s2mm_cmdsts_awclk] \
  [get_bd_pins axi_gpio_0/s_axi_aclk] \
  [get_bd_pins axi_interconnect_0/ACLK] \
  [get_bd_pins axi_interconnect_0/S00_ACLK] \
  [get_bd_pins axi_interconnect_0/M00_ACLK] \
  [get_bd_pins smartconnect_0/aclk] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] \
  [get_bd_pins axi_interconnect_0/M01_ACLK] \
  [get_bd_pins axi_register_slice_0/aclk] \
  [get_bd_pins axi_register_slice_1/aclk]
  connect_bd_net -net rp_resetn_1  [get_bd_ports rp_resetn] \
  [get_bd_pins axi_datamover_0/m_axi_mm2s_aresetn] \
  [get_bd_pins axi_datamover_0/m_axis_mm2s_cmdsts_aresetn] \
  [get_bd_pins axi_datamover_1/m_axi_s2mm_aresetn] \
  [get_bd_pins axi_datamover_1/m_axis_s2mm_cmdsts_aresetn] \
  [get_bd_pins axi_gpio_0/s_axi_aresetn] \
  [get_bd_pins axi_interconnect_0/ARESETN] \
  [get_bd_pins axi_interconnect_0/S00_ARESETN] \
  [get_bd_pins axi_interconnect_0/M00_ARESETN] \
  [get_bd_pins smartconnect_0/aresetn] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] \
  [get_bd_pins axi_interconnect_0/M01_ARESETN] \
  [get_bd_pins axi_register_slice_0/aresetn] \
  [get_bd_pins axi_register_slice_1/aresetn]

  # Create address segments
  assign_bd_address -offset 0x80000000 -range 0x08000000 -target_address_space [get_bd_addr_spaces axi_datamover_0/Data_MM2S] [get_bd_addr_segs rp_M_AXI/Reg] -force
  assign_bd_address -offset 0x80000000 -range 0x08000000 -target_address_space [get_bd_addr_spaces axi_datamover_1/Data_S2MM] [get_bd_addr_segs rp_M_AXI/Reg] -force
  assign_bd_address -offset 0x41000000 -range 0x00002000 -target_address_space [get_bd_addr_spaces rp_S_AXI] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] -force
  assign_bd_address -offset 0x41002000 -range 0x00002000 -target_address_space [get_bd_addr_spaces rp_S_AXI] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


