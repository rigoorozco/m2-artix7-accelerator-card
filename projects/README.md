# Project Status

I'll try to summarize the state of the projects briefly.

## xdma

This is the most barebones to test.

| | Feature | Status |
| -------- | ------- | ------- |
| ✅ | XDMA/PCIe | Working |
| ✅ | Block RAM | Assumed to be working. Testable using dma_from_device and dma_to_device. |

## xdma_ddr3

This project steps it up a notch adding the MIG 7 core for DDR3.

| | Feature | Status |
| -------- | ------- | ------- |
| ✅ | XDMA/PCIe | Working |
| ✅ | Block RAM | Assumed to be working. Testable using dma_from_device and dma_to_device.  |
| ⏳ | MIG/DDR3 | Not working. Need to bring in fixes from xdma_ddr3_dfx. |

## xdma_ddr3_dfx

This is the most complex of the three projects and has more bells and whistles.

| | Feature | Status |
| -------- | ------- | ------- |
| ✅ | XDMA/PCIe | Working. |
| ✅ | MIG/DDR3 | Working. Tested using dma_from_device and dma_to_device. |
| ✅ | HWICAP | Working. |
| 🛠️ | Reconfig Partition | My plan here is to write some modules to control the DataMovers to copy to/from DDR. Then add some simple multiply/add operations to demostrate some sort of processing. Currently the DataMovers are just hanging out. |

#### Further Details on HWICAP

I've tested various methods of generating binary bitstreams that are formatted in a way that the ICAP IP likes.

This can be solved by shuffling the bytes around in the HWICAP software or generating a bitstream in Vivado that will make writing the bistream easier from software. I've gone with the latter.

Partial reconfiguration seems to be working! Can be tested using `app/hwicap_write_bitstream` and following steps in:\
`app/scripts/partial-reconfig/load-partial-bitstream.sh`
