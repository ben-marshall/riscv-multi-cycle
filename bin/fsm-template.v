
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

// Port Listings //

);

// STATES //


//-----------------------------------------------------------------------------
// Signals for the %{ }% interface.
//-----------------------------------------------------------------------------

// SIGNALS //

//-----------------------------------------------------------------------------

//
// process: p_ctrl_next_state
//
//      Responsible for computing the next state of the core given the
//      current state.
//
always @(*) begin : p_ctrl_next_state

    // NEXT STATE LOGIC //

end


//
// process: p_ctrl_progress_state
//
//      Responsible for moving to the next state
//
always @(posedge clk, negedge resetn) begin : p_ctrl_progress_state

    // STATE PROGRESSION //

end

endmodule

