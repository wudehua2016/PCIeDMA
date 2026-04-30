// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (lin64) Build 3671981 Fri Oct 14 04:59:54 MDT 2022
// Date        : Tue Jan 21 22:55:17 2025
// Host        : dgx-a800 running 64-bit Ubuntu 22.04.5 LTS
// Command     : write_verilog -force -mode funcsim -rename_top bd_4bad_c_shift_ram_0_0 -prefix
//               bd_4bad_c_shift_ram_0_0_ bd_4bad_c_shift_ram_0_0_sim_netlist.v
// Design      : bd_4bad_c_shift_ram_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z015clg485-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "bd_4bad_c_shift_ram_0_0,c_shift_ram_v12_0_14,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "c_shift_ram_v12_0_14,Vivado 2022.2" *) 
(* NotValidForBitStream *)
module bd_4bad_c_shift_ram_0_0
   (D,
    CLK,
    CE,
    SCLR,
    Q);
  (* x_interface_info = "xilinx.com:signal:data:1.0 d_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME d_intf, LAYERED_METADATA undef" *) input [0:0]D;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk_intf CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME clk_intf, ASSOCIATED_BUSIF q_intf:sinit_intf:sset_intf:d_intf:a_intf, ASSOCIATED_RESET SCLR, ASSOCIATED_CLKEN CE, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN system_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0" *) input CLK;
  (* x_interface_info = "xilinx.com:signal:clockenable:1.0 ce_intf CE" *) (* x_interface_parameter = "XIL_INTERFACENAME ce_intf, POLARITY ACTIVE_HIGH" *) input CE;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 sclr_intf RST" *) (* x_interface_parameter = "XIL_INTERFACENAME sclr_intf, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *) input SCLR;
  (* x_interface_info = "xilinx.com:signal:data:1.0 q_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME q_intf, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {DATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value data} bitwidth {attribs {resolve_type generated dependency data_bitwidth format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}} DATA_WIDTH 1}" *) output [0:0]Q;

  wire CE;
  wire CLK;
  wire [0:0]D;
  wire [0:0]Q;
  wire SCLR;

  (* C_AINIT_VAL = "0" *) 
  (* C_HAS_CE = "1" *) 
  (* C_HAS_SCLR = "1" *) 
  (* C_HAS_SINIT = "0" *) 
  (* C_HAS_SSET = "0" *) 
  (* C_SINIT_VAL = "0" *) 
  (* C_SYNC_ENABLE = "0" *) 
  (* C_SYNC_PRIORITY = "1" *) 
  (* C_WIDTH = "1" *) 
  (* c_addr_width = "4" *) 
  (* c_default_data = "0" *) 
  (* c_depth = "1" *) 
  (* c_elaboration_dir = "./" *) 
  (* c_has_a = "0" *) 
  (* c_mem_init_file = "no_coe_file_loaded" *) 
  (* c_opt_goal = "0" *) 
  (* c_parser_type = "0" *) 
  (* c_read_mif = "0" *) 
  (* c_reg_last_bit = "1" *) 
  (* c_shift_type = "0" *) 
  (* c_verbosity = "0" *) 
  (* c_xdevicefamily = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  bd_4bad_c_shift_ram_0_0_c_shift_ram_v12_0_14 U0
       (.A({1'b0,1'b0,1'b0,1'b0}),
        .CE(CE),
        .CLK(CLK),
        .D(D),
        .Q(Q),
        .SCLR(SCLR),
        .SINIT(1'b0),
        .SSET(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2022.2"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
c/wA5liyV/LPsKRmFzwxOzMM9n38OKoskM2eV12+p8ymcpS5TSWtutYPfQvZnGZZfd8i/h93sskE
aYtyaj9r82ZsRS//wjee3CGcJ96gsie1s/zVMyvtQwl06PGFCfBpzauOVKiMwENeLpUT1RKqAXkx
Yl5ZRwDQye7scTEiJ00=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
pvq46JXLahp5XPx+a/0qqI+q3DAS5hdJHtrc58f+wKPIWSonA73Ry+sA2G22W5m9gcLjdutlrO3Z
tCFoOk9903pekANOyDnxNVC3XokdoOx60qR9SkTdoRSoFtoxsXGHf/DcXUII9M+W0bO/CDmYDcNo
r7aqLbU+SA6OqBOCM8rMYE4IRqWsN0B39RVdHWhmWVgQBS2mZk+30c3XYyN7rnCOE6eaGwaVtnwH
VfWH9pTe4g8uibOl93VQ7HnnI1im9xFEv0e1HXGZooWf4JBBcPjWG2olWoMegh1BWyXPDYsLai8q
DiMBE0Qcpk5n0TNTCsarWZUuaxcDrGxLdPdlKQ==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
mB8YWCR0O9x0T00SavylLJzD4EOwijo0xEcicZ6cVxQZWuyWbx+k/ZiPXGZlw54BI2rUVCcV2BLI
4gUw7aTkHqyMqWOZpc4RgAwB2x7+FB4EO/gBeGyMowJrid6yIiuOU1eXMIJlEudw057p9X069359
VOBwC7cPvZI8vSf4TAU=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Q3No/YDkVIy0FiweeVvn76i7Ri3EOYVbYAiHi2wWauttiokshnXqj8dkiKMFGvPocjMgQabi5r+y
aL7TsVpBMAiOxtVu1Mt6MAqN751M3k7qrb0Z0nLX3H/YHpXC7njMit3jmOHIafYANCF1YyMgR06C
lsmoPymvHm7N9d9Bj92VCkDOO0UYArO9YpQYzlUCe4iN6Bawbjge00kwpPm06b+LF85F+tlqlAxx
ntSor+XsBKxptIxSH+4BJafJ02+0JVXsdURVaycuWGCJsvUAbWNiRoPeN2woA3V/7ZIp551OSSJA
FHwaGLDcmtxipE0tjMmg/fMt8sEatgUs9amLcA==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
jnx7WBfdUta1DP+YRTT3fGRtjq857NO8Wcmmz63XNNB7mnqRUarhreRnndqogngF5poSxm+Fp9Qe
5/N64PQhcrXe7INbzX7GqJBCYQaDzLlx56Ezocscr/wB/94g1XHh5C7L+OaGsz73/C6nTrTx+qoO
vYXsLhOATbupH15I0QqrflKRn191h77YQ6O9D2LbiFJLiBIlQibYncy/VYCVBL3bZwpru4o+gy64
EClBbsC0+k/WEH0aCsQDlF37rB3VMvcwl0smwqdm6RZ2gzh2ohWxtz+8yh604ISRnvEqw+NQyZQf
QshGn3q1u43MADSpPe9C5Gl4T6pk+LZ/JSs3lw==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2021_07", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
S4JCYpvS357WfAEsQX/qUC4UZCr/A2YWWyJiXN9E8HjVpOdVBXoy9Yw4qqWt5SAZDrW3fpCiU6Xk
I3QWXZAsQv0gGfjq5c+nhZBf5SZ75y594X6JmZur+YdJk/D0QxsIXGWxZsRjfV5PXynYs9YZuxMc
PY5DzwXE9IIacOBWm31qWbCIhMpZwoDkmkU6+q8bWNbhSwGwr+XN9yy9KdFMwoQUPjQ7CL0HdF+o
DYz5SXrTzlc+1BZNT82zYZqGwxDcghaR33/vWKZMzqeR3ZpnIUUZBKJIroCkx+oEaeczxK5/DBcc
t7cgRzglxN2qg60fApXAf3SDcJ/+weCZKL1nGw==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Vjtlu8KNjnlNuUIE5zPRhhb8tB0OK/vR9xaBOqOYDrP2jeqyxMSFwVjyddbpvhJa4cs7tpaKRfqn
s4JFJ7oeyKOadS9yc/j1irJpOQQ4riipe4vewDCIq71FwpXqXOnRlt26x0r5rH9Y5eNCMItZs5II
8VnEtl8vauM5POdGNhFUGryFciFJg/7/xFV29uZxlno+WssvhIerE0b6i4Yj6PdEVf4KX2tMA8l9
g+sUhj5pwuErpZh8WwZYeve4N9FuVSUYlMmxJgpjPBPRdHXOtONBerkAJMxrr/1DhwILKg0RB3sm
rGYB7e6AiN9fJHD89spJ4K1S4h200ROiEbpNug==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
G43T8ZCfcyBws9KaAojYCDvIQxBJSUDk3BWoc7oxKs/Bh7fzJ8yxhRl3C4UER8pby+YR52a1OhxH
Gpcoj3PHLWs8FpQkDOgIbp7KEdqdbJ/7IjPbOWyn+Mjgni7Jk9ZsKLq023EGhEwxyz8KR492uBhP
y2S7Pkb9myeTsa6kHt6qseaYyHJG4Tt6iwEaQSFLscOQwGw2eNnH3Bm6v4ZEqL0W0iIpBqYvpeiE
GJApSzBSZ30dACWN2sN0OuBC0/IXNmR+syVqSB+PO/GN1n1p9E+ltyzmOgWeWiqBwxJhstmViafi
01TSaGccEU1yzCSNTWINZ7UhLf+0zGvHXdPZRblwHA91uxGramDe4ElhhYOLpbY8aKN1Tvst37Lw
Ev1cq+WJTrArjWnNufDZAxwO0huX9sDiT19/v28kSfYeTzFRxcyjCSRSjUxhmYMR+EM8DNfpvWFu
V2tqwwoQ35phMEIidKsu81KHd6hjUph5Ii3jbgSuDXYqHydSoflU4FZT

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
LTVGG4EqxAN35+EjEQ5dQgqkhUon8FKa6+oaA5F3/XQpOpJaz5NletAny4izGuEj/Rcko5Mb15Sv
55lokHX4MQDMfJEvj/xRT2uEHXNljDKmKN8zikxCTdy9H1PdStFfNS1CWujTtex7/zc9dxqgOd67
QcK7WbgKgh04q+osXEo4VG7R4xmwNDdiprgPhEOw+q0jLkLX9kdvNuzZ4KkdTBFHG2q2Ho4epXzg
wTRR/KDnf9ffxfSFCsxB49EOByzVzzdO2bud/VCR5VKw5dgQ3uTI6BTBEGKOe0igY+nZ2l6VtFv3
OL3+xEJUZheoPKRNA62H+2zw/prkdd2r+oBWOA==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
GoQnh80GCP5HLlnOi9stntzTXHvCOuV78iNNmSgUftZmlVs0dJymBytGdwsoAqu71gJCmhv82Z48
jU5dykWEzt0wGagbW3aKLkxOGWS+UGa64Ic8MDmuNoVGX+u0Q+dCiGVWkPtiXVeZt7Z4gGlx8XY9
Rf0InbQMhi76avbsRclf7TaojnEOildO41LjPp0uvBEKXW/WM4X8MHr8icacw9nGvhnYW5G/r5eJ
oG3Z6bRIOyT1Om5MbmhQLuuEE9aRpdC7NFknoTeOb2V54axH0pVvEeaWudrxbzbicNp0dfsJUqYk
gJj3Wsyoxwf8AMK3JwVrNO7uY3kxUimHz2u0eg==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
OSuKemptd0MQnqSZsJoF8EdxdrADpEJfyVWw9ONpHtBEhqRdy7l+ut2DGm9uW9AeqdFEcOu7Ei7/
bMdZNKky9qghBwTt+8/QFzGYkntVdjlcLuV9Co4djykbQIoYXENBO+HINCwO8QXCdS+895RmoO/f
gD7ucbzBYm1p6i9+vmDtpLsmWtFjugXqZow5xkVPnEWZZsvKIcA2/Cszumf0LylgJmNndoBeyVrC
qBcVIJDMo3xgkgbJYPnqPQM2+8EGEn4qInOgPssGXefVKDHvZsL/3IIJCSpCO3Ub7FdeBAok8MEv
H1YmFcPhtx0/zgk8UOrxbv1dVzk6bhLdp/1ZFg==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 6768)
`pragma protect data_block
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
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
