
#include "verilated.h"

#ifndef H_AXI_DEVICE
#define H_AXI_DEVICE

/*!
@brief A generic interface class which can model an AXI4 device.
@details Models a generic AXI device and is designed to be used as part of an
    axi_interconnect.
@note This is an abstract class definition and should not be instanced
    directly. It is expected to be implemented by other classes.
*/
class axi_device {
    
    public:
        
        /*!
        @brief Loads a single word from the AXI device.
        @param in address - The address of the data to return. Expected to be
            word aligned. I.e. the low two bits are zero.
        @returns the data at that address.
        */
        virtual vluint32_t load(vluint32_t address) = 0;
        
        /*!
        @brief Store a single word to the AXI device.
        @param in address - The address to store the data at. Expected to be
            word aligned. I.e. the low two bits are zero.
        @param in data - The data to store.
        @returns void
        */
        virtual void store(vluint32_t address, vluint32_t data) = 0;

        /*!
        @brief Instance a new AXI device with the given address range.
        */
        axi_device ( vluint32_t hi_addr, vluint32_t lo_addr) {
            this -> device_addr_hi = hi_addr;
            this -> device_addr_lo = lo_addr;
        }
        
        /*
        @brief Test if an address lies within the mapped range of this device.
        @returns True if yes, False otherwise.
        */
        bool address_hit(vluint32_t address) {
            return this -> device_addr_lo <= address &&
                   address <= this -> device_addr_hi  ;
        }

    protected:

        //! Top address for this device.
        vluint32_t  device_addr_hi;

        //! Bottom address for this device.
        vluint32_t  device_addr_lo;
};

#endif
