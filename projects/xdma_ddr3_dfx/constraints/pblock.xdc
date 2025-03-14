create_pblock pblock_rm
add_cells_to_pblock [get_pblocks pblock_rm] [get_cells -quiet [list xdma_ddr3_dfx_i/dfx_partition]]
resize_pblock [get_pblocks pblock_rm] -add {SLICE_X82Y1:SLICE_X163Y249 SLICE_X62Y50:SLICE_X81Y199}
resize_pblock [get_pblocks pblock_rm] -add {DSP48_X7Y2:DSP48_X8Y99 DSP48_X3Y20:DSP48_X6Y79}
resize_pblock [get_pblocks pblock_rm] -add {RAMB18_X7Y2:RAMB18_X8Y99 RAMB18_X4Y20:RAMB18_X6Y79}
resize_pblock [get_pblocks pblock_rm] -add {RAMB36_X7Y1:RAMB36_X8Y49 RAMB36_X4Y10:RAMB36_X6Y39}
