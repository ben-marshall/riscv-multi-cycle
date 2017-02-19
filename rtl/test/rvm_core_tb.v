
//
// RISCV multi-cycle implementation.
//
// Module:      rvm_core_tb
//
// Description: Testbench for the rvm_core.
//

`timescale 1ns/1ns
`include "rvm_constants.v"

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

    if(mem_addr == halt_addr) begin
        test_finished = 1;
        test_pass     = 0;
        timeout       = 0;
    
    end else if(mem_addr == pass_addr) begin
        test_finished = 1;
        test_pass     = 1;
        timeout       = 0;
    
    end else if(mem_addr == fail_addr) begin
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
            $display("\t%d\t: 0x%h", i, i_dut.i_rvm_gprs.registers[i]);
        end

        $display("Program Counter:     %h", i_dut.s_pc);
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
wire [3 :0] mem_ben  ; // Instruction memory byte enable.
wire        mem_wen  ; // Instruction memory write enable.
wire        mem_err  ; // Instruction memory error.
wire        mem_stall; // Instruction memory stall.
wire [31:0] mem_wdata; // Instruction memory write data.
wire [31:0] mem_rdata; // Instruction memory read data.
wire [31:0] mem_addr ; // Instruction memory address.

// Shifted memory address.
wire [31:0] mod_addr = mem_addr & 32'h0FFF_FFFF;

// The core instance.
rvm_core i_dut(
.clk        (clk        ), // The core level clock for sequential logic.
.resetn     (resetn     ), // Active low asynchronous reset signal.
.mem_addr   (mem_addr   ), // Memory address lines
.mem_rdata  (mem_rdata  ), // Memory read data
.mem_wdata  (mem_wdata  ), // Memory write data
.mem_c_en   (mem_c_en   ), // Memory chip enable
.mem_w_en   (mem_wen    ), // Memory write enable
.mem_b_en   (mem_ben    ), // Memory byte enable
.mem_error  (mem_err    ), // Memory error indicator
.mem_stall  (mem_stall  )  // Memory stall indicator
);

sram #(.size(16384)) i_memory(
.memfile(imem_file) ,
.gclk   (clk      ) ,  // Global clock signal
.resetn (resetn   ) ,  // Asynchronous active low reset.
.addr   (mod_addr ) ,  // Address lines
.rdata  (mem_rdata) ,  // Read data lines
.wdata  (mem_wdata) ,  // Write data lines
.b_en   (mem_ben  ) ,  // Chip Enable
.w_en   (mem_wen  ) ,  // write enable
.stall  (mem_stall) ,  // Stall signal
.error  (mem_err  )    // error signal
);

endmodule
