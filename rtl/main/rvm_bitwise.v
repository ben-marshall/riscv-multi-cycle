
//
// RISCV multi-cycle implementation.
//
// Module:      rvm_bitwise
//
// Description: Computes bitwise operations on two operands.
//
// op   | operation
// -----|-----------------------
//  00  | NOP                   
//  01  | OR                    
//  10  | AND                   
//  11  | XOR                   
//

`include "rvm_constants.v"

module rvm_bitwise(
input  wire [31:0] lhs,      // Value on left-hand side of the operator
input  wire [31:0] rhs,      // Value on right-hand side of the operator

input  wire [2:0]  op,       // What operation to perform?

output wire        valid,    // Asserts that the result is complete.
output wire [31:0] result    // The result
);

//
// Isolate inputs when the module is not enabled.
wire [31:0] i_lhs = lhs & {32{op != `RVM_BITWISE_NOP}};
wire [31:0] i_rhs = rhs & {32{op != `RVM_BITWISE_NOP}};

assign valid = op != `RVM_BITWISE_NOP;

//
// Compute the result
assign result = ({32{op == `RVM_BITWISE_OR }} & i_lhs | i_rhs) |
                ({32{op == `RVM_BITWISE_AND}} & i_lhs & i_rhs) |
                ({32{op == `RVM_BITWISE_XOR}} & i_lhs ^ i_rhs) ;

endmodule
