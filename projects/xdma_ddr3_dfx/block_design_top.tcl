
################################################################
# This is a generated script based on design: xdma_ddr3_dfx
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
# source xdma_ddr3_dfx_script.tcl


# The design that will be created by this Tcl script contains the following 
# block design container source references:
# dfx_partition

# Please add the sources before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7a200tfbg484-2
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name xdma_ddr3_dfx

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
xilinx.com:ip:axi_gpio:2.0\
xilinx.com:ip:axi_hwicap:3.0\
xilinx.com:ip:mig_7series:4.2\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:util_ds_buf:2.2\
xilinx.com:ip:xdma:4.1\
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:smartconnect:1.0\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:dfx_axi_shutdown_manager:1.0\
xilinx.com:ip:axi_register_slice:2.1\
xilinx.com:ip:dfx_decoupler:1.0\
xilinx.com:ip:xlslice:1.0\
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

##################################################################
# CHECK Block Design Container Sources
##################################################################
set bCheckSources 1
set list_bdc_active "dfx_partition"

array set map_bdc_missing {}
set map_bdc_missing(ACTIVE) ""
set map_bdc_missing(BDC) ""

if { $bCheckSources == 1 } {
   set list_check_srcs "\ 
dfx_partition \
"

   common::send_gid_msg -ssname BD::TCL -id 2056 -severity "INFO" "Checking if the following sources for block design container exist in the project: $list_check_srcs .\n\n"

   foreach src $list_check_srcs {
      if { [can_resolve_reference $src] == 0 } {
         if { [lsearch $list_bdc_active $src] != -1 } {
            set map_bdc_missing(ACTIVE) "$map_bdc_missing(ACTIVE) $src"
         } else {
            set map_bdc_missing(BDC) "$map_bdc_missing(BDC) $src"
         }
      }
   }

   if { [llength $map_bdc_missing(ACTIVE)] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2057 -severity "ERROR" "The following source(s) of Active variants are not found in the project: $map_bdc_missing(ACTIVE)" }
      common::send_gid_msg -ssname BD::TCL -id 2060 -severity "INFO" "Please add source files for the missing source(s) above."
      set bCheckIPsPassed 0
   }
   if { [llength $map_bdc_missing(BDC)] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2059 -severity "WARNING" "The following source(s) of variants are not found in the project: $map_bdc_missing(BDC)" }
      common::send_gid_msg -ssname BD::TCL -id 2060 -severity "INFO" "Please add source files for the missing source(s) above."
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}


##################################################################
# MIG PRJ FILE TCL PROCs
##################################################################

