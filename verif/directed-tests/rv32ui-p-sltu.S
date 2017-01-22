
#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32U                    # Define TVM used by program.

RVTEST_CODE_BEGIN               # Start of test code.

test_setup_code:
    li x1, 0
    li x2, 1
    li x3, 55
    li x4, -1
    li x5, 100
    li x6, -1000

test_01:
    sltu x8, x1, x2             # 0 < 1 - expect true
    beq  x8, x0, fail

test_02:
    sltu x8, x2, x1             # 1 < 0 - expect false
    bne  x8, x0, fail

test_03:
    sltu x8, x3, x4             # 55 < -1 - expect true
    beq  x8, x0, fail

test_04:
    sltu x8, x4, x3             # -1 < 55 - expect false
    bne  x8, x0, fail

test_05:
    sltu x8, x4, x6             # -1 < -1000 - expect false
    bne  x8, x0, fail

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
