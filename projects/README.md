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
| 🛠️ | HWICAP | In progress. |
| ⛔ | Reconfig Partition | My plan here is to write some modules to control the DataMovers to copy to/from DDR. Then add some simple multiply/add operations to demostrate some sort of processing. Currently the DataMovers are just hanging out. |

#### Further Details on HWICAP

I've tested various methods of generating binary bitstreams that are formatted in a way that the ICAP IP likes.

This can be solved by shuffling the bytes around in the HWICAP software or generating the bitstream in Vivado that will making writing the bistream easier. I've gone with the latter.

I think partial reconfiguration is working. However, I'm running into issues integrating it with the AXI Shutdown Manager.

Doing the following gets me into an unrecoverable state:
1. Disconnect/shutdown reconfigurable region 
2. Reload partial bitstream (is successful)
3. Re-connect reconfigurable region (nothing bad yet)
4. Disconnect/shutdown reconfigurable region (hell breaks loose)

Between steps 3 and 4 I can read/write to any register just fine. However, after step 4 I'm unable to read/write anything and have to reprogram the FPGA.

A couple strange things:
- If I don't reload the partial bitstream and just disconnect and re-connect. No problems occur.
- If I reload partial bitstreams over and over again without disconnecting no problems occur either.

It seems like disconncting the reconfigurable region after its been re-programmed is causing issues.