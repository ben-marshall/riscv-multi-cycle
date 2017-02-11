
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

input  wire  ctrl_illegal_instr, // No valid instruction decoded.
output wire  ctrl_fdu_mem_valid, // Decoder needs to catch memory data.

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

localparam FSM_STATE_W = 8;

//
// State encodings for the control FSM

localparam FSM_POST_RESET   = 0;
localparam FSM_FETCH_INSTR  = 1;
localparam FSM_DECODE_INSTR = 2;
localparam FSM_INC_PC_BY_4  = 3;

// Easy way to tell a state where we are executuing an instruction, the
// top most bit of the state vector is always set.
localparam FSM_EX_MASK    = 8'hA0;

localparam FSM_EX_ADD     = FSM_EX_MASK | {2'b0,`RVM_INSTR_ADD    };
localparam FSM_EX_ADDI    = FSM_EX_MASK | {2'b0,`RVM_INSTR_ADDI   };
localparam FSM_EX_AND     = FSM_EX_MASK | {2'b0,`RVM_INSTR_AND    };
localparam FSM_EX_ANDI    = FSM_EX_MASK | {2'b0,`RVM_INSTR_ANDI   };
localparam FSM_EX_AUIPC   = FSM_EX_MASK | {2'b0,`RVM_INSTR_AUIPC  };
localparam FSM_EX_BEQ     = FSM_EX_MASK | {2'b0,`RVM_INSTR_BEQ    };
localparam FSM_EX_BGE     = FSM_EX_MASK | {2'b0,`RVM_INSTR_BGE    };
localparam FSM_EX_BGEU    = FSM_EX_MASK | {2'b0,`RVM_INSTR_BGEU   };
localparam FSM_EX_BLT     = FSM_EX_MASK | {2'b0,`RVM_INSTR_BLT    };
localparam FSM_EX_BLTU    = FSM_EX_MASK | {2'b0,`RVM_INSTR_BLTU   };
localparam FSM_EX_BNE     = FSM_EX_MASK | {2'b0,`RVM_INSTR_BNE    };
localparam FSM_EX_CSRRC   = FSM_EX_MASK | {2'b0,`RVM_INSTR_CSRRC  };
localparam FSM_EX_CSRRCI  = FSM_EX_MASK | {2'b0,`RVM_INSTR_CSRRCI };
localparam FSM_EX_CSRRS   = FSM_EX_MASK | {2'b0,`RVM_INSTR_CSRRS  };
localparam FSM_EX_CSRRSI  = FSM_EX_MASK | {2'b0,`RVM_INSTR_CSRRSI };
localparam FSM_EX_CSRRW   = FSM_EX_MASK | {2'b0,`RVM_INSTR_CSRRW  };
localparam FSM_EX_CSRRWI  = FSM_EX_MASK | {2'b0,`RVM_INSTR_CSRRWI };
localparam FSM_EX_ECALL   = FSM_EX_MASK | {2'b0,`RVM_INSTR_ECALL  };
localparam FSM_EX_ERET    = FSM_EX_MASK | {2'b0,`RVM_INSTR_ERET   };
localparam FSM_EX_FENCE   = FSM_EX_MASK | {2'b0,`RVM_INSTR_FENCE  };
localparam FSM_EX_FENCE_I = FSM_EX_MASK | {2'b0,`RVM_INSTR_FENCE_I};
localparam FSM_EX_JAL     = FSM_EX_MASK | {2'b0,`RVM_INSTR_JAL    };
localparam FSM_EX_JALR    = FSM_EX_MASK | {2'b0,`RVM_INSTR_JALR   };
localparam FSM_EX_LB      = FSM_EX_MASK | {2'b0,`RVM_INSTR_LB     };
localparam FSM_EX_LBU     = FSM_EX_MASK | {2'b0,`RVM_INSTR_LBU    };
localparam FSM_EX_LH      = FSM_EX_MASK | {2'b0,`RVM_INSTR_LH     };
localparam FSM_EX_LHU     = FSM_EX_MASK | {2'b0,`RVM_INSTR_LHU    };
localparam FSM_EX_LUI     = FSM_EX_MASK | {2'b0,`RVM_INSTR_LUI    };
localparam FSM_EX_LW      = FSM_EX_MASK | {2'b0,`RVM_INSTR_LW     };
localparam FSM_EX_OR      = FSM_EX_MASK | {2'b0,`RVM_INSTR_OR     };
localparam FSM_EX_ORI     = FSM_EX_MASK | {2'b0,`RVM_INSTR_ORI    };
localparam FSM_EX_SB      = FSM_EX_MASK | {2'b0,`RVM_INSTR_SB     };
localparam FSM_EX_SH      = FSM_EX_MASK | {2'b0,`RVM_INSTR_SH     };
localparam FSM_EX_SLL     = FSM_EX_MASK | {2'b0,`RVM_INSTR_SLL    };
localparam FSM_EX_SLLI    = FSM_EX_MASK | {2'b0,`RVM_INSTR_SLLI   };
localparam FSM_EX_SLT     = FSM_EX_MASK | {2'b0,`RVM_INSTR_SLT    };
localparam FSM_EX_SLTI    = FSM_EX_MASK | {2'b0,`RVM_INSTR_SLTI   };
localparam FSM_EX_SLTIU   = FSM_EX_MASK | {2'b0,`RVM_INSTR_SLTIU  };
localparam FSM_EX_SLTU    = FSM_EX_MASK | {2'b0,`RVM_INSTR_SLTU   };
localparam FSM_EX_SRA     = FSM_EX_MASK | {2'b0,`RVM_INSTR_SRA    };
localparam FSM_EX_SRAI    = FSM_EX_MASK | {2'b0,`RVM_INSTR_SRAI   };
localparam FSM_EX_SRL     = FSM_EX_MASK | {2'b0,`RVM_INSTR_SRL    };
localparam FSM_EX_SRLI    = FSM_EX_MASK | {2'b0,`RVM_INSTR_SRLI   };
localparam FSM_EX_SUB     = FSM_EX_MASK | {2'b0,`RVM_INSTR_SUB    };
localparam FSM_EX_SW      = FSM_EX_MASK | {2'b0,`RVM_INSTR_SW     };
localparam FSM_EX_XOR     = FSM_EX_MASK | {2'b0,`RVM_INSTR_XOR    };
localparam FSM_EX_XORI    = FSM_EX_MASK | {2'b0,`RVM_INSTR_XORI   };

//
// Current and next state of the control FSM.
reg [FSM_STATE_W-1:0] ctrl_state;
reg [FSM_STATE_W-1:0] n_ctrl_state;

//
// Wait in the current state for something.
reg fsm_wait;

//-----------------------------------------------------------------------------
// Instruction decode unit signals
//

assign ctrl_fdu_mem_valid = ctrl_state == FSM_FETCH_INSTR;

//-----------------------------------------------------------------------------
// Register file interface signals
//

//              TBD


//-----------------------------------------------------------------------------
// Program counter interface signals.
//

assign d_pc_w_en  = ctrl_state == FSM_INC_PC_BY_4;
assign d_pc_wdata = {32{ctrl_state==FSM_INC_PC_BY_4}} & f_add_result;


//-----------------------------------------------------------------------------
// Interface signals for the functional units.
// 

assign f_add_lhs  = {32{ctrl_state == FSM_INC_PC_BY_4}} & s_pc;
assign f_add_rhs  = {32{ctrl_state == FSM_INC_PC_BY_4}} & 32'd4;
assign f_add_op   = { 2{ctrl_state == FSM_INC_PC_BY_4}} & `RVM_ARITH_ADD;


//-----------------------------------------------------------------------------
// Memory interface signals
// 

// Memory address lines
assign mem_addr  = {32{ctrl_state == FSM_FETCH_INSTR}} & s_pc;

// Memory write data
assign mem_wdata = 32'b0  ;

// Memory chip enable.
assign mem_c_en  = ctrl_state == FSM_FETCH_INSTR;

// Memory byte enable
assign mem_b_en  = {4{ctrl_state == FSM_FETCH_INSTR}};



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

        FSM_DECODE_INSTR : begin
            n_ctrl_state <= (FSM_EX_MASK | {2'b0, i_instr});
        end

        FSM_EX_ADD    : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_ADDI   : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_AND    : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_ANDI   : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_AUIPC  : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_BEQ    : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_BGE    : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_BGEU   : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_BLT    : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_BLTU   : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_BNE    : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_CSRRC  : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_CSRRCI : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_CSRRS  : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_CSRRSI : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_CSRRW  : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_CSRRWI : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_ECALL  : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_ERET   : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_FENCE  : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_FENCE_I: n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_JAL    : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_JALR   : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_LB     : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_LBU    : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_LH     : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_LHU    : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_LUI    : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_LW     : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_OR     : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_ORI    : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_SB     : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_SH     : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_SLL    : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_SLLI   : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_SLT    : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_SLTI   : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_SLTIU  : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_SLTU   : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_SRA    : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_SRAI   : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_SRL    : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_SRLI   : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_SUB    : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_SW     : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_XOR    : n_ctrl_state <= FSM_INC_PC_BY_4;
        FSM_EX_XORI   : n_ctrl_state <= FSM_INC_PC_BY_4;

        FSM_INC_PC_BY_4: begin
            n_ctrl_state    <= f_add_valid ? FSM_FETCH_INSTR :
                                             FSM_INC_PC_BY_4 ;
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
always @(posedge clk, negedge resetn) begin : p_ctrl_progress_state
    if(!resetn) begin
        ctrl_state <= FSM_POST_RESET;
    end else if(!fsm_wait) begin
        ctrl_state <= n_ctrl_state;
    end
end

endmodule
