//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2022.2 (lin64) Build 3671981 Fri Oct 14 04:59:54 MDT 2022
//Date        : Wed Aug 20 23:15:17 2025
//Host        : dgx-a800 running 64-bit Ubuntu 24.04.3 LTS
//Command     : generate_target system_wrapper.bd
//Design      : system_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module system_wrapper
   (DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb,
    GPIO_0_tri_i,
    GPIO_1_tri_i,
    HDMI_TX_CLK_N,
    HDMI_TX_CLK_P,
    HDMI_TX_N,
    HDMI_TX_P,
    M_AXIS_0_tdata,
    M_AXIS_0_tkeep,
    M_AXIS_0_tlast,
    M_AXIS_0_tready,
    M_AXIS_0_tvalid,
    M_AXIS_1_tdata,
    M_AXIS_1_tkeep,
    M_AXIS_1_tlast,
    M_AXIS_1_tready,
    M_AXIS_1_tvalid,
    PHYA_mdio_mdc,
    PHYA_mdio_mdio_io,
    PHYA_rgmii_rd,
    PHYA_rgmii_rx_ctl,
    PHYA_rgmii_rxc,
    PHYA_rgmii_td,
    PHYA_rgmii_tx_ctl,
    PHYA_rgmii_txc,
    S_AXIS_0_tdata,
    S_AXIS_0_tkeep,
    S_AXIS_0_tlast,
    S_AXIS_0_tready,
    S_AXIS_0_tvalid,
    S_AXIS_1_tdata,
    S_AXIS_1_tkeep,
    S_AXIS_1_tlast,
    S_AXIS_1_tready,
    S_AXIS_1_tvalid,
    m_axis_aclk_0,
    phy_rst_n_0,
    s_axis_aclk_0,
    s_axis_aresetn_0);
  inout [14:0]DDR_addr;
  inout [2:0]DDR_ba;
  inout DDR_cas_n;
  inout DDR_ck_n;
  inout DDR_ck_p;
  inout DDR_cke;
  inout DDR_cs_n;
  inout [3:0]DDR_dm;
  inout [31:0]DDR_dq;
  inout [3:0]DDR_dqs_n;
  inout [3:0]DDR_dqs_p;
  inout DDR_odt;
  inout DDR_ras_n;
  inout DDR_reset_n;
  inout DDR_we_n;
  inout FIXED_IO_ddr_vrn;
  inout FIXED_IO_ddr_vrp;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;
  input [31:0]GPIO_0_tri_i;
  input [31:0]GPIO_1_tri_i;
  output HDMI_TX_CLK_N;
  output HDMI_TX_CLK_P;
  output [2:0]HDMI_TX_N;
  output [2:0]HDMI_TX_P;
  output [63:0]M_AXIS_0_tdata;
  output [7:0]M_AXIS_0_tkeep;
  output M_AXIS_0_tlast;
  input M_AXIS_0_tready;
  output M_AXIS_0_tvalid;
  output [31:0]M_AXIS_1_tdata;
  output [3:0]M_AXIS_1_tkeep;
  output M_AXIS_1_tlast;
  input M_AXIS_1_tready;
  output M_AXIS_1_tvalid;
  output PHYA_mdio_mdc;
  inout PHYA_mdio_mdio_io;
  input [3:0]PHYA_rgmii_rd;
  input PHYA_rgmii_rx_ctl;
  input PHYA_rgmii_rxc;
  output [3:0]PHYA_rgmii_td;
  output PHYA_rgmii_tx_ctl;
  output PHYA_rgmii_txc;
  input [63:0]S_AXIS_0_tdata;
  input [7:0]S_AXIS_0_tkeep;
  input S_AXIS_0_tlast;
  output S_AXIS_0_tready;
  input S_AXIS_0_tvalid;
  input [31:0]S_AXIS_1_tdata;
  input [3:0]S_AXIS_1_tkeep;
  input S_AXIS_1_tlast;
  output S_AXIS_1_tready;
  input S_AXIS_1_tvalid;
  input m_axis_aclk_0;
  output [0:0]phy_rst_n_0;
  input s_axis_aclk_0;
  input s_axis_aresetn_0;

  wire [14:0]DDR_addr;
  wire [2:0]DDR_ba;
  wire DDR_cas_n;
  wire DDR_ck_n;
  wire DDR_ck_p;
  wire DDR_cke;
  wire DDR_cs_n;
  wire [3:0]DDR_dm;
  wire [31:0]DDR_dq;
  wire [3:0]DDR_dqs_n;
  wire [3:0]DDR_dqs_p;
  wire DDR_odt;
  wire DDR_ras_n;
  wire DDR_reset_n;
  wire DDR_we_n;
  wire FIXED_IO_ddr_vrn;
  wire FIXED_IO_ddr_vrp;
  wire [53:0]FIXED_IO_mio;
  wire FIXED_IO_ps_clk;
  wire FIXED_IO_ps_porb;
  wire FIXED_IO_ps_srstb;
  wire [31:0]GPIO_0_tri_i;
  wire [31:0]GPIO_1_tri_i;
  wire HDMI_TX_CLK_N;
  wire HDMI_TX_CLK_P;
  wire [2:0]HDMI_TX_N;
  wire [2:0]HDMI_TX_P;
  wire [63:0]M_AXIS_0_tdata;
  wire [7:0]M_AXIS_0_tkeep;
  wire M_AXIS_0_tlast;
  wire M_AXIS_0_tready;
  wire M_AXIS_0_tvalid;
  wire [31:0]M_AXIS_1_tdata;
  wire [3:0]M_AXIS_1_tkeep;
  wire M_AXIS_1_tlast;
  wire M_AXIS_1_tready;
  wire M_AXIS_1_tvalid;
  wire PHYA_mdio_mdc;
  wire PHYA_mdio_mdio_i;
  wire PHYA_mdio_mdio_io;
  wire PHYA_mdio_mdio_o;
  wire PHYA_mdio_mdio_t;
  wire [3:0]PHYA_rgmii_rd;
  wire PHYA_rgmii_rx_ctl;
  wire PHYA_rgmii_rxc;
  wire [3:0]PHYA_rgmii_td;
  wire PHYA_rgmii_tx_ctl;
  wire PHYA_rgmii_txc;
  wire [63:0]S_AXIS_0_tdata;
  wire [7:0]S_AXIS_0_tkeep;
  wire S_AXIS_0_tlast;
  wire S_AXIS_0_tready;
  wire S_AXIS_0_tvalid;
  wire [31:0]S_AXIS_1_tdata;
  wire [3:0]S_AXIS_1_tkeep;
  wire S_AXIS_1_tlast;
  wire S_AXIS_1_tready;
  wire S_AXIS_1_tvalid;
  wire m_axis_aclk_0;
  wire [0:0]phy_rst_n_0;
  wire s_axis_aclk_0;
  wire s_axis_aresetn_0;

  IOBUF PHYA_mdio_mdio_iobuf
       (.I(PHYA_mdio_mdio_o),
        .IO(PHYA_mdio_mdio_io),
        .O(PHYA_mdio_mdio_i),
        .T(PHYA_mdio_mdio_t));
  system system_i
       (.DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .GPIO_0_tri_i(GPIO_0_tri_i),
        .GPIO_1_tri_i(GPIO_1_tri_i),
        .HDMI_TX_CLK_N(HDMI_TX_CLK_N),
        .HDMI_TX_CLK_P(HDMI_TX_CLK_P),
        .HDMI_TX_N(HDMI_TX_N),
        .HDMI_TX_P(HDMI_TX_P),
        .M_AXIS_0_tdata(M_AXIS_0_tdata),
        .M_AXIS_0_tkeep(M_AXIS_0_tkeep),
        .M_AXIS_0_tlast(M_AXIS_0_tlast),
        .M_AXIS_0_tready(M_AXIS_0_tready),
        .M_AXIS_0_tvalid(M_AXIS_0_tvalid),
        .M_AXIS_1_tdata(M_AXIS_1_tdata),
        .M_AXIS_1_tkeep(M_AXIS_1_tkeep),
        .M_AXIS_1_tlast(M_AXIS_1_tlast),
        .M_AXIS_1_tready(M_AXIS_1_tready),
        .M_AXIS_1_tvalid(M_AXIS_1_tvalid),
        .PHYA_mdio_mdc(PHYA_mdio_mdc),
        .PHYA_mdio_mdio_i(PHYA_mdio_mdio_i),
        .PHYA_mdio_mdio_o(PHYA_mdio_mdio_o),
        .PHYA_mdio_mdio_t(PHYA_mdio_mdio_t),
        .PHYA_rgmii_rd(PHYA_rgmii_rd),
        .PHYA_rgmii_rx_ctl(PHYA_rgmii_rx_ctl),
        .PHYA_rgmii_rxc(PHYA_rgmii_rxc),
        .PHYA_rgmii_td(PHYA_rgmii_td),
        .PHYA_rgmii_tx_ctl(PHYA_rgmii_tx_ctl),
        .PHYA_rgmii_txc(PHYA_rgmii_txc),
        .S_AXIS_0_tdata(S_AXIS_0_tdata),
        .S_AXIS_0_tkeep(S_AXIS_0_tkeep),
        .S_AXIS_0_tlast(S_AXIS_0_tlast),
        .S_AXIS_0_tready(S_AXIS_0_tready),
        .S_AXIS_0_tvalid(S_AXIS_0_tvalid),
        .S_AXIS_1_tdata(S_AXIS_1_tdata),
        .S_AXIS_1_tkeep(S_AXIS_1_tkeep),
        .S_AXIS_1_tlast(S_AXIS_1_tlast),
        .S_AXIS_1_tready(S_AXIS_1_tready),
        .S_AXIS_1_tvalid(S_AXIS_1_tvalid),
        .m_axis_aclk_0(m_axis_aclk_0),
        .phy_rst_n_0(phy_rst_n_0),
        .s_axis_aclk_0(s_axis_aclk_0),
        .s_axis_aresetn_0(s_axis_aresetn_0));
endmodule
