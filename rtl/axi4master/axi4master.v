
//
// RISCV multi-cycle implementation.
//
// Module:      axi4master
//
// Description: Takes in an SRAM interface with stall and error signals and
//              routes them onto an AXI4 master bus.
//

module axi4master #(
)(                   

// AXI4 Global signals
input ACLK      ,   // Master clock for the AXI interface.
input ARESETn   ,   // Active low asynchronous reset.

// AXI Write Address Channel
output AWID     ,   // Master Write Address ID.
output [31:0] AWADDR   ,   // Master Write address.
output AWLEN    ,   // Master Burst Length (transfers / burst).
output AWSIZE   ,   // Master Burst Size   (size of transfer).
output AWBURST  ,   // Master Burst Type.
output AWLOCK   ,   // Master lock type.
output AWCACHE  ,   // Master memory type / cache characteristics.
output AWPROT   ,   // Master memory protection level.
output AWQOS    ,   // Master Quality of Service.
output AWREGION ,   // Master Region identifier.
output AWUSER   ,   // Master user signal.
output AWVALID  ,   // Master Write address valid.
input  AWREADY  ,   // Slave Write address ready.

// AXI Write Data Channel
output WID      ,   // Master Write ID tag.
output WDATA    ,   // Master Write data.
output WSTRB    ,   // Master Write strobes.
output WLAST    ,   // Master Write last.
output WUSER    ,   // Master User signal.
output WVALID   ,   // Write Valid.
input  WREADY   ,   // Slave Write ready.

// AXI4 Write Response Channel
input  BID      ,   // Slave Response ID tag.
input  BRESP    ,   // Slave Write response.
input  BUSER    ,   // Slave User signal.
input  BVALID   ,   // Slave Write response valid.
output BREADY   ,   // Master Response ready.

// AXI4 Read Address Channel
output ARID     ,   // Master Read address ID.
output [31:0] ARADDR   ,   // Master Read address.
output ARLEN    ,   // Master Burst length.
output ARSIZE   ,   // Master Burst size.
output ARBURST  ,   // Master Burst type.
output ARLOCK   ,   // Master Lock type.
output ARCACHE  ,   // Master Memory type.
output ARPROT   ,   // Master Protection type.
output ARQOS    ,   // Master Quality of Service, QoS.
output ARREGION ,   // Master Region identifier.
output ARUSER   ,   // Master User signal.
output ARVALID  ,   // Master Read address valid.
input  ARREADY  ,   // Slave Read address ready.

// AXI4 Read Data Channel 
output RID      ,   // Slave Read ID tag.
output RDATA    ,   // Slave Read data.
output RRESP    ,   // Slave Read response.
output RLAST    ,   // Slave Read last.
output RUSER    ,   // Slave User signal.
output RVALID   ,   // Slave Read valid.
input  RREADY   ,   // Master Read ready.
                     
// SRAM style requestor interface
input  [31:0] mem_addr  , // SRAM Memory address lines
output [31:0] mem_rdata , // SRAM Memory read data
input  [31:0] mem_wdata , // SRAM Memory write data
input         mem_c_en  , // SRAM Memory chip enable
input         mem_w_en  , // SRAM Memory write enable
input  [ 3:0] mem_b_en  , // SRAM Memory byte enable
output        mem_error , // SRAM Memory error indicator
output        mem_stall   // SRAM Memory stall indicator

);                   
                     
//-----------------------------------------------------------------------------
// Auixiliary signals for internal use.
//

// Should we be performing a read or write transaction
wire read_txn   = mem_c_en && !mem_w_en;
wire write_txn  = mem_c_en &&  mem_w_en;


//-----------------------------------------------------------------------------
// Write Address channel handling
//

assign AWADDR = {32{read_txn}} & mem_addr;

//-----------------------------------------------------------------------------
// Write Data channel handling
//


//-----------------------------------------------------------------------------
// Write Response channel handling
//


//-----------------------------------------------------------------------------
// Read Address channel handling
//

assign ARADDR = {32{read_txn}} & mem_addr;

//-----------------------------------------------------------------------------
// Read Response channel handling
//
                     
endmodule            
                     
                     
                     