proc write_mig_file_xdma_ddr3_dfx_mig_7series_0_0 { str_mig_prj_filepath } {

   file mkdir [ file dirname "$str_mig_prj_filepath" ]
   set mig_prj_file [open $str_mig_prj_filepath  w+]

   puts $mig_prj_file {﻿<?xml version="1.0" encoding="UTF-8" standalone="no" ?>}
   puts $mig_prj_file {<Project NoOfControllers="1">}
   puts $mig_prj_file {  }
   puts $mig_prj_file {<!-- IMPORTANT: This is an internal file that has been generated by the MIG software. Any direct editing or changes made to this file may result in unpredictable behavior or data corruption. It is strongly advised that users do not edit the contents of this file. Re-run the MIG GUI with the required settings if any of the options provided below need to be altered. -->}
   puts $mig_prj_file {  <ModuleName>xdma_ddr3_dfx_mig_7series_0_0</ModuleName>}
   puts $mig_prj_file {  <dci_inouts_inputs>1</dci_inouts_inputs>}
   puts $mig_prj_file {  <dci_inputs>1</dci_inputs>}
   puts $mig_prj_file {  <Debug_En>OFF</Debug_En>}
   puts $mig_prj_file {  <DataDepth_En>1024</DataDepth_En>}
   puts $mig_prj_file {  <LowPower_En>ON</LowPower_En>}
   puts $mig_prj_file {  <XADC_En>Enabled</XADC_En>}
   puts $mig_prj_file {  <TargetFPGA>xc7a200t-fbg484/-2</TargetFPGA>}
   puts $mig_prj_file {  <Version>4.2</Version>}
   puts $mig_prj_file {  <SystemClock>No Buffer</SystemClock>}
   puts $mig_prj_file {  <ReferenceClock>No Buffer</ReferenceClock>}
   puts $mig_prj_file {  <SysResetPolarity>ACTIVE LOW</SysResetPolarity>}
   puts $mig_prj_file {  <BankSelectionFlag>FALSE</BankSelectionFlag>}
   puts $mig_prj_file {  <InternalVref>1</InternalVref>}
   puts $mig_prj_file {  <dci_hr_inouts_inputs>50 Ohms</dci_hr_inouts_inputs>}
   puts $mig_prj_file {  <dci_cascade>0</dci_cascade>}
   puts $mig_prj_file {  <Controller number="0">}
   puts $mig_prj_file {    <MemoryDevice>DDR3_SDRAM/Components/MT41J128M16XX-125</MemoryDevice>}
   puts $mig_prj_file {    <TimePeriod>2500</TimePeriod>}
   puts $mig_prj_file {    <VccAuxIO>1.8V</VccAuxIO>}
   puts $mig_prj_file {    <PHYRatio>4:1</PHYRatio>}
   puts $mig_prj_file {    <InputClkFreq>200</InputClkFreq>}
   puts $mig_prj_file {    <UIExtraClocks>0</UIExtraClocks>}
   puts $mig_prj_file {    <MMCM_VCO>800</MMCM_VCO>}
   puts $mig_prj_file {    <MMCMClkOut0> 1.000</MMCMClkOut0>}
   puts $mig_prj_file {    <MMCMClkOut1>1</MMCMClkOut1>}
   puts $mig_prj_file {    <MMCMClkOut2>1</MMCMClkOut2>}
   puts $mig_prj_file {    <MMCMClkOut3>1</MMCMClkOut3>}
   puts $mig_prj_file {    <MMCMClkOut4>1</MMCMClkOut4>}
   puts $mig_prj_file {    <DataWidth>16</DataWidth>}
   puts $mig_prj_file {    <DeepMemory>1</DeepMemory>}
   puts $mig_prj_file {    <DataMask>1</DataMask>}
   puts $mig_prj_file {    <ECC>Disabled</ECC>}
   puts $mig_prj_file {    <Ordering>Normal</Ordering>}
   puts $mig_prj_file {    <BankMachineCnt>4</BankMachineCnt>}
   puts $mig_prj_file {    <CustomPart>FALSE</CustomPart>}
   puts $mig_prj_file {    <NewPartName/>}
   puts $mig_prj_file {    <RowAddress>14</RowAddress>}
   puts $mig_prj_file {    <ColAddress>10</ColAddress>}
   puts $mig_prj_file {    <BankAddress>3</BankAddress>}
   puts $mig_prj_file {    <MemoryVoltage>1.5V</MemoryVoltage>}
   puts $mig_prj_file {    <C0_MEM_SIZE>268435456</C0_MEM_SIZE>}
   puts $mig_prj_file {    <UserMemoryAddressMap>BANK_ROW_COLUMN</UserMemoryAddressMap>}
   puts $mig_prj_file {    <PinSelection>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="U6" SLEW="" VCCAUX_IO="" name="ddr3_addr[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="Y6" SLEW="" VCCAUX_IO="" name="ddr3_addr[10]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="U7" SLEW="" VCCAUX_IO="" name="ddr3_addr[11]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="W7" SLEW="" VCCAUX_IO="" name="ddr3_addr[12]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="Y9" SLEW="" VCCAUX_IO="" name="ddr3_addr[13]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="T6" SLEW="" VCCAUX_IO="" name="ddr3_addr[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="Y8" SLEW="" VCCAUX_IO="" name="ddr3_addr[2]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="W6" SLEW="" VCCAUX_IO="" name="ddr3_addr[3]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="AB7" SLEW="" VCCAUX_IO="" name="ddr3_addr[4]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="V7" SLEW="" VCCAUX_IO="" name="ddr3_addr[5]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="Y7" SLEW="" VCCAUX_IO="" name="ddr3_addr[6]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="W9" SLEW="" VCCAUX_IO="" name="ddr3_addr[7]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="AB8" SLEW="" VCCAUX_IO="" name="ddr3_addr[8]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="AA8" SLEW="" VCCAUX_IO="" name="ddr3_addr[9]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="V5" SLEW="" VCCAUX_IO="" name="ddr3_ba[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="AA6" SLEW="" VCCAUX_IO="" name="ddr3_ba[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="U5" SLEW="" VCCAUX_IO="" name="ddr3_ba[2]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="R6" SLEW="" VCCAUX_IO="" name="ddr3_cas_n"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15" PADName="V8" SLEW="" VCCAUX_IO="" name="ddr3_ck_n[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15" PADName="V9" SLEW="" VCCAUX_IO="" name="ddr3_ck_p[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="AB6" SLEW="" VCCAUX_IO="" name="ddr3_cke[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="T5" SLEW="" VCCAUX_IO="" name="ddr3_cs_n[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="AB1" SLEW="" VCCAUX_IO="" name="ddr3_dm[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="V2" SLEW="" VCCAUX_IO="" name="ddr3_dm[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="V4" SLEW="" VCCAUX_IO="" name="ddr3_dq[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="U3" SLEW="" VCCAUX_IO="" name="ddr3_dq[10]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="T1" SLEW="" VCCAUX_IO="" name="ddr3_dq[11]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="Y1" SLEW="" VCCAUX_IO="" name="ddr3_dq[12]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="U1" SLEW="" VCCAUX_IO="" name="ddr3_dq[13]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="Y2" SLEW="" VCCAUX_IO="" name="ddr3_dq[14]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="W1" SLEW="" VCCAUX_IO="" name="ddr3_dq[15]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="AB2" SLEW="" VCCAUX_IO="" name="ddr3_dq[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="AB3" SLEW="" VCCAUX_IO="" name="ddr3_dq[2]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="AA1" SLEW="" VCCAUX_IO="" name="ddr3_dq[3]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="AA5" SLEW="" VCCAUX_IO="" name="ddr3_dq[4]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="Y4" SLEW="" VCCAUX_IO="" name="ddr3_dq[5]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="AB5" SLEW="" VCCAUX_IO="" name="ddr3_dq[6]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="AA4" SLEW="" VCCAUX_IO="" name="ddr3_dq[7]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="W2" SLEW="" VCCAUX_IO="" name="ddr3_dq[8]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="U2" SLEW="" VCCAUX_IO="" name="ddr3_dq[9]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15" PADName="AA3" SLEW="" VCCAUX_IO="" name="ddr3_dqs_n[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15" PADName="R2" SLEW="" VCCAUX_IO="" name="ddr3_dqs_n[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15" PADName="Y3" SLEW="" VCCAUX_IO="" name="ddr3_dqs_p[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15" PADName="R3" SLEW="" VCCAUX_IO="" name="ddr3_dqs_p[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="T4" SLEW="" VCCAUX_IO="" name="ddr3_odt[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="R4" SLEW="" VCCAUX_IO="" name="ddr3_ras_n"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="LVCMOS15" PADName="T3" SLEW="" VCCAUX_IO="" name="ddr3_reset_n"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="W5" SLEW="" VCCAUX_IO="" name="ddr3_we_n"/>}
   puts $mig_prj_file {    </PinSelection>}
   puts $mig_prj_file {    <System_Control>}
   puts $mig_prj_file {      <Pin Bank="Select Bank" PADName="No connect" name="sys_rst"/>}
   puts $mig_prj_file {      <Pin Bank="Select Bank" PADName="No connect" name="init_calib_complete"/>}
   puts $mig_prj_file {      <Pin Bank="Select Bank" PADName="No connect" name="tg_compare_error"/>}
   puts $mig_prj_file {    </System_Control>}
   puts $mig_prj_file {    <TimingParameters>}
   puts $mig_prj_file {      <Parameters tcke="5" tfaw="40" tras="35" trcd="13.75" trefi="7.8" trfc="160" trp="13.75" trrd="7.5" trtp="7.5" twtr="7.5"/>}
   puts $mig_prj_file {    </TimingParameters>}
   puts $mig_prj_file {    <mrBurstLength name="Burst Length">8 - Fixed</mrBurstLength>}
   puts $mig_prj_file {    <mrBurstType name="Read Burst Type and Length">Sequential</mrBurstType>}
   puts $mig_prj_file {    <mrCasLatency name="CAS Latency">6</mrCasLatency>}
   puts $mig_prj_file {    <mrMode name="Mode">Normal</mrMode>}
   puts $mig_prj_file {    <mrDllReset name="DLL Reset">No</mrDllReset>}
   puts $mig_prj_file {    <mrPdMode name="DLL control for precharge PD">Slow Exit</mrPdMode>}
   puts $mig_prj_file {    <emrDllEnable name="DLL Enable">Enable</emrDllEnable>}
   puts $mig_prj_file {    <emrOutputDriveStrength name="Output Driver Impedance Control">RZQ/7</emrOutputDriveStrength>}
   puts $mig_prj_file {    <emrMirrorSelection name="Address Mirroring">Disable</emrMirrorSelection>}
   puts $mig_prj_file {    <emrCSSelection name="Controller Chip Select Pin">Enable</emrCSSelection>}
   puts $mig_prj_file {    <emrRTT name="RTT (nominal) - On Die Termination (ODT)">RZQ/4</emrRTT>}
   puts $mig_prj_file {    <emrPosted name="Additive Latency (AL)">0</emrPosted>}
   puts $mig_prj_file {    <emrOCD name="Write Leveling Enable">Disabled</emrOCD>}
   puts $mig_prj_file {    <emrDQS name="TDQS enable">Enabled</emrDQS>}
   puts $mig_prj_file {    <emrRDQS name="Qoff">Output Buffer Enabled</emrRDQS>}
   puts $mig_prj_file {    <mr2PartialArraySelfRefresh name="Partial-Array Self Refresh">Full Array</mr2PartialArraySelfRefresh>}
   puts $mig_prj_file {    <mr2CasWriteLatency name="CAS write latency">5</mr2CasWriteLatency>}
   puts $mig_prj_file {    <mr2AutoSelfRefresh name="Auto Self Refresh">Enabled</mr2AutoSelfRefresh>}
   puts $mig_prj_file {    <mr2SelfRefreshTempRange name="High Temparature Self Refresh Rate">Normal</mr2SelfRefreshTempRange>}
   puts $mig_prj_file {    <mr2RTTWR name="RTT_WR - Dynamic On Die Termination (ODT)">Dynamic ODT off</mr2RTTWR>}
   puts $mig_prj_file {    <PortInterface>AXI</PortInterface>}
   puts $mig_prj_file {    <AXIParameters>}
   puts $mig_prj_file {      <C0_C_RD_WR_ARB_ALGORITHM>RD_PRI_REG</C0_C_RD_WR_ARB_ALGORITHM>}
   puts $mig_prj_file {      <C0_S_AXI_ADDR_WIDTH>28</C0_S_AXI_ADDR_WIDTH>}
   puts $mig_prj_file {      <C0_S_AXI_DATA_WIDTH>128</C0_S_AXI_DATA_WIDTH>}
   puts $mig_prj_file {      <C0_S_AXI_ID_WIDTH>5</C0_S_AXI_ID_WIDTH>}
   puts $mig_prj_file {      <C0_S_AXI_SUPPORTS_NARROW_BURST>0</C0_S_AXI_SUPPORTS_NARROW_BURST>}
   puts $mig_prj_file {    </AXIParameters>}
   puts $mig_prj_file {  </Controller>}
   puts $mig_prj_file {</Project>}

   close $mig_prj_file
}
# End of write_mig_file_xdma_ddr3_dfx_mig_7series_0_0()



##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: dfx_socket
proc create_hier_cell_dfx_socket { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_dfx_socket() - Empty argument(s)!"}
     return
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

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 rp_M_AXI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 rp_S_AXI


  # Create pins
  create_bd_pin -dir I -type clk clk
  create_bd_pin -dir I resetn
  create_bd_pin -dir O -from 0 -to 0 rp_resetn

  # Create instance: decouple_shutdown_ctrl, and set properties
  set decouple_shutdown_ctrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 decouple_shutdown_ctrl ]
  set_property -dict [list \
    CONFIG.C_ALL_INPUTS_2 {1} \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_GPIO2_WIDTH {5} \
    CONFIG.C_GPIO_WIDTH {3} \
    CONFIG.C_IS_DUAL {1} \
  ] $decouple_shutdown_ctrl


  # Create instance: dfx_axi_shutdown_static_master, and set properties
  set dfx_axi_shutdown_static_master [ create_bd_cell -type ip -vlnv xilinx.com:ip:dfx_axi_shutdown_manager:1.0 dfx_axi_shutdown_static_master ]
  set_property -dict [list \
    CONFIG.DP_PROTOCOL {AXI4LITE} \
    CONFIG.RP_IS_MASTER {false} \
  ] $dfx_axi_shutdown_static_master


  # Create instance: dfx_axi_shutdown_static_slave, and set properties
  set dfx_axi_shutdown_static_slave [ create_bd_cell -type ip -vlnv xilinx.com:ip:dfx_axi_shutdown_manager:1.0 dfx_axi_shutdown_static_slave ]

  # Create instance: xlconcat_status, and set properties
  set xlconcat_status [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_status ]
  set_property -dict [list \
    CONFIG.IN0_WIDTH {1} \
    CONFIG.IN1_WIDTH {1} \
    CONFIG.IN2_WIDTH {1} \
    CONFIG.IN3_WIDTH {1} \
    CONFIG.IN4_WIDTH {1} \
    CONFIG.IN5_WIDTH {27} \
    CONFIG.NUM_PORTS {5} \
  ] $xlconcat_status


  # Create instance: rp_m_axi_register_slice, and set properties
  set rp_m_axi_register_slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 rp_m_axi_register_slice ]
  set_property -dict [list \
    CONFIG.ADDR_WIDTH {64} \
    CONFIG.ARUSER_WIDTH {0} \
    CONFIG.AWUSER_WIDTH {0} \
    CONFIG.BUSER_WIDTH {0} \
    CONFIG.DATA_WIDTH {128} \
    CONFIG.HAS_BRESP {1} \
    CONFIG.HAS_BURST {0} \
    CONFIG.HAS_CACHE {1} \
    CONFIG.HAS_LOCK {1} \
    CONFIG.HAS_PROT {0} \
    CONFIG.HAS_QOS {0} \
    CONFIG.HAS_REGION {1} \
    CONFIG.HAS_RRESP {1} \
    CONFIG.HAS_WSTRB {1} \
    CONFIG.ID_WIDTH {5} \
    CONFIG.MAX_BURST_LENGTH {256} \
    CONFIG.NUM_READ_OUTSTANDING {8} \
    CONFIG.NUM_READ_THREADS {1} \
    CONFIG.NUM_WRITE_OUTSTANDING {8} \
    CONFIG.NUM_WRITE_THREADS {1} \
    CONFIG.PROTOCOL {AXI4} \
    CONFIG.READ_WRITE_MODE {READ_WRITE} \
    CONFIG.REG_AR {1} \
    CONFIG.REG_AW {1} \
    CONFIG.REG_B {1} \
    CONFIG.RUSER_BITS_PER_BYTE {0} \
    CONFIG.RUSER_WIDTH {0} \
    CONFIG.SUPPORTS_NARROW_BURST {1} \
    CONFIG.WUSER_BITS_PER_BYTE {0} \
    CONFIG.WUSER_WIDTH {0} \
  ] $rp_m_axi_register_slice


  # Create instance: rp_s_axi_register_slice, and set properties
  set rp_s_axi_register_slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 rp_s_axi_register_slice ]
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
    CONFIG.SUPPORTS_NARROW_BURST {1} \
    CONFIG.WUSER_BITS_PER_BYTE {0} \
  ] $rp_s_axi_register_slice


  # Create instance: s_axi_smc, and set properties
  set s_axi_smc [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 s_axi_smc ]
  set_property -dict [list \
    CONFIG.NUM_MI {2} \
    CONFIG.NUM_SI {1} \
  ] $s_axi_smc


  # Create instance: resetn_dfx_decoupler, and set properties
  set resetn_dfx_decoupler [ create_bd_cell -type ip -vlnv xilinx.com:ip:dfx_decoupler:1.0 resetn_dfx_decoupler ]
  set_property -dict [list \
    CONFIG.ALL_PARAMS {INTF {resetn {ID 0 VLNV xilinx.com:signal:reset_rtl:1.0 REGISTER 0 SIGNALS {RST {PRESENT 1 WIDTH 1}}}}} \
    CONFIG.GUI_INTERFACE_NAME {resetn} \
    CONFIG.GUI_SELECT_VLNV {xilinx.com:signal:reset_rtl:1.0} \
  ] $resetn_dfx_decoupler


  # Create instance: shutdown_static_slave, and set properties
  set shutdown_static_slave [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 shutdown_static_slave ]
  set_property -dict [list \
    CONFIG.DIN_FROM {2} \
    CONFIG.DIN_TO {2} \
    CONFIG.DIN_WIDTH {3} \
  ] $shutdown_static_slave


  # Create instance: shutdown_static_master, and set properties
  set shutdown_static_master [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 shutdown_static_master ]
  set_property -dict [list \
    CONFIG.DIN_FROM {1} \
    CONFIG.DIN_TO {1} \
    CONFIG.DIN_WIDTH {3} \
  ] $shutdown_static_master


  # Create instance: decouple_resetn, and set properties
  set decouple_resetn [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 decouple_resetn ]
  set_property CONFIG.DIN_WIDTH {3} $decouple_resetn


  # Create interface connections
  connect_bd_intf_net -intf_net S_AXI_1 [get_bd_intf_pins S_AXI] [get_bd_intf_pins s_axi_smc/S00_AXI]
  connect_bd_intf_net -intf_net dfx_axi_shutdown_static_master_M_AXI [get_bd_intf_pins rp_s_axi_register_slice/S_AXI] [get_bd_intf_pins dfx_axi_shutdown_static_master/M_AXI]
  connect_bd_intf_net -intf_net dfx_axi_shutdown_static_slave_M_AXI [get_bd_intf_pins M_AXI] [get_bd_intf_pins dfx_axi_shutdown_static_slave/M_AXI]
  connect_bd_intf_net -intf_net rp_M_AXI_1 [get_bd_intf_pins rp_M_AXI] [get_bd_intf_pins rp_m_axi_register_slice/S_AXI]
  connect_bd_intf_net -intf_net rp_m_axi_register_slice_M_AXI [get_bd_intf_pins dfx_axi_shutdown_static_slave/S_AXI] [get_bd_intf_pins rp_m_axi_register_slice/M_AXI]
  connect_bd_intf_net -intf_net rp_s_axi_register_slice_M_AXI [get_bd_intf_pins rp_S_AXI] [get_bd_intf_pins rp_s_axi_register_slice/M_AXI]
  connect_bd_intf_net -intf_net s_axi_smc_M00_AXI [get_bd_intf_pins s_axi_smc/M00_AXI] [get_bd_intf_pins decouple_shutdown_ctrl/S_AXI]
  connect_bd_intf_net -intf_net s_axi_smc_M01_AXI [get_bd_intf_pins dfx_axi_shutdown_static_master/S_AXI] [get_bd_intf_pins s_axi_smc/M01_AXI]

  # Create port connections
  connect_bd_net -net clk_1  [get_bd_pins clk] \
  [get_bd_pins decouple_shutdown_ctrl/s_axi_aclk] \
  [get_bd_pins dfx_axi_shutdown_static_master/clk] \
  [get_bd_pins dfx_axi_shutdown_static_slave/clk] \
  [get_bd_pins rp_m_axi_register_slice/aclk] \
  [get_bd_pins rp_s_axi_register_slice/aclk] \
  [get_bd_pins s_axi_smc/aclk]
  connect_bd_net -net decouple_resetn_Dout  [get_bd_pins decouple_resetn/Dout] \
  [get_bd_pins resetn_dfx_decoupler/decouple]
  connect_bd_net -net decouple_shutdown_ctrl_gpio_io_o  [get_bd_pins decouple_shutdown_ctrl/gpio_io_o] \
  [get_bd_pins decouple_resetn/Din] \
  [get_bd_pins shutdown_static_master/Din] \
  [get_bd_pins shutdown_static_slave/Din]
  connect_bd_net -net dfx_axi_shutdown_static_master_in_shutdown  [get_bd_pins dfx_axi_shutdown_static_master/in_shutdown] \
  [get_bd_pins xlconcat_status/In1]
  connect_bd_net -net dfx_axi_shutdown_static_master_shutdown_requested  [get_bd_pins dfx_axi_shutdown_static_master/shutdown_requested] \
  [get_bd_pins xlconcat_status/In0]
  connect_bd_net -net dfx_axi_shutdown_static_slave_in_shutdown  [get_bd_pins dfx_axi_shutdown_static_slave/in_shutdown] \
  [get_bd_pins xlconcat_status/In3]
  connect_bd_net -net dfx_axi_shutdown_static_slave_shutdown_requested  [get_bd_pins dfx_axi_shutdown_static_slave/shutdown_requested] \
  [get_bd_pins xlconcat_status/In2]
  connect_bd_net -net resetn_1  [get_bd_pins resetn] \
  [get_bd_pins decouple_shutdown_ctrl/s_axi_aresetn] \
  [get_bd_pins dfx_axi_shutdown_static_master/resetn] \
  [get_bd_pins dfx_axi_shutdown_static_slave/resetn] \
  [get_bd_pins s_axi_smc/aresetn] \
  [get_bd_pins resetn_dfx_decoupler/rp_resetn_RST]
  connect_bd_net -net resetn_dfx_decoupler_decouple_status  [get_bd_pins resetn_dfx_decoupler/decouple_status] \
  [get_bd_pins xlconcat_status/In4]
  connect_bd_net -net resetn_dfx_decoupler_s_resetn_RST  [get_bd_pins resetn_dfx_decoupler/s_resetn_RST] \
  [get_bd_pins rp_resetn] \
  [get_bd_pins rp_s_axi_register_slice/aresetn] \
  [get_bd_pins rp_m_axi_register_slice/aresetn]
  connect_bd_net -net shutdown_static_master_Dout  [get_bd_pins shutdown_static_master/Dout] \
  [get_bd_pins dfx_axi_shutdown_static_master/request_shutdown]
  connect_bd_net -net shutdown_static_slave_Dout  [get_bd_pins shutdown_static_slave/Dout] \
  [get_bd_pins dfx_axi_shutdown_static_slave/request_shutdown]
  connect_bd_net -net xlconcat_status_dout  [get_bd_pins xlconcat_status/dout] \
  [get_bd_pins decouple_shutdown_ctrl/gpio2_io_i]

  # Restore current instance
  current_bd_instance $oldCurInst
}


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

  set_property -dict [list \
  SRC_RM_MAP./dfx_partition.dfx_partition {dfx_partition_inst_0} \
] [get_bd_designs $design_name]


  # Create interface ports
  set DDR3_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR3_0 ]

  set diff_clock_rtl_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 diff_clock_rtl_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {100000000} \
   ] $diff_clock_rtl_0

  set gpio_rtl_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 gpio_rtl_0 ]

  set pcie_7x_mgt_rtl_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pcie_7x_mgt_rtl_0 ]


  # Create ports
  set reset_rtl_0 [ create_bd_port -dir I -type rst reset_rtl_0 ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $reset_rtl_0
  set clk50 [ create_bd_port -dir I -type clk -freq_hz 50000000 clk50 ]

  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0 ]
  set_property -dict [list \
    CONFIG.C_ALL_INPUTS_2 {1} \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_GPIO2_WIDTH {2} \
    CONFIG.C_GPIO_WIDTH {3} \
    CONFIG.C_IS_DUAL {1} \
  ] $axi_gpio_0


  # Create instance: axi_hwicap_0, and set properties
  set axi_hwicap_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_hwicap:3.0 axi_hwicap_0 ]
  set_property -dict [list \
    CONFIG.C_INCLUDE_STARTUP {1} \
    CONFIG.C_OPERATION {0} \
    CONFIG.C_SHARED_STARTUP {0} \
    CONFIG.C_WRITE_FIFO_DEPTH {1024} \
  ] $axi_hwicap_0


  # Create instance: dfx_partition, and set properties
  set dfx_partition [ create_bd_cell -type container -reference dfx_partition dfx_partition ]
  set_property -dict [list \
    CONFIG.ACTIVE_SIM_BD {dfx_partition.bd} \
    CONFIG.ACTIVE_SYNTH_BD {dfx_partition.bd} \
    CONFIG.ENABLE_DFX {true} \
    CONFIG.LIST_SIM_BD {dfx_partition.bd} \
    CONFIG.LIST_SYNTH_BD {dfx_partition.bd} \
    CONFIG.LOCK_PROPAGATE {true} \
  ] $dfx_partition


  set_property SELECTED_SIM_MODEL rtl  $dfx_partition
  set_property APERTURES {{0x0 256M}} [get_bd_intf_pins /dfx_partition/rp_M_AXI]
  set_property APERTURES {{0x4001_0000 64K}} [get_bd_intf_pins /dfx_partition/rp_S_AXI]

  # Create instance: dfx_socket
  create_hier_cell_dfx_socket [current_bd_instance .] dfx_socket

  # Create instance: mig_7series_0, and set properties
  set mig_7series_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mig_7series:4.2 mig_7series_0 ]

  # Generate the PRJ File for MIG
  set str_mig_folder [get_property IP_DIR [ get_ips [ get_property CONFIG.Component_Name $mig_7series_0 ] ] ]
  set str_mig_file_name mig_a.prj
  set str_mig_file_path ${str_mig_folder}/${str_mig_file_name}
  write_mig_file_xdma_ddr3_dfx_mig_7series_0_0 $str_mig_file_path

  set_property -dict [list \
    CONFIG.BOARD_MIG_PARAM {Custom} \
    CONFIG.MIG_DONT_TOUCH_PARAM {Custom} \
    CONFIG.RESET_BOARD_INTERFACE {Custom} \
    CONFIG.XML_INPUT_FILE {mig_a.prj} \
  ] $mig_7series_0


  # Create instance: rst_mig_7series_0_100M, and set properties
  set rst_mig_7series_0_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_mig_7series_0_100M ]

  # Create instance: util_ds_buf, and set properties
  set util_ds_buf [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.2 util_ds_buf ]
  set_property CONFIG.C_BUF_TYPE {IBUFDSGTE} $util_ds_buf


  # Create instance: xdma_0, and set properties
  set xdma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xdma:4.1 xdma_0 ]
  set_property -dict [list \
    CONFIG.PF0_DEVICE_ID_mqdma {9024} \
    CONFIG.PF0_SRIOV_VF_DEVICE_ID {A034} \
    CONFIG.PF2_DEVICE_ID_mqdma {9224} \
    CONFIG.PF3_DEVICE_ID_mqdma {9324} \
    CONFIG.axi_data_width {128_bit} \
    CONFIG.axilite_master_en {true} \
    CONFIG.axisten_freq {125} \
    CONFIG.cfg_mgmt_if {false} \
    CONFIG.pciebar2axibar_axil_master {0x40000000} \
    CONFIG.pf0_Use_Class_Code_Lookup_Assistant {true} \
    CONFIG.pf0_base_class_menu {Memory_controller} \
    CONFIG.pf0_device_id {7024} \
    CONFIG.pf0_interrupt_pin {NONE} \
    CONFIG.pf0_msix_cap_pba_bir {BAR_3:2} \
    CONFIG.pf0_msix_cap_pba_offset {00008FE0} \
    CONFIG.pf0_msix_cap_table_bir {BAR_3:2} \
    CONFIG.pf0_msix_cap_table_offset {00008000} \
    CONFIG.pf0_msix_cap_table_size {01F} \
    CONFIG.pf0_msix_enabled {true} \
    CONFIG.pf0_sub_class_interface_menu {Other_memory_controller} \
    CONFIG.pl_link_cap_max_link_speed {5.0_GT/s} \
    CONFIG.pl_link_cap_max_link_width {X4} \
    CONFIG.plltype {QPLL1} \
    CONFIG.runbit_fix {false} \
    CONFIG.xdma_axi_intf_mm {AXI_Memory_Mapped} \
    CONFIG.xdma_axilite_slave {false} \
    CONFIG.xdma_pcie_64bit_en {true} \
    CONFIG.xdma_rnum_chnl {2} \
    CONFIG.xdma_wnum_chnl {2} \
  ] $xdma_0


  # Create instance: clk200_clk_wiz, and set properties
  set clk200_clk_wiz [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk200_clk_wiz ]
  set_property -dict [list \
    CONFIG.CLKOUT1_JITTER {142.107} \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {200.000} \
    CONFIG.MMCM_CLKOUT0_DIVIDE_F {5.000} \
    CONFIG.USE_RESET {false} \
  ] $clk200_clk_wiz


  # Create instance: xdma_axi_smc, and set properties
  set xdma_axi_smc [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 xdma_axi_smc ]
  set_property CONFIG.NUM_CLKS {2} $xdma_axi_smc


  # Create instance: xdma_axi_lite_smc, and set properties
  set xdma_axi_lite_smc [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 xdma_axi_lite_smc ]
  set_property -dict [list \
    CONFIG.NUM_MI {3} \
    CONFIG.NUM_SI {1} \
  ] $xdma_axi_lite_smc


  # Create instance: mig7_status_concat, and set properties
  set mig7_status_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 mig7_status_concat ]

  # Create interface connections
  connect_bd_intf_net -intf_net axi_gpio_0_GPIO [get_bd_intf_ports gpio_rtl_0] [get_bd_intf_pins axi_gpio_0/GPIO]
  connect_bd_intf_net -intf_net dfx_partition_rp_M_AXI [get_bd_intf_pins dfx_partition/rp_M_AXI] [get_bd_intf_pins dfx_socket/rp_M_AXI]
  connect_bd_intf_net -intf_net dfx_socket_M_AXI [get_bd_intf_pins dfx_socket/M_AXI] [get_bd_intf_pins xdma_axi_smc/S01_AXI]
  connect_bd_intf_net -intf_net diff_clock_rtl_0_1 [get_bd_intf_ports diff_clock_rtl_0] [get_bd_intf_pins util_ds_buf/CLK_IN_D]
  connect_bd_intf_net -intf_net mig_7series_0_DDR3 [get_bd_intf_ports DDR3_0] [get_bd_intf_pins mig_7series_0/DDR3]
  connect_bd_intf_net -intf_net rp_S_AXI_1 [get_bd_intf_pins dfx_partition/rp_S_AXI] [get_bd_intf_pins dfx_socket/rp_S_AXI]
  connect_bd_intf_net -intf_net xdma_0_M_AXI [get_bd_intf_pins xdma_0/M_AXI] [get_bd_intf_pins xdma_axi_smc/S00_AXI]
  connect_bd_intf_net -intf_net xdma_0_M_AXI_LITE [get_bd_intf_pins xdma_0/M_AXI_LITE] [get_bd_intf_pins xdma_axi_lite_smc/S00_AXI]
  connect_bd_intf_net -intf_net xdma_0_pcie_mgt [get_bd_intf_ports pcie_7x_mgt_rtl_0] [get_bd_intf_pins xdma_0/pcie_mgt]
  connect_bd_intf_net -intf_net xdma_axi_lite_smc_M00_AXI [get_bd_intf_pins xdma_axi_lite_smc/M00_AXI] [get_bd_intf_pins axi_gpio_0/S_AXI]
  connect_bd_intf_net -intf_net xdma_axi_lite_smc_M01_AXI [get_bd_intf_pins xdma_axi_lite_smc/M01_AXI] [get_bd_intf_pins dfx_socket/S_AXI]
  connect_bd_intf_net -intf_net xdma_axi_lite_smc_M02_AXI [get_bd_intf_pins axi_hwicap_0/S_AXI_LITE] [get_bd_intf_pins xdma_axi_lite_smc/M02_AXI]
  connect_bd_intf_net -intf_net xdma_axi_smc_M00_AXI [get_bd_intf_pins xdma_axi_smc/M00_AXI] [get_bd_intf_pins mig_7series_0/S_AXI]

  # Create port connections
  connect_bd_net -net clk200_clk_wiz_clk_out1  [get_bd_pins clk200_clk_wiz/clk_out1] \
  [get_bd_pins mig_7series_0/clk_ref_i] \
  [get_bd_pins mig_7series_0/sys_clk_i]
  connect_bd_net -net clk50_buf_IBUF_OUT  [get_bd_ports clk50] \
  [get_bd_pins axi_hwicap_0/icap_clk] \
  [get_bd_pins clk200_clk_wiz/clk_in1]
  connect_bd_net -net mig7_status_concat_dout  [get_bd_pins mig7_status_concat/dout] \
  [get_bd_pins axi_gpio_0/gpio2_io_i]
  connect_bd_net -net mig_7series_0_init_calib_complete  [get_bd_pins mig_7series_0/init_calib_complete] \
  [get_bd_pins mig7_status_concat/In1]
  connect_bd_net -net mig_7series_0_mmcm_locked  [get_bd_pins mig_7series_0/mmcm_locked] \
  [get_bd_pins rst_mig_7series_0_100M/dcm_locked] \
  [get_bd_pins mig7_status_concat/In0]
  connect_bd_net -net mig_7series_0_ui_clk  [get_bd_pins mig_7series_0/ui_clk] \
  [get_bd_pins rst_mig_7series_0_100M/slowest_sync_clk] \
  [get_bd_pins xdma_axi_smc/aclk1]
  connect_bd_net -net mig_7series_0_ui_clk_sync_rst  [get_bd_pins mig_7series_0/ui_clk_sync_rst] \
  [get_bd_pins rst_mig_7series_0_100M/ext_reset_in]
  connect_bd_net -net reset_rtl_0_1  [get_bd_ports reset_rtl_0] \
  [get_bd_pins xdma_0/sys_rst_n] \
  [get_bd_pins mig_7series_0/sys_rst]
  connect_bd_net -net rp_resetn_1  [get_bd_pins dfx_socket/rp_resetn] \
  [get_bd_pins dfx_partition/rp_resetn]
  connect_bd_net -net rst_mig_7series_0_100M_peripheral_aresetn  [get_bd_pins rst_mig_7series_0_100M/peripheral_aresetn] \
  [get_bd_pins mig_7series_0/aresetn]
  connect_bd_net -net util_ds_buf_IBUF_OUT  [get_bd_pins util_ds_buf/IBUF_OUT] \
  [get_bd_pins xdma_0/sys_clk]
  connect_bd_net -net xdma_0_axi_aclk  [get_bd_pins xdma_0/axi_aclk] \
  [get_bd_pins dfx_socket/clk] \
  [get_bd_pins axi_gpio_0/s_axi_aclk] \
  [get_bd_pins axi_hwicap_0/s_axi_aclk] \
  [get_bd_pins xdma_axi_lite_smc/aclk] \
  [get_bd_pins xdma_axi_smc/aclk] \
  [get_bd_pins dfx_partition/clk]
  connect_bd_net -net xdma_0_axi_aresetn  [get_bd_pins xdma_0/axi_aresetn] \
  [get_bd_pins dfx_socket/resetn] \
  [get_bd_pins axi_gpio_0/s_axi_aresetn] \
  [get_bd_pins axi_hwicap_0/s_axi_aresetn] \
  [get_bd_pins xdma_axi_lite_smc/aresetn] \
  [get_bd_pins xdma_axi_smc/aresetn]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces dfx_partition/axi_datamover_0/Data_MM2S] [get_bd_addr_segs mig_7series_0/memmap/memaddr] -force
  assign_bd_address -offset 0x00000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces dfx_partition/axi_datamover_1/Data_S2MM] [get_bd_addr_segs mig_7series_0/memmap/memaddr] -force
  assign_bd_address -offset 0x00000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs mig_7series_0/memmap/memaddr] -force
  assign_bd_address -offset 0x40010000 -range 0x00008000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI_LITE] [get_bd_addr_segs dfx_partition/axi_datamover_mm2s_c_0/s_axi/reg0] -force
  assign_bd_address -offset 0x40018000 -range 0x00008000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI_LITE] [get_bd_addr_segs dfx_partition/axi_datamover_s2mm_c_0/s_axi/reg0] -force
  assign_bd_address -offset 0x40000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI_LITE] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x40002000 -range 0x00001000 -with_name SEG_axi_gpio_0_Reg_2 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI_LITE] [get_bd_addr_segs dfx_socket/decouple_shutdown_ctrl/S_AXI/Reg] -force
  assign_bd_address -offset 0x40001000 -range 0x00001000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI_LITE] [get_bd_addr_segs axi_hwicap_0/S_AXI_LITE/Reg] -force


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


