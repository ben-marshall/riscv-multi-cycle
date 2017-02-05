
//
// RISCV multi-cycle implementation.
//
// Module:      rvm_control
//
// Description: Contains the main control FSM for the core.
//
//

`include "rvm_constants.v"

module rvm_control(
input  wire         clk,                // System level clock.
input  wire         resetn,             // Asynchronous active low reset.

output wire [31:0] f_add_lhs   ; // Left hand side of the adder operand.
output wire [31:0] f_add_rhs   ; // Right hand side of the adder operand.
output wire [ 1:0] f_add_op    ; // Adder operation to perform.
input  wire        f_add_valid ; // Adder has finished computing.
input  wire [32:0] f_add_result; // Result of the adder operation.

output wire [31:0] f_bit_lhs   ; // Left hand side of the bitwise operand.
output wire [31:0] f_bit_rhs   ; // Right hand side of the bitwise operand.
output wire [ 1:0] f_bit_op    ; // Bitwise operation to perform.
input  wire        f_bit_valid ; // Bitwise has finished computing.
input  wire [31:0] f_bit_result; // Result of the bitwise operation.

output wire [31:0] f_shf_lhs   ; // Left hand side of the shift operand.
output wire [31:0] f_shf_rhs   ; // Right hand side of the shift operand.
output wire [ 1:0] f_shf_op    ; // Shift operation to perform.
input  wire        f_shf_valid ; // Shift has finished computing.
input  wire [31:0] f_shf_result; // Result of the shift operation.

output wire        s_rs1_en    ; // RS1 Port Enable.
output wire [4 :0] s_rs1_addr  ; // RS1 Address.
input  wire [31:0] s_rs1_rdata ; // RS1 Read Data.

output wire        s_rs2_en    ; // RS1 Port Enable.
output wire [4 :0] s_rs2_addr  ; // RS1 Address.
input  wire [31:0] s_rs2_rdata ; // RS1 Read Data.

output wire        d_rd_wen    ; // RD Write Enable.
output wire [4 :0] d_rd_addr   ; // RD Address.
output wire [31:0] d_rd_wdata  ; // RD Write Data.

output wire [1:0]  d_pc_w_en ;  // Set the PC to the value on wdata.
output wire [31:0] d_pc_wdata;  // Data to write to the PC register.
input  wire [31:0] s_pc      ;  // The current program counter value.

);



endmodule
