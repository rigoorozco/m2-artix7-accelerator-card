# M2 Artix FPGA Accelerator Card
![image info](docs/XC7A200T-DDR.png)

WARNING: this repository is a major WIP. Proceed with  caution.

This repository focuses on the very cheap M.2 FPGA accelator card found on AliExpress:
https://es.aliexpress.com/item/1005006844453359.html

Namely, the version with DDR: XC7A200T-ddr

I've downloaded the documetation from pan.baidu and translated it using Google Translate. The user guide and schematic can be found in the `docs` directory.

## Build Options
With this repository you can build the following projects:
- xdma
- xdma_ddr3
- xdma_ddr3_dfx

### xdma:
This project is one of the two examples explained in the user guide. In my opinion the easier to script using the block design. This project allows a block RAM to be read via PCIe via the XDMA IP core.

The other example (which uses RIFFA) is not found in this repo.

###  xdma_ddr3:
This project is a hybrid between the xdma and an example provided that implements DDR3 using the Xilinx MIG IP core (also not found here).

From said project I copied the DDR settings and exported the pin constraints (found in `docs/mig_ddr3_pinout.ucf`).

This project allows the DDR3 chip to be read via PCIe similar to the block RAM.

### xdma_ddr4_dfx:
This project adds on the previous but adds a Partial Reconfigurable Partition.

This Reconfigurable Partition takes up the majority of the FPGA with most of the previously mentioned stuff in the static region: XDMA, MIG, AXI Interconnect, etc.

![image info](docs/Reconfigurable-Partition.png)

The Reconfigurable Partition is implemented using a block design which is has its pros and cons.

There is a top level block design that is essentially top (once a Verilog wrapper is generated for it):
`projects/xdma_ddr3_dfx/xdma_ddr3_dfx_bd.tcl` .

This BD instantiates a second BD (I'm sorry for the bad names):
`projects/xdma_ddr3_dfx/xdma_ddr3_dfx_bdc.tcl`

The magic happens in the way the second BD is instantiated. It uses what Xilinx calls a Block Design container. You can read about it here:
https://docs.amd.com/r/en-US/ug994-vivado-ip-subsystems/Introduction-to-Block-Design-Containers

This allows you to fix the address ranges and the interfaces between the static and reconfigurable regions.

The contents of the Reconfigurable Partition are somewhat unfinished here. Right now I have a block RAM instantiated that I plan on using to test read/writes. There are also some Xilinx DataMovers I threw in there to take up space.

The Reconfigurable Partition has a Slave AXI Bus and a Master AXI Bus. The idea is that the Slave AXI Bus is used for control (reading and writing registers) while the Master AXI Bus for reading and writing to the DDR3.

I've also implemented a hierchical block to group together the AXI Shutdown managers and DFX couplers.

## Building

### xdma and  xdma_ddr3

For the the first two projects, I'm still using Vivado 2021.1. Running the following will get you a bitstream:
```bash
source /opt/Xilinx/Vivado/2021.1/settings64.sh
cd project/xdma_ddr3_dfx
make
```
### xdma_ddr3_dfx

For the last project, I'm using Vivado 2024.2 (it plays better with DFX):

#### Source Vivado:
```bash
source /opt/Xilinx/Vivado/2021.1/settings64.sh
```

#### Build Static and Reconfigurable Regions:
```bash
make
```
This command will build the entire thing and provide you with the following:
- Top-level bitstream (with RP)
- Partial bitstream (only RP)
- Routed checkpoint for the top-level
- Sythesis checkpoint for RP
- Timing and power reports

#### Synthesizing the Reconfigurable Region:
```bash
make synth_partitions
```
This command could you some work TBH. Currently it re-does the first half of the previous command stopping with the sythesis checkpoint.

What this does is sythesize the whole thing and the just provide the checkpoint for the sythesized RP module. This is to ensure that all the connections with the Static Region are preserved. I tried synthesizing the RP module on its own, but I always get errors getting the AXI Buses to match up.

In theory, if you don't modify the top-level and keep the routed checkpoint for the top-level you shouldn't have any issues with RP being compatible with the top-level.

To run this command you must have first re-exported the block design container to TCL. To do this run the following in Vivad (make sure to only have the RP block design open):
```tcl
validate_design
write_bd_tcl -force -make_local -exclude_layout ../../xdma_ddr3_dfx_bdc.tcl
```

Or, if you want to use the GUI, just modify the block design and synthesize. Then just create a sythesis checkpoint with something like:
```tcl
write_checkpoint -force -cell ${module} ${build_directory}/reconfigurable/${inst}_synth.dcp
```

The outputs of this step will be used for the next command.

#### Implementing/Routing the Reconfigurable Region
```bash
make impl_partitions
```
This command takes the the routed Static checkpoint and the synthesized Reconfigurable checkpoint and builds the partial bitstream.

It does so by taking the routed top-level checkpoint and replacing the Reconfigurable Partion with a grey-box. The grey-box is then replaced with checkpoint from the previous step. You can take a peek at the following script for more details: \
`scripts/tcl/build_partitions.tcl`

Once done, it runs check against the originally created checkpoint for compatibity using `pr_verify` and writing a bitstream if successful.

The checkpoint being checked will be updated if you build the whole top-level again or run `make` so be careful!

## Other Notes

### Non-standard PCIe Lanes
The board was designed using a reversed lane order, oposite of what Xilinx recommends. This is talked about on Section 2.5 (page 30) of the user guide. I'm still working out how to script this. So doing it manually isn't necessary. This applies to all three projects.

I've also noticed that the XDMA IP core also have a reverse lane option you can check. I want to test this too.