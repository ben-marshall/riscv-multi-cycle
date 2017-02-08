
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
input  wire         clk        , // System level clock.
input  wire         resetn     , // Asynchronous active low reset.

output wire [31:0] f_add_lhs   , // Left hand side of the adder operand.
output wire [31:0] f_add_rhs   , // Right hand side of the adder operand.
output wire [ 1:0] f_add_op    , // Adder operation to perform.
input  wire        f_add_valid , // Adder has finished computing.
input  wire [32:0] f_add_result, // Result of the adder operation.

output wire [31:0] f_bit_lhs   , // Left hand side of the bitwise operand.
output wire [31:0] f_bit_rhs   , // Right hand side of the bitwise operand.
output wire [ 1:0] f_bit_op    , // Bitwise operation to perform.
input  wire        f_bit_valid , // Bitwise has finished computing.
input  wire [31:0] f_bit_result, // Result of the bitwise operation.

output wire [31:0] f_shf_lhs   , // Left hand side of the shift operand.
output wire [31:0] f_shf_rhs   , // Right hand side of the shift operand.
output wire [ 1:0] f_shf_op    , // Shift operation to perform.
input  wire        f_shf_valid , // Shift has finished computing.
input  wire [31:0] f_shf_result, // Result of the shift operation.

input  wire [ 4:0] i_rs1_addr  , // Instruction RS1 Address.
input  wire [ 4:0] i_rs2_addr  , // Instruction RS2 Address.
input  wire [ 4:0] i_rd_addr   , // Instruction RD address.
input  wire [31:0] i_immediate , // Instruction immediate.
input  wire [ 5:0] i_instr     , // The instruction identifier code.

output wire        s_rs1_en    , // Register file RS1 Port Enable.
output wire [ 4:0] s_rs1_addr  , // Register file RS1 Address.
input  wire [31:0] s_rs1_rdata , // Register file RS1 Read Data.

output wire        s_rs2_en    , // Register file RS1 Port Enable.
output wire [ 4:0] s_rs2_addr  , // Register file RS1 Address.
input  wire [31:0] s_rs2_rdata , // Register file RS1 Read Data.

output wire        d_rd_wen    , // Register file RD Write Enable.
output wire [ 4:0] d_rd_addr   , // Register file RD Address.
output wire [31:0] d_rd_wdata  , // Register file RD Write Data.

output wire [ 1:0] d_pc_w_en   , // Set the PC to the value on wdata.
output wire [31:0] d_pc_wdata  , // Data to write to the PC register.
input  wire [31:0] s_pc        , // The current program counter value.

output wire [31:0] mem_addr    , // Memory address lines
input  wire [31:0] mem_rdata   , // Memory read data
output wire [31:0] mem_wdata   , // Memory write data
output wire        mem_c_en    , // Memory chip enable
output wire [ 3:0] mem_b_en    , // Memory byte enable
input  wire        mem_error   , // Memory error indicator
input  wire        mem_stall     // Memory stall indicator

);

localparam FSM_STATE_W = 8

//
// State encodings for the control FSM

localparam FSM_POST_RESET   = 0;
localparam FSM_FETCH_INSTR  = 1;
localparam FSM_DECODE_INSTR = 2;
localparam FSM_INC_PC_BY_4  = 3;

//
// Current and next state of the control FSM.
reg [FSM_STATE_W-1:0] ctrl_state;
reg [FSM_STATE_W-1:0] n_ctrl_state;

//
// Wait in the current state for something.
reg fsm_wait;

//-----------------------------------------------------------------------------
// Register file interface signals
//

//              TBD


//-----------------------------------------------------------------------------
// Program counter interface signals.
//

//              TBD


//-----------------------------------------------------------------------------
// Interface signals for the functional units.
// 

//              TBD



//-----------------------------------------------------------------------------
// Memory interface signals
// 

//              TBD



//-----------------------------------------------------------------------------

//
// process: p_ctrl_next_state
//
//      Responsible for computing the next state of the core given the
//      current state.
//
always @(*) begin : p_ctrl_next_state
    n_ctrl_state = ctrl_state;
    fsm_wait     = 1'b0;

    case (ctrl_state)

        FSM_POST_RESET: begin
            n_ctrl_state <= FSM_FETCH_INSTR;
        end

        FSM_FETCH_INSTR: begin
            n_ctrl_state <= FSM_DECODE_INSTR;
        end

        FSM_DECODE_INSTR: begin
            n_ctrl_state <= FSM_INC_PC_BY_4;
            fsm_wait      = mem_stall;
        end

        FSM_INC_PC_BY_4: begin
            n_ctrl_state <= FSM_DECODE_INSTR;
        end

        default: begin
            n_ctrl_state <= FSM_POST_RESET;
        end
    endcase
end


//
// process: p_ctrl_progress_state
//
//      Responsible for moving to the next state
//
always @(posedge clk, negedge resetn) : begin p_ctrl_progress_state
    if(!resetn) begin
        ctrl_state <= FSM_POST_RESET;
    end else if(!fsm_wait) begin
        ctrl_state <= n_ctrl_state;
    end
end

endmodule
