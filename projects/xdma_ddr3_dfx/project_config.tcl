#
# Project specific configurations
#

set proj_name xdma_ddr3_dfx
set part_name xc7a200tfbg484-2
set block_design block_design_top.tcl

set constraints {
    constraints/pins.xdc \
    constraints/pcie_lanes_early.xdc \
    constraints/pblock.xdc \
}

set partition_bdc dfx_block_designs/default.tcl
set partition_cell xdma_ddr3_dfx_i/dfx_partition
set partition_inst dfx_partition_inst_0

set hdl_sources {
    ../../hdl/common/up_axi.v \
    ../../hdl/common/datamover_ctrl.v \
    ../../hdl/datamover_mm2s_ctrl/axi_datamover_mm2s_ctrl.v \
    ../../hdl/datamover_s2mm_ctrl/axi_datamover_s2mm_ctrl.v \
}
