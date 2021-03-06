#!/bin/bash

#
# Script responsible for gathering hex files ready for testing.
# Compiled hex files are pulled in for testing from the riscv-tools
# directory.
#

ELF2HEX=$RISCV/bin/elf2hex
OBJCPY=$RISCV/bin/riscv64-unknown-elf-objcopy
OBJDMP=$RISCV/bin/riscv64-unknown-elf-objdump

build_riscv_tests()
{
    echo "Building RISCV Test programs..."
    cd $RVM_HOME/verif/riscv-tests
    autoconf
    ./configure
    make
    cd $RVM_HOME
    echo "Building RISCV Test programs [DONE]"
}

source_riscv_tests()
{
    echo -n "Setting up ISA test programs..."
    WIDTH=4
    DEPTH=1024
    TEST_HEX_FILES=$RVM_HOME/verif/riscv-tests/isa
    
    HEX=$RVM_HOME/verif/riscv-tests/build/hex
    DIS=$RVM_HOME/verif/riscv-tests/build/dis
    ELF=$RVM_HOME/verif/riscv-tests/build/elf

    rm -rf $HEX $DIS $ELF
    
    mkdir -p $HEX
    mkdir -p $DIS
    mkdir -p $ELF

    cp $TEST_HEX_FILES/rv32ui-p* $ELF/.

    rm $ELF/*.dump

    FILE_LIST=`ls $ELF`
    for ELF_FILE in $FILE_LIST
    do
        $OBJDMP -D $ELF/$ELF_FILE > $DIS/$ELF_FILE.dis
        $OBJCPY --change-addresses=0x80000000 $ELF/$ELF_FILE
        #echo $ELF2HEX 4 8192 $ELF/$ELF_FILE \> $HEX/$ELF_FILE.hex
        $ELF2HEX 4 8192 $ELF/$ELF_FILE > $HEX/$ELF_FILE.hex
    done

    echo " [DONE]"
}
