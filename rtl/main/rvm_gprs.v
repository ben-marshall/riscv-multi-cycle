
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

wire [31:0] gpr_00 = registers[00];
wire [31:0] gpr_01 = registers[01];
wire [31:0] gpr_02 = registers[02];
wire [31:0] gpr_03 = registers[03];
wire [31:0] gpr_04 = registers[04];
wire [31:0] gpr_05 = registers[05];
wire [31:0] gpr_06 = registers[06];
wire [31:0] gpr_07 = registers[07];
wire [31:0] gpr_08 = registers[08];
wire [31:0] gpr_09 = registers[09];
wire [31:0] gpr_10 = registers[10];
wire [31:0] gpr_11 = registers[11];
wire [31:0] gpr_12 = registers[12];
wire [31:0] gpr_13 = registers[13];
wire [31:0] gpr_14 = registers[14];
wire [31:0] gpr_15 = registers[15];
wire [31:0] gpr_16 = registers[16];
wire [31:0] gpr_17 = registers[17];
wire [31:0] gpr_18 = registers[18];
wire [31:0] gpr_19 = registers[19];
wire [31:0] gpr_20 = registers[20];
wire [31:0] gpr_21 = registers[21];
wire [31:0] gpr_22 = registers[22];
wire [31:0] gpr_23 = registers[23];
wire [31:0] gpr_24 = registers[24];
wire [31:0] gpr_25 = registers[25];
wire [31:0] gpr_26 = registers[26];
wire [31:0] gpr_27 = registers[27];
wire [31:0] gpr_28 = registers[28];
wire [31:0] gpr_29 = registers[29];
wire [31:0] gpr_30 = registers[30];
wire [31:0] gpr_31 = registers[31];

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
