// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (lin64) Build 3671981 Fri Oct 14 04:59:54 MDT 2022
// Date        : Tue Jan 21 22:55:18 2025
// Host        : dgx-a800 running 64-bit Ubuntu 22.04.5 LTS
// Command     : write_verilog -force -mode synth_stub -rename_top system_uihdmitx_0_1 -prefix
//               system_uihdmitx_0_1_ system_uihdmitx_0_1_stub.v
// Design      : system_uihdmitx_0_1
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z015clg485-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "uihdmitx,Vivado 2022.2" *)
module system_uihdmitx_0_1(RSTn_i, VS_i, HS_i, VDE_i, RGB_i, PCLKX1_i, 
  PCLKX2_5_i, PCLKX5_i, TMDS_TX_CLK_P, TMDS_TX_CLK_N, TMDS_TX_P, TMDS_TX_N)
/* synthesis syn_black_box black_box_pad_pin="RSTn_i,VS_i,HS_i,VDE_i,RGB_i[23:0],PCLKX1_i,PCLKX2_5_i,PCLKX5_i,TMDS_TX_CLK_P,TMDS_TX_CLK_N,TMDS_TX_P[2:0],TMDS_TX_N[2:0]" */;
  input RSTn_i;
  input VS_i;
  input HS_i;
  input VDE_i;
  input [23:0]RGB_i;
  input PCLKX1_i;
  input PCLKX2_5_i;
  input PCLKX5_i;
  output TMDS_TX_CLK_P;
  output TMDS_TX_CLK_N;
  output [2:0]TMDS_TX_P;
  output [2:0]TMDS_TX_N;
endmodule
