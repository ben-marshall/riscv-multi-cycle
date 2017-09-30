
#include <iostream>

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
@brief If called, wave dumping is turned on and sent to the supplied
       file path.
@param in filepath - The file to write waves to.
*/
void verilator_sim::dump_waves_to(const char * filepath){
    
    this -> wave_tracing    = true;
    this -> wave_trace_file = filepath;
}

        
/*!
@brief Run the simulation to completion.
@returns True if the sim succeded or False if it failed.
*/
bool verilator_sim::run_sim(){

    Verilated::traceEverOn(this -> wave_tracing);

    if(this -> wave_tracing) {
        this -> wave_dump = new VerilatedVcdC;
        this -> dut -> trace(this->wave_dump, 99);
        this -> wave_dump -> open(this -> wave_trace_file);

        std::cout << "Waves will be dumped to: " 
                  << this->wave_trace_file 
                  << std::endl;
    }
    
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
        
        // Update the wavedump file.
        if(this -> wave_tracing) {
            this -> wave_dump -> dump(this -> sim_time);
        }

        // Increment simulation time.
        sim_time ++;
    }
    
    // Close the wave tracer if need be.
    if(this -> wave_tracing) {
        this -> wave_dump -> close();
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
