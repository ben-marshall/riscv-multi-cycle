
#include <iostream>
#include <cstdio>

#include "Vrvm_core_axi4.h"
#include "verilated.h"

int main(int argc, char **argv, char **env) {
    
    // Current simulation time.
    vluint64_t          sim_time = 0;
    const vluint64_t    max_time = 1000;

    std::cout << "Starting Verilator Simulation..." << std::endl;

    Verilated::commandArgs(argc, argv);
    Vrvm_core_axi4 * top = new Vrvm_core_axi4;

    // Initial input signal values.
    top -> ARESETn  = 0;
    top -> ACLK     = 0;

    while (!Verilated::gotFinish() && sim_time < max_time) {
        
        if(sim_time > 40) {
            top -> ARESETn = 1;
        }

        if(sim_time % 10 == 1) {
            top -> ACLK = ~top -> ACLK;
        }

        // Re-evaluate the simulation module.
        top->eval();

        // Increment simulation time.
        sim_time ++;
    }
    
    if(sim_time >= max_time){
        std::cout << "Simulation Complete. TIMEOUT" << std::endl;
    } else {
        std::cout << "Simulation Complete." << std::endl;
    }
    
    delete top;
    exit(0);
}
