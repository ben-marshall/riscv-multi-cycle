
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
input  wire         clk,                // System level clock.
input  wire         resetn,             // Asynchronous active low reset.

output wire [31:0]  mem_addr,           // Memory address lines
input  wire [31:0]  mem_rdata,          // Memory read data
output wire [31:0]  mem_wdata,          // Memory write data
output wire         mem_c_en,           // Memory chip enable
output wire [ 3:0]  mem_b_en,           // Memory byte enable
input  wire         mem_error,          // Memory error indicator
input  wire         mem_stall           // Memory stall indicator

);

//-----------------------------------------------------------------------------
// Interface signals for the CSR registers module
// 

wire        scu_instr_retired; // Set each time an instruction finishes.
wire        scu_goto_mtvec   ; // Next pc write should be to mtvec.
wire [ 3:0] f_scu_op         ; // Operation the SCU should do on CSRs
wire [31:0] f_scu_result     ; // WB result of any CSR operation.
wire [31:0] s_epc            ; // Current EPC value.
wire [31:0] s_mtvec          ; // Current MTVEC value.

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
wire [ 4:0] f_shf_rhs   ; // Right hand side of the shift operand.
wire [ 1:0] f_shf_op    ; // Shift operation to perform.
wire        f_shf_valid ; // Shift has finished computing.
wire [31:0] f_shf_result; // Result of the shift operation.

//-----------------------------------------------------------------------------
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
// Program counter interface signals.
//

wire        d_pc_w_en;   // Set the PC to the value on wdata.
wire [31:0] d_pc_wdata;  // Data to write to the PC register.
wire [31:0] s_pc;        // The current program counter value.

//-----------------------------------------------------------------------------
// Fetch decode unit
//

wire        ctrl_illegal_instr;
wire        ctrl_fdu_mem_valid;

wire [ 4:0] i_rs1_addr  ; // Instruction RS1 Address.
wire [ 4:0] i_rs2_addr  ; // Instruction RS2 Address.
wire [ 4:0] i_rd_addr   ; // Instruction RD address.
wire [31:0] i_immediate ; // Instruction immediate.
wire [ 5:0] i_instr     ; // The instruction identifier code.


rvm_fdu i_rvm_fdu(
.clk          (clk               ), // System level clock.
.resetn       (resetn            ), // Asynchronous active low reset.
.mem_rdata    (mem_rdata         ), // The fetched memory word.
.mem_valid    (ctrl_fdu_mem_valid), // Whether the fetched data is valid.
.illegal_instr(ctrl_illegal_instr), // No valid instruction decoded.
.rs1          (i_rs1_addr        ), // Source register 1.
.rs2          (i_rs2_addr        ), // Source register 2.
.dest         (i_rd_addr         ), // Destination register.
.imm          (i_immediate       ), // Decoded immediate.
.instr        (i_instr           )  // The instruction we have decoded.
);

//-----------------------------------------------------------------------------
// General Purpose and Control Status Register sets.
//

rvm_pcu i_rvm_pcu (
.clk     (clk       ), // System clock
.resetn  (resetn    ), // Asynchronous active low reset.
.pc_w_en (d_pc_w_en ), // Set the PC to the value on wdata.
.pc_wdata(d_pc_wdata), // Data to write to the PC register.
.pc      (s_pc      )  // The current program counter value.
);

