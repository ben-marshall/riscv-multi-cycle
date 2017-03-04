
//
// RISCV multi-cycle implementation.
//
// Module:      impl_top_tb
//
// Description: System level testbench.
//

`timescale 1ns/1ns
`include "rvm_constants.v"

module impl_top_tb();

wire [ 3:0] dut_sw          ;   // Slide switches.
wire [ 2:0] dut_rgb0        ;   // RGB Led 0.
wire [ 2:0] dut_rgb1        ;   // RGB Led 1.
wire [ 2:0] dut_rgb2        ;   // RGB Led 2.
wire [ 2:0] dut_rgb3        ;   // RGB Led 3.
wire [ 2:0] dut_led         ;   // Green Leds
wire [ 3:0] dut_btn         ;   // Push to make buttons.
wire            uart_rxd    ;   // UART Recieve pin.
wire            uart_txd    ;   // UART Transmit pin.

wire [15:0] dut_ddr3_dq     ;
wire [ 1:0] dut_ddr3_dqs_n  ;
wire [ 1:0] dut_ddr3_dqs_p  ;
wire [13:0] dut_ddr3_addr   ;
wire [ 2:0] dut_ddr3_ba     ;
wire        dut_ddr3_ras_n  ;
wire        dut_ddr3_cas_n  ;
wire        dut_ddr3_we_n   ;
wire        dut_ddr3_reset_n;
wire [ 0:0] dut_ddr3_ck_p   ;
wire [ 0:0] dut_ddr3_ck_n   ;
wire [ 0:0] dut_ddr3_cke    ;
wire [ 0:0] dut_ddr3_cs_n   ;
wire [ 1:0] dut_ddr3_dm     ;
wire [ 0:0] dut_ddr3_odt    ;

reg                 timeout;        // Finish due to timeout.
integer             cycle_count;    // Current cycle count.
integer             max_cycle_count;// Max cycles before timeout.

// Global clock and reset signals.
reg clk;
reg resetn =1'b0;
wire clk_req;

initial begin
    #16 assign resetn = 1'b1;  // Take DUT out of reset after 5 ticks
end

//
// Make the clock tick
always begin
    #5 assign clk = !clk;     // Toggle the clock every five ticks.
end

// Simulation argument parsing.
initial begin
    clk             = 1'b0;
    resetn          = 1'b0;
    cycle_count     = 0;
    max_cycle_count = 500;
    halt_addr       = 32'b0;

    if($value$plusargs("MAX_CYCLE_COUNT=%d" , max_cycle_count)  )begin end

    $display("Simulation Parameters: ");
    $display("> MAX_CYCLE_COUNT: %d", max_cycle_count);
    
    $dumpfile("work/waves.vcd");     
    $dumpvars(0,impl_top_tb);
end
    
integer i;

//
// Simulation running and control
always @(posedge clk) begin
    cycle_count = cycle_count + 1;

    test_finished = 0;
    test_pass     = 0;
    timeout       = 0;
    fail_hit      = 0;

    if(cycle_count > max_cycle_count) begin
        $display("Cycle timeout Reached: %d/%d", cycle_count,max_cycle_count);
        test_finished = 1;
        test_pass     = 0;
        timeout       = 1;
    end

    if(test_finished) begin
        
        if(test_pass) begin
            $display("TEST PASS                ");
        end else if (timeout) begin
            $display("TEST FAIL - TIMEOUT      ");
        end else if (fail_hit) begin
            $display("TEST FAIL - FAIL ADDRESS ");
        end else begin
            $display("TEST FAIL - UNKNOWN ERROR");
        end
        
        $finish(0);
    end

end

//
// Simulation stimulus sequence.
initial begin
    send_byte(8'b0011_0000); // SETUP
    send_byte(8'b0000_0010); // Address Byte 3
    send_byte(8'b0000_0010); // Address Byte 2
    send_byte(8'b0000_0010); // Address Byte 1
    send_byte(8'b0000_0010); // Address Byte 0
    send_byte(8'b0000_0000); // Length Byte 3
    send_byte(8'b0000_0000); // Length Byte 2
    send_byte(8'b0000_0000); // Length Byte 1
    send_byte(8'b0000_0100); // Length Byte 0

    #50

end

//
// Send a single byte on the UART input.
task send_byte;
    input [7:0] to_send;
    integer i;
    begin
        $display("Sending byte: %d at time %d", to_send, $time);

        #3520;  uart_rxd = 1'b0;
        for(i=0; i < 8; i = i+1) begin
            #3520;  uart_rxd = to_send[i];
        end
        #3520;  uart_rxd = 1'b1;
    end
endtask

//-------------------------------------------------------------------------

assign dut_sw   = {3'b0, resetn};
assign dut_btn  = 4'b0;

impl_top i_dut(
.clk         (clk             ),   // Top level system clock input.
.sw          (dut_sw          ),   // Slide switches.
.rgb0        (dut_rgb0        ),   // RGB Led 0.
.rgb1        (dut_rgb1        ),   // RGB Led 1.
.rgb2        (dut_rgb2        ),   // RGB Led 2.
.rgb3        (dut_rgb3        ),   // RGB Led 3.
.led         (dut_led         ),   // Green Leds
.btn         (dut_btn         ),   // Push to make buttons.
.uart_rxd    (dut_uart_rxd    ),   // UART Recieve pin.
.uart_txd    (dut_uart_txd    ),   // UART Transmit pin.
.ddr3_dq     (dut_ddr3_dq     ),
.ddr3_dqs_n  (dut_ddr3_dqs_n  ),
.ddr3_dqs_p  (dut_ddr3_dqs_p  ),
.ddr3_addr   (dut_ddr3_addr   ),
.ddr3_ba     (dut_ddr3_ba     ),
.ddr3_ras_n  (dut_ddr3_ras_n  ),
.ddr3_cas_n  (dut_ddr3_cas_n  ),
.ddr3_we_n   (dut_ddr3_we_n   ),
.ddr3_reset_n(dut_ddr3_reset_n),
.ddr3_ck_p   (dut_ddr3_ck_p   ),
.ddr3_ck_n   (dut_ddr3_ck_n   ),
.ddr3_cke    (dut_ddr3_cke    ),
.ddr3_cs_n   (dut_ddr3_cs_n   ),
.ddr3_dm     (dut_ddr3_dm     ),
.ddr3_odt    (dut_ddr3_odt    ) 
);

endmodule
