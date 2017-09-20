//
// RISCV multi-cycle implementation.
//
// Module: sram
//
// Description: A variable size SRAM module with load-file-on-reset function.
//
//

module sram(
    input   wire    [255*8:0] memfile,
    input   wire              gclk,       // Global clock signal
    input   wire              resetn,     // Asynchronous active low reset.
    input   wire [addr_w-1:0] addr,       // Address lines
    output  reg  [data_w-1:0] rdata,      // Read data lines
    input   wire [data_w-1:0] wdata,      // Write data lines
    input   wire  [3:0]       b_en,       // Chip Enable
    input   wire              w_en,       // write enable
    output  wire              stall,      // Stall signal
    output  reg               error       // error signal
);

parameter   addr_w  = 32;    // 32 bit address bus.
parameter   data_w  = 32;    // 32 bit word size.
parameter   size    = 8192;  // Size of the memory in words.

// Index into the memory.
wire [addr_w-1:0] addr_idx;

assign addr_idx = addr >> (data_w <= 32? 2 : 3);

// Used for iterating over the memory elements.
integer i;

// Storage for the actual memory elements.
reg  [data_w-1:0] memory [0: size-1];

// Currently requested data.
reg  [data_w-1:0] n_output_data;

// Never stall for now.
assign stall = 1'b0;

// Continously extract the requested data
always @(*) begin
    
    error = 1'b0;

    if(addr < size) begin
        n_output_data = memory[addr_idx];
    end else if(resetn) begin
        // This address is out of range!
        $display("ERROR: Requested read addr %h out of range.", addr);
        error = 1'b1;
    end
end

always @(posedge gclk) begin : do_writes
if(|b_en && w_en == 1'b1) begin
  if(addr < size) begin
    memory[addr_idx][31:24] = b_en[3] ? wdata[31:24] : memory[addr_idx][31:24];
    memory[addr_idx][23:16] = b_en[2] ? wdata[23:16] : memory[addr_idx][23:16];
    memory[addr_idx][15: 8] = b_en[1] ? wdata[15: 8] : memory[addr_idx][15: 8];
    memory[addr_idx][ 7: 0] = b_en[0] ? wdata[ 7: 0] : memory[addr_idx][ 7: 0];
  end else if(resetn) begin
      // This address is out of range!
      $display("ERROR: Requested write addr %h out of range.", addr);
      error = 1'b1;
  end
end
end


// present read data on each cycle.
always @(posedge gclk, negedge resetn) begin
    if(resetn == 1'b0) begin
        rdata = {data_w{1'b0}};
    end else if(|b_en == 1'b1) begin
        // Only perform the read if b_en and we are not being written to.
        rdata = n_output_data;
    end
end

// Intially, set all elements of the memory to x and load the memory file (if any)
// when coming out of reset.
initial begin
    n_output_data = 32'b0;
    
    for(i = 0; i < size; i = i + 1) begin
        memory[i] = {data_w{1'bx}};
    end

end

// Load the memory file coming out of reset.
initial @(posedge resetn) begin
    if(memfile != "") begin
        $display("In Reset -> Loading memory file: %s", memfile);
        $readmemh(memfile, memory, 0, size-1);
    end else begin
        $display("No memory file specified: Memory will be blank.");
    end
end


endmodule
