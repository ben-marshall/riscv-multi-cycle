
//
// RISCV multi-cycle implementation.
//
// Module:      N/A
//
// Description: Contains all compile time constants for the core.
//
//


`define RVM_BITWISE_NOP   2'b00
`define RVM_BITWISE_OR    2'b01
`define RVM_BITWISE_AND   2'b10
`define RVM_BITWISE_XOR   2'b11

`define RVM_ARITH_NOP     2'b00
`define RVM_ARITH_ADD     2'b01
`define RVM_ARITH_SUB     2'b10

`define RVM_SHIFT_NOP     2'b00
`define RVM_SHIFT_SLL     2'b01
`define RVM_SHIFT_SRL     2'b10
`define RVM_SHIFT_ASR     2'b11
