// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (lin64) Build 3671981 Fri Oct 14 04:59:54 MDT 2022
// Date        : Tue Jan 21 22:55:18 2025
// Host        : dgx-a800 running 64-bit Ubuntu 22.04.5 LTS
// Command     : write_verilog -force -mode funcsim -rename_top bd_4bad_c_counter_binary_0_0 -prefix
//               bd_4bad_c_counter_binary_0_0_ bd_4bad_c_counter_binary_0_0_sim_netlist.v
// Design      : bd_4bad_c_counter_binary_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z015clg485-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "bd_4bad_c_counter_binary_0_0,c_counter_binary_v12_0_15,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "c_counter_binary_v12_0_15,Vivado 2022.2" *) 
(* NotValidForBitStream *)
module bd_4bad_c_counter_binary_0_0
   (CLK,
    SCLR,
    THRESH0,
    Q);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk_intf CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME clk_intf, ASSOCIATED_BUSIF q_intf:thresh0_intf:l_intf:load_intf:up_intf:sinit_intf:sset_intf, ASSOCIATED_RESET SCLR, ASSOCIATED_CLKEN CE, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN system_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0" *) input CLK;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 sclr_intf RST" *) (* x_interface_parameter = "XIL_INTERFACENAME sclr_intf, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *) input SCLR;
  (* x_interface_info = "xilinx.com:signal:data:1.0 thresh0_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME thresh0_intf, LAYERED_METADATA undef" *) output THRESH0;
  (* x_interface_info = "xilinx.com:signal:data:1.0 q_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME q_intf, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {DATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value data} bitwidth {attribs {resolve_type generated dependency bitwidth format long minimum {} maximum {}} value 24} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value false}}}} DATA_WIDTH 24}" *) output [23:0]Q;

  wire CLK;
  wire [23:0]Q;
  wire SCLR;
  wire THRESH0;

  (* C_AINIT_VAL = "0" *) 
  (* C_CE_OVERRIDES_SYNC = "0" *) 
  (* C_FB_LATENCY = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "1" *) 
  (* C_HAS_SINIT = "0" *) 
  (* C_HAS_SSET = "0" *) 
  (* C_IMPLEMENTATION = "0" *) 
  (* C_SCLR_OVERRIDES_SSET = "1" *) 
  (* C_SINIT_VAL = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_WIDTH = "24" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* c_count_by = "1" *) 
  (* c_count_mode = "0" *) 
  (* c_count_to = "1100000000000000000000" *) 
  (* c_has_load = "0" *) 
  (* c_has_thresh0 = "1" *) 
  (* c_latency = "1" *) 
  (* c_load_low = "0" *) 
  (* c_restrict_count = "1" *) 
  (* c_thresh0_value = "1100000000000000000000" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  bd_4bad_c_counter_binary_0_0_c_counter_binary_v12_0_15 U0
       (.CE(1'b1),
        .CLK(CLK),
        .L({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .LOAD(1'b0),
        .Q(Q),
        .SCLR(SCLR),
        .SINIT(1'b0),
        .SSET(1'b0),
        .THRESH0(THRESH0),
        .UP(1'b1));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2022.2"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
KdkdvVsuosc8qR9X5PxQ/ghTeTrEz4qKVuenhDR9wRSL/BO/mhSwQtiFj74UO0sGv0zvjAntaq/3
l2/v8gOiVKmM666gbk/2UCISA4OFA3FDR9jYmiXdNXb2qHeS1ywQz5n/sTR5iu4KFEfwrl3IXtQw
aEiGegL+CQMaovJsto4=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
pZCj3qT3VD1SCS5RiZExsqqu16KpMtHXilQL9p5/eBl7qrfQjT1VhFtVbYUusepbChjsCCmCn7hr
72SuHmOmDWG78UARN7MLdO/+sePuyS06ak4nAw5xwjT0g+9970uMWYKvTeeYqoz2i+k+zX60Cuvu
iwBfxWM22DqukHlYzbEFWhNyXIkgJe71p67vGdXBmqu4/2wmlwGApqBxlwR+alwZ9UGHlxNQS4N5
z1wHu3Cp8LwGRjlaXjElcY8RDpvyz5l59ey8ar5HXR9Zqf6e1unE2NdhzHhEGRerRFXoKZppk1HB
6kIEY4EHAWz+HvPcqoP9eoYKDazoAGkJRVP6YA==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
gLgm7VvY3cNcNvdXvikCQd2nRniE4ae4hePOcAUlPDMoHDzQAD7Ngo12MGFns9JNPcCaUXfAmxL2
JNGojjrDRUWrv8FPV6FOEbDHs96fef8+gqLF4OqLck4kWpKhnJwaJjjzQirvXEzZxP+GsBKnkSp8
ceVlZJwP0F6XRv+RpQA=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
GeZP242oKQSNuofqDs4oIIXZEufPhRVrlFFeRSLY4VCxhMEMwfPrNXe33xO0zIEBoPW2X9mvUoTY
izdWQEtWImFzjzPCjkSLhEdIMmUBH02Y+Tw3eW5x23T0cK96pmoV2MH8kl99I27MN6stVd977fuB
Mjao5MnSXIGZ/uXGtgfUO9Zjs4/2wGmsI2/lANN2WOL9Sz4xeA8k40c2dNYgxgHoCwx8Ya/RYIZS
Cpuvzq4ZyFSNT/kMXnUmqj75/flpXT3mmyW+frexux3j9PxpKHmxAE9crvDx85rMamGiA4ftl+ac
H0FtL2cBqdlP60x+FjqleWCJoN6AYdxA0YZaeg==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
URmEGftuxvv0+tViRUdsFNnPXucZlVDfUQpjjXkpOA38QUzsIL9j1pGGp9doC4jcg/9MD149BTSw
vAG8684a3k+Tx/8sFGl/viK1q8ty9nktEABSahv8Etm5ZJVAzQJT7EaOzrYqyywSwabogvGUmN/7
DE3eOn6+sMCiMl6BLUhYyK39ntTWNFYVPiheclbBb36V1vzMOQl0mvPuS4hDXqba/+qBZXhqeYWK
ceNfwci6SsRRef6hLF/1S+20r2uBxJeYJjyfWGGFEGfxlAOz1MiYUUR/bEHWnbjwIcJTBHQNRdq4
4Ryb+iPuKcsXU/8ApD14i6ScW+VBPWSqnH9w+A==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2021_07", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
NtQgA3rUKfJt+21sTot44yr4gmte57FoFl8Q/327tsRJeEyNAiwWZaZN2mbo2NFcvyN2GhDw6avJ
NsF1Oxs36P8shoqOOiloWWrdTcyAdMhdk+UjeZgKcNSqd4Js87w/5LVQTwjB2mcBDfe1jrivv+IW
ZRBC8NvlW5z/1wF7+vzXRMziLQYeOkLB0OkpIY+eT5cZXDKuZ+4l0FMPjd+El96JGAEHG7Q0qS3F
OEApYEp8+nSZnragoytq4pkhVJEC22ye0hBhoBClJpszCcg0u+Ugf+mYZsj8BC2uqSY6Hh/gpjjw
enQ7aEYBaUR7GCwQN7fZmNhZYtBkyvNqydRQcA==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
CpIFM8Y8dBmpjtOVnOKcfppEFV+c1cRgsQtewNUe+5apiLDoRCdMyTqoCay7nz+Xagc0OvfZDg/Y
jSTsDjKVcEIyxOfix7iwjKW8Rz+a5wBIatI8wfCo7uLtuucz9otOWWI7BFQ2gn4VdQ73HJJlZMMY
OyEOd33tGjNSjxz3W07knDr1FwTE3BOfhq+Qj2ErnuV1dQbrTb3MiQMTnHaTCwtz6ip0pD6b5G4K
kBRUYe+UNXCMvSfNIN9MPSmolO4MjNwM5gnZZqLcR1hGuzH/Yeb/jPnhsZ7jFvlTT3nsM9JzMRAE
QwlzVuulHKQDS2I96arFosYPYMsalmn6CQW0gg==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
qinIxHFISC9r9LS7OKOuYVGM5EBkuuQNV1nDRui+QVNLn2QFCrWPeEClQIlNViKOt8MX9urHvu4e
l2L+eZKw6+St9cW9yUsYu36yoB4LqwG+vKvfR9CW82LGPyMAxdgk/p3n+F0Xp9Y2HaERwWDL99tW
V7cDvLLhyIwz7w4rI0BWWV+KMjXP2F5MNgykzZn7tzV8oY6MxOykFqRdI8DLAdlYGAs90wjJ3x84
S3fHciSox97FYpDi64v31Vb4RmRrwueXcvCc3w8gzjuwg7qraWLMYyPB+mERB2v1htX80PsWWVHE
QXkWiHWYvvrXEykUS04MmLNHpV8ZgBXO/NBEGn7mrITDEswk3u1Yviqy7CW2wLPQBoo5xW+uiu2e
8YZV/E+bAt+P/EH5RsC9alBgtuVKU1s9DaiEH8eUPEgJQ/TXwQW01pg8ECTYgiBS+IQSbld23aq3
goVo0ZMzRu/SA00Jmwt7upvsMkh9Q+2732ahu1FmlSNmyNGB1+bYf782

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
T1jqx5hmzZZMhPApzUC1oZLMAkHma8Ki4b2CvLNqxSn+MNWoTPomvQ775DMBEDai/gahYALsohdX
0f/e6LuPqt4zYtyAzmH+nRgOG/tilS1J674KsaHxudAfo4sM3awB/C4Q3VdYsO9FgvPQylnYKSGE
gJ46W+1Y789VQqPbt4dpnprhix6sLlwfww7We6cq2wu4PilFzovejouUBZqNMZHYi4suKcMcenp3
C7QRKloo8IF9yKrhGPcRJLQt2nus3bI0Q3ICxRk13Nrfhh/z4cdm0OGXz42q44snFEVy1lLxPOs7
W9tSe5ag3923oCT4NGGgK/gMTx5qXxFhV2MJUw==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
lpvZDieohZCCrsXHPHtMnetuTzwwqfw00ky0ejKt+N7kM83Z3+zxgsfpIfvaBQCLxYBviSpI/jZV
JPAg1U3GUm0SnRokzsHZhbLnpbfRBqVgOmoCt+JoEFiwQ9+vAa2v7xaqSv6brTas6Th+GZX0TkfO
aZeUVbvx9xSKHVryk5SYJgnIHcccWfOsg186sZroVcGcDVWehn3wuHaIf/ZQFtCQ7DXwpujsLNe+
jxxPYd4oTCB7y+AdO6OaXB4uQnZS/4deVHhoHplFf4nz1TAK/NlOe5thA6xxOa7HoVJi0jodM/GR
HVLA25RDjAT8zm20bFDYDIW9VjA+8ug7Q2T31w==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
JBgs+GfbBv/BHz1JEkaY7vIDl0UNOnlBwH8ky7TaawpBED/Ep3Jv+EJOIcyGvsptpCd+F0Swqzrl
VssPkrX1YovhHHp3ehwGEkwcPG8N8XlaTlUkCh0oEFfujMSLmInfkaG5pBF40sy/2/Q3z8MNeHHN
862nSnrM4voLDk0MtC9QDag/WwiL1G+twRsprULrbnKVRl69tbaswxC45yRBypRpAto/z19MtJUX
bryladhOZicKZC4tSqzm10gBqYY6EE7hAgw0n7w/R2yXenVbUtxGMZnicr77q94X3QxlRDyS5rnc
8MQpRc8KLATYhgRgGuD6tMiOk0hRDBrLt2776g==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 14736)
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
