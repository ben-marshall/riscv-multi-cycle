
//
// RISCV multi-cycle implementation.
//
// Module:      rvm_pcu
//
// Description: Program counter unit.
//
//

`include "rvm_constants.v"

module rvm_pcu(
input  wire          clk,       // System clock
input  wire          resetn,    // Asynchronous active low reset.

input  wire [1:0]    pc_w_en,   // Set the PC to the value on wdata.
input  wire [31:0]   pc_wdata,  // Data to write to the PC register.
output reg  [31:0]   pc         // The current program counter value.
);

always @(posedge clk, negedge resetn) begin: p_update_pc
    if(!resetn) begin
        pc <= `RVM_PC_POST_RESET;
    end else if(pc_w_en) begin
        pc <= pc_wdata;
    end
end

endmodule
