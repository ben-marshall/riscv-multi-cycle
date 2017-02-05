
//
// RISCV multi-cycle implementation.
//
// Module:      rvm_core
//
// Description: The top level for the core. Synthesis occurs below this point
//              in the hierarchy.
//

`include "rvm_constants.v"

module rvm_core(
input           wire clk,                   // System level clock.
input           wire resetn                 // Asynchronous active low reset.
);


//-----------------------------------------------------------------------------
// Interface signals for the functional units.
// 

wire [31:0] f_add_lhs   ; // Left hand side of the adder operand.
wire [31:0] f_add_rhs   ; // Right hand side of the adder operand.
wire [ 1:0] f_add_op    ; // Adder operation to perform.
wire        f_add_valid ; // Adder has finished computing.
wire [32:0] f_add_result; // Result of the adder operation.

wire [31:0] f_bit_lhs   ; // Left hand side of the bitwise operand.
wire [31:0] f_bit_rhs   ; // Right hand side of the bitwise operand.
wire [ 1:0] f_bit_op    ; // Bitwise operation to perform.
wire        f_bit_valid ; // Bitwise has finished computing.
wire [31:0] f_bit_result; // Result of the bitwise operation.

wire [31:0] f_shf_lhs   ; // Left hand side of the shift operand.
wire [31:0] f_shf_rhs   ; // Right hand side of the shift operand.
wire [ 1:0] f_shf_op    ; // Shift operation to perform.
wire        f_shf_valid ; // Shift has finished computing.
wire [31:0] f_shf_result; // Result of the shift operation.

//
// Register file interface signals
//

wire        s_rs1_en     ; // RS1 Port Enable.
wire [4 :0] s_rs1_addr   ; // RS1 Address.
wire [31:0] s_rs1_rdata  ; // RS1 Read Data.

wire        s_rs2_en     ; // RS1 Port Enable.
wire [4 :0] s_rs2_addr   ; // RS1 Address.
wire [31:0] s_rs2_rdata  ; // RS1 Read Data.

wire        d_rd_wen     ; // RD Write Enable.
wire [4 :0] d_rd_addr    ; // RD Address.
wire [31:0] d_rd_wdata   ; // RD Write Data.

//-----------------------------------------------------------------------------
// General Purpose and Control Status Register sets.
//

rvm_gprs i_rvm_gprs (
.clk       (clk        ), // The core level clock for sequential logic.
.clk_req   (clk_req    ), // Whether the gprs need a clock this cycle.
.resetn    (resetn     ), // Active low asynchronous reset signal.
.rs1_en    (s_rs1_en   ), // RS1 Port Enable.
.rs1_addr  (s_rs1_addr ), // RS1 Address.
.rs1_rdata (s_rs1_rdata), // RS1 Read Data.
.rs2_en    (s_rs2_en   ), // RS1 Port Enable.
.rs2_addr  (s_rs2_addr ), // RS1 Address.
.rs2_rdata (s_rs2_rdata), // RS1 Read Data.
.rd_wen    (d_rd_wen   ), // RD Write Enable.
.rd_addr   (d_rd_addr  ), // RD Address.
.rd_wdata  (d_rd_wdata )  // RD Write Data.
);

//-----------------------------------------------------------------------------
// Functional unit instances.
//

rvm_shift i_rvm_add_0(
.lhs   (f_add_lhs   ), // Value on left-hand side of operator
.rhs   (f_add_rhs   ), // Value on right-hand side of operator
.op    (f_add_op    ), // What to do?
.valid (f_add_valid ), // Asserts that the result is complete.
.result(f_add_result)  // The result of the addition / subtraction
);

rvm_shift i_rvm_bitwise_0(
.lhs   (f_bit_lhs   ), // Value on left-hand side of operator
.rhs   (f_bit_rhs   ), // Value on right-hand side of operator
.op    (f_bit_op    ), // What to do?
.valid (f_bit_valid ), // Asserts that the result is complete.
.result(f_bit_result)  // The result of the bitwise op
);

rvm_shift i_rvm_shift_0(
.lhs   (f_shf_lhs   ), // Value on left-hand side of shift operator
.rhs   (f_shf_rhs   ), // Value on right-hand side of shift operator
.op    (f_shf_op    ), // What to do?
.valid (f_shf_valid ), // Asserts that the result is complete.
.result(f_shf_result)  // The result of the shift
);

endmodule

