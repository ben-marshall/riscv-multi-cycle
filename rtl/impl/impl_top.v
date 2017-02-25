
// 
// Module: impl_top
// 
// Notes:
// - Top level module to be used in an implementation.
// - To be used in conjunction with the constraints/defaults.xdc file.
// - Ports can be (un)commented depending on whether they are being used.
// - The constraints file contains a complete list of the available ports
//   including the chipkit/Arduino pins.
//

`define SKIP_CALIB

module impl_top(
    input   wire clk        ,   // Top level system clock input.
    input   wire [3:0] sw   ,   // Slide switches.
    output  wire [2:0] rgb0 ,   // RGB Led 0.
    output  wire [2:0] rgb1 ,   // RGB Led 1.
    output  wire [2:0] rgb2 ,   // RGB Led 2.
    output  wire [2:0] rgb3 ,   // RGB Led 3.
    output  wire [2:0] led  ,   // Green Leds
    input   wire [3:0] btn  ,   // Push to make buttons.
    input   wire uart_rxd   ,   // UART Recieve pin.
    output  wire uart_txd   ,   // UART Transmit pin.
    
    // DDR3 Inouts
    inout [15:0]       ddr3_dq,
    inout [1:0]        ddr3_dqs_n,
    inout [1:0]        ddr3_dqs_p,
    // DDR3 Outputs
    output [13:0]     ddr3_addr,
    output [2:0]        ddr3_ba,
    output            ddr3_ras_n,
    output            ddr3_cas_n,
    output            ddr3_we_n,
    output            ddr3_reset_n,
    output [0:0]       ddr3_ck_p,
    output [0:0]       ddr3_ck_n,
    output [0:0]       ddr3_cke,
    output [0:0]        ddr3_cs_n,
    output [1:0]     ddr3_dm,
    output [0:0]       ddr3_odt
);

// Global signals Used for AXI and the core.
wire         ACLK    = clk ; // Master clock for the AXI interface.
wire         ARESETn = sw[0]; // Active low asynchronous reset.

// AXI Write Address Channel
wire        AWID     ; // Master Write Address ID. Tied to zero
wire [31:0] AWADDR   ; // Master Write address.
wire [ 7:0] AWLEN    ; // Master Burst Length (transfers / burst).
wire [ 2:0] AWSIZE   ; // Master Burst Size   (size of transfer).
wire [ 1:0] AWBURST  ; // Master Burst Type.
wire        AWLOCK   ; // Master lock type.
wire [ 3:0] AWCACHE  ; // Master memory type / cache characteristics.
wire [ 2:0] AWPROT   ; // Master memory protection level.
wire [ 3:0] AWQOS    ; // Master Quality of Service.
wire [ 4:0] AWREGION ; // Master Region identifier.
wire        AWUSER   ; // Master user signal.
wire        AWVALID  ; // Master Write address valid.
wire         AWREADY  ; // Slave Write address ready.

// AXI Write Data Channel
wire        WID      ; // Master Write ID tag. Tied to zero.
wire [31:0] WDATA    ; // Master Write data.
wire [ 3:0] WSTRB    ; // Master Write strobes. (Byte enable)
wire        WLAST    ; // Master Write last.
wire        WUSER    ; // Master User signal.
wire        WVALID   ; // Write Valid.
wire         WREADY   ; // Slave Write ready.

// AXI4 Write Response Channel
wire         BID      ; // Slave Response ID tag. Tied to zero
wire  [ 1:0] BRESP    ; // Slave Write response.
wire         BUSER    ; // Slave User signal.
wire         BVALID   ; // Slave Write response valid.
wire        BREADY   ; // Master Response ready.

// AXI4 Read Address Channel
wire        ARID     ; // Master Read address ID. Tied to zero
wire [31:0] ARADDR   ; // Master Read address.
wire [ 7:0] ARLEN    ; // Master Burst length.
wire [ 2:0] ARSIZE   ; // Master Burst size.
wire [ 1:0] ARBURST  ; // Master Burst type.
wire        ARLOCK   ; // Master Lock type.
wire [ 3:0] ARCACHE  ; // Master Memory type.
wire [ 2:0] ARPROT   ; // Master Protection type.
wire [ 3:0] ARQOS    ; // Master Quality of Service, QoS.
wire [ 4:0] ARREGION ; // Master Region identifier.
wire        ARUSER   ; // Master User signal.
wire        ARVALID  ; // Master Read address valid.
wire         ARREADY  ; // Slave Read address ready.

// AXI4 Read Data Channel 
wire         RID      ; // Slave Read ID tag. Tied to zero
wire  [31:0] RDATA    ; // Slave Read data.
wire  [ 1:0] RRESP    ; // Slave Read response.
wire         RLAST    ; // Slave Read last.
wire         RUSER    ; // Slave User signal.
wire         RVALID   ; // Slave Read valid.
wire        RREADY    ; // Master Read ready.

rvm_core_axi4 i_rvm_core_axi4(
.ACLK     (ACLK     ), // Master clock for the AXI interface.
.ARESETn  (ARESETn  ), // Active low asynchronous reset.
.AWID     (AWID     ), // Master Write Address ID. Tied to zero
.AWADDR   (AWADDR   ), // Master Write address.
.AWLEN    (AWLEN    ), // Master Burst Length (transfers / burst).
.AWSIZE   (AWSIZE   ), // Master Burst Size   (size of transfer).
.AWBURST  (AWBURST  ), // Master Burst Type.
.AWLOCK   (AWLOCK   ), // Master lock type.
.AWCACHE  (AWCACHE  ), // Master memory type / cache characteristics.
.AWPROT   (AWPROT   ), // Master memory protection level.
.AWQOS    (AWQOS    ), // Master Quality of Service.
.AWREGION (AWREGION ), // Master Region identifier.
.AWUSER   (AWUSER   ), // Master user signal.
.AWVALID  (AWVALID  ), // Master Write address valid.
.AWREADY  (AWREADY  ), // Slave Write address ready.
.WID      (WID      ), // Master Write ID tag. Tied to zero.
.WDATA    (WDATA    ), // Master Write data.
.WSTRB    (WSTRB    ), // Master Write strobes. (Byte enable)
.WLAST    (WLAST    ), // Master Write last.
.WUSER    (WUSER    ), // Master User signal.
.WVALID   (WVALID   ), // Write Valid.
.WREADY   (WREADY   ), // Slave Write ready.
.BID      (BID      ), // Slave Response ID tag. Tied to zero
.BRESP    (BRESP    ), // Slave Write response.
.BUSER    (BUSER    ), // Slave User signal.
.BVALID   (BVALID   ), // Slave Write response valid.
.BREADY   (BREADY   ), // Master Response ready.
.ARID     (ARID     ), // Master Read address ID. Tied to zero
.ARADDR   (ARADDR   ), // Master Read address.
.ARLEN    (ARLEN    ), // Master Burst length.
.ARSIZE   (ARSIZE   ), // Master Burst size.
.ARBURST  (ARBURST  ), // Master Burst type.
.ARLOCK   (ARLOCK   ), // Master Lock type.
.ARCACHE  (ARCACHE  ), // Master Memory type.
.ARPROT   (ARPROT   ), // Master Protection type.
.ARQOS    (ARQOS    ), // Master Quality of Service, QoS.
.ARREGION (ARREGION ), // Master Region identifier.
.ARUSER   (ARUSER   ), // Master User signal.
.ARVALID  (ARVALID  ), // Master Read address valid.
.ARREADY  (ARREADY  ), // Slave Read address ready.
.RID      (RID      ), // Slave Read ID tag. Tied to zero
.RDATA    (RDATA    ), // Slave Read data.
.RRESP    (RRESP    ), // Slave Read response.
.RLAST    (RLAST    ), // Slave Read last.
.RUSER    (RUSER    ), // Slave User signal.
.RVALID   (RVALID   ), // Slave Read valid.
.RREADY   (RREADY   )  // Master Read ready.
);
  
wire [11:0] device_temp;
  
wire     mmcm_locked;
reg      aresetn;
wire     app_sr_active;
wire     app_ref_ack;
wire     app_zq_ack;
wire     app_rd_data_valid;
wire     app_rd_data;
 
  // skip calibration wires
  wire                          calib_tap_req;
  reg                           calib_tap_load;
  reg [6:0]                     calib_tap_addr;
  reg [7:0]                     calib_tap_val;
  reg                           calib_tap_load_done;


rvm_ddr3_mig i_rvm_ddr3_mig(
.ddr3_dq        (ddr3_dq     ),
.ddr3_dqs_n     (ddr3_dqs_n  ),
.ddr3_dqs_p     (ddr3_dqs_p  ),
.ddr3_addr      (ddr3_addr   ),
.ddr3_ba        (ddr3_ba     ),
.ddr3_ras_n     (ddr3_ras_n  ),
.ddr3_cas_n     (ddr3_cas_n  ),
.ddr3_we_n      (ddr3_we_n   ),
.ddr3_reset_n   (ddr3_reset_n),
.ddr3_ck_p      (ddr3_ck_p   ),
.ddr3_ck_n      (ddr3_ck_n   ),
.ddr3_cke       (ddr3_cke    ),
.ddr3_cs_n      (ddr3_cs_n   ),
.ddr3_dm        (ddr3_dm     ),
.ddr3_odt       (ddr3_odt    ),

// Application interface ports

.mmcm_locked            (mmcm_locked),
.aresetn                (resetn),
.app_sr_req             (1'b0),
.app_ref_req            (1'b0),
.app_zq_req             (1'b0),
.app_sr_active          (app_sr_active),
.app_ref_ack            (app_ref_ack),
.app_zq_ack             (app_zq_ack),

// Slave Interface Write Address Ports
.s_axi_awid             (AWID),
.s_axi_awaddr           (AWADDR),
.s_axi_awlen            (AWLEN),
.s_axi_awsize           (AWSIZE),
.s_axi_awburst          (AWBURST),
.s_axi_awlock           (AWLOCK),
.s_axi_awcache          (AWCACHE),
.s_axi_awprot           (AWPROT),
.s_axi_awqos            (4'H0),
.s_axi_awvalid          (AWVALID),
.s_axi_awready          (AWREADY),
// Slave Interface wRITE dATA pORTS
.s_axi_wdata            (WDATA),
.s_axi_wstrb            (WSTRB),
.s_axi_wlast            (WLAST),
.s_axi_wvalid           (WVALID),
.s_axi_wready           (WREADY),
// Slave Interface wRITE rESPONSE pORTS
.s_axi_bid              (BID),
.s_axi_bresp            (BRESP),
.s_axi_bvalid           (BVALID),
.s_axi_bready           (BREADY),
// Slave Interface rEAD aDDRESS pORTS
.s_axi_arid             (ARID),
.s_axi_araddr           (ARADDR),
.s_axi_arlen            (ARLEN),
.s_axi_arsize           (ARSIZE),
.s_axi_arburst          (ARBURST),
.s_axi_arlock           (ARLOCK),
.s_axi_arcache          (ARCACHE),
.s_axi_arprot           (ARPROT),
.s_axi_arqos            (4'H0),
.s_axi_arvalid          (ARVALID),
.s_axi_arready          (ARREADY),
// Slave Interface rEAD dATA pORTS
.s_axi_rid              (RID),
.s_axi_rdata            (RDATA),
.s_axi_rresp            (RRESP),
.s_axi_rlast            (RLAST),
.s_axi_rvalid           (RVALID),
.s_axi_rready           (RREADY),
// System Clock Ports
.sys_clk_p              (clk),
.sys_clk_n              (!clk),
// Reference Clock Ports
.clk_ref_p              (clk),
.clk_ref_n              (!clk),
.device_temp            (device_temp),
.sys_rst                (resetn)
);


endmodule