rvm_gprs i_rvm_gprs (
.clk       (clk        ), // The core level clock for sequential logic.
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

rvm_adder i_rvm_add(
.lhs   (f_add_lhs   ), // Value on left-hand side of operator
.rhs   (f_add_rhs   ), // Value on right-hand side of operator
.op    (f_add_op    ), // What to do?
.valid (f_add_valid ), // Asserts that the result is complete.
.result(f_add_result)  // The result of the addition / subtraction
);

rvm_bitwise i_rvm_bitwise(
.lhs   (f_bit_lhs   ), // Value on left-hand side of operator
.rhs   (f_bit_rhs   ), // Value on right-hand side of operator
.op    (f_bit_op    ), // What to do?
.valid (f_bit_valid ), // Asserts that the result is complete.
.result(f_bit_result)  // The result of the bitwise op
);

rvm_shift i_rvm_shift(
.lhs   (f_shf_lhs   ), // Value on left-hand side of shift operator
.rhs   (f_shf_rhs   ), // Value on right-hand side of shift operator
.op    (f_shf_op    ), // What to do?
.valid (f_shf_valid ), // Asserts that the result is complete.
.result(f_shf_result)  // The result of the shift
);


//-----------------------------------------------------------------------------
// Core control instance.
//

rvm_control i_rvm_control(
.clk          (clk         ), // System level clock.
.resetn       (resetn      ), // Asynchronous active low reset.
.f_add_lhs    (f_add_lhs   ), // Left hand side of the adder operand.
.f_add_rhs    (f_add_rhs   ), // Right hand side of the adder operand.
.f_add_op     (f_add_op    ), // Adder operation to perform.
.f_add_valid  (f_add_valid ), // Adder has finished computing.
.f_add_result (f_add_result), // Result of the adder operation.
.f_bit_lhs    (f_bit_lhs   ), // Left hand side of the bitwise operand.
.f_bit_rhs    (f_bit_rhs   ), // Right hand side of the bitwise operand.
.f_bit_op     (f_bit_op    ), // Bitwise operation to perform.
.f_bit_valid  (f_bit_valid ), // Bitwise has finished computing.
.f_bit_result (f_bit_result), // Result of the bitwise operation.
.f_shf_lhs    (f_shf_lhs   ), // Left hand side of the shift operand.
.f_shf_rhs    (f_shf_rhs   ), // Right hand side of the shift operand.
.f_shf_op     (f_shf_op    ), // Shift operation to perform.
.f_shf_valid  (f_shf_valid ), // Shift has finished computing.
.f_shf_result (f_shf_result), // Result of the shift operation.
.ctrl_illegal_instr(ctrl_illegal_instr),
.ctrl_fdu_mem_valid(ctrl_fdu_mem_valid),
.i_rs1_addr   (i_rs1_addr  ), // Instruction RS1 Address.
.i_rs2_addr   (i_rs2_addr  ), // Instruction RS2 Address.
.i_rd_addr    (i_rd_addr   ), // Instruction RD address.
.i_immediate  (i_immediate ), // Instruction immediate.
.i_instr      (i_instr     ), // The instruction identifier code.
.s_rs1_en     (s_rs1_en    ), // Register file RS1 Port Enable.
.s_rs1_addr   (s_rs1_addr  ), // Register file RS1 Address.
.s_rs1_rdata  (s_rs1_rdata ), // Register file RS1 Read Data.
.s_rs2_en     (s_rs2_en    ), // Register file RS1 Port Enable.
.s_rs2_addr   (s_rs2_addr  ), // Register file RS1 Address.
.s_rs2_rdata  (s_rs2_rdata ), // Register file RS1 Read Data.
.d_rd_wen     (d_rd_wen    ), // Register file RD Write Enable.
.d_rd_addr    (d_rd_addr   ), // Register file RD Address.
.d_rd_wdata   (d_rd_wdata  ), // Register file RD Write Data.
.d_pc_w_en    (d_pc_w_en   ), // Set the PC to the value on wdata.
.d_pc_wdata   (d_pc_wdata  ), // Data to write to the PC register.
.s_pc         (s_pc        ), // The current program counter value.
.mem_addr     (mem_addr    ), // Memory address lines
.mem_rdata    (mem_rdata   ), // Memory read data
.mem_wdata    (mem_wdata   ), // Memory write data
.mem_c_en     (mem_c_en    ), // Memory chip enable
.mem_b_en     (mem_b_en    ), // Memory byte enable
.mem_error    (mem_error   ), // Memory error indicator
.mem_stall    (mem_stall   )  // Memory stall indicator
);


rvm_scu i_scu(
.clk                (clk), // Core level clock signal.
.resetn             (resetn), // Asynchronous negative edge reset.
.core_stall         (1'b0), // The SCU should wait while the core stalls.
.pc                 (s_pc), // Current value of the program counter.
.instr_retired      (scu_instr_retired), // completion of an instruction.
.goto_mtvec         (scu_goto_mtvec   ), // Tells PCU to go straight to MTVEC.
.scu_op             (f_scu_op         ), // Operation the FU should perform.
.arg_rs1_addr       (i_rs1_addr), // Address of register 2
.arg_rs1            (s_rs1_rdata), //The value of source register 1.
.arg_rs2            (s_rs2_rdata), //The value of source register 2.
.arg_imm            (i_immediate), //The Value of the immediate (if any).
.wb_val             (f_scu_result), // value to write back to register file.
.ld_bad_addr        (1'b0), // Do we need to store a bad address?
.bad_addr_val       (mem_addr), // The bad address value to store.
.trap_msi           (1'b0), // Machine software interrupt
.trap_mei           (1'b0), // Machine external interrupt
.trap_iaddr_misalign(1'b0), // Instruction address misaligned
.trap_iaddr_fault   (1'b0), // Instruction access fault
.trap_illegal_instr (1'b0), // Illegal instruction
.trap_breakpoint    (1'b0), // Breakpoint
.trap_laddr_misalign(1'b0), // Load address misaligned
.trap_laddr_fault   (1'b0), // Load access fault
.trap_saddr_misalign(1'b0), // Store/AMO address misaligned
.trap_saddr_fault   (1'b0), // Store/AMO access fault
.mepc               (s_epc), // The machine error program counter register.
.mtvec              (s_mtvec)  // The machine trap handler address register.
);

endmodule

