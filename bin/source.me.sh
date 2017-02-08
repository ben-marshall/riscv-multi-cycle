
source /etc/environment

export RVM_HOME=`pwd`
export RISCV=/opt/riscv

export PATH=$PATH:$RISCV/bin

echo "RVM_HOME  = $RVM_HOME"
echo "RISCV     = $RISCV"
echo "PATH      = $PATH"

# Copy the (hopefully) pre-compiled hex test files from the riscv tools folder.
source $RVM_HOME/bin/prep-tests.sh
source_riscv_tests

echo "Workspace setup complete."

