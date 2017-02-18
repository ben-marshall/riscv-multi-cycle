
//
// RISCV multi-cycle implementation.
//
// Module:      rvm_scu
//
// Description: System control unit. Contains core state, control and
//              configuration registers.
//

`include "rvm_constants.v"

module rvm_scu#(
parameter RVM_SCU_MISA      = `RVM_SCU_MISA     ,
parameter RVM_SCU_MVENDORID = `RVM_SCU_MVENDORID,
parameter RVM_SCU_MARCHID   = `RVM_SCU_MARCHID  ,
parameter RVM_SCU_MIMPID    = `RVM_SCU_MIMPID   ,
parameter RVM_SCU_MHARTID   = `RVM_SCU_MHARTID  
)(
input  wire clk,            // Core level clock signal.
input  wire resetn,         // Asynchronous negative edge reset.
input  wire core_stall,     // The SCU should wait while the core stalls.

input  wire [31:0] pc,      // Current value of the program counter.
input  wire        instr_retired, // Indicates completion of an instruction.
output wire        goto_mtvec, // Tells the PCU to jump straight to the MTVEC.

input  wire [3:0 ] scu_op, // Operation the FU should perform.

input  wire [4 :0] arg_rs1_addr, // Address of register 2
input  wire [31:0] arg_rs1, //The value of source register 1.
input  wire [31:0] arg_rs2, //The value of source register 2.
input  wire [31:0] arg_imm, //The Value of the immediate (if any).

output wire [31:0] wb_val , //The value to write back to the register file.

input  wire        ld_bad_addr, // Do we need to store a bad address?
input  wire [31:0] bad_addr_val, // The bad address value to store.

input  wire        trap_msi           ,// Machine software interrupt
input  wire        trap_mei           ,// Machine external interrupt
input  wire        trap_iaddr_misalign,// Instruction address misaligned
input  wire        trap_iaddr_fault   ,// Instruction access fault
input  wire        trap_illegal_instr ,// Illegal instruction
input  wire        trap_breakpoint    ,// Breakpoint
input  wire        trap_laddr_misalign,// Load address misaligned
input  wire        trap_laddr_fault   ,// Load access fault
input  wire        trap_saddr_misalign,// Store/AMO address misaligned
input  wire        trap_saddr_fault   ,// Store/AMO access fault

output wire [31:0] mepc   , // The machine error program counter register.
output wire [31:2] mtvec    // The machine trap handler address register.
);

//
// MIP Register
reg         reg_mip_meip;   // Machine external interrupt pending.
reg         reg_mip_mtip;   // Machine timer interrupt pending.
reg         reg_mip_msip;   // Machine software interrupt pending.
// MIE Register
reg         reg_mie_meie;   // Machine external interrupt enable.
reg         reg_mie_mtie;   // Machine timer interrupt enable.
reg         reg_mie_msie;   // Machine software interrupt enable.

//
// MTIME and MTIMECMP registers.
wire [63:0]  reg_mtime;
reg  [63:0]  reg_mtimecmp;

wire         trap_mti;          // Machine timer interrupt

//
// Only raise an interrupt if it is enabled in the MIE register.
wire raise_interrupt_mei = reg_mip_meip & reg_mie_meie ; 
wire raise_interrupt_mti = reg_mip_mtip & reg_mie_mtie ; 
wire raise_interrupt_msi = reg_mip_msip & reg_mie_msie ;

assign raise_interrupt = raise_interrupt_mei | 
                         raise_interrupt_mti | 
                         raise_interrupt_msi ;

assign raise_trap      = trap_iaddr_misalign | trap_iaddr_fault    |
                         trap_illegal_instr  | trap_breakpoint     |
                         trap_laddr_misalign | trap_laddr_fault    |
                         trap_saddr_misalign | trap_saddr_fault    ;

//
// Handle a trap due to an interupt or exception.
assign goto_mtvec      = raise_interrupt | raise_trap;

//
// Declare all of the CSRs
// ------------------------------------------------------------------------

