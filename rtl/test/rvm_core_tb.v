
//
// RISCV multi-cycle implementation.
//
// Module:      rvm_core_tb
//
// Description: Testbench for the rvm_core.
//

`timescale 1ns/1ns
`include "rvs_constants.v"

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
reg resetn;
wire clk_req;

//
// Make the clock tick
always begin
    #8 assign resetn = 1'b1;  // Take DUT out of reset after 5 ticks
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
    $dumpvars(0,i_dut);
end
    
integer i;

// Simulation running and control
always @(posedge clk) begin
    cycle_count = cycle_count + 1;

    test_finished = 0;
    test_pass     = 0;
    timeout       = 0;
    fail_hit      = 0;

    if(mem_i_addr == halt_addr) begin
        test_finished = 1;
        test_pass     = 0;
        timeout       = 0;
    
    end else if(mem_i_addr == pass_addr) begin
        test_finished = 1;
        test_pass     = 1;
        timeout       = 0;
    
    end else if(mem_i_addr == fail_addr) begin
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
            $display("\t RF not implemented yet");
            //$display("\t%d\t: 0x%h", i, i_dut.i_register_file.registers[i]);
        end

        $display("Program Counter:     %h", i_dut.pc);
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

// Memory bus signals
wire [3 :0] mem_i_ben  ; // Instruction memory byte enable.
wire        mem_i_wen  ; // Instruction memory write enable.
wire        mem_i_err  ; // Instruction memory error.
wire        mem_i_stall; // Instruction memory stall.
wire [31:0] mem_i_wdata; // Instruction memory write data.
wire [31:0] mem_i_rdata; // Instruction memory read data.
wire [31:0] mem_i_addr ; // Instruction memory address.

// The core instance.
rvs_core i_dut(
.clk        (clk        ), // The core level clock for sequential logic.
.clk_req    (clk_req    ), // Whether the core needs a clock this cycle.
.resetn     (resetn     ), // Active low asynchronous reset signal.
);

sram i_memory(
.memfile(imem_file  ) ,
.gclk   (clk        ) ,  // Global clock signal
.resetn (resetn     ) ,  // Asynchronous active low reset.
.addr   (mem_i_addr ) ,  // Address lines
.rdata  (mem_i_rdata) ,  // Read data lines
.wdata  (mem_i_wdata) ,  // Write data lines
.b_en   (mem_i_ben ) ,  // Chip Enable
.w_en   (mem_i_wen  ) ,  // write enable
.stall  (mem_i_stall) ,  // Stall signal
.error  (mem_i_err  )    // error signal
);

endmodule