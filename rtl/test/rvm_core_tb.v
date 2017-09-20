
//
// RISCV multi-cycle implementation.
//
// Module:      rvm_core_tb
//
// Description: Testbench for the rvm_core.
//

`timescale 1ns/1ns
`include "rvm_constants.v"

`define CORE_PATH i_dut.i_rvm_core

module rvm_core_tb();

reg                 timeout;        // Finish due to timeout.
integer             cycle_count;    // Current cycle count.
integer             max_cycle_count;// Max cycles before timeout.
reg     [100*8:0]   imem_file;      // Instruction memory file path.
reg                 test_finished;  // Set iffthe test should stop.
reg                 test_pass;      // Set iff test has passed.
reg     [31:0]      halt_addr;      // Automatically stop when hitting this.
reg     [31:0]      pass_addr;      // Automatically stop when hitting this.
reg     [31:0]      fail_addr;      // Automatically stop when hitting this.
reg                 fail_hit ;      // 

// Global clock and reset signals.
reg clk;
reg resetn =1'b0;
wire clk_req;

wire       [31:0] M_AXI_ARADDR;     // 
wire              M_AXI_ARREADY;    // 
wire       [ 2:0] M_AXI_ARSIZE;     // 
wire              M_AXI_ARVALID;    // 
wire       [31:0] M_AXI_AWADDR;     // 
wire              M_AXI_AWREADY;    // 
wire       [ 2:0] M_AXI_AWSIZE;     // 
wire              M_AXI_AWVALID;    // 
wire              M_AXI_BREADY;     // 
wire       [ 1:0] M_AXI_BRESP;      // 
wire              M_AXI_BVALID;     // 
wire       [31:0] M_AXI_RDATA;      // 
wire              M_AXI_RREADY;     // 
wire       [ 1:0] M_AXI_RRESP;      // 
wire              M_AXI_RVALID;     // 
wire       [31:0] M_AXI_WDATA;      // 
wire              M_AXI_WREADY;     // 
wire       [ 3:0] M_AXI_WSTRB;      // 
wire              M_AXI_WVALID;     // 

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

    if($value$plusargs("IMEM=%s"            , imem_file)        )begin end
    if($value$plusargs("MAX_CYCLE_COUNT=%d" , max_cycle_count)  )begin end
    if($value$plusargs("HALT_ADDR=%h"       , halt_addr)        )begin end
    if($value$plusargs("PASS_ADDR=%h"       , pass_addr)        )begin end
    if($value$plusargs("FAIL_ADDR=%h"       , fail_addr)        )begin end

    $display("Simulation Parameters: ");
    $display("> MAX_CYCLE_COUNT: %d", max_cycle_count);
    $display("> IMEM           : %s", imem_file); 
    $display("> Halt Address   : %h", halt_addr); 
    $display("> Pass Address   : %h", pass_addr); 
    $display("> Fail Address   : %h", fail_addr); 
    
    $dumpfile("work/waves.vcd");     
    $dumpvars(0,rvm_core_tb);
end
    
integer i;

// Simulation running and control
always @(posedge clk) begin
    cycle_count = cycle_count + 1;

    test_finished = 0;
    test_pass     = 0;
    timeout       = 0;
    fail_hit      = 0;

    if(M_AXI_ARADDR == halt_addr) begin
        test_finished = 1;
        test_pass     = 0;
        timeout       = 0;
    
    end else if(M_AXI_ARADDR == pass_addr) begin
        test_finished = 1;
        test_pass     = 1;
        timeout       = 0;
    
    end else if(M_AXI_ARADDR == fail_addr) begin
        test_finished = 1;
        test_pass     = 0;
        fail_hit      = 1;
        timeout       = 0;

    end else if(cycle_count > max_cycle_count) begin
        $display("Cycle timeout Reached: %d/%d", cycle_count,max_cycle_count);
        test_finished = 1;
        test_pass     = 0;
        timeout       = 1;
    end

    if(test_finished) begin
        
        $display("Register file values after %d cycles:", cycle_count);
        for (i = 0; i < 32; i = i + 1) begin
            $display("\t%d\t: 0x%h", i, `CORE_PATH.i_rvm_gprs.registers[i]);
        end

        $display("Program Counter:     %h", `CORE_PATH.s_pc);
        $display("Processor Cycles:    %d", cycle_count);

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

// ------------------------------------------------------------------------

//
// DUT instance
//
rvm_core_axi4 i_dut(
.ACLK          (clk           ) , // Master clock for the AXI interface.
.ARESETn       (resetn        ) , // Active low asynchronous reset.
.M_AXI_ARADDR  (M_AXI_ARADDR  ) , 
.M_AXI_ARREADY (M_AXI_ARREADY ) , 
.M_AXI_ARSIZE  (M_AXI_ARSIZE  ) , 
.M_AXI_ARVALID (M_AXI_ARVALID ) , 
.M_AXI_AWADDR  (M_AXI_AWADDR  ) , 
.M_AXI_AWREADY (M_AXI_AWREADY ) , 
.M_AXI_AWSIZE  (M_AXI_AWSIZE  ) , 
.M_AXI_AWVALID (M_AXI_AWVALID ) , 
.M_AXI_BREADY  (M_AXI_BREADY  ) , 
.M_AXI_BRESP   (M_AXI_BRESP   ) , 
.M_AXI_BVALID  (M_AXI_BVALID  ) , 
.M_AXI_RDATA   (M_AXI_RDATA   ) , 
.M_AXI_RREADY  (M_AXI_RREADY  ) , 
.M_AXI_RRESP   (M_AXI_RRESP   ) , 
.M_AXI_RVALID  (M_AXI_RVALID  ) , 
.M_AXI_WDATA   (M_AXI_WDATA   ) , 
.M_AXI_WREADY  (M_AXI_WREADY  ) , 
.M_AXI_WSTRB   (M_AXI_WSTRB   ) , 
.M_AXI_WVALID  (M_AXI_WVALID  )   
);


//
// Test memory
//
axi_sram #(
 .addr_w(32),
 .data_w(32),
 .size(8192)
) i_ram(
.memfile       (imem_file     ),
.ACLK          (clk           ) , // Master clock for the AXI interface.
.ARESETn       (resetn        ) , // Active low asynchronous reset.
.M_AXI_ARADDR  (M_AXI_ARADDR  ) , 
.M_AXI_ARREADY (M_AXI_ARREADY ) , 
.M_AXI_ARSIZE  (M_AXI_ARSIZE  ) , 
.M_AXI_ARVALID (M_AXI_ARVALID ) , 
.M_AXI_AWADDR  (M_AXI_AWADDR  ) , 
.M_AXI_AWREADY (M_AXI_AWREADY ) , 
.M_AXI_AWSIZE  (M_AXI_AWSIZE  ) , 
.M_AXI_AWVALID (M_AXI_AWVALID ) , 
.M_AXI_BREADY  (M_AXI_BREADY  ) , 
.M_AXI_BRESP   (M_AXI_BRESP   ) , 
.M_AXI_BVALID  (M_AXI_BVALID  ) , 
.M_AXI_RDATA   (M_AXI_RDATA   ) , 
.M_AXI_RREADY  (M_AXI_RREADY  ) , 
.M_AXI_RRESP   (M_AXI_RRESP   ) , 
.M_AXI_RVALID  (M_AXI_RVALID  ) , 
.M_AXI_WDATA   (M_AXI_WDATA   ) , 
.M_AXI_WREADY  (M_AXI_WREADY  ) , 
.M_AXI_WSTRB   (M_AXI_WSTRB   ) , 
.M_AXI_WVALID  (M_AXI_WVALID  )   
);

endmodule
