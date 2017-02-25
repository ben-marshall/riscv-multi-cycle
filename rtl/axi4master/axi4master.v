
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
output        RREADY   , // Master Read ready.
                     
// SRAM style requestor interface
input  [31:0] mem_addr , // SRAM Memory address lines
output [31:0] mem_rdata, // SRAM Memory read data
input  [31:0] mem_wdata, // SRAM Memory write data
input         mem_c_en , // SRAM Memory chip enable
input         mem_w_en , // SRAM Memory write enable
input  [ 3:0] mem_b_en , // SRAM Memory byte enable
output        mem_error, // SRAM Memory error indicator
output        mem_stall  // SRAM Memory stall indicator

);                   
                     
//-----------------------------------------------------------------------------
// Auixiliary signals for internal use.
//

// Should we be performing a read or write transaction
wire read_txn   = mem_c_en && !mem_w_en;
wire write_txn  = mem_c_en &&  mem_w_en;

// Pipestage 1 wires
wire [3:0] s0_b_en = mem_b_en; // Stage 0 Byte Enable
wire       s0_txn  = mem_c_en; // Stage 0 Transaction in flight
wire       s0_w_en = mem_w_en; // Stage 0 Write enable

// Pipeline stage 1 wires.
reg [3:0] s1_b_en; // Stage 1 Byte Enable
reg       s1_txn ; // Stage 1 Transaction in flight
reg       s1_w_en; // Stage 1 Write enable

// Wait for a transaction to complete before progressing the pipeline.
wire      pipeline_wait;

//
// Responsible for progressing the transaction handling pipeline.
//
always @(posedge ACLK, negedge ARESETn) begin: p_progress_pipeline
    if(!ARESETn) begin
        s1_b_en <= 4'b0;
        s1_w_en <= 1'b0;
        s1_txn  <= 1'b0;
    end else if (!pipeline_wait) begin
        s1_b_en <= s0_b_en;
        s1_w_en <= s0_w_en;
        s1_txn  <= s0_txn ;
    end
end

//
// Internal wires representing the channel control signals.
//

wire i_awvalid  = write_txn;
wire i_wvalid   = write_txn;
wire i_wlast    = write_txn;
wire i_bready   = s1_txn && s1_w_en;
wire i_arvalid  = read_txn;
wire i_rready   = s1_txn && !s1_w_en;
wire i_mem_error= RVALID && !RRESP[1];
wire i_mem_stall= !i_rready;

assign pipeline_wait = !RVALID;

//-----------------------------------------------------------------------------
// Write Address channel handling
//

assign AWID     = 1'b0;
assign AWADDR   = {32{read_txn}} & mem_addr;
assign AWLEN    = 8'b0;
assign AWSIZE   = 3'b0;
assign AWBURST  = 2'b0;
assign AWLOCK   = 1'b0;
assign AWCACHE  = 4'b0;
assign AWPROT   = 3'b0;
assign AWQOS    = 4'b0;
assign AWREGION = 4'b0;
assign AWUSER   = 1'b0;
assign AWVALID  = i_awvalid;

//-----------------------------------------------------------------------------
// Write Data channel handling
//

assign WID      = 1'b0;
assign WDATA    = {32{write_txn}} & mem_wdata;
assign WSTRB    = { 4{write_txn}} & mem_b_en;
assign WLAST    = i_wlast;
assign WUSER    = 1'b0;
assign WVALID   = i_wvalid;


//-----------------------------------------------------------------------------
// Write Response channel handling
//

assign BREADY   = i_bready; // Master Response ready.


//-----------------------------------------------------------------------------
// Read Address channel handling
//

assign ARID     = 1'b0;
assign ARADDR   = {32{read_txn}} & mem_addr;
assign ARLEN    = 8'b0;
assign ARSIZE   = 3'b0;
assign ARBURST  = 2'b0;
assign ARLOCK   = 1'b0;
assign ARCACHE  = 4'b0;
assign ARPROT   = 2'b0;
assign ARQOS    = 3'b0;
assign ARREGION = 4'b0;
assign ARUSER   = 1'b0;
assign ARVALID  = i_arvalid;

//-----------------------------------------------------------------------------
// Read Response channel handling
//

assign RREADY   = i_rready;

//-----------------------------------------------------------------------------
// SRAM style interface handling.
//

assign mem_rdata = RDATA;
assign mem_error = i_mem_error;
assign mem_stall = i_mem_stall;
                     
endmodule            
                     
                     
                     
