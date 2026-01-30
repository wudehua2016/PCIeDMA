-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2022.2 (lin64) Build 3671981 Fri Oct 14 04:59:54 MDT 2022
-- Date        : Tue Jan 21 22:55:18 2025
-- Host        : dgx-a800 running 64-bit Ubuntu 22.04.5 LTS
-- Command     : write_vhdl -force -mode synth_stub -rename_top system_uihdmitx_0_1 -prefix
--               system_uihdmitx_0_1_ system_uihdmitx_0_1_stub.vhdl
-- Design      : system_uihdmitx_0_1
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z015clg485-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity system_uihdmitx_0_1 is
  Port ( 
    RSTn_i : in STD_LOGIC;
    VS_i : in STD_LOGIC;
    HS_i : in STD_LOGIC;
    VDE_i : in STD_LOGIC;
    RGB_i : in STD_LOGIC_VECTOR ( 23 downto 0 );
    PCLKX1_i : in STD_LOGIC;
    PCLKX2_5_i : in STD_LOGIC;
    PCLKX5_i : in STD_LOGIC;
    TMDS_TX_CLK_P : out STD_LOGIC;
    TMDS_TX_CLK_N : out STD_LOGIC;
    TMDS_TX_P : out STD_LOGIC_VECTOR ( 2 downto 0 );
    TMDS_TX_N : out STD_LOGIC_VECTOR ( 2 downto 0 )
  );

end system_uihdmitx_0_1;

architecture stub of system_uihdmitx_0_1 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "RSTn_i,VS_i,HS_i,VDE_i,RGB_i[23:0],PCLKX1_i,PCLKX2_5_i,PCLKX5_i,TMDS_TX_CLK_P,TMDS_TX_CLK_N,TMDS_TX_P[2:0],TMDS_TX_N[2:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "uihdmitx,Vivado 2022.2";
begin
end;
