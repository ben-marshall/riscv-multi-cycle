
# `sys_ctrl` Module.

The module responsible for loading and dumping memory via the UART pins, and
starting/stopping/restarting the core.

## Write memory access registers.

- Send the UART byte value `0011_0000` - `0` in ASCII.
  - Read `4` bytes from the UART. With each value:
    - Write each byte to the `mem_addr_counter` starting with the most
      significant one.
  - Read `4` bytes from the UART. With each value:
    - Write each byte to the `mem_data_length` starting with the most
      significant one.

## Loading memory

- Send the UART byte value `0011_0001` - `1` in ASCII.
 - Read `mem_data_length` bytes from the UART. With each value:
   - Write the new byte to the byte-aligned address in `mem_addr_counter`.
   - Increment the `mem_addr_counter` value by one.
   - Decrement the `mem_data_length` register by one.
   - Continue until `mem_data_length` is zero.

## Dumping memory.

- Send the UART byte value `0011_0010` - `2` in ASCII.
 - Read `mem_data_length` bytes from the memory. With each value:
   - Write the byte out to the UART TX.
   - Increment the `mem_addr_counter` value by one.
   - Decrement the `mem_data_length` register by one.
   - Continue until `mem_data_length` is zero.
