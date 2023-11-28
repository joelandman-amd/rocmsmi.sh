#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run script as root user.  sudo ..."
  exit
fi

# 1st insert the modules into the kernel
./load_kernel_modules.bash

# 2nd run the rocm_smi_so to extract the binary
# to the local directory "run"
./rocm_smi_so run

# 3rd run the rocm_smi.bin located in run/bin/rocm_smi.bin
run/bin/rocm_smi.bin
