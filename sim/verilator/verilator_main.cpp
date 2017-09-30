
#include <iostream>
#include <cstdio>

#include "Vrvm_core_axi4.h"
#include "verilated.h"

#include "verilator_sim.hpp"

int main(int argc, char **argv, char **env) {

    std::cout << "Starting Verilator Simulation..." << std::endl;

    Verilated::commandArgs(argc, argv);

    verilator_sim * sim = new verilator_sim;

    sim -> dump_waves_to("vl_waves.vcd");

    bool result = sim -> run_sim();
    
    delete sim;
    
    std::cout << "Finished with code " << result << std::endl;

    if(result)
        exit(0);
    else
        exit(1);
}
