
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

output     [31:0] M_AXI_ARADDR,     // 
input             M_AXI_ARREADY,    // 
output     [ 2:0] M_AXI_ARSIZE,     // 
output            M_AXI_ARVALID,    // 

output     [31:0] M_AXI_AWADDR,     // 
input             M_AXI_AWREADY,    // 
output     [ 2:0] M_AXI_AWSIZE,     // 
output            M_AXI_AWVALID,    // 

output            M_AXI_BREADY,     // 
input      [ 1:0] M_AXI_BRESP,      // 
input             M_AXI_BVALID,     // 

input      [31:0] M_AXI_RDATA,      // 
output            M_AXI_RREADY,     // 
input      [ 1:0] M_AXI_RRESP,      // 
input             M_AXI_RVALID,     // 

output     [31:0] M_AXI_WDATA,      // 
input             M_AXI_WREADY,     // 
output     [ 3:0] M_AXI_WSTRB,      // 
output            M_AXI_WVALID      // 

);

wire [31:0]  mem_addr;          // Memory address lines
wire [31:0]  mem_rdata;         // Memory read data
wire [31:0]  mem_wdata;         // Memory write data
wire         mem_c_en;          // Memory chip enable
wire         mem_w_en;          // Memory write enable
wire [ 3:0]  mem_b_en;          // Memory byte enable
wire         mem_error;         // Memory error indicator
wire         mem_stall;         // Memory stall indicator

reg          aw_ready;          // State for checking aw_ready has been seen.
reg          wd_ready;          // State for checking w_ready has been seen.
reg          ar_ready;          // State for checking ar_ready has been seen.

// ----- AXI4 <-> SRAM Bridge Logic -----------------------------------

//
// Data read request channel protocol signalling.
//
always @(posedge ACLK, negedge ARESETn) begin
    if(!ARESETn) begin
        ar_ready <= 1'b0;
    end else begin
        ar_ready <= (ar_ready || M_AXI_ARREADY) && !M_AXI_RVALID;
    end
end

//
// Address write channel protocol signalling.
//
always @(posedge ACLK, negedge ARESETn) begin
    if(!ARESETn) begin
        aw_ready <= 1'b0;
    end else begin
        aw_ready <= (aw_ready || M_AXI_AWREADY) && !M_AXI_BVALID;
    end
end

//
// Write data channel protocol signalling.
//
always @(posedge ACLK, negedge ARESETn) begin
    if(!ARESETn) begin
        wd_ready <= 1'b0;
    end else begin
        wd_ready <= (wd_ready || M_AXI_WREADY) && !M_AXI_BVALID;
    end
end

//
// Memory stall & error signals.
assign mem_stall        = mem_c_en && (( mem_w_en && !M_AXI_BVALID) ||
                                       (!mem_w_en &&  M_AXI_RVALID)) ;

assign mem_error        = M_AXI_BVALID && M_AXI_BRESP != 2'b0 ||
                          M_AXI_RVALID && M_AXI_RRESP != 2'b0  ;

//
// Constant control signals.
assign M_AXI_BREADY     = 1'b1;
assign M_AXI_RREADY     = 1'b1;

// Reads
assign M_AXI_ARADDR     = mem_addr;
assign M_AXI_ARSIZE     = 3'b010;   // 4-bytes
assign M_AXI_ARVALID    = mem_c_en && !mem_w_en && !ar_ready;

assign mem_rdata        = M_AXI_RDATA;

// Write Requests
assign M_AXI_AWADDR     = mem_addr;
assign M_AXI_AWSIZE     = 3'b010;   // 4-bytes
assign M_AXI_AWVALID    = mem_c_en && !mem_w_en && !aw_ready;

assign M_AXI_WSTRB      = mem_b_en;
assign M_AXI_WDATA      = mem_wdata;
assign M_AXI_WVALID     = mem_c_en && !mem_w_en && !wd_ready;



// ----- CORE Instantiation -------------------------------------------

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

endmodule
