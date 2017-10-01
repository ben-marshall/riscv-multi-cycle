
#include <fstream>
#include <iostream>
#include <string>

#include "verilator_sim.hpp"


/*!
@brief Instance a new verilator simulation of the DUT.
*/
verilator_sim::verilator_sim() {
    
    // Create a new instance of the dut.
    this -> dut = new Vrvm_core_axi4;
    
    // Create a new main memory image.
    this -> main_memory = new axi_memory(0xA0000000, 0x80000000, 0xdeadc0de);
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
@brief Set the name of the file coverage data is written to.
@param in filepath - The file to write coverage data to.
*/
void verilator_sim::dump_coverage_to(const char * filepath){
    this -> cov_data_file = filepath;
}
        
        
/*!
@brief Load a hex file into main memory at the supplied offset.
@note This should be done before simulation is started.
*/
void verilator_sim::preload_main_memory(const char *filepath, 
                                        vluint32_t offset){
    std::cout << "Loading main memory with '"<<filepath<<"' at offset "
              << offset << std::endl;
    
    // Open the file for reading.
    std::ifstream hexfile;
    hexfile.open(filepath);

    if(hexfile.is_open()) {

        std::string line;
        vluint32_t  pointer = offset;
        
        // Read the file line by line, each line is a memory word.
        while(getline(hexfile, line)) {
            vluint32_t data = std::stoul(line,nullptr,16);
            
            main_memory -> store(pointer, data);

            pointer += 4;
        }

        hexfile.close();

        std::cout << "Loaded from " << offset << " to " 
                  << pointer << std::endl;

    } else {
        std::cerr << "ERROR: Could not open file for reading: "
                  << filepath << std::endl;
    }
    
}
       

/*!
@brief Set the pass and fail addresses for determining the success
       of the simulation.
*/
void verilator_sim::set_pass_fail_addrs(vluint32_t pass, vluint32_t fail)
{
    this -> pass_address = pass;
    this -> fail_address = fail;
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
    sim_time = 0;

    while (!Verilated::gotFinish()  && 
           sim_time < max_sim_time  &&
           !this -> break_sim_loop  )
    {
        
        if(sim_time > 40) {
            dut -> ARESETn = 1;
        }
        
        // Toggle the clock.
        if(sim_time % (clk_period/2) == 1) {
            dut -> ACLK = ~dut -> ACLK;
            
            // Do we need to update the IO pins?
            if(dut -> ACLK) {
                this -> handle_dut_io();
                this -> check_pass_fail();
            }
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

    dut -> final();

    if(this -> cov_data_file) {
        std::cout << "Writing Coverage Data: "<<this->cov_data_file<< std::endl;
        VerilatedCov::write(this -> cov_data_file);
    }
    
    if(sim_time >= max_sim_time){
        std::cerr << "TIMEOUT" << std::endl;
        return false;
    } else if (sim_passed) {
        return true;
    } else {
        return false;
    }
}


/*!
@brief Responsible for handling all DUT input / output pins.
@return void
@details Called on every *rising* edge of the system clock.
*/
void verilator_sim::handle_dut_io() {

    // AXI read channel.
    
    dut -> M_AXI_ARREADY = 0;
    dut -> M_AXI_AWREADY = 0;
    dut -> M_AXI_WREADY  = 0;
    dut -> M_AXI_RVALID  = 0;
    dut -> M_AXI_BVALID  = 0;

    if(dut -> M_AXI_ARVALID) {
        
        vluint32_t address = dut -> M_AXI_ARADDR & 0xFFFFFFFC;
        vluint32_t data    = main_memory -> load(address);
        
        dut -> M_AXI_ARREADY    = 1;
        dut -> M_AXI_RVALID     = 1;
        dut -> M_AXI_RDATA      = data;
    }

    if(dut -> M_AXI_AWVALID && dut -> M_AXI_WVALID) {
        
        vluint32_t address = dut -> M_AXI_AWADDR & 0xFFFFFFFC;
        
        vluint32_t mask    = ((dut -> M_AXI_WSTRB & 0x8 ? 0xFF : 0x00) << 24) |
                             ((dut -> M_AXI_WSTRB & 0x4 ? 0xFF : 0x00) << 16) |
                             ((dut -> M_AXI_WSTRB & 0x2 ? 0xFF : 0x00) <<  8) |
                             ((dut -> M_AXI_WSTRB & 0x1 ? 0xFF : 0x00) <<  0) ;
        
        vluint32_t new_data= dut -> M_AXI_WDATA;
        vluint32_t old_data= main_memory -> load(address);

        vluint32_t store   = (new_data & mask) | (old_data & ~mask);

        main_memory -> store ( address, store);
        
        dut -> M_AXI_AWREADY    = 1;
        dut -> M_AXI_WREADY     = 1;
        dut -> M_AXI_BVALID     = 1;
    }

}
        
/*!
@brief Check if the pass/fail addresses are present in the DUT.
@return void
*/
void verilator_sim::check_pass_fail() {

    if(dut -> M_AXI_ARVALID) {
        if(dut -> M_AXI_ARADDR  == this -> pass_address) {
            
            std::cout << "Pass address seen!"<<std::endl;
            this -> break_sim_loop  = true;
            this -> sim_passed      = true;

        } else if(dut -> M_AXI_ARVALID &&
                  dut -> M_AXI_ARADDR  == this -> fail_address) {

            std::cout << "Fail address seen!"<<std::endl;
            this -> break_sim_loop  = true;
            this -> sim_passed      = false;

        }
    }
}



/*!
@brief Clean up a completed simulation of the DUT
*/
verilator_sim::~verilator_sim() {
    
    delete this -> dut;
    delete this -> main_memory;
}
