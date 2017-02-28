
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
    output  wire uart_txd       // UART Transmit pin.
    
    
);

//
// Core instance memory interface wires.
//
wire [31:0]  rvm_mem_addr  ; // Memory address lines
wire [31:0]  rvm_mem_rdata ; // Memory read data
wire [31:0]  rvm_mem_wdata ; // Memory write data
wire         rvm_mem_c_en  ; // Memory chip enable
wire         rvm_mem_w_en  ; // Memory write enable
wire [ 3:0]  rvm_mem_b_en  ; // Memory byte enable
wire         rvm_mem_error ; // Memory error indicator
wire         rvm_mem_stall ; // Memory stall indicator

//
// Instance: i_rvm_core
//
//      This is the main core instance for the project.
//
rvm_core i_rvm_core (
.clk        (clk          ),  // System level clock.
.resetn     (sw[0]        ),  // Asynchronous active low reset.
.mem_addr   (rvm_mem_addr ),  // Memory address lines
.mem_rdata  (rvm_mem_rdata),  // Memory read data
.mem_wdata  (rvm_mem_wdata),  // Memory write data
.mem_c_en   (rvm_mem_c_en ),  // Memory chip enable
.mem_w_en   (rvm_mem_w_en ),  // Memory write enable
.mem_b_en   (rvm_mem_b_en ),  // Memory byte enable
.mem_error  (rvm_mem_error),  // Memory error indicator
.mem_stall  (rvm_mem_stall)   // Memory stall indicator
);

endmodule

