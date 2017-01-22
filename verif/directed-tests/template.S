
#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32U                    # Define TVM used by program.

RVTEST_CODE_BEGIN               # Start of test code.
    nop
    nop

test_01:

    li   x1, 0x2
    addi x2, x0, 1
    addi x2, x2, 1

    bne  x2, x1, fail
    beq  x2, x1, pass

    nop
    nop
RVTEST_CODE_END                 # End of test code.

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
