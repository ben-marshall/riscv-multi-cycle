
#include "verilator_sim.hpp"


/*!
@brief Instance a new verilator simulation of the DUT.
*/
verilator_sim::verilator_sim() {
    
    // Create a new instance of the dut.
    this -> dut = new Vrvm_core_axi4;
    
    // Create a new main memory image.
    this -> main_memory = new axi_memory(2^32-1, 0, 0xdeadc0de);
}


        
/*!
@brief Run the simulation to completion.
@returns True if the sim succeded or False if it failed.
*/
bool verilator_sim::run_sim(){
    
    // Initial input signal values.
    dut -> ARESETn  = 0;
    dut -> ACLK     = 0;

    while (!Verilated::gotFinish() && sim_time < max_sim_time) {
        
        if(sim_time > 40) {
            dut -> ARESETn = 1;
        }

        if(sim_time % (clk_period/2) == 1) {
            dut -> ACLK = ~dut -> ACLK;
        }

        // Re-evaluate the simulation module.
        dut->eval();

        // Increment simulation time.
        sim_time ++;
    }
    
    
    if(sim_time >= max_sim_time){
        return false;
    } else {
        return true;
    }
}


/*!
@brief Clean up a completed simulation of the DUT
*/
verilator_sim::~verilator_sim() {
    
    delete this -> dut;
    delete this -> main_memory;
}
