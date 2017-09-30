
#include "Vrvm_core_axi4.h"
#include "verilated.h"

#include "axi_device.h"
#include "axi_memory.h"

#ifndef H_VERILATOR_SIM
#define H_VERILATOR_SIM


/*
@brief Contains everything needed to run a simple verilator simulation.
*/
class verilator_sim {

    public:

        verilator_sim();
        ~verilator_sim();
        
        /*!
        @brief Run the simulation to completion.
        @returns True if the sim succeded or False if it failed.
        */
        bool run_sim();

    private:
        
        //! Acts as a complete memory space for the test.
    	axi_memory      * main_memory;

        //! The design under test.
        Vrvm_core_axi4  * dut;
        
        //! How many simulation ticks have we performed.
        vluint64_t      sim_time;
        
        //! Maximum number of simulation ticks before we quit.
        vluint64_t      max_sim_time = 10000;

        //! Period of the system clock in simulation ticks.
        vluint64_t      clk_period  = 20;
};

#endif
