
//
// RISCV multi-cycle implementation.
//
// Module:      rvm_gprs
//
// Description: Main 32x32 register file for the core.
//
//

`include "rvm_constants.v"

module rvm_gprs(
input  wire        clk        , // The core level clock for sequential logic.
output wire        clk_req    , // Whether the gprs need a clock this cycle.
input  wire        resetn     , // Active low asynchronous reset signal.

input  wire        rs1_en     , // RS1 Port Enable.
input  wire [4 :0] rs1_addr   , // RS1 Address.
output wire [31:0] rs1_rdata  , // RS1 Read Data.

input  wire        rs2_en     , // RS1 Port Enable.
input  wire [4 :0] rs2_addr   , // RS1 Address.
output wire [31:0] rs2_rdata  , // RS1 Read Data.

input  wire        rd_wen     , // RD Write Enable.
input  wire [4 :0] rd_addr    , // RD Address.
input  wire [31:0] rd_wdata     // RD Write Data.
    
);

reg [31:0] registers [31:0]; // The main register file.

// Register reads.
assign rs1_rdata = registers[rs1_addr & {5{rs1_en}}];
assign rs2_rdata = registers[rs2_addr & {5{rs2_en}}];

// Clock reqest only when writing.
assign clk_req = rd_wen;

genvar gen_i; // Used to generate the register and write logic.
generate

    for (gen_i = 0 ; gen_i < 32; gen_i = gen_i + 1) begin
        if(gen_i == 0) begin
            always @(resetn) begin
                registers[gen_i] = 32'b0;
            end
        end else begin
            always @(posedge clk, negedge resetn) begin
                if(resetn == 1'b0) begin
                    registers[gen_i] <= 32'b0;
                end else if(rd_wen == 1'b1 && rd_addr == gen_i) begin
                    registers[gen_i] <= rd_wdata;
                end
            end
        end

    end

endgenerate

endmodule
