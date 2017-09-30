
#include <map>

#include "verilated.h"

#include "axi_device.h"


class axi_memory : public axi_device {

    public:
        
        /*!
        @brief Loads a single word from the AXI memory device.
        @param in address - The address of the data to return. Expected to be
            word aligned. I.e. the low two bits are zero.
        @returns the data at that address.
        */
        virtual vluint32_t load(vluint32_t address);
        
        /*!
        @brief Store a single word to the AXI memory device.
        @param in address - The address to store the data at. Expected to be
            word aligned. I.e. the low two bits are zero.
        @param in data - The data to store.
        @returns void
        */
        virtual void store(vluint32_t address, vluint32_t data);

        
        /*!
        @brief Instance a new AXI memory device.
        @details
        */
        axi_memory( vluint32_t hi_addr, 
                    vluint32_t lo_addr, 
                    vluint32_t default_value);
    
    private:

        //! The internal associative memory array for the device.
    	std::map<vluint32_t, vluint32_t> mem;
        
        //! The default value returned when we hit uninitialised memory.
        vluint32_t  default_return_value;

};
