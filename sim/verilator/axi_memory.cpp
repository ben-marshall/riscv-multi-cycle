
#include <iostream>

#include "axi_memory.h"

/*!
@brief Instance a new AXI memory device.
@details
*/
axi_memory::axi_memory ( vluint32_t hi_addr, 
                         vluint32_t lo_addr,
                         vluint32_t default_value)
: axi_device(hi_addr, lo_addr){
    this -> default_return_value = default_value;
}

        
/*!
@brief Loads a single word from the AXI device.
@param in address - The address of the data to return. Expected to be
    word aligned. I.e. the low two bits are zero.
@returns the data at that address.
*/
vluint32_t axi_memory::load(vluint32_t address) {
    if(address_hit(address)) {
        return mem[address & 0xFFFFFFFC];
    } else {
        std::cerr << "ERROR: address "<<address<< " is not in the mapped range of this device: <" << this->device_addr_lo <<","<<this->device_addr_hi<<">"<<std::endl;
    }
}


/*!
@brief Store a single word to the AXI device.
@param in address - The address to store the data at. Expected to be
    word aligned. I.e. the low two bits are zero.
@param in data - The data to store.
@returns void
*/
void axi_memory::store(vluint32_t address, vluint32_t data) {
    if(address_hit(address)) {
        mem[address & 0xFFFFFFFC] = data;
    } else {
        std::cerr << "ERROR: address "<<address<< " is not in the mapped range of this device: <" << this->device_addr_lo <<","<<this->device_addr_hi<<">"<<std::endl;
    }
}
