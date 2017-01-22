#!/bin/bash

#
# Script responsible for gathering hex files ready for testing.
# Compiled hex files are pulled in for testing from the riscv-tools
# directory.
#

source_riscv_tests()
{
    TEST_SUBSET=rv32ui-p-
    TEST_HEX_FILES=$RISCV/riscv-tests/build/isa
    TEST_FOLDER=$RVM_HOME/verif/isa-tests/hex
    DIS_FOLDER=$RVM_HOME/verif/isa-tests/dis

    if [ -d $TEST_HEX_FILES ] ; then
        echo "Setting up test files..."
    else
        echo "ERROR: source test hex folder does not exist."
        echo "    $TEST_HEX_FILES"
        return 1
    fi

    rm -rf $TEST_FOLDER
    mkdir -p $TEST_FOLDER
    mkdir -p $DIS_FOLDER

    cp -f $TEST_HEX_FILES/*$TEST_SUBSET*.hex $TEST_FOLDER/.
    cp -f $TEST_HEX_FILES/*$TEST_SUBSET*.dump $DIS_FOLDER/.

    FILE_LIST=`ls $TEST_FOLDER`
    for HEX in $FILE_LIST
    do
        $RVM_HOME/bin/hexmem-refactor.py $TEST_FOLDER/$HEX 4
    done

    echo "Setup Input File Tests in $TEST_FOLDER"
    ls $TEST_FOLDER
    return 0
}
