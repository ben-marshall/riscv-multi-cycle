
//
// RISCV multi-cycle implementation.
//
// Module:      rvm_adder
//
// Description: A 32 bit add/subtract unit with two inputs and overflow
//              detection.
//
// op   | operation
// -----|-----------------------
//  00  | NOP                   
//  01  | ADD                   
//  10  | SUB                   
//  11  | Undefined             
//

`include "rvm_constants.v"

module rvm_adder(

input  wire [31:0] lhs,      // Value on left-hand side of + operator
input  wire [31:0] rhs,      // Value on right-hand side of + operator

input  wire [2:0]  op,       // What to do?

output wire        valid,    // Asserts that the result is complete.
output wire [31:0] result,   // The result of the addition / subtraction
output wire        overflow
);

//
// Isolate inputs to the adder when the module is not enabled.
wire [31:0] i_lhs = lhs & {32{op != `RVM_ARITH_NOP}};
wire [31:0] i_rhs = rhs & {32{op != `RVM_ARITH_NOP}};

assign valid = op != `RVM_ARITH_NOP;

wire result_ge = op == `RVM_ARITH_GE  && $signed(lhs) >= $signed(rhs);
wire result_geu= op == `RVM_ARITH_GEU && $unsigned(lhs >= rhs);
wire result_lt = op == `RVM_ARITH_LT  && $signed(lhs) <  $signed(rhs);
wire result_ltu= op == `RVM_ARITH_LTU && $unsigned(lhs <  rhs);

//
// Compute the result
assign {overflow,result} = ({33{op == `RVM_ARITH_ADD}} & (i_lhs + i_rhs)) |
                           ({33{op == `RVM_ARITH_SUB}} & (i_lhs - i_rhs)) |
                           ({33{op == `RVM_ARITH_GE }} & (result_ge    )) |
                           ({33{op == `RVM_ARITH_GEU}} & (result_geu   )) |
                           ({33{op == `RVM_ARITH_LT }} & (result_lt    )) |
                           ({33{op == `RVM_ARITH_LTU}} & (result_ltu   )) ;


endmodule
