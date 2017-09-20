
//
// RISCV multi-cycle implementation.
//
// Module:      axi_sram
//
// Description: A simple AXI SRAM module for testing.
//
//

`include "rvm_constants.v"

module axi_sram(
input   wire    [255*8:0] memfile,

input         ACLK              , // Master clock for the AXI interface.
input         ARESETn           , // Active low asynchronous reset.

input     [31:0] M_AXI_ARADDR,     // 
output           M_AXI_ARREADY,    // 
input     [ 2:0] M_AXI_ARSIZE,     // 
input            M_AXI_ARVALID,    // 

input     [31:0] M_AXI_AWADDR,     // 
output           M_AXI_AWREADY,    // 
input     [ 2:0] M_AXI_AWSIZE,     // 
input            M_AXI_AWVALID,    // 

input            M_AXI_BREADY,     // 
output    [ 1:0] M_AXI_BRESP,      // 
output           M_AXI_BVALID,     // 

output    [31:0] M_AXI_RDATA,      // 
input            M_AXI_RREADY,     // 
output    [ 1:0] M_AXI_RRESP,      // 
output           M_AXI_RVALID,     // 

input     [31:0] M_AXI_WDATA,      // 
output           M_AXI_WREADY,     // 
input     [ 3:0] M_AXI_WSTRB,      // 
input            M_AXI_WVALID      // 

);

parameter   addr_w  = 32;    // 32 bit address bus.
parameter   data_w  = 32;    // 32 bit word size.
parameter   size    = 8192;  // Size of the memory in words.

wire [addr_w-1:0] addr;       // Address lines
wire [data_w-1:0] rdata;      // Read data lines
wire [data_w-1:0] wdata;      // Write data lines
wire  [3:0]       b_en;       // Chip Enable
wire              w_en;       // write enable
wire              stall;      // Stall signal
wire              error;      // error signal

assign addr = M_AXI_AWVALID ? 32'h000F_FFFF & M_AXI_AWADDR      :
              M_AXI_ARVALID ? 32'h000F_FFFF & M_AXI_ARADDR      :
                              'b0               ;

assign b_en = M_AXI_WVALID  ? M_AXI_WSTRB       :
              M_AXI_ARVALID ? 4'b1111           :
                              4'b1111           ;

assign M_AXI_RDATA = rdata;
assign wdata       = M_AXI_WDATA;
assign M_AXI_BRESP = {1'b0,error};
assign M_AXI_RRESP = {1'b0,error};

assign M_AXI_AWREADY = !stall;
assign M_AXI_WREADY  = !stall;
assign M_AXI_RREADY  = !stall;
assign M_AXI_ARREADY = !stall;
assign w_en          = M_AXI_WVALID;
assign M_AXI_RVALID  = !stall;
assign M_AXI_BVALID  = !stall;

sram #(
 .addr_w(addr_w),
 .data_w(data_w),
 .size(size)
) i_sram (
.memfile(memfile),
.gclk(   ACLK),       // Global clock signal
.resetn( ARESETn),     // Asynchronous active low reset.
.addr(   addr),       // Address lines
.rdata(  rdata),      // Read data lines
.wdata(  wdata),      // Write data lines
.b_en(   b_en),       // Chip Enable
.w_en(   w_en),       // write enable
.stall(  stall),      // Stall signal
.error(  error)      // error signal
);

endmodule
