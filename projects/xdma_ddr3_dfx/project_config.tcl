#
# Project specific configurations
#

set proj_name xdma_ddr3_dfx
set part_name xc7a200tfbg484-2

set block_designs {
    xdma_ddr3_dfx_bdc.tcl \
    xdma_ddr3_dfx_bd.tcl \
}

set constraints {
    xdma_ddr3_dfx_pins.xdc \
    xdma_ddr3_dfx_early.xdc \
    xdma_ddr3_dfx_partitions.xdc \
}

set partition_definitions {
    xdma_ddr3_dfx_i/dfx_partition:dfx_partition_inst_0
}
