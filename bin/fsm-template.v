
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
{{signal.direction()}} [{{signal.get_range()}}] {{signal.verilog_name()}}
    {%- if not loop.last -%},{% endif %}
    {% endfor -%}
{%- if not loop.last -%},{%- endif -%}
{% endfor %}

);

//-----------------------------------------------------------------------------
// State variable encodings.
//-----------------------------------------------------------------------------

{% for state in states %}
localparam {{states[state].verilog_name()}} = {{loop.index0}};
{%- endfor %}

//
// Holders for the current and next states.
reg [{{state_var_w}}:0] {{state_var}};
reg [{{state_var_w}}:0] n_{{state_var}};

//-----------------------------------------------------------------------------

{% for interface_name in interfaces %}
{% set interface = interfaces[interface_name]  %}

//-----------------------------------------------------------------------------
// Signal assignments for the {{interface_name}} interface.
//-----------------------------------------------------------------------------

    {% for signal_name  in interface.signals -%}
    {% set signal = interface.signals[signal_name] -%}
    {%- if signal.writable -%}

assign {{signal_name}} =  
    {% for assignment in signal.values -%}
        { {{signal|length}} { {{state_var-}} 
            == 
        {{-assignment.state.verilog_name()-}} } } &  
        {{-assignment.value}}
        {%- if(loop.last) -%}
            ;
        {%- else -%}
            |
        {%- endif %}
    {% endfor %}
    {%- endif %}
    
    {% endfor -%}
{% endfor %}

//-----------------------------------------------------------------------------

//
// process: p_ctrl_next_state
//
//      Responsible for computing the next state of the core given the
//      current state.
//
always @(*) begin : p_ctrl_next_state
case ({{state_var}})

{%- for state_name in states %}
{% set state = states[state_name] %}
    {{state.verilog_name()}}: begin
        {% if state.single_next_state -%}
            n_{{state_var}} = {{state.next_state.verilog_name()}};

        {%- else -%}
            n_{{state_var}} = default_next_state;
            {% for ass in state.next_state %}
            if ({{ass.condition}}) n_{{state_var}} = {{ass.value}};
            {% endfor -%}
        {%- endif %}
    end
{%- endfor %}

    default:
        n_{{state_var}} = {{default_next_state}};

endcase end


//
// process: p_ctrl_progress_state
//
//      Responsible for moving to the next state
//
always @(posedge clk, negedge resetn) begin : p_ctrl_progress_state
    if(!resetn) begin
        {{state_var}} = {{default_next_state}};
    end else begin
        {{state_var}} = n_{{state_var}};
    end
end

endmodule

