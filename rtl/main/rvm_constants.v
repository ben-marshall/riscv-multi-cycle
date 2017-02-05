
//
// RISCV multi-cycle implementation.
//
// Module:      N/A
//
// Description: Contains all compile time constants for the core.
//
//

`define RVM_PC_POST_RESET 32'h0001_0000

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

`define RVM_INSTR_BLTU    6'd0 
`define RVM_INSTR_CSRRW   6'd1 
`define RVM_INSTR_LW      6'd2 
`define RVM_INSTR_LH      6'd3 
`define RVM_INSTR_LHU     6'd4 
`define RVM_INSTR_LB      6'd5 
`define RVM_INSTR_LBU     6'd6 
`define RVM_INSTR_SH      6'd7 
`define RVM_INSTR_SB      6'd8 
`define RVM_INSTR_ADD     6'd9 
`define RVM_INSTR_CSRRC   6'd10 
`define RVM_INSTR_BNE     6'd11 
`define RVM_INSTR_BGEU    6'd12 
`define RVM_INSTR_SLTIU   6'd13 
`define RVM_INSTR_SRLI    6'd14 
`define RVM_INSTR_FENCE   6'd15 
`define RVM_INSTR_FENCE_I 6'd16 
`define RVM_INSTR_SLL     6'd17 
`define RVM_INSTR_XOR     6'd18 
`define RVM_INSTR_SUB     6'd19 
`define RVM_INSTR_BLT     6'd20 
`define RVM_INSTR_ECALL   6'd21 
`define RVM_INSTR_LUI     6'd22 
`define RVM_INSTR_CSRRCI  6'd23 
`define RVM_INSTR_ADDI    6'd24 
`define RVM_INSTR_CSRRSI  6'd25 
`define RVM_INSTR_SRAI    6'd26 
`define RVM_INSTR_ORI     6'd27 
`define RVM_INSTR_CSRRS   6'd28 
`define RVM_INSTR_SRA     6'd29 
`define RVM_INSTR_BGE     6'd30 
`define RVM_INSTR_SRL     6'd31 
`define RVM_INSTR_OR      6'd32 
`define RVM_INSTR_XORI    6'd33 
`define RVM_INSTR_ANDI    6'd34 
`define RVM_INSTR_JAL     6'd35 
`define RVM_INSTR_SLT     6'd36 
`define RVM_INSTR_SLTI    6'd37 
`define RVM_INSTR_SLTU    6'd38 
`define RVM_INSTR_SLLI    6'd39 
`define RVM_INSTR_BEQ     6'd30 
`define RVM_INSTR_AND     6'd41 
`define RVM_INSTR_AUIPC   6'd42 
`define RVM_INSTR_CSRRWI  6'd43 
`define RVM_INSTR_JALR    6'd44 
`define RVM_INSTR_SW      6'd45 
`define RVM_INSTR_ERET    6'd46 
