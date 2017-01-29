
//
// RISCV multi-cycle implementation.
//
// Module:      rv32ui_decoder.v
//
// Description: Instruction decoder module. Takes a single 32 bit word as input
//              and decodes it into the relevent data and control lines.
//

`include "rvm_constants.v"

module rv32ui_decoder(
input  wire [`WORD_W    -1:0] inputword, // The word to decode.
input  wire                   decode_en, // Perform decode.

output wire                   illegal_instr, // No valid instruction decoded.

output wire [`REG_ADDR_W-1:0] rs1      , // Source register 1.
output wire [`REG_ADDR_W-1:0] rs2      , // Source register 2.
output wire [`REG_ADDR_W-1:0] dest     , // Destination register.
output wire [`WORD_W    -1:0] imm        // Decoded immediate.

);

// Use enc for internal references to input word. It is isolated such that it
// only runs when decoding is enabled.
wire [`WORD_W-1:0] enc = inputword & {32{decode_en}};

// BEGIN AUTO-GENERATED CODE
wire gen_bltu =    (enc[14:12] == 3'd6)
                && (enc[6:2] == 5'd24)
                && (enc[1:0] == 2'd3);
wire gen_csrrw =    (enc[14:12] == 3'd1)
                 && (enc[6:2] == 5'd28)
                 && (enc[1:0] == 2'd3);
wire gen_lw =    (enc[14:12] == 3'd2)
              && (enc[6:2] == 5'd0)
              && (enc[1:0] == 2'd3);
wire gen_lh =    (enc[14:12] == 3'd1)
              && (enc[6:2] == 5'd0)
              && (enc[1:0] == 2'd3);
wire gen_lhu =    (enc[14:12] == 3'd5)
               && (enc[6:2] == 5'd0)
               && (enc[1:0] == 2'd3);
wire gen_lb =    (enc[14:12] == 3'd0)
              && (enc[6:2] == 5'd0)
              && (enc[1:0] == 2'd3);
wire gen_lbu =    (enc[14:12] == 3'd4)
               && (enc[6:2] == 5'd0)
               && (enc[1:0] == 2'd3);
wire gen_sh =    (enc[14:12] == 3'd1)
              && (enc[6:2] == 5'd8)
              && (enc[1:0] == 2'd3);
wire gen_sb =    (enc[14:12] == 3'd0)
              && (enc[6:2] == 5'd8)
              && (enc[1:0] == 2'd3);
wire gen_add =    (enc[31:25] == 7'd0)
               && (enc[14:12] == 3'd0)
               && (enc[6:2] == 5'd12)
               && (enc[1:0] == 2'd3);
wire gen_csrrc =    (enc[14:12] == 3'd3)
                 && (enc[6:2] == 5'd28)
                 && (enc[1:0] == 2'd3);
wire gen_bne =    (enc[14:12] == 3'd1)
               && (enc[6:2] == 5'd24)
               && (enc[1:0] == 2'd3);
wire gen_bgeu =    (enc[14:12] == 3'd7)
                && (enc[6:2] == 5'd24)
                && (enc[1:0] == 2'd3);
wire gen_sltiu =    (enc[14:12] == 3'd3)
                 && (enc[6:2] == 5'd4)
                 && (enc[1:0] == 2'd3);
wire gen_srli =    (enc[31:26] == 6'd0)
                && (enc[14:12] == 3'd5)
                && (enc[6:2] == 5'd4)
                && (enc[1:0] == 2'd3);
wire gen_fence =    (enc[14:12] == 3'd0)
                 && (enc[6:2] == 5'd3)
                 && (enc[1:0] == 2'd3);
wire gen_fence_i =    (enc[14:12] == 3'd1)
                 && (enc[6:2] == 5'd3)
                 && (enc[1:0] == 2'd3);
wire gen_sll =    (enc[31:25] == 7'd0)
               && (enc[14:12] == 3'd1)
               && (enc[6:2] == 5'd12)
               && (enc[1:0] == 2'd3);
wire gen_xor =    (enc[31:25] == 7'd0)
               && (enc[14:12] == 3'd4)
               && (enc[6:2] == 5'd12)
               && (enc[1:0] == 2'd3);
wire gen_sub =    (enc[31:25] == 7'd32)
               && (enc[14:12] == 3'd0)
               && (enc[6:2] == 5'd12)
               && (enc[1:0] == 2'd3);
wire gen_blt =    (enc[14:12] == 3'd4)
               && (enc[6:2] == 5'd24)
               && (enc[1:0] == 2'd3);
wire gen_ecall =    (enc[11:7] == 5'd0)
                 && (enc[19:15] == 5'd0)
                 && (enc[31:20] == 12'd0)
                 && (enc[14:12] == 3'd0)
                 && (enc[6:2] == 5'd28)
                 && (enc[1:0] == 2'd3);
wire gen_lui =    (enc[6:2] == 5'd13)
               && (enc[1:0] == 2'd3);
wire gen_csrrci =    (enc[14:12] == 3'd7)
                  && (enc[6:2] == 5'd28)
                  && (enc[1:0] == 2'd3);
wire gen_addi =    (enc[14:12] == 3'd0)
                && (enc[6:2] == 5'd4)
                && (enc[1:0] == 2'd3);
wire gen_csrrsi =    (enc[14:12] == 3'd6)
                  && (enc[6:2] == 5'd28)
                  && (enc[1:0] == 2'd3);
wire gen_srai =    (enc[31:26] == 6'd16)
                && (enc[14:12] == 3'd5)
                && (enc[6:2] == 5'd4)
                && (enc[1:0] == 2'd3);
wire gen_ori =    (enc[14:12] == 3'd6)
               && (enc[6:2] == 5'd4)
               && (enc[1:0] == 2'd3);
wire gen_csrrs =    (enc[14:12] == 3'd2)
                 && (enc[6:2] == 5'd28)
                 && (enc[1:0] == 2'd3);
wire gen_sra =    (enc[31:25] == 7'd32)
               && (enc[14:12] == 3'd5)
               && (enc[6:2] == 5'd12)
               && (enc[1:0] == 2'd3);
wire gen_bge =    (enc[14:12] == 3'd5)
               && (enc[6:2] == 5'd24)
               && (enc[1:0] == 2'd3);
wire gen_srl =    (enc[31:25] == 7'd0)
               && (enc[14:12] == 3'd5)
               && (enc[6:2] == 5'd12)
               && (enc[1:0] == 2'd3);
wire gen_or =    (enc[31:25] == 7'd0)
              && (enc[14:12] == 3'd6)
              && (enc[6:2] == 5'd12)
              && (enc[1:0] == 2'd3);
wire gen_xori =    (enc[14:12] == 3'd4)
                && (enc[6:2] == 5'd4)
                && (enc[1:0] == 2'd3);
wire gen_andi =    (enc[14:12] == 3'd7)
                && (enc[6:2] == 5'd4)
                && (enc[1:0] == 2'd3);
wire gen_jal =    (enc[6:2] == 5'd27)
               && (enc[1:0] == 2'd3);
wire gen_slt =    (enc[31:25] == 7'd0)
               && (enc[14:12] == 3'd2)
               && (enc[6:2] == 5'd12)
               && (enc[1:0] == 2'd3);
wire gen_slti =    (enc[14:12] == 3'd2)
                && (enc[6:2] == 5'd4)
                && (enc[1:0] == 2'd3);
wire gen_sltu =    (enc[31:25] == 7'd0)
                && (enc[14:12] == 3'd3)
                && (enc[6:2] == 5'd12)
                && (enc[1:0] == 2'd3);
wire gen_slli =    (enc[31:26] == 6'd0)
                && (enc[14:12] == 3'd1)
                && (enc[6:2] == 5'd4)
                && (enc[1:0] == 2'd3);
wire gen_beq =    (enc[14:12] == 3'd0)
               && (enc[6:2] == 5'd24)
               && (enc[1:0] == 2'd3);
wire gen_and =    (enc[31:25] == 7'd0)
               && (enc[14:12] == 3'd7)
               && (enc[6:2] == 5'd12)
               && (enc[1:0] == 2'd3);
wire gen_auipc =    (enc[6:2] == 5'd5)
                 && (enc[1:0] == 2'd3);
wire gen_csrrwi =    (enc[14:12] == 3'd5)
                  && (enc[6:2] == 5'd28)
                  && (enc[1:0] == 2'd3);
wire gen_jalr =    (enc[14:12] == 3'd0)
                && (enc[6:2] == 5'd25)
                && (enc[1:0] == 2'd3);
wire gen_sw =    (enc[14:12] == 3'd2)
              && (enc[6:2] == 5'd8)
              && (enc[1:0] == 2'd3);
wire gen_eret =  (enc[7:0] == 8'h73)
              && (enc[31:20] == 12'h100)
              && (enc[14:12] == 3'b0);
// END AUTO-GENERATED CODE

// Detect what sort of instruction encoding format we have.
wire itype_r    = gen_add  | gen_slt  | gen_sltu  | gen_and  | gen_or  |
                  gen_xor  | gen_sll  | gen_srl   | gen_sub  | gen_sra ;
wire itype_i    = gen_andi | gen_addi | gen_sltiu | gen_slti | gen_ori | 
                  gen_xori | gen_slli | gen_srli  | gen_srai | gen_lw  |
                  gen_lh   | gen_lhu  | gen_lb    | gen_lbu  | gen_csrrw |
                  gen_csrrs| gen_csrrc| gen_csrrwi| gen_csrrsi | gen_csrrci |
                  gen_jalr | gen_fence_i;
wire itype_s    = gen_sw   | gen_sh   | gen_sb    ;
wire itype_sb   = gen_beq  | gen_bne  | gen_bltu  | gen_blt  | gen_bge |
                  gen_bgeu | gen_eret ;
wire itype_u    = gen_lui  | gen_auipc;
wire itype_uj   = gen_jal  ;

//
// Have we decoded a valid instruction?
assign illegal_instr = decode_en & 
            !(itype_r | itype_i | itype_s | itype_sb | itype_u | itype_uj | gen_fence);

// Extract and isolate the register address bitfields.
assign rs1 = enc[19:15]; // & {`REG_ADDR_W{itype_r | itype_i | itype_s | itype_sb}};
assign rs2 = enc[24:20]; // & {`REG_ADDR_W{itype_r |           itype_s | itype_sb}};
assign dest= enc[11:7 ]; // & {`REG_ADDR_W{itype_r | itype_i | itype_u | itype_uj}};

// Extract and isolate the immediate value from the encoded instruction.
assign imm = {`WORD_W{itype_i }} & {{21{enc[31]}},enc[31:20]               } |
             {`WORD_W{itype_s }} & {{21{enc[31]}},enc[31:25],enc[11:7]     } |
             {`WORD_W{itype_sb}} & {{20{enc[31]}},enc[31:25],enc[11:8],1'b0} |
             {`WORD_W{itype_u }} & {enc[31:12] , 12'b0                     } |
             {`WORD_W{itype_uj}} & {{12{enc[31]}}, enc[19:12], enc[20],enc[30:21],1'b0};

//
// TODO: Decoder outputs to decide which instruction to execute.
//

endmodule
