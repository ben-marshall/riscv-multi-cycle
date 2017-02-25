
//
// RISCV multi-cycle implementation.
//
// Module:      rvm_core_axi4
//
// Description: A wrapper around the rvm_core module which turns the SRAM
//              style interface into an AXI4 bus master.
//

`include "rvm_constants.v"

module rvm_core_axi4(

// Global signals Used for AXI and the core.
input         ACLK     , // Master clock for the AXI interface.
input         ARESETn  , // Active low asynchronous reset.

// AXI Write Address Channel
output        AWID     , // Master Write Address ID. Tied to zero
output [31:0] AWADDR   , // Master Write address.
output [ 7:0] AWLEN    , // Master Burst Length (transfers / burst).
output [ 2:0] AWSIZE   , // Master Burst Size   (size of transfer).
output [ 1:0] AWBURST  , // Master Burst Type.
output        AWLOCK   , // Master lock type.
output [ 3:0] AWCACHE  , // Master memory type / cache characteristics.
output [ 2:0] AWPROT   , // Master memory protection level.
output [ 3:0] AWQOS    , // Master Quality of Service.
output [ 4:0] AWREGION , // Master Region identifier.
output        AWUSER   , // Master user signal.
output        AWVALID  , // Master Write address valid.
input         AWREADY  , // Slave Write address ready.

// AXI Write Data Channel
output        WID      , // Master Write ID tag. Tied to zero.
output [31:0] WDATA    , // Master Write data.
output [ 3:0] WSTRB    , // Master Write strobes. (Byte enable)
output        WLAST    , // Master Write last.
output        WUSER    , // Master User signal.
output        WVALID   , // Write Valid.
input         WREADY   , // Slave Write ready.

// AXI4 Write Response Channel
input         BID      , // Slave Response ID tag. Tied to zero
input  [ 1:0] BRESP    , // Slave Write response.
input         BUSER    , // Slave User signal.
input         BVALID   , // Slave Write response valid.
output        BREADY   , // Master Response ready.

// AXI4 Read Address Channel
output        ARID     , // Master Read address ID. Tied to zero
output [31:0] ARADDR   , // Master Read address.
output [ 7:0] ARLEN    , // Master Burst length.
output [ 2:0] ARSIZE   , // Master Burst size.
output [ 1:0] ARBURST  , // Master Burst type.
output        ARLOCK   , // Master Lock type.
output [ 3:0] ARCACHE  , // Master Memory type.
output [ 2:0] ARPROT   , // Master Protection type.
output [ 3:0] ARQOS    , // Master Quality of Service, QoS.
output [ 4:0] ARREGION , // Master Region identifier.
output        ARUSER   , // Master User signal.
output        ARVALID  , // Master Read address valid.
input         ARREADY  , // Slave Read address ready.

// AXI4 Read Data Channel 
input         RID      , // Slave Read ID tag. Tied to zero
input  [31:0] RDATA    , // Slave Read data.
input  [ 1:0] RRESP    , // Slave Read response.
input         RLAST    , // Slave Read last.
input         RUSER    , // Slave User signal.
input         RVALID   , // Slave Read valid.
output        RREADY     // Master Read ready.

);

wire [31:0]  mem_addr,           // Memory address lines
wire [31:0]  mem_rdata,          // Memory read data
wire [31:0]  mem_wdata,          // Memory write data
wire         mem_c_en,           // Memory chip enable
wire         mem_w_en,           // Memory write enable
wire [ 3:0]  mem_b_en,           // Memory byte enable
wire         mem_error,          // Memory error indicator
wire         mem_stall           // Memory stall indicator

//
// Top level instantiation of the core.
//
rvm_core i_rvm_core(
.clk         (ACLK     ), // System level clock.
.resetn      (ARESETn  ), // Asynchronous active low reset.
.mem_addr    (mem_addr ), // Memory address lines
.mem_rdata   (mem_rdata), // Memory read data
.mem_wdata   (mem_wdata), // Memory write data
.mem_c_en    (mem_c_en ), // Memory chip enable
.mem_w_en    (mem_w_en ), // Memory write enable
.mem_b_en    (mem_b_en ), // Memory byte enable
.mem_error   (mem_error), // Memory error indicator
.mem_stall   (mem_stall)  // Memory stall indicator
);

axi4master i_axi4master( 
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
.RREADY   (RREADY   ), // Master Read ready.
.mem_addr (mem_addr ), // SRAM Memory address lines
.mem_rdata(mem_rdata), // SRAM Memory read data
.mem_wdata(mem_wdata), // SRAM Memory write data
.mem_c_en (mem_c_en ), // SRAM Memory chip enable
.mem_w_en (mem_w_en ), // SRAM Memory write enable
.mem_b_en (mem_b_en ), // SRAM Memory byte enable
.mem_error(mem_error), // SRAM Memory error indicator
.mem_stall(mem_stall)  // SRAM Memory stall indicator
);                   


endmodule
