
# Core Feature List

A short description of the main features which the core implements.

---

- Single issue, multi-cycle, in-order CPU. It's not fast!
- Implements the RV32UI instruction set architecture.
- Single AXI4 bus master interface for instructions and data.
 - Easy to integrate into a larger design.
- Designed to be very small and easy to fit into an FPGA design.
 - Multi-cycle micro-architecture allows for maximum logic sharing at the
   expense of performance.
- Free!
