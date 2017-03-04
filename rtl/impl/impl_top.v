
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
input   wire        clk         ,   // Top level system clock input.

input   wire [ 3:0] sw          ,   // Slide switches.
output  wire [ 2:0] rgb0        ,   // RGB Led 0.
output  wire [ 2:0] rgb1        ,   // RGB Led 1.
output  wire [ 2:0] rgb2        ,   // RGB Led 2.
output  wire [ 2:0] rgb3        ,   // RGB Led 3.
output  wire [ 2:0] led         ,   // Green Leds
input   wire [ 3:0] btn         ,   // Push to make buttons.
input   wire        uart_rxd    ,   // UART Recieve pin.
output  wire        uart_txd    ,   // UART Transmit pin.
    
                                    // DDR3 signals.
inout        [15:0] ddr3_dq     ,
inout        [ 1:0] ddr3_dqs_n  ,
inout        [ 1:0] ddr3_dqs_p  ,
output       [13:0] ddr3_addr   ,
output       [ 2:0] ddr3_ba     ,
output              ddr3_ras_n  ,
output              ddr3_cas_n  ,
output              ddr3_we_n   ,
output              ddr3_reset_n,
output       [ 0:0] ddr3_ck_p   ,
output       [ 0:0] ddr3_ck_n   ,
output       [ 0:0] ddr3_cke    ,
output       [ 0:0] ddr3_cs_n   ,
output       [ 1:0] ddr3_dm     ,
output       [ 0:0] ddr3_odt   
    
);

//-------------------------------------------------------------------------
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

wire         core_enable;
wire         core_reset;

wire         mem_bus_ctrl;

//-------------------------------------------------------------------------
// DDR3 Controller instance interface wires.
//

wire         sys_clk_i          ; // Single-ended system clock
wire         clk_ref_i          ; // Single-ended iodelayctrl clk
wire [27:0]  app_addr           ; // Quad word aligned address.
wire [2:0]   app_cmd            ; // 000 = write, 001 = read
wire         app_en             ; // Initiate a new request. (addr,cmd)
wire [127:0] app_wdf_data       ; // Data to be written.
wire         app_wdf_end        ; // End of data to write.
wire [15:0]  app_wdf_mask       ; // Byte enable write data lines.
wire         app_wdf_wren       ; // Write enable line.
wire         app_wdf_rdy        ; // Write data accepted.
wire [127:0] app_rd_data        ; // Read data value.
wire         app_rd_data_end    ; // End of data being read.
wire         app_rd_data_valid  ; // Data being read is valid.
wire         app_rdy            ; // Current request accpeted.
wire         app_sr_req         ; // ??
wire         app_ref_req        ; // ??
wire         app_zq_req         ; // Calibration request
wire         app_sr_active      ; //
wire         app_ref_ack        ; // Refresh acknowledge
wire         app_zq_ack         ; // Calibration acknowledge
wire         ui_clk             ;
wire         ui_clk_sync_rst    ;
wire         init_calib_complete;
wire [11:0]  device_temp        ;


//-------------------------------------------------------------------------
// Core & DDR3 controller connection interfacing.
//


//-------------------------------------------------------------------------
// System controller module instance.
//


sys_ctrl i_sys_ctrl(
.clk              (clk              ), // Top level system clock input.
.resetn           (sw[0]            ), // Asynchronous active low reset.
.uart_rxd         (uart_rxd         ), // UART Recieve.
.uart_txd         (uart_txd         ), // UART Transmit.
.core_en          (core_enable      ), // Core enable signal.
.core_reset       (core_reset       ), // Core reset signal.
.mem_bus_ctrl     (mem_bus_ctrl     ), // 0 = sys_ctrl, 1 = core.
.app_addr         (app_addr         ), // Quad word aligned address.
.app_cmd          (app_cmd          ), // 000 = write, 001 = read
.app_en           (app_en           ), // Initiate a new request. (addr,cmd)
.app_wdf_data     (app_wdf_data     ), // Data to be written.
.app_wdf_end      (app_wdf_end      ), // End of data to write.
.app_wdf_mask     (app_wdf_mask     ), // Byte enable write data lines.
.app_wdf_wren     (app_wdf_wren     ), // Write enable line.
.app_wdf_rdy      (app_wdf_rdy      ), // Write data accepted.
.app_rd_data      (app_rd_data      ), // Read data value.
.app_rd_data_end  (app_rd_data_end  ), // End of data being read.
.app_rd_data_valid(app_rd_data_valid), // Data being read is valid.
.app_rdy          (app_rdy          )  // Current request accpeted.
);



//-------------------------------------------------------------------------
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
  

//-------------------------------------------------------------------------
// Instance: i_ddr3_wb
//
//      The DDR3 SDRAM controller instance.
//
ddr3_wb i_ddr3_wb (
// Memory interface ports
.ddr3_addr          (ddr3_addr),
.ddr3_ba            (ddr3_ba),
.ddr3_cas_n         (ddr3_cas_n),
.ddr3_ck_n          (ddr3_ck_n),
.ddr3_ck_p          (ddr3_ck_p),
.ddr3_cke           (ddr3_cke),
.ddr3_ras_n         (ddr3_ras_n),
.ddr3_we_n          (ddr3_we_n),
.ddr3_dq            (ddr3_dq),
.ddr3_dqs_n         (ddr3_dqs_n),
.ddr3_dqs_p         (ddr3_dqs_p),
.ddr3_reset_n       (ddr3_reset_n),
.init_calib_complete(init_calib_complete),
.ddr3_cs_n          (ddr3_cs_n),
.ddr3_dm            (ddr3_dm),
.ddr3_odt           (ddr3_odt),
// Application interface ports
.app_addr           (app_addr         ),
.app_cmd            (app_cmd          ),
.app_en             (app_en           ),
.app_wdf_data       (app_wdf_data     ),
.app_wdf_end        (app_wdf_end      ),
.app_wdf_wren       (app_wdf_wren     ),
.app_rd_data        (app_rd_data      ),
.app_rd_data_end    (app_rd_data_end  ),
.app_rd_data_valid  (app_rd_data_valid),
.app_rdy            (app_rdy          ),
.app_wdf_rdy        (app_wdf_rdy      ),
.app_sr_req         (1'b0             ),
.app_ref_req        (1'b0             ),
.app_zq_req         (1'b0             ),
.app_sr_active      (app_sr_active    ),
.app_ref_ack        (app_ref_ack      ),
.app_zq_ack         (app_zq_ack       ),
.ui_clk             (ui_clk           ),
.ui_clk_sync_rst    (ui_rst           ),
.app_wdf_mask       (app_wdf_mask     ),
// System Clock Ports
.sys_clk_i          (sys_clk_i        ),
// Reference Clock Ports
.clk_ref_i          (clk_ref_i        ),
.device_temp        (device_temp      ),
.sys_rst            (sw[0]            )
);

endmodule

