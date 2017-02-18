
//
// RISCV multi-cycle implementation.
//
// Module:      rvm_shift
//
// Description: Provides 32-bit logical and arithmetic shifting.
//
// op   | operation
// -----|-----------------------
//  00  | NOP                   
//  01  | Logical shift left    
//  10  | Logical shift right   
//  11  | Arithmetic shift right
//

`include "rvm_constants.v"

module rvm_shift(

input  wire [31:0] lhs,      // Value on left-hand side of shift operator
input  wire [ 4:0] rhs,      // Value on right-hand side of shift operator

input  wire [1:0]  op,       // What to do?

output wire        valid,    // Asserts that the result is complete.
output wire [32:0] result    // The result

);

//
// Isolate inputs to the adder when the module is not enabled.
wire signed  [31:0] i_lhs = lhs & {32{op != `RVM_SHIFT_NOP}};
wire signed  [31:0] i_rhs = rhs & {32{op != `RVM_SHIFT_NOP}};

assign valid = op != `RVM_SHIFT_NOP;

assign result = ({32{op == `RVM_SHIFT_SLL}} & (i_lhs <<  i_rhs)) |
                ({32{op == `RVM_SHIFT_SRL}} & (i_lhs >>  i_rhs)) |
                ({32{op == `RVM_SHIFT_ASR}} & (i_lhs >>> i_rhs)) ;


endmodule
