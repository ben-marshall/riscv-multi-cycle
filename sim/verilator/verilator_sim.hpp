

#include "verilated.h"
#include "verilated_vcd_c.h"

#include "Vrvm_core_axi4.h"

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
        @brief If called, wave dumping is turned on and sent to the supplied
               file path.
        @param in filepath - The file to write waves to.
        */
        void dump_waves_to(const char * filepath);
        
        /*!
        @brief Set the name of the file coverage data is written to.
        @param in filepath - The file to write coverage data to.
        */
        void dump_coverage_to(const char * filepath);

        /*!
        @brief Load a hex file into main memory at the supplied offset.
        @note This should be done before simulation is started.
        */
        void preload_main_memory(const char *filepath, vluint32_t offset);
        
        /*!
        @brief Set the pass and fail addresses for determining the success
               of the simulation.
        */
        void set_pass_fail_addrs(vluint32_t pass, vluint32_t fail);
        
        /*!
        @brief Run the simulation to completion.
        @returns True if the sim succeded or False if it failed.
        */
        bool run_sim();

    private:
        
        //! If set, we exit the simulation loop at the next iteration
        bool            break_sim_loop = false;
        
        //! Did the simulation pass? Otherwise assume failure.
        bool            sim_passed     = false;

        //! If this address is seen then pass the test and stop the simulation.
        vluint32_t        pass_address = 0xFFFFFFFF;

        //! If this address is seen then fail the test and stop the simulation.
        vluint32_t        fail_address = 0xFFFFFFFF;
        
        //! Acts as a complete memory space for the test.
    	axi_memory      * main_memory;

        //! The design under test.
        Vrvm_core_axi4  * dut;
        
        //! How many simulation ticks have we performed.
        vluint64_t      sim_time;
        
        //! Maximum number of simulation ticks before we quit.
        vluint64_t      max_sim_time = 100000;

        //! Period of the system clock in simulation ticks.
        vluint64_t      clk_period  = 20;
    
        //! Should wave tracing be turned on for the simulation?
        bool            wave_tracing = false;

        //! Given wave_tracing == true, dump waves to this file.
        const char *    wave_trace_file = nullptr;

        //! Where we write coverage database information to.
        const char *    cov_data_file = nullptr;

        //! Verilator wave tracer instance
        VerilatedVcdC * wave_dump;

        /*!
        @brief Responsible for handling all DUT input / output pins.
        @return void
        @details Called on every *rising* edge of the system clock.
        */
        void            handle_dut_io();
        
        /*!
        @brief Check if the pass/fail addresses are present in the DUT.
        @return void
        */
        void            check_pass_fail();
};

#endif
