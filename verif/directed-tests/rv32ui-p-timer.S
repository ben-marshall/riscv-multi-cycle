
#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32U                    # Define TVM used by program.

#define MTVEC       0x305
#define MTIMECMP    0xFF0
#define MTIMECMPH   0xFF1
#define MIE         0x304

#
# Timer test:
# Used to make sure we can trigger timer interrupts.
RVTEST_CODE_BEGIN               # Start of test code.

test_setup:
    la      x1, mtimer_handler  # address of the handler.
    csrw    MTVEC, x1           # Put the address of the handler in mtvec

    li      x2, 0x40            # Load 4*16 into.
    csrw    MTIMECMPH, x0        # Load mtimecmph with 0
    csrw    MTIMECMP , x2        # Load mtimecmp with x2

    li      x3, 1 << 7          # Load bitmask
    csrs    MIE, x3             # Enable the mtimer interrupt

    li      x4, 0x20
    loop_wait:                  # Spin round waiting for the interrupt.
        addi x4,x4,-1
        bne x4,x0, loop_wait

    J fail

RVTEST_CODE_END                 # End of test code.


mtimer_handler:                 # Routine which will handle the interrupt.
    csrci   MIE, -1             # Disable all interrupts.
    li      x5, 0xFFFF
    li      x3, 1 << 7          # Load bitmask
    csrc    MIE, x3             # Clear the mtimer interrupt
    J pass

pass:
        RVTEST_PASS             # Signal success.

fail:
        RVTEST_FAIL

# Input data section.
# This section is optional, and this data is NOT saved in the output.
.data
        .align 3
testdata:
        .dword 41

# Output data section.
RVTEST_DATA_BEGIN               # Start of test output data region.
        .align 3
result:
        .dword -1
RVTEST_DATA_END                 # End of test output data region.
