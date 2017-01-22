
//
// RISCV single-cycle implementation.
//
// Constants File
//
// Description: Contains build-time constant used by the core.
//

`define WORD_W      32
`define REG_ADDR_W  5

`define RISCV_PC_RESET_VALUE 32'h00000200
//
// System Control Unit register addresses and values.
// ---------------------------------------------------------------------------

`define RISCV_SCU_MISA        32'h00000000
`define RISCV_SCU_MVENDORID   32'h00000000
`define RISCV_SCU_MARCHID     32'h00000000
`define RISCV_SCU_MIMPID      32'h00000000
`define RISCV_SCU_MHARTID     32'h00000000

`define RISCV_SCU_ADDR_MISA      12'hF14 // Should be F10, toolchain gives this.
`define RISCV_SCU_ADDR_MVENDORID 12'hF11 
`define RISCV_SCU_ADDR_MARCHID   12'hF12 
`define RISCV_SCU_ADDR_MIMPID    12'hF13 
`define RISCV_SCU_ADDR_MHARTID   12'hF10 
`define RISCV_SCU_ADDR_MSCRATCH  12'h340 
`define RISCV_SCU_ADDR_MEPC      12'h341 
`define RISCV_SCU_ADDR_MEDELEG   12'h302 
`define RISCV_SCU_ADDR_MIDELEG   12'h303 
`define RISCV_SCU_ADDR_MIE       12'h304 
`define RISCV_SCU_ADDR_MTVEC     12'h305 
`define RISCV_SCU_ADDR_MCYCLE    12'hF00 
`define RISCV_SCU_ADDR_MTIME     12'hF01
`define RISCV_SCU_ADDR_MINSTRET  12'hF02 
`define RISCV_SCU_ADDR_MCYCLEH   12'hF80 
`define RISCV_SCU_ADDR_MTIMEH    12'hF81
`define RISCV_SCU_ADDR_MINSTRETH 12'hF82 
`define RISCV_SCU_ADDR_MCAUSE    12'h342 
`define RISCV_SCU_ADDR_MBADADDR  12'h343 
`define RISCV_SCU_ADDR_MIP       12'h344 
`define RISCV_SCU_ADDR_MTIMECMP  12'hFF0
`define RISCV_SCU_ADDR_MTIMECMPH 12'hFF1

//
// Cause register values.
`define RISCV_CAUSE_MSI 31'd4  // Machine software interrupt
`define RISCV_CAUSE_MTI 31'd7  // Machine timer interrupt
`define RISCV_CAUSE_MEI 31'd11 // Machine external interrupt

`define RISCV_CAUSE_IADDR_MISALIGN 31'd0 // Instruction address misaligned
`define RISCV_CAUSE_IADDR_FAULT    31'd1 // Instruction access fault
`define RISCV_CAUSE_ILLEGAL_INSTR  31'd2 // Illegal instruction
`define RISCV_CAUSE_BREAKPOINT     31'd3 // Breakpoint
`define RISCV_CAUSE_LADDR_MISALIGN 31'd4 // Load address misaligned
`define RISCV_CAUSE_LADDR_FAULT    31'd5 // Load access fault
`define RISCV_CAUSE_SADDR_MISALIGN 31'd6 // Store/AMO address misaligned
`define RISCV_CAUSE_SADDR_FAULT    31'd7 // Store/AMO access fault
`define RISCV_CAUSE_ECALL_U        31'd8 // call from U-mode
`define RISCV_CAUSE_ECALL_S        31'd9 // call from S-mode
`define RISCV_CAUSE_ECALL_H        31'd10 // call from H-mode
`define RISCV_CAUSE_ECALL_M        31'd11 // call from M-mode

