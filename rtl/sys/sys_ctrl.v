
//
// RISCV multi-cycle implementation.
//
// Module:      sys_ctrl
//
// Description: Responsible for setting up the system at boot time.
//              - Recieving memory images via UART.
//              - Dumping memory to UART.
//              - Starting / Stopping the core.
//

`include "rvm_constants.v"

module sys_ctrl(

input  wire         clk         , // Top level system clock input.
input  wire         resetn      , // Asynchronous active low reset.

input  wire         uart_rxd    , // UART Recieve.
output wire         uart_txd    , // UART Transmit.

output wire         core_en     , // Core enable signal.
output wire         core_reset  , // Core reset signal.

output wire         mem_bus_ctrl, // 0 = sys_ctrl, 1 = core.

output wire [27:0]  app_addr         , // Quad word aligned address.
output wire [2:0]   app_cmd          , // 000 = write, 001 = read
output wire         app_en           , // Initiate a new request. (addr,cmd)
output wire [127:0] app_wdf_data     , // Data to be written.
output wire         app_wdf_end      , // End of data to write.
output wire [15:0]  app_wdf_mask     , // Byte enable write data lines.
output wire         app_wdf_wren     , // Write enable line.
input  wire         app_wdf_rdy      , // Write data accepted.
input  wire [127:0] app_rd_data      , // Read data value.
input  wire         app_rd_data_end  , // End of data being read.
input  wire         app_rd_data_valid, // Data being read is valid.
input  wire         app_rdy            // Current request accpeted.
);

//
// FSM State encodings.
localparam CTRL_POST_RESET  = 4'd0; // Post reset / setup state.
localparam CTRL_READY       = 4'd1; // Ready for a new command.
localparam CTRL_LD_A_3      = 4'd2;
localparam CTRL_LD_A_2      = 4'd3;
localparam CTRL_LD_A_1      = 4'd4;
localparam CTRL_LD_A_0      = 4'd5;
localparam CTRL_LD_D_3      = 4'd6;
localparam CTRL_LD_D_2      = 4'd7;
localparam CTRL_LD_D_1      = 4'd8;
localparam CTRL_LD_D_0      = 4'd9;
localparam CTRL_LOAD_MEM    = 4'd10;
localparam CTRL_DUMP_MEM    = 4'd11;

localparam CMD_SETUP        = 8'b0011_0000;
localparam CMD_LOAD         = 8'b0011_0001;
localparam CMD_DUMP         = 8'b0011_0010;

//----------------------------------------------------------------------------

//
// Current and next control FSM states.
reg  [3:0]  ctrl_state;
reg  [3:0]  n_ctrl_state;

wire        mem_addr_counter_inc;// Increment mem_addr_counter.
reg  [31:0] mem_addr_counter;   // Address counter for loading/dumping memory.

wire        mem_data_length_dec;// Decrement mem_data_length
reg  [31:0] mem_data_length;    // Length of the memory segment to load/dump.

reg         p_uart_rx_valid;
wire        uart_rx_en    ; // Recieve enable
wire        uart_rx_brk   ; // Did we get a BREAK message?
wire        uart_rx_valid ; // Valid data recieved and available.
wire        uart_rx_pvalid = !p_uart_rx_valid && uart_rx_valid;
wire [7:0]  uart_rx_data  ; // The recieved data.

wire        uart_tx_busy  ; // Module busy sending previous item.
wire        uart_tx_en    ; // Valid data recieved and available.
wire [7:0]  uart_tx_data  ; // The recieved data.


//----------------------------------------------------------------------------

assign app_addr    = mem_addr_counter[31:4];
assign app_cmd     = {2'b0, ctrl_state != CTRL_LOAD_MEM};
assign app_wdf_data= {119'b0, uart_rx_data} << {mem_addr_counter[3:0],3'b0}; 
assign app_wdf_end = 1'b1;
assign app_wdf_mask= 16'b1 << mem_addr_counter[3:0];
assign app_wdf_wren= ctrl_state == CTRL_LOAD_MEM;

assign uart_tx_data= (app_rd_data >> {mem_addr_counter[3:0],3'b0});
assign uart_tx_en  = app_rd_data_valid;
assign uart_rx_en  = !uart_rxd;

assign app_en = (ctrl_state == CTRL_LOAD_MEM && uart_rx_valid) ||
                (ctrl_state == CTRL_DUMP_MEM && !uart_tx_busy && !app_rdy);

assign mem_addr_counter_inc = app_rdy;
assign mem_data_length_dec  = app_rdy;

//----------------------------------------------------------------------------

//
// Computes the next state of the control FSM.
always @(*) begin : p_sys_ctrl_fsm_next
n_ctrl_state <= CTRL_READY;

case(ctrl_state)
    CTRL_POST_RESET : begin 
        n_ctrl_state <= CTRL_READY;
    end

    CTRL_READY      : begin
        if(uart_rx_valid && uart_rx_data == CMD_LOAD) begin
            n_ctrl_state <= CTRL_LOAD_MEM;
        end else if(uart_rx_pvalid && uart_rx_data == CMD_DUMP) begin
            n_ctrl_state <= CTRL_DUMP_MEM;
        end else if(uart_rx_pvalid && uart_rx_data == CMD_SETUP)begin
            n_ctrl_state <= CTRL_LD_A_3; // Load mem registers.
        end else begin
            n_ctrl_state <= CTRL_READY;
        end
    end
    
    CTRL_LD_A_3 : n_ctrl_state <= uart_rx_pvalid ? CTRL_LD_A_2 : CTRL_LD_A_3;
    CTRL_LD_A_2 : n_ctrl_state <= uart_rx_pvalid ? CTRL_LD_A_1 : CTRL_LD_A_2;
    CTRL_LD_A_1 : n_ctrl_state <= uart_rx_pvalid ? CTRL_LD_A_0 : CTRL_LD_A_1;
    CTRL_LD_A_0 : n_ctrl_state <= uart_rx_pvalid ? CTRL_LD_D_3 : CTRL_LD_A_0;
    CTRL_LD_D_3 : n_ctrl_state <= uart_rx_pvalid ? CTRL_LD_D_2 : CTRL_LD_D_3;
    CTRL_LD_D_2 : n_ctrl_state <= uart_rx_pvalid ? CTRL_LD_D_1 : CTRL_LD_D_2;
    CTRL_LD_D_1 : n_ctrl_state <= uart_rx_pvalid ? CTRL_LD_D_0 : CTRL_LD_D_1;
    CTRL_LD_D_0 : n_ctrl_state <= uart_rx_pvalid ? CTRL_READY  : CTRL_LD_D_0;

    CTRL_LOAD_MEM : begin
        n_ctrl_state = mem_data_length == 0 ? CTRL_READY : CTRL_DUMP_MEM;
    end

    CTRL_DUMP_MEM : begin
        n_ctrl_state = mem_data_length == 0 ? CTRL_READY : CTRL_DUMP_MEM;
    end

endcase

end


//
// Responsible for progressing the FSM.
always @(posedge clk, negedge resetn) begin: p_sys_ctrl_fsm_progress
    if(!resetn) begin
        ctrl_state <= CTRL_POST_RESET;
    end else begin
        ctrl_state <= n_ctrl_state;
    end
end

//----------------------------------------------------------------------------

//
// Handles loading, storing and incrementing the mem addr counter
always @(posedge clk, negedge resetn) begin : reg_mem_addr_ctrl
    if(!resetn) begin
        mem_addr_counter <= 32'b0;
    end else if(ctrl_state == CTRL_LD_A_3 && uart_rx_pvalid) begin
        mem_addr_counter <= {uart_rx_data           ,
                             mem_addr_counter[24:16],
                             mem_addr_counter[15: 8],
                             mem_addr_counter[ 7: 0]};

    end else if(ctrl_state == CTRL_LD_A_2 && uart_rx_pvalid) begin
        mem_addr_counter <= {mem_addr_counter[31:25],
                             uart_rx_data           ,
                             mem_addr_counter[15: 8],
                             mem_addr_counter[ 7: 0]};

    end else if(ctrl_state == CTRL_LD_A_1 && uart_rx_pvalid) begin
        mem_addr_counter <= {mem_addr_counter[31:25],
                             mem_addr_counter[24:16],
                             uart_rx_data           ,
                             mem_addr_counter[ 7: 0]};

    end else if(ctrl_state == CTRL_LD_A_0 && uart_rx_pvalid) begin
        mem_addr_counter <= {mem_addr_counter[31:25],
                             mem_addr_counter[24:16],
                             mem_addr_counter[15: 8],
                             uart_rx_data           };
    
    end else if(mem_addr_counter_inc) begin
        mem_addr_counter <= mem_addr_counter + 32'd1;
    end
end


//
// Handles loading, storing and incrementing the mem data length
always @(posedge clk, negedge resetn) begin : reg_mem_data_length_ctrl
    if(!resetn) begin
        mem_data_length <= 32'b0;
    end else if(ctrl_state == CTRL_LD_D_3 && uart_rx_pvalid) begin
        mem_data_length <= {uart_rx_data          ,
                            mem_data_length[24:16],
                            mem_data_length[15: 8],
                            mem_data_length[ 7: 0]};

    end else if(ctrl_state == CTRL_LD_D_2 && uart_rx_pvalid) begin
        mem_data_length <= {mem_data_length[31:25],
                            uart_rx_data          ,
                            mem_data_length[15: 8],
                            mem_data_length[ 7: 0]};

    end else if(ctrl_state == CTRL_LD_D_1 && uart_rx_pvalid) begin
        mem_data_length <= {mem_data_length[31:25],
                            mem_data_length[24:16],
                            uart_rx_data          ,
                            mem_data_length[ 7: 0]};

    end else if(ctrl_state == CTRL_LD_D_0 && uart_rx_pvalid) begin
        mem_data_length <= {mem_data_length[31:25],
                            mem_data_length[24:16],
                            mem_data_length[15: 8],
                            uart_rx_data          };
    
    end else if(mem_data_length_dec) begin
        mem_data_length <= mem_data_length - 32'd1;
    end
end

always @(posedge clk, negedge resetn) begin: p_prev_uart_valid
    if(!resetn) begin
        p_uart_rx_valid <= 1'b0;
    end else begin
        p_uart_rx_valid <= uart_rx_valid;
    end
end

//----------------------------------------------------------------------------

//
// Module instance for the UART transmitter.
uart_tx i_uart_tx(
.clk      (clk              ), // Top level system clock input.
.resetn   (resetn           ), // Asynchronous active low reset.
.uart_txd (uart_txd         ), // UART transmit pin.
.tx_busy  (uart_tx_busy     ), // Module busy sending previous item.
.tx_enable(uart_tx_en       ), // Valid data recieved and available.
.tx_data  (uart_tx_data     )  // The recieved data.
);


//
// Module instance for the UART reciever
uart_rx i_uart_rx(
.clk       (clk             ), // Top level system clock input.
.resetn    (resetn          ), // Asynchronous active low reset.
.uart_rxd  (uart_rxd        ), // UART Recieve pin.
.recv_en   (uart_rx_en      ), // Recieve enable
.break     (uart_rx_brk     ), // Did we get a BREAK message?
.recv_valid(uart_rx_valid   ), // Valid data recieved and available.
.recv_data (uart_rx_data    )  // The recieved data.
);

endmodule
