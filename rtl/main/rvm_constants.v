
//
// RISCV multi-cycle implementation.
//
// Module:      N/A
//
// Description: Contains all compile time constants for the core.
//
//

`define RVM_PC_POST_RESET 32'h8000_0000

`define RVM_BITWISE_NOP   2'b00
`define RVM_BITWISE_OR    2'b01
`define RVM_BITWISE_AND   2'b10
`define RVM_BITWISE_XOR   2'b11

`define RVM_ARITH_NOP     3'b000
`define RVM_ARITH_ADD     3'b001
`define RVM_ARITH_SUB     3'b010
`define RVM_ARITH_GE      3'b011
`define RVM_ARITH_GEU     3'b100
`define RVM_ARITH_LT      3'b101
`define RVM_ARITH_LTU     3'b110

`define RVM_SHIFT_NOP     2'b00
`define RVM_SHIFT_SLL     2'b01
`define RVM_SHIFT_SRL     2'b10
`define RVM_SHIFT_ASR     2'b11

//
// System Control Unit register addresses and values.
// ---------------------------------------------------------------------------

// Individual opcodes for the system control unit.
`define RVM_SCU_NOP     4'b0000
`define RVM_SCU_CSRRS   4'b0001
`define RVM_SCU_CSRRC   4'b0010
`define RVM_SCU_CSRRW   4'b0011
`define RVM_SCU_CSRRSI  4'b0100
`define RVM_SCU_CSRRCI  4'b0101
`define RVM_SCU_CSRRWI  4'b0110

`define RVM_SCU_MISA        32'h40000100
`define RVM_SCU_MVENDORID   32'h0BE0AA11
`define RVM_SCU_MARCHID     32'h00000000
`define RVM_SCU_MIMPID      32'h00000001
`define RVM_SCU_MHARTID     32'h00000000

`define RVM_SCU_ADDR_MISA      12'h301 // Should be F10, toolchain gives this.
`define RVM_SCU_ADDR_MVENDORID 12'hF11 
`define RVM_SCU_ADDR_MARCHID   12'hF12 
`define RVM_SCU_ADDR_MIMPID    12'hF13 
`define RVM_SCU_ADDR_MHARTID   12'hF14 
`define RVM_SCU_ADDR_MSCRATCH  12'h340 
`define RVM_SCU_ADDR_MEPC      12'h341 
`define RVM_SCU_ADDR_MEDELEG   12'h302 
`define RVM_SCU_ADDR_MIDELEG   12'h303 
`define RVM_SCU_ADDR_MIE       12'h304 
`define RVM_SCU_ADDR_MTVEC     12'h305 
`define RVM_SCU_ADDR_MCYCLE    12'hF00 
`define RVM_SCU_ADDR_MTIME     12'hF01
`define RVM_SCU_ADDR_MINSTRET  12'hF02 
`define RVM_SCU_ADDR_MCYCLEH   12'hF80 
`define RVM_SCU_ADDR_MTIMEH    12'hF81
`define RVM_SCU_ADDR_MINSTRETH 12'hF82 
`define RVM_SCU_ADDR_MCAUSE    12'h342 
`define RVM_SCU_ADDR_MBADADDR  12'h343 
`define RVM_SCU_ADDR_MIP       12'h344 
`define RVM_SCU_ADDR_MTIMECMP  12'hFF0
`define RVM_SCU_ADDR_MTIMECMPH 12'hFF1

//
// Cause register values.
`define RVM_CAUSE_MSI 31'd4  // Machine software interrupt
`define RVM_CAUSE_MTI 31'd7  // Machine timer interrupt
`define RVM_CAUSE_MEI 31'd11 // Machine external interrupt

`define RVM_CAUSE_IADDR_MISALIGN 31'd0 // Instruction address misaligned
`define RVM_CAUSE_IADDR_FAULT    31'd1 // Instruction access fault
`define RVM_CAUSE_ILLEGAL_INSTR  31'd2 // Illegal instruction
`define RVM_CAUSE_BREAKPOINT     31'd3 // Breakpoint
`define RVM_CAUSE_LADDR_MISALIGN 31'd4 // Load address misaligned
`define RVM_CAUSE_LADDR_FAULT    31'd5 // Load access fault
`define RVM_CAUSE_SADDR_MISALIGN 31'd6 // Store/AMO address misaligned
`define RVM_CAUSE_SADDR_FAULT    31'd7 // Store/AMO access fault
`define RVM_CAUSE_ECALL_U        31'd8 // call from U-mode
`define RVM_CAUSE_ECALL_S        31'd9 // call from S-mode
`define RVM_CAUSE_ECALL_H        31'd10 // call from H-mode
`define RVM_CAUSE_ECALL_M        31'd11 // call from M-mode


//
// Dense instruction encodings.
// ---------------------------------------------------------------------------


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
`define RVM_INSTR_BEQ     6'd40 
`define RVM_INSTR_AND     6'd41 
`define RVM_INSTR_AUIPC   6'd42 
`define RVM_INSTR_CSRRWI  6'd43 
`define RVM_INSTR_JALR    6'd44 
`define RVM_INSTR_SW      6'd45 
`define RVM_INSTR_ERET    6'd46 
`define RVM_INSTR_MRET    6'd47
