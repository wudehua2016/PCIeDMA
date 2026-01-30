`timescale 1ns / 1ps

`define PCI_EXP_EP_OUI 24'h000A35

//
// Device Serial Number (DSN) constants
//
`define PCI_EXP_EP_DSN_2 32'h00000001
`define PCI_EXP_EP_DSN_1 {{ 8'h1 }, `PCI_EXP_EP_OUI }

module zc_pcie_dma #
(
  parameter PL_FAST_TRAIN = "FALSE",        // Simulation Speedup
  parameter EXT_PIPE_SIM = "FALSE",         // This Parameter has effect on selecting Enable External PIPE Interface in GUI.    
  parameter PCIE_EXT_CLK = "TRUE",          // Use External Clocking Module
  parameter REF_CLK_FREQ = 0,               // 0 - 100 MHz, 1 - 125 MHz, 2 - 250 MHz
  parameter C_DATA_WIDTH = 64,              // RX/TX interface data width
  parameter KEEP_WIDTH = C_DATA_WIDTH / 8   // TSTRB width
)(
  output [0:0] pci_exp_txp,
  output [0:0] pci_exp_txn,
  input [0:0] pci_exp_rxp,
  input [0:0] pci_exp_rxn,

  input sys_clk_p,
  input sys_clk_n,
  input sys_rst_n,
  
  inout [14:0] DDR_addr,
  inout [2:0] DDR_ba,
  inout DDR_cas_n,
  inout DDR_ck_n,
  inout DDR_ck_p,
  inout DDR_cke,
  inout DDR_cs_n,
  inout [3:0] DDR_dm,
  inout [31:0] DDR_dq,
  inout [3:0] DDR_dqs_n,
  inout [3:0] DDR_dqs_p,
  inout DDR_odt,
  inout DDR_ras_n,
  inout DDR_reset_n,
  inout DDR_we_n,
  inout FIXED_IO_ddr_vrn,
  inout FIXED_IO_ddr_vrp,
  inout [53:0] FIXED_IO_mio,
  inout FIXED_IO_ps_clk,
  inout FIXED_IO_ps_porb,
  inout FIXED_IO_ps_srstb,
    output HDMI_TX_CLK_N,
  output HDMI_TX_CLK_P,
  output [2:0]HDMI_TX_N,
  output [2:0]HDMI_TX_P,
    output PHYA_mdio_mdc,
  inout PHYA_mdio_mdio_io,
  input [3:0]PHYA_rgmii_rd,
  input PHYA_rgmii_rx_ctl,
  input PHYA_rgmii_rxc,
  output [3:0]PHYA_rgmii_td,
  output PHYA_rgmii_tx_ctl,
  output PHYA_rgmii_txc,
  output [0:0]phy_rst_n_0
);

  //
  // Clock and reset
  // (* MARK_DEBUG="true" *)
  wire pipe_mmcm_rst_n;
  wire user_clk;
  wire user_reset;
  //(* MARK_DEBUG="true" *) 
   wire user_lnk_up;
  wire led_0;
  wire led_2;
  wire led_3;
  //
  // Transmit
  //
  wire s_axis_tx_tready;
  wire [3:0] s_axis_tx_tuser;
  //(* MARK_DEBUG="true" *) 
  wire [C_DATA_WIDTH - 1 : 0] s_axis_tx_tdata;
  wire [KEEP_WIDTH - 1 : 0] s_axis_tx_tkeep;
  wire s_axis_tx_tlast;
  wire s_axis_tx_tvalid;

  //
  // Receive
  //
  //(* MARK_DEBUG="true" *) 
  wire [C_DATA_WIDTH - 1 : 0] m_axis_rx_tdata;
  wire [KEEP_WIDTH - 1 : 0] m_axis_rx_tkeep;
  wire m_axis_rx_tlast;
  wire m_axis_rx_tvalid;
  wire m_axis_rx_tready;
  wire [21:0] m_axis_rx_tuser;
  //wire sys_rst_n;

  //
  // Common
  //
  wire tx_cfg_gnt;
  wire rx_np_ok;
  wire rx_np_req;
  wire cfg_turnoff_ok;
  wire cfg_trn_pending;
  wire cfg_pm_halt_aspm_l0s;
  wire cfg_pm_halt_aspm_l1;
  wire cfg_pm_force_state_en;
  wire [1:0] cfg_pm_force_state;
  wire cfg_pm_wake;
  wire [63:0] cfg_dsn;

  //
  // Flow vontrol
  //
  wire [2:0] fc_sel;

  //
  // Configuration interface
  //
  wire cfg_err_ecrc;
  wire cfg_err_cor;
  wire cfg_err_atomic_egress_blocked;
  wire cfg_err_internal_cor;
  wire cfg_err_malformed;
  wire cfg_err_mc_blocked;
  wire cfg_err_poisoned;
  wire cfg_err_norecovery;
  wire cfg_err_acs;
  wire cfg_err_internal_uncor;
  wire cfg_err_ur;
  wire cfg_err_cpl_timeout;
  wire cfg_err_cpl_abort;
  wire cfg_err_cpl_unexpect;
  wire cfg_err_posted;
  wire cfg_err_locked;
  wire [47:0] cfg_err_tlp_cpl_header;
  wire [127:0] cfg_err_aer_headerlog;
  wire [4:0] cfg_aer_interrupt_msgnum;
  wire cfg_interrupt;
  wire cfg_interrupt_assert;
  wire [7:0] cfg_interrupt_di;
  wire cfg_interrupt_stat;
  wire [4:0] cfg_pciecap_interrupt_msgnum;
  wire cfg_to_turnoff;
  wire [7:0] cfg_bus_number;
  wire [4:0] cfg_device_number;
  wire [2:0] cfg_function_number;
  //(* MARK_DEBUG="true" *) 
  wire [31:0] cfg_mgmt_di;
  //(* MARK_DEBUG="true" *) 
  wire [31:0] cfg_mgmt_do;
  wire [3:0] cfg_mgmt_byte_en;
  wire [9:0] cfg_mgmt_dwaddr;
  wire cfg_mgmt_wr_en;
  wire cfg_mgmt_rd_en;
  wire cfg_mgmt_wr_readonly;
  wire cfg_mgmt_rd_wr_done;  

  //
  // Physical layer control and status interface
  //
  wire pl_directed_link_auton;
  wire [1:0] pl_directed_link_change;
  wire pl_directed_link_speed;
  wire [1:0] pl_directed_link_width;
  wire pl_upstream_prefer_deemph;
  wire pl_phy_lnk_up;

  //
  // System interface
  //
  wire sys_rst_n_c;
  
  wire sys_clk;

  //
  // Register declaration
  //
  
  reg user_reset_q;
  reg user_lnk_up_q;
  reg [25:0] user_clk_heartbeat = 'h0;
  
  //
  // GPIO to SoC
  //
  wire [31:0] gpio_in;
  wire [31:0] gpio_debug;
  wire [15:0] device_id;
  
  //
  // Local parameters
  //
  localparam TCQ = 1;
  localparam USER_CLK_FREQ = 1;
  localparam USER_CLK2_DIV2 = "FALSE";
  localparam USERCLK2_FREQ = (USER_CLK2_DIV2 == "TRUE") ? (USER_CLK_FREQ == 4) ? 3 : (USER_CLK_FREQ == 3) ? 2 : USER_CLK_FREQ: USER_CLK_FREQ;
  wire sys_rst;
  
  //
  // PCIe Round-trip Latency Measurement Signals
  //
  (* MARK_DEBUG="true" *) reg [31:0] latency_counter;        // Latency counter (counts between TX and RX)
  (* MARK_DEBUG="true" *) reg [31:0] current_tlp_latency;    // Current TLP round-trip latency
  (* MARK_DEBUG="true" *) reg [31:0] max_tlp_latency;        // Maximum observed latency
  (* MARK_DEBUG="true" *) reg [31:0] min_tlp_latency;        // Minimum observed latency
  (* MARK_DEBUG="true" *) reg [31:0] tlp_count;              // Total number of TLPs processed
  (* MARK_DEBUG="true" *) reg [63:0] total_latency;          // Sum of all latencies for average calculation
  (* MARK_DEBUG="true" *) reg [31:0] last_5_latencies[4:0];  // Store last 5 latency measurements
  
  reg counting_enabled;                                      // Flag indicating latency counting is active
  reg tx_tlp_detected;                                       // Flag indicating TX TLP was detected
  reg rx_tlp_detected;                                       // Flag indicating RX TLP was detected
  reg [2:0] latency_index;                                   // Index for storing last 5 latencies
  
  IBUF sys_reset_n_ibuf(.O(sys_rst_n_c), .I(sys_rst_n));

  IBUFDS_GTE2 refclk_ibuf(.O(sys_clk), .ODIV2(), .I(sys_clk_p), .CEB(1'b0), .IB(sys_clk_n));
  
  reg[25:0] testCLK; // (* MARK_DEBUG="true" *)
  reg testWire;
  (* MARK_DEBUG="true" *)
  wire [5:0] pl_ltssm_state;
  
  // LEDs output buffers
  OBUF led_0_obuf (.O(led_0), .I(!user_reset)); // T16 LED4
  OBUF led_2_obuf (.O(led_2), .I(user_lnk_up)); // LED 6
  //OBUF led_3_obuf (.O(led_3), .I(user_clk_heartbeat[25])); // LED7
  OBUF led_3_obuf (.O(led_3), .I(testCLK[25]));
  //OBUF led_3_obuf (.O(led_3), .I(testWire));

  // Create a Clock Heartbeat on LED #3
  reg init;
  always @(posedge sys_clk) begin

    testCLK <= testCLK + 1'b1;

  end

  //
  // PCIe Round-trip Latency Measurement Logic
  //
  always @(posedge user_clk) begin
    if (user_reset) begin
      latency_counter <= 32'h0;
      current_tlp_latency <= 32'h0;
      max_tlp_latency <= 32'h0;
      min_tlp_latency <= 32'hFFFFFFFF;
      tlp_count <= 32'h0;
      total_latency <= 64'h0;
      counting_enabled <= 1'b0;
      tx_tlp_detected <= 1'b0;
      rx_tlp_detected <= 1'b0;
      latency_index <= 3'b0;
      
      // Initialize last 5 latencies array
      last_5_latencies[0] <= 32'h0;
      last_5_latencies[1] <= 32'h0;
      last_5_latencies[2] <= 32'h0;
      last_5_latencies[3] <= 32'h0;
      last_5_latencies[4] <= 32'h0;
      
    end else begin
      
      // Detect TX TLP start (s_axis_tx becomes valid and ready - TLP request sent)
      if (s_axis_tx_tvalid && s_axis_tx_tready && !counting_enabled) begin
        latency_counter <= 32'h0;        // Reset counter
        counting_enabled <= 1'b1;       // Start counting
        tx_tlp_detected <= 1'b1;
      end else begin
        tx_tlp_detected <= 1'b0;
      end
      
      // Increment counter when counting is enabled
      if (counting_enabled) begin
        latency_counter <= latency_counter + 1'b1;
      end
      
      // Detect RX TLP completion (m_axis_rx receives last data - TLP response received)
      if (m_axis_rx_tvalid && m_axis_rx_tready && m_axis_rx_tlast && counting_enabled) begin
        counting_enabled <= 1'b0;       // Stop counting
        rx_tlp_detected <= 1'b1;
        
        // Save current latency measurement
        current_tlp_latency <= latency_counter;
        
        // Update statistics
        tlp_count <= tlp_count + 1'b1;
        total_latency <= total_latency + latency_counter;
        
        // Update max latency
        if (latency_counter > max_tlp_latency) begin
          max_tlp_latency <= latency_counter;
        end
        
        // Update min latency (only after first measurement)
        if ((latency_counter < min_tlp_latency) && (tlp_count > 0)) begin
          min_tlp_latency <= latency_counter;
        end else if (tlp_count == 0) begin
          min_tlp_latency <= latency_counter;  // First measurement
        end
        
        // Store in last 5 latencies circular buffer
        last_5_latencies[latency_index] <= latency_counter;
        if (latency_index == 3'd4) begin
          latency_index <= 3'd0;
        end else begin
          latency_index <= latency_index + 1'b1;
        end
        
      end else begin
        rx_tlp_detected <= 1'b0;
      end
      
      // Handle timeout case (optional - reset counting after too many cycles)
      if (counting_enabled && (latency_counter >= 32'hFFFFF000)) begin
        counting_enabled <= 1'b0;  // Stop counting on timeout
        latency_counter <= 32'h0;
      end
      
    end
  end

  always @(posedge user_clk) begin
  
    user_reset_q <= user_reset;
    user_lnk_up_q <= user_lnk_up;
    
  end

  assign pipe_mmcm_rst_n = 1'b1;
  assign cfg_turnoff_ok = 1'b0;
  
  // completer address
  assign device_id = { cfg_bus_number, cfg_device_number, cfg_function_number };
  
  // GPIO input - Include latency statistics in GPIO debug
  assign gpio_in = { 16'h0, device_id };
  
  //
  // PCI Express endpoint shared logic wrapper
  //
  pcie_7x_0_support #
  (  
    .LINK_CAP_MAX_LINK_WIDTH( 1 ),              // PCIe Lane Width
    .KEEP_WIDTH( KEEP_WIDTH ),                  // TSTRB width
    .PCIE_REFCLK_FREQ( REF_CLK_FREQ ),          // PCIe reference clock frequency
    .PCIE_USERCLK1_FREQ( USER_CLK_FREQ + 1 ),   // PCIe user clock 1 frequency
    .PCIE_USERCLK2_FREQ( USERCLK2_FREQ + 1 ),   // PCIe user clock 2 frequency             
    .PCIE_USE_MODE("3.0"),                      // PCIe use mode
    .PCIE_GT_DEVICE("GTX")                      // PCIe GT device
  ) 
  pcie_7x_0_support_i
  (
    // PCI Express transmit
    .pci_exp_txn( pci_exp_txn ),
    .pci_exp_txp( pci_exp_txp ),

    // PCI Express receive
    .pci_exp_rxn( pci_exp_rxn ),
    .pci_exp_rxp( pci_exp_rxp ),

    // Clocking sharing    
    .pipe_pclk_sel_slave( 1'b0 ),
    .pipe_mmcm_rst_n( pipe_mmcm_rst_n ),

    // AXI-S Common
    .user_clk_out( user_clk ),
    .user_reset_out( user_reset ),
    .user_lnk_up( user_lnk_up ),

    // AXI-S transmit
    .s_axis_tx_tready( s_axis_tx_tready ),
    .s_axis_tx_tdata( s_axis_tx_tdata ),
    .s_axis_tx_tkeep( s_axis_tx_tkeep ),
    .s_axis_tx_tuser( s_axis_tx_tuser ),
    .s_axis_tx_tlast( s_axis_tx_tlast ),
    .s_axis_tx_tvalid( s_axis_tx_tvalid ),

    // AXI-S receive
    .m_axis_rx_tdata( m_axis_rx_tdata ),
    .m_axis_rx_tkeep( m_axis_rx_tkeep ),
    .m_axis_rx_tlast( m_axis_rx_tlast ),
    .m_axis_rx_tvalid( m_axis_rx_tvalid ),
    .m_axis_rx_tready( m_axis_rx_tready ),
    .m_axis_rx_tuser( m_axis_rx_tuser ),

    // Flow control   
    .fc_sel( fc_sel ),

    // Management interface
    .cfg_mgmt_di( cfg_mgmt_di ),
    .cfg_mgmt_do( cfg_mgmt_do ),
    .cfg_mgmt_byte_en( cfg_mgmt_byte_en ),
    .cfg_mgmt_dwaddr( cfg_mgmt_dwaddr ),
    .cfg_mgmt_wr_en( cfg_mgmt_wr_en ),
    .cfg_mgmt_rd_en( cfg_mgmt_rd_en ),
    .cfg_mgmt_wr_readonly( cfg_mgmt_wr_readonly ),
    .cfg_mgmt_rd_wr_done( cfg_mgmt_rd_wr_done ),
    .cfg_mgmt_wr_rw1c_as_rw( 1'b0 ),

    // Error reporting interface
    .cfg_err_ecrc( cfg_err_ecrc ),
    .cfg_err_ur( cfg_err_ur ),
    .cfg_err_cpl_timeout( cfg_err_cpl_timeout ),
    .cfg_err_cpl_unexpect( cfg_err_cpl_unexpect ),
    .cfg_err_cpl_abort( cfg_err_cpl_abort ),
    .cfg_err_posted( cfg_err_posted ),
    .cfg_err_cor( cfg_err_cor ),
    .cfg_err_atomic_egress_blocked( cfg_err_atomic_egress_blocked ),
    .cfg_err_internal_cor( cfg_err_internal_cor ),
    .cfg_err_malformed( cfg_err_malformed ),
    .cfg_err_mc_blocked( cfg_err_mc_blocked ),
    .cfg_err_poisoned( cfg_err_poisoned ),
    .cfg_err_norecovery( cfg_err_norecovery ),
    .cfg_err_tlp_cpl_header( cfg_err_tlp_cpl_header ),
    .cfg_err_locked( cfg_err_locked ),
    .cfg_err_acs( cfg_err_acs ),
    .cfg_err_internal_uncor( cfg_err_internal_uncor ),

    // AER interface 
    .cfg_err_aer_headerlog( cfg_err_aer_headerlog ),
    .cfg_aer_interrupt_msgnum( cfg_aer_interrupt_msgnum ),

    // AXI common
    .tx_cfg_gnt( tx_cfg_gnt ),
    .rx_np_ok( rx_np_ok ),
    .rx_np_req( rx_np_req ),
    .cfg_trn_pending( cfg_trn_pending ),
    .cfg_pm_halt_aspm_l0s( cfg_pm_halt_aspm_l0s ),
    .cfg_pm_halt_aspm_l1( cfg_pm_halt_aspm_l1 ),
    .cfg_pm_force_state_en( cfg_pm_force_state_en ),
    .cfg_pm_force_state( cfg_pm_force_state ),
    .cfg_dsn( cfg_dsn ),
    .cfg_turnoff_ok( cfg_turnoff_ok ),
    .cfg_pm_wake( cfg_pm_wake ),
  
    // RP only
    .cfg_pm_send_pme_to( 1'b0 ),
    .cfg_ds_bus_number( 8'b0 ),
    .cfg_ds_device_number( 5'b0 ),
    .cfg_ds_function_number( 3'b0 ),
    
    // EP Only
    .cfg_interrupt( cfg_interrupt ),
    .cfg_interrupt_assert( cfg_interrupt_assert ),
    .cfg_interrupt_di( cfg_interrupt_di ),    
    .cfg_interrupt_stat( cfg_interrupt_stat ),
    .cfg_pciecap_interrupt_msgnum( cfg_pciecap_interrupt_msgnum ),

    // Configuration interface     
    .cfg_to_turnoff( cfg_to_turnoff ),
    .cfg_bus_number( cfg_bus_number ),
    .cfg_device_number( cfg_device_number ),
    .cfg_function_number( cfg_function_number ),    

    // Physical layer control and status interface
    .pl_directed_link_change( pl_directed_link_change ),
    .pl_directed_link_width( pl_directed_link_width ),
    .pl_directed_link_speed( pl_directed_link_speed ),
    .pl_directed_link_auton( pl_directed_link_auton ),
    .pl_upstream_prefer_deemph( pl_upstream_prefer_deemph ),    
    .pl_transmit_hot_rst( 1'b0 ),
    .pl_phy_lnk_up(pl_phy_lnk_up),
    .pl_downstream_deemph_source( 1'b0 ),
    .pl_ltssm_state(pl_ltssm_state),

    // PCI Express DRP interface
    .pcie_drp_clk( 1'b1 ),
    .pcie_drp_en( 1'b0 ),
    .pcie_drp_we( 1'b0 ),
    .pcie_drp_addr( 9'h0 ),
    .pcie_drp_di( 16'h0 ),

    // System interface
    .sys_clk( sys_clk ),
    .sys_rst_n( sys_rst_n_c )
  );
  
  // GPIO debug includes latency information for monitoring
  assign gpio_debug = current_tlp_latency;

  assign fc_sel = 3'b0;

  assign tx_cfg_gnt = 1'b1;                        // Always allow transmission of Config traffic within block
  assign rx_np_ok = 1'b1;                          // Allow Reception of Non-posted Traffic
  assign rx_np_req = 1'b1;                         // Always request Non-posted Traffic if available
  assign cfg_pm_wake = 1'b0;                       // Never direct the core to send a PM_PME Message
  assign cfg_trn_pending = 1'b0;                   // Never set the transaction pending bit in the Device Status Register
  assign cfg_pm_halt_aspm_l0s = 1'b0;              // Allow entry into L0s
  assign cfg_pm_halt_aspm_l1 = 1'b0;               // Allow entry into L1
  assign cfg_pm_force_state_en  = 1'b0;            // Do not qualify cfg_pm_force_state
  assign cfg_pm_force_state  = 2'b00;              // Do not move force core into specific PM state  
  assign s_axis_tx_tuser[0] = 1'b0;                // Unused for V6
  assign s_axis_tx_tuser[1] = 1'b0;                // Error forward packet
  assign s_axis_tx_tuser[2] = 1'b0;                // Stream packet

  assign cfg_err_cor = 1'b0;                       // Never report Correctable Error
  assign cfg_err_ur = 1'b0;                        // Never report UR
  assign cfg_err_ecrc = 1'b0;                      // Never report ECRC Error
  assign cfg_err_cpl_timeout = 1'b0;               // Never report Completion Timeout
  assign cfg_err_cpl_abort = 1'b0;                 // Never report Completion Abort
  assign cfg_err_cpl_unexpect = 1'b0;              // Never report unexpected completion
  assign cfg_err_posted = 1'b0;                    // Never qualify cfg_err_* inputs
  assign cfg_err_locked = 1'b0;                    // Never qualify cfg_err_ur or cfg_err_cpl_abort
  assign cfg_err_atomic_egress_blocked = 1'b0;     // Never report Atomic TLP blocked
  assign cfg_err_internal_cor = 1'b0;              // Never report internal error occurred
  assign cfg_err_malformed = 1'b0;                 // Never report malformed error
  assign cfg_err_mc_blocked = 1'b0;                // Never report multi-cast TLP blocked
  assign cfg_err_poisoned = 1'b0;                  // Never report poisoned TLP received
  assign cfg_err_norecovery = 1'b0;                // Never qualify cfg_err_poisoned or cfg_err_cpl_timeout
  assign cfg_err_acs = 1'b0;                       // Never report an ACS violation
  assign cfg_err_internal_uncor = 1'b0;            // Never report internal uncorrectable error
  assign cfg_err_aer_headerlog = 128'h0;           // Zero out the AER Header Log
  assign cfg_aer_interrupt_msgnum = 5'b00000;      // Zero out the AER Root Error Status Register
  assign cfg_err_tlp_cpl_header = 48'h0;           // Zero out the header information

  assign cfg_interrupt_stat = 1'b0;                // Never set the Interrupt Status bit
  assign cfg_pciecap_interrupt_msgnum = 5'b00000;  // Zero out Interrupt Message Number
  assign cfg_interrupt_assert = 1'b0;              // Always drive interrupt de-assert
  assign cfg_interrupt = 1'b0;                     // Never drive interrupt by qualifying cfg_interrupt_assert
  assign cfg_interrupt_di = 8'b0;                  // Do not set interrupt fields

  assign pl_directed_link_change = 2'b00;          // Never initiate link change
  assign pl_directed_link_width = 2'b00;           // Zero out directed link width
  assign pl_directed_link_speed = 1'b0;            // Zero out directed link speed
  assign pl_directed_link_auton = 1'b0;            // Zero out link autonomous input
  assign pl_upstream_prefer_deemph = 1'b1;         // Zero out preferred de-emphasis of upstream port

  assign cfg_mgmt_di = 32'h0;                      // Zero out CFG MGMT input data bus
  assign cfg_mgmt_byte_en = 4'h0;                  // Zero out CFG MGMT byte enables
  assign cfg_mgmt_wr_en = 1'b0;                    // Do not write CFG space
  assign cfg_mgmt_wr_readonly = 1'b0;              // Never treat RO bit as RW  

  // Assign the input DSN
  assign cfg_dsn = { `PCI_EXP_EP_DSN_2, 
                     `PCI_EXP_EP_DSN_1 };                  

  //
  // Config space access
  //  

  reg m_axis_cfg_tx_tready = 1'b1;
  reg s_axis_cfg_rx_tlast = 1'b1;
  reg [3:0] s_axis_cfg_rx_tkeep = 4'b1111;
  
  wire [31:0] m_axis_cfg_tx_tdata;
  
  assign cfg_mgmt_dwaddr = m_axis_cfg_tx_tdata[9:0];

  //
  // Block design instance
  //
  system_wrapper zynq_soc_i(

    // External memory
    .DDR_addr( DDR_addr ),
    .DDR_ba( DDR_ba ),
    .DDR_cas_n( DDR_cas_n ),
    .DDR_ck_n( DDR_ck_n ),
    .DDR_ck_p( DDR_ck_p ),
    .DDR_cke( DDR_cke ),
    .DDR_cs_n( DDR_cs_n ),
    .DDR_dm( DDR_dm ),
    .DDR_dq( DDR_dq ),
    .DDR_dqs_n( DDR_dqs_n ),
    .DDR_dqs_p( DDR_dqs_p ),
    .DDR_odt( DDR_odt ),
    .DDR_ras_n( DDR_ras_n ),
    .DDR_reset_n( DDR_reset_n ),
    .DDR_we_n( DDR_we_n ),

    // Fixed I/O
    .FIXED_IO_ddr_vrn( FIXED_IO_ddr_vrn ),
    .FIXED_IO_ddr_vrp( FIXED_IO_ddr_vrp ),
    .FIXED_IO_mio( FIXED_IO_mio ),
    .FIXED_IO_ps_clk( FIXED_IO_ps_clk ),
    .FIXED_IO_ps_porb( FIXED_IO_ps_porb ),
    .FIXED_IO_ps_srstb( FIXED_IO_ps_srstb ),

    // GPIO
    .GPIO_0_tri_i( gpio_in ),
    .GPIO_1_tri_i(gpio_debug),
    
    //HDMI
     .HDMI_TX_CLK_N(HDMI_TX_CLK_N),
     .HDMI_TX_CLK_P(HDMI_TX_CLK_P),
     .HDMI_TX_N(HDMI_TX_N),
     .HDMI_TX_P(HDMI_TX_P),
     
     // PHYA
     .PHYA_mdio_mdc(PHYA_mdio_mdc),
     .PHYA_mdio_mdio_io(PHYA_mdio_mdio_io),
     .PHYA_rgmii_rd(PHYA_rgmii_rd),
     .PHYA_rgmii_rx_ctl(PHYA_rgmii_rx_ctl),
     .PHYA_rgmii_rxc(PHYA_rgmii_rxc),
     .PHYA_rgmii_td(PHYA_rgmii_td),
     .PHYA_rgmii_tx_ctl(PHYA_rgmii_tx_ctl),
     .PHYA_rgmii_txc(PHYA_rgmii_txc),
     // reset
     .phy_rst_n_0(phy_rst_n_0),
    
    // TLP transmit
    .M_AXIS_0_tdata( s_axis_tx_tdata ),
    .M_AXIS_0_tkeep( s_axis_tx_tkeep ),
    .M_AXIS_0_tlast( s_axis_tx_tlast ),
    .M_AXIS_0_tready( s_axis_tx_tready ),
    .M_AXIS_0_tvalid( s_axis_tx_tvalid ),

    // TLP receive
    .S_AXIS_0_tdata( m_axis_rx_tdata ),
    .S_AXIS_0_tkeep( m_axis_rx_tkeep ),
    .S_AXIS_0_tlast( m_axis_rx_tlast ),
    .S_AXIS_0_tready( m_axis_rx_tready ),
    .S_AXIS_0_tvalid( m_axis_rx_tvalid ),

    // Configuration space data out
    .M_AXIS_1_tdata( m_axis_cfg_tx_tdata ),
    .M_AXIS_1_tready( m_axis_cfg_tx_tready ),
    .M_AXIS_1_tvalid( cfg_mgmt_rd_en ),

    // Configuration space data in
    .S_AXIS_1_tdata( cfg_mgmt_do ),
    .S_AXIS_1_tkeep( s_axis_cfg_rx_tkeep ),
    .S_AXIS_1_tlast( s_axis_cfg_rx_tlast ),
    .S_AXIS_1_tvalid( cfg_mgmt_rd_wr_done ),

    // Clocks and reset
    .m_axis_aclk_0( user_clk ),
    .s_axis_aclk_0( user_clk ),
    .s_axis_aresetn_0( ~user_reset )
  );
  
endmodule