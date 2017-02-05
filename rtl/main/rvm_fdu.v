
//
// RISCV multi-cycle implementation.
//
// Module:      rvm_fdu
//
// Description: Responsible for fetching and decoding instructions.
//
//

`include "rvm_constants.v"

module rvm_fdu(
input  wire        clk,           // System level clock.
input  wire        resetn,        // Asynchronous active low reset.

input  wire [31:0] mem_rdata    , // The fetched memory word.
input  wire        mem_valid    , // Whether the fetched data is valid.

output wire        illegal_instr, // No valid instruction decoded.
output wire [ 4:0] rs1          , // Source register 1.
output wire [ 4:0] rs2          , // Source register 2.
output wire [ 4:0] dest         , // Destination register.
output wire [31:0] imm          , // Decoded immediate.
output wire [ 5:0] instr          // The instruction we have decoded.
);

//
// Generated decoder interface signals.
//

wire [31:0] inputword    ; // The word to decode.

wire        illegal_instr; // No valid instruction decoded.

wire [ 4:0] rs1          ; // Source register 1.
wire [ 4:0] rs2          ; // Source register 2.
wire [ 4:0] dest         ; // Destination register.
wire [31:0] imm          ; // Decoded immediate.

//
// Storage for the fetched word we are decoding.
//

reg  [31:0] fetched_data;

always @(posedge clk, negedge resetn) begin : p_decode_catch_rdata
    if(!resetn) begin
        fetched_data <= 32'b0;
    end else if (mem_valid) begin
        fetched_data <= mem_rdata;
    end
end


//
// Decoder for the RV32UI instruction set
//
rv32ui_decoder i_rvm_decoder(
.inputword    (fetched_data ), // The word to decode.
.decode_en    (1'b1         ), // Perform decode.
.illegal_instr(illegal_instr), // No valid instruction decoded.
.rs1          (rs1          ), // Source register 1.
.rs2          (rs2          ), // Source register 2.
.dest         (dest         ), // Destination register.
.imm          (imm          ), // Decoded immediate.
.instr        (instr        )  // The decoded instruction.
);

endmodule
