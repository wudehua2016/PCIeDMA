
set_property PACKAGE_PIN K8 [get_ports {phy_rst_n_0[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {phy_rst_n_0[0]}]
#
#create_clock -period 10.000 -name sys_clk [get_ports sys_clk_p]
###############-----ETH1----#################
set_property PACKAGE_PIN J6 [get_ports PHYA_mdio_mdio_io]
set_property PACKAGE_PIN J8 [get_ports PHYA_mdio_mdc]

set_property IOSTANDARD LVCMOS33 [get_ports PHYA_mdio_mdio_io]
set_property IOSTANDARD LVCMOS33 [get_ports PHYA_mdio_mdc]

set_property PACKAGE_PIN K4 [get_ports PHYA_rgmii_rxc]
set_property PACKAGE_PIN P1 [get_ports PHYA_rgmii_rx_ctl]
### -----------------RX------------------###
set_property PACKAGE_PIN N1 [get_ports {PHYA_rgmii_rd[0]}]
set_property PACKAGE_PIN R2 [get_ports {PHYA_rgmii_rd[1]}]
set_property PACKAGE_PIN K3 [get_ports {PHYA_rgmii_rd[2]}]
set_property PACKAGE_PIN R3 [get_ports {PHYA_rgmii_rd[3]}]
### -----------------TX------------------###
set_property PACKAGE_PIN L7 [get_ports PHYA_rgmii_txc]
set_property PACKAGE_PIN L2 [get_ports PHYA_rgmii_tx_ctl]
set_property PACKAGE_PIN L1 [get_ports {PHYA_rgmii_td[0]}]
set_property PACKAGE_PIN J5 [get_ports {PHYA_rgmii_td[1]}]
set_property PACKAGE_PIN K5 [get_ports {PHYA_rgmii_td[2]}]
set_property PACKAGE_PIN J7 [get_ports {PHYA_rgmii_td[3]}]

set_property SLEW FAST [get_ports PHYA_rgmii_txc]
set_property SLEW FAST [get_ports PHYA_rgmii_tx_ctl]
set_property SLEW FAST [get_ports {PHYA_rgmii_td[*]}]

set_property IOSTANDARD LVCMOS33 [get_ports PHYA_rgmii_rxc]
set_property IOSTANDARD LVCMOS33 [get_ports PHYA_rgmii_rx_ctl]
set_property IOSTANDARD LVCMOS33 [get_ports {PHYA_rgmii_rd[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports PHYA_rgmii_txc]
set_property IOSTANDARD LVCMOS33 [get_ports PHYA_rgmii_tx_ctl]
set_property IOSTANDARD LVCMOS33 [get_ports {PHYA_rgmii_td[*]}]



set_property PACKAGE_PIN T2 [get_ports HDMI_TX_CLK_P]
set_property PACKAGE_PIN U2 [get_ports {HDMI_TX_P[2]}]
set_property PACKAGE_PIN M2 [get_ports {HDMI_TX_P[1]}]
set_property PACKAGE_PIN L6 [get_ports {HDMI_TX_P[0]}]

set_property IOSTANDARD TMDS_33 [get_ports {HDMI_TX_P[*]}]
set_property IOSTANDARD TMDS_33 [get_ports HDMI_TX_CLK_P]

set_property BITSTREAM.GENERAL.COMPRESS true [current_design]

# set_property IOSTANDARD LVCMOS18 [get_ports sys_rst_n]
#set_property IOSTANDARD LVCMOS33 [get_ports led_0]
#set_property IOSTANDARD LVCMOS33 [get_ports led_2]
#set_property IOSTANDARD LVCMOS33 [get_ports led_3]

#set_property PACKAGE_PIN V19 [get_ports led_3]
#set_property PACKAGE_PIN U19 [get_ports led_2]
#set_property PACKAGE_PIN T16 [get_ports led_0]

#set_property PACKAGE_PIN U5 [get_ports sys_clk_p]
#set_property PACKAGE_PIN V5 [get_ports sys_clk_n]


#######################PCIE#############################
set_property PACKAGE_PIN AB22 [get_ports sys_rst_n]
set_property IOSTANDARD LVCMOS18 [get_ports sys_rst_n]


# PCI Express reference clock 100MHz
create_clock -period 10.000 -name pcie_sys_clk -waveform {0.000 5.000} [get_ports sys_clk_p]
set_property PACKAGE_PIN U9 [get_ports sys_clk_p]
set_property PACKAGE_PIN V9 [get_ports sys_clk_n]
# MGT locations
#
#
set_property LOC GTPE2_CHANNEL_X0Y0 [get_cells {pcie_7x_0_support_i/pcie_7x_0_i/pcie_7x_0/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[0].gt_wrapper_i/gtp_channel.gtpe2_channel_i}]
set_property LOC GTPE2_CHANNEL_X0Y0 [get_cells {pcie_7x_0_support_i/pcie_7x_0_i/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[0].gt_wrapper_i/gtp_channel.gtpe2_channel_i}]
set_property PACKAGE_PIN AA7 [get_ports {pci_exp_rxp[0]}]
set_property PACKAGE_PIN AA3 [get_ports {pci_exp_txp[0]}]
#set_property LOC GTPE2_CHANNEL_X0Y1 [get_cells {pcie_7x_0_support_i/pcie_7x_0_i/pcie_7x_0/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[1].gt_wrapper_i/gtp_channel.gtpe2_channel_i}]
#set_property PACKAGE_PIN W8 [get_ports {pci_exp_rxp[1]}]
#set_property LOC GTPE2_CHANNEL_X0Y1 [get_cells {pcie_7x_0_support_i/pcie_7x_0_i/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[1].gt_wrapper_i/gtp_channel.gtpe2_channel_i}]
#set_property PACKAGE_PIN W4 [get_ports {pci_exp_txp[1]}]





create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list zynq_soc_i/system_i/clk_wiz_0/inst/clk_out2]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 64 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[0]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[1]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[2]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[3]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[4]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[5]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[6]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[7]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[8]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[9]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[10]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[11]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[12]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[13]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[14]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[15]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[16]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[17]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[18]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[19]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[20]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[21]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[22]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[23]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[24]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[25]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[26]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[27]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[28]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[29]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[30]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[31]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[32]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[33]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[34]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[35]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[36]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[37]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[38]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[39]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[40]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[41]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[42]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[43]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[44]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[45]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[46]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[47]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[48]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[49]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[50]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[51]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[52]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[53]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[54]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[55]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[56]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[57]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[58]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[59]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[60]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[61]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[62]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARADDR[63]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 8 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TKEEP[0]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TKEEP[1]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TKEEP[2]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TKEEP[3]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TKEEP[4]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TKEEP[5]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TKEEP[6]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TKEEP[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 6 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {pl_ltssm_state[0]} {pl_ltssm_state[1]} {pl_ltssm_state[2]} {pl_ltssm_state[3]} {pl_ltssm_state[4]} {pl_ltssm_state[5]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 64 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[0]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[1]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[2]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[3]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[4]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[5]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[6]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[7]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[8]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[9]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[10]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[11]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[12]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[13]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[14]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[15]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[16]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[17]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[18]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[19]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[20]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[21]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[22]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[23]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[24]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[25]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[26]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[27]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[28]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[29]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[30]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[31]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[32]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[33]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[34]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[35]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[36]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[37]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[38]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[39]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[40]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[41]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[42]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[43]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[44]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[45]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[46]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[47]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[48]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[49]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[50]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[51]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[52]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[53]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[54]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[55]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[56]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[57]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[58]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[59]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[60]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[61]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[62]} {zynq_soc_i/system_i/S_AXIS_0_1_TDATA[63]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 8 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {zynq_soc_i/system_i/S_AXIS_0_1_TKEEP[0]} {zynq_soc_i/system_i/S_AXIS_0_1_TKEEP[1]} {zynq_soc_i/system_i/S_AXIS_0_1_TKEEP[2]} {zynq_soc_i/system_i/S_AXIS_0_1_TKEEP[3]} {zynq_soc_i/system_i/S_AXIS_0_1_TKEEP[4]} {zynq_soc_i/system_i/S_AXIS_0_1_TKEEP[5]} {zynq_soc_i/system_i/S_AXIS_0_1_TKEEP[6]} {zynq_soc_i/system_i/S_AXIS_0_1_TKEEP[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 32 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WDATA[0]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WDATA[1]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WDATA[2]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WDATA[3]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WDATA[4]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WDATA[5]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WDATA[6]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WDATA[7]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WDATA[8]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WDATA[9]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WDATA[10]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WDATA[11]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WDATA[12]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WDATA[13]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WDATA[14]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WDATA[15]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WDATA[16]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WDATA[17]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WDATA[18]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WDATA[19]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WDATA[20]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WDATA[21]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WDATA[22]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WDATA[23]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WDATA[24]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WDATA[25]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WDATA[26]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WDATA[27]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WDATA[28]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WDATA[29]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WDATA[30]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WDATA[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 2 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RRESP[0]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RRESP[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 32 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RDATA[0]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RDATA[1]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RDATA[2]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RDATA[3]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RDATA[4]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RDATA[5]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RDATA[6]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RDATA[7]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RDATA[8]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RDATA[9]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RDATA[10]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RDATA[11]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RDATA[12]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RDATA[13]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RDATA[14]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RDATA[15]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RDATA[16]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RDATA[17]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RDATA[18]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RDATA[19]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RDATA[20]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RDATA[21]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RDATA[22]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RDATA[23]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RDATA[24]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RDATA[25]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RDATA[26]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RDATA[27]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RDATA[28]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RDATA[29]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RDATA[30]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RDATA[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 2 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_BRESP[0]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_BRESP[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 64 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[0]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[1]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[2]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[3]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[4]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[5]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[6]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[7]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[8]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[9]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[10]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[11]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[12]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[13]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[14]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[15]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[16]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[17]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[18]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[19]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[20]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[21]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[22]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[23]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[24]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[25]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[26]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[27]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[28]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[29]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[30]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[31]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[32]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[33]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[34]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[35]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[36]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[37]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[38]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[39]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[40]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[41]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[42]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[43]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[44]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[45]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[46]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[47]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[48]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[49]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[50]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[51]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[52]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[53]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[54]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[55]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[56]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[57]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[58]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[59]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[60]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[61]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[62]} {zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWADDR[63]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 64 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[0]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[1]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[2]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[3]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[4]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[5]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[6]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[7]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[8]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[9]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[10]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[11]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[12]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[13]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[14]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[15]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[16]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[17]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[18]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[19]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[20]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[21]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[22]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[23]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[24]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[25]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[26]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[27]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[28]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[29]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[30]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[31]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[32]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[33]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[34]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[35]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[36]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[37]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[38]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[39]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[40]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[41]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[42]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[43]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[44]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[45]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[46]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[47]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[48]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[49]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[50]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[51]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[52]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[53]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[54]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[55]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[56]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[57]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[58]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[59]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[60]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[61]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[62]} {zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TDATA[63]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARREADY]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 1 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_ARVALID]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 1 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWREADY]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 1 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_AWVALID]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 1 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_BREADY]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 1 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_BVALID]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 1 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RREADY]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 1 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_RVALID]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 1 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WREADY]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 1 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list zynq_soc_i/system_i/axi_interconnect_0_M01_AXI_WVALID]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 1 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TLAST]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 1 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TREADY]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 1 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list zynq_soc_i/system_i/axis_data_fifo_0_M_AXIS_TVALID]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
set_property port_width 1 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list zynq_soc_i/system_i/S_AXIS_0_1_TLAST]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
set_property port_width 1 [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list zynq_soc_i/system_i/S_AXIS_0_1_TREADY]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe26]
set_property port_width 1 [get_debug_ports u_ila_0/probe26]
connect_debug_port u_ila_0/probe26 [get_nets [list zynq_soc_i/system_i/S_AXIS_0_1_TVALID]]
create_debug_core u_ila_1 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_1]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_1]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_1]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_1]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_1]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_1]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_1]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_1]
set_property port_width 1 [get_debug_ports u_ila_1/clk]
connect_debug_port u_ila_1/clk [get_nets [list pcie_7x_0_support_i/pipe_clock_i/CLK_USERCLK2]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe0]
set_property port_width 32 [get_debug_ports u_ila_1/probe0]
connect_debug_port u_ila_1/probe0 [get_nets [list {last_5_latencies[3][0]} {last_5_latencies[3][1]} {last_5_latencies[3][2]} {last_5_latencies[3][3]} {last_5_latencies[3][4]} {last_5_latencies[3][5]} {last_5_latencies[3][6]} {last_5_latencies[3][7]} {last_5_latencies[3][8]} {last_5_latencies[3][9]} {last_5_latencies[3][10]} {last_5_latencies[3][11]} {last_5_latencies[3][12]} {last_5_latencies[3][13]} {last_5_latencies[3][14]} {last_5_latencies[3][15]} {last_5_latencies[3][16]} {last_5_latencies[3][17]} {last_5_latencies[3][18]} {last_5_latencies[3][19]} {last_5_latencies[3][20]} {last_5_latencies[3][21]} {last_5_latencies[3][22]} {last_5_latencies[3][23]} {last_5_latencies[3][24]} {last_5_latencies[3][25]} {last_5_latencies[3][26]} {last_5_latencies[3][27]} {last_5_latencies[3][28]} {last_5_latencies[3][29]} {last_5_latencies[3][30]} {last_5_latencies[3][31]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe1]
set_property port_width 32 [get_debug_ports u_ila_1/probe1]
connect_debug_port u_ila_1/probe1 [get_nets [list {latency_counter[0]} {latency_counter[1]} {latency_counter[2]} {latency_counter[3]} {latency_counter[4]} {latency_counter[5]} {latency_counter[6]} {latency_counter[7]} {latency_counter[8]} {latency_counter[9]} {latency_counter[10]} {latency_counter[11]} {latency_counter[12]} {latency_counter[13]} {latency_counter[14]} {latency_counter[15]} {latency_counter[16]} {latency_counter[17]} {latency_counter[18]} {latency_counter[19]} {latency_counter[20]} {latency_counter[21]} {latency_counter[22]} {latency_counter[23]} {latency_counter[24]} {latency_counter[25]} {latency_counter[26]} {latency_counter[27]} {latency_counter[28]} {latency_counter[29]} {latency_counter[30]} {latency_counter[31]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe2]
set_property port_width 32 [get_debug_ports u_ila_1/probe2]
connect_debug_port u_ila_1/probe2 [get_nets [list {last_5_latencies[4][0]} {last_5_latencies[4][1]} {last_5_latencies[4][2]} {last_5_latencies[4][3]} {last_5_latencies[4][4]} {last_5_latencies[4][5]} {last_5_latencies[4][6]} {last_5_latencies[4][7]} {last_5_latencies[4][8]} {last_5_latencies[4][9]} {last_5_latencies[4][10]} {last_5_latencies[4][11]} {last_5_latencies[4][12]} {last_5_latencies[4][13]} {last_5_latencies[4][14]} {last_5_latencies[4][15]} {last_5_latencies[4][16]} {last_5_latencies[4][17]} {last_5_latencies[4][18]} {last_5_latencies[4][19]} {last_5_latencies[4][20]} {last_5_latencies[4][21]} {last_5_latencies[4][22]} {last_5_latencies[4][23]} {last_5_latencies[4][24]} {last_5_latencies[4][25]} {last_5_latencies[4][26]} {last_5_latencies[4][27]} {last_5_latencies[4][28]} {last_5_latencies[4][29]} {last_5_latencies[4][30]} {last_5_latencies[4][31]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe3]
set_property port_width 64 [get_debug_ports u_ila_1/probe3]
connect_debug_port u_ila_1/probe3 [get_nets [list {total_latency[0]} {total_latency[1]} {total_latency[2]} {total_latency[3]} {total_latency[4]} {total_latency[5]} {total_latency[6]} {total_latency[7]} {total_latency[8]} {total_latency[9]} {total_latency[10]} {total_latency[11]} {total_latency[12]} {total_latency[13]} {total_latency[14]} {total_latency[15]} {total_latency[16]} {total_latency[17]} {total_latency[18]} {total_latency[19]} {total_latency[20]} {total_latency[21]} {total_latency[22]} {total_latency[23]} {total_latency[24]} {total_latency[25]} {total_latency[26]} {total_latency[27]} {total_latency[28]} {total_latency[29]} {total_latency[30]} {total_latency[31]} {total_latency[32]} {total_latency[33]} {total_latency[34]} {total_latency[35]} {total_latency[36]} {total_latency[37]} {total_latency[38]} {total_latency[39]} {total_latency[40]} {total_latency[41]} {total_latency[42]} {total_latency[43]} {total_latency[44]} {total_latency[45]} {total_latency[46]} {total_latency[47]} {total_latency[48]} {total_latency[49]} {total_latency[50]} {total_latency[51]} {total_latency[52]} {total_latency[53]} {total_latency[54]} {total_latency[55]} {total_latency[56]} {total_latency[57]} {total_latency[58]} {total_latency[59]} {total_latency[60]} {total_latency[61]} {total_latency[62]} {total_latency[63]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe4]
set_property port_width 32 [get_debug_ports u_ila_1/probe4]
connect_debug_port u_ila_1/probe4 [get_nets [list {tlp_count[0]} {tlp_count[1]} {tlp_count[2]} {tlp_count[3]} {tlp_count[4]} {tlp_count[5]} {tlp_count[6]} {tlp_count[7]} {tlp_count[8]} {tlp_count[9]} {tlp_count[10]} {tlp_count[11]} {tlp_count[12]} {tlp_count[13]} {tlp_count[14]} {tlp_count[15]} {tlp_count[16]} {tlp_count[17]} {tlp_count[18]} {tlp_count[19]} {tlp_count[20]} {tlp_count[21]} {tlp_count[22]} {tlp_count[23]} {tlp_count[24]} {tlp_count[25]} {tlp_count[26]} {tlp_count[27]} {tlp_count[28]} {tlp_count[29]} {tlp_count[30]} {tlp_count[31]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe5]
set_property port_width 32 [get_debug_ports u_ila_1/probe5]
connect_debug_port u_ila_1/probe5 [get_nets [list {min_tlp_latency[0]} {min_tlp_latency[1]} {min_tlp_latency[2]} {min_tlp_latency[3]} {min_tlp_latency[4]} {min_tlp_latency[5]} {min_tlp_latency[6]} {min_tlp_latency[7]} {min_tlp_latency[8]} {min_tlp_latency[9]} {min_tlp_latency[10]} {min_tlp_latency[11]} {min_tlp_latency[12]} {min_tlp_latency[13]} {min_tlp_latency[14]} {min_tlp_latency[15]} {min_tlp_latency[16]} {min_tlp_latency[17]} {min_tlp_latency[18]} {min_tlp_latency[19]} {min_tlp_latency[20]} {min_tlp_latency[21]} {min_tlp_latency[22]} {min_tlp_latency[23]} {min_tlp_latency[24]} {min_tlp_latency[25]} {min_tlp_latency[26]} {min_tlp_latency[27]} {min_tlp_latency[28]} {min_tlp_latency[29]} {min_tlp_latency[30]} {min_tlp_latency[31]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe6]
set_property port_width 32 [get_debug_ports u_ila_1/probe6]
connect_debug_port u_ila_1/probe6 [get_nets [list {max_tlp_latency[0]} {max_tlp_latency[1]} {max_tlp_latency[2]} {max_tlp_latency[3]} {max_tlp_latency[4]} {max_tlp_latency[5]} {max_tlp_latency[6]} {max_tlp_latency[7]} {max_tlp_latency[8]} {max_tlp_latency[9]} {max_tlp_latency[10]} {max_tlp_latency[11]} {max_tlp_latency[12]} {max_tlp_latency[13]} {max_tlp_latency[14]} {max_tlp_latency[15]} {max_tlp_latency[16]} {max_tlp_latency[17]} {max_tlp_latency[18]} {max_tlp_latency[19]} {max_tlp_latency[20]} {max_tlp_latency[21]} {max_tlp_latency[22]} {max_tlp_latency[23]} {max_tlp_latency[24]} {max_tlp_latency[25]} {max_tlp_latency[26]} {max_tlp_latency[27]} {max_tlp_latency[28]} {max_tlp_latency[29]} {max_tlp_latency[30]} {max_tlp_latency[31]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe7]
set_property port_width 32 [get_debug_ports u_ila_1/probe7]
connect_debug_port u_ila_1/probe7 [get_nets [list {last_5_latencies[2][0]} {last_5_latencies[2][1]} {last_5_latencies[2][2]} {last_5_latencies[2][3]} {last_5_latencies[2][4]} {last_5_latencies[2][5]} {last_5_latencies[2][6]} {last_5_latencies[2][7]} {last_5_latencies[2][8]} {last_5_latencies[2][9]} {last_5_latencies[2][10]} {last_5_latencies[2][11]} {last_5_latencies[2][12]} {last_5_latencies[2][13]} {last_5_latencies[2][14]} {last_5_latencies[2][15]} {last_5_latencies[2][16]} {last_5_latencies[2][17]} {last_5_latencies[2][18]} {last_5_latencies[2][19]} {last_5_latencies[2][20]} {last_5_latencies[2][21]} {last_5_latencies[2][22]} {last_5_latencies[2][23]} {last_5_latencies[2][24]} {last_5_latencies[2][25]} {last_5_latencies[2][26]} {last_5_latencies[2][27]} {last_5_latencies[2][28]} {last_5_latencies[2][29]} {last_5_latencies[2][30]} {last_5_latencies[2][31]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe8]
set_property port_width 32 [get_debug_ports u_ila_1/probe8]
connect_debug_port u_ila_1/probe8 [get_nets [list {current_tlp_latency[0]} {current_tlp_latency[1]} {current_tlp_latency[2]} {current_tlp_latency[3]} {current_tlp_latency[4]} {current_tlp_latency[5]} {current_tlp_latency[6]} {current_tlp_latency[7]} {current_tlp_latency[8]} {current_tlp_latency[9]} {current_tlp_latency[10]} {current_tlp_latency[11]} {current_tlp_latency[12]} {current_tlp_latency[13]} {current_tlp_latency[14]} {current_tlp_latency[15]} {current_tlp_latency[16]} {current_tlp_latency[17]} {current_tlp_latency[18]} {current_tlp_latency[19]} {current_tlp_latency[20]} {current_tlp_latency[21]} {current_tlp_latency[22]} {current_tlp_latency[23]} {current_tlp_latency[24]} {current_tlp_latency[25]} {current_tlp_latency[26]} {current_tlp_latency[27]} {current_tlp_latency[28]} {current_tlp_latency[29]} {current_tlp_latency[30]} {current_tlp_latency[31]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe9]
set_property port_width 32 [get_debug_ports u_ila_1/probe9]
connect_debug_port u_ila_1/probe9 [get_nets [list {last_5_latencies[1][0]} {last_5_latencies[1][1]} {last_5_latencies[1][2]} {last_5_latencies[1][3]} {last_5_latencies[1][4]} {last_5_latencies[1][5]} {last_5_latencies[1][6]} {last_5_latencies[1][7]} {last_5_latencies[1][8]} {last_5_latencies[1][9]} {last_5_latencies[1][10]} {last_5_latencies[1][11]} {last_5_latencies[1][12]} {last_5_latencies[1][13]} {last_5_latencies[1][14]} {last_5_latencies[1][15]} {last_5_latencies[1][16]} {last_5_latencies[1][17]} {last_5_latencies[1][18]} {last_5_latencies[1][19]} {last_5_latencies[1][20]} {last_5_latencies[1][21]} {last_5_latencies[1][22]} {last_5_latencies[1][23]} {last_5_latencies[1][24]} {last_5_latencies[1][25]} {last_5_latencies[1][26]} {last_5_latencies[1][27]} {last_5_latencies[1][28]} {last_5_latencies[1][29]} {last_5_latencies[1][30]} {last_5_latencies[1][31]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe10]
set_property port_width 32 [get_debug_ports u_ila_1/probe10]
connect_debug_port u_ila_1/probe10 [get_nets [list {last_5_latencies[0][0]} {last_5_latencies[0][1]} {last_5_latencies[0][2]} {last_5_latencies[0][3]} {last_5_latencies[0][4]} {last_5_latencies[0][5]} {last_5_latencies[0][6]} {last_5_latencies[0][7]} {last_5_latencies[0][8]} {last_5_latencies[0][9]} {last_5_latencies[0][10]} {last_5_latencies[0][11]} {last_5_latencies[0][12]} {last_5_latencies[0][13]} {last_5_latencies[0][14]} {last_5_latencies[0][15]} {last_5_latencies[0][16]} {last_5_latencies[0][17]} {last_5_latencies[0][18]} {last_5_latencies[0][19]} {last_5_latencies[0][20]} {last_5_latencies[0][21]} {last_5_latencies[0][22]} {last_5_latencies[0][23]} {last_5_latencies[0][24]} {last_5_latencies[0][25]} {last_5_latencies[0][26]} {last_5_latencies[0][27]} {last_5_latencies[0][28]} {last_5_latencies[0][29]} {last_5_latencies[0][30]} {last_5_latencies[0][31]}]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets user_clk]
