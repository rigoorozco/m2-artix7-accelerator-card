#bit compress spix4 speed up
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE Yes [current_design]

# 50 MHz clock
set_property -dict {PACKAGE_PIN Y18 IOSTANDARD LVCMOS33} [get_ports clk50]
create_clock -period 20 [get_ports clk50]

#led*3 outpuy
set_property -dict {PACKAGE_PIN AB21 IOSTANDARD LVCMOS33} [get_ports gpio_rtl_0_tri_o[2]]
set_property -dict {PACKAGE_PIN AA20 IOSTANDARD LVCMOS33} [get_ports gpio_rtl_0_tri_o[1]]
set_property -dict {PACKAGE_PIN AB20 IOSTANDARD LVCMOS33} [get_ports gpio_rtl_0_tri_o[0]]

# PCIe lane 0
set_property PACKAGE_PIN A8 [get_ports {pcie_7x_mgt_rtl_0_rxn[0]}]
set_property PACKAGE_PIN B8 [get_ports {pcie_7x_mgt_rtl_0_rxp[0]}]
set_property PACKAGE_PIN A4 [get_ports {pcie_7x_mgt_rtl_0_txn[0]}]
set_property PACKAGE_PIN B4 [get_ports {pcie_7x_mgt_rtl_0_txp[0]}]

# PCIe lane 1
set_property PACKAGE_PIN C11 [get_ports {pcie_7x_mgt_rtl_0_rxn[1]}]
set_property PACKAGE_PIN D11 [get_ports {pcie_7x_mgt_rtl_0_rxp[1]}]
set_property PACKAGE_PIN C5 [get_ports {pcie_7x_mgt_rtl_0_txn[1]}]
set_property PACKAGE_PIN D5 [get_ports {pcie_7x_mgt_rtl_0_txp[1]}]

# PCIe lane 2
set_property PACKAGE_PIN A10 [get_ports {pcie_7x_mgt_rtl_0_rxn[2]}]
set_property PACKAGE_PIN B10 [get_ports {pcie_7x_mgt_rtl_0_rxp[2]}]
set_property PACKAGE_PIN A6 [get_ports {pcie_7x_mgt_rtl_0_txn[2]}]
set_property PACKAGE_PIN B6 [get_ports {pcie_7x_mgt_rtl_0_txp[2]}]

# PCIe lane 3
set_property PACKAGE_PIN C9 [get_ports {pcie_7x_mgt_rtl_0_rxn[3]}]
set_property PACKAGE_PIN D9 [get_ports {pcie_7x_mgt_rtl_0_rxp[3]}]
set_property PACKAGE_PIN D7 [get_ports {pcie_7x_mgt_rtl_0_txp[3]}]
set_property PACKAGE_PIN C7 [get_ports {pcie_7x_mgt_rtl_0_txn[3]}]

# PCIe clock input
set_property PACKAGE_PIN F10 [get_ports {diff_clock_rtl_0_clk_p[0]}]
set_property PACKAGE_PIN E10 [get_ports {diff_clock_rtl_0_clk_n[0]}]

# PCIe reset_n input
set_property -dict {PACKAGE_PIN K22 IOSTANDARD LVCMOS33 PULLUP TRUE} [get_ports reset_rtl_0]
