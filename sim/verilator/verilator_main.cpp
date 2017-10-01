
#include <iostream>
#include <cstdio>

#include "Vrvm_core_axi4.h"
#include "verilated.h"

#include "verilator_sim.hpp"

int main(int argc, char **argv, char **env) {

    if(argc != 6) {
        std::cout 
            << "Usage: " << argv[0] 
            << " <waves file> <memory file> <pass addr> <fail addr> <cov file>"
            << std::endl;
        exit(1);
    }

    std::cout << "Starting Verilator Simulation..." << std::endl;

    Verilated::commandArgs(argc, argv);

    verilator_sim   * sim = new verilator_sim;

    char            * waves_file = argv[1];
    char            * mem_file   = argv[2];
    vluint32_t        pass_addr  = std::stoul(argv[3],nullptr,16);
    vluint32_t        fail_addr  = std::stoul(argv[4],nullptr,16);
    char            * cov_file   = argv[5];

    std::cout << "Pass address: " << pass_addr << " " << argv[3] << std::endl;
    std::cout << "Fail address: " << fail_addr << " " << argv[4] << std::endl;

    sim -> dump_waves_to(waves_file);
    sim -> dump_coverage_to(cov_file);
    sim -> set_pass_fail_addrs(pass_addr, fail_addr);
    sim -> preload_main_memory(mem_file, 0x80000000);

    bool result = sim -> run_sim();
    
    delete sim;
    
    std::cout << "Finished with code " << result << std::endl;
    
    if(result) {
        std::cout << "TEST PASS" << std::endl;
        exit(0);
    } else {
        std::cout << "TEST FAIL" << std::endl;
        exit(1);
    }
}