//
// Constant value registers.
wire [31:0] reg_misa      = RVM_SCU_MISA     ;
wire [31:0] reg_mvendorid = RVM_SCU_MVENDORID;
wire [31:0] reg_marchid   = RVM_SCU_MARCHID  ;
wire [31:0] reg_mimpid    = RVM_SCU_MIMPID   ;
wire [31:0] reg_mhartid   = RVM_SCU_MHARTID  ;
wire [31:0] reg_medeleg   = 32'b0            ;
wire [31:0] reg_mideleg   = 32'b0            ;

//
// MEPC register.
reg [31:0]  reg_mepc;
wire  mepc_capture = raise_trap;
assign mepc = reg_mepc;
always @(posedge clk or negedge resetn) begin : p_scu_mepc
    if(resetn == 1'b0) begin
        reg_mepc <= 32'b0;
    end else if(mepc_capture) begin
        reg_mepc <= pc;
    end else if(csr_write & csr_address == `RVM_SCU_ADDR_MEPC) begin
        reg_mepc <= csr_wdata;
    end
end

//
// MTVEC register.
reg    [31:0]  reg_mtvec;
assign mtvec = reg_mtvec[31:2];
always @(posedge clk or negedge resetn) begin : p_scu_mtvec
    if(resetn == 1'b0) begin
        reg_mtvec <= 32'h0000_01c0;
    end else if(csr_write & csr_address == `RVM_SCU_ADDR_MTVEC) begin
        reg_mtvec <= {csr_wdata[31:2],2'b0};
    end
end

//
// MSCRATCH register.
reg [31:0]  reg_mscratch;
always @(posedge clk or negedge resetn) begin : p_scu_mscratch
    if(resetn == 1'b0) begin
        reg_mscratch <= 32'b0;
    end else if(csr_write & csr_address == `RVM_SCU_ADDR_MSCRATCH) begin
        reg_mscratch <= csr_wdata;
    end
end

//
// MCYCLE register.
reg [63:0]  reg_mcycle;
always @(posedge clk or negedge resetn) begin : p_scu_mcycle
    if(resetn == 1'b0) begin
        reg_mcycle <= 32'b0;
    end else if(csr_write & csr_address == `RVM_SCU_ADDR_MCYCLE) begin
        reg_mcycle <= {reg_mcycle[63:32],csr_wdata};
    end else if(csr_write & csr_address == `RVM_SCU_ADDR_MCYCLEH) begin
        reg_mcycle <= {csr_wdata, reg_mcycle[31: 0]};
    end else begin
        reg_mcycle <= reg_mcycle + 1;
    end
end

//
// MINSTRET register.
reg [63:0]  reg_minstret;
wire reg_minstret_stall = core_stall | !instr_retired;
always @(posedge clk or negedge resetn) begin : p_scu_minstret
    if(resetn == 1'b0) begin
        reg_minstret <= 32'b0;
    end else if(csr_write & csr_address == `RVM_SCU_ADDR_MINSTRET) begin
        reg_minstret <= {reg_minstret[63:32],csr_wdata};
    end else if(csr_write & csr_address == `RVM_SCU_ADDR_MINSTRETH) begin
        reg_minstret <= {csr_wdata, reg_minstret[31: 0]};
    end else if(!reg_minstret_stall) begin
        reg_minstret = reg_minstret + 1;
    end
end

//
// MBADADDR Register
reg [31:0] reg_mbadaddr;
always @(posedge clk or negedge resetn) begin: p_scu_mbadaddr
    if(resetn == 1'b0) begin
        reg_mbadaddr <= 32'b0;
    end else if(ld_bad_addr) begin
        reg_mbadaddr <= bad_addr_val;
    end else if (csr_write && csr_address == `RVM_SCU_ADDR_MBADADDR) begin
        reg_mbadaddr <= csr_wdata;
    end
end

//
// MCAUSE Register
reg [31:0] reg_mcause;
always @(posedge clk or negedge resetn) begin: p_scu_mcause
    if(resetn == 1'b0) begin
        reg_mcause  <= 32'b0;  
    end else if(raise_interrupt) begin
        reg_mcause  <= {1'b1,
                       trap_msi ? `RVM_CAUSE_MSI :
                       trap_mti ? `RVM_CAUSE_MTI :
                       trap_mei ? `RVM_CAUSE_MEI :
                       31'b0}; 

    end else if(raise_trap) begin
        reg_mcause  <= {1'b0,
                       trap_iaddr_misalign ? `RVM_CAUSE_IADDR_MISALIGN:
                       trap_iaddr_fault    ? `RVM_CAUSE_IADDR_FAULT   :
                       trap_illegal_instr  ? `RVM_CAUSE_ILLEGAL_INSTR :
                       trap_breakpoint     ? `RVM_CAUSE_BREAKPOINT    :
                       trap_laddr_misalign ? `RVM_CAUSE_LADDR_MISALIGN:
                       trap_laddr_fault    ? `RVM_CAUSE_LADDR_FAULT   :
                       trap_saddr_misalign ? `RVM_CAUSE_SADDR_MISALIGN:
                       trap_saddr_fault    ? `RVM_CAUSE_SADDR_FAULT   :
                       31'b0                                          };
    end
end


//
// MIE Register
// - Register bits declared at the top of the file.
wire [31:0] reg_mie = {20'b0, reg_mie_meie, 3'b0, reg_mie_mtie,3'b0, reg_mie_msie,3'b0};
always @(posedge clk or negedge resetn) begin: p_scu_mie
    if(resetn == 1'b0) begin
        reg_mie_meie <= 1'b0;
        reg_mie_mtie <= 1'b0;
        reg_mie_msie <= 1'b0;
    end else if (csr_write & csr_address == `RVM_SCU_ADDR_MIE) begin
        reg_mie_meie <= csr_wdata[11];
        reg_mie_mtie <= csr_wdata[7];
        reg_mie_msie <= csr_wdata[3];
    end
end

//
// MIP Register
// - Register bits declared at the top of the file.
wire [31:0] reg_mip = {20'b0, reg_mip_meip, 3'b0, reg_mip_mtip,3'b0, reg_mip_msip,3'b0};
always @(posedge clk or negedge resetn) begin: p_scu_mip
    if(resetn == 1'b0) begin
        reg_mip_meip <= 1'b0;
        reg_mip_mtip <= 1'b0;
        reg_mip_msip <= 1'b0;
    end else if (csr_write & csr_address == `RVM_SCU_ADDR_MIP) begin
        reg_mip_meip <= csr_wdata[11] & reg_mie_meie;
        reg_mip_mtip <= csr_wdata[7]  & reg_mie_mtie;
        reg_mip_msip <= csr_wdata[3]  & reg_mie_msie;
    end else begin
        reg_mip_meip <= trap_mei & !raise_interrupt_mei ;
        reg_mip_mtip <= trap_mti & !raise_interrupt_mti ;
        reg_mip_msip <= trap_msi & !raise_interrupt_msi ;
    end
end

//
// MTIMECMP Register
always @(posedge clk or negedge resetn) begin: p_scu_mtime
    if (resetn == 1'b0) begin
        reg_mtimecmp <= 64'hFFFF_FFFF_FFFF_FFFF;
    end else if(csr_write & csr_address == `RVM_SCU_ADDR_MTIMECMP) begin
        reg_mtimecmp <= {reg_mtimecmp[63:32], csr_wdata};
    end else if(csr_write & csr_address == `RVM_SCU_ADDR_MTIMECMPH) begin
        reg_mtimecmp <= {csr_wdata, reg_mtimecmp[31:0]};
    end
end

//
// Assume that the system will operate at a fixed frequency, so use the
// existing cycle counter as the reg_mtime value.
assign reg_mtime = reg_mcycle;
assign trap_mti  = reg_mtimecmp < reg_mtime;

//
// Handle instructions which will access the CSRs.
// ------------------------------------------------------------------------

// Which instruction are we executing?
wire op_csrrw = scu_op == `RVM_SCU_CSRRW;
wire op_csrrs = scu_op == `RVM_SCU_CSRRS;
wire op_csrrc = scu_op == `RVM_SCU_CSRRC;
wire op_csrwi = scu_op == `RVM_SCU_CSRRWI;
wire op_csrsi = scu_op == `RVM_SCU_CSRRSI;
wire op_csrci = scu_op == `RVM_SCU_CSRRCI;

// Writes to & reads from CSR
wire csr_read  = op_csrrw | op_csrrs | op_csrrc | op_csrwi | op_csrsi | op_csrci;
wire csr_write = op_csrrw | op_csrrs | op_csrrc | op_csrwi | op_csrsi | op_csrci;

wire [31:0] arg_csri     = {{27{arg_rs1_addr[4]}}, arg_rs1_addr};

wire [31:0] csr_wdata    = {32{op_csrrw}} &              arg_rs1     |
                           {32{op_csrrs}} & (csr_rdata | arg_rs1)    |
                           {32{op_csrrc}} & (csr_rdata & ~arg_rs1)    |
                           {32{op_csrwi}} &              arg_csri    |
                           {32{op_csrsi}} & (csr_rdata | arg_csri)   |
                           {32{op_csrci}} & (csr_rdata & ~arg_csri)   ;

wire [11:0] csr_address  = {12{csr_read | csr_write}} & arg_imm[11:0];

wire [31:0] csr_rdata = 
    {32{csr_address == `RVM_SCU_ADDR_MISA     }} & reg_misa             |
    {32{csr_address == `RVM_SCU_ADDR_MVENDORID}} & reg_mvendorid        |
    {32{csr_address == `RVM_SCU_ADDR_MARCHID  }} & reg_marchid          |
    {32{csr_address == `RVM_SCU_ADDR_MIMPID   }} & reg_mimpid           |
    {32{csr_address == `RVM_SCU_ADDR_MHARTID  }} & reg_mhartid          |
    {32{csr_address == `RVM_SCU_ADDR_MTVEC    }} & reg_mtvec            |
    {32{csr_address == `RVM_SCU_ADDR_MSCRATCH }} & reg_mscratch         |
    {32{csr_address == `RVM_SCU_ADDR_MIDELEG  }} & reg_mideleg          |
    {32{csr_address == `RVM_SCU_ADDR_MEDELEG  }} & reg_medeleg          |
    {32{csr_address == `RVM_SCU_ADDR_MCAUSE   }} & reg_mcause           |
    {32{csr_address == `RVM_SCU_ADDR_MBADADDR }} & reg_mbadaddr         |
    {32{csr_address == `RVM_SCU_ADDR_MIE      }} & reg_mie              |
    {32{csr_address == `RVM_SCU_ADDR_MIP      }} & reg_mip              |
    {32{csr_address == `RVM_SCU_ADDR_MINSTRET }} & reg_minstret[31: 0]  |
    {32{csr_address == `RVM_SCU_ADDR_MCYCLE   }} & reg_mcycle  [31: 0]  |
    {32{csr_address == `RVM_SCU_ADDR_MINSTRETH}} & reg_minstret[63:32]  |
    {32{csr_address == `RVM_SCU_ADDR_MCYCLEH  }} & reg_mcycle  [63:32]  |
    {32{csr_address == `RVM_SCU_ADDR_MTIME    }} & reg_mtime   [31: 0]  |
    {32{csr_address == `RVM_SCU_ADDR_MTIMEH   }} & reg_mtime   [63:32]  |
    {32{csr_address == `RVM_SCU_ADDR_MTIMECMP }} & reg_mtime   [31: 0]  |
    {32{csr_address == `RVM_SCU_ADDR_MTIMECMPH}} & reg_mtime   [63:32]  |
    {32{csr_address == `RVM_SCU_ADDR_MEPC     }} & reg_mepc             ;

// Writeback to GPR interface
assign wb_val= csr_rdata;

endmodule
