
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
{% for interface_name in interfaces %}
{% set interface = interfaces[interface_name]  %}
// Interface: {{interface_name}}
    {% for signal_name  in interface.signals -%}
    {% set signal = interface.signals[signal_name] -%}
{{signal.direction()}} [{{signal.get_range()}}] {{signal_name}}
    {%- if not loop.last -%},{% endif %}
    {% endfor -%}
{%- if not loop.last -%},{%- endif -%}
{% endfor %}

);

// STATES //
{% for state in states %}
localparam {{state}} = {{loop.index0}};
{%- endfor %}

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

