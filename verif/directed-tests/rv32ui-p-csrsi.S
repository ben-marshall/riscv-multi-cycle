
#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32U                    # Define TVM used by program.

#
# Test: CSRSI
# - Behaves the same as CSRSI, but the mask value is
#   taken from a zero extended 5-bit immediate.
# - The original value of the CSR is then put into the rd register.
#
RVTEST_CODE_BEGIN               # Start of test code.

test_01:
    li    x1, 4
    csrw  mbadaddr,x1           # Load 4 into the mbadaddr register
    csrsi mbadaddr, 3           # set low two bits in mbadaddr
    csrrw  x1, mbadaddr, x2     # 
    
    li    x2, 7                 # Expected value of mbadaddr

    bne   x2, x1, fail          # if x2 != x1 then fail.
    J pass

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
